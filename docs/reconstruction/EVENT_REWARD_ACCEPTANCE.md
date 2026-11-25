# Event reward acceptance

## First recharge

`RechargeViewMgr` reads event 3 and directs the player to the mailbox.
ActivityInfoClient 3 resolves Pet template 208, ten units of item 20456,
640 diamonds and one item 188. The server derives personal mail from
the first eligible simulated ledger entry. Checkout retries retain one
receipt. Claims use 1054/1106, grant the configured rewards inside the
wallet transaction, and set the existing `first_charge_claimed` flag.
This uses only the private-local simulated checkout path.

PostgreSQL verified one ledger grant, one claim across concurrent requests,
exact item counts, one Pet with the original template ID, and a final
diamond balance of 800 for the 160-diamond package plus the reward.

On Waydroid, QA character 4 opened the First Recharge Reward mail and
claimed its attachments. ACK 1106 succeeded. PostgreSQL recorded
2,398 → 3,038 diamonds, Katty UID 37/template 208, ten Thunderwrath books
and one Silver Bag(M). Cold login restored the balance and Katty.

## Seven-day event

The seven daily gift records have types and IDs from SevenDayInfo. The
client measures elapsed 24-hour periods from character creation and closes
the event at eight displayed days. The server uses that same elapsed-time
window, including the one-time claim state for each eligible day. Tests
inject a clock and cover day 1, day 2, future day, expiry and replay.
Rewards follow the linked RewardInfo rows. Quest and purchase task
categories in the same screen still need independent adapters.

Waydroid day 1 showed the reward animation and completed stamp.
Request 391 returned success in ACK 390. The saved claim flag is
`seven1=1`; the reward included five Whittiger fragments, one potion
and one Milchick Cookie.

[Latest client evidence](EXECUTION_CHECKPOINT.md)
