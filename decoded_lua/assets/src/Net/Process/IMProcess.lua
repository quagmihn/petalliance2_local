require("src.Net.Proto.ProtoInclude")

local IMProcess = {}
local NetMgr = require("src.Net.NetMgr")
local MsgPrinter = require("src.Net.MsgPrinter")
local CallbackMgr = require("src.Net.CallbackMgr")

function IMProcess.init()
    NetMgr.addProcess(Proto.Command.GC_MESSAGE_NTF,
        IMProcess.onGC_Message_Ntf)

end

function IMProcess.onGC_Message_Ntf(msg)

    local res = Proto.parseP_GC_Message_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_Message_Ntf")

    CharInfo.doCommand(res.command, res.param)
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_MESSAGE_NTF)
    return res.code

end

return IMProcess
