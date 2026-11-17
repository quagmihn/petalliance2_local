local FamilyShopMgr = {}

local resName = ""
local resNameDownBar = ""
local resNameBG = ""
local NUM_PER_LINE = 3

function FamilyShopMgr.Init()
    resName = "Player/Family/FamilyShop.csb"
    resNameDownBar = "Player/Family/FamilyShopDownBar.csb"
    resNameBG = "Pet/Formation/FormationBGNew.csb"
    NUM_PER_LINE = 3
end

local function initStaticData()
    CSResourceMgr.setLabelString(resName, "txt_title", "family138", nil, {r=26,g=37,b=48,a=255,w=1})
    
    CSResourceMgr.setLabelString(resNameDownBar, "tip1", "family136", nil, {r=0,g=0,b=0,a=255,w=1})
    CSResourceMgr.setLabelString(resNameDownBar, "tip2", "family137", nil, {r=0,g=0,b=0,a=255,w=1})
    
    local diff = CocosModuleMgr.getScreenSizeDiff()
    if diff < 0 then
        local list = CSResourceMgr.getNodeByName(resName,"list")
        local lsize = list:getContentSize()
        list:setContentSize(lsize.width, lsize.height+diff*2.66)
    end
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
end

function FamilyShopMgr.hideUI()
    UnblockLoader.cancel("FamilyShopMgr")
    CSResourceMgr.removeCSObjectByTag(resName)
    CSResourceMgr.removeCSObjectByTag(resNameDownBar)
    CSResourceMgr.removeCSObjectByTag(resNameBG, "FamilyShopMgr")
    UIStack.pop("FamilyShopMgr")
end

