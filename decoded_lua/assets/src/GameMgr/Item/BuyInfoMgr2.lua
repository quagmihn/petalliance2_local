--vesion number 1.0
--@client side BuyInfoMgr2.lua
--[[
这个文件是购买商会商城物品的界面
--]]
--script writer Leon Lee
--creation time 2016-4-13

local BuyInfoMgr2 = {}

--翻译
local trans_wupingoumai = "exchange070"
local trans_shuliang = "exchange055"
local trans_danjia = "exchange056"
local trans_zongjia = "exchange057"
local trans_chiyoujinbi = "exchange074"
local trans_chiyouyinbi = "exchange058"
local trans_chiyouzuanshi = "exchange075"
local trans_queren = "exchange059"
local trans_goumaichenggong = "exchange071"

local trans_errortaiduo = "exchange076"
local trans_errornomoney = "exchange077"
local trans_errornet =  "exchange078"
---------------------------------我是分割线------------------------------------


--ui初始化信息
local resNameBuyInfoMgr = ""

local coinTexture = {
    [1] = {texture ="UI/CommonFiles/icon_jinbi.png",scale = 0.6},--金币
    [2] = {texture ="UI/CommonFiles/ico_lanzuan.png",scale = 0.6},--钻石
    [3] = {texture ="UI/CommonFiles/Icn_silvery_cash.png",scale = 1},--银币
   
}

local fontInfo = {
    txt_title={
        have_selstate = false, --是否有选中态
        outline_width = 1,
        font_color = {r =144,g=238,b=255,a=255},          
        outline_color = {r =0,g=0,b=0,a=255},   
        text = trans_wupingoumai                  
    },  

    txt_sellnum={
        have_selstate = false, --是否有选中态
        outline_width = 1,
        font_color = {r =144,g=238,b=255,a=255},          
        outline_color = {r =38,g=54,b=76,a=255},   
        text = trans_shuliang         
    },

    txt_uprice={
        have_selstate = false, --是否有选中态
        outline_width = nil,
        font_color = {r =144,g=238,b=255,a=255},          
        outline_color = {r =38,g=54,b=76,a=255},   
        text = trans_danjia         
    }, 

    txt_allprice={
        have_selstate = false, --是否有选中态
        outline_width = nil,
        font_color = {r =144,g=238,b=255,a=255},          
        outline_color = {r =38,g=54,b=76,a=255},   
        text = trans_zongjia         
    }, 

    txt_upricenum={
        have_selstate = false, --是否有选中态
        outline_width = nil,
        font_color = {r =144,g=238,b=255,a=255},          
        outline_color = {r =38,g=54,b=76,a=255},   
        text = "nodata"       
    },

    txt_allpricenum={
        have_selstate = false, --是否有选中态
        outline_width = nil,
        font_color = {r =144,g=238,b=255,a=255},          
        outline_color = {r =38,g=54,b=76,a=255},   
        text = "nodata"        
    },

    txt_havemoney={
        have_selstate = false, --是否有选中态
        outline_width = nil,
        font_color = {r =144,g=238,b=255,a=255},          
        outline_color = {r =38,g=54,b=76,a=255},   
        text = trans_chiyouyinbi         
    }, 

    btn_buy = {
        have_selstate = false, --是否有选中态
        outline_width = 2,
        font_color = {r =227,g=233,b=255,a=255},          
        outline_color = {r =0,g=0,b=0,a=255},   
        text = trans_queren    

    },    

    txt_allscoinnum={
        have_selstate = false, --是否有选中态
        outline_width = nil,
        font_color = {r =144,g=238,b=255,a=255},          
        outline_color = {r =38,g=54,b=76,a=255},   
        text = "nodata"    
    },

}

--UI数据
local buyInfoData--购买的数据信息
local editBox
local coinTypeEnum = { --货币分类
    GoldenCoin = 1,--金币
    MCoin =2,--钻石
    SilverCoin = 3 --银币
}
local oldbuynum = 1

---------------------------------我是分割线------------------------------------

---设置label的字体
local function setLabel(label,string,outline,outlinewidth,textColor,maxwidth)

    CSResourceMgr.setLabelColorByNode(label,textColor)
    CSResourceMgr.setLabelStringByNode(label,string,nil)
    if outlinewidth~=nil  then
        label:enableOutline(outline, outlinewidth)
    end

    if maxwidth~=nil then
        CSResourceMgr.setLabelMaxWidthByNode(label,maxwidth)
    end
end

local function hideUI()
    GameAudio.playUISound("retract")
    UnblockLoader.cancel("BuyInfoMgr.show")
    CSResourceMgr.removeCSObjectByTag(resNameBuyInfoMgr)
end



