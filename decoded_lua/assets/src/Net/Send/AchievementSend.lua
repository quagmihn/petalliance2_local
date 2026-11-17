require( "src.Net.Proto.ProtoInclude")

local AchievementSend = {}
local NetMgr = require("src.Net.NetMgr")

function AchievementSend.sendCG_GetAchievements_Req()

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_GetAchievements_Req, data)
    
end

function AchievementSend.sendCG_FinishAchievement_Req(params)

    local data = {
    		achievementID = params.achievementID
    }
    NetMgr.send(Proto.writeP_CG_FinishAchievement_Req, data)

end

function AchievementSend.sendCG_FinishPokemonAchievement_Req(params)

    local data = {
        pokeAchievementID = params.pokeAchievementID
    }
    NetMgr.send(Proto.writeP_CG_FinishPokemonAchievement_Req, data)

end

function AchievementSend.sendCG_GetPokemonAchievements_Req(params)

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_GetPokemonAchievements_Req, data)

end

function AchievementSend.sendCG_GetPotentials_Req(params)

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_GetPotentials_Req, data)

end

function AchievementSend.sendCG_BuyPotential_Req(params)

    local data = {
        potentialID = params.potentialID
    }
    NetMgr.send(Proto.writeP_CG_BuyPotential_Req, data)

end

function AchievementSend.sendCG_ResetAchievement_Req(params)

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_ResetAchievement_Req, data)

end

return AchievementSend
