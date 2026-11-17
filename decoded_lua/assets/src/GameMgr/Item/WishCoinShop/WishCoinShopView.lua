local WishCoinShopTopBar = require("src.GameMgr.Item.WishCoinShop.WishCoinShopTopBar")
local WishCoinShopView = {}
local resNameDB = "Pet/Formation/FormationBGNew.csb"
local resName  = "Item/wishCoinShop/WishCoinShopView.csb"
local itemIconInfo 		= {}
local itemsList    		= {}
local ShopInfoConfig 	= nil
local curShop    = Proto.SHOP_WISH
local preOrder   = 11
local beOrder    = 10
local wishShopCreateTime = nil
WishCoinShopView.getShop = false

function WishCoinShopView.init()
	itemIconInfo = {}
	curShop    = Proto.SHOP_WISH
end

function WishCoinShopView.setItemList(shoplist)
	local cjson     = require("cjson")
	itemsList = shoplist
end

function WishCoinShopView.clear()
	itemIconInfo = {}
	itemsList    = {}
	WishCoinShopView.getShop = false
end

function resetLabelStr(node,isButton,textColor,outLineColor,outLine,sStr,replace)
	local label = nil
	if isButton then
		label = node:getTitleRenderer()
        label:setTTFConfig({fontFilePath = CSResourceMgr.LANG_FONT[LuaSqlite.LANG_TYPE] or CSResourceMgr.LANG_FONT[1],
        fontSize = node:getTitleFontSize(), glyphs = "DYNAMIC"})
	else
        node:setFontName(CSResourceMgr.LANG_FONT[LuaSqlite.LANG_TYPE] or CSResourceMgr.LANG_FONT[1])
		label = node
	end
	
	if sStr then
		sStr = LuaSqlite.getLanguageByKey(sStr)
		label:setString(sStr)
	else
		local str = label:getString()
		str = LuaSqlite.getLanguageByKey(str)
		-- str = '[{"color":"FF0F00","text":"+700*法强的魔法攻击攻+++++++++"}]'
		if CocosModuleMgr.checkIsRichLabelString(str) then
			label:setString("")
			local labelMaxWidth = 500
            -- local dibanNode = CSResourceMgr.getNodeByName(resNameS, "diban")
            local RFontSize = label:getFontSize()
            if replace then
            	str = string.gsub(str,"<1>",replace)
            end
            local richLabelS = CocosModuleMgr.createRichLabel(node, str, RFontSize, "cuyuan_GBK.ttf", labelMaxWidth, 0, 0, nil, true)
            local labelHeight = richLabelS.realHeight
            -- if richLabelS.realWidth>labelMaxWidth then
            --     richLabelS:setPosition(node:getPositionX()-labelMaxWidth/2, node:getPositionY()+labelHeight)
            -- else
            --     richLabelS:setPosition(node:getPositionX()-richLabelS.realWidth/2, node:getPositionY()+labelHeight)
            -- end
        else
        	if replace then
            	str = string.gsub(str,"<1>",replace)
            end
        	label:setString(str)
        end
		
	end
	if outLineColor then
		label:enableOutline(outLineColor, outLine)
	end
	if textColor then
		label:setTextColor(textColor)
	end
end

function WishCoinShopView.hide()
	WishCoinShopView.clear()
	CSResourceMgr.removeCSObjectByTag(resName)
	CSResourceMgr.removeCSObjectByTag(resNameDB)
end


