# Content registry and runtime validation

The current server shares the parsed tables exposed by `client_config.table`
and the Pet definitions in `pet_config`. Stable template IDs remain in these
definitions. PostgreSQL stores owned Pet UIDs, formation slots, inventory
quantities, appearance selections, and transaction history.

Pet creation, captures and rewards now use the same starting-skill
validation. Both Gacha startup and RewardInfo resolution run that validation
before accepting a Pet award. It verifies the configured draw choices,
including every positive-weight skill ID and the basic attack. Existing
owned Pet records keep their stored skills.

The previous asset audit parsed 228 files and recorded nine parser blockers.
The existing machine-readable source indexes are under
`artifacts/content-restoration-20261119/catalogs/`. Availability in those
indexes means the definition could be read. Server use and Android
verification are tracked in [Content coverage](CONTENT_COVERAGE.md).

- [Pet templates and skills](PET_TEMPLATE_MATRIX.md)
- [Items, equipment and appearance](ITEM_TEMPLATE_MATRIX.md)
- [Gacha rarity](GACHA_RARITY_MATRIX.md) and [pool linkage](GACHA_POOL_MATRIX.md)
- [Shop content](SHOP_CONTENT_COVERAGE.md)
- [Map identity and generation](MAP_GENERATION_ANALYSIS.md)
- [Formation protocol and battle trace](FORMATION_BATTLE_TRACE.md)
