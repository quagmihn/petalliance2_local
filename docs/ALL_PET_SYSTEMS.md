# All Pet systems

Every listed table is decoded from the client configuration using its Lua XDat field declaration. Detailed rows are retained in the JSON companion.

- `PokemonInfo.dat`: **252 records**; backend status: config indexed, feature-specific protocol/runtime validation required.
- `PokemonBallInfo.dat`: **3 records**; backend status: config indexed, feature-specific protocol/runtime validation required.
- `PetAdvanceInfo.dat`: **50 records**; backend status: config indexed, feature-specific protocol/runtime validation required.
- `PetStrengthenInfo.dat`: **400 records**; backend status: config indexed, feature-specific protocol/runtime validation required.
- `PetEvoInfo.dat`: **88 records**; backend status: config indexed, feature-specific protocol/runtime validation required.
- `PetStarUpInfo.dat`: **275 records**; backend status: config indexed, feature-specific protocol/runtime validation required.
- `PetSkillInfo.dat`: **3730 records**; backend status: config indexed, feature-specific protocol/runtime validation required.
- `PetEquipInfo.dat`: **39 records**; backend status: config indexed, feature-specific protocol/runtime validation required.
- `ExperienceInfo.dat`: **100 records**; backend status: config indexed, feature-specific protocol/runtime validation required.
- `ItemInfo.dat`: **1776 records**; backend status: config indexed, feature-specific protocol/runtime validation required.
- `GeneInfo.dat`: **269 records**; backend status: config indexed, feature-specific protocol/runtime validation required.
- `AttributeChangeInfo.dat`: **30 records**; backend status: config indexed, feature-specific protocol/runtime validation required.

## Capture ball facts

`PokemonBallInfo` defines ball IDs and rarity probability vectors. `BattleCCSB.lua` order is `{2,3,1}`; `ItemInfo` IDs 1, 2, 3 are the actual Master/Para/Senior ball items. The catch UI's add button issues market item 201. Parsed `MarketInfo.dat` row 201 specifies item 1, `coinType=2` (diamonds), price 600. No starter quest award references those ball IDs.

## Runtime status

Pet EXP feed and tutorial Stage handlers have PostgreSQL integration coverage. A capture protocol handler and a live capture success still require separate implementation/runtime verification.
