"""Economy handlers for configured purchases, local checkout, and prize draws."""
from __future__ import annotations

import json
import hashlib
import logging
import os
import re

from character_values import vip_info_id
from protocol import ProtocolDecodeError, Reader, Writer, success_code

log = logging.getLogger("game_socket.economy")


async def get_recharge_cd(session, payload: bytes):
    Reader(payload).finish()
    cooldowns = await session.db.local_recharge_cooldowns(session.char_id) if (
        session.char_id is not None and local_payment_enabled()) else {}
    return 655, success_code().string(json.dumps(cooldowns, separators=(",", ":"))).bytes()


def wallet_update(row, counters=None) -> tuple[int, bytes]:
    from local_play import silver_override

    currencies = row["currencies_json"] or {}
    if isinstance(currencies, str):
        currencies = json.loads(currencies)
    # Legacy currencies_json can contain stale mirrors of these canonical
    # character columns. Merge extension currencies first, then let the
    # committed row win for every authoritative wallet field.
    values = dict(currencies)
    values.update({"g_cash": row["gold"], "m_cash": row["diamond"],
                   "gold": row["gold"], "diamond": row["diamond"],
                   "actionvalue": row["stamina"], "viplevel": vip_info_id(row["vip_level"]),
                   "vip_points": row["vip_points"]})
    if "recharge_total" in row.keys():
        values["recharge"] = {"totalMoney": int(row["recharge_total"])}
    if counters:
        values.update(counters)
    silver = silver_override(row)
    if silver is not None:
        values["goldCoin"] = silver
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
    from arena_shop import transact
    from handlers.inventory import reward_packets

    r = Reader(payload); shop_type, index, count = r.u32(), r.u32(), r.u32(); r.finish()
    if shop_type == 1 and session.char_id is not None:
        result = await transact(session.db, session.char_id, purchase=(index, count))
        if result is None:
            return 1953, Writer().u16(1).bytes()
        _, wallet, grant = result
        return [*reward_packets(grant), wallet_update(wallet, {"arenascore": json.loads(wallet["game_values"])["arenascore"]}),
                (1953, Writer().u16(0).bytes())]
    return reject_unmapped_purchase(session, 858, "CG_BUYGOODS_REQ", 1953,
                                    "GC_BUYGOODS_ACK", shop_type=shop_type,
                                    index=index, count=count)


async def arena_shop_catalog(session, payload, ack_id):
    from arena_shop import transact

    r = Reader(payload)
    shop_type = r.u32()
    r.finish()
    if shop_type != 1 or session.char_id is None:
        return ack_id, Writer().u16(1).bytes()
    result = await transact(session.db, session.char_id, refresh=ack_id == 1876)
    if result is None:
        return ack_id, Writer().u16(1).bytes()
    state, wallet, _ = result
    body = Writer().u16(0).u8(len(state["stock"]))
    for offer in state["stock"]:
        for field in offer:
            body.u32(field)
    if ack_id == 1746:
        body.u32(state["system"]).u32(state["manual"]).u32(state["system"])
    ack = (ack_id, body.bytes())
    return [wallet_update(wallet), ack] if ack_id == 1876 and wallet is not None else ack


async def reset_arena_shop(session, payload):
    from arena_shop import transact

    reader = Reader(payload)
    shop_type = reader.u32()
    reader.finish()
    result = await transact(session.db, session.char_id) if shop_type == 1 and session.char_id is not None else None
    return 1737, Writer().u16(0 if result else 1).bytes()


async def buy_product(session, payload: bytes):
    from handlers.inventory import inventory_packets
    from local_play import enabled
    from market_config import local_offers

    r = Reader(payload); product_id, count = r.string(), r.u32(); r.finish()
    if (session.char_id is not None and enabled("LOCAL_MARKET_SHOP") and 1 <= count <= 99
            and product_id in session.local_market_quotes and product_id in local_offers()):
        product = local_offers()[product_id]
        purchase = await session.db.buy_market_item(session.char_id, product, count)
        if purchase is None:
            return 471, Writer().u16(1).bytes()
        session.local_market_quotes.discard(product_id)
        log.info("local_market_purchase char_id=%s product=%s quantity=%s price_silver=%s virtual=%s",
                 session.char_id, product_id, count, product["num"] * count, purchase["virtual_silver"])
        return [*inventory_packets([(purchase["item_id"], purchase["item_count"])]),
                wallet_update(purchase["character"]), (471, Writer().u16(0).bytes())]
    return reject_unmapped_purchase(session, 481, "CG_BUYPRODUCT_REQ", 471,
                                    "GC_BUYPRODUCT_ACK", product_id=product_id,
                                    count=count)


async def get_my_market(session, payload: bytes):
    Reader(payload).finish()
    if session.char_id is None:
        return 493, Writer().u16(1).bytes()
    # The private server has no player-authored listings. The client reads
    # configured Commerce and Mall offers separately from MarketInfo.
    return 493, Writer().u16(0).vector_strings([]).bytes()


