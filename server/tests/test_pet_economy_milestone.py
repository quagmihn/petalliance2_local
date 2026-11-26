import asyncio
import json
import os
import secrets
import tempfile
import unittest
from pathlib import Path
from types import SimpleNamespace
from unittest.mock import patch

from admin.qa_account import run as admin_run, star_materials
from client_config import table
from db.database import Database
from game_socket import Session, dispatch
from pet_config import star_steps
from protocol import Reader, Writer
from recharge_config import normal_families
from vip_config import max_vip, milestone


class PetEconomyConfig(unittest.TestCase):
    def test_target_vip_and_recharge_catalog(self):
        self.assertEqual((max_vip()["id"], max_vip()["viplevel"], max_vip()["recharge"]), (21, 20, 160000))
        self.assertTrue(all(milestone(row, []) for row in range(1, 22)))
        self.assertEqual({(bonus["id"], repeat["id"]) for bonus, repeat in normal_families().values()},
                         {(2, 3), (4, 12), (5, 6), (7, 13), (8, 9), (10, 11)})
        self.assertEqual(len(star_steps(45)), 5)


class PetEconomyTransaction(unittest.IsolatedAsyncioTestCase):
    async def asyncSetUp(self):
        dsn = os.getenv("TEST_DATABASE_URL")
        if not dsn:
            self.skipTest("TEST_DATABASE_URL required")
        self.db = await Database.connect(dsn)
        self.addAsyncCleanup(self.db.close)
        self.assertEqual(await self.db.pool.fetchval("SELECT current_database()"), "monster2_test_db")
        await self.db.initialize()
        tag = "pet-economy-" + secrets.token_hex(6)
        account = await self.db.pool.fetchval(
            "INSERT INTO accounts(username,token) VALUES($1,$2) RETURNING user_id", tag, secrets.token_hex(16))
        self.addAsyncCleanup(self.db.pool.execute, "DELETE FROM accounts WHERE user_id=$1", account)
        self.char = await self.db.create_character(account, 1, tag)
        self.session = Session(self.db)
        self.session.char_id = self.char["char_id"]
        self.session.account_id = account

    async def stack(self, item):
        return await self.db.pool.fetchval("SELECT count FROM inventory WHERE char_id=$1 AND item_id=$2",
                                           self.char["char_id"], item) or 0

    async def test_all_five_stars_keep_the_same_uid_and_consume_only_verified_costs(self):
        char_id = self.session.char_id
        pet = await self.db.grant_pet(char_id, 45)
        target = pet["pet_uid"]
        async with self.db.pool.acquire() as conn, conn.transaction():
            dry = await star_materials(conn, self.char, target, False)
            self.assertEqual(dry["items_to_add"], {11000: 180})
            self.assertEqual(dry["pets_to_add"], {45: 10, 46: 5})
            self.assertEqual(await self.stack(11000), 0)
            await star_materials(conn, self.char, target, True)
            self.assertEqual((await star_materials(conn, self.char, target, False))["pets_to_add"], {})
        for current, step in enumerate(star_steps(45)):
            foods = await self.db.pool.fetch(
                "SELECT pet_uid FROM pets WHERE char_id=$1 AND pet_template_id=$2 AND pet_uid<>$3 LIMIT $4",
                char_id, step.pet, target, step.pet_count)
            writer = Writer().u32(target).u8(len(foods))
            for food in foods:
                writer.u32(food["pet_uid"])
            payload = writer.bytes()
            error = (1650, b"\x01\x00")
            self.assertEqual(await dispatch(self.session, 1596, payload), error)
            await self.db.pool.execute(
                "UPDATE pets SET training_stage=$2,level=$3 WHERE pet_uid=$1", target, step.stage, step.stage * 2)
            results = await asyncio.gather(*[dispatch(self.session, 1596, payload) for _ in range(2)])
            self.assertIn(error, results)
            packets = next(result for result in results if result != error)
            self.assertEqual([msg for msg, _ in packets], [112, *([3138] * step.pet_count), 3141, 1650])
            self.assertEqual(packets[-1], (1650, b"\x00\x00"))
            reader = Reader(packets[-2][1])
            self.assertEqual(reader.u64(), target)
            self.assertEqual(json.loads(reader.string())["star"], current + 1)
        self.assertEqual(await self.stack(11000), 0)
        self.assertEqual(await self.db.pool.fetchval("SELECT star FROM pets WHERE pet_uid=$1", target), 5)
        self.assertEqual(await dispatch(self.session, 1596, Writer().u32(target).u8(0).bytes()), (1650, b"\x01\x00"))

    async def test_vip_shop_override_is_private_and_keeps_price_rank_and_ledger(self):
        char = self.session.char_id
        offer = table("MarketInfo")[178]
        await self.db.pool.execute("UPDATE characters SET vip_level=20,diamond=1000 WHERE char_id=$1", char)
        with patch.dict(os.environ, {"MONSTER2_LAUNCH_PROFILE": "local", "LOCAL_PAYMENT_SANDBOX": "1",
                                    "PAYMENT_PROVIDER": "local", "VIP_SHOP_UNLIMITED": "0"}):
            self.assertIsNotNone(await self.db.buy_market_item(char, offer, 10))
            self.assertIsNone(await self.db.buy_market_item(char, offer, 1))
            with patch.dict(os.environ, {"VIP_SHOP_UNLIMITED": "1", "PAYMENT_PROVIDER": "external"}):
                self.assertIsNone(await self.db.buy_market_item(char, offer, 1))
            with patch.dict(os.environ, {"VIP_SHOP_UNLIMITED": "1"}):
                self.assertIsNotNone(await self.db.buy_market_item(char, offer, 2))
                await self.db.pool.execute("UPDATE characters SET vip_level=0 WHERE char_id=$1", char)
                self.assertIsNone(await self.db.buy_market_item(char, offer, 1))
        self.assertEqual(await self.stack(187), 12)
        self.assertEqual(await self.db.pool.fetchval("SELECT diamond FROM characters WHERE char_id=$1", char), 760)
        self.assertEqual(await self.db.pool.fetchval(
            "SELECT sum(quantity) FROM vip_shop_purchases WHERE char_id=$1 AND unlimited", char), 2)

    async def test_arena_exchange_uses_stored_offers_stock_and_arena_currency(self):
        char = self.session.char_id
        shop = Writer().u32(1).bytes()
        order = Writer().u32(1).u32(0).u32(1).bytes()
        failure = (1953, b"\x01\x00")
        self.assertEqual(await dispatch(self.session, 277, b""), (51, b"\x01\x00"))
        self.assertEqual(await dispatch(self.session, 858, order), failure)
        self.assertEqual(await dispatch(self.session, 778, shop), (1746, b"\x01\x00"))
        await self.db.pool.execute("UPDATE characters SET level=11 WHERE char_id=$1", char)
        _, opened = await dispatch(self.session, 778, shop)
        reader = Reader(opened)
        self.assertEqual((reader.u16(), reader.u8()), (0, 9))
        award, stock, quantity, price, requirement = [reader.u32() for _ in range(5)]
        self.assertEqual((stock, requirement), (1, 0))
        item = table("AwardElementInfo")[award]["elementID"]
        self.assertEqual(await dispatch(self.session, 858, order), failure)
        self.assertEqual(await dispatch(self.session, 632,
                         Writer().u32(char).string("arenascore").string("100000").bytes()), (630, b"\x01\x00"))
        await self.db.pool.execute("""UPDATE characters SET game_values=game_values ||
            jsonb_build_object('arenascore',$2::integer), diamond=10 WHERE char_id=$1""", char, price + 15)
        results = await asyncio.gather(*[dispatch(self.session, 858, order) for _ in range(2)])
        self.assertIn(failure, results)
        success = next(result for result in results if result != failure)
        self.assertEqual(success[-1], (1953, b"\x00\x00"))
        self.assertEqual(json.loads(Reader(success[-2][1]).string())["arenascore"], 15)
        self.assertEqual(await self.stack(item), quantity)
        self.assertEqual(await self.db.pool.fetchval(
            "SELECT count(*) FROM arena_shop_purchases WHERE char_id=$1 AND item_id=$2", char, item), 1)
        reload = Reader((await dispatch(self.session, 778, shop))[1])
        self.assertEqual((reload.u16(), reload.u8(), reload.u32(), reload.u32()), (0, 9, award, 0))
        refreshed = await dispatch(self.session, 853, shop)
        self.assertEqual([message for message, _ in refreshed], [473, 1876])
        self.assertEqual(await self.db.pool.fetchval("SELECT diamond FROM characters WHERE char_id=$1", char), 5)

    async def test_local_recharge_all_pairs_and_vip20_claim_once(self):
        char = self.session.char_id
        with patch.dict(os.environ, {"GAME_ENV": "test", "LOCAL_PAYMENT_SANDBOX": "1", "PAYMENT_PROVIDER": "local"}):
            async def buy(sku, key):
                return await dispatch(self.session, 90, Writer().u32(sku).string(f"local:N{sku}:{key}").bytes())

            for sku, (bonus, repeat) in normal_families().items():
                if sku != bonus["id"]:
                    continue
                self.assertEqual(await buy(repeat["id"], "premature"), (89, b"\x01\x00"))
                paid = await buy(sku, "bonus")
                self.assertEqual(paid[-1], (89, b"\x00\x00"))
                self.assertEqual((await buy(sku, "bonus"))[-1], paid[-1])
                self.assertEqual(await buy(sku, "bonus-again"), (89, b"\x01\x00"))
                self.assertEqual((await buy(repeat["id"], "repeat"))[-1], (89, b"\x00\x00"))
            _, body = await dispatch(self.session, 662, b"")
            self.assertEqual(Reader(body).u16(), 0)
            self.assertEqual(len(await self.db.local_recharge_cooldowns(char)), 6)
        request = Writer().u32(21).u8(0).bytes()
        self.assertEqual(await dispatch(self.session, 61, request), (60, b"\x01\x00"))
        await self.db.pool.execute("UPDATE characters SET vip_level=20 WHERE char_id=$1", char)
        result = await dispatch(self.session, 61, request)
        self.assertEqual([message for message, _ in result], [112, 3141, 60])
        self.assertEqual(await self.stack(50057), 1)
        self.assertEqual(await dispatch(self.session, 61, request), (60, b"\x01\x00"))
        _, state = await dispatch(self.session, 63, b"")
        got = Reader(state)
        self.assertEqual((got.u16(), got.u8(), got.u32()), (0, 1, 21))
        got.finish()

    async def test_vip_admin_apply_and_guarded_rollback(self):
        char = self.session.char_id
        with tempfile.TemporaryDirectory() as directory:
            snapshot = str(Path(directory) / "vip.json")
            args = SimpleNamespace(action="vip-max", play=False, apply=False, rollback=None,
                                   rollback_file=None, char_id=char, account_id=self.session.account_id)
            with patch("builtins.print"):
                await admin_run(args)
                self.assertFalse(Path(snapshot).exists())
                self.assertEqual(await self.db.pool.fetchval("SELECT vip_level FROM characters WHERE char_id=$1", char), 0)
                args.apply = True
                args.rollback_file = snapshot
                await admin_run(args)
                self.assertEqual(Path(snapshot).stat().st_mode & 0o777, 0o600)
                self.assertEqual(await self.db.pool.fetchval("SELECT vip_level FROM characters WHERE char_id=$1", char), 20)
                args.apply = False
                args.rollback_file = None
                args.rollback = snapshot
                await self.db.pool.execute("UPDATE characters SET recharge_total=99 WHERE char_id=$1", char)
                with self.assertRaises(ValueError):
                    await admin_run(args)
                await self.db.pool.execute("UPDATE characters SET recharge_total=0 WHERE char_id=$1", char)
                await admin_run(args)
                self.assertEqual(await self.db.pool.fetchval("SELECT vip_level FROM characters WHERE char_id=$1", char), 0)
