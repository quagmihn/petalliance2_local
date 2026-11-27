"""Daily mission gifts and claimable milestones from authoritative progress."""
from functools import cache
import json
import time

from client_config import table
from handlers.inventory import award_strings, reward_packets
from progress import daily_state
from protocol import Writer
from reward_config import RewardConfigError, drop_plan, resolve_award_element, roll_drop
from reward_service import receive_rewards


EVENTS = {
    3: "ADVENTURE_NORMAL_CLEARED", 4: "ADVENTURE_ELITE_CLEARED", 5: "ADVENTURE_HERO_CLEARED",
    6: "PET_FED", 7: "GACHA_COMPLETED", 8: "PET_CAPTURED", 9: "ARENA_BATTLE_FINISHED",
    13: "PET_ENHANCED", 17: "STAMINA_PURCHASED", 34: "ADVENTURE_ENTERED",
}
LEVEL_CONFIG = {1019: 22001, 1010: 22003, 1016: 22004, 1006: 22005, 1017: 22006,
                1015: 22007, 1018: 22008, 1023: 24017}
PROGRESS_FIELDS = {"cwhd", "zyhq", "zyhq1", "zyhq2", "zldj", "gkfb1", "gkfb2", "gkfb3",
                   "ndj", "ndj1", "ccyc6", "jjc", "jjc1"}


@cache
def daily_missions():
    return {key: row for key, row in table("NewQuestInfo").items()
            if row["type"] == 2 and row["resetType"] == 1 and row["needVisable"]}


def mission_progress(mission, state):
    scores = state["events"]
    return [min(objective["amount"], scores.get(EVENTS.get(objective["eventType"]), 0))
            for objective in mission["objectiveList"]]


def daily_rows(values, now):
    state = daily_state(values, now)
    return [(key, int(key in state["missions"]), mission_progress(mission, state))
            for key, mission in daily_missions().items()]


async def daily_updates(session):
    from handlers.map import quest_notifications

    current = daily_rows(await values_for(session), time.time())
    previous = session.daily_entries
    session.daily_entries = current
    if previous is None:
        return []
    changed = [entry for entry, before in zip(current, previous, strict=True) if entry != before]
    return list(quest_notifications(changed)) if changed else []


async def values_for(session):
    if session.char_id is None:
        return {}
    return json.loads(await session.db.pool.fetchval(
        "SELECT game_values FROM characters WHERE char_id=$1", session.char_id) or "{}")


async def daily_claim(session, key, *, gift=False):
    from handlers.economy import wallet_update

    failure = (1798 if gift else 726, Writer().u16(1).bytes())
    if session.char_id is None:
        return failure
    now = time.time()
    async with session.db.pool.acquire() as conn, conn.transaction():
        row = await conn.fetchrow("SELECT * FROM characters WHERE char_id=$1 FOR UPDATE", session.char_id)
        values = json.loads(row["game_values"])
        state = daily_state(values, now)
        if gift:
            milestones = table("GlobalConfigAddInfo")
            needs, drops = milestones[30]["values"], milestones[31]["values"]
            if not 1 <= key <= min(len(needs), len(drops)) or state["power"] < needs[key - 1]:
                return failure
            claimed, drop = state["gifts"], drops[key - 1]
        else:
            mission = daily_missions().get(key)
            if mission is None or not mission["objectiveList"]:
                return failure
            lock = LEVEL_CONFIG.get(key)
            if lock and row["level"] < table("GlobalConfigAddInfo")[lock]["values"][0]:
                return failure
            for objective, value in zip(mission["objectiveList"], mission_progress(mission, state), strict=True):
                if (objective["eventType"] not in EVENTS or objective["mainID"] or objective["subID"]
                        or objective["finalID"] or value < objective["amount"]):
                    return failure
            claimed, drop = state["missions"], mission["awardID"]
        if key in claimed:
            return failure
        try:
            awards = roll_drop(drop_plan(drop), 1)
        except RewardConfigError:
            return failure
        granted = await receive_rewards(conn, session.char_id, values, awards, session.db._grant_character_exp)
        if granted is None:
            return failure
        claimed.append(key)
        if not gift:
            state["power"] += mission["dailyQuestPower"]
        updated = await conn.fetchrow(
            """UPDATE characters SET game_values=game_values ||
               jsonb_build_object('gameplay_daily',$2::jsonb) WHERE char_id=$1 RETURNING *""",
            session.char_id, json.dumps(state))
    counters = {"dailyquestpower": state["power"], **{
        f"dailyquestgift{i}": int(i + 1 in state["gifts"]) for i in range(3)}}
    ack = Writer().u16(0).u32(key).vector_strings(award_strings(awards)).bytes()
    return [*reward_packets({**granted, "wallet": None}), wallet_update(updated, counters),
            (failure[0], ack)]


