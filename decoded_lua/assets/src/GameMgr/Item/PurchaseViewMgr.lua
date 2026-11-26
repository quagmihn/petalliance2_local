local PurchaseViewMgr = {}
PurchaseViewMgr.ROW = 2
PurchaseViewMgr.TAB_NUM = 2

local resName = ""
local resNameItem = ""
local resNameBG = ""
local itemNodes = {}
local monthCardInfo = {}
local vipAwardInfo = {}
local rechargeCDInfo = nil
local richLabelL = nil
local dayCount = 0
local compoundPetInfo = {}
local AwardSelectViewMgr = require("src.GameMgr.Item.AwardSelectViewMgr")
local scheduler = require("src.framework.scheduler")
local mCardHandler = nil
local curTab = 1
PurchaseViewMgr.showVipShopRedPoint = true

function PurchaseViewMgr.Init()
    resName = "Item/Purchase/purchaseLayer.csb"
    resNameMoon = "Item/Purchase/purchaseMoonCard.csb"
    resNameItem = "Item/Purchase/purchaseItem.csb"
    resNameBG = "Pet/Formation/FormationBGNew.csb"
    resNameTips = "Item/Purchase/purchaseTipsView.csb"
    itemNodes = {}
    monthCardInfo = {}
    vipAwardInfo = {}
    rechargeCDInfo = nil
    richLabelL = nil
    mCardHandler = nil
    dayCount = 0
    curTab = 1
    compoundPetInfo = {}
end

local iconPathVec1 = {
    "UI/CommonFiles/VIPMonthCard.png",
    "UI/CommonFiles/VIPSeasonCard.png",
    "UI/CommonFiles/60diamond.png",
    "UI/CommonFiles/300diamond.png",
    "UI/CommonFiles/980diamond.png",
    "UI/CommonFiles/1980diamond.png",
    "UI/CommonFiles/3280diamond.png",
    "UI/CommonFiles/6480diamond.png"
}

local iconPathVec2 = {
    "UI/CommonFiles/60diamond.png",
    "UI/CommonFiles/300diamond.png",
    "UI/CommonFiles/980diamond.png",
    "UI/CommonFiles/1980diamond.png",
    "UI/CommonFiles/3280diamond.png",
    "UI/CommonFiles/6480diamond.png"
}

function PurchaseViewMgr.setMonthCardInfo(vec)
    monthCardInfo = vec
end

function PurchaseViewMgr.getMonthCardInfo()
    if #monthCardInfo > 0 then
        return true
    else
        return false
    end
end

function PurchaseViewMgr.setVipAwardInfo(vec)
    vipAwardInfo = vec
end

function PurchaseViewMgr.setRechargeCDInfo(vec)
    rechargeCDInfo = vec
end

function PurchaseViewMgr.show(scene,callback,tab)
    if CSResourceMgr.getCsbObj(resName) then
        return
    end
    if not NetInterface.isConnect then
        return
    end
    NetInterface.sendWithBlock("GC_RechargeCD_Ack", function()
        local MonthCardSend = require("src.Net.Send.MonthCardSend")
        MonthCardSend.sendCG_RechargeCD_Req()
    end, function()
        NetInterface.sendWithBlock("ZC_LoadMonthCard_Ack", function()
            local MonthCardSend = require("src.Net.Send.MonthCardSend")
            MonthCardSend.sendCZ_LoadMonthCard_Req()
        end, function()
            NetInterface.sendWithBlock("GC_VipAwardInfo_Ack", function()
                local VipSend = require("src.Net.Send.VipSend")
                VipSend.sendCG_VipAwardInfo_Req()
            end, function()
                UIStack.push("PurchaseViewMgr", PurchaseViewMgr.hide, true)
                if not tab then
                    PurchaseViewMgr.open(scene,1)
                else
                    curTab = tab
                    PurchaseViewMgr.open(scene,tab)
                end
                if callback~=nil then 
                    callback()
                end
            end, function(code)
                TipsMgr.showError(scene, code)
            end)
        end, function(code)
            TipsMgr.showError(scene, code)
        end)
    end, function(code)
        TipsMgr.showError(scene, code)
    end)
end

