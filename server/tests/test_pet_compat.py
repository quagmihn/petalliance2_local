from __future__ import annotations

import json
import os
import struct
import tempfile
import unittest
import asyncio
from types import SimpleNamespace
from urllib.parse import urlsplit

from handlers import pet
from protocol import Reader, Writer, frame, xor_payload
from pet_config import starting_skills
from admin.migrate_legacy_pets import (apply_plan, plan_rows, reconstruct_starting_skills,
                                       rollback)


class LegacyPetUnitTests(unittest.TestCase):
    def row(self, **overrides):
        skills, passive = starting_skills(1)
        row = dict(pet_uid=22, char_id=9, pet_template_id=1, nickname="legacy",
                   level=1, exp=0, star=0, evolution=0, slot_index=0,
                   skills_json=skills, passive_skills_json=passive,
                   equips_json=[], training_stage=0)
        row.update(overrides)
        return row

    def test_new_and_existing_valid_pet_serialize(self):
        for skills_json in (starting_skills(1)[0], json.dumps(starting_skills(1)[0])):
            data = json.loads(pet.pet_json(self.row(skills_json=skills_json)))
            self.assertEqual((data["objID"], data["pokeID"], data["Stage"]), (22, 1, 0))
            self.assertEqual(len(data["skills"]), 4)

    def test_legacy_jsonb_string_array_decodes_once(self):
        skills = starting_skills(1)[0]
        # asyncpg decodes a JSONB scalar string to its string contents; this is
        # the shape seen when old code stored an encoded array inside JSONB.
        data = json.loads(pet.pet_json(self.row(skills_json=json.dumps(skills))))
        self.assertEqual(data["skills"], skills)

    def test_missing_stage_returns_field_specific_error(self):
        row = self.row(); del row["training_stage"]
        with self.assertRaises(pet.PetDataError) as caught:
            pet.pet_json(row)
        self.assertEqual((caught.exception.pet_uid, caught.exception.field), (22, "Stage"))

    def test_reconstruction_uses_config_and_preserves_multiple_existing_skills(self):
        expected = starting_skills(1)[0]
        self.assertEqual(reconstruct_starting_skills(22, 1, []), expected)
        partial = reconstruct_starting_skills(22, 1, [expected[0], expected[1]])
        self.assertEqual(partial[:2], expected[:2])
        nonzero = [skill for skill in partial if skill]
        self.assertEqual(len(nonzero), len(set(nonzero)))
        passive_ids = [item["paSkillID"] for item in starting_skills(1)[1]
                       if item["paSkillID"]]
        self.assertEqual(len(passive_ids), len(set(passive_ids)))
        passive_ids = [item["paSkillID"] for item in starting_skills(1)[1]
                       if item["paSkillID"]]
        self.assertEqual(len(passive_ids), len(set(passive_ids)))

    def test_unknown_template_is_rejected(self):
        with self.assertRaisesRegex(ValueError, "unknown GeneInfo"):
            reconstruct_starting_skills(22, 999999, [])


class QueryPetsErrorTests(unittest.IsolatedAsyncioTestCase):
    async def test_invalid_pet_returns_schema_error_without_dropping_session(self):
        row = dict(pet_uid=22, char_id=9, pet_template_id=1, level=1, exp=0,
                   star=0, evolution=0, slot_index=0, skills_json=[],
                   passive_skills_json=[], equips_json=[], training_stage=0)

        class Pool:
            async def fetch(self, *_args):
                return [row]

        s = SimpleNamespace(account_id=7, char_id=9, db=SimpleNamespace(pool=Pool()))
        ack, body = await pet.query_pets(s, Writer().u64(9).u32(0).u32(1).bytes())
        self.assertEqual((ack, body), (3139, Writer().u16(1).bytes()))
        # A separate request remains serviceable on the same session.
        row["skills_json"] = starting_skills(1)[0]
        from game_socket import dispatch
        ack, body = await dispatch(s, 3140, Writer().u64(9).u32(0).u32(1).bytes())
        self.assertEqual((ack, Reader(body).u16()), (3139, 0))


