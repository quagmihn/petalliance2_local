from __future__ import annotations

import asyncio
import hashlib
import json
import logging
import os
import time
import uuid

from db.database import Database
from handlers import treasure
from handlers import arena, pet_development, pet_evolution, progression
from handlers import character_state
from handlers import (auth, battle, chat, economy, events, inventory, map as map_handler,
                      pet, player, territory, world_boss)
from protocol import (Reader, Writer, frame, read_frame, redact_payload,
                      ProtocolDecodeError, redact_response_payload,
                      safe_request_fields)

logging.basicConfig(level=os.getenv("LOG_LEVEL", "INFO"),
                    format="%(asctime)s %(levelname)s tcp %(message)s")
log = logging.getLogger("game_socket")

# IDs copied from ProtoCommand.lua (little-endian WORDs in the frame).
CMD = {
    "read_info": 690, "read_info_ack": 721,
    "get_life_skill_data": 128, "get_life_skill_data_ack": 181,
    "get_treasure_box_data": 227, "get_treasure_box_data_ack": 225,
    "platform_login": 2130, "platform_login_ack": 2126,
    "device_login": 2156, "device_login_ack": 2183,
    "device_bind": 2211, "device_bind_ack": 2179,
    "create_character": 1655, "create_character_ack": 807,
    "query_pets": 3140, "query_pets_ack": 3139,
    "get_fashions": 2075, "get_fashions_ack": 2102,
    "set_fashions": 2121, "set_fashions_ack": 2109,
    "restore_fashions": 2098, "restore_fashions_ack": 2066,
    "get_items": 59, "get_items_ack": 37, "get_items_ntf": 112,
    "use_item": 516, "use_item_ack": 526, "update_pokemon_ntf": 3141,
    "update_army": 1755, "update_army_ack": 1756,
    "get_army": 1760, "get_army_ack": 1774,
    "get_finished_adventures": 3078, "get_finished_adventures_ack": 3081,
    "get_character_values": 770, "get_character_values_ack": 747,
    "get_server_time": 1214, "get_server_time_ack": 1216,
    "get_explore": 1074, "get_explore_ack": 1109,
    "get_map_events": 1338, "get_map_events_ack": 1433,
    "get_capsule_info": 1519, "get_capsule_info_ack": 1396,
    "get_capsule_cds": 1573, "get_capsule_cds_ack": 1526,
    "get_signin": 806, "get_signin_ack": 676,
    "list_bulletins": 324, "list_bulletins_ack": 320,
    "recover_tower": 18, "recover_tower_ack": 17,
    "get_pet_wiki": 55, "get_pet_wiki_ack": 54,
    "get_wishing_trees": 96, "get_wishing_trees_ack": 97,
    "get_vip_awards": 63, "get_vip_awards_ack": 62,
    "get_achievements": 72, "get_achievements_ack": 74,
    "get_potentials": 69, "get_potentials_ack": 70,
    "get_seven_day_award": 391, "get_seven_day_award_ack": 390,
    "compound_pet_piece": 83, "compound_pet_piece_ack": 84,
    "get_activities": 154, "get_activities_ack": 152,
    "get_friends": 347, "get_friends_ack": 253,
    "get_friend_detail": 1283, "get_friend_detail_ack": 1261,
    "get_current_adventure": 2999, "get_current_adventure_ack": 2997,
    "create_adventure": 2996, "create_adventure_ack": 3080,
    "fire_adventure_event": 4, "fire_adventure_event_ack": 5,
    "finish_adventure": 3082, "finish_adventure_ack": 2995,
    "get_adventure_award": 2998, "get_adventure_award_ack": 3079,
    "load_month_card": 3104, "load_month_card_ack": 3106,
    "recharge_cd": 662, "recharge_cd_ack": 655,
    "get_world_open_time": 412, "get_world_open_time_ack": 410,
    "get_science": 659, "get_science_ack": 651,
    "check_unread_mail": 930, "check_unread_mail_ack": 1077,
    "list_mail": 978, "list_mail_ack": 274,
    "get_mail": 288, "get_mail_ack": 305,
    "claim_mail": 1054, "claim_mail_ack": 1106,
    "delete_mail": 1114, "delete_mail_ack": 271,
    "get_world_boss": 446, "get_world_boss_ack": 450,
    "quest_list": 785, "quest_list_ack": 26, "quest_list_ntf": 404,
    "quest_commit": 400, "quest_commit_ack": 726,
    "quest_update": 3133, "quest_update_ack": 3132,
    "change_character_info": 632, "change_character_info_ack": 630,
    "buy_goods": 858, "buy_goods_ack": 1953,
    "get_shop": 778, "get_shop_ack": 1746,
    "query_arena": 277, "query_arena_ack": 51,
    "system_refresh_goods": 835, "system_refresh_goods_ack": 859,
    "refresh_goods": 853, "refresh_goods_ack": 1876,
    "buy_product": 481, "buy_product_ack": 471,
    "get_my_market": 478, "get_my_market_ack": 493,
    "search_market_products": 492, "search_market_products_ack": 520,
    "buy_market": 577, "buy_market_ack": 563,
    "buy_activity": 595, "buy_activity_ack": 593,
    "buy_mcash": 398, "buy_mcash_ack": 406,
    "buy_packet": 2042, "buy_packet_ack": 2043,
    "buy_power": 1242, "buy_power_ack": 991,
    "buy_gcash": 463, "buy_gcash_ack": 449,
    "capsule_egg": 1392, "capsule_egg_ack": 1561,
    "recharge_test": 90, "recharge_test_ack": 89,
    "take_month_card": 3102, "take_month_card_ack": 3103,
    "buy_npc": 86, "red_heart": 79, "claim_vip": 61,
    "pet_star_up": 1596, "pet_evolve": 1247, "pet_super_evolve": 729,
    "pet_advance_stage": 1038, "pet_advance_stage_ack": 1032,
    "pet_skill_change": 1282, "pet_skill_level": 1302, "pet_equip_strengthen": 561,
    "change_channel": 380, "change_channel_ack": 386,
    "chat": 45, "chat_ack": 35,
    "query_self_territory": 1644, "query_self_territory_ack": 1664,
    "territory_info": 1819, "territory_info_ack": 1901,
    "get_week_champion": 501, "get_week_champion_ack": 498,
    "get_home": 118, "get_home_ack": 32,
    "create_pve_battle": 136, "create_pve_battle_ack": 210,
    "pve_capture": 15, "pve_capture_ack": 198,
    "pve_battle_end": 263, "pve_battle_end_ack": 186,
}
MSG_NAME = {value: key for key, value in CMD.items() if not key.endswith("_ack") and not key.endswith("_ntf")}
MSG_NAME.update({131: "CG_CLIENTINFO_REQ", 1626: "CM_APPOINTNICKNAME_REQ",
                 1684: "CG_DEVICE_RELOGIN_REQ", 380: "CG_CHANGECHANNEL_REQ"})
