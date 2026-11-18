# Game mode registry

Status as of 2026-11-18. Families below are separated by their target APK scene and state/configuration path, not by display title alone.

| Family | Client entry / scene | State/config source | Mechanics evidenced | Current server coverage | Runtime status |
|---|---|---|---|---|---|
| Town / character hub | `TownScene` | character profile, Town assets, NPC config | character/NPC interaction, menus, portals | login and character persistence; selected NPC/gameplay flows | Waydroid login verified; broad hub actions incomplete |
| World map | `WorldMapMgr.show` | `map_list.txt`, `map_node.txt`, `map_event.txt`, route assets | route graph, node lock, stage/explore/event node dispatch | event-18 trainer/wild/gift subset | Previous play session verified Lost Forest; current source not loaded in live process |
| Adventure tile dungeon | `SearchingScene` → `SearchingMapMgr.createSearchingMap` | `AdventureInfo.dat`, `SceneInfo.dat`, `EventInfo`, pickup/obstruction/portal/trainer tables, `Searching/env/{cd,ysd,sm,by,sn}` | floor grid, fog, tile movement, pickups, battle, switch, portals, objectives/stars | request 2996 sends configured SceneInfo cells; select rewards/events/clear support | Config/protocol tests; no current Secret Path Waydroid run |
| Lost Tower | `LostTowerScene` / `LostTowerMgr` | `LostTowerInfo`, `FloorRelationInfo`, `LostTowerMonster*`, `PointLostTowerInfo`, `LostTowerAwardInfo` | generated floor grid, steps, floors, portals, tower battles | incomplete | Not runtime verified |
| Common-dungeon/test-map framework | `DungeonMapMgr.creareDungeon`, `DungeonTestMapMgr` | runtime map parameters and editor test UI | generic grid construction for caller-provided dimensions/events | framework exists client-side; no equivalent complete production content path verified | Unsupported pending a real caller/content reference |
| Copy-map battle board | `CopyMapMgr` | map-family terrain components and caller parameters | battle-board layout/rendering | client rendering only in this audit | Not runtime verified |
| Battle scene | `BattleScene` | battle type/group, configured monsters, previous-scene return path | turn battle, battle result and return-to-caller-scene | selected PvE/tutorial paths | Prior tutorial and wild capture verified; broad group coverage unverified |
| Activity/event panels | event-specific managers and `EventProcess` | event catalogs, daily/achievement/activity data | eligibility, progress, claim, reward | selected map-node claims; many generic empty/error responses remain | No broad Waydroid claims verified |
| Recharge / month cards | `PurchaseViewMgr`, `PayConfig` | `NormalRechargeInfo`, `MonthCardRechargeInfo`, `FirstRechargeAwardInfo` | local order selection, package reward, entitlement/daily claim | local TCP request 90 implemented in workspace; month daily claim incomplete | Actual click blocked: official server is stale and production schema absent |
| Regular and NPC shops | `MarketInfo`, Adventure NPC shop managers | Market/Shop catalogs and currency | catalog, price, limit, atomic grant | Market purchase previously Waydroid verified; other catalogs incomplete | Partial |

## Identity finding: Lost Forest and Secret Path

Target English localization maps `map2` to LOST FOREST and `map5` to SECRET PATH. In world 1, their stage nodes are respectively Adventure 1 (point 2) and Adventure 2 (point 10). `AdventureInfo` preserves distinct prerequisite, level, goal and reward records, but **both Adventure 1 and Adventure 2 point to `scene=[1]`**. Both therefore select the same 30 `SceneInfo` cells, same 5×6 dimensions, and same environment code 1 (`Searching/env/cd/`) in the original target APK data. The matching SceneInfo row-set SHA256 is `4903ac645bee7f4dcdb2ed2d18c952175307c4e84f3597cd45b4c77fbd7326e3`.

This establishes that the observed common tile layout is present in the target APK's configuration. It does **not** prove that the publisher intended the maps to look alike, but there is no separate Secret Path layout in these references to load. The current server returns the requested Adventure ID and uses only that Adventure's configured scene references; it does not remap ID 2 to ID 1. No arbitrary map substitution was introduced. Progress objectives and rewards remain distinct in configuration.

The world-map icons are separate: node 2 uses `mzsl`; node 10 uses `smhg`. These are overview-node resources and do not supply a different SearchingScene floor layout.
