local RemoveBuffOnEnemy = class("RemoveBuffOnEnemy", BattleTemplate)

function RemoveBuffOnEnemy:ctor(templateInfo)

    RemoveBuffOnEnemy.super.ctor(self, templateInfo)

end

function RemoveBuffOnEnemy:work(data, ownerPet, templateLevel)

    local tagName = data:getParamValue("buff名", templateLevel)

    if (nil ~= tagName) then
    	local targetPet = BattleCotroller.getCurrentBattle():getEnemy(ownerPet)
    	if targetPet then
	        targetPet:removeBuffByTag(tagName)
	    end
    end

end

function RemoveBuffOnEnemy:getSkillDesc(data, templateLevel)

    return BattleAidFunc.getSkillDesc(data, templateLevel)

end

return RemoveBuffOnEnemy