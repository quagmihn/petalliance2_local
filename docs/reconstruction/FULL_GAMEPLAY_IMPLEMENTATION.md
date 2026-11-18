# Full gameplay implementation checkpoint

Date: 2026-11-18. This is a partial implementation checkpoint, not a claim that the target APK has been fully restored.

## Implemented in this checkpoint

### Reconnect and loading callbacks

Client logs showed a reconnect replay path sending a pending quest-list request and then unconditionally sending another quest-list request from `NetInterface.resend()`. `Reconnector.finish()` could also reissue a channel join already being replayed. Lua diagnostics showed callback registrations for ACK 26 and 386 being replaced. `NetInterface.hasPending()` now guards those automatic requests, and `resend()` snapshots the pending cache before replay. This keeps one callback owner for each in-flight ACK and retains its normal success/error cleanup.

The logged request/ACK pairs completed and the loading overlay was hidden before `SOCKET_TCP_CLOSE`; the extracted log does not include a synchronized production TCP close row. The close initiator and the underlying transport close cause therefore remain **unresolved**. The reconnect duplicate was fixed because the source call stacks demonstrated it, but that alone does not prove the connection close or map transition is fixed.

### Local recharge simulation

Target Lua catalog schemas now decode 12 normal recharge packages and 2 month-card packages. The original client calculation is preserved: normal packages grant `mCash * bonusRate` when a bonus rate is configured, otherwise `mCash + giftMCash`; month cards grant configured `initMCash` and extend their configured entitlement days. The code does not infer VIP EXP or first-charge mail rewards.

The private client purchase buttons now use the existing RechargeTestCmd request (90) instead of calling Android/iOS provider SDK functions. Each click creates one local order key. The server rejects unconfigured package IDs, mismatched package IDs, a disabled sandbox, or a configured external payment provider. Successful requests atomically update the wallet/recharge total and month-card entitlement, write a `simulated=true` ledger row, then send wallet notification 473 and ACK 89. Duplicate delivery of the same key returns current state without a second grant.

Schema is additive in `local_recharge_transactions`. Activation requires `LOCAL_PAYMENT_SANDBOX=1`; it is off by default. Do not enable it where an external provider is configured.

## Verification

- PostgreSQL test database: real test transaction for normal package 2 (160 configured diamonds), duplicate delivery (one ledger row and one grant), month card 10001 (400 initial diamonds, 30-day entitlement), and sandbox-disabled rejection.
- Framed TCP test: request 90 returns wallet notification 473 then ACK 89, with an idempotent second delivery.
- Lua syntax: `luac -p` on recharge and reconnect modules.
- APK builder: all four patched encrypted Lua entries were extracted and compared byte-for-byte to the edited sources. Package/version are `com.petalliance2.sea` / 7 / 1.0.0; signature matches the installed baseline certificate. New APK SHA256: `364d275f98101e548758bc7b46ce775b7c9d0f13f830a574d24d2a2df5134e76`. APK was not installed during this checkpoint.
- Waydroid local purchase click: **BLOCKED/PENDING**. The official production server is still the previous running process; it was not restarted and the play database schema was not modified during this work.

## Content status retained from prior checkpoint

- Content indexes remain 747 quests, 290 AdventureInfo records, and 907 monster groups. The shared quest reward and world-map event-18 node handlers are partial, with Waydroid validation only for prior capture/quest 10008 flow.
- Map trainer/wild/gift event families have representative PostgreSQL/TCP coverage; complete map unlock visuals, route state, and multi-map progression remain unverified.
- Regular MarketInfo purchase and wild capture have previous Waydroid evidence. Other shop catalog types, finite stock/reset semantics, and inventory full/invalid-purchase UI flows remain incomplete.
- Daily/seven-day/achievement/event reward systems remain partial or fail-closed. Social, mail, guild, and ranking systems are unsupported or incomplete.
- Pet capture, Pet EXP, Stage, evolution, equipment, skills, and formation each have different coverage; no claim of complete Pet gameplay is made.

## Remaining steps

1. Run the full suite after the latest reconnect/client changes and record exact counts.
2. Rebuild and validate the signed APK from the installed baseline.
3. Use a separately configured test runtime and Waydroid session to verify the actual recharge BUY click and reconnect behavior, capturing synchronized TCP and Android logs.
4. Diagnose the remaining close using the same connection/session ID on both sides; do not infer the cause from ACK 386 or ACK 26 alone.
5. Back up and validate restore of the selected play database before restarting/migrating its server process. Only then configure the local sandbox explicitly if desired.
6. Continue the quest/map/event engines from `IMPLEMENTATION_BACKLOG.md`; this checkpoint does not mark broad coverage complete.

## Release state

No production/play database write, service restart, account change, or Git push occurred. The prior 93-test result predates this checkpoint. See the next acceptance update for the latest suite and APK hashes.
