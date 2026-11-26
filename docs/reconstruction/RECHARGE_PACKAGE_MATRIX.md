# Local recharge package matrix

| Family | First-bonus SKU | Repeat SKU | Price in configured cents | Bonus / repeat diamonds |
| --- | ---: | ---: | ---: | --- |
| Normal | 2 | 3 | 99 | 160 / 80 |
| Normal | 4 | 12 | 499 | 800 / 480 |
| Normal | 5 | 6 | 999 | 1,600 / 980 |
| Normal | 7 | 13 | 2,999 | 4,800 / 3,300 |
| Normal | 8 | 9 | 4,999 | 8,000 / 5,600 |
| Normal | 10 | 11 | 9,999 | 16,000 / 13,000 |
| M-PASS | 10001 | 10001 renews | 499 | 400 up front, 160 per eligible day, 30 days |
| M-PASS | 10002 | 10002 renews | 999 | 800 up front, 320 per eligible day, 90 days |

The first six paired rows come from NormalRechargeInfo and the target's `checkRechargeFun`. ACK 655 used to always return an empty object, so the client kept showing first-bonus tiles. It now loads the relevant purchase timestamps from the local ledger. A locked transaction validates the active variant, inserts a simulated order, updates the wallet and VIP, and records the reward once. The store redraws package and entitlement state after checkout. The existing first-charge mail remains a separate claim. No weekly entitlement is defined by the installed MonthCardRechargeInfo.

PostgreSQL and protocol verified the six normal pairs and M-PASS renewal, duplicate-order rejection and daily claim. QA character 834 clicked N2 and N3 in Waydroid and received +160 and +80. The two M-PASS PURCHASE actions recorded 30 and 90 days, granted +400 and +800, and each client automatically submitted its eligible first daily claim (+160 and +320) through 3102/3103. The replaced daily subtitles now use the packaged quantities.

The N10/N11 Wish Tree banner needs separate bonus evidence. M-PASS Gacha and capture modifiers, further campaign claims and other package families remain open. [Normal first bonus](../../artifacts/pet-economy-20261126/qa-recharge-first-click.png) · [Repeat checkout](../../artifacts/pet-economy-20261126/qa-recharge-repeat-click.png) · [M-PASS activation](../../artifacts/pet-economy-20261126/qa-mpass-90-purchased.png)
