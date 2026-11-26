# Level 50 and VIP 20 acceptance

`minh` resolved uniquely to account 6 / char 2 on `monster2_db`, role `monster2`. The backed-up operation updated only the following fields.

| State | Before | After |
| --- | ---: | ---: |
| Level | 6 | 50 |
| EXP | 630 | 183,360 |
| VIP rank | 20 | 20 |
| VIP points | 999,999,999 | 999,999,999 |
| Stored stamina | 999 | 999 |
| Private freedom | absent | true |

`ExperienceInfo` sets the Level 50 stamina recovery max to 150. The change preserves the existing balance of 999. Immediately before and after the transaction, matching digests verified the remaining character data, Pet and formation, inventory, quest and Adventure rows, Gacha and recharge history.

Use the private snapshot named in `artifacts/freedom-level50-20261126/owner-progression.json` for a guarded rollback. The same rollback operation was tested on `monster2_test_db`. It checks identity, exact saved progression, recharge totals and VIP claims before touching any fields. This release made no schema migration.

Guarded rollback example, using the private snapshot path reported by the apply command.

```bash
DATABASE_URL='postgresql://monster2@/monster2_db?host=/run/postgresql' \
  python server/admin/set_local_progression.py --database monster2_db \
  --account-id 6 --char-id 2 --name minh --rollback /path/to/private/snapshot.json
```

## Waydroid runtime

The official launcher ran gameplay revision `822403b` for the second cold login. The profile displayed `minh`, player ID 2, Level 50, VIP 20, and the saved costume. Home loaded and the wardrobe opened on the playing account. Screenshots include `owner-level50-cold-relogin.png`, `owner-profile-restored-appearance.png`, `owner-home.png` and `owner-wardrobe.png`.

Login still issues a separate automatic request to commit invisible quest 2005. The expected `RewardInfo 11002` row is missing from the target catalog. The server rejected this request and the quest remained unchanged. The client showed a brief “Failed” toast.
