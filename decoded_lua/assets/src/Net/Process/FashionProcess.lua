require("src.Net.Proto.ProtoInclude")

local FashionProcess = {}
local NetMgr = require("src.Net.NetMgr")
local MsgPrinter = require("src.Net.MsgPrinter")
local CallbackMgr = require("src.Net.CallbackMgr")

function FashionProcess.init()
    NetMgr.addProcess(Proto.Command.GC_FASHIONS_NTF,
        FashionProcess.onGC_Fashions_Ntf)
    NetMgr.addProcess(Proto.Command.GC_RESTOREFASHIONS_ACK,
        FashionProcess.onGC_RestoreFashions_Ack)
    NetMgr.addProcess(Proto.Command.GC_SETFASHIONS_ACK,
        FashionProcess.onGC_SetFashions_Ack)
    NetMgr.addProcess(Proto.Command.GC_GETFASHIONS_ACK,
        FashionProcess.onGC_GetFashions_Ack)

end

function FashionProcess.onGC_GetFashions_Ack(msg)
    
    local res = Proto.parseP_GC_GetFashions_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_GetFashions_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        local cjson = require("cjson")
        local vec = cjson.decode(res.FashionInfo)
        AvatarViewMgr.setFashionTabel(vec)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETFASHIONS_ACK)
    return res.code

end

function FashionProcess.onGC_SetFashions_Ack(msg)

    local res = Proto.parseP_GC_SetFashions_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_SetFashions_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        StandardTipsMgr.show(0, "保存成功")
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_SETFASHIONS_ACK)
    return res.code

end

function FashionProcess.onGC_RestoreFashions_Ack(msg)

    local res = Proto.parseP_GC_RestoreFashions_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_RestoreFashions_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        print("还原成功")
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_RESTOREFASHIONS_ACK)
    return res.code

end

function FashionProcess.onGC_Fashions_Ntf(msg)

    local res = Proto.parseP_GC_Fashions_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_Fashions_Ntf")

    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_FASHIONS_NTF)
    return res.code

end

return FashionProcess
