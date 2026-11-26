# VIP 20

The installed target configuration has VipInfo ID 21 for rank 20, with threshold 160,000 in the recharge table's units. GlobalConfigAddInfo 55 sets the maximum wire ID to 21, and the client displays `viplevel` from that row. All 21 configured privilege drops resolve through DropInfo, RewardInfo and their template references. Paid local orders update recharge total, VIP points and any newly reached configured rank in the same transaction. Ties select the highest reachable rank. Previously stored higher ranks are retained.

Waydroid on QA character 834 displayed VIP 20 and its privilege panel. CLAIM sent 61 and received ACK 60 after awarding Katty (template 208), items 41 ×7 and 155 ×7, and the unidentified badge 50057. PostgreSQL retains claimed ID 21, and replay rejection is integration-tested. The previewed VIP perk descriptions also refer to unrelated game modes whose mechanics still require verification.

The `vip-max` command requires an explicit account and character. The QA rank and points were set separately from the payment ledger. A production dry run for account 6 / character 2 found VIP 15 and 999,999,999 existing points. The target is VIP 20 with the same points. The player rank remains 15.

```sh
MONSTER2_VIP_PLAY_DATABASE_URL='postgresql://monster2@/monster2_db?host=/run/postgresql' \
  python server/admin/qa_account.py vip-max --play --account-id 6 --char-id 2 --dry-run
```

An authorized apply uses `--apply --restored-dump <validated-dump> --rollback-file <new-path>`. The tool checks the archive's database identity and writes a private snapshot before mutation. `--rollback <snapshot>` verifies the current rank, purchase total and claims before restoring the previous VIP fields. The same apply and rollback paths passed on the test database. [VIP panel](../../artifacts/pet-economy-20261126/qa-vip20-privilege.png) · [Katty reward](../../artifacts/pet-economy-20261126/qa-vip20-claim.png) · [Completed after cold login](../../artifacts/pet-economy-20261126/qa-vip20-after-relogin.png)
