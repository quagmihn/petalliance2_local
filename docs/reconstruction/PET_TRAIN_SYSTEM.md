# Pet Train

Pet Train uses 1717/1699, 665/663 and 1694/1714. Gold cost, return percentage, caps and overflow values resolve through PetStrengthenInfo and GlobalConfig. A single additive `pets.development_json` column stores training and Relation state with an empty JSON default. Stats and combat power are recalculated using the same inputs fed by BattleBasicValueCalc. Committed updates refresh the Pet snapshot and wallet.

Waydroid trained Panda UID 1347 in HP. Gold moved 4,514,856 → 4,513,856, HP 5,619 → 5,650, power 4,750 → 4,755, and PostgreSQL saved `{"hpx":1}`. Regression tests cover the transaction and serialization. Reset and overflow have no Android acceptance in this checkpoint.
