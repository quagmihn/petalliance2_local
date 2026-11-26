local VipShopViewMgr = {}

local resName = ""
local vipNodes = {}
local res = nil
local itemInfoTable = {}

local refreshNode = nil
local refreshMarketInfo = nil

VipShopViewMgr.DiscountPicPath = {
    "UI/CommonFiles/remark1.png",
    "UI/CommonFiles/remark2.png",
}

local labelColor = {
    {r=244,g=211,b=33 ,a=255},
    {r=189,g=231,b=252,a=255},
    {r=215,g=224,b=225,a=255},
    {r=255,g=246,b=0  ,a=255},
    {r=71 ,g=96 ,b=103,a=255},
    {r=236,g=253,b=255,a=255},
    {r=255,g=0  ,b=0  ,a=255},
}

local outlineColor = {
    {r=0,g=0,b=0,a=255,w=1,s=1},
    {r=0,g=0,b=0,a=255,w=2},
    {r=8,g=12,b=15,a=255,w=1},
    {r=103,g=113,b=121,a=255,w=1},
}

function VipShopViewMgr.Init()
    resName = "Item/Purchase/vipShopListView.csb"
    vipNodes = {}
    res = nil
    refreshNode = nil
    refreshMarketInfo = nil
end

function VipShopViewMgr.hide()
    vipNodes = {}
    res = nil
    UnblockLoader.cancel("VipShopViewMgr")
    CSResourceMgr.removeCSObjectByTag(resName)
end

function VipShopViewMgr.request(listNode, onLoaded)
    local shopList = VipShopViewMgr.getVipShopList()
    local goodsIDList = {"vipShopUnlimited"}
    for k,v in pairs(shopList) do
        table.insert(goodsIDList, "buyMarketItemNum_"..v.id)
        table.insert(goodsIDList, "buyMarketItemTime_"..v.id)
    end
    NetInterface.sendWithBlock("GC_GetCharacterValues_Ack", function()
        local LoginSend = require("src.Net.Send.LoginSend")
        LoginSend.sendCG_GetCharacterValues_Req(goodsIDList) --petPacketNum
    end, function()
        VipShopViewMgr.createVipList(listNode)
        if onLoaded then onLoaded() end
    end, function(code)
        TipsMgr.showError(SceneMgr.getRunningScene, code)
    end)
end

function VipShopViewMgr.getVipShopList()
    local marketList = ItemInfo.getAllMarketInfo()
    local shopList = {}
    for k,v in pairs(marketList) do
        if v.marketType == 4 then
            table.insert(shopList, v)
        end
    end
    return shopList
end

function VipShopViewMgr.createVipList(listNode)
    if PurchaseViewMgr.showVipShopRedPoint == true then
        PurchaseViewMgr.showVipShopRedPoint = false
        PurchaseViewMgr.setRedPoint()
    end

    local funcTable = {}
    res = CSResourceMgr.createRes(nil, resName)
    local shopList = VipShopViewMgr.getVipShopList()
    listNode:removeAllItems()
    for i = 1, #shopList do
        -- table.insert(funcTable, function()
            vipNodes[i] = CSResourceMgr.getNodeByName(resName, "btn_node"):clone()
            VipShopViewMgr.refreshVipListNode(vipNodes[i], shopList[i])
            listNode:pushBackCustomItem(vipNodes[i])
        -- end)
    end
    -- UnblockLoader.load(funcTable, "VipShopViewMgr")
end

