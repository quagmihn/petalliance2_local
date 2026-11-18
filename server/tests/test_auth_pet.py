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

    async def test_chat_send_returns_explicit_unsupported_code_with_schema_ack(self):
        from handlers.chat import send_chat
        ack_id, payload = await send_chat(
            session(), Writer().string("2").string("world").string("hello").bytes())
        self.assertEqual((ack_id, Reader(payload).u16()), (35, 1))

    async def test_empty_territory_and_champion_have_client_schema(self):
        from game_socket import CMD, dispatch
        s = session(); s.char_id = 2
        self.assertEqual((CMD["query_self_territory"], CMD["query_self_territory_ack"]), (1644, 1664))
        ack_id, payload = await dispatch(s, CMD["query_self_territory"], b"")
        self.assertEqual(ack_id, 1664)
        r = Reader(payload); self.assertEqual((r.u16(), r.u32(), r.u8()), (0, 0, 0)); r.finish()
        self.assertEqual((CMD["get_week_champion"], CMD["get_week_champion_ack"]), (501, 498))
        ack_id, payload = await dispatch(s, CMD["get_week_champion"], b"")
        self.assertEqual(ack_id, 498)
        r = Reader(payload)
        self.assertEqual((r.u16(), r.u32(), r.string(), r.string(), r.u8(), r.string()),
                         (0, 0, "", "", 0, ""))
        r.finish()
        self.assertEqual((CMD["territory_info"], CMD["territory_info_ack"]), (1819, 1901))
        ack_id, payload = await dispatch(s, CMD["territory_info"], Writer().u8(1).u32(1).bytes())
        r = Reader(payload)
        code, count = r.u16(), r.u8()
        self.assertEqual((ack_id, code, count), (1901, 0, 0))
        r.finish()


