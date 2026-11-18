# Gameplay acceptance

## Local draw trial

| Scenario | Status | Evidence |
| --- | --- | --- |
| Free, x1 and x10 with the local test pool | PASS on official test launcher | Absolute inventory and wallet updates arrive before result ACK. After the three calls PostgreSQL held 24 items and 124 diamonds. |
| Cooldown and insufficient funds | PASS on TCP and PostgreSQL | Both were rejected without another ledger row or reward grant. |
| Inventory after cold TCP relogin | PASS | A fresh authenticated socket fetched the committed 24-item stack. |
| Independent quest and Adventure setup | PASS on official test launcher | The fresh fixture returned its single active quest and its seeded Adventure clear. |
| Waydroid | APK launch PASS, gameplay BLOCKED | Signed test APK launched to LoginScene in user 10. The app stopped at its agreement screen. No draw or inventory interaction ran in Android. |

The targeted Lua module compiles and the full 105-test regression suite passed
with PostgreSQL. The independent fixture sets a known starting state. Live
battle, event claims, shop purchase and Android quest or map completion remain
separate acceptance scenarios.

| Scenario | Status | Evidence |
| --- | --- | --- |
| Draw rejection and persistent state | TCP and PostgreSQL verified | Request 1392 returned 1561/code 1. Wallet, inventory, Pet count and completed quest count matched the before snapshot. |
| Guide exit after rejected draw | Lua verified | The real guide code cancelled its pending result callback and released guide state. The regression test fails if rejection completes the quest or restarts the same guide immediately. |
| Guide exit after rejected draw in Waydroid | Blocked | The signed QA build reached the agreement screen in a separate Android profile. The QA profile made no request 1392. The existing Android profile and APK were restored to their prior launch configuration. |
| Independent QA resources | PostgreSQL verified | The fixture supports level, wallet and item inputs for fresh accounts. Tests cover dry-run, commit, rollback and rejection of the wrong database or a superuser. Scene prerequisites still apply. |
| Normal recharge, M-PASS renewal and daily claim | TCP and PostgreSQL verified | Existing tests cover balance changes, local ledger, entitlement extension, duplicate daily claim and expiration. Android PURCHASE and claim are still unverified. |
| Map progress | Prior partial Waydroid evidence | Last accepted relogin restored the Secret Path node and 2/10 stars. The current run did not add consecutive map clears. |
| Full tutorial, events and remaining shop flows | Pending | No new Android acceptance evidence. |

The full suite passed 103 tests with no skips against `monster2_test_db`. The QA APK launched in Waydroid and matched the production-style package/version 7 and signing certificate. See [EXECUTION_CHECKPOINT.md](EXECUTION_CHECKPOINT.md) for hashes, ports and the runtime configuration.
