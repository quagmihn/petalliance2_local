local BuyItemViewMgr = {}

local resName = ""
local editBox = nil

local labelColor = {
    {r=144,g=238,b=255,a=255},
    {r=227,g=233,b=255,a=255},
    {r=217,g=234,b=255,a=255},
    {r=55 ,g=178,b=219,a=255}
}

local outlineColor = {
    {r=0  ,g=0  ,b=0  ,a=255,w=1},
    {r=38 ,g=54 ,b=76 ,a=255,w=1},
    {r=0  ,g=0  ,b=0  ,a=255,w=2},
}

local coinType = {
    "exchange074",
    "exchange075",
    "exchange058",
    "activity98",
}

BuyItemViewMgr.tipsType = {
    "tips13",
    "tips14",
    "tips61",
    "tips13",
    "MxbShoptips5",
    "MxbShoptips5"
}

BuyItemViewMgr.coinTexture = {
    [1] = {texture = "UI/CommonFiles/icon_jinbi.png", scale = 0.6},--金币
    [2] = {texture = "UI/CommonFiles/ico_lanzuan.png", scale = 0.6},--钻石
    [3] = {texture = "UI/CommonFiles/Icn_silvery_cash.png", scale = 1},--银币
    [4] = {texture = "UI/CommonFiles/activity_score_01.png", scale = 1},--活动积分
    [5] = {texture = "Pet/Education/icn_summon_01.png",scale = 0.6},--心愿币
    [6] = {texture = "Pet/Education/icn_dream_01.png",scale = 0.6},--梦想币
}

function BuyItemViewMgr.Init()
    resName = "Item/Auction/BuyInfo.csb"
    editBox = nil
end

function BuyItemViewMgr.hide()
    UnblockLoader.cancel("BuyItemViewMgr")
    GameAudio.playUISound("retract")
    CSResourceMgr.removeCSObjectByTag(resName)
    UIStack.pop("BuyItemViewMgr")
end

