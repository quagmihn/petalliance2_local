from protocol import Reader, Writer


async def territory_info(session, payload: bytes):
    r = Reader(payload)
    count = r.u8()
    if count > 64:
        raise ValueError("territory adventure vector too large")
    adventure_ids = [r.u32() for _ in range(count)]
    r.finish()
    if any(adventure_id <= 0 for adventure_id in adventure_ids):
        raise ValueError("territory adventure IDs must be positive")
    # The local test world has no claimed territory rows. ACK 1901 defines
    # `code + vector<string>`; an empty vector is the truthful no-ownership state.
    return 1901, Writer().u16(0).vector_strings([]).bytes()


async def query_self_territory(session, payload: bytes):
    Reader(payload).finish()  # Request 1644 has no serialized fields.
    if session.char_id is None:
        return 1664, Writer().u16(1).bytes()
    # This local server has no claimed-territory or family records. The client
    # schema defines a valid empty state as code + adventure ID + family IDs.
    return 1664, Writer().u16(0).u32(0).u8(0).bytes()
