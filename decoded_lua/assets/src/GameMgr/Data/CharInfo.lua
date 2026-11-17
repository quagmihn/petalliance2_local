local BattleCotroller   = require("src.GameMgr.Battle.BattleCotroller")
local PVPDailog         = require("src.GameMgr.Battle.UI.PVPDailog") 

local CharInfo = {}

local info = {}
local readContent = nil
local mcharID = 0
local timeDiff = 0
local timeZone = 0
local loginTime = 0
local serverOpenTime = 0
local updateVipShopRedPoint = false

local VipInfoConfig = nil
local SigninInfoConfig = nil
local SigninRepairCostInfoConfig = nil
local BuyPowerInfoConfig = nil
local GoldPointInfoConfig = nil
local FashionShowAwardInfoConfig = nil
local FashionShowRuleInfoConfig = nil

local mlifeSkillInfo = nil --生活技能信息

function CharInfo.Init()
    info = {
        username = "test",
        nickname = "test",
        gender = 0,
        g_cash = 0,
        m_cash = 0,
        totalmoney = 0,
        activitypoint = 0,
        viplevel = 1,
        level = 1,
        exp = 0,
        actionvalue = 0,
        actionvaluemax = 0,
        lastactionvaluechangetime = 0,  -- 体力最后更新时间
        lasteatfoodtime = 0,            -- 食物增加体力最后更新时间
        currentfoodtype = 0,            -- 当前食物类型
        
        todayarenafighttimes = 0,       -- 今日竞技场挑战次数    
        arenaupdatetime = 0,            -- 竞技场数据刷新时间
        todayarenafightrefreshtimes = 0,-- 今日购买挑战次数
        todayarenafightcdendtime = 0,   -- 挑战冷却时间
        arenascore = 0,                 -- 竞技场积分
        toprank = 0,                    -- JJC最高名次
        arenarank = 0,                  -- JJC当前名次

        todaymarenafighttimes = 0,
        marenaupdatetime = 0,
        todaymarenafightrefreshtimes = 0,
        todaymarenafightcdendtime = 0,

        ismarenaon = false,             -- 是否手动战斗
        
        pvparenagrade = 0,              -- 大联盟赛杯段
        pvparenapoint = 0,              -- 大联盟赛积分

        pvparenacoin = 0,               -- 大联盟赛币

        fixpvparenapoint = 0,           -- 大联盟赛已连续扣除分数
        
        explorepacketnum = 10,          -- 探索背包上限
        itempacketnum = SystemInfo.getGlobalConfigAddInfoByID(6601).values[1],              --物品背包上限
        petpacketnum = SystemInfo.getGlobalConfigAddInfoByID(6701).values[1],               --宠物背包上限
        
        dailyquestpower = 0,            -- 活跃度
        dailyquestgift0 = -1,           -- 第一阶段活跃度宝箱是否领取（0未领取 1 已领取）
        dailyquestgift1 = -1,           -- 第二阶段活跃度宝箱是否领取（0未领取 1 已领取）
        dailyquestgift2 = -1,           -- 第三阶段活跃度宝箱是否领取（0未领取 1 已领取）
        
        curfashion = "",
        
        maplock = 0,                    -- 地图解锁id
        missionlock = 0,                -- 任务解锁id
        
        losttowerpoint = 0,             -- 千层塔积分
        furniturelosttowermaxstepnumber = 0,   --千层塔步数上限附加
        losttowerfreetransfer = 0,        -- 传送免费标志
        
        lifeskilllevel = 0,             --生活技能等级
        
        -- 关卡副本最高关卡经验
        advexp1 = 0,
        advexp2 = 0,
        advexp3 = 0,

        vipShopGoodsInfo = {},
        survivalbattlefloor = 0,
        survivalbattletime = 0,
        getsurvivaltime = 0,
        survivalBattlePets = {},
    }
    readContent = nil
    mcharID = 0
    timeDiff = 0
    timeZone = 8*3600
    loginTime = 0
    serverOpenTime = 0

    if VipInfoConfig==nil then
        VipInfoConfig = require("src.DatReader.VipInfoConfig")
        VipInfoConfig.init()
    end
    
    if GoldPointInfoConfig==nil then
        GoldPointInfoConfig = require("src.DatReader.GoldPointInfoConfig")
        GoldPointInfoConfig.init()
    end
    
    if BuyPowerInfoConfig==nil then
        BuyPowerInfoConfig = require("src.DatReader.BuyPowerInfoConfig")
        BuyPowerInfoConfig.init()
    end
    
    if SigninInfoConfig==nil then
        SigninInfoConfig = require("src.DatReader.SigninInfoConfig")
        SigninInfoConfig.init()
    end

    if SigninRepairCostInfoConfig==nil then
        SigninRepairCostInfoConfig = require("src.DatReader.SigninRepairCostInfoConfig")
        SigninRepairCostInfoConfig.init()
    end
    
    if FashionShowAwardInfoConfig==nil then
        FashionShowAwardInfoConfig = require("src.DatReader.FashionShowAwardInfoConfig")
        FashionShowAwardInfoConfig.init()
    end
    
    if FashionShowRuleInfoConfig==nil then
        FashionShowRuleInfoConfig = require("src.DatReader.FashionShowRuleInfoConfig")
        FashionShowRuleInfoConfig.init()
    end

    mlifeSkillInfo = nil
end

function CharInfo.setCharWorld(world)
    info.world = world
end

function CharInfo.getCharWorld()
    return info.world
end

function CharInfo.setCharID(charID)
    mcharID = charID
    print("-----current charID: ", charID)
end

function CharInfo.getCharID()
    return mcharID
end

function CharInfo.setServerTime(val)
    print("-----server time:", val, CocosModuleMgr.getTimeStr(val))
    print("-----os time:", os.time(), CocosModuleMgr.getTimeStr(os.time()))
    timeDiff = val - os.time()

    if CharInfo.getCharID() == 0 then
        return
    end
    
    --所有需要刷新时间的地方都写在这里
    ExploreInfo.refreshServerTime()
    PetExploreMgr.refreshServerTime()
    ArenaViewMgr.refreshServerTime()
    StatusBarMgr.refreshServerTime()
    LoginMsgMgr.refreshServerTime()
    StageBossListMgr.refreshServerTime()
    GachaViewMgr.refreshServerTime()
    AdvConfirmMgrNew.refreshServerTime()
    LostTowerInfo.refreshServerTime()
    MissionListMgr.refreshServerTime()
    TeamViewMgr.refreshServerTime()
    ActivityViewMgr.refreshServerTime()
    ArenaPKViewMgr.refreshServerTime()
    WorldBossInfo.refreshServerTime()
