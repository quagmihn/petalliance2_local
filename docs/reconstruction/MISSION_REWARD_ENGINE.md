# Daily Mission progress and claim

Daily Mission uses the 18 visible type-2/reset-1 NewQuestInfo rows. Daily state turns over at 06:00 UTC+7, per GlobalConfig 6900. The event pipeline records durable daily and cumulative totals in the authoritative transaction. Nine of the 18 mission rows can receive progress from verified action adapters. Arena, unimplemented counters and objective filters still block the remaining rows. Quest list 785/26 includes daily state and changed entries are sent with 404.

Claim uses 400/726 and resolves the configured awardID via DropInfo. The character row lock covers eligibility, rewards, the claimed flag and daily activity points. The three milestone gifts use 1794/1798 and GlobalConfig 30/31. Structured objective filters require their own source-backed action adapter before their reward is enabled.

Waydroid completed and claimed mission 1011 after a paid stamina purchase, crediting 400 character EXP and 15 daily activity points in PostgreSQL. Integration tests cover duplicate requests, the persistent counter, and the correct reward. Milestone gift UI and non-daily Mission families remain pending.

## Quest 2005 and the DropInfo-only story rewards

The deployed client's automatic commit of quest 2005 returned 726/code 1 for an otherwise completed objective because the prior server attempted to look up 11002 in RewardInfo. The target DropInfo 11002 resolves to two of item 10002. The catalog audit found 349 story or side quest rows with this unambiguous DropInfo-only structure. The 72 overlaps continue to use the existing compatibility rewards, including the prior tutorial Pet. Full source parity for those overlaps is still pending.

The claim transaction now validates shared inventory limits before granting rewards or creating child quests. The PostgreSQL regression confirms overflow leaves the pending quest and child state intact. It also verifies child 20002, the configured item bundle and exactly one grant even if the original request is replayed from a fresh session.

On the official server, the installed APK relogged as `6:2:minh` and sent the same quest request. The client displayed two Exp Potion(S), PostgreSQL recorded quest 2005 as completed, activated 20002 and advanced `map_lock` from `9-0` to `10-0`. See `live-minh-quest2005.png`, the before/after TSVs and `release.log` in the evidence directory.
