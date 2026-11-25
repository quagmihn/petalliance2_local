# Wild encounter and capture

The production trace for Wise Arena Adventure 3 showed request 136 with
`battleType=2`, `battleTypeID=111` and `subID=0`. The old server rejected
type 2 with ACK 210/code 1. Cell 111 references DisposableInfo 7. The Lua
overlay uses that record's `eventType=2` and `eventRandomID=1` to display
MonstrosityInfo 1. The server now resolves the same IDs. This encounter's
capture count is zero and its battle reward advertises 16 Pet EXP.

World-map wild battles use type 1 and carry a MonstrosityInfo ID. When the
active quest and unlock prove the authored node, its configured capture
count and validated acquisition template enable the capture UI. Request
15 carries the Pet template ID and ball item ID. The latest issued battle
provides the encounter identity. PostgreSQL validates ownership, eligible
rarity, remaining attempts, ball stock and Pet capacity before deduction.
A failed roll spends one ball and decrements one attempt. Success grants
the configured Pet and its owned UID. A repeat of a completed successful
request returns the same Pet without spending another ball.

The framed integration exercises locked node, wrong sub-ID, wrong template,
failure with attempts remaining, success, and accepted replay. It verifies
two attempt records and one owned Pet. It also verifies Wise Arena's
persisted one-time encounter replacement. Failed attempts have no request
nonce in the target wire format. Catch-rate activity modifiers and red-tier
rates require additional source evidence.

Waydroid fought cell 111 in Wise Arena. ACK 210 accepted wild template
reference 1, ACK 186 completed the battle with 16 Pet EXP, and the
Adventure persisted the fired event before the portal exit. Capturing
at an eligible world-map node still needs its own Android run.

[Runtime checkpoint](EXECUTION_CHECKPOINT.md)
