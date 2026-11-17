local ReturnDamage = class("ReturnDamage", BattleTemplate)

function ReturnDamage:ctor(templateInfo)

    ReturnDamage.super.ctor(self, templateInfo)

    self.damageVal = 0

end

function ReturnDamage:work(data, ownerPet, templateLevel)
    
    if ATTACK_ATTACK ~= BattleCotroller.getCurrentBattle().attackType then
        return false
    end
    local returnRatio = data:getParamValue("反伤比例", templateLevel)
    returnRatio = BattleAidFunc.str2Percent(returnRatio)

    local value = BattleCotroller.getCurrentBattle().finaldamage * returnRatio
    value = BattleAidFunc.normalize(value)

    if (true == ownerPet.attributes.invincible) then
        value = 0
    end

    local attackPet = BattleCotroller.getCurrentBattle().attackPet
    attackPet:addBuffDamage(value)
    
end

function ReturnDamage:getSkillDesc(data, templateLevel)
    
    local returnRatio = data:getParamValue("反伤比例", templateLevel)
    returnRatio = BattleAidFunc.str2Percent(returnRatio)
    
    return BattleAidFunc.getSkillDesc(data, templateLevel, {["反伤比例"] = (returnRatio*100).."%%"})

end

return ReturnDamage