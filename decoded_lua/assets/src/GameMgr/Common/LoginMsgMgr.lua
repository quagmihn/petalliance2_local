local LoginMsgMgr = {}

LoginMsgMgr.MSG_SIZE = 26

local resName = ""
local process = 0
local loginTime = 0

local scheduler = nil
local schedulerHandle = nil

LoginMsgMgr.CHECK_STATUS = 0

function LoginMsgMgr.Init()
    print("LoginMsgMgr初始化")
    
    resName = "Scene/MsgLoader.csb"
    process = 0
    loginTime = 0
    
    scheduler = require("src.framework.scheduler")
    if schedulerHandle~=nil then
        scheduler.unscheduleGlobal(schedulerHandle)
        schedulerHandle = nil
    end
    
    LoginMsgMgr.CHECK_STATUS = 0
end

function LoginMsgMgr.addUI()
    if CSResourceMgr.getCsbObj(resName) or process>=LoginMsgMgr.MSG_SIZE then
        return
    end
    LoginMsgMgr.IsInLoginProgress = true
    CSResourceMgr.createRes(SceneMgr.getRunningScene, resName):setLocalZOrder(CocosModuleMgr.ZORDER_MSGBOX)
    CSResourceMgr.setRelativePosition(resName, 320, 480)
    CSResourceMgr.setLabelString(resName, "Text_1", CocosModuleMgr.createStringWithFormat({"login26", "0"}), "", 
        CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
    CSResourceMgr.playAllFrame(resName, true)
    CSResourceMgr.setSpeedRate(resName, 0.5)
end

function LoginMsgMgr.updateUI(step)
    process = step
    if not CSResourceMgr.getCsbObj(resName) then
        return
    end
    if step>LoginMsgMgr.MSG_SIZE then
        return
    end
    local node = CSResourceMgr.getNodeByName(resName, "LoadingBar_1")
    local percent = math.ceil(step*100/LoginMsgMgr.MSG_SIZE)
    CocosModuleMgr.setLoadingBarPercent(node, percent, 1, function(p)
        CSResourceMgr.setLabelString(resName, "Text_1", CocosModuleMgr.createStringWithFormat({"login26", p}))
    end)
end

LoginMsgMgr.IsInLoginProgress = false --为了修改加载时不让出洋葱头，所以才加的
function LoginMsgMgr.request() 
    local function reqOthers()
        LoginMsgMgr.updateUI(2)
        NetInterface.send("GC_GetItemPacket_Ack", function()
            local ItemSend = require("src.Net.Send.ItemSend")
            ItemSend.sendCG_GetItemPacket_Req()
        end, function()
            LoginMsgMgr.updateUI(3)
            NetInterface.send("GC_GetPetArmys_Ack", function()
                local PetSend = require("src.Net.Send.PetSend")
                PetSend.sendCG_GetPetArmys_Req()
            end, function()
                LoginMsgMgr.updateUI(4)
                NetInterface.send("GC_GetFinishedAdventures_Ack", function()
                    local AdventureSend = require("src.Net.Send.AdventureSend")
                    AdventureSend.sendCG_GetFinishedAdventures_Req()
                end, function()
                    LoginMsgMgr.updateUI(5)
                    NetInterface.send("GC_GetCharacterValues_Ack", function()
                        local LoginSend = require("src.Net.Send.LoginSend")
                        --第一批请求字段
                        --分成两段的原因:1.有些数据有前后级关系;2.防止回复的协议长度过长而被截          
                        LoginSend.sendCG_GetCharacterValues_Req({"map_lock", "isMArenaOn", "local_freedom", "local_unlimited_pet_storage", "local_unlimited_item_storage",
                            "sciencePoint", "resetScienceConsumeTime", "resetScienceConsumeNum","scienceLevel","todayWArenaFightTimes","todayWArenaFightRefreshTimes","wArenaUpdateTime"})
                    end, function()
                        CharInfo.set({maplock=CharInfo.get().map_lock or 0})
                        LoginMsgMgr.updateUI(6)
                        NetInterface.send("GC_GetCharacterValues_Ack", function()
                            local LoginSend = require("src.Net.Send.LoginSend")
                            --第二批请求字段
                            --分成两段的原因:1.有些数据有前后级关系;2.防止回复的协议长度过长而被截
                            LoginSend.sendCG_GetCharacterValues_Req({"explorePacketNum", "itemPacketNum", "petPacketNum",
                                "todayBuyPowerCount", "lastBuyPowerTime", "furnitureDailyEventTimes", "friendPoints", 
                                "furnitureLostTowerMaxStepNumber", "furnitureSuitcaseValueRate", "furnitureComputerValueRate",
                                "LifeSkillLevel", "LifeSkillCareer", "familyQuestFailedTime", "familyQuestOK", "familyQuestAwardIndex",
                                "todayFamilyQuestNum", "todayFamilyQuestTime", "getFamilyDevoteBufferTime", "familyDevoteBuffer",
                                "goldCoin", "familyDungeonStepNumber", "familyDungeonStepNumberUpdateTime", "recharge",
                                "todayArenaFightTimes", "arenaUpdateTime", "todayArenaFightRefreshTimes", "arenaScore", "topRank",
                                "todayMArenaFightTimes", "marenaUpdateTime", "todayMArenaFightRefreshTimes",
                                "pvpArenaGrade", "pvpArenaPoint", "pvpArenaCoin", "fixPvpArenaPoint", "create_time", "achievementPoint", "arenaRank",
                                "lostTowerFloor", "lostTowerPoint", })
                        end, function()
                            LoginMsgMgr.updateUI(7)
                            NetInterface.send("GC_GetCharacterValues_Ack", function()
                                local LoginSend = require("src.Net.Send.LoginSend")
                                --第三批请求字段
                                --分成两段的原因:1.有些数据有前后级关系;2.防止回复的协议长度过长而被截
                                LoginSend.sendCG_GetCharacterValues_Req({"activity", "familyQuestID", "advExp1", "advExp2", "advExp3", 
                                    "treasureBoxSelect", "worldBossTime", "catchRateAddCount",
                                    "survivalBattleFloor","world"})
                            end, function()
                                LoginMsgMgr.updateUI(8)
                                if HomeInfo.GetLocalHomeInfo() == nil then
                                    HomeInfo.SetCurrentHomeCharID(CharInfo.getCharID())
                                    HomeInfo.GetHomeInfo(false)
                                end
                                if CharInfo.getFamilyID()~=nil and FamilyInfo.GetLocalFamilyInfo()==nil then
                                    FamilyInfo.QueryMyFamily(false, function()
                                        FamilyInfo.UpdateFightPoint(false, StatusBarMgr.getTotalFightPoint())
                                    end)
                                end
                                NetInterface.send("GC_GetExploreData_Ack", function()
                                    local ExploreSend = require("src.Net.Send.ExploreSend")
                                    ExploreSend.sendCG_GetExploreData_Req()
                                end, function()
                                    LoginMsgMgr.updateUI(9)
                                    NetInterface.send("GC_GetMyMapNodeEventInfo_Ack", function()
                                        local AdventureSend = require("src.Net.Send.AdventureSend")
                                        AdventureSend.sendCG_GetMyMapNodeEventInfo_Req()
                                    end, function()
                                        LoginMsgMgr.updateUI(10)
                                        NetInterface.send("GC_CapsuleEggCDs_Ack", function()
                                            local PetSend = require("src.Net.Send.PetSend")
                                            PetSend.sendCG_CapsuleEggCDs_Req()
                                        end, function()
                                            LoginMsgMgr.updateUI(11)
                                            NetInterface.send("GC_LoadSigninData_Ack", function()
                                                local SigninSend = require("src.Net.Send.SigninSend")
                                                SigninSend.sendCG_LoadSigninData_Req()
                                            end, function()
                                                LoginMsgMgr.updateUI(12)
                                                NetInterface.send("GC_RecoverStepNumber_Ack", function()
                                                    local LostTowerSend = require("src.Net.Send.LostTowerSend")
                                                    LostTowerSend.sendCG_RecoverStepNumber_Req()
                                                end, function()
                                                    LoginMsgMgr.updateUI(13)
                                                    NetInterface.send("GC_GetPetWiki_Ack", function()
                                                        local PetSend = require("src.Net.Send.PetSend")
                                                        PetSend.sendCG_GetPetWiki_Req()
                                                    end, function()
                                                        LoginMsgMgr.updateUI(14)
                                                        NetInterface.send("GC_GetWishingTreesData_Ack", function()
                                                            local WishingTreeSend = require("src.Net.Send.WishingTreeSend")
                                                            WishingTreeSend.sendCG_GetWishingTreesData_Req()
                                                        end, function()
                                                            LoginMsgMgr.updateUI(15)
                                                            NetInterface.send("GC_VipAwardInfo_Ack", function()
                                                                local VipSend = require("src.Net.Send.VipSend")
                                                                VipSend.sendCG_VipAwardInfo_Req()
                                                            end, function()
                                                                LoginMsgMgr.updateUI(16)
                                                                NetInterface.send("GC_GetPokemonAchievements_Ack", function()
                                                                    local AchievementSend = require("src.Net.Send.AchievementSend")
                                                                    AchievementSend.sendCG_GetPokemonAchievements_Req()
                                                                end, function()
                                                                    LoginMsgMgr.updateUI(17)
                                                                    NetInterface.send("GC_GetPotentials_Ack", function()
                                                                        local AchievementSend = require("src.Net.Send.AchievementSend")
                                                                        AchievementSend.sendCG_GetPotentials_Req()
                                                                    end, function()
                                                                        LoginMsgMgr.updateUI(18)
                                                                        NetInterface.send("GC_GetActivitiesData_Ack", function()
                                                                            local ActivitySend = require("src.Net.Send.ActivitySend")
                                                                            ActivitySend.sendCG_GetActivitiesData_Req()
                                                                        end, function()
                                                                            LoginMsgMgr.updateUI(19)
                                                                            NetInterface.send("GC_GetMyFriends_Ack", function()
                                                                                local ChatUserSend = require("src.Net.Send.ChatUserSend")
                                                                                ChatUserSend.sendCG_GetMyFriends_Req()
                                                                            end, function()
                                                                                LoginMsgMgr.updateUI(20)
                                                                                NetInterface.send("GC_GetCurrentAdventrue_Ack",function()
                                                                                    local AdventureSend = require("src.Net.Send.AdventureSend")
                                                                                    AdventureSend.sendCG_GetCurrentAdventrue_Req()
                                                                                end, function()
                                                                                    LoginMsgMgr.updateUI(21)
                                                                                    NetInterface.send("ZC_LoadMonthCard_Ack",function()
                                                                                        local MonthCardSend = require("src.Net.Send.MonthCardSend")
                                                                                        MonthCardSend.sendCZ_LoadMonthCard_Req()
                                                                                    end, function()
                                                                                        LoginMsgMgr.updateUI(22)
                                                                                        NetInterface.send("GC_GetWorldOpenTime_Ack", function()
                                                                                        	local ActivitySend = require("src.Net.Send.ActivitySend")
                                                                                        	ActivitySend.sendCG_GetWorldOpenTime_Req()
                                                                                        end, function()
                                                                                            LoginMsgMgr.updateUI(23)
                                                                                            NetInterface.send("GC_GetScienceDatas_Ack", function()
                                                                                                local PetSend = require("src.Net.Send.PetSend")
                                                                                                PetSend.sendCG_GetScienceDatas_Req()
                                                                                            end, function()
                                                                                                LoginMsgMgr.updateUI(24)
                                                                                                TreasureBoxInfo.GetTreasureBoxData(TreasureBoxInfo.checkRedPoint)
                                                                                                NetInterface.send("GC_CheckUnReadMail_Ack",function()
                                                                                                    local MailSend = require("src.Net.Send.MailSend")
                                                                                                    MailSend.sendCG_CheckUnReadMail_Req()
                                                                                                end, function()
                                                                                                    LoginMsgMgr.updateUI(25)
                                                                                                    NetInterface.sendWithBlock("GC_GetWorldBoss_Ack", function()
                                                                                                        local BossSend = require("src.Net.Send.WorldBossSend")
                                                                                                        BossSend.sendCG_GetWorldBoss_Req()
                                                                                                    end, function()
                                                                                                        WorldBossInfo.checkWorldBossTakeAward()
                                                                                                        WorldMapMgr.refreshWorldBoss()
                                                                                                        LoginMsgMgr.updateUI(26)
                                                                                                        NetInterface.send("ZC_QuestList_Ack", function()
                                                                                                            local NewQuestSend = require("src.Net.Send.NewQuestSend")
                                                                                                            NewQuestSend.sendCZ_QuestList_Req()
                                                                                                        end, function()
                                                                                                            CocosModuleMgr.setScreenTouch(false)
                                                                                                            TownChatMgr.changeChannel(function()
                                                                                                                CocosModuleMgr.setScreenTouch(true)
                                                                                                                TeamInfo.checkTeamWhenLogin(function()
                                                                                                                    QuestInfo.checkAllQuestAndFinish()
                                                                                                                    if not GameGuideMgr.checkIsGuiding() and SceneMgr.currentScene=="MainScene" then
                                                                                                                        NoticeViewMgr.show(SceneMgr.getRunningScene)

          --                                                                                                              local url = "http://192.168.240.1:8080/m/game/"
        --                                                                                                                if device.platform=="ios" then
      --                                                                                                                      iOSFunction.showWebPage(url, true, true)
    --                                                                                                                    elseif device.platform=="android" then
  --                                                                                                                          AndroidFunction.showWebPage(url, true, true)
--                                                                                                                        end

                                                                                                                    end
                                                                                                                end)
                                                                                                            end)
                                                                                                            CSResourceMgr.removeCSObjectByTag(resName)
                                                                                                            --最好把请求任务的消息放在最后发
                                                                                                            --！！！！不许在这里乱发协议
                                                                                                            print("其他数据请求完毕，另加需要增加LoginMsgMgr.MSG_SIZE")
                                                                                                            --刚进主城宠物按钮红点判断
                                                                                                            BasicMenuMgr.setPetEductionRedPoint()
                                                                                                            WorldMapAwardsMgr.IS_LOGIN = false
                                                                                                            WorldMapAwardsMgr.requestData(function()
                                                                                                                TaskWatcherManager.requestGetTaskPrizeInfo(function()
                                                                                                                    local shopList = VipShopViewMgr.getVipShopList()
                                                                                                                    local goodsIDList = {}
                                                                                                                    for k,v in pairs(shopList) do
                                                                                                                        table.insert(goodsIDList, "buyMarketItemNum_"..v.id)
                                                                                                                        table.insert(goodsIDList, "buyMarketItemTime_"..v.id)
                                                                                                                    end
                                                                                                                    NetInterface.sendWithBlock("GC_GetCharacterValues_Ack", function()
                                                                                                                        local LoginSend = require("src.Net.Send.LoginSend")
                                                                                                                        LoginSend.sendCG_GetCharacterValues_Req(goodsIDList)
                                                                                                                    end, function()
                                                                                                                    -- PurchaseViewMgr.setVipShopRedPoint()
                                                                                                                    end)
                                                                                                                end)
                                                                                                            end)                                                                                                    
                                                                                                            LoginMsgMgr.IsInLoginProgress = false
                                                                                                            local param = {}
                                                                                                            GameLogMgr.OnGameStateChange(GameLogMgr.UserGameState.STATE_LOADINGTOGAME,param)
                                                                                                            --存储苹果表需要的数据
                                                                                                            iWatchConnectivity.saveMainData()
                                                                                                            iWatchConnectivity.saveItemData()
                                                                                                            iWatchConnectivity.initSession()
                                                                                                            iWatchConnectivity.checkCatchPet()                                                                                                    
                                                                                                        end)
                                                                                                    end)
                                                                                                end)
                                                                                            end)
                                                                                        end)
                                                                                    end)
                                                                                end)
                                                                            end)
                                                                        end)
                                                                    end)
                                                                end)                                                            
                                                            end)
                                                        end)
                                                    end)
                                                end)
                                            end)
                                        end)
                                    end)
                                end)
                            end)
                        end)
                    end)
                end)
            end)
        end)
    end

    local function reqPets(callback)
        NetInterface.send("GC_QueryPokemons_Ack", function()
            local PetSend = require("src.Net.Send.PetSend")
            PetSend.sendCG_QueryPokemons_Req()
        end, callback)
    end

    local function checkPets()
        print("当前未激活宠物信息获取进度：", PokemonInfo.getEndIndex().."/"..PokemonInfo.getUnactivePetNum())
        local reserveCount = PokemonInfo.getUnactivePetNum()
        LoginMsgMgr.updateUI(reserveCount > 0 and PokemonInfo.getEndIndex()/reserveCount or 1)

        if PokemonInfo.getUnactivePetNum()>PokemonInfo.getEndIndex() then
            reqPets(checkPets)
        else
            reqOthers()
        end

    end

    loginTime = CharInfo.getServerTime()
    LoginMsgMgr.updateUI(1)
    checkPets()

end

function LoginMsgMgr.refreshServerTime()
    --[[
    if schedulerHandle~=nil then
        scheduler.unscheduleGlobal(schedulerHandle)
        schedulerHandle = nil
    end
    schedulerHandle = scheduler.performWithDelayGlobal(function()
        print("LoginMsgMgr.refreshServerTime")
    end, dTime) 
    ]]
    if loginTime==0 then
    	return
    end
    local refreshClock = 6*3600
    local dayDiff = CocosModuleMgr.getDayTimeDiff(loginTime, CharInfo.getServerTime(), refreshClock)
    print("LoginMsgMgr.refreshServerTime DayDiff:", dayDiff)
    if dayDiff~=0 then
        loginTime = CharInfo.getServerTime()
        
        --已经过了一天，请求每日刷新
        NetInterface.send("GC_GetMyMapNodeEventInfo_Ack", function()
            local AdventureSend = require("src.Net.Send.AdventureSend")
            AdventureSend.sendCG_GetMyMapNodeEventInfo_Req()
        end, function()
            print("每日刷新数据请求完毕")
            NetInterface.send("GC_LoadSigninData_Ack", function()
                local SigninSend = require("src.Net.Send.SigninSend")
                SigninSend.sendCG_LoadSigninData_Req()
            end, function()
                print("每日签到数据请求完毕")
--                CheckViewMgr.show(SceneMgr.getRunningScene)
            end)
        end)
    end
end

function LoginMsgMgr.getLoginTime()
    return loginTime
end

return LoginMsgMgr