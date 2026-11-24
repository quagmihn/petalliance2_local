# Gacha rarity

`PokemonInfo.Init` supplies the UI colors. `PetEducationMgr` supplies the
rank icons. The acquisition column counts valid skill pools.

| Tier | Client grade | UI color | Discovered | Valid for acquisition |
| ---: | --- | --- | ---: | ---: |
| 1 | C | Green | 67 | 16 |
| 2 | B | Blue | 28 | 27 |
| 3 | A | Purple | 41 | 38 |
| 4 | S | Gold | 47 | 45 |
| 5 | SS | Orange | 23 | 22 |
| 6 | SSS | Red | 46 | 46 |

The target APK orders orange before red. Panda is Grade A, tier 3. Senior's
only Pet in the supplied ordinary pool is tier 5 and falls outside the requested
Gold cap. Supreme's supplied ordinary pool contains only items. The Pet
catalog has usable templates in all six tiers. Usability does not establish
which machine can select a template or its probability.

Senior's four other directly linked groups contain zero Pet entries.
Supreme's normal-ten group has one tier 5 Pet. Its other directly linked
groups contain no Pet entries. The available links therefore provide no
eligible Senior Pet under the cap and no red Supreme Pet.

The local Senior cap now filters tier 5 and higher before any free, x1
or x10 ordinary draw. It keeps the configured relative item weights. In
the supplied pool the effective weights are 1,500 and 4,300, giving roughly
25.86% and 74.14%, respectively. Senior currently grants items only.
Supreme can accept known compatible Pet templates in a validated catalog,
including tier 6. The deployed Supreme catalog remains item-only pending
eligible award data. The scripted Panda tutorial receipt remains separate.

[Current pools and limitations](GACHA_POOL_MATRIX.md)