function BuyItemViewMgr.wishShopShow(scene, itemID, resType, price, maxCnt, shopType, shopIndex,itemCnt,callback) 
    UIStack.push("BuyItemViewMgr",BuyItemViewMgr.hide,false)
    if resType == 1 then
        resType = 5
    else
        resType = 6
    end
    local function loadCSB()
        local curLayer = CSResourceMgr.createRes(scene, resName)
        curLayer:setLocalZOrder(CocosModuleMgr.ZORDER_FLOAT)
        CSResourceMgr.setRelativePosition(resName, 320, 480)
    
        CSResourceMgr.getNodeByName(resName, "db"):setVisible(false)   
        CSResourceMgr.clickEventBinding(resName, "close", function()
            BuyItemViewMgr.hide()
        end) 
    end

    local function loadUI()
        local labelTitle    = CSResourceMgr.getNodeByName(resName, "txt_title")
        local labelNum      = CSResourceMgr.getNodeByName(resName, "txt_sellnum")
        local labelSTitle   = CSResourceMgr.getNodeByName(resName, "txt_uprice")
        local labelTTitle   = CSResourceMgr.getNodeByName(resName, "txt_allprice")
        local labelCoin     = CSResourceMgr.getNodeByName(resName, "txt_havemoney")
        local labelSPrice   = CSResourceMgr.getNodeByName(resName, "txt_upricenum")
        local labelTPrice   = CSResourceMgr.getNodeByName(resName, "txt_allpricenum")
        local labelHaveCoin = CSResourceMgr.getNodeByName(resName, "txt_allscoinnum")
        local btnBuy        = CSResourceMgr.getNodeByName(resName, "btn_buy")
        local fieldtextbg   = CSResourceMgr.getNodeByName(resName, "pic_fieldtextbg")
        local labelName     = CSResourceMgr.getNodeByName(resName, "name")
        local labelDesc     = CSResourceMgr.getNodeByName(resName, "usetip")
        local spriteRes     = {}
        for i = 1, 3 do
            spriteRes[i] = CSResourceMgr.getNodeByName(resName, "pic_silvercoin"..i)
            spriteRes[i]:loadTexture(BuyItemViewMgr.coinTexture[resType].texture)
            spriteRes[i]:setScale(BuyItemViewMgr.coinTexture[resType].scale)
        end

        local resCnt = 0
        if resType == 1 then
            resCnt = CharInfo.getGCash()
        elseif resType == 2 then
            resCnt = CharInfo.getMCash()
        elseif resType == 3 then
            resCnt = CharInfo.getSilverCash()
        elseif resType == 4 then
            resCnt = CharInfo.getActivityPoint()
        elseif resType == 5 then
            resCnt = BagViewMgr.getItemNum(9992)
        else
            resCnt = BagViewMgr.getItemNum(9993)
        end

        local itemInfo = ItemInfo.getItemInfoById(itemID)
        -- CSResourceMgr.setSpriteTexture(resName, "icdb", ItemInfo.getItemRareBGImage(itemID))
        -- CSResourceMgr.setSpriteTexture(resName, "icon", itemInfo.icon)
        local iNode = ItemInfo.getItemIconById(itemID, itemCnt)
        local iNodeParent = CSResourceMgr.getNodeByName(resName,"icon")
        local parentSize = iNodeParent:getContentSize()
        iNode:addTo(iNodeParent)
        iNode:setPosition(parentSize.width/2,parentSize.height/2) 
        iNode:setScale(0.7,0.7)

        CSResourceMgr.setLabelStringByNode(labelTitle, "exchange070", outlineColor[1])
        CSResourceMgr.setLabelStringByNode(labelNum, "exchange055", outlineColor[2], nil, 168)
        CSResourceMgr.setLabelStringByNode(labelSTitle, "exchange056", outlineColor[2], nil, 96)
        CSResourceMgr.setLabelStringByNode(labelTTitle, "exchange057", outlineColor[2], nil, 96)
        CSResourceMgr.setLabelStringByNode(labelCoin, coinType[resType], outlineColor[2])
        CSResourceMgr.setLabelStringByNode(labelSPrice, price, outlineColor[2])
        CSResourceMgr.setLabelStringByNode(labelHaveCoin, resCnt, outlineColor[2])
        CSResourceMgr.setLabelStringByNode(labelName, itemInfo.name, outlineColor[1])
        -- CSResourceMgr.setLabelStringByNode(labelDesc, itemInfo.desc)
        CSResourceMgr.setButtonStringByNode(btnBuy, "lifeSkill063", outlineColor[3])

        CSResourceMgr.setLabelColorByNode(labelTitle,       labelColor[1])
        CSResourceMgr.setLabelColorByNode(labelNum,         labelColor[1])
        CSResourceMgr.setLabelColorByNode(labelSTitle,      labelColor[1])
        CSResourceMgr.setLabelColorByNode(labelTTitle,      labelColor[1])
        CSResourceMgr.setLabelColorByNode(labelCoin,        labelColor[1])
        CSResourceMgr.setLabelColorByNode(labelSPrice,      labelColor[1])
        CSResourceMgr.setLabelColorByNode(labelTPrice,      labelColor[1])
        CSResourceMgr.setLabelColorByNode(labelHaveCoin,    labelColor[1])
        CSResourceMgr.setLabelColorByNode(labelName,        labelColor[4])
        -- CSResourceMgr.setLabelColorByNode(labelDesc,        labelColor[3])
        CSResourceMgr.setButtonStringColorByNode(btnBuy,    labelColor[2])

        local chooseNum = 1
        editBox = CocosModuleMgr.newTextEditor(fieldtextbg,"empty.png",140,36,75,18,24,50,"",2,function()         
            local number = editBox:getText()
            if tonumber(number) <= 0 then
                editBox:setText(1)
            else
                local maxCanBuyCnt = math.min(number, math.floor(resCnt / price), maxCnt)
                chooseNum = maxCanBuyCnt
            end
            editBox:setText(chooseNum)
            CSResourceMgr.setLabelStringByNode(labelTPrice, price * chooseNum, outlineColor[2])
        end)
        
        editBox:setText(chooseNum)
        CSResourceMgr.setLabelStringByNode(labelTPrice, price * chooseNum, outlineColor[2])

        CSResourceMgr.clickEventBindingByNode(btnBuy,function()
            if resCnt < price * chooseNum then
                StandardTipsMgr.show(1, BuyItemViewMgr.tipsType[resType])
            else
                local data = {type = shopType, index = shopIndex,buyCount = chooseNum}
                NetInterface.sendWithBlock("GC_BUYGOODS_ACK",function() 
                    local CommonShopSend =require("src.Net.Send.CommonShopSend")
                    CommonShopSend.sendCG_BuyGoods_Req(data)
                end,
                function()
                    GameAudio.playUISound("success")
                    TipsMgr.show(SceneMgr.getRunningScene, "LtTips6")
                    BuyItemViewMgr.hide()
                    
                    if callback then
                        callback(shopIndex+1,chooseNum)
                    end
                end,
                function(code)
                    print("buy item faild!!! ", code)
                end, nil, false)
            end
        end)
    end

    local function playAction()
        GameAudio.playUISound("popup")
        local db = CSResourceMgr.getNodeByName(resName, "db")
        db:setVisible(true)
        CocosModuleMgr.showUIAnimation(db, "down")
    end

    local funcTable = {loadCSB, loadUI, playAction}
    UnblockLoader.load(funcTable, "BuyItemViewMgr")
