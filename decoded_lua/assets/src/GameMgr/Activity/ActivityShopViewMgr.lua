local ActivityShopViewMgr = {}

local resName = ""
local resNameBG = ""
local parentNodes = {}
local itemNodes = {}
local goodsList = {}
local activityShopInfo = {}
local npcNode = nil
local iconNodes = {}

ActivityShopViewMgr.ROW = 3--列
ActivityShopViewMgr.lastBuyTime = {}
ActivityShopViewMgr.buyItemList = {}

ActivityShopViewMgr.buyGoodsID = 0
ActivityShopViewMgr.buyCount = 0
ActivityShopViewMgr.spendRes = 0

ActivityShopViewMgr.AtmospherePath = {
    "Activity/Atmosphere/Atmosphere_1.png",
    "Activity/Atmosphere/Atmosphere_2.png",
}

function ActivityShopViewMgr.checkIsActivityShopActive()
    if ActivityShopViewMgr.checkIsActive() == true then
        npcNode = NpcMgr.addNPC(102, nil, nil, function ()
            ActivityShopViewMgr.request()
        end)
    else
        if npcNode ~= nil then
            NpcMgr.moveNPC(npcNode.node)
            npcNode = nil
        end
    end
end

function ActivityShopViewMgr.Init()
    resName = "Activity/ActivityShop.csb"
    resNameBG = "Pet/Formation/FormationBGNew.csb"
    parentNodes = {}
    itemNode = {}
    iconNodes = {}
    goodsList = ActivityInfo.getActivityShopAllInfo()

    local tabTable, activityParams = ActivityViewMgr.getActivitiesData()
    for k,v in pairs(tabTable) do
        for k1,v1 in pairs(v) do
            if v1.type == ActivityInfo.ActivityShop then
                activityShopInfo = v1
                break
            end
        end
    end
end

function ActivityShopViewMgr.checkPointValid()
    if not activityShopInfo or not activityShopInfo.beginTime or not activityShopInfo.lastTime then
        return false
    end
    local updateTime = CharInfo.get().updateactivitypointtime or 0
    if activityShopInfo.beginTime>updateTime then
    	return false
    end
    return true
end

function ActivityShopViewMgr.hide()
    UnblockLoader.cancel("ActivityShopViewMgr")

    ActivityShopViewMgr.buyGoodsID = 0
    ActivityShopViewMgr.buyCount = 0
    local list = CSResourceMgr.getNodeByName(resName, "list")
    if list then
        list:removeAllItems()
    end
    parentNodes = {}
    itemNode = {}
    iconNodes = {}
    CSResourceMgr.removeCSObjectByTag(resName)
    CSResourceMgr.removeCSObjectByTag(resNameBG, "ActivityShopViewMgr")
    UIStack.pop("ActivityShopViewMgr")
end

function ActivityShopViewMgr.request()
    if not NetInterface.isConnect then
        return
    end
    local function requestActivityShopData()
        NetInterface.sendWithBlock("GC_GetSelfActivityShopData_Ack", function ()
            local ActivitySend = require("src.Net.Send.ActivitySend")
            ActivitySend.sendCG_GetSelfActivityShopData_Req()
        end, function()
            if ActivityShopViewMgr.checkBuyTime(ActivityShopViewMgr.lastBuyTime) == false then
                ActivityShopViewMgr.buyItemList = {}
            end
            ActivityShopViewMgr.show(SceneMgr.getRunningScene)
        end, function(code)
            print("error code : ", code)
        end)
    end
    local function requestActivityPoint()
        NetInterface.sendWithBlock("GC_GetCharacterValues_Ack", function()
            local LoginSend = require("src.Net.Send.LoginSend")
            LoginSend.sendCG_GetCharacterValues_Req({
                "activityPoint", "updateActivityPointTime"})
        end, function()
            requestActivityShopData()
        end, function(code)
            StandardTipsMgr.show(1,"getPetEquip failed code="..code)
        end)
    end
    requestActivityPoint()
end

