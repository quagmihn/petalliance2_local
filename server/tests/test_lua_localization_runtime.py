import base64
import shutil
import sqlite3
import subprocess
import tempfile
import unittest
from contextlib import closing
from pathlib import Path
from zipfile import ZIP_STORED, ZipFile

ROOT = Path(__file__).resolve().parents[2]


@unittest.skipUnless(shutil.which("lua"), "Lua interpreter is unavailable")
class LuaLocalizationRuntimeTests(unittest.TestCase):
    def test_loader_reads_named_rows_and_switches_language(self):
        result = subprocess.run(
            ["lua", "server/tests/fixtures/lua_localization_harness.lua"],
            cwd=ROOT, text=True, capture_output=True, check=True,
        )
        self.assertIn("LUA_LOCALIZATION_HARNESS_OK", result.stdout)
        self.assertIn("translation_count=3", result.stdout)
        self.assertIn("resolved_path=download/Config/db/lang_en.db", result.stdout)
        self.assertIn("candidate_path=res/Config/db/lang_en.db", result.stdout)
        self.assertIn("sqlite_header_valid=true", result.stdout)
        self.assertIn("selected_file=lang_vn", result.stdout)

    def test_signed_apk_language_asset_is_readable_sqlite_and_copyable(self):
        apk = ROOT / "dist/monster2_patched.apk"
        self.assertTrue(apk.is_file(), "build the patched APK before running this test")
        with ZipFile(apk) as archive:
            member = "assets/res/Config/db/lang_en.db"
            info = archive.getinfo(member)
            self.assertEqual(info.compress_type, ZIP_STORED)
            asset_bytes = archive.read(member)
        self.assertEqual(asset_bytes[:16], b"SQLite format 3\0")

        with tempfile.TemporaryDirectory() as temp_dir:
            writable_copy = Path(temp_dir) / "language_lang_en.db"
            writable_copy.write_bytes(asset_bytes)
            self.assertEqual(writable_copy.stat().st_size, len(asset_bytes))
            self.assertEqual(writable_copy.read_bytes(), asset_bytes)
            with closing(sqlite3.connect(writable_copy)) as connection:
                self.assertEqual(connection.execute("PRAGMA integrity_check").fetchone()[0], "ok")
                self.assertGreater(
                    connection.execute("SELECT COUNT(*) FROM tbl_lang").fetchone()[0], 0)
                self.assertEqual(
                    connection.execute(
                        "SELECT lang FROM tbl_lang WHERE code='menu5'").fetchone()[0],
                    "EXPLORE",
                )

    def test_runtime_apk_language_sidecars_match_sqlite_assets(self):
        expected = {
            "en": ("EXPLORE", "ASSEMBLE STONE", "Shawn", "Shawn"),
            "vn": ("Mạo Hiểm", "Đá Tập Kết", "Shawn", "Shawn"),
        }
        keys = ("menu5", "town8", "npcname2", "train99998")
        with ZipFile(ROOT / "dist/monster2_runtime.apk") as archive:
            for lang, translations in expected.items():
                with self.subTest(lang=lang), closing(sqlite3.connect(":memory:")) as db:
                    member = f"assets/res/Config/db/lang_{lang}.db"
                    image = archive.read(member)
                    self.assertEqual(base64.b64decode(archive.read(member + ".b64")), image)
                    db.deserialize(image)
                    self.assertEqual(db.execute("PRAGMA integrity_check").fetchone(), ("ok",))
                    actual = tuple(
                        db.execute("SELECT lang FROM tbl_lang WHERE code=?", (key,)).fetchone()[0]
                        for key in keys
                    )
                    self.assertEqual(actual, translations)

    def test_lua_source_parses(self):
        subprocess.run(
            ["luac", "-p", "decoded_lua/assets/src/GameMgr/Support/LuaSqlite.lua"],
            cwd=ROOT, check=True,
        )


if __name__ == "__main__":
    unittest.main()
