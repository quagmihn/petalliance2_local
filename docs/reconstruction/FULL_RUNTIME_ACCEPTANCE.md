# Full runtime acceptance checkpoint

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