function ActivityShopViewMgr.show(scene)
    UIStack.push("ActivityShopViewMgr", ActivityShopViewMgr.hide, true)

    local function init()
        ActivityShopViewMgr.spendRes = 0
    end

    local function loadCSB()
        local curLayerBG = CSResourceMgr.createRes(scene, resNameBG, "ActivityShopViewMgr")
        curLayerBG:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resNameBG, 320, 480, "ActivityShopViewMgr")

        local layer = CSResourceMgr.createRes(scene, resName)
        layer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setFullScreen(resName)
        CSResourceMgr.setRelativePosition(resName, 320, 480)

        CSResourceMgr.getNodeByName(resName,"item_name"):setFontSize(20)
        CSResourceMgr.getNodeByName(resName,"txt_desc"):setFontSize(22)

        local btnBG = CSResourceMgr.getNodeByName(resName, "btn_bg1")
        btnBG:setVisible(false)

        local btnClose = CSResourceMgr.getNodeByName(resName, "btn_close")
        CSResourceMgr.clickEventBindingByNode(btnClose, function() 
            ActivityShopViewMgr.hide()
        end)

        local panel = CSResourceMgr.getNodeByName(resName, "panel")
        panel:setVisible(false)
    end

    local function loadUI()
        -- local atmosphere1    = CSResourceMgr.getNodeByName(resName, "pic_icon1")
        -- local atmosphere2    = CSResourceMgr.getNodeByName(resName, "pic_icon2")
        -- CSResourceMgr.setSpriteTextureByNode(atmosphere1, ActivityShopViewMgr.AtmospherePath[1])
        -- CSResourceMgr.setSpriteTextureByNode(atmosphere2, ActivityShopViewMgr.AtmospherePath[2])

        local labelTitle     = CSResourceMgr.getNodeByName(resName, "txt_title")
        local labelTimeTitle = CSResourceMgr.getNodeByName(resName, "txt_time_tilte")
        local labelDesc      = CSResourceMgr.getNodeByName(resName, "txt_desc")

        CSResourceMgr.setLabelStringByNode(labelTitle, "activity77", {r=0,g=0,b=0,a=255,w=1,s=3})
        CSResourceMgr.setLabelStringByNode(labelTimeTitle, "activity78", {r=0,g=0,b=0,a=255,w=1,s=2})
        CSResourceMgr.setLabelStringByNode(labelDesc, "activity79", {r=0,g=0,b=0,a=255,w=1,s=2})

        CSResourceMgr.setLabelColorByNode(labelTitle,   {r=254,g=234,b=0,a=255})
        CSResourceMgr.setLabelColorByNode(labelTimeTitle, {r=119,g=204,b=245,a=255})
        CSResourceMgr.setLabelColorByNode(labelDesc, {r=120,g=144,b=178,a=255})

        ActivityShopViewMgr.refreshRes()
        ActivityShopViewMgr.createItemNodes()
        ActivityShopViewMgr.setTimeLeft()
    end

    local function playAction()
        local panel = CSResourceMgr.getNodeByName(resName, "panel")
        panel:setVisible(true)
        CocosModuleMgr.showUIAnimation(panel, "down")
    end

    local funcTable = {init, loadCSB, loadUI, playAction}
    UnblockLoader.load(funcTable, "ActivityShopViewMgr")
end

function ActivityShopViewMgr.createItemNodes()
    local list = CSResourceMgr.getNodeByName(resName, "list")
    local parent = CSResourceMgr.getNodeByName(resName, "parent2")
    local diban = CSResourceMgr.getNodeByName(resName, "parent1")
    local item = CSResourceMgr.getNodeByName(resName, "item")
    list:removeAllItems()
    local itemCnt = PetEducationMgr.getTableLength(goodsList)
    local maxLine = math.ceil(itemCnt / ActivityShopViewMgr.ROW)
    for i = 1, maxLine do
        parentNodes[i] = parent:clone()
        local bg = diban:clone()
        -- parentNodes[i]:addTo(list)
        list:pushBackCustomItem(parentNodes[i])

        bg:addTo(parentNodes[i])
        bg:setVisible(true)
        bg:setColor({r=36,g=62,b=77})
        bg:setPosition(260, 100)
    end
    local idx = 1
    local index = 1
    local index2 = 1
    local diffX = 180
    for k,v in pairs(goodsList) do
        local line = math.ceil(index / ArenaExchangeMgr.ROW)
        local row = index % ActivityShopViewMgr.ROW == 0 and ActivityShopViewMgr.ROW or index % ActivityShopViewMgr.ROW
        itemNodes[index] = item:clone()
        itemNodes[index]:addTo(parentNodes[line])
        itemNodes[index]:setPositionX(260 + (row - 2) * diffX)
        itemNodes[index]:setPositionY(120)
        itemNodes[index]:setScale(0.93, 0.93)
        -- ActivityShopViewMgr.refreshItem(itemNodes[index], v, index, true)
        itemNodes[index]:setScale(0, 0)
        -- transition.scaleTo(itemNodes[index], {scale=0.93, time=0.2})
        itemNodes[index]:setVisible(false)
        index = index + 1
    end
    for k,v in pairs(goodsList) do
        list:performWithDelay(function ()
            ActivityShopViewMgr.refreshItem(itemNodes[index2], v, index2, true)
            transition.scaleTo(itemNodes[index2], {scale=0.93, time=0.2})
            itemNodes[index2]:setVisible(true)
            index2 = index2 + 1
        end, 0.06 * idx)
        idx = idx + 1
    end
