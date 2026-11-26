# Implementation backlog

## After the private freedom and catalog release

1. Exercise Bag item 254 in Waydroid and capture the selected reward and its post-login stock. Use the audit to separate the 115 chest mappings missing valid award kinds or references from the 136 currently enabled. Trace type-8 stamina restoration and the separate equipment, crafting and furniture paths.
2. Run a Rage/Profound combat action, active replacement and passive replacement using an eligible Pet. Check runtime effect and ownership. Resolve the 58 Fight templates only where a source proves a valid starting group, and locate target-compatible battle resources for templates 157 and 10000.
3. Run the remaining Seven-Day types from `TaskWatcherManager` against known server mutations. Track original event-specific counters for the 80 unimplemented rows. UI-derived counters require authoritative backing before awards are enabled.
4. Run the four other normal recharge price tiers in Android and resolve the Wish Tree Seed reward for N10/N11. Preserve first-vs-repeat and separate claims.
5. Exercise and reconcile the remaining feature-local entry guards, especially Home, original Arena and Dungeon flows. Freedom covers the shared menu and wardrobe gates and the known Pet tab entry points. Actual game prerequisites and absent mode implementations still control their actions.
6. Keep Pet storage stress tests above 500 separate from ordinary acceptance. Test client sorting, battle, evolution, release and Bag subtype handling at scale. Inspect non-reward inventory mutation paths before raising the verified scope.

## Next Pet and economy acceptance

1. Implement truthful local NPC Arena entry through 277/51 and replay/history
   267/265. Trace the 317/356 opponent payload and the ranked fight/action
   protocols separately from PvE. Then use the existing level-11 type-1 exchange
   to verify win → Arena points → buy → relogin. The purchase engine supports
   778/1746, 835/859, 853/1876 and 858/1953 already.
2. Add reconnect-safe evolution for 1247/777, starting with normal branches
   whose costs, destination, skill candidates and slot contracts are resolved.
   Persist the pending selection until a valid skill-choice or clear request.
   Super evolution still needs relation and 5-star eligibility.
3. Implement the unidentified equipment item → owned instance → appraisal →
   equip lifecycle. Use the VIP claim's badge voucher 50057 as an independent
   QA case. Verify distinct inventory/template/equipment instance IDs first.
4. Resolve active and passive high-rarity skills in Android combat, then test
   crafting and education. Compare effects, cost and persistence. There are
   384 valid book references and 2,360 configured upgrade edges in the current
   engine's audited domain.
5. Establish the broader ordinary Gacha pool policy, including the requested
   Senior C/B/A roster and Supreme eligible Pet and costume rewards. Complete
   mount, handheld and furniture ownership before adding those prizes.
6. Trace the Wish Tree Seed shown on N10/N11 and the client-advertised M-PASS
   Gacha and capture perks before expanding the ledger reward rules. Replay
   other normal SKUs and feature triggers independently.
7. Use `qa_account.py vip-max` with an explicit playing account and the
   verified backup for a separate VIP rank application where authorized.

## Next acceptance after Wise Arena and item rewards

- Exercise an authored capture node in Waydroid. The recorded Wise Arena
  Bashful cell is a fight with zero capture attempts. Use the eligible
  world-map node for quest 1503 or an unfinished route capture on a QA
  character. Also replay the direct Trainer tap while standing adjacent,
  test rejection recovery in the APK, and check defeated-cell rendering
  after a fresh entry.
- Trace the distinct Golden Chest flow from TreasureBoxInfo and
  requests 229, 285 and 318. The item-use failure in the old log was
  Silver Bag(S). Four Symbols and ordinary gift chest previews use
  RewardInfo and should be tested separately from Team Treasure.
- Verify fragment synthesis and ordinary skill learning, replacement and
  enhancement in the Android bag and Pet screens, then cold-relogin.
  Continue with the separate skill-book crafting and education protocols.
