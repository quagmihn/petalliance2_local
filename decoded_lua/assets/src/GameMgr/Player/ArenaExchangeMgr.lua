local ArenaExchangeMgr = {}

local resName = ""
ArenaExchangeMgr.itemRow = 3
local itemNodes = {}
ArenaExchangeMgr.LABLE_OUTLINE_THICK = 1
ArenaExchangeMgr.ROW = 3

ArenaExchangeMgr.shopItems = {}
ArenaExchangeMgr.refreshCount = nil
ArenaExchangeMgr.shopResetTime = nil
ArenaExchangeMgr.systemReflashTime = nil
ArenaExchangeMgr.resetGoods = false

local refreshInfo = {}

local textColor = {
    {r=0,g=0,b=0,a=255},
    {r=255,g=255,b=255,a=255},
    {r=228,g=235,b=254,a=255},
    {r=255,g=78,b=0,a=255},
}
local outlineColor = {
    {r=0,g=0,b=0,a=255},
    {r=0,g=0,b=0,a=255,w=1,s=1},
    {r=0,g=0,b=0,a=255,w=1,s=2},
}

function ArenaExchangeMgr.Init()
    print("ArenaExchangeMgr初始化")
    
    resName = "Player/Arena/ArenaExchange.csb"
end

function ArenaExchangeMgr.show(scene)
    local function loadItems()
        local list = CSResourceMgr.getNodeByName(resName, "list")
        local item = CSResourceMgr.getNodeByName(resName, "item")
        local diban = CSResourceMgr.getNodeByName(resName, "diban")
        list:removeAllItems()
        local totalLine = math.ceil(#ArenaExchangeMgr.shopItems / ArenaExchangeMgr.ROW)
        local diffX = 180
        local panelNodes = {}
        for i = 1, totalLine do
            panelNodes[i] = diban:clone()
            panelNodes[i]:setColor((i % 2) ~= 0 and {r=43,g=65,b=98,a=255} or {r=3,g=23,b=49,a=255})
            panelNodes[i]:setOpacity(204)
            list:pushBackCustomItem(panelNodes[i])
        end
        local idx = 1
        local index = 1
        local functionTable = {}
        for k,v in pairs(ArenaExchangeMgr.shopItems) do
            list:performWithDelay(function ()
                local line = math.ceil(index / ArenaExchangeMgr.ROW)
                local row = index % ArenaExchangeMgr.ROW == 0 and ArenaExchangeMgr.ROW or index % ArenaExchangeMgr.ROW
                itemNodes[index] = item:clone()
                itemNodes[index]:addTo(panelNodes[line])
                itemNodes[index]:setPositionX((row - 1) * diffX + 120)
                itemNodes[index]:setPositionY(135)
                itemNodes[index]:setScale(0.93, 0.93)
                ArenaExchangeMgr.setItemNode(itemNodes[index], v, index)
                itemNodes[index]:setScale(0, 0)
                transition.scaleTo(itemNodes[index], {scale=0.93, time=0.2})
                itemNodes[index]:setVisible(true)
                index = index + 1
            end, 0.1 * idx)
            idx = idx + 1
        end
        item:setVisible(false)
    end

    local function InitRefreshInfo()
        local shopRefreshInfo = ItemInfo.getShopReFlashInfoById(1)--ArenaExchangeMgr.refreshCount
        if shopRefreshInfo then
            for key, value in pairs(shopRefreshInfo.reflashDetail) do
                refreshInfo[value.count] = value.consume
            end
        end
    end

	local function loadCSB()
        local layer = CSResourceMgr.createRes(scene, resName)
        CSResourceMgr.setFullScreen(resName)
        layer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        layer:setOpacity(0)

        local title = CSResourceMgr.getNodeByName(resName, {"panel_1", "title"})
        CSResourceMgr.setLabelStringByNode(title, "arena33", outlineColor[2])

        local labelRefresh = CSResourceMgr.getNodeByName(resName, {"panel_2", "refresh_btn", "refresh_name"})
        CSResourceMgr.setLabelStringByNode(labelRefresh, "arena34", outlineColor[3])

        InitRefreshInfo()
        local btnRefresh = CSResourceMgr.getNodeByName(resName, {"panel_2", "refresh_btn"})
        local function setBtnRefresh()
            local param = ArenaExchangeMgr.refreshCount+1 > 25 and 25 or ArenaExchangeMgr.refreshCount+1
            local MCashCost = ItemInfo.getConsumeElementInfoById(refreshInfo[param]).num
            CSResourceMgr.setButtonEnabledByNode(btnRefresh, MCashCost <= CharInfo.getMCash())
            CSResourceMgr.clickEventBindingByNode(btnRefresh, function()
                local vipLevel = CharInfo.getVIPLevel()
                local vipInfo = CharInfo.getVipInfoByID(vipLevel)
                if ArenaExchangeMgr.refreshCount >= vipInfo.arenaShopRefresh then
                    DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 2, "train169")
                else
                    DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 2, CocosModuleMgr.createStringWithFormat({"arena48", MCashCost}), function()
                        ArenaExchangeMgr.resetGoods = true
                        NetInterface.sendWithBlock("GC_REFRESHGOODS_ACK",function()
                            local CommonShopSend = require("src.Net.Send.CommonShopSend")
                            CommonShopSend.sendCG_RefreshGoods_Req({type = 1,})
                        end,function()
                            GameAudio.playUISound("shoprefresh")
                            ArenaExchangeMgr.resetGoods = false
                            ArenaExchangeMgr.refreshCount = ArenaExchangeMgr.refreshCount + 1
                            loadItems()
                            setBtnRefresh()
                        end,function(code)
                            TipsMgr.showError(nil,code)
                        end, nil, false)
                    end,function()--取消
                    end)
                end
            end)
        end
        setBtnRefresh()

        local panel1 = CSResourceMgr.getNodeByName(resName, "panel_1")
        local panel2 = CSResourceMgr.getNodeByName(resName, "panel_2")
        local list = CSResourceMgr.seekNodeByName(panel1, "list")
        local diff = CocosModuleMgr.getScreenSizeDiff() > 0 and CocosModuleMgr.getScreenSizeDiff() or 0
        ViewMgrUtils.vFitSetPos(diff, {panel1})
        ViewMgrUtils.vFitSetPos(-diff, {panel2})
        ViewMgrUtils.vFitStretch(diff, {list})

        transition.fadeIn(layer, {time=0.5})
    end

    local function refreshTime()
        ArenaExchangeMgr.refreshTimeLeft()
    end

    local funcTable = {loadCSB, loadItems, refreshTime}
    UnblockLoader.load(funcTable,"ArenaExchangeMgr")