function FamilyShopMgr.show(scene)
    if CSResourceMgr.getCsbObj(resName) then
        return  
    end
    UIStack.push("FamilyShopMgr",FamilyShopMgr.hideUI,true)
    local function loadBG()
        local bgLayer = CSResourceMgr.createRes(scene, resNameBG, "FamilyShopMgr")
        bgLayer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resNameBG, 320, 480, "FamilyShopMgr")
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
            FamilyShopMgr.hideUI()
        end)
        
        initStaticData()

        initDynamicData()
        
        CSResourceMgr.clickEventBinding(resName, "btn_gold", function()
            ExchangeViewMgr.show(scene,ExchangeViewMgr.GCASHTYPE)
        end)

        CSResourceMgr.clickEventBinding(resName, "btn_diamond", function()
            PurchaseViewMgr.show(scene)
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
    
    FamilyInfo.GetFamilyShopData()
end

local function checkTip(purchased, needLevel, id, tip)
    for k,v in pairs(purchased) do
        if v == id then
            local txt = CSResourceMgr.seekNodeByName(tip, "txt")
            CSResourceMgr.setLabelStringByNode(txt, "NetErrorText24", {r=0,g=0,b=0,a=255,w=1})
            CSResourceMgr.setLabelColorByNode(txt, {r=0 ,g=240 ,b=255 ,a=255})
            tip:setVisible(true)
            return false
        end
    end
    
    local info = FamilyInfo.GetLocalFamilyInfo()
    if info ~= nil then
        local familyLevel = (info.familyLevel or 1)
        if familyLevel < needLevel then
            local txt = CSResourceMgr.seekNodeByName(tip, "txt")
            CSResourceMgr.setLabelStringByNode(txt, CocosModuleMgr.createStringWithFormat({"family139", needLevel}), {r=0,g=0,b=0,a=255,w=1})
            CSResourceMgr.setLabelColorByNode(txt, {r=255 ,g=0 ,b=0 ,a=255})
            tip:setVisible(true)
            return false
        end
    end
    return true
end

local function updateCostColor(costTbl, devote)
    if CSResourceMgr.getCsbObj(resName) then
        for k,v in pairs(costTbl) do
            local cost = tonumber(v:getString())
            if devote < cost then
                CSResourceMgr.setLabelColorByNode(v, {r=255 ,g=0 ,b=0 ,a=255})
            else
                CSResourceMgr.setLabelColorByNode(v, {r=255 ,g=255 ,b=255 ,a=255})
            end
        end
    end
end

function FamilyShopMgr.createList(purchased)
    local costTbl = {}
    purchased = purchased or {}
    if CSResourceMgr.getCsbObj(resName) then
        local list = CSResourceMgr.getNodeByName(resName,"list")
        list:removeAllItems()
        
        local devote = tonumber(CSResourceMgr.getNodeByName(resName, "txt_devote"):getString())
        local membersInfo =  FamilyInfo.GetLocalFamilyMembersInfo()
        if CharInfo.getFamilyID() ~= nil and membersInfo ~= nil then
            devote = membersInfo[tostring(CharInfo.getCharID())].devotePoint or 0
        end
        
        local funcTable = {}
        UnblockLoader.cancel("FamilyShopMgr")
        local cloneNum = math.ceil(FamilyDataInfo.getFamilyShopInfoTotal()/NUM_PER_LINE)
        local shopInfoTbl = {}
        for idx=1, FamilyDataInfo.getFamilyShopInfoTotal() do
            table.insert(shopInfoTbl, FamilyDataInfo.getFamilyShopInfoById(idx))
        end
        table.sort(shopInfoTbl, function(a, b)
            return a.needLevel < b.needLevel
        end)
        --print("##########shopInfoTbl=",#shopInfoTbl)
        for i=1, cloneNum do
            table.insert(funcTable,function()
                local component = CSResourceMgr.getNodeByName(resName,"item_component"):clone()
                for idx=1, NUM_PER_LINE do
                    local id = (i-1)*NUM_PER_LINE + idx
                    if id <= #shopInfoTbl then
                        local shopInfo = shopInfoTbl[id]
                        local awardElementInfo = ItemInfo.getAwardElementInfoById(shopInfo.awardElementID)
                        local item = CSResourceMgr.seekNodeByName(component, "item"..idx)
                        local bg1 = CSResourceMgr.seekNodeByName(item, "bg1")
                        bg1:setColor({r=128,g=161,b=172})
                        local bg2 = CSResourceMgr.seekNodeByName(item, "bg2")
                        bg2:setColor({r=38,g=56,b=71})
                        local itemName,itemNameColor
                        if awardElementInfo.elementType == Proto.AET_ITEM then
                            local itemInfo = ItemInfo.getItemInfoById(awardElementInfo.elementID)
                            itemName = itemInfo.name
                            itemNameColor = ItemInfo.COLOR[itemInfo.itemRare+1]
                        elseif awardElementInfo.elementType == Proto.AET_PET then
                            local pokemonInfo = PokemonInfo.getPokemonInfoByID(awardElementInfo.elementID)
                            itemName = pokemonInfo.name
                            itemNameColor = PokemonInfo.COLOR[pokemonInfo.rarePoint]
                        end
                        local name = CSResourceMgr.seekNodeByName(item, "name")
                        local cost = CSResourceMgr.seekNodeByName(item, "cost")
                        table.insert(costTbl, cost)
                        CSResourceMgr.setLabelStringByNode(name, itemName, {r=0,g=0,b=0,a=255,w=1})
                        CSResourceMgr.setLabelColorByNode(name, itemNameColor)
                        CSResourceMgr.setLabelStringByNode(cost, shopInfo.price, {r=0,g=0,b=0,a=255,w=1})
                        if devote < shopInfo.price then
                            CSResourceMgr.setLabelColorByNode(cost, {r=255 ,g=0 ,b=0 ,a=255})
                        end
                        local tip = CSResourceMgr.seekNodeByName(item, "tip")
                        tip:setColor({r=0,g=0,b=0})
                        tip:setOpacity(100)
                        
                        CSResourceMgr.clickEventBindingByNode(item,function()
                            devote = tonumber(CSResourceMgr.getNodeByName(resName, "txt_devote"):getString())
                            local membersInfo =  FamilyInfo.GetLocalFamilyMembersInfo()
                            if CharInfo.getFamilyID() ~= nil and membersInfo ~= nil then
                                devote = membersInfo[tostring(CharInfo.getCharID())].devotePoint or 0
                            end
                            if devote >= shopInfo.price then
                                FamilyInfo.BuyFamilyShopGoods(shopInfo.id, function()
                                    AwardsListMgr.show(SceneMgr.getRunningScene, {{awardElementInfo.elementID, shopInfo.awardCount}})
                                    
                                    table.insert(purchased, shopInfo.id)
                                    local enable = checkTip(purchased, shopInfo.needLevel, shopInfo.id, tip)
                                    CSResourceMgr.setButtonEnabledByNode(item, enable)
                                    CSResourceMgr.seekNodeByName(item, "gray"):setVisible(not enable)
                                    
                                    CSResourceMgr.setLabelString(resName, "txt_devote", devote - shopInfo.price, nil, {r=0,g=0,b=0,a=255,w=1})
                                    if CharInfo.getFamilyID() ~= nil and membersInfo ~= nil then
                                        membersInfo[tostring(CharInfo.getCharID())].devotePoint = devote - shopInfo.price
                                    end
                                    updateCostColor(costTbl, devote - shopInfo.price)
                                end)
                            else
                                StandardTipsMgr.show(1,"family141")
                            end
                        end, 3)
                        
                        local enable = checkTip(purchased, shopInfo.needLevel, shopInfo.id, tip)
                        CSResourceMgr.setButtonEnabledByNode(item, enable)
                        local gray = CSResourceMgr.seekNodeByName(item, "gray")
                        gray:setColor({r=0,g=0,b=0})
                        gray:setOpacity(153)
                        gray:setVisible(not enable)
                        local icon = CSResourceMgr.seekNodeByName(item, "icon")
                        local iNode = ItemInfo.getItemIconById(awardElementInfo.elementID, shopInfo.awardCount)
                        iNode:setPosition(0, 0)
                        iNode:setScale(0.8)
                        iNode:removeFromParent()
                        CSResourceMgr.setButtonEnabledByNode(iNode, false)
                        iNode:addTo(icon)
                        item:setVisible(true)
                    end
                end
                component:setVisible(true)
                component:setScaleY(0)
                list:pushBackCustomItem(component)
                transition.scaleTo(component,{scale=1.0,time = 0.1})
            end)
        end
        UnblockLoader.load(funcTable,"FamilyShopMgr")
    end
end

return FamilyShopMgr