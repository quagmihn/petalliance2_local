import json
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]


class ReconstructionRegistryTests(unittest.TestCase):
    def test_registry_covers_every_command_constant(self):
        source = (ROOT / "decoded_lua/assets/src/Net/Proto/ProtoCommand.lua").read_text()
        expected = {int(value): name for name, value in __import__("re").findall(
            r"\b([A-Z][A-Z0-9_]*)\s*=\s*(\d+)\s*,?", source)}
        registry = json.loads((ROOT / "docs/reconstruction/protocol_registry.json").read_text())
        actual = {row["id"]: row["name"] for row in registry["commands"]}
        self.assertEqual(actual, expected)
        self.assertEqual(registry["command_count"], 1024)

    def test_every_client_request_has_a_serializer_and_explicit_decoder_status(self):
        registry = json.loads((ROOT / "docs/reconstruction/protocol_registry.json").read_text())
        requests = registry["request_definitions"]
        self.assertEqual(len(requests), 374)
        self.assertTrue(all(row["request_serializer"]["status"] == "PARSED"
                            for row in requests))
        self.assertTrue(all(row["response_decoder"]["status"] in
                            ("PARSED", "NO_ACK_NAMED", "UNMAPPED") for row in requests))
        self.assertGreaterEqual(sum(bool(row["calling_lua_modules"]) for row in requests), 300)

    def test_every_hashed_asset_registry_row_has_sha256(self):
        path = ROOT / "docs/reconstruction/asset_registry.jsonl"
        rows = [json.loads(line) for line in path.read_text().splitlines()]
        self.assertEqual(len(rows), 16049)
        self.assertTrue(all(len(row["sha256"]) == 64 and row["size"] >= 0 for row in rows))


if __name__ == "__main__":
    unittest.main()
