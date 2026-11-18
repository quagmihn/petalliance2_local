# Monster2 restoration status

Date: 2026-11-18
Source: `/home/quagmihn/Project/monster2_rebuild`
Official runtime: `./server/run_all.sh production`, database `monster2_db`, role `monster2`
Integration database: `monster2_test_db`, role `quagmihn`

## Overall result

Partial recovery only. The official server and client can log in, load Town, move the avatar on walkable ground, run the configured type-1 wild encounter, buy the configured Master Ball, capture the configured Catepii, and commit quest 10008 on Waydroid. This verifies one supported quest/capture/shop path; it does not establish full-game restoration. Pet EXP feeding, broad map progression, event claims, and recharge remain unverified.

## Content inventory

`tools/audit_game_content.py` reads the client XDat tables through the Lua protocol declarations and the existing binary `NewQuestInfo.dat` parser, then generates machine-readable and Markdown catalogs:

- **747 quests** and their configured parent/child edges: [ALL_QUESTS.md](ALL_QUESTS.md), [quest_graph.json](quest_graph.json).
- **290 AdventureInfo entries**, plus 22,486 scene rows, 10 map-node rows, and 220 map-event rows: [ALL_MAPS.md](ALL_MAPS.md).
- Event/activity catalog: [ALL_EVENTS.md](ALL_EVENTS.md).
- **907 configured monster groups**: [ALL_BATTLE_GROUPS.md](ALL_BATTLE_GROUPS.md).
- Pet-related configuration tables: [ALL_PET_SYSTEMS.md](ALL_PET_SYSTEMS.md), [pet_config_index.json](pet_config_index.json).
- Protocol declarations/catalog coverage: [PROTOCOL_COVERAGE.md](PROTOCOL_COVERAGE.md).

These catalogs preserve raw numeric fields where client semantics have not been established. They are discovery artifacts, not proof that every quest, map, event, or protocol flow is implemented. Quest graph checks expose inconsistent parent/child and missing reward references; see the generated validation block in `ALL_QUESTS.md`.

## Implemented changes and evidence

### Pet EXP feed and immediate UI ordering

Request 516/ACK 526 uses the configured potion and Pet EXP tables. The handler persists the item deduction and Pet level/EXP atomically, leaves training Stage independent, and sends item and Pet notifications before the success ACK. The ACK callback refreshes the visible Pet panel from cached state, so sending the notification after ACK explains the stale level display. PostgreSQL/TCP tests verify committed level/EXP, consumed item, and response ordering. Waydroid Pet feeding was **not performed** in this run. The protocol has no operation ID, so an ACK-lost client cannot safely replay this non-idempotent request; the client marks feed non-resendable.

### Tutorial wild encounters and capture

The client callsite `GameGuideMgr1.lua::firstPetCatch()` selects a wild-monster ID in `999997..999999`; these are not trainer group `99999`. They use battle type 1 and `MonstrosityInfo` entries. The separate trainer battle uses type 5. Server configuration now resolves only the three configured wild encounters for their active quest and supplies configured enemy stats, skills, EXP, and capture-attempt count.

Capture-ball evidence from client config:

- `PokemonBallInfo` maps the actual capture balls to item IDs 2 (Para), 3 (Senior), and 1 (Master); all are catalogued capture items.
- The capture view's add button invokes the MarketInfo purchase flow for catalog entry 201. That entry grants one item 1 for 600 diamonds and is unlimited (`buyMax=0`). Tutorial quest rewards do not provide these balls. No arbitrary starter grant was added.

The implementation consumes a configured ball and one attempt under transaction/row locks, rolls the configured rarity chance, records attempts, creates the configured Pet on success, and advances the capture objective only on success. A repeated request after success returns the same captured Pet without consuming another ball. Market purchase validates the catalog and currency and atomically deducts currency/grants the item; inventory and authoritative wallet updates arrive before ACK. Runtime evidence found three linked issues and fixes: the client reset the catch template ID during victory cleanup; request 15 sends the Pet template ID (26), while the server had keyed it as an encounter ID (999998); and the client committed the capture quest even when `isCatched=0`. The client now retains the template ID, server resolves it against the current configured encounter, and failed capture outcomes do not complete the quest. Waydroid showed configured price 600, request 577/ACK 563, then request 15 `(pokemonID=26,itemID=1)`/ACK 198 caught. PostgreSQL consumed one Master Ball, created Pet UID 3/template 26, and advanced quest 10008 progress to `[1]`. CommitQuest 400 received ACK 726/code 0 and notification 404; quest state persisted with status 1/progress `[1]`.

### Reconnect-safe battle completion

