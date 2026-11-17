require( "src.Net.Proto.ProtoInclude")

local FashionSend = {}
local NetMgr = require("src.Net.NetMgr")

function FashionSend.sendCG_GetFashions_Req()

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_GetFashions_Req, data)

end

function FashionSend.sendCG_SetFashions_Req(params)

    local data = {
    	FashionInfo = params,
    }
    NetMgr.send(Proto.writeP_CG_SetFashions_Req, data)

end

function FashionSend.sendCG_RestoreFashions_Req()

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_RestoreFashions_Req, data)

end

return FashionSend
