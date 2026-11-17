local VampireRatioByAtt = class("VampireRatioByAtt", BattleTemplate)

function VampireRatioByAtt:ctor(templateInfo)

    VampireRatioByAtt.super.ctor(self, templateInfo)

end

function VampireRatioByAtt:work(data, ownerPet, templateLevel)

    local damageRatio = data:getParamValue("伤害比例", templateLevel)
    damageRatio = BattleAidFunc.str2Percent(damageRatio)
    local dmgageType = data:getParamValue("伤害类型",templateLevel)
    local enemyPet = BattleCotroller.getCurrentBattle():getEnemy(ownerPet)
    local damage = 0
    if dmgageType == "物攻" then--物攻   
    	damage = enemyPet:getAttribute(Proto.AT_ATK)
    elseif dmgageType == "魔攻" then--特功
    	damage = enemyPet:getAttribute(Proto.AT_SATK)
    end
    ownerPet:addBuffDamage(damage)
    
    enemyPet:addBuffCure(damage*damageRatio)

end

function VampireRatioByAtt:getSkillDesc(data, templateLevel)

	local damageRatio = data:getParamValue("伤害比例", templateLevel)
	damageRatio = BattleAidFunc.str2Percent(damageRatio)
    return BattleAidFunc.getSkillDesc(data, templateLevel, {["伤害比例"] = (damageRatio*100).."%%"})

end

return VampireRatioByAtt