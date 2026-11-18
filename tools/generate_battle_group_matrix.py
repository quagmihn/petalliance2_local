#!/usr/bin/env python3
"""Generate an auditable index of configured MonsterGroupManInfo rows."""
from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "server"))
from client_config import table  # noqa: E402
from battle_group_config import tutorial_requirements  # noqa: E402


def main() -> None:
    groups = table("MonsterGroupManInfo")
    scenes = table("SceneInfo")
    adventures = table("AdventureInfo")
    requirements = tutorial_requirements()
    scene_groups: dict[int, set[int]] = {}
    for scene in scenes.values():
        if int(scene.get("eventType", 0)) == 8:
            scene_groups.setdefault(int(scene["event"]), set()).add(int(scene["number"]))
    adventure_maps: dict[int, set[int]] = {}
    for adventure in adventures.values():
        for scene_id in adventure["scene"]:
            for group_id, refs in scene_groups.items():
                if scene_id in refs:
                    adventure_maps.setdefault(group_id, set()).add(int(adventure["id"]))

    lines = [
        "# Battle group matrix",
        "",
        "Generated from `MonsterGroupManInfo.dat`, `MonstrosityInfo.dat`, `SceneInfo.dat`, `AdventureInfo.dat`, and the decoded tutorial guide callers.",
        "The table lists the 907 configured trainer groups. A config row alone does not authorize a player to start that battle; runtime access needs a verified caller context.",
        "",
        "| Group ID | Battle type/context | Quest ID | Map/Adventure IDs | Enemies | Config EXP | Requirements | Implementation status |",
        "|---:|---|---:|---|---|---:|---|---|",
    ]
    for group_id, group in sorted(groups.items()):
        requirement = requirements.get(int(group_id))
        maps = sorted(adventure_maps.get(int(group_id), set()))
        context = "PVE MonsterManGroup (5)" if requirement else "MonsterManGroup; caller-specific"
        qid = str(requirement["quest_id"]) if requirement else "—"
        map_ids = ",".join(map(str, maps)) or "—"
        enemies = ",".join(map(str, group["pokemons"])) or "none"
        gate = f"quest {qid} active" if requirement else "caller/map authorization not mapped"
        status = "Implemented; config enemies + win progress" if requirement else "Config indexed; runtime context not implemented/verified"
        lines.append(f"| {group_id} | {context} | {qid} | {map_ids} | {enemies} | {group['exp']} | {gate} | {status} |")
    lines += [
        "",
        "## Verified guide call sites",
        "",
        "| Group ID | Lua flow | Active quest gate | Enemy config ID | Runtime status |",
        "|---:|---|---:|---:|---|",
    ]
    for group_id, requirement in sorted(requirements.items()):
        group = groups[group_id]
        lines.append(f"| {group_id} | `{requirement['lua_flow']}` | {requirement['quest_id']} | {','.join(map(str, group['pokemons']))} | Implemented; see Waydroid/TCP report for runtime acceptance |")
    (ROOT / "BATTLE_GROUP_MATRIX.md").write_text("\n".join(lines) + "\n")


if __name__ == "__main__":
    main()
