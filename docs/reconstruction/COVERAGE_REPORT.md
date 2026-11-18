# Coverage report

Snapshot generated from the current local reconstruction source; statuses are scoped to evidence, not product completeness.

| Inventory | Discovered | Parsed/source indexed | Current backend route | Protocol tests | Waydroid evidence |
|---|---:|---:|---:|---|---|
| Protocol command constants | 1024 | 1024 | 54/374 client requests statically routed | 93-test suite, targeted paths only | Login/Town; wild 136/210, 263/186, capture 15/198; MarketInfo 577/563 |
| Client request definitions | 374 | serializers 374; ACK decoders 373; GameMgr callers 306 | 54 | Partial; see registry | No per-request complete acceptance |
| Quests | 747 | all quest rows parsed; 72 reference a currently resolvable RewardInfo using implemented reward types; 367 reference missing RewardInfo IDs; 308 have awardID=0 | Generic configured commit with atomic supported reward grants; event-18 node adapters cover 55 trainer, 30 wild, and 111 gift/collect objective references; other objective types remain partial | TCP/PostgreSQL reward, trainer, wild, and gift-node paths tested | Quest 10008 capture objective and commit verified on Waydroid; new reward/node paths remain Waydroid-pending |
| AdventureInfo | 290 | all rows parsed | Selected requests only | Partial | No full map clear/unlock acceptance |
| SceneInfo | 22486 | all rows parsed | event/battle subsets | Partial | One wild encounter |
| Battle groups | 907 | all rows parsed | small configured subset | selected trainer/wild/adventure contracts | one type-1 wild group start/end |
| Activity/Event catalogs | 1768 | catalog tables listed in EVENT_MATRIX | Sparse/unverified | None comprehensive | no claims verified |
| Recharge packages | 14 | 12 `NormalRechargeInfo` + 2 `MonthCardRechargeInfo` decoded using target Lua schemas | Local-only request 90 path: configured diamond grant, month-card days and `recharge_total`; external provider path rejected | PostgreSQL transaction + framed TCP, duplicate-order replay, gate-off, package catalog behavior | Client APK installed and cold login verified; BUY click not yet exercised |
| Extracted assets | 16049 | SHA256 for all registry rows | n/a | hash inventory | no broad asset compatibility testing |

Quest reward and map-node scopes were added after the original 87-test checkpoint. `RewardInfo` weighted alternatives are resolved from `RewardInfo`/`AwardElementInfo`; supported element types 1–5 map to gold, diamonds, items, character EXP, and configured Pets. Event-18 map objectives resolve against target `map_event.txt` and require the configured map/node lock. Type-0 trainers and type-1 wild encounters advance only after a server-issued battle win; type-2 gift nodes accept the original client progress request only for a configured unlocked node and persist an idempotent node claim. Missing reward references and unsupported reward kinds fail closed. Latest full suite: **96 PASS, 0 FAIL, 0 skipped** on `monster2_test_db`; run log `/tmp/monster2-full-suite-20261118.log`. Recent changes remain outside the official running process and are not yet Waydroid-verified.

Local recharge coverage is 14/14 configured package records parsed and supported by the simulation handler. The client routes purchase buttons to request 90 with an order key; the backend uses catalog IDs and commits a `simulated=true` ledger row with the wallet update before ACK 89. Database/TCP tests cover normal and month-card package application and duplicate retry. UI acceptance remains pending. First-recharge awards in `FirstRechargeAwardInfo` are intentionally not granted because their relationship to package IDs is not established by source evidence.

Reconnect diagnostics exposed duplicate quest-list and channel-change submissions on reconnect. The Lua callback-preserving dedupe fix is source/contract tested. The rebuilt APK was installed with app data preserved; a fresh cold login for account 6/char 2 reached MainScene, showed one ACK 26/386 callback registration each, cleared loading, and released the touch lock. No induced reconnect occurred during that run, and no same-session server log proves the old TCP close initiator, so reconnect recovery and the old close remain unverified.

## Status definitions

- `DISCOVERED`: source ID/path exists.
- `PARSED`: structure decoded with target format parser.
- `IMPLEMENTED`: server behavior exists for stated scope.
- `PROTOCOL_TESTED`: request, response/notifications, and persistence tested on TCP/PostgreSQL.
- `WAYDROID_VERIFIED`: visible client flow and resulting state observed on target APK.
- `BLOCKED`: explicit reproducible dependency or runtime gate prevents validation.
- `UNSUPPORTED`: no adequate source/config/protocol evidence or implementation.

Do not promote a row to Waydroid verified from ACK-only coverage.
