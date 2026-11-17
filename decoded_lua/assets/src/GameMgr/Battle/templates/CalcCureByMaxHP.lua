local CalcCureByMaxHP = class("CalcCureByMaxHP", BattleTemplate)

function CalcCureByMaxHP:ctor(templateInfo)

    CalcCureByMaxHP.super.ctor(self, templateInfo)

end

function CalcCureByMaxHP:work(data, ownerPet, templateLevel)

    local cureRatio = data:getParamValue("治疗比例", templateLevel)
    cureRatio = BattleAidFunc.str2Percent(cureRatio)
    ownerPet.triggerBuff.cureValue = ownerPet:getAttribute(Proto.AT_HP) * cureRatio

end

function CalcCureByMaxHP:getSkillDesc(data, templateLevel)

	local cureRatio = data:getParamValue("治疗比例", templateLevel)
    cureRatio = BattleAidFunc.str2Percent(cureRatio)
    return BattleAidFunc.getSkillDesc(data, templateLevel, {["治疗比例"] = (cureRatio*100).."%%"})

end

return CalcCureByMaxHP