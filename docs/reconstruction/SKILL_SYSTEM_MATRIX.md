# Skill configuration and gameplay

| Client A-type | UI family | Config records | Valid book links | Configured upgrade edges |
| --- | --- | ---: | ---: | ---: |
| 0 | Ordinary active | 1,275 | 209 | 872 |
| 1 | Profound active | 455 | 80 | 324 |
| 6 | Passive | 1,020 | 95 | 380 |
| 7 | Support | 460 | 0 | 368 |
| 8 | Innate | 520 | 0 | 416 |

Skill record IDs and book IDs are separate. `airpower` carries the configured rarity used in Pet skill cost lookup. Valid books cover grades 1–5 for types 0 and 1, and grades 2–4 for type 6. Ordinary upgrades use matching skill-family books and shards; support and innate edges use the configured doubled shard cost. `PetSkillInfo` also exposes element, target parameters, priority, PP, energy, trigger and effect fields. The report records those rows through the canonical parser.

The prior Waydroid run verified Skill Gacha x1 and x10, Jumpkick replacement and Jumpkick 1711 → 1712. PostgreSQL covers passive and innate paths. Broad Android battle testing across skills, upgrade effects, crafting and evolution-unlocked choice remain open. A valid book or upgrade edge is configuration coverage, and needs its own battle-effect acceptance. [Prior evidence](EXECUTION_CHECKPOINT.md)
