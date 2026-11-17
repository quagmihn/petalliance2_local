require( "src.Net.Proto.ProtoInclude")

local ExpeditionSend = {}
local NetMgr = require("src.Net.NetMgr")

function ExpeditionSend.sendCG_GetExpeditionData_Req(params)

    local data = {
        type = params.type,
        petList = params.petList
    }
    NetMgr.send(Proto.writeP_CG_GetExpeditionData_Req, data)

end

function ExpeditionSend.sendCG_ExpeditionBattleEnd_Req(params)

    local data = {
        petObjID = params.petObjID,
        petHP    = params.petHP,
        damage   = params.damage,
        quests   = params.quests
    }
    NetMgr.send(Proto.writeP_CG_ExpeditionBattleEnd_Req, data)

end

function ExpeditionSend.sendCG_GetPointLotteryData_Req(params)

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_GetPointLotteryData_Req, data)

end

function ExpeditionSend.sendCG_RollDice_Req(params)

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_RollDice_Req, data)

end

function ExpeditionSend.sendCG_BuyRollCount_Req(params)

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_BuyRollCount_Req, data)

end

return ExpeditionSend
