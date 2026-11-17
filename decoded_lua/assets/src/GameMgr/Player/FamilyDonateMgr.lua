local FamilyDonateMgr = {}

local resName = ""

function FamilyDonateMgr.Init()
    resName = "Player/Family/FamilyDonate.csb"
end

function FamilyDonateMgr.hideUI()
    CSResourceMgr.removeCSObjectByTag(resName)
    UIStack.pop("FamilyDonateMgr")
end

local function buyItem()
    local price = ItemInfo.getItemInfoById(197).paramC
    local data = {itemID = 197, unitPrice = price, buyMax = 0, coinType = 2}
    BuyInfoMgr2.show(SceneMgr.getRunningScene,data)
end

local function donate()
    local goldNum = tonumber(CSResourceMgr.getNodeByName(resName, {"db","frame1","num"}):getString())
    local itemNum = tonumber(CSResourceMgr.getNodeByName(resName, {"db","frame2","num"}):getString())
    if goldNum == 0 and itemNum == 0 then
        StandardTipsMgr.show(1,"family118")
    else
        FamilyDonateMgr.hideUI()
        FamilyInfo.FamilyDonation(goldNum, 197, itemNum)
    end
end

local function checkGCashState(donationLimit)
    local cash = CharInfo.getGCash()
    local currentNum = tonumber(CSResourceMgr.getNodeByName(resName, {"db","frame1","num"}):getString())
    local donatedNum = tonumber(CSResourceMgr.getNodeByName(resName, {"db","num2"}):getString())
    CSResourceMgr.setButtonEnabled(resName,{"db","frame1","plus"},(cash - currentNum) >= 10000 and currentNum + donatedNum < donationLimit )
    CSResourceMgr.setButtonEnabled(resName,{"db","frame1","minus"},currentNum > 0 )
end

local function checkItemState(itemLimit)
    local currentNum = tonumber(CSResourceMgr.getNodeByName(resName, {"db","frame2","num"}):getString())
    CSResourceMgr.setButtonEnabled(resName,{"db","frame2","plus"},currentNum < itemLimit )
    CSResourceMgr.setButtonEnabled(resName,{"db","frame2","minus"},currentNum > 0 )
end

local function checkDonateState()
    local info = FamilyInfo.GetLocalFamilyInfo()
    if info then
        local familyLevel = info.familyLevel or 1
        
        local donationLimit = FamilyDataInfo.getFamilyLevelInfoById(familyLevel).donationLimit
        checkGCashState(donationLimit)
        
        local itemLimit = BagViewMgr.getItemNum(197) or 0
        checkItemState(itemLimit)
    end
end

local function refreshAfterDonate()
    local deltaDevote = SystemInfo.getGlobalConfigAddInfoByID(68).values[1]
    local deltaIcon = SystemInfo.getGlobalConfigAddInfoByID(68).values[2]
    --print("deltaDevote,deltaIcon=",deltaDevote,deltaIcon)
    local goldNum = tonumber(CSResourceMgr.getNodeByName(resName, {"db","frame1","num"}):getString())
    local totalDevote = goldNum / 10000 * deltaDevote
    local totalIcon = goldNum / 10000 * deltaIcon
    
    local itemNum = tonumber(CSResourceMgr.getNodeByName(resName, {"db","frame2","num"}):getString())
    deltaDevote = ItemInfo.getItemInfoById(197).paramA
    deltaIcon = ItemInfo.getItemInfoById(197).paramB
    totalDevote = totalDevote + itemNum * deltaDevote
    totalIcon = totalIcon + itemNum * deltaIcon
    CSResourceMgr.setLabelString(resName, {"db","frame3","num1"}, totalDevote, nil, {r=0,g=0,b=0,a=255,w=1})
    CSResourceMgr.setLabelString(resName, {"db","frame3","num2"}, totalIcon, nil, {r=0,g=0,b=0,a=255,w=1})
end

