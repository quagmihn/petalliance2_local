require("src.Net.Proto.ProtoInclude")

local BulletinProcess = {}
local NetMgr = require("src.Net.NetMgr")
local MsgPrinter = require("src.Net.MsgPrinter")
local CallbackMgr = require("src.Net.CallbackMgr")

function BulletinProcess.init()
    NetMgr.addProcess(Proto.Command.GC_GETBULLETIN_ACK,
        BulletinProcess.onGC_GetBulletin_Ack)
    NetMgr.addProcess(Proto.Command.GC_LISTBULLETIN_ACK,
        BulletinProcess.onGC_ListBulletin_Ack)

end

function BulletinProcess.onGC_ListBulletin_Ack(msg)
    
    local res = Proto.parseP_GC_ListBulletin_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_ListBulletin_Ack")
    if (Proto.Error.ERROR_OK == res.code.value) then
        NoticeViewMgr.setBullListInfo(res.bulletins)
    end
    CallbackMgr.doCallFunc(res.code.value, Proto.Command.GC_LISTBULLETIN_ACK)
    return res.code.value

end

function BulletinProcess.onGC_GetBulletin_Ack(msg)

    local res = Proto.parseP_GC_GetBulletin_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_GetBulletin_Ack")
    if (Proto.Error.ERROR_OK == res.code.value) then
        NoticeViewMgr.setNoticeInfo(res.info)
    end
    CallbackMgr.doCallFunc(res.code.value, Proto.Command.GC_GETBULLETIN_ACK)
    return res.code.value

end

return BulletinProcess
