# Adventure sweep acceptance

Quick sweep uses 1738 → 1741 and publishes 1749 with the current crown/counter state. It requires three stored crowns and a clear, compatible authored geometry, configured stage/feature eligibility and enough stamina. Batch limits and the Hero daily cap are read from the target configuration. The repeatable reward resolves `AdventureInfo.rewards → DropInfo`. Each sweep rolls again and grants its configured character EXP. Initial-clear and quest bonuses use their own flows. The available client contract establishes no sweep Pet EXP grant.

The validator enabled 270 of 275 Adventures with authored geometry. IDs 20049, 20073, 20076, 20078 and 20080 have unresolved DropInfo references 147, 219, 228, 234 and 240. The other 15 of the 290 catalog records lack geometry on this path. The local APK adds an operation key protected by the same database transaction. PostgreSQL verifies reconnect replay receives the earlier result without charging or granting again.

Waydroid QA tapped **SWEEP** and **SWEEP 10 TIME** on Puzzle (Adventure 7). The QA fixture already contained its three-crown record. Both results animated and both requests returned 1741/code 0.

| Result | Before | After x1 | After x10 |
| --- | ---: | ---: | ---: |
| Character EXP | 36116 | 36188 | 36908 |
| Stamina | 9789 | 9779 | 9679 |
| Gold | 4517944 | 4517954 | 4518056 |
| Sweep count | 0 | 1 | 11 |
| Crown mask | 15 | 15 | 15 |

The two actions granted eleven item 10002 and nine item 154 overall. The random gold outcomes varied across individual draws. Evidence `qa-sweep-single.png`, `qa-sweep-ten.png` and `qa.log` in `artifacts/adventure-economy-20261126/`.
