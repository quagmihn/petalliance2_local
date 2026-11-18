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
- `event_type=18` (“clear world-map node”, confirmed by `QuestInfo.guideFunc` / `checkProcessMapSmallPoint`) supports all three observed target-client map-event families: type 0 trainer nodes (55 objective references, 53 groups) through a server-issued type-5 win; type 1 wild-monster nodes (30 references) through a configured `MonstrosityInfo` type-1 battle and win; type 2 gift/collect nodes (111 references) through the client’s `result=998` interaction followed by request 3133. All paths require an unambiguous active configured quest and an unlocked map/node. Gift claims are persisted idempotently in `world_map_node_claims`. Unknown event types remain rejected.
- Configured quest awards: 72 of 747 quest rows currently resolve a supported nonzero reward ID; missing references and unsupported reward kinds fail closed.

The map-node trainer, wild, and gift paths have PostgreSQL/TCP integration coverage, including locked-node rejection, configured payloads, battle win or idempotent collection, quest progress, and commit. They have not been verified in Waydroid.