ACK_NAME = {2126: "GC_PLATFORMLOGIN_ACK", 2179: "GC_DEVICEBIND_ACK",
            2183: "GC_DEVICELOGIN_ACK", 132: "GC_CLIENTINFO_ACK",
            1104: "MC_APPOINTNICKNAME_ACK", 807: "GC_CREATECHAR_ACK",
            32: "GC_GETHOME_ACK",
            1526: "GC_CAPSULEEGGCDS_ACK", 386: "GC_CHANGECHANNEL_ACK"}
ACK_NAME.update({value: key.upper() for key, value in CMD.items() if key.endswith("_ack")})
ACK_NAME.update({60: "GC_GETVIPAWARD_ACK", 112: "GC_UPDATEITEMS_NTF", 1650: "GC_PETSTARUP_ACK",
                 3138: "GC_DELPOKEMON_NTF", 3141: "GC_UPDATEPOKEMON_NTF"})
EXPECTED_ACKS = {
    690: (721,), 128: (181,),
    227: (225,),
    118: (32,), 380: (386,), 154: (152,), 662: (655,), 785: (26, 404),
    3133: (3132,), 400: (726, 404), 632: (630,), 45: (35,),
    1644: (1664,), 1819: (1901,), 501: (498,),
    2075: (2102,), 2121: (2109,), 2098: (2066,),
    1283: (1261,), 481: (112, 133, 262, 473, 471), 1242: (473, 991, 404),
    72: (74,), 268: (837,), 73: (112, 133, 262, 3141, 473, 67),
    328: (112, 133, 262, 3141, 473, 485), 1794: (112, 133, 262, 3141, 473, 1798),
    869: (1737,), 296: (112, 133, 262, 3141, 473, 299), **{request: (ack,) for request, ack in arena.ACKS.items()},
    **{request: (112, 473, 3141, ack) for request, ack in pet_development.TRAIN_ACKS.items()},
    **{request: (2041, 3141, ack) for request, ack in pet_development.RELATION_ACKS.items()},
    1038: (112, 473, 1032), 1282: (133, 3141, 1369), 1302: (112, 133, 3141, 1371),
    2996: (3080,), 3078: (3081, 1749),
    2998: (3079,),
    1738: (112, 133, 262, 3141, 473, 1749, 1741),
    722: (746,),
    4: (5,), 83: (262, 3141, 84), 324: (320,), 391: (112, 133, 262, 473, 3141, 390),
    930: (1077,), 978: (274,), 288: (305,), 1054: (112, 133, 262, 473, 3141, 1106), 1114: (271,),
    90: (473, 89),
    1247: (112, 133, 262, 473, 3141, 777), 729: (112, 133, 262, 473, 3138, 3141, 728),
    1667: (3141, 1653), 415: (414,),
    61: (112, 133, 262, 473, 3141, 60), 63: (62,), 1596: (112, 3138, 3141, 1650),
    3082: (2995, 404, 473, 1749),
    15: (112, 3141, 198), 136: (112, 210), 263: (3141, 186), 1392: (112, 133, 262, 3141, 473, 1561), 1519: (1396,),
    516: (526, 112, 133, 262, 473, 3141, 2105), 478: (493,), 492: (520,), 577: (563, 112, 473),
}