end

function CharInfo.getServerTime()
    local time = timeDiff + os.time()
    return time
end

function CharInfo.setServerTimeZone(val)
    print("-----server time zone:", val)
    timeZone = val
end

function CharInfo.getServerTimeZone()
    return timeZone
end

function CharInfo.update(jsonCode)
    local cjson = require("cjson")
    local j = cjson.decode(jsonCode)
    for k, v in pairs(j) do
        local oldkey = k
        --print("oldkey is ................."..oldkey)
        local key = string.lower(k)
        local preVal = info[key]
        local nowStrVal, preStrVal = v, preVal
        if type(v)=="table" then
        	nowStrVal = cjson.encode(v)
        end
        if type(preVal)=="table" then
            preStrVal = cjson.encode(preVal)
        end
        if key == "familyquestid" then
            if nowStrVal~=preStrVal or j.familyquestfailedtime ~= info.familyquestfailedtime then
                local posY = TownMapMgr.DEFAULT_TMAP_POSY_DIFF
                local diff = CocosModuleMgr.getScreenSizeDiff()
                if diff > 0.0 and diff < 100.0 then
                    posY = posY + diff * 1.26
                end
                FurnitureViewMgr.checkRandomQuestNPC(v or 0, posY)
            end
        end 
        if nowStrVal~=preStrVal then
            info[key] = v
            --print("-----------CharInfo", key, v)
            if key=="actionvalue" or key=="lastactionvaluechangetime" then
                StatusBarMgr.refreshServerTime()
                local actionVal, changeTime = CharInfo.getActionValue()
                local avrs = SystemInfo.getGlobalConfigAddInfoByID(4).values[1]
                local actionMax = CharInfo.getActionValueMax()
                changeTime = changeTime or 0
                local timediff = (actionMax-actionVal-1)*avrs+changeTime
                print(timediff.."秒后，体力回复满...")
                if timediff>0 then
                    BaseFunction.cancelLocalNotificationWithKey(3)
                    BaseFunction.registerLocalNotification(os.time()+timediff, nil, "idling29", "", 3, 0)
                end
            elseif key=="todaybuypowercount" or key=="lastbuypowertime" then
                StatusBarMgr.refreshBuyPowerTimes()
            elseif key=="level" then
                NetInterface.sendWithBlock("GC_GetActivitiesData_Ack", function()
                    local ActivitySend = require("src.Net.Send.ActivitySend")
                    ActivitySend.sendCG_GetActivitiesData_Req()
                end, nil, function(code)
                    TipsMgr.showError(nil, code)
                end)
                StatusBarMgr.refreshLevel()
                LevelUpViewMgr.show(preVal, v)
                GameLogMgr.OnGameStateChange(GameLogMgr.UserGameState.STATE_LEVELUP)
                TownMapMgr.refreshNameLabel(nil, v)
                if TownMapMgr.refreshLevel then
                    TownMapMgr.refreshLevel()
                end
                PetFormationMgr.addPetArmy(v)
                MissionListMgr.refreshLevel()
                ScienceInfo.refreshLevel()
                TaskWatcherManager.onUserLevelUp({level=v})
            elseif key=="viplevel" then
                StatusBarMgr.refreshVipLevel()
            elseif key=="m_cash" then
                StatusBarMgr.refreshCash()
                PVPQuestListMgr.refreshDiamond()
                PVPQuestShopMgr.refreshDiamond()
                ScienceViewMgr.refreshCash()
            elseif key=="g_cash" then
                StatusBarMgr.refreshGold()
                PetExploreMgr.refreshGold()
                PVPQuestListMgr.refreshGold()
                PVPQuestShopMgr.refreshGold()
                ScienceViewMgr.refreshGold()
            elseif key== "expeditionpoint" then
                print("expeditionpoint~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~") 
                StatusBarMgr.refreshExpeditionScore()
            elseif key=="arenascore" then
                StatusBarMgr.refreshScore()
            elseif key=="dailyquestpower" then
                MissionListMgr.refreshAP()
            elseif key=="curfashion" then
                WorldMapMgr.changeAvatar()
                EmbeddedMapMgr.changeAvatar()
                TownMapMgr.changeAvatar()
                StatusBarMgr.refreshHead()
            elseif key == "familyid" then
                info.confraternityid = v
                if v == 0 then
                    info.hasconfraternity = 0
                    FamilyInfo.SetLocalFamilyInfo(nil)
                else
                    if info.hasconfraternity == 0 and FamilyListViewMgr.IsOpen() then
                        FamilyListViewMgr.hide()
                        --MyFamilyLstViewMgr.show(SceneMgr.getRunningScene)
                    end
                    info.hasconfraternity = 1
                    FamilyInfo.QueryMyFamily(false, function()
                        FamilyInfo.UpdateFightPoint(false, StatusBarMgr.getTotalFightPoint())
                    end)
                end
            elseif key == "furnituredailyeventtimes" then
                FurnitureTVMgr.setMaxTimes(v)
            elseif key == "familyquestid" then
                local msInfo = QuestInfo.getFamilyQuestInfoById(v)
                if msInfo then
                    MissionListMgr.checkRedPoint()
                    if msInfo.familyQuestType==Proto.FQT_ARREST then
                        AdventureInfo.setFamilyQuestInfo(msInfo.params[2], msInfo.params[3], msInfo.params[1])
                    elseif msInfo.familyQuestType==Proto.FQT_MONSTER then
                        AdventureInfo.setFamilyQuestInfo(msInfo.params[2], msInfo.params[3], nil, msInfo.params[1])
                    end
                end
            elseif key == "familyquestok" then
                if v==1 then
                    AdventureInfo.setFamilyQuestInfo()
                end
                MissionListMgr.checkRedPoint()
            elseif key == "familydevotebuffer" then
                StatusBarMgr.setFamilyBuffBtn()
            elseif key == "create_time" then 
                GameLogMgr.roleInfo.roleCreateTime = v
                print("GameLogMgr.roleInfo.roleCreateTime"..GameLogMgr.roleInfo.roleCreateTime)
            elseif key == "pvpbattleid" then
                print("charInfo~~~~~~~~~~pvpBattleID",v)
                local battleID = tonumber(v)
                BattlePVPMgr.onCreateBattleID(battleID)
