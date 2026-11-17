local MissionListMgr = {}

MissionListMgr.ICON_PATH = ""
MissionListMgr.FADE_TIME = 0.5

local resName = ""
local resNameA = ""
local resNameB = ""
local resNameC = ""
local resNameBG = ""
local resNameAni = ""
local tabname = {}
local apVec = {}
local checkRedPointFuncVec = {}
local dailyMissionLock = nil

local curTab = 1
local hasRedPoint = false
local isAPRequested = false
local refreshAPFunc = nil
local addNewMissionFunc = nil
local missionCellNodes = {}
local missionDCellNodes = {}
local missionFCellNodes = {}
local missionVec = {}
local awardElementsString = {}

function MissionListMgr.Init()
    resName = "Player/MissionList.csb"
    resNameA = "Player/MissionTabA.csb"
    resNameB = "Player/MissionTabB.csb"
    resNameC = "Player/MissionTabC.csb"
    resNameBG = "Pet/Formation/FormationBGNew.csb"
    resNameAni = "Spine/effects/Ui_chongwulingqujiemian.png"
    tabname = {"mission1", "mission2", "town4"}
    apVec = {30, 60, 100}
    checkRedPointFuncVec = {
        [1] = function()
            local CurQuest = QuestInfo.getCurQuestInfos()
            for key, var in pairs(CurQuest) do
                if QuestInfo.checkQuestFinished(var.questID) and QuestInfo.getNewQuestInfoById(var.questID).needVisable==1 then
                    print("checkRedPointFunc yes, qid:", var.questID)
                    return true
                end
            end
            return false
        end,
        [2] = function()
            local DailyQuest = QuestInfo.getDailyQuestInfos()
            for key, var in pairs(DailyQuest) do
                if QuestInfo.checkQuestFinished(var.questID) and var.status~=Proto.QUEST_STATUS_DONE then
                    print("checkRedPointFunc yes, qid", var.questID)
                    return true
                end
            end
            return false
        end,
        [3] = function()
            local fqID = CharInfo.getFamilyQuestID()
            if fqID then
                local msInfo = QuestInfo.getFamilyQuestInfoById(fqID)
                if msInfo then
                    local mType = msInfo.familyQuestType
                    local curProcess = 0
                    local needProcess = 1
                    if mType==Proto.FQT_ARREST or mType==Proto.FQT_PATROL or mType==Proto.FQT_MONSTER then
                        curProcess = CharInfo.getFamilyQuestOK() or 0
                        needProcess = 1
                    elseif mType==Proto.FQT_SEARCH then
                        if CharInfo.getServerTime()<=tonumber(CharInfo.getFamilyQuestFailedTime()) then
                            curProcess = ItemInfo.getCharItemNum(msInfo.params[1])
                        end
                        needProcess = msInfo.params[2]
                    end
                    if curProcess>=needProcess then
                        return true
                    end
                end
            end
            return false
        end,
    }
    if not dailyMissionLock then
        dailyMissionLock = {}
    	local sID = {
    	    [1019] = 22001,
            [1020] = 22002,
            [1010] = 22003,
            [1016] = 22004,
            [1006] = 22005,
            [1017] = 22006,
            [1015] = 22007,
            [1018] = 22008,
            [1023] = 24017,
    	}
    	for key, var in pairs(sID) do
            local value = SystemInfo.getGlobalConfigAddInfoByID(var)
            if value then
                dailyMissionLock[key] = value.values[1]
            end
    	end
    end
    
    curTab = 1
    hasRedPoint = false
    isAPRequested = false
    refreshAPFunc = nil
    addNewMissionFunc = nil
    missionCellNodes = {}
    missionDCellNodes = {}
    missionFCellNodes = {}
    missionVec = {}
    awardElementsString = {
        [1] = 9998,
        [2] = 9999,
        [46] = 9996,
        [90] = 9997,
    }
end

function MissionListMgr.setTab(id)
	if id~=1 and id~=2 then
		return
	end
	curTab = id
end

