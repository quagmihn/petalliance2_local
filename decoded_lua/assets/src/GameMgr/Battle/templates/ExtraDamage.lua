local ExtraDamage = class("ExtraDamage", BattleTemplate)

function ExtraDamage:ctor(templateInfo)

    ExtraDamage.super.ctor(self,templateInfo)

end

function ExtraDamage:work(data,ownerPet,templateLevel)

	if not BattleCotroller.getCurrentBattle().miss then
	    local damageRatio = data:getParamValue("伤害比例", templateLevel)
	    damageRatio = BattleAidFunc.str2Percent(damageRatio)

	    local dmgageType = data:getParamValue("伤害类型",templateLevel)

	    local enemyPet = BattleCotroller.getCurrentBattle():getEnemy(ownerPet)
	    if dmgageType == "物攻" then
	        local damageValue = ownerPet:getAttribute(Proto.AT_ATK) * damageRatio
	        damageValue = BattleAidFunc.normalize(damageValue)
	        enemyPet:addBuffDamage(damageValue)
	        -- BattleCotroller.getCurrentBattle():addExtraDamage(damageValue) 
	    elseif dmgageType == "魔攻" then
	        local damageValue = ownerPet:getAttribute(Proto.AT_SATK) * damageRatio
	        damageValue = BattleAidFunc.normalize(damageValue)
	        enemyPet:addBuffDamage(damageValue)
	        -- BattleCotroller.getCurrentBattle():addExtraDamage(damageValue)
	    elseif dmgageType == "血量上限" then
	    	local damageValue = ownerPet:getAttribute(Proto.AT_HP) * damageRatio
	        damageValue = BattleAidFunc.normalize(damageValue)
	        enemyPet:addBuffDamage(damageValue) 
	        -- BattleCotroller.getCurrentBattle():addExtraDamage(damageValue)
	    elseif dmgageType == "物防" then
	    	local damageValue = ownerPet:getAttribute(Proto.AT_DEF) * damageRatio
	        damageValue = BattleAidFunc.normalize(damageValue)
	        enemyPet:addBuffDamage(damageValue) 
       elseif dmgageType == "魔防" then
	    	local damageValue = ownerPet:getAttribute(Proto.AT_SDEF) * damageRatio
	        damageValue = BattleAidFunc.normalize(damageValue)
	        enemyPet:addBuffDamage(damageValue) 
	    end
	end

end


function ExtraDamage:getSkillDesc(data, templateLevel)

	local damageRatio = data:getParamValue("伤害比例", templateLevel)
	damageRatio = BattleAidFunc.str2Percent(damageRatio)
    return BattleAidFunc.getSkillDesc(data, templateLevel, {["伤害比例"] = (damageRatio*100).."%%"})

end

return ExtraDamage