--                if BattlePVPMgr.mIsPVPBattle then
--                    if not battleID then
--                        DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene,2,"对手已退出PVP战斗",function() 
--                                    BattlePVPMgr.endCalcTime()
--                                    BattleUIMgr.cleanUIMgr() 
--                                    BattleMapMgr.cleanPVPInfo()
--                                    BattlePVPMgr.cleanPVPInfo()      
--                                    SceneMgr.replaceScene(SceneMgr.getRunningScene, SceneMgr.previousScene) 
--                                end,nil,nil,false)
--                    end
--                end
            elseif key == "pvpserverid" then  
                print("charInfo~~~~~~~~~~pvpServerID",v)
                BattlePVPMgr.setserverID(tonumber(v))
            elseif key == "treasureboxselect" then
                if type(v) ~= "string" then
                    print("[CHAR_VALUE_DIAG] treasureboxselect expected string, got "..type(v))
                else
                    print("charInfo~~~~~~~~~~treasureBoxSelect",sz_T2S(v))
                end
                if type(v) == "string" and #v > 0 then
                    local TreasureBoxSend = require("src.Net.Send.TreasureBoxSend")
                    NetInterface.send("GC_SelectTreasureBox_Ack", function()
                        TreasureBoxSend.sendCG_SelectTreasureBox_Req({boxID=0})
                    end, function()
                    end, function(code)
                        TipsMgr.showError(nil, code)
                    end)
                end
            elseif key == "catchrateaddcount" then
                if ActivityViewMgr.getCatchPetValue().value==0 then
                	info.catchrateaddcount = 0
                end
            elseif key == "arenarank" then
                TownMapMgr.refreshNameLabel(nil, nil, nil, v)
            elseif key == "petequips" then
                --print("charInfo~~~~~~~~~~petequips=",sz_T2S(v))
                PetEquipmentMgr.setPetEquipmentFromServer(v)
            elseif key == "sciencepoint" then
                ScienceInfo.changeSciencePoint()
            end
            AchievementListMgr.isThisAchievementOK(key)
            TaskWatcherManager.processGetTaskPrizeInfo(oldkey,v)
        end
        local tempStr = string.sub(k,1,17)
        if tempStr == "buyMarketItemNum_" or tempStr == "buyMarketItemTime" then
            info.vipShopGoodsInfo[k] = v
            updateVipShopRedPoint = true
        end
    end
    if updateVipShopRedPoint == true then
        PurchaseViewMgr.setRedPoint()
        -- PurchaseViewMgr.setVipShopRedPoint()
        updateVipShopRedPoint = false
    end
end

function CharInfo.set(params, boolVal)
    local cjson = require("cjson")
    for key, var in pairs(params) do
        local k = string.lower(key)
        local preVal = info[key]
        local nowStrVal, preStrVal = var, preVal
        --[[
        --这里就不检查table是否和之前数据一样了
        if type(var)=="table" then
            nowStrVal = cjson.encode(var)
        end
        if type(preVal)=="table" then
            preStrVal = cjson.encode(preVal)
        end]]
        if nowStrVal~=preStrVal then
            if type(var)=="table" then
                info[k] = clone(var)
            else
                info[k] = var
            end            
            --print("-----------CharInfo", k, var)
            if k=="maplock" then
                local lockinfoVec = lua_string_split(var, "-")
                if lockinfoVec[1] then
                    info.maplock = tonumber(lockinfoVec[1]) or 0
                end
                if lockinfoVec[2] then
                    info.missionlock = tonumber(lockinfoVec[2]) or 0
                end
                WorldMapMgr.checkMapLockInfo(boolVal)
                BasicMenuMgr.checkMapLockInfo(boolVal)
                StatusBarMgr.checkMapLockInfo(boolVal)
                EmbeddedMapMgr.checkNPC()
            elseif k=="g_cash" then
                StatusBarMgr.refreshGold()
                PetExploreMgr.refreshGold()
                ScienceViewMgr.refreshGold()
            elseif key=="curfashion" then
                WorldMapMgr.changeAvatar()
                EmbeddedMapMgr.changeAvatar()
                TownMapMgr.changeAvatar()
                StatusBarMgr.refreshHead()
            end
        end
	end
end

function CharInfo.get()
	return info
end

function CharInfo.getUserName()
	return info.username
end

function CharInfo.getNickName()
    return info.nickname
end

function CharInfo.setNickName(nameStr)
    info.nickname = nameStr
end

function CharInfo.getSex()
    return info.gender
end

function CharInfo.getGCash()
    return info.g_cash
end

function CharInfo.getMCash()
    return info.m_cash
end

function CharInfo.getExpeditionPoint()
    return info.expeditionpoint
end

function CharInfo.setExpeditionPoint(score)
    info.expeditionpoint = score
end

function CharInfo.getExpediCreateTime()
    return info.expeditioncreatetime
end

function CharInfo.getFinishExpeditionLevel()
    return info.finishexpeditionlevel
end

function CharInfo.getFinishExpeditionTime()
    return info.finishexpeditiontime
end

function CharInfo.getPasswordGiftTime()
    return info.passwordgifttime
end

function CharInfo.getPasswordGiftNum()
    return info.passwordgiftnum
end

function CharInfo.getPasswordProduct()
    return info.passwordproduct
end

function CharInfo.getCurrentExpeditionLevel()
    return info.currentexpeditionlevel
end

function CharInfo.setExpediCreateTime(time)
    info.expeditioncreatetime = time
end

function CharInfo.getActivityPoint()
    if not ActivityShopViewMgr.checkPointValid() then
    	return 0
    end
    return info.activitypoint
end

function CharInfo.getRechargeTotal()
	return info.m_cashtotal
end

function CharInfo.getVIPLevel()
    return info.viplevel
end

function CharInfo.getLevel()
    return info.level
end

function CharInfo.getExp()
    return info.exp
end

function CharInfo.getArenaScore()
    return info.arenascore or 0
end

function CharInfo.getArenaTopRank()
    return info.toprank or 0
end

function CharInfo.getArenaRank()
    return info.arenarank or 0
end

