# Item template validation

| Source | Discovered | Validation scope |
| --- | ---: | --- |
| ItemInfo | 1,776 across 25 types | Stable, unique parsed IDs. 104 literal icon paths unresolved in the asset audit |
| EquipmentInfo | 5 | Character equipment definitions parsed |
| PetEquipInfo | 39 | Pet equipment templates parsed |
| FashionItemInfo | 300 | 291 voucher links resolve to valid appearances |
| FashionSuitEffectInfo | 10 | Set definitions parsed |
| PokemonBallInfo | 3 | Capture item definitions parsed |

Market's 90 item references resolve. The other audited purchase paths contain
426 distinct missing ItemInfo IDs across the target shop tables. Equipped
appearance is covered by prior Waydroid and PostgreSQL tests. Generic equipment
instance ownership, equip/unequip and item-type-specific effects remain partial.

The audited joins resolve 228 shop-to-item rows and 2,453
AwardElementInfo-to-item rows. The 2,681 valid links span 1,225 different
item IDs. This count covers those joins and excludes file reference and
localization checks.

[Existing item audit](ITEM_CATALOG.md) · [Appearance audit](FASHION_CATALOG.md)
