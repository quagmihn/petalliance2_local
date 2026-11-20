"""Validate the catalog entries served by the existing Market transaction."""
from functools import cache

from client_config import table


def validate_offers(products, items):
    enabled = {}
    for sku, offer in products.items():
        if offer["coinType"] not in (1, 2, 3) or (offer["buyMax"] and offer["marketType"] != 4):
            continue
        if offer["itemID"] not in items:
            raise ValueError(f"Market SKU {sku} references missing item {offer['itemID']}")
        if offer["num"] <= 0:
            raise ValueError(f"Market SKU {sku} requires a positive price")
        enabled[sku] = offer
    return enabled


@cache
def enabled_offers():
    return validate_offers(table("MarketInfo"), table("ItemInfo"))