function MissionListMgr.show(scene, tab)
    if CSResourceMgr.getCsbObj(resNameBG, "MissionListMgr") then
        return
    end
    UIStack.push("MissionListMgr", MissionListMgr.hide, true)

    curTab = tab or curTab
    hasRedPoint = false
    
    local function checkTab()
    	if curTab==1 then
            MissionListMgr.checkSkill(nil)
    		MissionListMgr.setTabA(true)
    		MissionListMgr.setTabB(false)
            MissionListMgr.setTabC(false)
        elseif curTab==2 then
            MissionListMgr.checkSkill("exp")
            MissionListMgr.setTabA(false)
            MissionListMgr.setTabB(true)
            MissionListMgr.setTabC(false)
        elseif curTab==3 then
            MissionListMgr.checkSkill("famliy")
            MissionListMgr.setTabA(false)
            MissionListMgr.setTabB(false)
            MissionListMgr.setTabC(true)
    	end
    end
    
    local function loadBG()
        local bgLayer = CSResourceMgr.createRes(scene, resNameBG, "MissionListMgr")
        bgLayer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resNameBG, 320, 480, "MissionListMgr")
        bgLayer:setOpacity(0)
        transition.fadeIn(bgLayer, {time=0.3})
    end
	
	local function loadCSB()
		local layer = CSResourceMgr.createRes(scene, resName)
        layer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        layer:setVisible(false)
        CSResourceMgr.setRelativePosition(resName, 320, 480)
        CocosModuleMgr.setEdgeDistance(layer, nil, nil, nil, 0)
        
        local diff = CocosModuleMgr.getScreenSizeDiff()
        local frame = CSResourceMgr.getNodeByName(resName, "frame")
        local fsize = frame:getContentSize()
        frame:setContentSize(fsize.width, fsize.height+diff)
        local title = CSResourceMgr.getNodeByName(resName, "title")
        local tposy = title:getPositionY()
        title:setPositionY(tposy+diff)
        local line = CSResourceMgr.getNodeByName(resName, "line")
        local lposy = line:getPositionY()
        line:setPositionY(lposy+diff)
        line:setLocalZOrder(5)
        local skill = CSResourceMgr.getNodeByName(resName, "skill")
        local sposy = skill:getPositionY()
        skill:setPositionY(sposy+diff)
        for var=1, #tabname do
            local tabbtn = CSResourceMgr.getNodeByName(resName, "tab"..var)
            local tabposy = tabbtn:getPositionY()
            tabbtn:setPositionY(tabposy+diff)
        end
        
        CSResourceMgr.setLabelColor(resName, "title", {r=214,g=245,b=251,a=255})
        CSResourceMgr.setLabelString(resName, "title", "mission8", "", {r=26,g=37,b=48,a=255})
        local textColor = {{r=82,g=82,b=82,a=255}, {r=255,g=255,b=255,a=255}}
        local outlineColor = {{r=230,g=230,b=230,a=255,w=1}, {r=0,g=0,b=0,a=255,w=1,s=1}}
        for var=1, #tabname do
        	CSResourceMgr.clickEventBinding(resName, "tab"..var, function()
        	    if var==3 then
        	    	if CharInfo.getFamilyID() == nil or FamilyInfo.GetLocalFamilyInfo() == nil then
                        StandardTipsMgr.show(1, "mission13")
                        return
                    end
        	    end
                local n = curTab
                CSResourceMgr.setButtonEnabled(resName, "tab"..n, true)
                CSResourceMgr.setLabelString(resName, "tabtext"..n, tabname[n], "", outlineColor[1], nil, 100)
                CSResourceMgr.setLabelColor(resName, "tabtext"..n, textColor[1])
                CSResourceMgr.getNodeByName(resName, "tab"..n):setScale(1)
                CSResourceMgr.getNodeByName(resName, "tab"..n):setLocalZOrder(0)
        		curTab = var
        		checkTab()
                CSResourceMgr.setButtonEnabled(resName, "tab"..var, false)
                CSResourceMgr.setLabelString(resName, "tabtext"..var, tabname[var], "", outlineColor[2], nil, 100)
                CSResourceMgr.setLabelColor(resName, "tabtext"..var, textColor[2])
                CSResourceMgr.getNodeByName(resName, "tab"..var):setScale(1.1)
                CSResourceMgr.getNodeByName(resName, "tab"..var):setLocalZOrder(1)
            end, nil, nil, "sheetClick")
        	if var==curTab then
                CSResourceMgr.setButtonEnabled(resName, "tab"..var, false)
                CSResourceMgr.setLabelString(resName, "tabtext"..var, tabname[var], "", outlineColor[2], nil, 100)
                CSResourceMgr.setLabelColor(resName, "tabtext"..var, textColor[2])
                CSResourceMgr.getNodeByName(resName, "tab"..var):setScale(1.1)
                CSResourceMgr.getNodeByName(resName, "tab"..var):setLocalZOrder(1)
        	else
                CSResourceMgr.setButtonEnabled(resName, "tab"..var, true)
                CSResourceMgr.setLabelString(resName, "tabtext"..var, tabname[var], "", outlineColor[1], nil, 100)
                CSResourceMgr.setLabelColor(resName, "tabtext"..var, textColor[1])
                CSResourceMgr.getNodeByName(resName, "tab"..var):setScale(1)
                CSResourceMgr.getNodeByName(resName, "tab"..var):setLocalZOrder(0)
        	end
        end
	end
	
	local function playCSB()
        CSResourceMgr.getCsbObj(resName):setVisible(true)
		CocosModuleMgr.showUIAnimation(CSResourceMgr.getCsbObj(resName), "up", function()
            --checkTab()
		end)
        checkTab()
        StatusBarMgr.showTopInfoBar(function()
            MissionListMgr.hide()
        end)
	end
	
	local function checkRedPoint()
        for var=1, #tabname do
            local tabRed = CSResourceMgr.getNodeByName(resName, "tabred"..var)
            tabRed:setVisible(checkRedPointFuncVec[var]())
            tabRed:setScale(1.2)
            tabRed:pos(110, 31)
		end
	end
	
    local funcTable = {loadBG, loadCSB, playCSB, checkRedPoint}
    UnblockLoader.load(funcTable, "MissionListMgr.show")
end

