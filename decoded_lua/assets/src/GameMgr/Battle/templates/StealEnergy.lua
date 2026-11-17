local StealEnergy = class("StealEnergy", BattleTemplate)

function StealEnergy:ctor(templateInfo)

    StealEnergy.super.ctor(self, templateInfo)
    
end

function StealEnergy:work(data, ownerPet, templateLevel)

    if (ATTACK_ATTACK == BattleCotroller.getCurrentBattle().attackType) then
        local value = tonumber(data:getParamValue("偷取值", templateLevel))
        ownerPet.team:addEnergyDirectly(value)

        local enemy = BattleCotroller.getCurrentBattle():getEnemy(ownerPet)
        if enemy then
            enemy.team:reduceEnergyDirectly(value)
        end
    end

end

function StealEnergy:getSkillDesc(data, templateLevel)

    local value = tonumber(data:getParamValue("偷取值", templateLevel))
    return BattleAidFunc.getSkillDesc(data, templateLevel, {["偷取值"] = value})

end

return StealEnergy