@unittest.skipUnless(os.getenv("TEST_DATABASE_URL"), "requires TEST_DATABASE_URL")
class LegacyPetMigrationIntegrationTests(unittest.IsolatedAsyncioTestCase):
    async def asyncSetUp(self):
        dsn = os.environ["TEST_DATABASE_URL"]
        self.assertEqual(urlsplit(dsn).path.lstrip("/"), "monster2_test_db")
        from db.database import Database
        self.db = await Database.connect(dsn)
        identity = await self.db.pool.fetchrow(
            "SELECT current_database() AS name,(SELECT rolsuper FROM pg_roles WHERE rolname=current_user) superuser")
        self.assertEqual(identity["name"], "monster2_test_db")
        self.assertFalse(identity["superuser"])
        import secrets
        self.account = await self.db.create_account("petcompat-" + secrets.token_hex(8), secrets.token_hex(16))
        self.char = await self.db.create_character(self.account["user_id"], 1,
                                                   "petcompat-" + secrets.token_hex(6))
        self.pet_uid = await self.db.pool.fetchval(
            """INSERT INTO pets(char_id,pet_template_id,slot_index,skills_json,
                                 passive_skills_json,equips_json,training_stage)
               VALUES($1,1,0,'[]'::jsonb,'[]'::jsonb,'[]'::jsonb,0) RETURNING pet_uid""",
            self.char["char_id"])

    async def asyncTearDown(self):
        await self.db.pool.execute("DELETE FROM accounts WHERE user_id=$1", self.account["user_id"])
        await self.db.close()

    async def test_copy_of_legacy_pet_apply_retry_rollback_login_and_reconnect(self):
        rows = await self.db.pool.fetch("SELECT * FROM pets WHERE char_id=$1 ORDER BY slot_index,pet_uid",
                                        self.char["char_id"])
        initial = plan_rows(rows)
        self.assertEqual((initial[0]["pet_uid"], initial[0]["changed"]), (self.pet_uid, True))
        with tempfile.TemporaryDirectory() as temp:
            backup = os.path.join(temp, "legacy-backup.json")
            from game_socket import handle_client
            tcp_server = await asyncio.start_server(
                lambda reader, writer: handle_client(reader, writer, self.db), "127.0.0.1", 0)
            tcp_reader, tcp_writer = await asyncio.open_connection(
                "127.0.0.1", tcp_server.sockets[0].getsockname()[1])
            async def receive_raw():
                length, msg_id = struct.unpack("<HH", await tcp_reader.readexactly(4))
                return msg_id, await tcp_reader.readexactly(length - 4)
            try:
                tcp_writer.write(frame(1684, xor_payload(Writer().i32(self.char["char_id"])
                                                        .string(self.account["token"]).bytes())))
                await tcp_writer.drain()
                self.assertEqual((await receive_raw())[0], 773)
                query = Writer().u64(self.char["char_id"]).u32(0).u32(10).bytes()
                tcp_writer.write(frame(3140, xor_payload(query))); await tcp_writer.drain()
                ack, error_body = await receive_raw()
                self.assertEqual((ack, Reader(error_body).u16()), (3139, 1))

                # The schema error is returned without closing this real TCP
                # session. Apply only to the synthetic test character, then
                # repeat the same request over the same socket.
                await apply_plan(self.db, "monster2_test_db", self.account["user_id"],
                                 self.char["char_id"], initial, __import__("pathlib").Path(backup))
                tcp_writer.write(frame(3140, xor_payload(query))); await tcp_writer.drain()
                ack, body = await receive_raw()
                r = Reader(body)
                self.assertEqual((ack, r.u16(), r.u64()), (3139, 0, self.char["char_id"]))
                r.u32(); r.u32()
                self.assertEqual(r.u8(), 1)
                self.assertEqual(json.loads(r.string())["objID"], self.pet_uid)
            finally:
                tcp_writer.close()
                await tcp_writer.wait_closed()
                tcp_server.close()
                await tcp_server.wait_closed()
            migrated = await self.db.pool.fetchrow("SELECT * FROM pets WHERE pet_uid=$1", self.pet_uid)
            payload = json.loads(pet.pet_json(migrated))
            self.assertEqual((payload["objID"], payload["pokeID"], payload["Stage"]),
                             (self.pet_uid, 1, 0))
            self.assertEqual(payload["skills"], [981, 2801, 0, 971])
            self.assertEqual(migrated["slot_index"], 0)
            self.assertEqual(json_value_for_test(migrated["equips_json"]), [])

            # A second plan is idempotent; it creates no skill additions.
            retry = plan_rows(await self.db.pool.fetch(
                "SELECT * FROM pets WHERE char_id=$1 ORDER BY slot_index,pet_uid", self.char["char_id"]))
            self.assertFalse(retry[0]["changed"])

            # Login/relogin and QueryPets still read the same UID, active formation and skills.
            from handlers.auth import device_relogin
            from game_socket import dispatch
            relogin_session = SimpleNamespace(db=self.db, account_id=None, username="", world_id=1,
                                               char_id=None, user_token="")
            ack, _ = await device_relogin(relogin_session,
                Writer().i32(self.char["char_id"]).string(self.account["token"]).bytes())
            self.assertEqual(ack, 773)
            self.assertEqual(relogin_session.char_id, self.char["char_id"])
            ack, body = await dispatch(relogin_session, 3140,
                Writer().u64(self.char["char_id"]).u32(0).u32(10).bytes())
            r = Reader(body)
            self.assertEqual((ack, r.u16(), r.u64()), (3139, 0, self.char["char_id"]))
            r.u32(); r.u32()
            self.assertEqual(r.u8(), 1)
            self.assertEqual(json.loads(r.string())["objID"], self.pet_uid)

            # A fresh pool simulates a reconnect and confirms durable migration state.
            from db.database import Database
            reopened = await Database.connect(os.environ["TEST_DATABASE_URL"])
            try:
                same = await reopened.pool.fetchrow("SELECT * FROM pets WHERE pet_uid=$1", self.pet_uid)
                self.assertEqual(json_value_for_test(same["skills_json"]), [981, 2801, 0, 971])
            finally:
                await reopened.close()

            await rollback(self.db, "monster2_test_db", self.account["user_id"],
                           self.char["char_id"], __import__("pathlib").Path(backup))
            restored = await self.db.pool.fetchrow("SELECT skills_json,passive_skills_json FROM pets WHERE pet_uid=$1",
                                                   self.pet_uid)
            self.assertEqual((json_value_for_test(restored["skills_json"]),
                              json_value_for_test(restored["passive_skills_json"])), ([], []))


def json_value_for_test(value):
    return json.loads(value) if isinstance(value, str) else value


if __name__ == "__main__":
    unittest.main()