function MissionListMgr.setTabA(boolVisible)
	local parent = CSResourceMgr.getNodeByName(resName, "diban")
	local curNode = CSResourceMgr.getCsbObj(resNameA)
	if curNode then
        curNode:setVisible(boolVisible)
	else
        if boolVisible then
	   	    local function loadCSB()
	   	    	local layer = CSResourceMgr.createRes(parent, resNameA)
	   	    	
                local diff = CocosModuleMgr.getScreenSizeDiff()
                local list = CSResourceMgr.getNodeByName(resNameA, "list")
                local lsize = list:getContentSize()
                list:setContentSize(lsize.width, lsize.height+diff)
                
                CSResourceMgr.getNodeByName(resName, "skill"):setVisible(false)
	   	    end
	   	    
            local tmpMissionData = QuestInfo.getCurQuestInfos()
            local missionData = {}
            local glowMissionData = {}
	   	    for key, var in pairs(tmpMissionData) do
	   	        local boolGlow = false
	   	        for n=1, #GameGuideMgr.GLOW_MISSION_ID_EVO do
                    if GameGuideMgr.GLOW_MISSION_ID_EVO[n]==var.questID then
	   	        		boolGlow = true
	   	        		break
	   	        	end
	   	        end
                if not boolGlow then
                    for n=1, #GameGuideMgr.GLOW_MISSION_ID_STU do
                        if GameGuideMgr.GLOW_MISSION_ID_STU[n]==var.questID then
                            boolGlow = true
                            break
                        end
                    end
	   	        end
                if boolGlow then
                    table.insert(glowMissionData, var)
	   	        else
                    if QuestInfo.checkQuestFinished(var.questID) then
                        table.insert(missionData, 1, var)
                    else
                        table.insert(missionData, var)
                    end
	   	        end                
	   	    end
            for key, var in pairs(glowMissionData) do
                table.insert(missionData, 1, var)
	   	    end
            local funcTable = {loadCSB}
            missionCellNodes = {}
            missionVec = {}
            local function initMs(funcTable, var, index)
                local msID = var.questID
                table.insert(funcTable, function()
                    local parent = CSResourceMgr.getNodeByName(resNameA, "mdiban"):clone()
                    missionCellNodes[msID] = parent
                    if index then
                        table.insert(missionVec, index, var.questID)
                        CSResourceMgr.getNodeByName(resNameA, "list"):insertCustomItem(parent, index-1)
                    else
                        table.insert(missionVec, msID)
                        CSResourceMgr.getNodeByName(resNameA, "list"):pushBackCustomItem(parent)
                    end
                end)
                table.insert(funcTable, function()
                    local msInfo = QuestInfo.getNewQuestInfoById(msID)
                    local list = CSResourceMgr.getNodeByName(resNameA, "list")
                    local parent = missionCellNodes[msID]
                    local icon = CSResourceMgr.seekNodeByName(parent, "icon")
                    if msInfo.icon then
                        CSResourceMgr.setSpriteTextureByNode(icon, MissionListMgr.ICON_PATH..msInfo.icon)
                    end
                    local gico = CSResourceMgr.seekNodeByName(parent, "gico")
                    local eico = CSResourceMgr.seekNodeByName(parent, "eico")
                    local aico = CSResourceMgr.seekNodeByName(parent, "aico")
                    local gicodb = CSResourceMgr.seekNodeByName(parent, "gicodb")
                    local eicodb = CSResourceMgr.seekNodeByName(parent, "eicodb")
                    if msInfo.awardIcon~="nil" then
                        CSResourceMgr.setSpriteTextureByNode(aico, MissionListMgr.ICON_PATH..msInfo.awardIcon)
                    end
                    local gold = CSResourceMgr.seekNodeByName(parent, "gold")
                    if msInfo.buttonName then
                        if msInfo.buttonName==0 or tonumber(msInfo.buttonName)==0 or tonumber(msInfo.buttonName)==nil then
                            gold:setVisible(false)
                            gico:setVisible(false)
                            gicodb:setVisible(false)
                        else
                            CSResourceMgr.setLabelStringByNode(gold, msInfo.buttonName, {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 100)
                            gicodb:setColor({r=81,g=112,b=137})
                        end
                    end
                    local exp = CSResourceMgr.seekNodeByName(parent, "exp")
                    if msInfo.targetMapName then
                        if msInfo.targetMapName==0 or tonumber(msInfo.targetMapName)==0 or tonumber(msInfo.targetMapName)==nil then
                            exp:setVisible(false)
                            eico:setVisible(false)
                            eicodb:setVisible(false)
                        else
                            CSResourceMgr.setLabelStringByNode(exp, msInfo.targetMapName, {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 100)
                            eicodb:setColor({r=81,g=112,b=137})
                        end
                    end
                    CSResourceMgr.seekNodeByName(parent, "mstitledb"):setColor({r=81,g=112,b=137})
                    local mstitle = CSResourceMgr.seekNodeByName(parent, "mstitle")
                    CSResourceMgr.setLabelColorByNode(mstitle, {r=255,g=240,b=0,a=255})
                    CSResourceMgr.setLabelStringByNode(mstitle, msInfo.name, {r=17,g=27,b=38,a=255,w=1,s=1}, nil, 310)
                    local desc = CSResourceMgr.seekNodeByName(parent, "desc")
                    CSResourceMgr.setLabelColorByNode(desc, {r=71,g=96,b=103,a=255})
                    CSResourceMgr.setLabelStringByNode(desc, msInfo.desc, nil, nil, 290)
                    local curProcess = var.progressList[1] or 0
                    local needProcess = msInfo.objectiveList[1].amount
                    local process = CSResourceMgr.seekNodeByName(parent, "process")
                    CSResourceMgr.setLabelStringByNode(process, curProcess.."/"..needProcess, 
                        {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 70)
                    local pbar = CSResourceMgr.seekNodeByName(parent, "pbar")
                    pbar:setPercent(curProcess*100/needProcess)
                    local clain = CSResourceMgr.seekNodeByName(parent, "clain")
                    CSResourceMgr.setButtonStringColorByNode(clain, {r=248,g=255,b=238,a=255})
                    CSResourceMgr.setButtonStringByNode(clain, "mission6", {r=36,g=98,b=5,a=255,w=1,s=1})
                    CSResourceMgr.clickEventBindingByNode(clain, function(sender)
                        local function finish()
                            gicodb:setVisible(false)
                            eicodb:setVisible(false)
                            transition.moveTo(gico, {x=167, y=62, time=0.1})
                            transition.moveTo(eico, {x=272, y=60, time=0.1})
                            transition.moveTo(aico, {x=377, y=62, time=0.1})
                            transition.moveTo(gold, {x=220, y=60, time=0.1})
                            transition.moveTo(exp, {x=325, y=60, time=0.1})
                            parent:performWithDelay(function()
                                transition.moveBy(gico, {y=50, time=0.8})
                                transition.moveBy(eico, {y=50, time=0.8})
                                transition.moveBy(aico, {y=50, time=0.8})
                                transition.moveBy(gold, {y=50, time=0.8})
                                transition.moveBy(exp, {y=50, time=0.8})
                                transition.fadeOut(gico, {time=0.8})
                                transition.fadeOut(eico, {time=0.8})
                                transition.fadeOut(aico, {time=0.8})
                                transition.fadeOut(gold, {time=0.8})
                                transition.fadeOut(exp, {time=0.8})
                                parent:performWithDelay(function()
                                    transition.moveBy(parent, {x=600, time=0.2})
                                    parent:performWithDelay(function()
                                        for k, v in pairs(missionVec) do
                                            if v==msID then
                                                missionCellNodes[msID] = nil
                                                list:removeItem(k-1)
                                                table.remove(missionVec, k)
                                                break
                                            end
                                        end
                                    end, 0.2)
                                end, 0.8)
                            end, 0.1)
                        end
                        
                        finish()
                        NetInterface.sendWithBlock("ZC_CommitQuest_Ack", function()
                            local NewQuestSend = require("src.Net.Send.NewQuestSend")
                            NewQuestSend.sendCZ_CommitQuest_Req(msID)
                        end, function()
                        	local tabRed = CSResourceMgr.getNodeByName(resName, "tabred1")
                            if tabRed then
                                tabRed:setVisible(checkRedPointFuncVec[1]())
                        	end
                        end, function(code)
                            TipsMgr.showError(nil, code)
                        end)
                    end, nil, "reward")
                    local guide = CSResourceMgr.seekNodeByName(parent, "guide")
                    CSResourceMgr.setButtonStringColorByNode(guide, {r=248,g=255,b=238,a=255})
                    CSResourceMgr.setButtonStringByNode(guide, "mission5", {r=100,g=74,b=2,a=255,w=1,s=1})
                    CSResourceMgr.clickEventBindingByNode(guide, function()
                        MissionListMgr.hide()
                        QuestInfo.guideFunc(msID)
                    end, nil, "select1")
                    CSResourceMgr.seekNodeByName(parent, "claindb"):setLocalZOrder(-1)
                    CSResourceMgr.seekNodeByName(parent, "guidedb"):setLocalZOrder(-1)
                    if curProcess>=needProcess then
                        clain:setVisible(true)
                    else
                        guide:setVisible(true)
                    end
                    parent:setCascadeOpacityEnabled(true)
                end)
                table.insert(funcTable, function()
                    missionCellNodes[msID]:setVisible(true)
                    missionCellNodes[msID]:setScaleY(0)
                    transition.scaleTo(missionCellNodes[msID], {scale=1, time=0.1})
                end)
            end
            addNewMissionFunc = initMs
            for k=1, #missionData do
                local var = missionData[k]
                if QuestInfo.getNewQuestInfoById(var.questID).needVisable==1 then
                    initMs(funcTable, var)
                end
            end
            UnblockLoader.load(funcTable, "MissionListMgr.setTabA")
	    end
	end
end

function MissionListMgr.setTabB(boolVisible)
    local parent = CSResourceMgr.getNodeByName(resName, "diban")
    local curNode = CSResourceMgr.getCsbObj(resNameB)
    if curNode then
        curNode:setVisible(boolVisible)
    else
        if boolVisible then
            local function changeAPLabel()
                if not CSResourceMgr.getCsbObj(resNameB) then
                	return
                end
                local num = CharInfo.get().dailyquestpower
                CSResourceMgr.setLabelColor(resNameB, "hytitle", {r=166,g=243,b=255,a=255})
                CSResourceMgr.setLabelString(resNameB, "hytitle", "mission9", nil, {r=12,g=27,b=38,a=255,w=1,s=1}, nil, 120)
                CSResourceMgr.setLabelString(resNameB, "hydata", num, nil, {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 100)
                --[[
                local hydata = CSResourceMgr.getNodeByName(resNameB, "hydata")
                hydata:removeAllChildren()
                CocosModuleMgr.createRichLabel(hydata, CocosModuleMgr.createStringWithFormat({"mission9", num}),
                    23, "cuyuan_GBK.ttf", 640, 0, 0)
                ]]
                    
                for var=1, #apVec do
                    local status = CharInfo.get()["dailyquestgift"..var-1]
                    if status==1 then
                        CSResourceMgr.setButtonEnabled(resNameB, "apbtn"..var, false)
                        CSResourceMgr.setButtonEnabled(resNameB, "apimg"..var, false)
                    elseif status==0 then
                        CSResourceMgr.setButtonEnabled(resNameB, "apbtn"..var, true)
                        CSResourceMgr.setButtonEnabled(resNameB, "apimg"..var, true)
                        if num>=apVec[var] then
                            local tag = "MissionListMgr"..var
                            if not AnimationMgr.getGafObj(resNameAni, tag) then
                                local parent = CSResourceMgr.getNodeByName(resNameB, "apimg"..var)
                                local ani = AnimationMgr.createAni(parent, resNameAni, 
                                    45, 42.5, tag)
                                ani:setScale(0.2)
                                ani:setLocalZOrder(-1)
                                parent:setLocalZOrder(-1)
                                AnimationMgr.playAni(resNameAni, "animation", true, tag)
                            end
                        end
                    end
                    CSResourceMgr.getNodeByName(resNameB, "apimg"..var):setTouchEnabled(false)
                end
                    
                CocosModuleMgr.setLoadingBarPercent(CSResourceMgr.getNodeByName(resNameB, "progressbar"), num, 1)
                --CSResourceMgr.getNodeByName(resNameB, "progressbar"):setPercent(num)
            end
            
            local function loadCSB()
                local layer = CSResourceMgr.createRes(parent, resNameB)
                
                local diff = CocosModuleMgr.getScreenSizeDiff()
                local list = CSResourceMgr.getNodeByName(resNameB, "list")
                local lsize = list:getContentSize()
                list:setContentSize(lsize.width, lsize.height+diff)
                local listdb = CSResourceMgr.getNodeByName(resNameB, "listdb")
                local ldbsize = listdb:getContentSize()
                listdb:setContentSize(ldbsize.width, ldbsize.height+diff)
                local hydiban = CSResourceMgr.getNodeByName(resNameB, "hydiban")
                local hposy = hydiban:getPositionY()
                hydiban:setPositionY(hposy+diff)
                
                local dropVec = SystemInfo.getGlobalConfigAddInfoByID(31).values
                for var=1, #apVec do
                    CSResourceMgr.setLabelString(resNameB, "hypoint"..var, apVec[var], "", {r=0,g=0,b=0,a=255,w=1,s=1})
                    --[[
                    CSResourceMgr.longtouchEventBinding(resNameB, "apbtn"..var, function()
                        DropInfoViewMgr.showWithDropID(dropVec[var])
                    end, function()
                        if CharInfo.get().dailyquestpower<apVec[var] then
                            StandardTipsMgr.show(1, "mission3")
                            return
                        end
                        NetInterface.sendWithBlock("GC_GetDailyQuestStepAward_Ack", function()
                            local NewQuestSend = require("src.Net.Send.NewQuestSend")
                            NewQuestSend.sendCG_GetDailyQuestStepAward_Req(var)
                        end, function()
                            CSResourceMgr.setButtonEnabled(resNameB, "apbtn"..var, false)
                            CSResourceMgr.setButtonEnabled(resNameB, "apimg"..var, false)
                            AnimationMgr.removeGafObjectByTag(resNameAni, "MissionListMgr"..var)
                        end, function(code)
                            TipsMgr.showError(nil, code)
                        end)
                        GameAudio.playUISound("itemGet")
                    end)]]
                    CSResourceMgr.clickEventBinding(resNameB, "apbtn"..var, function()
                        if CharInfo.get().dailyquestpower<apVec[var] then
                            DropInfoViewMgr.showWithDropID(dropVec[var])
                            return
                        end
                        NetInterface.sendWithBlock("GC_GetDailyQuestStepAward_Ack", function()
                            local NewQuestSend = require("src.Net.Send.NewQuestSend")
                            NewQuestSend.sendCG_GetDailyQuestStepAward_Req(var)
                        end, function()
                            CSResourceMgr.setButtonEnabled(resNameB, "apbtn"..var, false)
                            CSResourceMgr.setButtonEnabled(resNameB, "apimg"..var, false)
                            AnimationMgr.removeGafObjectByTag(resNameAni, "MissionListMgr"..var)
                        end, function(code)
                            TipsMgr.showError(nil, code)
                        end)
                        GameAudio.playUISound("itemGet")
                    end)
                    CSResourceMgr.getNodeByName(resNameB, "apbtn"..var):setPressedActionEnabled(true)
                end
                
                if isAPRequested then
                    changeAPLabel()
                else
                    NetInterface.sendWithBlock("GC_GetCharacterValues_Ack", function()
                        local LoginSend = require("src.Net.Send.LoginSend")
                        LoginSend.sendCG_GetCharacterValues_Req({"dailyQuestPower", "dailyQuestGift0", 
                            "dailyQuestGift1", "dailyQuestGift2"})
                    end, function()
                        changeAPLabel()
                        --isAPRequested = true
                    end, function(code)
                        TipsMgr.showError(nil, code)
                    end)
                end
                refreshAPFunc = changeAPLabel
            end

            local skillUpInfo, num = AchievementListMgr.getSkillUpInfo("exp")            
            local tmpMissionData = QuestInfo.getDailyQuestInfos()
            local missionData = {}
            local unlockMissionData = {}
            for key, var in pairs(tmpMissionData) do
                if var.status~=Proto.QUEST_STATUS_DONE then
                    local function addMs()
                        if QuestInfo.checkQuestFinished(var.questID) then
                            table.insert(missionData, 1, var)
                        else
                            table.insert(missionData, var)
                        end
                    end
                    local levelLock = dailyMissionLock[tonumber(var.questID)]
                    if levelLock then
                        if levelLock>CharInfo.getLevel() then
                            table.insert(unlockMissionData, var)
                        else
                            addMs()
                        end
                    else
                        addMs()
                    end
                end
            end
            for key, var in pairs(unlockMissionData) do
                table.insert(missionData, var)
            end
            for key, var in pairs(tmpMissionData) do
                if var.status==Proto.QUEST_STATUS_DONE then
                    table.insert(missionData, var)
                end
            end
            local funcTable = {loadCSB}
            missionDCellNodes = {}
            missionDCellNodes.lockButton = {}
            for n=1, #missionData do
                local var = missionData[n]
            	local key = var.questID
                table.insert(funcTable, function()
                    local parent = CSResourceMgr.getNodeByName(resNameB, "mdiban"):clone()
                    missionDCellNodes[key] = parent
                    CSResourceMgr.getNodeByName(resNameB, "list"):pushBackCustomItem(parent)
                end)
                table.insert(funcTable, function()
                    local msID = var.questID
                    local msInfo = QuestInfo.getNewQuestInfoById(msID)
                    local parent = missionDCellNodes[key]
                    local icon = CSResourceMgr.seekNodeByName(parent, "icon")
                    if msInfo.icon then
                        CSResourceMgr.setSpriteTextureByNode(icon, MissionListMgr.ICON_PATH..msInfo.icon)
                    end
                    local aico = CSResourceMgr.seekNodeByName(parent, "aico")
                    if msInfo.awardIcon~="nil" then
                        CSResourceMgr.setSpriteTextureByNode(aico, MissionListMgr.ICON_PATH..msInfo.awardIcon)
                    end
                    CSResourceMgr.seekNodeByName(parent, "mstitledb"):setColor({r=81,g=112,b=137})
                    local mstitle = CSResourceMgr.seekNodeByName(parent, "mstitle")
                    CSResourceMgr.setLabelColorByNode(mstitle, {r=255,g=240,b=0,a=255})
                    CSResourceMgr.setLabelStringByNode(mstitle, msInfo.name, {r=17,g=27,b=38,a=255,w=1,s=1}, nil, 310)
                    local desc = CSResourceMgr.seekNodeByName(parent, "desc")
                    CSResourceMgr.setLabelColorByNode(desc, {r=71,g=96,b=103,a=255})
                    CSResourceMgr.setLabelStringByNode(desc, msInfo.desc, nil, nil, 290)
                    local msStatus = var.status
                    local gico = CSResourceMgr.seekNodeByName(parent, "gico")
                    local eico = CSResourceMgr.seekNodeByName(parent, "eico")
                    local aico = CSResourceMgr.seekNodeByName(parent, "aico")
                    local gicodb = CSResourceMgr.seekNodeByName(parent, "gicodb")
                    local eicodb = CSResourceMgr.seekNodeByName(parent, "eicodb")
                    local gold = CSResourceMgr.seekNodeByName(parent, "gold")
                    local arrow = CSResourceMgr.seekNodeByName(parent, "expup")
                    if msInfo.buttonName then
                        if msInfo.buttonName==0 or tonumber(msInfo.buttonName)==0 or tonumber(msInfo.buttonName)==nil then
                        	gold:setVisible(false)
                            gico:setVisible(false)
                            gicodb:setVisible(false)
                        else
                            CSResourceMgr.setLabelStringByNode(gold, msInfo.buttonName, {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 100)
                            gicodb:setColor({r=81,g=112,b=137})
                        end
                    end
                    local exp = CSResourceMgr.seekNodeByName(parent, "exp")
                    if msInfo.targetMapName then
                        if msInfo.targetMapName==0 or tonumber(msInfo.targetMapName)==0 or tonumber(msInfo.targetMapName)==nil then
                            exp:setVisible(false)
                            eico:setVisible(false)
                            eicodb:setVisible(false)
                        else
                            local maxWidth = 100
                            local addNum = 0
                            if skillUpInfo then
                                maxWidth = 80
                                CSResourceMgr.setLabelColorByNode(exp, {r=147,g=254,b=6,a=255})
                                arrow:setVisible(true)
                                arrow:zorder(1)
                                addNum = skillUpInfo.params[1]
                            end
                            CSResourceMgr.setLabelStringByNode(exp, msInfo.targetMapName+addNum, {r=0,g=0,b=0,a=255,w=1,s=1}, 
                                nil, maxWidth)
                            eicodb:setColor({r=81,g=112,b=137})
                        end
                    end
                    local award = CSResourceMgr.seekNodeByName(parent, "award")
                    if msInfo.dailyQuestPower and tonumber(msInfo.dailyQuestPower) then
                        CSResourceMgr.setLabelStringByNode(award, "x"..msInfo.dailyQuestPower, 
                            {r=0,g=0,b=0,a=255,w=1}, nil, 38)
                    end
                    local curProcess = var.progressList[1] or 0
                    local needProcess = msInfo.objectiveList[1].amount
                    local process = CSResourceMgr.seekNodeByName(parent, "process")
                    CSResourceMgr.setLabelStringByNode(process, curProcess.."/"..needProcess, 
                        {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 70)
                    local pbar = CSResourceMgr.seekNodeByName(parent, "pbar")
                    pbar:setPercent(curProcess*100/needProcess)
                    local flag = CSResourceMgr.seekNodeByName(parent, "flag")
                    local flagtext = CSResourceMgr.seekNodeByName(parent, "flagtext")
                    CSResourceMgr.setLabelStringByNode(flagtext, "mission7", {r=194,g=27,b=27,a=255,w=3}, nil, 120)
                    local clain = CSResourceMgr.seekNodeByName(parent, "clain")
                    CSResourceMgr.setButtonStringColorByNode(clain, {r=248,g=255,b=238,a=255})
                    CSResourceMgr.setButtonStringByNode(clain, "mission6", {r=36,g=98,b=5,a=255,w=1,s=1})
                    CSResourceMgr.clickEventBindingByNode(clain, function(sender)
                        local function finish()
                            gicodb:setVisible(false)
                            eicodb:setVisible(false)
                            arrow:setVisible(false)
                            transition.moveTo(gico, {x=167, y=62, time=0.1})
                            transition.moveTo(eico, {x=272, y=60, time=0.1})
                            transition.moveTo(aico, {x=377, y=62, time=0.1})
                            transition.moveTo(gold, {x=220, y=60, time=0.1})
                            transition.moveTo(exp, {x=325, y=60, time=0.1})
                            transition.moveTo(award, {x=392, y=60, time=0.1})
                            parent:performWithDelay(function()
                                transition.moveBy(gico, {y=50, time=0.8})
                                transition.moveBy(eico, {y=50, time=0.8})
                                transition.moveBy(aico, {y=50, time=0.8})
                                transition.moveBy(gold, {y=50, time=0.8})
                                transition.moveBy(exp, {y=50, time=0.8})
                                transition.moveBy(award, {y=50, time=0.8})
                                transition.fadeOut(gico, {time=0.8})
                                transition.fadeOut(eico, {time=0.8})
                                transition.fadeOut(aico, {time=0.8})
                                transition.fadeOut(gold, {time=0.8})
                                transition.fadeOut(exp, {time=0.8})
                                transition.fadeOut(award, {time=0.8})
                            end, 0.1)
                            flag:setVisible(true)
                            flagtext:setVisible(true)
                            clain:setVisible(false)
                        end
                        finish()
                        NetInterface.sendWithBlock("ZC_CommitQuest_Ack", function()
                        	local NewQuestSend = require("src.Net.Send.NewQuestSend")
                            NewQuestSend.sendCZ_CommitQuest_Req(msID)
                        end, function()
                            local tabRed = CSResourceMgr.getNodeByName(resName, "tabred2")
                            if tabRed then
                                tabRed:setVisible(checkRedPointFuncVec[2]())
                            end
                        end, function(code)
                        	TipsMgr.showError(nil, code)
                        end)
                    end, nil, "reward")
                    local guide = CSResourceMgr.seekNodeByName(parent, "guide")
                    CSResourceMgr.setButtonStringColorByNode(guide, {r=248,g=255,b=238,a=255})
                    CSResourceMgr.setButtonStringByNode(guide, "mission5", {r=100,g=74,b=2,a=255,w=1,s=1})
                    CSResourceMgr.clickEventBindingByNode(guide, function()
                        MissionListMgr.hide()
                        QuestInfo.guideFunc(msID)
                    end, nil, "select1")
                    local levelLock = dailyMissionLock[tonumber(msID)]
                    if levelLock then
                        if levelLock>CharInfo.getLevel() then
                            CSResourceMgr.setButtonEnabledByNode(guide, false)
                            CSResourceMgr.setButtonStringByNode(guide, CocosModuleMgr.createStringWithFormat({"tips33", levelLock}), 
                                {r=55,g=55,b=55,a=255,w=1,s=1})
                            missionDCellNodes.lockButton[msID] = guide
                    	end
                    end
                    CSResourceMgr.seekNodeByName(parent, "claindb"):setLocalZOrder(-1)
                    CSResourceMgr.seekNodeByName(parent, "guidedb"):setLocalZOrder(-1)
                    if msStatus==Proto.QUEST_STATUS_DONE then
                        flag:setVisible(true)
                        flagtext:setVisible(true)
                        gicodb:setVisible(false)
                        eicodb:setVisible(false)
                        gico:setVisible(false)
                        eico:setVisible(false)
                        aico:setVisible(false)
                        gold:setVisible(false)
                        exp:setVisible(false)
                        award:setVisible(false)
                    else
                        --local testnumber = GetRandom.random(1, 2)
                        if curProcess>=needProcess then
                            clain:setVisible(true)
                        else
                            guide:setVisible(true)
                        end
                    end
                    parent:setCascadeOpacityEnabled(true)
                end)
                table.insert(funcTable, function()
                    missionDCellNodes[key]:setVisible(true)
                    missionDCellNodes[key]:setScaleY(0)
                    transition.scaleTo(missionDCellNodes[key], {scale=1, time=0.1})
                end)
            end
            UnblockLoader.load(funcTable, "MissionListMgr.setTabB")
        end
    end
end

function MissionListMgr.setTabC(boolVisible)
    local parent = CSResourceMgr.getNodeByName(resName, "diban")
    local curNode = CSResourceMgr.getCsbObj(resNameC)
    if curNode then
        curNode:setVisible(boolVisible)
    else
        if boolVisible then
            local function loadCSB()
                local layer = CSResourceMgr.createRes(parent, resNameC)

                local diff = CocosModuleMgr.getScreenSizeDiff()
                local list = CSResourceMgr.getNodeByName(resNameC, "list")
                local lsize = list:getContentSize()
                list:setContentSize(lsize.width, lsize.height+diff)
            end
            
            local skillUpInfo, num = AchievementListMgr.getSkillUpInfo("famliy")
            missionFCellNodes = {}
            local missionDatas = {CharInfo.getFamilyQuestID()}
            local funcTable = {loadCSB}
            local function initMs(funcTable, var, index)
                local msID = var
                table.insert(funcTable, function()
                    local parent = CSResourceMgr.getNodeByName(resNameC, "mdiban"):clone()
                    missionFCellNodes[msID] = parent
                    if index then
                        CSResourceMgr.getNodeByName(resNameC, "list"):insertCustomItem(parent, index-1)
                    else
                        CSResourceMgr.getNodeByName(resNameC, "list"):pushBackCustomItem(parent)
                    end
                end)
                table.insert(funcTable, function()
                    local msInfo = QuestInfo.getFamilyQuestInfoById(msID)
                    local list = CSResourceMgr.getNodeByName(resNameC, "list")
                    local parent = missionFCellNodes[msID]
                    local awardIndex = CharInfo.get().familyquestawardindex or 0
                    local stageico = CSResourceMgr.seekNodeByName(parent, "stageico")
                    CSResourceMgr.setSpriteTextureByNode(stageico, PetEducationMgr.getRareIcon(msInfo.classType))
                    local gico = CSResourceMgr.seekNodeByName(parent, "gico")
                    gico:setLocalZOrder(2)
                    local eico = CSResourceMgr.seekNodeByName(parent, "eico")
                    eico:setLocalZOrder(2)
                    local aico = CSResourceMgr.seekNodeByName(parent, "aico")
                    CSResourceMgr.setSpriteTextureByNode(aico, 
                        ItemInfo.getItemInfoById(awardElementsString[msInfo.awardElements[awardIndex+1]]).icon)
                    aico:setLocalZOrder(2)
                    local gicodb = CSResourceMgr.seekNodeByName(parent, "gicodb")
                    gicodb:setLocalZOrder(1)
                    local eicodb = CSResourceMgr.seekNodeByName(parent, "eicodb")
                    eicodb:setLocalZOrder(1)
                    local aicodb = CSResourceMgr.seekNodeByName(parent, "aicodb")
                    aicodb:setLocalZOrder(1)
                    local arrow1 = CSResourceMgr.seekNodeByName(parent, "goldup")
                    arrow1:setLocalZOrder(1)
                    local arrow2 = CSResourceMgr.seekNodeByName(parent, "expup")
                    arrow2:setLocalZOrder(1)
                    local gold = CSResourceMgr.seekNodeByName(parent, "gold")
                    local exp = CSResourceMgr.seekNodeByName(parent, "exp")
                    local maxWidth = 100
                    if skillUpInfo then
                        CSResourceMgr.setLabelColorByNode(exp, {r=147,g=254,b=6,a=255})
                        CSResourceMgr.setLabelColorByNode(gold, {r=147,g=254,b=6,a=255})
                        maxWidth = 80
                        arrow1:setVisible(true)
                        arrow2:setVisible(true)
                    end
                    CSResourceMgr.setLabelStringByNode(exp, msInfo.familyCoin + (skillUpInfo ~= nil and skillUpInfo.params[1] or 0),
                        {r=0,g=0,b=0,a=255,w=1,s=1}, nil, maxWidth)
                    exp:setLocalZOrder(2)
                    eicodb:setColor({r=81,g=112,b=137})
                    CSResourceMgr.setLabelStringByNode(gold, msInfo.devotePoint + (skillUpInfo ~= nil and skillUpInfo.params[1] or 0),
                        {r=0,g=0,b=0,a=255,w=1,s=1}, nil, maxWidth)
                    gold:setLocalZOrder(2)
                    gicodb:setColor({r=81,g=112,b=137})
                    local award = CSResourceMgr.seekNodeByName(parent, "award")
                    CSResourceMgr.setLabelStringByNode(award, msInfo.awardElementNums[awardIndex+1], {r=0,g=0,b=0,a=255,w=1,s=1}, 
                        nil, 100)
                    award:setLocalZOrder(2)
                    aicodb:setColor({r=81,g=112,b=137})
                    CSResourceMgr.seekNodeByName(parent, "mstitledb"):setColor({r=81,g=112,b=137})
                    local dbline = CSResourceMgr.seekNodeByName(parent, "dbline")
                    dbline:setColor({r=128,g=161,b=172})
                    dbline:setOpacity(128)
                    local timedb = CSResourceMgr.seekNodeByName(parent, "timedb")
                    timedb:setColor({r=0,g=0,b=0})
                    timedb:setOpacity(128)
                    local mstitle = CSResourceMgr.seekNodeByName(parent, "mstitle")
                    CSResourceMgr.setLabelColorByNode(mstitle, {r=255,g=240,b=0,a=255})
                    CSResourceMgr.setLabelStringByNode(mstitle, msInfo.name, {r=17,g=27,b=38,a=255,w=1,s=1}, nil, 290)
                    local desc = CSResourceMgr.seekNodeByName(parent, "desc")
                    CSResourceMgr.setLabelColorByNode(desc, {r=71,g=96,b=103,a=255})
                    CSResourceMgr.setLabelStringByNode(desc, msInfo.desc)
                    CSResourceMgr.setLabelMaxWidthByNode(desc, 400)
                    local ptitle = CSResourceMgr.seekNodeByName(parent, "ptitle")
                    CSResourceMgr.setLabelColorByNode(ptitle, {r=166,g=243,b=255,a=255})
                    CSResourceMgr.setLabelStringByNode(ptitle, "mission4", {r=12,g=27,b=38,a=255,w=1,s=1}, nil, 90)
                    local mType = msInfo.familyQuestType
                    local curProcess = 0
                    local needProcess = 1
                    if mType==Proto.FQT_ARREST or mType==Proto.FQT_PATROL or mType==Proto.FQT_MONSTER then
                        curProcess = CharInfo.getFamilyQuestOK() or 0
                        needProcess = 1
                    elseif mType==Proto.FQT_SEARCH then
                        curProcess = ItemInfo.getCharItemNum(msInfo.params[1])
                        needProcess = msInfo.params[2]
                    end
                    missionFCellNodes[msID].curProcess = curProcess
                    missionFCellNodes[msID].needProcess = needProcess
                    missionFCellNodes[msID].type = mType
                    local process = CSResourceMgr.seekNodeByName(parent, "process")
                    CSResourceMgr.setLabelStringByNode(process, curProcess.."/"..needProcess, 
                        {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 70)
                    local pbar = CSResourceMgr.seekNodeByName(parent, "pbar")
                    pbar:setPercent(curProcess*100/needProcess)
                    local clain = CSResourceMgr.seekNodeByName(parent, "clain")
                    CSResourceMgr.setButtonStringColorByNode(clain, {r=248,g=255,b=238,a=255})
                    CSResourceMgr.clickEventBindingByNode(clain, function(sender)
                        local function finish()
                            gicodb:setVisible(false)
                            eicodb:setVisible(false)
                            aicodb:setVisible(false)
                            arrow1:setVisible(false)
                            arrow2:setVisible(false)
                            transition.moveTo(gico, {x=167, y=62, time=0.1})
                            transition.moveTo(eico, {x=272, y=60, time=0.1})
                            transition.moveTo(aico, {x=377, y=60, time=0.1})
                            transition.moveTo(gold, {x=220, y=60, time=0.1})
                            transition.moveTo(exp, {x=325, y=60, time=0.1})
                            transition.moveTo(award, {x=430, y=60, time=0.1})
                            parent:performWithDelay(function()
                                transition.moveBy(gico, {y=50, time=0.8})
                                transition.moveBy(eico, {y=50, time=0.8})
                                transition.moveBy(aico, {y=50, time=0.8})
                                transition.moveBy(gold, {y=50, time=0.8})
                                transition.moveBy(exp, {y=50, time=0.8})
                                transition.moveBy(award, {y=50, time=0.8})
                                transition.fadeOut(gico, {time=0.8})
                                transition.fadeOut(eico, {time=0.8})
                                transition.fadeOut(aico, {time=0.8})
                                transition.fadeOut(gold, {time=0.8})
                                transition.fadeOut(exp, {time=0.8})
                                transition.fadeOut(award, {time=0.8})
                                parent:performWithDelay(function()
                                    transition.moveBy(parent, {x=600, time=0.2})
                                    parent:performWithDelay(function()
                                        for k, v in pairs(missionDatas) do
                                            if v==msID then
                                                missionFCellNodes[msID] = nil
                                                list:removeItem(k-1)
                                                table.remove(missionDatas, k)
                                                break
                                            end
                                        end
                                    end, 0.2)
                                end, 0.8)
                            end, 0.1)
                            CSResourceMgr.getNodeByName(resName, "tabred3"):setVisible(false)
                        end
                        FamilyInfo.CommitFamilyQuest(finish)
                    end, nil, "reward")
                    if curProcess>=needProcess then
                        CSResourceMgr.setButtonEnabledByNode(clain, true)
                        CSResourceMgr.setButtonStringByNode(clain, "mission12", {r=36,g=98,b=5,a=255,w=1,s=1})
                    else
                        CSResourceMgr.setButtonEnabledByNode(clain, false)
                        CSResourceMgr.setButtonStringByNode(clain, "mission11", {r=0,g=0,b=0,a=255,w=1,s=1})
                    end
                    MissionListMgr.refreshServerTime()
                    parent:setCascadeOpacityEnabled(true)
                end)
                table.insert(funcTable, function()
                    if missionFCellNodes[msID] then
                        missionFCellNodes[msID]:setVisible(true)
                        missionFCellNodes[msID]:setScaleY(0)
                        transition.scaleTo(missionFCellNodes[msID], {scale=1, time=0.1})
                    end
                end)
            end
            for k=1, #missionDatas do
                if QuestInfo.getFamilyQuestInfoById(missionDatas[k]) then
                    initMs(funcTable, missionDatas[k])
                end
            end
            UnblockLoader.load(funcTable, "MissionListMgr.setTabC")
        end
    end
end

function MissionListMgr.hide()
    if not CSResourceMgr.getCsbObj(resName) then
    	return
    end
    if DropInfoViewMgr.isShown() then
    	DropInfoViewMgr.hide()
    	return
    end
    StatusBarMgr.hideTopInfoBar()
    MissionListMgr.checkRedPoint()
    refreshAPFunc = nil
    addNewMissionFunc = nil
    missionCellNodes = {}
    missionDCellNodes = {}
    missionFCellNodes = {}
    missionVec = {}
    UnblockLoader.cancel("MissionListMgr.setTabA")
    UnblockLoader.cancel("MissionListMgr.setTabB")
    UnblockLoader.cancel("MissionListMgr.setTabC")
    UnblockLoader.cancel("MissionListMgr.show")
    for var=1, #apVec do
        AnimationMgr.removeGafObjectByTag(resNameAni, "MissionListMgr"..var)
    end
    CSResourceMgr.removeList(resNameA, "list")
    CSResourceMgr.removeList(resNameB, "list")
    CSResourceMgr.removeList(resNameC, "list")
    CSResourceMgr.removeCSObjectByTag(resNameA)
    CSResourceMgr.removeCSObjectByTag(resNameB)
    CSResourceMgr.removeCSObjectByTag(resNameC)
    CSResourceMgr.removeCSObjectByTag(resName)
    CSResourceMgr.removeCSObjectByTag(resNameBG, "MissionListMgr")
    GameAudio.playUISound("retract")
    UIStack.pop("MissionListMgr")
end

function MissionListMgr.refreshAP()
    if refreshAPFunc then
		refreshAPFunc()
	end
end

function MissionListMgr.refreshServerTime()
    if device.platform == "ios" or device.platform == "windows" then  -- ios版，检查评论时间
        if QuestInfo.commentBeginTime then
            local pass = CharInfo.getServerTime() - QuestInfo.commentBeginTime
            print(QuestInfo.commentBeginTime, pass)
            if pass >= 10 then
                QuestInfo.sendQuestUpdate(QuestInfo.IOSCommemtQuestID, 1)
            end
            QuestInfo.commentBeginTime = nil
        end
        local cBeginTime = UserSettings.get("commentBeginTime", 15)
        if cBeginTime and cBeginTime ~= 0 then
            UserSettings.set({commentBeginTime = 0}, 15)
        end
    end

    for key, var in pairs(missionFCellNodes) do
        local parent = var
        local timeSec = CharInfo.getFamilyQuestFailedTime()-CharInfo.getServerTime()
        if var.type==Proto.FQT_SEARCH or var.curProcess<var.needProcess then
            if timeSec>0 then
                local timetitle = CSResourceMgr.seekNodeByName(parent, "timetitle")
                CSResourceMgr.setLabelColorByNode(timetitle, {r=166,g=243,b=255,a=255})
                CSResourceMgr.setLabelStringByNode(timetitle, "mission10", {r=12,g=27,b=38,a=255,w=1,s=1}, nil, 90)
                local time = CSResourceMgr.seekNodeByName(parent, "time")
                CSResourceMgr.setLabelStringByNode(time, "00:00:00", {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 125)
                CocosModuleMgr.setTimeLabelCountDown(time, timeSec, function()
                    missionFCellNodes = {}
                    CSResourceMgr.removeList(resNameC, "list")
                end)
            else
                missionFCellNodes = {}
                CSResourceMgr.removeList(resNameC, "list")
            end
        end
	end
end

function MissionListMgr.refreshLevel()
    if missionDCellNodes.lockButton then
        for key, var in pairs(missionDCellNodes.lockButton) do
            local levelLock = dailyMissionLock[key]
            if levelLock then
                if levelLock<=CharInfo.getLevel() then
                    CSResourceMgr.setButtonStringByNode(var, "mission5", {r=100,g=74,b=2,a=255,w=1,s=1})
                    CSResourceMgr.setButtonEnabledByNode(var, true)
                    missionDCellNodes.lockButton[key] = nil
                end
            end
		end
	end
end

function MissionListMgr.addNewMission(vec)
	if addNewMissionFunc then
        local funcTable = {}
        for key, var in pairs(vec) do
            if QuestInfo.getNewQuestInfoById(var.questID).needVisable==1 then
                print("MissionListMgr addNewMission", var.questID)
                addNewMissionFunc(funcTable, var)
            end
        end
        UnblockLoader.load(funcTable, "MissionListMgr.setTabA")
	end
    MissionListMgr.checkRedPoint()
end

function MissionListMgr.updateMission(param)
    print("MissionListMgr updateMission", param.questID)
    local msInfo = QuestInfo.getNewQuestInfoById(param.questID)
    if msInfo.needVisable==0 then
        return
    end
    if msInfo.type~=Proto.QUEST_TYPE_EVERYDAY then
        if addNewMissionFunc and CSResourceMgr.getCsbObj(resNameA) then
            print("updateMission complete", param.questID)
            local curProcess = param.progressList[1] or 0
            local needProcess = msInfo.objectiveList[1].amount
            local funcTable = {}
            if curProcess>=needProcess then
                table.insert(funcTable, function()
                    for k, v in pairs(missionVec) do
                        if v==param.questID then
                            CSResourceMgr.getNodeByName(resNameA, "list"):removeItem(k-1)
                            table.remove(missionVec, k)
                            break
                        end
                    end
                end)
                addNewMissionFunc(funcTable, param, 1)
                CSResourceMgr.getNodeByName(resName, "tabred1"):setVisible(true)
            else
                table.insert(funcTable, function()
                    local parent = missionCellNodes[param.questID]
                    if parent then
                        local process = CSResourceMgr.seekNodeByName(parent, "process")
                        CSResourceMgr.setLabelStringByNode(process, curProcess.."/"..needProcess, {r=0,g=0,b=0,a=200}, nil, 70)
                        local clain = CSResourceMgr.seekNodeByName(parent, "clain")
                        local guide = CSResourceMgr.seekNodeByName(parent, "guide")
                        clain:setVisible(false)
                        guide:setVisible(true)
                    end
                end)
            end
            UnblockLoader.load(funcTable, "MissionListMgr.setTabA")
        end
    end
    MissionListMgr.checkRedPoint()
end

function MissionListMgr.checkRedPoint()
    local flag = checkRedPointFuncVec[3]()
	if not flag then
        flag = checkRedPointFuncVec[1]()
	end
    if not flag then
        flag = checkRedPointFuncVec[2]()
    end
    if flag then
        hasRedPoint = true
        StatusBarMgr.addRedPoint(1)
    else
        if hasRedPoint then
            hasRedPoint = false
            StatusBarMgr.hideRedPoint(1)
        end
    end
end

function MissionListMgr.getMissionItemNodeByID(questID)
    return missionCellNodes[questID]
end

function MissionListMgr.checkSkill(name)
    if not name then
        CSResourceMgr.getNodeByName(resName, "skill"):setVisible(false)
    	return
    end
    local skillUpInfo, num = AchievementListMgr.getSkillUpInfo(name)
    if skillUpInfo then
        CSResourceMgr.getNodeByName(resName, "skill"):setVisible(true)
        local icon = CSResourceMgr.getNodeByName(resName, "skillicon")
        local iconRes = "Battle/skillIcon/"..skillUpInfo.icon
        icon:setScale(0.5)
        CSResourceMgr.setSpriteTextureByNode(icon, iconRes)
        CSResourceMgr.clickEventBinding(resName, "skill", function()
            AchievementListMgr.showSkillInfo(skillUpInfo, false, false, nil)
        end, nil, 3)
        local skillLv = CSResourceMgr.getNodeByName(resName, "skilllevel")
        CSResourceMgr.setLabelColorByNode(skillLv, {r=255,g=255,b=255,a=255})
        CSResourceMgr.setLabelStringByNode(skillLv, "Lv"..num, {r=0,g=0,b=0,a=255})
    else
        CSResourceMgr.getNodeByName(resName, "skill"):setVisible(false)
    end
end

return MissionListMgr