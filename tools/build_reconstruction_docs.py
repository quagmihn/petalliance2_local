#!/usr/bin/env python3
"""Generate reconstruction maps and coverage summaries from client sources."""
from __future__ import annotations
import json, re
from collections import Counter
from pathlib import Path
import sys
ROOT=Path(__file__).resolve().parents[1]; sys.path.insert(0,str(ROOT/'server'))
from client_config import table
from quest_config import load_quests
OUT=ROOT/'docs/reconstruction'; CFG=ROOT/'apk_extracted/assets/res/Config'

def md(rows):
    if not rows:return ''
    clean=lambda x:str(x).replace('|','\\|').replace('\n',' ')
    return '| '+' | '.join(rows[0])+' |\n| '+' | '.join('---' for _ in rows[0])+' |\n'+'\n'.join('| '+' | '.join(clean(v) for v in row)+' |' for row in rows[1:])
def get(name):
    try:return table(name)
    except (ValueError,FileNotFoundError):return None

def write(name, text): (OUT/name).write_text(text.rstrip()+'\n')
reg=json.load((OUT/'protocol_registry.json').open())
req=reg['request_definitions']; allcmd=reg['commands']
serial=sum(x['request_serializer']['status']=='PARSED' for x in req)
decoders=sum(x['response_decoder']['status']=='PARSED' for x in req)
callers=sum(bool(x['calling_lua_modules']) for x in req)
routes=sum(x['server_route'] is not None for x in req)
quests=load_quests(); graph=json.load((OUT/'../quest_graph.json').open()) if (OUT/'../quest_graph.json').exists() else {}
asset_rows=[json.loads(x) for x in (OUT/'asset_registry.jsonl').open()]
asset_types=Counter(x['type'] for x in asset_rows)

write('MASTER_ARCHITECTURE.md',f'''# Reconstruction architecture

## Target and boundaries

The compatibility target is the shipped APK extracted under `apk_raw/unpacked` / `apk_extracted`; Lua source is reconstructed under `decoded_lua/assets/src`. The current backend is a single Python process pair (HTTP gateway and TCP protocol server) with PostgreSQL persistence. The proposed service boundaries below are logical modules sharing one authoritative transaction/database layer; they are not separate network services.

## Current runtime components

| Responsibility | Current implementation | State |
|---|---|---|
| Authentication/session | `server/handlers/auth.py`, `server/game_socket.py` | Login/relogin route exists; session reliability needs broad reconnect tests |
| Character/profile | `server/handlers/player.py`, `server/character_values.py`, schema `characters` | Starter/login/appearance handlers; full attribute coverage incomplete |
| Pet | `server/handlers/pet.py`, `server/pet_config.py` | Pet query/formation and selected training/feed flows; many configured operations lack handler coverage |
| Battle | `server/handlers/battle.py`, `server/battle_group_config.py` | Tutorial trainer, wild, and selected adventure contexts; most battle modes unsupported |
| Quest/reward | `server/quest_config.py`, handlers in `player.py` / `map.py` | Catalog parsed; lifecycle not general for all objective types |
| World/adventure | `server/handlers/map.py` | Selected adventure requests; whole map graph is not implemented |
| Inventory/economy/shop | `server/handlers/inventory.py`, `server/handlers/economy.py` | Pet feed and MarketInfo subset; many shops and limits are incomplete |
| Events/social/ranking/mail | protocol/client catalogs; sparse handlers | Mostly discovered, not implemented/verified |
| Configuration | `server/client_config.py` | Lua-declared XDat parsing for supported tables; individual malformed/unsupported tables are tracked as parser gaps |
| Persistence/migrations | `server/db/database.py`, `server/db/schema.sql` | PostgreSQL, transaction-based operations; additive schema only in recent recovery work |
| Launch/observability | `server/run_all.sh`, `server/game_socket.py` | Official launcher validates actual DB identity; request latency logs exist |

## Authoritative operation shape

`Lua serializer → framed TCP request → authenticated Session → domain handler → PostgreSQL transaction/row locks → commit → configured notifications → ACK → Lua decoder/callback → canonical state refresh`. Any operation not following this shape is a backlog item. The network protocol stays compatible; modularity is within the Python application.

## Scale discovered

- 528 GameMgr Lua modules across 22 subsystem directories.
- 162 protocol Lua files; 1,024 command constants and 374 `CG_*_REQ` definitions.
- 184 `.dat` config tables are parsed by the current XDat loader; some other tables are present but unsupported/malformed for that loader.
- 16,049 extracted asset files are hashed in `asset_registry.jsonl`.
- 747 quest rows, 290 AdventureInfo records, 22,486 SceneInfo rows, 907 trainer/battle groups and 2,142 MonstrosityInfo rows.

This is an inventory baseline, not a completeness claim.''')

