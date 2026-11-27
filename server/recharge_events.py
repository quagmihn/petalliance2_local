"""Recharge eligibility projected from committed local payment receipts."""
from datetime import datetime, timedelta, timezone
from functools import cache
import json

from client_config import table
from progress import local_day
from reward_config import RewardConfigError, resolve_award_element
from reward_service import receive_rewards


@cache
def campaigns():
    result = {}
    for key, row in table("ActivityInfoClient").items():
        if row["type"] != 12 or not row["params"]:
            continue
        mode = int(row["params"][0].split(",")[0])
        tiers = {}
        for index, param in enumerate(row["params"]):
            amount, awards, _ = param.split(",")[1 if index == 0 else 0:]
            try:
                tiers[int(amount)] = [resolve_award_element(*map(int, reward.split("_")))
                                      for reward in awards.split("&")]
            except RewardConfigError:
                continue
        result[key] = (mode, row["beginTime"], row["beginTime"] + row["lastTime"], tiers)
    return result


async def receipts(conn, char_id, begin, end):
    return await conn.fetch(
        """SELECT transaction_id,paid_amount,package_kind,created_at FROM local_recharge_transactions
           WHERE char_id=$1 AND simulated AND created_at>=to_timestamp($2) AND created_at<to_timestamp($3)
           ORDER BY created_at,transaction_id""", char_id, begin, end)


async def daily_mail(conn, char_id, values, now):
    _, begin, end, tiers = campaigns()[6]
    if not begin <= now < end:
        return None
    _, first_begin, first_end, first_tiers = campaigns()[3]
    day = local_day(now)
    threshold = min(tiers)
    orders = await receipts(conn, char_id, min(begin, first_begin), max(end, first_end))
    first = next((row["transaction_id"] for row in orders if row["paid_amount"] >= min(first_tiers)
                  and first_begin <= row["created_at"].timestamp() < first_end), None)
    for order in orders:
        timestamp = order["created_at"].timestamp()
        if (begin <= timestamp < end and local_day(timestamp) == day and order["package_kind"] == "normal"
                and order["paid_amount"] >= threshold and order["transaction_id"] != first):
            saved = values.get("recharge_daily_mail", {})
            if saved.get("day") != day:
                saved = {"day": day}
            return {"receipt": order, "state": saved, "awards": tiers[threshold], "end": end}
    return None


def hour_string(timestamp):
    return datetime.fromtimestamp(timestamp, timezone(timedelta(hours=7))).strftime("%Y%m%d%H")


async def progress(conn, char_id, values, now):
    result = {}
    _, begin, end, first = campaigns()[3]
    orders = await receipts(conn, char_id, begin, end)
    match = next((row for row in orders if row["paid_amount"] >= min(first)), None)
    if match:
        result["3"] = {"1": {"token": True, "time": hour_string(match["created_at"].timestamp())}}
    daily = await daily_mail(conn, char_id, values, now)
    if daily:
        result["6"] = {"1": {"token": True, "time": hour_string(daily["receipt"]["created_at"].timestamp())}}
    for key, (mode, begin, end, tiers) in campaigns().items():
        if mode not in (2, 3) or not begin <= now < end:
            continue
        orders = await receipts(conn, char_id, begin, end)
        total = sum(row["paid_amount"] for row in orders if row["package_kind"] == "normal"
                    and (mode == 2 or local_day(row["created_at"].timestamp()) == local_day(now)))
        season = f"{key}:{begin if mode == 2 else local_day(now)}"
        claims = values.get("recharge_campaign_claims", {}).get(season, [])
        result[str(key)] = {"total": total, **{str(amount): {"token": amount in claims}
                                                for amount in tiers if total >= amount}}
    return result


async def claim_campaign(db, char_id, key, amount, now):
    event = campaigns().get(key)
    if not event:
        return None
    mode, begin, end, tiers = event
    if mode not in (2, 3) or not begin <= now < end or amount not in tiers:
        return None
    async with db.pool.acquire() as conn, conn.transaction():
        raw = await conn.fetchval("SELECT game_values FROM characters WHERE char_id=$1 FOR UPDATE", char_id)
        if raw is None:
            return None
        values = json.loads(raw)
        eligibility = (await progress(conn, char_id, values, now)).get(str(key), {}).get(str(amount))
        if not eligibility or eligibility["token"]:
            return None
        grant = await receive_rewards(conn, char_id, values, tiers[amount], db._grant_character_exp)
        if grant is None:
            return None
        state = values.get("recharge_campaign_claims", {})
        season = f"{key}:{begin if mode == 2 else local_day(now)}"
        state.setdefault(season, []).append(amount)
        await conn.execute("""UPDATE characters SET game_values=game_values ||
                           jsonb_build_object('recharge_campaign_claims',$2::jsonb) WHERE char_id=$1""",
                           char_id, json.dumps(state))
        return grant
