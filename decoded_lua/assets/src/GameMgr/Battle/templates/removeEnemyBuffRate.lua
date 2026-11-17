local removeEnemyBuffRate = class("removeEnemyBuffRate", BattleTemplate)

function removeEnemyBuffRate:ctor(templateInfo)

    removeEnemyBuffRate.super.ctor(self, templateInfo)

end

function removeEnemyBuffRate:work(data, ownerPet, templateLevel)

    local tagName = data:getParamValue("buff名", templateLevel)
    local rate    = data:getParamValue("概率", templateLevel)

    rate = BattleAidFunc.str2Percent(rate)
    
    if (nil ~= tagName) then
    	local targetPet = BattleCotroller.getCurrentBattle():getEnemy(ownerPet)
    	if targetPet then
    		if GetRandom.random(0,99) < rate*100 then
	        	targetPet:removeBuffByTag(tagName)
	    	end
	    end
    end

end

function removeEnemyBuffRate:getSkillDesc(data, templateLevel)
	local rate = data:getParamValue("概率", templateLevel)
    rate = BattleAidFunc.str2Percent(rate)

    return BattleAidFunc.getSkillDesc(data, templateLevel, {["概率"] = (rate*100).."%%"})

end

return removeEnemyBuffRate