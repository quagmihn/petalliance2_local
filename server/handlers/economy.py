"""Economy packet handlers.

Catalog-backed transactional purchase and payment delivery are not available
yet. Return the protocol failure code instead of granting fabricated products.
"""
from __future__ import annotations

import json
import hashlib
import logging
import os
import re

from protocol import ProtocolDecodeError, Reader, Writer, success_code

log = logging.getLogger("game_socket.economy")


async def get_recharge_cd(session, payload: bytes):
    Reader(payload).finish()
    # Client parser expects Proto.parseCode followed by a JSON string. Empty
    # cooldown state is represented by an empty JSON object.
    return 655, success_code().string("{}").bytes()


def wallet_update(row) -> tuple[int, bytes]:
    currencies = row["currencies_json"] or {}
    if isinstance(currencies, str):
        currencies = json.loads(currencies)
    # Legacy currencies_json can contain stale mirrors of these canonical
    # character columns. Merge extension currencies first, then let the
    # committed row win for every authoritative wallet field.
    values = dict(currencies)
    values.update({"g_cash": row["gold"], "m_cash": row["diamond"],
                   "gold": row["gold"], "diamond": row["diamond"],
                   "actionvalue": row["stamina"], "viplevel": row["vip_level"],
                   "vip_points": row["vip_points"]})
    if "recharge_total" in row.keys():
        values["recharge"] = {"totalMoney": int(row["recharge_total"])}
    return 473, Writer().string(json.dumps(values, separators=(",", ":"))).bytes()


def item_sync(item_id: int, count: int = 1) -> tuple[int, bytes]:
    return 126, Writer().vector_strings([
        json.dumps({"itemID": item_id, "num": count}, separators=(",", ":"))
    ]).bytes()


def reject_unmapped_purchase(session, request_id: int, request_name: str,
                             response_id: int, response_name: str, *,
                             shop_type=None, index=None, product_id=None,
                             item_id=None, count=None):
    log.warning(
        "purchase_rejected request_id=%d request_name=%s response_id=%d response_name=%s "
        "account_id=%s char_id=%s shop_type=%s index=%s product_id=%s item_id=%s count=%s "
        "currency_before=unavailable currency_after=unavailable reward_status=not_granted "
        "transaction_id=absent reason=catalog_transaction_unavailable",
        request_id, request_name, response_id, response_name,
        getattr(session, "account_id", None), session.char_id,
        shop_type, index, product_id, item_id, count)
    return response_id, Writer().u16(1).bytes()


async def buy_goods(session, payload: bytes):
    r = Reader(payload); shop_type, index, count = r.u32(), r.u32(), r.u32(); r.finish()
    return reject_unmapped_purchase(session, 858, "CG_BUYGOODS_REQ", 1953,
                                    "GC_BUYGOODS_ACK", shop_type=shop_type,
                                    index=index, count=count)


async def buy_product(session, payload: bytes):
    r = Reader(payload); product_id, count = r.string(), r.u32(); r.finish()
    return reject_unmapped_purchase(session, 481, "CG_BUYPRODUCT_REQ", 471,
                                    "GC_BUYPRODUCT_ACK", product_id=product_id,
                                    count=count)


async def buy_market(session, payload: bytes):
    from handlers.inventory import item_counts_update

    r = Reader(payload); product_id, count = r.u32(), r.u32(); r.finish()
    ack = (563, Writer().u16(1).bytes())
    if session.char_id is None or not 1 <= count <= 99:
        return ack
    from client_config import table
    market = table("MarketInfo").get(product_id)
    if market is None:
        return ack
    # MarketInfo coinType follows BuyInfoMgr: 1 gold, 2 diamonds, 3 silver
    # (the latter is stored in characters.currencies_json.goldCoin).
    try:
        purchase = await session.db.buy_market_item(session.char_id, market, count)
    except (ValueError, KeyError, TypeError, IndexError) as exc:
        log.info("market_purchase_rejected char_id=%s market_id=%s reason=%s",
                 session.char_id, product_id, exc)
        return ack
    if purchase is None:
        return ack
    notifications = []
    notifications.append(item_counts_update([(purchase["item_id"], purchase["item_count"])]))
    notifications.append(wallet_update(purchase["character"]))
    notifications.append((563, Writer().u16(0).bytes()))
    log.info("market_purchase char_id=%s market_id=%s item_id=%s count=%s cost=%s currency=%s",
             session.char_id, product_id, market["itemID"], count,
             int(market["num"]) * count,
             market["coinType"])
    return notifications


