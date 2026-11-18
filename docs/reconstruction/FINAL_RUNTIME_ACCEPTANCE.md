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

Screenshots and synchronized server logs are local evidence under `artifacts/pet-exp-feed-20261118/` and are deliberately not tracked in Git. Production data was not manually edited to create a test pass. Runtime encounter rows from normal Waydroid gameplay are present in `monster2_db`.

Cold relogin was completed after capture; Town and the quest continuation dialogue loaded. PostgreSQL retains Pet UID 3/template 26 and quest 10008 status 1/progress `[1]`. Continue the discovered quest/map graph; broader content remains incomplete.
