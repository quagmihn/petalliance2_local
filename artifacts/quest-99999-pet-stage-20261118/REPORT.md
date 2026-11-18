# Battle group 99999 and Pet Stage persistence report

Date: 2026-11-18

## Result summary

| Acceptance | Result | Evidence |
|---|---|---|
| Request 136 / group 99999 | PASS | Official server accepted group 99999 and returned ACK 210/code 0 with configured enemy 999994. |
| Battle runs and victory | PASS | Waydroid displayed the configured enemy at 224 HP and the tutorial battle reached Victory. |
| Request 263 / ACK 186 | PASS | Client sent result `1` and Pet detail `2,146`; official server returned ACK 186/code 0. |
| Quest 10007 completion | PASS | Client sent commit 400; ACK 726/code 0; server sent notification 404 with child quest 10008. |
| Quest persistence | PASS | PostgreSQL has quest 10007 status 1/progress `[1]`, quest 10008 status 0/progress `[0]`; after cold app restart and login, client received quest 10008 again. |
| Pet Stage implementation | PASS in test DB | Request 1038 transaction integration test charged configured costs, persisted `training_stage=1`, and QueryPets serialized the saved Stage. A second ineligible Stage attempt was rejected without mutation. |
| Pet Stage on account 6 / Pet UID 2 | BLOCKED by legitimate eligibility | Production Pet is level 1/stage 0; game config requires Pet level 2 and item 154 ×3 for the first Stage. Inventory has no item 154. No production currency/item/Pet state was changed to bypass this. |
| Full PostgreSQL-backed suite | PASS | `tests-with-postgres.log`: 76 tests, 0 skipped, 0 failures. |

## Battle root cause and fix

Quest 10007 invokes `GameGuideMgr.secondBattle()` and the shipped Lua configuration requests embedded battle group 99999. `MonsterGroupManInfo.dat` defines group 99999 with enemy template 999994, group code `train99999`, and 37 EXP. `MonstrosityInfo.dat` defines the enemy as level 1 with skill 541 and configured HP 224. The server's former type-5 battle validation recognized only group 99998, so a valid quest battle was rejected as `group_id_mismatch`.

The server now resolves type-5 tutorial groups from `server/config/tutorial_battle_groups.json`, verifies the mapped quest is active, and builds enemy/EXP payloads from the client tables. It records the battle group and validates its lifecycle before advancing the mapped quest objective. `BATTLE_GROUP_MATRIX.md` inventories configured battle groups; only groups with demonstrated Lua callers and authorization mappings are marked implemented.

The first production attempt exposed a second client-side cause: `secondBattle`'s battle callback did not call `BattleMapMgr.sendGameOver`, so the server never received request 263 and the quest remained active. The callback now reports the actual battle result and Pet HP data. On Waydroid the resulting flow completed through the normal Victory screen and scene exit.

## Pet Stage root cause and implementation

The client sends Pet training Stage advance as request 1038 with Pet UID; ACK 1032 contains code, UID, and new Stage. The TCP dispatch previously had no handler for 1038 and persistence had no atomic Stage-advance path. The new handler uses `PetAdvanceInfo`, `ConsumeElementInfo`, and `PokemonInfo` configuration, locks character/Pet/inventory rows, checks ownership, level, max Stage, configured costs and balances, deducts the configured gold/diamond/items and updates `pets.training_stage` in one transaction. It returns success only after commit. QueryPets reads the persisted Stage.

Test database integration exercised success and an ineligible follow-up attempt. Production Pet UID 2 was inspected read-only before and after the battle; it remains template 1, level 1, exp 0, training stage 0, evolution 0, skills `[981, 2801, 0, 971]`, formation slot 0. Production character balances and inventory were preserved.

The live account could not perform the Stage upgrade through the UI because it lacks the configured level and material requirements. Therefore end-to-end production Pet upgrade persistence is not claimed as runtime-verified. This is an eligibility block, not a missing-Stage serializer error.

## Production integrity and runtime

- Exact database identity: `monster2_db`, role `monster2`.
- A pre-runtime custom-format backup is at `monster2_db-before-runtime.dump`; `pg_restore --list` parsed its 83-entry TOC. It was not restored to a temporary DB during this run.
- No schema migration or manual SQL mutation was performed.
- Official launcher reported commit `8d0d6967acd69b85990b6a6003f227873c2cdefe`, dirty worktree, and database `monster2_db`/role `monster2`.
- Updated APK installed with `adb install -r`, preserving app data. SHA256: `a61f8ec0028703666824acc16faedae7779a5b1a2d8fb45f90903294f4ab6837`.
- Runtime screenshots and Android logcat are in this directory. TCP evidence is preserved in the task execution log; the final tracked official launcher session also confirms relogin and QueryPets ACK 3139.

## Remaining limitations

- Production Pet Stage UI action remains unverified until Pet UID 2 meets its actual level/material requirement through ordinary gameplay.
- This change implements the traced training Stage operation; it does not assert that every distinct Pet level-up, enhancement, evolution, or skill-change operation is implemented.
- The matrix inventories source-configured groups but does not claim every battle family has a handler; groups without verified caller semantics remain unimplemented.
- The server exited once during the manual runtime sequence; it was restarted using the official launcher. The final cold relogin was successful and recovered the existing character, Pet, and quest state.
