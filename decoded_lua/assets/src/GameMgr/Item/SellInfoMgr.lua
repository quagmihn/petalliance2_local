--vesion number 1.0
--@client side SellInfoMgr.lua
--[[
这个文件是出售道具的界面
--]]
--script writer Leon Lee
--creation time 2016-4-9

local SellInfoMgr={}

--翻译
local trans_wupingchushou = "exchange054"
local trans_shuliang = "exchange055"
local trans_danjia = "exchange056"
local trans_zongjia = "exchange057"
local trans_chiyouyinbi = "exchange058"
local trans_queren = "exchange059"
local trans_shouxufei = "exchange060"

local editBox1 = nil
local editBox2 = nil

local trans_chushouchenggong = "exchange061"
local trans_errortaiduo = "exchange062"
local trans_errornoitem = "exchange063"
local trans_errornoprice = "exchange064"
local trans_errornojinbi = "exchange065"
local trans_errormax = "exchange066"
local trans_errornumberout = "exchange067"
local trans_errorpriceout = "exchange068"
local trans_erroritemmax = "exchange069"
local trans_errorpricetoomin = "exchange095"

--数据层
local shouxufeilv = 0.1 --手续费率
local sellInfoData --{itemID = xxx,itemNum = xxx}
local CONST_MAX_SELLNUMBER = 1000
local CONST_MAX_UNITPRICE = 1000000
local CONST_MAX_SELLITEMNUM = 10--最大的道具出售数量
local uiData = nil
local oldunitprice = 1
local oldsellnum = 1
---------------------------------我是分割线------------------------------------

--ui初始化信息
local resNameSellInfoMgr = ""

