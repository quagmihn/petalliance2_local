#!/usr/bin/env python3
"""Generate full, config-parsed content and protocol coverage indexes.

XDat tables are decoded through the Lua field declarations in
``decoded_lua/assets/src/Net/Proto`` via ``server.client_config``. Quest
relationships come only from NewQuestInfo.dat parent/child fields. Any
semantics not represented in those fields remain explicitly unknown.
"""
from __future__ import annotations

import ast
import json
import sys
from collections import Counter, defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "server"))
from client_config import table  # noqa: E402
from quest_config import load_quests  # noqa: E402

DOCS = ROOT / "docs"
CONFIG = ROOT / "apk_extracted/assets/res/Config"
LUA = ROOT / "decoded_lua/assets/src"


def md_table(headers: list[str], rows: list[list[object]]) -> list[str]:
    clean = lambda value: str(value).replace("|", "\\|").replace("\n", " ")
    return (["| " + " | ".join(headers) + " |",
             "| " + " | ".join("---" for _ in headers) + " |"]
            + ["| " + " | ".join(clean(v) for v in row) + " |" for row in rows])


def quest_validation(quests: dict[int, object]) -> dict[str, list]:
    ids = set(quests)
    errors: dict[str, list] = {"missing_child": [], "parent_child_mismatch": [],
                               "cycles": [], "missing_award": []}
    graph: dict[int, list[int]] = defaultdict(list)
    rewards = table("RewardInfo")
    for qid, q in quests.items():
        for child in q.child_ids:
            if not child:
                continue
            if child not in ids:
                errors["missing_child"].append([qid, child])
            else:
                graph[qid].append(child)
                parent = quests[child].parent_id
                if parent not in (0, qid):
                    errors["parent_child_mismatch"].append([qid, child, parent])
        if q.award_id and q.award_id not in rewards:
            errors["missing_award"].append([qid, q.award_id])
    visiting: set[int] = set()
    visited: set[int] = set()
    stack: list[int] = []

    def visit(node: int) -> None:
        if node in visiting:
            start = stack.index(node)
            cycle = stack[start:] + [node]
            if cycle not in errors["cycles"]:
                errors["cycles"].append(cycle)
            return
        if node in visited:
            return
        visiting.add(node); stack.append(node)
        for child in graph[node]:
            visit(child)
        stack.pop(); visiting.remove(node); visited.add(node)
    for qid in ids:
        visit(qid)
    return errors


def quest_docs() -> None:
    quests = load_quests()
    rows = []
    edges = []
    for qid, q in sorted(quests.items()):
        children = [x for x in q.child_ids if x]
        edges.extend([[qid, child] for child in children])
        objectives = "; ".join(
            f"type {o.event_type}: ({o.main_id},{o.sub_id},{o.final_id}), "
            f"amount {o.amount}, query {o.query_type}" for o in q.objectives) or "none"
        reward = f"award={q.award_id}; gold={q.gold_reward}; exp={q.exp_reward}; " \
                 f"diamonds={q.diamond_reward}"
        rows.append([qid, q.name or "(empty/localized elsewhere)", q.quest_type,
                     q.parent_id or "—", ", ".join(map(str, children)) or "—",
                     objectives, reward, q.unlock_map_id or "—", q.need_visible,
                     "Configured; objective action/backend status requires mapping"])
    errors = quest_validation(quests)
    content = ["# All quests", "",
               f"Parsed **{len(quests)} quests** from `NewQuestInfo.dat` using the "
               "binary row parser in `server/quest_config.py`.", "",
               "Numeric objective IDs are preserved exactly; no natural-language "
               "meaning is inferred where localization or client callsite evidence is absent.", "",
               *md_table(["ID", "Name key", "Type", "Parent", "Children", "Objective fields",
                          "Rewards", "Unlock map", "Visible", "Backend/runtime status"], rows),
               "", "## Dependency graph", "",
               f"Raw configured edges: **{len(edges)}**. See `{(DOCS / 'quest_graph.json').name}` "
               "for the machine-readable graph.", "",
               "## Automated graph validation", "",
               "```json", json.dumps(errors, indent=2), "```", "",
               "Required level is not a field in this quest schema; any such condition "
               "must be derived from the referenced feature/map config or Lua callsite. "
               "Required items, event, request/response are not encoded per quest row and "
               "are listed as unknown until a verified objective handler maps them.", ""]
    (DOCS / "ALL_QUESTS.md").write_text("\n".join(content))
    (DOCS / "quest_graph.json").write_text(json.dumps({
        "source": "NewQuestInfo.dat parentID/childIDs",
        "nodes": [{"id": qid, "type": q.quest_type, "parent": q.parent_id,
                   "children": [x for x in q.child_ids if x]} for qid, q in sorted(quests.items())],
        "edges": edges, "validation": errors,
    }, indent=2) + "\n")


