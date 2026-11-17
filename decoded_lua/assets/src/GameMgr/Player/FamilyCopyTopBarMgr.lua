local FamilyCopyTopBarMgr = {}

local resName = ""

function FamilyCopyTopBarMgr.Init()
    resName = "Player/Family/FamilyCopyTopBar.csb"
end

local function updateStepNum()
    local totalStepNum = SystemInfo.getGlobalConfigAddInfoByID(56).values[1]
    CSResourceMgr.setLabelString(resName, "step_num", CharInfo.getFamilyDungeonStepNumber().."/"..totalStepNum, nil, {r=70,g=61,b=48,a=255,w=1})
end

local function triggerCountDown()
    FamilyCopyMgr.incCurrentStepNum()
    updateStepNum()
    local totalStepNum = SystemInfo.getGlobalConfigAddInfoByID(56).values[1]
    if CharInfo.getFamilyDungeonStepNumber() < totalStepNum then
        local refreshStepInterval = SystemInfo.getGlobalConfigAddInfoByID(57).values[1]
        local cd = CSResourceMgr.getNodeByName(resName, "refresh_time")
        CocosModuleMgr.setTimeLabelCountDown(cd, refreshStepInterval, function()
            triggerCountDown()
        end)
        CSResourceMgr.getNodeByName(resName, "step_refresh"):setVisible(true)
        cd:setVisible(true)
        CSResourceMgr.getNodeByName(resName, "step_max"):setVisible(false)
     else
        CSResourceMgr.getNodeByName(resName, "step_refresh"):setVisible(false)
        CSResourceMgr.getNodeByName(resName, "refresh_time"):setVisible(false)
        CSResourceMgr.getNodeByName(resName, "step_max"):setVisible(true)
     end
end

function FamilyCopyTopBarMgr.decCurrentStepNum()
    FamilyCopyMgr.decCurrentStepNum()
    updateStepNum()
    if CSResourceMgr.getNodeByName(resName, "step_max"):isVisible() == true then
        local refreshStepInterval = SystemInfo.getGlobalConfigAddInfoByID(57).values[1]
        local time = refreshStepInterval - (CharInfo.getServerTime() - CharInfo.getFamilyDungeonStepNumberUpdateTime())% refreshStepInterval
        local cd = CSResourceMgr.getNodeByName(resName, "refresh_time")
        CocosModuleMgr.setTimeLabelCountDown(cd, time, function()
            triggerCountDown()
        end)
        CSResourceMgr.getNodeByName(resName, "step_refresh"):setVisible(true)
        cd:setVisible(true)
        CSResourceMgr.getNodeByName(resName, "step_max"):setVisible(false)
    end
end

function FamilyCopyTopBarMgr.updateDevote()
    if CSResourceMgr.getCsbObj(resName) then
        local devote = CSResourceMgr.getNodeByName(resName, "devote_num")
        local info =  FamilyInfo.GetLocalFamilyMembersInfo()
        if CharInfo.getFamilyID() ~= nil and info ~= nil then
            CSResourceMgr.setLabelStringByNode(devote, info[tostring(CharInfo.getCharID())].devotePoint or 0, {r=0,g=0,b=0,a=255,w=1})
        else
            CSResourceMgr.setLabelStringByNode(devote, 0, {r=0,g=0,b=0,a=255,w=1})
        end
    end
end

local function initStaticData()
    CSResourceMgr.getNodeByName(resName,"buff_list"):setScale(0.0, 0.0)
    CSResourceMgr.setLabelString(resName, "floor_txt", LuaSqlite.getLanguageByKey("LtText1").."：", nil, {r=0,g=0,b=0,a=255,w=1})
    CSResourceMgr.setLabelString(resName, "buff_txt", "LtText3", nil, {r=0,g=0,b=0,a=255,w=1})
    CSResourceMgr.setLabelString(resName, "step_txt", LuaSqlite.getLanguageByKey("LtText4").."：")
    CSResourceMgr.setLabelString(resName, "step_max", "LtText6")
    CSResourceMgr.setLabelString(resName, "step_refresh", LuaSqlite.getLanguageByKey("LtText5").."：")
    CSResourceMgr.setLabelString(resName, "event_txt", "family92", nil, {r=0,g=0,b=0,a=255,w=1})
    FamilyCopyTopBarMgr.updateDevote()
    
    FamilyCopyMgr.adjustStepInfo()
    updateStepNum()
    local totalStepNum = SystemInfo.getGlobalConfigAddInfoByID(56).values[1]
    if CharInfo.getFamilyDungeonStepNumber() < totalStepNum then
        local refreshStepInterval = SystemInfo.getGlobalConfigAddInfoByID(57).values[1]
        local time = refreshStepInterval - (CharInfo.getServerTime() - CharInfo.getFamilyDungeonStepNumberUpdateTime())% refreshStepInterval
        local cd = CSResourceMgr.getNodeByName(resName, "refresh_time")
        CocosModuleMgr.setTimeLabelCountDown(cd, time, function()
            triggerCountDown()
        end)
        CSResourceMgr.getNodeByName(resName, "step_refresh"):setVisible(true)
        cd:setVisible(true)
        CSResourceMgr.getNodeByName(resName, "step_max"):setVisible(false)
    else
        CSResourceMgr.getNodeByName(resName, "step_refresh"):setVisible(false)
        CSResourceMgr.getNodeByName(resName, "refresh_time"):setVisible(false)
        CSResourceMgr.getNodeByName(resName, "step_max"):setVisible(true)
    end
end

local function initDynamicData()
end

local function hideUI()
    FamilyCopyMapMgr.cleanLocalCopyMapInfo()
    CSResourceMgr.removeCSObjectByTag(resName)
    FamilyInfo.GoHome()
end

local function toggleBuffPanel()
    local panel = CSResourceMgr.getNodeByName(resName,"buff_list")
    if panel:getScaleX() < 1.0 then
        transition.scaleTo(panel,{scaleX=1.0,scaleY=1.0,time=0.1})
    else
        transition.scaleTo(panel,{scaleX=0.0,scaleY=0.0,time=0.1})
    end
end

function FamilyCopyTopBarMgr.refreshBuffInfo(buffInfo)
    for k, v in pairs(buffInfo) do
        local node = CSResourceMgr.getNodeByName(resName, "buff_"..k)
        local num = CSResourceMgr.seekNodeByName(node,"num")
        CSResourceMgr.setLabelStringByNode(num, v, {r=0,g=0,b=0,a=255,w=1})
    end
end

function FamilyCopyTopBarMgr.setCurrentFloor(floor)
    if CSResourceMgr.getCsbObj(resName) then
        CSResourceMgr.setLabelString(resName, "floor_num", floor, nil, {r=0,g=0,b=0,a=255,w=1})
    end
end

function FamilyCopyTopBarMgr.show(scene)
    if CSResourceMgr.getCsbObj(resName) then
        return  
    end
    
    local function loadCSB()
        local curLayer = CSResourceMgr.createRes(scene, resName)
        CSResourceMgr.setFullScreen(resName)
        CocosModuleMgr.setEdgeDistance(curLayer, nil, nil, 0, nil, false)
        curLayer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)

        CSResourceMgr.clickEventBinding(resName, "close", function()
            hideUI()
        end)
        
        CSResourceMgr.clickEventBinding(resName, "buff_info", function()
            toggleBuffPanel()
        end)
        
        CSResourceMgr.clickEventBinding(resName, "event", function()
            FamilyCopyEventMgr.show(scene)
        end)
        
        initStaticData()

        initDynamicData()
    end
    
    loadCSB()
end

return FamilyCopyTopBarMgr