require("src.Net.Proto.ProtoInclude")

local ActivateCodeProcess = {}
local NetMgr = require("src.Net.NetMgr")
local MsgPrinter = require("src.Net.MsgPrinter")
local CallbackMgr = require("src.Net.CallbackMgr")

function ActivateCodeProcess.init()
    NetMgr.addProcess(Proto.Command.GC_USEACTIVATECODE_ACK,
        ActivateCodeProcess.onGC_UseActivateCode_Ack)

end

function ActivateCodeProcess.onGC_UseActivateCode_Ack(msg)

    local res = Proto.parseP_GC_UseActivateCode_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_UseActivateCode_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_USEACTIVATECODE_ACK)
    return res.code

end

return ActivateCodeProcess
