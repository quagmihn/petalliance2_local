local FamilySignView = class("FamilySignView")
local FamilySignData = require("src.GameMgr.Player.FamilySignData")
local scene   =  nil
local resName =  "Player/Family/sign.csb"

function FamilySignView:ctor(parent)
	scene = parent
	self.signData = FamilySignData.new()
	self.signData:addEventListener(FamilySignData.OPEN,handler(self,self.show))
	self.signData:addEventListener(FamilySignData.SIGN,handler(self,self.finishSignUI))
	
	-- self.signData:dispatchEvent({name =  FamilySignData.OPEN})
end

function FamilySignView:finishSignUI()
	print("FamilySignView.finishSignUI")
	local cjson = require("cjson")
	local award = {}
	local info  = {}
	info.aID = 1
	info.elementType = "item"
	info.num = self.signData.rewardNum 
	info.elementID = 9994

	award[1] = cjson.encode(info)
	AwardsListMgr.show(scene,award)
	CSResourceMgr.setButtonEnabledByNode(self.btn, false)
	resetLabelStr(self.btn,true,nil,{r=0,g=0,b=0,a=255},1,"familySignIn8")
end

function FamilySignView:onClickSign()
	self.signData:sendSign()
end

function FamilySignView:hide()
	CSResourceMgr.removeCSObjectByTag(resName)
end

function FamilySignView:show()
	local layer   = CSResourceMgr.createRes(scene,resName)
	local close   = CSResourceMgr.getNodeByName(resName,"close")
	self.btn     = CSResourceMgr.getNodeByName(resName,"btn")
	local level   = CSResourceMgr.getNodeByName(resName,"level")
	local persons = CSResourceMgr.getNodeByName(resName,"persons")
	local num     = CSResourceMgr.getNodeByName(resName,"num")
	local rewardStr = CSResourceMgr.getNodeByName(resName,"rewardStr")
	local rule      = CSResourceMgr.getNodeByName(resName,"rule")
	local detail    = CSResourceMgr.getNodeByName(resName,"detail")
	local name      = CSResourceMgr.getNodeByName(resName,"name")
	CocosModuleMgr.setRelativePosition(layer,320,480)
	layer:zorder(CocosModuleMgr.ZORDER_CHAT)

	CocosModuleMgr.showUIAnimation(layer, "down")

	resetLabelStr(self.btn,true,nil,{r=0,g=0,b=0,a=255},1)
	resetLabelStr(level,false,nil,nil,1,nil,self.signData.info.familyLevel or 1) 
	resetLabelStr(persons,false,nil,nil,1,nil,self.signData.persons)
	resetLabelStr(rewardStr,false,nil,{r=0,g=0,b=0,a=255},1)
	resetLabelStr(num,false,nil,{r=0,g=0,b=0,a=255},1,self.signData.rewardNum)
	resetLabelStr(name,false,{r=166,g=243,b=255,a=255},{r=0,g=0,b=0,a=255},1)
	resetLabelStr(rule,false,nil,nil,1)
	resetLabelStr(detail,false,nil,nil,1)

	if self.signData.isSign then
		CSResourceMgr.setButtonEnabledByNode(self.btn, false)
		resetLabelStr(self.btn,true,nil,{r=0,g=0,b=0,a=255},1,"familySignIn8")
	end

	CSResourceMgr.clickEventBindingByNode(close, function()
				self:hide()
		end, 1)

	CSResourceMgr.clickEventBindingByNode(self.btn, function()
				self:onClickSign()
		end, 1)

end

return FamilySignView