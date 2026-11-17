local OrderManDataMgr = class("OrderManDataMgr")
local OrderManServerMgr = require("src.GameMgr.OrderMan.OrderManServerMgr")
local PasswordProductInfoConfig = nil

OrderManDataMgr.OPEN      		= "OPEN"
OrderManDataMgr.SENDORDER 		= "SENDORDER"
OrderManDataMgr.BUYPRODUCT     	= "BUYPRODUCT"
OrderManDataMgr.products  =  {}

function OrderManDataMgr:ctor()
	self.passwordProduct  = nil
	self.passwordGiftTime = nil
	self.passwordGiftNum  = nil
	self.passwordGiftNumMax = SystemInfo.getGlobalConfigAddInfoByID(95).values[1]
	cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
	self.OrderManServer = OrderManServerMgr.new()
	self.OrderManServer:registerScriptHandler(handler(self,self.openSuccess),self.OrderManServer.OPEN)
	self.OrderManServer:registerScriptHandler(handler(self,self.sendOrderSuccess),self.OrderManServer.SENDORDER)
	self.OrderManServer:registerScriptHandler(handler(self,self.buyProductSuccess),self.OrderManServer.BUYPRODUCT)

	if PasswordProductInfoConfig==nil then
        PasswordProductInfoConfig = require("src.DatReader.PasswordProductInfoConfig")
        PasswordProductInfoConfig.init()
    end

end
--[[
	data.id=Proto.parseDWORD(entry); -- 
	data.group=Proto.parseDWORD(entry); -- 
	data.productType=Proto.parseDWORD(entry); -- 
	data.productId=Proto.parseDWORD(entry); -- 
	data.num=Proto.parseDWORD(entry); -- 
	data.params=Proto.parseString(entry); -- 
	data.weight=Proto.parseDWORD(entry); -- 
	data.passwordCoin=Proto.parseDWORD(entry); -- 
]]
function OrderManDataMgr:getPasswordProductInfoById(id)
	return PasswordProductInfoConfig.readEntryByID(id)
end

function OrderManDataMgr:reducePasswordGiftNum()
	self.passwordGiftNum = self.passwordGiftNum + 1
end

function OrderManDataMgr:buyProductSuccess(buyProduct)

	self:dispatchEvent({name =  OrderManDataMgr.BUYPRODUCT,buyProductID = buyProduct})
end

function OrderManDataMgr:buyProduct(buyProductID)
	self.OrderManServer:buyProduct(buyProductID)
end

function OrderManDataMgr:openSuccess(data)
	self.passwordProduct  = data.passwordProduct
	self.passwordGiftTime = data.passwordGiftTime
	self.passwordGiftNum  = data.passwordGiftNum
	self:dispatchEvent({name =  OrderManDataMgr.OPEN})
end

function OrderManDataMgr:sendOrderSuccess(str)
	print("buyProductSuccess",sz_T2S(OrderManDataMgr.products))
	self.passwordProduct = OrderManDataMgr.products
	self:dispatchEvent({name =  OrderManDataMgr.SENDORDER,str = str})
	print("buyProductSuccess   after")
end

function OrderManDataMgr:sendOrder(str)
	self.OrderManServer:setOrderString(str)
end

function OrderManDataMgr:checkFreshOrderMan()
	local serverTime   = CharInfo.getServerTime()
	local passwordTime = tonumber(self.passwordGiftTime) or 0
	local needSec = SystemInfo.getGlobalConfigAddInfoByID(6900).values[1]
	local dayDiff = CocosModuleMgr.getDayTimeDiff(passwordTime, serverTime, needSec) 
	if dayDiff == 0 then
		print("checkFreshOrderMan  0",passwordTime)
		return false
	else
		print("checkFreshOrderMan  1",passwordTime)
		return true
	end
	return false
end

return OrderManDataMgr