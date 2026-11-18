# Quest graph

Source: binary `NewQuestInfo.dat`, parsed by `server/quest_config.py`; raw parent/child edges are in [quest_graph.json](../quest_graph.json) and all rows in [ALL_QUESTS.md](../ALL_QUESTS.md).

- Nodes: **747**.
- Configured child edges: **680**.
- Objectives retain original numeric event type/arguments. Natural-language semantics are not inferred if localization or Lua handlers do not establish them.
- Quest rows encode prerequisites/children, objective vectors, reward references and unlock map fields. They do not encode all feature flags or runtime requirements.
- Generated validation in `ALL_QUESTS.md` reports absent children, parent-child inconsistencies, cycles and missing RewardInfo references.

Current server handles selected tutorial/quest commit behavior. No assertion is made that every objective type or all 747 quest lifecycles are implemented. Implement objective adapters by discovered event type, validate every edge/reference automatically, and preserve the client’s actual status enum/reward lifecycle.