function PurchaseViewMgr.open(scene,tab)

    local function loadBG()
        local bgLayer = CSResourceMgr.createRes(scene, resNameBG, "PurchaseViewMgr")
        bgLayer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resNameBG, 320, 480, "PurchaseViewMgr")
        bgLayer:setOpacity(0)
        transition.fadeIn(bgLayer, {time=0.3})
    end

    local function loadCSB()
        local curLayer = CSResourceMgr.createRes(scene, resName)
        curLayer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resName, 320, 480)
        CocosModuleMgr.setEdgeDistance(curLayer, nil, nil, nil, 0, false)

        local diff = CocosModuleMgr.getScreenSizeDiff()
        local background = CSResourceMgr.getNodeByName(resName, "background")
        local bgsize = background:getContentSize()
        background:setContentSize(bgsize.width, bgsize.height+diff)
        local list = CSResourceMgr.getNodeByName(resName, "list")
        local ltsize = list:getContentSize()
        list:setContentSize(ltsize.width, ltsize.height+diff)
        local list_vip = CSResourceMgr.getNodeByName(resName, "list_vip")
        local lt1size = list_vip:getContentSize()
        list_vip:setContentSize(lt1size.width, lt1size.height+diff)
        local topdb = CSResourceMgr.getNodeByName(resName, "topdb")
        local tpposy = topdb:getPositionY()
        topdb:setPositionY(tpposy+diff)
        local tabs = CSResourceMgr.getNodeByName(resName, "tabs")
        local tbposy = tabs:getPositionY()
        tabs:setPositionY(tbposy+diff)
        local title = CSResourceMgr.getNodeByName(resName, "title")
        local ttposy = title:getPositionY()
        title:setPositionY(ttposy+diff)

        PurchaseViewMgr.setRedPoint()

        CSResourceMgr.clickEventBinding(resName, "close", function()
            PurchaseViewMgr.hide()
        end)

        CSResourceMgr.clickEventBinding(resName, "powerBtn", function()
            PurchaseViewMgr.showVipTips()
        end)

        CSResourceMgr.setLabelString(resName, "title", "recharge11", "", {r=0,g=0,b=0,a=255})
        CSResourceMgr.setLabelColor(resName, "title", {r=129,g=233,b=249,a=255})
        CSResourceMgr.setLabelString(resName, "shoptitle", "recharge12", "", {r=0,g=0,b=0,a=255})
        CSResourceMgr.setLabelColor(resName, "shoptitle", {r=255,g=255,b=255,a=255})
        CSResourceMgr.setButtonString(resName, "powerBtn", "recharge13", "", {r=81,g=63,b=13,a=255})
        CSResourceMgr.setButtonStringColor(resName, "powerBtn", {r=255,g=249,b=190,a=255})
        CSResourceMgr.setLabelString(resName, "tabLB1", "recharge41", "", {r=0,g=0,b=0,a=255})
        CSResourceMgr.setLabelString(resName, "tabLB2", "recharge42", "", {r=0,g=0,b=0,a=255})
        local LoadingBar = CSResourceMgr.getNodeByName(resName, "LoadingBar")
        local totalmoney = 0
        if CharInfo.get().recharge then
            totalmoney = CharInfo.get().recharge.totalMoney or 0
        end
        local vipLv = CharInfo.getVIPLevel()
        local vipInfo = CharInfo.getVipInfoByID(vipLv)
        local nextVipInfo = nil
        if vipLv ~= SystemInfo.getGlobalConfigAddInfoByID(55).values[1] then
            nextVipInfo = CharInfo.getVipInfoByID(vipLv+1)
            CSResourceMgr.setLabelString(resName, "viptips", "VIP"..vipInfo.viplevel..CocosModuleMgr.createStringWithFormat({"recharge14",nextVipInfo.recharge-totalmoney})..nextVipInfo.viplevel, "", {r=0,g=0,b=0,a=255})
            CSResourceMgr.setLabelColor(resName, "viptips", {r=129,g=233,b=249,a=255})
            CSResourceMgr.setLabelString(resName, "barValue", totalmoney.."/"..nextVipInfo.recharge, "", {r=25,g=47,b=63,a=255})
            CSResourceMgr.setLabelColor(resName, "barValue", {r=255,g=255,b=255,a=255})
            LoadingBar:setPercent((totalmoney/nextVipInfo.recharge)*100)
        else
            CSResourceMgr.setLabelString(resName, "viptips", "VIP "..(SystemInfo.getGlobalConfigAddInfoByID(55).values[1]-1),"",{r=0,g=0,b=0,a=255})
            CSResourceMgr.setLabelColor(resName, "viptips", {r=129,g=233,b=249,a=255})
            CSResourceMgr.setLabelString(resName, "barValue", totalmoney.."/"..vipInfo.recharge, "", {r=25,g=47,b=63,a=255})
            CSResourceMgr.setLabelColor(resName, "barValue", {r=255,g=255,b=255,a=255})
            LoadingBar:setPercent(100)
        end
        PurchaseViewMgr.setPurchaseItem()

        local tabFrame = CSResourceMgr.getNodeByName(resName, "tabFrame")
        tabFrame:setLocalZOrder(2)
        for var=1, PurchaseViewMgr.TAB_NUM do
            if var == tab then
                local spriteTab = CSResourceMgr.getNodeByName(resName, "tab"..tab)
                spriteTab:setLocalZOrder(1)
                local posY = spriteTab:getPositionY()
                spriteTab:setPositionY(posY+3)
                spriteTab:setScale(1.1)
            end
            local spriteTab = CSResourceMgr.getNodeByName(resName, "tab"..var)
            CSResourceMgr.clickEventBinding(resName, "tab"..var, function()
                GameAudio.playUISound("sheetClick")
                spriteTab:setLocalZOrder(1)
                local posY = spriteTab:getPositionY()
                spriteTab:setPositionY(posY+3)
                spriteTab:setScale(1.1)
                if curTab ~= var then
                    local spriteTab = CSResourceMgr.getNodeByName(resName, "tab"..curTab)
                    spriteTab:setLocalZOrder(-1)
                    local posY = spriteTab:getPositionY()
                    spriteTab:setPositionY(posY-3)
                    spriteTab:setScale(1)
                end
                curTab = var
                PurchaseViewMgr.changeTab(var)
            end)
        end
        PurchaseViewMgr.changeTab(tab)
        local labelLB = CSResourceMgr.getNodeByName(resName, "tipsLB")
        CSResourceMgr.setLabelStringByNode(labelLB, "vipshop5")
        CSResourceMgr.setLabelColorByNode(labelLB, {r=129,g=233,b=249,a=255})
        if PurchaseViewMgr.showVipShopRedPoint == true and VipShopViewMgr.getVipShopRedPointState() == true then
            local btnVipShopPage = CSResourceMgr.getNodeByName(resName, "tab2")
            PetEducationMgr.createRedPoint(btnVipShopPage, "btnVipShopPage", 0.7, 0, 0, 6, 116, 38)
        end
        --[[
        if device.platform=="ios" then
            iOSFunction.LoadProducts(scene, function(products)
                for var=1, 5 do
                    CSResourceMgr.clickEventBinding(resName, "item"..var, function()
                        DialogBoxMgr.showSmallDialogBox(scene, 2, CocosModuleMgr.createStringWithFormat({"是否购买<<1>>？", productsInfo[var].title}), function()
                            iOSFunction.BuyItem(scene, var)
                        end)
                    end)
                    CSResourceMgr.setLabelString(resName, "price"..var, CocosModuleMgr.createStringWithFormat({"<1> / <2>", productsInfo[var].title, productsInfo[var].price}))
                end
            end)
        end
        ]]
    end

    local function playCSB()
        CocosModuleMgr.showUIAnimation(CSResourceMgr.getNodeByName(resName,"background"),"down")
        StatusBarMgr.showTopInfoBar(function()
            PurchaseViewMgr.hide()
        end)
    end

    local funcTable = {loadBG, loadCSB, playCSB}
    loadBG()
    loadCSB()
    playCSB()
end

function PurchaseViewMgr.changeTab(tabid)
    for var=1, PurchaseViewMgr.TAB_NUM do
        CSResourceMgr.setButtonEnabled(resName, "tab"..var, true)
    end
    CSResourceMgr.setButtonEnabled(resName, "tab"..tabid, false)

    local topdb = CSResourceMgr.getNodeByName(resName, "topdb")
    local list = CSResourceMgr.getNodeByName(resName, "list")
    local list_vip = CSResourceMgr.getNodeByName(resName, "list_vip")
    local tipsLB = CSResourceMgr.getNodeByName(resName, "tipsLB")
    if tabid == 1 then
        topdb:setVisible(true)
        list:setVisible(true)
        list_vip:setVisible(false)
        tipsLB:setVisible(false)
    else
        topdb:setVisible(false)
        list:setVisible(false)
        tipsLB:setVisible(true)
        list_vip:setVisible(true)
        list_vip:setPositionX(305)
        VipShopViewMgr.request(list_vip, function()
            tipsLB:setVisible(curTab == 2 and CharInfo.get().vipshopunlimited ~= true)
        end)
    end
end

function PurchaseViewMgr.hide()
    curTab = 1
    StatusBarMgr.hideTopInfoBar()
    itemNodes = {}
    -- monthCardInfo = {}
    vipAwardInfo = {}
    compoundPetInfo = {}
    local list = CSResourceMgr.getNodeByName(resName, "list")
    list:removeAllItems()
    CSResourceMgr.removeCSObjectByTag(resNameBG, "PurchaseViewMgr")
    CSResourceMgr.removeCSObjectByTag(resNameMoon)
    CSResourceMgr.removeCSObjectByTag(resNameTips)
	CSResourceMgr.removeCSObjectByTag(resName)
    UIStack.pop("PurchaseViewMgr")
end

