# Implementation backlog

Checkpoint baseline tag: `baseline-partial-verified-2026-11-18` at commit `947a052d59663a70b28821b28d3983e1ed83951e`. See `FINAL_RUNTIME_ACCEPTANCE.md` for the exact tested state.

## P0 — runtime state correctness

1. Inventory capacity defaults now use client config: itemPacketNum=70, petPacketNum=40, explorePacketNum=10; Waydroid reached the add flow.
2. Capture client must retain the configured Pet template ID across victory cleanup; server maps that ID to the owned configured encounter. PostgreSQL contract is passing; repeat on Waydroid after the rebuilt APK.
3. Verify wallet update after server restart; current handler now makes committed wallet columns authoritative over legacy JSON mirrors.
4. Exercise Pet EXP potion on Waydroid; compare request, committed DB state, immediate UI, and cold login.

## P1 — shared domain engines

5. Implement inventory slot/stack limits from client config and catalog semantics; share the reward resolver with purchase/adventure paths. Quest commits now grant supported RewardInfo gold/diamond/item/EXP/Pet rewards atomically and persist idempotency claims; purchase/adventure reward service reuse remains.
6. Map every quest objective event type to a verified domain event adapter; add graph/reference tests for all 747 rows. Current quest reward coverage: 72 configured award IDs resolve; 367 reference absent RewardInfo IDs; 308 use awardID=0. Quest reward runtime through Waydroid is pending.
7. Build map/adventure state graph and generic entry/explore/event/battle/clear/reward lifecycle from AdventureInfo, SceneInfo, MapNodeInfo, MapEventInfo, and client callsites. Event-18 world-map objectives now cover observed map_event types: 55 trainer references / 53 groups, 30 wild-monster references, and 111 gift/collect references. Each validates active quest and node unlock; gifts have an idempotency table. PostgreSQL/TCP covers representative flows, while all three interaction families need Waydroid verification.
8. Add per-mode battle resolver/eligibility/reward contract for all discovered battle type families; never authorize unknown IDs.
9. Implement Pet level/stage/evolution/strengthen/star/equipment/skill flows independently from their exact configs and protocol.

## P2 — services/data

10. Event claim state and reset semantics for verified local schedules.
11. Each shop catalog, stock refresh/limit rules, and atomic wallet/inventory notifications.
12. Local-only RechargeTestCmd checkout now parses all 12 normal and 2 month-card catalogs, grants configured initial diamonds, advances recharge total/month entitlement, and is idempotent per generated order key. PostgreSQL/TCP verified; Android BUY click still needs Waydroid verification. First-charge mail rewards and daily month-card claims remain unresolved.
13. Social/family/friends/chat/mail/ranking/achievement protocol coverage and persistence.
14. Appearance/equipment/pet/UI cache contracts, including state revisions where wire protocol supports them.

## P3 — broad acceptance

15. Content-wide static foreign-key/reference audit with categorized unsupported configs.
16. Profile request/SQL/transaction/client redraw latencies; optimize only measured slow paths.
17. Separate Waydroid acceptance by interaction/scene/battle family, cold relogin, and official server restart.
18. Compare optional newer lawful assets against the target APK before integration; no upgrade assets currently merged.

## 2026-11-18 active implementation checkpoint

- Implemented the local recharge UI path in `PayConfig.payLocal`; Android/iOS no longer invoke external SDK checkout in this private build. The APK packer now includes those Lua changes.
- Added a local recharge ledger with `simulated=TRUE`, per-character idempotency, configured normal package grant rules from `PayConfig.genRechargeInfoTable`, and month-card entitlement. Activation requires `LOCAL_PAYMENT_SANDBOX=1` and no external `PAYMENT_PROVIDER`; default is off.
- Fixed a demonstrated reconnect duplication: source traces showed `NetInterface.resend()` replaying pending quest/channel requests and then issuing a second quest-list request; `Reconnector.finish()` could also submit another channel join. This overwrote callbacks (`replaced=true`). Replay now snapshots pending requests and checks ACK ownership before starting the automatic refresh/channel join.
- Full suite after recharge + reconnect dedupe: 96 PASS, 0 FAIL, 0 skipped on `monster2_test_db` (log `/tmp/monster2-full-suite-20261118.log`).
- Installed APK from exact baseline with `adb install -r`, preserving app data. Cold login on Waydroid for account 6/char 2 reached MainScene; requests 785/380 and ACKs 26/386 had single callback registrations, loading cleared and input lock released. Evidence: `artifacts/full-gameplay-20261118/`.
- No induced reconnect occurred during the fresh login; reconnect replay still needs Waydroid test. The old socket close was not paired with server logs.
- Live server was not restarted or migrated. Next: test recharge click only after applying server code/schema to an isolated runtime; capture synchronized logs for induced reconnect and eventual production server close root cause.