def map_docs() -> None:
    adventures, scenes = table("AdventureInfo"), table("SceneInfo")
    groups = table("MonsterGroupManInfo")
    events = table("MapEventInfo")
    awards, elements = table("RewardInfo"), table("AwardElementInfo")
    scene_ids = set(s["number"] for s in scenes.values())
    rows, missing = [], {"missing_scene": [], "missing_battle_group": [], "missing_event": []}
    for aid, adv in sorted(adventures.items()):
        selected = [s for s in scenes.values()
                    if s["number"] in adv["scene"] and s["floor"] <= adv["floor"]]
        event_refs = sorted({(int(s["event"]), int(s["eventType"]))
                             for s in selected if s["event"]})
        battle_ids = sorted({event for event, typ in event_refs if typ == 8})
        for sid in adv["scene"]:
            if sid not in scene_ids:
                missing["missing_scene"].append([aid, sid])
        for gid in battle_ids:
            if gid not in groups:
                missing["missing_battle_group"].append([aid, gid])
        for event_id, _typ in event_refs:
            if event_id not in events and event_id not in groups:
                missing["missing_event"].append([aid, event_id])
        reward = awards.get(int(adv["rewards"]))
        reward_detail = "unknown"
        if reward:
            reward_detail = ", ".join(
                f"{eid}×{num} ({elements.get(eid, {}).get('elementType', '?')}:{elements.get(eid, {}).get('elementID', '?')})"
                for eid, num in zip(reward["element"], reward["nReward"])) or "none"
        rows.append([aid, adv["name"], adv["level"], adv["prepose"], adv["power"],
                     ",".join(map(str, adv["scene"])),
                     ", ".join(f"{event}:{typ}" for event, typ in event_refs) or "—",
                     ",".join(map(str, battle_ids)) or "—",
                     f"EXP {adv['Exp_rewards']}; reward {adv['rewards']}: {reward_detail}",
                     "Configured; Waydroid status not inferred"])
    content = ["# All maps and Adventure configs", "",
               f"Parsed **{len(adventures)} AdventureInfo IDs**, **{len(scenes)} SceneInfo rows**, "
               f"**{len(table('MapNodeInfo'))} MapNodeInfo rows**, **{len(events)} map-event configs**.", "",
               "Adventure map IDs, level/prepose/power fields, scene membership, event refs, "
               "battle groups, and reward references come from parsed client tables.", "",
               *md_table(["Map ID", "Name key", "Level", "Prepose", "Power", "Scenes",
                          "Events", "Battle groups", "Rewards", "Backend/runtime status"], rows),
               "", "## Referential validation", "", "```json", json.dumps(missing, indent=2), "```", "",
               "`AdventureInfo` has no universal quest prerequisite or explicit star condition; "
               "those are not fabricated. Runtime status is not established by config presence.", ""]
    (DOCS / "ALL_MAPS.md").write_text("\n".join(content))


