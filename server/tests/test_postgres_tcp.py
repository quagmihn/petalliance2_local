"""Real TCP + PostgreSQL regression. Combat result here is a protocol fixture;
Android gameplay is validated separately and cannot be inferred from this test.
"""
import asyncio
import json
import os
import secrets
import struct
import unittest
from unittest.mock import patch
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
            async def commit_quest(quest_id):
                writer.write(frame(400, xor_payload(Writer().u32(quest_id).bytes())))
                await writer.drain()
                notes = []
                while True:
                    msg, body, _ = await asyncio.wait_for(receive(), 3)
                    if msg == 726:
                        return Reader(body), notes
                    self.assertIn(msg, (112, 3141, 473))
                    notes.append(msg)
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

            # The client's quest 10008 capture guide uses a type-1 wild monster
            # ID (999997..999999), distinct from trainer group 99999/type 5.
            await db.pool.execute(
                "INSERT INTO quests(char_id,quest_id,status,progress) VALUES($1,10008,0,'[0]'::jsonb)",
                char_id)
            wild = await send(136, Writer().u32(1).u32(999999).u32(0).bytes(), 210)
            self.assertEqual(wild.u16(), 0); self.assertEqual(wild.u8(), 1)
            wild_enemy = json.loads(wild.string())
            self.assertEqual((wild_enemy["mID"], wild_enemy["canCatch"]), (999999, True))
            self.assertEqual((wild.u32(), wild.u8()), (8, 0)); wild.finish()
            await db.pool.execute(
                "INSERT INTO inventory(char_id,item_id,count) VALUES($1,2,1) "
                "ON CONFLICT(char_id,item_id) DO UPDATE SET count=EXCLUDED.count", char_id)
            # Deterministic configured-rate boundary: roll 0 is below the
            # Para Ball's positive configured catch chance for this species.
            with patch("secrets.randbelow", return_value=0):
                writer.write(frame(15, xor_payload(Writer().u32(26).u32(2).bytes())))
                await writer.drain()
                msg, body, _ = await receive()
                self.assertEqual(msg, 112)
                item_state = Reader(body); self.assertEqual(item_state.u8(), 1)
                self.assertEqual(json.loads(item_state.string()), {"itemID": 2, "num": 0})
                item_state.finish()
                msg, body, _ = await receive()
                self.assertEqual(msg, 3141)
                captured_uid = Reader(body).u64()
                self.assertGreater(captured_uid, 0)
                pet_body = Reader(body); pet_body.u64(); captured_pet = json.loads(pet_body.string()); pet_body.finish()
                self.assertEqual(captured_pet["pokeID"], 26)
                msg, body, _ = await receive()
                capture_ack = Reader(body)
                self.assertEqual((msg, capture_ack.u16(), capture_ack.u16()), (198, 0, 1))
                captured_payload = json.loads(capture_ack.string())
                self.assertEqual(captured_payload["objID"], captured_uid)
                self.assertEqual(capture_ack.u32(), 0); capture_ack.finish()
            self.assertEqual(await db.pool.fetchval(
                "SELECT count(*) FROM pets WHERE char_id=$1 AND pet_uid=$2 AND pet_template_id=26",
                char_id, captured_uid), 1)
            self.assertIsNone(await db.pool.fetchval(
                "SELECT count FROM inventory WHERE char_id=$1 AND item_id=2", char_id))
            capture_progress = await db.pool.fetchval(
                "SELECT progress FROM quests WHERE char_id=$1 AND quest_id=10008", char_id)
            self.assertEqual(json.loads(capture_progress) if isinstance(capture_progress, str)
                             else capture_progress, [1])
            # A duplicate delivery of the successful request returns the
            # already-created Pet without consuming a second ball or creating
            # another Pet. The client is also patched to disable auto-resend.
            duplicate = await send(15, Writer().u32(26).u32(2).bytes(), 112)
            self.assertEqual(duplicate.u8(), 1)
            self.assertEqual(json.loads(duplicate.string()), {"itemID": 2, "num": 0})
            duplicate.finish()
            msg, body, _ = await receive()
            self.assertEqual(msg, 198)
            duplicate_ack = Reader(body)
            self.assertEqual((duplicate_ack.u16(), duplicate_ack.u16()), (0, 1))
            self.assertEqual(json.loads(duplicate_ack.string())["objID"], captured_uid)
            duplicate_ack.u32(); duplicate_ack.finish()
            self.assertEqual(await db.pool.fetchval(
                "SELECT count(*) FROM pets WHERE char_id=$1 AND pet_template_id=26", char_id), 1)
            # BattleScene transitions can reconnect the TCP socket between the
            # create request and end request. The authenticated character's
            # active encounter must survive that fresh transport session.
            writer.close()
            await writer.wait_closed()
            reader, writer = await asyncio.open_connection("127.0.0.1", port)
            login_after_reconnect = await send(2156, binding, 2183)
            self.assertEqual(login_after_reconnect.i32(), 0)
            wild_end = await send(263, Writer().u16(1).vector_strings(["{\"turn\":1}"]).bytes(), 186)
            self.assertEqual((wild_end.u16(), wild_end.u32()), (0, 8)); wild_end.finish()
            self.assertEqual(await db.pool.fetchval(
                "SELECT state FROM tutorial_battle_sessions WHERE char_id=$1 AND battle_type=1 "
                "ORDER BY battle_id DESC LIMIT 1", char_id), "won")
            self.assertTrue(await db.start_tutorial_wild_battle(
                char_id, "abandoned-session", 999997, 10008, 3))
            self.assertTrue(await db.start_tutorial_wild_battle(
                char_id, "new-session", 999998, 10008, 3))
            states = await db.pool.fetch(
                "SELECT battle_type_id,state FROM tutorial_battle_sessions "
                "WHERE char_id=$1 AND battle_type=1 ORDER BY battle_id DESC LIMIT 2", char_id)
            self.assertEqual([(row["battle_type_id"], row["state"]) for row in states],
                             [(999998, "started"), (999997, "lost")])
            self.assertTrue(await db.finish_tutorial_battle(char_id, "other-session", False))
            self.assertEqual(await db.pool.fetchval(
                "SELECT state FROM tutorial_battle_sessions WHERE char_id=$1 AND battle_type_id=999998",
                char_id), "lost")
            self.assertTrue(await db.start_tutorial_wild_battle(
                char_id, "capture-after-win", 999997, 10008, 3))
            self.assertTrue(await db.finish_tutorial_battle(char_id, "capture-after-win", True))
            post_win_session = await db.pool.fetchrow(
                "SELECT battle_type,battle_type_id,state,capture_attempts_remaining,captured_pet_uid "
                "FROM tutorial_battle_sessions WHERE char_id=$1 ORDER BY battle_id DESC LIMIT 1", char_id)
            self.assertEqual(tuple(post_win_session), (1, 999997, "won", 3, None))
            await db.pool.execute(
                "INSERT INTO inventory(char_id,item_id,count) VALUES($1,2,1) "
                "ON CONFLICT(char_id,item_id) DO UPDATE SET count=EXCLUDED.count", char_id)
            with patch("secrets.randbelow", return_value=0):
                post_win_capture = await db.capture_wild_pet(
                    char_id, "capture-after-win", 26, 2)
            self.assertIsNotNone(post_win_capture)
            self.assertTrue(post_win_capture["caught"])
            self.assertGreater(post_win_capture["pet_uid"], 0)
            wild_progress = await db.pool.fetchval(
                "SELECT progress FROM quests WHERE char_id=$1 AND quest_id=10008", char_id)
            self.assertEqual(json.loads(wild_progress) if isinstance(wild_progress, str)
                             else wild_progress, [1])
            await db.pool.execute(
                "DELETE FROM quests WHERE char_id=$1 AND quest_id=10008", char_id)
            await db.pool.execute(
                "UPDATE characters SET recharge_total=4321 WHERE char_id=$1", char_id)
            recharge_values = await send(770, Writer().u8(1).string("recharge").bytes(), 747)
            self.assertEqual(recharge_values.u16(), 0)
            self.assertEqual(json.loads(recharge_values.string()),
                             {"recharge": {"totalMoney": 4321}})
            recharge_values.finish()

            # Feed a configured EXP potion through the actual TCP protocol. Pet EXP
            # is cumulative and distinct from character EXP and training Stage.
            from client_config import table
            pokemon = table("PokemonInfo")[starter["pokeID"]]
            costs = table("PetAdvanceInfo")[1]["stageCons"][int(pokemon["elementAtt1"]) - 1]["costs"]
            consume_table = table("ConsumeElementInfo")
            await db.pool.execute("UPDATE characters SET level=2,gold=10000,diamond=10000 WHERE char_id=$1", char_id)
            await db.pool.execute(
                "INSERT INTO inventory(char_id,item_id,count) VALUES($1,10002,1) "
                "ON CONFLICT(char_id,item_id) DO UPDATE SET count=EXCLUDED.count", char_id)
            writer.write(frame(516, xor_payload(
                Writer().u32(10002).u32(pet_uid).string("").u32(1).bytes())))
            await writer.drain()
            msg, body, _ = await receive()
            self.assertEqual(msg, 112)
            item_updates = Reader(body)
            self.assertEqual(item_updates.u8(), 1)
            self.assertEqual(json.loads(item_updates.string()), {"itemID": 10002, "num": 0})
            item_updates.finish()
            msg, body, _ = await receive()
            update = Reader(body)
            self.assertEqual((msg, update.u64()), (3141, pet_uid))
            fed_pet = json.loads(update.string()); update.finish()
            self.assertEqual((fed_pet["level"], fed_pet["exp"]), (2, 100))
            msg, body, _ = await receive()
            feed = Reader(body)
            self.assertEqual((msg, feed.u16(), feed.u32(), feed.u32()), (526, 0, 10002, 0))
            self.assertEqual(feed.u8(), 0); feed.finish()
            self.assertEqual(await db.pool.fetchval(
                "SELECT (SELECT count FROM inventory WHERE char_id=$1 AND item_id=10002)", char_id), None)
            pet_state = await db.pool.fetchrow(
                "SELECT level,exp FROM pets WHERE char_id=$1 AND pet_uid=$2", char_id, pet_uid)
            self.assertEqual((pet_state["level"], pet_state["exp"]), (2, 100))

            # Product 201 is configured as one Master Ball for 600 MCash.
            await db.pool.execute("UPDATE characters SET diamond=10000 WHERE char_id=$1", char_id)
            writer.write(frame(577, xor_payload(Writer().u32(201).u32(1).bytes())))
            await writer.drain()
            msg, body, _ = await receive()
            self.assertEqual(msg, 112)
            market_item = Reader(body)
            self.assertEqual(market_item.u8(), 1)
            self.assertEqual(json.loads(market_item.string()), {"itemID": 1, "num": 1})
            market_item.finish()
            msg, body, _ = await receive()
            self.assertEqual(msg, 473)
            market_wallet = json.loads(Reader(body).string())
            self.assertEqual(market_wallet["m_cash"], 9400)
            msg, body, _ = await receive()
            self.assertEqual((msg, Reader(body).u16()), (563, 0))
            self.assertEqual(await db.pool.fetchval(
                "SELECT count FROM inventory WHERE char_id=$1 AND item_id=1", char_id), 1)

            # Exercise the real Stage-up protocol against configured costs in the test DB.
            for cost_id in costs:
                cost = consume_table[cost_id]
                if cost["elementType"] == 3:
                    await db.pool.execute(
                        """INSERT INTO inventory(char_id,item_id,count) VALUES($1,$2,$3)
                           ON CONFLICT(char_id,item_id) DO UPDATE SET count=EXCLUDED.count""",
                        char_id, cost["elementID"], cost["num"])
            before_costs = await db.pool.fetchrow(
                "SELECT gold,diamond FROM characters WHERE char_id=$1", char_id)
            stage_ack = await send(1038, Writer().u32(pet_uid).bytes(), 1032)
            self.assertEqual((stage_ack.u16(), stage_ack.u32(), stage_ack.u16()), (0, pet_uid, 1))
            stage_ack.finish()
            self.assertEqual(await db.pool.fetchval(
                "SELECT training_stage FROM pets WHERE char_id=$1 AND pet_uid=$2", char_id, pet_uid), 1)
            for cost_id in costs:
                cost = consume_table[cost_id]
                if cost["elementType"] == 3:
                    self.assertIsNone(await db.pool.fetchval(
                        "SELECT count FROM inventory WHERE char_id=$1 AND item_id=$2",
                        char_id, cost["elementID"]))
            r = await send(3140, Writer().u64(char_id).u32(0).u32(10).bytes(), 3139)
            self.assertEqual((r.u16(), r.u64()), (0, char_id)); r.u32(); r.u32()
            self.assertEqual(r.u8(), 1)
            upgraded_pet = json.loads(r.string())
            self.assertEqual((upgraded_pet["objID"], upgraded_pet["Stage"],
                              upgraded_pet["level"], upgraded_pet["exp"]), (pet_uid, 1, 2, 100))
            inactive_count = r.u8()
            for _ in range(inactive_count):
                r.string()
            self.assertEqual(r.u32(), inactive_count)
            helper_count = r.u8()
            for _ in range(helper_count):
                r.string()
            r.finish()
            after_costs = await db.pool.fetchrow(
                "SELECT gold,diamond FROM characters WHERE char_id=$1", char_id)
            for cost_id in costs:
                cost = consume_table[cost_id]
                if cost["elementType"] == 1:
                    self.assertEqual(before_costs["gold"] - after_costs["gold"], cost["num"])
                elif cost["elementType"] == 2:
                    self.assertEqual(before_costs["diamond"] - after_costs["diamond"], cost["num"])
            second_stage = await send(1038, Writer().u32(pet_uid).bytes(), 1032)
            self.assertEqual(second_stage.u16(), 1); second_stage.finish()
            self.assertEqual(await db.pool.fetchval(
                "SELECT training_stage FROM pets WHERE char_id=$1 AND pet_uid=$2", char_id, pet_uid), 1)

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
            self.assertEqual((await commit_quest(1))[0].u16(), 0)
            self.assertEqual((await receive())[0], 404)
            self.assertEqual((await send(136, bytes.fromhex("050000009e86010000000000"), 210)).u16(), 0)
            # Explicit synthetic protocol fixture; never used as runtime proof.
            self.assertEqual((await send(263, Writer().u16(1).vector_strings(["1,0"]).bytes(), 186)).u16(), 0)
            writer.write(frame(400, xor_payload(Writer().u32(10001).bytes())))
            await writer.drain()
            reward_messages = []
            while True:
                msg, body, _ = await asyncio.wait_for(receive(), 3)
                reward_messages.append(msg)
                if msg == 726:
                    commit = Reader(body)
                    self.assertEqual(commit.u16(), 0)
                    self.assertEqual(commit.u32(), 10001)
                    quest_awards = [json.loads(commit.string()) for _ in range(commit.u8())]
                    commit.finish()
                    break
            self.assertEqual(reward_messages, [3141, 473, 726])
            self.assertIn({"elementType": "pet", "elementID": 116, "num": 1}, quest_awards)
            self.assertEqual(await db.pool.fetchval(
                "SELECT count(*) FROM pets WHERE char_id=$1 AND pet_template_id=116", char_id), 1)
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
            self.assertEqual((await commit_quest(10002))[0].u16(), 0)
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
            self.assertEqual((await commit_quest(2))[0].u16(), 0)
            story_children = Reader((await receive())[1])
            spawned = []
            for _ in range(story_children.u8()):
                spawned.append(story_children.u32()); story_children.u8(); story_children.u64()
                for _ in range(story_children.u8()): story_children.u32()
            story_children.finish()
            self.assertIn(3, spawned)
            await db.pool.execute(
                "UPDATE quests SET progress='[1]'::jsonb WHERE char_id=$1 AND quest_id=3", char_id)
            item_commit, item_notes = await commit_quest(3)
            self.assertEqual((item_commit.u16(), item_commit.u32()), (0, 3))
            item_awards = [json.loads(item_commit.string()) for _ in range(item_commit.u8())]
            item_commit.finish()
            self.assertEqual(item_notes, [112, 473])
            self.assertIn({"elementType": "item", "elementID": 10003, "num": 30}, item_awards)
            self.assertEqual(await db.pool.fetchval(
                "SELECT count FROM inventory WHERE char_id=$1 AND item_id=10003", char_id), 30)
            child_message, child_body, _ = await receive()
            self.assertEqual(child_message, 404)
            retry_item_commit, _ = await commit_quest(3)
            retry_item_commit.u16(); retry_item_commit.u32()
            retry_awards = [json.loads(retry_item_commit.string())
                            for _ in range(retry_item_commit.u8())]
            retry_item_commit.finish()
            self.assertEqual(retry_awards, item_awards)
            self.assertEqual(await db.pool.fetchval(
                "SELECT count FROM inventory WHERE char_id=$1 AND item_id=10003", char_id), 30)
            guide_progress = await db.pool.fetchval(
                "SELECT progress FROM quests WHERE char_id=$1 AND quest_id=10003", char_id)
            self.assertEqual(json.loads(guide_progress) if isinstance(guide_progress, str)
                             else guide_progress, [0])
            self.assertEqual((await commit_quest(10003))[0].u16(), 0)
            self.assertEqual((await receive())[0], 404)
            self.assertEqual(await db.pool.fetchval(
                "SELECT status FROM quests WHERE char_id=$1 AND quest_id=10003", char_id), 1)
            guide_progress = await db.pool.fetchval(
                "SELECT progress FROM quests WHERE char_id=$1 AND quest_id=10003", char_id)
            self.assertEqual(json.loads(guide_progress) if isinstance(guide_progress, str)
                             else guide_progress, [1])

            # Configured event-18 map-node trainer: map_event 1003 is type 0,
            # whose configured object is MonsterGroupManInfo 2003.
            await db.pool.execute(
                "UPDATE characters SET game_values=game_values || jsonb_build_object('map_lock','4-0') WHERE char_id=$1",
                char_id)
            await db.pool.execute(
                "INSERT INTO quests(char_id,quest_id,status,progress) VALUES($1,1501,0,'[0]')",
                char_id)
            denied = await send(136, Writer().u32(5).u32(99999).u32(0).bytes(), 210)
            self.assertEqual(denied.u16(), 1); denied.finish()
            locked_node = await send(136, Writer().u32(5).u32(2003).u32(0).bytes(), 210)
            self.assertEqual(locked_node.u16(), 1); locked_node.finish()
            await db.pool.execute(
                "UPDATE characters SET game_values=game_values || jsonb_build_object('map_lock','5-0') WHERE char_id=$1",
                char_id)
            node_battle = await send(136, Writer().u32(5).u32(2003).u32(0).bytes(), 210)
            self.assertEqual((node_battle.u16(), node_battle.u8()), (0, 1))
            node_enemy = json.loads(node_battle.string())
            self.assertEqual(node_enemy["mID"], 1001)
            self.assertEqual(node_battle.u32(), 24); node_battle.u8(); node_battle.finish()
            node_end = await send(263, Writer().u16(1).vector_strings(["{\"turn\":1}"]).bytes(), 186)
            self.assertEqual((node_end.u16(), node_end.u32()), (0, 24)); node_end.finish()
            node_progress = await db.pool.fetchval(
                "SELECT progress FROM quests WHERE char_id=$1 AND quest_id=1501", char_id)
            self.assertEqual(json.loads(node_progress) if isinstance(node_progress, str)
                             else node_progress, [1])
            node_update = Writer().u32(1501).u8(0).u64(1).u8(1).u32(1).bytes()
            self.assertEqual((await send(3133, node_update, 3132)).u16(), 0)
            node_commit, _ = await commit_quest(1501)
            self.assertEqual((node_commit.u16(), node_commit.u32(), node_commit.u8()), (0, 1501, 0))
            node_commit.finish()

            await db.pool.execute(
                """INSERT INTO quests(char_id,quest_id,status,progress) VALUES($1,10006,1,'[1]')
                   ON CONFLICT(char_id,quest_id) DO UPDATE SET status=1,progress='[1]'""", char_id)
            await db.pool.execute(
                """INSERT INTO quests(char_id,quest_id,status,progress) VALUES($1,10007,0,'[0]')
                   ON CONFLICT(char_id,quest_id) DO UPDATE SET status=0,progress='[0]'""", char_id)
            group_ack = await send(136, Writer().u32(5).u32(99999).u32(0).bytes(), 210)
            self.assertEqual(group_ack.u16(), 0); self.assertEqual(group_ack.u8(), 1)
            group_enemy = json.loads(group_ack.string())
            self.assertEqual(group_enemy["mID"], 999994)
            self.assertEqual(group_enemy["skill1"], 541)
            self.assertEqual((group_ack.u32(), group_ack.u8()), (37, 0)); group_ack.finish()
            end_ack = await send(263, Writer().u16(1).vector_strings(["{\"turn\":1}"]).bytes(), 186)
            self.assertEqual((end_ack.u16(), end_ack.u32()), (0, 37)); end_ack.finish()
            battle_progress = await db.pool.fetchval(
                "SELECT progress FROM quests WHERE char_id=$1 AND quest_id=10007", char_id)
            self.assertEqual(json.loads(battle_progress) if isinstance(battle_progress, str)
                             else battle_progress, [1])
            self.assertEqual((await commit_quest(10007))[0].u16(), 0)
            child_ntf = Reader((await receive())[1]); spawned = []
            for _ in range(child_ntf.u8()):
                spawned.append(child_ntf.u32()); child_ntf.u8(); child_ntf.u64()
                for _ in range(child_ntf.u8()): child_ntf.u32()
            child_ntf.finish(); self.assertEqual(spawned, [10008])
            self.assertEqual(await db.pool.fetchval(
                "SELECT status FROM quests WHERE char_id=$1 AND quest_id=10007", char_id), 1)
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
