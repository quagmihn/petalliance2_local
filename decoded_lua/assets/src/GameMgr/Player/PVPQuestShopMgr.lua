local PVPQuestShopMgr = {}

local resName = ""
local resNameDownBar = ""
local resNameBG = ""
local NUM_PER_LINE = 3

local refreshInfo = {}

function PVPQuestShopMgr.Init()
    resName = "Player/ArenaPK/PVPQuestShop.csb"
    resNameDownBar = "Player/ArenaPK/PVPQuestShopDownBar.csb"
    resNameBG = "Pet/Formation/FormationBGNew.csb"
    NUM_PER_LINE = 3
end

function PVPQuestShopMgr.initUIData()

    CSResourceMgr.setLabelString(resName, "txt_title", "pvptasktips6", nil, {r=26,g=37,b=48,a=255,w=1})
    
    CSResourceMgr.setLabelString(resNameDownBar, "tip1", "pvptasktips7", nil, {r=0,g=0,b=0,a=255,w=1})
    CSResourceMgr.setLabelString(resNameDownBar, "tip2", "pvptasktips8", nil, {r=0,g=0,b=0,a=255,w=1})

    local reset = CSResourceMgr.getNodeByName(resNameDownBar, "reset")
    CSResourceMgr.setButtonStringByNode(reset, LuaSqlite.getLanguageByKey("skillReset1"), nil, {r=0,g=0,b=0,a=255,w=1})
    
    local diff = CocosModuleMgr.getScreenSizeDiff()
    if diff < 0 then
        local list = CSResourceMgr.getNodeByName(resName,"list")
        local lsize = list:getContentSize()
        list:setContentSize(lsize.width, lsize.height+diff*2.66)
    end

end

function PVPQuestShopMgr.refreshData()
    
    PVPQuestShopMgr.refreshPvpArenaCoin()
    PVPQuestShopMgr.refreshGold()
    PVPQuestShopMgr.refreshDiamond()

end

function PVPQuestShopMgr.refreshPvpArenaCoin()

    if CSResourceMgr.getCsbObj(resName) then
        local devote = CSResourceMgr.getNodeByName(resName, "txt_devote")
        CSResourceMgr.setLabelStringByNode(devote, CharInfo.getPvpArenaCoin(), {r=0,g=0,b=0,a=255,w=1})
    end

end

function PVPQuestShopMgr.refreshGold()

    if CSResourceMgr.getCsbObj(resName) then
        local gold = CSResourceMgr.getNodeByName(resName, "txt_gold")
        CSResourceMgr.setLabelStringByNode(gold, CharInfo.getGCash())
    end

end

function PVPQuestShopMgr.refreshDiamond()

    if CSResourceMgr.getCsbObj(resName) then
        local diamond = CSResourceMgr.getNodeByName(resName, "txt_diamond")
        CSResourceMgr.setLabelStringByNode(diamond, CharInfo.getMCash())
    end

end

function PVPQuestShopMgr.hideUI()
    UnblockLoader.cancel("PVPQuestShopMgr")
    CSResourceMgr.removeCSObjectByTag(resName)
    CSResourceMgr.removeCSObjectByTag(resNameDownBar)
    CSResourceMgr.removeCSObjectByTag(resNameBG, "PVPQuestShopMgr")
    UIStack.pop("PVPQuestShopMgr")
end

function PVPQuestShopMgr.show(scene)
    if CSResourceMgr.getCsbObj(resName) then
        return  
    end
    UIStack.push("PVPQuestShopMgr",PVPQuestShopMgr.hideUI,true)
    local function loadBG()
        local bgLayer = CSResourceMgr.createRes(scene, resNameBG, "PVPQuestShopMgr")
        bgLayer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resNameBG, 320, 480, "PVPQuestShopMgr")
        bgLayer:setOpacity(0)
        transition.fadeIn(bgLayer, {time=0.3})
    end

    local function InitRefreshInfo()
        local shopRefreshInfo = ItemInfo.getShopReFlashInfoById(4)
        if shopRefreshInfo then
            for key, value in pairs(shopRefreshInfo.reflashDetail) do
                refreshInfo[value.count] = value.consume
            end
        end
    end
    
    local function loadCSB()

        InitRefreshInfo()

        local curLayer = CSResourceMgr.createRes(scene, resName)
        curLayer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CocosModuleMgr.setEdgeDistance(curLayer, 0, nil, 0, nil, false)
        CSResourceMgr.getNodeByName(resName, "db"):setVisible(false)
        
        curLayer = CSResourceMgr.createRes(scene, resNameDownBar)
        curLayer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CocosModuleMgr.setEdgeDistance(curLayer, 0, nil, nil, 0, false)
        curLayer:setVisible(false)
        
        CSResourceMgr.clickEventBinding(resName, "close", function()
            PVPQuestShopMgr.hideUI()
        end)

        CSResourceMgr.clickEventBinding(resNameDownBar, "reset", function()
            PVPQuestShopMgr.reset()
        end)
        
        PVPQuestShopMgr.initUIData()

        PVPQuestShopMgr.refreshData()
        
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
    
    PVPQuestShopMgr.getShop()

