import contextlib
import io
import json
import os
import tempfile
import unittest
from pathlib import Path
from types import SimpleNamespace
from unittest.mock import AsyncMock, patch

import asyncpg

from admin import copy_legacy_character_test as fixtures


def fixture_args(**overrides):
    return SimpleNamespace(**{
        "test_dsn_env": "TEST_DATABASE_URL", "apply": False, "manifest": None,
        "device_id": None, "level": 2, "gold": 500, "diamond": 250,
        "item": [(1, 3)], "independent": False, "active_quest": None,
        "cleared_adventure": None, **overrides,
    })


class QAFixtureTests(unittest.IsolatedAsyncioTestCase):
    def test_resources_reject_invalid_inputs(self):
        for overrides in (
            {"level": 0}, {"level": 100000}, {"gold": -1}, {"diamond": 1 << 32},
            {"item": [(0, 1)]}, {"item": [(1, 0)]}, {"item": [(1, 1), (1, 1)]},
            {"independent": True, "level": 1},
            {"independent": True, "active_quest": [10010]},
            {"independent": True, "cleared_adventure": [(1, 7)]},
        ):
            with self.subTest(overrides=overrides), self.assertRaises(ValueError):
                fixtures.fresh_resources(fixture_args(**overrides))

    async def test_non_test_database_rejected_before_any_write(self):
        for identity in (
            {"db": "monster2_db", "superuser": False},
            {"db": "monster2_test_db", "superuser": True},
        ):
            connection = AsyncMock()
            connection.fetchrow.return_value = identity
            with self.subTest(identity=identity), patch.dict(os.environ, {"TEST_DATABASE_URL": "unused"}), \
                    patch.object(fixtures.asyncpg, "connect", return_value=connection), \
                    self.assertRaisesRegex(ValueError, "non-superuser monster2_test_db"):
                await fixtures.create_fresh_control(fixture_args(apply=True))
            self.assertEqual(connection.fetchrow.await_count, 1)
            connection.transaction.assert_not_called()
            connection.execute.assert_not_called()
            connection.close.assert_awaited_once()

    async def test_dry_run_apply_and_rollback_against_postgres(self):
        dsn = os.getenv("TEST_DATABASE_URL")
        if not dsn:
            self.skipTest("TEST_DATABASE_URL required")
        connection = await asyncpg.connect(dsn)
        try:
            with tempfile.TemporaryDirectory() as directory, contextlib.redirect_stdout(io.StringIO()) as output:
                path = Path(directory) / "fixture.json"
                args = fixture_args(manifest=str(path), independent=True, active_quest=[2],
                                    cleared_adventure=[(1, 12)])
                await fixtures.create_fresh_control(args)
                plan = json.loads(output.getvalue())
                self.assertTrue(plan["dry_run"])
                self.assertEqual(plan["resources"]["inventory"], [[1, 3]])
                self.assertFalse(path.exists())
                self.assertIsNone(await connection.fetchval(
                    "SELECT char_id FROM characters WHERE name=$1", plan["character"]))

                args.apply = True
                await fixtures.create_fresh_control(args)
                manifest = json.loads(path.read_text())
                args.rollback = str(path)
                try:
                    self.assertEqual(path.stat().st_mode & 0o777, 0o600)
                    character = await connection.fetchrow(
                        "SELECT level,exp,gold,diamond FROM characters WHERE char_id=$1 AND account_id=$2",
                        manifest["char_id"], manifest["account_id"])
                    self.assertEqual(dict(character), {"level": 2, "exp": plan["resources"]["exp"],
                                                       "gold": 500, "diamond": 250})
                    self.assertEqual(await connection.fetchval(
                        "SELECT count FROM inventory WHERE char_id=$1 AND item_id=1", manifest["char_id"]), 3)
                    self.assertTrue(await connection.fetchval(
                        "SELECT game_values->'qa_independent'='true'::jsonb FROM characters WHERE char_id=$1",
                        manifest["char_id"]))
                    self.assertEqual([tuple(row) for row in await connection.fetch(
                        "SELECT quest_id,status FROM quests WHERE char_id=$1", manifest["char_id"])],
                        [(2, 0)])
                    self.assertEqual(await connection.fetchval(
                        "SELECT star_mask FROM character_adventure_clears WHERE char_id=$1 AND adventure_id=1",
                        manifest["char_id"]), 12)
                finally:
                    await fixtures.rollback_fixture(args)
                self.assertIsNone(await connection.fetchval(
                    "SELECT char_id FROM characters WHERE char_id=$1", manifest["char_id"]))
                self.assertEqual(await connection.fetchval(
                    "SELECT count(*) FROM inventory WHERE char_id=$1", manifest["char_id"]), 0)
        finally:
            await connection.close()
