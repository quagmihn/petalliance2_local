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
from game_socket import Session, dispatch, handle_client
from local_draw import (catalog_audit, catalog_report, cooldowns, execute,
                        load_catalog, startup_catalog, test_catalog)
from protocol import Reader, Writer, frame, xor_payload


class LocalDrawTests(unittest.IsolatedAsyncioTestCase):
    def test_private_play_pools_have_machine_specific_categories_and_weights(self):
        from collections import Counter
        from random import Random
        from client_config import table
        from local_draw import parse_catalog
        from pet_config import pokemon

        path, _, machines = startup_catalog("config/local_play_draw.json")
        for machine_id, expected in ((1, {1, 2, 3, 4}), (2, {3, 4, 5, 6}), (3, set())):
            machine = machines[machine_id]
            self.assertEqual({pokemon(prize_id)["rare"] for kind, prize_id, _, _ in machine.prizes
                              if kind == "pet"}, expected)
            self.assertEqual(sum(weight for _, _, _, weight in machine.prizes), 10_000)
            with patch("local_draw.randbelow", side_effect=Random(machine_id).randrange):
                sample = [award for _ in range(2_000) for award in machine.draw(10)]
            counts = Counter((a["elementType"], a["elementID"], a["num"]) for a in sample)
            self.assertEqual(len(counts), len(machine.prizes))
            for kind, prize_id, qty, weight in machine.prizes:
                self.assertAlmostEqual(counts[kind, prize_id, qty] / 20_000, weight / 10_000, delta=0.012)
        self.assertEqual({table("ItemInfo")[i]["itemType"] for _, i, _, _ in machines[3].prizes}, {2})
        raw = json.loads(path.read_bytes())
        raw["machines"]["1"][0]["pet_id"] = 207
        with self.assertRaisesRegex(ValueError, "incompatible rarity"):
            parse_catalog(json.dumps(raw), complete=True)

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

    def test_target_draw_uses_the_resolved_normal_config_and_weights(self):
        from client_config import table
        from pet_config import pokemon
        from reward_config import resolve_award_element

        _, _, machines = startup_catalog("config/target_draw.json")
        self.assertEqual(set(machines), set(table("CapsuleEggInfo")))
        for machine_id, machine in machines.items():
            group_id = table("CapsuleEggInfo")[machine_id]["normalEggAwardIndex"]
            entries = table("CapsuleEggAwardInfo")[group_id]["awardInfoVec"]
            expected = []
            for entry in entries:
                reward = resolve_award_element(entry["awardItemIndex"], entry["awardItemNum"])
                if machine_id == 1 and reward["kind"] == "pet" and pokemon(reward["id"])["rare"] > 4:
                    continue
                expected.append((reward["kind"], reward["id"], reward["num"], entry["rate"]))
            self.assertEqual(machine.prizes, tuple(expected))
            self.assertEqual(sum(prize[3] for prize in machine.prizes),
                             5800 if machine_id == 1 else 10000)
        report = catalog_report("config/target_draw.json")
        self.assertEqual(report["pool_rules"], "target-normal-independent")
        self.assertEqual(report["tutorial"]["pet_id"], 45)

    def test_draw_catalog_rejects_templates_without_a_basic_attack(self):
        from local_draw import parse_catalog

        with self.assertRaisesRegex(ValueError, "Pet template 119 has invalid starting skill"):
            parse_catalog('{"1":[{"pet_id":119,"count":1,"weight":10000}]}')

    def test_local_rarity_bounds_apply_to_each_draw_in_x1_and_x10(self):
        from client_config import table
        from local_draw import parse_catalog
        from pet_config import acquisition_skill_pools

        templates = {}
        for row in table("PokemonInfo").values():
            rarity = row["rarePoint"]
            if rarity not in (4, 5, 6) or rarity in templates:
                continue
            try:
                acquisition_skill_pools(row["id"])
            except ValueError:
                continue
            templates[rarity] = row["id"]
        pool = [{"pet_id": templates[rarity], "count": 1, "weight": weight}
                for rarity, weight in ((4, 2000), (5, 3000), (6, 5000))]
        catalog = parse_catalog(json.dumps({"1": pool, "2": pool}))
        for count in (1, 10):
            with patch("local_draw.randbelow", return_value=1999) as roll:
                self.assertEqual([entry["elementID"] for entry in catalog[1].draw(count)],
                                 [templates[4]] * count)
                roll.assert_called_with(2000)
            with patch("local_draw.randbelow", return_value=9999) as roll:
                self.assertEqual([entry["elementID"] for entry in catalog[2].draw(count)],
                                 [templates[6]] * count)
                roll.assert_called_with(10000)
        with self.assertRaisesRegex(ValueError, "Gold rarity cap"):
            parse_catalog(json.dumps({"1": pool[1:]}))

    async def test_tutorial_panda_is_atomic_and_resumes_after_legacy_draw(self):
        dsn = os.getenv("TEST_DATABASE_URL")
        if not dsn:
            self.skipTest("TEST_DATABASE_URL required")
        db = await Database.connect(dsn)
        account_id = None
        try:
            self.assertEqual(await db.pool.fetchval("SELECT current_database()"), "monster2_test_db")
            await db.initialize()
            token = secrets.token_hex(20)
            account_id = await db.pool.fetchval(
                "INSERT INTO accounts(username,token) VALUES($1,$1) RETURNING user_id", token)
            char, starter = await db.create_character_with_pet(account_id, 1, token[:12], 0, 0, 1)
            char_id = char["char_id"]
            await db.pool.execute(
                """INSERT INTO quests(char_id,quest_id,status,progress) VALUES
                   ($1,10009,0,'[1]'),($1,10010,0,'[0]')""", char_id)
            session = Session(db)
            session.char_id = char_id
            request = bytes.fromhex("0200010001000000")
            with patch.dict(os.environ, {"GAME_ENV": "test", "MONSTER2_DRAW_CATALOG": "config/local_draw.json"}):
                self.assertEqual(await dispatch(session, 1392, request), (1561, b"\x01\x00"))
                await db.pool.execute(
                    "UPDATE quests SET status=1 WHERE char_id=$1 AND quest_id=10009", char_id)
                self.assertEqual(await dispatch(session, 1392, request), (1561, b"\x01\x00"))
                await db.start_adventure(char_id, 1)
                self.assertTrue(await db.start_adventure_battle(
                    char_id, "guide-isolation", 1, 15, 1))
                self.assertTrue(await db.finish_tutorial_battle(char_id, "guide-isolation", True))
                self.assertEqual(await db.pool.fetchval(
                    "SELECT progress FROM quests WHERE char_id=$1 AND quest_id=10010", char_id), "[0]")
                for machine in (1, 2):
                    await db.pool.execute(
                        """INSERT INTO local_draw_history
                           (char_id,machine_id,draw_count,is_free,draw_day,currency,cost,awards,created_at)
                           VALUES($1,$2,1,true,0,'gold',0,'[]',now())""", char_id, machine)
                # A legacy battle could already have written a completed-looking
                # vector without a corresponding draw. The guide must recover.
                await db.pool.execute(
                    "UPDATE quests SET progress='[1]' WHERE char_id=$1 AND quest_id=10010", char_id)
                self.assertEqual((await cooldowns(db, char_id))[2], (0, 0))
                blocked = await dispatch(session, 400, Writer().u32(10010).bytes())
                self.assertEqual(blocked, (726, b"\x01\x00"))
                results = await asyncio.gather(*(dispatch(session, 1392, request) for _ in range(2)))
                draw, replay = sorted(results, key=lambda r: len(r), reverse=True)
                self.assertEqual(replay, (1561, b"\x01\x00"))
                self.assertEqual([msg_id for msg_id, _ in draw], [3141, 473, 1561])
                pet_body = Reader(draw[0][1])
                uid, pet = pet_body.u64(), json.loads(pet_body.string())
                pet_body.finish()
                self.assertEqual((pet["objID"], pet["pokeID"], len(pet["skills"])), (uid, 45, 4))
                result = Reader(draw[-1][1])
                self.assertEqual((result.u16(), result.u8()), (0, 1))
                award = json.loads(result.string())
                self.assertEqual((award["elementType"], award["elementID"], award["num"]), ("pet", 45, 1))
                self.assertEqual(json.loads(award["detail"]), pet)
                result.finish()
                self.assertGreater((await cooldowns(db, char_id))[2][1], 0)
                self.assertEqual(await db.pool.fetchval(
                    "SELECT count(*) FROM pets WHERE char_id=$1 AND pet_template_id=45", char_id), 1)
                self.assertEqual(await db.pool.fetchval(
                    """SELECT count(*) FROM local_draw_history WHERE char_id=$1 AND is_free AND cost=0
                       AND awards @> '[{"elementType":"pet","elementID":45}]'""", char_id), 1)
                self.assertEqual(await db.pool.fetchval(
                    "SELECT progress FROM quests WHERE char_id=$1 AND quest_id=10010", char_id), "[1]")
                relogin = Session(db)
                ack_id, ack = await dispatch(relogin, 1684, Writer().i32(char_id).string(token).bytes())
                self.assertEqual((ack_id, Reader(ack).i32()), (773, 0))
                commit = await dispatch(relogin, 400, Writer().u32(10010).bytes())
                self.assertEqual([msg_id for msg_id, _ in commit], [726, 404])
                await db.start_adventure(char_id, 1)
                self.assertTrue(await db.start_adventure_battle(
                    char_id, "formation-isolation", 1, 15, 1))
                self.assertTrue(await db.finish_tutorial_battle(char_id, "formation-isolation", True))
                self.assertEqual(await db.pool.fetchval(
                    "SELECT progress FROM quests WHERE char_id=$1 AND quest_id=10011", char_id), "[0]")
                await db.pool.execute(
                    "UPDATE quests SET progress='[1]' WHERE char_id=$1 AND quest_id=10011", char_id)
                self.assertEqual(await dispatch(relogin, 400, Writer().u32(10011).bytes()),
                                 (726, b"\x01\x00"))
                members = [starter["pet_uid"], uid]
                save = Writer().u8(1).u32(1).u8(2).u32(members[0]).u32(members[1]).u8(0)
                self.assertEqual(await dispatch(relogin, 1755, save.bytes()), (1756, b"\x00\x00"))
                self.assertEqual(await db.pool.fetchval(
                    "SELECT slot_index FROM pets WHERE char_id=$1 AND pet_uid=$2", char_id, uid), 1)
                cold = Session(db)
                ack_id, ack = await dispatch(cold, 1684, Writer().i32(char_id).string(token).bytes())
                self.assertEqual((ack_id, Reader(ack).i32()), (773, 0))
                ack_id, ack = await dispatch(cold, 1760, b"")
                saved = Reader(ack)
                self.assertEqual((ack_id, saved.u16()), (1774, 0))
                self.assertEqual(json.loads(saved.string()), {"1": members, "1h": []})
                saved.finish()
                formation = await dispatch(relogin, 400, Writer().u32(10011).bytes())
                self.assertEqual([msg_id for msg_id, _ in formation], [726, 404])
        finally:
            if account_id is not None:
                await db.pool.execute("DELETE FROM accounts WHERE user_id=$1", account_id)
            await db.close()

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
