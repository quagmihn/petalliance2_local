local AOECure = class("AOECure", BattleTemplate)

function AOECure:ctor(templateInfo)

    AOECure.super.ctor(self,templateInfo)

end

function AOECure:work(data, ownerPet, templateLevel)

    BattleCotroller.getCurrentBattle().attackTarget = ownerPet
    BattleCotroller.getCurrentBattle().attackType = ATTACK_CURE

    local cureRatio = BattleAidFunc.str2Percent(data:getParamValue("场上治疗比例", templateLevel))
    local multiRatio = BattleAidFunc.str2Percent(data:getParamValue("场下治疗比例", templateLevel))
    if (nil == cureRatio or nil == multiRatio) then
        return
    end

    BattleCotroller.getCurrentBattle():fight(cureRatio, multiRatio, true)

end

function AOECure:getSkillDesc(data, templateLevel)

    local cureRatio = data:getParamValue("场上治疗比例", templateLevel)
    if cureRatio == nil then
        return "模版未实现"
    end
    cureRatio = BattleAidFunc.str2Percent(cureRatio)

    local cureRatio2 = data:getParamValue("场下治疗比例", templateLevel)
    if cureRatio2 == nil then
        return "模版未实现"
    end
    cureRatio2 = BattleAidFunc.str2Percent(cureRatio2)

    return BattleAidFunc.getSkillDesc(data, templateLevel, {
        ["场上治疗比例"] = (cureRatio*100).."%%",
        ["场下治疗比例"] = (cureRatio2*100).."%%",
    })

end

return AOECure