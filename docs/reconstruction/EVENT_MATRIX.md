# Event matrix

The APK exposes multiple independent activity/event catalogs; they must not be merged by filename assumptions. Current request registry includes activity requests, but a request route is not a reward implementation. Event progress, eligibility, claim state, reset schedule, atomic grants, deduplication, UI notification, and relogin persistence remain unverified unless specifically covered by tests.

| Table | Rows | Runtime support |
| --- | --- | --- |
| ActivityInfoClient | 43 | Catalog only; claim/progress state requires protocol-backed implementation |
| EventInfo | 6 | Catalog only; claim/progress state requires protocol-backed implementation |
| EventListInfo | 459 | Catalog only; claim/progress state requires protocol-backed implementation |
| EventNpcInfo | 197 | Catalog only; claim/progress state requires protocol-backed implementation |
| ActivityShopInfo | 7 | Catalog only; claim/progress state requires protocol-backed implementation |
| RandomEventInfo | 3 | Catalog only; claim/progress state requires protocol-backed implementation |
| MapEventInfo | 220 | Catalog only; claim/progress state requires protocol-backed implementation |
| ExploreEventSInfo | 14 | Catalog only; claim/progress state requires protocol-backed implementation |
| FamilyEventInfo | 819 | Catalog only; claim/progress state requires protocol-backed implementation |

Detailed client text/params are in `ALL_EVENTS.md`. Expired official timestamps can be represented by explicitly configured local event schedules only after preserving event rules/rewards from client data.
