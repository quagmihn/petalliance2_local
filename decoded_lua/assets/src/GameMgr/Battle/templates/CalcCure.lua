local CalcCure = class("CalcCure", BattleTemplate)

function CalcCure:ctor(templateInfo)

    CalcCure.super.ctor(self, templateInfo)

end

function CalcCure:work(data, ownerPet, templateLevel,skill)

    local cureRatio = data:getParamValue("治疗比例", templateLevel)
    cureRatio = BattleAidFunc.str2Percent(cureRatio)
    ownerPet.triggerBuff.cureValue = CalCure(ownerPet, BattleCotroller.getCurrentBattle().attackTarget, skill, false) * cureRatio

end

function CalcCure:getSkillDesc(data, templateLevel)

    local cureRatio = data:getParamValue("治疗比例", templateLevel)
    cureRatio = BattleAidFunc.str2Percent(cureRatio)
    return BattleAidFunc.getSkillDesc(data, templateLevel, {["治疗比例"] = (cureRatio*100).."%%"})

end

return CalcCure