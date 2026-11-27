"""Transactional rewards for the configured login gifts and local checkout mail."""

import json
import time

from client_config import table
from handlers.economy import local_payment_enabled
from handlers.inventory import award_strings, reward_packets
from protocol import Reader, Writer
from reward_config import RewardConfigError, resolve_award_element, resolve_reward
from reward_service import receive_rewards
import recharge_events
from seven_day_config import SUPPORTED_TYPES


def first_recharge():
    activity = table("ActivityInfoClient")[3]
    if activity["type"] != 12 or len(activity["params"]) != 1:
        raise ValueError("unexpected first recharge activity configuration")
    threshold, _, award_list, _ = activity["params"][0].split(",")
    rewards = [resolve_award_element(*map(int, pair.split("_"))) for pair in award_list.split("&")]
    return activity["beginTime"], activity["beginTime"] + activity["lastTime"], int(threshold), rewards


async def get_seven_day_award(session, payload):
    r = Reader(payload)
    gift_id, choice = r.u32(), r.u32()
    r.finish()
    error = (390, Writer().u16(1).bytes())
    gift = table("SevenDayInfo").get(gift_id)
    if (session.char_id is None or not gift or choice or gift["sevenQuestType"] not in SUPPORTED_TYPES
            or gift["wayToGetReward"] != [0] or not 1 <= gift["openDay"] <= 7):
        return error
    price = 0
    if gift["sevenQuestType"] == 7:
        prices = gift["needCondition"]
        if len(prices) != 2 or type(prices[1]) is not int or prices[1] <= 0:
            return error
        price = prices[1]
    try:
        rewards = [resolve_reward(reward) for reward in gift["rewardInfos"]]
    except RewardConfigError:
        return error
    if not rewards or any(reward is None for reward in rewards):
        return error
    state = await session.db.claim_seven_day_gift(
        session.char_id, gift, time.time(), rewards, diamond_price=price)
    if state is None:
        return error
    # The original callback renders acquired Pets from 3141. Its award
    # vector is for currency and item previews only.
    shown = award_strings([reward for reward in rewards if reward["kind"] != "pet"])
    return [*reward_packets(state), (390, Writer().u16(0).vector_strings(shown).bytes())]


def mail_payload(mail, rewards, end):
    kind = {"item": 3, "exp": 4, "pet": 5, "goldCoin": 11}
    items = " ".join(f"{kind[r['kind']]} {r['id']} {r['num']}"
                     for r in rewards if r["kind"] in kind)
    return {
        "_id": mail["created_at"].isoformat(), "type": 0,
        "title": "First Recharge Reward", "senderName": "Monster2",
        "content": "Your first local recharge reward is attached.",
        "sendTime": int(mail["created_at"].timestamp()), "deadTime": end,
        "gCash": sum(r["num"] for r in rewards if r["kind"] == "g_cash"),
        "mCash": sum(r["num"] for r in rewards if r["kind"] == "m_cash"),
        "items": items,
        "isRead": bool(mail["is_read"]), "isFetch": bool(mail["first_charge_claimed"]),
    }


async def get_recharge_mail(session):
    if session.char_id is None or not local_payment_enabled():
        return None
    begin, end, threshold, rewards = first_recharge()
    mail = await session.db.first_recharge_mail(session.char_id, begin, end, threshold)
    return mail_payload(mail, rewards, end) if mail else None


async def get_activities(session, payload):
    Reader(payload).finish()
    data = {}
    if session.char_id is not None and local_payment_enabled():
        async with session.db.pool.acquire() as conn:
            values = json.loads(await conn.fetchval(
                "SELECT game_values FROM characters WHERE char_id=$1", session.char_id))
            state = await recharge_events.progress(conn, session.char_id, values, time.time())
        if state:
            data["recharge"] = state
    return 152, Writer().u16(0).json_string(data).bytes()


async def claim_recharge_banner(session, payload):
    r = Reader(payload)
    key, amount = r.u32(), r.u32()
    r.finish()
    result = (await recharge_events.claim_campaign(session.db, session.char_id, key, amount, time.time())
              if session.char_id is not None and local_payment_enabled() else None)
    if result is None:
        return 299, Writer().u16(1).bytes()
    return [*reward_packets(result), (299, Writer().u16(0).bytes())]


