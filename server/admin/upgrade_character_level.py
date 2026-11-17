"""Back up and set one character to a configuration-valid level.

Read-only by default. Applying requires --apply and DATABASE_URL. A JSON
snapshot is fsynced before the UPDATE runs; --rollback restores only the
character's previous level and exp, leaving all other character state intact.
"""
from __future__ import annotations

import argparse
import asyncio
import json
import os
import struct
import tempfile
from datetime import date, datetime, timezone
from decimal import Decimal
from pathlib import Path
from typing import Any

import asyncpg

ROOT = Path(__file__).resolve().parents[2]
DEFAULT_CONFIG = ROOT / "unpacked/assets/res/Config/ExperienceInfo.dat"
BACKUP_DIR = ROOT / "server/backups"


def read_role_exp_table(path: Path = DEFAULT_CONFIG) -> dict[int, int]:
    """Read level->cumulative-role-EXP from the length-prefixed client table."""
    data = path.read_bytes()
    if len(data) < 4:
        raise ValueError("ExperienceInfo.dat is truncated")
    count = struct.unpack_from("<I", data, 0)[0]
    if not 1 <= count <= 1000:
        raise ValueError(f"invalid ExperienceInfo entry count: {count}")
    result: dict[int, int] = {}
    offset = 4
    for _ in range(count):
        if offset + 4 > len(data):
            raise ValueError("truncated ExperienceInfo record length")
        size = struct.unpack_from("<I", data, offset)[0]
        offset += 4
        end = offset + size
        if size < 49 or end > len(data):
            raise ValueError(f"invalid ExperienceInfo record size: {size}")
        record = memoryview(data)[offset:end]
        level, role_exp = struct.unpack_from("<II", record, 0)
        pet_count = record[8]
        # Fields: DWORD id, DWORD roleExp, BYTE pet-vector count, pet EXPs,
        # then four DWORD fields. This matches Proto_Pet_Types.
        expected_size = 9 + pet_count * 4 + 16
        if size != expected_size or level in result:
            raise ValueError(f"ExperienceInfo schema mismatch at level {level}")
        result[level] = role_exp
        offset = end
    if offset != len(data):
        raise ValueError("unexpected trailing bytes in ExperienceInfo.dat")
    if sorted(result) != list(range(1, count + 1)):
        raise ValueError("ExperienceInfo levels are not contiguous from level 1")
    values = [result[level] for level in sorted(result)]
    if any(a >= b for a, b in zip(values, values[1:])):
        raise ValueError("ExperienceInfo cumulative EXP is not strictly increasing")
    return result


def exp_at_start_of_level(role_exp: dict[int, int], target_level: int) -> int:
    if target_level not in role_exp:
        raise ValueError(f"target level {target_level} is outside the client table")
    return 0 if target_level == 1 else role_exp[target_level - 1]


def _json_default(value: Any):
    if isinstance(value, (datetime, date)):
        return value.isoformat()
    if isinstance(value, Decimal):
        return str(value)
    if isinstance(value, (bytes, bytearray, memoryview)):
        return {"__bytes_hex__": bytes(value).hex()}
    raise TypeError(f"cannot serialize database value {type(value).__name__}")


def _quote_ident(value: str) -> str:
    return '"' + value.replace('"', '""') + '"'


async def _target_schema(conn) -> tuple[set[str], list[tuple[str, str]]]:
    columns = await conn.fetch(
        "SELECT column_name FROM information_schema.columns "
        "WHERE table_schema='public' AND table_name='characters'")
    names = {row["column_name"] for row in columns}
    required = {"char_id", "account_id", "level", "exp"}
    if not required <= names:
        raise RuntimeError(f"characters schema missing required columns: {sorted(required - names)}")
    deps = await conn.fetch(
        """SELECT tc.table_name, kcu.column_name
           FROM information_schema.table_constraints tc
           JOIN information_schema.key_column_usage kcu
             ON tc.constraint_name=kcu.constraint_name AND tc.constraint_schema=kcu.constraint_schema
           JOIN information_schema.constraint_column_usage ccu
             ON ccu.constraint_name=tc.constraint_name AND ccu.constraint_schema=tc.constraint_schema
           WHERE tc.constraint_type='FOREIGN KEY' AND tc.table_schema='public'
             AND ccu.table_schema='public' AND ccu.table_name='characters'
             AND ccu.column_name='char_id'
           ORDER BY tc.table_name, kcu.ordinal_position""")
    return names, [(row["table_name"], row["column_name"]) for row in deps]


async def _snapshot(conn, character, dependencies: list[tuple[str, str]],
                    target_level: int, target_exp: int) -> dict[str, Any]:
    char_id = character["char_id"]
    related: dict[str, list[dict[str, Any]]] = {}
    for table, column in dependencies:
        query = (f"SELECT to_jsonb(t) AS row FROM public.{_quote_ident(table)} t "
                 f"WHERE t.{_quote_ident(column)}=$1 ORDER BY 1")
        related[table] = []
        for row in await conn.fetch(query, char_id):
            value = row["row"]
            if isinstance(value, str):
                value = json.loads(value)
            related[table].append(value)
    return {"account_id": character["account_id"], "char_id": char_id,
            "target_level": target_level, "target_exp": target_exp,
            "character": dict(character),
            "dependent_rows": related}