function CharInfo.getActionValue()
    local nowActionValue = info.actionvalue
    local lastActionValueChangeTime = info.lastactionvaluechangetime
    local now = CharInfo.getServerTime()
    local actionValueMax = CharInfo.getActionValueMax()
    local avrs = SystemInfo.getGlobalConfigAddInfoByID(4).values[1]
    -- 家具缩短恢复时间
    local furnitureID = HomeInfo.GetMaxRareDegreeFurniture(Proto.FT_BED)
    if furnitureID then
        local speedRate = (100-ItemInfo.getItemInfoById(HomeInfo.GetMaxRareDegreeFurniture(Proto.FT_BED)).paramB)/100
        avrs = avrs * speedRate
    end
    
    local nextChangeTime = nil
    if now>lastActionValueChangeTime+avrs then
        local newActionValue = nowActionValue+math.floor((now-lastActionValueChangeTime)/avrs)
        if newActionValue>actionValueMax then
            if nowActionValue>actionValueMax then
                newActionValue = nowActionValue
            else
                newActionValue = actionValueMax
            end
        else
            nextChangeTime = lastActionValueChangeTime+math.ceil((now-lastActionValueChangeTime)/avrs)*avrs-now
        end
        nowActionValue = newActionValue
    else
        if nowActionValue<actionValueMax then
            nextChangeTime = lastActionValueChangeTime+avrs-now
        end
    end
    print("CharInfo#nowActionValue", nowActionValue, "CharInfo#nextChangeTime", tostring(nextChangeTime),
        "CharInfo#actionValueMax", actionValueMax)
    return nowActionValue, nextChangeTime
end

function CharInfo.getActionValueMax()
    local actionvaluemax = ExperienceInfo.getExperienceInfoByID(info.level).limitPower
	return actionvaluemax
end

function CharInfo.setLocalSettings(valTable)
    local infoVec = UserSettings.get("CharID"..CharInfo.getCharID(), 11) or {}
    for key, var in pairs(valTable) do
        infoVec[key] = var
    end
    local writeVec = {}
    writeVec["CharID"..CharInfo.getCharID()] = infoVec
    UserSettings.set(writeVec, 11)
end

function CharInfo.getLocalSettings(key)
    local infoVec = UserSettings.get("CharID"..CharInfo.getCharID(), 11)
    if infoVec then
        return infoVec[key]
    end
    return nil
end

function CharInfo.setCurReadContent(val)
    readContent = val
end

function CharInfo.getCurReadContent()
    local val = readContent
    return val
end

function CharInfo.getCurfashion()
    return info.curfashion
end

function CharInfo.getHeadIcon(fashionInfo)
    if not fashionInfo then
    	return ""
    end
    local skinInfo = PlayerAnimeMgr.skinInfoTransfer(fashionInfo)
    if skinInfo[2] then
    	local iInfo = ItemInfo.getFashionItemInfoById(skinInfo[2])
    	if iInfo then
    		return iInfo.filePath
    	end
    end
    return "empty.png"
end

