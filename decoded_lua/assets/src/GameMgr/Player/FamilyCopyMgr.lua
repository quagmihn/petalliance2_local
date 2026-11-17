local FamilyCopyMgr = {}
 
local resName = ""
local currentAwardFloor = 1

function FamilyCopyMgr.Init()
    resName = "Player/Family/FamilyCopy.csb"
    currentAwardFloor = 1
end

function FamilyCopyMgr.hideUI()
    CSResourceMgr.removeCSObjectByTag(resName)
    UIStack.pop("FamilyCopyMgr")
end

local function enterCopy()
    SceneMgr.replaceScene(SceneMgr.getRunningScene, "FamilyCopyMapScene")
end

local function getAward()
    FamilyCopyMgr.hideUI()
    FamilyInfo.GetFamilyAward()
end

function FamilyCopyMgr.adjustStepInfo()
    local totalStepNum = SystemInfo.getGlobalConfigAddInfoByID(56).values[1]
    local refreshStepInterval = SystemInfo.getGlobalConfigAddInfoByID(57).values[1]
    if CharInfo.getFamilyDungeonStepNumber() >= totalStepNum then
        CharInfo.setFamilyDungeonStepNumberUpdateTime(CharInfo.getServerTime())
    else
        local adjustStepTimes = math.floor((CharInfo.getServerTime() - CharInfo.getFamilyDungeonStepNumberUpdateTime())/refreshStepInterval)
        if adjustStepTimes > 0 then
            CharInfo.setFamilyDungeonStepNumber(CharInfo.getFamilyDungeonStepNumber() + adjustStepTimes >= totalStepNum and totalStepNum or CharInfo.getFamilyDungeonStepNumber() + adjustStepTimes)
            CharInfo.setFamilyDungeonStepNumberUpdateTime(CharInfo.getFamilyDungeonStepNumberUpdateTime() + adjustStepTimes * refreshStepInterval)
        end
    end
end

local function initStaticData()
    CSResourceMgr.setLabelString(resName, "txt_title", LuaSqlite.getLanguageByKey("chat4")..LuaSqlite.getLanguageByKey("iteminfo18"), nil, {r=0,g=0,b=0,a=255,w=2})
    CSResourceMgr.setLabelString(resName, "txt_get", "family100", nil, {r=255,g=0,b=0,a=255,w=2})
    CSResourceMgr.setLabelString(resName, "txt_bg1", "family97")
    CSResourceMgr.setButtonString(resName, "btn_view", "family99", nil, {r=0,g=0,b=0,a=255,w=1})
    CSResourceMgr.setLabelString(resName, "txt_event", "family92", nil, {r=0,g=0,b=0,a=255,w=2})
    CSResourceMgr.setButtonString(resName, "btn_enter", "family98", nil, {r=0,g=0,b=0,a=255,w=1})
    
    FamilyCopyMgr.adjustStepInfo()
    local totalStepNum = SystemInfo.getGlobalConfigAddInfoByID(56).values[1]
    CSResourceMgr.setLabelString(resName, "txt_bg2", CocosModuleMgr.createStringWithFormat({"family96", CharInfo.getFamilyDungeonStepNumber(), totalStepNum}))
end

function FamilyCopyMgr.incCurrentStepNum()
    local totalStepNum = SystemInfo.getGlobalConfigAddInfoByID(56).values[1]
    local currentStepNum = CharInfo.getFamilyDungeonStepNumber()
    if currentStepNum >= totalStepNum then
        CharInfo.setFamilyDungeonStepNumberUpdateTime(CharInfo.getServerTime())
    else
        CharInfo.setFamilyDungeonStepNumber(currentStepNum + 1)
        CharInfo.setFamilyDungeonStepNumberUpdateTime(CharInfo.getServerTime())
    end
end

