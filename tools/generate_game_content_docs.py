#!/usr/bin/env python3
"""Generate source-indexed quest and Adventure catalog documents from shipped configs."""
from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "server"))
from client_config import table
from quest_config import load_quests


def qobj(obj):
    return (f"type={obj.event_type}, main={obj.main_id}, sub={obj.sub_id}, "
            f"final={obj.final_id}, amount={obj.amount}, query={obj.query_type}")


def quest_index():
    quests = load_quests()
    lines = ["# Game content index", "",
             "Generated from `apk_extracted/assets/res/Config/NewQuestInfo.dat` "
             "with `server/quest_config.py`; quest IDs and raw objective fields are "
             "fully parsed. Text names/descriptions are localization keys/empty "
             "strings in this binary table, so prose semantics remain partial unless "
             "confirmed by client Lua.", "",
             f"Quest records: **{len(quests)}**. IDs are listed in the table below.", "",
             "Quest type numeric values are retained as configured; client enum names "
             "need separate enum confirmation. Parent and child links are direct "
             "configuration edges. Rewards are raw configured fields, not inferred.", "",
             "| ID | Type | Name key | Prerequisite | Children | Objective(s) | "
             "Award ID / gold / EXP / diamonds | NPC / map unlock | Status |",
             "|---:|---:|---|---:|---|---|---|---|---|"]
    for q in sorted(quests.values(), key=lambda x: x.quest_id):
        objectives = "; ".join(qobj(o) for o in q.objectives) or "none"
        child = ", ".join(map(str, (x for x in q.child_ids if x))) or "—"
        reward = f"{q.award_id} / {q.gold_reward} / {q.exp_reward} / {q.diamond_reward}"
        npcmap = f"NPC fields in objective; unlock_map={q.unlock_map_id}"
        text = f"{q.name or '∅'}; strong={q.strong_type or '∅'}; visible={q.need_visible}"
        lines.append(f"| {q.quest_id} | {q.quest_type} | {text} | {q.parent_id or '—'} | "
                     f"{child} | {objectives} | {reward} | {npcmap} | Config parsed; "
                     "runtime status not inferred |")
    lines += ["", "## Tutorial chain observed in config and Lua", "",
              "`1 → 10001 → {2, 10002} → 10003 → 10005 → 10006 → 10007 ...` "
              "(branches continue in the raw table; see every child edge above). "
              "`GameGuideMgr.lua` dispatches guide IDs to client walkthroughs; only "
              "IDs with corresponding guide handlers have a known UI flow.", "",
              "## Source and coverage limits", "",
              "- Full quest IDs, numeric types, parent/child references, raw objectives, "
              "reward fields, map-unlock strings, visibility and strong-guide flags: **FULL**.",
              "- Objective natural-language meanings and NPC names: **PARTIAL**; numeric "
              "event codes and IDs are retained without guessing.",
              "- Quest runtime state and rewards for untested quests: **NOT VERIFIED**.",
              "- Side/daily/event quest reset behavior: config present but server lifecycle "
              "coverage is not established by this index.", ""]
    return "\n".join(lines)


def adventure_matrix():
    adventures = table("AdventureInfo")
    scenes = table("SceneInfo")
    rewards = table("RewardInfo")
    elements = table("AwardElementInfo")
    rows = ["# Adventure matrix", "",
            "Generated from shipped `AdventureInfo`, `SceneInfo`, `RewardInfo`, and "
            "`AwardElementInfo` tables. Adventure IDs/parameters and scene-event "
            "assignments are parsed; display names remain localization keys.", "",
            f"Adventure configs: **{len(adventures)}**. Scene records: **{len(scenes)}**.", "",
            "| Map ID | Name key | Unlock/config requirements | Event IDs/types | "
            "Battle group evidence | Rewards | Runtime status |",
            "|---:|---|---|---|---|---|---|"]
    for aid, a in sorted(adventures.items()):
        cells = [s for s in scenes.values() if s["number"] in a["scene"] and s["floor"] <= a["floor"]]
        events = sorted({f"{s['event']}:{s['eventType']}" for s in cells if s["event"]})
        battles = sorted({s["event"] for s in cells if s["eventType"] == 8 and s["event"]})
        reward_id = a["rewards"]
        reward_text = f"EXP={a['Exp_rewards']}; reward={reward_id}"
        reward = rewards.get(reward_id)
        if reward:
            detail = []
            for eid, count in zip(reward["element"], reward["nReward"]):
                element = elements.get(eid)
                detail.append(f"{eid}×{count}" + (f"(type {element['elementType']}:{element['elementID']})" if element else "(unresolved)"))
            reward_text += "; " + ", ".join(detail)
        unlock = f"prepose={a['prepose']}, level={a['level']}, power={a['power']}, scenes={a['scene']}, floor≤{a['floor']}"
        rows.append(f"| {aid} | {a['name']} | {unlock} | {', '.join(events) or '—'} | "
                    f"{battles or 'No eventType 8 marker'} | {reward_text} | "
                    f"Configured; runtime not verified |")
    rows += ["", "## Coverage limits", "",
             "- Adventure/scene/reward table relationships: **FULL for parsed tables**.",
             "- Human map names, story prerequisites outside `prepose`, NPC prose, "
             "dungeon semantics and all battle-group mappings: **PARTIAL**.",
             "- Only map IDs exercised by current regression/runtime evidence can be "
             "considered implemented; rows marked configured are not runtime claims.",
             "- Missing protocol support and absent assets are not synthesized.", ""]
    return "\n".join(rows)


