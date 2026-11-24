import copy
import json
import subprocess
from pathlib import Path
import unittest
from types import SimpleNamespace
from handlers.pet import pet_json
from pet_config import starting_skills, validate_pet, pokemon


class PetRuntimeContracts(unittest.TestCase):
    def test_wild_capture_template_id_survives_battle_cleanup(self):
        root = Path(__file__).resolve().parents[2]
        source = (root / "decoded_lua/assets/src/GameMgr/Map/BattleMapMgr.lua").read_text()
        callback = source.split("function BattleMapMgr.sendGameOver", 1)[1].split(
            "function BattleMapMgr.battleSchedulerStart", 1)[0]
        keep = callback.index("local catchPetID = catchPet")
        clean = callback.index("BattleMapMgr.cleanPVPInfo()")
        restore = callback.index("BattleMapMgr.setCanCatchPet(catchPetID)")
        self.assertLess(keep, clean)
        self.assertLess(clean, restore)

    def test_capture_serializer_sends_wild_pet_template_and_unlocks_on_rejection(self):
        root = Path(__file__).resolve().parents[2]
        send = (root / "decoded_lua/assets/src/GameMgr/Battle/BattleCCSB.lua").read_text()
        process = (root / "decoded_lua/assets/src/Net/Process/PVEProcess.lua").read_text()
        self.assertIn("pokemonID = BattleMapMgr.getCanCatchPet()", send)
        rejection = process.split("function PVEProcess.onGC_PVEPokemonCatch_Ack", 1)[1]
        self.assertIn("CocosModuleMgr.setScreenTouch(true)", rejection)
        self.assertIn("BattleCCSB.setCatchButtonEnabled(true)", rejection)
        success_path = rejection.split("if (Proto.Error.ERROR_OK == res.code) then", 1)[1].split(
            "else", 1)[0]
        self.assertIn("res.isCatched == 1", success_path)
        error_path = rejection.split("else", 1)[1].split("CallbackMgr.doCallFunc", 1)[0]
        self.assertNotIn("finishProcess", error_path)
        self.assertNotIn("catchPetState(1", error_path)

    def test_strengthening_stage_is_independent_of_evolution(self):
        skills, passive = starting_skills(7)
        row = dict(pet_uid=123, pet_template_id=7, level=10, exp=0,
                   star=0, evolution=1, training_stage=2,
                   skills_json=skills, equips_json=[], passive_skills_json=passive)
        data = json.loads(pet_json(row))
        self.assertEqual((data["Stage"], data["evolution"]), (2, 1))

    def test_monster_hp_uses_per_mille_modifier(self):
        from pet_config import tutorial_monster, untrained_hp
        from handlers.battle import FIRST_GUIDE_BATTLE
        self.assertEqual(untrained_hp(13, 1, 0), 117)
        self.assertEqual(tutorial_monster()["hp"], 208)
        self.assertEqual(FIRST_GUIDE_BATTLE["hp"], 208)

    def test_all_starter_templates_use_configured_skills_and_stage(self):
        for template in (1, 4, 7):
            skills, passive = starting_skills(template)
            row = dict(pet_uid=123, pet_template_id=template, level=1, exp=0,
                       star=0, evolution=0, training_stage=0,
                       skills_json=json.dumps(skills), equips_json="[]",
                       passive_skills_json=json.dumps(passive))
            data = json.loads(pet_json(row))
            validate_pet(data)
            self.assertEqual(data["skills"], skills)
            self.assertEqual(data["Stage"], 0)
            self.assertEqual(data["pokeID"], template)
            self.assertGreater(data["hpmax"], pokemon(template)["rates"][0])
            for field, invalid in (("Stage", None), ("skills", "[]"),
                                   ("skills", []), ("skills", [999999, 0, 0, 0]),
                                   ("equips", "[]"), ("hp", 0)):
                bad = copy.deepcopy(data); bad[field] = invalid
                with self.assertRaises(ValueError):
                    validate_pet(bad)


class FormationRuntimeContracts(unittest.IsolatedAsyncioTestCase):
    def test_lua_team_power_reuses_detail_formula_and_ignores_missing_uid(self):
        root = Path(__file__).resolve().parents[2]
        program = """
local pets = dofile("decoded_lua/assets/src/GameMgr/Data/PokemonInfo.lua")
pets.getPokemonInfoByID = function(id) return {id=id} end
local first = {pokeID=1, fc=0, yoke={yokeValues={7}}}
local second = {pokeID=2, fc=900}
PetEducationMgr = {calPetFC=function(config, pet, yoke, rates)
    assert(config.id == pet.pokeID and yoke[1] == 7 and yoke[6] == 0 and rates[1] == 0)
    return 383
end}
pets.getPetInfoByObjID = function(id) return ({[11]=first,[12]=second})[id] end
assert(pets.getFightPoint({first,second}) == 1283)
assert(pets.getFightPointByObjID({11,12,13}) == 1283)
assert(pets.getFightPoint({}) == 0)
"""
        subprocess.run(["lua", "-"], input=program, text=True, cwd=root, check=True)

    async def test_primary_and_helper_vectors_match_army_uids(self):
        from handlers.pet import query_pets, get_army
        from protocol import Reader, Writer
        rows = []
        for uid, slot in ((41, 0), (42, 3), (43, -1)):
            skills, passive = starting_skills(7)
            rows.append(dict(pet_uid=uid, slot_index=slot, pet_template_id=7,
                             level=1, exp=0, star=0, evolution=0, training_stage=0,
                             skills_json=skills, equips_json=[], passive_skills_json=passive))
        class Pool:
            async def fetch(self, sql, char_id):
                return [row for row in rows if "slot_index>=0" not in sql or row["slot_index"] >= 0]
        session = SimpleNamespace(char_id=123, db=SimpleNamespace(pool=Pool()))
        ack, body = await query_pets(session, Writer().u64(123).u32(0).u32(10).bytes())
        r = Reader(body)
        self.assertEqual((ack, r.u16(), r.u64(), r.u32(), r.u32()), (3139, 0, 123, 0, 3))
        primary = [json.loads(r.string())["objID"] for _ in range(r.u8())]
        inactive = [json.loads(r.string())["objID"] for _ in range(r.u8())]
        self.assertEqual(r.u32(), 1)
        helpers = [json.loads(r.string())["objID"] for _ in range(r.u8())]; r.finish()
        self.assertEqual((primary, inactive, helpers), ([41], [43], [42]))
        ack, body = await get_army(session, b"")
        r = Reader(body)
        self.assertEqual((ack, r.u16(), json.loads(r.string())), (1774, 0, {"1": primary, "1h": helpers}))
        r.finish()


class TutorialBattleLuaContracts(unittest.TestCase):
    def test_adventure_trainer_tile_rules(self):
        root = Path(__file__).resolve().parents[2]
        subprocess.run(["lua", "server/tests/fixtures/trainer_tiles_harness.lua"], cwd=root, check=True)

    def test_second_battle_reports_result_before_tutorial_continuation(self):
        source = (Path(__file__).resolve().parents[2] /
                  "decoded_lua/assets/src/GameMgr/Common/GameGuideMgr1.lua").read_text()
        start = source.index("function GameGuideMgr.secondBattle()")
        end = source.index("function GameGuideMgr.firstPetCatch()", start)
        second_battle = source[start:end]
        self.assertIn("param=99999", second_battle)
        self.assertIn("BattleMapMgr.setBattleCallback(function(detail)", second_battle)
        self.assertIn("BattleMapMgr.sendGameOver(detail.result, detail.me)", second_battle)


if __name__ == "__main__":
    unittest.main()