function PurchaseViewMgr.setPurchaseItem()
    CSResourceMgr.createRes(CSResourceMgr.getCsbObj(resName), resNameItem):setPositionX(-1000)
    local list = CSResourceMgr.getNodeByName(resName, "list")
    list:removeAllItems()

    local mRechargeInfo = ItemInfo.getMonthCardRechargeInfoAllId()
    local nRechargeInfo = ItemInfo.getNormalRechargeInfoAllId()
    local totalmoney = 0
    if CharInfo.get().recharge then
        totalmoney = CharInfo.get().recharge.totalMoney or 0
    end
    local vipLv = CharInfo.getVIPLevel()
    local nextVipInfo = CharInfo.getVipInfoByID(vipLv+1)
    local vipInfoTable = CharInfo.getVipInfoAllId()

    local panelNodes = {}
    local visibleNormal = {}
    local orderedNormal = PurchaseViewMgr.sortRechargeInfo(nRechargeInfo)
    local catalogCount = #orderedNormal
    orderedNormal = PurchaseViewMgr.checkRechargeFun(orderedNormal)
    for i = 1, catalogCount do
        if orderedNormal[i] then table.insert(visibleNormal, orderedNormal[i]) end
    end
    local totalLine = math.ceil((#mRechargeInfo + #visibleNormal)/PurchaseViewMgr.ROW)
    local panel = CSResourceMgr.getNodeByName(resName, "panel")
    for i = 1, totalLine do
        panelNodes[i] = panel:clone()
        list:pushBackCustomItem(panelNodes[i])
    end

    local index = 1
    local diffX = 280
    local iconPathVec = iconPathVec2
    iconPathVec = iconPathVec1
    for k,v in pairs(mRechargeInfo) do
        local line = math.ceil(index / PurchaseViewMgr.ROW)
        local row = index % PurchaseViewMgr.ROW == 0 and PurchaseViewMgr.ROW or index % PurchaseViewMgr.ROW
        itemNodes[index] = CSResourceMgr.getNodeByName(resNameItem, "dbBtn"):clone()
        itemNodes[index]:addTo(panelNodes[line])
        itemNodes[index]:setPositionX(itemNodes[index]:getPositionX() + (row - 1) * diffX)

        local cover = CSResourceMgr.seekNodeByName(itemNodes[index], "cover")
        cover:setOpacity(130)
        cover:setColor({r=0,g=0,b=0,a=255})
        cover:setVisible(false)

        local icon = CSResourceMgr.seekNodeByName(itemNodes[index], "icon")
        CSResourceMgr.setSpriteTextureByNode(icon, iconPathVec[index])
        local tipsBG = CSResourceMgr.seekNodeByName(itemNodes[index], "tipsBG")
        tipsBG:setVisible(false)
        local tips = CSResourceMgr.seekNodeByName(itemNodes[index], "tips")
        tips:setVisible(false)
        local discount = CSResourceMgr.seekNodeByName(itemNodes[index], "discount")
        local subtitle = LuaSqlite.getLanguageByKey("recharge15")
        if subtitle:find("<1>", 1, true) then
            subtitle = CocosModuleMgr.createStringWithFormat({"recharge15",v.initMCash})
        else
            subtitle = subtitle:gsub("%d+", tostring(v.mCashPerDay), 1)
        end
        CSResourceMgr.setLabelStringByNode(discount, subtitle)
        local countDown = CSResourceMgr.seekNodeByName(itemNodes[index], "countDown")
        CSResourceMgr.setLabelStringByNode(countDown, "recharge40")
        local days = CSResourceMgr.seekNodeByName(itemNodes[index], "days")

        local price = CSResourceMgr.seekNodeByName(itemNodes[index], "price")
        CSResourceMgr.setLabelColorByNode(price, {r=255,g=255,b=255,a=255})
        --阿杜修改英文版显示
                if LuaSqlite.LANG_TYPE~= 1 then
                    CSResourceMgr.setLabelStringByNode(price, "$"..v.money/100, {r=93,g=55,b=4,a=255})
                else
                    CSResourceMgr.setLabelStringByNode(price, "$"..v.money/100, {r=93,g=55,b=4,a=255})
                end

        local name = CSResourceMgr.seekNodeByName(itemNodes[index], "name")
        CSResourceMgr.setLabelColorByNode(name, {r=255,g=255,b=255,a=255})
        CSResourceMgr.setLabelStringByNode(name, v.name, {r=19,g=69,b=98,a=255})

        local nameBG = CSResourceMgr.seekNodeByName(itemNodes[index], "nameBG")
        nameBG:setColor({r=27,g=82,b=116,a=255})
        local discountSign = CSResourceMgr.seekNodeByName(itemNodes[index], "discountSign")
        discountSign:setColor({r=41,g=75,b=101,a=255})

        local ownLabel = CSResourceMgr.seekNodeByName(itemNodes[index], "ownLabel")
        CSResourceMgr.setLabelColorByNode(ownLabel, {r=247,g=228,b=17,a=255})
        CSResourceMgr.setLabelStringByNode(ownLabel, "recharge16", {r=34,g=68,b=13,a=255})
        CSResourceMgr.setSpriteTextureByNode(ownsign,"UI/CommonFiles/frame_prompt_ribbon_green_su.png")

        for k1,v1 in pairs(monthCardInfo) do
            if v1.id == v.id then
                if v1.endTime > 0 then
                    local loginTime = CharInfo.getServerTime()
                    dayCount = CocosModuleMgr.getDayTimeDiff(loginTime, v1.endTime, 21600)
                    if dayCount >= 0 then
                        str = dayCount
                        countDown:setVisible(true)
                        days:setVisible(true)
                        discount:setVisible(false)
                        CSResourceMgr.setLabelStringByNode(days, CocosModuleMgr.createStringWithFormat({"recharge17",str}))
                    end
                end
            end
        end

        CSResourceMgr.clickEventBindingByNode(itemNodes[index], function()
            PurchaseViewMgr.showMoonCardTip(itemNodes[1],v)
        end,2)

        index = index + 1
    end

    for _,v in ipairs(visibleNormal) do
        local line = math.ceil(index / PurchaseViewMgr.ROW)
        local row = index % PurchaseViewMgr.ROW == 0 and PurchaseViewMgr.ROW or index % PurchaseViewMgr.ROW
        itemNodes[index] = CSResourceMgr.getNodeByName(resNameItem, "dbBtn"):clone()
        itemNodes[index]:addTo(panelNodes[line])
        itemNodes[index]:setPositionX(itemNodes[index]:getPositionX() + (row - 1) * diffX)

        local cover = CSResourceMgr.seekNodeByName(itemNodes[index], "cover")
        cover:setOpacity(130)
        cover:setColor({r=0,g=0,b=0,a=255})
        cover:setVisible(false)

        local icon = CSResourceMgr.seekNodeByName(itemNodes[index], "icon")
        CSResourceMgr.setSpriteTextureByNode(icon, iconPathVec[index])
        local tipsBG = CSResourceMgr.seekNodeByName(itemNodes[index], "tipsBG")
        tipsBG:setVisible(false)
        local tips = CSResourceMgr.seekNodeByName(itemNodes[index], "tips")
        tips:setVisible(false)
        local ownsign = CSResourceMgr.seekNodeByName(itemNodes[index], "ownsign")
        ownsign:setVisible(false)
        local discount = CSResourceMgr.seekNodeByName(itemNodes[index], "discount")
        local discountSign = CSResourceMgr.seekNodeByName(itemNodes[index], "discountSign")
        discountSign:setColor({r=41,g=75,b=101,a=255})

        if v.bonusRate ~= 0 then
            CSResourceMgr.setLabelStringByNode(discount, CocosModuleMgr.createStringWithFormat({"recharge18",v.mCash}))
        else
            if v.giftMCash ~= 0 then
                CSResourceMgr.setLabelStringByNode(discount, CocosModuleMgr.createStringWithFormat({"recharge19",v.giftMCash}))
            else
                discount:setVisible(false)
                discountSign:setVisible(false)
            end
        end

        if v.id == 10 or v.id == 11 then
            local ownLabel = CSResourceMgr.seekNodeByName(itemNodes[index], "ownLabel")
            CSResourceMgr.setLabelColorByNode(ownLabel, {r=247,g=228,b=17,a=255})
            CSResourceMgr.setLabelStringByNode(ownLabel, "recharge20", {r=34,g=68,b=13,a=255})
            local ownsign = CSResourceMgr.seekNodeByName(itemNodes[index], "ownsign")
            CSResourceMgr.setSpriteTextureByNode(ownsign,"UI/CommonFiles/frame_prompt_ribbon_blue_su.png")
            ownsign:setVisible(true)
            ownsign:setContentSize(240,42)
        end
        
        CSResourceMgr.clickEventBindingByNode(itemNodes[index], function()
            PayConfig.payLocal(v.id, false)
        end,2)

        local price = CSResourceMgr.seekNodeByName(itemNodes[index], "price")
        CSResourceMgr.setLabelColorByNode(price, {r=255,g=255,b=255,a=255})
        --阿杜修改英文版显示
        if LuaSqlite.LANG_TYPE~= 1 then
            CSResourceMgr.setLabelStringByNode(price, "$"..v.money/100, {r=93,g=55,b=4,a=255})
        else
            CSResourceMgr.setLabelStringByNode(price, "$"..v.money/100, {r=93,g=55,b=4,a=255})
        end

        local name = CSResourceMgr.seekNodeByName(itemNodes[index], "name")
        CSResourceMgr.setLabelColorByNode(name, {r=255,g=255,b=255,a=255})
        CSResourceMgr.setLabelStringByNode(name, v.name, {r=19,g=69,b=98,a=255})

        local nameBG = CSResourceMgr.seekNodeByName(itemNodes[index], "nameBG")
        nameBG:setColor({r=27,g=82,b=116,a=255})
        
        index = index + 1
    end
end

function PurchaseViewMgr.checkRechargeFun(nRechargeInfo)
    local timeStamp = 0
    local rechargeInfo = nil
    local loginTime = CharInfo.getServerTime()
    if rechargeCDInfo then
        if rechargeCDInfo.N2 then
            for k,v in pairs(rechargeCDInfo.N2.time) do
                timeStamp = PurchaseViewMgr.turnTimeData(v)
                rechargeInfo = ItemInfo.getNormalRechargeInfoById(2)
                if timeStamp + rechargeInfo.bonusCD*60 > loginTime then
                    nRechargeInfo[1] = nil
                else
                    nRechargeInfo[10] = nil
                end
            end
        else
            nRechargeInfo[10] = nil
        end

        if rechargeCDInfo.N5 then
            for k,v in pairs(rechargeCDInfo.N5.time) do
                timeStamp = PurchaseViewMgr.turnTimeData(v)
                rechargeInfo = ItemInfo.getNormalRechargeInfoById(5)
                if timeStamp + rechargeInfo.bonusCD*60 > loginTime then
                    nRechargeInfo[4] = nil
                else
                    nRechargeInfo[11] = nil
                end
            end
        else
            nRechargeInfo[11] = nil
        end

        if rechargeCDInfo.N8 then
            for k,v in pairs(rechargeCDInfo.N8.time) do
                timeStamp = PurchaseViewMgr.turnTimeData(v)
                rechargeInfo = ItemInfo.getNormalRechargeInfoById(8)
                if timeStamp + rechargeInfo.bonusCD*60 > loginTime then
                    nRechargeInfo[7] = nil
                else
                    nRechargeInfo[12] = nil
                end
            end
        else
            nRechargeInfo[12] = nil
        end
		
		if rechargeCDInfo.N4 then
            for k,v in pairs(rechargeCDInfo.N4.time) do
                timeStamp = PurchaseViewMgr.turnTimeData(v)
                rechargeInfo = ItemInfo.getNormalRechargeInfoById(4)
                if timeStamp + rechargeInfo.bonusCD*60 > loginTime then
                    nRechargeInfo[2] = nil
                else
                    nRechargeInfo[3] = nil
                end
            end
        else
            nRechargeInfo[3] = nil
        end
		
		if rechargeCDInfo.N7 then
            for k,v in pairs(rechargeCDInfo.N7.time) do
                timeStamp = PurchaseViewMgr.turnTimeData(v)
                rechargeInfo = ItemInfo.getNormalRechargeInfoById(7)
                if timeStamp + rechargeInfo.bonusCD*60 > loginTime then
                    nRechargeInfo[5] = nil
                else
                    nRechargeInfo[6] = nil
                end
            end
        else
            nRechargeInfo[6] = nil
        end
		
		if rechargeCDInfo.N10 then
            for k,v in pairs(rechargeCDInfo.N10.time) do
                timeStamp = PurchaseViewMgr.turnTimeData(v)
                rechargeInfo = ItemInfo.getNormalRechargeInfoById(10)
                if timeStamp + rechargeInfo.bonusCD*60 > loginTime then
                    nRechargeInfo[8] = nil
                else
                    nRechargeInfo[9] = nil
                end
            end
        else
            nRechargeInfo[9] = nil
        end
    else
        nRechargeInfo[3] = nil
        nRechargeInfo[6] = nil
        nRechargeInfo[9] = nil
		nRechargeInfo[10] = nil
		nRechargeInfo[11] = nil
		nRechargeInfo[12] = nil
    end
    return nRechargeInfo
end

local function setVipTipsLabel(vipID)
    local level = CharInfo.getVIPLevel()
    local vipInfo = CharInfo.getVipInfoByID(vipID)
    local nextVipInfo = nil
    local totalmoney = 0
    if CharInfo.get().recharge then
        totalmoney = CharInfo.get().recharge.totalMoney or 0
    end
    local tips = CSResourceMgr.getNodeByName(resNameTips, "tips")
    if level <= vipID and level ~= SystemInfo.getGlobalConfigAddInfoByID(55).values[1] then
        tips:setVisible(true)
    else
        tips:setVisible(false)
    end
    local leftBtn = CSResourceMgr.getNodeByName(resNameTips, "leftBtn")
    local rightBtn = CSResourceMgr.getNodeByName(resNameTips, "rightBtn")
    if vipID == 1 then
        leftBtn:setVisible(false)
    end
    if vipID == SystemInfo.getGlobalConfigAddInfoByID(55).values[1] then
        rightBtn:setVisible(false)
    else
        nextVipInfo = CharInfo.getVipInfoByID(vipID+1)
        CSResourceMgr.setLabelStringByNode(tips, CocosModuleMgr.createStringWithFormat({"recharge14",nextVipInfo.recharge-totalmoney})..nextVipInfo.viplevel)
    end
    local tipInfo = CSResourceMgr.getNodeByName(resNameTips, "tipInfo")
    tipInfo:removeAllChildren()
    richLabelL = CocosModuleMgr.createRichLabel(tipInfo, vipInfo.explain, 24, CSResourceMgr.LANG_FONT[LuaSqlite.LANG_TYPE] or CSResourceMgr.LANG_FONT[1], TownChatMgr.MAX_LABEL_WIDTH,nil,nil,nil,true)
    tipInfo:setString(" ")
    tipInfo:setTextAreaSize({width = 0, height = richLabelL.realHeight})
    tipInfo:ignoreContentAdaptWithSize(false)

    local getBtn = CSResourceMgr.getNodeByName(resNameTips, "getBtn")
    local canGet = true
    for k,v in pairs(vipAwardInfo) do
        if v == vipInfo.id then
            canGet = false
        end
    end
    if level < vipID then
        canGet = false
    end
    if canGet then
        CSResourceMgr.setButtonStringByNode(getBtn,"recharge26",{r=0,g=0,b=0,a=255})
        CSResourceMgr.setButtonEnabledByNode(getBtn, true)
    else
        if level >= vipID then
            CSResourceMgr.setButtonStringByNode(getBtn,"recharge27",{r=0,g=0,b=0,a=255})
        else
            CSResourceMgr.setButtonStringByNode(getBtn,"recharge26",{r=0,g=0,b=0,a=255})
        end
        CSResourceMgr.setButtonEnabledByNode(getBtn, false)
    end

    local dropInfo = AdventureInfo.getDropInfoByID(vipInfo.awardsID[1])
    local index = 1
    local awardsVec = {}
    for k,v in pairs(dropInfo.reNumber) do
        local rewardInfo = AdventureInfo.getRewardInfoByID(v)
        for k1,v1 in pairs(rewardInfo.element) do
            local awardElementInfo = ItemInfo.getAwardElementInfoById(v1)
            local itemInfo = nil
            local path = nil
            local itemInfoID = awardElementInfo.elementID
            if awardElementInfo.elementType == 1 then
                itemInfo = ItemInfo.getItemInfoById(9998)
                itemInfoID = 9998
                path = ItemInfo.getItemRareBGImage(itemInfoID)
            elseif awardElementInfo.elementType == 2 then
                itemInfo = ItemInfo.getItemInfoById(9999)
                itemInfoID = 9999
                path = ItemInfo.getItemRareBGImage(itemInfoID)
            elseif awardElementInfo.elementType == Proto.AET_PET then--宠物
                local pokeInfo = PokemonInfo.getPokemonInfoByID(awardElementInfo.elementID)
                itemInfo = {}
                itemInfo.icon = "Pet/PetIcon/"..pokeInfo.icon..".png"
                path = "Pet/BasicPetList_2/Stage/"..pokeInfo.rarePoint..".png"
            else
                itemInfo = ItemInfo.getItemInfoById(awardElementInfo.elementID)
                path = ItemInfo.getItemRareBGImage(itemInfoID)
            end

            local icon = CSResourceMgr.getNodeByName(resNameTips, "icon"..index)
            icon:setVisible(true)
            CSResourceMgr.setSpriteTextureByNode(icon, itemInfo.icon)

            local iconBG = CSResourceMgr.getNodeByName(resNameTips, "iconBG"..index)
            iconBG:setVisible(true)
            local petBG = CSResourceMgr.getNodeByName(resNameTips, "petBG"..index)
            petBG:setVisible(awardElementInfo.elementType == Proto.AET_PET)
            if awardElementInfo.elementType == Proto.AET_PET then
                CSResourceMgr.setSpriteTextureByNode(petBG, path)
                icon:setScale(0.8)
            else
                CSResourceMgr.setButtonTextureByNode(iconBG, path, path, path)
                icon:setScale(0.7)
            end
            CSResourceMgr.clickEventBindingByNode(iconBG, function()
                if awardElementInfo.elementType == Proto.AET_PET then
                    StatusBarMgr.hideTopInfoBar()
                    PetInfoViewMgr.show(SceneMgr.getRunningScene, awardElementInfo.elementID, function ()
                        StatusBarMgr.showTopInfoBar(function()
                            PurchaseViewMgr.hide()
                        end)
                    end)
                else
                    ItemInfoViewMgr.show({id = itemInfoID, sum = rewardInfo.nReward[k1]}, false)
                end
            end)

            local count = CSResourceMgr.getNodeByName(resNameTips, "count"..index)
            count:setVisible(true)
            CSResourceMgr.setLabelColorByNode(count, {r=255,g=255,b=255,a=255})
            CSResourceMgr.setLabelStringByNode(count, rewardInfo.nReward[k1], {r=0,g=0,b=0,a=255})
            if awardElementInfo.elementType ~= Proto.AET_PET then
                table.insert(awardsVec,{itemInfoID,rewardInfo.nReward[k1]})
            end
            index = index + 1
        end
    end

    local function sendProto(awardID)
        local params = {}
        local vec = {}
        if awardID then
            table.insert(vec,awardID)            
        end
        params.id = vipInfo.id
        params.awardID = vec
        NetInterface.sendWithBlock("GC_GetVipAward_Ack", function()
            local VipSend = require("src.Net.Send.VipSend")
            VipSend.sendCG_GetVipAward_Req(params)
        end, function()
            canGet = false
            table.insert(vipAwardInfo,vipInfo.id)
            GameAudio.playUISound("specialItemGet")
            PurchaseViewMgr.setRedPoint()
            CSResourceMgr.setButtonStringByNode(getBtn,"recharge27",{r=0,g=0,b=0,a=255})
            CSResourceMgr.setButtonEnabledByNode(getBtn, false)
            local function showGetPet()
                for k,v in pairs(compoundPetInfo) do
                    GachaViewMgr.playGetAPet(v.pokeID, v, function ()
                        showGetPet()
                    end)
                    table.remove(compoundPetInfo, 1)
                    return
                end
            end
            AwardsListMgr.show(SceneMgr.getRunningScene, awardsVec)
            if PetEducationMgr.getTableLength(awardsVec) > 0 then
                showGetPet()
            end
        end, function(code)
            TipsMgr.showError(scene, code)
        end)
    end

    local awardsNum = #dropInfo.reNumber
    if #vipInfo.awardsID > 1 then
        local icon = CSResourceMgr.getNodeByName(resNameTips, "icon"..index)
        icon:setVisible(true)
        local itemInfo = ItemInfo.getItemInfoById(11200)
        CSResourceMgr.setSpriteTextureByNode(icon, itemInfo.icon)

        local iconBG = CSResourceMgr.getNodeByName(resNameTips, "iconBG"..index)
        iconBG:setVisible(true)

        local count = CSResourceMgr.getNodeByName(resNameTips, "count"..index)
        count:setVisible(true)
        CSResourceMgr.setLabelStringByNode(count, " ")

        local path = ItemInfo.getItemRareBGImage(11200)
        CSResourceMgr.setButtonTextureByNode(iconBG, path, path, path)

        CSResourceMgr.clickEventBindingByNode(iconBG, function()
            ItemInfoViewMgr.show({id = 11200, sum = 1}, false)
        end)
        index = index + 1
        awardsNum = awardsNum + 1

        local petInfos = {}
        for var=2,#vipInfo.awardsID do
            local petInfo = {}
            local dropInfo = AdventureInfo.getDropInfoByID(vipInfo.awardsID[var])
            for k,v in pairs(dropInfo.reNumber) do
                local rewardInfo = AdventureInfo.getRewardInfoByID(v)
                for k1,v1 in pairs(rewardInfo.element) do
                    local awardElementInfo = ItemInfo.getAwardElementInfoById(v1)
                    petInfo = PokemonInfo.getPokemonInfoByID(awardElementInfo.elementID)
                end
            end
            petInfos[vipInfo.awardsID[var]] = petInfo
        end

        CSResourceMgr.clickEventBinding(resNameTips, "getBtn", function()
            AwardSelectViewMgr.show(SceneMgr.getRunningScene,petInfos,sendProto)
        end)
    else
        CSResourceMgr.clickEventBinding(resNameTips, "getBtn", function()
            if canGet then
                sendProto()
            else
                StandardTipsMgr.show(1, "recharge22")
            end
        end)
    end

    local iconBG1 = CSResourceMgr.getNodeByName(resNameTips, "iconBG1")
    local iconBG2 = CSResourceMgr.getNodeByName(resNameTips, "iconBG2")
    local iconBG3 = CSResourceMgr.getNodeByName(resNameTips, "iconBG3")
    local iconBG4 = CSResourceMgr.getNodeByName(resNameTips, "iconBG4")
    local iconBG5 = CSResourceMgr.getNodeByName(resNameTips, "iconBG5")
    if awardsNum == 2 then
        iconBG1:setPositionX(55)
        iconBG2:setPositionX(155)
    elseif awardsNum == 4 then
        iconBG1:setPositionX(55)
        iconBG2:setPositionX(155)
        iconBG3:setPositionX(-45)
        iconBG4:setPositionX(255)
    else
        iconBG1:setPositionX(105)
        iconBG2:setPositionX(205)
        iconBG3:setPositionX(5)
        iconBG4:setPositionX(305)
        iconBG5:setPositionX(-95)
    end

    for i=index,5 do
        local iconBG = CSResourceMgr.getNodeByName(resNameTips, "iconBG"..index)
        iconBG:setVisible(false)
    end
end

function PurchaseViewMgr.setCompoundPetInfo(jsStr)
    if CSResourceMgr.getCsbObj(resName) then
        local cjson = require("cjson")
        local tbl = cjson.decode(jsStr)
        table.insert(compoundPetInfo, tbl)
    end
end

function PurchaseViewMgr.showVipTips()
    local curRes = CSResourceMgr.createRes(SceneMgr.getRunningScene, resNameTips)
    curRes:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
    CSResourceMgr.setFullScreen(resNameTips)
    CocosModuleMgr.showUIAnimation(CSResourceMgr.getNodeByName(resNameTips,"background"),"down")
    local totalmoney = 0
    if CharInfo.get().recharge then
        totalmoney = CharInfo.get().recharge.totalMoney or 0
    end
    local vipLevel = CharInfo.getVIPLevel()
    local vipInfo = CharInfo.getVipInfoByID(vipLevel)
    local nextVipInfo = nil
    local tips = CSResourceMgr.getNodeByName(resNameTips, "tips")
    if vipLevel ~= SystemInfo.getGlobalConfigAddInfoByID(55).values[1] then
        nextVipInfo = CharInfo.getVipInfoByID(vipLevel+1)
        CSResourceMgr.setLabelStringByNode(tips, CocosModuleMgr.createStringWithFormat({"recharge14",nextVipInfo.recharge-totalmoney})..nextVipInfo.viplevel)
    else
        tips:setVisible(false)
    end
    local title = CSResourceMgr.getNodeByName(resNameTips, "title")
    CSResourceMgr.setLabelStringByNode(title, "VIP "..vipInfo.viplevel)
    local atitle = CSResourceMgr.getNodeByName(resNameTips, "atitle")
    CSResourceMgr.setLabelColorByNode(atitle, {r=255,g=255,b=255,a=255})
    CSResourceMgr.setLabelStringByNode(atitle, "recharge23", {r=0,g=0,b=0,a=255})

    local tipInfo = CSResourceMgr.getNodeByName(resNameTips, "tipInfo")
    richLabelL = CocosModuleMgr.createRichLabel(tipInfo, vipInfo.explain, 24, CSResourceMgr.LANG_FONT[LuaSqlite.LANG_TYPE] or CSResourceMgr.LANG_FONT[1], TownChatMgr.MAX_LABEL_WIDTH,nil,nil,nil,true)
    tipInfo:setString(" ")
    tipInfo:setTextAreaSize({width = 0, height = richLabelL.realHeight})
    tipInfo:ignoreContentAdaptWithSize(false)

    local awardsTips = CSResourceMgr.getNodeByName(resNameTips, "awardsTips")
    CSResourceMgr.setLabelStringByNode(awardsTips, "recharge24")
    awardsTips:setVisible(false)

    local getBtn = CSResourceMgr.getNodeByName(resNameTips, "getBtn")
    local canGet = true
    for k,v in pairs(vipAwardInfo) do
        if v == vipInfo.id then
            canGet = false
        end
    end
    
    if canGet then
        CSResourceMgr.setButtonStringByNode(getBtn,"recharge26",{r=0,g=0,b=0,a=255})
        CSResourceMgr.setButtonEnabledByNode(getBtn, true)
    else
        CSResourceMgr.setButtonStringByNode(getBtn,"recharge27",{r=0,g=0,b=0,a=255})
        CSResourceMgr.setButtonEnabledByNode(getBtn, false)
    end

    setVipTipsLabel(vipLevel)

    CSResourceMgr.clickEventBinding(resNameTips, "cover", function()
        CSResourceMgr.removeCSObjectByTag(resNameTips)
    end)

    local count = vipLevel
    local leftBtn = CSResourceMgr.getNodeByName(resNameTips, "leftBtn")
    local rightBtn = CSResourceMgr.getNodeByName(resNameTips, "rightBtn")
    if vipLevel == 1 then
        leftBtn:setVisible(false)
    end
    if vipLevel == SystemInfo.getGlobalConfigAddInfoByID(55).values[1] then
        rightBtn:setVisible(false)
    end
    CSResourceMgr.clickEventBindingByNode(leftBtn, function()
        GameAudio.playUISound("petchange")
        count = count - 1
        setVipTipsLabel(count)
        rightBtn:setVisible(true)
    end)
    CSResourceMgr.clickEventBindingByNode(rightBtn, function()
        GameAudio.playUISound("petchange")
        count = count + 1
        setVipTipsLabel(count)
        leftBtn:setVisible(true)
    end)
end

function PurchaseViewMgr.showMoonCardTip(node,MoonInfo)
    local curRes = CSResourceMgr.createRes(SceneMgr.getRunningScene, resNameMoon)
    curRes:setLocalZOrder(CocosModuleMgr.ZORDER_FLOAT)
    CSResourceMgr.setFullScreen(resNameMoon)
    CocosModuleMgr.showUIAnimation(CSResourceMgr.getNodeByName(resNameMoon,"background"),"down")

    local tipInfo = CSResourceMgr.getNodeByName(resNameMoon, "tipInfo")
    local richLabel = CocosModuleMgr.createRichLabel(tipInfo, CocosModuleMgr.createStringWithFormat({"recharge10",MoonInfo.mCashPerDay,MoonInfo.initMCash}), 24, CSResourceMgr.LANG_FONT[LuaSqlite.LANG_TYPE] or CSResourceMgr.LANG_FONT[1], TownChatMgr.MAX_LABEL_WIDTH,nil,nil,nil,true)
    tipInfo:setString(" ")
    tipInfo:setTextAreaSize({width = 0, height = richLabel.realHeight})
    tipInfo:ignoreContentAdaptWithSize(false)

    CSResourceMgr.setButtonString(resNameMoon, "buyBtn", "recharge36", "", {r=0,g=0,b=0,a=255})
    CSResourceMgr.setButtonStringColor(resNameMoon, "buyBtn", {r=255,g=255,b=255,a=255})
    CSResourceMgr.setButtonString(resNameMoon, "cancelBtn", "recharge37", "", {r=0,g=0,b=0,a=255})
    CSResourceMgr.setButtonStringColor(resNameMoon, "cancelBtn", {r=255,g=255,b=255,a=255})
    CSResourceMgr.setLabelString(resNameMoon, "title", "recharge34", "", {r=0,g=0,b=0,a=255})
    CSResourceMgr.setLabelString(resNameMoon, "titleS", "recharge35", "", {r=0,g=0,b=0,a=255})

    CSResourceMgr.clickEventBinding(resNameMoon, "buyBtn", function()
        -- StandardTipsMgr.show(1, "recharge30")
        PayConfig.payLocal(MoonInfo.id, true)
    end)

    CSResourceMgr.clickEventBinding(resNameMoon, "cancelBtn", function()
        CSResourceMgr.removeCSObjectByTag(resNameMoon)
    end)
end

function PurchaseViewMgr.refreshUI(info)
    local totalmoney = 0
    if CharInfo.get().recharge then
        totalmoney = CharInfo.get().recharge.totalMoney or 0
    end
    NetInterface.sendWithBlock("GC_GetActivitiesData_Ack", function()
        local ActivitySend = require("src.Net.Send.ActivitySend")
        ActivitySend.sendCG_GetActivitiesData_Req()
    end,function()
        if not CSResourceMgr.getCsbObj(resName) then
            local curMCash = CharInfo.getMCash()
            totalmoney = totalmoney + info.money
            CharInfo.set({viplevel=info.vipLevel,m_cash=info.mCash+info.periodMCash+curMCash,recharge={totalMoney=totalmoney}})
            StatusBarMgr.refreshVipLevel()
            StatusBarMgr.refreshCash()
            PurchaseViewMgr.setRedPoint()
            StandardTipsMgr.show(0, "recharge29")
            return
        else
            NetInterface.sendWithBlock("GC_RechargeCD_Ack", function()
                local MonthCardSend = require("src.Net.Send.MonthCardSend")
                MonthCardSend.sendCG_RechargeCD_Req()
            end, function()
                PurchaseViewMgr.setPurchaseItem()
            end, function(code)
                TipsMgr.showError(scene, code)
            end)
        end
        local pType = string.sub(info.productID,1,1)
        local id = tonumber(string.sub(info.productID,2,-1))
        local sendInfo = {}
        if pType == "M" then
            sendInfo = ItemInfo.getMonthCardRechargeInfoById(id)
        elseif pType == "N" then
            sendInfo = ItemInfo.getNormalRechargeInfoById(id)
        end
        local curVip = info.vipLevel
        local vipInfo = CharInfo.getVipInfoByID(curVip)
        local nVipInfo = nil
        local LoadingBar = CSResourceMgr.getNodeByName(resName, "LoadingBar")
        if curVip ~= SystemInfo.getGlobalConfigAddInfoByID(55).values[1] then
            local nextVipInfo = CharInfo.getVipInfoByID(curVip+1)
            totalmoney = totalmoney + info.money
            if totalmoney > nextVipInfo.recharge then
                for k,v in pairs(vipInfoTable) do
                    if totalmoney < sendInfo.recharge then
                        curVip = sendInfo.id - 1
                        break
                    end
                end
            end
            nVipInfo = CharInfo.getVipInfoByID(curVip+1)
            PlayerAnimeMgr.showWorldPKEffect(TownMapMgr.Player,vipInfo.viplevel,PlayerAnimeMgr.SELF_TAG_STRING)
            CSResourceMgr.setLabelString(resName, "viptips", "VIP"..vipInfo.viplevel..CocosModuleMgr.createStringWithFormat({"recharge14",nVipInfo.recharge-totalmoney})..nVipInfo.viplevel)
            CSResourceMgr.setLabelString(resName, "barValue", totalmoney.."/"..nVipInfo.recharge)
            LoadingBar:setPercent((totalmoney/nVipInfo.recharge)*100)
            CharInfo.set({recharge={totalMoney=totalmoney}})
        else 
            totalmoney = totalmoney + info.money
            CSResourceMgr.setLabelString(resName, "viptips", "VIP "..(SystemInfo.getGlobalConfigAddInfoByID(55).values[1]-1))
            CSResourceMgr.setLabelString(resName, "barValue", totalmoney.."/"..vipInfo.recharge)
            LoadingBar:setPercent(100)
        end
        if sendInfo.id == 10001 then
            local countDown = CSResourceMgr.seekNodeByName(itemNodes[1], "countDown")
            CSResourceMgr.setLabelStringByNode(countDown, "recharge40")
            local days = CSResourceMgr.seekNodeByName(itemNodes[1], "days")
            local discount = CSResourceMgr.seekNodeByName(itemNodes[1], "discount")
            countDown:setVisible(true)
            days:setVisible(true)
            discount:setVisible(false)
            dayCount = dayCount + 30
            str = dayCount
            CSResourceMgr.setLabelStringByNode(days, CocosModuleMgr.createStringWithFormat({"recharge17",str}))
            CSResourceMgr.removeCSObjectByTag(resNameMoon)
        end
        local curMCash = CharInfo.getMCash()
        CharInfo.set({viplevel=info.vipLevel,m_cash=info.mCash+info.periodMCash+curMCash})
        StatusBarMgr.refreshVipLevel()
        StatusBarMgr.refreshCash()
        PurchaseViewMgr.setRedPoint()
        StandardTipsMgr.show(0, "recharge29")
    end, function(code)
        TipsMgr.showError(scene, code)
    end)
end

--充值失败提示 1
--充值成功NTF未回 2
function PurchaseViewMgr.refreshLocalCheckout(isMonthCard)
    if not CSResourceMgr.getCsbObj(resName) then return end
    local vipID = CharInfo.getVIPLevel()
    local level = CharInfo.getVipInfoByID(vipID)
    local maxID = SystemInfo.getGlobalConfigAddInfoByID(55).values[1]
    local total = (CharInfo.get().recharge or {}).totalMoney or 0
    local nextLevel = vipID < maxID and CharInfo.getVipInfoByID(vipID + 1) or nil
    local threshold = nextLevel and nextLevel.recharge or level.recharge
    local label = "VIP "..level.viplevel
    if nextLevel then
        label = label..CocosModuleMgr.createStringWithFormat({"recharge14", math.max(0, threshold - total)})..nextLevel.viplevel
    end
    CSResourceMgr.setLabelString(resName, "viptips", label)
    CSResourceMgr.setLabelString(resName, "barValue", total.."/"..threshold)
    CSResourceMgr.getNodeByName(resName, "LoadingBar"):setPercent(nextLevel and math.min(100, total/threshold*100) or 100)
    local MonthCardSend = require("src.Net.Send.MonthCardSend")
    local function refreshPackages()
        if CSResourceMgr.getCsbObj(resName) then PurchaseViewMgr.setPurchaseItem() end
    end
    local function onFailure(code)
        TipsMgr.showError(scene, code)
    end
    if isMonthCard then
        CSResourceMgr.removeCSObjectByTag(resNameMoon)
        NetInterface.sendWithBlock("ZC_LoadMonthCard_Ack", MonthCardSend.sendCZ_LoadMonthCard_Req,
            refreshPackages, onFailure, nil, false)
    else
        NetInterface.sendWithBlock("GC_RechargeCD_Ack", MonthCardSend.sendCG_RechargeCD_Req,
            refreshPackages, onFailure, nil, false)
    end
end

function PurchaseViewMgr.showTipMsg(tpye)
    if tpye == 1 then
        StandardTipsMgr.show(1, "recharge25")
    elseif tpye == 2 then
        StandardTipsMgr.show(0, "recharge28")
    end
end

function PurchaseViewMgr.setRedPoint()
    local vipLevel = CharInfo.getVIPLevel()
    if CSResourceMgr.getCsbObj(resName) then
        local redPoint = CSResourceMgr.getNodeByName(resName, "redPoint")
        if vipLevel > #vipAwardInfo then
            redPoint:setVisible(true)
        else
            redPoint:setVisible(false)
        end
    end
    if vipLevel > #vipAwardInfo then
        StatusBarMgr.addRedPoint(8)
    else
        -- StatusBarMgr.hideRedPoint(8)
        PurchaseViewMgr.setVipShopRedPoint()
    end
end

function PurchaseViewMgr.setVipShopRedPoint()
    if PurchaseViewMgr.showVipShopRedPoint == true then
        if VipShopViewMgr.getVipShopRedPointState() == true then
            StatusBarMgr.addRedPoint(8)
        else
            StatusBarMgr.hideRedPoint(8)
            if CSResourceMgr.getCsbObj(resName) then
                -- PetEducationMgr.hideRedPoint("btnVipShopPage")
                PetEducationMgr.removeRedPoint("btnVipShopPage")
            end
        end
    else
        StatusBarMgr.hideRedPoint(8)
        if CSResourceMgr.getCsbObj(resName) then
            PetEducationMgr.removeRedPoint("btnVipShopPage")
        end
    end
end

function PurchaseViewMgr.turnTimeData(timeData)
    local timeVec = {}
    local vec1 = lua_string_split(timeData,"T")
    local vec2 = lua_string_split(vec1[1],"-")
    local vec3 = lua_string_split(vec1[2],".")

    timeVec.year = vec2[1]
    timeVec.month = vec2[2]
    timeVec.day = vec2[3]

    local vec4 = lua_string_split(vec3[1],":")
    timeVec.hour = vec3[1]
    timeVec.min = vec3[2]
    timeVec.sec = vec3[3]

    return os.time({year=timeVec.year, month=timeVec.month, day=timeVec.day, hour=timeVec.hour, min=timeVec.min, sec=timeVec.sec})
end

function PurchaseViewMgr.sortRechargeInfo(vec)
    table.sort(vec, function(a, b)
        local aIdx = tonumber(a.orderName)
        local bIdx = tonumber(b.orderName)
        return aIdx < bIdx
    end)
   
    return vec
end

function PurchaseViewMgr.checkMoonTime(timeM)
    local time = CharInfo.getServerTime() + CharInfo.getServerTimeZone()-21600
    local timeC = time - time%86400
    if timeC > timeM then
        return true 
    else
        return false
    end
end

function PurchaseViewMgr.getMCardAward()
    local function sendMCardProto(moonID)
        NetInterface.sendWithBlock("ZC_TakeMonthCardAward_Ack", function()
            local MonthCardSend = require("src.Net.Send.MonthCardSend")
            MonthCardSend.sendCZ_TakeMonthCardAward_Req(moonID)
        end, nil, function(code)
            TipsMgr.showError(scene, code)
        end)
    end
    local mRechargeInfo = ItemInfo.getMonthCardRechargeInfoAllId()
    for k,v in pairs(mRechargeInfo) do
        for k1,v1 in pairs(monthCardInfo) do
            if v1.id == v.id then
                if v1.endTime > 0 then
                    local loginTime = CharInfo.getServerTime()
                    dayCount = CocosModuleMgr.getDayTimeDiff(loginTime, v1.endTime, 21600)
                    if dayCount >= 0 then
                        if v1.lastAwardTime ~= 0 then
                            if PurchaseViewMgr.checkMoonTime(v1.lastAwardTime) then
                                sendMCardProto(v1.id)
                            end
                        else
                            sendMCardProto(v1.id)
                        end
                    else
                        return
                    end
                else
                    return
                end
            end
        end
    end
    
    local time = CharInfo.getServerTime() + CharInfo.getServerTimeZone()
    local timeC = 86400 - time%86400
    local timeM = 0
    if timeC > 21600 then
        timeM = timeC + 21600
    else
        timeM = 21600 - timeC
    end
    
    if mCardHandler then
        scheduler.unscheduleGlobal(mCardHandler)
    end
    mCardHandler = scheduler.performWithDelayGlobal(function()
        NetInterface.sendWithBlock("ZC_LoadMonthCard_Ack", function()
            local MonthCardSend = require("src.Net.Send.MonthCardSend")
            MonthCardSend.sendCZ_LoadMonthCard_Req()
        end, nil, function(code)
            TipsMgr.showError(scene, code)
        end)
    end, timeM)
end

return PurchaseViewMgr
