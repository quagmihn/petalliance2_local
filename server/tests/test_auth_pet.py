import os
import json
import unittest
from types import SimpleNamespace
from urllib.parse import urlsplit

from handlers import auth, chat, pet
from protocol import ProtocolDecodeError, Reader, Writer


class FakePool:
    def __init__(self):
        self.binding = None

    async def fetchrow(self, query, *args):
        if "FROM device_bindings" in query:
            return self.binding
        if "FROM accounts WHERE user_id" in query:
            return {"user_id": 7, "username": "local-user", "token": "account-token"}
        if "FROM accounts WHERE token" in query:
            return {"user_id": 7, "username": "local-user", "token": "account-token"}
        if "FROM characters" in query:
            return None
        raise AssertionError(f"unexpected query: {query}")

    async def fetch(self, query, *args):
        if "FROM device_bindings" in query:
            return []
        raise AssertionError(f"unexpected query: {query}")


class FakeDB:
    def __init__(self):
        self.pool = FakePool()
        self.bind_calls = []

    async def upsert_account(self, username, token):
        return {"user_id": 7, "username": username, "token": token}

    async def bind_device(self, device_id, world_id, token, account_id):
        self.bind_calls.append((device_id, world_id, token, account_id))
        self.pool.binding = {"device_id": device_id, "world_id": world_id,
                             "device_token": token, "account_id": account_id}

    async def character(self, account_id, world_id):
        return None


def session():
    value = SimpleNamespace(db=FakeDB(), account_id=None, username="", world_id=1,
                            char_id=None, user_token="")
    return value


class LoginSequenceTests(unittest.IsolatedAsyncioTestCase):
    async def test_platform_login_ack_is_2126_and_has_valid_empty_vector(self):
        s = session()
        response_id, body = await auth.platform_login(
            s, Writer().string("local-user").string("account-token").bytes())
        self.assertEqual(response_id, 2126)
        r = Reader(body)
        self.assertEqual((r.i32(), r.string(), r.i32(), r.u8()), (0, "", 0, 0))
        r.finish()
        self.assertEqual(s.account_id, 7)

    async def test_client_info_matches_eleven_strings_and_two_dwords(self):
        s = session()
        names = ["127.0.0.1", "offline", "Android", "offline", "00:00:00:00:00:00",
                 "offline-device", "1", "0.2", "offline", "0x0", "local"]
        payload = b"".join(v.encode() + b"\0" for v in names) + Writer().u32(0).u32(1).bytes()
        response_id, body = await auth.client_info(s, payload)
        self.assertEqual(response_id, 132)
        self.assertEqual(Reader(body).u16(), 0)
        self.assertEqual(s.client_info["ip"], names[0])

    async def test_bind_then_device_login_returns_2183_and_no_character(self):
        s = session()
        s.account_id = 7
        request = Writer().string("device-id").string("1").string("device-token").bytes()
        ack_id, ack = await auth.device_bind(s, request)
        self.assertEqual(ack_id, 2179)
        self.assertEqual(Reader(ack).i32(), 0)
        login_id, login_body = await auth.device_login(s, request)
        self.assertEqual(login_id, 2183)
        r = Reader(login_body)
        self.assertEqual((r.i32(), r.string(), r.i32()), (0, "", 0))
        self.assertEqual(r.u32(), 0)  # no existing character
        r.u64(); r.i32()
        self.assertEqual(r.string(), "account-token")
        r.finish()

    async def test_device_login_rejects_wrong_token_with_proto_error(self):
        s = session()
        s.db.pool.binding = {"device_id": "device-id", "world_id": 1,
                             "device_token": "correct", "account_id": 7}
        request = Writer().string("device-id").string("1").string("wrong").bytes()
        ack_id, body = await auth.device_login(s, request)
        self.assertEqual(ack_id, 2183)
        r = Reader(body)
        self.assertNotEqual(r.i32(), 0)
        self.assertEqual(r.string(), "device binding not found")
        self.assertEqual(r.i32(), 0)
        r.finish()