local function sendBuyProductReq(buynum) --购买数量
    print("buynum....."..buynum,buyInfoData.id)
    if buyInfoData.buyMax > 0 then
        if buynum >buyInfoData.sellNum then 
            StandardTipsMgr.show(1,trans_errortaiduo)
            return 
        end
    
    end
    
    local cashnum = -1
    if buyInfoData.coinType == coinTypeEnum.GoldenCoin then cashnum = CharInfo.getGCash() end --金币
    if buyInfoData.coinType == coinTypeEnum.MCoin then cashnum = CharInfo.getMCash() end --钻石
    if buyInfoData.coinType == coinTypeEnum.SilverCoin then cashnum =  CharInfo.getSilverCash() end --银币
    if cashnum == nil then cashnum = 0 end
    --print("cashnum,buynum,unitprice",cashnum,buynum,buynum*buyInfoData.unitPrice)
    
    if cashnum<buynum*buyInfoData.unitPrice then
        StandardTipsMgr.show(1,trans_errornomoney)
        return         
    end
    
    if buynum ==0 then 
        StandardTipsMgr.show(1,trans_errortaiduo)
        return 
    end
    
    
    
    
    local data = {marketInfoID = buyInfoData.id,num =buynum}
    NetInterface.sendWithBlock("GC_BUYMARKETITEM_Ack",function() 
        local buySend =require("src.Net.Send.MarketSend")
        buySend.sendCG_BuyMarketItem_Req(data)

        --[[网络不稳定测试代码
        OvertimeListener.cancel(ackName, true)
        NetInterface.isConnect = false
        NetInterface.isWaiting = false
        local NetMgr = require("src.Net.NetMgr")
        NetMgr.reconnector = nil
        NetMgr.disconnect()
        ]]
    end,
    function()
        GameAudio.playUISound("success")
        TipsMgr.show(SceneMgr.getRunningScene,trans_goumaichenggong)
        AuctionMgrNew.refresh(3)
        --hideUI()
		BuyInfoMgr2.hide()
    end,
    function(code)
        if code == -1 then 
            local characterValueStr = ""
            if buyInfoData.coinType == coinTypeEnum.GoldenCoin then characterValueStr = "g_cash" end --金币
            if buyInfoData.coinType == coinTypeEnum.MCoin then characterValueStr = "m_cash" end --钻石
            if buyInfoData.coinType == coinTypeEnum.SilverCoin then characterValueStr = "goldCoin" end --银币
            NetInterface.sendWithBlock("GC_GetCharacterValues_Ack", function()
                local LoginSend = require("src.Net.Send.LoginSend")
                LoginSend.sendCG_GetCharacterValues_Req({characterValueStr}) --petPacketNum
            end, function() --成功获得参数
                local curCashNum = -1
                if buyInfoData.coinType == coinTypeEnum.GoldenCoin then curCashNum = CharInfo.getGCash() end --金币
                if buyInfoData.coinType == coinTypeEnum.MCoin then curCashNum = CharInfo.getMCash() end --钻石
                if buyInfoData.coinType == coinTypeEnum.SilverCoin then curCashNum =  CharInfo.getSilverCash() end --银币
                if curCashNum == nil then curCashNum = 0 end 
                if curCashNum < cashnum then 
                     GameAudio.playUISound("success")
                     TipsMgr.show(SceneMgr.getRunningScene,trans_goumaichenggong)
                     AuctionMgrNew.refresh(3)
                     --hideUI()
		             BuyInfoMgr2.hide()   
                     local reqTbl = {}
                     table.insert(reqTbl,buyInfoData.itemID)
                     print("reqItemNum............."..reqTbl[1])
                     ItemInfo.reqItemNum(reqTbl)
                else 
                     StandardTipsMgr.show(1, trans_errornet)   
                end              
            end, function(code)
                TipsMgr.showError(SceneMgr.getRunningScene, code)
            end)
        else 
            TipsMgr.showError(SceneMgr.getRunningScene,code)
        end
    end,nil,false
    )

end


