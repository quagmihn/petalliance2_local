# Coverage report

## 2026-11-24 runtime update

The unseeded character completed both scripted draws, deployed Panda,
continued the authored story, and cleared Wise Arena through two floors
with two crowns. Ordinary free, x1 and x10 draws were also repeated on the
current release using the independent QA character. Town Market recovered
from its loading screen and a configured Mall purchase persisted through
cold login. See the
[execution checkpoint](EXECUTION_CHECKPOINT.md) for evidence and limits.

## 2026-11-22 content and runtime checkpoint

The current content export and unresolved links are documented in the
[content reference matrix](CONTENT_REFERENCE_MATRIX.md). The runtime evidence
below is scoped to the interaction and fixture listed.

| Scope | DISCOVERED / PARSED | REFERENCES_VALID / IMPLEMENTED | Acceptance |
| --- | --- | --- | --- |
| Pets | 252 | 191 usable Fight loadouts, 3 Material; 58 lack an authored basic attack | DATABASE_TESTED for configured acquisition, feeding, Stage, battle EXP and formation. WAYDROID_VERIFIED for the starter, the separate Panda checkpoint and representative progression. |
| Items | 1,776 | 25 types; 104 unresolved literal icon paths | WAYDROID_VERIFIED for an Adventure EXP potion received, used and restored through Pet state on cold login. Split stacks, general equipment and remaining uses are open. |
| Equipment and Fashion | 5 character equipment records, 39 Pet equipment templates, 300 appearances, 291 vouchers | All 291 vouchers resolve; instance acquisition and loadouts remain partial | WAYDROID_VERIFIED for Silver Helmet voucher redemption, equip and cold relogin. Equipment instance workflows remain BLOCKED on protocol and source coverage. |
| Gacha | 3 machines, 17 linked target pools, 27 target entries | Eight enabled ordinary rows after the local Senior rarity cap; all original target awards resolve | The scripted free Panda was WAYDROID_VERIFIED in isolation. Paid modes were verified before the cap change. The cap and live startup validation are DATABASE_TESTED. Original wish and sequence rules remain open. |
| Shops | 90 Market, 567 CommonShop, 7 Activity, 50 Family offers | All 90 enabled Market references resolve; 493 CommonShop and 62 Adventure NPC offer rows have missing references | DATABASE_TESTED for atomic Market purchasing and cap checks. Prior Waydroid evidence covers capture-ball checkout, local recharge and M-PASS. |
| Quests | 747 | 72 resolvable rewards, 308 no-award rows, 367 unresolved reward links, one missing parent | DATABASE_TESTED for supported objective adapters and transaction guards. The fresh Waydroid sequence verifies the first Adventure, its quest claim and guided training. |
| Adventures / battles | 290 Adventures, 22,486 authored cells, 907 trainer groups | 275 exact grids, 15 placeholder layouts fail entry | WAYDROID_VERIFIED for authored Lost Forest and Secret Path portal clears across QA cases. Multi-floor progression and all encounter variants remain open. |
| Events | 43 activities, 31 sign-ins, 182 stationary awards | References exported for review | Config parsed. Broad eligibility, claims and runtime verification remain open. |

The official source and current APK are recorded in the
[execution checkpoint](EXECUTION_CHECKPOINT.md). Earlier results follow.

## 2026-11-20 · Content integrity

| Scope | Tested or evidenced | Open |
| --- | --- | --- |
| Guided draw and formation | PostgreSQL and framed TCP prove Adventure victories and stale counters cannot complete 10010 or 10011. Current Waydroid cold login restores the QA profile with the prior staged guide award. | Fresh sequential Android path from character creation to 10010. |
| Ordinary Gacha | Three active machines and nine normal award entries resolve at launch. Existing target audit resolved 17 linked pools and 27 source entries. Prior Waydroid evidence covers staged free/x1/x10. | Original sequence precedence, counters, Wish, Dream and membership modifiers. |
| Items, Pets and fashion | Existing audit parsed 1,776 items, 252 Pet templates, 3,730 skill rows, 88 evolution rows and 300 appearances. Prior Android evidence covers voucher and equip/relogin. | Equipment-instance lifecycle, unsupported item operations and broader inventory/fashion paths. |
| Shop | All 90 enabled Market offers share a startup and request-time reference/pricing check. Current Waydroid STORE opens and preserves the VIP purchase gate. | Eligible BUY on current deployment remains pending. The OrderMan purchase references missing Market SKU 203. |
| Lost Forest and Secret Path | Distinct Adventure IDs 1 and 2 share source scene 1, with separate goals, rewards and progression. Lost Forest reached its NPC and encounter on the prior Android run. | Both full clears, independent progress/cold login and floor transitions where configured. |
| Quest dependencies | 747 parsed rows in the existing graph. 367 reward links are unresolved across 291 IDs. | Resolve dangling references and remaining objective types before enabling affected content. |

