import asyncio
import json
import os
import secrets
import unittest
from unittest.mock import patch

from db.database import Database
from game_socket import Session, dispatch
from protocol import Reader, Writer


class ItemEventRewards(unittest.IsolatedAsyncioTestCase):
    async def asyncSetUp(self):
        dsn = os.getenv("TEST_DATABASE_URL")
        if not dsn:
            self.skipTest("TEST_DATABASE_URL required")
        self.db = await Database.connect(dsn)
        self.addAsyncCleanup(self.db.close)
        self.assertEqual(await self.db.pool.fetchval("SELECT current_database()"), "monster2_test_db")
        await self.db.initialize()
        name = "item-event-" + secrets.token_hex(8)
        account = await self.db.pool.fetchval(
            "INSERT INTO accounts(username,token) VALUES($1,$2) RETURNING user_id", name, secrets.token_hex(16))
        self.addAsyncCleanup(self.db.pool.execute, "DELETE FROM accounts WHERE user_id=$1", account)
        self.session = Session(self.db)
        self.session.account_id = account
        self.char_id = await self.db.pool.fetchval(
            "INSERT INTO characters(account_id,world_id,name) VALUES($1,1,$2) RETURNING char_id", account, name)
        self.session.char_id = self.char_id

    async def send(self, message_id, body=b""):
        result = await dispatch(self.session, message_id, body)
        return [result] if isinstance(result, tuple) else result

    async def stack(self, item):
        return await self.db.pool.fetchval(
            "SELECT count FROM inventory WHERE char_id=$1 AND item_id=$2", self.char_id, item) or 0

    async def test_chest_and_fragment_exchange_preserve_exact_item_and_pet_counts(self):
        await self.db.grant_item(self.char_id, 199)
        body = Writer().u32(199).u32(0).string("").u32(1).bytes()
        responses = await self.send(516, body)
        self.assertEqual([i for i, _ in responses], [112, 526])
        ack = Reader(responses[-1][1])
        self.assertEqual((ack.u16(), ack.u32(), ack.u32(), ack.u8()), (0, 199, 0, 1))
        self.assertEqual(json.loads(ack.string()), {"elementType": "item", "elementID": 10004, "num": 1})
        self.assertEqual((await self.stack(199), await self.stack(10004)), (0, 1))
        self.assertEqual(await self.send(516, body), [(526, b"\x01\x00")])
        await self.db.grant_item(self.char_id, 187)
        silver = await self.send(516, Writer().u32(187).u32(0).string("").u32(1).bytes())
        self.assertEqual([i for i, _ in silver], [112, 473, 526])
        self.assertEqual(json.loads(Reader(silver[1][1]).string())["goldCoin"], 100)

        frag_id = 38012
        await self.db.grant_item(self.char_id, frag_id, 5)
        self.assertIn(262, [msg for msg, _ in await self.send(59)])
        results = await asyncio.gather(*[self.send(83, Writer().u32(frag_id).bytes()) for _ in range(2)])
        success = next(result for result in results if len(result) > 1)
        self.assertEqual([msg for msg, _ in success], [262, 3141, 84])
        self.assertIn([(84, b"\x01\x00")], results)
        reader = Reader(success[1][1])
        uid = reader.u64()
        self.assertEqual(json.loads(reader.string())["pokeID"], 26)
        self.assertEqual((await self.stack(frag_id), await self.db.pool.fetchval(
            "SELECT pet_template_id FROM pets WHERE pet_uid=$1 AND char_id=$2", uid, self.char_id)), (0, 26))

    async def test_seven_day_window_configured_gifts_and_replay(self):
        stored = await self.db.pool.fetchval("SELECT created_at FROM characters WHERE char_id=$1", self.char_id)
        day_one = stored.timestamp() + 100
        with patch("handlers.events.time.time", return_value=day_one):
            self.assertEqual(await self.send(391, Writer().u32(24).u32(0).bytes()), [(390, b"\x01\x00")])
            gift = Writer().u32(1).u32(0).bytes()
            result = await self.send(391, gift)
            self.assertEqual([msg for msg, _ in result], [112, 262, 390])
            self.assertEqual((await self.stack(38056), await self.stack(154)), (5, 1))
            self.assertEqual(await self.send(391, gift), [(390, b"\x01\x00")])
        with patch("handlers.events.time.time", return_value=day_one + 86400):
            result = await self.send(391, Writer().u32(24).u32(0).bytes())
            self.assertEqual([msg for msg, _ in result], [112, 262, 3141, 390])
            self.assertEqual(await self.stack(38056), 10)
        with patch("handlers.events.time.time", return_value=day_one + 7 * 86400):
            self.assertEqual(await self.send(391, Writer().u32(110).u32(0).bytes()), [(390, b"\x01\x00")])
        self.assertEqual(await self.db.character_values(self.char_id, ["seven1", "seven24", "seven110"]),
                         {"seven1": 1, "seven24": 1, "seven110": 0})

    async def test_shard_only_talent_upgrade_checks_slot_and_uses_packaged_cost(self):
        from pet_config import starting_skills

        skills, passive = starting_skills(45)
        passive[3]["paSkillID"] = 3761
        uid = await self.db.pool.fetchval(
            """INSERT INTO pets(char_id,pet_template_id,skills_json,passive_skills_json)
               VALUES($1,45,$2::jsonb,$3::jsonb) RETURNING pet_uid""",
            self.char_id, json.dumps(skills), json.dumps(passive))
        await self.db.grant_item(self.char_id, 10001, 42)
        self.assertEqual(await self.send(1302, Writer().u32(uid).u32(3).bytes()), [(1371, b"\x01\x00")])
        request = Writer().u32(uid).u32(7).bytes()
        result = await self.send(1302, request)
        self.assertEqual([msg for msg, _ in result], [112, 3141, 1371])
        ack = Reader(result[-1][1])
        self.assertEqual((ack.u16(), ack.u32(), ack.u32(), ack.u32()), (0, uid, 7, 3762))
        self.assertEqual(await self.stack(10001), 0)
        self.assertEqual(await self.send(1302, request), [(1371, b"\x01\x00")])
        stored = await self.db.pool.fetchval("SELECT passive_skills_json FROM pets WHERE pet_uid=$1", uid)
        self.assertEqual(json.loads(stored)[3]["paSkillID"], 3762)

    async def test_skill_books_partition_on_login_and_learn_and_upgrade_atomically(self):
        from pet_config import starting_skills

        skills, passive = starting_skills(26)
        uid = await self.db.pool.fetchval(
            """INSERT INTO pets(char_id,pet_template_id,skills_json,passive_skills_json)
               VALUES($1,26,$2::jsonb,$3::jsonb) RETURNING pet_uid""",
            self.char_id, json.dumps(skills), json.dumps(passive))
        for book, qty in ((20171, 2), (20307, 1), (20043, 1)):
            await self.db.grant_item(self.char_id, book, qty)
        self.assertEqual([msg for msg, _ in await self.send(59)], [37, 583])
        bad = Writer().u32(uid).u32(2).u32(20307).bytes()
        self.assertEqual(await self.send(1282, bad), [(1369, b"\x01\x00")])
        self.assertEqual(await self.stack(20307), 1)
        request = Writer().u32(uid).u32(2).u32(20171).bytes()
        learned = await asyncio.gather(self.send(1282, request), self.send(1282, request))
        result = next(result for result in learned if len(result) > 1)
        self.assertEqual([msg for msg, _ in result], [133, 3141, 1369])
        ack = Reader(result[-1][1])
        self.assertEqual((ack.u16(), ack.u32(), ack.u32(), ack.u32()), (0, uid, 2, 1711))
        self.assertIn([(1369, b"\x01\x00")], learned)
        self.assertEqual(await self.stack(20171), 1)
        upgrade = Writer().u32(uid).u32(2).bytes()
        await self.db.grant_item(self.char_id, 10001, 14)
        self.assertEqual(await self.send(1302, upgrade), [(1371, b"\x01\x00")])
        self.assertEqual((await self.stack(10001), await self.stack(20171)), (14, 1))
        await self.db.grant_item(self.char_id, 10001)
        result = await self.send(1302, upgrade)
        self.assertEqual([msg for msg, _ in result], [112, 133, 3141, 1371])
        ack = Reader(result[-1][1])
        self.assertEqual((ack.u16(), ack.u32(), ack.u32(), ack.u32()), (0, uid, 2, 1712))
        self.assertEqual((await self.stack(10001), await self.stack(20171)), (0, 0))
        for slot, book, new_skill in ((3, 20043, 431), (5, 20307, 3071)):
            result = await self.send(1282, Writer().u32(uid).u32(slot).u32(book).bytes())
            self.assertEqual([msg for msg, _ in result], [133, 3141, 1369])
            ack = Reader(result[-1][1])
            self.assertEqual((ack.u16(), ack.u32(), ack.u32(), ack.u32()), (0, uid, slot, new_skill))
        saved = await self.db.pool.fetchrow("SELECT skills_json,passive_skills_json FROM pets WHERE pet_uid=$1", uid)
        self.assertEqual(json.loads(saved["skills_json"])[2:], [1712, 431])
        self.assertEqual(json.loads(saved["passive_skills_json"])[1]["paSkillID"], 3071)

    async def test_first_recharge_uses_simulated_receipt_and_claims_mail_only_once(self):
        with patch.dict(os.environ, {"GAME_ENV": "test", "LOCAL_PAYMENT_SANDBOX": "1",
                                     "PAYMENT_PROVIDER": "local"}):
            listing = Writer().string("0").u32(0).u16(10).bytes()
            self.assertEqual(Reader((await self.send(978, listing))[0][1]).u16(), 0)
            self.assertEqual((await self.send(930))[0], (1077, b"\0" * 6))
            order = Writer().u32(2).string("local:N2:item-event-test-order").bytes()
            self.assertEqual([msg for msg, _ in await self.send(90, order)], [473, 89])
            self.assertEqual([msg for msg, _ in await self.send(90, order)], [473, 89])
            self.assertEqual((await self.send(930))[0], (1077, b"\0\0\0\0\1\0"))
            packet = Reader((await self.send(978, listing))[0][1])
            self.assertEqual(packet.u16(), 0)
            mail = json.loads(packet.string())["0"]
            self.assertEqual((mail["mCash"], mail["isFetch"]), (640, False))
            claim = Writer().string(mail["_id"]).u16(0).bytes()
            results = await asyncio.gather(self.send(1054, claim), self.send(1054, claim))
            granted = next(result for result in results if len(result) > 1)
            self.assertEqual([msg for msg, _ in granted], [112, 133, 473, 3141, 1106])
            self.assertIn([(1106, b"\x01\x00")], results)
            wallet = await self.db.pool.fetchrow(
                "SELECT diamond,first_charge_claimed FROM characters WHERE char_id=$1", self.char_id)
            self.assertEqual(tuple(wallet), (800, True))
            self.assertEqual((await self.stack(20456), await self.stack(188)), (10, 1))
            self.assertEqual(await self.db.pool.fetchval(
                "SELECT count(*) FROM pets WHERE char_id=$1 AND pet_template_id=208", self.char_id), 1)

    async def test_client_skill_task_progress_updates_without_database_type_error(self):
        task = Writer().u32(self.char_id).string("sevenDayCompleteTask").string("72").bytes()
        self.assertEqual(await self.send(632, task), [(630, b"\0\0")])
        values = await self.db.pool.fetchval("SELECT game_values FROM characters WHERE char_id=$1", self.char_id)
        self.assertEqual(json.loads(values)["sevendaycompletetask"], "72")
        claimed = Writer().u32(self.char_id).string("seven1").string("1").bytes()
        self.assertEqual(await self.send(632, claimed), [(630, b"\x01\x00")])
