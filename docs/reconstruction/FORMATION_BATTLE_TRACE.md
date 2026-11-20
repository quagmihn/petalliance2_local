# Formation persistence and battle trace

## Source and observed failure

The old client sent formation request 1755 with one army record, army index
1, a vector of fighting Pet UIDs, and a vector of helpers. The server
validated ownership, distinct species and level-gated capacity and committed
the selected slot indices before ACK 1756.

The recorded owner session received `1760 → 1774` with `[2,3]`. It saved
`[2,27]` at 08:15:02 and received `1756/code 0`. Group 2003 then received
`136 → 210/code 0`. A later read-only PostgreSQL query showed UID 2 /
template 1 in slot 0, Panda UID 27 / template 45 in slot 1, and Catepii UID
3 / template 26 in reserve. These logs establish that the selection was
saved. The old client lacked a friendly snapshot log for the reported scene.

`PetListMgr.savePetTeam` updated the UID lists after the ACK. The normal
`BattleMapMgr.createBattleScene` path took friendly models from
`PokemonInfo.getActivePets()`, which was still the active list received at
login. ACK 210 provides enemy models and battle EXP, so the server did
not select the stale friendly roster. The introductory
`BattleMapMgr.firstBattleShow` has a separate explicit scripted team.
Trainer group 2003 is guided gameplay, with the ordinary saved friendly
team. Active Adventure and Lost Tower battles use their respective
expedition rosters.

## Repair and checks

- A successful 1756 now applies the exact request's UID vectors to the
  active, support and reserve collections together. Selection in the editor
  is independent until success. Normal battles and team power read the
  updated collections. New expedition snapshots replace earlier slots in
  full. A running expedition retains its own roster.
- The Lua test saves Panda over Catepii, sees Panda in the next battle
  without relogin, switches to Catepii and sees it in another battle.
  It also checks a scripted team, support slots, unknown or repeated UIDs,
  and independent Adventure snapshots.
- The PostgreSQL test acquires Panda through the guide draw, saves it
  through request 1755, checks its slot, cold-logs in and retrieves the
  same UIDs through 1760/1774.
- In the first Waydroid replay, QA account 75 / character 7 loaded group
  2003 from MainScene with UID 17 / template 7 in fighting slot 1 and UID
  18 / template 45 in slot 2. The player switched to Panda and won.
  The UI nevertheless went directly to quest commit without sending 263.
  The guided NPC event previously omitted the normal battle-end callback.
  The client now sends the real battle trace, then waits for ACK 186 and
  for the player to leave the summary before committing the quest.
  The Lua suite checks both event orders and an acknowledged loss.

Slot indices are zero-based in PostgreSQL and one-based in the BattleScene
log. See `artifacts/formation-content-20261120/` for the first replay and
[the current checkpoint](EXECUTION_CHECKPOINT.md) for the deployed result.

## Final APK on the official server

| Action | Wire and database state |
| --- | --- |
| Guided trainer victory (group 2003) | `136 → 210`, then `263 → 186`, both code 0. Battle 24 became `won`. Quest `400 → 726/code 0` and notification 404 completed 10032. |
| Drag Panda into the first fighting slot and close the editor | 1755 sent `[18,17]`, 1756 returned code 0. PostgreSQL stored UID 18 / template 45 in slot 0 and UID 17 / template 7 in slot 1. Panda became the active follower before relogin. |
| Enter the normal trainer battle in Secret Path with the same app session | 2996/3080 selected Adventure 2. Request 136 used type 3, scene cell 15, group 1. BattleScene showed Panda UID 18 first and Zupedo UID 17 second. The player won and received `263 → 186/code 0`. Battle 25 became `won` with Adventure ID 2. |
| Exit Secret Path through its portal | `3082 → 2995/code 0`, 473 and 1749. PostgreSQL stored mask 12 and the configured clear rewards for Adventure 2. |
| Cold relogin | A new Android process and TCP session returned `1760 → 1774` with `[18,17]` and 1749 with Adventure 2 / mask 12. The preview showed Panda first and the earned star. The post-login database snapshot matched the saved slots, quest and map results. |
| Enter a second normal trainer battle after relogin | BattleScene again logged UID 18 / template 45 first and UID 17 / template 7 second. The new session finished through `263 → 186/code 0`. |

The runtime test reordered two owned Pets. Replacing a reserve Catepii
with Panda is covered by the Lua regression. The owner account was read only.
