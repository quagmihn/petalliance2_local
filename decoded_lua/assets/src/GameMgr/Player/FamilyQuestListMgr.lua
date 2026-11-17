local FamilyQuestListMgr = {}

local resName = ""
local resNameDownBar = ""
local resNameBG = ""
local difficultyString = {}
local awardElementsString = {}
local totalQuestLimit = 0
local skillUpInfo = nil

function FamilyQuestListMgr.Init()
    resName = "Player/Family/FamilyQuestList.csb"
    resNameDownBar = "Player/Family/FamilyQuestDownBar.csb"
    resNameBG = "Pet/Formation/FormationBGNew.csb"
    difficultyString = {
        [1] = "Pet/Education/c.png",
        [2] = "Pet/Education/b.png",
        [3] = "Pet/Education/a.png",
        [4] = "Pet/Education/s.png",
    }
    awardElementsString = {
        [1] = 9998,
        [2] = 9999,
        [46] = 9996,
        [90] = 9997,
    }
    totalQuestLimit = SystemInfo.getGlobalConfigAddInfoByID(63).values[1]
    skillUpInfo = nil
end

local function initStaticData()
    CSResourceMgr.setButtonString(resName, "btn_log", "family72", nil, {r=0,g=0,b=0,a=255,w=1})
    local tip = CSResourceMgr.getNodeByName(resName, "input_tip")
    --阿杜修改英文版显示
	if LuaSqlite.LANG_TYPE ~= 5 then
		CSResourceMgr.setLabelMaxWidthByNode(tip, 370)
	end
--    tip:setString(LuaSqlite.getLanguageByKey("family75"))
	CSResourceMgr.setLabelStringByNode(tip,"family75")

    CSResourceMgr.setLabelString(resName, "txt_title", "family73", nil, {r=26,g=37,b=48,a=255,w=1})
    CSResourceMgr.setLabelString(resName, "txt_remian", "Territorialtext10", nil, {r=12,g=27,b=38,a=255,w=1},nil,120)
    
    CSResourceMgr.setLabelString(resName, "txt_failed1", "family76", nil, {r=1,g=11,b=25,a=255,w=1})
    CSResourceMgr.setLabelString(resName, "txt_failed2", "family78", nil, {r=1,g=11,b=25,a=255,w=1})
    
    local num
    skillUpInfo,num = AchievementListMgr.getSkillUpInfo("famliy")
    if skillUpInfo ~= nil then
        local potential = CSResourceMgr.getNodeByName(resName, "potential_bg")
        potential:setVisible(true)
        local icon = CSResourceMgr.seekNodeByName(potential, "icon")
        CSResourceMgr.setSpriteTextureByNode(icon, "Battle/skillIcon/"..skillUpInfo.icon)
        icon:setScale(0.6)
        local level = CSResourceMgr.seekNodeByName(potential, "level")
        CSResourceMgr.setLabelStringByNode(level, "Lv"..num, {r=0,g=0,b=0,a=255,w=1})
    end
    
    --CSResourceMgr.setButtonString(resNameDownBar, "reset", "skillReset1", nil, {r=0,g=0,b=0,a=255,w=1})
    CSResourceMgr.setLabelString(resNameDownBar, "tip", "family135", nil, {r=0,g=0,b=0,a=255,w=1})
    
    local diff = CocosModuleMgr.getScreenSizeDiff()
    if diff < 0 then
        local list = CSResourceMgr.getNodeByName(resName,"list")
        local lsize = list:getContentSize()
        list:setContentSize(lsize.width, lsize.height+diff*2.66)
    end
end

local function isResetEnable(info)
    local maxTimes = SystemInfo.getGlobalConfigAddInfoByID(2001).values[1]
    --print("=========maxTimes=",maxTimes)
    local usedTimes = info.resetFamilyQuestNum or 0
    local t1 = info.lastResetFamilyQuestTime or 0
    local offsetTime = 24*3600
    local t2 = CharInfo.getServerTime()
    local dayDiff = CocosModuleMgr.getDayTimeDiff(t1,t2,offsetTime)
    if dayDiff ~= 0 then -- 非同一天
        usedTimes = 0
    end
    info.resetFamilyQuestNum = usedTimes
    
    return usedTimes<maxTimes, usedTimes, maxTimes
