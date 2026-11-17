import unittest
from types import SimpleNamespace
from unittest.mock import patch

from game_socket import Session, dispatch
from protocol import Reader, Writer


class EventStore:
    def __init__(self, active=1):
        self.active = active
        self.events = []

    async def record_adventure_events(self, char_id, adventure_id, event_ids):
        if adventure_id != self.active:
            return False
        self.events.extend((char_id, adventure_id, event_id) for event_id in event_ids)
        return True


class AdventureEventProtocolTests(unittest.IsolatedAsyncioTestCase):
    async def test_fire_adventure_event_uses_byte_vector_and_matching_ack(self):
        db = SimpleNamespace(record_adventure_events=None)
        store = EventStore()
        db.record_adventure_events = store.record_adventure_events
        session = SimpleNamespace(db=db, char_id=22, current_adventure_id=1)
        # CG_FireAdventureEvent_Req: adventure DWORD, vector BYTE count, DWORD IDs.
        ack, body = await dispatch(session, 4,
                                   Writer().u32(1).u8(2).u32(5).u32(30).bytes())
        self.assertEqual((ack, Reader(body).u16()), (5, 0))
        self.assertEqual(store.events, [(22, 1, 5), (22, 1, 30)])

    async def test_unknown_event_rejected_without_recording(self):
        store = EventStore()
        session = SimpleNamespace(db=SimpleNamespace(record_adventure_events=store.record_adventure_events),
                                  char_id=22, current_adventure_id=1)
        ack, body = await dispatch(session, 4, Writer().u32(1).u8(1).u32(999999).bytes())
        self.assertEqual((ack, Reader(body).u16()), (5, 1))
        self.assertEqual(store.events, [])

    async def test_empty_command_l_id_four_is_ping_ack_with_no_response(self):
        session = Session(SimpleNamespace())
        self.assertIsNone(await dispatch(session, 4, b""))

    async def test_seven_day_claim_returns_schema_valid_error_without_reward(self):
        session = Session(SimpleNamespace())
        ack, body = await dispatch(session, 391, Writer().u32(1).u32(0).bytes())
        response = Reader(body)
        self.assertEqual((ack, response.u16()), (390, 1))
        response.finish()

    async def test_friend_detail_failure_ack_releases_callback_without_disconnect(self):
        ack, body = await dispatch(Session(SimpleNamespace()), 1283, Writer().string("10").bytes())
        response = Reader(body)
        self.assertEqual((ack, response.u16()), (1261, 1))
        response.finish()

    async def test_zero_star_exit_returns_no_award_vector(self):
        async def finish(char_id, star, rewards):
            self.assertEqual((char_id, star, rewards), (22, 0, []))
            return []
        session = SimpleNamespace(db=SimpleNamespace(finish_adventure=finish), char_id=22,
                                  current_adventure_id=1)
        ack, body = await dispatch(session, 3082, Writer().u16(0).bytes())
        response = Reader(body)
        self.assertEqual((ack, response.u16()), (2995, 0))
        self.assertEqual(response.u8(), 0)
        response.finish()

    async def test_clear_uses_configured_reward_and_persists_ack_payload(self):
        stored = []
        async def finish(char_id, star, rewards):
            stored.extend(rewards)
            return ['{"kind":"exp","id":0,"num":60}',
                    '{"kind":"item","id":10002,"num":1}']
        tables = {
            "AdventureInfo": {1: {"Exp_rewards": 60, "rewards": 1}},
            "RewardInfo": {1: {"element": [5], "nReward": [1], "probability": [100]}},
            "AwardElementInfo": {5: {"elementType": 3, "elementID": 10002}},
        }
        session = SimpleNamespace(db=SimpleNamespace(finish_adventure=finish), char_id=22,
                                  current_adventure_id=1)
        with patch("handlers.map.client_table", side_effect=lambda name: tables[name]):
            ack, body = await dispatch(session, 3082, Writer().u16(12).bytes())
        response = Reader(body)
        self.assertEqual((ack, response.u16()), (2995, 0))
        self.assertEqual([response.string() for _ in range(response.u8())], [
            '{"elementType":"exp","elementID":0,"num":60}',
            '{"elementType":"item","elementID":10002,"num":1}',
        ])
        response.finish()
        self.assertEqual(stored, [{"kind": "exp", "id": 0, "num": 60},
                                  {"kind": "item", "id": 10002, "num": 1}])

    async def test_non_clear_nonzero_star_is_rejected(self):
        session = SimpleNamespace(db=SimpleNamespace(), char_id=22, current_adventure_id=1)
        with patch("handlers.map.client_table", return_value={1: {"Exp_rewards": 60, "rewards": 1}}):
            ack, body = await dispatch(session, 3082, Writer().u16(4).bytes())
        response = Reader(body)
        self.assertEqual((ack, response.u16()), (2995, 1))
        response.finish()


if __name__ == "__main__":
    unittest.main()
