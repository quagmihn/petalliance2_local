require("src.Net.Proto.ProtoInclude")
require("src.GameMgr.login")

local PortalProcess = {}
local NetMgr = require("src.Net.NetMgr")
local MsgPrinter = require("src.Net.MsgPrinter")
local CallbackMgr = require("src.Net.CallbackMgr")

function PortalProcess.init()
    NetMgr.addProcess(Proto.Command.GC_DEVICEBIND_ACK,
        PortalProcess.onGC_DeviceBind_Ack)
    NetMgr.addProcess(Proto.Command.GC_PLATFORMLOGIN_ACK,
        PortalProcess.onGC_PlatformLogin_Ack)

end

function PortalProcess.onGC_PlatformLogin_Ack(msg)

    local res = Proto.parseP_GC_PlatformLogin_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_PlatformLogin_Ack")
	print("--------GC_PlatformLogin_Ack-----------------:",res.code.value)
    if (Proto.Error.ERROR_OK == res.code.value) then
        platformLogin_ack(res)
    end
    CallbackMgr.doCallFunc(res.code.value, Proto.Command.GC_PLATFORMLOGIN_ACK)
    return res.code.value

end

function PortalProcess.onGC_DeviceBind_Ack(msg)

    local res = Proto.parseP_GC_DeviceBind_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_DeviceBind_Ack")
    print("revice device bind ack:",res.code.value,res.code.file,res.code.line)
    if (Proto.Error.ERROR_OK == res.code.value) then
    end
    CallbackMgr.doCallFunc(res.code.value, Proto.Command.GC_DEVICEBIND_ACK)
    return res.code.value

end

return PortalProcess