local function initStaticData()
    CSResourceMgr.setLabelString(resName, "txt_title", "family113", nil, {r=0,g=0,b=0,a=255,w=1})
    local info = FamilyInfo.GetLocalFamilyInfo()
    if info then
        local familyLevel = info.familyLevel or 1
        CSResourceMgr.setLabelString(resName, {"db","name1"}, CocosModuleMgr.createStringWithFormat({"family114", familyLevel}), nil, {r=0,g=0,b=0,a=255,w=1})
        local donationLimit = FamilyDataInfo.getFamilyLevelInfoById(familyLevel).donationLimit
        CSResourceMgr.setLabelString(resName, {"db","num1"}, donationLimit, nil, {r=0,g=0,b=0,a=255,w=1})
        CSResourceMgr.setLabelString(resName, {"db","name2"}, "family115", nil, {r=0,g=0,b=0,a=255,w=1})
        local itemIcon = ItemInfo.getItemInfoById(197).icon
        CSResourceMgr.setSpriteTexture(resName, {"db","frame2","icon"}, itemIcon)
        local db = ItemInfo.getItemRareBGImage(197)
        CSResourceMgr.setButtonTexture(resName, {"db","frame2","icdb"}, db, db, db)
        CSResourceMgr.setLabelString(resName, {"db","frame3","txt"}, "family116", nil, {r=0,g=0,b=0,a=255,w=1})
        CSResourceMgr.setSpriteTexture(resName, {"db","frame3","icon2"}, string.sub(info.icon, 1, -5).."_hz.png")
        local btnItem = CSResourceMgr.getNodeByName(resName, {"db","item","btn"})
        CSResourceMgr.setButtonTextureByNode(btnItem, itemIcon, itemIcon, itemIcon)
        btnItem:setScale(0.8, 0.8)
        CSResourceMgr.setButtonString(resName, {"db","btn_donate"}, "family93", nil, {r=0,g=0,b=0,a=255,w=1})
        
        local input1 = CSResourceMgr.getNodeByName(resName, {"db","frame1","num"})
        local plus = CSResourceMgr.getNodeByName(resName, {"db","frame1","plus"})
        CSResourceMgr.clickEventBindingByNode(plus, function()
            local currentNum = tonumber(input1:getString())
            CSResourceMgr.setLabelStringByNode(input1, currentNum + 10000, {r=0,g=0,b=0,a=255,w=1})
            checkGCashState(donationLimit)
            refreshAfterDonate()
        end)
        CSResourceMgr.setButtonEnabledByNode(plus, false)
        local minus = CSResourceMgr.getNodeByName(resName, {"db","frame1","minus"})
        CSResourceMgr.clickEventBindingByNode(minus, function()
            local currentNum = tonumber(input1:getString())
            CSResourceMgr.setLabelStringByNode(input1, currentNum - 10000, {r=0,g=0,b=0,a=255,w=1})
            checkGCashState(donationLimit)
            refreshAfterDonate()
        end)
        CSResourceMgr.setButtonEnabledByNode(minus, false)
        
        local itemLimit = BagViewMgr.getItemNum(197) or 0
        CSResourceMgr.setLabelString(resName, {"db","item","txt"}, itemLimit, nil, {r=0,g=0,b=0,a=255,w=1})
        local input2 = CSResourceMgr.getNodeByName(resName, {"db","frame2","num"})
        local plus = CSResourceMgr.getNodeByName(resName, {"db","frame2","plus"})
        CSResourceMgr.clickEventBindingByNode(plus, function()
            local currentNum = tonumber(input2:getString())
            CSResourceMgr.setLabelStringByNode(input2, currentNum + 1, {r=0,g=0,b=0,a=255,w=1})
            itemLimit = BagViewMgr.getItemNum(197) or 0
            checkItemState(itemLimit)
            refreshAfterDonate()
        end)
        CSResourceMgr.setButtonEnabledByNode(plus, false)
        local minus = CSResourceMgr.getNodeByName(resName, {"db","frame2","minus"})
        CSResourceMgr.clickEventBindingByNode(minus, function()
            local currentNum = tonumber(input2:getString())
            CSResourceMgr.setLabelStringByNode(input2, currentNum - 1, {r=0,g=0,b=0,a=255,w=1})
            itemLimit = BagViewMgr.getItemNum(197) or 0
            checkItemState(itemLimit)
            refreshAfterDonate()
        end)
        CSResourceMgr.setButtonEnabledByNode(minus, false)
    end
end

function FamilyDonateMgr.show(scene)
    if CSResourceMgr.getCsbObj(resName) or CharInfo.getFamilyID() == nil then
        return  
    end
    UIStack.push("FamilyDonateMgr",FamilyDonateMgr.hideUI,false)
    local function loadCSB()
        local curLayer = CSResourceMgr.createRes(scene, resName)
        curLayer:setLocalZOrder(CocosModuleMgr.ZORDER_FLOAT)
        CSResourceMgr.setRelativePosition(resName, 320, 480)
        CSResourceMgr.getNodeByName(resName, "db"):setVisible(false)

        CSResourceMgr.clickEventBinding(resName, "close", function()
            FamilyDonateMgr.hideUI()
        end)
        
        CSResourceMgr.clickEventBinding(resName, {"db","item","btn"}, function()
            buyItem()
        end, nil, 3)
        
        CSResourceMgr.clickEventBinding(resName, "btn_donate", function()
            donate()
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
    
    FamilyInfo.QueryFamilyDonation()
end

function FamilyDonateMgr.updateDonatedNum(num)
    if CSResourceMgr.getCsbObj(resName) then
        CSResourceMgr.setLabelString(resName, {"db","num2"}, num or 0, nil, {r=0,g=0,b=0,a=255,w=1})
        
        checkDonateState()
    end
end

function FamilyDonateMgr.updateItemNum()
    if CSResourceMgr.getCsbObj(resName) then
        local itemLimit = BagViewMgr.getItemNum(197) or 0
        CSResourceMgr.setLabelString(resName, {"db","item","txt"}, itemLimit, nil, {r=0,g=0,b=0,a=255,w=1})
        checkItemState(itemLimit)
    end
end

return FamilyDonateMgr