async def achievement_progress(conn, row, values):
    char_id = row["char_id"]
    counters = values.get("gameplay_lifetime", {})
    owned = await conn.fetchval("SELECT count(DISTINCT pet_template_id) FROM pets WHERE char_id=$1", char_id)
    orders = await conn.fetchrow(
        """SELECT coalesce(sum(draw_count),0) AS spins, count(*) FILTER (WHERE draw_count=10) AS multis
           FROM local_draw_history WHERE char_id=$1""", char_id)
    recharge = await conn.fetchval(
        "SELECT count(*) FROM local_recharge_transactions WHERE char_id=$1 AND simulated", char_id)
    clears = await conn.fetchrow(
        """SELECT count(*) FILTER (WHERE adventure_id<10000) AS normal,
                  count(*) FILTER (WHERE adventure_id BETWEEN 10000 AND 19999) AS elite,
                  count(*) FILTER (WHERE adventure_id>=20000) AS hero
           FROM character_adventure_clears WHERE char_id=$1 AND star_mask & 8 <> 0""", char_id)
    return {"cwhd": owned, "zyhq": row["gold"], "zyhq1": row["diamond"], "zyhq2": recharge,
            "zldj": row["level"], "ndj": int(orders["spins"]), "ndj1": orders["multis"],
            "gkfb1": max(clears["normal"], counters.get("ADVENTURE_NORMAL_CLEARED", 0)),
            "gkfb2": max(clears["elite"], counters.get("ADVENTURE_ELITE_CLEARED", 0)),
            "gkfb3": max(clears["hero"], counters.get("ADVENTURE_HERO_CLEARED", 0)),
            "ccyc6": counters.get("PET_STAR_UP", 0), "jjc": counters.get("ARENA_BATTLE_FINISHED", 0),
            "jjc1": int(values.get("local_arena", {}).get("rank", 0))}


async def list_achievements(session, collection):
    values = await values_for(session)
    key = "pet_achievement_claims" if collection else "achievement_claims"
    claims = values.get(key, [])
    body = Writer().u16(0).u8(len(claims))
    for claim in claims:
        body.u16(claim)
    return (74 if collection else 837), body.bytes()


async def claim_achievement(session, key, collection):
    from handlers.economy import wallet_update

    ack = 67 if collection else 485
    failure = (ack, Writer().u16(1).bytes())
    catalog = table("PokemonAchievementInfo" if collection else "AchievementInfo")
    plan = catalog.get(key)
    if session.char_id is None or not plan:
        return failure
    claim_key = "pet_achievement_claims" if collection else "achievement_claims"
    async with session.db.pool.acquire() as conn, conn.transaction():
        row = await conn.fetchrow("SELECT * FROM characters WHERE char_id=$1 FOR UPDATE", session.char_id)
        values = json.loads(row["game_values"])
        claims = values.get(claim_key, [])
        if key in claims:
            return failure
        if collection:
            owned = await conn.fetch("SELECT DISTINCT pet_template_id FROM pets WHERE char_id=$1", session.char_id)
            allowed = bool(plan["petIDs"]) and set(plan["petIDs"]) <= {pet["pet_template_id"] for pet in owned}
            if any(pet not in table("PokemonInfo") for pet in plan["petIDs"]):
                return failure
        else:
            field = plan["countFieldName"]
            if field not in PROGRESS_FIELDS:
                return failure
            value = (await achievement_progress(conn, row, values))[field]
            allowed = 0 < value <= plan["num"] if field == "jjc1" else value >= plan["num"]
            if any(prior["id"] < key and prior["id"] not in claims for prior in catalog.values()
                   if prior["countFieldName"] == field):
                return failure
        if not allowed:
            return failure
        try:
            awards = [{"kind": kind, "id": 0, "num": plan[source]}
                      for source, kind in (("gcash", "g_cash"), ("mcash", "m_cash")) if plan[source]]
            if plan.get("awardElementID"):
                awards.append(resolve_award_element(plan["awardElementID"], plan["awardElementNum"]))
        except RewardConfigError:
            return failure
        granted = await receive_rewards(conn, session.char_id, values, awards, session.db._grant_character_exp)
        if granted is None:
            return failure
        point = int(values.get("achievementpoint", 0)) + plan["point"]
        updated = await conn.fetchrow(
            "UPDATE characters SET game_values=game_values || $2::jsonb WHERE char_id=$1 RETURNING *",
            session.char_id, json.dumps({claim_key: [*claims, key], "achievementpoint": point}))
    return [*reward_packets({**granted, "wallet": None}), wallet_update(updated, {"achievementpoint": point}),
            (ack, Writer().u16(0).u16(key).bytes())]