end

function PVPQuestShopMgr.sendSystemRefreshGoodes()

    local timePoints = SystemInfo.getGlobalConfigAddInfoByID(34).values
    for i=1,#timePoints do
        offsetTime = 3600 * timePoints[i]
        local dayDiff = CocosModuleMgr.getDayTimeDiff(ArenaExchangeMgr.systemReflashTime, CharInfo.getServerTime(), offsetTime)
        if dayDiff ~= 0 then
            ArenaViewMgr.systemRefresh = true
            NetInterface.sendWithBlock("GC_SYSTEMREFRESHGOODS_ACK",function()
                local CommonShopSend = require("src.Net.Send.CommonShopSend")
                CommonShopSend.sendCG_SystemRefreshGoods_Req({type = Proto.SHOP_PVPARENA})
            end,function()
                ArenaViewMgr.systemRefresh = false
                PVPQuestShopMgr.getShop()
            end,function(code)
                TipsMgr.showError(scene, code)
            end)
            
            return true
        end
    end

    return false

end

function PVPQuestShopMgr.getShop()

    ArenaViewMgr.getShop = true
    NetInterface.sendWithBlock("GC_GETSHOP_ACK", function()
        local CommonShopSend = require("src.Net.Send.CommonShopSend")
        CommonShopSend.sendCG_getShop_Req({type = Proto.SHOP_PVPARENA})
    end, function()
        ArenaViewMgr.getShop = false
        local offsetTime = SystemInfo.getGlobalConfigAddInfoByID(36).values[1] * 3600
        local dayDiff = CocosModuleMgr.getDayTimeDiff(ArenaExchangeMgr.shopResetTime, CharInfo.getServerTime(), offsetTime)
        if dayDiff ~= 0 then
            ArenaViewMgr.resetShop = true
            NetInterface.sendWithBlock("GC_RESETSHOP_ACK", function() 
                local CommonShopSend = require("src.Net.Send.CommonShopSend")
                CommonShopSend.sendCG_ResetShop_Req({type = Proto.SHOP_PVPARENA,})
            end, function()
                ArenaViewMgr.resetShop = false
                ArenaExchangeMgr.shopResetTime = CharInfo.getServerTime()
                if not PVPQuestShopMgr.sendSystemRefreshGoodes() then
                    PVPQuestShopMgr.createList()
                end
            end, function(code)
                TipsMgr.showError(scene, code)
            end)
        else
            if not PVPQuestShopMgr.sendSystemRefreshGoodes() then
                PVPQuestShopMgr.createList()
            end
        end
        
    end, function(code)
        TipsMgr.showError(scene, code)
    end)
    
end

