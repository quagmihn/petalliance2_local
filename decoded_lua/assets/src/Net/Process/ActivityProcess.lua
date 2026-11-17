require("src.Net.Proto.ProtoInclude")

local ActivityProcess = {}
local NetMgr = require("src.Net.NetMgr")
local MsgPrinter = require("src.Net.MsgPrinter")
local CallbackMgr = require("src.Net.CallbackMgr")

function ActivityProcess.init()
    NetMgr.addProcess(Proto.Command.GC_BUYACTIVITYSHOPITEM_ACK,
        ActivityProcess.onGC_BuyActivityShopItem_Ack)
    NetMgr.addProcess(Proto.Command.GC_GETSELFACTIVITYSHOPDATA_ACK,
        ActivityProcess.onGC_GetSelfActivityShopData_Ack)
    NetMgr.addProcess(Proto.Command.GC_SURVIVALBATTLEEND_ACK,
        ActivityProcess.onGC_SurvivalBattleEnd_Ack)
    NetMgr.addProcess(Proto.Command.GC_GETSURVIVALBATTLEDATA_ACK,
        ActivityProcess.onGC_GetSurvivalBattleData_Ack)
    NetMgr.addProcess(Proto.Command.GC_GETWORLDOPENTIME_ACK,
        ActivityProcess.onGC_GetWorldOpenTime_Ack)
    NetMgr.addProcess(Proto.Command.GC_FETCHDAILYCOUNTACTIVITYAWARD_ACK,
        ActivityProcess.onGC_FetchDailyCountActivityAward_Ack)
    NetMgr.addProcess(Proto.Command.GC_FETCHCONTINUELOGINAWARDS_ACK,
        ActivityProcess.onGC_FetchContinueLoginAwards_Ack)
    NetMgr.addProcess(Proto.Command.GC_GETPOKEMONACHIEVEMENTSACT_ACK,
        ActivityProcess.onGC_GetPokemonAchievementsAct_Ack)
    NetMgr.addProcess(Proto.Command.GC_GETPETWIKIACTIVITY_ACK,
        ActivityProcess.onGC_GetPetWikiActivity_Ack)
    NetMgr.addProcess(Proto.Command.GC_GETPETWIKIACTIVITY_NTF,
        ActivityProcess.onGC_GetPetWikiActivity_Ntf)
    NetMgr.addProcess(Proto.Command.GC_FINISHPOKEMONACHIEVEMENTACTIVITY_ACK,
        ActivityProcess.onGC_FinishPokemonAchievementActivity_Ack)
    NetMgr.addProcess(Proto.Command.GC_FETCHWORLDBOSSAWARDS_ACK,
        ActivityProcess.onGC_FetchWorldBossAwards_Ack)
    NetMgr.addProcess(Proto.Command.GC_FETCHTEAMDUNGEONAWARDS_ACK,
        ActivityProcess.onGC_FetchTeamDungeonAwards_Ack)
    NetMgr.addProcess(Proto.Command.GC_FETCHPVPARENAGRADEPOINTAWARDS_ACK,
        ActivityProcess.onGC_FetchPVPArenaGradePointAwards_Ack)
    NetMgr.addProcess(Proto.Command.GC_TIMELIMITCAPSULEEGG_ACK,
        ActivityProcess.onGC_TimeLimitCapsuleEgg_Ack)
    NetMgr.addProcess(Proto.Command.GC_GETSEVENDAYAWARD_ACK,
        ActivityProcess.onGC_GetSevenDayAward_Ack)
    NetMgr.addProcess(Proto.Command.GC_FETCHSPOKESMANGUESSAWARDS_ACK,
        ActivityProcess.onGC_FetchSpokesmanGuessAwards_Ack)
    NetMgr.addProcess(Proto.Command.GC_FETCHCONSUMEAWARDS_ACK,
        ActivityProcess.onGC_FetchConsumeAwards_Ack)
    NetMgr.addProcess(Proto.Command.GC_FETCHGROWTHFUNDAWARDS_ACK,
        ActivityProcess.onGC_FetchGrowthFundAwards_Ack)
    NetMgr.addProcess(Proto.Command.GC_BUYGROWTHFUND_ACK,
        ActivityProcess.onGC_BuyGrowthFund_Ack)
    NetMgr.addProcess(Proto.Command.GC_FETCHDAILYACTIONVALUE_ACK,
        ActivityProcess.onGC_FetchDailyActionValue_Ack)
    NetMgr.addProcess(Proto.Command.GC_FETCHRECHARGEAWARDS_ACK,
        ActivityProcess.onGC_FetchRechargeAwards_Ack)
    NetMgr.addProcess(Proto.Command.GC_FETCHUPGRADEAWARDS_ACK,
        ActivityProcess.onGC_FetchUpgradeAwards_Ack)
    NetMgr.addProcess(Proto.Command.GC_FETCHFIRSTLOGINAWARDS_ACK,
        ActivityProcess.onGC_FetchFirstLoginAwards_Ack)
    NetMgr.addProcess(Proto.Command.GC_FETCHLOGINAWARDS_ACK,
        ActivityProcess.onGC_FetchLoginAwards_Ack)
    NetMgr.addProcess(Proto.Command.GC_GETACTIVITIESDATA_ACK,
        ActivityProcess.onGC_GetActivitiesData_Ack)

