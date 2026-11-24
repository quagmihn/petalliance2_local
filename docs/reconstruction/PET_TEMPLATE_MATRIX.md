# Pet template validation

| Check | Count | Source |
| --- | ---: | --- |
| Distinct Pet template IDs | 252 | PokemonInfo |
| Templates with valid starting skill pools | 194 | GeneInfo, GeneProbabilityInfo, PetSkillInfo |
| Templates with no configured basic attack in the starting pool | 58 | All selectable entries in the first skill pool resolve to 0 |
| Skill records | 3,730 | PetSkillInfo |
| Evolution records | 88 | PetEvoInfo |
| Equipment templates | 39 | PetEquipInfo |
| Distinct unresolved Pet template IDs referenced by awards or genes | 33 | AwardElementInfo and GeneInfo combined |

The 194 templates pass acquisition validation. The audit does not exercise
every appearance, evolution, equipment effect or skill in Android. The
acquisition check prevents the 58 unusable starting loadouts from being
persisted through an enabled reward. The authored templates remain readable
for analysis. Pet UIDs in formation refer to owned records and retain
level, Stage, EXP, skills, and equipment across a slot change.

## Follow-up across three local config snapshots

`Proto_Pet_Types.lua` defines use type 0 as Fight and 1 as Material.
Of the 194 valid starting loadouts, 191 belong to Fight and 3 to Material.
All 58 invalid entries are Fight and classified `MISSING_CONFIGURATION`.
Every available snapshot resolves their basic-attack pool to skill 0.
The checked encounter, award, fragment and evolution tables reference none
of these 58. There is no verified alternate attack to import. No skill
records were added or changed. Generate the per-template report with
`python tools/audit_pet_starting_skills.py`.

[Existing Pet inventory audit](PET_CATALOG.md)
