# Map generation and save boundaries

Adventure entry 2996 returns ACK 3080 with the Adventure ID and a JSON state
containing floor-specific cell events and NPC shop rows.
`SearchingMapMgr.getDataFromServer` accepts those events only for the currently
selected Adventure ID. The client reads the floor count and goal references
from AdventureInfo, allocates each floor's grid, then overlays events by
scene ID, floor and coordinates. This wire contract carries no geometry seed.
Lost Tower uses its own floor relation and Pet state.

Lost Forest (Adventure 1) and Secret Path (Adventure 2) share the authored
scene 1 grid of 30 cells in the available APKs. Their goal rows, required
progress and clear rewards belong to their respective Adventure ID.
Existing scene resources give no alternate Secret Path grid. The map
payload still leaves NPC shop entries empty.

Cell claims and clear transactions now compare the requested ID with the
locked current run. A stale socket cannot apply one Adventure's rewards
or clear flag to a different Adventure. PostgreSQL regression tests
exercise stale requests across Adventures 1 and 2.

In Waydroid, QA character 7 selected Secret Path, saw Goal and the shared
grid, defeated the authored trainer at scene cell 15, and walked to the
portal. The world map showed a star. PostgreSQL recorded Adventure 2 with
mask 12, 62 character EXP and item 2 ×1. Other masks and Adventure IDs
were unaffected by this clear. Lost Forest entry and encounters have prior
Android evidence. A consecutive full clear of both remains pending.

[Asset comparison and map IDs](MAP_IDENTITY_MATRIX.md)
