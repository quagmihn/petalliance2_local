import unittest

from reward_config import RewardConfigError, resolve_reward


class QuestRewardConfigTests(unittest.TestCase):
    def test_configured_currency_and_item_rewards_resolve(self):
        self.assertEqual(resolve_reward(4000, draw=0),
                         {"kind": "g_cash", "id": 0, "num": 100000})
        self.assertEqual(resolve_reward(4001, draw=0),
                         {"kind": "item", "id": 10003, "num": 30})

    def test_configured_pet_reward_resolves_only_known_template(self):
        self.assertEqual(resolve_reward(2000, draw=0),
                         {"kind": "pet", "id": 116, "num": 1})

    def test_missing_reward_reference_fails_closed(self):
        with self.assertRaisesRegex(RewardConfigError, "missing RewardInfo"):
            resolve_reward(11006)

    def test_zero_reward_has_no_catalog_entry(self):
        self.assertIsNone(resolve_reward(0))


if __name__ == "__main__":
    unittest.main()
