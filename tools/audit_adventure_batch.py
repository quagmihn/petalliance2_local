"""Enumerate authored Adventure geometry, event dependencies and reward plans."""
from collections import Counter
import json
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "server"))

from adventure_config import adventure_tools, obstruction_skills, scene_cells
from client_config import table, text_table
from reward_config import RewardConfigError, drop_plan, reward_options


def audit():
    stages = table("AdventureInfo")
    goals = {int(row[0]): row for row in text_table("Fbmb.txt") if row[0].isdigit()}
    event_tables = {2: table("MonstrosityInfo"), 8: table("MonsterGroupManInfo"),
                    21: table("DisposableInfo")}
    for kind, name in ((1, "fbpickup.txt"), (3, "obstruction.txt"), (7, "teleport.txt"),
                       (22, "fbnpc.txt")):
        event_tables[kind] = {int(row[0]): row for row in text_table(name) if row[0].isdigit()}
    result = {}
    for key, stage in stages.items():
        reasons, deferred = set(), set()
        cells = scene_cells(key)
        counts = Counter()
        if not cells:
            reasons.add("missing or incomplete authored geometry")
        if stage["prepose"] and stage["prepose"] not in stages:
            reasons.add(f"missing prepose {stage['prepose']}")
        for target in stage["target"]:
            if target not in goals:
                reasons.add(f"missing goal {target}")
        try:
            drop_plan(stage["rewards"])
            reward = True
        except RewardConfigError as exc:
            reasons.add(str(exc))
            reward = False
        for cell in cells:
            kind, value = cell["eventType"], cell["event"]
            counts[kind] += 1
            if kind in event_tables and value not in event_tables[kind]:
                reasons.add(f"cell {cell['id']} missing event {kind}:{value}")
                continue
            if kind == 1 and value not in adventure_tools():
                try:
                    reward_options(cell["award"])
                except RewardConfigError as exc:
                    deferred.add(f"pickup {cell['id']}: {exc}")
            if kind == 3 and value not in obstruction_skills():
                deferred.add(f"obstacle {value} lacks a confirmed skill requirement")
            if kind not in (0, 1, 2, 3, 4, 5, 7, 8, 21):
                deferred.add(f"event family {kind} needs its own acceptance")
            if kind == 21:
                disposable = event_tables[21][value]
                event_type = disposable["eventType"]
                if event_type in (2, 8) and disposable["eventRandomID"] not in event_tables[event_type]:
                    reasons.add(f"cell {cell['id']} missing disposable encounter {disposable['eventRandomID']}")
        result[key] = {"floors": stage["floor"], "authored_cells": len(cells), "scene": stage["scene"],
                       "level": stage["level"], "prepose": stage["prepose"],
                       "goals": stage["target"], "event_types": dict(counts), "clear_drop": stage["rewards"],
                       "valid_clear_drop": reward, "reference_errors": sorted(reasons), "pending": sorted(deferred)}
    return result


if __name__ == "__main__":
    entries = audit()
    summary = {"adventures": len(entries), "authored": sum(bool(entry["authored_cells"]) for entry in entries.values()),
               "authored_with_valid_drop": sum(bool(entry["authored_cells"]) and entry["valid_clear_drop"]
                                                 for entry in entries.values()),
               "without_known_reference_errors": sum(not entry["reference_errors"] for entry in entries.values()),
               "event_types": sorted({key for entry in entries.values() for key in entry["event_types"]})}
    print(json.dumps({"summary": summary, "adventures": entries}, indent=2))