function FamilyCopyMgr.decCurrentStepNum()
    local totalStepNum = SystemInfo.getGlobalConfigAddInfoByID(56).values[1]
    local currentStepNum = CharInfo.getFamilyDungeonStepNumber()
    if currentStepNum >= totalStepNum then
        CharInfo.setFamilyDungeonStepNumber(currentStepNum - 1)
        CharInfo.setFamilyDungeonStepNumberUpdateTime(CharInfo.getServerTime())
    elseif currentStepNum > 0 then
        CharInfo.setFamilyDungeonStepNumber(currentStepNum - 1)
    end
end

function FamilyCopyMgr.setAwardInfo(awardFloor, enableAward)
    if CSResourceMgr.getCsbObj(resName) then
        currentAwardFloor = awardFloor or 1
        CSResourceMgr.setLabelString(resName, "name", CocosModuleMgr.createStringWithFormat({"family95", currentAwardFloor}), nil, {r=0,g=0,b=0,a=255,w=1})
        CSResourceMgr.getNodeByName(resName, "btn_view"):setVisible(currentAwardFloor < FamilyDataInfo.getFamilyAwardInfoTotal() and true or false)
        CSResourceMgr.getNodeByName(resName, "btn_get"):setVisible(enableAward > 0 and true or false)
        
        local familyAwardInfo = FamilyDataInfo.getFamilyAwardInfoById(currentAwardFloor)
        for i=1, #familyAwardInfo.awardElements do
            local id = familyAwardInfo.awardElements[i]
            local count = familyAwardInfo.awardCounts[i]
            local awardElementInfo = ItemInfo.getAwardElementInfoById(id)
            local itemInfo = ItemInfo.getItemInfoById(awardElementInfo.elementID)
            local icdb = CSResourceMgr.getNodeByName(resName, "icdb"..i)
            local icon = CSResourceMgr.seekNodeByName(icdb, "icon")
            local num = CSResourceMgr.seekNodeByName(icdb, "num")
            CSResourceMgr.setSpriteTextureByNode(icon, itemInfo.icon)
            CSResourceMgr.setLabelStringByNode(num, count, {r=0,g=0,b=0,a=255,w=1})
            icdb:setVisible(true)
        end
    end
end

function FamilyCopyMgr.show(scene)
    if CSResourceMgr.getCsbObj(resName) then
        return  
    end
    UIStack.push("FamilyCopyMgr",FamilyCopyMgr.hideUI,false)
    local function loadCSB()
        local curLayer = CSResourceMgr.createRes(scene, resName)
        curLayer:setLocalZOrder(CocosModuleMgr.ZORDER_FLOAT)
        CSResourceMgr.setRelativePosition(resName, 320, 480)
        CSResourceMgr.getNodeByName(resName, "db"):setVisible(false)
        
        CSResourceMgr.clickEventBinding(resName, "bg", function()
            FamilyCopyMgr.hideUI()
        end)
        
        CSResourceMgr.clickEventBinding(resName, "close", function()
            FamilyCopyMgr.hideUI()
        end)
        
        CSResourceMgr.clickEventBinding(resName, "btn_view", function()
            FamilyCopyBonusMgr.show(scene, currentAwardFloor + 1)
        end)
        
        CSResourceMgr.clickEventBinding(resName, "btn_event", function()
            FamilyCopyEventMgr.show(scene)
        end)
        
        CSResourceMgr.clickEventBinding(resName, "btn_get", function()
            getAward()
        end)
        
        CSResourceMgr.clickEventBinding(resName, "btn_enter", function()
            enterCopy()
        end)
        
        initStaticData()
    end
    
    local function playCSB()
        local node = CSResourceMgr.getNodeByName(resName, "db")
        if node ~= nil then
            node:setVisible(true)
            CocosModuleMgr.showUIAnimation(node, "down")
        end
    end
    
    loadCSB()
    playCSB()
    
    FamilyInfo.GetFamilyAwardInfo()
end
 
return FamilyCopyMgr