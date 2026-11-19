import asyncio
import json
import os
import secrets
import socket
import struct
import subprocess
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

from db.database import Database
from game_socket import handle_client
from local_draw import catalog_audit, catalog_report, execute, load_catalog, startup_catalog, test_catalog
from protocol import Reader, Writer, frame, xor_payload


class LocalDrawTests(unittest.IsolatedAsyncioTestCase):
    def test_official_catalog_is_identical_in_test_play_and_production(self):
        reports = []
        for mode, database in (("test", "monster2_test_db"), ("play", "monster2_play_db"),
                               ("production", "monster2_db")):
            with patch.dict(os.environ, {"GAME_ENV": mode, "MONSTER2_EXPECTED_DB": database}):
                reports.append(catalog_report("config/local_draw.json"))
        for key in ("source", "sha256", "machine_ids", "modes", "rewards", "prize_kinds"):
            self.assertEqual([report[key] for report in reports[1:]], [reports[0][key]] * 2)
        self.assertEqual(reports[0]["modes"], {
            1: ["free", "x1", "x10"], 2: ["free", "x1", "x10"], 3: ["x1", "x10"]
        })

    def test_incomplete_catalog_rejected_at_startup(self):
        with tempfile.TemporaryDirectory() as tmp:
            config = Path(tmp) / "incomplete.json"
            config.write_text('{"2":[{"item_id":1,"count":1,"weight":10000}]}')
            with self.assertRaisesRegex(ValueError, "missing enabled machine pools: 1, 3"):
                catalog_report(str(config))
            with socket.socket() as http, socket.socket() as game:
                http.bind(("127.0.0.1", 0))
                game.bind(("127.0.0.1", 0))
                env = dict(os.environ, HTTP_PORT=str(http.getsockname()[1]),
                           GAME_PORT=str(game.getsockname()[1]),
                           DATABASE_URL="postgresql:///monster2_test_db",
                           MONSTER2_DRAW_CATALOG=str(config))
            launcher = Path(__file__).resolve().parents[1] / "run_all.sh"
            rejected = subprocess.run(
                [str(launcher), "test"], env=env, capture_output=True, text=True, timeout=10,
            )
            self.assertNotEqual(rejected.returncode, 0)
            self.assertIn("Invalid Gacha catalog", rejected.stderr)
            self.assertIn("missing enabled machine pools: 1, 3", rejected.stderr)
            self.assertNotIn("http_pid=", rejected.stdout)

    def test_catalog_reference_audit_and_opt_in(self):
        self.assertEqual(catalog_audit(), {
            "machines": 3, "pools": 17, "entries": 27,
            "missing_pools": [], "missing_elements": [],
        })
        with tempfile.TemporaryDirectory() as tmp:
            config = Path(tmp) / "invalid.json"
            config.write_text('{"2":[{"item_id":0,"count":1,"weight":1}]}')
            with patch.dict(os.environ, {"GAME_ENV": "production", "MONSTER2_TEST_DRAW_CATALOG": str(config)}):
                self.assertEqual(test_catalog(), {})
            with self.assertRaisesRegex(ValueError, "invalid local prize"):
                load_catalog(str(config))

    async def test_ten_single_and_free_with_cold_relogin(self):
        dsn = os.getenv("TEST_DATABASE_URL")
        if not dsn:
            self.skipTest("TEST_DATABASE_URL required")
        db = await Database.connect(dsn)
        account_id = None
        try:
            identity = await db.pool.fetchrow(
                "SELECT current_database() AS db, rolsuper FROM pg_roles WHERE rolname=current_user")
            self.assertEqual(identity["db"], "monster2_test_db")
            self.assertFalse(identity["rolsuper"])
            await db.initialize()
            token = secrets.token_hex(24)
            account_id = await db.pool.fetchval(
                "INSERT INTO accounts(username,token) VALUES($1,$2) RETURNING user_id",
                "qa-draw-" + token[:12], token,
            )
            char_id = await db.pool.fetchval(
                """INSERT INTO characters(account_id,world_id,name,level,diamond,game_values)
                   VALUES($1,1,$2,2,3000,'{"qa_independent":true}'::jsonb) RETURNING char_id""",
                account_id, "DrawQA-" + token[:12],
            )

            async def accept(reader, writer):
                await handle_client(reader, writer, db)

            async with await asyncio.start_server(accept, "127.0.0.1", 0) as server:
                port = server.sockets[0].getsockname()[1]

                async def connect():
                    return await asyncio.open_connection("127.0.0.1", port)

                with tempfile.TemporaryDirectory() as tmp:
                    config = Path(tmp) / "local.json"
                    config.write_text('{"2":[{"item_id":1,"count":2,"weight":1}]}')
                    with patch.dict(os.environ, {"GAME_ENV": "test", "MONSTER2_TEST_DRAW_CATALOG": str(config)}):
                        reader, writer = await connect()
                        try:
                            await send(writer, 1684, Writer().i32(char_id).string(token))
                            self.assertEqual((await receive(reader, 773)).i32(), 0)
                            await send(writer, 324, Writer())
                            bulletins = await receive(reader, 320)
                            self.assertEqual(
                                (bulletins.i32(), bulletins.string(), bulletins.i32(), bulletins.u8()),
                                (0, "", 0, 0),
                            )
                            bulletins.finish()
                            with patch.dict(os.environ, {"MONSTER2_DRAW_CATALOG": "config/local_draw.json"}):
                                await send(writer, 1392, Writer().raw(bytes.fromhex("0100010001000000")))
                                self.assertEqual((await receive(reader, 112)).u8(), 1)
                                self.assertEqual(json.loads((await receive(reader, 473)).string())["diamond"], 3000)
                                legacy = await receive(reader, 1561)
                                self.assertEqual((legacy.u16(), legacy.u8()), (0, 1))
                                legacy.string()
                                legacy.finish()
                                await send(writer, 1392, Writer().raw(bytes.fromhex("0100010001000000")))
                                self.assertEqual((await receive(reader, 1561)).u16(), 390)
                            # Isolate the deterministic fixture's inventory and history.
                            await db.pool.execute("DELETE FROM inventory WHERE char_id=$1", char_id)
                            await db.pool.execute("DELETE FROM local_draw_history WHERE char_id=$1", char_id)
                            for choice, free, size, inventory, balance in (
                                (1, 1, 1, 2, 3000), (1, 0, 1, 4, 2712), (2, 0, 10, 24, 124),
                            ):
                                await send(writer, 1392, Writer().u16(2).u16(choice).u16(free).u16(0))
                                sync = await receive(reader, 112)
                                self.assertEqual(sync.u8(), 1)
                                self.assertEqual(json.loads(sync.string()), {"itemID": 1, "num": inventory})
                                self.assertEqual(json.loads((await receive(reader, 473)).string())["diamond"], balance)
                                ack = await receive(reader, 1561)
                                self.assertEqual((ack.u16(), ack.u8()), (0, size))
                                for _ in range(size):
                                    self.assertEqual(json.loads(ack.string()), {
                                        "elementType": "item", "elementID": 1, "num": 2,
                                    })
                                ack.finish()
                                # Real Supreme client sends this blocking
                                # request after rendering a successful result.
                                await send(writer, 1519, Writer())
                                unsupported = await receive(reader, 1396)
                                self.assertEqual(unsupported.u16(), 1)
                                unsupported.finish()
                                if choice == 1 and not free:
                                    # Enough funds to pay twice. A fast retry
                                    # still produces only one paid draw.
                                    await send(writer, 1392, Writer().u16(2).u16(1).u16(0).u16(0))
                                    self.assertEqual((await receive(reader, 1561)).u16(), 1)

                            for free, code in ((1, 390), (0, 1)):
                                await send(writer, 1392, Writer().u16(2).u16(1).u16(free).u16(0))
                                self.assertEqual((await receive(reader, 1561)).u16(), code)
                            await send(writer, 1573, Writer())
                            cooldowns = await receive(reader, 1526)
                            self.assertEqual((cooldowns.u16(), cooldowns.u8()), (0, 2))
                            self.assertEqual((cooldowns.u16(), cooldowns.u64()), (0, 0))
                            self.assertEqual(cooldowns.u16(), 1)
                            self.assertGreater(cooldowns.u64(), 0)
                            cooldowns.finish()
                        finally:
                            writer.close()
                            await writer.wait_closed()

                        reader, writer = await connect()
                        try:
                            await send(writer, 1684, Writer().i32(char_id).string(token))
                            self.assertEqual((await receive(reader, 773)).i32(), 0)
                            await send(writer, 59, Writer())
                            self.assertEqual((await receive(reader, 37)).u16(), 0)
                            sync = await receive(reader, 112)
                            self.assertEqual(sync.u8(), 1)
                            self.assertEqual(json.loads(sync.string()), {"itemID": 1, "num": 24})
                        finally:
                            writer.close()
                            await writer.wait_closed()

            history = await db.pool.fetch(
                """SELECT cost,draw_count,is_free FROM local_draw_history
                   WHERE char_id=$1 ORDER BY draw_id""", char_id)
            self.assertEqual([tuple(row) for row in history], [(0, 1, True), (288, 1, False), (2588, 10, False)])
            self.assertEqual(await db.pool.fetchval(
                "SELECT diamond FROM characters WHERE char_id=$1", char_id), 124)
            machine = startup_catalog("config/local_draw.json")[2][3]
            await db.pool.execute("UPDATE characters SET diamond=100 WHERE char_id=$1", char_id)
            with patch.dict(os.environ, {"GAME_ENV": "production"}):
                code, result = await execute(db, char_id, 3, machine, 1, False)
                self.assertEqual((code, result), (1, None))
            # Choose the last bucket to exercise a configured Pet reference.
            with patch.dict(os.environ, {"GAME_ENV": "test"}), patch("local_draw.randbelow", return_value=9999):
                key = "0" * 20
                code, result = await execute(db, char_id, 3, machine, 1, False, key)
                await db.pool.execute("UPDATE characters SET diamond=100 WHERE char_id=$1", char_id)
                await db.pool.execute(
                    "UPDATE local_draw_history SET created_at=now()-interval '1 hour' WHERE char_id=$1 AND request_key=$2",
                    char_id, key)
                self.assertEqual(await execute(db, char_id, 3, machine, 1, False, key), (1, None))
            self.assertEqual(code, 0)
            awards, wallet, items, pets = result
            self.assertEqual((wallet["diamond"], items, len(pets)), (2, {}, 1))
            pet = json.loads(pets[0])
            self.assertEqual(awards, [{"elementType": "pet", "elementID": 26, "num": 1, "detail": pets[0]}])
            self.assertEqual(await db.pool.fetchval(
                "SELECT pet_template_id FROM pets WHERE char_id=$1 AND pet_uid=$2", char_id, pet["objID"]), 26)
            self.assertEqual(await db.pool.fetchval("SELECT count(*) FROM pets WHERE char_id=$1", char_id), 1)
        finally:
            if account_id is not None:
                await db.pool.execute("DELETE FROM accounts WHERE user_id=$1", account_id)
            await db.close()


async def send(writer, cmd, body):
    writer.write(frame(cmd, xor_payload(body.bytes())))
    await writer.drain()


async def receive(reader, expected):
    async with asyncio.timeout(3):
        length, msg = struct.unpack("<HH", await reader.readexactly(4))
        if msg != expected:
            raise AssertionError(f"expected command {expected}, received {msg}")
        return Reader(await reader.readexactly(length - 4))
