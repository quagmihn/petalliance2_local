# Purchase flow matrix

| Flow | Client action/protocol | Workspace implementation | Production database/process | Waydroid acceptance |
|---|---|---|---|---|
| Normal recharge package | PurchaseViewMgr → local `PayConfig.payLocal` → request 90 / ACK 89; wallet notification 473 | Valid NormalRechargeInfo package, idempotency key, configured diamond grant, `simulated=true` transaction, atomic wallet update | `LOCAL_PAYMENT_SANDBOX` unset (off); `local_recharge_transactions` absent; HTTP/TCP process started before implementation commit | BLOCKED; actual PURCHASE not clicked |
| Month card/M-PASS buy | request 90 / ACK 89 | Configured initial diamonds and entitlement duration extension implemented | Same stale process/schema | BLOCKED |
| M-PASS daily claim | request 3102 / ACK 3103 | Not implemented; fail-closed response | No entitlement claim schema verified in production | BLOCKED |
| Market purchase | Request 577 / ACK 563 | Existing configured MarketInfo transaction and wallet/item notifications | Prior known runtime source includes earlier market purchase code | Prior Waydroid evidence exists for one market product; not a current-source retest |
| Other item/product/shop purchase types | Requests include 858, 481, 595, 398, 2042, 1242, 463 and Adventure NPC 310? per protocol registry | Catalog semantics/limits/notifications incomplete | Not deployed/tested as a family | BLOCKED/partial |
| Event shop | event-specific catalog and purchase requests | Not fully implemented | No production verification | BLOCKED |

## Recharge safety and deployment facts

- Live TCP and HTTP PIDs at check: 99836 and 99835, parent launcher PID 99789, `./run_all.sh production`.
- Both inherited `DATABASE_URL` values target database `monster2_db`, role `monster2` (Unix socket; no host/port in URL).
- `LOCAL_PAYMENT_SANDBOX` was unset in both processes. Server default is disabled. `PAYMENT_PROVIDER` was unset; local handler defaults it to local, but sandbox-off still rejects.
- The processes started at 15:26 local time, before commit `29ebf1b` at 16:45, so they have not loaded the recharge implementation.
- The current workspace launcher/schema/source are not live. Production role reports `CREATEDB=false`; `local_recharge_transactions` is absent.
- No real payment provider is called by the local client path. However, no actual purchase acceptance is claimed.

## Transaction evidence already available

The 99-test suite on `monster2_test_db` covers local request 90, simulated package rewards, duplicate-order idempotency, month-card initial grant/duration, disabled sandbox rejection and wallet notification/ACK ordering. This is PostgreSQL/TCP contract evidence only; the client PURCHASE click and resulting entitlement remain unverified.
