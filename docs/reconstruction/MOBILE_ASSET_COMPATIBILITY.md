# Mobile asset compatibility

The target APK's canonical data equals the checked-in `apk_extracted` and `unpacked` assets for the eleven audited tables. The available comparison source `apk_raw/unpacked` is a different resource set. No independent phone export or second attached Android device was located. The comparison classifies records by ID and hash without installing native libraries or overwriting target files.

The nearby `apk_raw/petalliance2.apk` declares package `com.petalliance2.sea`, version code 7 and version name 1.0.0, SHA256 `e38982cb531a986eff0d3143f82f17cedca0c9a70253f585db4e2c724314e1d5`. Its Pokemon, Skill, PetSkill, Drop, Reward and Market tables hash to the target files, while the identically named files in `apk_raw/unpacked` differ. The alternate directory's APK provenance is therefore unresolved.

| Record type | Target | Alternate | Alternate-only | Changed shared IDs |
| --- | ---: | ---: | ---: | ---: |
| PokemonInfo | 252 | 257 | 5 | 215 |
| SkillInfo | 3730 | 3795 | 65 | 65 |
| PetSkillInfo | 3730 | 3795 | 65 | 0 |
| SkillTagInfo | 619 | 634 | 15 | 1 |
| GeneInfo | 269 | 296 | 27 | 5 |
| GeneProbabilityInfo | 1006 | 1062 | 56 | 6 |
| ItemInfo | 1776 | 1790 | 18 | 2 |
| FashionItemInfo | 300 | 300 | 0 | 20 |
| DropInfo | 1192 | 1234 | 46 | 56 |
| RewardInfo | 3211 | 3241 | 102 | 1207 |
| MarketInfo | 90 | 73 | 19 | 49 |

Alternate Pet IDs 20018–20022 have the expected candidate icons and both animation resource sets. Their alternate gene, probability and skill references resolve within that directory. The target has the underlying skill and probability IDs for 20018 and 20019, so they are the first overlay candidates. Target templates 20020, 20021 and 20022 require 5, 9 and 8 additional probability rows respectively, as well as 3, 4 and 4 additional starting skill IDs. All five lack an English name and description in the candidate locale. The source Chinese catalog contains their names, and the descriptions for 20018 and 20019 contain the placeholder `XXXX`.

The alternate skill set adds 65 records across 13 skill families. The alternate item set removes four target IDs. The alternate Market omits 36 target entries. Importing whole tables would change existing player-facing behavior. See the machine-readable audit for individual IDs, hashes and dependency paths.
