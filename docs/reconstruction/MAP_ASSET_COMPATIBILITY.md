# Map asset compatibility

## Target APK assets

| Reference | Target resource | Configuration meaning | Compatibility |
|---|---|---|---|
| Adventure field code 1 | `apk_raw/unpacked/assets/res/Searching/env/cd/` | `AdvEnvironmentMgr` maps field 1 to `cd/`; Adventure 1 and 2 both configure field 1 | Native target assets; compatible |
| Adventure cell terrain/fog | `SceneInfo.dat` fields `terrRes`, `fogRes`, `isInitOpen`, `target` | Each cell is selected by the adventure's scene-number set and floor | Native target config; 30 cells per Adventure 1/2 |
| Lost Forest world-map node | `Map/WorldMap/icon/mzsl.png` | `map_node.txt` node 2, overview icon | Exact target resource reference |
| Secret Path world-map node | `Map/WorldMap/icon/smhg.png` | `map_node.txt` node 10, overview icon | Exact target resource reference |
| Adventure title | localization `fbname1`, `fbname2` | LOST FOREST, SECRET PATH | Exact target localization |

No newer-version asset replacement was used. The different `mzsl` and `smhg` node icons do not imply separate interior maps. Target configuration maps both names to Adventure field 1 and SceneInfo number 1. The cell data hash is `4903ac645bee7f4dcdb2ed2d18c952175307c4e84f3597cd45b4c77fbd7326e3` for both.

## Runtime limitation

The current official server process predates the local-recharge source commit and has not loaded the current workspace. We did not restart it because the required production backup restore test cannot be performed with the available PostgreSQL role. Thus the map identity findings are source/configuration verified, while the current Waydroid visual comparison and cross-map cold-relogin test are BLOCKED.
