# Character level 15 and progression audit

## Verified character schema and EXP rule

The checked-in PostgreSQL schema stores the player level in
`characters.level` and cumulative role EXP in `characters.exp`. Other values
are separate (`game_values`, `quests`, inventory, pets, and homes). The live
PostgreSQL endpoint did not respond during this audit, so live columns, the
target row, and its current dependent data remain unverified.

The client `ExperienceInfo.dat` is a 100-entry, length-prefixed binary table.
`Proto_Pet_Types.lua` defines the row fields; parsing the bundled table yields
`roleExp=5080` for level 14 and `roleExp=6050` for level 15. The client UI uses
the previous level's cumulative threshold as the start of the current bar.
Therefore `level=15, exp=5080` is a valid level-15 boundary value.

`server/admin/upgrade_character_level.py` is read-only unless passed `--apply`.
It validates the live table columns and target account/character pair, locks
the character row, snapshots the character and rows in all discovered tables
with a direct FK to it, fsyncs the JSON backup, then updates only `level` and
`exp` in one PostgreSQL transaction. Re-running at the target state is a no-op.
Rollback restores only level/EXP and refuses if the character has progressed
since the migration. The script has not been applied because PostgreSQL was
unavailable; no account data was modified or backed up.

Once PostgreSQL is available, set `DATABASE_URL` and preview with
`PYTHONPATH=server python -m admin.upgrade_character_level`. Apply only after
reviewing the reported before/after values with
`PYTHONPATH=server python -m admin.upgrade_character_level --apply`. The tool
prints the durable backup path; rollback with
`PYTHONPATH=server python -m admin.upgrade_character_level --rollback <backup.json>`.

## Level-based unlock matrix from `ExpOpenLock.txt` and `ExpOpenLockInfo.txt`

These source tables list level unlock notifications. They do not encode quest
prerequisites, live state, or every feature's independent server-side gate.
For IDs 1–35, the translated feature label is from the bundled English
`tbl_lang` row `jsgn<ID>`. Features with required level at most 15 are eligible
for the level gate after the upgrade; level 16+ features remain locked. This
does not change `map_lock`, quest records, global-config requirements, or
per-feature state.

| Feature | Required level | Other requirements | Config source | Current state | Target state |
|---|---:|---|---|---|---|
| Bag | 2 | Not encoded in level table | ExpOpenLock ID 1 | Unknown; DB unavailable | Level gate met |
| Quest | 2 | Tutorial/quest state may apply | ID 2 | Unknown | Level gate met; quest state preserved |
| Wise Arena | 3 | Arena-specific state not audited | ID 3 | Unknown | Level gate met |
| Sign-in | 3 | Daily/server state not audited | ID 4 | Unknown | Level gate met |
| Tunnel | 4 | Map progression may apply | ID 5 | Unknown | Level gate met |
| Ruin | 4 | Map progression may apply | ID 6 | Unknown | Level gate met |
| Jungle | 5 | Map progression may apply | ID 7 | Unknown | Level gate met |
| Puzzle | 6 | Map progression may apply | ID 8 | Unknown | Level gate met |
| Elite stage | 6 | Main-story/map progression may apply | ID 9 | Unknown | Level gate met |
| Trap | 7 | Map progression may apply | ID 10 | Unknown | Level gate met |
| Elite trap | 8 | Map progression may apply | ID 11 | Unknown | Level gate met |
| Broken road | 10 | Map progression may apply | ID 12 | Unknown | Level gate met |
| Extra team slot | 10 | Team state not audited | ID 13 | Unknown | Level gate met |
| Hive | 10 | Map progression may apply | ID 14 | Unknown | Level gate met |
| Arena | 11 | Arena-specific state not audited | ID 15 | Unknown | Level gate met |
| Elite broken road | 11 | Map progression may apply | ID 16 | Unknown | Level gate met |
| Chat | 12 | Server/channel state not audited | ID 17 | Unknown | Level gate met |
| Elite hive | 12 | Map progression may apply | ID 18 | Unknown | Level gate met |
| Heroic hive | 12 | Map progression may apply | ID 19 | Unknown | Level gate met |
| Death valley | 12 | Map progression may apply | ID 20 | Unknown | Level gate met |
| Elite death valley | 12 | Map progression may apply | ID 21 | Unknown | Level gate met |
| Stonehenge | 12 | Map progression may apply | ID 22 | Unknown | Level gate met |
| Friends | 13 | Server/friend state not audited | ID 23 | Unknown | Level gate met |
| Style | 13 | Fashion state not audited | ID 24 | Unknown | Level gate met |
| Heroic death valley | 13 | Map progression may apply | ID 25 | Unknown | Level gate met |
| Watchtower | 13 | Map progression may apply | ID 26 | Unknown | Level gate met |
| Handbook | 14 | Collection state not audited | ID 27 | Unknown | Level gate met |
| Elite Stonehenge | 14 | Map progression may apply | ID 28 | Unknown | Level gate met |
| Elite watchtower | 14 | Map progression may apply | ID 29 | Unknown | Level gate met |
| House | 15 | Home record is separate | ID 30 | Unknown | Level gate met; home data preserved |
| Life manufacture | 15 | Profession state may apply | ID 31 | Unknown | Level gate met |
| Market | 15 | Market service state not audited | ID 32 | Unknown | Level gate met |
| Heroic watchtower | 15 | Map progression may apply | ID 33 | Unknown | Level gate met |
| Observatory | 15 | Map progression may apply | ID 34 | Unknown | Level gate met |
| Oasis | 15 | Map progression may apply | ID 35 | Unknown | Level gate met |
| IDs 36–39 | 16 | Level gate | ExpOpenLockInfo IDs 36–39 | Unknown | Remain locked |

