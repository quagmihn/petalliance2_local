import unittest
from pathlib import Path

from admin.upgrade_character_level import (
    DEFAULT_CONFIG, exp_at_start_of_level, read_role_exp_table,
)


class LevelMigrationConfigTests(unittest.TestCase):
    def test_experience_config_is_parsed_and_level_15_exp_is_valid(self):
        table = read_role_exp_table(DEFAULT_CONFIG)
        self.assertEqual(len(table), 100)
        self.assertEqual(table[14], 5080)
        self.assertEqual(table[15], 6050)
        exp = exp_at_start_of_level(table, 15)
        self.assertEqual(exp, 5080)
        self.assertLess(table[14], table[15])
        self.assertLess(exp, table[15])

    def test_truncated_experience_file_is_rejected(self):
        import tempfile
        with tempfile.TemporaryDirectory() as directory:
            broken = Path(directory) / "ExperienceInfo.dat"
            broken.write_bytes(b"\x01\x00\x00\x00\x31\x00")
            with self.assertRaises(ValueError):
                read_role_exp_table(broken)

    def test_target_level_outside_config_is_rejected(self):
        with self.assertRaises(ValueError):
            exp_at_start_of_level({1: 60}, 2)


if __name__ == "__main__":
    unittest.main()