class PetPacketTests(unittest.IsolatedAsyncioTestCase):
    async def test_capsule_cd_ack_has_both_indexed_records(self):
        msg_id, payload = await pet.get_capsule_egg_cds(None, b"")
        self.assertEqual(msg_id, 1526)
        r = Reader(payload)
        self.assertEqual(r.u16(), 0)
        self.assertEqual(r.u8(), 2)
        self.assertEqual([(r.u16(), r.u64()) for _ in range(2)], [(0, 0), (0, 0)])
        r.finish()


class ChatChannelTests(unittest.IsolatedAsyncioTestCase):
    async def test_dispatch_routes_channel_request_to_protocol_ack(self):
        from game_socket import CMD, dispatch

        self.assertEqual(CMD["change_channel"], 380)
        self.assertEqual(CMD["change_channel_ack"], 386)
        ack_id, payload = await dispatch(
            session(), CMD["change_channel"],
            Writer().string("zhucheng_1").string("{}").bytes())
        self.assertEqual(ack_id, CMD["change_channel_ack"])
        r = Reader(payload)
        self.assertEqual(r.u16(), 0)
        self.assertEqual(r.string(), "zhucheng_1")
        r.finish()

    async def test_change_channel_stores_channel_and_acks_386(self):
        s = session()
        request = Writer().string("zhucheng_2").string("{}").bytes()
        ack_id, payload = await chat.change_channel(s, request)
        self.assertEqual(ack_id, 386)
        r = Reader(payload)
        self.assertEqual(r.u16(), 0)
        self.assertEqual(r.string(), "zhucheng_2")
        r.finish()
        self.assertEqual((s.channel, s.channel_data), ("zhucheng_2", "{}"))

    async def test_empty_channel_is_rejected_as_malformed(self):
        with self.assertRaises(ProtocolDecodeError):
            await chat.change_channel(session(), Writer().string("").string("{}").bytes())


class PostgreSQLIntegrationTests(unittest.IsolatedAsyncioTestCase):
    async def test_account_binding_character_pet_and_quest_seed(self):
        dsn = os.getenv("TEST_DATABASE_URL")
        if not dsn:
            self.skipTest("set TEST_DATABASE_URL to an isolated disposable database")
        db_name = urlsplit(dsn).path.lstrip("/")
        if not db_name.endswith("_test"):
            self.skipTest("refusing integration writes unless database name ends in _test")
        from db.database import Database
        import secrets

        db = await Database.connect(dsn)
        username = "rctest-" + secrets.token_hex(8)
        try:
            await db.initialize()
            account = await db.create_account(username, secrets.token_hex(16))
            device_id, device_token = "device-" + secrets.token_hex(8), secrets.token_hex(16)
            await db.bind_device(device_id, 1, device_token, account["user_id"])
            char, starter = await db.create_character_with_pet(
                account["user_id"], 1, "char-" + secrets.token_hex(6), 1, 0, 7)
            self.assertIsNotNone(starter)
            snapshot = await db.player_snapshot(char["char_id"])
            self.assertEqual(len(snapshot["pets"]), 1)
            quest_rows = []
            for quest in snapshot["quests"]:
                progress = quest["progress"]
                if isinstance(progress, str): progress = json.loads(progress)
                quest_rows.append((quest["quest_id"], quest["status"], progress))
            self.assertEqual(quest_rows, [(1, 0, [0])])
            home = await db.home_state(char["char_id"])
            self.assertEqual(home, {"level": 1, "homeName": char["name"], "furnitures": {}})
            wallet = await db.pool.fetchrow(
                "SELECT gold,diamond,vip_level FROM characters WHERE char_id=$1", char["char_id"])
            self.assertEqual((wallet["gold"], wallet["diamond"], wallet["vip_level"]), (0, 0, 0))
            await db.pool.execute("DELETE FROM accounts WHERE user_id=$1", account["user_id"])
        finally:
            await db.close()


if __name__ == "__main__":
    unittest.main()
