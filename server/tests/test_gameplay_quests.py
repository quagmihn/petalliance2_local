import json
import unittest
from types import SimpleNamespace

from game_socket import CMD, dispatch
from handlers import battle
from protocol import Reader, Writer
from quest_config import load_quests


class QuestDB:
    """Handler contract fake; SQL transaction behavior is covered by optional PG tests."""
    def __init__(self):
        self.quests = {1: {"status": 0, "progress": [0]}}
        self.level = 1
        self.has_pet = True
        self.battles = {}

    async def ensure_first_quest_for_level_one(self, char_id):
        self.ensure_called = char_id
        self.quests.setdefault(1, {"status": 0, "progress": [0]})
        if self.has_pet and self.quests[1]["status"] == 0:
            self.quests[1]["progress"] = [1]

    async def update_configured_tutorial_progress(self, char_id, quest_id, progress, amount):
        row = self.quests.get(quest_id)
        if not row or row["status"] != 0 or progress != [amount]:
            return False
        if quest_id == 1 and self.has_pet:
            row["progress"] = progress
            return True
        if quest_id == 10002 and self.level >= 2:
            row["progress"] = progress
            return True
        if quest_id == 10003 and self.quests.get(2, {}).get("status") == 1:
            row["progress"] = progress
            return True
        return False

    async def start_tutorial_battle(self, char_id, session_id, group_id):
        if group_id != 99998 or self.quests.get(10001, {}).get("status") != 0:
            return False
        self.battles[session_id] = "started"
        return True

    async def finish_tutorial_battle(self, char_id, session_id, won):
        if self.battles.get(session_id) != "started":
            return False
        self.battles[session_id] = "won" if won else "lost"
        if won:
            self.quests[10001]["progress"] = [1]
        return True

    async def commit_configured_tutorial_quest(self, char_id, quest, all_quests):
        row = self.quests.get(quest.quest_id)
        if row is None:
            return False, []
        if row["status"] == 1:
            return True, []
        if row["status"] != 0:
            return False, []
        if quest.parent_id and self.quests.get(quest.parent_id, {}).get("status") != 1:
            return False, []
        if quest.quest_id == 1 and not self.has_pet:
            return False, []
        if quest.quest_id == 10001 and "won" not in self.battles.values():
            return False, []
        if quest.quest_id == 10002 and self.level < 2:
            return False, []
        if quest.quest_id == 10003 and self.quests.get(2, {}).get("status") != 1:
            return False, []
        row["status"] = 1
        row["progress"] = [quest.objectives[0].amount]
        children = []
        for child in quest.child_ids:
            if child and child not in self.quests:
                self.quests[child] = {"status": 0, "progress": [0] * max(1, len(all_quests[child].objectives))}
                children.append(child)
        return True, children

    async def home_state(self, char_id):
        return {"level": 1, "homeName": "starter", "furnitures": {}} if char_id == 2 else None

    @property
    def pool(self):
        return self

    async def fetch(self, _query, char_id):
        return [dict(quest_id=qid, status=row["status"], progress=row["progress"])
                for qid, row in sorted(self.quests.items())]


