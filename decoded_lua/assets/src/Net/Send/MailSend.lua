require( "src.Net.Proto.ProtoInclude")

local MailSend = {}
local NetMgr = require("src.Net.NetMgr")

function MailSend.sendCG_CheckUnReadMail_Req()

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_CheckUnReadMail_Req, data)

end

function MailSend.sendCG_GetMail_Req(mailID, type)

    local data = {
        mailIndex = mailID,
        mailType = type,
    }
    NetMgr.send(Proto.writeP_CG_GetMail_Req, data)

end

function MailSend.sendCG_GetMailAttach_Req(mailID, type)

    local data = {
        mailIndex = mailID,
        mailType = type,
    }
    NetMgr.send(Proto.writeP_CG_GetMailAttach_Req, data)

end

function MailSend.sendCG_GetSomeMails_Req(hint1, hint2)

    local data = {
        GruopTimeTip = hint1,
        personCount = hint2,
        mailCount = MailMgr.DEFAULT_SHOWMAIL_SIZE,
    }
    print("CG_GetSomeMails_Req", hint1, hint2)
    NetMgr.send(Proto.writeP_CG_GetSomeMails_Req, data)

end

function MailSend.sendCG_DelMail_Req(mailID, type)

    local data = {
        mailIndex = mailID,
        mailType = type,
    }
    NetMgr.send(Proto.writeP_CG_DelMail_Req, data)

end

return MailSend