function CharInfo.doCommand(command, param)
    local cjson = require("cjson")
    local res = cjson.decode(param)
	if command=="mxmevo.chat.ntf" then
        local content = cjson.decode(res.concent)
	    if content.home_msg ~= nil then
            --print("$$$$$$$$$$invite_enter_home res.charIDFrom="..tostring(res.charIDFrom))
            if content.home_msg == HomeInfo.CHAT_CONTENT_INVITE_ENTER_HOME then
                if tonumber(res.charIDFrom) ~= CharInfo.getCharID() and (SceneMgr.currentScene ~= "HomeScene" or HomeInfo.GetCurrentHomeCharID() ~= tonumber(res.charIDFrom)) and not TeamInfo.getInfo(TeamInfo.KEY_TEAMID) and SceneMgr.currentScene ~= "BossMapScene" then
                    DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 2, res.charIDFromName..LuaSqlite.getLanguageByKey("home003"), function()
                        if SceneMgr.currentScene == "HomeScene" then
                            HomeInfo.BroadcastHomePlayerLeaveMsg(CharInfo.getNickName())
                        end
                        HomeInfo.SetCurrentHomeCharID(tonumber(res.charIDFrom))
                        FamilyInfo.SetLastQueryMemberDetailInfo({nickname = res.charIDFromName})
                        SceneMgr.mapEnterType = 1
                        SceneMgr.replaceScene(SceneMgr.getRunningScene, "HomeScene")
                    end, nil, nil, false)
                end
            elseif content.home_msg == HomeInfo.CHAT_CONTENT_HOME_PLAYER_UPDATE then
                --print("@@@@@@@@@@@@recv HomeInfo.CHAT_CONTENT_HOME_PLAYER_UPDATE:"..sz_T2S(content))
                if tonumber(res.charIDFrom) ~= CharInfo.getCharID() and SceneMgr.currentScene == "HomeScene" then
                    HomeInfo.AddLocalPlayer(res.charIDFrom, content.level, content.confraternity, content.nickname, content.petID, content.petname, content.posx, content.speed, content.playerSkin)
                end
            elseif content.home_msg == HomeInfo.CHAT_CONTENT_HOME_PLAYER_LEAVE then
                if tonumber(res.charIDFrom) ~= CharInfo.getCharID() and SceneMgr.currentScene == "HomeScene" then
                    HomeInfo.RemoveLocalPlayer(res.charIDFrom)
                end
            elseif content.home_msg == HomeInfo.CHAT_CONTENT_HOME_CHANGED then
                local cfg = content.home
                if tonumber(res.charIDFrom) ~= CharInfo.getCharID() and SceneMgr.currentScene == "HomeScene" and cfg and HomeInfo.GetCurrentHomeCharID() == tonumber(res.charIDFrom) then
                    FurnitureViewMgr.EmptyFurnitureTable()
                    FurnitureViewMgr.InitPlaceableArea(3)
                    FurnitureViewMgr.InitBlueRedSprite()
                    FurnitureViewMgr.InitBlockInfo()
                    FurnitureViewMgr.InitExpandLevel()
                    if cfg.level ~= nil then
                        FurnitureViewMgr.SetExpandLevel(cfg.level)
                    else
                        FurnitureViewMgr.SetExpandLevel(1)
                    end
                    if cfg.homeName ~= nil then
                        FurnitureViewMgr.SetHomeName(cfg.homeName)
                    else
                        FurnitureViewMgr.SetHomeName(res.charIDFromName)
                    end
                    if cfg.furnitures ~= nil then
                        for k,v in pairs(cfg.furnitures) do
                            --print("###########GC_GetHome_Ack k="..tostring(k))
                            local objID = tonumber(k)
                            local itemID = v.itemID
                            --print("###########GC_GetHome_Ack objID="..tostring(objID).." itemID="..tostring(itemID))
                            local Index = v.otherParam["Index"]
                            --print("###########GC_GetHome_Ack index="..tostring(Index))
                            local FurnitureType = FurnitureViewMgr.GetFurnitureType(itemID)
                            if FurnitureType == Proto.FT_DOOR or FurnitureType == Proto.FT_DOORBOARD or FurnitureType == Proto.FT_LAMP or 
                                FurnitureType == Proto.FT_ROOT or FurnitureType == Proto.FT_FLOOR or FurnitureType == Proto.FT_WALLPAPER then
                                FurnitureViewMgr.ShowFixedFurnitureFromServer(FurnitureType, itemID, objID, Index)
                            else
                                FurnitureViewMgr.ShowFurnitureByIndex(itemID, objID, Index, FurnitureType)
                            end
                        end
                    end

                    FurnitureViewMgr.SortFurniture()
                end
            end
        elseif content.family_msg ~= nil then
            if content.family_msg == FamilyInfo.CMD.CHAT_CONTENT_INVITE_ENTER_FAMILY then
                if tonumber(res.charIDFrom) ~= CharInfo.getCharID() and SceneMgr.currentScene ~= "BossMapScene" then
                    DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 2, CocosModuleMgr.createStringWithFormat({"family11", res.charIDFromName,
                        content.name, content.id}), function()
                        FamilyInfo.JoinFamily(content.id)
                        FamilyInfo.SendInviteEnterFamilyAck(res.charIDFrom, 1)
                        end, function()
                            FamilyInfo.SendInviteEnterFamilyAck(res.charIDFrom, 0)
                        end, nil, false)
                end
            elseif content.family_msg == FamilyInfo.CMD.CHAT_CONTENT_INVITE_ENTER_FAMILY_ACK then
                if tonumber(res.charIDFrom) ~= CharInfo.getCharID() then
                    if content.result == 0 then
                        StandardTipsMgr.show(1, "family10")
                    else
                        StandardTipsMgr.show(0, "family16")
                    end
                end
            end
        else
            TownChatMgr.onMessageNtf(res.channel,res.charIDFromName,res.concent,res.charIDTo,res.charIDFrom)
        end
    elseif command=="ntf.mxmevo.addfriend" then
        FriendsViewMgr.showNewFriendRedPoint(res.newfriend,res.needConfirm)
    elseif command=="ntf.mxmevo.battleNtf" then
        
        local record = loadstring("return "..res.report)()
        
        if not BattlePVPMgr.mIsPVPBattle then
            print("battleNtf~~~~nidex...."..res.turnIndex.."..."..(res.report))
            BattleCotroller.setBattleRecords(record,res.turnIndex)
        else
            print("battleNtf~~~~nidex...before."..res.turnIndex.."..."..sz_T2S(record))
            if not BattlePVPMgr.mPVPIsChallenger then 
                for key,var in pairs(record) do
                    if var.ani then
                        record[key][1] = (record[key][1] + 1)%2
                        record[key][3] = (record[key][3] + 1)%2

                        if record[key][7] then
                            local mySix = record[key][7][2]
                            local hisSix = record[key][7][1]
                            record[key][7][1] = mySix
                            record[key][7][2] = hisSix
                        end
                    elseif var.energy then
                        record[key].energy[1] = record[key].energy[2] 
                    elseif var.changePet then
                        record[key][1] = (record[key][1] + 1)%2
                        if record[key][3] then
                            local mySix = record[key][3][2]
                            local hisSix = record[key][3][1]
                            record[key][3][1] = mySix
                            record[key][3][2] = hisSix
                        end
                        
                    elseif var.gameover then
                        if record[key][1] == PLAYER_WIN then
                            record[key][1] = PLAYER_LOSE
                        else
                            record[key][1] = PLAYER_WIN
                        end
                    elseif var.assistSkill then
                        if var[1][1] then
                            if var[1][1].side == TEAM_A then
                                var[1][1].side = TEAM_B
                            else
                                var[1][1].side = TEAM_A
                            end
                        end
                    elseif var.selectSkill then
                        local teamA_selectSkill  = record[key].teamB
                        -- local teamB_selectSkill = record[key][2].teamA
                        record[key].teamA = teamA_selectSkill
                    elseif var.checkBuffer then
                        local myBuffs   = clone(record[key][2])
                        local hisBuffs  = clone(record[key][1])
                        record[key][1]  = myBuffs
                        record[key][2]  = hisBuffs
                        if record[key][3] then
                            local mySix = record[key][3][2]
                            local hisSix = record[key][3][1]
                            record[key][3][1] = mySix
                            record[key][3][2] = hisSix
                        end

                    elseif var.triggeredPassiveSkill then
                        local myPassives    = clone(record[key][2])
                        local hisPassives   = clone(record[key][1])
                        record[key][1]      = myPassives
                        record[key][2]      = hisPassives
                        if record[key][3] then
                            local mySix         = clone(record[key][3][2])
                            local hisSix        = clone(record[key][3][1])
                            record[key][3][1]   = mySix
                            record[key][3][2]   = hisSix
                        end
                    elseif var.buffDamage then
                        local mybuff    = clone(record[key][2])
                        local hisbuff   = clone(record[key][1])
                        record[key][1]      = mybuff
                        record[key][2]      = hisbuff
                        if record[key][3] then
                            local mySix         = clone(record[key][3][2])
                            local hisSix        = clone(record[key][3][1])
                            record[key][3][1]   = mySix
                            record[key][3][2]   = hisSix
                        end
                    elseif var.showSelectSkill then
                        local team = record[key][1]
                        if team == TEAM_A then
                            record[key][1] = TEAM_B
                        else
                            record[key][1] = TEAM_A
                        end
                    end
                end
            end
            print("mPVPIsChallenger....",BattlePVPMgr.mPVPIsChallenger)
            print("battleNtf~~~~nidex..aft.record."..res.turnIndex.."..."..sz_T2S(record))
            if true == BattlePVPMgr.mIsPVPBattle then
                if res.turnIndex ~= 1 then
                    PVPDailog.waitOpponentHide()
                end
            end 
            BattlePVPMgr.data[res.turnIndex] = record
            print("sendIsCommand.......",BattlePVPMgr.sendIsCommand)
            if BattlePVPMgr.sendIsCommand then
                BattleCotroller.runPVPBattleData(res.turnIndex)
            end
        end
        
--        BattleCotroller.setBattleRecords(record,res.turnIndex)
--        BattleCotroller.setcurrentRecord(record)
            
