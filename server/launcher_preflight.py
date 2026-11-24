"""Validate the official runtime before either game listener is started."""

import asyncio
import hashlib
import ipaddress
import json
import os
from pathlib import Path

import asyncpg

from client_config import CONFIG, ROOT
from db.database import Database
from local_draw import catalog_report
from market_config import enabled_offers
from quest_config import load_quests


def digest(path):
    with path.open("rb") as source:
        return hashlib.file_digest(source, "sha256").hexdigest()


def report(label, values):
    print(f"{label}=" + json.dumps(values, sort_keys=True), flush=True)


def runtime_content():
    server_config = ROOT / "server/config"
    groups = {
        "pets": ("PokemonInfo.dat", "GeneInfo.dat", "GeneProbabilityInfo.dat", "PetSkillInfo.dat"),
        "items": ("ItemInfo.dat", "PetPieceInfo.dat", "RewardInfo.dat", "AwardElementInfo.dat"),
        "market": ("MarketInfo.dat", "ShopInfo.dat", "ShopPoolInfo.dat"),
        "maps": ("AdventureInfo.dat", "SceneInfo.dat", "FloorRelationInfo.dat", "DisposableInfo.dat",
                 "MonstrosityInfo.dat", "MonsterGroupManInfo.dat", "map_event.txt", "map_node.txt"),
        "events": ("ActivityInfoClient.dat", "SevenDayInfo.dat", "FirstRechargeAwardInfo.dat",
                   "RewardInfo.dat", "NormalRechargeInfo.dat", "MonthCardRechargeInfo.dat"),
        "quests": ("NewQuestInfo.dat", "story.txt"),
    }
    resolved = {}
    for group, names in groups.items():
        entries = {}
        for name in names:
            path = CONFIG / name
            if name == "NewQuestInfo.dat":
                path = Path(os.getenv("NEW_QUEST_INFO_PATH") or path).resolve()
            entries[str(path)] = digest(path)
        resolved[group] = entries
    if os.environ["MONSTER2_LAUNCH_PROFILE"] == "local":
        profile = {str(path): digest(path) for path in (server_config / "local-play.env",)}
        resolved["launcher"] = profile
    return resolved


def payment_mode():
    if os.environ.get("LOCAL_PAYMENT_SANDBOX") != "1":
        return "disabled"
    if os.environ["MONSTER2_LAUNCH_PROFILE"] != "local" or os.getenv("PAYMENT_PROVIDER") != "local":
        raise SystemExit("Simulated checkout requires the private local launcher profile.")
    for key in ("GAME_BIND", "HTTP_BIND"):
        # The shipped Waydroid bridge and loopback are the only allowed
        # endpoints for this install's simulated checkout.
        address = ipaddress.ip_address(os.environ[key])
        if not (address.is_loopback or str(address) == "192.168.240.1"):
            raise SystemExit(f"Simulated checkout requires a private Waydroid or loopback {key}.")
    return "local-simulated"


async def check_database():
    db = await Database.connect()
    try:
        row = await db.pool.fetchrow("SELECT current_database() AS database, current_user AS role")
        report("postgresql", dict(row))
    finally:
        await db.close()


def main():
    payment = payment_mode()
    path = os.environ["MONSTER2_DRAW_CATALOG"]
    try:
        report("gacha_catalog", catalog_report(path))
    except (OSError, ValueError, KeyError, TypeError) as exc:
        raise SystemExit(f"Invalid Gacha catalog {path!r}: {exc}. Correct MONSTER2_DRAW_CATALOG before starting.") from None
    try:
        report("market_catalog", {"enabled_offers": len(enabled_offers())})
        report("content_catalogs", runtime_content())
        load_quests()
        client = json.loads((ROOT / "server/config/runtime_client.json").read_text())
        apk = ROOT / client["artifact"]
        client["status"] = ("missing" if not apk.is_file()
                            else "matches" if digest(apk) == client["sha256"] else "sha256-mismatch")
        report("android_client", client)
        report("payment", {"mode": payment})
    except (OSError, ValueError, KeyError, TypeError) as exc:
        raise SystemExit(f"Invalid runtime content: {exc}") from None
    try:
        asyncio.run(check_database())
    except FileNotFoundError:
        raise SystemExit(
            "Database preflight failed: PostgreSQL Unix socket is missing. "
            "Check the local PostgreSQL instance and configured socket directory and port.") from None
    except asyncpg.PostgresError as exc:
        raise SystemExit(f"Database preflight failed ({type(exc).__name__}). "
                         "Check the role, database and local authentication.") from None
    except (OSError, RuntimeError, TimeoutError) as exc:
        raise SystemExit(f"Database preflight failed ({type(exc).__name__}). "
                         "Check PostgreSQL availability and the database selected for this profile.") from None


if __name__ == "__main__":
    main()