end

function ArenaExchangeMgr.setItemNode(node, item, index)
    local haveEnoughRes = item.price <= CharInfo.getArenaScore()
    local itemName = CSResourceMgr.seekNodeByName(node, "item_name")
    local itemCost = CSResourceMgr.seekNodeByName(node, "item_cost")
    local gray     = CSResourceMgr.seekNodeByName(node, "gray")
    local background1 = CSResourceMgr.seekNodeByName(node, "item_background_1")
    local background2 = CSResourceMgr.seekNodeByName(node, "item_background_2")
    local background3 = CSResourceMgr.seekNodeByName(node, "item_background_3")

    local isJishu = math.floor((index - 1) / 3) % 2 == 0
    background1:setColor({r=179,g=200,b=206,a=255})
    background3:setColor(isJishu == true and {r=2,g=16,b=28,a=255} or {r=35,g=56,b=87,a=255})
    background3:setOpacity(178)

    local name,nameColor
    print("ArenaExchangeMgr.setItemNode id", item.itemID)
    local awardInfo = ItemInfo.getAwardElementInfoById(item.itemID)
    local itemInfo = ItemInfo.getItemInfoById(awardInfo.elementID)
    if awardInfo.elementType == Proto.AET_ITEM then
        name = itemInfo.name
        nameColor = ItemInfo.COLOR[itemInfo.itemRare+1]
    elseif awardInfo.elementType == Proto.AET_PET then
        name = ""
        nameColor = PokemonInfo.COLOR[pokemonInfo.rarePoint]
    end

    local iNode = ItemInfo.getItemIconById(awardInfo.elementID, item.num)
    iNode:setPosition(0, 0)
    iNode:setScale(0.8)
    iNode:removeFromParent()
    iNode:addTo(background2)
    -- iNode:setScale(needPetNode[i]:getContentSize().width / iNode:getContentSize().width)

    CSResourceMgr.setLabelStringByNode(itemName, name, outlineColor[1], 1, 150)
    CSResourceMgr.setLabelStringByNode(itemCost, item.price)
    CSResourceMgr.setLabelColorByNode(itemName, nameColor)
    CSResourceMgr.setLabelColorByNode(itemCost, haveEnoughRes and textColor[2] or textColor[4])

    CSResourceMgr.setButtonEnabledByNode(node, item.count >= 1)
    gray:setColor({r=0,g=0,b=0,a=255})
    gray:setOpacity(153)
    gray:setVisible(item.count < 1)

    local function setBtnByNode(inode)
        CSResourceMgr.longtouchEventBindingByNode(inode, function ()
            ItemInfoViewMgr.show({id = awardInfo.elementID}, false)
        end, function ()
            if haveEnoughRes then
                DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 2, "LtTips5", function()
                    NetInterface.sendWithBlock("GC_BUYGOODS_ACK",function()
                        local CommonShopSend = require("src.Net.Send.CommonShopSend")
                        CommonShopSend.sendCG_BuyGoods_Req({type = 1, index = index - 1,buyCount = 1})
                    end, function()
                        GameAudio.playUISound("shopexchange")
                        StandardTipsMgr.show(0, "LtTips6")   -- "购买成功"
                        item.count = item.count - 1
                        ArenaExchangeMgr.setItemNode(node, item, index)
                        
                        local labelScore = CSResourceMgr.getNodeByName(resName, {"bottom", "score", "label_score"})
                        CSResourceMgr.setLabelStringByNode(labelScore, CharInfo.getArenaScore())
                    end, function(code)
                        print("failed to buy")
                    end, nil, false)
                end, function()--取消
                end)
            else
                StandardTipsMgr.show(1, "LtTips3")
            end
        end, 3)
    end
    setBtnByNode(node)
    setBtnByNode(iNode)