end

function ActivityShopViewMgr.refreshItem(node, awardInfo, index, needCreateNewIcon)
    local id = awardInfo.id
    local itemID = awardInfo.itemID
    local maxBuyCnt = awardInfo.buyCount
    local price = awardInfo.price
    local currBuyCnt = 0
    for k,v in pairs(ActivityShopViewMgr.buyItemList) do
        if v.itemID == id then
            currBuyCnt = v.buyCount
            break
        end
    end
    local currMaxBuyCnt = maxBuyCnt - currBuyCnt
    local awardElementInfo = ItemInfo.getAwardElementInfoById(itemID)
    local itemInfo, elementType = ActivityCapsuleEggView.getItemInfo(itemID)

    local labelName = CSResourceMgr.seekNodeByName(node, "item_name")
    local labelCost = CSResourceMgr.seekNodeByName(node, "item_cost")
    local labelCnt  = CSResourceMgr.seekNodeByName(node, "item_kucun")
    local iconNode  = CSResourceMgr.seekNodeByName(node, "item_node")
    local bg1       = CSResourceMgr.seekNodeByName(node, "item_background_1")
    local bg2       = CSResourceMgr.seekNodeByName(node, "item_background_3")
    local gray      = CSResourceMgr.seekNodeByName(node, "item_gray")
    local enoughRes = (CharInfo.getActivityPoint() - ActivityShopViewMgr.spendRes) >= price

    local strCnt = LuaSqlite.getLanguageByKey("activity80")..currMaxBuyCnt
    CSResourceMgr.setLabelStringByNode(labelName, itemInfo.name, {r=0,g=0,b=0,a=255,w=1,s=2},nil,120)
    CSResourceMgr.setLabelStringByNode(labelCost, price, {r=0,g=0,b=0,a=255,w=1,s=2})
    CSResourceMgr.setLabelStringByNode(labelCnt, strCnt, currMaxBuyCnt <= 0 and {r=0,g=0,b=0,a=255,w=1} or nil)

    CSResourceMgr.setLabelColorByNode(labelName, ItemInfo.COLOR[itemInfo.itemRare+1])
    CSResourceMgr.setLabelColorByNode(labelCost, enoughRes == false and {r=255,g=0,b=0,a=255} or {r=255,g=255,b=255,a=255})
    CSResourceMgr.setLabelColorByNode(labelCnt,  currMaxBuyCnt <= 0 and {r=255,g=0,b=0,a=255} or {r=36,g=62,b=79,a=255})

    gray:setColor({r=0,g=0,b=0})
    gray:setOpacity(153)
    gray:setVisible(enoughRes == false)

    bg1:setColor({r=128,g=160,b=171})
    bg2:setColor({r=12,g=30,b=44})

    local pokeID = 0
    if elementType == Proto.AET_PET then
        pokeID = awardElementInfo.elementID
    end

    if needCreateNewIcon == nil or needCreateNewIcon == true then
        iconNodes[index] = elementType ~= Proto.AET_PET and ItemInfo.getItemIconById(itemInfo.id, nil) or ItemInfo.getPetIconById2(pokeID)
        iconNodes[index]:setPosition(0, -5)
        iconNodes[index]:removeFromParent()
        iconNodes[index]:addTo(iconNode)
        iconNodes[index]:setScale(0.6)
    end

    CSResourceMgr.longtouchEventBindingByNode(iconNodes[index], function ()
        if elementType == Proto.AET_PET then
            PetInfoViewMgr.show(SceneMgr.getRunningScene, pokeID)
        else
            ItemInfoViewMgr.show(itemInfo, false)
        end
    end, function ()
        if currMaxBuyCnt <= 0 then
            StandardTipsMgr.show(1, "activity100")
        elseif enoughRes == false then
            StandardTipsMgr.show(1, "activity81")
        else
            BuyItemViewMgr.showActivityShop(SceneMgr.getRunningScene, itemInfo.id, 4, price, currMaxBuyCnt, id, pokeID)
        end
    end)

    CSResourceMgr.longtouchEventBindingByNode(node, function ()
        if elementType == Proto.AET_PET then
            PetInfoViewMgr.show(SceneMgr.getRunningScene, pokeID)
        else
            ItemInfoViewMgr.show(itemInfo, false)
        end
    end, function ()
        if currMaxBuyCnt <= 0 then
            StandardTipsMgr.show(1, "activity100")
        elseif enoughRes == false then
            StandardTipsMgr.show(1, "activity81")
        else
            BuyItemViewMgr.showActivityShop(SceneMgr.getRunningScene, itemInfo.id, 4, price, currMaxBuyCnt, id, pokeID)
        end
    end)
