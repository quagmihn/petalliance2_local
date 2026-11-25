# Adventure Trainer rules

The Adventure client uses authored facing, alert state, floor identity and
traversability. A passive move onto a side-adjacent or front-adjacent tile
leaves the Trainer idle. An adjacent tap uses the original click handler.
An automatic encounter requires the player to be two cardinal cells ahead.
The intervening tile must be an empty, revealed and reachable tile. The
Trainer moves there before requesting battle. Its original scene ID follows
the actor, so the server still resolves the same group after the move.

`AdvCharMgr` calls `LtMapOption.isReachable` and checks the intervening
tile's event and live occupancy. The target client represents walls, rocks,
water and switches through these map checks. The available Adventure search
path did not establish a separate directed-edge table.

The server scopes a battle to the active Adventure and authored scene.
Completed cells reject repeat issuance during the same run. The server
persists one-time battle overlays and sends their configured finish event
on a new Adventure entry. Ordinary repeatable Trainers can be encountered
again in a new run. The client delays Trainer cleanup until ACK 210 accepts
the encounter. A rejection releases movement, restores the cell's alert
state and suppresses automatic retries from the same standing tile.

The coordinate harness exercises adjacent inactivity, a direct tap outside
the facing direction, one-step approach, out-of-range tiles, blocked and
occupied cells, previously defeated cells and rejection recovery. The
PostgreSQL battle fixture retains ownership and replay checks.

[Runtime checkpoint](EXECUTION_CHECKPOINT.md)
