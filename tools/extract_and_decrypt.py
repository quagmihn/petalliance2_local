#!/usr/bin/env python3
import struct
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
APK_RAW_DIR = ROOT / "apk_raw"
EXTRACTED_DIR = ROOT / "apk_extracted"

SIGN = b"XXTEA"
KEY = b"kyopkm"
DELTA = 0x9E3779B9


def xxtea_decrypt(data: bytes, key: bytes = KEY) -> bytes | None:
    """Decrypt Cocos2d-x XXTEA-encrypted Lua payload.
    Format: b'XXTEA' + encrypted uint32 words. key zero-padded to 16 bytes.
    Original payload length stored in v[n-1] (last uint32 word).
    """
    if not data.startswith(SIGN):
        return None
    payload = data[len(SIGN):]
    if len(payload) < 8 or len(payload) % 4 != 0:
        return None

    k = struct.unpack("<4I", key.ljust(16, b"\x00")[:16])
    v = list(struct.unpack("<%dI" % (len(payload) // 4), payload))
    n = len(v) - 1
    if n < 1:
        return None

    # Standard XXTEA decrypt (btea) with n = number of words
    # Cocos2d-x uses n as count including? common impl: n = len(v)
    # but stored length is in v[n-1]. We'll use btea with n=len(v).
    def btea(v, n, k):
        if n > 1:  # decrypt
            rounds = 6 + 52 // n
            sum_ = (rounds * DELTA) & 0xFFFFFFFF
            y = v[0]
            while sum_ != 0:
                e = (sum_ >> 2) & 3
                for p in range(n - 1, -1, -1):
                    z = v[p - 1] if p > 0 else v[n - 1]
                    mx = (((z >> 5 ^ y << 2) + (y >> 3 ^ z << 4)) ^ ((sum_ ^ y) + (k[(p & 3) ^ e] ^ z)))
                    v[p] = (v[p] - mx) & 0xFFFFFFFF
                    y = v[p]
                sum_ = (sum_ - DELTA) & 0xFFFFFFFF
        return v

    v = btea(v, len(v), k)
    orig_len = v[-1]
    out = struct.pack("<%dI" % len(v), *v)
    if orig_len < 0 or orig_len > len(out) - 4:
        # fallback: some implementations store len differently; try trim nulls
        return out.rstrip(b"\x00")
    return out[:orig_len]


def find_apk(apk_raw_dir: Path) -> Path:
    apks = sorted(apk_raw_dir.glob("*.apk"))
    if not apks:
        raise FileNotFoundError(f"No .apk found in {apk_raw_dir}")
    return apks[0]


def extract_apk(apk_path: Path, out_dir: Path) -> None:
    out_dir.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(apk_path, "r") as zf:
        zf.extractall(out_dir)


def decrypt_src_assets(out_dir: Path) -> tuple[int, int, int]:
    src_dir = out_dir / "assets" / "src"
    total = decrypted = skipped = 0
    if not src_dir.exists():
        return 0, 0, 0
    for path in src_dir.rglob("*"):
        if not path.is_file():
            continue
        if path.suffix.lower() not in (".lua", ".luac"):
            continue
        total += 1
        data = path.read_bytes()
        if not data.startswith(SIGN):
            skipped += 1
            continue
        plain = xxtea_decrypt(data, KEY)
        if plain is None:
            print(f"[WARN] decrypt failed: {path.relative_to(out_dir)}")
            skipped += 1
            continue
        path.write_bytes(plain)
        decrypted += 1
    return total, decrypted, skipped


def main():
    apk = find_apk(APK_RAW_DIR)
    print(f"Using APK: {apk}")
    print(f"Extracting to: {EXTRACTED_DIR}")
    extract_apk(apk, EXTRACTED_DIR)
    print("Extraction complete.")
    total, decrypted, skipped = decrypt_src_assets(EXTRACTED_DIR)
    print(f"Lua files: total={total} decrypted={decrypted} skipped/not-encrypted-or-failed={skipped}")

    # quick sanity check
    sample = EXTRACTED_DIR / "assets/src/main.lua"
    if sample.exists():
        head = sample.read_bytes()[:80]
        print(f"Sample main.lua head: {head!r}")


if __name__ == "__main__":
    main()