def _opaque_id(value: str) -> str:
    return hashlib.sha256(value.encode("utf-8", "replace")).hexdigest()[:12]


class Session:
    def __init__(self, db: Database):
        self.db = db
        self.connection_id = uuid.uuid4().hex[:12]
        self.session_id = uuid.uuid4().hex[:12]
        self.account_id: int | None = None
        self.world_id = 1
        self.char_id: int | None = None
        self.username = ""
        self.user_token = ""
        self.channel = ""
        self.town_position = None
        self.local_market_quotes = set()
        self.stamina_quote = None
        self.daily_entries = None


async def dispatch(session: Session, msg_id: int, payload: bytes) -> tuple[int, bytes] | None:
    if msg_id in arena.ACKS:
        return await arena.handle(session, msg_id, payload)
    if msg_id in pet_development.TRAIN_ACKS:
        return await pet_development.train(session, msg_id, payload)
    if msg_id in pet_development.RELATION_ACKS:
        return await pet_development.relation(session, msg_id, payload)
    if msg_id == 869:
        return await economy.reset_arena_shop(session, payload)
    if msg_id == 296:
        return await events.claim_recharge_banner(session, payload)
    if msg_id in (72, 268):
        Reader(payload).finish()
        return await progression.list_achievements(session, msg_id == 72)
    if msg_id in (73, 328, 1794):
        reader = Reader(payload)
        key = reader.u32() if msg_id == 1794 else reader.u16()
        reader.finish()
        if msg_id == 1794:
            return await progression.daily_claim(session, key, gift=True)
        return await progression.claim_achievement(session, key, msg_id == 73)
    if msg_id == CMD["compound_pet_piece"]:
        return await inventory.compound_pet_piece(session, payload)
    # Native CommandL.SYSPING_ACK shares numeric ID 4 with the Lua command
    # CG_FIREADVENTUREEVENT_REQ. The native packet has no body; the gameplay
    # request has an adventure ID and byte-counted event vector.
    if msg_id == 4:
        if not payload:
            return None
        return await map_handler.fire_adventure_events(session, payload)
    if msg_id == CMD["get_seven_day_award"]:
        return await events.get_seven_day_award(session, payload)
    if msg_id == CMD["get_activities"]: return await events.get_activities(session, payload)
    if msg_id == CMD["check_unread_mail"]: return await events.check_unread_mail(session, payload)
    if msg_id == CMD["list_mail"]: return await events.list_mail(session, payload)
    if msg_id == CMD["get_mail"]: return await events.update_mail(session, payload, CMD["get_mail_ack"])
    if msg_id == CMD["claim_mail"]: return await events.update_mail(session, payload, CMD["claim_mail_ack"])
    if msg_id == CMD["delete_mail"]: return await events.update_mail(session, payload, CMD["delete_mail_ack"])
    if msg_id == CMD["finish_adventure"]:
        return await map_handler.finish_adventure(session, payload)
    if msg_id == 1738:
        return await map_handler.quick_clear_adventure(session, payload)
    if msg_id == 722:
        return await map_handler.adventure_use_skill(session, payload)
    if msg_id == CMD["read_info"]:
        return await character_state.read_info(session, payload)
    if msg_id == CMD["get_life_skill_data"]:
        return await character_state.life_skill(session, payload)
    if msg_id == CMD["get_treasure_box_data"]:
        return await treasure.get_data(session, payload)
    if msg_id == 131: return await auth.client_info(session, payload)
    if msg_id == CMD["platform_login"]: return await auth.platform_login(session, payload)
    if msg_id == CMD["device_bind"]: return await auth.device_bind(session, payload)
    if msg_id == CMD["device_login"]: return await auth.device_login(session, payload)
    if msg_id == 1684: return await auth.device_relogin(session, payload)
    if msg_id == 1626: return await player.appoint_nickname(session, payload)
    if msg_id == CMD["create_character"]: return await player.create_character(session, payload)
    if msg_id == CMD["pve_capture"]: return await battle.capture_pokemon(session, payload)
    if msg_id == CMD["query_pets"]: return await pet.query_pets(session, payload)
    if msg_id == CMD["get_fashions"]: return await player.get_fashions(session, payload)
    if msg_id == CMD["set_fashions"]: return await player.set_fashions(session, payload)
    if msg_id == CMD["restore_fashions"]: return await player.restore_fashions(session, payload)
    if msg_id == CMD["get_items"]: return await inventory.get_items(session, payload)
    if msg_id == CMD["use_item"]: return await inventory.use_item(session, payload)
    if msg_id == CMD["update_army"]: return await pet.update_army(session, payload)
    if msg_id == CMD["get_army"]: return await pet.get_army(session, payload)
    if msg_id == CMD["get_capsule_info"]: return await pet.get_capsule_egg_info(session, payload)
    if msg_id == CMD["get_capsule_cds"]: return await pet.get_capsule_egg_cds(session, payload)
    if msg_id == CMD["get_character_values"]: return await player.get_character_values(session, payload)
    if msg_id == CMD["buy_goods"]: return await economy.buy_goods(session, payload)
    if msg_id == CMD["get_shop"]: return await economy.arena_shop_catalog(session, payload, 1746)
    if msg_id == CMD["system_refresh_goods"]: return await economy.arena_shop_catalog(session, payload, 859)
    if msg_id == CMD["refresh_goods"]: return await economy.arena_shop_catalog(session, payload, 1876)
    if msg_id == CMD["buy_product"]: return await economy.buy_product(session, payload)
    if msg_id == CMD["get_my_market"]: return await economy.get_my_market(session, payload)
    if msg_id == CMD["search_market_products"]: return await economy.search_market_products(session, payload)
    if msg_id == CMD["buy_market"]: return await economy.buy_market(session, payload)
    if msg_id == CMD["buy_activity"]: return await economy.buy_activity(session, payload)
    if msg_id == CMD["buy_mcash"]: return await economy.buy_mcash(session, payload)
    if msg_id == CMD["buy_packet"]: return await economy.buy_packet(session, payload)
    if msg_id == CMD["buy_power"]: return await economy.buy_power(session, payload)
    if msg_id == CMD["buy_gcash"]: return await economy.buy_gcash(session, payload)
    if msg_id == CMD["capsule_egg"]: return await economy.capsule_egg(session, payload)
    if msg_id == CMD["recharge_test"]: return await economy.recharge_test(session, payload)
    if msg_id == CMD["load_month_card"]: return await economy.load_month_card(session, payload)
    if msg_id == CMD["recharge_cd"]: return await economy.get_recharge_cd(session, payload)
    if msg_id == CMD["take_month_card"]: return await economy.take_month_card(session, payload)
    if msg_id == CMD["buy_npc"]: return await economy.buy_npc(session, payload)
    if msg_id == CMD["red_heart"]: return await economy.red_heart(session, payload)
    if msg_id == CMD["claim_vip"]: return await economy.claim_vip_award(session, payload)
    if msg_id == CMD["get_vip_awards"]: return await economy.get_vip_awards(session, payload)
    if msg_id == CMD["pet_star_up"]: return await economy.pet_star_up(session, payload)
    if msg_id == CMD["pet_advance_stage"]: return await pet.advance_stage(session, payload)
    if msg_id == CMD["pet_evolve"]: return await pet_evolution.evolve(session, payload, 777)
    if msg_id == CMD["pet_super_evolve"]: return await pet_evolution.evolve(session, payload, 728)
    if msg_id == 1667: return await pet_evolution.evolution_skills(session, payload)
    if msg_id == 415: return await pet_evolution.evolution_skills(session, payload, clear=True)
    if msg_id == CMD["pet_skill_change"]: return await economy.pet_skill_action(session, payload, 1369)
    if msg_id == CMD["pet_skill_level"]: return await economy.pet_skill_action(session, payload, 1371)
    if msg_id == CMD["pet_equip_strengthen"]: return await economy.pet_equip_strengthen(session, payload)
    if msg_id == CMD["get_finished_adventures"]: return await map_handler.get_finished_adventures(session, payload)
    if msg_id == CMD["create_adventure"]: return await map_handler.create_adventure(session, payload)
    if msg_id == CMD["get_adventure_award"]: return await map_handler.get_adventure_award(session, payload)
    if msg_id == CMD["get_server_time"]: return await player.get_server_time(session, payload)
    if msg_id == CMD["change_channel"]: return await chat.change_channel(session, payload)
    if msg_id == CMD["get_friend_detail"]: return await chat.get_friend_detail(session, payload)
    if msg_id == CMD["chat"]: return await chat.send_chat(session, payload)
    if msg_id == CMD["query_self_territory"]: return await territory.query_self_territory(session, payload)
    if msg_id == CMD["territory_info"]: return await territory.territory_info(session, payload)
    if msg_id == CMD["get_week_champion"]: return await world_boss.get_week_champion(session, payload)
    if msg_id == CMD["quest_list"]: return await map_handler.get_quests(session, payload)
    if msg_id == CMD["get_home"]: return await map_handler.get_home(session, payload)
    if msg_id in (CMD["create_pve_battle"], CMD["pve_battle_end"]):
        return await battle.handle(msg_id, payload, session)
    if msg_id == CMD["quest_update"]: return await map_handler.update_quest(session, payload)
    if msg_id == CMD["quest_commit"]: return await map_handler.commit_quest(session, payload)
    if msg_id == CMD["change_character_info"]:
        return await player.change_character_info(session, payload)
    # CommandL is supplied by the native networking layer and is not part of
    # the decoded Lua command table. Allow deployments to configure its IDs;
    # keep the ACK payload empty as NetMgr.sendSysPing_Ack writes only a WORD.
    heartbeat_id = os.getenv("GAME_HEARTBEAT_REQUEST_ID")
    if heartbeat_id and msg_id == int(heartbeat_id):
        return int(os.getenv("GAME_HEARTBEAT_ACK_ID", heartbeat_id)), b""
    # LoginMsgMgr's startup queue expects these acknowledgements to release its
    # serial callback chain. Their full gameplay data are populated in later
    # handlers; zero/empty values are valid empty-account states per Proto_*.
    return await map_handler.startup_empty_ack(session, msg_id, payload)


