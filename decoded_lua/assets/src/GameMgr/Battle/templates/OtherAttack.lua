local OtherAttack = class("OtherAttack", BattleTemplate)

function OtherAttack:ctor(templateInfo)

    OtherAttack.super.ctor(self,templateInfo)

end

function OtherAttack:work(data, ownerPet, templateLevel)

    BattleCotroller.getCurrentBattle().attackTarget = BattleCotroller.getCurrentBattle().defencePet

    local multiRatio = BattleAidFunc.str2Percent(data:getParamValue("场下伤害比例", templateLevel))

    BattleCotroller.getCurrentBattle():fight2(multiRatio)

end

function OtherAttack:getSkillDesc(data, templateLevel)
    
    local damageRatio2 = data:getParamValue("场下伤害比例", templateLevel)
    damageRatio2 = BattleAidFunc.str2Percent(damageRatio2)

    return BattleAidFunc.getSkillDesc(data, templateLevel, {
        ["场下伤害比例"] = (damageRatio2*100).."%%",
    })

end

return OtherAttack