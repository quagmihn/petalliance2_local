# Map generation and save boundaries

## Wise Arena floor two

The authored scene contains Trainer scene 96 and disposable scene 111,
which resolves through event 7 to wild MonstrosityInfo 1. Waydroid
observed the Trainer step one tile and start its configured fight, then
finished the separate Bashful fight at scene 111. The one-time event
is stored against Adventure 3. The run exited through the authored portal
and received the configured EXP and two balls.

The disposable monster and the Trainer remain distinct encounters.
The first reports zero capture attempts. World-map capture eligibility
derives from the linked quest node and the monster's capture count.
Lost Forest and Secret Path retain their independent authored cell sets,
Adventure IDs and save records.

Adventure entry 2996 returns ACK 3080 with the Adventure ID and a JSON state
containing floor-specific cell events and NPC shop rows.
`SearchingMapMgr.getDataFromServer` accepts those events only for the currently
selected Adventure ID. The client reads the floor count and goal references
from AdventureInfo, allocates each floor's grid, then overlays events by
scene ID, floor and coordinates. This wire contract carries no geometry seed.
Lost Tower uses its own floor relation and Pet state.

The earlier analysis conflated two fields. The client copies
`AdventureInfo.scene` into `SearchingMapMgr.fieldType` for presentation.
`SceneInfo.number` is the Adventure number. Lost Forest (1) and Secret
Path (2) share field type 1, with different authored 30-cell grids.
Their trainer cell IDs are 15 and 44, respectively. Wise Arena (3) gets
60 cells across two floors even though both floors use field type 1.

An exact floor/coordinate scan passes for 275 of 290 Adventures with
the Adventure-number join. The former environment join matched 22.
The remaining 15 records have placeholder coordinates (0,0). Entry
fails before creating a run for those records. The map payload still
leaves NPC shop entries empty.

Cell claims and clear transactions now compare the requested ID with the
locked current run. A stale socket cannot apply one Adventure's rewards
or clear flag to a different Adventure. PostgreSQL regression tests
exercise stale requests across Adventures 1 and 2.

In the earlier Waydroid checkpoint, QA character 7 selected Secret Path,
defeated a trainer on the erroneously shared grid and walked to the
portal. The world map showed a star. PostgreSQL recorded Adventure 2 with
mask 12, 62 character EXP and item 2 ×1. Other masks and Adventure IDs
were unaffected by this clear. Lost Forest entry and encounters have prior
Android evidence. A framed TCP test now checks separate sequential clears
for Adventures 1, 2 and 3 using synthetic victory masks. It verifies entry
cell counts, rejects Adventure 1's trainer in Adventure 2 and checks the
distinct persisted rewards and star masks.

[Asset comparison and map IDs](MAP_IDENTITY_MATRIX.md)
