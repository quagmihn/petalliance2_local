# Loading, home ACK, quest bootstrap, and localization findings

## Reconstructed client timeline

The only available client log is `waydroid_logcat.txt`. Its timestamps are
Waydroid local time (UTC+07); the normalized UTC values below subtract seven
hours. No TCP server log for this same connection/session is present. A prior
server log at 16:44 local is a different run and is not joined to this timeline.

| Waydroid time (+07) | UTC | Request / response | Expected ACK | Callback / client state evidence |
|---|---|---|---|---|
| 11:13:33.440 | 04:13:33.440Z | device relogin result 0 | — | Session resumed; process PID 4407 |
| 11:13:33.442 | 04:13:33.442Z | resend request 118 | 32 `GC_GETHOME_ACK` | pending resend confirmed by client |
| 11:13:33.443 | 04:13:33.443Z | request 785 | 26 then 404 | quest bootstrap starts |
| 11:13:33.444 | 04:13:33.444Z | request 380 | 386 | channel setup |
| 11:13:33.563 | 04:13:33.563Z | response 26 | 26 | client says current mission count 0 |
| 11:13:33.564 | 04:13:33.564Z | response 404 | 404 | `GameGuideMgr` sees 0 beginner guide quests |
| 11:13:33.565 | 04:13:33.565Z | response 386 | 386 | channel ACK successfully dispatched |
| 11:13:53.476 | 04:13:53.476Z | request 118 still pending | 32 | `NetInterface.send` times out after 20 seconds |
| 11:13:53.477 | 04:13:53.477Z | socket closes | — | client reconnect path is entered |

The log proves the home request remained pending and caused an async network
timeout/disconnect. Because `HomeInfo.GetHomeInfo(false)` uses `NetInterface.send`
(not `sendWithBlock`), this evidence alone does not prove it owns the visible
loading overlay. The separate blocking request that owns that overlay is not
identified by this log excerpt.

## Home packet proof

`ProtoCommand.lua` defines `CG_GETHOME_REQ=118` and
`GC_GETHOME_ACK=32`. `Proto_Garden.lua` writes request 118 as a DWORD character
ID. The ACK decoder reads WORD status; only for status 0 it reads a NUL-terminated
JSON string and DWORD character ID. `HomeProcess.onGC_GetHome_Ack` decodes the
JSON before resolving `CallbackMgr` for ID 32. A successful response therefore
needs valid home JSON and the requested character ID. An error response is the
nonzero WORD status alone.

Prior server dispatch had no 118 route, so `dispatch()` returned no response.
The repair adds this mapping and PostgreSQL-backed home lookup. Stored home JSON
is returned when available; an existing character with no saved home receives
a source-compatible level-one empty home using the character name. A missing
character receives protocol error status 1.

## Beginner quest evidence

The observed 26 ACK and 404 NTF were dispatched. `questNum=0` and the empty
notification caused `QuestInfo.add({})` and `GameGuideMgr` found no strong quest.
The client configuration `NewQuestInfo.dat` defines quest 1 as the first strong
quest, with child 10001. The backend previously seeded quest 1 only when it
created a character, so an existing level-one character with no quest rows
continued receiving an empty list. The new level-one/no-quest check inserts
quest 1 with progress `[0]` idempotently before serializing 26 and 404.

The current database was unreachable, so character 2's level and PostgreSQL
rows could not be checked. The log proves no quest was returned, but not whether
that character met the level-one seeding condition.

## Localization proof

The three SQLite databases remain valid and include the observed translation
keys. `LuaSqlite.Init()` reads `Config/lang.txt` with `TxtReader`; that reader
only splits plaintext TSV. The packaged `lang.txt` starts with `XXTEA` and its
decrypted content is the six-row language filename/folder map. Since the map
was empty, locale selection could not reliably choose `lang_en.db`, `lang.db`,
or `lang_vn.db`; lookup then returned the original key. `LangInfo.dat` is not
used by this Lua locale-selection path.

The Lua loader now decrypts this catalog before parsing it, validates the
selection against catalog entries, and falls back to the English SQLite file
when a requested DB cannot be loaded. Translation values continue to come from
`tbl_lang`.

## Verification limits

- Python regression suite: 27 tests pass; the isolated PostgreSQL integration
  test is skipped because PostgreSQL is unavailable.
- `luac -p` passed for the modified Lua source.
- The Lua override in the rebuilt APK decrypts byte-for-byte to the modified
  source, and APK signatures verify.
- Waydroid reports `Session: STOPPED`; no client runtime verification or
  loading-overlay dismissal was possible here.