async def buy_activity(session, payload: bytes):
    r = Reader(payload); item_id, count = r.u32(), r.u32(); r.finish()
    return reject_unmapped_purchase(session, 595, "CG_BUYACTIVITYSHOPITEM_REQ", 593,
                                    "GC_BUYACTIVITYSHOPITEM_ACK", item_id=item_id,
                                    count=count)


async def buy_mcash(session, payload: bytes):
    r = Reader(payload); item_id, count = r.u32(), r.u32(); r.finish()
    return reject_unmapped_purchase(session, 398, "CG_BUYONEMCASHSHOP_REQ", 406,
                                    "GC_BUYONEMCASHSHOP_ACK", item_id=item_id,
                                    count=count)


async def buy_packet(session, payload: bytes):
    r = Reader(payload); product_id = r.u32(); r.finish()
    return reject_unmapped_purchase(session, 2042, "CG_BUYPACKET_REQ", 2043,
                                    "GC_BUYPACKET_ACK", product_id=product_id)


async def buy_power(session, payload: bytes):
    Reader(payload).finish()
    return reject_unmapped_purchase(session, 1242, "CG_BUYPOWER_REQ", 991,
                                    "GC_BUYPOWER_ACK")


async def buy_gcash(session, payload: bytes):
    Reader(payload).finish()
    return reject_unmapped_purchase(session, 463, "CG_BUYGCASH_REQ", 449,
                                    "GC_BUYGCASH_ACK")


def local_payment_enabled():
    return (os.getenv("LOCAL_PAYMENT_SANDBOX", "0") == "1"
            and os.getenv("GAME_ENV", "").lower() in ("test", "play", "production")
            and os.getenv("PAYMENT_PROVIDER", "local").lower() in ("", "local", "none"))


async def recharge_test(session, payload: bytes):
    r = Reader(payload); pay_id, app_id = r.u32(), r.string(); r.finish()
    failure = (89, Writer().u16(1).bytes())
    if not local_payment_enabled():
        log.warning("local_recharge_rejected char_id=%s reason=sandbox_disabled", session.char_id)
        return failure
    match = re.fullmatch(r"local:([NM])(\d{1,10}):(.{1,160})", app_id)
    if match is None or session.char_id is None:
        log.warning("local_recharge_rejected char_id=%s reason=invalid_order_key", session.char_id)
        return failure
    kind, package_id_text, order_key = match.groups()
    package_id = int(package_id_text)
    if package_id != pay_id:
        log.warning("local_recharge_rejected char_id=%s reason=package_mismatch", session.char_id)
        return failure
    from client_config import table
    package_kind = "normal" if kind == "N" else "month"
    catalog_name = "NormalRechargeInfo" if kind == "N" else "MonthCardRechargeInfo"
    package = table(catalog_name).get(package_id)
    if package is None:
        log.warning("local_recharge_rejected char_id=%s package=%s reason=unknown_package",
                    session.char_id, package_id)
        return failure
    diamonds = (int(package["mCash"]) * int(package["bonusRate"])
                if kind == "N" and int(package["bonusRate"]) != 0
                else int(package["mCash"]) + int(package.get("giftMCash", 0))
                if kind == "N" else int(package["initMCash"]))
    if diamonds <= 0 or int(package["money"]) <= 0:
        return failure
    try:
        result = await session.db.apply_local_recharge(
            session.char_id, app_id, package_kind, package, diamonds,
            int(package["money"]))
    except (ValueError, KeyError, TypeError) as exc:
        log.warning("local_recharge_rejected char_id=%s package=%s reason=%s",
                    session.char_id, package_id, exc)
        return failure
    if result is None:
        return failure
    log.info("local_recharge char_id=%s package_kind=%s package_id=%s simulated=true "
             "duplicate=%s order_hash=%s diamonds=%s",
             session.char_id, package_kind, package_id, result["duplicate"],
             hashlib.sha256(app_id.encode()).hexdigest()[:12], diamonds)
    # 473 is the client's canonical wallet notification. It must reflect the
    # committed row before the package callback receives ACK 89.
    return [wallet_update(result["character"]), (89, Writer().u16(0).bytes())]


