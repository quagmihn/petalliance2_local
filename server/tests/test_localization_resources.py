import sqlite3
import struct
import sys
import unittest
from contextlib import closing
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "tools"))
from decode_lua import decrypt


class LocalizationResourceTests(unittest.TestCase):
    def test_encrypted_language_catalog_decodes_to_runtime_mapping(self):
        encrypted = (ROOT / "unpacked/assets/res/Config/lang.txt").read_bytes()
        self.assertTrue(encrypted.startswith(b"XXTEA"))
        plain = decrypt(encrypted[5:], b"kyopkm").decode("utf-8")
        rows = {}
        for line in plain.splitlines()[1:]:
            language_id, filename, folder, _label = line.split("\t")
            rows[int(language_id)] = (filename, folder)
        self.assertEqual(rows[3], ("lang_en", "en"))
        self.assertEqual(rows[6], ("lang_vn", "vn"))

    def test_existing_translation_databases_have_runtime_keys(self):
        expectations = {
            "lang.db": {"login21": "切换账号", "login22": "确认选区"},
            "lang_en.db": {"login21": "LOG OUT", "login22": "CONFIRM",
                           "login26": "LOADING CHARACTER INFO...<1>%",
                           "map2": "LOST FOREST", "menu6": "TOWN"},
            "lang_vn.db": {"login21": "Đổi tài khoản", "login22": "Chọn server"},
        }
        for filename, values in expectations.items():
            path = ROOT / "unpacked/assets/res/Config/db" / filename
            with closing(sqlite3.connect(path)) as connection:
                self.assertEqual(connection.execute("PRAGMA integrity_check").fetchone()[0], "ok")
                for key, expected in values.items():
                    row = connection.execute(
                        "SELECT lang FROM tbl_lang WHERE code=?", (key,)).fetchone()
                    self.assertIsNotNone(row, f"{filename} missing {key}")
                    self.assertEqual(row[0], expected)

    def test_runtime_loader_decrypts_catalog_and_keeps_key_lookup_db_driven(self):
        source = (ROOT / "decoded_lua/assets/src/GameMgr/Support/LuaSqlite.lua").read_text()
        self.assertIn('string.sub(content, 1, 5) == "XXTEA"', source)
        self.assertIn('crypto.decryptXXTEA, string.sub(content, 6), "kyopkm"', source)
        self.assertIn('SELECT code, lang FROM tbl_lang', source)
        self.assertIn('return tostring(key or "")', source)
        for field in ("language=", "database_path=", "database_open_status=",
                      "translation_count=", "lookup_key=", "lookup_result=",
                      "fallback_reason="):
            self.assertIn(field, source)

    def test_reported_keys_exist_in_all_supported_language_databases(self):
        keys = ("menu5", "town8", "npcname2", "npcnick4", "train99998",
                "activity51", "login21", "login22")
        for filename in ("lang.db", "lang_en.db", "lang_vn.db"):
            path = ROOT / "unpacked/assets/res/Config/db" / filename
            with closing(sqlite3.connect(path)) as connection:
                values = dict(connection.execute(
                    "SELECT code,lang FROM tbl_lang WHERE code IN (" +
                    ",".join("?" for _ in keys) + ")", keys))
            self.assertEqual(set(values), set(keys), f"{filename} missing a reported key")

    def test_langinfo_dat_records_match_chinese_sqlite_resource(self):
        path = ROOT / "apk_extracted/assets/res/Config/LangInfo.dat"
        data = path.read_bytes()
        count = struct.unpack_from("<I", data, 0)[0]
        entries = {}
        offset = 4
        for _ in range(count):
            size = struct.unpack_from("<I", data, offset)[0]
            offset += 4
            record = data[offset:offset + size]
            offset += size
            key, value = record.split(b"\0", 1)
            self.assertTrue(value.endswith(b"\0"))
            entries[key.decode("utf-8")] = value[:-1].decode("utf-8")
        self.assertEqual(offset, len(data))
        with closing(sqlite3.connect(
                ROOT / "unpacked/assets/res/Config/db/lang.db")) as connection:
            sqlite_entries = dict(connection.execute("SELECT code,lang FROM tbl_lang"))
        self.assertEqual(entries.keys(), sqlite_entries.keys())
        differences = {key for key, value in entries.items()
                       if sqlite_entries.get(key) != value}
        self.assertEqual(differences, {"tipsnameerror"})
        self.assertEqual(entries["login21"], sqlite_entries["login21"])
        self.assertEqual(entries["login22"], sqlite_entries["login22"])


if __name__ == "__main__":
    unittest.main()