end

local function initDynamicData()
    local devote = CSResourceMgr.getNodeByName(resName, "txt_devote")
    local membersInfo =  FamilyInfo.GetLocalFamilyMembersInfo()
    local info = FamilyInfo.GetLocalFamilyInfo()
    if CharInfo.getFamilyID() ~= nil and membersInfo ~= nil and info ~= nil then
        local devotePoint = membersInfo[tostring(CharInfo.getCharID())].devotePoint or 0
        --[[
        if membersInfo[tostring(CharInfo.getCharID())].devotePoint ~= nil then
            local lastSetDevotePointTime = tonumber(membersInfo[tostring(CharInfo.getCharID())].lastSetDevotePointTime or 0)
            local lastDevoteRefreshTime = tonumber(info.lastDevoteRefreshTime or 0)
            if lastSetDevotePointTime > lastDevoteRefreshTime then
                devotePoint = membersInfo[tostring(CharInfo.getCharID())].devotePoint
            end
        end
        ]]
        CSResourceMgr.setLabelStringByNode(devote, devotePoint, {r=0,g=0,b=0,a=255,w=1})
    else
        CSResourceMgr.setLabelStringByNode(devote, 0, {r=0,g=0,b=0,a=255,w=1})
    end
    local gold = CSResourceMgr.getNodeByName(resName, "txt_gold")
    CSResourceMgr.setLabelStringByNode(gold, CharInfo.getGCash())
    local diamond = CSResourceMgr.getNodeByName(resName, "txt_diamond")
    CSResourceMgr.setLabelStringByNode(diamond, CharInfo.getMCash())
    
    local todayFamilyQuestTime = tonumber(CharInfo.getTodayFamilyQuestTime() or 0)
    local bVaild = (CocosModuleMgr.getDayTimeDiff(todayFamilyQuestTime, CharInfo.getServerTime(), 6 * 3600) == 0 and true or false)
    CSResourceMgr.setLabelString(resName, "txt_remain_num", CocosModuleMgr.createStringWithFormat({"home014", totalQuestLimit - (bVaild == true and (CharInfo.getTodayFamilyQuestNum() or 0) or 0), totalQuestLimit}))
    
    if info ~= nil then
        local familyLevel = (info.familyLevel or 1)
        CSResourceMgr.setSpriteTexture(resNameDownBar, "icon", string.sub(info.icon, 1, -5).."_hz.png")
        CSResourceMgr.setLabelString(resNameDownBar, "num1", info.familyCoin or 0, nil, {r=0,g=0,b=0,a=255,w=1})
        local resetCoin = FamilyDataInfo.getFamilyLevelInfoById(familyLevel).resetFamilyQuestCost or 0
        CSResourceMgr.setLabelString(resNameDownBar, "num2", resetCoin, nil, {r=0,g=0,b=0,a=255,w=1})
        if (info.familyCoin or 0) < resetCoin then
            CSResourceMgr.setLabelColor(resNameDownBar, "num1", {r=255,g=0,b=0,a=255})
        end
        
        local jobSelf = FamilyInfo.GetJobByMemberID(CharInfo.getCharID())
        local reset = CSResourceMgr.getNodeByName(resNameDownBar, "reset")
        local enable, usedTimes, maxTimes = isResetEnable(info)
        local times = string.format("(%d/%d)", maxTimes - usedTimes, maxTimes)
        CSResourceMgr.setButtonStringByNode(reset, LuaSqlite.getLanguageByKey("skillReset1")..times, nil, {r=0,g=0,b=0,a=255,w=1})
        if jobSelf ~= FamilyInfo.JobType.Job_Leader and jobSelf ~= FamilyInfo.JobType.Job_Elder then
            CSResourceMgr.setButtonEnabledByNode(reset, false)
        else
            --[[
            local refreshTime = info.lastResetFamilyQuestTime or 0
            local timePoints = SystemInfo.getGlobalConfigAddInfoByID(6900).values
            local offsetTime = timePoints[1]
            local dayDiff = CocosModuleMgr.getDayTimeDiff(refreshTime, CharInfo.getServerTime(), offsetTime)
            if dayDiff == 0 then
                CSResourceMgr.setButtonEnabled(resNameDownBar, "reset", false)
            end
            ]]
            CSResourceMgr.setButtonEnabledByNode(reset, enable)
            
            if enable then
                if (info.familyCoin or 0) < resetCoin then
                    CSResourceMgr.setButtonEnabledByNode(reset, false)
                end
            end
        end
    end
