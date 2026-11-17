from protocol import Reader, Writer


async def get_week_champion(session, payload: bytes):
    Reader(payload).finish()  # Request 501 has no serialized fields.
    if session.char_id is None:
        return 498, Writer().u16(1).bytes()
    # No world-boss champion exists in the local data set. Serialize the
    # complete empty champion record expected by Proto_WorldBoss.lua.
    return 498, Writer().u16(0).u32(0).string("").string("").u8(0).string("").bytes()
