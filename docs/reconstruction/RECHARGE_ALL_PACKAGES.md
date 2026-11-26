# Local recharge coverage

The existing simulated checkout uses package IDs and an order ledger, with no external payment. The twelve normal bonus/repeat SKUs across six prices pass PostgreSQL checks. The two entitlement packages M10001 and M10002 retain their configured duration, initial grant and daily claim. The feature runs through the official private profile.

| Bonus → repeat | Bonus diamonds | Repeat diamonds |
| --- | ---: | ---: |
| N2 → N3 | 160 | 80 |
| N4 → N12 | 800 | 480 |
| N5 → N6 | 1,600 | 980 |
| N7 → N13 | 4,800 | 3,300 |
| N8 → N9 | 8,000 | 5,600 |
| N10 → N11 | 16,000 | 13,000 |

Waydroid QA 834 clicked the N7 price tile, then the same tile twice for N13. The three commits increased diamonds from 419,190 to 430,590 and cumulative recharge from 1,696 to 10,693. Each genuine order has its own ledger entry. Prior Android evidence covers N2, N3 and both M-PASS products. Exact cooldowns and first-bonus rules are still read from the target configuration.

Pending · Android clicks for the other price tiers, authenticated delivery of N10/N11's advertised Wish Tree Seed, and evidence for any other recharge product family or milestone. Completed purchase, mail claim and earned milestone eligibility use separate state.
