local OrderManUIMgr = class("OrderManUIMgr")
local orderData    = require("src.GameMgr.OrderMan.OrderManDataMgr")
local resBk  	= "Pet/Formation/FormationBGNew.csb"
local res    	= "OrderMan/OrderManLayer.csb"
local scene  	= nil
local editBox 	= nil
local restCountstr = ""
local orderNumStr  = ""
local effAni = nil

function OrderManUIMgr:ctor(parent)
	scene = parent
	self.orderData = orderData.new()
	self.orderData:addEventListener(orderData.OPEN,handler(self,self.show))
	self.orderData:addEventListener(orderData.SENDORDER,handler(self,self.sendOrder))
	self.orderData:addEventListener(orderData.BUYPRODUCT,handler(self,self.showBuyProduct))
	self.productIcon = {}
	self.openTime = false
	-- self.orderData:dispatchEvent({name =  orderData.OPEN})
end

function OrderManUIMgr:hide()
	CSResourceMgr.removeCSObjectByTag(resBk)
	CSResourceMgr.removeCSObjectByTag(res)
	StatusBarMgr.hideTopInfoBar()
end

function OrderManUIMgr:onSendOrderClicked(data)
	local count = self.orderData.passwordGiftNumMax - self.orderData.passwordGiftNum > 0 and 
			self.orderData.passwordGiftNumMax - self.orderData.passwordGiftNum or 0
	-- if count <= 0 then
	-- 	StandardTipsMgr.show(1, "welfare15")
	-- 	return
	-- end
	self.orderData:sendOrder(data)
end

