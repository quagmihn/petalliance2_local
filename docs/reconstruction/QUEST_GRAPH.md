# Quest graph

Source: binary `NewQuestInfo.dat`, parsed by `server/quest_config.py`; raw parent/child edges are in [quest_graph.json](../quest_graph.json) and all rows in [ALL_QUESTS.md](../ALL_QUESTS.md).

- Nodes: **747**.
- Configured child edges: **680**.
- Objectives retain original numeric event type/arguments. Natural-language semantics are not inferred if localization or Lua handlers do not establish them.
- Quest rows encode prerequisites/children, objective vectors, reward references and unlock map fields. They do not encode all feature flags or runtime requirements.
- Generated validation in `ALL_QUESTS.md` reports absent children, parent-child inconsistencies, cycles and missing RewardInfo references.

Current server handles selected tutorial/quest commit behavior. No assertion is made that every objective type or all 747 quest lifecycles are implemented. Implement objective adapters by discovered event type, validate every edge/reference automatically, and preserve the client’s actual status enum/reward lifecycle.

## Implemented objective adapters

- `event_type=19` (“clear Adventure”, confirmed by `QuestInfo.guideFunc` and `checkAdventureFinished`) advances only when the configured Adventure returns a clear star, in the same PostgreSQL transaction as clear state and rewards.
- `event_type=18` (“clear world-map node”, confirmed by `QuestInfo.guideFunc` / `checkProcessMapSmallPoint`) now has a restricted trainer-node path for **55 objectives across 53 configured trainer groups**. The objective `finalID` resolves through target `map_event.txt` rows of type 0 to a `MonsterGroupManInfo` group; the map/node must exist in `map_node.txt` and be unlocked by the character. The request must match one unambiguous active quest, then a server-issued type-5 battle win advances progress. Other map event types are not included.
- Configured quest awards: 72 of 747 quest rows currently resolve a supported nonzero reward ID; missing references and unsupported reward kinds fail closed.

The map-node battle path has PostgreSQL/TCP integration coverage, including locked-node authorization, battle win, quest update echo and commit. It has not been verified in Waydroid.
