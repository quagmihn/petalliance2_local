# Skill Book coverage

The target `PetSkillInfo` has 3,730 definitions. The 384 compatible book links now participate in Skill Gacha. `skill_config.py` checks the linked skill family, element or dedicated species, and slot before it consumes a book. Existing upgrade costs from the shipped config cover 2,360 edges, including shard-only paths.

| Skill type | Grade counts from `airpower` | Books |
| --- | --- | ---: |
| Active (0) | 1=46, 2=69, 3=54, 4=30, 5=10 | 209 |
| Rage/Profound (1) | 1=13, 2=32, 3=20, 4=9, 5=6 | 80 |
| Passive (6) | 2=26, 3=35, 4=34 | 95 |

The audit found no compatible grade-6 book link. Talent and support records use a different progression path. The Android QA session received books via Skill x10 and saved upgrades for Pet UID 1432, including 4694 in slot 0 and 2992 in slot 4. The battle effects of every definition, high-rarity Rage in an actual fight, and dedicated skill education still require validation.

Reproduce the catalog using `python tools/audit_pet_economy.py`.
