"""Wire primitives confirmed against decoded Lua ByteArray and HDSocketTCP."""
from __future__ import annotations

import struct
import json
import hashlib

XOR_KEY = b"4inch_MxM"


class ProtocolDecodeError(ValueError):
    """A malformed wire frame or serialized field from the peer."""


def xor_payload(payload: bytes) -> bytes:
    # HDSocketTCP applies two position-dependent XOR passes; their composition
    # is symmetric, so the same operation decodes client request payloads.
    n = len(payload)
    return bytes(b ^ XOR_KEY[i % len(XOR_KEY)] ^ XOR_KEY[(n - i - 1) % len(XOR_KEY)]
                 for i, b in enumerate(payload))


async def read_frame(reader):
    """Read one complete TCP packet; readexactly handles split and coalesced IO."""
    prefix = await reader.readexactly(2)
    length = int.from_bytes(prefix, "little")
    if length < 4 or length > 65535:
        raise ProtocolDecodeError(f"invalid frame length {length}")
    tail = await reader.readexactly(length - 2)
    msg_id = int.from_bytes(tail[:2], "little")
    return msg_id, xor_payload(tail[2:]), length


def _mask(value: str) -> str:
    return "sha256:" + hashlib.sha256(value.encode("utf-8", "replace")).hexdigest()[:12]


def safe_request_fields(msg_id: int, payload: bytes) -> dict[str, object]:
    """Decode auth/client-info fields for logs without recording credentials."""
    r = Reader(payload)
    if msg_id == 2130:
        username, token = r.string(), r.string()
        return {"username": _mask(username), "token": "<redacted>", "token_length": len(token)}
    if msg_id in (2156, 2211):
        device_id, world, token = r.string(), r.string(), r.string()
        return {"device_id": _mask(device_id), "world_id": world,
                "device_token": "<redacted>", "token_length": len(token)}
    if msg_id == 1684:
        char_id = r.i32(); token = r.string()
        return {"char_id": char_id, "user_token": "<redacted>", "token_length": len(token)}
    if msg_id == 131:
        names = ("ip", "device_model", "os_name", "os_ver", "mac_addr", "udid",
                 "app_channel", "app_ver", "network", "device_screen", "platform_tag")
        fields = {name: r.string() for name in names}
        group_id, channel_id = r.u32(), r.u32()
        for name in ("ip", "mac_addr", "udid"):
            fields[name] = _mask(fields[name])
        fields["group_id"], fields["channel_id"] = group_id, channel_id
        return fields
    return {}


def redact_payload(msg_id: int, payload: bytes) -> bytes:
    """Keep byte lengths for diagnostics while zeroing credentials/identifiers."""
    if msg_id in (2130, 2156, 2211):
        r = Reader(payload)
        identity_start = r.pos; identity = r.string(); identity_end = r.pos - 1
        if msg_id == 2130:
            token_start = r.pos
            token = r.string()
            token_end = r.pos
            ranges = [(identity_start, identity_end, len(identity)),
                      (token_start, token_end - 1, len(token))]
        else:
            world_start = r.pos
            world = r.string()
            world_end = r.pos - 1
            token_start = r.pos
            token = r.string()
            ranges = [(identity_start, identity_end, len(identity)),
                      (world_start, world_end, len(world)),
                      (token_start, r.pos - 1, len(token))]
        for start, end, value_len in reversed(ranges):
            payload = payload[:start] + b"*" * value_len + payload[end:]
        return payload
    if msg_id == 1684:
        r = Reader(payload); r.i32(); token_start = r.pos
        token = r.string(); token_end = r.pos
        return payload[:token_start] + b"*" * len(token) + payload[token_end:]
    if msg_id == 131:
        r = Reader(payload); offsets = []
        for index in range(11):
            start = r.pos; value = r.string()
            if index in (0, 4, 5): offsets.append((start, r.pos - 1, len(value)))
        for start, end, value_len in reversed(offsets):
            payload = payload[:start] + b"*" * value_len + payload[end:]
        return payload
    return payload


def redact_response_payload(msg_id: int, payload: bytes) -> bytes:
    """Redact device/account tokens in ACK bodies before logging hex."""
    r = Reader(payload)
    if msg_id == 2126:
        r.i32(); r.string(); r.i32(); count = r.u8()
        ranges = []
        for _ in range(count):
            id_start = r.pos; device_id = r.string(); id_end = r.pos - 1
            r.string(); token_start = r.pos
            token = r.string()
            ranges.append((id_start, id_end, len(device_id)))
            ranges.append((token_start, r.pos - 1, len(token)))
    elif msg_id == 2183:
        r.i32(); r.string(); r.i32(); r.u32(); r.u64(); r.i32()
        start = r.pos; token = r.string(); ranges = [(start, r.pos - 1, len(token))]
    else:
        return payload
    for start, end, value_len in reversed(ranges):
        payload = payload[:start] + b"*" * value_len + payload[end:]
    return payload


class Reader:
    def __init__(self, data: bytes): self.data, self.pos = data, 0
    def take(self, n: int) -> bytes:
        if n < 0 or self.pos + n > len(self.data): raise ProtocolDecodeError("truncated packet")
        out = self.data[self.pos:self.pos+n]; self.pos += n; return out
    def u8(self): return self.take(1)[0]
    def u16(self): return struct.unpack("<H", self.take(2))[0]
    def u32(self): return struct.unpack("<I", self.take(4))[0]
    def i32(self): return struct.unpack("<i", self.take(4))[0]
    def u64(self): return struct.unpack("<Q", self.take(8))[0]
    def string(self, limit: int = 65535) -> str:
        end = self.data.find(b"\0", self.pos, min(len(self.data), self.pos + limit + 1))
        if end < 0: raise ProtocolDecodeError("unterminated protocol string")
        value = self.data[self.pos:end]; self.pos = end + 1
        return value.decode("utf-8", "replace")
    def finish(self) -> None:
        if self.pos != len(self.data):
            raise ProtocolDecodeError(f"{len(self.data) - self.pos} trailing payload bytes")


class Writer:
    def __init__(self): self.data = bytearray()
    def u8(self, value): self.data.extend(struct.pack("<B", value & 0xff)); return self
    def u16(self, value): self.data.extend(struct.pack("<H", value & 0xffff)); return self
    def u32(self, value): self.data.extend(struct.pack("<I", value & 0xffffffff)); return self
    def i32(self, value): self.data.extend(struct.pack("<i", int(value))); return self
    def u64(self, value): self.data.extend(struct.pack("<Q", int(value) & 0xffffffffffffffff)); return self
    def raw(self, value: bytes): self.data.extend(value); return self
    def string(self, value: str): self.data.extend(value.encode("utf-8") + b"\0"); return self
    def vector_strings(self, values):
        self.u8(len(values))
        for value in values: self.string(value)
        return self
    def json_string(self, value): return self.string(json.dumps(value, separators=(",", ":")))
    def bytes(self): return bytes(self.data)


def frame(msg_id: int, body: bytes = b"") -> bytes:
    packet_len = 4 + len(body)
    if packet_len > 65535: raise ValueError("packet too large")
    return struct.pack("<HH", packet_len, msg_id) + body


def success_code() -> Writer:
    # Proto.parseCode = int32 value, NUL-terminated file, int32 line.
    return Writer().i32(0).string("").i32(0)
