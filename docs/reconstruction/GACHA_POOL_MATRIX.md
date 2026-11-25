# Gacha pool linkage

## Official local pools

`server/config/local_play_draw.json` supplies three pools with 24 enabled
reward rows. Each normal pool has explicit local weights totaling 10,000.
Packaged tables supply the machine modes, prices, cooldowns, and valid
templates. The pack uses C=1 green, B=2 blue, A=3 purple, S=4 gold,
SS=5 orange, and SSS=6 red.

| Machine | Ordinary eligibility and rewards |
| --- | --- |
| Senior | Free, gold x1/x10. Pets at ranks 1–4; capture balls, cookies, essence, Soul Stone and Pet EXP potions. |
| Supreme | Free, diamond x1/x10. Pets at ranks 3–6; Master Balls and vouchers for the Silver Helmet and Black Iron Gun. Mount and furniture activation remain open. |
| Skill | Diamond x1/x10. Skill Shards and original active, profound and passive skill book templates. |

The APK retains the original Senior banner art that advertises C–SSS.
The local pool enforces C–S for every ordinary Senior Pet selection.

The one-time, quest-eligible Supreme free draw still grants Panda template 45.
The PostgreSQL integration covers ledger concurrency, replay and persistence.
Seeded 20,000-selection samples per machine validate the three weight vectors.
Waydroid recorded successful free, x1 and x10 actions on Senior and
Supreme, and x1 and x10 on Skill. Skill has no free action in the target.
Each recorded action returned ACK 1561 and logged the charged currency and
grants in PostgreSQL. [Runtime checkpoints](EXECUTION_CHECKPOINT.md)

## Packaged pool audit

| Evidence | Machines | Pools | Award rows |
| --- | ---: | ---: | ---: |
| Target configuration table | 3 | 17 | 27 |
| Directly referenced by normal, first, first-ten, normal-ten or guarantee fields | 3 | 12 distinct | 18 |
| Supplied ordinary catalog | 3 | 3 | 9 |
| Effective ordinary catalog with local Senior rarity cap | 3 | 3 | 8 |
| Older local substitute | 3 | 3 | 8 |

All 27 target award rows resolve their template references. Five groups are
outside the five direct field links. Supplied normal weights are validated
against 10,000 per pool. In the optional target-normal catalog the Senior cap leaves an effective
weight of 5,800, while both other machines retain 10,000. The local x10 rule uses ten independent
selections from the enabled normal group. The existing tutorial entitlement
uses the Lua evidence and a committed draw receipt separately. Pity
precedence, the regular x10 group behavior, cooldown interactions, Wish,
Dream and membership modifiers remain unverified.

[Detailed audit from the earlier checkpoint](GACHA_CONTENT_MATRIX.md)