end

function ActivityShopViewMgr.refreshRes()
    local labelRes = CSResourceMgr.getNodeByName(resName, "txt_res")
    CSResourceMgr.setLabelStringByNode(labelRes, CharInfo.getActivityPoint() - ActivityShopViewMgr.spendRes)
    CSResourceMgr.setLabelColorByNode(labelRes, {r=255,g=255,b=255,a=255})
end

function ActivityShopViewMgr.onBuyItemSuccess()
    local haveInsert = false
    for k,v in pairs(ActivityShopViewMgr.buyItemList) do
        if v.itemID == ActivityShopViewMgr.buyGoodsID then
            v.buyCount = v.buyCount + ActivityShopViewMgr.buyCount
            haveInsert = true
            break
        end
    end
    if haveInsert == false then
        local tab = {itemID = ActivityShopViewMgr.buyGoodsID, buyCount = ActivityShopViewMgr.buyCount}
        table.insert(ActivityShopViewMgr.buyItemList, tab)
    end
    local index = 1
    for k,v in pairs(goodsList) do
        ActivityShopViewMgr.refreshItem(itemNodes[index], v, index, false)
        index = index + 1
    end
    -- ActivityShopViewMgr.createItemNodes()
    ActivityShopViewMgr.refreshRes()
end

function ActivityShopViewMgr.setTimeLeft()
    local labelTime = CSResourceMgr.getNodeByName(resName, "txt_time")
    local loginTime = CharInfo.getServerTime()
    local lastTime = activityShopInfo.beginTime + activityShopInfo.lastTime
    local isPlat = true

    if platform ~= "windows" then
        if activityShopInfo.plat ~= "all" then
            if activityShopInfo.plat ~= platform then
                isPlat = false
            end
        end
    end
    if loginTime <= lastTime and loginTime >= activityShopInfo.beginTime and isPlat then
        local timeVec,str = ActivityHalloweenViewMgr.turnTimeDiff(lastTime)
        local t = 0
        if #timeVec > 1 then
            t = tonumber(timeVec[1]) * 10 + tonumber(timeVec[2])
        else
            t = tonumber(timeVec[1])
        end
        CSResourceMgr.setLabelStringByNode(labelTime, t.." "..str, {r=0,g=0,b=0,a=255,w=1,s=1})
        CSResourceMgr.setLabelColorByNode(labelTime, {r=254,g=234,b=0,a=255})
		if LuaSqlite.LANG_TYPE == 6 then
			labelTime:setPositionX(labelTime:getPositionX()+65)
		end
    end
end

function ActivityShopViewMgr.checkIsActive()
    if not activityShopInfo or not activityShopInfo.beginTime or not activityShopInfo.lastTime then
        return false
    end
    local loginTime = CharInfo.getServerTime()
    local lastTime = activityShopInfo.beginTime + activityShopInfo.lastTime
    local isPlat = true

    if platform ~= "windows" then
        if activityShopInfo.plat ~= "all" then
            if activityShopInfo.plat ~= platform then
                isPlat = false
            end
        end
    end
    if loginTime <= lastTime and loginTime >= activityShopInfo.beginTime and isPlat then
        return true
    end
    return false
end

--上次购买是否是当前活动时间内购买的物品
function ActivityShopViewMgr.checkBuyTime(lastBuyTime)
    local lastTime = activityShopInfo.beginTime + activityShopInfo.lastTime
    if lastBuyTime < activityShopInfo.beginTime or lastBuyTime > lastTime then
        return false
    end
    return true
end

return ActivityShopViewMgr