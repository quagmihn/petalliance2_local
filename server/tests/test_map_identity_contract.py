import json
import sqlite3
import unittest
from pathlib import Path
from types import SimpleNamespace

from game_socket import dispatch
from client_config import table, text_table
from protocol import Reader, Writer


ROOT = Path(__file__).resolve().parents[2]


class MapIdentityContractTests(unittest.IsolatedAsyncioTestCase):
    def test_lost_forest_and_secret_path_are_distinct_world_map_nodes(self):
        rows = text_table("map_node.txt")
        nodes = {row[6]: row for row in rows[1:] if row[0] == "1"}
        self.assertEqual((nodes["map2"][1], nodes["map2"][2], nodes["map2"][3]),
                         ("2", "2", "1"))
        self.assertEqual((nodes["map5"][1], nodes["map5"][2], nodes["map5"][3]),
                         ("10", "2", "2"))
        with sqlite3.connect(ROOT / "apk_extracted/assets/res/Config/db/lang_en.db") as db:
            names = dict(db.execute(
                "select code, lang from tbl_lang where code in ('map2','map5','fbname1','fbname2')"))
        self.assertEqual(names["map2"], "LOST FOREST")
        self.assertEqual(names["map5"], "SECRET PATH")
        self.assertEqual(names["fbname1"], "LOST FOREST")
        self.assertEqual(names["fbname2"], "SECRET PATH")

    def test_original_config_reuses_scene_template_but_keeps_adventure_identity(self):
        adventures = table("AdventureInfo")
        scenes = table("SceneInfo")
        self.assertEqual(adventures[1]["scene"], [1])
        self.assertEqual(adventures[2]["scene"], [1])
        def rows(adventure_id):
            a = adventures[adventure_id]
            return sorted((s for s in scenes.values()
                           if s["number"] in set(a["scene"]) and s["floor"] <= a["floor"]),
                          key=lambda s: (s["floor"], s["id"]))
        self.assertEqual(rows(1), rows(2))
        self.assertNotEqual(adventures[1]["target"], adventures[2]["target"])
        self.assertNotEqual(adventures[1]["rewards"], adventures[2]["rewards"])
        self.assertNotEqual(adventures[1]["prepose"], adventures[2]["prepose"])

    async def test_adventure_response_preserves_requested_map_id(self):
        class DB:
            def __init__(self):
                self.current = {}
            async def start_adventure(self, char_id, adventure_id):
                self.current[char_id] = adventure_id

        session = SimpleNamespace(db=DB(), char_id=2, current_adventure_id=None)
        for adventure_id in (1, 2):
            ack, body = await dispatch(session, 2996, Writer().u32(adventure_id).bytes())
            self.assertEqual(ack, 3080)
            r = Reader(body)
            self.assertEqual(r.u16(), 0)
            self.assertEqual(r.u32(), adventure_id)
            state = json.loads(r.string())
            r.finish()
            self.assertEqual(state["advID"], adventure_id)
            self.assertEqual(session.db.current[2], adventure_id)
            self.assertEqual(len(state["events"]), 30)


if __name__ == "__main__":
    unittest.main()