function PVPQuestShopMgr.createList()

    if CSResourceMgr.getCsbObj(resName) then
        local list = CSResourceMgr.getNodeByName(resName,"list")
        list:removeAllItems()
        
        local funcTable = {}
        UnblockLoader.cancel("PVPQuestShopMgr")

        local aInfo = ArenaInfo.getAllPVPArenaGradeInfo()

        local cloneNum = math.ceil(#ArenaExchangeMgr.shopItems/NUM_PER_LINE)
        for i=1, cloneNum do
            table.insert(funcTable,function()
                local component = CSResourceMgr.getNodeByName(resName,"item_component"):clone()
                for idx=1, NUM_PER_LINE do
                    local id = (i-1)*NUM_PER_LINE + idx
                    if id <= #ArenaExchangeMgr.shopItems then
                        local shopInfo = ArenaExchangeMgr.shopItems[id]
                        local awardElementInfo = ItemInfo.getAwardElementInfoById(shopInfo.itemID)
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

                        cost:setPositionX(cost:getPositionX() - 10)
                        CSResourceMgr.setLabelStringByNode(name, itemName, {r=0,g=0,b=0,a=255,w=1}, nil, 140)
                        CSResourceMgr.setLabelColorByNode(name, itemNameColor)
                        CSResourceMgr.setLabelStringByNode(cost, shopInfo.price, {r=0,g=0,b=0,a=255,w=1})

                        local curArenaPoint = ArenaInfo.getPVPArenaPoint()
                        if curArenaPoint < shopInfo.conditionNum then
                            for j=1, #aInfo do
                                if aInfo[j].startPoint == shopInfo.conditionNum then
                                    local devote = CSResourceMgr.seekNodeByName(item, "devote")
                                    devote:setVisible(false)
                                    CSResourceMgr.setLabelStringByNode(cost, CocosModuleMgr.createStringWithFormat({"pvptasktips12", aInfo[j].gradeName}), {r=0,g=0,b=0,a=255,w=1})
                                    break
                                end
                            end 
                        end

                        if CharInfo.getPvpArenaCoin() < shopInfo.price or curArenaPoint < shopInfo.conditionNum then
                            CSResourceMgr.setLabelColorByNode(cost, {r=255 ,g=0 ,b=0 ,a=255})
                        end

                        CSResourceMgr.longtouchEventBindingByNode(item, function ()
                            ItemInfoViewMgr.show({id = awardElementInfo.elementID}, false)
                        end, function ()
                            if curArenaPoint < shopInfo.conditionNum then
                                StandardTipsMgr.show(1, "pvptasktips10")
                            elseif CharInfo.getPvpArenaCoin() >= shopInfo.price then
                                DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 2, "LtTips5", function()
                                    NetInterface.sendWithBlock("GC_BUYGOODS_ACK",function()
                                        local CommonShopSend = require("src.Net.Send.CommonShopSend")
                                        CommonShopSend.sendCG_BuyGoods_Req({type = Proto.SHOP_PVPARENA, index = id - 1,buyCount = 1})
                                    end, function()
                                        GameAudio.playUISound("shopexchange")
                                        StandardTipsMgr.show(0, "LtTips6")

                                        shopInfo.count = shopInfo.count - 1
                                        if shopInfo.count == 0 then
                                            CSResourceMgr.setButtonEnabledByNode(item, false)
                                            local gray = CSResourceMgr.seekNodeByName(item, "gray")
                                            gray:setVisible(true)
                                        end
                                        
                                        PVPQuestShopMgr.refreshPvpArenaCoin()
                                    end, function(code)
                                    end, nil, false)
                                end, function()
                                end)
                            else
                                StandardTipsMgr.show(1, "pvptasktips11")
                            end
                        end, 3)
                        
                        local enable = true
                        if shopInfo.count == 0 then
                            enable = false
                        end
                        CSResourceMgr.setButtonEnabledByNode(item, enable)
                        local gray = CSResourceMgr.seekNodeByName(item, "gray")
                        gray:setColor({r=0,g=0,b=0})
                        gray:setOpacity(153)
                        gray:setVisible(not enable)
                        local icon = CSResourceMgr.seekNodeByName(item, "icon")
                        local iNode = ItemInfo.getItemIconById(awardElementInfo.elementID,shopInfo.num)
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
        UnblockLoader.load(funcTable,"PVPQuestShopMgr")
    end

end

function PVPQuestShopMgr.reset()

    local param = ArenaExchangeMgr.refreshCount+1 > 25 and 25 or ArenaExchangeMgr.refreshCount+1
    local MCashCost = ItemInfo.getConsumeElementInfoById(refreshInfo[param]).num
    DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 2, CocosModuleMgr.createStringWithFormat({"pvptasktips9", MCashCost}), function()
        ArenaExchangeMgr.resetGoods = true
        NetInterface.sendWithBlock("GC_REFRESHGOODS_ACK",function()
            local CommonShopSend = require("src.Net.Send.CommonShopSend")
            CommonShopSend.sendCG_RefreshGoods_Req({type = Proto.SHOP_PVPARENA})
        end,function()
            GameAudio.playUISound("shoprefresh")
            ArenaExchangeMgr.resetGoods = false
            PVPQuestShopMgr.getShop()
        end,function(code)
            TipsMgr.showError(nil,code)
        end, nil, false)
    end,function()
    end)

end

return PVPQuestShopMgr