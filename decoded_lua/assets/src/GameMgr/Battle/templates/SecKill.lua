local SecKill = class("SecKill", BattleTemplate)

function SecKill:ctor(templateInfo)

    SecKill.super.ctor(self, templateInfo)

end

function SecKill:work(data, ownerPet, templateLevel)
    
    local attackType = BattleCotroller.getCurrentBattle().attackType
    if (ATTACK_ATTACK == attackType or ATTACK_CHAOS == attackType) then
        local dmgageType = data:getParamValue("秒杀类型",templateLevel)
        local skill = ownerPet:getSelectedSkill()
        local enemyPet = BattleCotroller.getCurrentBattle():getEnemy(ownerPet)
        if dmgageType == "物理秒杀" then
            if ownerPet:getAttribute(Proto.AT_ATK) > enemyPet:getAttribute(Proto.AT_DEF) 
                and 3 == skill.info.skill_B_Type then
                BattleCotroller.getCurrentBattle().finaldamage = enemyPet.hp
                ownerPet.attributes.ignoreDef = true
            end
        elseif dmgageType == "魔法秒杀" then
            if ownerPet:getAttribute(Proto.AT_SATK) > enemyPet:getAttribute(Proto.AT_SDEF) 
                and 4 == skill.info.skill_B_Type then
                BattleCotroller.getCurrentBattle().finaldamage = enemyPet.hp
                ownerPet.attributes.ignoreDef = true
            end
        end
    end

end

function SecKill:getSkillDesc(data, templateLevel)

    return BattleAidFunc.getSkillDesc(data, templateLevel)

end

return SecKill