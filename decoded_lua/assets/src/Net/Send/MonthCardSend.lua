require( "src.Net.Proto.ProtoInclude")

local MonthCardSend = {}
local NetMgr = require("src.Net.NetMgr")

function MonthCardSend.sendCZ_LoadMonthCard_Req()
    local data = {
    }
    NetMgr.send(Proto.writeP_CZ_LoadMonthCard_Req, data)

end

function MonthCardSend.sendCZ_TakeMonthCardAward_Req(params)

    local data = {
    	id = params,
    }
    NetMgr.send(Proto.writeP_CZ_TakeMonthCardAward_Req, data)

end

function MonthCardSend.sendCG_RechargeCD_Req()

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_RechargeCD_Req, data)

end

return MonthCardSend