def daily_mail_payload(daily):
    if not daily or daily["state"].get("deleted"):
        return None
    order, state = daily["receipt"], daily["state"]
    mail = mail_payload({"created_at": order["created_at"], "is_read": state.get("read", False),
                         "first_charge_claimed": state.get("claim", False)}, daily["awards"], daily["end"])
    return {**mail, "_id": f"local-daily:{order['transaction_id']}", "title": "Daily Recharge Reward",
            "content": "Your daily local recharge reward is attached."}


async def get_daily_mail(session):
    if session.char_id is None or not local_payment_enabled():
        return None
    async with session.db.pool.acquire() as conn:
        values = json.loads(await conn.fetchval(
            "SELECT game_values FROM characters WHERE char_id=$1", session.char_id))
        return daily_mail_payload(await recharge_events.daily_mail(conn, session.char_id, values, time.time()))


async def check_unread_mail(session, payload):
    Reader(payload).finish()
    mail = await get_recharge_mail(session)
    daily = await get_daily_mail(session)
    unread = any(message and not message["isRead"] for message in (mail, daily))
    return 1077, Writer().u16(0).u16(0).u16(unread).bytes()


async def list_mail(session, payload):
    r = Reader(payload)
    r.string()
    personal_count, requested = r.u32(), r.u16()
    r.finish()
    messages = []
    if not personal_count and requested:
        messages = [mail for mail in (await get_recharge_mail(session), await get_daily_mail(session)) if mail]
    return 274, Writer().u16(0).json_string({str(i): mail for i, mail in enumerate(messages)}).bytes()


async def update_daily_mail(session, index, message_id):
    error = (message_id, Writer().u16(1).bytes())
    if session.char_id is None or not local_payment_enabled():
        return error
    async with session.db.pool.acquire() as conn, conn.transaction():
        values = json.loads(await conn.fetchval(
            "SELECT game_values FROM characters WHERE char_id=$1 FOR UPDATE", session.char_id))
        daily = await recharge_events.daily_mail(conn, session.char_id, values, time.time())
        mail = daily_mail_payload(daily)
        if mail is None or index != mail["_id"]:
            return error
        state = daily["state"]
        granted = None
        if message_id == 1106:
            if state.get("claim"):
                return error
            granted = await receive_rewards(conn, session.char_id, values, daily["awards"], session.db._grant_character_exp)
            if granted is None:
                return error
            state["claim"] = True
        elif message_id == 271:
            if not state.get("claim"):
                return error
            state["deleted"] = True
        state["read"] = True
        await conn.execute("""UPDATE characters SET game_values=game_values ||
                           jsonb_build_object('recharge_daily_mail',$2::jsonb) WHERE char_id=$1""",
                           session.char_id, json.dumps(state))
    body = Writer().u16(0)
    if message_id == 305:
        body.json_string(daily_mail_payload(daily))
    ack = message_id, body.bytes()
    return [*reward_packets(granted), ack] if granted is not None else ack


async def update_mail(session, payload, message_id):
    r = Reader(payload)
    index, mail_type = r.string(), r.u16()
    r.finish()
    if mail_type == 0 and index.startswith("local-daily:"):
        return await update_daily_mail(session, index, message_id)
    mail = await get_recharge_mail(session) if mail_type == 0 else None
    error = (message_id, Writer().u16(1).bytes())
    if not mail or mail["_id"] != index:
        return error
    if message_id == 305:
        await session.db.mark_first_recharge_mail(session.char_id, delete=False)
        return 305, Writer().u16(0).json_string(mail).bytes()
    if message_id == 271:
        deleted = await session.db.mark_first_recharge_mail(session.char_id, delete=True)
        return (271, Writer().u16(0).bytes()) if deleted else error
    begin, end, threshold, rewards = first_recharge()
    state = await session.db.claim_first_recharge_mail(session.char_id, time.time(), begin, end, threshold, rewards)
    if state is None:
        return error
    return [*reward_packets(state), (1106, Writer().u16(0).bytes())]