end

function BuyItemViewMgr.show(scene, itemID, resType, price, maxCnt, goodsID,callback)
    UIStack.push("BuyItemViewMgr",BuyItemViewMgr.hide,false)
    local function loadCSB()
        local curLayer = CSResourceMgr.createRes(scene, resName)
        curLayer:setLocalZOrder(CocosModuleMgr.ZORDER_FLOAT)
        CSResourceMgr.setRelativePosition(resName, 320, 480)
    
        CSResourceMgr.getNodeByName(resName, "db"):setVisible(false)   
        CSResourceMgr.clickEventBinding(resName, "close", function()
            BuyItemViewMgr.hide()
        end) 
    end

    local function loadUI()
        local labelTitle    = CSResourceMgr.getNodeByName(resName, "txt_title")
        local labelNum      = CSResourceMgr.getNodeByName(resName, "txt_sellnum")
        local labelSTitle   = CSResourceMgr.getNodeByName(resName, "txt_uprice")
        local labelTTitle   = CSResourceMgr.getNodeByName(resName, "txt_allprice")
        local labelCoin     = CSResourceMgr.getNodeByName(resName, "txt_havemoney")
        local labelSPrice   = CSResourceMgr.getNodeByName(resName, "txt_upricenum")
        local labelTPrice   = CSResourceMgr.getNodeByName(resName, "txt_allpricenum")
        local labelHaveCoin = CSResourceMgr.getNodeByName(resName, "txt_allscoinnum")
        local btnBuy        = CSResourceMgr.getNodeByName(resName, "btn_buy")
        local fieldtextbg   = CSResourceMgr.getNodeByName(resName, "pic_fieldtextbg")
        local labelName     = CSResourceMgr.getNodeByName(resName, "name")
        local labelDesc     = CSResourceMgr.getNodeByName(resName, "usetip")
        local spriteRes     = {}
        for i = 1, 3 do
            spriteRes[i] = CSResourceMgr.getNodeByName(resName, "pic_silvercoin"..i)
            spriteRes[i]:loadTexture(BuyItemViewMgr.coinTexture[resType].texture)
            spriteRes[i]:setScale(BuyItemViewMgr.coinTexture[resType].scale)
        end

        local resCnt = 0
        if resType == 1 then
            resCnt = CharInfo.getGCash()
        elseif resType == 2 then
            resCnt = CharInfo.getMCash()
        elseif resType == 3 then
            resCnt = CharInfo.getSilverCash()
        elseif resType == 4 then
            resCnt = CharInfo.getActivityPoint()
        elseif resType == 5 then
            resCnt = BagViewMgr.getItemNum(9992)
        else
            resCnt = BagViewMgr.getItemNum(9993)
        end

        local itemInfo = ItemInfo.getItemInfoById(itemID)
        CSResourceMgr.setSpriteTexture(resName, "icdb", ItemInfo.getItemRareBGImage(itemID))
        CSResourceMgr.setSpriteTexture(resName, "icon", itemInfo.icon)

        CSResourceMgr.setLabelStringByNode(labelTitle, "exchange070", outlineColor[1])
        CSResourceMgr.setLabelStringByNode(labelNum, "exchange055", outlineColor[2], nil, 168)
        CSResourceMgr.setLabelStringByNode(labelSTitle, "exchange056", outlineColor[2], nil, 96)
        CSResourceMgr.setLabelStringByNode(labelTTitle, "exchange057", outlineColor[2], nil, 96)
        CSResourceMgr.setLabelStringByNode(labelCoin, coinType[resType], outlineColor[2])
        CSResourceMgr.setLabelStringByNode(labelSPrice, price, outlineColor[2])
        CSResourceMgr.setLabelStringByNode(labelHaveCoin, resCnt, outlineColor[2])
        CSResourceMgr.setLabelStringByNode(labelName, itemInfo.name, outlineColor[1])
        -- CSResourceMgr.setLabelStringByNode(labelDesc, itemInfo.desc)
        CSResourceMgr.setButtonStringByNode(btnBuy, "lifeSkill063", outlineColor[3])

        CSResourceMgr.setLabelColorByNode(labelTitle,       labelColor[1])
        CSResourceMgr.setLabelColorByNode(labelNum,         labelColor[1])
        CSResourceMgr.setLabelColorByNode(labelSTitle,      labelColor[1])
        CSResourceMgr.setLabelColorByNode(labelTTitle,      labelColor[1])
        CSResourceMgr.setLabelColorByNode(labelCoin,        labelColor[1])
        CSResourceMgr.setLabelColorByNode(labelSPrice,      labelColor[1])
        CSResourceMgr.setLabelColorByNode(labelTPrice,      labelColor[1])
        CSResourceMgr.setLabelColorByNode(labelHaveCoin,    labelColor[1])
        CSResourceMgr.setLabelColorByNode(labelName,        labelColor[4])
        -- CSResourceMgr.setLabelColorByNode(labelDesc,        labelColor[3])
        CSResourceMgr.setButtonStringColorByNode(btnBuy,    labelColor[2])

        local chooseNum = 1
        editBox = CocosModuleMgr.newTextEditor(fieldtextbg,"empty.png",140,36,75,18,24,50,"",2,function()         
            local number = editBox:getText()
            if tonumber(number) <= 0 then
                editBox:setText(1)
            else
                local maxCanBuyCnt = math.min(number, math.floor(resCnt / price), maxCnt)
                chooseNum = maxCanBuyCnt
            end
            editBox:setText(chooseNum)
            CSResourceMgr.setLabelStringByNode(labelTPrice, price * chooseNum, outlineColor[2])
        end,false)
        
        editBox:setText(chooseNum)
        CSResourceMgr.setLabelStringByNode(labelTPrice, price * chooseNum, outlineColor[2])

        CSResourceMgr.clickEventBindingByNode(btnBuy,function()
            if resCnt < price * chooseNum then
                StandardTipsMgr.show(1, BuyItemViewMgr.tipsType[resType])
            else
                local data = {marketInfoID = goodsID, num = chooseNum}
                NetInterface.sendWithBlock("GC_BUYMARKETITEM_Ack",function() 
                    local buySend =require("src.Net.Send.MarketSend")
                    buySend.sendCG_BuyMarketItem_Req(data)
                end,
                function()
                    GameAudio.playUISound("success")
                    TipsMgr.show(SceneMgr.getRunningScene, "LtTips6")
                    BuyItemViewMgr.hide()
                    VipShopViewMgr.onBuySuccess(chooseNum)
                    if callback then
                        callback()
                    end
                end,
                function(code)
                    print("buy item faild!!! ", code)
                end, nil, false)
            end
        end)
    end

    local function playAction()
        GameAudio.playUISound("popup")
        local db = CSResourceMgr.getNodeByName(resName, "db")
        db:setVisible(true)
        CocosModuleMgr.showUIAnimation(db, "down")
    end

    local funcTable = {loadCSB, loadUI, playAction}
    UnblockLoader.load(funcTable, "BuyItemViewMgr")
