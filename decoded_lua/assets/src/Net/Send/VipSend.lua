require( "src.Net.Proto.ProtoInclude")

local VipSend = {}
local NetMgr = require("src.Net.NetMgr")

function VipSend.sendCG_GetVipAward_Req(params)

    local data = {
    	vipID = params.id,
        awardID = params.awardID
    }
    NetMgr.send(Proto.writeP_CG_GetVipAward_Req, data)

end

function VipSend.sendCG_VipAwardInfo_Req(params)

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_VipAwardInfo_Req, data)

end

function VipSend.sendCG_RechargeTestCmd_Req(params)

    local data = {
        payID = params.payID,
        appID = params.appID
    }
    NetMgr.send(Proto.writeP_CG_RechargeTestCmd_Req, data)

end

return VipSend
