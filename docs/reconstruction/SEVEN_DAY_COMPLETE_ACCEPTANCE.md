# Seven-Day coverage and acceptance

`SevenDayInfo` contains 111 rows. The server implements 31 from five objective types. The valid rewards for all 31 rows passed config validation.

| Type | Rows | Authoritative requirements |
| --- | ---: | --- |
| Daily gift (1) | 7 | Character age and claim state |
| Adventure clear (3) | 5 | Configured difficulty clear flags from `character_adventure_clears` |
| Diamond offer (7) | 7 | Character age, claim state and configured diamond price |
| Character level (10) | 8 | Persisted level and claim state |
| Pet collection (36) | 4 | Count of owned Pets at the configured exact grade or any grade |

Requests use 391/390. Day 1 free gift and the 800-diamond day 1 offer both succeeded through Waydroid on QA 834. The paid reward created Pet 116 and the wallet fell by 800. A repeat claim was rejected. PostgreSQL tests advance a controlled clock through all seven days, checking correct prices, grants, repeat rejection and the seven-day expiry. The character creation timestamp remains the basis for the event on the playing account.

The other 80 objective rows require authoritative feature counters or gameplay systems. Extra server-saved counters, long-expired activity schedules and separate original recharge milestones remain to be reconciled before enabling those rows.
