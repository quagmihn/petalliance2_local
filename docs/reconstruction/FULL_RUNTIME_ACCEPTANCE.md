# Full runtime acceptance checkpoint

## Deployment and verification update

- **Restore verified.** Connected as the PostgreSQL database administrator over the Unix socket solely to create `monster2_restore_purchase_1217ccbe`. Restored as `monster2`, exit 0, using a single transaction and no ownership or ACL replay. All 13 table data sets matched the archived COPY records. The restore contains 2 accounts, 2 characters, 3 pets, 17 quests and 2 inventory rows. PostgreSQL reports all constraints validated, including 13 foreign keys. Archive SHA256 `1217ccbe66d808ad03ae6be075720d39b36be4cd178856acfe8714631b2bfbfd`. Production role privileges and pg_hba were preserved.
- **Deployed.** Started the project launcher in production mode on free ports. Both pools verified `monster2_db` / `monster2`. Launcher schema initialization added `local_recharge_transactions` and `local_month_cards`. The user unit `monster2-local-purchase.service` supplies `LOCAL_PAYMENT_SANDBOX=1` and `PAYMENT_PROVIDER=local`. No external provider or real checkout was used.
- **WAYDROID_VERIFIED.** Installed APK SHA256 `364d275f98101e548758bc7b46ce775b7c9d0f13f830a574d24d2a2df5134e76`. After server restart, cold login returned character 2 on the Secret Path world node and showed the existing 2/10 map-star total. This is persisted progress evidence, not a new map clear.
- **BLOCKED.** The mandatory guide intercepted world-map and currency taps. Following Senior Gacha → ONCE FREE sent 1392 → 1561/code 1 (`award_pool_catalog_unavailable`). Close and diamond controls did not respond after the rejection. Restart and cold login returned to the guide. No UI request 90 or 3102 was observed and both production payment tables still had zero rows. Wallet rows matched before and after. Map-entry/clear and checkout acceptance remain open.
- **TCP_TESTED / PostgreSQL integration.** The 99-test suite passed on `monster2_test_db`. Coverage includes request 90, idempotent delivery, M-PASS initial diamonds and renewal, the 3102/3103 daily claim schema, all-or-nothing balance updates, duplicate claim, wrong package and expired entitlement. The new claim handler is tested via server dispatch functions; an actual Waydroid claim remains blocked.

Local evidence is in `artifacts/secret-path-runtime-20261118/`, including `senior-gacha-blocked.png`, `secret-path-relogin-guide.png`, paired TCP and logcat, and before/after wallet rows. The earlier checkpoint below records the pre-deployment state.

Date: 2026-11-18. This is a blocked deployment and partial source audit, not a complete gameplay acceptance.

## Identity and deployment

| Item | Result |
|---|---|
| Workspace Git commit | `bf04c8417f25171a53d55f806b760b0ec5d46601` |
| Live official launcher / PIDs | `./run_all.sh production`; launcher 99789, HTTP 99835, TCP 99836 |
| Live database identity | `monster2_db`, role `monster2`, Unix socket |
| Source loaded by live process | Older than current workspace; process began 15:26, before `29ebf1b` at 16:45 |
| Installed client | `com.petalliance2.sea`, version 7, signature preserved; installed APK SHA256 `364d275f98101e548758bc7b46ce775b7c9d0f13f830a574d24d2a2df5134e76` |
| Waydroid | Session/container RUNNING; client PID 60298 at check |
| Sandbox mode | `LOCAL_PAYMENT_SANDBOX` unset in both live processes; default disabled |
| Production recharge schema | `local_recharge_transactions` absent |

## Backup and restore check

A new custom-format dump was written to `artifacts/secret-path-runtime-20261118/monster2_db-precheck.dump`, size 34,773 bytes, SHA256 `1217ccbe66d808ad03ae6be075720d39b36be4cd178856acfe8714631b2bfbfd`. `pg_restore -l` parsed its archive and listed 99 lines. Full restore validation is **BLOCKED**: the production role has `CREATEDB=false`, and isolated `CREATE DATABASE monster2_restore_verify_20261118` returned permission denied. No restore was attempted against or over `monster2_test_db`; production was not modified.

## Map identity

LOST FOREST is world 1 point 2 → Adventure 1 (`fbname1`). SECRET PATH is point 10 → Adventure 2 (`fbname2`). Both original AdventureInfo rows use scene number 1 and the same 30 SceneInfo rows, floor dimensions 5×6 and environment 1. Their prepose, objectives, EXP and reward references are distinct. The current server source preserves the requested Adventure ID; no remapping was found. Source/config identity regression tests pass. Visual Waydroid comparison and per-map persistence after relogin are **BLOCKED** because safely updating the official server is gated on restore verification.

## Recharge and shops

The current client APK contains the local purchase path, but the live TCP process is older than that code, sandbox is disabled, and production schema is missing. The actual PURCHASE click was not run. M-PASS daily claims remain unimplemented. Market purchase had prior Waydroid evidence for a single product on an older verified milestone; other shop families are incomplete.

## Tests

- Full source suite against explicit `TEST_DATABASE_URL=postgresql:///monster2_test_db`: **99 PASS, 0 FAIL, 0 skipped**.
- Added map identity contracts: distinct world nodes, original shared scene template, requested Adventure ID preserved in response/state.
- Waydroid actual map and recharge flows: **BLOCKED**, not PASS.

## Safe next action

Obtain a PostgreSQL operator path capable of restoring the dump into a newly created isolated database, then verify counts/schema. After that, plan an additive production migration, explicitly enable local-only payment, restart only the recorded official launcher, and test PURCHASE/M-PASS and map visuals through the installed client. No such privilege or restore step was available in this checkpoint.