The client also reads `characters.game_values.map_lock` (key `map_lock`) as a
separate map/story progression threshold. It is deliberately not set to 15:
the source maps additionally use quest/route progress. No prerequisite quest
completion or reward claim is applied without the live quest rows and complete
quest reward/objective configuration.

## Localization findings and diagnostic change

Lua localization is handled by `LuaSqlite.lua`, which selects a file/folder
from encrypted `Config/lang.txt`, copies `Config/db/<language>.db` to the
writable path for SQLite, and loads `tbl_lang(code, lang)` into a Lua cache.
The Lua source tree has no file-loader reference to `LangInfo.dat`;
`Proto_Lang_Types.lua` declares a `(string id, string lang)` record but no Lua
manager loads it. Its binary structure is independently validated as a DWORD
entry count followed by DWORD-length-prefixed records containing `key\0text\0`.
The extracted file has 24,544 records; keys and values match Chinese
`lang.db` except the punctuation variant in `tipsnameerror`. It is therefore a
duplicate Chinese localization resource, separate from the language-filename
catalog in `Config/lang.txt` used by LuaSqlite. The checked-in English,
Vietnamese, and Chinese SQLite DBs all contain the reported keys.

The loader now logs language, runtime database path, open/query status,
translation count, first lookup result for the reported keys, and a fallback
reason for missing values. APK access and on-device lookup still require a
Waydroid run; Waydroid was stopped during this audit.

## Purchase and local-payment audit status

Purchase request schemas and ACK IDs are defined in client `Proto_*.lua`.
`CG_BUYGOODS_REQ=858` carries `(DWORD shopType, DWORD index, DWORD buyCount)`
and expects `GC_BUYGOODS_ACK=1953`, whose body is a WORD status. The client
source maps shop types 1, 3, and 4 to arena score, Lost Tower points, and PVP
arena coins; types 5 and 6 use item currencies 9992 and 9993. The client
`ShopInfo.dat` has type entries 1, 3, 4, 5, and 6; `ShopPoolInfo.dat` has 55
weighted pool records with award-element ID, price, quantity, purchase count,
weight, and condition.

The backend still intentionally rejects purchases: it lacks the `getShop`
request/ACK route (client 778→1746), persisted per-character shop stock and
refresh state, and a ledger. The request's index alone does not identify the
selected award element until the server-generated shop list is reconstructed.
The client protocol also supplies no purchase transaction ID, so a reconnect
retry cannot be distinguished from a second intentional identical purchase
without a carefully validated idempotency strategy. `success_purchase` must
not be changed to success until those states and ACK plus wallet/inventory
notifications are implemented atomically.

Local recharge remains disabled/unconfigured. The backend has tests asserting
that it does not return fabricated payment success. No real payment endpoint is
used. Implementing a sandbox grant still needs a parsed, version-matched local
recharge catalog and a transactional idempotency ledger, neither of which was
validated in this pass.

## Runtime boundary

At audit time `pg_isready -h 127.0.0.1 -p 5432` returned no response and
`waydroid status` reported `Session: STOPPED`. Thus no database snapshot,
character update, account-specific unlock inspection, shop transaction, or
device verification was performed.
