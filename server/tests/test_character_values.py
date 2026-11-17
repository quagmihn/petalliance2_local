import json
import unittest
from types import SimpleNamespace

from handlers.player import get_character_values
from protocol import Reader, Writer


class ValuesDB:
    async def character_values(self, _char_id, keys):
        from character_values import validate_character_values
        return validate_character_values(keys, {})


class CharacterValueContractTests(unittest.IsolatedAsyncioTestCase):
    async def test_loginmsgmgr_fields_have_expected_json_types(self):
        # The three exact batches issued by LoginMsgMgr.lua.
        keys = ["map_lock", "isMArenaOn", "sciencePoint", "resetScienceConsumeTime",
                "resetScienceConsumeNum", "scienceLevel", "todayWArenaFightTimes",
                "todayWArenaFightRefreshTimes", "wArenaUpdateTime", "explorePacketNum",
                "itemPacketNum", "petPacketNum", "todayBuyPowerCount", "lastBuyPowerTime",
                "furnitureDailyEventTimes", "friendPoints", "furnitureLostTowerMaxStepNumber",
                "furnitureSuitcaseValueRate", "furnitureComputerValueRate", "LifeSkillLevel",
                "LifeSkillCareer", "familyQuestFailedTime", "familyQuestOK", "familyQuestAwardIndex",
                "todayFamilyQuestNum", "todayFamilyQuestTime", "getFamilyDevoteBufferTime",
                "familyDevoteBuffer", "goldCoin", "familyDungeonStepNumber",
                "familyDungeonStepNumberUpdateTime", "recharge", "todayArenaFightTimes",
                "arenaUpdateTime", "todayArenaFightRefreshTimes", "arenaScore", "topRank",
                "todayMArenaFightTimes", "marenaUpdateTime", "todayMArenaFightRefreshTimes",
                "pvpArenaGrade", "pvpArenaPoint", "pvpArenaCoin", "fixPvpArenaPoint",
                "create_time", "achievementPoint", "arenaRank", "lostTowerFloor", "lostTowerPoint",
                "activity", "familyQuestID", "advExp1", "advExp2", "advExp3", "treasureBoxSelect",
                "worldBossTime", "catchRateAddCount", "survivalBattleFloor", "world"]
        session = SimpleNamespace(char_id=2, db=ValuesDB())
        ack_id, body = await get_character_values(session, Writer().u8(len(keys)).raw(
            b"".join(Writer().string(key).bytes() for key in keys)).bytes())
        self.assertEqual(ack_id, 747)
        r = Reader(body); self.assertEqual(r.u16(), 0); values = json.loads(r.string()); r.finish()
        self.assertIsInstance(values["map_lock"], str)
        self.assertIsInstance(values["isMArenaOn"], bool)
        self.assertIsInstance(values["sciencePoint"], int)
        self.assertIsInstance(values["activity"], dict)
        self.assertIsInstance(values["treasureBoxSelect"], str)
        self.assertEqual(values["treasureBoxSelect"], "")
        self.assertIsInstance(values["world"], int)
        self.assertEqual(set(values), set(keys), "one of LoginMsgMgr's requested keys lacks a typed contract")

    async def test_known_key_wrong_stored_type_uses_logged_typed_default(self):
        from character_values import validate_character_values
        values = validate_character_values(["treasureBoxSelect", "isMArenaOn"],
                                           {"treasureBoxSelect": 0, "isMArenaOn": 1})
        self.assertEqual(values, {"treasureBoxSelect": "", "isMArenaOn": True})


if __name__ == "__main__":
    unittest.main()
