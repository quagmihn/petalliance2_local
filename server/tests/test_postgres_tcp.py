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
            create = Writer().string("tcp-char-" + suffix).u8(1).u8(1).u8(7).u8(1).i32(1).string("").u8(0).bytes()
            r = await send(1655, create, 807)
            self.assertEqual((r.i32(), r.string(), r.i32()), (0, "", 0))
            char_id = r.u32(); self.assertNotEqual(char_id, 2)
            r = await send(3140, Writer().u64(char_id).u32(0).u32(10).bytes(), 3139)
            self.assertEqual(r.u16(), 0); self.assertEqual(r.u64(), char_id)
            r.u32(); r.u32(); self.assertEqual(r.u8(), 1)
            validate_pet(json.loads(r.string()))
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
            self.assertEqual((await send(785, b"", 26)).u16(), 0)
            self.assertEqual((await receive())[0], 404)
            self.assertEqual(await db.pool.fetchval("SELECT status FROM quests WHERE char_id=$1 AND quest_id=10001", char_id), 1)
            self.assertEqual(await db.pool.fetchval("SELECT count(*) FROM quests WHERE char_id=$1 AND quest_id IN (2,10002)", char_id), 2)
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
