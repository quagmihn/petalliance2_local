require( "src.Net.Proto.ProtoInclude")

local TerritorialSend = {}
local NetMgr = require("src.Net.NetMgr")

function TerritorialSend.sendCG_TerritoryInfo_Req(params)

    local data = {
        adventureIDs = params,
    }
    NetMgr.send(Proto.writeP_CG_TerritoryInfo_Req, data)

end

function TerritorialSend.sendCG_TerritoryFight_Req(params)

    local data = {
        adventureID = params.adventureID,
        petsID = params.petsID,
        helpPetsID = params.helpPetsID
    }
    NetMgr.send(Proto.writeP_CG_TerritoryFight_Req, data)

end

function TerritorialSend.sendCG_FightEnd_Req(params)

    local data = {
        isWin = params.isWin,
        adventureID = params.adventureID,
        territoryBattleID = params.territoryBattleID,
        petsID = params.petsID,
    }
    NetMgr.send(Proto.writeP_CG_FightEnd_Req, data)

end

function TerritorialSend.sendCG_TerritoryRankInfo_Req()

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_TerritoryRankInfo_Req, data)

end


function TerritorialSend.sendCG_TerritorialAward_Req()

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_TerritorialAward_Req, data)

end

function TerritorialSend.sendCG_SelfTerritoryInfo_Req()

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_SelfTerritoryInfo_Req, data)

end

function TerritorialSend.sendCG_TerritoryCountInfo_Req()

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_TerritoryCountInfo_Req, data)

end

function TerritorialSend.sendCG_QuerySelfTerritoryIDInfo_Req(params)

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_QuerySelfTerritoryIDInfo_Req, data)

end

function TerritorialSend.sendCG_TerritorialResetInfo_Req()

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_TerritorialResetInfo_Req, data)

end

function TerritorialSend.sendCG_TerritoryInfoNoPets_Req(params)

    local data = {
        adventureIDs = params,
    }
    NetMgr.send(Proto.writeP_CG_TerritoryInfoNoPets_Req, data)

end

return TerritorialSend
