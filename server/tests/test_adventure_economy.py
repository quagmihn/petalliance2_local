import json
import os
import time
import unittest
from unittest.mock import patch

import test_item_event_rewards
from battle_group_config import resolve_wild
from chest_config import chest_drop, chest_rewards
from client_config import table
from game_socket import Session
from market_config import enabled_offers
from protocol import Reader, Writer
from reward_config import RewardConfigError


class CatalogContracts(unittest.TestCase):
    def test_every_bag_chest_resolves_only_its_drop_children(self):
        items = table("ItemInfo")
        drops = table("DropInfo")
        blocked = []
        for item_id, item in items.items():
            if item["itemType"] != 18 or not item["bUse"]:
                continue
            self.assertIn(item["paramA"], drops)
            try:
                plan = chest_drop(item_id)
            except RewardConfigError:
                blocked.append(item_id)
                continue
            self.assertEqual([n for n, _ in plan], drops[item["paramA"]]["count"])
            with patch("reward_config.secrets.randbelow", return_value=0):
                self.assertEqual(chest_rewards(item_id, 2),
                                 [pool[0][1] for count, pool in plan for _ in range(count)] * 2)
        self.assertEqual(blocked, [366, 385, 387, 388, 12000, *range(61106, 61116)])


class AdventureEconomyContracts(unittest.IsolatedAsyncioTestCase):
    asyncSetUp = test_item_event_rewards.ItemEventRewards.asyncSetUp
    send = test_item_event_rewards.ItemEventRewards.send
    stack = test_item_event_rewards.ItemEventRewards.stack

    async def test_multi_pet_chest_persists_unique_pets_and_no_unrelated_potion(self):
        await self.db.grant_item(self.char_id, 201)
        request = Writer().u32(201).u32(0).string("").u32(1).bytes()
        result = await self.send(516, request)
        pets = [Reader(body).u64() for msg, body in result if msg == 3141]
        self.assertEqual(len(set(pets)), 4)
        rows = await self.db.pool.fetch(
            "SELECT pet_template_id FROM pets WHERE char_id=$1 ORDER BY pet_template_id", self.char_id)
        self.assertEqual([r["pet_template_id"] for r in rows], [115, 116, 117, 118])
        self.assertEqual((await self.stack(201), await self.stack(10004)), (0, 0))
        self.assertEqual(await self.send(516, request), [(526, b"\x01\x00")])

    async def test_chest_receipt_prevents_replay_even_with_another_chest(self):
        await self.db.grant_item(self.char_id, 201, 2)
        token = f"local:{int(time.time()):08x}{1:016x}"
        request = Writer().u32(201).u32(0).string(token).u32(1).bytes()
        first = await self.send(516, request)
        self.session = Session(self.db)
        self.session.char_id = self.char_id
        replay = await self.send(516, request)
        conflict = Writer().u32(201).u32(0).string(token).u32(2).bytes()
        self.assertEqual(await self.send(516, conflict), [(526, b"\x01\x00")])
        self.assertEqual(first[-1], replay[-1])
        self.assertEqual([msg for msg, _ in replay], [112, 526])
        self.assertEqual(await self.stack(201), 1)
        self.assertEqual(await self.db.pool.fetchval("SELECT count(*) FROM pets WHERE char_id=$1", self.char_id), 4)

    async def test_virtual_silver_is_scoped_and_leaves_genuine_balance_intact(self):
        offer = next(row for row in enabled_offers().values() if row["coinType"] == 3)
        request = Writer().u32(offer["id"]).u32(2).bytes()
        self.assertEqual(await self.send(577, request), [(563, b"\x01\x00")])
        name = await self.db.pool.fetchval("SELECT name FROM characters WHERE char_id=$1", self.char_id)
        with patch.dict(os.environ, {
            "LOCAL_UNLIMITED_SILVER": "1", "MONSTER2_LAUNCH_PROFILE": "test",
            "LOCAL_PAYMENT_SANDBOX": "1", "PAYMENT_PROVIDER": "local",
            "LOCAL_UNLIMITED_SILVER_PLAYER": f"{self.session.account_id}:{self.char_id}:{name}",
        }):
            for _ in range(2):
                result = await self.send(577, request)
                wallet = next(body for msg, body in result if msg == 473)
                self.assertEqual(json.loads(Reader(wallet).string())["goldCoin"], 999_999_999)
            self.assertEqual((await self.db.character_values(self.char_id, ["goldCoin"]))["goldCoin"], 999_999_999)
            self.assertEqual(await self.send(577, Writer().u32(999999).u32(1).bytes()),
                             [(563, b"\x01\x00")])
        self.assertEqual(await self.stack(offer["itemID"]), 4)
        self.assertEqual((await self.db.character_values(self.char_id, ["goldCoin"]))["goldCoin"], 0)

    async def test_every_target_market_offer_grants_its_own_item_and_charges_its_currency(self):
        await self.db.pool.execute(
            """UPDATE characters SET vip_level=20,gold=1000000,diamond=1000000,
               currencies_json='{"goldCoin":1000000}',game_values='{"itemPacketNum":999}'
               WHERE char_id=$1""", self.char_id)
        spent = {1: 0, 2: 0, 3: 0}
        for sku, offer in enabled_offers().items():
            with self.subTest(sku=sku):
                before = await self.stack(offer["itemID"])
                result = await self.send(577, Writer().u32(sku).u32(1).bytes())
                self.assertEqual(result[-1], (563, b"\x00\x00"))
                self.assertEqual(await self.stack(offer["itemID"]), before + 1)
                spent[offer["coinType"]] += offer["num"]
        wallet = await self.db.character_values(self.char_id, ["gold", "diamond", "goldCoin"])
        self.assertEqual([wallet[key] for key in ("gold", "diamond", "goldCoin")],
                         [1000000 - spent[key] for key in (1, 2, 3)])

    async def test_town_ack_is_scoped_to_position_on_joined_channel(self):
        channel = "zhucheng_2"
        await self.send(380, Writer().string(channel).string("").bytes())
        position = json.dumps({"mapres": "Map/TownMap/town_01.csb", "posx": 221.5, "nickname": "test"})
        for recipient, scope, data in (("7", channel, position), ("", "zhucheng_3", position),
                                       ("", channel, "hello")):
            self.assertEqual(await self.send(45, Writer().string(recipient).string(scope).string(data).bytes()),
                             [(35, b"\x01\x00")])
        state = await self.db.pool.fetchrow("SELECT map_id,pos_x,pos_y FROM characters WHERE char_id=$1", self.char_id)
        for _ in range(2):
            self.assertEqual(await self.send(45, Writer().string("").string(channel).string(position).bytes()),
                             [(35, b"\x00\x00")])
        self.assertEqual(self.session.town_position, ("Map/TownMap/town_01.csb", 221.5))
        self.assertEqual(await self.db.pool.fetchrow(
            "SELECT map_id,pos_x,pos_y FROM characters WHERE char_id=$1", self.char_id), state)

    async def test_sweep_x1_x10_cost_and_retry_with_crowns_retained(self):
        await self.db.pool.execute(
            """UPDATE characters SET level=30,vip_level=20,stamina=150,
               game_values='{"map_lock":"19-0"}' WHERE char_id=$1""", self.char_id)
        now = int(time.time())
        single = Writer().u32(2).u32(0).u32(0).string(f"{now:08x}{1:016x}").bytes()
        ten = Writer().u32(2).u32(0).u32(10).string(f"{now:08x}{2:016x}").bytes()
        self.assertEqual(await self.send(1738, single), [(1741, b"\x01\x00")])
        await self.db.pool.execute(
            "INSERT INTO character_adventure_clears VALUES($1,2,15)", self.char_id)
        starting_exp = await self.db.pool.fetchval("SELECT exp FROM characters WHERE char_id=$1", self.char_id)
        for request, draws in ((single, 1), (ten, 10)):
            result = await self.send(1738, request)
            ack = Reader(result[-1][1])
            self.assertEqual((result[-1][0], ack.u16(), ack.u8()), (1741, 0, draws * 3 + 1))
        self.session = Session(self.db)
        self.session.char_id = self.char_id
        self.assertEqual([msg for msg, _ in await self.send(1738, ten)], [1749, 1741])
        row = await self.db.pool.fetchrow("SELECT exp,stamina FROM characters WHERE char_id=$1", self.char_id)
        self.assertEqual(tuple(row), (starting_exp + 62 * 11, 40))
        self.assertEqual((await self.stack(10002), await self.stack(38)), (11, 11))
        state, = await self.db.adventure_clears(self.char_id, include_sweeps=True)
        self.assertEqual((state["star"], state["qcTimes"]), (15, 11))

    async def test_obstacle_requires_skill_or_claimed_flute_and_survives_reconnect(self):
        request = Writer().u32(4).bytes()
        await self.send(2996, request)
        cut = Writer().u32(0).u32(124).u32(4).u32(2).bytes()
        self.assertEqual(await self.send(722, cut), [(746, b"\x01\x00")])
        await self.db.pool.execute(
            "INSERT INTO pets(char_id,pet_template_id,skills_json) VALUES($1,1,'[361,0,0,971]')",
            self.char_id)
        self.assertEqual(await self.send(722, cut), [(746, b"\x00\x00")])
        flute = Writer().u32(150).u32(173).u32(4).u32(1).bytes()
        self.assertEqual(await self.send(722, flute), [(746, b"\x01\x00")])
        pick = Writer().u32(1).u32(5).u32(6).bytes()
        self.assertEqual(await self.send(2998, pick), [(3079, b"\x00\x00\x00")])
        self.assertEqual(await self.send(722, flute), [(746, b"\x00\x00")])
        self.assertEqual(await self.send(722, flute), [(746, b"\x00\x00")])
        self.assertEqual(await self.send(2998, pick), [(3079, b"\x01\x00")])
        self.session = Session(self.db)
        self.session.char_id = self.char_id
        body = Reader((await self.send(2996, request))[0][1])
        self.assertEqual((body.u16(), body.u32()), (0, 4))
        events = {cell["sceneID"]: cell["type"] for cell in json.loads(body.string())["events"]}
        self.assertEqual([events[i] for i in (124, 150, 173)], [0, 0, 0])

    async def test_adventure_capture_transaction_and_non_capture_cell(self):
        adv, scene_id = 3, 111
        await self.send(2996, Writer().u32(adv).bytes())
        battle = await self.send(136, Writer().u32(2).u32(scene_id).u32(0).bytes())
        ack = Reader(battle[-1][1])
        self.assertEqual((ack.u16(), ack.u8()), (0, 1))
        self.assertNotIn("canCatch", json.loads(ack.string()))
        await self.db.grant_item(self.char_id, 1, 2)
        self.assertEqual(await self.send(15, Writer().u32(6).u32(1).bytes()), [(198, b"/\x01")])
        self.assertEqual(await self.stack(1), 2)
        # The authored Adventure layouts don't place positive-attempt groups.
        # Issue a real configured capturable group only in the integration fixture.
        group = 57
        info = table("MonstrosityInfo")[group]
        self.assertTrue(resolve_wild(group)[0]["canCatch"])
        self.assertTrue(await self.db.start_adventure_battle(
            self.char_id, self.session.session_id, adv, scene_id + 1, group,
            battle_type=2, attempts=info["capture"]))
        target = info["petnumber"]
        with patch("secrets.randbelow", return_value=0):
            for _ in range(2):
                got = await self.send(15, Writer().u32(target).u32(1).bytes())
                self.assertEqual(Reader(got[-1][1]).u16(), 0)
        self.assertEqual(await self.stack(1), 1)
        self.assertEqual(await self.db.pool.fetchval("SELECT count(*) FROM pets WHERE char_id=$1", self.char_id), 1)