end

function ActivityProcess.onGC_GetActivitiesData_Ack(msg)

    local res = Proto.parseP_GC_GetActivitiesData_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_GetActivitiesData_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        print("GetActivitiesData Success!")
        local cjson = require("cjson")
        local vec = cjson.decode(res.data)
        ActivityViewMgr.setActivitiesData(vec)
        RechargeViewMgr.setActivitiesData(vec)
        ActivityHalloweenViewMgr.setActivitiesData(vec)
        ActivityViewMgr.setRedPoint()
        RechargeViewMgr.setRedPoint()
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETACTIVITIESDATA_ACK)
    return res.code

end

function ActivityProcess.onGC_FetchLoginAwards_Ack(msg)

    local res = Proto.parseP_GC_FetchLoginAwards_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_FetchLoginAwards_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        print("FetchLoginAwards Success!")
    elseif res.code == 494 then
        StandardTipsMgr.show(1,"activity2")
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_FETCHLOGINAWARDS_ACK)
    return res.code

end

function ActivityProcess.onGC_FetchFirstLoginAwards_Ack(msg)

    local res = Proto.parseP_GC_FetchFirstLoginAwards_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_FetchFirstLoginAwards_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        print("FetchFirstLoginAwards Success!")
    elseif res.code == 494 then
        StandardTipsMgr.show(1,"activity2")
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_FETCHFIRSTLOGINAWARDS_ACK)
    return res.code

end

function ActivityProcess.onGC_FetchUpgradeAwards_Ack(msg)

    local res = Proto.parseP_GC_FetchUpgradeAwards_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_FetchUpgradeAwards_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        print("FetchUpgradeAwards Success!")
    elseif res.code == 494 then
        StandardTipsMgr.show(1,"activity2")
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_FETCHUPGRADEAWARDS_ACK)
    return res.code

end

function ActivityProcess.onGC_FetchRechargeAwards_Ack(msg)
    
    local res = Proto.parseP_GC_FetchRechargeAwards_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_FetchRechargeAwards_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        print("FetchRechargeAwards Success!")
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_FETCHRECHARGEAWARDS_ACK)
    return res.code

end

function ActivityProcess.onGC_FetchDailyActionValue_Ack(msg)

    local res = Proto.parseP_GC_FetchDailyActionValue_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_FetchDailyActionValue_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
       print("FetchDailyActionValue Success!")
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_FETCHDAILYACTIONVALUE_ACK)
    return res.code

end

function ActivityProcess.onGC_BuyGrowthFund_Ack(msg)

    local res = Proto.parseP_GC_BuyGrowthFund_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_BuyGrowthFund_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_BUYGROWTHFUND_ACK)
    return res.code

end

function ActivityProcess.onGC_FetchGrowthFundAwards_Ack(msg)

    local res = Proto.parseP_GC_FetchGrowthFundAwards_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_FetchGrowthFundAwards_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_FETCHGROWTHFUNDAWARDS_ACK)
    return res.code

end

function ActivityProcess.onGC_FetchConsumeAwards_Ack(msg)

    local res = Proto.parseP_GC_FetchConsumeAwards_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_FetchConsumeAwards_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_FETCHCONSUMEAWARDS_ACK)
    return res.code

end

