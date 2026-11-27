"""Target-client stamina prices, regeneration, and connection-scoped quotes."""
import json
import time

from character_values import vip_info_id
from client_config import table
from progress import local_day, record

QUOTE_KEYS = {"todaybuypowercount", "lastbuypowertime", "todaybuygcashcount", "lastbuygcashtime"}


def purchases_today(values, now):
    timestamp = values.get("lastbuypowertime", 0)
    if type(timestamp) is not int or not timestamp or local_day(now) != local_day(timestamp):
        return 0
    return int(values.get("todaybuypowercount", 0))


def balance_at(row, values, now):
    maximum = table("ExperienceInfo")[row["level"]]["limitPower"]
    stored = row["stamina"]
    timestamp = values.get("lastactionvaluechangetime", int(row["created_at"].timestamp()))
    if type(timestamp) is not int or timestamp <= 0 or timestamp > now:
        timestamp = now
    if stored >= maximum:
        return stored, now
    seconds = table("GlobalConfigAddInfo")[4]["values"][0]
    gained = min(maximum - stored, (now - timestamp) // seconds)
    updated = stored + gained
    return updated, (now if updated == maximum else timestamp + seconds * gained)


async def purchase(db, char_id, quote):
    now = int(time.time())
    if not quote or quote[:2] != (char_id, local_day(now)):
        return None
    async with db.pool.acquire() as conn, conn.transaction():
        row = await conn.fetchrow("SELECT * FROM characters WHERE char_id=$1 FOR UPDATE", char_id)
        if not row:
            return None
        values = json.loads(row["game_values"])
        count = purchases_today(values, now)
        vip = table("VipInfo").get(vip_info_id(row["vip_level"]))
        offer = table("BuyPowerInfo").get(count + 1)
        if count != quote[2] or not vip or count >= vip["buyPower"] or not offer:
            return None
        stamina, _ = balance_at(row, values, now)
        stamina += offer["power"]
        if row["diamond"] < offer["cost"] or stamina > 0xffff:
            return None
        updates = {"todaybuypowercount": count + 1, "lastbuypowertime": now,
                   "lastactionvaluechangetime": now}
        row = await conn.fetchrow(
            """UPDATE characters SET diamond=diamond-$2,stamina=$3,game_values=game_values || $4::jsonb
               WHERE char_id=$1 RETURNING *""", char_id, offer["cost"], stamina, json.dumps(updates))
        await record(conn, char_id, "STAMINA_PURCHASED", now=now)
    return row, updates, (char_id, local_day(now), count + 1)
