# Gameplay dependency audit (read-only baseline)

This map was assembled from `decoded_lua/assets/src/Net/Proto`, `Net/Process`,
`GameMgr`, the server router/handlers/schema, and the version 1.0.128745
configuration files. No source or database was changed while this baseline was
being collected. PostgreSQL was unavailable at `127.0.0.1:5432`, so rows for
account 6 / character 2 could not be inspected.

## Client quest and startup flow

`LoginMsgMgr.request()` uses a serial chain of blocking ACKs. After character
values it requests static/game state, including `CZ_QUESTLIST_REQ` (785).
`NewQuestProcess.onZC_QuestList_Ack()` releases the ACK waiter for ID 26;
`NewQuestProcess.onZC_NewQuest_Ntf()` passes the 404 notification's quest vector
to `QuestInfo.add()`. `QuestInfo.add()` updates quest state, then calls
`GameGuideMgr.checkProcess()` and `checkProcessInTown()`.

`GameGuideMgr.checkProcess()` selects only active quests whose configured
`strongType` is `1`. Versioned `NewQuestInfo.dat` parses as 747 records; quest
1 is the first strong tutorial quest and has child 10001. Its objective is
event type 2 and amount 1. Quest 10001 then leads into the next configured
strong quest chain. This is evidence for the seed from the game configuration,
not a guessed quest ID.

The server currently returns quest count 0 when `quests` has no rows. Character
creation currently inserts a character and starting pet but no quest rows.
Therefore a newly created character receives no tutorial quest and the client
has no active strong quest to start. Whether account 6 / character 2 has this
condition is not established because the database was down.

## Verified protocol and handler map

| Feature | Client request | Expected ACK / NTF | Current server handler | DB tables | Status / evidence |
|---|---:|---|---|---|---|
| Platform login | 2130 | 2126 `GC_PLATFORMLOGIN_ACK` | `handlers/auth.py` | accounts | Implemented; IDs in `ProtoCommand.lua` and dispatch |
| Device bind | 2211 | 2179 `GC_DEVICEBIND_ACK` | `handlers/auth.py` | accounts, device_bindings | Implemented |
| Device login | 2156 | 2183 `GC_DEVICELOGIN_ACK` | `handlers/auth.py` | accounts, device_bindings, characters | Implemented |
| Character creation | 1655 | 807 `GC_CREATECHAR_ACK` | `handlers/player.py` | characters, pets | Implemented; no quest seed |
| Character values | 770 | 747 `GC_GETCHARACTERVALUES_ACK` | `handlers/player.py` | characters | ACK implemented; before this change unknown fields defaulted to 0 and map lock was not persisted |
| Quest list | 785 | 26 `ZC_QUESTLIST_ACK`, then 404 `ZC_NEWQUEST_NTF` | `handlers/map.py:get_quests` | quests | Mapping verified in `Proto_NewQuest.lua`; empty DB yields empty list, so no tutorial |
| Quest objective update | 3133 | 3132 `ZC_UPDATEQUEST_ACK`; possibly 767 update NTF | None | quests | Client request/ACK schema in `Proto_NewQuest.lua`; server has no route |
| Quest completion | 400 | 726 `ZC_COMMITQUEST_ACK`, plus reward notifications | None | quests, inventory, characters | Client schema verified; server has no route |
| Change persisted character info | 632 | 630 `MC_CHANGEINFO_ACK` | None | characters | Client schema verified; used by client to persist `map_lock`; no server route |
| Tutorial step telemetry | 384 | 369 `GC_STEPLOG_ACK` | None | none identified | Client schema verified, but call sites and whether it gates progress need further trace |
| Chat | 45 | 35 `GC_CHAT_ACK` | None | none | `Proto_Chat.lua` writes 3 strings; client registers ACK 35 |
| Recharge cooldown | 662 | 655 `GC_RECHARGECD_ACK` | None | characters | Request empty; success ACK contains `Proto.parseCode` and JSON string `jsCD` |
| Activities | 154 | 152 `GC_GETACTIVITIESDATA_ACK` | `startup_empty_ack` | none | Client schema expects code + serialized activity data; current `{}` placeholder is not proven semantically complete |
| Change channel | 380 | 386 `GC_CHANGECHANNEL_ACK` | `handlers/chat.py` | none | Verified mapping; response implemented |
| Server time | 1214 | 1216 | `handlers/player.py` | none | Verified mapping; response implemented |
| Wishing tree | 96 | 97 | `startup_empty_ack` | none | ACK exists; empty payload validity must be confirmed against parser/config |
| World boss | 446 | 450 | `startup_empty_ack` | none | ACK exists; current all-zero fields are not proven to represent a valid state |

