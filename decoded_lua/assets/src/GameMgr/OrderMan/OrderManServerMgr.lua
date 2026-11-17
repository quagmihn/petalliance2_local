local OrderManServerMgr = class("OrderManServerMgr")

function OrderManServerMgr:ctor()
	self.listener_ = {}
	self.password      = nil
	self.useMCash      = nil
	self.buyProductID  = nil
	self.OPEN          = 1
	self.SENDORDER     = 2
	self.BUYPRODUCT    = 3
	self.state  = self.OPEN
end

function OrderManServerMgr:registerScriptHandler(listener,state)
	-- self.nextListenerIndex = self.nextListenerIndex + 1
	if nil == self.listener_[state] then
		self.listener_[state] = {}
	end
	self.listener_[state] = listener
	if self.state == state and  self.OPEN == self.state then
		self:receiveData()
	end
end

function OrderManServerMgr:setOrderString(data)
	if data then
		self.password = data
		self:sendServeOrder()
	else
		print("发送失败")
	end
end

function OrderManServerMgr:buyProduct(buyProductID)
	self.state = self.BUYPRODUCT
	print("OrderManServerMgrbuyProductID  ",buyProductID)
	NetInterface.sendWithBlock("GC_BuyPasswordProduct_Ack", function()
	    local OrderManSend = require("src.Net.Send.OrderManSend")
	    OrderManSend.sendCG_BuyPasswordProduct_Req({productID = buyProductID}) 
	    end, function()
	    	if self.listener_[self.BUYPRODUCT] then
				self.listener_[self.BUYPRODUCT](buyProductID)
			end
	        end, function(code)
	        TipsMgr.showError(nil, code)
	    end)
end

function OrderManServerMgr:receiveData()
	if nil == self.listener_[self.OPEN] then
		print("没有注册接收服务器接口")
	end

    NetInterface.sendWithBlock("GC_GetCharacterValues_Ack", function()
	    local LoginSend = require("src.Net.Send.LoginSend")
	    LoginSend.sendCG_GetCharacterValues_Req({"passwordProduct","passwordGiftTime","passwordGiftNum"}) 
	    end, function()
	    		local data = {}
	    		data.passwordProduct  = CharInfo.getPasswordProduct()
	    		data.passwordGiftTime = CharInfo.getPasswordGiftTime()
	    		data.passwordGiftNum  = CharInfo.getPasswordGiftNum()
	    		print("receiveData  ",sz_T2S(data))
	            if self.listener_[self.OPEN] then
					self.listener_[self.OPEN](data)
				end
	        end, function(code)
	        TipsMgr.showError(nil, code)
	    end)

	
end

function OrderManServerMgr:sendServeOrder()
	if nil == self.listener_[self.SENDORDER] then
		print("没有注册口命服务器接口")
		return
	end
	self.state = self.SENDORDER
	if self.password then
		-- local useMCash = SystemInfo.getGlobalConfigAddInfoByID(96).values[1]
		local password = ""
		local useMCash = 1
		if type(self.password) == "string" then
			useMCash = 0
			password = self.password
		end
		NetInterface.sendWithBlock("GC_PasswordGift_Ack", function()
	    local OrderManSend = require("src.Net.Send.OrderManSend")
	    OrderManSend.sendCG_PasswordGift_Req({password = password,useMCash = useMCash}) 
	    end, function()
	    	self.listener_[self.SENDORDER](self.password)
	    	self.password = nil
	        end, function(code)
	        TipsMgr.showError(nil, code)
	    end)
	end

end

return OrderManServerMgr