write('PROTOCOL_REGISTRY.md',f'''# Protocol registry

The canonical registry is [protocol_registry.json](protocol_registry.json), generated from `decoded_lua/assets/src/Net/Proto/ProtoCommand.lua`, Lua serializers/decoders, Net/Send wrappers and static GameMgr callers. It includes every command constant and every client `CG_*_REQ` row.

| Measure | Count | Interpretation |
|---|---:|---|
| Command constants | {len(allcmd)} | Includes request, ACK, notification, and other command families |
| Client request definitions | {len(req)} | `CG_*_REQ` command constants |
| Request serializers parsed | {serial} | Serializer function found; schema fields preserve wire type/order and source comments where available |
| ACK decoders parsed | {decoders} | Named ACK decoder found; does not guarantee backend response correctness |
| Requests with GameMgr caller found | {callers} | Static send wrapper reference located |
| Current server routes detected | {routes} | Static route only; special dispatch may need semantic validation |

Notification IDs are not guessed or attached to requests without source evidence. Exceptional command pairs, one-way/native messages, reused numeric IDs, and async notifications need explicit annotations. ID 4 is dual-use (native heartbeat ACK versus Lua adventure event request) and dispatch distinguishes empty heartbeat from populated gameplay payload. Unknown session/game-state prerequisites remain `UNMAPPED` in the registry.

The generated registry is useful for exhaustive coverage checks but is not yet a complete hand-verified protocol specification. Payload schemas should be reviewed against each Lua writer, parser, and callback before implementing remaining routes.''')

qedges=sum(len([x for x in q.child_ids if x]) for q in quests.values())
write('QUEST_GRAPH.md',f'''# Quest graph

Source: binary `NewQuestInfo.dat`, parsed by `server/quest_config.py`; raw parent/child edges are in [quest_graph.json](../quest_graph.json) and all rows in [ALL_QUESTS.md](../ALL_QUESTS.md).

- Nodes: **{len(quests)}**.
- Configured child edges: **{qedges}**.
- Objectives retain original numeric event type/arguments. Natural-language semantics are not inferred if localization or Lua handlers do not establish them.
- Quest rows encode prerequisites/children, objective vectors, reward references and unlock map fields. They do not encode all feature flags or runtime requirements.
- Generated validation in `ALL_QUESTS.md` reports absent children, parent-child inconsistencies, cycles and missing RewardInfo references.

Current server handles selected tutorial/quest commit behavior. No assertion is made that every objective type or all 747 quest lifecycles are implemented. Implement objective adapters by discovered event type, validate every edge/reference automatically, and preserve the client’s actual status enum/reward lifecycle.''')

adv=get('AdventureInfo') or {}; scenes=get('SceneInfo') or {}; nodes=get('MapNodeInfo') or {}; events=get('MapEventInfo') or {}
maprows=[['Adventure ID','Name key','Required level','Prerequisite','Scenes','Targets','Rewards','Runtime']]
for i,x in sorted(adv.items()):maprows.append([i,x.get('name',''),x.get('level','?'),x.get('prepose','?'),','.join(map(str,x.get('scene',[]))),','.join(map(str,x.get('target',[]))),x.get('rewards','?'),'CONFIG_ONLY'])
write('MAP_GRAPH.md',f'''# Map and Adventure graph

Adventure entries: **{len(adv)}**; SceneInfo rows: **{len(scenes)}**; MapNodeInfo rows: **{len(nodes)}**; MapEventInfo rows: **{len(events)}**. Complete AdventureInfo matrix is below; detailed scene/node/event payloads remain available from the original parsed config and `docs/ALL_MAPS.md`.

`prepose`, `level`, `scene`, `target`, `rewards`, and `mapInfo` are retained as configured. Their semantics must be joined with client scene/event handlers and validated before opening a map. The current server implements selected Adventure request paths; the full entry/explore/event/clear/star/reward graph has not passed protocol or Waydroid acceptance.

{md(maprows)}''')

