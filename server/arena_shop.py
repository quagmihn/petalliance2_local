"""Catalog and transactions for the type-1 Arena exchange."""
import json
import secrets
import time
from functools import cache

from client_config import table
from local_play import freedom
from reward_config import resolve_award_element
from reward_service import receive_rewards


@cache
def pools():
    config = table("ShopPoolInfo")
    result = []
    for pool_id in table("ShopInfo")[1]["shopPool"]:
        pool = config[pool_id]
        if pool["conditionNum"] != 0:
            raise ValueError(f"Arena slot {pool_id} has an unsupported unlock requirement")
        offers = []
        for offer in pool["shopDetail"]:
            weight = offer["weigth"]
            if weight <= 0:
                continue
            reward = resolve_award_element(offer["itemID"], offer["number"])
            if reward["kind"] != "item" or min(offer["price"], offer["count"]) <= 0:
                raise ValueError(f"Invalid Arena offer in pool {pool_id}")
            offers.append((weight, (offer["itemID"], offer["count"], offer["number"], offer["price"], 0)))
        if not offers:
            raise ValueError(f"Arena pool {pool_id} is empty")
        result.append(tuple(offers))
    return tuple(result)


def roll_offers():
    stock = []
    for offers in pools():
        draw = secrets.randbelow(sum(weight for weight, _ in offers))
        for weight, offer in offers:
            if draw < weight:
                stock.append(list(offer))
                break
            draw -= weight
    return stock


def refresh_window(now):
    day = now // 86400 * 86400
    resets = table("GlobalConfigAddInfo")[34]["values"]
    hours = [day + hour * 3600 for hour in sorted(resets)]
    return (max((hour for hour in hours if hour <= now), default=hours[-1] - 86400),
            min((hour for hour in hours if hour > now), default=hours[0] + 86400))


async def transact(db, char_id, *, refresh=False, purchase=None):
    async with db.pool.acquire() as conn, conn.transaction():
        char = await conn.fetchrow("SELECT * FROM characters WHERE char_id=$1 FOR UPDATE", char_id)
        if char is None:
            return None
        values = json.loads(char["game_values"])
        if not freedom(values) and char["level"] < table("GlobalConfigAddInfo")[24002]["values"][0]:
            return None
        now = int(time.time())
        start, _ = refresh_window(now)
        state = values.get("arena_shop")
        if not state or state["system"] != start:
            if purchase is not None:
                return None
            state = {"system": start, "manual": 0, "stock": roll_offers()}
        wallet = None
        grant = None
        if refresh:
            limit = table("VipInfo")[char["vip_level"] + 1]["arenaShopRefresh"]
            step = state["manual"] + 1
            if step > limit:
                return None
            cost_id = next((row["consume"] for row in table("ShopReflashInfo")[1]["reflashDetail"]
                            if row["count"] == min(step, 25)), None)
            cost = table("ConsumeElementInfo")[cost_id]
            if cost["elementType"] != 2 or not 0 < cost["num"] <= char["diamond"]:
                return None
            wallet = await conn.fetchrow(
                "UPDATE characters SET diamond=diamond-$2 WHERE char_id=$1 RETURNING *", char_id, cost["num"])
            state.update(manual=step, stock=roll_offers())
        if purchase is not None:
            index, count = purchase
            stock = state["stock"]
            if not 0 <= index < len(stock):
                return None
            award, available, number, price, _ = stock[index]
            score = int(values.get("arenascore", 0))
            if not 1 <= count <= available or score < price * count:
                return None
            reward = resolve_award_element(award, number * count)
            grant = await receive_rewards(conn, char_id, values, [reward], db._grant_character_exp)
            if grant is None:
                return None
            stock[index][1] -= count
            values["arenascore"] = score - price * count
            await conn.execute(
                """INSERT INTO arena_shop_purchases(char_id,award_id,item_id,quantity,price)
                   VALUES($1,$2,$3,$4,$5)""", char_id, award, reward["id"], reward["num"], price * count)
        if values.get("arena_shop") != state or refresh or purchase is not None:
            changes = {"arena_shop": state}
            if purchase is not None:
                changes["arenascore"] = values["arenascore"]
            wallet = await conn.fetchrow(
                """UPDATE characters SET game_values=game_values || $2::jsonb WHERE char_id=$1 RETURNING *""",
                char_id, json.dumps(changes))
        return state, wallet, grant
