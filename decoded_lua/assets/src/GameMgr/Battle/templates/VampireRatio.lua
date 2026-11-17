local VampireRatio = class("VampireRatio", BattleTemplate)

function VampireRatio:ctor(templateInfo)

    VampireRatio.super.ctor(self, templateInfo)

    self.damageVal = 0

end

function VampireRatio:work(data, ownerPet, templateLevel)

    local damageRatio = data:getParamValue("吸血比例", templateLevel)
    damageRatio = BattleAidFunc.str2Percent(damageRatio)

    local damage = BattleAidFunc.normalize(ownerPet:getMaxHP() * damageRatio)
    ownerPet:addBuffDamage(damage)
    
    local enemyPet = BattleCotroller.getCurrentBattle():getEnemy(ownerPet)
    enemyPet:addBuffCure(damage*enemyPet:getAttribute(Proto.AT_HEALRATE)/1000)
    
end

function VampireRatio:getSkillDesc(data, templateLevel)

    local damageRatio = data:getParamValue("吸血比例", templateLevel)
    damageRatio = BattleAidFunc.str2Percent(damageRatio)
    return BattleAidFunc.getSkillDesc(data, templateLevel, {["吸血比例"] = (damageRatio*100).."%%"})

end

return VampireRatio