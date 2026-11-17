require( "src.Net.Proto.ProtoInclude")

local ActivitySend = {}
local NetMgr = require("src.Net.NetMgr")

function ActivitySend.sendCG_GetActivitiesData_Req()

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_GetActivitiesData_Req, data)

end

function ActivitySend.sendCG_FetchLoginAwards_Req(params)

    local data = {
        day = params
    }
    NetMgr.send(Proto.writeP_CG_FetchLoginAwards_Req, data)

end

function ActivitySend.sendCG_FetchFirstLoginAwards_Req()

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_FetchFirstLoginAwards_Req, data)

end

function ActivitySend.sendCG_FetchUpgradeAwards_Req(params)

    local data = {
        level = params
    }
    NetMgr.send(Proto.writeP_CG_FetchUpgradeAwards_Req, data)

end

function ActivitySend.sendCG_FetchRechargeAwards_Req(params)

    local data = {
        aID = params.aID,
        mCash = params.mCash
    }
    NetMgr.send(Proto.writeP_CG_FetchRechargeAwards_Req, data)

end

function ActivitySend.sendCG_FetchDailyActionValue_Req()

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_FetchDailyActionValue_Req, data)

end

function ActivitySend.sendCG_BuyGrowthFund_Req(params)

    local data = {
        aID = params
    }
    NetMgr.send(Proto.writeP_CG_BuyGrowthFund_Req, data)

end

function ActivitySend.sendCG_FetchGrowthFundAwards_Req(params)

    local data = {
        level = params
    }
    NetMgr.send(Proto.writeP_CG_FetchGrowthFundAwards_Req, data)

end

function ActivitySend.sendCG_FetchConsumeAwards_Req(params)

    local data = {
        aID = params.aID,
        mCash = params.mCash
    }
    NetMgr.send(Proto.writeP_CG_FetchConsumeAwards_Req, data)

end

function ActivitySend.sendCG_FetchSpokesmanGuessAwards_Req(params)

    local data = {
        aID = params.aID,
        awardIndex = params.awardIndex, --0~N
    }
    NetMgr.send(Proto.writeP_CG_FetchSpokesmanGuessAwards_Req, data)

end

function ActivitySend.sendCG_GetSevenDayAward_Req(params)

    local data = {
        sevenDayID = params.sevenDayID,
        selectIndex = params.selectIndex
    }
    NetMgr.send(Proto.writeP_CG_GetSevenDayAward_Req, data)

end

-- data.aID -- 活动ID
-- data.atype -- 宠物1，技�?
function ActivitySend.sendCG_TimeLimitCapsuleEgg_Req(params)

    local data = {
        aID = params.aID,
        atype = params.atype
    }
    NetMgr.send(Proto.writeP_CG_TimeLimitCapsuleEgg_Req, data)

end

function ActivitySend.sendCG_FetchPVPArenaGradePointAwards_Req(params)

    local data = {
        aID = params.aID,
    }
    NetMgr.send(Proto.writeP_CG_FetchPVPArenaGradePointAwards_Req, data)

end

function ActivitySend.sendCG_FetchTeamDungeonAwards_Req(params)

    local data = {
        aID = params.aID,
    }
    NetMgr.send(Proto.writeP_CG_FetchTeamDungeonAwards_Req, data)

end

function ActivitySend.sendCG_FinishPokemonAchievementActivity_Req(params)

    local data = {
        pokeAchievementID = params
    }
    NetMgr.send(Proto.writeP_CG_FinishPokemonAchievementActivity_Req, data)

end


function ActivitySend.sendCG_GetPetWikiActivity_Req()

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_GetPetWikiActivity_Req, data)

end

function ActivitySend.sendCG_GetPokemonAchievementsAct_Req()

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_GetPokemonAchievementsAct_Req, data)

end

function ActivitySend.sendCG_FetchWorldBossAwards_Req(params)

    local data = {
        aID = params.aID,
    }
    NetMgr.send(Proto.writeP_CG_FetchWorldBossAwards_Req, data)

end

function ActivitySend.sendCG_FetchContinueLoginAwards_Req(params)

    local data = {
        aID = params.aID,
    }
    NetMgr.send(Proto.writeP_CG_FetchContinueLoginAwards_Req, data)

end

function ActivitySend.sendCG_FetchDailyCountActivityAward_Req(params)

    local data = {
        aID = params.aID,
        count = params.count,
    }
    NetMgr.send(Proto.writeP_CG_FetchDailyCountActivityAward_Req, data)

end

function ActivitySend.sendCG_GetWorldOpenTime_Req()

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_GetWorldOpenTime_Req, data)

end

function ActivitySend.sendCG_GetSurvivalBattleData_Req()

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_GetSurvivalBattleData_Req, data)

end

function ActivitySend.sendCG_SurvivalBattleEnd_Req(params)

    local data = {
        damage = params.damage,
        usePetID = params.usePetID,
    }
    NetMgr.send(Proto.writeP_CG_SurvivalBattleEnd_Req, data)

end

function ActivitySend.sendCG_GetSelfActivityShopData_Req(params)

    local data = {
    }
    NetMgr.send(Proto.writeP_CG_GetSelfActivityShopData_Req, data)

end

function ActivitySend.sendCG_BuyActivityShopItem_Req(params)

    local data = {
        itemID = params.itemID,
        count = params.count,
    }
    NetMgr.send(Proto.writeP_CG_BuyActivityShopItem_Req, data)

end

return ActivitySend