--显示上边栏道具
local function showItemInfo()
    local iteminfo = ItemInfo.getItemInfoById(buyInfoData.itemID)

    if iteminfo.itemType == 15 then 
        local itemIcon =  ItemInfo.getItemIconById(iteminfo.id)
        itemIcon:setScale(0.75)
        local icdb = CSResourceMgr.getNodeByName(resNameBuyInfoMgr, "icdb")
        local db = CSResourceMgr.getNodeByName(resNameBuyInfoMgr, "db")
        db:addChild(itemIcon)
        itemIcon:setPosition(icdb:getPosition())
    else
        CSResourceMgr.setLabelString(resNameBuyInfoMgr, "name", iteminfo.name, "", {r=0,g=0,b=0,a=255}, nil, 300)
        CSResourceMgr.setLabelColor(resNameBuyInfoMgr, "name", {r=55,g=178,b=219,a=255})

        --[[
        CSResourceMgr.setLabelString(resNameBuyInfoMgr, "info", iteminfo.desc)
        CSResourceMgr.setLabelColor(resNameBuyInfoMgr, "info", {r=112,g=131,b=158,a=255})
        CSResourceMgr.setLabelMaxWidth(resNameBuyInfoMgr, "info", 440)
        ]]--

        CSResourceMgr.setSpriteTexture(resNameBuyInfoMgr, "icdb", ItemInfo.getItemRareBGImage(buyInfoData.itemID))
        CSResourceMgr.setSpriteTexture(resNameBuyInfoMgr, "icon", iteminfo.icon)

        local usetip = CSResourceMgr.getNodeByName(resNameBuyInfoMgr, "usetip")
        local usestatus = ""
        if Proto.FT_BIND_USE==iteminfo.bindType then
            usestatus = "iteminfo1"
        end

        CSResourceMgr.setLabelString(resNameBuyInfoMgr, "usetip", usestatus, "", nil, nil, 300)
        CSResourceMgr.setLabelColor(resNameBuyInfoMgr, "usetip", {r=217,g=234,b=255,a=255})
        usetip:enableOutline({r=0,g=0,b=0,a=255}, 1)

        local plusStr = "x"
        local sumLabel = CSResourceMgr.getNodeByName(resNameBuyInfoMgr, "num")
        local sellnumstr = ""
        print("buyInfoData.buyMax:"..buyInfoData.buyMax)
        if buyInfoData.buyMax >0 then
            sellnumstr = plusStr..(buyInfoData.sellNum)
        end
        CSResourceMgr.setLabelString(resNameBuyInfoMgr, "num",sellnumstr, "", nil, nil, 100)
        sumLabel:enableOutline({r=0,g=0,b=0,a=255}, 1)
    end

end

local function initUIBaseData()
    oldbuynum = 1
    local title = CSResourceMgr.getNodeByName(resNameBuyInfoMgr,"txt_title") 
    setLabel(title,fontInfo.txt_title.text,fontInfo.txt_title.outline_color,fontInfo.txt_title.outline_width,fontInfo.txt_title.font_color)

    local sellnum = CSResourceMgr.getNodeByName(resNameBuyInfoMgr,"txt_sellnum")
    setLabel(sellnum,fontInfo.txt_sellnum.text,fontInfo.txt_sellnum.outline_color,fontInfo.txt_sellnum.outline_width,fontInfo.txt_sellnum.font_color)

    local uprice = CSResourceMgr.getNodeByName(resNameBuyInfoMgr,"txt_uprice")
    setLabel(uprice,fontInfo.txt_uprice.text,fontInfo.txt_uprice.outline_color,fontInfo.txt_uprice.outline_width,fontInfo.txt_uprice.font_color)

    local allprice = CSResourceMgr.getNodeByName(resNameBuyInfoMgr,"txt_allprice")
    setLabel(allprice,fontInfo.txt_allprice.text,fontInfo.txt_allprice.outline_color,fontInfo.txt_allprice.outline_width,fontInfo.txt_allprice.font_color)

    local havemoney = CSResourceMgr.getNodeByName(resNameBuyInfoMgr,"txt_havemoney")
    if buyInfoData.coinType == coinTypeEnum.GoldenCoin then fontInfo.txt_havemoney.text = trans_chiyoujinbi end --金币
    if buyInfoData.coinType == coinTypeEnum.MCoin then fontInfo.txt_havemoney.text = trans_chiyouzuanshi end --钻石
    if buyInfoData.coinType == coinTypeEnum.SilverCoin then fontInfo.txt_havemoney.text = trans_chiyouyinbi end --银币
    
    setLabel(havemoney,fontInfo.txt_havemoney.text,fontInfo.txt_havemoney.outline_color,fontInfo.txt_havemoney.outline_width,fontInfo.txt_havemoney.font_color)

    local btnbuy = CSResourceMgr.getNodeByName(resNameBuyInfoMgr,"btn_buy")
    CSResourceMgr.setButtonStringByNode(btnbuy,fontInfo.btn_buy.text,fontInfo.btn_buy.outline_color)
    CSResourceMgr.setButtonStringColorByNode(btnbuy,fontInfo.btn_buy.font_color)
    CSResourceMgr.clickEventBindingByNode(btnbuy,function()

            local num = editBox:getText()
            local itemtype = ItemInfo.getItemInfoById(buyInfoData.itemID).itemType
            if itemtype ~= 12 then
                sendBuyProductReq(tonumber(num))
            else
                FamilyInfo.BuyFamilyDonationItem(buyInfoData.itemID, tonumber(num))
            end
    end)



    local upricenum = CSResourceMgr.getNodeByName(resNameBuyInfoMgr,"txt_upricenum")
    setLabel(upricenum,buyInfoData.unitPrice,fontInfo.txt_upricenum.outline_color,fontInfo.txt_upricenum.outline_width,fontInfo.txt_upricenum.font_color)

    local fieldtextbg = CSResourceMgr.getNodeByName(resNameBuyInfoMgr,"pic_fieldtextbg")
    local allpricenum = CSResourceMgr.getNodeByName(resNameBuyInfoMgr,"txt_allpricenum")
    setLabel(allpricenum,buyInfoData.unitPrice,fontInfo.txt_allpricenum.outline_color,fontInfo.txt_allpricenum.outline_width,fontInfo.txt_allpricenum.font_color)

    local allscoinnum = CSResourceMgr.getNodeByName(resNameBuyInfoMgr,"txt_allscoinnum")
    
    local cashnum = -1
    if buyInfoData.coinType == coinTypeEnum.GoldenCoin then cashnum = CharInfo.getGCash() end --金币
    if buyInfoData.coinType == coinTypeEnum.MCoin then cashnum = CharInfo.getMCash() end --钻石
    if buyInfoData.coinType == coinTypeEnum.SilverCoin then cashnum = CharInfo.getSilverCash() end --银币
   -- print("CharInfo.getSilverCash(),buyInfoData.coinType" ..CharInfo.getSilverCash(),buyInfoData.coinType)
    if cashnum == nil then cashnum = 0 end
    
    setLabel(allscoinnum,cashnum,fontInfo.txt_allscoinnum.outline_color,fontInfo.txt_allscoinnum.outline_width,fontInfo.txt_allscoinnum.font_color)


    editBox =  CocosModuleMgr.newTextEditor(fieldtextbg,"empty.png",140,36,75,18,24,50,"",2,function()         
        local number = editBox:getText()
        if tonumber(number) <= 0 then 
            editBox:setText(oldbuynum)
        else
            oldbuynum = number
            setLabel(allpricenum,buyInfoData.unitPrice*tonumber(number),fontInfo.txt_allpricenum.outline_color,fontInfo.txt_allpricenum.outline_width,fontInfo.txt_allpricenum.font_color)
        end
    end)

    editBox:setText(tostring(1))

    showItemInfo()
    
    local silvercoin1 = CSResourceMgr.getNodeByName(resNameBuyInfoMgr,"pic_silvercoin1")    
    local silvercoin2 = CSResourceMgr.getNodeByName(resNameBuyInfoMgr,"pic_silvercoin2")  
    local silvercoin3 = CSResourceMgr.getNodeByName(resNameBuyInfoMgr,"pic_silvercoin3")
    
    silvercoin1:loadTexture(coinTexture[buyInfoData.coinType].texture)
    silvercoin1:setScale(coinTexture[buyInfoData.coinType].scale) 
    
    silvercoin2:loadTexture(coinTexture[buyInfoData.coinType].texture)
    silvercoin2:setScale(coinTexture[buyInfoData.coinType].scale)   
    
    silvercoin3:loadTexture(coinTexture[buyInfoData.coinType].texture)
    silvercoin3:setScale(coinTexture[buyInfoData.coinType].scale)  
    print("buyInfoData.coinType "..buyInfoData.coinType)