groups=get('MonsterGroupManInfo') or {}; mgrows=[['Group','Name key','Enemies','Helpers','EXP','Current scope']]
for i,x in sorted(groups.items()):mgrows.append([i,x.get('name',''),','.join(map(str,x.get('pokemons',[]))),','.join(map(str,x.get('helperPokemons',[]))),x.get('exp','?'),'CONFIG_ONLY'])
write('BATTLE_GROUP_MATRIX.md',f'''# Battle group matrix

Configured MonsterGroupManInfo groups: **{len(groups)}**. Full matrix below. Referenced monster IDs are verified against MonstrosityInfo by the content audit; this does not mean every battle type has the correct caller, eligibility checks, or reward behavior implemented.

Implemented subset: configured tutorial trainer groups and tutorial wild IDs are handled by current Python battle code; selected Adventure scene event type 8 is supported. Runtime evidence in the latest checkpoint covers wild battle 999998 start/end only. Other rows remain configuration-only unless a specific contract/runtime test says otherwise.

{md(mgrows)}''')

pet_names=[x.stem for x in CFG.glob('*.dat') if any(t in x.stem.lower() for t in ('pet','pokemon','monstrosity','skill','experience','expinfo','ball'))]
petrows=[['Config table','Rows','Purpose/status']]
for n in sorted(pet_names):
    t=get(n); petrows.append([n,len(t) if t is not None else 'PARSER_BLOCKED','Parsed source; per-operation use must be validated'])
write('PET_SYSTEM_MATRIX.md',f'''# Pet system matrix

Pet-related config tables discovered by filename: **{len(pet_names)}**. Full record-level IDs are in [ALL_PET_SYSTEMS.md](../ALL_PET_SYSTEMS.md) and [pet_config_index.json](../pet_config_index.json). Selected starter/query/formation, Pet EXP feeding, Stage, and wild capture logic has code/tests. Do not conflate level/EXP, training Stage, enhancement, evolution, star-up, equip, skills, and equipment purification.

| Flow | Source evidence | Backend/runtime status |
|---|---|---|
| Pet query/serialization | QueryPets Lua decoder, PokemonInfo/MonstrosityInfo | Existing handler; tested legacy validation paths |
| Wild capture | GameGuideMgr + BattleCCSB; PokemonBallInfo; ItemInfo | Transactional implementation and PostgreSQL contract; Waydroid has not captured |
| Pet EXP feed | Item UI, request 516/ACK 526, ExperienceInfo | PostgreSQL/TCP tested; actual Waydroid feed pending |
| Training Stage | PetAdvanceInfo and request 1038 flow | Separate persisted operation; runtime acceptance pending |
| Enhance/evolve/star/skills/equipment | Pet*Info tables and 374-request registry | Discoverable but per-flow backend coverage incomplete |

{md(petrows)}''')

activity_tables=['ActivityInfoClient','EventInfo','EventListInfo','EventNpcInfo','ActivityShopInfo','RandomEventInfo','MapEventInfo','ExploreEventSInfo','FamilyEventInfo']
eventrows=[['Table','Rows','Runtime support']]
for n in activity_tables:
    t=get(n); eventrows.append([n,len(t) if t is not None else 'PARSER_BLOCKED','Catalog only; claim/progress state requires protocol-backed implementation'])
write('EVENT_MATRIX.md',f'''# Event matrix

The APK exposes multiple independent activity/event catalogs; they must not be merged by filename assumptions. Current request registry includes activity requests, but a request route is not a reward implementation. Event progress, eligibility, claim state, reset schedule, atomic grants, deduplication, UI notification, and relogin persistence remain unverified unless specifically covered by tests.

{md(eventrows)}

Detailed client text/params are in `ALL_EVENTS.md`. Expired official timestamps can be represented by explicitly configured local event schedules only after preserving event rules/rewards from client data.''')

shop_tables=['ShopInfo','ShopPoolInfo','ShopReflashInfo','MarketInfo','ActivityShopInfo','FamilyShopInfo','NormalRechargeInfoIos','MonthCardRechargeInfoIos']
shoprows=[['Table','Rows','Parsing/implementation status']]
for n in shop_tables:
    t=get(n); shoprows.append([n,len(t) if t is not None else 'PARSER_BLOCKED','MarketInfo unlimited catalog purchase subset tested; all other catalogs need independent protocol and limits'])
write('SHOP_MATRIX.md',f'''# Shop and recharge matrix

Catalogs are distinct systems with different currencies, stock, refresh, limits, and grant semantics. Never route an item through a different catalog based only on matching item ID.

{md(shoprows)}

MarketInfo entry 201 used by the target capture UI maps to Master Ball item 1 for 600 diamonds and has no configured buy limit. Handler transaction tests pass. Waydroid purchase was stopped client-side by `BAG IS FULL`; no purchase request/reward was observed. Recharge receipt/package tables have parser gaps and no local simulated checkout implementation. Real payment providers are not contacted.''')

