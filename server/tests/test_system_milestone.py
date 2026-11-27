import json
import os
import unittest
from unittest.mock import patch

import test_item_event_rewards
from client_config import table
from game_socket import Session
from handlers.arena import opponents
from market_config import local_offers
from pet_config import insert_owned_pet
from protocol import Reader, Writer
from recharge_config import normal_families

PRIVATE = {"GAME_ENV": "test", "LOCAL_PAYMENT_SANDBOX": "1", "PAYMENT_PROVIDER": "local",
           "MONSTER2_LAUNCH_PROFILE": "test", "LOCAL_NPC_ARENA": "1", "LOCAL_MARKET_SHOP": "1",
           "LOCAL_ARENA_REPLAY_PROBE": "1"}


class SystemMilestone(unittest.IsolatedAsyncioTestCase):
    asyncSetUp = test_item_event_rewards.ItemEventRewards.asyncSetUp
    send = test_item_event_rewards.ItemEventRewards.send
    stack = test_item_event_rewards.ItemEventRewards.stack

    async def test_story_drop_only_award_fails_atomically_then_commits_once(self):
        # A persisted, completed objective is required before a story claim.
        await self.db.pool.executemany(
            "INSERT INTO quests(char_id,quest_id,status,progress) VALUES($1,$2,$3,$4::jsonb)",
            [(self.char_id, 2004, 1, "[1]"), (self.char_id, 2005, 0, "[1]")])
        await self.db.pool.execute("INSERT INTO inventory(char_id,item_id,count) VALUES($1,10002,$2)",
                                   self.char_id, (1 << 32) - 1)
        request = Writer().u32(2005).bytes()
        self.assertEqual(await self.send(400, request), [(726, b"\x01\x00")])
        self.assertEqual(await self.db.pool.fetch(
            "SELECT quest_id FROM quests WHERE char_id=$1 AND quest_id=20002", self.char_id), [])
        await self.db.pool.execute("UPDATE inventory SET count=0 WHERE char_id=$1 AND item_id=10002",
                                   self.char_id)
        packets = await self.send(400, request)
        reader = Reader(dict(packets)[726])
        self.assertEqual((reader.u16(), reader.u32(), reader.u8()), (0, 2005, 1))
        self.assertEqual(json.loads(reader.string()), {"elementType": "item", "elementID": 10002, "num": 2})
        reader.finish()
        self.assertIn(404, dict(packets))
        self.session = Session(self.db)
        self.session.char_id = self.char_id
        self.assertEqual(dict(await self.send(400, request))[726], dict(packets)[726])
        self.assertEqual(await self.stack(10002), 2)
        quests = dict(await self.db.pool.fetch(
            "SELECT quest_id,status FROM quests WHERE char_id=$1", self.char_id))
        self.assertEqual(quests, {2004: 1, 2005: 1, 20002: 0})

    async def test_stamina_purchase_and_daily_claim_commit_once(self):
        await self.db.pool.execute("UPDATE characters SET diamond=1000,stamina=190,vip_level=20 WHERE char_id=$1",
                                   self.char_id)
        req = Writer().vector_strings(["todayBuyPowerCount", "lastBuyPowerTime",
                                       "todayBuyGCashCount", "lastBuyGCashTime"]).bytes()
        self.assertEqual(await self.send(1242), [(991, b"\x01\x00")])
        await self.send(770, req)
        self.assertEqual((await self.send(1242))[-1], (991, b"\x00\x00"))
        self.session = Session(self.db)
        self.session.char_id = self.char_id
        self.assertEqual(await self.send(1242), [(991, b"\x01\x00")])
        self.assertEqual((await self.send(400, Writer().u32(1011).bytes()))[-1][0], 726)
        self.assertEqual(await self.send(400, Writer().u32(1011).bytes()), [(726, b"\x01\x00")])
        row = await self.db.pool.fetchrow(
            "SELECT stamina,diamond,exp,game_values FROM characters WHERE char_id=$1", self.char_id)
        self.assertEqual((row["stamina"], row["diamond"], row["exp"]), (310, 950, 400))
        self.assertEqual(json.loads(row["game_values"])["gameplay_daily"]["power"], 15)

    async def test_local_market_page_quote_paid_delivery_and_reconnect(self):
        await self.db.pool.execute('UPDATE characters SET currencies_json=$2 WHERE char_id=$1',
                                   self.char_id, '{"goldCoin":500}')
        with patch.dict(os.environ, PRIVATE):
            query = Writer().u32(17).u32(4).u32(10002).u32(1).u32(0).u32(6).string("").bytes()
            listing = Reader((await self.send(492, query))[0][1])
            self.assertEqual((listing.u16(), listing.u8()), (0, 1))
            card = json.loads(listing.string())
            self.assertEqual((card["itemID"], card["unitPrice"]), (10002, local_offers()["local:10002"]["num"]))
            purchase = Writer().string(card["productID"]).u32(2).bytes()
            self.assertEqual((await self.send(481, purchase))[-1], (471, b"\x00\x00"))
            self.session = Session(self.db)
            self.session.char_id = self.char_id
            self.assertEqual(await self.send(481, purchase), [(471, b"\x01\x00")])
            self.assertEqual(await self.stack(10002), 2)
            wallet = await self.db.character_values(self.char_id, ["goldCoin"])
            self.assertEqual(wallet["goldCoin"], 500 - 2 * card["unitPrice"])

    async def test_achievement_collection_and_level_rewards(self):
        for template in (10, 11, 12):
            await insert_owned_pet(self.db.pool, self.char_id, template)
        packet = Writer().u16(1).bytes()
        self.assertEqual((await self.send(73, packet))[-1], (67, b"\x00\x00\x01\x00"))
        self.assertEqual(await self.send(73, packet), [(67, b"\x01\x00")])
        self.assertEqual(await self.send(72), [(74, b"\x00\x00\x01\x01\x00")])
        await self.db.pool.execute("UPDATE characters SET level=5 WHERE char_id=$1", self.char_id)
        first = next(row for row in table("AchievementInfo").values() if row["countFieldName"] == "zldj")
        packet = Writer().u16(first["id"]).bytes()
        self.assertEqual((await self.send(328, packet))[-1], (485, b"\0\0" + packet))
        points = await self.db.character_values(self.char_id, ["achievementpoint", "zldj"])
        self.assertEqual(points, {"achievementpoint": 50 + first["point"], "zldj": 5})

    async def test_daily_recharge_mail_uses_second_qualifying_order(self):
        bonus, repeat = normal_families()[2]
        with patch.dict(os.environ, PRIVATE):
            for sku, order in ((bonus["id"], "event-first"), (repeat["id"], "event-daily")):
                result = await self.send(90, Writer().u32(sku).string(f"local:N{sku}:{order}").bytes())
                self.assertEqual(result[-1], (89, b"\0\0"))
            listing = Reader((await self.send(978, Writer().string("0").u32(0).u16(10).bytes()))[0][1])
            self.assertEqual(listing.u16(), 0)
            messages = json.loads(listing.string())
            daily = next(message for message in messages.values() if message["_id"].startswith("local-daily:"))
            self.assertEqual(daily["mCash"], 80)
            packet = Writer().string(daily["_id"]).u16(0).bytes()
            self.assertEqual((await self.send(1054, packet))[-1], (1106, b"\0\0"))
            self.assertEqual(await self.send(1054, packet), [(1106, b"\x01\x00")])
            self.assertEqual((await self.stack(10004), await self.stack(178)), (10, 2))

    async def test_pet_training_and_relation_persist_authoritative_stats(self):
        await self.db.pool.execute("UPDATE characters SET gold=10000 WHERE char_id=$1", self.char_id)
        main, first, second = [await insert_owned_pet(self.db.pool, self.char_id, template)
                               for template in (1, 13, 15)]
        uid = main["pet_uid"]
        train = Writer().u32(uid).json_string({"hpx": 2}).bytes()
        results = await self.send(1717, train)
        self.assertEqual([message for message, _ in results], [473, 1699, 3141])
        self.assertEqual((await self.db.character_values(self.char_id, ["gold"]))["gold"], 8000)
        for slot, pet in enumerate((first, second)):
            wire = Writer().u32(uid).u16(1).u16(slot).u32(pet["pet_uid"]).bytes()
            self.assertEqual((await self.send(2010, wire))[-1], (2035, b"\0\0"))
        saved = json.loads(await self.db.pool.fetchval("SELECT development_json FROM pets WHERE pet_uid=$1", uid))
        self.assertEqual(saved["hpx"], 2)
        self.assertGreater(saved["yoke"]["yokeValues"][0], 0)
        self.assertFalse(await self.db.update_primary_army(self.char_id, [first["pet_uid"]], []))
        wire = Writer().u32(uid).u16(1).u16(0).bytes()
        self.assertEqual((await self.send(1966, wire))[-1], (1973, b"\0\0"))
        saved = json.loads(await self.db.pool.fetchval("SELECT development_json FROM pets WHERE pet_uid=$1", uid))
        self.assertEqual(saved["yoke"]["yokeValues"][0], 0)

    async def test_arena_practice_roster_and_snapshot_do_not_award_a_win(self):
        await self.db.pool.execute("UPDATE characters SET level=30 WHERE char_id=$1", self.char_id)
        pet = await insert_owned_pet(self.db.pool, self.char_id, 1, slot=0)
        with patch.dict(os.environ, PRIVATE):
            body = Reader((await self.send(277))[0][1])
            self.assertEqual((body.u16(), body.u32(), body.u8(), body.u32(), body.u32()),
                             (0, len(opponents()) + 1, 1, pet["pet_uid"], 1))
            roster = Reader((await self.send(317, Writer().u32(len(opponents()) + 1).bytes()))[0][1])
            self.assertEqual((roster.u16(), roster.u8()), (0, 3))
            npc = json.loads(roster.string())
            result = Reader((await self.send(517, Writer().u32(npc["rank"]).u32(1).u8(0).bytes()))[0][1])
            self.assertEqual(result.u16(), 0)
            self.assertTrue(result.string().startswith("local-practice-"))
            self.assertEqual((result.u8(), json.loads(result.string())["objID"]), (1, pet["pet_uid"]))
            self.assertGreater(result.u8(), 0)
            self.assertEqual((await self.db.character_values(self.char_id, ["arenascore"]))["arenascore"], 0)
