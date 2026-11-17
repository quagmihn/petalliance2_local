local MultiAttack = class("MultiAttack", BattleTemplate)

function MultiAttack:ctor(templateInfo)

    MultiAttack.super.ctor(self,templateInfo)

end

function MultiAttack:work(data, ownerPet, templateLevel)

    local battle = BattleCotroller.getCurrentBattle() 
    battle.attackTarget = BattleCotroller.getCurrentBattle().defencePet
    battle.attackType = ATTACK_ATTACK
    
    local damageRatio = data:getParamValue("伤害比例", templateLevel)
    if damageRatio == nil then
        return
    end
    local damageRate = BattleAidFunc.str2Percent(damageRatio)
    
    local count = data:getParamValue("伤害次数", templateLevel)
    if count == nil then
        return
    end
    count = tonumber(count)
    
    for i=1,count do
        local damageRate = BattleAidFunc.str2Percent(damageRatio)
        battle:fight(damageRate)
    end

end

function MultiAttack:getSkillDesc(data, templateLevel)
    
    local damageRatio = data:getParamValue("伤害比例", templateLevel)
    damageRatio = BattleAidFunc.str2Percent(damageRatio)
    
    local count = data:getParamValue("伤害次数", templateLevel)

    return BattleAidFunc.getSkillDesc(data, templateLevel, {["伤害比例"] = (damageRatio*100).."%%",["伤害次数"] = count})

end

return MultiAttack