function VipShopViewMgr.refreshVipListNode(parent, marketInfo)
    local background1 = CSResourceMgr.seekNodeByName(parent, "pic_bg1")
    local background2 = CSResourceMgr.seekNodeByName(parent, "pic_bg2")
    local background3 = CSResourceMgr.seekNodeByName(parent, "pic_bg3")
    local background4 = CSResourceMgr.seekNodeByName(parent, "pic_bg4")
    background1:setColor({r=128,g=161,b=172,a=255})
    background2:setColor({r=162,g=173,b=179,a=255})
    background3:setColor({r=71 ,g=96 ,b=103,a=255})
    background4:setColor({r=65 ,g=110,b=138,a=255})

    local needResCnt = marketInfo.num
    local needResType = marketInfo.coinType
    local itemID = marketInfo.itemID
    local buyMax = marketInfo.buyMax
    local needVipLv = marketInfo.vip
    local isVipEnough = CharInfo.getVipInfoByID(CharInfo.getVIPLevel()).viplevel >= needVipLv
    local currBuyTimes = CharInfo.getVipShopGoodsInfo()[tostring("buyMarketItemNum_"..marketInfo.id)] or 0
    local lastBuyTime = CharInfo.getVipShopGoodsInfo()[tostring("buyMarketItemTime_"..marketInfo.id)] or CharInfo.getServerTime()
    local offsetTime = SystemInfo.getGlobalConfigAddInfoByID(6900).values[1]
    -- local dayDiff = CocosModuleMgr.weekTimeDiff(lastBuyTime, CharInfo.getServerTime(), 1, offsetTime)
    local dayDiff = CocosModuleMgr.getWeekRefreshTime(lastBuyTime, 1, offsetTime) == CocosModuleMgr.getWeekRefreshTime(CharInfo.getServerTime(), 1, offsetTime) and 0 or 1
    if dayDiff ~= 0 then
        currBuyTimes = 0
    end
    local oldNum = marketInfo.oldNum
    local tag = marketInfo.tag
    local resPath = BuyItemViewMgr.coinTexture[needResType].texture
    local itemInfo = ItemInfo.getItemInfoById(itemID)
    local tagPath = "empty.png"
    if tag then
        if tag == "remai" then
            tagPath = VipShopViewMgr.DiscountPicPath[2]
        elseif tag == "zhekou" then
            tagPath = VipShopViewMgr.DiscountPicPath[1]
        end
    end

    local resCnt = 0
    if needResType == 1 then
        resCnt = CharInfo.getGCash()
    elseif needResType == 2 then
        resCnt = CharInfo.getMCash()
    elseif needResType == 3 then
        resCnt = CharInfo.getSilverCash()
    end

    local itemNode      = CSResourceMgr.seekNodeByName(parent, "node_icon")
    local labelVipLv    = CSResourceMgr.seekNodeByName(parent, "txt_needVip")
    local labelName     = CSResourceMgr.seekNodeByName(parent, "txt_name")
    local labelOldPrice = CSResourceMgr.seekNodeByName(parent, "txt_oldPrice")
    local labelNewPrice = CSResourceMgr.seekNodeByName(parent, "txt_nowPrice")
    local labelDesc     = CSResourceMgr.seekNodeByName(parent, "txt_desc")
    local labelTimes    = CSResourceMgr.seekNodeByName(parent, "txt_times")
    local spriteRes     = CSResourceMgr.seekNodeByName(parent, "pic_diamon")
    local spriteTag     = CSResourceMgr.seekNodeByName(parent, "pic_zhekou")
    local spriteLine    = CSResourceMgr.seekNodeByName(parent, "pic_line")

    local unlimited = CharInfo.get().vipshopunlimited == true
    local available = buyMax - currBuyTimes
    local strBuyTimes = buyMax - currBuyTimes > 0 and LuaSqlite.getLanguageByKey("vipshop3")..buyMax-currBuyTimes.."/"..buyMax or "vipshop4"

    CSResourceMgr.setLabelStringByNode(labelVipLv, CocosModuleMgr.createStringWithFormat({"vipshop1", needVipLv}), outlineColor[2], 1, 100)
    CSResourceMgr.setLabelStringByNode(labelName, itemInfo.name, outlineColor[1], 1, 208)
    CSResourceMgr.setLabelStringByNode(labelOldPrice, LuaSqlite.getLanguageByKey("vipshop2")..oldNum, outlineColor[1], 1, 104)
    CSResourceMgr.setLabelStringByNode(labelNewPrice, needResCnt, outlineColor[1], 1, 78)
    CSResourceMgr.setLabelStringByNode(labelDesc, itemInfo.desc)
    CSResourceMgr.setLabelStringByNode(labelTimes, strBuyTimes, outlineColor[1], 1, 120)

    CSResourceMgr.setLabelColorByNode(labelVipLv,    isVipEnough == true and labelColor[1] or labelColor[7])
    CSResourceMgr.setLabelColorByNode(labelName,     labelColor[2])
    CSResourceMgr.setLabelColorByNode(labelOldPrice, labelColor[3])
    CSResourceMgr.setLabelColorByNode(labelNewPrice, labelColor[4])
    CSResourceMgr.setLabelColorByNode(labelDesc,     labelColor[5])
    CSResourceMgr.setLabelColorByNode(labelTimes,    buyMax-currBuyTimes > 0 and labelColor[6] or labelColor[7])
    labelTimes:setVisible(isVipEnough and not unlimited)
    background4:setVisible(isVipEnough and not unlimited)

    CSResourceMgr.setSpriteTextureByNode(spriteTag, tagPath)
    CSResourceMgr.setSpriteTextureByNode(spriteRes, resPath)
    spriteRes:setScale(BuyItemViewMgr.coinTexture[needResType].scale)
    spriteLine:setContentSize(labelOldPrice:getContentSize().width + 5, spriteLine:getContentSize().height)
    spriteLine:setColor({r=215,g=224,b=225,a=255})

    CSResourceMgr.setLabelMaxWidthByNode(labelDesc, 432)
    labelDesc:setAnchorPoint(0, 0.5)
    labelDesc:setPositionY(66)

    CSResourceMgr.clickEventBindingByNode(parent, function ()
        if isVipEnough == false then
            StandardTipsMgr.show(1, "NetErrorText388")
        elseif resCnt < needResCnt then
            StandardTipsMgr.show(1, BuyItemViewMgr.tipsType[needResType])
        elseif not unlimited and available <= 0 then
            StandardTipsMgr.show(1, "exchange066")
        else
            refreshNode = parent
            refreshMarketInfo = marketInfo
            BuyItemViewMgr.show(SceneMgr.getRunningScene, itemID, needResType, needResCnt, unlimited and 99 or available, marketInfo.id)
        end
    end)

    local iNode = ItemInfo.getItemIconById(itemID, nil)
    -- CSResourceMgr.setButtonTextureByNode(itemNode, "empty.png","empty.png","empty.png")
    iNode:setPosition(0, 0)
    iNode:removeFromParent()
    iNode:addTo(itemNode)
    iNode:setScale(100 / iNode:getContentSize().width)
