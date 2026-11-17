local Cure = class("Cure", BattleTemplate)

function Cure:ctor(templateInfo)

    Cure.super.ctor(self, templateInfo)
end

function Cure:work(data, ownerPet, templateLevel)

    BattleCotroller.getCurrentBattle().attackTarget = ownerPet
    BattleCotroller.getCurrentBattle().attackType = ATTACK_CURE

    local cureRatio = data:getParamValue("治疗比例", templateLevel)
    if cureRatio == nil then
        return
    end
    local cureRatio = BattleAidFunc.str2Percent(cureRatio)
    BattleCotroller.getCurrentBattle():fight(cureRatio, nil, true)
    
end

function Cure:getSkillDesc(data, templateLevel)

    local cureRatio = data:getParamValue("治疗比例", templateLevel)
    cureRatio = BattleAidFunc.str2Percent(cureRatio)
    return BattleAidFunc.getSkillDesc(data, templateLevel, {["治疗比例"] = (cureRatio*100).."%%"})

end

return Cure