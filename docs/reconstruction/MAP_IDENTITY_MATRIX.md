# Map identity matrix

Target APK configuration audit, 2026-11-18.

| World | Node / map key | Localized name | Gameplay type | Adventure ID | Floor / grid | Scene IDs | Environment | Objectives / reward refs | Status |
|---|---|---|---|---:|---|---|---:|---|---|
| 1 | point 2 / `map2` | LOST FOREST (`fbname1`) | Adventure tile dungeon | 1 | 1 / 5×6 | 30 cells; `number=1` | 1 (`cd/`) | goals 1,2,3; clear reward 1; 60 EXP; prerequisite 0 | Config decoded; prior Waydroid Lost Forest runtime evidence exists; current code not loaded |
| 1 | point 10 / `map5` | SECRET PATH (`fbname2`) | Adventure tile dungeon | 2 | 1 / 5×6 | same 30 cells; `number=1` | 1 (`cd/`) | goals 4,5,6; clear reward 4; 62 EXP; prerequisite 1; node lock ID 4 | Config decoded; no Waydroid acceptance of this source |

The shared SceneInfo rows are byte-decoded equal in the parser output. `AdventureInfo` still keeps per-adventure state keyed by adventure ID, and the server emits `advID` from the request. Automated regression tests assert IDs 1 and 2 remain distinct while the original cell template is shared.

No separate Secret Path floor, scene number, terrain list or spawn layout was found in the target `AdventureInfo`/`SceneInfo` linkage. Do not label a substituted layout as implemented. If a later source version or lawful project asset set reveals a separate target-compatible Secret Path layout, compare its scene number, floor size, event references and asset version before considering it.
