from __future__ import annotations

from protocol import ProtocolDecodeError, Reader, Writer


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