def add_catalog_sections(content: str) -> str:
    catalogs = [
        ("Event and activity catalog", "ActivityInfoClient",
         lambda r: f"type={r['type']}, page={r['page']}, opens={r['openServerDays']}d, "
                   f"duration={r['lastTime']}s, params={r['params']}"),
        ("Recharge package catalog", "NormalRechargeInfo",
         lambda r: f"money={r['money']}, currency={r['mCash']}+{r['giftMCash']}, "
                   f"bonusRate={r['bonusRate']}, order={r['orderName']}"),
        ("Month-card packages", "MonthCardRechargeInfo",
         lambda r: f"money={r['money']}, days={r['days']}, daily={r['mCashPerDay']}, "
                   f"initial={r['initMCash']}"),
        ("Fashion catalog", "FashionItemInfo",
         lambda r: f"sex={r['sex']}, file={r['filePath']}, hidden={r['isHide']}, "
                   f"skill={r['skillID']}"),
        ("Role level and EXP table", "ExperienceInfo",
         lambda r: f"roleExp={r['roleExp']}, powerCap={r['limitPower']}, "
                   f"levelPower={r['levelUpAddPower']}, petLevelMax={r['petLevelMax']}"),
    ]
    lines = [content.rstrip(), "", "## Other discovered catalogs", "",
             "These catalogs are parsed from shipped config. Presence is not proof of "
             "handler/runtime support. Activity dates and payment provider schedules "
             "are historical config and are not treated as live availability.", ""]
    for title, table_name, formatter in catalogs:
        records = table(table_name)
        lines += [f"### {title} ({len(records)} records)", "",
                  f"Source: `apk_extracted/assets/res/Config/{table_name}.dat`.", "",
                  "| ID | Configured data |", "|---:|---|"]
        for ident, record in sorted(records.items()):
            label = record.get("name", "")
            lines.append(f"| {ident} | {label} — {formatter(record)} |")
        lines.append("")

    shops, pools = table("ShopInfo"), table("ShopPoolInfo")
    lines += [f"### In-game shop catalog ({len(shops)} shop entries, {len(pools)} pools)", "",
              "ShopInfo references configured ShopPoolInfo pools. Currency semantics for "
              "the raw price field must be confirmed against the owning shop manager "
              "before serving purchases.", "", "| Shop ID | Pool IDs |", "|---:|---|"]
    for ident, row in sorted(shops.items()):
        lines.append(f"| {ident} | {row['shopPool']} |")
    lines += ["", "Pool item/price/count catalog:", "", "| Pool | Item IDs | Prices | counts |", "|---:|---|---|---|"]
    for ident, row in sorted(pools.items()):
        detail = row["shopDetail"]
        lines.append(f"| {ident} | {', '.join(str(x['itemID']) for x in detail)} | "
                     f"{', '.join(str(x['price']) for x in detail)} | "
                     f"{', '.join(str(x['number']) for x in detail)} |")

    event_tables = [("EventInfo", "EventInfo"), ("Event NPC", "EventNpcInfo"),
                    ("Map events", "MapEventInfo"), ("Event lists", "EventListInfo")]
    lines += ["", "### Event and map-event schemas", "",
              "The client includes activity, event, event-NPC, map-event, and random-event "
              "managers/configs. These are IDs/config records, not proof of present-day "
              "eligibility or a fully implemented event lifecycle.", ""]
    for title, name in event_tables:
        try:
            count = len(table(name))
            lines.append(f"- `{name}`: {count} parsed records (**config found; runtime partial/unverified**).")
        except Exception as exc:
            lines.append(f"- `{name}`: source found but parser incomplete ({type(exc).__name__}).")
    for fname in ("npc.txt", "TownNpc.txt", "map_npc.txt", "map_list.txt", "map_node.txt",
                  "map_event.txt", "quest.txt", "ExpOpenLock.txt", "ExperienceInfo.dat"):
        path = ROOT / "apk_extracted/assets/res/Config" / fname
        if path.exists():
            state = "parsed by quest/client config reader" if fname.endswith(".dat") else "source located; semantics not fully normalized"
            lines.append(f"- `{fname}`: **{state}**.")
    lines += ["", "### Recharge safety", "",
              "The catalogs above describe configured bundles only. The live payment "
              "provider flow has not been connected or simulated by this report; no "
              "receipt is fabricated. A local recharge sandbox still requires an "
              "explicit environment gate, provider isolation, idempotency and end-to-end "
              "tests before it can be called implemented.", ""]
    return "\n".join(lines)


def main():
    (ROOT / "GAME_CONTENT_INDEX.md").write_text(add_catalog_sections(quest_index()), encoding="utf-8")
    (ROOT / "ADVENTURE_MATRIX.md").write_text(adventure_matrix(), encoding="utf-8")


if __name__ == "__main__":
    main()
