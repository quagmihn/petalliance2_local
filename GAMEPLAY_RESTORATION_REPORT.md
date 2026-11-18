# Gameplay restoration report — 2026-11-18

## Verified this pass

| Area | Status | Evidence |
|---|---|---|
| Quest 10003 client guide completion | **PASS** | Waydroid sent request 400 for 10003; play server returned ACK 726/code 0 and notification 404 for child 10005. PostgreSQL `monster2_play_db` persists 10003 as status 1 and 10005 as status 0/progress `[0]`. |
| Tutorial input after commit | **PASS** | After closing Mission UI the client returned to Town and accepted a tap on Pet, opening Battle Team / Select Pet. Screenshot: `artifacts/gameplay-restoration-20261118/waydroid-pet-ui.png`. |
| Pet detail and team display | **PASS (runtime)** | Waydroid displayed the starter Pet, two skills and battle-team slot without Lua error: `artifacts/gameplay-restoration-20261118/waydroid-pet-detail.png`. |
| Quest client failure/timeout unlock | **PASS (automated)** | Lua contract test checks both failure and timeout release the screen-touch mask and continuous-finish state. |
| Quest marker guard | **PASS (automated)** | The zero-target marker behavior is explicit config (`server/config/quest_client_commit_markers.json`) and is applied only to the configured marker; ordinary event-2 objectives still require persisted progress. This prevents quest 10001 being completed before the tutorial battle. |
| Character default outfit on cold relogin | **PASS (runtime)** | Server restart and cold relogin on Waydroid restored the configured outfit in Town: `artifacts/gameplay-restoration-20261118/waydroid-after-relogin-confirm.png`. |
| Outfit creation/change persistence | **PASS (PostgreSQL/TCP integration)** | Integration test creates a character with configured fashion IDs, changes equipped fashion through protocol, logs in again, and checks the same value. Tests use `monster2_test_db`. |
| Config indexes | **PASS (parser output)** | `GAME_CONTENT_INDEX.md` indexes all 747 quest rows and relevant discovered catalogs; `ADVENTURE_MATRIX.md` indexes 290 configured Adventure rows. Many gameplay meanings are explicitly marked partial/unverified. |
| Full automated server suite | **PASS** | `server/tests`: 73 tests, 0 failures, 0 skips, using PostgreSQL test DB. Log: `artifacts/gameplay-restoration-20261118/tests-final.log`. |
| APK | **PASS (artifact/runtime install)** | `dist/monster2_gameplay.apk`, SHA256 `2957196b52dc2d86e87e1df8a5ab878aa0bf8f66c91407e17f2bff00af70f90f`, signature verifies (debug certificate); installed Waydroid package was exercised. |
| Official launcher | **PASS** | `server/run_all.sh play` reports both listeners using `monster2_play_db`, role `monster2_play`; HTTP 8080 and TCP 5568. Log: `artifacts/gameplay-restoration-20261118/server-final.log`. |

## Quest 10003 cause and change

`NewQuestInfo.dat` describes 10003 with a zero-target event-type-2 objective, while the client guide advances through the Mission UI and calls the quest-finished flow. It is not a server-observable battle or item event. The previous generic progress requirement rejected that explicit guide finish (ACK code 1), leaving the client walkthrough in its continuous-finish state. The Lua failure/timeout cleanup also failed to re-enable screen touch.

The server now accepts that client commit only for explicit client-guide-marker config rows with a completed configured parent. Ordinary objectives still require persisted progress; 10001 remains dependent on the server-recorded tutorial battle. The client releases its touch mask on request error and timeout. This pass confirms 10003 specifically; it does not establish that every tutorial marker has been classified.

## Content discovery limits

- Quest config fields, IDs, relationships, numeric objectives and raw rewards parse successfully for all 747 records. Many descriptions are localization keys, objective enum semantics need the originating manager, and event/quest runtime support is incomplete.
- The Adventure index contains 290 config rows and their raw scene/reward references. This is not evidence that all maps, cell events, enemy groups, assets, or clear/reward flows are playable.
- Catalogs for events, activities, shops, recharge and cosmetics are indexed, but those indexes do not imply handlers have been implemented.

## Remaining work / release status

**Not gameplay-ready as a complete offline/private-server game.**

- Quest 10005 onward has not been completed on Waydroid in this pass.
- Quest 10005's configured guide is `firstFeed()` and the runtime UI opens the Pet EXP potion page. Selecting the available EXP Potion(S) is rejected by the client with “Please raise your character level”; the play character is level 1 with 60 EXP, while `ExperienceInfo.dat` sets level 1's pet level cap to 1. This is a real progression blocker, not a network failure. No level/EXP or quest data was manually altered to bypass it. Screenshots: `waydroid-feed-action.png`, `waydroid-feed-confirm.png`.
- The 10003 → 10005 transition is persisted, but the later tutorial/main/side/daily/event quest chain is not fully implemented or runtime verified.
- Adventure maps beyond prior partial support are not fully playable or verified.
- Event participation/claim persistence is incomplete.
- Shop purchase handlers currently reject unmapped purchases; no full atomic catalog purchase flow is verified.
- `recharge_test` remains disabled/rejected; no local recharge sandbox has been implemented. No real payment path was used.
- Cold-login showed the configured default outfit after server restart. User-selected outfit persistence is covered by test DB integration, but has not yet been exercised end-to-end through the live Waydroid UI.
- No full progression matrix or server-restart suite was run for every feature group.
- Runtime character in the screenshots is account 1 / character 1 on the play DB; no account or character was deleted or manually quest-completed.
- The current working tree has uncommitted changes and an unrelated existing modified image. No commit or push was made because the overall requested release acceptance is not met.

## Runtime artifact references

- `artifacts/gameplay-restoration-20261118/waydroid-mission-open.png`
- `artifacts/gameplay-restoration-20261118/waydroid-after-quest-close.png`
- `artifacts/gameplay-restoration-20261118/waydroid-pet-ui.png`
- `artifacts/gameplay-restoration-20261118/waydroid-pet-detail.png`
- `artifacts/gameplay-restoration-20261118/waydroid-feed-action.png`
- `artifacts/gameplay-restoration-20261118/waydroid-feed-confirm.png`
- `artifacts/gameplay-restoration-20261118/waydroid-after-relogin-confirm.png`
- `artifacts/gameplay-restoration-20261118/server-final.log`
- `artifacts/gameplay-restoration-20261118/tests-final.log`