end

function ArenaExchangeMgr.refreshItemNodes()
    local index = 1
    for k,v in pairs(ArenaExchangeMgr.shopItems) do
        ArenaExchangeMgr.setItemNode(itemNodes[index], v, index)
        index = index + 1
    end
end

function ArenaExchangeMgr.refreshTimeLeft()
    local timeTable = SystemInfo.getGlobalConfigAddInfoByID(34).values
    local serverTime = os.date("*t", CharInfo.getServerTime())
    local h = serverTime.hour
    local m = serverTime.min
    local s = serverTime.sec
    local rTime = timeTable[1]
    for i = 1, #timeTable do
        if h > timeTable[i] then
            if i < #timeTable then
                rTime = timeTable[i+1]
            else
                rTime = timeTable[1]
            end
        end
    end

    local delayTime = {}
    if h >= timeTable[#timeTable] then
        delayTime.hour = (24 - h + rTime - 1) >= 10 and (24 - h + rTime - 1) or "0"..(24 - h + rTime - 1)
    else
        delayTime.hour = (rTime - h) >= 10 and (rTime - h) or "0"..(rTime - h)
    end
    delayTime.min = (59 - m) >= 10 and (59 - m) or "0"..(59 - m)
    delayTime.sec = (59 - s) >= 10 and (59 - s) or "0"..(59 - s)

    local timeLabel = CSResourceMgr.getNodeByName(resName, "refresh_time")
    CSResourceMgr.setLabelStringByNode(timeLabel, delayTime.hour..":"..delayTime.min..":"..delayTime.sec, outlineColor[3])

    timeLabel:performWithDelay(function ()
        CSResourceMgr.setLabelStringByNode(timeLabel, delayTime.hour..":"..delayTime.min..":"..delayTime.sec)
        ArenaExchangeMgr.refreshTimeLeft()
        if delayTime.hour == 0 and delayTime.min == 0 and delayTime.sec == 0 then
            NetInterface.sendWithBlock("GC_SYSTEMREFRESHGOODS_ACK",function()
                local CommonShopSend = require("src.Net.Send.CommonShopSend")
                CommonShopSend.sendCG_SystemRefreshGoods_Req({type = 1,})
            end,function()
                ArenaExchangeMgr.refreshItemNodes()
            end,function()
            end)
        end
    end, 1)
end

function ArenaExchangeMgr.hide()
    itemNodes = {}
    refreshInfo = {}
    -- ArenaExchangeMgr.shopItems = {}
    -- ArenaExchangeMgr.refreshCount = nil
    -- ArenaExchangeMgr.shopResetTime = nil
    -- ArenaExchangeMgr.systemReflashTime = nil
    UnblockLoader.cancel("ArenaExchangeMgr")
    if CSResourceMgr.getCsbObj(resName) then
        CSResourceMgr.getNodeByName(resName, "list"):removeAllItems()
    end
    CSResourceMgr.removeCSObjectByTag(resName)
end

return ArenaExchangeMgr