def event_docs() -> None:
    catalogs = [("ActivityInfoClient", "Client activity definitions"),
                ("EventInfo", "Event definitions"), ("EventListInfo", "Event list entries"),
                ("EventNpcInfo", "Event NPC entries"), ("SigninInfo", "Sign-in rewards"),
                ("SevenDayInfo", "Seven-day activity entries"),
                ("AchievementInfo", "Achievements"),
                ("ActivityPokemonAchievementInfo", "Pet achievement entries")]
    lines = ["# All events and reward activities", "",
             "Catalog schemas are parsed from the client XDat declarations. Historical "
             "dates are retained; config presence does not establish current eligibility or runtime support.", ""]
    for name, title in catalogs:
        records = table(name)
        catalog_rows = [[rid, row.get("name", row.get("number", "")),
                         json.dumps(row, ensure_ascii=False, separators=(",", ":")),
                         "Protocol/request and runtime claim need separate verification"]
                        for rid, row in sorted(records.items())]
        lines += [f"## {title} — {name} ({len(records)} records)", "",
                  f"Source: `apk_extracted/assets/res/Config/{name}.dat`.", "",
                  *md_table(["ID", "Name/label", "Configured fields", "Protocol/backend/runtime"],
                            catalog_rows), ""]
    (DOCS / "ALL_EVENTS.md").write_text("\n".join(lines))


def battle_docs() -> None:
    groups, monsters = table("MonsterGroupManInfo"), table("MonstrosityInfo")
    scenes, adventures = table("SceneInfo"), table("AdventureInfo")
    scene_refs: dict[int, set[int]] = defaultdict(set)
    for scene in scenes.values():
        if scene["eventType"] == 8 and scene["event"]:
            scene_refs[int(scene["event"])].add(int(scene["number"]))
    map_refs: dict[int, set[int]] = defaultdict(set)
    for aid, adv in adventures.items():
        for gid, refs in scene_refs.items():
            if refs.intersection(adv["scene"]):
                map_refs[gid].add(aid)
    tutorial_groups = json.loads((ROOT / "server/config/tutorial_battle_groups.json").read_text())
    wild = json.loads((ROOT / "server/config/tutorial_wild_battles.json").read_text())
    enemies = []
    for gid, row in sorted(groups.items()):
        missing = [mid for mid in row["pokemons"] if mid not in monsters]
        context = "configured trainer-group table; caller gate unmapped"
        implemented = "Configured only; caller/authorization not verified"
        if gid in tutorial_groups:
            context = f"type {tutorial_groups[gid]['battle_type']}; quest {tutorial_groups[gid]['quest_id']}"
            implemented = "Configured tutorial resolver; Waydroid status in runtime report"
        enemies.append([gid, context, ",".join(map(str, sorted(map_refs[gid]))) or "—",
                        ",".join(map(str, row["pokemons"])), row["exp"],
                        "missing " + str(missing) if missing else "all templates resolve", implemented])
    for monster_id in wild["monster_ids"]:
        requirement, info = wild, monsters.get(int(monster_id), {})
        enemies.append([monster_id, f"type {requirement['battle_type']}; quest {requirement['quest_id']} (wild)",
                        "—", str(info.get("petnumber", "?")), info.get("exp", "?"),
                        "configured wild monster" if info else "missing monster", "tutorial wild resolver"])
    lines = ["# All battle groups and encounters", "",
             f"Configured trainer groups: **{len(groups)}**; configured wild tutorial encounters: **{len(wild['monster_ids'])}**.", "",
             *md_table(["Group/encounter ID", "Type/caller requirements", "Adventure maps",
                        "Enemy template IDs", "EXP", "Config validation", "Backend/runtime status"], enemies), ""]
    (DOCS / "ALL_BATTLE_GROUPS.md").write_text("\n".join(lines))


