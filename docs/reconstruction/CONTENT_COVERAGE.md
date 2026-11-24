# Content coverage

| Scope | Discovered | Validated or supported | Acceptance still open |
| --- | ---: | --- | --- |
| Pet templates | 252 | 191 verified Fight starting loadouts, 3 Material, 58 missing configuration across all three snapshots | Full skill, evolution, equipment and appearance interactions remain partial. |
| Item templates | 1,776 | Catalog parsed and Market's 90 item links validated | Item usage and owned equipment lifecycle remain partial. |
| Character and Pet equipment | 5 and 39 | Definitions parsed | Runtime equipment workflows remain partial. |
| Appearances | 300 | 291 voucher links resolve. Prior acquisition, equip and relogin are verified. | Complete appearance and accessory workflow coverage. |
| Gacha | 17 pools, 27 awards | All award references resolve. Eight effective ordinary rows and a local Gold cap on Senior. | Broader eligible Pet awards and special sequence rules. |
| Shop | 90 Market SKUs, plus CommonShop, ActivityShop, FamilyShop and Adventure NPC families | 90 Market SKUs enabled | Unsupported shop mechanics and missing references. |
| Quest | 747 | 72 resolvable reward links and 308 no-reward rows | 367 reward links unresolved across 291 reward IDs. Some objective handlers remain partial. |
| Adventure | 290 | 275 exact authored grids. TCP and PostgreSQL passed consecutive synthetic clears for Adventures 1–3. | 15 placeholder maps, consecutive Android clears and full multi-floor verification. |

The existing reference JSON records 751 unresolved IDs across template
namespaces. This consists of 426 item, 33 Pet, 291 reward and one parent-quest
ID. Missing asset paths are tracked independently. Definition counts include
records whose gameplay remains unverified.

[Checkpoint and runtime evidence](EXECUTION_CHECKPOINT.md)
