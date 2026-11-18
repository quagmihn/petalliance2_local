# Final runtime acceptance checkpoint

Date: 2026-11-18. This records a partial verified checkpoint; it is not a release-complete report.

Verified source commit: `144d757` (`Fix Waydroid wild capture and market state sync`). Push is blocked because GitHub HTTPS credentials are unavailable in this session.

| Check | Result | Evidence |
|---|---|---|
| Baseline source | PASS | tag `baseline-partial-verified-2026-11-18`, commit `947a052d59663a70b28821b28d3983e1ed83951e` |
| Installed patched APK | PASS | Package v7/signature compatible; SHA256 `362d724207e8b1da7fe55f8f86e0672f195e9f6b6388d2c7119e56fa1d677448` |
| Official server | PASS | `server/run_all.sh production`, source tree, HTTP 8080 and TCP 5568, database `monster2_db`, role `monster2` |
| PostgreSQL/TCP suite | PASS | 87 tests, separate `monster2_test_db`; no skips |
| Login/Town | PASS | Existing Waydroid account 6 / char 2 relogin screenshot/log in `artifacts/pet-exp-feed-20261118/` |
| Wild battle | PASS | Request 136/ACK 210 code 0; battle end 263/ACK 186 code 0, 8 EXP; capture UI reached |
| Inventory capacity | CODE/TEST PASS, WAYDROID RETEST PENDING | Missing `itemPacketNum` previously defaulted to 0 and overrode client config 70; response now derives configured 70/40/10. Contract tests verify defaults and preserve purchased capacity |
| MarketInfo purchase | PASS | Waydroid request 577; ACK 563 code 0; 600 diamonds deducted, item 1 granted; wallet notification reflects committed balance |
| Capture | PASS | Waydroid request 15 sent `pokemonID=26,itemID=1`; ACK 198 success/caught; item consumed; Pet UID 3/template 26 persisted; screenshot `waydroid-capture-success.png` |
| Quest 10008 | PASS | Capture set progress `[1]`; CommitQuest 400→726 code 0 plus 404 notification; PostgreSQL status 1/progress `[1]` |
| Quest/map continuation | PARTIAL | Capture objective/commit verified; broader next quest/map flow not yet validated |
| Pet EXP live UI | BLOCKED | TCP/DB tests pass; no Waydroid feed performed |
| Events/recharge | BLOCKED/INCOMPLETE | no live event reward or local simulated recharge completion |
| Production backup | PARTIAL | PostgreSQL archives and SHA256/TOC validation pass; isolated restore could not be run because current role lacks CREATEDB and `sudo -n -u postgres` requires password |
| Push | BLOCKED | `git push origin main` failed because GitHub HTTPS credential helper has no interactive username source |
| Configured quest rewards | CODE + PostgreSQL/TCP PASS; PLAY RUNTIME PENDING | RewardInfo-backed atomic gold/diamond/item/EXP/Pet grants, claim idempotency, and pre-ACK notifications tested in the 93-test suite on `monster2_test_db`; not deployed to the play server and not yet exercised through Waydroid |
| World-map event-18 trainer nodes | PROTOCOL + PostgreSQL/TCP PASS; WAYDROID PENDING | 55 configured objective references across 53 groups; target `map_event.txt` type-0 group resolution and `map_node.txt` unlock validation; one full battle/update/commit integration fixture |
| World-map event-18 wild nodes | PROTOCOL + PostgreSQL/TCP PASS; WAYDROID PENDING | 30 objective references; event type 1 resolves configured MonstrosityInfo, requires unlocked node and active quest, and advances only on won type-1 battle |
| World-map event-18 gift/collect nodes | PROTOCOL + PostgreSQL/TCP PASS; WAYDROID PENDING | 111 objective references; event type 2 follows client `result=998` then request 3133, validates node unlock, and stores an idempotent node claim |

Screenshots and synchronized server logs are local evidence under `artifacts/pet-exp-feed-20261118/` and are deliberately not tracked in Git. Production data was not manually edited to create a test pass. Runtime encounter rows from normal Waydroid gameplay are present in `monster2_db`.

Cold relogin was completed after capture; Town and the quest continuation dialogue loaded. PostgreSQL retains Pet UID 3/template 26 and quest 10008 status 1/progress `[1]`. Continue the discovered quest/map graph; broader content remains incomplete.

## 2026-11-18 implementation follow-up (not yet runtime accepted)

| Check | Result | Evidence |
|---|---|---|
| Local recharge catalog | PASS: 14 parsed | Target Lua config schemas decode 12 normal and 2 month-card offers; rewards follow `PayConfig.genRechargeInfoTable` |
| Recharge transaction/TCP | PASS | `monster2_test_db`; request 90 emits committed wallet notification 473 then ACK 89; duplicate key does not duplicate grant; month-card 10001 stores 30 days and 400 initial diamonds |
| Recharge safety gate | PASS | Default disabled; explicit `LOCAL_PAYMENT_SANDBOX=1`; configured nonlocal provider rejected |
| Reconnect callback duplication | CODE + LUA TEST PASS | Pending quest/channel replay checks prevent automatic second request and callback replacement; 96-test suite includes regression |
| Latest test suite | PASS | 96 tests, no failures/skips, `monster2_test_db`, `/tmp/monster2-full-suite-20261118.log` |
| Local recharge APK | BUILD/PACKAGE PASS; WAYDROID PENDING | `dist/monster2_local-recharge.apk`, SHA256 `364d275f98101e548758bc7b46ce775b7c9d0f13f830a574d24d2a2df5134e76`; built from `dist/monster2_restoration.apk` (installed-baseline SHA256 `362d724207e8b1da7fe55f8f86e0672f195e9f6b6388d2c7119e56fa1d677448`); patched encrypted Lua matched source and signature matches installed cert. Do not call runtime accepted until actual BUY click is exercised. |
| Production database/server | UNCHANGED | No production schema write, server restart, or recharge grant in this follow-up |
| TCP close/root cause | BLOCKED | Client logs show close/reconnect after ACK completion, but there is no synchronized server log for that same connection. Duplicate callback ownership is fixed; transport close initiator remains unproven. |

See [FULL_GAMEPLAY_IMPLEMENTATION.md](FULL_GAMEPLAY_IMPLEMENTATION.md) for the scope, exact limitations, and next executable steps.
