local expectedCode, callbackCode, callbackID, noticeCount = 1, nil, nil, 0
local originalRequire = require
require = function(name)
    if name == "src.Net.Proto.ProtoInclude"
    or name == "src.Net.NetMgr"
    or name == "src.Net.MsgPrinter"
    or name == "src.Net.CallbackMgr" then
        if name == "src.Net.MsgPrinter" then return MsgPrinter end
        if name == "src.Net.NetMgr" then return {} end
        if name == "src.Net.CallbackMgr" then
            return {doCallFunc=function(code, id) callbackCode, callbackID = code, id end}
        end
        return {}
    end
    return originalRequire(name)
end

Proto = {Command={GC_CREATEPVEBATTLE_ACK=210}, Error={ERROR_OK=0},
         parseP_GC_CreatePVEBattle_Ack=function()
             return {code=expectedCode}
         end}
SceneMgr = {currentScene="SearchingScene"}
SearchingMapMgr = {battlePos=15}
SearchingMgr = {onbattle=true, canMove=false, eventStateInfoTable={[15]=2}}
MsgPrinter = {rcvMsg=function() end}
StandardTipsMgr = {show=function() noticeCount=noticeCount+1 end}

local process = assert(loadfile("decoded_lua/assets/src/Net/Process/PVEProcess.lua"))()
process.onGC_CreatePVEBattle_Ack({})
assert(SearchingMgr.onbattle == false)
assert(SearchingMgr.canMove == true)
assert(SearchingMgr.eventStateInfoTable[15] == 1)
assert(callbackCode == 1 and callbackID == 210)
assert(noticeCount == 1)
print("LUA_BATTLE_RECOVERY_OK")
