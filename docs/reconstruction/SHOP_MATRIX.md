# Shop and recharge matrix

Catalogs are distinct systems with different currencies, stock, refresh, limits, and grant semantics. Never route an item through a different catalog based only on matching item ID.

| Table | Rows | Parsing/implementation status |
| --- | --- | --- |
| ShopInfo | 5 | MarketInfo unlimited catalog purchase subset tested; all other catalogs need independent protocol and limits |
| ShopPoolInfo | 55 | MarketInfo unlimited catalog purchase subset tested; all other catalogs need independent protocol and limits |
| ShopReflashInfo | 3 | MarketInfo unlimited catalog purchase subset tested; all other catalogs need independent protocol and limits |
| MarketInfo | 90 | MarketInfo unlimited catalog purchase subset tested; all other catalogs need independent protocol and limits |
| ActivityShopInfo | 7 | MarketInfo unlimited catalog purchase subset tested; all other catalogs need independent protocol and limits |
| FamilyShopInfo | 50 | MarketInfo unlimited catalog purchase subset tested; all other catalogs need independent protocol and limits |
| NormalRechargeInfoIos | PARSER_BLOCKED | MarketInfo unlimited catalog purchase subset tested; all other catalogs need independent protocol and limits |
| MonthCardRechargeInfoIos | PARSER_BLOCKED | MarketInfo unlimited catalog purchase subset tested; all other catalogs need independent protocol and limits |

MarketInfo entry 201 used by the target capture UI maps to Master Ball item 1 for 600 diamonds and has no configured buy limit. Handler transaction tests pass. Waydroid purchase was stopped client-side by `BAG IS FULL`; no purchase request/reward was observed. Recharge receipt/package tables have parser gaps and no local simulated checkout implementation. Real payment providers are not contacted.