class PostgreSQLIntegrationTests(unittest.IsolatedAsyncioTestCase):
    async def test_account_binding_character_pet_and_quest_seed(self):
        dsn = os.getenv("TEST_DATABASE_URL")
        if not dsn:
            self.skipTest("set TEST_DATABASE_URL to an isolated disposable database")
        db_name = urlsplit(dsn).path.lstrip("/")
        if not (db_name.endswith("_test") or db_name.endswith("_test_db")):
            self.skipTest("refusing integration writes unless database name ends in _test")
        from db.database import Database
        import secrets

        db = await Database.connect(dsn)
        username = "rctest-" + secrets.token_hex(8)
        account = None
        try:
            identity = await db.pool.fetchrow(
                "SELECT current_database() AS name, rolsuper FROM pg_roles WHERE rolname=current_user")
            self.assertEqual(identity["name"], "monster2_test_db")
            self.assertFalse(identity["rolsuper"], "integration tests must not run as superuser")
            await db.initialize()
            account = await db.create_account(username, secrets.token_hex(16))
            device_id, device_token = "device-" + secrets.token_hex(8), secrets.token_hex(16)
            await db.bind_device(device_id, 1, device_token, account["user_id"])
            char, starter = await db.create_character_with_pet(
                account["user_id"], 1, "char-" + secrets.token_hex(6), 1, 0, 7)
            self.assertIsNotNone(starter)
            game_values = char["game_values"]
            if isinstance(game_values, str): game_values = json.loads(game_values)
            expected_fashion = game_values["curfashion"]
            from handlers.player import write_char_base
            self.assertTrue(write_char_base(char, username).endswith(
                expected_fashion.encode() + b"\0"))
            from handlers.pet import pet_json, get_army
            from pet_config import validate_pet
            pet_data = json.loads(pet_json(starter))
            validate_pet(pet_data)
            self.assertEqual(pet_data["Stage"], 0)
            self.assertEqual(pet_data["objID"], starter["pet_uid"])
            self.assertEqual(pet_data["pokeID"], 7)
            self.assertEqual(len(pet_data["skills"]), 4)
            self.assertIsInstance(pet_data["equips"], list)
            self.assertGreater(pet_data["hp"], 100)
            from game_socket import dispatch
            real_session = SimpleNamespace(db=db, char_id=char["char_id"])
            army_ack, army_body = await get_army(real_session, b"")
            r = Reader(army_body)
            self.assertEqual((army_ack, r.u16(), json.loads(r.string())),
                             (1774, 0, {"1": [starter["pet_uid"]], "1h": []}))
            r.finish()
            boxes = [{"type": 1, "time": 123}]
            await db.pool.execute("UPDATE characters SET game_values=$2::jsonb WHERE char_id=$1",
                                  char["char_id"], json.dumps({"treasure_boxes": boxes}))
            ack, body = await dispatch(real_session, 227, b"")
            r = Reader(body)
            self.assertEqual((ack, r.u16(), json.loads(r.string())), (225, 0, boxes))
            r.finish()
            ack, body = await dispatch(real_session, 128, b"")
            r = Reader(body)
            self.assertEqual((ack, r.u16(), json.loads(r.string())), (181, 0, {"level": 0, "exp": 0}))
            r.finish()
            ack, body = await dispatch(real_session, 690, Writer().string("sevenDayCompleteTask").bytes())
            r = Reader(body)
            self.assertEqual((ack, r.u16(), r.string()), (721, 0, ""))
            r.finish()
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
            import struct
            from pathlib import Path
            vip_config = (Path(__file__).resolve().parents[2] /
                          "apk_extracted/assets/res/Config/VipInfo.dat").read_bytes()
            first_vip_id, first_vip_level = struct.unpack_from("<II", vip_config, 8)
            self.assertEqual(first_vip_level, wallet["vip_level"])
            base = Reader(write_char_base(char, username))
            base.string(); base.string(); base.u8(); base.u8()
            base.u32(); base.u32(); base.u32()
            self.assertEqual(base.u8(), first_vip_id)
            from handlers import economy
            ack, body = await economy.load_month_card(SimpleNamespace(db=db, char_id=char["char_id"]), b"")
            self.assertEqual(ack, 3106)
            r = Reader(body)
            self.assertEqual((r.i32(), r.string(), r.i32(), r.u8(), r.u32()), (0, "", 0, 0, 1))
            r.finish()
            from quest_config import load_quests
            quests = load_quests()
            char_id = char["char_id"]
            await db.ensure_first_quest_for_level_one(char_id)
            self.assertEqual(await db.commit_configured_tutorial_quest(char_id, quests[1], quests),
                             (True, [10001]))
            self.assertEqual(await db.commit_configured_tutorial_quest(char_id, quests[10001], quests),
                             (False, []))
            battle_session = "pgtest-" + secrets.token_hex(8)
            self.assertTrue(await db.start_tutorial_battle(char_id, battle_session, 99998))
            self.assertTrue(await db.finish_tutorial_battle(char_id, battle_session, True))
            self.assertFalse(await db.finish_tutorial_battle(char_id, battle_session, True))
            self.assertEqual(await db.commit_configured_tutorial_quest(char_id, quests[10001], quests),
                             (True, [2, 10002]))
            gold = await db.pool.fetchval("SELECT gold FROM characters WHERE char_id=$1", char_id)
            self.assertEqual(gold, sum(int(q.gold_reward) if q.gold_reward.isdigit() else 0
                                       for q in (quests[1], quests[10001])))
            self.assertEqual(await db.commit_configured_tutorial_quest(char_id, quests[10001], quests),
                             (True, []))
            self.assertEqual(await db.pool.fetchval("SELECT gold FROM characters WHERE char_id=$1", char_id), gold)
        finally:
            try:
                if account is not None:
                    await db.pool.execute("DELETE FROM accounts WHERE user_id=$1", account["user_id"])
            finally:
                await db.close()


if __name__ == "__main__":
    unittest.main()
