local CureByMaxHP = class("CureByMaxHP", BattleTemplate)

function CureByMaxHP:ctor(templateInfo)

    CureByMaxHP.super.ctor(self, templateInfo)
end

function CureByMaxHP:work(data, ownerPet, templateLevel)

    BattleCotroller.getCurrentBattle().attackTarget = ownerPet
    BattleCotroller.getCurrentBattle().attackType = ATTACK_CURE

    local cureRatio = data:getParamValue("治疗比例", templateLevel)
    if cureRatio == nil then
        return
    end
    local cureRatio = BattleAidFunc.str2Percent(cureRatio)
    local cureValue = ownerPet:getAttribute(Proto.AT_HP) * cureRatio
    ownerPet:addBuffCure(cureValue)
    
end

function CureByMaxHP:getSkillDesc(data, templateLevel)

    local cureRatio = data:getParamValue("治疗比例", templateLevel)
    cureRatio = BattleAidFunc.str2Percent(cureRatio)
    return BattleAidFunc.getSkillDesc(data, templateLevel, {["治疗比例"] = (cureRatio*100).."%%"})

end

return CureByMaxHP