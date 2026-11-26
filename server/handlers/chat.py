from __future__ import annotations

import json
import logging

from character_values import vip_info_id
from fashion_config import stored_fashion_state
from protocol import ProtocolDecodeError, Reader, Writer


log = logging.getLogger("game_socket")


async def send_chat(session, payload: bytes):
    """Reject chat explicitly while completing the client's ACK contract."""
    r = Reader(payload)
    recipient, _channel, _content = r.string(), r.string(), r.string()
    r.finish()
    # There is no chat relay/storage in this offline backend. Return the
    # protocol error code instead of claiming a message was delivered.
    log.info(
        "chat_rejected connection_id=%s session_id=%s account_id=%s char_id=%s "
        "request_id=45 response_id=35 recipient_char_id=%s reason=relay_unavailable",
        getattr(session, "connection_id", None), getattr(session, "session_id", None),
        getattr(session, "account_id", None), session.char_id,
        recipient if recipient.isascii() and recipient.isdecimal() and len(recipient) <= 20 else None,
    )
    return 35, Writer().u16(1).bytes()


async def change_channel(session, payload: bytes):
    """Join the requested chat channel and ACK using Proto_Chat's schema."""
    r = Reader(payload)
    channel, data = r.string(), r.string()
    r.finish()
    if not channel:
        raise ProtocolDecodeError("CG_CHANGECHANNEL_REQ has an empty channel")
    # The private server has no cross-world chat service. Retain the requested
    # channel on this live session so later chat traffic can be scoped to it.
    session.channel = channel
    session.channel_data = data
    return 386, Writer().u16(0).string(channel).bytes()


async def get_friend_detail(session, payload: bytes):
    """Return the selected character's profile for the wardrobe entry point."""
    r = Reader(payload)
    friend_id = r.string()
    r.finish()
    if not friend_id:
        raise ProtocolDecodeError("CG_GETFRIENDDETAIL_REQ has an empty friend ID")
    error = 1261, Writer().u16(1).bytes()
    if session.char_id is None or friend_id != str(session.char_id):
        return error
    row = await session.db.pool.fetchrow(
        """SELECT c.name,c.level,c.vip_level,c.game_values,
                  (SELECT count(*) FROM pets WHERE char_id=c.char_id) AS owned_pets,
                  (SELECT count(DISTINCT pet_template_id) FROM pets WHERE char_id=c.char_id) AS pet_species
           FROM characters c WHERE c.char_id=$1""", session.char_id,
    )
    if row is None:
        return error
    values = json.loads(row["game_values"])
    detail = {
        "charID": session.char_id, "nickname": row["name"], "level": row["level"],
        "vipLevel": vip_info_id(row["vip_level"]), "charSign": values.get("charsign", ""),
        "pets.num": row["owned_pets"], "diffPets.num": row["pet_species"],
        "lifeSkill": {"career": values.get("lifeskillcareer", 0), "level": values.get("lifeskilllevel", 0)},
        "fashion": {"curFashion": stored_fashion_state(values)["curFashion"]},
    }
    return 1261, Writer().u16(0).string(json.dumps(detail, separators=(",", ":"))).bytes()
