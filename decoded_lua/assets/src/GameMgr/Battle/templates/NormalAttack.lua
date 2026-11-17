local NormalAttack = class("NormalAttack", BattleTemplate)

function NormalAttack:ctor(templateInfo)

    NormalAttack.super.ctor(self,templateInfo)

end

function NormalAttack:work(data, ownerPet, templateLevel)
    BattleCotroller.getCurrentBattle().attackTarget = BattleCotroller.getCurrentBattle().defencePet
    BattleCotroller.getCurrentBattle().attackType = ATTACK_ATTACK
    
    local damageRatio = data:getParamValue("伤害比例", templateLevel)
    if damageRatio == nil then
        return
    end
    local damageRate = BattleAidFunc.str2Percent(damageRatio)
    BattleCotroller.getCurrentBattle():fight(damageRate)
end

function NormalAttack:getSkillDesc(data, templateLevel)
    
	local damageRatio = data:getParamValue("伤害比例", templateLevel)
    if damageRatio == nil then
        return "模版未实现"
    end
    damageRatio = BattleAidFunc.str2Percent(damageRatio)
    return BattleAidFunc.getSkillDesc(data, templateLevel, {["伤害比例"] = (damageRatio*100).."%%"})

end

return NormalAttack