end

function VipShopViewMgr.onBuySuccess(chooseNum)
    if refreshNode and refreshMarketInfo then
        VipShopViewMgr.refreshVipListNode(refreshNode, refreshMarketInfo)
    end
end

function VipShopViewMgr.getVipShopRedPointState()
    for k,v in pairs(VipShopViewMgr.getVipShopList()) do
        local needResCnt = v.num
        local needResType = v.coinType
        local itemID = v.itemID
        local buyMax = v.buyMax
        local needVipLv = v.vip
        local isVipEnough = CharInfo.getVipInfoByID(CharInfo.getVIPLevel()).viplevel >= needVipLv
        local currBuyTimes = CharInfo.getVipShopGoodsInfo()[tostring("buyMarketItemNum_"..v.id)] or 0
        local lastBuyTime = CharInfo.getVipShopGoodsInfo()[tostring("buyMarketItemTime_"..v.id)] or CharInfo.getServerTime()
        local offsetTime = SystemInfo.getGlobalConfigAddInfoByID(6900).values[1]
        -- local dayDiff = CocosModuleMgr.weekTimeDiff(lastBuyTime, CharInfo.getServerTime(), 1, offsetTime)
        local dayDiff = CocosModuleMgr.getWeekRefreshTime(lastBuyTime, 1, offsetTime) == CocosModuleMgr.getWeekRefreshTime(CharInfo.getServerTime(), 1, offsetTime) and 0 or 1
        if dayDiff ~= 0 then
            currBuyTimes = 0
        end
        local resCnt = 0
        if needResType == 1 then
            resCnt = CharInfo.getGCash()
        elseif needResType == 2 then
            resCnt = CharInfo.getMCash()
        elseif needResType == 3 then
            resCnt = CharInfo.getSilverCash()
        end
        if isVipEnough == true and (CharInfo.get().vipshopunlimited == true or buyMax - currBuyTimes > 0) and resCnt >= needResCnt then
            return true
        end
    end
    return false
end

return VipShopViewMgr