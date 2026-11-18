# Event coverage

| Event family | Evidence/config | Current server state | Acceptance |
|---|---|---|---|
| World-map event-18 trainer node | `map_event.txt` type 0; configured trainer group and node lock | Authenticated configured battle, win updates objective | PostgreSQL/TCP tests; Waydroid pending |
| World-map event-18 wild node | type 1; configured MonstrosityInfo | Server-issued wild battle; only win advances objective | PostgreSQL/TCP tests; Waydroid pending |
| World-map gift/collect node | type 2; client sends result marker then 3133 | Configured unlocked-node validation and idempotent claim | PostgreSQL/TCP tests; Waydroid pending |
| Adventure tile event | SceneInfo event types include pickup, obstruction, portal, trainer, monster, switch and exit; auxiliary text configs drive behavior | Selected Adventure cell reward, event record and clear paths | Partial protocol/DB tests; no Secret Path Waydroid run |
| Daily login / sign-in | client managers and protocol request catalog | Basic response stubs or incomplete persistence | Not verified |
| Seven-day rewards | event manager/protocol | Fail-closed ACK; no reward grant | Explicitly unsupported |
| Achievements / activity / limited-time events | `EventInfo`, `EventListInfo`, activity managers, protocol catalog | Catalog/eligibility/claim flows incomplete | Not verified |
| VIP / login calendar / online time | client managers and protocol messages | Incomplete | Not verified |
| Event shops | event catalog and shop managers | Incomplete | Not verified |

No event is counted as implemented solely because its catalog loads or a request receives an ACK. Claims that do not have a configured, validated reward currently fail closed.
