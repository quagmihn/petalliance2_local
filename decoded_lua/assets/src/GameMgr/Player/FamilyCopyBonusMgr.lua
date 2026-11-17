local FamilyCopyBonusMgr = {}

local resName = ""

function FamilyCopyBonusMgr.Init()
    resName = "Player/Family/FamilyCopyBonus.csb"
end

local function initDynamicData(floor)
    CSResourceMgr.setLabelString(resName, "bonus", CocosModuleMgr.createStringWithFormat({"family101", floor}), nil, {r=0,g=0,b=0,a=255,w=1})
    
    local familyAwardInfo = FamilyDataInfo.getFamilyAwardInfoById(floor)
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

function FamilyCopyBonusMgr.hideUI()
    CSResourceMgr.removeCSObjectByTag(resName)
    UIStack.pop("FamilyCopyBonusMgr")
end

function FamilyCopyBonusMgr.show(scene, floor)
    if CSResourceMgr.getCsbObj(resName) then
        return  
    end
    UIStack.push("FamilyCopyBonusMgr",FamilyCopyBonusMgr.hideUI,false)
    local function loadCSB()
        local curLayer = CSResourceMgr.createRes(scene, resName)
        curLayer:setLocalZOrder(CocosModuleMgr.ZORDER_FLOAT)
        CSResourceMgr.setRelativePosition(resName, 320, 480)
        CSResourceMgr.getNodeByName(resName, "db"):setVisible(false)
        
        CSResourceMgr.clickEventBinding(resName, "bg", function()
            FamilyCopyBonusMgr.hideUI()
        end)
        
        initDynamicData(floor)
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
end

return FamilyCopyBonusMgr