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
12. Local-only recharge package catalog and simulated idempotent transaction after correctly parsing package/reward configs; reject external provider integration.
13. Social/family/friends/chat/mail/ranking/achievement protocol coverage and persistence.
14. Appearance/equipment/pet/UI cache contracts, including state revisions where wire protocol supports them.

## P3 — broad acceptance

15. Content-wide static foreign-key/reference audit with categorized unsupported configs.
16. Profile request/SQL/transaction/client redraw latencies; optimize only measured slow paths.
17. Separate Waydroid acceptance by interaction/scene/battle family, cold relogin, and official server restart.
18. Compare optional newer lawful assets against the target APK before integration; no upgrade assets currently merged.
