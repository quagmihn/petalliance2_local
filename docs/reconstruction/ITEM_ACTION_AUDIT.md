# Item action audit

The target indexes 1,776 ItemInfo definitions and 1,091 rows with `bUse=1`. Generate the machine-readable matrix with `python tools/audit_pet_economy.py`. It records each item's type, name, description key, referenced ID and implemented outcomes or blocked reason.

| Bag action | Validated coverage |
| --- | --- |
| RewardInfo chests (type 18) | 136 of 251 have fully resolvable positive-weight outcome vectors. The other 115 are blocked with specific missing references or unsupported award kinds. |
| SelectableAwardInfo boxes (type 28) | 28 boxes, 230 valid choices. |
| Costume vouchers (type 22) | 291 defined wardrobe links. |
| Silver bags (type 10) | 5 quantities resolve to `goldCoin`. |
| Pet EXP (type 19) | 5 configured Pet potions. The remaining item has a separate target contract. |

The selectable box takes a zero-based row index and the configured reward amount. It spends one box. A drawing recipe (type 23) can have a numeric reference that overlaps a box ID. The regression suite confirms that such a recipe cannot produce a box reward. Bag chests now validate every weighted outcome before consuming the item. Their normalized weighted-alternative behavior is the established local model. Exact original odds or bundle semantics are unresolved where the source lacks authoritative server rules.

Android QA consumed chest 313 and received book 20121. Item 254 → ten fragments 38078, invalid choices and wrong item category passed PostgreSQL tests. Other material, stamina potion, equipment, mount and furniture effects remain pending. The original use-item packet has no request ID for deduplicating intentional repeated clicks.
