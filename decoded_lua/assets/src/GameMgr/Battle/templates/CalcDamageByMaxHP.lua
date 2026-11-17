local CalcDamageByMaxHP = class("CalcDamageByMaxHP", BattleTemplate)

function CalcDamageByMaxHP:ctor(templateInfo)

    CalcDamageByMaxHP.super.ctor(self, templateInfo)

end

function CalcDamageByMaxHP:work(data, ownerPet, templateLevel)

    local damageRatio = data:getParamValue("伤害比例", templateLevel)
    damageRatio = BattleAidFunc.str2Percent(damageRatio)

    local enemyPet = BattleCotroller.getCurrentBattle():getEnemy(ownerPet)
    enemyPet.triggerBuff.damageValue = enemyPet:getAttribute(Proto.AT_HP) * damageRatio

end

function CalcDamageByMaxHP:getSkillDesc(data, templateLevel)

    local damageRatio = data:getParamValue("伤害比例", templateLevel)
	damageRatio = BattleAidFunc.str2Percent(damageRatio)
    return BattleAidFunc.getSkillDesc(data, templateLevel, {["伤害比例"] = (damageRatio*100).."%%"})

end

return CalcDamageByMaxHP