end

function FamilyQuestListMgr.hideUI()
    UnblockLoader.cancel("FamilyQuestListMgr")
    CSResourceMgr.removeCSObjectByTag(resName)
    CSResourceMgr.removeCSObjectByTag(resNameDownBar)
    CSResourceMgr.removeCSObjectByTag(resNameBG, "FamilyQuestListMgr")
    UIStack.pop("FamilyQuestListMgr")
end

local function reset()
    local reset = CSResourceMgr.getNodeByName(resNameDownBar, "reset")
    CSResourceMgr.setButtonEnabledByNode(reset, false)
    FamilyInfo.ResetFamilyQuest(function()
        local info = FamilyInfo.GetLocalFamilyInfo()
        if info ~= nil then
            local enable, usedTimes, maxTimes = isResetEnable(info)
            local times = string.format("(%d/%d)", maxTimes - usedTimes, maxTimes)
            CSResourceMgr.setButtonStringByNode(reset, LuaSqlite.getLanguageByKey("skillReset1")..times, nil, {r=0,g=0,b=0,a=255,w=1})
            CSResourceMgr.setButtonEnabledByNode(reset, enable)
            CSResourceMgr.setLabelString(resNameDownBar, "num1", info.familyCoin or 0, nil, {r=0,g=0,b=0,a=255,w=1})
            
            if enable then
                local familyLevel = (info.familyLevel or 1)
                local resetCoin = FamilyDataInfo.getFamilyLevelInfoById(familyLevel).resetFamilyQuestCost or 0
                if (info.familyCoin or 0) < resetCoin then
                    CSResourceMgr.setLabelColor(resNameDownBar, "num1", {r=255,g=0,b=0,a=255})
                    CSResourceMgr.setButtonEnabledByNode(reset, false)
                end
            end
        end
    end)
end

