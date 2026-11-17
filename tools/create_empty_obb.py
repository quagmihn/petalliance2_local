#!/usr/bin/env python3
"""Create the empty expansion ZIP expected by this extracted Android build."""
import argparse
import zipfile
from pathlib import Path


def main() -> int:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--package", default="com.petalliance2.sea")
    p.add_argument("--version-code", default="7")
    p.add_argument("--output", type=Path)
    a = p.parse_args()
    name = f"main.{a.version_code}.{a.package}.obb"
    out = a.output or (Path.home() / ".local/share/waydroid/data/media/0/Android/obb" / a.package / name)
    out.parent.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(out, "w", compression=zipfile.ZIP_STORED):
        pass
    with zipfile.ZipFile(out) as zf:
        if zf.namelist(): raise RuntimeError("empty OBB unexpectedly contains entries")
    print(out)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