See [content reference audit](CONTENT_REFERENCE_MATRIX.md) and
[current runtime evidence](EXECUTION_CHECKPOINT.md) for the source snapshots
and limits. Historical results below refer to their own launch and catalog
snapshots.

The opt-in draw adapter decodes three machine configurations and audits 17
original pool references. A separate local catalog passed free, x1 and x10
trials through the official test launcher with a disposable fixture. Committed
inventory was verified after a cold TCP relogin. Shared absolute inventory
updates are used by draws, market purchases, quest rewards and inventory
reads. This increases protocol and database coverage. Android gameplay
acceptance and the original server's sequence rules remain open.

## Draw rejection and isolated QA

The full suite passed 103 tests with real PostgreSQL. Coverage gained a targeted Lua guide recovery check, a framed TCP draw rejection with a database state comparison, and three fixture tests. The draw reward engine and Android acceptance coverage did not increase. See [GAMEPLAY_ACCEPTANCE.md](GAMEPLAY_ACCEPTANCE.md).

## Deployment update

Restore verification passed and the existing local recharge handler is live on monster2_db. M-PASS package entitlements and daily claims now pass PostgreSQL integration. Waydroid confirmed cold relogin to the existing map state, but the mandatory Senior Gacha guide blocked STORE and fresh map entries. These flows remain **BLOCKED** in real-client acceptance. See [full runtime acceptance](FULL_RUNTIME_ACCEPTANCE.md).

## 2026-11-18 map identity and runtime deployment audit

| Scope | Result | Evidence / limit |
|---|---|---|
| LOST FOREST identity | Config verified | World 1 point 2 / `map2` → Adventure 1, `fbname1`, scene 1, 30 cells, 5×6, field 1 |
| SECRET PATH identity | Config verified | World 1 point 10 / `map5` → Adventure 2, `fbname2`, scene 1, same 30 cells/5×6/field 1; distinct goals, prerequisite, level and clear reward |
| Server map-ID preservation | Protocol tested | Added test dispatches Adventure 1 then 2 and asserts each ACK and JSON state retain the requested Adventure ID |
| Secret Path visual on Waydroid | BLOCKED | Current official process is pre-implementation; safe deployment waits on isolated backup restore validation |
| Local recharge click | BLOCKED | APK contains local path, but live server is pre-implementation, sandbox unset/off, production schema absent |
| M-PASS daily claim | UNSUPPORTED | Request 3102/ACK 3103 exists; claim lifecycle is not implemented |
| Latest full suite | PASS | 99 PASS, 0 FAIL, 0 skipped using `TEST_DATABASE_URL=postgresql:///monster2_test_db` |
| Production backup restore | BLOCKED | Dump archive validates; role `monster2` cannot create an isolated DB (`CREATEDB=false`) |

See `GAME_MODE_REGISTRY.md`, `MAP_IDENTITY_MATRIX.md`, `MAP_ASSET_COMPATIBILITY.md`, `PURCHASE_FLOW_MATRIX.md`, and `FULL_RUNTIME_ACCEPTANCE.md` for detailed evidence. No map or purchase is promoted to Android verified based on source or ACK tests.

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

Local recharge coverage is 14/14 configured package records parsed and supported by the simulation handler. The client routes purchase buttons to request 90 with an order key; the backend uses catalog IDs and commits a `simulated=true` ledger row with the wallet update before ACK 89. Database/TCP tests cover normal and month-card package application and duplicate retry. UI acceptance remains pending. Production has not been migrated and the running server predates this code. First-recharge awards in `FirstRechargeAwardInfo` are intentionally not granted because their relationship to package IDs is not established by source evidence.

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
