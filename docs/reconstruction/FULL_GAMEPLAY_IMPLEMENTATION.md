# Full gameplay implementation checkpoint

## 2026-11-18 follow-up: map identity and deployment gate

The target data audit establishes the precise Lost Forest / Secret Path mapping in `reconstruction/MAP_IDENTITY_MATRIX.md`. World map node 2 (`map2`, LOST FOREST) selects Adventure 1. Node 10 (`map5`, SECRET PATH) selects Adventure 2. Both target AdventureInfo records reference `scene=[1]`, yielding the exact same 30 SceneInfo rows, 5×6 grid, and environment code 1. Their goals (1–3 vs 4–6), prepose (0 vs 1), levels (1 vs 2), EXP (60 vs 62), and clear rewards (1 vs 4) remain distinct. The shared inner layout is in the target config itself; no alternate Secret Path SceneInfo reference was found. Server request 2996 preserves `advID`, and new tests cover ID and state separation. This is source/configuration evidence; no claim is made that this layout was Waydroid visually accepted as Secret Path.

The newly installed APK was pulled back from Waydroid and its SHA256 matches `364d275f98101e548758bc7b46ce775b7c9d0f13f830a574d24d2a2df5134e76`. Official processes 99835/99836 use `monster2_db`/`monster2`, but started before local recharge commit `29ebf1b`. In both processes `LOCAL_PAYMENT_SANDBOX` is unset; the default is off. Production does not have `local_recharge_transactions`.

A fresh backup is `artifacts/secret-path-runtime-20261118/monster2_db-precheck.dump` (SHA256 `1217ccbe66d808ad03ae6be075720d39b36be4cd178856acfe8714631b2bfbfd`; `pg_restore -l` succeeds). Restore verification into an isolated DB is blocked because role `monster2` has `CREATEDB=false`; create returned permission denied. Production was not migrated or restarted. Consequently the Waydroid PURCHASE click, M-PASS entitlement/daily claim, and visual Secret Path comparison remain unverified.

Added `server/tests/test_map_identity_contract.py`. The full suite with `TEST_DATABASE_URL=postgresql:///monster2_test_db` is 99 PASS, 0 FAIL, 0 skipped. Detailed deployment status is in `reconstruction/FULL_RUNTIME_ACCEPTANCE.md`; the remaining sequence is in `reconstruction/IMPLEMENTATION_BACKLOG.md`.

Date: 2026-11-18. This is a partial implementation checkpoint, not a claim that the target APK has been fully restored.

## Implemented in this checkpoint

### Reconnect and loading callbacks

Older client logs showed a reconnect replay path sending a pending quest-list request and then unconditionally sending another quest-list request from `NetInterface.resend()`. `Reconnector.finish()` could also reissue a channel join already being replayed. Lua diagnostics showed callback registrations for ACK 26 and 386 being replaced. `NetInterface.hasPending()` now guards those automatic requests, and `resend()` snapshots the pending cache before replay. This keeps one callback owner for each in-flight ACK and retains its normal success/error cleanup.

After installing the rebuilt APK with `adb install -r` (app data preserved), Waydroid cold login for account 6/character 2 reached MainScene. In the same client PID, quest-list request 785 had one registration (`ack 26 replaced=false`), change-channel request 380 had one registration (`ack 386 replaced=false`), ACK 386 completed with `loading_visible=false`, and the input lock was released. There was no socket close/reconnect during the roughly 20-second observation window. This validates cold login/loading cleanup, not the reconnect path itself; no disconnect occurred to exercise replay. The old close initiator and the original map-completion transition remain **unresolved** because no paired TCP/server log was captured for the old close session.

### Local recharge simulation

Target Lua catalog schemas now decode 12 normal recharge packages and 2 month-card packages. The original client calculation is preserved: normal packages grant `mCash * bonusRate` when a bonus rate is configured, otherwise `mCash + giftMCash`; month cards grant configured `initMCash` and extend their configured entitlement days. The code does not infer VIP EXP or first-charge mail rewards.