--        if res.turnIndex == 1 then
--            BattleCotroller.judgeNextBattle()
--        end
    elseif command=="mxmevo.mail.newMailnotify" then
        MailMgr.newMailNotify()
    elseif command=="ntf.mxmevo.pvpinfoNtf" then 
        print("pvpinfoNtf~~~~~~~~~~")
        BattlePVPMgr.setPVPInfomation(res)
    elseif command=="mxmevo.arenabattle.end" then
        --res.isWin
        --res.arenaBattleID
        if res.isWin then
            ArenaViewMgr.refreshArenaEnemys()
        end
    elseif command=="mxmevo.family.value.ntf" then
        --print("=========mxmevo.family.value.ntf res=",sz_T2S(res)) 
        if CharInfo.getFamilyID() ~= nil then
            if res.devotePoint ~= nil then
                local info = FamilyInfo.GetLocalFamilyMembersInfo()
                if info ~= nil and info[tostring(CharInfo.getCharID())] ~= nil then
                    if res.devotePoint > (info[tostring(CharInfo.getCharID())].devotePoint or 0) then
                        TaskWatcherManager.saveJZGongXianDianChangeState({devotePoint = res.devotePoint})
                    end
                    info[tostring(CharInfo.getCharID())].devotePoint = res.devotePoint
                end
            end
            
            if res.familyCoin ~= nil then
                local info = FamilyInfo.GetLocalFamilyInfo()
                if info ~= nil then
                    info.familyCoin = res.familyCoin
                end
            end
        end
    elseif command=="mxmevo.wishingTree.newTree" then
        TreeInfoView.plantTree(res,true)
    elseif command=="mxmevo.wishingTree.removeTree" then
        TownTreeMgr.removeTree(tonumber(param))
        TreeInfoView.removeTreeData(tonumber(param))
    elseif command=="mxmevo.wishingTree.prayBroadcast" then
        TreeInfoView.addTreeExp(tonumber(param))
    elseif command=="mxmevo.broadcastmsg" then
        HorseLayerMgr.addMsg(res.content)
    elseif command=="mxmevo.broadcastmsg2" then
        HorseLayerMgr.addMsg2(res.content)
    elseif command=="mxmevo.team.join.ntf" then
        TeamInfo.receiveTeamJoinNtf(res)
    elseif command=="mxmevo.team.invite" then
        TeamInfo.receiveTeamInvite(res)
    elseif command=="mxmevo.teammember.update" then
        TeamInfo.receiveTeammemberUpdate(res)
    elseif command=="mxmevo.team.kick" then
        TeamInfo.receiveTeamKick(res)
    elseif command=="mxmevo.team.sort" then
        TeamInfo.receiveTeamSort(res)
    elseif command=="mxmevo.team.canautojoin.change" then
        TeamInfo.receiveTeamCanautojoinChange(res)
    elseif command=="mxmevo.team.change.leader.ntf" then
        TeamInfo.receiveTeamChangeLeader(res)
    elseif command=="mxmevo.team.refuse" then
        TeamInfo.receiveTeamRefuseJoin(res)
    elseif command=="mxmevo.team.dungeon.start.ntf" then
        local boxes = TeamCopyWinMgr.getBoxes()
        if boxes then
            local TreasureBoxSend = require("src.Net.Send.TreasureBoxSend")
            NetInterface.send("GC_SelectTreasureBox_Ack", function()
                TreasureBoxSend.sendCG_SelectTreasureBox_Req({boxID=0})
            end)
            TeamCopyWinMgr.clearBoxes()
        end
        TeamCopyMapMgr.cleanLocalCopyMapInfo()
        SceneMgr.replaceScene(SceneMgr.getRunningScene, "TeamCopyMapScene")
    elseif command=="mxmevo.team.pet.hp.change.ntf" then
        print("mxmevo.team.pet.hp.change.ntf res="..sz_T2S(res))
        TeamCopyTopBarMgr.updatePetsHpPercent(res)
        if res.pets then
            local objID = {}
            local hp = {}
            for i=1,#res.pets do
                objID[i] = res.pets[i].objID
                hp[i] = res.pets[i].hp
            end
            TeamCopyMapMgr.updateLocalMembersPetsHp(res.charID, {objID = objID, hp = hp})
        end
    elseif command=="mxmevo.character.state.change.ntf" then
        print("mxmevo.character.state.change.ntf res=",sz_T2S(res))
        TeamCopyMapMgr.changePlayerCurrentState(res.charID, res.state)
    elseif command=="mxmevo.character.army.change.ntf" then
        print("mxmevo.character.army.change.ntf res=",sz_T2S(res))
        if res.charID ~= CharInfo.getCharID() then
            TeamCopyTopBarMgr.changePlayerArmyPet(res)
        end
    elseif command=="mxm.team.monster.hp.change.ntf" then
        print("mxm.team.monster.hp.change.ntf res=",sz_T2S(res))
        --TeamCopyMapMgr.updateMonsterHp(res.x, res.y, res.monsterHP)
        local bInfo = {{monsterID = res.monsterID, hp = res.monsterHP}}
        TeamCopyMapMgr.addLocalBattleInfo(bInfo)
    elseif command=="mxm.team.dungeon.kill.monsters.ntf" then
        print("mxm.team.dungeon.kill.monsters.ntf res=",sz_T2S(res))
        TeamCopyMapMgr.incKillMonsterNum()
    elseif command=="mxm.monster.state.ntf" then
        print("mxm.monster.state.ntf res=",sz_T2S(res))
        TeamCopyMapMgr.setLockPVEGridByID(res.monsterID, res.charID, res.state)
    elseif command=="mxmevo.bossHP.ntf" then
        print("mxmevo.bossHP~~~~~~~",sz_T2S(res))
        local bossHP  = tonumber(res.bossHP)
        BattleCotroller.lastbossHP = bossHP
        if res.joinedCharID == CharInfo.getCharID() then
            if not BattlePVPMgr.mIsPVPBattle then
                BattlePVPMgr.mIsPVPBattle       = true
                BattlePVPMgr.mPVPIsChallenger   = true
                BattlePVPMgr.setserverID(res.serverID)
                BattlePVPMgr.setBattleID(res.battleID)
                local myPets = {}
                myPets[OUTPETS]         = res.selfPets
                myPets[INPETS]          = res.selfHelperPets
                local hisPets = {}
                hisPets[OUTPETS]        = res.bossPokemon 
                hisPets[OUTPETS][1].hp  = bossHP
                BattleCotroller.bossHP  = bossHP
                hisPets[INPETS]         = res.bossHelperPokemon
                BattleMapMgr.setEnemyPets(hisPets)
                BattleMapMgr.setMyPets(myPets)
                SceneMgr.replaceScene(SceneMgr.getRunningScene,"BattleScene")
                print("joinedCharID~~~~~~bossHP~~~~~",bossHP) 
            end
        else   
            if res.charID ~= CharInfo.getCharID() then  
                if BattleCCSB.MENU then
                    if BattleCCSB.MENU.isOut == false and BattleCotroller.bossHP then  
                        BattleCotroller.bossHP          = BattleCotroller.bossHP -  res.damage
                        if res.damage > 0 then
                            if BattleCotroller.bossHP < 0 then
                                BattleCotroller.bossHP = 0
                            end
                            BattleUIMgr.checkBloodbarAndBloodNum(1, BattleCotroller.bossHP) 
                            BattleUIMgr.addFightLabel({petType = 1, 
                                value = res.damage, 
                                type = "normal", iscritical = false}) 
                            BattleUIMgr.showTeammateDamage(res.otherParams.fashion.curFashion, res.otherParams.name, res.damage)
                        elseif res.damage < 0 then 
                            res.damage = -1 * res.damage  
                            BattleUIMgr.checkBloodbarAndBloodNum(1, bossHP) 
                            BattleUIMgr.addFightLabel({petType = 1, 
                                value = res.damage, 
                                type = "addhp", iscritical = false})
                        end
                    end
                end
            else
                print("BattleCotroller.TeamA_Damage ......",res.damage) 
                BattleCotroller.TeamA_Damage = res.damage
            end

            if res.bossHP == "0" then 
                if BattlePVPMgr.mIsPVPBattle then 
                    if res.charID ~= CharInfo.getCharID() then 
                        if SceneMgr.currentScene == "BattleScene" then
                            BattleCotroller.isPause = true  
                            BattleCCSB.MENU.isOut = true 
                            DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene,1,"team52",function()  
                                    BattlePVPMgr.sendLeaveBattleCommand()             
                                    BattleUIMgr.quiteBattle()
                                end,nil,nil,false) 
                        else
                            MapSeekerMgr.SeekFunc = function()
                                DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene,1,"team52",function()  
                                    BattlePVPMgr.sendLeaveBattleCommand()             
                                    BattleUIMgr.quiteBattle()
                                end,nil,nil,false)
                            end
                        end
                    end
                end
            end
        end
    elseif command=="NewWishingTreeSeed" then
        AwardsListMgr.show(SceneMgr.getRunningScene, {{res,1}})
    elseif command=="ntf.recharge" then
	    PurchaseViewMgr.refreshUI(res)
    elseif command=="mxmevo.leavePVP" then
        if BattlePVPMgr.mIsPVPBattle then
            DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene,2,"wifiPK2",function() 
                if BattlePVPMgr.isPVPArenaBattle == PVP_YES_ARENA then
                    BattlePVPMgr.ArenaWinShow()

                else
                    BattlePVPMgr.endCalcTime()
                    BattleUIMgr.quiteBattle()
                end
            end,nil,nil,false) 
        end
    elseif command=="mxmevo.pvperror" then
        if res.isTimeOut == true then
            DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene,1,"wifiPK3",function() 
                    if BattlePVPMgr.isPVPArenaBattle == PVP_YES_ARENA then 
                        BattlePVPMgr.ArenaWinShow()

                    else
                        BattlePVPMgr.endCalcTime()
                        BattleUIMgr.quiteBattle()
                    end
                end,nil,nil,false)
        else
            DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene,1,"wifiPK4",function() 
                    
                end,nil,nil,false)
        end
    elseif command=="mxmevo.pvpselectskill.ntf" then
        if res.skillIndex > 0 and res.skillIndex <= 4 then
            BattleUIMgr.showSelectSkill(1, res.skillIndex, true)
        end
    elseif command== "mxmevo.pvpArenaGradePoint.ntf" then
        print("mxmevo.pvpArenaGradePoint.ntf~~~~~~~~~~",res.everyArenaPoint,res.everyArenaGrade)
        BattlePVPMgr.seteveryArenaPoints(res.everyArenaPoint)
        BattlePVPMgr.seteveryArenaGrade(res.everyArenaGrade)
        -- BattlePVPMgr.isPVPArenaOver   = true
    elseif command== "gm.kickAllPlayer.ntf" then 
        LoginViewMgr.isKickByServer = 1
      
        local function backToLoginView()
            LoginViewMgr.gameReInit()
        end

        ExitGameViewMgr.show(SceneMgr.getRunningSecne,backToLoginView,"login40",8)
        
    end
	print("docommand~~~~~~~~~~")
