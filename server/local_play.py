"""Private-local access and storage policy. Gameplay requirements stay in their handlers."""
import os

from character_values import validate_character_values


def enabled(setting):
    return (os.getenv(setting) == "1"
            and os.getenv("MONSTER2_LAUNCH_PROFILE") in ("local", "test")
            and os.getenv("LOCAL_PAYMENT_SANDBOX") == "1"
            and os.getenv("PAYMENT_PROVIDER") == "local")


def freedom(values):
    return enabled("LOCAL_FREEDOM_MODE") and values.get("local_freedom") is True


def silver_override(row):
    """Project a client-safe balance for exactly the private profile's player."""
    if not enabled("LOCAL_UNLIMITED_SILVER"):
        return None
    identity = os.getenv("LOCAL_UNLIMITED_SILVER_PLAYER", "").split(":", 2)
    if len(identity) != 3 or not {"account_id", "char_id", "name"}.issubset(row.keys()):
        return None
    current = [str(row["account_id"]), str(row["char_id"]), row["name"]]
    return 999_999_999 if identity == current else None


def storage_limits(values):
    limits = validate_character_values(["petPacketNum", "itemPacketNum"], values)
    return (None if enabled("LOCAL_UNLIMITED_PET_STORAGE") else limits["petPacketNum"],
            None if enabled("LOCAL_UNLIMITED_ITEM_STORAGE") else limits["itemPacketNum"])
