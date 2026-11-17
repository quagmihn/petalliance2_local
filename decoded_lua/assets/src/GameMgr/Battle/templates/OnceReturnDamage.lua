local OnceReturnDamage = class("OnceReturnDamage", BattleTemplate)

function OnceReturnDamage:ctor(templateInfo)

    OnceReturnDamage.super.ctor(self, templateInfo)

    self.damageVal = 0

end

function OnceReturnDamage:work(data, ownerPet, templateLevel)
    
    if ATTACK_ATTACK ~= BattleCotroller.getCurrentBattle().attackType then
        return false
    end
    local returnRatio = data:getParamValue("反伤比例", templateLevel)
    returnRatio = BattleAidFunc.str2Percent(returnRatio)

    local value = BattleCotroller.getCurrentBattle().finaldamage * returnRatio
    value = BattleAidFunc.normalize(value)

    local attackPet = BattleCotroller.getCurrentBattle().attackPet
    attackPet:addBuffDamage(value)

    ownerPet.triggerBuff:clearRound()
    
end

function OnceReturnDamage:getSkillDesc(data, templateLevel)
    
    local returnRatio = data:getParamValue("反伤比例", templateLevel)
    returnRatio = BattleAidFunc.str2Percent(returnRatio)
    
    return BattleAidFunc.getSkillDesc(data, templateLevel, {["反伤比例"] = (returnRatio*100).."%%"})

end

return OnceReturnDamage