end

-- data.id=Proto.parseDWORD(entry); -- ID
-- data.viplevel=Proto.parseDWORD(entry); -- vip等级
-- data.explain=Proto.parseString(entry); -- 特权说明
-- data.awardsID=Proto.parseDWORD(entry); -- 等级奖励
-- data.recharge=Proto.parseDWORD(entry); -- 充值费用
-- data.goldTimes=Proto.parseDWORD(entry); -- 点金次数
-- data.buyPower=Proto.parseDWORD(entry); -- 购买体力
-- data.reActivity=Proto.parseDWORD(entry); -- 重置活动本次数
-- data.reCost=Proto.parseDWORD(entry); -- 重置费用
-- data.reCommon=Proto.parseDWORD(entry); -- 重置一般本次数
-- data.exploreAwardTimeReduceRate=Proto.parseDWORD(entry); -- 缩短挂机结算时间(百分比)
-- data.ltSetpNumber=Proto.parseDWORD(entry); -- 迷失之塔移动步数
-- data.ltShopRefresh=Proto.parseDWORD(entry); -- 迷失之塔商店刷新次数
-- data.arenaShopRefresh=Proto.parseDWORD(entry); -- 竞技场商店刷新次数
-- data.repairTimes=Proto.parseBYTE(entry); -- 签到补签次数
function CharInfo.getVipInfoByID(id)
    return VipInfoConfig.readEntryByID(id)
end

function CharInfo.getVipInfoAllId()
    local vec = {}
    for var=1, VipInfoConfig.getEntryCount() do
        local id = VipInfoConfig.getEntryID(var)
        table.insert(vec, CharInfo.getVipInfoByID(id))
    end
    return vec
end

-- data.id=Proto.parseDWORD(entry); -- 次数
-- data.gold=Proto.parseDWORD(entry); -- 产出金币
-- data.jewel=Proto.parseDWORD(entry); -- 花费钻石
function CharInfo.getGoldPointInfoByID(id)
    return GoldPointInfoConfig.readEntryByID(id)
end

