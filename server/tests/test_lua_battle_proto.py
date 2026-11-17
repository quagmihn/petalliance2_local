import shutil
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


@unittest.skipUnless(shutil.which("lua"), "Lua interpreter is unavailable")
class LuaBattleProtocolContractTests(unittest.TestCase):
    def test_client_serializer_and_ack_decoders(self):
        result = subprocess.run(["lua", "server/tests/fixtures/lua_battle_proto_harness.lua"],
                                cwd=ROOT, text=True, capture_output=True, check=True)
        self.assertIn("LUA_BATTLE_PROTO_OK request_hex=8800050000009e86010000000000", result.stdout)


if __name__ == "__main__":
    unittest.main()
