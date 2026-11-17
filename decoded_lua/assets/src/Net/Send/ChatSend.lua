require("src.Net.Proto.ProtoInclude")

local ChatSend = {}
local NetMgr = require("src.Net.NetMgr")
local GenInfo = require("src.Data.GenInfo")

function ChatSend.sendCZ_ScreenChat_Req(content)

    local data = {
        content = {text = content, dataItems = {}},
    }
    NetMgr.send(Proto.writeP_CZ_ScreenChat_Req, data)
	
end

function ChatSend.sendCZ_UseSpaceBugle_Req(params) 

    local data = {
        content = params.content,
        color   = params.color,
        useItem = 1,
        pos     = 1 
    } 
    NetMgr.send(Proto.writeP_CZ_UseSpaceBugle_Req, data)
end

function ChatSend.sendCG_Chat_Req(params)

    local data = {
        charID = params.charID,
        channel   = params.channel,
        concent   = params.concent
    }
    NetMgr.send(Proto.writeP_CG_Chat_Req, data)

end

function ChatSend.sendCG_ChangeChannel_Req(params)

    local data = {
        channel = params.channel,
        data   = params.data
    }
    --print("@@@@@@@@@@@sendCG_ChangeChannel_Req"..sz_T2S(data))
    NetMgr.send(Proto.writeP_CG_ChangeChannel_Req, data)

end

return ChatSend