def pet_docs() -> None:
    catalogs = ["PokemonInfo", "PokemonBallInfo", "PetAdvanceInfo", "PetStrengthenInfo",
                "PetEvoInfo", "PetStarUpInfo", "PetSkillInfo", "PetEquipInfo",
                "ExperienceInfo", "ItemInfo", "GeneInfo", "AttributeChangeInfo"]
    lines = ["# All Pet systems", "",
             "Every listed table is decoded from the client configuration using its Lua "
             "XDat field declaration. Detailed rows are retained in the JSON companion.", ""]
    summary = {}
    for name in catalogs:
        data = table(name)
        summary[name] = {str(i): row for i, row in data.items()}
        lines.append(f"- `{name}.dat`: **{len(data)} records**; backend status: config indexed, "
                     "feature-specific protocol/runtime validation required.")
    lines += ["", "## Capture ball facts", "",
              "`PokemonBallInfo` defines ball IDs and rarity probability vectors. "
              "`BattleCCSB.lua` order is `{2,3,1}`; `ItemInfo` IDs 1, 2, 3 are the actual "
              "Master/Para/Senior ball items. The catch UI's add button issues market item 201. "
              "Parsed `MarketInfo.dat` row 201 specifies item 1, `coinType=2` (diamonds), "
              "price 600. No starter quest award references those ball IDs.", "",
              "## Runtime status", "",
              "Pet EXP feed and tutorial Stage handlers have PostgreSQL integration coverage. "
              "A capture protocol handler and a live capture success still require separate "
              "implementation/runtime verification.", ""]
    (DOCS / "ALL_PET_SYSTEMS.md").write_text("\n".join(lines))
    (DOCS / "pet_config_index.json").write_text(json.dumps(summary, ensure_ascii=False, indent=2) + "\n")


def protocol_docs() -> None:
    path = ROOT / "server/game_socket.py"
    tree = ast.parse(path.read_text())
    commands = next(ast.literal_eval(node.value) for node in tree.body
                    if isinstance(node, ast.Assign) and any(
                        isinstance(target, ast.Name) and target.id == "CMD" for target in node.targets))
    dispatch = next(node for node in tree.body if isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef))
                    and node.name == "dispatch")
    route_names: dict[str, str] = {}
    for node in ast.walk(dispatch):
        if isinstance(node, ast.If):
            test = ast.unparse(node.test)
            if "CMD[" in test:
                try:
                    key = test.split('CMD[', 1)[1].split(']', 1)[0].strip("'\"")
                    calls = [n for n in ast.walk(node) if isinstance(n, ast.Call)
                             and isinstance(n.func, ast.Attribute)]
                    if calls:
                        route_names[key] = calls[0].func.attr
                except (IndexError, ValueError):
                    pass
    rows = []
    for key, message_id in sorted(commands.items(), key=lambda kv: (kv[1], kv[0])):
        if key.endswith("_ack") or key.endswith("_ntf"):
            continue
        response_key = key + "_ack"
        response_id = commands.get(response_key, "notification/paired ACK not represented in CMD")
        route = route_names.get(key, "unmapped" if key in commands else "—")
        status = "handler routed; feature behavior must be integration/runtime tested" if route != "unmapped" else "no explicit route"
        if key == "use_item":
            status = "Pet EXP feed handler; PostgreSQL TCP integration tested; Waydroid blocked"
        elif key == "create_pve_battle":
            status = "tutorial/adventure paths routed; type 1 tutorial wild encounter Waydroid start tested"
        rows.append([message_id, key, response_id, route, status])
    lines = ["# Protocol coverage", "",
             "Request IDs and ACK IDs are parsed from the server's literal command map; "
             "dispatch routes come from Python AST. Client serializer definitions live under "
             "`decoded_lua/assets/src/Net/Proto` and `Net/Send`.", "",
             *md_table(["Request ID", "Request name", "Response ID", "Server route", "Coverage status"], rows), ""]
    (DOCS / "PROTOCOL_COVERAGE.md").write_text("\n".join(lines))


def main() -> int:
    DOCS.mkdir(exist_ok=True)
    quest_docs(); map_docs(); event_docs(); battle_docs(); pet_docs(); protocol_docs()
    print("generated docs/ALL_QUESTS.md docs/ALL_MAPS.md docs/ALL_EVENTS.md "
          "docs/ALL_BATTLE_GROUPS.md docs/ALL_PET_SYSTEMS.md docs/PROTOCOL_COVERAGE.md")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
