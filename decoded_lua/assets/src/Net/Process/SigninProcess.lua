require("src.Net.Proto.ProtoInclude")

local SigninProcess = {}
local NetMgr = require("src.Net.NetMgr")
local MsgPrinter = require("src.Net.MsgPrinter")
local CallbackMgr = require("src.Net.CallbackMgr")

function SigninProcess.init()
    NetMgr.addProcess(Proto.Command.GC_SIGNINREPAIR_ACK,
        SigninProcess.onGC_SigninRepair_Ack)
    NetMgr.addProcess(Proto.Command.GC_SIGNIN_ACK,
        SigninProcess.onGC_Signin_Ack)
    NetMgr.addProcess(Proto.Command.GC_LOADSIGNINDATA_ACK,
        SigninProcess.onGC_LoadSigninData_Ack)

end

function SigninProcess.onGC_LoadSigninData_Ack(msg)

    local res = Proto.parseP_GC_LoadSigninData_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_LoadSigninData_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    	local cjson = require("cjson")
        local vec = cjson.decode(res.signinData)
        CheckViewMgr.setSigninTabel(vec)
        -- CheckViewMgr.setRedPoint()
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_LOADSIGNINDATA_ACK)
    return res.code

end

function SigninProcess.onGC_Signin_Ack(msg)

    local res = Proto.parseP_GC_Signin_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_Signin_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    	print("Signin Success!")
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_SIGNIN_ACK)
    return res.code

end

function SigninProcess.onGC_SigninRepair_Ack(msg)

    local res = Proto.parseP_GC_SigninRepair_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_SigninRepair_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    	print("SigninRepair Success!")
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_SIGNINREPAIR_ACK)
    return res.code

end

return SigninProcess
