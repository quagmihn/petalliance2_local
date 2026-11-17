local FurnitureSofaMgr = {}

local resName = ""
local refreshTimes = 0
local maxTimes = 1

function FurnitureSofaMgr.Init()
    resName = "Item/Bag/FurnitureSofa.csb"
    refreshTimes = 0
    maxTimes = 1
end

function FurnitureSofaMgr.hideUI()
    UnblockLoader.cancel("FurnitureSofaMgr")
    CSResourceMgr.removeCSObjectByTag(resName)
    UIStack.pop("FurnitureSofaMgr")
end

local function confirm()
    FamilyInfo.GetFamilyDevoteBuffer()
end

function FurnitureSofaMgr.setRefreshTimes(times)
    --[[
    if times ~= nil then
        refreshTimes = times
        if CSResourceMgr.getCsbObj(resName) then
            CSResourceMgr.setLabelString(resName, "txt_refresh", CocosModuleMgr.createStringWithFormat({"home006", refreshTimes, maxTimes}))
            CSResourceMgr.setButtonEnabled(resName, "btn_verify", refreshTimes < maxTimes)
        end
    end
    ]]
end

function FurnitureSofaMgr.show(scene, id)
    if CSResourceMgr.getCsbObj(resName) then
        return  
    end
    UIStack.push("FurnitureSofaMgr",FurnitureSofaMgr.hideUI,false)
    local function loadCSB()
        local curLayer = CSResourceMgr.createRes(scene, resName)
        curLayer:setLocalZOrder(CocosModuleMgr.ZORDER_FLOAT)
        CSResourceMgr.setRelativePosition(resName, 320, 480)
        CSResourceMgr.getNodeByName(resName, "db"):setVisible(false)
        
        CSResourceMgr.clickEventBinding(resName, "bg", function()
            FurnitureSofaMgr.hideUI()
        end)
        
        CSResourceMgr.clickEventBinding(resName, "close", function()
            FurnitureSofaMgr.hideUI()
        end)
        
        CSResourceMgr.clickEventBinding(resName, "btn_ok", function()
            FurnitureSofaMgr.hideUI()
            confirm()
        end)
        
        local itemData = ItemInfo.getItemInfoById(id) 
        if itemData ~= nil then
            maxTimes = itemData.paramB
        end
        CSResourceMgr.setLabelString(resName, "txt_title", itemData ~= nil and itemData.name or "itemname37010", nil, {r=0,g=0,b=0,a=255,w=1})
        CSResourceMgr.setButtonString(resName, "btn_ok", "tips3", nil, {r=0,g=0,b=0,a=255,w=1})
        local attr = CSResourceMgr.getNodeByName(resName, "txt_attr")
        CSResourceMgr.setLabelMaxWidthByNode(attr, 320)
        if not CharInfo.getFamilyID() then
            attr:setString(LuaSqlite.getLanguageByKey("home017"))
        else
            attr:setString(LuaSqlite.getLanguageByKey("home011"))
        end
        local familyDevoteBufferTime = tonumber(CharInfo.getFamilyDevoteBufferTime() or 0)
        refreshTimes = (CocosModuleMgr.getDayTimeDiff(familyDevoteBufferTime, CharInfo.getServerTime(), 6 * 3600) == 0 and 0 or 1)
        CSResourceMgr.setLabelString(resName, "txt_remain", CocosModuleMgr.createStringWithFormat({"home010", refreshTimes, maxTimes}), nil, {r =0,g=0,b=0,a=255,w=1})
        CSResourceMgr.setButtonEnabled(resName, "btn_ok", (refreshTimes >= maxTimes and CharInfo.getFamilyID() ~= nil) and true or false)
        
        local rank, total = HomeInfo.getCharFamilyRankByID(CharInfo.getCharID())
        --local percent = FamilyDataInfo.getFamilyDevoteBufferInfoById(total - rank + 1).bufferRate/100
        local familyLevel = 1
        local info = FamilyInfo.GetLocalFamilyInfo()
        if info ~= nil then
            familyLevel = (info.familyLevel or 1)
        end
        local percent = FamilyDataInfo.getFamilyDevoteBufferInfoById(familyLevel).bufferRate/100
        local fightlabel = CSResourceMgr.getNodeByName(resName,"num_attr")
        fightlabel:setVisible(CharInfo.getFamilyID() and true or false)
        CSResourceMgr.setLabelStringByNode(fightlabel, CocosModuleMgr.createStringWithFormat({"home013", percent}),{r =0,g=0,b=0,a=255,w=1})
    end
    
    local function playCSB()
        local node = CSResourceMgr.getNodeByName(resName, "db")
        if node ~= nil then
            node:setVisible(true)
            CocosModuleMgr.showUIAnimation(node, "down")
        end
    end
    
    local funcTable = {loadCSB, playCSB}

    UnblockLoader.load(funcTable, "FurnitureSofaMgr")
end

return FurnitureSofaMgr