function OrderManUIMgr:show()
	local layer = nil
	local orderOwnCount = ItemInfo.getCharItemNum(9986)
	if nil == orderOwnCount then
		orderOwnCount = 0
	end
	local function loadDB()
		local layerDB = CSResourceMgr.createRes(scene,resBk)
		CocosModuleMgr.setRelativePosition(layerDB,320,480)
		layerDB:zorder(CocosModuleMgr.ZORDER_CHAT) 
	end
	local function loadCSB()
		layer = CSResourceMgr.createRes(scene,res)

		CocosModuleMgr.setRelativePosition(layer,320,480)
		CocosModuleMgr.setEdgeDistance(layer, nil, nil, 5, nil, false) 
		layer:zorder(CocosModuleMgr.ZORDER_CHAT)

		local diff 		   = CocosModuleMgr.getScreenSizeDiff()
		local itemPos      = CSResourceMgr.getNodeByName(res,"itemPos")
		local orderPng     = CSResourceMgr.getNodeByName(res,"orderPng")
		local inputOrder   = CSResourceMgr.getNodeByName(res,"inputOrder")
		local orderShopStr = CSResourceMgr.getNodeByName(res,"orderShopStr")
		local npcPos       = CSResourceMgr.getNodeByName(res,"npc")
		local help         = CSResourceMgr.getNodeByName(res,"help")

		self.title        = CSResourceMgr.getNodeByName(res,"title")
		self.dialogTxt    = CSResourceMgr.getNodeByName(res,"dialogTxt")
		self.orderNum     = CSResourceMgr.getNodeByName(res,"orderNum")
		self.rewardStr    = CSResourceMgr.getNodeByName(res,"rewardStr")	
		self.shangta      = CSResourceMgr.getNodeByName(res,"shangta")
		self.downPart     = CSResourceMgr.getNodeByName(res,"downPart")
		self.dialog       = CSResourceMgr.getNodeByName(res,"dialog")
		self.editBG       = CSResourceMgr.getNodeByName(res,"editBG")
		self.shopTip      = CSResourceMgr.getNodeByName(res,"shopTip")
		self.restTime     = CSResourceMgr.getNodeByName(res,"restTime")
		self.list         = CSResourceMgr.getNodeByName(res,"list")
		self.restCount    = CSResourceMgr.getNodeByName(res,"restCount")
		
		local rewardItem  = ItemInfo.getItemIconById(9998,200000) 

		rewardItem:addTo(itemPos)
		rewardItem:setPosition(10,10)
		rewardItem:setScale(0.6,0.6)

		CSResourceMgr.clickEventBindingByNode(rewardItem, function()
				ItemInfoViewMgr.show({id = 9998,type=1},false)
			end)

		resetLabelStr(self.title,false,{r=175,g=241,b=255,a=255},{r=31,g=56,b=78,a=255},1)
		resetLabelStr(self.dialogTxt,false)
		resetLabelStr(self.orderNum,false,{r=175,g=241,b=255,a=255},{r=0,g=0,b=0,a=255},2)
		resetLabelStr(self.rewardStr,false,nil,{r=0,g=0,b=0,a=255},1)
		resetLabelStr(self.shangta,true,nil,{r=0,g=0,b=0,a=255},1)
		resetLabelStr(self.shopTip,false,{r=175,g=241,b=255,a=255})
		resetLabelStr(inputOrder,false)
		resetLabelStr(orderShopStr,false)
		resetLabelStr(self.restCount,false)
		resetLabelStr(self.restTime,false)

		restCountstr = self.restCount:getString()
		if -1*diff < 0 then
			self.dialog:setPositionY(self.dialog:getPositionY()-diff/2) 
		end
		self.downPart:setPositionY(-1*diff)
		itemPos:setPositionY((self.dialog:getPositionY() + (-1*diff + 386))/2)
		local npcRes = "Spine/npc/em47.png"
		local npcAni = AnimationMgr.createAni(npcPos, npcRes, 
            30, -50)
		npcAni:setScale(-0.7,0.7)
		AnimationMgr.playAni(npcRes, "kaixin", true) 
		effAni = AnimationMgr.createAni(itemPos, "Spine/effects/Ui_chongwulingqujiemian.png", 
            10, 10)
        effAni:setLocalZOrder(-1)
        effAni:setScale(0.5) 
        AnimationMgr.playAni(effAni.res, "animation", true)
        self.dialogTxt:setString(self.dialogTxt:getString())
        CSResourceMgr.setLabelMaxWidthByNode(self.dialogTxt, 260)
        self.dialogTxt:setAnchorPoint(0,1)
		StatusBarMgr.showTopInfoBar(function()
			effAni:removeFromParent(true) 
            self:hide()
        end,1)
        orderNumStr = self.orderNum:getString()
		local numStr = string.gsub(orderNumStr,"<1>",orderOwnCount)
		self.orderNum:setString(numStr)
		for i = 1,3 do
			local rewardIcon = CSResourceMgr.getNodeByName(res,"item"..i)
			rewardIcon:removeFromParent()
			self.list:pushBackCustomItem(rewardIcon) 
			self.productIcon[i] = rewardIcon
		end

		editBox = CocosModuleMgr.newTextEditor(self.editBG,"empty.png",140,36,75,18,24,80,"",1,function()         
            local data = tostring(editBox:getText())
            if data then
            	self:onSendOrderClicked(data)
        	end
        	editBox:setText(data) 
        end,false)
		editBox:setText("")
		
		if self.orderData:checkFreshOrderMan() then
			self.orderData.passwordGiftNum = 0
			self.orderData.passwordProduct = nil
		end
		self:refreshProducts()
		local count = self.orderData.passwordGiftNumMax - self.orderData.passwordGiftNum > 0 and 
			self.orderData.passwordGiftNumMax - self.orderData.passwordGiftNum or 0
		local restNumStr   = string.gsub(restCountstr,"<1>",count)
		restNumStr = string.gsub(restNumStr,"<2>",self.orderData.passwordGiftNumMax)
		self.restCount:setString(restNumStr)

		CSResourceMgr.clickEventBindingByNode(orderPng, function()
				self:buyOrderItems()
			end, 2)
		CSResourceMgr.clickEventBindingByNode(help, function()
				DialogBoxMgr.showSmallDialogBox(scene,1,"welfare16",function()             
                    end,nil,nil,true)
			end)
		CSResourceMgr.clickEventBindingByNode(self.shangta, function()
				DialogBoxMgr.showSmallDialogBox(scene,2,"welfare19",function()             
                       	self:onSendOrderClicked(1)
                    end,nil,nil,false)
			end, 1)
	end
	local function Animation()
		CocosModuleMgr.showUIAnimation(layer, "down")
	end
	local funcTable = {loadDB,loadCSB,Animation}
	for key,var in pairs(funcTable) do
		var()
	end
end 

function OrderManUIMgr:onClickBuyProduct(productID)
	print("onClickBuyProduct  ")
	self.orderData:buyProduct(productID)
end

function OrderManUIMgr:checkHideProduct()
	local isRunOut = true
	if self.orderData.passwordProduct then
		for key,var in pairs(self.orderData.passwordProduct.list) do
			if nil == var.used then
				isRunOut = false
			end
		end
	end
	if true == isRunOut then
		self.openTime = false
		self:hideProducts()
		return true
	end
	return false
end

