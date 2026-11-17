from protocol import Reader, Writer


async def query_self_territory(session, payload: bytes):
    Reader(payload).finish()  # Request 1644 has no serialized fields.
    if session.char_id is None:
        return 1664, Writer().u16(1).bytes()
    # This local server has no claimed-territory or family records. The client
    # schema defines a valid empty state as code + adventure ID + family IDs.
    return 1664, Writer().u16(0).u32(0).u8(0).bytes()
