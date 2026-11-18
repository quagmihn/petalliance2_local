#!/usr/bin/env python3
"""Generate source-backed client, protocol, and asset inventories.

This records what is statically present in the target APK extraction. It does
not infer unknown wire semantics or claim server/runtime coverage.
"""
from __future__ import annotations
import hashlib, json, re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LUA = ROOT / 'decoded_lua/assets/src'
PROTO = LUA / 'Net/Proto'
GAME = LUA / 'GameMgr'
CONFIG = ROOT / 'apk_extracted/assets/res/Config'
OUT = ROOT / 'docs/reconstruction'
OUT.mkdir(parents=True, exist_ok=True)

def norm(s: str) -> str: return re.sub(r'[^A-Z0-9]', '', s.upper())
def rel(p: Path) -> str: return p.relative_to(ROOT).as_posix()
def rows(text: str):
    return [(n, int(v)) for n, v in re.findall(r'\b([A-Z][A-Z0-9_]*)\s*=\s*(\d+)\s*,?', text)]

all_lua_files=sorted(LUA.rglob('*.lua'))
lua_contents={f:f.read_text(errors='replace') for f in all_lua_files}
commands = rows((PROTO / 'ProtoCommand.lua').read_text(errors='replace'))
by_name = {name: ident for name, ident in commands}
by_id = {ident: name for name, ident in commands}
assert len(commands) == len(by_name) == len(by_id), 'duplicate protocol command name or ID'

proto_files = list(PROTO.glob('Proto_*.lua'))
write_defs = {}
parse_defs = {}
for path in proto_files:
    text = path.read_text(errors='replace')
    for m in re.finditer(r'function\s+Proto\.(writeP_[A-Za-z0-9_]+)\s*\([^\n]*\)(.*?)\nend', text, re.S):
        write_defs[norm(m.group(1).removeprefix('writeP_'))] = (path, m.group(2))
    for m in re.finditer(r'function\s+Proto\.(parseP_[A-Za-z0-9_]+)\s*\([^\n]*\)(.*?)\nend', text, re.S):
        parse_defs[norm(m.group(1).removeprefix('parseP_'))] = (path, m.group(2))

def field_schema(body: str, writer: bool):
    patterns = {
        'u8': r'Proto\.writeBYTE\(msg,\s*([^\)]+)\)',
        'u16': r'Proto\.writeWORD\(msg,\s*([^\)]+)\)',
        'u32': r'Proto\.writeDWORD\(msg,\s*([^\)]+)\)',
        'string': r'Proto\.writeString\(msg,\s*([^\)]+)\)',
        'vector': r'Proto\.writeVector\(msg,\s*([^\)]+)\)',
    } if writer else {
        'u8': r'Proto\.parseBYTE\(entry\)', 'u16': r'Proto\.parseWORD\(entry\)',
        'u32': r'Proto\.parseDWORD\(entry\)', 'string': r'Proto\.parseString\(entry\)',
        'vector': r'Proto\.parseVector\(entry,\s*([^)]+)\)',
    }
    result=[]
    for line in body.splitlines():
        stripped=line.strip()
        comment = stripped.split('--',1)[1].strip() if '--' in stripped else ''
        for kind, pattern in patterns.items():
            m=re.search(pattern,line)
            if not m: continue
            field = m.group(1).strip() if writer else ''
            result.append({'type':kind,'field':field,'comment':comment})
    return result

# Server routing is reported separately from protocol declaration coverage.
game_socket=(ROOT/'server/game_socket.py').read_text(errors='replace')
cmd_block=re.search(r'CMD\s*=\s*\{(.*?)\n\}', game_socket, re.S)
server_cmd={k:int(v) for k,v in re.findall(r'"([a-z0-9_]+)"\s*:\s*(\d+)',cmd_block.group(1))} if cmd_block else {}
routes={}
dispatch_src=game_socket.split('async def dispatch',1)[1].split('async def ',1)[0] if 'async def dispatch' in game_socket else game_socket
for key in set(re.findall(r'CMD\["([a-z0-9_]+)"\]', dispatch_src)):
    if key in server_cmd: routes[server_cmd[key]]=key