function WishCoinShopView.show()
	local isWishCoin = true
	local layer      = nil
	local function loadDB()
		local layerDB = CSResourceMgr.createRes(SceneMgr.getRunningScene,resNameDB)
		CocosModuleMgr.setRelativePosition(layerDB,320,480)
		layerDB:zorder(CocosModuleMgr.ZORDER_CHAT) 
	end

	local function loadCSB()
		layer  = CSResourceMgr.createRes(SceneMgr.getRunningScene,resName)	
		local title  = CSResourceMgr.getNodeByName(resName,"title")
		local tab1   = CSResourceMgr.getNodeByName(resName,"tab1")
		local tab2   = CSResourceMgr.getNodeByName(resName,"tab2")
		local edge   = CSResourceMgr.getNodeByName(resName,"edge")
		local frame  = CSResourceMgr.getNodeByName(resName,"frame")
		local list   = CSResourceMgr.getNodeByName(resName,"detailList")
		local updatelabel = CSResourceMgr.getNodeByName(resName,"updatelabel")
		local ltsize 	= list:getContentSize() 
		local diff 		= CocosModuleMgr.getScreenSizeDiff()
		local frameSize = frame:getContentSize() 
        list:setContentSize(ltsize.width, ltsize.height+diff) 
        frame:setContentSize(frameSize.width, frameSize.height+diff) 

		CocosModuleMgr.setRelativePosition(layer,320,480)
		CocosModuleMgr.setEdgeDistance(layer, nil, nil, 5, nil, false) 
		layer:zorder(CocosModuleMgr.ZORDER_CHAT)
		edge:zorder(12)
		WishCoinShopView.tab1 = tab1
		WishCoinShopView.tab2 = tab2
		resetLabelStr(updatelabel,false,{r=93,g=196,b=244,a=255},{r=0,g=0,b=0,a=255},1) 
		resetLabelStr(title,false,{r=214,g=245,b=251,a=255},{r=0,g=0,b=0,a=255},1)
		resetLabelStr(tab1,true,{r=255,g=255,b=255,a=255},{r=0,g=0,b=0,a=255},1)
		resetLabelStr(tab2,true,{r=82,g=82,b=82,a=255},{r=255,g=255,b=255,a=255},1)
		CSResourceMgr.setLabelMaxWidthByNode(updatelabel, 248, 1)
		updatelabel:setAnchorPoint(1,0)
		CSResourceMgr.setButtonEnabledByNode(tab1,false)  
		tab1:setScale(1.15,1.15) 
		tab1:zorder(preOrder) 
		tab2:zorder(beOrder)
		CSResourceMgr.clickEventBindingByNode(tab1,function()
				WishCoinShopView.sendServerShopType(Proto.SHOP_WISH,WishCoinShopView.setWishPrice)
			end)
		CSResourceMgr.clickEventBindingByNode(tab2,function()
				WishCoinShopView.sendServerShopType(Proto.SHOP_DREAM,WishCoinShopView.setDreamPrice)
			end)
	end
	local function loadItems()
		WishCoinShopView.resetItems(1)
		CocosModuleMgr.showUIAnimation(layer, "down")
	end
	local funcTable = {loadDB,loadCSB,loadItems}
	for key,var in pairs(funcTable) do
		var()
	end

end

