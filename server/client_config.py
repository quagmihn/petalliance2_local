"""Read simple XDat config records using the shipped Lua decoder declarations.

Unsupported/conditional schemas fail closed. This is for static config tables,
not a replacement for validation of untrusted network messages.
"""
import functools
import re
import sys
from pathlib import Path
from pet_config import rows
from protocol import Reader

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))
from decode_lua import decrypt


@functools.cache
def decoders():
    result = {}
    for path in (ROOT / "decoded_lua/assets/src/Net/Proto").glob("*Types.lua"):
        text = path.read_text()
        for name, body in re.findall(r"function Proto\.parse(\w+)\(entry\)(.*?)\nend", text, re.S):
            if re.search(r"\n\s*if\s", body):
                continue
            fields = re.findall(r"data\.(\w+)\s*=\s*Proto\.parse(\w+)\(entry(?:,Proto\.parse(\w+))?\)", body)
            if fields:
                result[name] = fields
    return result


def parse(r, kind):
    if kind in ("BYTE", "CountryID", "BOOL"): return r.u8()
    if kind in ("WORD", "TownID"): return r.u16()
    if kind in ("DWORD", "PetID", "int"): return r.u32()
    if kind in ("QWORD", "TIME_SEC", "CharacterID"): return r.u64()
    if kind in ("String", "string", "LifeNick", "NickName", "UserName"): return r.string()
    fields = decoders().get(kind)
    if fields is None:
        raise ValueError(f"unsupported Lua config type {kind}")
    return {key: [parse(r, item) for _ in range(r.u8())] if field == "Vector" else parse(r, field)
            for key, field, item in fields}


@functools.cache
def table(name):
    result = {}
    for raw in rows(name):
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
