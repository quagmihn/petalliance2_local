local FamilySignData = class("FamilySignData")

FamilySignData.OPEN      		= "OPEN"
FamilySignData.SIGN             = "SIGN"

function FamilySignData:ctor()
	self.info = FamilyInfo.GetLocalFamilyInfo()
	self.persons = 50
	self.familySignTime = 0
	self.rewardNum = 0
	self.isSign = false
	cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
	self.FamilySignServer = FamilySignServer.new()
	self.FamilySignServer:registerScriptHandler(handler(self,self.openSuccess),self.FamilySignServer.OPEN)
	self.FamilySignServer:registerScriptHandler(handler(self,self.signSuccess),self.FamilySignServer.SIGN)
end

function FamilySignData:openSuccess(data)
	self.familySignTime = data.familySignTime or 0
	self.persons        = data.persons
	self.info.familyLevel = data.familyLevel
	self.rewardNum = 500+self.info.familyLevel*80 + self.persons*10
	if false == self:checkFresh() then
		self.isSign = true
	end
	self:dispatchEvent({name =  FamilySignData.OPEN})
end

function FamilySignData:sendSign()
	self.FamilySignServer:sendSign()
end

function FamilySignData:signSuccess()
	self:dispatchEvent({name =  FamilySignData.SIGN})
end
function FamilySignData:checkFresh()
	local serverTime   = CharInfo.getServerTime()
	local familySignTime = tonumber(self.familySignTime) or 0
	local needSec = SystemInfo.getGlobalConfigAddInfoByID(6900).values[1]
	local dayDiff = CocosModuleMgr.getDayTimeDiff(familySignTime, serverTime, needSec) 
	if dayDiff == 0 then
		print("checkFresh  0",familySignTime)
		return false
	else
		print("checkFresh  1",familySignTime)
		return true
	end
end
return FamilySignData