end

function BuyItemViewMgr.showActivityShop(scene, itemID, resType, price, maxCnt, goodsID, pokeID)
    UIStack.push("BuyItemViewMgr",BuyItemViewMgr.hide,false)
    local function loadCSB()
        local curLayer = CSResourceMgr.createRes(scene, resName)
        curLayer:setLocalZOrder(CocosModuleMgr.ZORDER_FLOAT)
        CSResourceMgr.setRelativePosition(resName, 320, 480)
    
        CSResourceMgr.getNodeByName(resName, "db"):setVisible(false)   
        CSResourceMgr.clickEventBinding(resName, "close", function()
            BuyItemViewMgr.hide()
        end) 
    end

    local function loadUI()
        local labelTitle    = CSResourceMgr.getNodeByName(resName, "txt_title")
        local labelNum      = CSResourceMgr.getNodeByName(resName, "txt_sellnum")
        local labelSTitle   = CSResourceMgr.getNodeByName(resName, "txt_uprice")
        local labelTTitle   = CSResourceMgr.getNodeByName(resName, "txt_allprice")
        local labelCoin     = CSResourceMgr.getNodeByName(resName, "txt_havemoney")
        local labelSPrice   = CSResourceMgr.getNodeByName(resName, "txt_upricenum")
        local labelTPrice   = CSResourceMgr.getNodeByName(resName, "txt_allpricenum")
        local labelHaveCoin = CSResourceMgr.getNodeByName(resName, "txt_allscoinnum")
        local btnBuy        = CSResourceMgr.getNodeByName(resName, "btn_buy")
        local fieldtextbg   = CSResourceMgr.getNodeByName(resName, "pic_fieldtextbg")
        local labelName     = CSResourceMgr.getNodeByName(resName, "name")
        local labelDesc     = CSResourceMgr.getNodeByName(resName, "usetip")
        local spriteRes     = {}
        for i = 1, 3 do
            spriteRes[i] = CSResourceMgr.getNodeByName(resName, "pic_silvercoin"..i)
            spriteRes[i]:loadTexture(BuyItemViewMgr.coinTexture[resType].texture)
            spriteRes[i]:setScale(BuyItemViewMgr.coinTexture[resType].scale)
        end

        local resCnt = 0
        if resType == 1 then
            resCnt = CharInfo.getGCash()
        elseif resType == 2 then
            resCnt = CharInfo.getMCash()
        elseif resType == 3 then
            resCnt = CharInfo.getSilverCash()
        elseif resType == 4 then
            resCnt = CharInfo.getActivityPoint() - ActivityShopViewMgr.spendRes
        end

        local isPet = pokeID and pokeID ~= 0
        local bg = CSResourceMgr.getNodeByName(resName, "icdb")
        local itemInfo = {}
        if isPet == true then
            local iNode = ItemInfo.getPetIconById2(pokeID)
            iNode:setPosition(0, 0)
            iNode:removeFromParent()
            iNode:addTo(bg)
            iNode:setScale(0.6)
            itemInfo.name = PokemonInfo.getPokemonInfoByID(pokeID).name
        else
            itemInfo = ItemInfo.getItemInfoById(itemID)
            local itemtype = ItemInfo.getItemType(itemID)
            if itemtype == 4 then
                local iNode = ItemInfo.getItemIconById(itemID, nil)
                iNode:setPosition(0, 0)
                iNode:removeFromParent()
                iNode:addTo(bg)
                iNode:setScale(0.6)
            else
                CSResourceMgr.setSpriteTexture(resName, "icdb", ItemInfo.getItemRareBGImage(itemID))
                CSResourceMgr.setSpriteTexture(resName, "icon", itemInfo.icon)
            end
        end

        CSResourceMgr.setLabelStringByNode(labelTitle, "exchange070", outlineColor[1])
        CSResourceMgr.setLabelStringByNode(labelNum, "exchange055", outlineColor[2], nil, 168)
        CSResourceMgr.setLabelStringByNode(labelSTitle, "exchange056", outlineColor[2], nil, 96)
        CSResourceMgr.setLabelStringByNode(labelTTitle, "exchange057", outlineColor[2], nil, 96)
        CSResourceMgr.setLabelStringByNode(labelCoin, coinType[resType], outlineColor[2])
        CSResourceMgr.setLabelStringByNode(labelSPrice, price, outlineColor[2])
        CSResourceMgr.setLabelStringByNode(labelHaveCoin, resCnt, outlineColor[2])
        CSResourceMgr.setLabelStringByNode(labelName, itemInfo.name, outlineColor[1])
        -- CSResourceMgr.setLabelStringByNode(labelDesc, itemInfo.desc)
        CSResourceMgr.setButtonStringByNode(btnBuy, "lifeSkill063", outlineColor[3])

        CSResourceMgr.setLabelColorByNode(labelTitle,       labelColor[1])
        CSResourceMgr.setLabelColorByNode(labelNum,         labelColor[1])
        CSResourceMgr.setLabelColorByNode(labelSTitle,      labelColor[1])
        CSResourceMgr.setLabelColorByNode(labelTTitle,      labelColor[1])
        CSResourceMgr.setLabelColorByNode(labelCoin,        labelColor[1])
        CSResourceMgr.setLabelColorByNode(labelSPrice,      labelColor[1])
        CSResourceMgr.setLabelColorByNode(labelTPrice,      labelColor[1])
        CSResourceMgr.setLabelColorByNode(labelHaveCoin,    labelColor[1])
        CSResourceMgr.setLabelColorByNode(labelName,        labelColor[4])
        -- CSResourceMgr.setLabelColorByNode(labelDesc,        labelColor[3])
        CSResourceMgr.setButtonStringColorByNode(btnBuy,    labelColor[2])

        local chooseNum = 1
        editBox = CocosModuleMgr.newTextEditor(fieldtextbg,"empty.png",140,36,75,18,24,50,"",2,function()         
            local number = editBox:getText()
            if tonumber(number) <= 0 then
                editBox:setText(1)
            else
                local maxCanBuyCnt = math.min(number, math.floor(resCnt / price), maxCnt)
                chooseNum = maxCanBuyCnt
                if tonumber(number) > maxCanBuyCnt then
                    StandardTipsMgr.show(1, "activity100")
                end
            end
            editBox:setText(chooseNum)
            CSResourceMgr.setLabelStringByNode(labelTPrice, price * chooseNum, outlineColor[2])
        end)
        
        editBox:setText(chooseNum)
        CSResourceMgr.setLabelStringByNode(labelTPrice, price * chooseNum, outlineColor[2])

        CSResourceMgr.clickEventBindingByNode(btnBuy,function()
            if ActivityShopViewMgr.checkIsActive() == false then
                StandardTipsMgr.show(1, "activity92")
            elseif resCnt < price * chooseNum then
                StandardTipsMgr.show(1, BuyItemViewMgr.tipsType[resType])
            else
                local showTable = {}
                if isPet == false then
                    table.insert(showTable,{itemID, chooseNum})
                end
                local data = {itemID = goodsID, count = chooseNum}
                NetInterface.sendWithBlock("GC_BuyActivityShopItem_Ack",function() 
                    local ActivitySend = require("src.Net.Send.ActivitySend")
                    ActivitySend.sendCG_BuyActivityShopItem_Req(data)
                end,
                function()
                    ActivityShopViewMgr.buyGoodsID = goodsID
                    ActivityShopViewMgr.buyCount = chooseNum
                    ActivityShopViewMgr.spendRes = ActivityShopViewMgr.spendRes + chooseNum * price

                    GameAudio.playUISound("success")
                    TipsMgr.show(SceneMgr.getRunningScene, "LtTips6")
                    BuyItemViewMgr.hide()
                    ActivityShopViewMgr.onBuyItemSuccess()
                    if isPet == true then
                        GachaViewMgr.playGetAPet(pokeID)
                    else
                        AwardsListMgr.show(SceneMgr.getRunningScene, showTable)
                    end 
                end,
                function(code)
                    print("buy item faild!!! ", code)
                end, nil, false)
            end
        end)
    end

    local function playAction()
        GameAudio.playUISound("popup")
        local db = CSResourceMgr.getNodeByName(resName, "db")
        db:setVisible(true)
        CocosModuleMgr.showUIAnimation(db, "down")
    end

    local funcTable = {loadCSB, loadUI, playAction}
    UnblockLoader.load(funcTable, "BuyItemViewMgr")
end

return BuyItemViewMgr