def _write_snapshot(snapshot: dict[str, Any], backup_dir: Path) -> Path:
    backup_dir.mkdir(parents=True, exist_ok=True)
    stamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%S.%fZ")
    path = backup_dir / f"account{snapshot['account_id']}_char{snapshot['char_id']}_level_{stamp}.json"
    fd, temp_name = tempfile.mkstemp(prefix=path.name + ".", suffix=".tmp", dir=backup_dir)
    try:
        with os.fdopen(fd, "w", encoding="utf-8") as output:
            json.dump(snapshot, output, ensure_ascii=False, indent=2, default=_json_default)
            output.flush()
            os.fsync(output.fileno())
        os.replace(temp_name, path)
        directory_fd = os.open(backup_dir, os.O_RDONLY)
        try:
            os.fsync(directory_fd)
        finally:
            os.close(directory_fd)
    except BaseException:
        try:
            os.unlink(temp_name)
        except FileNotFoundError:
            pass
        raise
    return path


async def upgrade(*, dsn: str, account_id: int, char_id: int, target_level: int,
                  apply: bool, backup_dir: Path, config_path: Path = DEFAULT_CONFIG) -> dict[str, Any]:
    role_exp = read_role_exp_table(config_path)
    desired_exp = exp_at_start_of_level(role_exp, target_level)
    conn = await asyncpg.connect(dsn)
    try:
        async with conn.transaction():
            _, dependencies = await _target_schema(conn)
            character = await conn.fetchrow(
                "SELECT * FROM public.characters WHERE char_id=$1 AND account_id=$2 FOR UPDATE",
                char_id, account_id)
            if character is None:
                raise LookupError(f"character {char_id} does not belong to account {account_id}")
            lower = 0 if target_level == 1 else role_exp[target_level - 1]
            upper = role_exp[target_level]
            if not (lower <= desired_exp < upper):
                raise AssertionError("computed EXP is not valid for target level")
            result = {"account_id": account_id, "char_id": char_id,
                      "before_level": character["level"], "before_exp": character["exp"],
                      "target_level": target_level, "target_exp": desired_exp,
                      "valid_exp_range": [lower, upper],
                      "dependent_tables": sorted({t for t, _ in dependencies})}
            if not apply or (character["level"] == target_level and character["exp"] == desired_exp):
                result["changed"] = False
                return result
            snapshot = await _snapshot(conn, character, dependencies, target_level, desired_exp)
            backup_path = _write_snapshot(snapshot, backup_dir)
            updated = await conn.fetchrow(
                "UPDATE public.characters SET level=$3, exp=$4 "
                "WHERE char_id=$1 AND account_id=$2 RETURNING level,exp",
                char_id, account_id, target_level, desired_exp)
            if updated is None or (updated["level"], updated["exp"]) != (target_level, desired_exp):
                raise RuntimeError("level update verification failed")
            result.update(changed=True, after_level=updated["level"], after_exp=updated["exp"],
                          backup=str(backup_path))
            return result
    finally:
        await conn.close()


async def rollback(*, dsn: str, backup_path: Path) -> dict[str, Any]:
    snapshot = json.loads(backup_path.read_text(encoding="utf-8"))
    char = snapshot["character"]
    conn = await asyncpg.connect(dsn)
    try:
        async with conn.transaction():
            await _target_schema(conn)
            current = await conn.fetchrow(
                "SELECT level,exp FROM public.characters WHERE char_id=$1 AND account_id=$2 FOR UPDATE",
                snapshot["char_id"], snapshot["account_id"])
            if current is None:
                raise LookupError("target character no longer exists")
            if current["level"] == char["level"] and current["exp"] == char["exp"]:
                return {"rolled_back": False, "reason": "already_at_backup_state"}
            if (current["level"], current["exp"]) != (
                    snapshot.get("target_level"), snapshot.get("target_exp")):
                raise RuntimeError("refusing rollback: character progressed after migration")
            restored = await conn.fetchrow(
                "UPDATE public.characters SET level=$3,exp=$4 "
                "WHERE char_id=$1 AND account_id=$2 RETURNING level,exp",
                snapshot["char_id"], snapshot["account_id"], char["level"], char["exp"])
            return {"rolled_back": True, "level": restored["level"], "exp": restored["exp"]}
    finally:
        await conn.close()


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--account-id", type=int, default=6)
    parser.add_argument("--char-id", type=int, default=2)
    parser.add_argument("--target-level", type=int, default=15)
    parser.add_argument("--apply", action="store_true", help="write after taking a durable JSON backup")
    parser.add_argument("--rollback", type=Path)
    parser.add_argument("--backup-dir", type=Path, default=BACKUP_DIR)
    parser.add_argument("--config", type=Path, default=DEFAULT_CONFIG)
    args = parser.parse_args()
    dsn = os.getenv("DATABASE_URL")
    if not dsn:
        parser.error("DATABASE_URL is required; it is never guessed")
    if args.rollback:
        result = asyncio.run(rollback(dsn=dsn, backup_path=args.rollback))
    else:
        result = asyncio.run(upgrade(dsn=dsn, account_id=args.account_id, char_id=args.char_id,
                                     target_level=args.target_level, apply=args.apply,
                                     backup_dir=args.backup_dir, config_path=args.config))
    print(json.dumps(result, ensure_ascii=False, indent=2, default=_json_default))


if __name__ == "__main__":
    main()