extrows=[['File type','Count']]+[[k,v] for k,v in asset_types.most_common()]
write('ASSET_COMPATIBILITY.md',f'''# Asset compatibility inventory

A content hash/size/path registry for **{len(asset_rows)}** files across `apk_raw/unpacked/assets`, `apk_extracted/assets`, `decoded_lua/assets`, and extracted native libraries is in [asset_registry.jsonl](asset_registry.jsonl). Duplicate resources at raw and extracted locations are retained as distinct paths so integrity can be compared by SHA256. Compatibility is initially `SOURCE_PRESENT`; reference graph and runtime compatibility are not inferred from filename/hash alone.

Native library inspection: target includes stripped Android Cocos2d-x/Lua shared objects for armeabi, armeabi-v7a, and arm64-v8a. The arm64 `libcocos2dlua.so` is ELF AArch64; its dynamic symbol table contains Cocos2d, Lua, network, audio, and data-reader registrations. No native binary was modified or replaced.

{md(extrows)}

No newer-version resources have been integrated. Such assets need format, ID-reference, animation, texture/font, ABI, Lua loader, and Waydroid compatibility testing before replacement.''')

route_rows=Counter(x['coverage_status'] for x in req)
write('COVERAGE_REPORT.md',f'''# Coverage report

Snapshot generated from the current local reconstruction source; statuses are scoped to evidence, not product completeness.

| Inventory | Discovered | Parsed/source indexed | Current backend route | Protocol tests | Waydroid evidence |
|---|---:|---:|---:|---|---|
| Protocol command constants | {len(allcmd)} | {len(allcmd)} | {routes}/{len(req)} client requests statically routed | 82-test suite, targeted paths only | Login/Town; wild 136/210 then 263/186 |
| Client request definitions | {len(req)} | serializers {serial}; ACK decoders {decoders}; GameMgr callers {callers} | {routes} | Partial; see registry | No per-request complete acceptance |
| Quests | {len(quests)} | all quest rows parsed | Selected tutorial/commit path | Selected integration tests | Quest 10008 capture blocked |
| AdventureInfo | {len(adv)} | all rows parsed | Selected requests only | Partial | No full map clear/unlock acceptance |
| SceneInfo | {len(scenes)} | all rows parsed | event/battle subsets | Partial | One wild encounter |
| Battle groups | {len(groups)} | all rows parsed | small configured subset | selected trainer/wild/adventure contracts | one type-1 wild group start/end |
| Activity/Event catalogs | {sum(len(get(n) or {}) for n in activity_tables)} | catalog tables listed in EVENT_MATRIX | Sparse/unverified | None comprehensive | no claims verified |
| Extracted assets | {len(asset_rows)} | SHA256 for all registry rows | n/a | hash inventory | no broad asset compatibility testing |

## Status definitions

- `DISCOVERED`: source ID/path exists.
- `PARSED`: structure decoded with target format parser.
- `IMPLEMENTED`: server behavior exists for stated scope.
- `PROTOCOL_TESTED`: request, response/notifications, and persistence tested on TCP/PostgreSQL.
- `WAYDROID_VERIFIED`: visible client flow and resulting state observed on target APK.
- `BLOCKED`: explicit reproducible dependency or runtime gate prevents validation.
- `UNSUPPORTED`: no adequate source/config/protocol evidence or implementation.

Do not promote a row to Waydroid verified from ACK-only coverage.''')