function ActivityProcess.onGC_FetchSpokesmanGuessAwards_Ack(msg)

    local res = Proto.parseP_GC_FetchSpokesmanGuessAwards_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_FetchSpokesmanGuessAwards_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_FETCHSPOKESMANGUESSAWARDS_ACK)
    return res.code

end

function ActivityProcess.onGC_GetSevenDayAward_Ack(msg)

    local res = Proto.parseP_GC_GetSevenDayAward_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_GetSevenDayAward_Ack")
    local cjson = require("cjson")
    if (Proto.Error.ERROR_OK == res.code) then
        local awardsVec = {}
        for k,v in pairs(res.awards) do
            local info = cjson.decode(v)
            local itemID = nil
            if info.elementType == "m_cash" then
                itemID = 9999
            elseif info.elementType == "g_cash" then
                itemID = 9998
            elseif info.elementType == "exp" then
                itemID = 9997
            elseif info.elementType == "goldCoin" then
                itemID = 9996
            elseif info.elementType == "item" then
                itemID = info.elementID
            end
            table.insert(awardsVec,{itemID,info.num})
        end
        AwardsListMgr.show(SceneMgr.getRunningScene, awardsVec)
        local compoundPetInfo = ActivityViewMgr.getCompoundPetInfo()
        local function showGetPet()
            for k,v in pairs(compoundPetInfo) do
                GachaViewMgr.playGetAPet(v.pokeID, v, function ()
                    showGetPet()
                end)
                table.remove(compoundPetInfo, 1)
                return
            end
        end
        if PetEducationMgr.getTableLength(awardsVec) > 0 then
            showGetPet()
        end
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETSEVENDAYAWARD_ACK)
    return res.code

end

function ActivityProcess.onGC_TimeLimitCapsuleEgg_Ack(msg)

    local res = Proto.parseP_GC_TimeLimitCapsuleEgg_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_TimeLimitCapsuleEgg_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        print("TimeLimitCapsuleEgg Success!")
        if (Proto.Error.ERROR_OK == res.code) then
            for k,v in pairs(res.awardVecStr) do
                print("-------",k,v)
            end
            local cjson = require("cjson")
            local awards = {}
            for k,v in pairs(res.awardVecStr) do
                local award = cjson.decode(v)
                awards[tonumber(k)] = award
            end
            ActivityCapsuleEggView.setTenDrawAward(awards)
            HalloweenCapsuleEggView.setTenDrawAward(awards)
        elseif (Proto.Error.ERROR__PET_BRINGLIMIT == res.code) then
            GachaViewMgr.showBringLimitDialog() 
        elseif (Proto.Error.ERROR_NotEnoughBagFreeCell == res.code) then
            GachaViewMgr.showNotEnoughBagFreeCellDialog() 
        end
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_TIMELIMITCAPSULEEGG_ACK)
    return res.code

end

function ActivityProcess.onGC_FetchPVPArenaGradePointAwards_Ack(msg)

    local res = Proto.parseP_GC_FetchPVPArenaGradePointAwards_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_FetchPVPArenaGradePointAwards_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_FETCHPVPARENAGRADEPOINTAWARDS_ACK)
    return res.code

end

function ActivityProcess.onGC_FetchTeamDungeonAwards_Ack(msg)

    local res = Proto.parseP_GC_FetchTeamDungeonAwards_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_FetchTeamDungeonAwards_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_FETCHTEAMDUNGEONAWARDS_ACK)
    return res.code

end

function ActivityProcess.onGC_FetchWorldBossAwards_Ack(msg)

    local res = Proto.parseP_GC_FetchWorldBossAwards_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_FetchWorldBossAwards_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_FETCHWORLDBOSSAWARDS_ACK)
    return res.code

end

function ActivityProcess.onGC_FinishPokemonAchievementActivity_Ack(msg)

    local res = Proto.parseP_GC_FinishPokemonAchievementActivity_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_FinishPokemonAchievementActivity_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        -- res.pokeAchievementID
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_FINISHPOKEMONACHIEVEMENTACTIVITY_ACK)
    return res.code

end



function ActivityProcess.onGC_GetPetWikiActivity_Ntf(msg)

    local res = Proto.parseP_GC_GetPetWikiActivity_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_GetPetWikiActivity_Ntf")
    for k,v in pairs(res.petWiki) do
        CollectPetActivityViewMgr.setPetWikiActivity(v)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETPETWIKIACTIVITY_NTF)
    return res.code

