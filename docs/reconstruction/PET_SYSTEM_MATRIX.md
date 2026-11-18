# Pet system matrix

Pet-related config tables discovered by filename: **36**. Full record-level IDs are in [ALL_PET_SYSTEMS.md](../ALL_PET_SYSTEMS.md) and [pet_config_index.json](../pet_config_index.json). Selected starter/query/formation, Pet EXP feeding, Stage, and wild capture logic has code/tests. Do not conflate level/EXP, training Stage, enhancement, evolution, star-up, equip, skills, and equipment purification.

| Flow | Source evidence | Backend/runtime status |
|---|---|---|
| Pet query/serialization | QueryPets Lua decoder, PokemonInfo/MonstrosityInfo | Existing handler; tested legacy validation paths |
| Wild capture | GameGuideMgr + BattleCCSB; PokemonBallInfo; ItemInfo | Waydroid captured configured Catepii template 26; ball 1 consumed, Pet UID 3 persisted, quest 10008 progress committed |
| Pet EXP feed | Item UI, request 516/ACK 526, ExperienceInfo | PostgreSQL/TCP tested; actual Waydroid feed pending |
| Training Stage | PetAdvanceInfo and request 1038 flow | Separate persisted operation; runtime acceptance pending |
| Enhance/evolve/star/skills/equipment | Pet*Info tables and 374-request registry | Discoverable but per-flow backend coverage incomplete |

| Config table | Rows | Purpose/status |
| --- | --- | --- |
| ActivityPokemonAchievementInfo | 14 | Parsed source; per-operation use must be validated |
| BossKillAwardInfo | 2 | Parsed source; per-operation use must be validated |
| CustomSkillBookInfo | 5 | Parsed source; per-operation use must be validated |
| ElementSkillInfo | 8 | Parsed source; per-operation use must be validated |
| ExperienceInfo | 100 | Parsed source; per-operation use must be validated |
| LifeSkillCareerChange | 1000 | Parsed source; per-operation use must be validated |
| LifeSkillExp | 10 | Parsed source; per-operation use must be validated |
| MonstrosityInfo | 2142 | Parsed source; per-operation use must be validated |
| PetAdvanceInfo | 50 | Parsed source; per-operation use must be validated |
| PetBufferInfo | 125 | Parsed source; per-operation use must be validated |
| PetEquipBaptismInfo | 4 | Parsed source; per-operation use must be validated |
| PetEquipEffectInfo | 448 | Parsed source; per-operation use must be validated |
| PetEquipEffectSetInfo | 25 | Parsed source; per-operation use must be validated |
| PetEquipInfo | 39 | Parsed source; per-operation use must be validated |
| PetEquipPurifyExpInfo | 4 | Parsed source; per-operation use must be validated |
| PetEquipPurifyInfo | 4 | Parsed source; per-operation use must be validated |
| PetEquipRestorePurifyInfo | 4 | Parsed source; per-operation use must be validated |
| PetEquipRestoreStrengthenInfo | 4 | Parsed source; per-operation use must be validated |
| PetEquipStrengthenInfo | 4 | Parsed source; per-operation use must be validated |
| PetEvoInfo | 88 | Parsed source; per-operation use must be validated |
| PetFreedomAwardGroupInfo | 31 | Parsed source; per-operation use must be validated |
| PetFreedomAwardInfo | 273 | Parsed source; per-operation use must be validated |
| PetFreedomStarpointInfo | 25 | Parsed source; per-operation use must be validated |
| PetPieceInfo | 103 | Parsed source; per-operation use must be validated |
| PetResetStarInfo | 5 | Parsed source; per-operation use must be validated |
| PetSkillInfo | 3730 | Parsed source; per-operation use must be validated |
| PetStarUpInfo | 275 | Parsed source; per-operation use must be validated |
| PetStrengthenInfo | 400 | Parsed source; per-operation use must be validated |
| PokemonAchievementInfo | 25 | Parsed source; per-operation use must be validated |
| PokemonBallInfo | 3 | Parsed source; per-operation use must be validated |
| PokemonInfo | 252 | Parsed source; per-operation use must be validated |
| PotentialSkillInfo | 54 | Parsed source; per-operation use must be validated |
| SkillInfo | 3730 | Parsed source; per-operation use must be validated |
| SkillPlay | PARSER_BLOCKED | Parsed source; per-operation use must be validated |
| SkillTagInfo | 619 | Parsed source; per-operation use must be validated |
| SkillTemplateInfo | 273 | Parsed source; per-operation use must be validated |