function OrderManUIMgr:showBuyProduct(event)
	local costItemCount =  ItemInfo.getCharItemNum(9986)
    local str = string.gsub(orderNumStr,"<1>",costItemCount)
    self.orderNum:setString(str)
	self.productIcon[self.clickIndex].itemIcon:setTouchEnabled(false)
	BattleFuncMgr.setNodeGray(self.productIcon[self.clickIndex].itemIcon,false)
	BattleFuncMgr.setNodeGray(self.productIcon[self.clickIndex],false) 
	BattleFuncMgr.setNodeGray(self.productIcon[self.clickIndex].head,false) 
	if self.productIcon[self.clickIndex].sp then
		BattleFuncMgr.setNodeGray(self.productIcon[self.clickIndex].sp,false)
		self.productIcon[self.clickIndex].sp = nil
	end
	self.orderData.passwordProduct.list[self.clickIndex].used = true
	-- print("OrderManUIMgr:buyProduct ",sz_T2S(event))
	local cjson = require("cjson")
	local award = {}
	local info  = {}
	local passwordInfo  = self.orderData:getPasswordProductInfoById(event.buyProductID)
	info.aID = 1
	info.elementType = ""
	info.num = passwordInfo.num
	info.elementID = passwordInfo.productId
	if passwordInfo.productType == 2 then
		info.elementType = "pet"
	elseif passwordInfo.productType == 1 then
		info.elementType = "item"
	else 
		info.elementType = "equip"
		if self.productIcon[self.clickIndex].equipID then
			info.elementID = self.productIcon[self.clickIndex].equipID
		end
	end
	award[1] = cjson.encode(info)
	AwardsListMgr.show(scene,award)
	self:checkHideProduct()
	for key,var in pairs(self.productIcon) do
    	self:checkPriceColorByKey(key)
    end
end

function OrderManUIMgr:buyOrderItems() 
	local marketInfo   = ItemInfo.getMarketInfoById(203)
	BuyItemViewMgr.show(scene, 9986, 2, marketInfo.num, 100000, 203,function()
        local costItemCount = ItemInfo.getCharItemNum(9986)
        local str = string.gsub(orderNumStr,"<1>",costItemCount)
        self.orderNum:setString(str)
        for key,var in pairs(self.productIcon) do
        	self:checkPriceColorByKey(key)
        end
    end)
end

function OrderManUIMgr:refreshRestTime(endTime)
    local restTimeSec = endTime - CharInfo.getServerTime()
	if nil == endTime then
		return
	end 
	local h 	= 0
	local h_Str = ""
	local m     = 0
	local m_Str = ""
	local s     = 0
	local s_Str = ""

	if restTimeSec > 0 then
	    h     = math.floor(restTimeSec/3600)
	    h_Str = h >= 10 and h or "0"..h
	    m     = math.floor((restTimeSec - h*3600)/60)
	    m_Str = m >= 10 and m or "0"..m
	    s     = restTimeSec - h*3600 - m*60
	    s_Str = s >= 10 and s or "0"..s
	end
    self.restTime:show()
    transition.stopTarget(self.restTime)
    if h <= 0 and m <= 0 and s <= 0 or false == self.openTime then
		self:hideProducts()
    end
    self.restTime:setString(LuaSqlite.getLanguageByKey("welfare6")..h_Str..":"..m_Str..":"..s_Str)
    self.restTime:performWithDelay(function ()
        if h <= 0 and m <= 0 and s <= 0 or false == self.openTime then
			self:hideProducts()
        else
        	self:refreshRestTime(endTime)
        end
    end, 1)
end

function OrderManUIMgr:hideProducts()
	self.shopTip:show()
    self.restTime:hide()
    for key = 1,3 do
		if self.productIcon[key] then
			self.productIcon[key]:hide()
		end
	end
end

function OrderManUIMgr:showProducts()
	self.shopTip:hide()
    self.restTime:show()
    for key = 1,3 do
		if self.productIcon[key] then
			self.productIcon[key]:show()
		end
	end
end

function OrderManUIMgr:checkPriceColorByKey(key)
	-- if self.productIcon[key] then
		local price      = self.productIcon[key].price
		if ItemInfo.getCharItemNum(9986) >= tonumber(price:getString()) then
			price:setTextColor({r=255,g=255,b=255,a=255})
		else
			price:setTextColor({r=255,g=0,b=0,a=255})
		end
	-- end
end

