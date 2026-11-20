import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


@unittest.skipUnless(shutil.which("lua"), "Lua interpreter is unavailable")
class LuaBattleProtocolContractTests(unittest.TestCase):
    def test_saved_formation_reaches_each_normal_battle_without_relogin(self):
        result = subprocess.run(["lua", "server/tests/fixtures/lua_formation_harness.lua"],
                                cwd=ROOT, text=True, capture_output=True, check=True)
        self.assertIn("LUA_FORMATION_OK", result.stdout)

    def test_client_serializer_and_ack_decoders(self):
        result = subprocess.run(["lua", "server/tests/fixtures/lua_battle_proto_harness.lua"],
                                cwd=ROOT, text=True, capture_output=True, check=True)
        self.assertIn("LUA_BATTLE_PROTO_OK request_hex=8800050000009e86010000000000", result.stdout)

    def test_rejected_searching_battle_releases_client_battle_lock(self):
        result = subprocess.run(["lua", "server/tests/fixtures/lua_battle_recovery_harness.lua"],
                                cwd=ROOT, text=True, capture_output=True, check=True)
        self.assertIn("LUA_BATTLE_RECOVERY_OK", result.stdout)


if __name__ == "__main__":
    unittest.main()
