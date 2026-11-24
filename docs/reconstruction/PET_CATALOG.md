# Pet catalog

The target APK contains **252 PokemonInfo templates**, 269 GeneInfo rows,
1,006 skill-probability groups, 3,730 PetSkillInfo rows, and 88 PetEvoInfo
entries. The registry exports rarity, element, growth and level-cap fields,
localization and icon references. A GeneInfo record may exist without a
matching Pet template in this target APK.

| Entity | Identity on the wire | Persistence |
| --- | --- | --- |
| Pet template | `pokeID`, from PokemonInfo | Stable static ID |
| Owned Pet | `objID`, serialized as the owned UID | `pets.pet_uid` and its owning character |
| Skills | Four active slots from the template's GeneInfo groups, plus passive records | `skills_json` and `passive_skills_json` |
| Progression | Level, EXP, Stage, star, evolution, and slot | Fields on the owned Pet |
| Formation | Owned Pet UIDs in the primary and support vectors | `pets.slot_index` |

Panda is `PokemonInfo[45]`, `petname45`, rarity 3, displayed as Grade A.
The later skill guide tests `pokeID == 45`. Guide 10010 announces Panda by
name, so the scripted draw awards template 45 directly. A new owned UID is
allocated and sent in 3141 and the detail in 1561. The quest records the grant
only after the Pet, the four skill slots, and the free attempt persist.

The missing-reference audit found two GeneInfo rows and 33 AwardElementInfo
Pet references whose template IDs are absent from the target PokemonInfo.
They are exported for comparison, with no guessed template substitutions.
Starting skills are valid for 191 Fight and three Material templates. A
further 58 Fight templates lack a basic attack in all three local snapshots.
[Gacha evidence](GACHA_CONTENT_MATRIX.md) · [Reference matrix](CONTENT_REFERENCE_MATRIX.md)
