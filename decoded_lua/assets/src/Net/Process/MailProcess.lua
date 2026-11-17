require("src.Net.Proto.ProtoInclude")

local MailProcess = {}
local NetMgr = require("src.Net.NetMgr")
local MsgPrinter = require("src.Net.MsgPrinter")
local CallbackMgr = require("src.Net.CallbackMgr")

function MailProcess.init()
    NetMgr.addProcess(Proto.Command.GC_NEWMAILNOTIFY_NTF,
        MailProcess.onGC_NewMailNotify_Ntf)
    NetMgr.addProcess(Proto.Command.GC_DELMAIL_ACK,
        MailProcess.onGC_DelMail_Ack)
    NetMgr.addProcess(Proto.Command.GC_GETSOMEMAILS_ACK,
        MailProcess.onGC_GetSomeMails_Ack)
    NetMgr.addProcess(Proto.Command.GC_GETMAILATTACH_ACK,
        MailProcess.onGC_GetMailAttach_Ack)
    NetMgr.addProcess(Proto.Command.GC_GETMAIL_ACK,
        MailProcess.onGC_GetMail_Ack)
    NetMgr.addProcess(Proto.Command.GC_CHECKUNREADMAIL_ACK,
        MailProcess.onGC_CheckUnReadMail_Ack)

end

function MailProcess.onGC_CheckUnReadMail_Ack(msg)

    local res = Proto.parseP_GC_CheckUnReadMail_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_CheckUnReadMail_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        print("onGC_CheckUnReadMail_Ack hasUnReadGroupMail", res.hasUnReadGroupMail)
        print("onGC_CheckUnReadMail_Ack hasUnReadPersonMail", res.hasUnReadPersonMail)
        if res.hasUnReadGroupMail==1 or res.hasUnReadPersonMail==1 then
            MailMgr.newMailNotify(false)            
        else
            MailMgr.setHasNewMail(false)
        end
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_CHECKUNREADMAIL_ACK)
    return res.code

end

function MailProcess.onGC_GetMail_Ack(msg)

    local res = Proto.parseP_GC_GetMail_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_GetMail_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        --res.mailInfo
        print(res.mailInfo)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETMAIL_ACK)
    return res.code

end

function MailProcess.onGC_GetMailAttach_Ack(msg)

    local res = Proto.parseP_GC_GetMailAttach_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_GetMailAttach_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETMAILATTACH_ACK)
    return res.code

end

function MailProcess.onGC_GetSomeMails_Ack(msg)

    local res = Proto.parseP_GC_GetSomeMails_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_GetSomeMails_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        MailMgr.update(res.mails)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETSOMEMAILS_ACK)
    return res.code

end

function MailProcess.onGC_DelMail_Ack(msg)

    local res = Proto.parseP_GC_DelMail_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_DelMail_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_DELMAIL_ACK)
    return res.code

end

function MailProcess.onGC_NewMailNotify_Ntf(msg)

    local res = Proto.parseP_GC_NewMailNotify_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_NewMailNotify_Ntf")

    MailMgr.newMailNotify()

    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_NEWMAILNOTIFY_NTF)
    return res.code

end

return MailProcess
