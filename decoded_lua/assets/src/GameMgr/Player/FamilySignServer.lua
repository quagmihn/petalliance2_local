local FamilySignServer = class("FamilySignServer")
function FamilySignServer:ctor()
	self.listener_ = {}
	self.OPEN      = 1
	self.SIGN      = 2
	self.state  = self.OPEN
end

function FamilySignServer:registerScriptHandler(listener,state) 
	-- self.nextListenerIndex = self.nextListenerIndex + 1
	if nil == self.listener_[state] then
		self.listener_[state] = {}
	end
	self.listener_[state] = listener
	if self.state == state and self.OPEN == self.state then
		self:receiveData()
	end
end

function FamilySignServer:sendSign()
	self.state = self.SIGN

	NetInterface.sendWithBlock("GC_Family_Ack", function()
	    local FamilySend = require("src.Net.Send.FamilySend")
	    local pagetable = {}
		local str = json.encode(pagetable)
	    FamilySend.sendCG_Family_Req({cmd = "FamilySign",concent = str}) 
	    end, function()
	    		self.listener_[self.state]() 
	        end, function(code)
	        TipsMgr.showError(nil, code)
	    end)

end

function FamilySignServer:receiveData()
	self.state =  self.OPEN

	NetInterface.sendWithBlock("GC_GetCharacterValues_Ack", function()
	    local LoginSend = require("src.Net.Send.LoginSend")
	    LoginSend.sendCG_GetCharacterValues_Req({"lastFamilySignTime"}) 
	    end, function()
	    		local data = {}
	    		data.familySignTime  = CharInfo.getLastFamilySignTime()

                NetInterface.sendWithBlock("GC_Family_Ack", function()
			    local FamilySend = require("src.Net.Send.FamilySend")
			    local pagetable = {}
    			local str = json.encode(pagetable)
			    FamilySend.sendCG_Family_Req({cmd = "QueryMyFamily",concent = str}) 
			    end, function()
			    		local info = FamilyInfo.GetLocalFamilyInfo()
			    		local serverTime   = CharInfo.getServerTime()
			    		local yesterdayTime = serverTime - 86400
			    		local date   = os.date("*t",yesterdayTime)
					    local year  = date.year
					    local month = date.month
					    local day   = date.day
					    local monthStr = month >= 10 and tostring(month) or "0"..month
					    local dayStr = day >= 10 and tostring(day) or "0"..day
					    local str    = year..monthStr..dayStr
					    if nil == info.signNum then
					    	info.signNum = {}
					    end
			    		data.persons  = info.signNum[str] or 0
			    		data.familyLevel = info.familyLevel or 1
                        print("receiveData  ",sz_T2S(info))
			            if self.listener_[self.OPEN] then
							self.listener_[self.OPEN](data)
						end
			        end, function(code)
			        TipsMgr.showError(nil, code)
			    end)

	        end, function(code)
	        TipsMgr.showError(nil, code)
	    end)

end

return FamilySignServer