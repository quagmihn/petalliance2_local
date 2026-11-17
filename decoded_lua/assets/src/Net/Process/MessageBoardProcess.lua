require("src.Net.Proto.ProtoInclude")

local MessageBoardProcess = {}
local NetMgr = require("src.Net.NetMgr")
local MsgPrinter = require("src.Net.MsgPrinter")
local CallbackMgr = require("src.Net.CallbackMgr")

function MessageBoardProcess.init()
    NetMgr.addProcess(Proto.Command.GC_GETMESSAGESFBBYAPPROVE_ACK,
        MessageBoardProcess.onGC_GetMessagesFBByApprove_Ack)
    NetMgr.addProcess(Proto.Command.GC_GETMESSAGESFBBYTIME_ACK,
        MessageBoardProcess.onGC_GetMessagesFBByTime_Ack)
    NetMgr.addProcess(Proto.Command.GC_GETMESSAGESPETBYAPPROVE_ACK,
        MessageBoardProcess.onGC_GetMessagesPetByApprove_Ack)
    NetMgr.addProcess(Proto.Command.GC_GETMESSAGESPETBYTIME_ACK,
        MessageBoardProcess.onGC_GetMessagesPetByTime_Ack)
    NetMgr.addProcess(Proto.Command.GC_POSTAPPROVEFB_ACK,
        MessageBoardProcess.onGC_PostApproveFB_Ack)
    NetMgr.addProcess(Proto.Command.GC_POSTAPPROVEPET_ACK,
        MessageBoardProcess.onGC_PostApprovePet_Ack)
    NetMgr.addProcess(Proto.Command.GC_POSTMESSAGEFB_ACK,
        MessageBoardProcess.onGC_PostMessageFB_Ack)
    NetMgr.addProcess(Proto.Command.GC_POSTMESSAGEPET_ACK,
        MessageBoardProcess.onGC_PostMessagePet_Ack)

end

function MessageBoardProcess.onGC_PostMessagePet_Ack(msg)

    local res = Proto.parseP_GC_PostMessagePet_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_PostMessagePet_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_POSTMESSAGEPET_ACK)
    return res.code

end

function MessageBoardProcess.onGC_PostMessageFB_Ack(msg)

    local res = Proto.parseP_GC_PostMessageFB_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_PostMessageFB_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_POSTMESSAGEFB_ACK)
    return res.code

end

function MessageBoardProcess.onGC_PostApprovePet_Ack(msg)

    local res = Proto.parseP_GC_PostApprovePet_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_PostApprovePet_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_POSTAPPROVEPET_ACK)
    return res.code

end

function MessageBoardProcess.onGC_PostApproveFB_Ack(msg)

    local res = Proto.parseP_GC_PostApproveFB_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_PostApproveFB_Ack")
    print("GC_PostApproveFB_Ack",res.code)
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_POSTAPPROVEFB_ACK)
    return res.code

end

function MessageBoardProcess.onGC_GetMessagesPetByTime_Ack(msg)

    local res = Proto.parseP_GC_GetMessagesPetByTime_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_GetMessagesPetByTime_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        MsgBoardView.update(res.comments)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETMESSAGESPETBYTIME_ACK)
    return res.code

end

function MessageBoardProcess.onGC_GetMessagesPetByApprove_Ack(msg)

    local res = Proto.parseP_GC_GetMessagesPetByApprove_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_GetMessagesPetByApprove_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        MsgBoardView.update(res.comments)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETMESSAGESPETBYAPPROVE_ACK)
    return res.code

end

function MessageBoardProcess.onGC_GetMessagesFBByTime_Ack(msg)

    local res = Proto.parseP_GC_GetMessagesFBByTime_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_GetMessagesFBByTime_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        MsgBoardView.update(res.comments)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETMESSAGESFBBYTIME_ACK)
    return res.code

end

function MessageBoardProcess.onGC_GetMessagesFBByApprove_Ack(msg)

    local res = Proto.parseP_GC_GetMessagesFBByApprove_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_GetMessagesFBByApprove_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        MsgBoardView.update(res.comments)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETMESSAGESFBBYAPPROVE_ACK)
    return res.code

end

return MessageBoardProcess