async def search_market_products(session, payload: bytes):
    from local_play import enabled
    from market_config import search_local_offers

    r = Reader(payload)
    category, subtype, item_id, sort, start, count = (r.u32() for _ in range(6))
    label = r.string(limit=96)
    r.finish()
    if session.char_id is None:
        return 520, Writer().u16(1).bytes()
    offers = search_local_offers(category, subtype, item_id, sort, start, count, label) if enabled("LOCAL_MARKET_SHOP") else []
    session.local_market_quotes = {offer["productID"] for offer in offers}
    return 520, Writer().u16(0).vector_strings([json.dumps(offer) for offer in offers]).bytes()


async def buy_market(session, payload: bytes):
    from handlers.inventory import inventory_packets
    from market_config import enabled_offers

    r = Reader(payload); product_id, count = r.u32(), r.u32(); r.finish()
    ack = (563, Writer().u16(1).bytes())
    if session.char_id is None or not 1 <= count <= 99:
        return ack
    market = enabled_offers().get(product_id)
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
    notifications = inventory_packets([(purchase["item_id"], purchase["item_count"])])
    notifications.append(wallet_update(purchase["character"], purchase["counters"]))
    notifications.append((563, Writer().u16(0).bytes()))
    log.info("market_purchase char_id=%s market_id=%s item_id=%s count=%s cost=%s currency=%s virtual_silver=%s",
             session.char_id, product_id, market["itemID"], count,
             int(market["num"]) * count,
             market["coinType"], purchase["virtual_silver"])
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
    from stamina import purchase

    Reader(payload).finish()
    result = await purchase(session.db, session.char_id, session.stamina_quote)
    if result is None:
        return 991, Writer().u16(1).bytes()
    row, counters, session.stamina_quote = result
    return [wallet_update(row, counters), (991, Writer().u16(0).bytes())]


async def buy_gcash(session, payload: bytes):
    Reader(payload).finish()
    return reject_unmapped_purchase(session, 463, "CG_BUYGCASH_REQ", 449,
                                    "GC_BUYGCASH_ACK")


def local_payment_enabled():
    return (os.getenv("LOCAL_PAYMENT_SANDBOX", "0") == "1"
            and os.getenv("GAME_ENV", "").lower() in ("test", "play", "production")
            and os.getenv("PAYMENT_PROVIDER", "").lower() == "local")


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
    from handlers.inventory import inventory_packets
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
    notifications = inventory_packets(item_counts.items())
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
    from handlers.inventory import reward_packets
    from vip_config import milestone

    r = Reader(payload)
    vip_id = r.u32()
    requested = [r.u32() for _ in range(r.u8())]
    r.finish()
    error = 60, Writer().u16(1).bytes()
    if session.char_id is None:
        return error
    try:
        resolved = milestone(vip_id, requested)
    except (KeyError, ValueError) as exc:
        log.warning("vip_reward_invalid char_id=%s vip_info_id=%s reason=%s", session.char_id, vip_id, exc)
        return error
    if resolved is None:
        return error
    state = await session.db.claim_vip_milestone(session.char_id, vip_id, *resolved)
    return [*reward_packets(state), (60, Writer().u16(0).bytes())] if state is not None else error


async def get_vip_awards(session, payload: bytes):
    Reader(payload).finish()
    if session.char_id is None:
        return 62, Writer().u16(1).u8(0).bytes()
    claimed = await session.db.vip_awards(session.char_id)
    output = Writer().u16(0).u8(len(claimed))
    for vip_id in claimed:
        output.u32(vip_id)
    return 62, output.bytes()


async def pet_star_up(session, payload: bytes):
    from handlers.inventory import inventory_packets

    error = 1650, Writer().u16(1).bytes()
    r = Reader(payload)
    pet_uid = r.u32()
    materials = [r.u32() for _ in range(r.u8())]
    r.finish()
    if session.char_id is None:
        return error
    try:
        result = await session.db.advance_pet_star(session.char_id, pet_uid, materials)
    except (KeyError, ValueError) as exc:
        log.warning("pet_star_rejected char_id=%s pet_uid=%s reason=%s", session.char_id, pet_uid, exc)
        return error
    if result is None:
        return error
    pet, item, count = result
    return [*inventory_packets([(item, count)]),
            *((3138, Writer().u64(uid).bytes()) for uid in materials),
            (3141, Writer().u64(pet_uid).string(pet).bytes()),
            (1650, Writer().u16(0).bytes())]


async def pet_evolve(session, payload: bytes, ack_id: int):
    r = Reader(payload); r.u32(); r.u16(); r.u8(); r.finish()
    return ack_id, Writer().u16(1).bytes()


async def pet_skill_action(session, payload: bytes, ack_id: int):
    from handlers.inventory import inventory_packets

    r = Reader(payload)
    pet_uid, slot = r.u32(), r.u32()
    book_id = r.u32() if ack_id == 1369 else None
    r.finish()
    state = (await session.db.manage_pet_skill(session.char_id, pet_uid, slot, book_id)
             if session.char_id is not None else None)
    if state is None:
        return ack_id, Writer().u16(1).bytes()
    new_skill, counts, pet = state
    return [*inventory_packets(counts.items()),
            (3141, Writer().u64(pet_uid).string(pet).bytes()),
            (ack_id, Writer().u16(0).u32(pet_uid).u32(slot).u32(new_skill).bytes())]


async def pet_equip_strengthen(session, payload: bytes):
    r = Reader(payload); r.u32(); r.u8(); r.u32(); r.finish()
    return 573, Writer().u16(1).bytes()

