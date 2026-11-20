import asyncio
import json
import os
import secrets
import unittest

from db.database import Database
from handlers.battle import handle
from pet_config import starting_skills
from protocol import Reader, Writer
from types import SimpleNamespace


class BattleExpTests(unittest.IsolatedAsyncioTestCase):
    async def test_snapshot_level_up_notifications_and_concurrent_result_replay(self):
        dsn = os.getenv("TEST_DATABASE_URL")
        if not dsn:
            self.skipTest("TEST_DATABASE_URL required")
        db = await Database.connect(dsn)
        account_id = None
        try:
            self.assertEqual(await db.pool.fetchval("SELECT current_database()"), "monster2_test_db")
            await db.initialize()
            token = "battle-exp-" + secrets.token_hex(12)
            account_id = await db.pool.fetchval(
                "INSERT INTO accounts(username,token) VALUES($1,$1) RETURNING user_id", token)
            char_id = await db.pool.fetchval(
                "INSERT INTO characters(account_id,world_id,name,level) VALUES($1,1,$2,20) RETURNING char_id",
                account_id, token)
            uids = []
            for template, slot, exp in ((7, 0, 44), (45, 1, 0), (26, 3, 0), (180, -1, 0)):
                skills, passive = starting_skills(template)
                uids.append(await db.pool.fetchval(
                    """INSERT INTO pets(char_id,pet_template_id,slot_index,exp,skills_json,passive_skills_json)
                       VALUES($1,$2,$3,$4,$5::jsonb,$6::jsonb) RETURNING pet_uid""",
                    char_id, template, slot, exp, json.dumps(skills), json.dumps(passive)))
            lead, other, support, reserve = uids
            await db.start_adventure(char_id, 2)
            self.assertTrue(await db.start_adventure_battle(char_id, "original", 2, 15, 1))
            # An edit concurrent with the fight cannot change its recipients.
            self.assertTrue(await db.update_primary_army(char_id, [lead, reserve], []))
            session = SimpleNamespace(db=db, char_id=char_id, session_id="reconnect")
            forged = Writer().u16(1).vector_strings([f"{lead},120", f"{reserve},95"]).bytes()
            self.assertEqual(await handle(263, forged, session), (186, b"\x01\x00"))
            trace = Writer().u16(1).vector_strings([f"{other},0", f"{lead},120"]).bytes()
            results = await asyncio.gather(handle(263, trace, session), handle(263, trace, session))
            success, replay = sorted(results, key=len, reverse=True)
            self.assertEqual(replay, (186, b"\x01\x00"))
            self.assertEqual([msg for msg, _ in success], [3141, 3141, 186])
            for (msg, data), uid, level, exp in zip(success[:2], (lead, other), (2, 1), (60, 16)):
                packet = Reader(data)
                self.assertEqual(packet.u64(), uid)
                pet = json.loads(packet.string())
                self.assertEqual((pet["objID"], pet["level"], pet["exp"]), (uid, level, exp))
                packet.finish()
            rows = await db.pool.fetch(
                "SELECT pet_uid,level,exp FROM pets WHERE char_id=$1 ORDER BY pet_uid", char_id)
            self.assertEqual([tuple(row) for row in rows],
                             [(lead, 2, 60), (other, 1, 16), (support, 1, 0), (reserve, 1, 0)])
            self.assertEqual(await db.pool.fetchval("SELECT exp FROM characters WHERE char_id=$1", char_id), 0)
        finally:
            if account_id is not None:
                await db.pool.execute("DELETE FROM accounts WHERE user_id=$1", account_id)
            await db.close()