function WishCoinShopView.resetItems(wishType)
	local itemList = CSResourceMgr.getNodeByName(resName,"detailList")
	CSResourceMgr.removeListByNode(itemList) 
	itemIconInfo.coneSp   = {}
	itemIconInfo.coinNum  = {}
	itemIconInfo.limtNum  = {}
	itemIconInfo.storeNum = {}
	itemIconInfo.itemDB   = {}
	itemIconInfo.itemNumber = {}
	local itemDB = CSResourceMgr.getNodeByName(resName,"itemDB")
	local shopType = Proto.SHOP_WISH
	if wishType ~= 1 then
		shopType = Proto.SHOP_DREAM 
	end
	for key,var in pairs(itemsList) do
		local item = itemDB:clone()
		local limitFont = CSResourceMgr.seekNodeByName(item, "limitFont")
		local storeNum  = CSResourceMgr.seekNodeByName(item, "storeNum")
		local limtNum   = CSResourceMgr.seekNodeByName(item, "limtNum")
		local itemName  = CSResourceMgr.seekNodeByName(item, "itemName")
		local coinNum   = CSResourceMgr.seekNodeByName(item, "coinNum")
		local prePrice  = CSResourceMgr.seekNodeByName(item, "prePrice")
		local showLabel = CSResourceMgr.seekNodeByName(item, "showLabel")
		local line      = CSResourceMgr.seekNodeByName(item, "line") 
		local prePriceStr = LuaSqlite.getLanguageByKey("MxbShoptips6") 
		local storeNumSize = storeNum:getContentSize()

		limtNum:hide()
		itemIconInfo.coneSp[#itemIconInfo.coneSp+1]     = CSResourceMgr.seekNodeByName(item, "coneSp")
		itemIconInfo.storeNum[#itemIconInfo.storeNum+1] = storeNum
		itemIconInfo.limtNum[#itemIconInfo.limtNum+1]   = limtNum
		itemIconInfo.coinNum[#itemIconInfo.coinNum+1]   = coinNum
		itemIconInfo.itemDB[#itemIconInfo.itemDB+1]     = item
		itemIconInfo.itemNumber[#itemIconInfo.itemNumber+1] = var.num
		CSResourceMgr.seekNodeByName(item, "headDB"):setColor({r=128,g=161,b=172,a=255})
		CSResourceMgr.seekNodeByName(item, "nameDB"):setColor({r=81,g=112,b=137,a=255})
		CSResourceMgr.seekNodeByName(item, "coinDB"):setColor({r=44,g=74,b=99,a=255})
		
		if key == 1 then
			prePriceStr = string.gsub(prePriceStr,"<1>",var.price*2)
			itemIconInfo.prePrice = prePrice
			resetLabelStr(prePrice,false,{r=215,g=224,b=225,a=255},{r=0,g=0,b=0,a=255},1)
			prePrice:setString(prePriceStr)
			local spCheap =  display.newSprite(CocosModuleMgr.getWordImage("remark2.png")) 
			spCheap:zorder(10)
			spCheap:addTo(item)
			spCheap:setPosition(42,66) 
			local priceSize = prePrice:getContentSize()
			line:setContentSize(priceSize.width+5,line:getContentSize().height) 
		else
			prePrice:hide() 
			line:hide()
		end 
		local element   = ItemInfo.getAwardElementInfoById(var.itemID)
		local headSP   = ItemInfo.getItemIconById(element.elementID,var.num, nil, true)
		local headName = CSResourceMgr.seekNodeByName(headSP,"name")
		headSP:addTo(item)
		headSP:setPosition(59,56)
		headSP:setScale(0.72,0.72)
		headName:hide()
		itemName:setString(headName:getString())
		
		local itemType = ItemInfo.getItemType(element.elementID)
		local desc     = ItemInfo.getItemInfoById(element.elementID).desc
		if itemType == 4 then
			local rare     = CSResourceMgr.seekNodeByName(headSP,"rare")
			CSResourceMgr.seekNodeByName(headSP,"rareBack"):hide()
			rare:setPosition(117,120)
			rare:setScale(0.8,0.8)
		end

		limtNum:setPositionX(storeNumSize.width+2+storeNum:getPositionX())
		
		coinNum:setString(var.price)
		storeNum:setString(var.count)
		showLabel:setString(LuaSqlite.getLanguageByKey(desc))

		resetLabelStr(limitFont,false,{r=182,g=195,b=209,a=255},{r=0,g=0,b=0,a=255},1)
		if var.count <= 0 then
			resetLabelStr(storeNum,false,{r=255,g=0,b=0,a=255},{r=0,g=0,b=0,a=255},1)
		else
			resetLabelStr(storeNum,false,{r=255,g=255,b=255,a=255},{r=0,g=0,b=0,a=255},1)
		end
		resetLabelStr(limtNum,false,{r=255,g=255,b=255,a=255},{r=0,g=0,b=0,a=255},1)
		resetLabelStr(coinNum,false,{r=255,g=246,b=0,a=255},{r=0,g=0,b=0,a=255},1)
		resetLabelStr(itemName,false,{r=255,g=246,b=0,a=255},{r=0,g=0,b=0,a=255},1) 

		CSResourceMgr.clickEventBindingByNode(item,function()
				if itemsList[key].count <= 0 then
					-- TipsMgr.show(SceneMgr.getRunningScene, "exchange066")
					StandardTipsMgr.show(1, "exchange066")
				else
					BuyItemViewMgr.wishShopShow(SceneMgr.getRunningScene, element.elementID,wishType, 
						var.price, var.count,shopType, key-1,var.num,wishShopCallback)
				end
			end)

		CSResourceMgr.clickEventBindingByNode(headSP,function()
                if element.elementType == Proto.AET_ITEM then
                    ItemInfoViewMgr.show({id = element.elementID,type = 1}, false)
                -- elseif element.elementType == Proto.AET_PET then
                --     PetInfoViewMgr.show(SceneMgr.getRunningScene, itemInfo.elementID)
                else
                    ItemInfoViewMgr.show({id = ItemInfo.AWARD[element.elementType],type = 1}, false) 
                end
            end)

		itemList:pushBackCustomItem(item)
		item:setScale(1,0)
		item:performWithDelay(function() 
				item:scaleTo(0.03, 1)
			end, 0.03*(key-1))
	end
end

function WishCoinShopView.sendServerShopType(shopType,callback)

	local function changeUI()
		if not CSResourceMgr.getCsbObj(resName) then
        	curShop = Proto.SHOP_WISH
    		WishCoinShopTopBar.show()
			WishCoinShopView.show()
    	else
    		if callback then
    			callback()
    		end
    	end
	end

	WishCoinShopView.getShop = true
	NetInterface.sendWithBlock("GC_GETSHOP_ACK", function()
            local CommonShopSend = require("src.Net.Send.CommonShopSend")
            CommonShopSend.sendCG_getShop_Req({type = shopType})
        end, function()	
            WishCoinShopView.getShop = true
            local offsetTime = SystemInfo.getGlobalConfigAddInfoByID(94).values[1] * 3600
            local dayDiff = CocosModuleMgr.getDayTimeDiff(wishShopCreateTime, 
            					CharInfo.getServerTime(),offsetTime) 
            if dayDiff ~= 0 then
                NetInterface.sendWithBlock("GC_SystemRefreshGoods_Ack", function()
                    local CommonShopSend = require("src.Net.Send.CommonShopSend")
                    CommonShopSend.sendCG_SystemRefreshGoods_Req({type = shopType,})
                end, function()
                	WishCoinShopView.sendServerShopType(shopType,callback)
                end, function(code)
                    TipsMgr.showError(scene, code)
                end)
            else
                changeUI()
            end
            
        end, function(code)
            TipsMgr.showError(scene, code)
        end)
end

function WishCoinShopView.setWishShopCreateTime(timeData)
	wishShopCreateTime = timeData
end

function wishShopCallback(key,count)
	WishCoinShopTopBar.update()

	local storeValue =  tonumber(itemIconInfo.storeNum[key]:getString())
	storeValue = storeValue - count
	if storeValue <= 0 then
		itemIconInfo.storeNum[key]:setTextColor({r=255,g=0,b=0,a=255})
		storeValue = 0
		itemsList[key].count = 0
	end
	itemIconInfo.storeNum[key]:setString(storeValue)
end

function WishCoinShopView.setWishPrice()
	local scaleTime = 0.05
	
	CSResourceMgr.setButtonEnabledByNode(WishCoinShopView.tab2,true) 
	CSResourceMgr.setButtonEnabledByNode(WishCoinShopView.tab1,false) 
	WishCoinShopView.tab2:scaleTo(scaleTime,1.0)
	WishCoinShopView.tab1:scaleTo(scaleTime,1.15)
	WishCoinShopView.tab1:zorder(preOrder)
	WishCoinShopView.tab2:zorder(beOrder)
	resetLabelStr(WishCoinShopView.tab1,true,{r=255,g=255,b=255,a=255},{r=0,g=0,b=0,a=255},1)
	resetLabelStr(WishCoinShopView.tab2,true,{r=82,g=82,b=82,a=255},{r=255,g=255,b=255,a=255},1)
	WishCoinShopView.resetItems(1)
	for key,var in pairs(itemsList) do
		CSResourceMgr.setSpriteTextureByNode(itemIconInfo.coneSp[key], "Pet/Education/icn_summon_01.png",true)
	end

	curShop = Proto.SHOP_WISH
end

function WishCoinShopView.setDreamPrice()
	local scaleTime = 0.05

	CSResourceMgr.setButtonEnabledByNode(WishCoinShopView.tab1,true) 
	CSResourceMgr.setButtonEnabledByNode(WishCoinShopView.tab2,false) 
	WishCoinShopView.tab1:scaleTo(scaleTime,1.0)
	WishCoinShopView.tab2:scaleTo(scaleTime,1.15)
	WishCoinShopView.tab1:zorder(beOrder)
	WishCoinShopView.tab2:zorder(preOrder)
	resetLabelStr(WishCoinShopView.tab2,true,{r=255,g=255,b=255,a=255},{r=0,g=0,b=0,a=255},1) 
	resetLabelStr(WishCoinShopView.tab1,true,{r=82,g=82,b=82,a=255},{r=255,g=255,b=255,a=255},1)
	WishCoinShopView.resetItems(2)
	for key,var in pairs(itemsList) do
		CSResourceMgr.setSpriteTextureByNode(itemIconInfo.coneSp[key], "Pet/Education/icn_dream_01.png",true)
	end

	curShop = Proto.SHOP_DREAM
end

return WishCoinShopView