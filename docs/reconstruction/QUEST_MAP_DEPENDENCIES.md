# Quest and map dependencies

## Verified opening chain

| Adventure | Map node | Name | Prerequisite | Level | Goals | Clear reward | Server state key |
|---:|---|---|---:|---:|---|---:|---|
| 1 | world 1, point 2 (`map2`) | LOST FOREST | 0 | 1 | 1, 2, 3 | RewardInfo 1; 60 EXP | character + adventure ID 1 |
| 2 | world 1, point 10 (`map5`) | SECRET PATH | 1 | 2 | 4, 5, 6 | RewardInfo 4; 62 EXP | character + adventure ID 2 |

`map_node.txt` carries a separate world-node lock field: node 2 has lock ID 1 and node 10 has lock ID 4. Client `WorldMapInfo` builds route/node state from that field and the configured world-map route graph. A complete runtime explanation of lock ID 4 and its notification/UI refresh is still required before marking Secret Path unlock acceptance.

## Cross-reference rules

- Adventure ID selects the `AdventureInfo` row and is preserved in create/current/finish protocol state.
- Scene rows are selected only when `SceneInfo.number` is listed in that Adventure's `scene` vector and the row floor is within the configured floor count.
- Floor dimensions, objectives, prerequisite, EXP and clear rewards are read from the selected Adventure row.
- Map node display key/icon and lock are separately read from `map_node.txt`; a world map title does not choose the Adventure floor data.
- Target configuration for Adventure 1 and 2 intentionally/recurrently references the same scene number 1. Shared geometry is therefore source data, not a server fallback.
- Existing quest graph has 747 IDs and 680 configured child edges; see `QUEST_GRAPH.md` and `quest_graph.json`. Only source-established objective types should be activated; unresolved references remain blocked.

## Known blockers

1. No distinct Secret Path `SceneInfo` layout reference was found in target config.
2. World-node lock ID 4 and the client route-completion visual transition lack Waydroid acceptance against current source.
3. Broad quest-to-map unlock transition and cold relogin across these two maps are not validated.
4. A single generic successful Adventure ACK is not evidence that floor events, stars, clear rewards and child quests all run correctly.
