# Achievements and collection claims

AchievementInfo has 150 regular tiers and PokemonAchievementInfo has 25 collection rows. The server connects known persisted data (owned species, wallet, level, recharge history, Adventure clears, draw history and real star upgrades) to achievement eligibility. The 11 connected progress fields cover 55 regular tiers. Arena counters await actual battle settlement. Collection requirements compare owned species to the complete configured set.

Lists use 268/837 and 72/74. Claims use 328/485 and 73/67. Prerequisite tiers, reward references, claim state and achievement points are validated and committed with the configured grant under the same lock. Historical counters are reconciled only where matching database history exists.

Waydroid claimed Junior Trainer, achievement 1000. PostgreSQL recorded the ID, five diamonds and five achievement points. Regular and collection claims and duplicate rejection have PostgreSQL test coverage. Other cumulative event categories need their own validated producers.
