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


def storage_limits(values):
    limits = validate_character_values(["petPacketNum", "itemPacketNum"], values)
    return (None if enabled("LOCAL_UNLIMITED_PET_STORAGE") else limits["petPacketNum"],
            None if enabled("LOCAL_UNLIMITED_ITEM_STORAGE") else limits["itemPacketNum"])