function CharInfo.getGoldPointInfoAllId()
    local vec = {}
    for var=1, GoldPointInfoConfig.getEntryCount() do
        local id = GoldPointInfoConfig.getEntryID(var)
        table.insert(vec, CharInfo.getGoldPointInfoByID(id))
    end
    return vec
end

-- data.id=Proto.parseDWORD(entry); -- 次数
-- data.cost=Proto.parseDWORD(entry); -- 花费钻石
-- data.power=Proto.parseDWORD(entry); -- 体力恢复
function CharInfo.getBuyPowerInfoByID(id)
    return BuyPowerInfoConfig.readEntryByID(id)
end

function CharInfo.getBuyPowerInfoAllId()
    local vec = {}
    for var=1, BuyPowerInfoConfig.getEntryCount() do
        local id = BuyPowerInfoConfig.getEntryID(var)
        table.insert(vec, CharInfo.getBuyPowerInfoByID(id))
    end
    return vec
end

--[[
data.id=Proto.parseDWORD(entry); -- 日期的天
data.vipRate=Proto.parseSigninVipRate(entry); -- VIP翻倍
data.awards=Proto.parseVector(entry,Proto.parseSigninDayAward); -- 奖励组，一月到十二月
]]
function CharInfo.getSigninInfoById(id)
    return SigninInfoConfig.readEntryByID(id)
end

function CharInfo.getSigninInfoAllId()
    local vec = {}
    for var=1, SigninInfoConfig.getEntryCount() do
        local id = SigninInfoConfig.getEntryID(var)
        table.insert(vec, CharInfo.getSigninInfoById(id))
    end
    return vec
end

--[[
data.id=Proto.parseBYTE(entry); -- 次数
data.cost=Proto.parseDWORD(entry); -- 费用
]]
function CharInfo.getSigninRepairCostInfoById(id)
    return SigninRepairCostInfoConfig.readEntryByID(id)
end

function CharInfo.setLifeSkillInfo(lifeskillinfo)
    mlifeSkillInfo = lifeskillinfo
    local cjson = require("cjson")
    local jsonInfo = cjson.decode(mlifeSkillInfo)
    if jsonInfo == nil then
        info.lifeskilllevel = 0
        print("jsonInfo is null")
        
    else
        
        jsonInfo.level = jsonInfo.level or 0
        info.lifeskilllevel = jsonInfo.level
        print("jsonInfo is not null "..jsonInfo.level)
    end
end

function CharInfo.getLifeSkillInfo()
    return mlifeSkillInfo
end

function CharInfo.getLifeSkillCareer()
    return info.lifeskillcareer
end

function CharInfo.getFamilyQuestID()
    return info.familyquestid
end

function CharInfo.getLastFamilySignTime()
    return info.lastfamilysigntime or 0
end

function CharInfo.getFamilyQuestFailedTime()
    return info.familyquestfailedtime or 0
end

function CharInfo.getFamilyQuestOK()
    return info.familyquestok
end

function CharInfo.getTodayFamilyQuestNum()
    return info.todayfamilyquestnum
end

function CharInfo.getTodayFamilyQuestTime()
    return info.todayfamilyquesttime
end

function CharInfo.getFamilyDevoteBufferTime()
    return info.getfamilydevotebuffertime
end

function CharInfo.getFamilyDevoteBuffer()
    return info.familydevotebuffer or 0
end

function CharInfo.getFamilyDungeonStepNumber()
    return info.familydungeonstepnumber
end

function CharInfo.setFamilyDungeonStepNumber(number)
    info.familydungeonstepnumber = number
end

function CharInfo.getFamilyDungeonStepNumberUpdateTime()
    return info.familydungeonstepnumberupdatetime
end

function CharInfo.setFamilyDungeonStepNumberUpdateTime(time)
    info.familydungeonstepnumberupdatetime = time
end

function CharInfo.getVipShopGoodsInfo()
    return info.vipShopGoodsInfo
end

function CharInfo.getAutoArenaBattle()
    return info.ismarenaon or false
end

function CharInfo.getSurvivalBattleFloor()
    return info.survivalbattlefloor or 0
end

function CharInfo.GetSurvivalBattleTime()
    return info.survivalbattletime
end

function CharInfo.getSurvivalTime()
    return info.getsurvivaltime
end

--获得银币
function CharInfo.getSilverCash()
    return info.goldcoin
end

-- data.id=Proto.parseDWORD(entry); -- ID
-- data.mailID=Proto.parseDWORD(entry); -- 邮件ID
-- data.awardList=Proto.parseVector(entry,Proto.parseAwardItem); -- 奖励列表
-- awardList是table，元素的格式如下
-- data.itemID=Proto.parseDWORD(entry); -- 道具ID
-- data.itemCount=Proto.parseDWORD(entry); -- 道具数量
function CharInfo.getFashionShowAwardInfoById(id)
    return FashionShowAwardInfoConfig.readEntryByID(id)
end

function CharInfo.getFashionShowAwardInfoAllId()
    local vec = {}
    for var=1, FashionShowAwardInfoConfig.getEntryCount() do
        local id = FashionShowAwardInfoConfig.getEntryID(var)
        table.insert(vec, CharInfo.getFashionShowAwardInfoById(id))
    end
    return vec
end

-- data.id=Proto.parseDWORD(entry); -- ID
-- data.sencePath=Proto.parseString(entry); -- 场景
-- data.petType=Proto.parseDWORD(entry); -- 限定宠物系别
-- data.fashionID=Proto.parseDWORD(entry); -- 限定时装
function CharInfo.getFashionShowRuleInfoById(id)
    return FashionShowRuleInfoConfig.readEntryByID(id)
end

function CharInfo.getFamilyID()
    --print("$$$$$$$$$$$$$$$$info="..sz_T2S(info))
    if info.hasconfraternity ~= 0 then
        return info.confraternityid
    end
    return nil
end

function CharInfo.getWorldBossTime()
    return info.worldbosstime
end
--今日跨服战次数
function CharInfo.getTodayWArenaFightTimes()
    return info.todaywarenafighttimes
end

--今日跨服战刷新次数
function CharInfo.getTodayWArenaFightRefreshTimes()
    return info.todaywarenafightrefreshtimes
end

--更新时间戳
function CharInfo.getWArenaUpdateTime()
    return info.warenaupdatetime
end

function CharInfo.setServerOpenTime(val)
	serverOpenTime = val
end

function CharInfo.getServerOpenTime()
	return serverOpenTime
end

function CharInfo.getFixPvpArenaPoint()
    return info.fixpvparenapoint
end

function CharInfo.getPvpArenaCoin()
    return info.pvparenacoin
end

return CharInfo