- Reconstruct mount and furniture acquisition before enabling those
  prizes. Find evidence for ordinary first-ten, guarantees, Wish,
  Dream and membership modifiers before changing the local draw rules.
- Continue Seven-Day progress and purchase categories, daily recharge
  promotions, Pet equipment and late Adventure props. Define accepted
  rewards from the packaged records for each handler before enabling it.
- Trace the Town position relay. The client periodically sends request
  45 with channel 0 / `zhucheng_2` and a position object. ACK 35 returns
  code 1 because the relay is absent. Its repeated red notice is separate
  from the fixed Wise Arena battle error and from successful reward claims.

## Next acceptance after the unseeded tutorial replay

1. Complete all Wise Arena pickup cells in one run and verify the third
   crown. The sequential character reached both floors, used Slash,
   defeated the trainer and persisted two crowns.
2. Trace the original first-ten selection sequence outside the guide.
   The current Senior free and Skill x1/x10 passed in Waydroid.
   Restore Wish/Dream independently from the ordinary pools and leave
   unsupported costume/Pet rewards outside enabled catalog selections.
3. Extend the accepted Town Market checkout beyond Normal Essence.
   Resolve the missing Adventure NPC supplies and trace VIP thresholds
   against compatible source data. Continue the owned equipment instance
   and slot protocol before enabling affected offers.
4. Resolve missing quest, battle and event dependencies using the generated
   [reference matrix](CONTENT_REFERENCE_MATRIX.md). The target has 58 Fight
   templates without a basic attack in the available snapshots.
5. Trace the Town position broadcast. Motion sends request 45 on
   `zhucheng_2` and still shows a generic failure because the relay is absent.
   The current player stayed connected.

## Next acceptance after battle EXP and the authored-scene switch

1. Complete the three-Adventure chain on Android, including portal
   traversal with the newly mapped Wise Arena floors. A framed TCP
   sequence verifies IDs, rewards and mask persistence.
2. Establish source-backed Pet eligibility and odds for the two ordinary
   Gacha pools. Senior already enforces the Gold cap. The deployed Senior
   and Supreme pools currently contain only items.
3. Resolve target-compatible price/config for SKU 203. The alternate row
   identifies item 9986, while target and alternate currencies/amounts
   for nearby offers need comparison before any import.
4. Verify owned equipment instance ID and slot handling against the client.
   Maintain distinction between a fashion voucher, an owned appearance,
   and a slotted equipment instance. Continue event/reward reference checks.

See [runtime evidence](EXECUTION_CHECKPOINT.md) and
[current coverage](CONTENT_COVERAGE.md).

## Next acceptance cases after formation and trainer progress

1. Repeat the normal encounter after swapping a reserve Pet into the
   main team through the Android editor. Waydroid reordered two owned
   Pets and used that order in the Secret Path battle. The Lua
   regression covers replacing a reserve Pet.
2. Trace battle EXP application. Group 2003 in this run showed +24 in
   the summary, while the database left both fighters at EXP 0. Determine
   the client evidence for eligible members and persistence before adding
   an award rule.
3. Establish a supported Senior Pet pool compatible with the requested
   tier 4 cap and a broader Supreme pool with independently validated
   eligibility and odds. The current Senior group is outside that policy.
4. Resume Adventure acceptance through the existing QA fixture. Check
   separately named runs, goals, rewards and route state before testing
   repeated or concurrent requests. Audit unsupported equipment/shop
   references and gameplay before exposing additional products.

See [content coverage](CONTENT_COVERAGE.md) and
[deployed confirmation](EXECUTION_CHECKPOINT.md).

## Next acceptance cases after the 2026-11-20 integrity fix

1. Resume fresh sequential QA character 6 at active quest 10002 and exercise
   normal actions through 10009/10010. Capture both draw ACKs, Pet UID, quest
   commits, formation and cold-login state. Keep owner character 2 out of
   QA writes.