function FamilyQuestListMgr.show(scene)
    if CSResourceMgr.getCsbObj(resName) then
        return  
    end
    UIStack.push("FamilyQuestListMgr",FamilyQuestListMgr.hideUI,true)
    local function loadBG()
        local bgLayer = CSResourceMgr.createRes(scene, resNameBG, "FamilyQuestListMgr")
        bgLayer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resNameBG, 320, 480, "FamilyQuestListMgr")
        bgLayer:setOpacity(0)
        transition.fadeIn(bgLayer, {time=0.3})
    end
    
    local function loadCSB()
        local curLayer = CSResourceMgr.createRes(scene, resName)
        curLayer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CocosModuleMgr.setEdgeDistance(curLayer, 0, nil, 0, nil, false)
        CSResourceMgr.getNodeByName(resName, "db"):setVisible(false)
        
        curLayer = CSResourceMgr.createRes(scene, resNameDownBar)
        curLayer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CocosModuleMgr.setEdgeDistance(curLayer, 0, nil, nil, 0, false)
        curLayer:setVisible(false)
        
        CSResourceMgr.clickEventBinding(resName, "close", function()
            FamilyQuestListMgr.hideUI()
        end)
        
        CSResourceMgr.clickEventBinding(resNameDownBar, "reset", function()
            reset()
        end)
        
        initStaticData()

        initDynamicData()
        
        CSResourceMgr.clickEventBinding(resName, "btn_gold", function()
            ExchangeViewMgr.show(scene,ExchangeViewMgr.GCASHTYPE)
        end)
        
        CSResourceMgr.clickEventBinding(resName, "btn_diamond", function()
            PurchaseViewMgr.show(scene)
        end)
        
        CSResourceMgr.clickEventBinding(resName, "icdb", function()
            if skillUpInfo then
                AchievementListMgr.showSkillInfo(skillUpInfo, false, false)
            end
        end)
        
        CSResourceMgr.clickEventBinding(resName, "btn_log", function()
            FamilyLogViewMgr.show(scene)
        end)
    end
    
    local function playCSB()
        local node = CSResourceMgr.getNodeByName(resName, "db")
        if node ~= nil then
            node:setVisible(true)
            CocosModuleMgr.showUIAnimation(node, "down")
        end
        
        CSResourceMgr.getCsbObj(resNameDownBar):setVisible(true)
        CocosModuleMgr.showUIAnimation(CSResourceMgr.getCsbObj(resNameDownBar), "up")
    end
    
    loadBG()
    loadCSB()
    playCSB()
    
    local familyQuestID = CharInfo.getFamilyQuestID() or 0          --0:可以领取新任务(已经领取奖励)
    local familyQuestOK = CharInfo.getFamilyQuestOK() or 0          --1:成功 0:失败
    local familyQuestFailedTime = tonumber(CharInfo.getFamilyQuestFailedTime() or 0)
    print("============familyQuestID=",familyQuestID,"getServerTime=",CharInfo.getServerTime(),"familyQuestFailedTime=",familyQuestFailedTime,"familyQuestOK=",familyQuestOK)
    if familyQuestID == 0 or familyQuestOK == 1 or CharInfo.getServerTime() < familyQuestFailedTime or CharInfo.getServerTime() >= familyQuestFailedTime + 3600 then
        FamilyInfo.GetFamilyQuest()
    else
        CSResourceMgr.getNodeByName(resName,"pic_cover"):setVisible(true)
        CSResourceMgr.setLabelString(resName, "txt_failed1", "family76", nil, {r=1,g=11,b=25,a=255,w=1})
        CSResourceMgr.setLabelString(resName, "txt_failed2", "family78", nil, {r=1,g=11,b=25,a=255,w=1})
        local cd = CSResourceMgr.getNodeByName(resName,"txt_remain_time")
        CocosModuleMgr.setTimeLabelCountDown(cd, familyQuestFailedTime + 3600 - CharInfo.getServerTime(), function()
            if CSResourceMgr.getCsbObj(resName) then
                CSResourceMgr.getNodeByName(resName,"pic_cover"):setVisible(false)
                FamilyInfo.GetFamilyQuest()
            end
        end)
    end
end

