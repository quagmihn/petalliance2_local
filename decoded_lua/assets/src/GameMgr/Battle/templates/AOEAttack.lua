local AOEAttack = class("AOEAttack", BattleTemplate)

function AOEAttack:ctor(templateInfo)

    AOEAttack.super.ctor(self,templateInfo)

end

function AOEAttack:work(data, ownerPet, templateLevel)

    BattleCotroller.getCurrentBattle().attackTarget = BattleCotroller.getCurrentBattle().defencePet
    BattleCotroller.getCurrentBattle().attackType = ATTACK_ATTACK

    local damageRatio = BattleAidFunc.str2Percent(data:getParamValue("场上伤害比例", templateLevel))
    local multiRatio = BattleAidFunc.str2Percent(data:getParamValue("场下伤害比例", templateLevel))
    if (nil == damageRatio or nil == multiRatio) then
        return
    end

    BattleCotroller.getCurrentBattle():fight(damageRatio, multiRatio)

end

function AOEAttack:getSkillDesc(data, templateLevel)
    
	local damageRatio = data:getParamValue("场上伤害比例", templateLevel)
    if damageRatio == nil then
        return "模版未实现"
    end
    damageRatio = BattleAidFunc.str2Percent(damageRatio)

    local damageRatio2 = data:getParamValue("场下伤害比例", templateLevel)
    if damageRatio2 == nil then
        return "模版未实现"
    end
    damageRatio2 = BattleAidFunc.str2Percent(damageRatio2)

    return BattleAidFunc.getSkillDesc(data, templateLevel, {
        ["场上伤害比例"] = (damageRatio*100).."%%",
        ["场下伤害比例"] = (damageRatio2*100).."%%",
    })

end

return AOEAttack