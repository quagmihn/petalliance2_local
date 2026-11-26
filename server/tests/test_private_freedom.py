import json
import os
import random
from collections import Counter
from pathlib import Path
from tempfile import TemporaryDirectory
from unittest import IsolatedAsyncioTestCase, TestCase
from unittest.mock import patch

from admin.set_local_progression import change
from client_config import table
from draw_expansion import compatible_books, compatible_fashion_vouchers, compatible_pets
from local_draw import SERVER_ROOT, parse_catalog
from local_play import freedom, storage_limits
from pet_config import starting_skills
from protocol import Reader, Writer, frame
import test_item_event_rewards


LOCAL = {
    "MONSTER2_LAUNCH_PROFILE": "test",
    "LOCAL_PAYMENT_SANDBOX": "1",
    "PAYMENT_PROVIDER": "local",
    "LOCAL_FREEDOM_MODE": "1",
    "LOCAL_UNLIMITED_PET_STORAGE": "1",
    "LOCAL_UNLIMITED_ITEM_STORAGE": "1",
}


class PrivateCatalogTests(TestCase):
    def test_pool_coverage_and_distribution(self):
        catalog = parse_catalog((SERVER_ROOT / "config/expanded_play_draw.json").read_bytes(), complete=True)
        pets = compatible_pets()
        books = {item for group in compatible_books().values() for item in group}
        for machine_id, tiers in ((1, (1, 2, 3)), (2, (3, 4, 5, 6))):
            self.assertEqual({value for kind, value, _, _ in catalog[machine_id].prizes if kind == "pet"},
                             {value for tier in tiers for value in pets[tier]})
        self.assertTrue(books <= {value for _, value, _, _ in catalog[3].prizes})
        self.assertEqual({value for kind, value, _, _ in catalog[2].prizes
                          if kind == "item" and table("ItemInfo")[value]["itemType"] == 22},
                         set(compatible_fashion_vouchers()))
        generator = random.Random(25)
        for machine in catalog.values():
            weights = Counter()
            for kind, value, _, weight in machine.prizes:
                weights[kind, value] += weight
            self.assertEqual(sum(weights.values()), 10_000)
            with patch("local_draw.randbelow", generator.randrange):
                samples = Counter((entry["elementType"], entry["elementID"]) for entry in machine.draw(50_000))
            self.assertGreater(len(samples), len(weights) * 0.9)
            for kind in {kind for kind, _ in weights}:
                rate = sum(value for (category, _), value in weights.items() if category == kind) / 10_000
                observed = sum(value for (category, _), value in samples.items() if category == kind) / 50_000
                self.assertAlmostEqual(observed, rate, delta=0.015)

    def test_private_profile_and_account_authorization(self):
        with patch.dict(os.environ, LOCAL):
            self.assertTrue(freedom({"local_freedom": True}))
            self.assertFalse(freedom({"local_freedom": 1}))
            self.assertEqual(storage_limits({}), (None, None))
            with patch.dict(os.environ, {"PAYMENT_PROVIDER": "external"}):
                self.assertFalse(freedom({"local_freedom": True}))
                self.assertTrue(all(isinstance(limit, int) for limit in storage_limits({})))


class PrivateProgressionTests(IsolatedAsyncioTestCase):
    asyncSetUp = test_item_event_rewards.ItemEventRewards.asyncSetUp
    send = test_item_event_rewards.ItemEventRewards.send

    async def test_progression_snapshot_and_rollback_preserve_inventory(self):
        args = dict(expected_db="monster2_test_db", account=self.session.account_id, char=self.char_id,
                    name=await self.db.pool.fetchval("SELECT name FROM characters WHERE char_id=$1", self.char_id),
                    level=50, vip=20, freedom=True)
        dsn = os.environ["TEST_DATABASE_URL"]
        await self.db.grant_item(self.char_id, 199, 4)
        with self.assertRaisesRegex(ValueError, "exact name"):
            await change(dsn, **(args | {"name": "wrong"}))
        dry_run = await change(dsn, **args)
        self.assertEqual(dry_run["after"]["exp"], 183360)
        self.assertFalse(dry_run["changed"])
        with TemporaryDirectory() as temporary:
            applied = await change(dsn, **args, apply=True, backup_dir=Path(temporary))
            self.assertTrue(applied["changed"])
            with patch.dict(os.environ, LOCAL):
                self.assertEqual(await self.db.character_values(self.char_id, ["local_freedom"]),
                                 {"local_freedom": True})
            self.assertGreaterEqual(applied["after"]["vip_points"], table("VipInfo")[21]["recharge"])
            rollback = await change(dsn, **args, rollback=Path(applied["backup"]))
            self.assertEqual(rollback["after"], dry_run["before"])
            self.assertEqual(await self.db.pool.fetchval(
                "SELECT count FROM inventory WHERE char_id=$1 AND item_id=199", self.char_id), 4)

    async def test_pet_pagination_through_500_and_inventory_frames(self):
        skills, passive = starting_skills(1)
        with patch.dict(os.environ, LOCAL):
            for previous, total in ((0, 40), (40, 100), (100, 250), (250, 500)):
                await self.db.pool.execute(
                    """INSERT INTO pets(char_id,pet_template_id,slot_index,skills_json,passive_skills_json)
                       SELECT $1,1,CASE WHEN n=1 AND $4=0 THEN 0 ELSE -1 END,$2::jsonb,$3::jsonb
                       FROM generate_series(1,$5::int) n""",
                    self.char_id, json.dumps(skills), json.dumps(passive), previous, total - previous)
                start, seen = 0, set()
                while start < total - 1:
                    msg, body = (await self.send(3140, Writer().u64(self.char_id).u32(start).u32(start + 100).bytes()))[0]
                    self.assertEqual(msg, 3139)
                    frame(msg, body)
                    reader = Reader(body)
                    self.assertEqual((reader.u16(), reader.u64(), reader.u32()), (0, self.char_id, start))
                    end = reader.u32()
                    self.assertEqual(reader.u8(), 1)
                    self.assertEqual(json.loads(reader.string())["pokeID"], 1)
                    count = reader.u8()
                    seen.update(json.loads(reader.string())["objID"] for _ in range(count))
                    self.assertEqual((reader.u32(), reader.u8()), (total - 1, 0))
                    self.assertEqual(end, start + count)
                    self.assertGreater(count, 0)
                    reader.finish()
                    start = end
                self.assertEqual(len(seen), total - 1)
        await self.db.pool.executemany(
            "INSERT INTO inventory(char_id,item_id,count) VALUES($1,$2,$3)",
            [(self.char_id, item_id, 4_000_000_000 if index == 0 else 1)
             for index, item_id in enumerate(list(table("ItemInfo"))[:500])])
        responses = await self.send(59)
        seen_items = {}
        for msg, body in responses[1:]:
            frame(msg, body)
            reader = Reader(body)
            for _ in range(reader.u8()):
                item = json.loads(reader.string())
                seen_items[item["itemID"]] = item["num"]
            reader.finish()
        self.assertGreaterEqual(len(seen_items), 500)
        self.assertIn(4_000_000_000, seen_items.values())