The private client purchase buttons now use the existing RechargeTestCmd request (90) instead of calling Android/iOS provider SDK functions. Each click creates one local order key. The server rejects unconfigured package IDs, mismatched package IDs, a disabled sandbox, or a configured external payment provider. Successful requests atomically update the wallet/recharge total and month-card entitlement, write a `simulated=true` ledger row, then send wallet notification 473 and ACK 89. Duplicate delivery of the same key returns current state without a second grant.

Schema is additive in `local_recharge_transactions`. Activation requires `LOCAL_PAYMENT_SANDBOX=1`; it is off by default. Do not enable it where an external provider is configured.

## Verification

- PostgreSQL test database: real test transaction for normal package 2 (160 configured diamonds), duplicate delivery (one ledger row and one grant), month card 10001 (400 initial diamonds, 30-day entitlement), and sandbox-disabled rejection.
- Framed TCP test: request 90 returns wallet notification 473 then ACK 89, with an idempotent second delivery.
- Lua syntax: `luac -p` on recharge and reconnect modules.
- APK builder/install: all four patched encrypted Lua entries were extracted and compared byte-for-byte to the edited sources. Package/version are `com.petalliance2.sea` / 7 / 1.0.0; signature matches the installed baseline certificate. `adb install -r` preserved app data, and pulling the installed `base.apk` confirmed SHA256 `364d275f98101e548758bc7b46ce775b7c9d0f13f830a574d24d2a2df5134e76`.
- Waydroid cold login/input state: **PASS for this path**. Screenshot `artifacts/full-gameplay-20261118/waydroid-after-reconnect-patch.png`; filtered same-PID client log `artifacts/full-gameplay-20261118/waydroid-reconnect-session.log`. Process 99836 was confirmed using database `monster2_db`, role `monster2`; read-only identity lookup confirmed account 6/character 2. The official TCP process was not restarted.
- Actual reconnect after an induced disconnect: **PENDING**. The verified login did not reconnect, so the dedupe branch remains Lua-contract tested but not Waydroid exercised.
- Waydroid local purchase click: **BLOCKED/PENDING**. The official production server is still the previous running process; it was not restarted and the play database schema was not modified during this work.

## Content status retained from prior checkpoint

- Content indexes remain 747 quests, 290 AdventureInfo records, and 907 monster groups. The shared quest reward and world-map event-18 node handlers are partial, with Waydroid validation only for prior capture/quest 10008 flow.
- Map trainer/wild/gift event families have representative PostgreSQL/TCP coverage; complete map unlock visuals, route state, and multi-map progression remain unverified.
- Regular MarketInfo purchase and wild capture have previous Waydroid evidence. Other shop catalog types, finite stock/reset semantics, and inventory full/invalid-purchase UI flows remain incomplete.
- Daily/seven-day/achievement/event reward systems remain partial or fail-closed. Social, mail, guild, and ranking systems are unsupported or incomplete.
- Pet capture, Pet EXP, Stage, evolution, equipment, skills, and formation each have different coverage; no claim of complete Pet gameplay is made.

## Remaining steps

1. The latest full suite is 96 PASS, 0 FAIL, 0 skipped; rerun after subsequent source changes.
2. Signed APK is installed and hash-verified on Waydroid.
3. Use an isolated test runtime and Waydroid flow to verify actual recharge BUY and induced reconnect, capturing synchronized TCP and Android logs.
4. Diagnose the old close using the same connection/session ID on both sides; do not infer its cause from ACK 386 or ACK 26 alone.
5. Back up and validate restore of the selected play database before restarting/migrating its server process. Only then configure the local sandbox explicitly if desired.
6. Continue quest/map/event engines from `IMPLEMENTATION_BACKLOG.md`; this checkpoint does not mark broad coverage complete.

## Release state

No production/play database write, service restart, account change, or Git push occurred. The prior 93-test result predates this checkpoint. See the next acceptance update for the latest suite and APK hashes.
