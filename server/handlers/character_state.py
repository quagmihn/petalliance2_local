"""Startup read schemas from Proto_Login and Proto_LifeSkill."""
import json
from protocol import Reader, Writer


async def values_for(session):
    if session.char_id is None:
        return None
    raw = await session.db.pool.fetchval("SELECT game_values FROM characters WHERE char_id=$1", session.char_id)
    return json.loads(raw) if isinstance(raw, str) else raw


async def read_info(session, payload):
    r = Reader(payload); key = r.string(); r.finish()
    values = await values_for(session)
    if values is None:
        return 721, Writer().u16(1).string("").bytes()
    content = values.get("read_info", {}).get(key, "")
    if not isinstance(content, str):
        raise ValueError("read_info content must be a string")
    return 721, Writer().u16(0).string(content).bytes()


async def life_skill(session, payload):
    Reader(payload).finish()
    values = await values_for(session)
    if values is None:
        return 181, Writer().u16(1).bytes()
    data = values.get("life_skill", {"level": 0, "exp": 0})
    if not isinstance(data, dict) or any(type(data.get(k)) is not int or data[k] < 0 for k in ("level", "exp")):
        raise ValueError("invalid persisted life_skill")
    return 181, Writer().u16(0).string(json.dumps(data, separators=(",", ":"))).bytes()