async def handle_client(reader: asyncio.StreamReader, writer: asyncio.StreamWriter, db: Database) -> None:
    peer = writer.get_extra_info("peername")
    session = Session(db)
    close_reason = "client_eof"
    log.info("connected connection_id=%s session_id=%s peer=%s", session.connection_id,
             session.session_id, peer)
    try:
        while True:
            msg_id, body, length = await read_frame(reader)
            try:
                fields = safe_request_fields(msg_id, body)
            except (ValueError, IndexError, UnicodeError) as exc:
                fields = {"decode_error": str(exc)}
            safe_hex = redact_payload(msg_id, body).hex()
            request_name = ("SYSPING_ACK" if msg_id == 4 and not body else
                            MSG_NAME.get(msg_id, "UNKNOWN"))
            log.info("request connection_id=%s session_id=%s peer=%s id=%d name=%s length=%d fields=%s payload_hex=%s",
                     session.connection_id, session.session_id, peer, msg_id,
                     request_name, length, fields, safe_hex[:512])
            expected_acks = None if msg_id == 4 and not body else EXPECTED_ACKS.get(msg_id)
            if expected_acks is not None:
                log.info("pending_ack connection_id=%s session_id=%s request_id=%d expected_response_ids=%s",
                         session.connection_id, session.session_id, msg_id, expected_acks)
            started = asyncio.get_running_loop().time()
            try:
                answer = await dispatch(session, msg_id, body)
            except ProtocolDecodeError:
                close_reason = "protocol_decode_error"
                log.exception("protocol_decode_error connection_id=%s session_id=%s peer=%s id=%d name=%s",
                              session.connection_id, session.session_id, peer,
                              msg_id, MSG_NAME.get(msg_id, "UNKNOWN"))
                raise
            except Exception as exc:
                module = type(exc).__module__
                close_reason = "database_exception" if module.startswith("asyncpg") else "handler_exception"
                log.exception("%s connection_id=%s session_id=%s peer=%s id=%d name=%s account_id=%s char_id=%s",
                              close_reason,
                              session.connection_id, session.session_id, peer, msg_id,
                              MSG_NAME.get(msg_id, "UNKNOWN"), session.account_id, session.char_id)
                raise
            elapsed_ms = (asyncio.get_running_loop().time() - started) * 1000
            log.info("handler_complete connection_id=%s session_id=%s id=%d name=%s elapsed_ms=%.2f account_id=%s char_id=%s result=%s",
                     session.connection_id, session.session_id, msg_id,
                     MSG_NAME.get(msg_id, "UNKNOWN"), elapsed_ms,
                     session.account_id, session.char_id,
                     "no_response" if answer is None else "response_ready")
            if answer is None:
                continue
            answers = answer if isinstance(answer, list) else [answer]
            if (msg_id == CMD["finish_adventure"] and session.char_id is not None
                    and body != b"\0\0" and answers[0][1].startswith(b"\0\0")):
                progress = await db.committed_character_progress(session.char_id)
                answers.append((473, Writer().string(json.dumps(progress)).bytes()))
                answers.extend(await map_handler.adventure_clear_notifications(session))
            if msg_id in (15, 400, 516, 1038, 1242, 1392, 1738, 2996, 3082) and session.daily_entries is not None:
                notices = await progression.daily_updates(session)
                if notices:
                    answers.extend(notices)
                    if expected_acks is not None:
                        expected_acks = (*expected_acks, 404)
            packet_sizes = []
            for ack_id, ack_body in answers:
                packet = frame(ack_id, ack_body)
                safe_ack = redact_response_payload(ack_id, ack_body)
                packet_sizes.append((ack_id, len(packet), safe_ack[:256].hex()))
                writer.write(packet)
            await writer.drain()
            for ack_id, size, encoded in packet_sizes:
                if expected_acks is not None and ack_id not in expected_acks:
                    log.warning("response_mapping_mismatch connection_id=%s session_id=%s request_id=%d expected_response_ids=%s actual_response_id=%d",
                                session.connection_id, session.session_id, msg_id,
                                expected_acks, ack_id)
                log.info("response connection_id=%s session_id=%s peer=%s request_id=%d response_id=%d response_name=%s length=%d payload_hex=%s",
                         session.connection_id, session.session_id, peer, msg_id,
                         ack_id, ACK_NAME.get(ack_id, "UNKNOWN"), size, encoded)
    except asyncio.IncompleteReadError as exc:
        close_reason = "client_eof" if not exc.partial else "truncated_frame"
        if exc.partial:
            log.warning("truncated_frame connection_id=%s session_id=%s peer=%s received=%d expected=%d",
                        session.connection_id, session.session_id, peer, len(exc.partial), exc.expected)
    except ConnectionError:
        close_reason = "transport_error"
    except asyncio.CancelledError:
        close_reason = "transport_error"
        raise
    except ValueError as exc:
        if close_reason not in {"handler_exception", "database_exception", "protocol_decode_error"}:
            close_reason = "protocol_error"
        log.exception("%s connection_id=%s session_id=%s peer=%s error=%s",
                      close_reason,
                      session.connection_id, session.session_id, peer, exc)
    except Exception:
        close_reason = "server_exception"
        log.exception("server_exception connection_id=%s session_id=%s peer=%s",
                      session.connection_id, session.session_id, peer)
    finally:
        writer.close()
        try:
            await writer.wait_closed()
        except ConnectionError:
            pass
        log.info("disconnected connection_id=%s session_id=%s peer=%s account_id=%s char_id=%s reason=%s",
                 session.connection_id, session.session_id, peer,
                 session.account_id, session.char_id, close_reason)


async def main() -> None:
    from local_draw import catalog_report
    if path := os.getenv("MONSTER2_DRAW_CATALOG"):
        log.info("gacha_catalog_active=%s", json.dumps(catalog_report(path), sort_keys=True))
    db = await Database.connect()
    await db.initialize()
    host, port = os.getenv("GAME_BIND", "0.0.0.0"), int(os.getenv("GAME_PORT", "5568"))
    server = await asyncio.start_server(lambda r, w: handle_client(r, w, db), host, port)
    log.info("listening on %s:%d", host, port)
    try:
        async with server: await server.serve_forever()
    finally:
        await db.close()


if __name__ == "__main__": asyncio.run(main())