async def capsule_egg(session, payload: bytes):
    from handlers.inventory import item_counts_update
    from local_draw import configured_catalog, execute

    failure = 1561, Writer().u16(1).bytes()
    r = Reader(payload)
    try:
        opt_type, choice, free, selection = r.u16(), r.u16(), r.u16(), r.u16()
        request_key = r.string(limit=48) if r.pos < len(payload) else None
        r.finish()
    except ProtocolDecodeError:
        return failure
    if request_key is not None and not re.fullmatch(r"[0-9a-f]{16,48}", request_key):
        return failure
    if session.char_id is None or selection or free not in (0, 1) or choice not in (1, 2):
        return failure
    try:
        catalog = configured_catalog()
    except (OSError, ValueError, KeyError, TypeError) as exc:
        log.error("local_draw_catalog_invalid error=%s", exc)
        return failure
    if not catalog:
        log.error("gacha_rejected reason=no_local_catalog char_id=%s mode=%s",
                  session.char_id, os.getenv("GAME_ENV"))
        return failure
    machine = catalog.get(opt_type)
    if machine is None:
        log.info("gacha_rejected reason=unsupported_machine char_id=%s machine=%s",
                 session.char_id, opt_type)
        return failure
    code, result = await execute(session.db, session.char_id, opt_type, machine,
                                 1 if choice == 1 else 10, bool(free), request_key)
    if result is None:
        return 1561, Writer().u16(code).bytes()
    awards, wallet, item_counts, pets = result
    notifications = [item_counts_update(item_counts.items())] if item_counts else []
    # Pet state precedes the result. The result carries the same serialized
    # detail with the committed ID for the result card and Pet animation.
    notifications.extend(
        (3141, Writer().u64(json.loads(pet)["objID"]).string(pet).bytes()) for pet in pets
    )
    notifications.append(wallet_update(wallet))
    notifications.append((1561, Writer().u16(0).vector_strings([json.dumps(award) for award in awards]).bytes()))
    return notifications


async def load_month_card(session, payload: bytes):
    Reader(payload).finish()
    rows = await session.db.local_month_cards(session.char_id) if session.char_id is not None else []
    body = success_code().u8(len(rows))
    for row in rows:
        body.i32(row["package_id"]).u32(row["expires"]).u32(row["last_claim"])
    return 3106, body.u32(0 if rows else 1).bytes()


async def take_month_card(session, payload: bytes):
    from client_config import table

    r = Reader(payload)
    package_id = r.i32()
    r.finish()
    error = 3103, Writer().i32(1).string("").i32(0).bytes()
    if not local_payment_enabled() or session.char_id is None:
        return error
    package = table("MonthCardRechargeInfo").get(package_id)
    if package is None or int(package["mCashPerDay"]) <= 0:
        return error
    wallet = await session.db.claim_local_month_card(
        session.char_id, package_id, int(package["mCashPerDay"]))
    if wallet is None:
        return error
    return [wallet_update(wallet), (3103, success_code().bytes())]


async def buy_npc(session, payload: bytes):
    r = Reader(payload); index = r.u32(); r.finish()
    return reject_unmapped_purchase(session, 86, "CG_BUYNPCSHOPGOODS_REQ", 85,
                                    "GC_BUYNPCSHOPGOODS_ACK", index=index)


async def red_heart(session, payload: bytes):
    r = Reader(payload); pos = r.u16(); r.finish()
    return reject_unmapped_purchase(session, 79, "CG_BUYREDHEARTGOODS_REQ", 76,
                                    "GC_BUYREDHEARTGOODS_ACK", index=pos)


async def claim_vip_award(session, payload: bytes):
    r = Reader(payload); _vip_id = r.u32(); count = r.u8()
    for _ in range(count): r.u32()
    r.finish()
    return 60, Writer().u16(1).bytes()


async def pet_star_up(session, payload: bytes):
    r = Reader(payload); r.u32(); [r.u32() for _ in range(r.u8())]; r.finish()
    return 1650, Writer().u16(1).bytes()


async def pet_evolve(session, payload: bytes, ack_id: int):
    r = Reader(payload); r.u32(); r.u16(); r.u8(); r.finish()
    return ack_id, Writer().u16(1).bytes()


async def pet_skill_level(session, payload: bytes):
    r = Reader(payload); r.u32(); r.u32(); r.finish()
    return 1371, Writer().u16(1).bytes()


async def pet_equip_strengthen(session, payload: bytes):
    r = Reader(payload); r.u32(); r.u8(); r.u32(); r.finish()
    return 573, Writer().u16(1).bytes()

