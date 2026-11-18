# Protocol registry

The canonical registry is [protocol_registry.json](protocol_registry.json), generated from `decoded_lua/assets/src/Net/Proto/ProtoCommand.lua`, Lua serializers/decoders, Net/Send wrappers and static GameMgr callers. It includes every command constant and every client `CG_*_REQ` row.

| Measure | Count | Interpretation |
|---|---:|---|
| Command constants | 1024 | Includes request, ACK, notification, and other command families |
| Client request definitions | 374 | `CG_*_REQ` command constants |
| Request serializers parsed | 374 | Serializer function found; schema fields preserve wire type/order and source comments where available |
| ACK decoders parsed | 373 | Named ACK decoder found; does not guarantee backend response correctness |
| Requests with GameMgr caller found | 306 | Static send wrapper reference located |
| Current server routes detected | 54 | Static route only; special dispatch may need semantic validation |

Notification IDs are not guessed or attached to requests without source evidence. Exceptional command pairs, one-way/native messages, reused numeric IDs, and async notifications need explicit annotations. ID 4 is dual-use (native heartbeat ACK versus Lua adventure event request) and dispatch distinguishes empty heartbeat from populated gameplay payload. Unknown session/game-state prerequisites remain `UNMAPPED` in the registry.

The generated registry is useful for exhaustive coverage checks but is not yet a complete hand-verified protocol specification. Payload schemas should be reviewed against each Lua writer, parser, and callback before implementing remaining routes.
