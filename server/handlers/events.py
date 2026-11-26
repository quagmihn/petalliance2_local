"""Transactional rewards for the configured login gifts and local checkout mail."""

import json
import time

from client_config import table
from handlers.economy import local_payment_enabled
from handlers.inventory import award_strings, reward_packets
from protocol import Reader, Writer
from reward_config import RewardConfigError, resolve_award_element, resolve_reward
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
    mail = await get_recharge_mail(session)
    data = {}
    if mail:
        # RechargeViewMgr expects an hour string and switches to the daily
        # recharge promotion when the first-purchase token is set.
        from datetime import datetime, timedelta, timezone

        zone = timezone(timedelta(hours=7))
        hour = datetime.fromtimestamp(mail["sendTime"], zone).strftime("%Y%m%d%H")
        data["recharge"] = {"3": {"1": {"token": True, "time": hour}}}
    return 152, Writer().u16(0).json_string(data).bytes()


async def check_unread_mail(session, payload):
    Reader(payload).finish()
    mail = await get_recharge_mail(session)
    unread = bool(mail and not mail["isRead"])
    return 1077, Writer().u16(0).u16(0).u16(unread).bytes()


async def list_mail(session, payload):
    r = Reader(payload)
    r.string()
    personal_count, requested = r.u32(), r.u16()
    r.finish()
    mail = await get_recharge_mail(session) if not personal_count and requested else None
    return 274, Writer().u16(0).json_string({"0": mail} if mail else {}).bytes()


async def update_mail(session, payload, message_id):
    r = Reader(payload)
    index, mail_type = r.string(), r.u16()
    r.finish()
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
