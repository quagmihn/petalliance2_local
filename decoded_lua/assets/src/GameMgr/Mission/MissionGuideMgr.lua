local MissionGuideMgr = {}

local resName = ""
local isShown = false
local isLoaded = false
local curScene = nil
local questInfo = {}

function MissionGuideMgr.Init()
    --[[    
    resName = "UI/Mission/MissionOutLayer.csb"
    isShown = true
    isLoaded = false
    curScene = nil]]
end

function MissionGuideMgr.guide(questID)
    local qInfo = QuestInfo.getNewQuestInfoById(questID)
end

function MissionGuideMgr.finish(type, param)
	local curQuestIDs = QuestInfo.getCurQuestIDs()
    for var=1, #curQuestIDs do
        local qID = curQuestIDs[var]
        local qInfo = QuestInfo.getNewQuestInfoById(qID)
        
	end
end

function MissionGuideMgr.addUI(scene)
    isLoaded = false
    curScene = scene

    if not SystemOptionsMgr.getOption(3) then
        print("玩家设置不打开任务提示")
        return false
    end

    local mTbl = QuestInfo.getCurQuestIDs()
    
    if #mTbl==0 then
        print("当前没有任务，不创建任务引导UI")
    	return false
    end
    
    local curLayer = CSResourceMgr.createRes(scene, resName)
    curLayer:setLocalZOrder(9)
    CocosModuleMgr.setRelativePosition(curLayer, 320, 480)
    CocosModuleMgr.setEdgeDistance(curLayer, nil, 0, nil, nil, true, 0.2)
    
    CSResourceMgr.clickEventBinding(resName, "ctrl", function()
    	if isShown then
            MissionGuideMgr.hide()
    	else
            MissionGuideMgr.show()
    	end
    end, "", true)
    
    MissionGuideMgr.reset()
    
    if isShown then
        MissionGuideMgr.show()
    end
    isLoaded = true
end

function MissionGuideMgr.refresh()
    if not isLoaded then
        if curScene~=nil then
            MissionGuideMgr.addUI(curScene)
        end
    else
        MissionGuideMgr.reset()
    end
end

function MissionGuideMgr.reset()
    CSResourceMgr.getNodeByName(resName, {"list"}):removeAllItems()
    
    local mTbl = QuestInfo.getCurQuestInfos()
    if #mTbl==0 then
        print("当前没有任务，不创建任务引导UI")
        MissionGuideMgr.remove()
        return false
    end
    
    for key, var in pairs(mTbl) do
        local color = {r=255, g=255, b=255, a=255}
        if var.type == Proto.QUEST_TYPE_MAIN then
            color = {r=255, g=240, b=0, a=255}
        elseif var.type == Proto.QUEST_TYPE_SUB then
            color = {r=0, g=222, b=255, a=255}
        elseif var.type == Proto.QUEST_TYPE_EVERYDAY then
            color = {r=18, g=255, b=0, a=255}
        end
        CSResourceMgr.setLabelString(resName, {"example", "title"}, var.name, "", CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
        CSResourceMgr.setLabelString(resName, {"example", "desc"}, var.desc, "", CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
        CSResourceMgr.clickEventBinding(resName, "example", function()
            MapSeekerMgr.autoSeekPath(var.map, var.button, function()
                CSResourceMgr.callButtonFunc(TownMapMgr.MapRes, var.button)
            end)
        end)
        local item = CSResourceMgr.getNodeByName(resName, "example"):clone()
        CSResourceMgr.seekNodeByName(item, "title"):setTextColor(color)
        item:setVisible(true)
        CSResourceMgr.getNodeByName(resName, {"list"}):pushBackCustomItem(item)
        if var.strongType=="1" then
            --CocosModuleMgr.setButtonGuide(item)
        end
    end
end

function MissionGuideMgr.remove()
    if isShown then
        CSResourceMgr.playActionWithCallback(resName, 30, 40, 1, function()
            CSResourceMgr.getNodeByName(resName, {"list"}):removeAllItems()
            CSResourceMgr.removeCSObjectByTag(resName)
        end)
    else
        CSResourceMgr.getNodeByName(resName, {"list"}):removeAllItems()
        CSResourceMgr.removeCSObjectByTag(resName)
    end
end

function MissionGuideMgr.show()
    isShown = true
    CSResourceMgr.playAction(resName, 0, 10, false)
end

function MissionGuideMgr.hide()
    isShown = false
    CSResourceMgr.playAction(resName, 30, 40, false)
end

return MissionGuideMgr