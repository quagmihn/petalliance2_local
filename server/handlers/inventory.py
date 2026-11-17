import json

from protocol import Writer


async def get_items(session, payload: bytes):
    rows = []
    if session.char_id is not None:
        rows = await session.db.pool.fetch(
            "SELECT item_id,count FROM inventory WHERE char_id=$1 ORDER BY item_id", session.char_id
        )
    # Proto_Item.lua acknowledgement counts items, equips, furniture, skillbooks,
    # and pet pieces; unknown catalog classifications remain zero.
    total = sum(int(row["count"]) for row in rows)
    ack = Writer().u16(0).u32(total).u32(0).u32(0).u32(0).u32(0).bytes()
    responses = [(37, ack)]
    for start in range(0, len(rows) or 1, 255):
        batch = rows[start:start + 255]
        items = [json.dumps(
            {"itemID": row["item_id"], "num": row["count"]}, separators=(",", ":")
        ) for row in batch]
        responses.append((112, Writer().vector_strings(items).bytes()))
    return responses
