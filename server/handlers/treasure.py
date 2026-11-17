"""Schema from Proto_TreasureBox.lua and TreasureBoxInfo.setMyTreasureBoxData."""
import json
from protocol import Reader, Writer


async def get_data(session, payload):
    Reader(payload).finish()
    if session.char_id is None:
        return 225, Writer().u16(1).bytes()
    values = await session.db.pool.fetchval(
        "SELECT game_values FROM characters WHERE char_id=$1", session.char_id)
    if values is None:
        return 225, Writer().u16(1).bytes()
    if isinstance(values, str):
        values = json.loads(values)
    boxes = values.get("treasure_boxes", [])
    if not isinstance(boxes, list) or any(
        not isinstance(box, dict) or type(box.get("type")) is not int
        or ("time" in box and type(box["time"]) not in (int, float)) for box in boxes
    ):
        raise ValueError("invalid persisted treasure_boxes")
    return 225, Writer().u16(0).string(json.dumps(boxes, separators=(",", ":"))).bytes()