for num in re.findall(r'msg_id\s*==\s*(\d+)', game_socket): routes[int(num)]='direct dispatch'

request_id_by_writer={norm('CG_'+name[3:-4]+'_Req'):ident for name,ident in commands if name.startswith('CG_') and name.endswith('_REQ')}
send_request_ids={}
for send_file in (LUA/'Net/Send').glob('*.lua'):
    source=send_file.read_text(errors='replace')
    for fn,body in re.findall(r'function\s+\w+\.(sendCG_[A-Za-z0-9_]+)\s*\([^\n]*\)(.*?)\nend',source,re.S):
        writer=re.search(r'Proto\.writeP_(CG_[A-Za-z0-9_]+)',body)
        if writer and norm(writer.group(1)) in request_id_by_writer:
            send_request_ids[request_id_by_writer[norm(writer.group(1))]]=fn
protocol=[]
for name, ident in commands:
    if not name.startswith('CG_') or not name.endswith('_REQ'): continue
    stem=name[3:-4]
    response_name='GC_'+stem+'_ACK'
    response_id=by_name.get(response_name)
    wkey=norm('CG_'+stem+'_Req')
    pkey=norm('GC_'+stem+'_Ack')
    w=write_defs.get(wkey); p=parse_defs.get(pkey)
    # A command can use an exceptional ACK name or notification-only response.
    actual_ack=by_id.get(response_id) if response_id is not None else None
    caller_token=send_request_ids.get(ident)
    callers=[rel(f) for f,content in lua_contents.items()
             if caller_token and f.is_relative_to(GAME) and caller_token in content]
    protocol.append({
        'request_id':ident,'request_name':name,
        'request_serializer':{'function':w[0].name if w else None,
                              'source':rel(w[0]) if w else None,
                              'fields':field_schema(w[1],True) if w else [],
                              'status':'PARSED' if w else 'UNMAPPED'},
        'response_id':response_id,'response_name':actual_ack,
        'response_decoder':{'function':p[0].name if p else None,
                            'source':rel(p[0]) if p else None,
                            'fields':field_schema(p[1],False) if p else [],
                            'status':'PARSED' if p else ('NO_ACK_NAMED' if response_id is None else 'UNMAPPED')},
        'notification_ids':[], 'notification_ids_status':'UNMAPPED; inspect async NetMgr callbacks', 'calling_lua_modules':callers,
        'required_session_state':'UNMAPPED', 'required_gameplay_state':'UNMAPPED',
        'server_route':routes.get(ident),
        'coverage_status':'IMPLEMENTED_ROUTE' if ident in routes else 'UNIMPLEMENTED_ROUTE'
    })
command_index=[]
for name,ident in commands:
    direction=name.split('_',1)[0]
    kind=name.rsplit('_',1)[-1]
    command_index.append({'id':ident,'name':name,'direction':direction,'kind':kind,
                          'request_id':ident if kind=='REQ' else None,
                          'paired_response_id':by_name.get(direction.replace('CG','GC',1)+'_'+name.split('_',1)[1][:-4]+'_ACK') if direction=='CG' and kind=='REQ' else None})
(OUT/'protocol_registry.json').write_text(json.dumps({'source':rel(PROTO/'ProtoCommand.lua'),
    'command_count':len(command_index),'commands':command_index,
    'request_definition_count':len(protocol),
    'request_definitions':protocol},ensure_ascii=False,indent=2)+'\n')

# Build the complete Lua manager inventory, including state/data/support modules.
configs={p.stem for p in CONFIG.glob('*.dat')}
def subsystem(path: Path):
    parts=path.relative_to(GAME).parts
    return parts[0] if parts else 'root'