local fontInfo = {
    txt_title={
        have_selstate = false, --是否有选中态
        outline_width = 1,
        font_color = {r =144,g=238,b=255,a=255},          
        outline_color = {r =0,g=0,b=0,a=255},   
        text = trans_wupingchushou                  
    },  
    
    txt_sellnum={
        have_selstate = false, --是否有选中态
        outline_width = 1,
        font_color = {r =144,g=238,b=255,a=255},          
        outline_color = {r =38,g=54,b=76,a=255},   
        text = trans_shuliang         
    },
    
    
    txt_unitprice={
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
    
    txt_shouxufei={
        have_selstate = false, --是否有选中态
        outline_width = nil,
        font_color = {r =144,g=238,b=255,a=255},          
        outline_color = {r =38,g=54,b=76,a=255},   
        text = trans_shouxufei         
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
    
    btn_sell = {
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

--显示上边栏道具
local function showItemInfo()
    local iteminfo = ItemInfo.getItemInfoById(sellInfoData.itemID)

    CSResourceMgr.setLabelString(resNameSellInfoMgr, "name", iteminfo.name, "", {r=0,g=0,b=0,a=255}, nil, 300)
    CSResourceMgr.setLabelColor(resNameSellInfoMgr, "name", {r=55,g=178,b=219,a=255})

    --[[
    CSResourceMgr.setLabelString(resNameBuyInfoMgr, "info", iteminfo.desc)
    CSResourceMgr.setLabelColor(resNameBuyInfoMgr, "info", {r=112,g=131,b=158,a=255})
    CSResourceMgr.setLabelMaxWidth(resNameBuyInfoMgr, "info", 440)
    ]]--

    CSResourceMgr.setSpriteTexture(resNameSellInfoMgr, "icdb", ItemInfo.getItemRareBGImage(sellInfoData.itemID))
    CSResourceMgr.setSpriteTexture(resNameSellInfoMgr, "icon", iteminfo.icon)

    local itemNode = CSResourceMgr.getNodeByName(resNameSellInfoMgr,"btn_tips")
    CSResourceMgr.buttonEventBindingByNode(itemNode, function ()
                    ItemInfoViewMgr.show({id = sellInfoData.itemID}, false)
                end, function ()
                    ItemInfoViewMgr.hide()
                end, function ()
                end, function ()
                    ItemInfoViewMgr.hide()
                end, true)

    local usetip = CSResourceMgr.getNodeByName(resNameSellInfoMgr, "usetip")
    local usestatus = ""
    if Proto.FT_BIND_USE==iteminfo.bindType then
        usestatus = "iteminfo1"
    end

    CSResourceMgr.setLabelString(resNameSellInfoMgr, "usetip", usestatus, "", nil, nil, 300)
    CSResourceMgr.setLabelColor(resNameSellInfoMgr, "usetip", {r=217,g=234,b=255,a=255})
    usetip:enableOutline({r=0,g=0,b=0,a=255}, 1)

    local plusStr = "x"
    local sumLabel = CSResourceMgr.getNodeByName(resNameSellInfoMgr, "num")
    CSResourceMgr.setLabelString(resNameSellInfoMgr, "num",plusStr..sellInfoData.itemNum, "", nil, nil, 100)
    sumLabel:enableOutline({r=0,g=0,b=0,a=255}, 1)

end


local function hideUI()
    GameAudio.playUISound("retract")
    UnblockLoader.cancel("SellInfoMgr.show")
    CSResourceMgr.removeCSObjectByTag(resNameSellInfoMgr)
end


local function sendSellProductsReq(itemid,sellnum,unitprice,objid)
    objid = objid or 0
    --[[
    local mySellCount = AuctionMgrNew.getMySellItemLst()
    if mySellCount >=10 then
        StandardTipsMgr.show(1,trans_errortaiduo)
        return     
    end
    ]]

    unitprice = tonumber(editBox2:getText()) 
    print("unitprice is...............",editBox2:getText())
    if sellnum > sellInfoData.itemNum then
        StandardTipsMgr.show(1,trans_errortaiduo)
        return 
    end
    
    if sellnum == 0 then
        StandardTipsMgr.show(1,trans_errornoitem)
        return     
    end
    
    if sellnum > CONST_MAX_SELLNUMBER then
        StandardTipsMgr.show(1,trans_errornumberout)       
        return
    end

    if sellInfoData.minprice == nil then 
        sellInfoData.minprice = 1
    end

    if unitprice < tonumber(sellInfoData.minprice) then 
        editBox2:setText(tostring(sellInfoData.minprice))
        unitprice = sellInfoData.minprice
        StandardTipsMgr.show(1,trans_errorpricetoomin)
        local zongjia = sellnum*unitprice
        local shouxufei = zongjia*shouxufeilv
        print("zongjia and shouxufei is.................",zongjia,shouxufei)
        local upricenum = CSResourceMgr.getNodeByName(resNameSellInfoMgr,"txt_upricenum")
        local allpricenum = CSResourceMgr.getNodeByName(resNameSellInfoMgr,"txt_allpricenum")
        if shouxufei < 1 then 
            shouxufei = 1
        else
            shouxufei = math.floor(shouxufei)
        end
        setLabel(upricenum,tostring(zongjia),fontInfo.txt_upricenum.outline_color,fontInfo.txt_upricenum.outline_width,fontInfo.txt_upricenum.font_color)   
        setLabel(allpricenum,tostring(shouxufei),fontInfo.txt_allpricenum.outline_color,fontInfo.txt_allpricenum.outline_width,fontInfo.txt_allpricenum.font_color)  
        return 
    end
    
    if AuctionMgrNew.MyAuctionNum >= CONST_MAX_SELLITEMNUM then
        StandardTipsMgr.show(1,trans_erroritemmax)       
        return        
    end
    
    if unitprice == 0 then
    
        StandardTipsMgr.show(1,trans_errornoprice)
        return      
    end
    
    if unitprice >CONST_MAX_UNITPRICE then
    
        StandardTipsMgr.show(1,trans_errorpriceout)       
        return    
    end
    
    local zongjia = sellnum*unitprice
    local shouxufei = zongjia*shouxufeilv
    if shouxufei < 1 then 
        shouxufei = 1
    else
        shouxufei = math.floor(shouxufei)
    end
    
    local scoinnum = CharInfo.getSilverCash()
    if scoinnum == nil then scoinnum =0 end
    if tonumber(scoinnum)< shouxufei then 
        StandardTipsMgr.show(1,trans_errornojinbi)
        return      
    end       

    
    local data = {itemID = itemid,objID = objid,sellNum = sellnum,unitPrice = unitprice}
    NetInterface.sendWithBlock("GC_SELLONMARKET_ACK",function() 
        local sellSend =require("src.Net.Send.MarketSend")
        sellSend.sendCG_SellOnMarket_Req(data)
    end,
    function()
        GameAudio.playUISound("success")
        TipsMgr.show(SceneMgr.getRunningScene,trans_chushouchenggong)
        AuctionMgrNew.refresh(2,{itemid = data.itemID,num = data.sellNum,oldnum = sellInfoData.itemNum,iconbutton = uiData,objID = objid})
        --hideUI()
		SellInfoMgr.hide()
    end,
    function(code)
        TipsMgr.showError(SceneMgr.getRunningScene,code)
    end
    )
end



local function initUIBaseData()
    oldunitprice = 1
    oldsellnum = 1
    local title = CSResourceMgr.getNodeByName(resNameSellInfoMgr,"txt_title") 
    setLabel(title,fontInfo.txt_title.text,fontInfo.txt_title.outline_color,fontInfo.txt_title.outline_width,fontInfo.txt_title.font_color)

    local sellnum = CSResourceMgr.getNodeByName(resNameSellInfoMgr,"txt_sellnum")
    setLabel(sellnum,fontInfo.txt_sellnum.text,fontInfo.txt_sellnum.outline_color,fontInfo.txt_sellnum.outline_width,fontInfo.txt_sellnum.font_color)
    
    local uprice = CSResourceMgr.getNodeByName(resNameSellInfoMgr,"txt_unitprice")
    setLabel(uprice,fontInfo.txt_unitprice.text,fontInfo.txt_unitprice.outline_color,fontInfo.txt_unitprice.outline_width,fontInfo.txt_unitprice.font_color)

    local allprice = CSResourceMgr.getNodeByName(resNameSellInfoMgr,"txt_allprice")
    setLabel(allprice,fontInfo.txt_allprice.text,fontInfo.txt_allprice.outline_color,fontInfo.txt_allprice.outline_width,fontInfo.txt_allprice.font_color) 
    
    local havemoney = CSResourceMgr.getNodeByName(resNameSellInfoMgr,"txt_havemoney")
    setLabel(havemoney,fontInfo.txt_havemoney.text,fontInfo.txt_havemoney.outline_color,fontInfo.txt_havemoney.outline_width,fontInfo.txt_havemoney.font_color)
   
    local shouxufei = CSResourceMgr.getNodeByName(resNameSellInfoMgr,"txt_shouxufei")
    setLabel(shouxufei,fontInfo.txt_shouxufei.text,fontInfo.txt_shouxufei.outline_color,fontInfo.txt_shouxufei.outline_width,fontInfo.txt_shouxufei.font_color)

    local fieldtextbg1 = CSResourceMgr.getNodeByName(resNameSellInfoMgr,"pic_fieldtextbg")
    local fieldtextbg2 = CSResourceMgr.getNodeByName(resNameSellInfoMgr,"pic_fieldtextbg2")
    
    

    local upricenum = CSResourceMgr.getNodeByName(resNameSellInfoMgr,"txt_upricenum")
    setLabel(upricenum,"0",fontInfo.txt_upricenum.outline_color,fontInfo.txt_upricenum.outline_width,fontInfo.txt_upricenum.font_color)
  
    local allpricenum = CSResourceMgr.getNodeByName(resNameSellInfoMgr,"txt_allpricenum")
    setLabel(allpricenum,"0",fontInfo.txt_allpricenum.outline_color,fontInfo.txt_allpricenum.outline_width,fontInfo.txt_allpricenum.font_color)

    shouxufeilv = SystemInfo.getGlobalConfigAddInfoByID(23000).values[1]/100
    --print("手续费率是。。。。。。。。。。"..shouxufeilv)
    local function showPrice()
        local number = tonumber(editBox1:getText())
        local uprice = tonumber(editBox2:getText())
        number = math.floor(number)
        uprice = math.floor(uprice)
        editBox1:setText(number)
        editBox2:setText(uprice)      

        print("number is .....................",number)
        if number <=0 or uprice <=0 then 
            editBox1:setText(oldsellnum)
            editBox2:setText(oldunitprice)
            return 
        end


        local zongjia = number*uprice
        local shouxufei = zongjia*shouxufeilv
        if shouxufei < 1 then 
            shouxufei = 1
        else 
            shouxufei = math.floor(shouxufei)
        end


        setLabel(upricenum,tostring(zongjia),fontInfo.txt_upricenum.outline_color,fontInfo.txt_upricenum.outline_width,fontInfo.txt_upricenum.font_color)   
        setLabel(allpricenum,tostring(shouxufei),fontInfo.txt_allpricenum.outline_color,fontInfo.txt_allpricenum.outline_width,fontInfo.txt_allpricenum.font_color)   
        oldsellnum = number 
        oldunitprice = uprice
    end
    editBox1 =  CocosModuleMgr.newTextEditor(fieldtextbg1,"empty.png",140,36,75,18,24,50,"",2,function()         
        showPrice()
    end)
    editBox1:setText("1")
 
    editBox2 =  CocosModuleMgr.newTextEditor(fieldtextbg2,"empty.png",140,36,75,18,24,50,"",2,function()         
        --local number = editBox:getText()
        --setLabel(allpricenum,buyInfoData.unitPrice*tonumber(number),fontInfo.txt_allpricenum.outline_color,fontInfo.txt_allpricenum.outline_width,fontInfo.txt_allpricenum.font_color)
        showPrice()
        end)
    local price = uiData[3]
    if price == nil then price = 10 end
    --print("sell price is.........................."..price)
    editBox2:setText(tostring(price))

    local allscoinnum = CSResourceMgr.getNodeByName(resNameSellInfoMgr,"txt_allscoinnum")   
    local scoin = CharInfo.getSilverCash()
    if scoin == nil then scoin = 0 end 
    setLabel(allscoinnum,scoin,fontInfo.txt_allscoinnum.outline_color,fontInfo.txt_allscoinnum.outline_width,fontInfo.txt_allscoinnum.font_color)
    
    
    local btnsell = CSResourceMgr.getNodeByName(resNameSellInfoMgr,"btn_sell")
    CSResourceMgr.setButtonStringByNode(btnsell,fontInfo.btn_sell.text,fontInfo.btn_sell.outline_color)
    CSResourceMgr.setButtonStringColorByNode(btnsell,fontInfo.btn_sell.font_color)
    print("sellInfoData.objid itemID is:",sellInfoData.objid,sellInfoData.itemID)
    CSResourceMgr.clickEventBindingByNode(btnsell,function()

            local num = editBox1:getText()
            local uprice = editBox2:getText()
            sendSellProductsReq(sellInfoData.itemID,tonumber(num),tonumber(uprice),sellInfoData.objid)--objid为0，只有家具才要传Objid,这个objid如何获得
          
    end)
    
    showItemInfo()
    showPrice()
end

local function hideUI()
    UnblockLoader.cancel("SellInfoMgr.show")
    CSResourceMgr.removeCSObjectByTag(resNameSellInfoMgr)
end

local function addUI(scene,data)
    if CSResourceMgr.getCsbObj(resNameSellInfoMgr) or data == nil then
        return  
    end    
    
    
    sellInfoData = nil
    sellInfoData = data
    
    local function loadCSB()
        local curLayer = CSResourceMgr.createRes(scene, resNameSellInfoMgr)
        curLayer:setLocalZOrder(CocosModuleMgr.ZORDER_FLOAT)
        CSResourceMgr.setRelativePosition(resNameSellInfoMgr, 320, 480)

        initUIBaseData()

        CSResourceMgr.getNodeByName(resNameSellInfoMgr, "db"):setVisible(false)   
        --[[
        CSResourceMgr.clickEventBinding(resNameBuyInfoMgr, "bg", function()
        hideUI()
        end)
        ]]
        CSResourceMgr.clickEventBinding(resNameSellInfoMgr, "close", function()
            --hideUI()
			SellInfoMgr.hide()
        end)     
    end
    
    local function playCSB()
        GameAudio.playUISound("popup")
        local db = CSResourceMgr.getNodeByName(resNameSellInfoMgr, "db")
        db:setVisible(true)
        CocosModuleMgr.showUIAnimation(db, "down")
    end

    loadCSB()
    playCSB()
end


function SellInfoMgr.Init()
    resNameSellInfoMgr = "Item/Auction/SellInfo.csb"
    editBox1= nil
    editBox2= nil
end

function SellInfoMgr.show(scene,data,uidata)	 
	UIStack.push("SellInfoMgr",SellInfoMgr.hide,false)
    uiData = uidata

    addUI(scene,data)
end

function SellInfoMgr.hide()
	hideUI()
	UIStack.pop("SellInfoMgr")
end


return SellInfoMgr