write('IMPLEMENTATION_BACKLOG.md','''# Implementation backlog

Checkpoint baseline tag: `baseline-partial-verified-2026-11-18` at commit `947a052d59663a70b28821b28d3983e1ed83951e`. See `FINAL_RUNTIME_ACCEPTANCE.md` for the exact tested state.

## P0 — runtime state correctness

1. Verify inventory capacity values now come from GlobalConfigAddInfo (items 6601 and Pet slots 6701); preserve larger character upgrades and test actual ACK JSON.
2. Capacity defaults now use client config: itemPacketNum=70, petPacketNum=40, explorePacketNum=10; PostgreSQL typed contract tests pass. Cold relogin Waydroid and repeat capture UI purchase click. If capacity is still full, instrument `BagViewMgr.refreshItemInfo`, `CharInfo.itempacketnum`, and inventory notifications.
3. Complete purchase 201 and capture at actual configured odds; verify balance, inventory, Pet UID, quest progress, and relogin persistence.
4. Exercise Pet EXP potion on Waydroid; compare request, committed DB state, immediate UI, and cold login.

## P1 — shared domain engines

5. Implement inventory slot/stack limits from client config and catalog semantics; make reward and purchase grants share the same transactional service.
6. Map every quest objective event type to a verified domain event adapter; add graph/reference tests for all 747 rows.
7. Build map/adventure state graph and generic entry/explore/event/battle/clear/reward lifecycle from AdventureInfo, SceneInfo, MapNodeInfo, MapEventInfo, and client callsites.
8. Add per-mode battle resolver/eligibility/reward contract for all discovered battle type families; never authorize unknown IDs.
9. Implement Pet level/stage/evolution/strengthen/star/equipment/skill flows independently from their exact configs and protocol.

## P2 — services/data

10. Event claim state and reset semantics for verified local schedules.
11. Each shop catalog, stock refresh/limit rules, and atomic wallet/inventory notifications.
12. Local-only recharge package catalog and simulated idempotent transaction after correctly parsing package/reward configs; reject external provider integration.
13. Social/family/friends/chat/mail/ranking/achievement protocol coverage and persistence.
14. Appearance/equipment/pet/UI cache contracts, including state revisions where wire protocol supports them.

## P3 — broad acceptance

15. Content-wide static foreign-key/reference audit with categorized unsupported configs.
16. Profile request/SQL/transaction/client redraw latencies; optimize only measured slow paths.
17. Separate Waydroid acceptance by interaction/scene/battle family, cold relogin, and official server restart.
18. Compare optional newer lawful assets against the target APK before integration; no upgrade assets currently merged.''')

write('FINAL_RUNTIME_ACCEPTANCE.md','''# Final runtime acceptance checkpoint

Date: 2026-11-18. This records a partial verified checkpoint; it is not a release-complete report.

| Check | Result | Evidence |
|---|---|---|
| Baseline source | PASS | tag `baseline-partial-verified-2026-11-18`, commit `947a052d59663a70b28821b28d3983e1ed83951e` |
| Baseline APK | PASS | Installed APK SHA256 equals `b24ea2d5239d61e15c47574df37a74c12dccac5440e14cd549c7939f0f0f6fcf` |
| Official server | PASS | `server/run_all.sh production`, source tree, HTTP 8080 and TCP 5568, database `monster2_db`, role `monster2` |
| PostgreSQL/TCP suite | PASS | 79 tests after capacity-default fix, separate `monster2_test_db`; no skips |
| Login/Town | PASS | Existing Waydroid account 6 / char 2 relogin screenshot/log in `artifacts/pet-exp-feed-20261118/` |
| Wild battle | PASS | Request 136/ACK 210 code 0; battle end 263/ACK 186 code 0, 8 EXP; capture UI reached |
| Inventory capacity | CODE/TEST PASS, WAYDROID RETEST PENDING | Missing `itemPacketNum` previously defaulted to 0 and overrode client config 70; response now derives configured 70/40/10. Contract tests verify defaults and preserve purchased capacity |
| Capture | BLOCKED | All ball stacks were zero; Master Ball button reported BAG IS FULL before request 577. Capacity default fix now awaits Waydroid relogin/runtime confirmation |
| Quest/map completion | BLOCKED | No capture request, so quest objective/map transition not completed |
| Pet EXP live UI | BLOCKED | TCP/DB tests pass; no Waydroid feed performed |
| Events/shop/recharge | BLOCKED/INCOMPLETE | no live reward/purchase/recharge completion |
| Production backup | PARTIAL | PostgreSQL archives and SHA256/TOC validation pass; isolated restore could not be run because current role lacks CREATEDB and `sudo -n -u postgres` requires password |
| Push | BLOCKED | `git push origin main` failed because GitHub HTTPS credential helper has no interactive username source |

Screenshots and synchronized server logs are local evidence under `artifacts/pet-exp-feed-20261118/` and are deliberately not tracked in Git. Production data was not manually edited to create a test pass. Runtime encounter rows from normal Waydroid gameplay are present in `monster2_db`.

Next check after capacity default commit: restart only the official launcher, cold relogin, inspect `GET_CHARACTER_VALUES_ACK` for itemPacketNum=70/petPacketNum=40, then repeat the real UI add/capture path.''')
print(f'generated reconstruction docs; protocol requests={len(req)}, commands={len(allcmd)}, assets={len(asset_rows)}')
