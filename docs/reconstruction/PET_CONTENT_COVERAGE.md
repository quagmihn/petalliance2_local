# Pet and item coverage · 2026-11-26

| Domain | Target records | Verified scope |
| --- | ---: | --- |
| PokemonInfo | 252 | 191 combat and 3 material templates pass all positive-weight starting-skill checks. The remaining 58 are combat templates whose basic attack resolves to skill 0 across all three snapshots. |
| PetStarUpInfo | 275 | 251 rows join to PokemonInfo. The full primary-material path validates for 190 usable templates. Panda is the Waydroid acceptance case. |
| PetEvoInfo | 88 | Parsed branches, levels, costs, reward skill groups and destination references. Evolution transactions remain open. |
| ItemInfo | 1,776 / 25 item types | Market 90/90 links resolve. Bags, reward chests, skill books, fragments and appearance vouchers have existing transaction coverage. |
| Equipment and appearance | Five character equipment, 39 Pet equipment, 300 appearances | 291 appearance vouchers resolve. The existing wardrobe persistence passed previously. Equipment instance ownership, appraisal, equip/unequip and mount/furniture behavior remain open. |

Starter creation, capture, Gacha, rewards, synthesis and QA Pet grants use the same starting-skill initializer. The standalone admin grant previously created an empty loadout. The shared insert preserves acquired template, level, Stage and stars where the source supplies them.

Run `python tools/audit_pet_economy.py` for the per-template and per-skill counts. See [starting-skill evidence](PET_TEMPLATE_MATRIX.md), [item reference scope](ITEM_TEMPLATE_MATRIX.md) and [current checkpoint](EXECUTION_CHECKPOINT.md).
