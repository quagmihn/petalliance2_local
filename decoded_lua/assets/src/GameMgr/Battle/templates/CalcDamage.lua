local CalcDamage = class("CalcDamage", BattleTemplate)

function CalcDamage:ctor(templateInfo)

    CalcDamage.super.ctor(self, templateInfo)

end

function CalcDamage:work(data, ownerPet, templateLevel)

    local damageRatio = data:getParamValue("伤害比例", templateLevel)
    damageRatio = BattleAidFunc.str2Percent(damageRatio)
    BattleCotroller.getCurrentBattle():getEnemy(ownerPet).triggerBuff.damageValue = CalDamage(ownerPet, BattleCotroller.getCurrentBattle().attackTarget, ownerPet:getSelectedSkill(), false) * damageRatio

end

function CalcDamage:getSkillDesc(data, templateLevel)

	local damageRatio = data:getParamValue("伤害比例", templateLevel)
	damageRatio = BattleAidFunc.str2Percent(damageRatio)
    return BattleAidFunc.getSkillDesc(data, templateLevel, {["伤害比例"] = (damageRatio*100).."%%"})

end

return CalcDamage