end

function ActivityProcess.onGC_GetPetWikiActivity_Ack(msg)

    local res = Proto.parseP_GC_GetPetWikiActivity_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_GetPetWikiActivity_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        if res.num == 0 then
            CollectPetActivityViewMgr.open(SceneMgr.getRunningScene)
        else
            CollectPetActivityViewMgr.setPetWikiNum(res.num)
        end
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETPETWIKIACTIVITY_ACK)
    return res.code

end

function ActivityProcess.onGC_GetPokemonAchievementsAct_Ack(msg)

    local res = Proto.parseP_GC_GetPokemonAchievementsAct_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_GetPokemonAchievementsAct_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        CollectPetActivityViewMgr.setPokeAchievementIDs(res.pokeAchievementIDs)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETPOKEMONACHIEVEMENTSACT_ACK)
    return res.code

end

function ActivityProcess.onGC_GetGMActivities_Ack(msg)

    local res = Proto.parseP_GC_GetGMActivities_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_GetGMActivities_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        ActivityViewMgr.setGMCount(res.count)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETGMACTIVITIES_ACK)
    return res.code

end

function ActivityProcess.onGC_GMActivitiesInfo_Ntf(msg)

    local res = Proto.parseP_GC_GMActivitiesInfo_Ntf(msg)
    MsgPrinter.rcvMsg(res, "GC_GMActivitiesInfo_Ntf")

    local cjson = require("cjson")
    for k,v in pairs(res.activities) do
        local tbl = cjson.decode(v)
        ActivityViewMgr.setGMParamsActivity(tbl)
    end

    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GMACTIVITIESINFO_NTF)
    return res.code

end

function ActivityProcess.onGC_FetchContinueLoginAwards_Ack(msg)

    local res = Proto.parseP_GC_FetchContinueLoginAwards_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_FetchContinueLoginAwards_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_FETCHCONTINUELOGINAWARDS_ACK)
    return res.code

end

function ActivityProcess.onGC_FetchDailyCountActivityAward_Ack(msg)

    local res = Proto.parseP_GC_FetchDailyCountActivityAward_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_FetchDailyCountActivityAward_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_FETCHDAILYCOUNTACTIVITYAWARD_ACK)
    return res.code

end

function ActivityProcess.onGC_GetWorldOpenTime_Ack(msg)

    local res = Proto.parseP_GC_GetWorldOpenTime_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_GetWorldOpenTime_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        CharInfo.setServerOpenTime(res.openTime)
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETWORLDOPENTIME_ACK)
    return res.code

end

function ActivityProcess.onGC_GetSurvivalBattleData_Ack(msg)

    local res = Proto.parseP_GC_GetSurvivalBattleData_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_GetSurvivalBattleData_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        local cjson = require("cjson")
        SurviveBattleViewMgr.currfloor = res.currentFloor
        SurviveBattleViewMgr.bossInfo = cjson.decode(res.boss)
        SurviveBattleViewMgr.usedPets = res.vecUsedPets
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETSURVIVALBATTLEDATA_ACK)
    return res.code

end

function ActivityProcess.onGC_SurvivalBattleEnd_Ack(msg)

    local res = Proto.parseP_GC_SurvivalBattleEnd_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_SurvivalBattleEnd_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_SURVIVALBATTLEEND_ACK)
    return res.code

end

function ActivityProcess.onGC_GetSelfActivityShopData_Ack(msg)

    local res = Proto.parseP_GC_GetSelfActivityShopData_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_GetSelfActivityShopData_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
        ActivityShopViewMgr.lastBuyTime = res.lastBuyTime
        ActivityShopViewMgr.buyItemList = res.vecData
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_GETSELFACTIVITYSHOPDATA_ACK)
    return res.code

end

function ActivityProcess.onGC_BuyActivityShopItem_Ack(msg)

    local res = Proto.parseP_GC_BuyActivityShopItem_Ack(msg)
    MsgPrinter.rcvMsg(res, "GC_BuyActivityShopItem_Ack")
    if (Proto.Error.ERROR_OK == res.code) then
    end
    CallbackMgr.doCallFunc(res.code, Proto.Command.GC_BUYACTIVITYSHOPITEM_ACK)
    return res.code

end

return ActivityProcess