modules=[]
for f in sorted(GAME.rglob('*.lua')):
    text=lua_contents[f]
    req=sorted(set(re.findall(r'require\s*\(?\s*["\']([^"\']+)',text)))
    sends=sorted(set(re.findall(r'\b(sendCG_[A-Za-z0-9_]+)\s*\(',text)))
    tab_refs=sorted(set(re.findall(r'\b([A-Z][A-Za-z0-9]*(?:Info|Config|DB))\b',text)))
    modules.append({'path':rel(f),'subsystem':subsystem(f),'requires':req,
                    'protocol_calls':sends,'configuration_symbols':tab_refs})
(OUT/'client_modules.json').write_text(json.dumps({'count':len(modules),'modules':modules},ensure_ascii=False,indent=2)+'\n')

# Hash all extracted APK assets once, retaining duplicate paths from raw/extracted trees.
asset_roots=[ROOT/'apk_raw/unpacked/assets',ROOT/'apk_extracted/assets',ROOT/'decoded_lua/assets',ROOT/'apk_extracted/lib']
files=[]
for base in asset_roots:
    if base.exists(): files.extend(p for p in base.rglob('*') if p.is_file())
asset_lines=[]
for f in sorted(set(files)):
    h=hashlib.sha256()
    with f.open('rb') as stream:
        for block in iter(lambda:stream.read(1024*1024),b''): h.update(block)
    asset_lines.append({'path':rel(f),'type':f.suffix.lower().lstrip('.') or 'extensionless',
                        'size':f.stat().st_size,'sha256':h.hexdigest(),
                        'referenced_by':'UNMAPPED','client_version':'target-apk extraction',
                        'compatibility':'SOURCE_PRESENT; usage/compatibility not yet runtime validated'})
with (OUT/'asset_registry.jsonl').open('w') as out:
    for row in asset_lines: out.write(json.dumps(row,ensure_ascii=False,separators=(',',':'))+'\n')

# System inventory summary is intentionally conservative: modules and protocol
# calls are evidence, implementation is evaluated separately.
by_sub={}
for m in modules: by_sub.setdefault(m['subsystem'],[]).append(m)
lines=['# Client system inventory','',
       f"Target: extracted APK Lua source. Parsed {len(modules)} GameMgr Lua modules, {len(proto_files)} protocol Lua files, {len(commands)} command constants ({len(protocol)} client request definitions), and {len(asset_lines)} asset files.",'',
       'The inventory below maps source entry points by shipped directory. Presence does not imply a working server implementation or runtime feature. See `protocol_registry.json` and `IMPLEMENTATION_BACKLOG.md` for coverage.','',
       '| Client subsystem | Lua modules | Protocol send calls found | Config symbols found | Server/runtime status |','|---|---:|---:|---:|---|']
for sub,items in sorted(by_sub.items()):
    calls=sorted({x for m in items for x in m['protocol_calls']})
    refs=sorted({x for m in items for x in m['configuration_symbols'] if x in configs})
    lines.append(f'| `{sub}` | {len(items)} | {len(calls)} | {len(refs)} | Source inventoried; backend/Waydroid coverage requires per-feature verification |')
lines += ['', '## Module-by-module index','', '| Source | Subsystem | Protocol calls | Lua dependencies | Config references |','|---|---|---|---|---|']
for m in modules:
    lines.append('| `{}` | `{}` | {} | {} | {} |'.format(m['path'],m['subsystem'],
        ', '.join('`'+x+'`' for x in m['protocol_calls']) or '—',
        ', '.join('`'+x+'`' for x in m['requires']) or '—',
        ', '.join('`'+x+'`' for x in m['configuration_symbols'] if x in configs) or '—'))
(OUT/'CLIENT_SYSTEM_INVENTORY.md').write_text('\n'.join(lines)+'\n')
print(json.dumps({'commands':len(commands),'request_definitions':len(protocol),'modules':len(modules),
                  'protocol_files':len(proto_files),'assets':len(asset_lines),'config_tables':len(configs)},indent=2))
