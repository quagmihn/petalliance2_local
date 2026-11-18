"""Real TCP + PostgreSQL regression. Combat result here is a protocol fixture;
Android gameplay is validated separately and cannot be inferred from this test.
"""
import asyncio
import json
import os
import secrets
import struct
import unittest
from db.database import Database
from game_socket import handle_client
from pet_config import validate_pet
from protocol import Reader, Writer, frame, xor_payload


class PostgreSQLTCPFlow(unittest.IsolatedAsyncioTestCase):
    async def test_new_account_quest_chain_and_relogin(self):
        dsn = os.getenv("TEST_DATABASE_URL")
        if not dsn:
            self.skipTest("TEST_DATABASE_URL required")
        db = await Database.connect(dsn)
        server = None; writer = None; account_id = None
        connections = set()
        async def accept(r, w):
            task = asyncio.current_task(); connections.add(task)
            try:
                await handle_client(r, w, db)
            finally:
                connections.discard(task)
        try:
            identity = await db.pool.fetchrow("SELECT current_database() name,rolsuper FROM pg_roles WHERE rolname=current_user")
            self.assertEqual(identity["name"], "monster2_test_db")
            self.assertFalse(identity["rolsuper"])
            await db.initialize()
            server = await asyncio.start_server(accept, "127.0.0.1", 0)
            port = server.sockets[0].getsockname()[1]
            reader, writer = await asyncio.open_connection("127.0.0.1", port)
            async def receive():
                length, msg = struct.unpack("<HH", await reader.readexactly(4))
                return msg, await reader.readexactly(length - 4), length
            async def send(msg, body, expected):
                writer.write(frame(msg, xor_payload(body))); await writer.drain()
                actual, response, _ = await asyncio.wait_for(receive(), 3)
                self.assertEqual(actual, expected)
                return Reader(response)
            suffix = secrets.token_hex(8)
            username, token = "tcp-test-" + suffix, secrets.token_hex(16)
            r = await send(2130, Writer().string(username).string(token).bytes(), 2126)
            self.assertEqual(r.i32(), 0)
            account_id = await db.pool.fetchval("SELECT user_id FROM accounts WHERE username=$1", username)
            self.assertNotEqual(account_id, 6)
            binding = Writer().string("tcp-device-" + suffix).string("1").string(secrets.token_hex(16)).bytes()
            self.assertEqual((await send(2211, binding, 2179)).i32(), 0)
            self.assertEqual((await send(2156, binding, 2183)).i32(), 0)
            initial_fashions = [1, 1001, 2001, 3001, 4001, 5001]
            create = (Writer().string("tcp-char-" + suffix).u8(1).u8(1).u8(7).u8(1)
                      .i32(1).string("").u8(len(initial_fashions)))
            for fashion_id in initial_fashions: create.u32(fashion_id)
            create = create.bytes()
            r = await send(1655, create, 807)
            self.assertEqual((r.i32(), r.string(), r.i32()), (0, "", 0))
            char_id = r.u32(); self.assertNotEqual(char_id, 2)
            fashions = await send(2075, b"", 2102)
            self.assertEqual(fashions.u16(), 0)
            fashion_state = json.loads(fashions.string()); fashions.finish()
            self.assertEqual(fashion_state["curFashion"], initial_fashions)
            self.assertTrue(all(fashion_id in group for fashion_id, group in
                                zip(initial_fashions[1:5], fashion_state["bag"][:4])))
            changed_fashions = initial_fashions[:-1] + [0]
            set_fashion = Writer().u8(len(changed_fashions))
            for fashion_id in changed_fashions: set_fashion.u32(fashion_id)
            updated = await send(2121, set_fashion.bytes(), 2109)
            self.assertEqual(updated.u16(), 0)
            self.assertEqual(json.loads(updated.string())["curFashion"], changed_fashions)
            updated.finish()
            self.assertEqual(await db.pool.fetchval(
                "SELECT game_values->>'curfashion' FROM characters WHERE char_id=$1", char_id),
                json.dumps(changed_fashions, separators=(",", ":")))
            r = await send(3140, Writer().u64(char_id).u32(0).u32(10).bytes(), 3139)
            self.assertEqual(r.u16(), 0); self.assertEqual(r.u64(), char_id)
            r.u32(); r.u32(); self.assertEqual(r.u8(), 1)
            starter = json.loads(r.string())
            validate_pet(starter)
            pet_uid = starter["objID"]
            formation = (Writer().u8(1).u32(1).u8(1).u32(pet_uid).u8(0).bytes())
            self.assertEqual((await send(1755, formation, 1756)).u16(), 0)
            formation = (Writer().u8(1).u32(1).u8(1).u32(0).u8(0).bytes())
            self.assertEqual((await send(1755, formation, 1756)).u16(), 1)
            army = await send(1760, b"", 1774)
            self.assertEqual(army.u16(), 0)
            self.assertEqual(json.loads(army.string()), {"1": [pet_uid], "1h": []})

            await db.start_adventure(char_id, 1)
            event_ack = await send(4, Writer().u32(1).u8(2).u32(5).u32(30).bytes(), 5)
            self.assertEqual(event_ack.u16(), 0); event_ack.finish()
            self.assertEqual(await db.pool.fetchval(
                "SELECT count(*) FROM adventure_fired_events WHERE char_id=$1 AND adventure_id=1",
                char_id), 2)
            finish = await send(3082, Writer().u16(12).bytes(), 2995)
            self.assertEqual(finish.u16(), 0)
            awards = [finish.string() for _ in range(finish.u8())]; finish.finish()
            self.assertEqual(awards, [
                '{"elementType":"exp","elementID":0,"num":60}',
                '{"elementType":"item","elementID":10002,"num":1}',
            ])
            self.assertIsNotNone(await db.pool.fetchval(
                "SELECT completed_at FROM character_adventures WHERE char_id=$1", char_id))
            self.assertEqual(await db.pool.fetchval(
                "SELECT exp FROM characters WHERE char_id=$1", char_id), 60)
            self.assertEqual(await db.pool.fetchval(
                "SELECT count FROM inventory WHERE char_id=$1 AND item_id=10002", char_id), 1)
            async def verify_clear_notifications():
                msg, body, _ = await receive()
                self.assertEqual(msg, 473)
                progress = json.loads(Reader(body).string())
                self.assertEqual((progress["level"], progress["exp"]), (2, 60))
                msg, body, _ = await receive()
                stars = Reader(body)
                self.assertEqual((msg, stars.u8()), (1749, 1))
                self.assertEqual(json.loads(stars.string()), {"advID": 1, "star": 12})
                stars.finish()

            await verify_clear_notifications()
            # A retried clear returns the retained ACK payload without granting twice.
            retry = await send(3082, Writer().u16(12).bytes(), 2995)
            self.assertEqual(retry.u16(), 0); self.assertEqual([retry.string() for _ in range(retry.u8())], awards)
            retry.finish()
            await verify_clear_notifications()
            # Starting another run must preserve previously earned stars.
            await db.start_adventure(char_id, 2)
            finished = await send(3078, b"", 3081)
            self.assertEqual((finished.u16(), finished.u32()), (0, 1))
            finished.finish()
            msg, body, _ = await receive()
            stars = Reader(body)
            self.assertEqual((msg, stars.u8()), (1749, 1))
            self.assertEqual(json.loads(stars.string()), {"advID": 1, "star": 12})
            stars.finish()
            self.assertEqual(await db.pool.fetchval(
                "SELECT exp FROM characters WHERE char_id=$1", char_id), 60)
            # ID 4 with no payload is the native SYSPING_ACK; it is intentionally
            # one-way. The following request proves the socket remains usable.
            writer.write(frame(4, b"")); await writer.drain()
            seven_day = await send(391, Writer().u32(1).u32(0).bytes(), 390)
            self.assertEqual(seven_day.u16(), 1); seven_day.finish()
            r = await send(227, b"", 225)
            self.assertEqual((r.u16(), r.string()), (0, "[]")); r.finish()
            self.assertEqual((await send(128, b"", 181)).u16(), 0)
            self.assertEqual((await send(690, Writer().string("sevenDayCompleteTask").bytes(), 721)).u16(), 0)
            self.assertEqual((await send(785, b"", 26)).u16(), 0)
            self.assertEqual((await receive())[0], 404)
            self.assertEqual((await send(400, Writer().u32(1).bytes(), 726)).u16(), 0)
            self.assertEqual((await receive())[0], 404)
            self.assertEqual((await send(136, bytes.fromhex("050000009e86010000000000"), 210)).u16(), 0)
            # Explicit synthetic protocol fixture; never used as runtime proof.
            self.assertEqual((await send(263, Writer().u16(1).vector_strings(["1,0"]).bytes(), 186)).u16(), 0)
            self.assertEqual((await send(400, Writer().u32(10001).bytes(), 726)).u16(), 0)
            msg, body, _ = await receive(); self.assertEqual(msg, 404)
            ntf = Reader(body); children = []
            for _ in range(ntf.u8()):
                children.append(ntf.u32()); ntf.u8(); ntf.u64()
                for _ in range(ntf.u8()): ntf.u32()
            ntf.finish(); self.assertEqual(children, [2, 10002])
            writer.close(); await writer.wait_closed()
            reader, writer = await asyncio.open_connection("127.0.0.1", port)
            self.assertEqual((await send(1684, Writer().i32(char_id).string(token).bytes(), 773)).i32(), 0)
            fashions = await send(2075, b"", 2102)
            self.assertEqual(fashions.u16(), 0)
            self.assertEqual(json.loads(fashions.string())["curFashion"], changed_fashions)
            fashions.finish()
            values = await send(770, Writer().u8(1).string("curfashion").bytes(), 747)
            self.assertEqual(values.u16(), 0)
            self.assertEqual(json.loads(values.string())["curfashion"],
                             json.dumps(changed_fashions, separators=(",", ":")))
            values.finish()
            self.assertEqual((await send(785, b"", 26)).u16(), 0)
            self.assertEqual((await receive())[0], 404)
            self.assertEqual(await db.pool.fetchval("SELECT status FROM quests WHERE char_id=$1 AND quest_id=10001", char_id), 1)
            self.assertEqual(await db.pool.fetchval("SELECT count(*) FROM quests WHERE char_id=$1 AND quest_id IN (2,10002)", char_id), 2)

            # Complete the configured tutorial/Adventure chain against real
            # PostgreSQL rows over the same TCP handler. This is a synthetic
            # test character, never the play character.
            await db.pool.execute("UPDATE characters SET level=2 WHERE char_id=$1", char_id)
            update = Writer().u32(10002).u8(0).u64(1).u8(1).u32(1).bytes()
            self.assertEqual((await send(3133, update, 3132)).u16(), 0)
            self.assertEqual((await send(400, Writer().u32(10002).bytes(), 726)).u16(), 0)
            self.assertEqual((await receive())[0], 404)
            self.assertEqual((await send(2996, Writer().u32(1).bytes(), 3080)).u16(), 0)
            # The second configured map clear advances event-19 story progress.
            self.assertEqual((await send(3082, Writer().u16(12).bytes(), 2995)).u16(), 0)
            self.assertEqual((await receive())[0], 473)
            self.assertEqual((await receive())[0], 1749)
            story_progress = await db.pool.fetchval(
                "SELECT progress FROM quests WHERE char_id=$1 AND quest_id=2", char_id)
            self.assertEqual(json.loads(story_progress) if isinstance(story_progress, str)
                             else story_progress, [1])
            self.assertEqual((await send(400, Writer().u32(2).bytes(), 726)).u16(), 0)
            story_children = Reader((await receive())[1])
            spawned = []
            for _ in range(story_children.u8()):
                spawned.append(story_children.u32()); story_children.u8(); story_children.u64()
                for _ in range(story_children.u8()): story_children.u32()
            story_children.finish()
            self.assertIn(3, spawned)
            guide_progress = await db.pool.fetchval(
                "SELECT progress FROM quests WHERE char_id=$1 AND quest_id=10003", char_id)
            self.assertEqual(json.loads(guide_progress) if isinstance(guide_progress, str)
                             else guide_progress, [0])
            self.assertEqual((await send(400, Writer().u32(10003).bytes(), 726)).u16(), 0)
            self.assertEqual((await receive())[0], 404)
            self.assertEqual(await db.pool.fetchval(
                "SELECT status FROM quests WHERE char_id=$1 AND quest_id=10003", char_id), 1)
            guide_progress = await db.pool.fetchval(
                "SELECT progress FROM quests WHERE char_id=$1 AND quest_id=10003", char_id)
            self.assertEqual(json.loads(guide_progress) if isinstance(guide_progress, str)
                             else guide_progress, [1])
        finally:
            if writer:
                writer.close(); await writer.wait_closed()
            if server:
                server.close(); await server.wait_closed()
            if connections:
                await asyncio.gather(*list(connections))
            if account_id is not None:
                await db.pool.execute("DELETE FROM accounts WHERE user_id=$1", account_id)
            await db.close()
