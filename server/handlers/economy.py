"""Economy packet handlers.

Catalog-backed transactional purchase and payment delivery are not available
yet. Return the protocol failure code instead of granting fabricated products.
"""
from __future__ import annotations

import json
import logging

from protocol import Reader, Writer, success_code

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
    values = {"g_cash": row["gold"], "m_cash": row["diamond"],
              "gold": row["gold"], "diamond": row["diamond"],
              "actionvalue": row["stamina"], "viplevel": row["vip_level"],
              "vip_points": row["vip_points"]}
    values.update(currencies)
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
    r = Reader(payload); product_id, count = r.u32(), r.u32(); r.finish()
    return reject_unmapped_purchase(session, 577, "CG_BUYMARKETITEM_REQ", 563,
                                    "GC_BUYMARKETITEM_ACK", product_id=product_id,
                                    count=count)


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


async def recharge_test(session, payload: bytes):
    r = Reader(payload); _pay_id, _app_id = r.u32(), r.string(); r.finish()
    log.warning("payment_rejected reason=no_local_idempotency_catalog char_id=%s", session.char_id)
    return 89, Writer().u16(1).bytes()


async def capsule_egg(session, payload: bytes):
    r = Reader(payload); opt_type, choice, _free, _choice_ex = r.u16(), r.u16(), r.u16(), r.u16()
    r.finish()
    log.warning("gacha_rejected reason=award_pool_catalog_unavailable char_id=%s", session.char_id)
    return 1561, Writer().u16(1).bytes()


async def load_month_card(session, payload: bytes):
    Reader(payload).finish()
    row = await session.db.pool.fetchrow(
        "SELECT month_card_until FROM characters WHERE char_id=$1", session.char_id)
    # No entitlement exists for a new character. The login chain requires a
    # successful read with an empty vector and the isNeverBuy DWORD.
    if row is not None and row["month_card_until"] is None:
        return 3106, success_code().u8(0).u32(1).bytes()
    return 3106, Writer().i32(1).string("").i32(0).bytes()


async def take_month_card(session, payload: bytes):
    return 3103, Writer().i32(1).string("").i32(0).bytes()


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

