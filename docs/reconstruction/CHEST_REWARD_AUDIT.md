# Chest reward audit

The target APK has 251 usable Bag items with `ItemInfo.itemType=18`. Each `paramA` resolves to `DropInfo`. Its parallel `reNumber` and `count` vectors specify the reward groups and rolls per group. Each roll resolves `RewardInfo.element / nReward / probability` and then `AwardElementInfo`. The former server looked up `paramA` directly in `RewardInfo`, so a numerically valid ID could grant an unrelated reward. Selection chests (type 28) use `SelectableAwardInfo` and a choice index. They retain a separate validation path.

| Example | Previously incorrect or incomplete behavior | Configured result |
| --- | --- | --- |
| 199, evolution stone pack | One item 10004, an EXP Potion, from RewardInfo 1036 | Drop 1036, groups 1388–1397. Ten of each item 107, 108, 110, 111, 112, 114, 115, 120, 124 and 9. |
| 200, random ancient Pet | Direct reward lookup | One configured Pet from templates 115–118. |
| 201, ancient Pet bundle | Direct reward lookup | All four of templates 115–118, with separate owned UIDs. |
| 205, Rage book chest | Direct reward lookup | Roll among the configured books 20024, 20030, 20094, 20127 and 20458. |
| 215, diamond chest | Direct reward lookup | Configured weighted diamond outcomes 11, 111 and 1111. |
| 216, book material bundle | Direct reward lookup | Ten of item 11000. |
| 233, Custom Taurus Chest | Direct reward lookup | Drop 1063 resolves to Taurus template 212 and its configured gene. |
| 300, potion and material bundle | Direct reward lookup | Ten item 10004, 100 item 154 and 50 item 155. |
| 313, custom Pet chest | Skill book 20121 from the unrelated direct reward group | Configured gene-specific Pet variants, initialized from their original skill pools. |

236 Bag chest definitions resolve. Four reject unresolved Pet/gene dependencies (366, 385, 387, 388). Eleven require award classes without a verified grant contract (12000, 61106–61115). The client has separate treasure systems, including Gold Key 169 and the team TreasureBox protocol family. A literal “Gold Chest” opening in those systems remains unverified.

Inventory consumption, grants, Pet creation, counts and chest receipts commit together. The local Bag sends an operation key through the chest request's otherwise empty target string. The server rejects expired keys and repeated keys with different selections or quantities. A repeated committed key returns the saved result and current chest count without mutating owned rewards. The legacy request remains accepted with an empty target string and has no replay identity. The local client disables automatic resend for item use.

The PostgreSQL integration suite validates all 251 mappings, confirms the four-Pet bundle and proves that a repeated key leaves an additional unopened chest in the Bag. A Waydroid Bag click opened Custom Taurus Chest 233, the result showed SSS Taurus, and the TCP notification and test database recorded Pet UID 7324, template 212. Screenshots and the synchronized logs are in `artifacts/adventure-economy-20261126/`.

On the final APK after cold login, Custom Cancer Chest 240 opened through request 516 with a local operation key. ACK 526 succeeded, inventory count became zero, and notification 3141 carried Pet UID 7897, template 215. The persisted receipt records gene 10006. Evidence files are `qa-final-chest-description.png`, `qa-final-chest-result.png` and `qa-final.log`.

Machine-readable audit `artifacts/adventure-economy-20261126/content-audit.json` includes each chest's text, roll count, eligible weighted outcomes and blocker.