ID 404 is not an unknown response: it is `ZC_NEWQUEST_NTF`, the quest-list
notification. ID 45 is `CG_CHAT_REQ`; ID 662 is `CG_RECHARGECD_REQ`. The ACK
IDs are not required to equal request IDs.

## Persistence and progression gaps

- `characters` initially had no `map_lock` field. `LoginMsgMgr` requests
  `map_lock`. `QuestInfo.sendQuestFinished()` has a commented-out block that
  would send command 632; its active block updates map lock locally. Thus server
  quest completion must apply configured unlocks itself for persistence.
- There is no handler for 632, 3133, or 400, so quest completion/progression
  cannot be persisted through the current socket implementation.
- Existing `quests` rows serialize progress as a vector, but the database model
  stores arbitrary JSONB and current handler accepts several possible shapes.
- Current economy code has generic success paths, hardcoded example grants,
  separate item/wallet writes, and no purchase ledger/idempotency. It cannot
  satisfy atomic shop transactions or a local payment sandbox safely.
- Schema installs a trigger that forces unlimited wallet values on every
  character insert/update. This is global and conflicts with real shop balance
  validation. It must be replaced with an explicit development-only mode before
  economy work is considered complete.

## UI, resources, and localization

Touch locks are controlled from client Lua, prominently through
`GameGuideMgr`/`GameGuideMgr1-3` and `CocosModuleMgr.setScreenTouch()`. The
existing log contains prior session timeouts for client-info, device-login,
and home ACKs, but does not establish a current touch callback trace or prove a
current UI blocker. A current correlated client/server run is needed before
changing touch behavior.

Language SQLite files were previously confirmed valid, but runtime lookup still
needs a device-side trace through `LangInfo.dat`, SQLite open path, selected
locale, and lookup cache. No localization database changes are justified by
this audit.

## Database observation limit

`pg_isready -h 127.0.0.1 -p 5432` returned “no response”. No SQL reads or writes
were made. The account 6 / character 2 quest, inventory, pet, wallet, and map
state are therefore unknown. A successful read-only dump or a running database
is required to distinguish missing rows from server serialization defects.

## Evidence-backed implementation after the baseline

- Newly created characters now receive quest 1 (`status=0`, progress `[0]`) in
  the same PostgreSQL transaction as character/pet creation. Existing character
  progression is not rewritten during login.
- Quest 400 accepts only configured first quest 1, atomically marks it done and
  activates configured child 10001, then returns ACK 726 and NTF 404 in the
  client-defined layouts. Replays do not duplicate the child row. Other quest
  completion and reward claims remain rejected until their config and reward
  rules are implemented.
- Request 3133 is implemented only for quest 1, validating the one-element
  progress vector against its configured bound (0..1); other IDs are rejected.
- Request 632 persists same-character key/value updates in `characters.game_values`;
  `maplock` is normalized to `map_lock`, which the 770 handler reads back.
  This preserves actual 632 requests from other client flows; it does not yet
  make the active local-only map-unlock branch persistent.
- Recharge cooldown request 662 now receives schema-valid response 655 with
  the client-required `Proto.parseCode` and empty JSON cooldown object.
- The legacy unconditional wallet trigger was removed from schema bootstrap,
  and new VIP-point balances default to zero. Existing balances were not
  altered. Unvalidated generic shop, gacha, recharge, and upgrade stubs now
  return protocol failure without granting items or mutating character data;
  catalog-backed atomic transactions remain pending. The broad HTTP IAP fake
  success route was removed: payment-like routes return 403 unless the explicit
  development flag is set, then 501 until a verified catalog and idempotency
  key are configured. TCP recharge test requests also fail closed.
- TCP logs now record expected response IDs for these mapped requests and warn
  on mismatches; database exceptions retain their correct disconnect reason.
