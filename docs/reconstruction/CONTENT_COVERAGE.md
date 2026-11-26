# Content coverage

## 2026-11-26 · Private freedom and expanded economy

| Mechanism | Established coverage | Acceptance |
| --- | --- | --- |
| Pet initialization | 191 Fight templates and 3 material templates have valid starting skill groups. 189 Fight templates also meet the target asset checks. | Senior and Supreme x10 persisted new Pets on QA. |
| Ordinary Gacha | 79 Senior Pet templates, 148 Supreme Pet templates, 172 wearable vouchers, 384 books, and 793 total weighted rows across 3 machines. | QA exercised all 3 machines. The final Supreme pool produced Thanamon in Waydroid. |
| Bag | 1,091 use-enabled entries audited. 136 complete chest vectors, 28 selectable boxes, 5 Silver Bags, 291 voucher links, and 5 Pet potions. | Android chest and wardrobe use, PostgreSQL selectable choices and misclassified recipe rejection. |
| Seven-Day | 31 of 111 rows, including all 7 daily gifts and all 7 diamond offers. | Day 1 free and paid claims on Android. Scripted clock and objective claims verified in PostgreSQL. |
| Local recharge | 12 legal original normal SKU variants and 2 entitlement SKUs in the existing transaction engine. | Actual N7 first purchase and two N13 repeat purchases. |
| Storage | Removable local slot caps, safe stack width and bounded Pet pages. | 500 Pets and 516 item IDs on Android, with 40/100/250/500 wire tests. |

See [checkpoint](EXECUTION_CHECKPOINT.md) and [remaining work](IMPLEMENTATION_BACKLOG.md).

## 2026-11-26 Pet and economy acceptance

| Area | Evidence |
| --- | --- |
| Pet | 191 valid Fight loadouts and 3 material loadouts. The configured Star-up engine accepted five rounds through Waydroid and persisted the same owned Pet UID. |
| Skills | 3,730 definitions, 384 linked books and 2,360 validated configuration edges. Existing Android active learning and upgrade evidence remains narrower. |
| VIP | All 21 privilege drop sets resolve. VIP 20 display, claim and cold relogin passed on QA. |
| VIP Shop | Private limit override tested above the original cap on Android. Regular shop and eligibility rules remain enforced. |
| Arena | 157 catalog candidates across nine slot positions and working PostgreSQL checkout. Original Arena combat lobby and points earning are blocked. |
| Recharge | 12 normal SKU variants and two entitlement SKUs tested in PostgreSQL. Four SKU purchases, daily awards and retention passed on Android. |

[Latest runtime checkpoint](EXECUTION_CHECKPOINT.md) · [Detailed content matrix](PET_CONTENT_COVERAGE.md)

## 2026-11-25 runtime additions

| Family | Coverage |
| --- | --- |
| Adventure monsters | Packaged static and disposable battle IDs resolve through the active floor. Wise Arena cell 111 fought and returned to the loaded floor on Waydroid. |
| World-map capture | Ball checks, capture attempts, Pet creation and success replay are PostgreSQL/TCP tested. The Wise Arena cell has zero capture attempts. |
| Gacha | Three enabled pools, 24 resolved reward entries, original IDs and explicit local weight vectors, with the separate scripted Panda guarantee. |
| Item actions | Silver bags, configured reward chests and Pet-fragment synthesis are PostgreSQL tested. The medium Silver Bag was used from the Waydroid Bag. |
| Skills | Original ordinary, element, profound and passive books in the Skill pool. Ownership, replacement and upgrade are PostgreSQL tested. |
| Events | First local recharge mail and login gifts use the packaged reward IDs. Waydroid claimed the first recharge award and the first daily gift. Other Seven-Day task types remain open. |

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