class QuestProtocolTests(unittest.IsolatedAsyncioTestCase):
    def setUp(self):
        self.session = SimpleNamespace(db=QuestDB(), char_id=2, account_id=6,
                                       username="u", user_token="t", world_id=1,
                                       session_id="session-a")
        self.config = load_quests()

    def test_new_quest_info_binary_config_and_chain(self):
        self.assertEqual(len(self.config), 747)
        self.assertEqual(self.config[1].child_ids, (10001,))
        self.assertEqual(self.config[10001].child_ids, (2, 10002))
        self.assertEqual(self.config[10002].child_ids, (10003,))
        self.assertEqual(self.config[10003].child_ids, (10005,))
        self.assertEqual(self.config[10001].objectives[0].event_type, 2)
        self.assertEqual(self.config[2].objectives[0].event_type, 19)
        self.assertEqual(self.config[10001].gold_reward, "2000")
        self.assertEqual(self.config[10001].unlock_map_id, "1")

    async def test_first_pet_battle_and_level_two_guide_progression(self):
        self.assertEqual(CMD["quest_commit"], 400)
        result = await dispatch(self.session, 400, Writer().u32(1).bytes())
        self.assertEqual([packet[0] for packet in result], [726, 404])
        ntf = Reader(result[1][1])
        self.assertEqual(ntf.u8(), 1)
        self.assertEqual((ntf.u32(), ntf.u8()), (10001, 0))
        ntf.u64(); self.assertEqual((ntf.u8(), ntf.u32()), (1, 0)); ntf.finish()

        # The client requests type 5 / trainer ID 1; server binds its response to group 99998.
        ack_id, body = await dispatch(self.session, 136,
                                      Writer().u32(5).u32(1).u32(0).bytes())
        self.assertEqual(ack_id, 210)
        r = Reader(body); self.assertEqual(r.u16(), 0)
        self.assertEqual(r.u8(), 1)
        monster = json.loads(r.string())
        self.assertEqual((monster["mID"], monster["level"], monster["skill1"]), (999996, 1, 371))
        self.assertEqual(r.u32(), 16); self.assertEqual(r.u8(), 0); r.finish()

        ack_id, body = await dispatch(self.session, 263, Writer().u16(1).vector_strings(["1,0"]).bytes())
        self.assertEqual((ack_id, Reader(body).u16(), self.session.db.quests[10001]["progress"]),
                         (186, 0, [1]))
        result = await dispatch(self.session, 400, Writer().u32(10001).bytes())
        self.assertEqual([packet[0] for packet in result], [726, 404])
        ntf = Reader(result[1][1]); self.assertEqual(ntf.u8(), 2)
        # Re-read with a fresh reader to assert configured children, not a hardcoded child.
        ntf = Reader(result[1][1]); count = ntf.u8(); children = []
        for _ in range(count):
            qid, status = ntf.u32(), ntf.u8(); ntf.u64(); n = ntf.u8()
            children.append(qid)
            for _ in range(n): ntf.u32()
        ntf.finish(); self.assertEqual(children, [2, 10002])
        duplicate = await dispatch(self.session, 400, Writer().u32(10001).bytes())
        self.assertEqual([packet[0] for packet in duplicate], [726])

        self.session.db.level = 2
        result = await dispatch(self.session, 400, Writer().u32(10002).bytes())
        self.assertEqual([packet[0] for packet in result], [726, 404])
        ntf = Reader(result[1][1]); self.assertEqual(ntf.u8(), 1)
        self.assertEqual((ntf.u32(), ntf.u8()), (10003, 0)); ntf.u64()
        self.assertEqual((ntf.u8(), ntf.u32()), (1, 0)); ntf.finish()

    async def test_arbitrary_and_unproven_commits_are_rejected(self):
        ack_id, body = await dispatch(self.session, 400, Writer().u32(10001).bytes())
        self.assertEqual((ack_id, Reader(body).u16()), (726, 1))
        ack_id, body = await dispatch(self.session, 400, Writer().u32(999999).bytes())
        self.assertEqual((ack_id, Reader(body).u16()), (726, 1))
        bad_update = Writer().u32(10001).u8(0).u64(1).u8(1).u32(1).bytes()
        ack_id, body = await dispatch(self.session, 3133, bad_update)
        self.assertEqual((ack_id, Reader(body).u16()), (3132, 1))

    async def test_configured_progress_requires_server_evidence(self):
        self.session.db.quests[10002] = {"status": 0, "progress": [0]}
        update = Writer().u32(10002).u8(0).u64(1).u8(1).u32(1).bytes()
        ack_id, body = await dispatch(self.session, 3133, update)
        self.assertEqual((ack_id, Reader(body).u16()), (3132, 1))
        self.session.db.level = 2
        ack_id, body = await dispatch(self.session, 3133, update)
        self.assertEqual((ack_id, Reader(body).u16()), (3132, 0))
        self.session.db.quests[2] = {"status": 0, "progress": [0]}
        ack_id, body = await dispatch(self.session, 3133,
                                      Writer().u32(2).u8(0).u64(1).u8(1).u32(1).bytes())
        self.assertEqual((ack_id, Reader(body).u16()), (3132, 1))

    async def test_battle_requires_active_server_issued_encounter(self):
        ack_id, body = await dispatch(self.session, 263,
                                      Writer().u16(1).vector_strings(["1,0"]).bytes())
        self.assertEqual((ack_id, Reader(body).u16()), (186, 1))

    async def test_failed_battle_does_not_complete_objective(self):
        self.session.db.quests[10001] = {"status": 0, "progress": [0]}
        await self.session.db.start_tutorial_battle(2, "session-a", 99998)
        ack_id, body = await dispatch(self.session, 263,
                                      Writer().u16(0).vector_strings(["1,0"]).bytes())
        self.assertEqual((ack_id, Reader(body).u16()), (186, 0))
        self.assertEqual(self.session.db.quests[10001]["progress"], [0])

    async def test_quest_list_uses_configured_initial_row(self):
        from handlers.map import get_quests
        self.session.db.quests = {1: {"status": 0, "progress": [0]}}
        responses = await get_quests(self.session, b"")
        self.assertEqual([packet_id for packet_id, _ in responses], [26, 404])
        ack = Reader(responses[0][1]); self.assertEqual((ack.u16(), ack.u32()), (0, 1)); ack.finish()
        ntf = Reader(responses[1][1]); self.assertEqual(ntf.u8(), 1)
        self.assertEqual((ntf.u32(), ntf.u8()), (1, 0)); ntf.u64()
        self.assertEqual((ntf.u8(), ntf.u32()), (1, 1)); ntf.finish()


if __name__ == "__main__":
    unittest.main()
