Proto = {Command={CG_CREATEPVEBATTLE_REQ=136, GC_CREATEPVEBATTLE_ACK=210,
                   CG_PVEBATTLEEND_REQ=263, GC_PVEBATTLEEND_ACK=186},
         Error={ERROR_OK=0}}
local function le(value, bytes)
    local out = {}
    for i=1,bytes do out[i] = string.char(value % 256); value = math.floor(value / 256) end
    return table.concat(out)
end
Proto.writeWORD=function(out,v) out[#out+1]=le(v,2) end
Proto.writeDWORD=function(out,v) out[#out+1]=le(v,4) end
Proto.writeString=function(out,v) out[#out+1]=v.."\0" end
Proto.writeVector=function(out,items,write)
    Proto.writeBYTE(out,#items)
    for _,item in ipairs(items) do write(out,item) end
end
Proto.writeBYTE=function(out,v) out[#out+1]=le(v,1) end
Proto.parseWORD=function(r) local v=r:read(2); return v:byte(1)+v:byte(2)*256 end
Proto.parseDWORD=function(r) local v=r:read(4); return v:byte(1)+v:byte(2)*256+v:byte(3)*65536+v:byte(4)*16777216 end
Proto.parseString=function(r) local v=r:readCString(); return v end
Proto.parseVector=function(r,parse)
    local count=r:read(1):byte(); local items={}
    for i=1,count do items[i]=parse(r) end
    return items
end
local source = assert(io.open("decoded_lua/assets/src/Net/Proto/Proto_Battle.lua","rb")):read("*a")
assert(load(source))()
local req={}; Proto.writeP_CG_CreatePVEBattle_Req(req,{battleType=5,battleTypeID=99998,battleTypeSubID=0})
local packet=table.concat(req)
assert(packet==string.char(136,0,5,0,0,0,158,134,1,0,0,0,0,0), "unexpected client request bytes")

local function reader(bytes)
    local r={data=bytes,pos=1}
    function r:read(n) local s=self.data:sub(self.pos,self.pos+n-1); assert(#s==n); self.pos=self.pos+n; return s end
    function r:readCString() local e=self.data:find("\0",self.pos,true); assert(e); local s=self.data:sub(self.pos,e-1); self.pos=e+1; return s end
    return r
end
local ack=reader(string.char(0,0,1).."{}\0"..string.char(16,0,0,0)..string.char(0))
local decoded=Proto.parseP_GC_CreatePVEBattle_Ack(ack)
assert(decoded.code==0 and #decoded.monsters==1 and decoded.exp==16 and #decoded.helpMonsters==0)
local endAck=reader(string.char(0,0,16,0,0,0))
local endDecoded=Proto.parseP_GC_PVEBattleEnd_Ack(endAck)
assert(endDecoded.code==0 and endDecoded.exp==16)
print("LUA_BATTLE_PROTO_OK request_hex="..(packet:gsub(".",function(c) return string.format("%02x",c:byte()) end)))

Proto.Command.CG_GETTREASUREBOXDATA_REQ=227
Proto.Command.GC_GETTREASUREBOXDATA_ACK=225
assert(loadfile("decoded_lua/assets/src/Net/Proto/Proto_TreasureBox.lua"))()
local treasureRequest={}; Proto.writeP_CG_GetTreasureBoxData_Req(treasureRequest,{})
assert(table.concat(treasureRequest)==string.char(227,0))
local treasureAck=reader(string.char(0,0)..'[{"type":1,"time":123}]\0')
local boxes=Proto.parseP_GC_GetTreasureBoxData_Ack(treasureAck)
assert(boxes.code==0 and boxes.boxes=='[{"type":1,"time":123}]')
assert(treasureAck.pos==#treasureAck.data+1)
print("LUA_TREASURE_PROTO_OK")
