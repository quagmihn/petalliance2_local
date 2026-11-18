# Monster2 state synchronization and economy restoration

## Verified in this increment

- The baseline was captured in the private runtime directory before changes. The original launcher processes were HTTP 13826 and TCP 13827 in the main project checkout. The selected database was monster2_db. The live Waydroid account and character observed in login logs were 6 and 2. The dump SHA256 was f2a1449880bdc889f4365b180a3378cabf8301ce313dfbb3bb6fa5b77403a7b3. Archive parsing passed. The baseline APK SHA256 was 2957196b52dc2d86e87e1df8a5ab878aa0bf8f66c91407e17f2bff00af70f90f.
- Reward transactions previously updated only cumulative EXP. The client victory screen independently projects a level from its pre-ACK snapshot and reward list. ExperienceInfo sets the first two cumulative thresholds at 60 and 140. At a total of 60 EXP, the configured result is Lv.2 with 0/80 toward Lv.3. The server now updates level in the same transaction as quest, cell and clear EXP. Startup repairs existing levels below the configured threshold. Existing higher levels are preserved. Adventure ACK is followed by a 473 notification with committed values.
- The finished-Adventure handler previously returned an empty count. Clear masks were stored only on the current run, which was overwritten by a subsequent start. A per-character/per-Adventure clear table now accumulates the completed masks and backfills the latest legacy result. The real 3081 count and 1749 vectors populate the original map cache on login and after clear. TCP tests confirm a retry on the same run does not grant twice and starting a different run preserves the clear. Configured quest map unlock logic is retained. The complete server-side validation of each star goal is pending. The current code validates the four-bit wire range and stores the result reported by the original client.
- The Pet detail reused the original attribute formula, while formation and status totals summed serialized fc, which was zero. The Lua fallback reuses calPetFC with the current Pet and its bonds when base combat power is absent. The original active-slot sum excludes support Pet scores. Waydroid showed Tygnite and the deployed team both at 383 after a cold launch. The original attribute display showed HP 165, PHY ATK 93, PHY DEF 46, MAG ATK 59, MAG DEF 50 and SPEED 72. Request 1755 now persists primary formation slots atomically with ownership, duplicate, and configured level checks. TCP verifies a valid save and rejecting an unowned UID. Multiple-Pet sum is covered by the Lua test. Waydroid multi-Pet editing has not been verified.
- The English offline text is friendList18. ChatProcess showed it for every nonzero response to request 45, ACK 35. This server returns code 1 because relay is unavailable, including channel requests with no recipient. The revised client shows the generic protocol error and the server logs the reason and numeric target when available. This diagnoses the popup. Multiplayer presence and duplicate-session ownership remain unimplemented.
- The Pet upgrade UI opened at the reconciled character level and displayed its actual requirements, including Enhance +5 and a material count of 0/5. The upgrade, enhancement and evolution transaction paths remain pending.

## State contract

| Field | PostgreSQL or runtime authority | Server wire | Lua consumer |
| --- | --- | --- | --- |
| Level, cumulative EXP | characters.level, characters.exp | Login 773/2183 and Adventure-triggered 473 | CharInfo, Town status and level gates. AdvClearView is a projection against the pre-ACK snapshot. |
| Gold, diamonds, VIP | characters.gold, diamond, vip_level | Login, character-values 747, wallet 473 | CharInfo, status bar and wallet views |
| Pet attributes and power | Pet fields and static attribute config. Power is derived in Lua when base fc is missing. | QueryPets 3139 | PokemonInfo, PetEducationMgr and Pet detail |
| Formation and team power | pets.slot_index. Active members contribute derived power. | 1755/1756 and 1760/1774 | PokemonInfo and PetFormationMgr |
| Map unlock | characters.game_values.map_lock, updated by configured quest rules | 747 and quest commit response | CharInfo and map gates |
| Adventure clear and stars | character_adventure_clears, character_adventures active run | 2995, 3081, 1749 | AdventureInfo and WorldMapMgr |
| Quest status | quests | 26, 404, 726 | QuestInfo and mission views |
| Inventory | inventory | 37 and inventory notifications where implemented | Bag manager |
| Event claims and shop transactions | Pending | Existing unsupported request handlers return errors | Activity and shop views |
| Online state | TCP session identifiers. No presence registry. | Login and disconnect lifecycle | Network managers and social views |

## Remaining acceptance

[Event catalog](EVENT_CATALOG_MATRIX.md) records the shipped activity entries and unmapped claim routes. Event reward grants, shop transactions and simulated recharge were not implemented or exercised in this increment. ShopInfo, ShopPoolInfo, ShopReflashInfo, ActivityShopInfo and NormalRechargeInfo are readable, but price/currency selection, request identity, limits and rewards still need to be verified per route. Real payment services were not contacted.

The official launcher was restarted against monster2_db. Initial cold relogin showed Lv.3 at 180 cumulative EXP, one Lost Forest star and team power 383. A new Waydroid clear of Lost Forest then yielded 60 EXP. The live 2995/473/1749 sequence agreed with PostgreSQL at Lv.4 and 240 cumulative EXP. The victory UI showed Lv.4 and 0/120 within that level. The map showed one star and 1/10 progress, and Town showed Lv.4 and 383 team power. The battle preview also showed +16 Pet EXP, while the Pet's persisted EXP stayed at zero. Pet battle EXP persistence, all-scene level verification, complete star-goal validation, multi-Pet changes in Waydroid, and economy flows remain pending. The integration suite covers fresh character creation, the 60 EXP threshold, notification bytes, repeat clear requests, persistent stars and formation validation. All 74 tests passed against monster2_test_db.

The verified incremental APK is dist/monster2_state_sync.apk, SHA256 d16662df4492ec676399e1e0e6bacc11ad522e6a9077773c25d8b8c6c9ce1a6a. Runtime logs, baseline snapshot, private backup and Waydroid screenshots are under ~/.local/state/monster2-state-sync. Source edits include the database schema and reward/formation transactions, TCP dispatch, Adventure, Pet and chat handlers, PokemonInfo and ChatProcess Lua, the APK builder, and PostgreSQL/TCP and Lua regression coverage. The release also folds in the earlier locally tested launcher and gameplay changes needed by this checkout.

The verified source increment is commit `7317024024dce3b0c94092a1c39625254d862b5e` on GitHub main. Its tree matches the locally tested commit `e647c6f55dbcfdaf815c6edac17b183c7cee299c`.

After the final restart, cold device login returned the same Lv.4 character, 383 team power, and Lost Forest star. The private screenshot set includes the level-up dialog, victory, map, Town, Pet detail, Battle Team, upgrade requirements and cold relogin.
