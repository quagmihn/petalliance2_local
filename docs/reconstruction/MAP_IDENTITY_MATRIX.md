# Map identity matrix

The unseeded Waydroid run confirmed two authored floors for Wise Arena
(Adventure 3). It used Panda's Slash, traversed the configured floor link,
defeated the trainer, and persisted star mask 14 plus the configured 64
character EXP and two balls. The gold/chest objective still needs a complete
pickup run. See the [execution checkpoint](EXECUTION_CHECKPOINT.md).

**Current layout.** `SceneInfo.number` identifies the Adventure. Lost
Forest and Secret Path share field type 1 and 5×6 dimensions. Lost Forest
uses authored cells 1–30 and trainer 15 / group 1. Secret Path uses authored
cells 31–60 and trainer 44 / group 2. Both authored grids have Waydroid
clear screenshots. The export and the server use the corrected join.
[Map generation analysis](MAP_GENERATION_ANALYSIS.md)

## Expanded asset and runtime audit

The 24 locally available APK archives and all three extracted trees contained one identical AdventureInfo and SceneInfo pair. AdventureInfo.dat SHA256 is `4d0cfd0a0ef83b1560f51a57eabedcc73211b110d7b17bd256439128141107cc`. SceneInfo.dat SHA256 is `8fe50ef01642d1ff814522d9ad7e36f33a7914d795a912603fb29e0063cbb598`. These include the raw APK and the locally built generations. No distinct original Secret Path floor was found, and no substitute was introduced. Publisher intent and any unavailable alternate resource set remain unverified.

Cold Waydroid login restored the Secret Path world node and existing star total. The Senior Gacha guide gate prevented a fresh map entry/clear comparison on the deployed build. **BLOCKED** for per-map encounters, exit and reward acceptance in this run. Prior evidence and configuration identities follow.

Target APK configuration audit, 2026-11-18.

| World | Node / map key | Localized name | Gameplay type | Adventure ID | Floor / grid | Scene IDs | Environment | Objectives / reward refs | Status |
|---|---|---|---|---:|---|---|---:|---|---|
| 1 | point 2 / `map2` | LOST FOREST (`fbname1`) | Adventure tile dungeon | 1 | 1 / 5×6 | 30 cells; `number=1` | 1 (`cd/`) | goals 1,2,3; clear reward 1; 60 EXP; prerequisite 0 | Config decoded; prior Waydroid Lost Forest runtime evidence exists; current code not loaded |
| 1 | point 10 / `map5` | SECRET PATH (`fbname2`) | Adventure tile dungeon | 2 | 1 / 5×6 | same 30 cells; `number=1` | 1 (`cd/`) | goals 4,5,6; clear reward 4; 62 EXP; prerequisite 1; node lock ID 4 | Config decoded; no Waydroid acceptance of this source |

The shared SceneInfo rows are byte-decoded equal in the parser output. `AdventureInfo` still keeps per-adventure state keyed by adventure ID, and the server emits `advID` from the request. Automated regression tests assert IDs 1 and 2 remain distinct while the original cell template is shared.

No separate Secret Path floor, scene number, terrain list or spawn layout was found in the target `AdventureInfo`/`SceneInfo` linkage. Do not label a substituted layout as implemented. If a later source version or lawful project asset set reveals a separate target-compatible Secret Path layout, compare its scene number, floor size, event references and asset version before considering it.