2. Reuse the isolated Adventure fixture for two real map clears. Compare
   the wire Adventure ID, goal and encounter state, earned rewards and
   independent relogin state. The indexed scene source is shared.
3. Run the existing Market purchase and wardrobe flows from their
   isolated QA profiles, checking the Bag and the equipped appearance
   after relogin. Audit the other shop families against missing references
   before enabling offers.
4. Resolve the pending quest dependency references and confirm equipped
   item instance and slot contracts against the client. Keep unsupported
   mechanics at their current acceptance status.

See [latest deployed source and evidence](EXECUTION_CHECKPOINT.md).

The official local Gacha service is **WAYDROID_VERIFIED** for every enabled
machine and mode. The controlled profile confirmed draw animations, costs,
rewards, a failed retry, responsive input, and persistence after server
restart. See [EXECUTION_CHECKPOINT.md](EXECUTION_CHECKPOINT.md) for the
release and evidence.

The checkout UI, M-PASS entitlement and first daily claim ran on the same
isolated profile. The VIP ID repair let the client reopen STORE after the
claim. STORE's VIP progression label and legacy M-PASS perk text still
need to match the configured benefits.

Next exercise an item purchase through the in-game shop and compare the
request, ACK, wallet, inventory, and cold login. Run the two Adventure entries
with separate active quests and verify progression and map rewards. Use the
[QA fixture](../../server/PLAY.md) for independent starting states. The
sequential tutorial, original Gacha guarantees, wish and dream modes, and
full sequential progression remain separate cases.

## Current deployment status

The specified dump passed full isolated restore verification. The official
server runs the local payment implementation on monster2_db with the two
additive ledger and entitlement tables. M-PASS daily claim already passes
PostgreSQL integration. The locally available APK generations preserve the
same Secret Path scene.

## 2026-11-18 checkpoint: Secret Path and local purchase deployment

- Audited the shipped `map_node.txt`, localized names, `AdventureInfo.dat`, `SceneInfo.dat`, and client `SearchingMapMgr`/`WorldMapInfo` code. LOST FOREST is world 1 point 2 → Adventure 1; SECRET PATH is point 10 → Adventure 2. Both target configs explicitly reference scene number 1 and the same 30 SceneInfo rows. The server does not remap the requested Adventure ID. Added contract tests and detailed identity matrices; do not substitute another map layout without new target-version evidence.
- Live runtime remains old: PIDs 99835/99836 began before commit `29ebf1b`; both connect to `monster2_db` as `monster2`. `LOCAL_PAYMENT_SANDBOX` is unset/off, and `local_recharge_transactions` is absent.
- Fresh custom-format production dump created and archive-index validated, but restore validation is blocked because role `monster2` has `CREATEDB=false`; isolated database creation was denied. No production migration or restart was performed.
- Exact Waydroid PURCHASE click and M-PASS acceptance remain blocked until the official process/schema can safely be updated. Month-card daily claim is not implemented.
- Full suite rerun with `TEST_DATABASE_URL=postgresql:///monster2_test_db`: 99 PASS, 0 FAIL, 0 skipped. New map identity tests are included.
- Next executable action: use an authorized DB operator path to restore the saved dump into a new isolated database and verify it; then add the recharge schema, restart only the recorded official launcher with explicit local-only gate, and perform Waydroid PURCHASE/M-PASS. Separately investigate whether another lawful target-version asset/config set contains a distinct Secret Path floor; the target APK config currently shows shared geometry.

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

The current local character can continue to open gameplay menus. His invisible quest 2005 automatically attempts commit at login and is rejected because `RewardInfo 11002` is absent. The three available RewardInfo snapshots were decoded: the 3,241-row target and both 3,211-row alternate extracts omit 11002. Locate an independent compatible source or establish the intended reward contract before enabling that commit. Its progress stayed `[1]` and existing rewards stayed unchanged.
