# Item actions

| Client family | Entry | Eligibility and committed changes |
| --- | --- | --- |
| Silver bag, type 10 | 516 → 526 | A usable ItemInfo row with a positive `paramA` exchanges the selected stack quantity for configured silver per unit. Wallet 473 and Bag 112 show the committed amounts. |
| Gift or chest, type 18 | 516 → 526 | The usable row's `paramA` resolves RewardInfo and AwardElementInfo. Rewards and stack consumption commit together. The ACK contains the configured reward preview. |
| Pet EXP potion, type 19 | 516 → 526 | The existing configured feed list, target UID, quantity and level cap apply. Pet and bag updates precede the ACK. |
| Fashion voucher, type 22 | 516 → 526 | A voucher resolves one FashionItemInfo appearance. The existing wardrobe path persists ownership and publishes 2105. |
| Pet shard, type 15 | 83 → 84 | PetPieceInfo supplies the required quantity and a GeneInfo key. GeneInfo supplies the Pet template. Deduction and Pet allocation share the transaction. Notifications 262 and 3141 precede the synthesis ACK. |
| Capture ball, type 9 | 15 → 198 | Ball and encounter configuration determine attempts and odds. See [the capture flow](WILD_CAPTURE_FLOW.md). |

The player's item-use error on November 24 was request 516 for item 187.
The target identifies it as Silver Bag(S), worth 100 silver. Separately,
the target identifies item 169 as Gold Key and names a separate Golden
chest in the localization data. The actual Golden chest interaction has
its own reward path and remains open.

Waydroid verified Silver Bag(M), item 188. The Bag showed the item,
removed it on use and displayed the success animation. PostgreSQL
recorded one consumed bag and 500 silver in `currencies_json.goldCoin`.
The regular Gacha gold balance is separate.

PostgreSQL also verified item 199 using its exact RewardInfo 1036, which
currently yields item 10004 for all three weighted alternatives. Some chest
display labels conflict with the shipped reward vectors. Claims follow
the records, with discrepancies retained in this report.

The test for shard 38012 spends five and grants one Catepii, template 26.
Concurrent requests against one recipe grant one Pet. The legacy stack
protocol has no request identifier to distinguish repeated use of multiple
owned units from separate intentional uses. Selectable boxes, equipment
instances and general furniture activation require further verification.
