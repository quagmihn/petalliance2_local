"""Typed defaults for the client JSON carried by GC_GetCharacterValues_Ack."""
from __future__ import annotations

import logging
from typing import Any

log = logging.getLogger("game_socket")

STRING_KEYS = {"map_lock", "maplock", "treasureboxselect", "curfashion", "usercode", "conusercode"}
ARRAY_KEYS = {"petequips", "wishingtree", "survivalbattlepets"}
OBJECT_DEFAULTS = {
    "activity": {"login": {"yday": 0}, "spokesmanguess": {}},
    "passwordproduct": {"list": []},
}
BOOLEAN_KEYS = {"ismarenaon"}

# Numeric values requested by LoginMsgMgr and consumed as counters, timestamps,
# levels, currencies, or rank data in the client managers.
NUMERIC_KEYS = set("""
sciencepoint resetscienceconsumetime resetscienceconsumenum sciencelevel
todaywarenafighttimes todaywarenafightrefreshtimes warenaupdatetime
explorepacketnum itempacketnum petpacketnum todaybuypowercount lastbuytime lastbuypowertime
furnituredailyeventtimes friendpoints furniturelosttowermaxstepnumber
furnituresuitcasevaluerate lifeskilllevel lifeskillcareer
familyquestfailedtime familyquestok familyquestawardindex todayfamilyquestnum
todayfamilyquesttime getfamilydevotebuffertime familydevotebuffer goldcoin
familydungeonstepnumber familydungeonstepnumberupdatetime recharge todayarenafighttimes
arenaupdatetime todayarenafightrefreshtimes arenascore toprank todaymarenafighttimes
marenaupdatetime todaymarenafightrefreshtimes pvparenagrade pvparenapoint pvparenacoin
fixpvparenapoint achievementpoint arenarank losttowerfloor losttowerpoint familyquestid
advexp1 advexp2 advexp3 worldbosstime catchrateaddcount survivalbattlefloor world
gold diamond viplevel vip_level actionvalue stamina vip_points create_time
""".split())
NUMERIC_KEYS.add("furniturecomputervalu erate".replace(" ", ""))


def _expected(key: str):
    normalized = key.lower()
    if normalized in STRING_KEYS: return str, ""
    if normalized in ARRAY_KEYS: return list, []
    if normalized in OBJECT_DEFAULTS: return dict, OBJECT_DEFAULTS[normalized]
    if normalized in BOOLEAN_KEYS: return (bool, int), False
    if normalized in NUMERIC_KEYS: return int, 0
    if normalized.startswith(("buymarketitemnum_", "buymarketitemtime_", "msa_", "aaw_", "weektake", "takeweekawardtime")):
        return int, 0
    return None


def validate_character_values(requested: list[str], raw: dict[str, Any]) -> dict[str, Any]:
    result: dict[str, Any] = {}
    for key in requested:
        spec = _expected(key)
        if spec is None:
            # Do not invent a value for an unclassified field. Existing stored
            # values still pass through, while absent keys are omitted.
            if key in raw:
                result[key] = raw[key]
            continue
        expected, default = spec
        value = raw.get(key, default)
        if expected == (bool, int) and isinstance(value, int) and not isinstance(value, bool):
            if value in (0, 1):
                value = bool(value)
        valid = isinstance(value, expected)
        if expected is int and isinstance(value, bool): valid = False
        if not valid:
            log.warning("character_value_type_mismatch key=%s expected=%s actual=%s fallback=typed_default",
                        key, getattr(expected, "__name__", str(expected)), type(value).__name__)
            value = default
        result[key] = value
    return result
