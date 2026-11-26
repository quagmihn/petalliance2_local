# Pet Star-up and evolution

Client request `1596` sends the target Pet UID and a vector of material Pet UIDs. The server reads the next row in PetStarUpInfo, locks the character and owned records, validates Stage and resource references, consumes the exact item stack and reserve Pets, and updates the same target UID. It sends inventory 112, each removed Pet 3138 and target state 3141 before ACK 1650. Reused material UIDs fail. Equipped, slotted and in-flight Pets are protected. Captured Pets retained by legacy battle receipts are also protected pending a history migration.

| Panda upgrade | Required Stage | Item 11000 | Reserve Pet requirement |
| --- | ---: | ---: | --- |
| 1 | 5 | 5 | Template 45 ×1 |
| 2 | 10 | 15 | Template 45 ×2 |
| 3 | 15 | 30 | Template 45 ×3 |
| 4 | 20 | 50 | Template 45 ×4 |
| 5 | 25 | 80 | Template 46 ×5 |

The target table configures five stars and 10% additional attributes per star. QA Android user 12 / account 848 / character 834 purchased all five upgrades on Panda UID 1347. It began upgraded to the Stage prerequisite by fixture with zero stars. Star-up consumed 180 items and 15 reserve Pets, and kept template 45 and fighting slot 1. STATUS opened automatically when selecting Panda. HP changed from 3,746 to 5,619 and power from 3,168 to 4,750. The five stars survived both the server and app restart. [Initial STATUS](../../artifacts/pet-economy-20261126/qa-panda-status-before.png) · [Five stars](../../artifacts/pet-economy-20261126/qa-star-5.png) · [Cold login](../../artifacts/pet-economy-20261126/qa-panda-after-relogin.png)

```sh
TEST_DATABASE_URL=postgresql:///monster2_test_db python server/admin/qa_account.py pet-star-materials \
  --account-id 848 --char-id 834 --pet-uid 1347 --to-max --dry-run
```

Use `--apply` for the configured shortfall on the isolated test database. Stage prerequisites are reported separately. Fresh evolution testing requires a selected authored branch, a reconnect-safe request, configured skill-choice persistence, and client validation after the template changes. In particular Panda 45 can branch to 46, 47 or 48 at level 31. Super evolution has additional Star and relation requirements. Requests 1247 and 729 still reject these paths.
