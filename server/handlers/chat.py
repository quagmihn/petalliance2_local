from __future__ import annotations

from protocol import ProtocolDecodeError, Reader, Writer


async def send_chat(session, payload: bytes):
    """Reject chat explicitly while completing the client's ACK contract."""
    r = Reader(payload)
    _char_id, _channel, _content = r.string(), r.string(), r.string()
    r.finish()
    # There is no chat relay/storage in this offline backend. Return the
    # protocol error code instead of claiming a message was delivered.
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
    """Return the protocol's explicit not-found error until profiles are persisted."""
    r = Reader(payload)
    friend_id = r.string()
    r.finish()
    if not friend_id:
        raise ProtocolDecodeError("CG_GETFRIENDDETAIL_REQ has an empty friend ID")
    # The client consumes a detail string only on code=0. Profile composition
    # is not backed by a complete local data model, so fail cleanly instead of
    # inventing a profile or leaving the blocking callback pending.
    return 1261, Writer().u16(1).bytes()
