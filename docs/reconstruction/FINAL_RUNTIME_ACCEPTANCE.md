# Final runtime acceptance checkpoint

Date: 2026-11-18. This records a partial verified checkpoint; it is not a release-complete report.

| Check | Result | Evidence |
|---|---|---|
| Baseline source | PASS | tag `baseline-partial-verified-2026-11-18`, commit `947a052d59663a70b28821b28d3983e1ed83951e` |
| Baseline APK | PASS | Installed APK SHA256 equals `b24ea2d5239d61e15c47574df37a74c12dccac5440e14cd549c7939f0f0f6fcf` |
| Official server | PASS | `server/run_all.sh production`, source tree, HTTP 8080 and TCP 5568, database `monster2_db`, role `monster2` |
| PostgreSQL/TCP suite | PASS | 79 tests after capacity-default fix, separate `monster2_test_db`; no skips |
| Login/Town | PASS | Existing Waydroid account 6 / char 2 relogin screenshot/log in `artifacts/pet-exp-feed-20261118/` |
| Wild battle | PASS | Request 136/ACK 210 code 0; battle end 263/ACK 186 code 0, 8 EXP; capture UI reached |
| Inventory capacity | CODE/TEST PASS, WAYDROID RETEST PENDING | Missing `itemPacketNum` previously defaulted to 0 and overrode client config 70; response now derives configured 70/40/10. Contract tests verify defaults and preserve purchased capacity |
| Capture | BLOCKED | All ball stacks were zero; Master Ball button reported BAG IS FULL before request 577. Capacity default fix now awaits Waydroid relogin/runtime confirmation |
| Quest/map completion | BLOCKED | No capture request, so quest objective/map transition not completed |
| Pet EXP live UI | BLOCKED | TCP/DB tests pass; no Waydroid feed performed |
| Events/shop/recharge | BLOCKED/INCOMPLETE | no live reward/purchase/recharge completion |
| Production backup | PARTIAL | PostgreSQL archives and SHA256/TOC validation pass; isolated restore could not be run because current role lacks CREATEDB and `sudo -n -u postgres` requires password |
| Push | BLOCKED | `git push origin main` failed because GitHub HTTPS credential helper has no interactive username source |

Screenshots and synchronized server logs are local evidence under `artifacts/pet-exp-feed-20261118/` and are deliberately not tracked in Git. Production data was not manually edited to create a test pass. Runtime encounter rows from normal Waydroid gameplay are present in `monster2_db`.

Next check after capacity default commit: restart only the official launcher, cold relogin, inspect `GET_CHARACTER_VALUES_ACK` for itemPacketNum=70/petPacketNum=40, then repeat the real UI add/capture path.
