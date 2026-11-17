"""Export a read-only, explicit-target Pet migration and rollback artifact."""
from __future__ import annotations

import argparse
import asyncio
import json
import os
from pathlib import Path

from server.admin.migrate_legacy_pets import Database, _target_rows, _identity, plan_rows


async def main_async(args):
    dsn = os.environ.get(args.dsn_env)
    if not dsn:
        raise ValueError(f"required DSN environment variable {args.dsn_env} is unset")
    db = await Database.connect(dsn)
    try:
        identity = await _identity(db)
        if identity["database"] != args.database or identity["superuser"]:
            raise ValueError("database identity mismatch or superuser role; refusing export")
        rows = await _target_rows(db, args.account_id, args.char_id)
        plans = plan_rows(rows)
        data = {
            "purpose": "dry-run migration plan and guarded rollback source; no DB writes",
            "identity": {key: identity[key] for key in identity.keys()},
            "database": args.database,
            "account_id": args.account_id,
            "char_id": args.char_id,
            "plans": plans,
            "changed_fields": ["skills_json", "passive_skills_json"],
        }
        target = Path(args.output)
        target.parent.mkdir(parents=True, exist_ok=True)
        payload = json.dumps(data, ensure_ascii=False, sort_keys=True, indent=2, default=str).encode()
        fd = os.open(target, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
        with os.fdopen(fd, "wb") as out:
            out.write(payload)
            out.flush()
            os.fsync(out.fileno())
        print(json.dumps({"identity": data["identity"], "output": str(target),
                          "pet_uids": [p["pet_uid"] for p in plans],
                          "changed": [p["pet_uid"] for p in plans if p["changed"]]}, default=str))
    finally:
        await db.close()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--database", required=True)
    parser.add_argument("--dsn-env", required=True)
    parser.add_argument("--account-id", type=int, required=True)
    parser.add_argument("--char-id", type=int, required=True)
    parser.add_argument("--output", required=True)
    asyncio.run(main_async(parser.parse_args()))


if __name__ == "__main__":
    main()