end



local function addUI(scene,data)
    if CSResourceMgr.getCsbObj(resNameBuyInfoMgr) or data == nil then
        return  
    end

    buyInfoData = nil
    buyInfoData = data
    local function loadCSB()
        local curLayer = CSResourceMgr.createRes(scene, resNameBuyInfoMgr)
        curLayer:setLocalZOrder(CocosModuleMgr.ZORDER_FLOAT)
        CSResourceMgr.setRelativePosition(resNameBuyInfoMgr, 320, 480)

        initUIBaseData()

        CSResourceMgr.getNodeByName(resNameBuyInfoMgr, "db"):setVisible(false)   
        --[[
        CSResourceMgr.clickEventBinding(resNameBuyInfoMgr, "bg", function()
        hideUI()
        end)
        ]]
        CSResourceMgr.clickEventBinding(resNameBuyInfoMgr, "close", function()
            --hideUI()
			BuyInfoMgr2.hide()
        end) 
    end


    local function playCSB()
        GameAudio.playUISound("popup")
        local db = CSResourceMgr.getNodeByName(resNameBuyInfoMgr, "db")
        db:setVisible(true)
        CocosModuleMgr.showUIAnimation(db, "down")
    end

    loadCSB()
    playCSB()

end


function BuyInfoMgr2.Init()
    resNameBuyInfoMgr = "Item/Auction/BuyInfo.csb"
    editBox = nil
end

function BuyInfoMgr2.show(scene,data,closecallback)
	 UIStack.push("BuyInfoMgr2",BuyInfoMgr2.hide,false)
     addUI(scene,data)
end

function BuyInfoMgr2.hide()
	hideUI()
	UIStack.pop("BuyInfoMgr2")
end



return BuyInfoMgr2