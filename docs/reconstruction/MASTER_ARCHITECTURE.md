# Reconstruction architecture

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

This is an inventory baseline, not a completeness claim.