The observed error was request 263 rejected as `no_active_encounter` after the client reconnected: the server bound the active battle to the old TCP session ID. Battle state is now resolved against the authenticated character and remains one-use/row-locked; a matching encounter can resume on reconnect. Tests cover reconnect and completion. Waydroid then received request 136/type 1/group 999998 ACK 210/code 0 with configured Caterpii data; auto battle sent request 263 and received ACK 186/code 0 with 8 configured EXP. The client proceeded to the wild capture screen. In the earlier failed runtime, battle_id 9 remained `started`; it was not manually changed. A later eligible battle request may supersede a different abandoned battle by marking the old encounter `lost`, never rewardable.

### Movement

On Waydroid, a tap on a walkable map position moved the avatar locally and generated no TCP movement request; the position visibly changed. This supports local movement for this scene. Invalid ground, NPC, portal, Pet, and object taps were not separately verified. The earlier visible `Failed` occurred on the server's rejected battle-end ACK after reconnect; it is not evidence that ordinary ground movement caused that toast.

## Automated tests

PostgreSQL integration and TCP suite: **87 PASS, 0 FAIL, 0 skipped** using `TEST_DATABASE_URL` for `monster2_test_db`. Tests include feed transaction/notification ordering, configured wild encounter authorization, capture transaction/idempotency, market catalog purchase, wallet canonical-field precedence, capture request/client state contract, and battle reconnect handling. These results do not replace Waydroid gameplay verification.

## Runtime, backup, and APK

- Official launcher log confirms both HTTP and TCP pools on `monster2_db` / `monster2`, source directory `/home/quagmihn/Project/monster2_rebuild/server`, commit base `395f4c7e874b57732cbc25da1d0381dc44467227` with local changes.
- Waydroid cold relogin on account 6 / character 2 succeeded after capture; Town and the post-capture guide dialogue loaded. Evidence screenshots: `artifacts/pet-exp-feed-20261118/waydroid-capture-success.png`, `capture-award.png`, and `post-capture-relogin-progress.png`.
- Installed/rebuilt APK SHA256: `362d724207e8b1da7fe55f8f86e0672f195e9f6b6388d2c7119e56fa1d677448`; pulled installed APK hash matched. Signing certificate SHA256 `f6a9b74ac979b6f3c221eb0b21789619b1238c89ca813b9033a60425cf489a3a` matches the app signer. App data was preserved; `pm clear` was not used.
- Verified source changes are in commit `6c21560` (`Restore configured wild capture and Pet economy flows`).
- Pre-change custom-format production backup: `artifacts/pet-exp-feed-20261118/monster2_db_before_runtime.dump`, SHA256 `9a76b45359542acef1849d2a454a193ef7f2df1a6e355b208c591a1316962844`; archive TOC parsed. A second PostgreSQL custom archive `monster2_db_pre_restoration-20261118-135929.dump` has SHA256 `db83a441108b7eba5d5eb9fe1c1cdb6d3a74e04201aba6af8a0d8e40d1edd89b` and `pg_restore --list` succeeds. Full isolated restore verification was blocked because the current role lacks CREATEDB and local postgres sudo requires a password. No production restore or manual gameplay-state rewrite was performed.

## Remaining status

| Area | Status |
|---|---|
| Quest catalog and graph discovery | Implemented as audit output; graph semantics have unresolved validation errors |
| General quest lifecycle across all 747 entries | Blocked/incomplete; numeric objective semantics and handlers are not fully mapped |
| Map/adventure progression | Cataloged; full generic progression is not implemented or Waydroid-verified |
| Wild encounter start/end | Integration tested; Waydroid request 136/210 and 263/186 both succeeded |
| Capture balls/capture | Waydroid verified: MarketInfo 201 purchase, configured capture chance, Pet UID 3/template 26, inventory consume, quest objective and commit |
| Pet EXP feed and Stage | Feed transaction tested; feed UI and Stage upgrade not verified in Waydroid |
| Ground movement | One valid ground tap moved locally without a request; other tap types and invalid-ground behavior unverified |
| Events/reward claims | Cataloged; handlers and runtime claims incomplete |
| Shop | MarketInfo purchase protocol implemented/tested for configured unlimited items; live UI stopped before request 577 due “BAG IS FULL”; other shops incomplete |
| Local recharge | Not implemented. Only the configured `recharge.totalMoney` response shape was corrected |
| Latency profiling | Request handler durations are logged; end-to-end database/TCP/UI interval profile is not yet produced |

The live purchase dialog reports “BAG IS FULL”, but a read-only production query found one inventory stack containing two units; client config `GlobalConfigAddInfo` 6601 defines 70 initial item slots. No request 577 followed the dialog. The mismatch is likely in client bag state/capacity initialization and needs tracing before the catalog purchase can be accepted in Waydroid.

The primary next acceptance path is to repair and verify that bag-capacity state, use the configured MarketInfo 201 purchase in the live capture UI, verify inventory/wallet notifications, complete one real capture at configured odds, and then verify quest progress and Pet persistence after relogin. Do not force success or inject items into the production character to manufacture a pass.
