"""Read simple XDat config records using the shipped Lua decoder declarations.

Unsupported/conditional schemas fail closed. This is for static config tables,
not a replacement for validation of untrusted network messages.
"""
import functools
import re
import struct
import sys
from pathlib import Path
from pet_config import CONFIG, rows
from protocol import Reader

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))
from decode_lua import decrypt


@functools.cache
def decoders():
    result = {}
    # Config row parsers are defined in both ``*_Types.lua`` and feature files
    # such as Proto_Market.lua. Parse the shipped declarations themselves so
    # tables do not silently become unsupported just because the type parser
    # lives outside the historical *_Types convention.
    for path in (ROOT / "decoded_lua/assets/src/Net/Proto").glob("Proto_*.lua"):
        text = path.read_text()
        for name, body in re.findall(r"function Proto\.parse(\w+)\(entry\)(.*?)\nend", text, re.S):
            if re.search(r"\n\s*if\s", body):
                continue
            fields = re.findall(r"data\.(\w+)\s*=\s*Proto\.parse(\w+)\(entry(?:,Proto\.parse(\w+))?\)", body)
            if fields:
                result[name] = fields
    # These target-client recharge readers are simple, unconditional XDat
    # records, but their parser functions live beside conditional protocol
    # types and the generic scanner intentionally skips those blocks.
    result["NormalRechargeInfo"] = [
        ("id", "int", None), ("name", "string", None), ("money", "int", None),
        ("mCash", "int", None), ("giftMCash", "int", None),
        ("bonusRate", "int", None), ("bonusCD", "int", None),
        ("orderName", "String", None), ("image", "String", None), ("tag", "String", None),
    ]
    result["MonthCardRechargeInfo"] = [
        ("id", "int", None), ("name", "string", None), ("money", "int", None),
        ("days", "int", None), ("mCashPerDay", "int", None),
        ("initMCash", "int", None), ("orderName", "String", None),
    ]
    result["FirstRechargeAwardInfo"] = [
        ("id", "int", None), ("type", "int", None), ("itemID", "int", None),
        ("itemCount", "int", None), ("mailID", "int", None),
    ]
    return result


def parse(r, kind):
    if kind in ("BYTE", "CountryID", "BOOL"): return r.u8()
    if kind in ("WORD", "TownID"): return r.u16()
    if kind in ("DWORD", "PetID", "int"): return r.u32()
    if kind in ("QWORD", "TIME_SEC", "CharacterID"): return r.u64()
    if kind in ("String", "string", "LifeNick", "NickName", "UserName"): return r.string()
    if kind == "FloatString": return float(r.string())
    if kind in ("float", "Float"): return struct.unpack("<f", r.take(4))[0]
    fields = decoders().get(kind)
    if fields is None:
        raise ValueError(f"unsupported Lua config type {kind}")
    return {key: [parse(r, item) for _ in range(r.u8())] if field == "Vector" else parse(r, field)
            for key, field, item in fields}


@functools.cache
def table(name, config_dir=CONFIG):
    result = {}
    for raw in rows(name, config_dir):
        r = Reader(raw)
        row = parse(r, name)
        r.finish()
        if row["id"] in result:
            raise ValueError(f"duplicate {name} ID")
        result[row["id"]] = row
    return result


@functools.cache
def text_table(name):
    raw = (ROOT / "apk_extracted/assets/res/Config" / name).read_bytes()
    if raw.startswith(b"XXTEA"):
        raw = decrypt(raw[5:], b"kyopkm")
    text = raw.decode("utf-8-sig")
    return [line.split("\t") for line in text.splitlines() if line]