function OrderManUIMgr:refreshProducts()
	if self.orderData.passwordProduct  and #self.orderData.passwordProduct.list > 0 then
		local endTime = nil
		if self:checkHideProduct() then
			return
		end
		for key,var in pairs(self.orderData.passwordProduct.list) do
			local passwordInfo  = self.orderData:getPasswordProductInfoById(var.productID)
			local itemID        = passwordInfo.productId
			local itemIcon      = nil
			local iteminfo = ItemInfo.getItemInfoById(itemID)
			local cjson = require("cjson")
			local equipInfo = cjson.decode(passwordInfo.params)
			if passwordInfo.productType ~= 2 then
				itemIcon = ItemInfo.getItemIconById(itemID, passwordInfo.num, 
                nil, nil, nil)
			else
				itemIcon = ItemInfo.getPetIconById2(itemID,passwordInfo.num)
			end
			endTime = var.endTime
			if self.productIcon[key].itemIcon then
				self.productIcon[key].itemIcon:removeFromParent(true)
				self.productIcon[key].itemIcon = nil
			end
			self.productIcon[key].sp       = nil
			self.productIcon[key].price    = CSResourceMgr.seekNodeByName(self.productIcon[key],"item_num"..key)
			self.productIcon[key].head     = CSResourceMgr.seekNodeByName(itemIcon,"s")
			self.productIcon[key].price:setString(passwordInfo.passwordCoin)
			itemIcon:addTo(self.productIcon[key])
			itemIcon:setPosition(60,70)
			itemIcon:setScale(0.5,0.5)

			self.productIcon[key].itemIcon = itemIcon
			if "" == passwordInfo.params then
				if iteminfo and 26 == iteminfo.itemType then
					self.productIcon[key].sp = display.newSprite("Item/zhuangbei/weijianding.png")
					self.productIcon[key].sp:addTo(itemIcon)
					self.productIcon[key].sp:zorder(10)
					self.productIcon[key].sp:setScale(1.2,1.2)
					self.productIcon[key].sp:setPosition(itemIcon:getContentSize().width/2,itemIcon:getContentSize().height/2)
				end
			else
	        	local itemRes = PetEquipInfo.getEquipQualityBGImage(equipInfo.equipID)
	        	local info = PetEquipInfo.getPetEquipInfoById(equipInfo.equipID)
	        	self.productIcon[key].equipID = equipInfo.equipID
    			CSResourceMgr.setButtonTextureByNode(itemIcon, itemRes, itemRes, itemRes)
    			CSResourceMgr.setSpriteTextureByNode(self.productIcon[key].head, info.icon)
			end
			
			if var.used then
				self.productIcon[key].itemIcon:setTouchEnabled(false)
				BattleFuncMgr.setNodeGray(self.productIcon[key],false) 
				BattleFuncMgr.setNodeGray(self.productIcon[key].itemIcon,false)
				BattleFuncMgr.setNodeGray(self.productIcon[key].head,false) 
				if self.productIcon[key].sp then
					BattleFuncMgr.setNodeGray(self.productIcon[key].sp,false)
				end
			else
				self.productIcon[key].itemIcon:setTouchEnabled(true)
				BattleFuncMgr.setNodeGray(self.productIcon[key],true) 
				BattleFuncMgr.setNodeGray(self.productIcon[key].itemIcon,true)
				BattleFuncMgr.setNodeGray(self.productIcon[key].head,true) 
			end
			self:checkPriceColorByKey(key)
			CSResourceMgr.buttonEventBindingByNodeXP(itemIcon, function()
	        end, function()
	            if ItemInfo.getCharItemNum(9986) < passwordInfo.passwordCoin then
					self:buyOrderItems()
				else
					self.clickIndex = key
					self:onClickBuyProduct(var.productID)
				end
	        end, nil, function()
	            -- ItemInfoViewMgr.show({id = itemID,type = 1}, false)
	            -- Item/zhuangbei/weijianding.png
	        end, false, nil, function()
	        	-- if passwordInfo.productType ~= 3 then
	         --    	ItemInfoViewMgr.show({id = itemID,type = 1}, false)
	         --    else
	            	-- PetEquipmentOperationMgr.show(scene, nil, equipInfo, operationTxt, isTip, funcOperationSuccess)
	            	if passwordInfo.params ~= "" then
	            		PetEquipmentOperationMgr.show(scene, nil, equipInfo, "", "null")
	            	else
	            		if passwordInfo.productType ~= 2 then
	            			ItemInfoViewMgr.show({id = itemID,type = 1}, false)
	            		else
	            			StatusBarMgr.hideTopInfoBar()
	            			PetInfoViewMgr.show(scene, itemID,function()
	            					StatusBarMgr.showTopInfoBar(function()
							            self:hide()
							        end,1)
	            				end)
	            		end
	            	end
	        	-- end
	        end)

		end
		self.openTime = true
		self:showProducts()
		self:refreshRestTime(endTime)
	else
		self:hideProducts()
	end
	
end

function OrderManUIMgr:sendOrder(event)
	self:refreshProducts()
	self.orderData:reducePasswordGiftNum()
	local count = self.orderData.passwordGiftNumMax - self.orderData.passwordGiftNum > 0 and 
			self.orderData.passwordGiftNumMax - self.orderData.passwordGiftNum or 0
	local restNumStr   = string.gsub(restCountstr,"<1>",count)
	restNumStr = string.gsub(restNumStr,"<2>",self.orderData.passwordGiftNumMax)
	self.restCount:setString(restNumStr)
	AwardsListMgr.show(scene,{'{"aID":1,"elementType":"g_cash","num":200000}'})

end

return OrderManUIMgr