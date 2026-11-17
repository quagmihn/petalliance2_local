import unittest
from types import SimpleNamespace

from game_socket import CMD, dispatch
from protocol import Reader, Writer


class QuestDB:
    def __init__(self):
        self.progress = None
        self.commit_count = 0

    async def set_first_tutorial_progress(self, char_id, progress):
        self.progress = (char_id, progress)
        return progress == [1]

    async def commit_first_tutorial_quest(self, char_id):
        self.commit_count += 1
        return char_id == 2

    async def home_state(self, char_id):
        if char_id != 2:
            return None
        return {"level": 1, "homeName": "starter", "furnitures": {}}

    async def ensure_first_quest_for_level_one(self, char_id):
        self.ensure_called = char_id

    @property
    def pool(self):
        return self

    async def fetch(self, query, char_id):
        return [{"quest_id": 1, "status": 0, "progress": [0]}]


class QuestProtocolTests(unittest.IsolatedAsyncioTestCase):
    def setUp(self):
        self.session = SimpleNamespace(db=QuestDB(), char_id=2, account_id=6,
                                       username="u", user_token="t", world_id=1)

    async def test_verified_ids_and_initial_tutorial_commit(self):
        self.assertEqual(CMD["quest_commit"], 400)
        result = await dispatch(self.session, 400, Writer().u32(1).bytes())
        self.assertEqual([entry[0] for entry in result], [726, 404])
        ack = Reader(result[0][1])
        self.assertEqual((ack.u16(), ack.u32(), ack.u8()), (0, 1, 0))
        ack.finish()
        ntf = Reader(result[1][1])
        self.assertEqual(ntf.u8(), 1)
        self.assertEqual((ntf.u32(), ntf.u8()), (10001, 0))
        ntf.u64()
        self.assertEqual((ntf.u8(), ntf.u32()), (1, 0))
        ntf.finish()

    async def test_only_validated_first_tutorial_progress_is_accepted(self):
        self.assertEqual(CMD["quest_update"], 3133)
        request = Writer().u32(1).u8(0).u64(1).u8(1).u32(1).bytes()
        ack_id, body = await dispatch(self.session, 3133, request)
        self.assertEqual(ack_id, 3132)
        self.assertEqual(Reader(body).u16(), 0)
        self.assertEqual(self.session.db.progress, (2, [1]))

        invalid = Writer().u32(10001).u8(0).u64(1).u8(1).u32(1).bytes()
        ack_id, body = await dispatch(self.session, 3133, invalid)
        self.assertEqual((ack_id, Reader(body).u16()), (3132, 1))

    async def test_non_configured_commit_is_rejected(self):
        ack_id, body = await dispatch(self.session, 400, Writer().u32(10001).bytes())
        self.assertEqual((ack_id, Reader(body).u16()), (726, 1))
        self.assertEqual(self.session.db.commit_count, 0)

    async def test_recharge_cd_uses_client_schema_and_distinct_ack(self):
        ack_id, body = await dispatch(self.session, 662, b"")
        self.assertEqual(ack_id, 655)
        r = Reader(body)
        self.assertEqual((r.i32(), r.string(), r.i32(), r.string()), (0, "", 0, "{}"))
        r.finish()

    async def test_get_home_118_uses_schema_ack_32_and_json_payload(self):
        self.assertEqual(CMD["get_home"], 118)
        ack_id, body = await dispatch(self.session, 118, Writer().u32(2).bytes())
        self.assertEqual(ack_id, 32)
        r = Reader(body)
        self.assertEqual(r.u16(), 0)
        import json
        self.assertEqual(json.loads(r.string()), {
            "level": 1, "homeName": "starter", "furnitures": {}})
        self.assertEqual(r.u32(), 2)
        r.finish()

    async def test_get_home_unknown_character_returns_protocol_error(self):
        ack_id, body = await dispatch(self.session, 118, Writer().u32(99).bytes())
        self.assertEqual(ack_id, 32)
        self.assertEqual(Reader(body).u16(), 1)

    async def test_quest_list_sends_count_and_configured_first_quest(self):
        from handlers.map import get_quests
        responses = await get_quests(self.session, b"")
        self.assertEqual([packet_id for packet_id, _ in responses], [26, 404])
        self.assertEqual(self.session.db.ensure_called, 2)
        ack = Reader(responses[0][1])
        self.assertEqual((ack.u16(), ack.u32()), (0, 1))
        ack.finish()
        ntf = Reader(responses[1][1])
        self.assertEqual(ntf.u8(), 1)
        self.assertEqual((ntf.u32(), ntf.u8()), (1, 0))
        ntf.u64()
        self.assertEqual((ntf.u8(), ntf.u32()), (1, 0))
        ntf.finish()


if __name__ == "__main__":
    unittest.main()