function FamilyQuestListMgr.createList(questID, questAwards)
    local info = FamilyInfo.GetLocalFamilyInfo()
    if CSResourceMgr.getCsbObj(resName) and questID and questAwards and info ~= nil then
        --print("FamilyQuestListMgr.createList questID=",sz_T2S(questID))
        local familyQuestID = CharInfo.getFamilyQuestID() or 0
        local familyQuestOK = CharInfo.getFamilyQuestOK() or 0
        local familyQuestFailedTime = tonumber(CharInfo.getFamilyQuestFailedTime() or 0)
        local list = CSResourceMgr.getNodeByName(resName,"list")
        list:removeAllItems()
        
        local todayFamilyQuestTime = tonumber(CharInfo.getTodayFamilyQuestTime() or 0)
        local bVaild = (CocosModuleMgr.getDayTimeDiff(todayFamilyQuestTime, CharInfo.getServerTime(), 6 * 3600) == 0 and true or false)
        
        local funcTable = {}
        UnblockLoader.cancel("FamilyQuestListMgr")
        for i=1, #questID do
            table.insert(funcTable,function()
                local quest = CSResourceMgr.getNodeByName(resName,"btn_quest"):clone()
                for var=1, 4 do
                    local quest_bg = CSResourceMgr.seekNodeByName(quest, "quest_bg"..(2*(var-1)+1))
                    quest_bg:setColor({r=81,g=112,b=137})
                end
                local questInfo = QuestInfo.getFamilyQuestInfoById(questID[i])
                local quest_name = CSResourceMgr.seekNodeByName(quest, "quest_name")
                CSResourceMgr.setLabelStringByNode(quest_name, questInfo.name, {r=17,g=27,b=38,a=255,w=1})
                local quest_desc = CSResourceMgr.seekNodeByName(quest, "quest_desc")
                CSResourceMgr.setLabelStringByNode(quest_desc, questInfo.desc)
                local quest_btn_recv = CSResourceMgr.seekNodeByName(quest, "quest_btn_recv")
                CSResourceMgr.setButtonStringByNode(quest_btn_recv, "family74", {r=36,g=98,b=5,a=255,w=2})
                local quest_bg = CSResourceMgr.seekNodeByName(quest, "quest_bg6")
                CSResourceMgr.setSpriteTextureByNode(quest_bg, string.sub(info.icon, 1, -5).."_hz.png")
                quest_bg = CSResourceMgr.seekNodeByName(quest, "quest_bg8")
                CSResourceMgr.setSpriteTextureByNode(quest_bg, ItemInfo.getItemInfoById(awardElementsString[questInfo.awardElements[questAwards[i] + 1]]).icon)
                local quest_difficulty = CSResourceMgr.seekNodeByName(quest, "quest_difficulty")
                CSResourceMgr.setSpriteTextureByNode(quest_difficulty, difficultyString[questInfo.classType])
                local quest_devote = CSResourceMgr.seekNodeByName(quest, "quest_devote")
                CSResourceMgr.setLabelStringByNode(quest_devote, questInfo.devotePoint + (skillUpInfo ~= nil and skillUpInfo.params[1] or 0), {r=0,g=0,b=0,a=255,w=1})
                local quest_coin = CSResourceMgr.seekNodeByName(quest, "quest_coin")
                CSResourceMgr.setLabelStringByNode(quest_coin, questInfo.familyCoin + (skillUpInfo ~= nil and skillUpInfo.params[1] or 0), {r=0,g=0,b=0,a=255,w=1})
                if skillUpInfo ~= nil then
                    CSResourceMgr.setLabelColorByNode(quest_devote, {r=147,g=254,b=6,a=255})
                    local arrow = CSResourceMgr.seekNodeByName(quest, "arrow1")
                    arrow:setVisible(true)
                    
                    CSResourceMgr.setLabelColorByNode(quest_coin, {r=147,g=254,b=6,a=255})
                    arrow = CSResourceMgr.seekNodeByName(quest, "arrow2")
                    arrow:setVisible(true)
                end
                local quest_bonus = CSResourceMgr.seekNodeByName(quest, "quest_bonus")
                CSResourceMgr.setLabelStringByNode(quest_bonus, questInfo.awardElementNums[questAwards[i] + 1], {r=0,g=0,b=0,a=255,w=1})
                
                CSResourceMgr.clickEventBindingByNode(quest_btn_recv,function()
                    GameAudio.playUISound("reward")
                    FamilyQuestListMgr.hideUI()
                    FamilyInfo.ApplyFamilyQuest(i-1, questInfo.classType)
                end)
                --CSResourceMgr.setButtonEnabledByNode(recvbtn, (familyQuestID == 0 or CharInfo.getServerTime() >= familyQuestFailedTime + 3600) and ((bVaild == true and (CharInfo.getTodayFamilyQuestNum() or 0) or 0) < totalQuestLimit) and true or false)
                quest:setVisible(true)
                quest:setScaleY(0)
                list:pushBackCustomItem(quest)
                transition.scaleTo(quest,{scale=1.0,time = 0.1})
            end)
        end
        UnblockLoader.load(funcTable,"FamilyQuestListMgr")
    end
end

return FamilyQuestListMgr