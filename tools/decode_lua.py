#!/usr/bin/env python3
"""Decode Cocos2d-x XXTEA Lua assets without modifying the source tree."""
from __future__ import annotations

import argparse
import os
import struct
from pathlib import Path

DELTA = 0x9E3779B9


def _mx(sum_: int, y: int, z: int, p: int, e: int, key: list[int]) -> int:
    return ((((z >> 5) ^ (y << 2)) + ((y >> 3) ^ (z << 4))) ^
            ((sum_ ^ y) + (key[(p & 3) ^ e] ^ z))) & 0xFFFFFFFF


def _to_words(data: bytes, include_length: bool) -> list[int]:
    n = (len(data) + 3) // 4
    padded = data + b"\0" * (n * 4 - len(data))
    words = list(struct.unpack("<" + "I" * n, padded)) if n else []
    if include_length:
        words.append(len(data))
    return words


def _to_bytes(words: list[int], include_length: bool) -> bytes:
    if not words:
        return b""
    raw = struct.pack("<" + "I" * len(words), *words)
    if not include_length:
        return raw
    length = words[-1]
    if length > len(raw) - 4 or length <= len(raw) - 8:
        raise ValueError("invalid XXTEA plaintext length")
    return raw[:-4][:length]


def decrypt(data: bytes, key_bytes: bytes) -> bytes:
    if len(key_bytes) == 0:
        raise ValueError("XXTEA key cannot be empty")
    if len(data) < 8 or len(data) % 4:
        raise ValueError("ciphertext length must be at least 8 and divisible by 4")
    key = _to_words(key_bytes[:16].ljust(16, b"\0"), False)
    v = list(struct.unpack("<" + "I" * (len(data) // 4), data))
    n = len(v) - 1
    rounds = 6 + 52 // (n + 1)
    total = (rounds * DELTA) & 0xFFFFFFFF
    y = v[0]
    while total:
        e = (total >> 2) & 3
        for p in range(n, 0, -1):
            z = v[p - 1]
            v[p] = (v[p] - _mx(total, y, z, p, e, key)) & 0xFFFFFFFF
            y = v[p]
        z = v[n]
        v[0] = (v[0] - _mx(total, y, z, 0, e, key)) & 0xFFFFFFFF
        y = v[0]
        total = (total - DELTA) & 0xFFFFFFFF
    return _to_bytes(v, True)


def encrypt(data: bytes, key_bytes: bytes) -> bytes:
    if len(key_bytes) == 0:
        raise ValueError("XXTEA key cannot be empty")
    v = _to_words(data, True)
    if len(v) < 2:
        raise ValueError("XXTEA plaintext is too short")
    key = _to_words(key_bytes[:16].ljust(16, b"\0"), False)
    n = len(v) - 1
    rounds = 6 + 52 // (n + 1)
    total = 0
    z = v[n]
    for _ in range(rounds):
        total = (total + DELTA) & 0xFFFFFFFF
        e = (total >> 2) & 3
        for p in range(n):
            y = v[p + 1]
            v[p] = (v[p] + _mx(total, y, z, p, e, key)) & 0xFFFFFFFF
            z = v[p]
        y = v[0]
        v[n] = (v[n] + _mx(total, y, z, n, e, key)) & 0xFFFFFFFF
        z = v[n]
    return struct.pack("<" + "I" * len(v), *v)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", type=Path, nargs="?", default=Path("apk_extracted"))
    parser.add_argument("destination", type=Path, nargs="?", default=Path("decoded_lua"))
    parser.add_argument("--key", default=os.getenv("XXTEA_KEY"), help="key (or XXTEA_KEY env var)")
    parser.add_argument("--sign", default="XXTEA", help="Cocos asset prefix to remove")
    args = parser.parse_args()
    if not args.key:
        parser.error("provide --key or XXTEA_KEY; key is not present in readable workspace metadata")
    source = args.source.resolve()
    dest = args.destination.resolve()
    ok = failed = copied = 0
    for path in source.rglob("*.lua"):
        rel = path.relative_to(source)
        target = dest / rel
        target.parent.mkdir(parents=True, exist_ok=True)
        raw = path.read_bytes()
        try:
            if raw.startswith(args.sign.encode()):
                payload = decrypt(raw[len(args.sign):], args.key.encode())
                target.write_bytes(payload)
                ok += 1
            else:
                target.write_bytes(raw)
                copied += 1
        except (ValueError, struct.error) as exc:
            failed += 1
            print(f"FAILED {rel}: {exc}")
    print(f"decoded={ok} copied_plain={copied} failed={failed} output={dest}")
    return 1 if failed else 0


if __name__ == "__main__":
    raise SystemExit(main())
