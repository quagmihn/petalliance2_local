local Vampire = class("Vampire", BattleTemplate)

function Vampire:ctor(templateInfo)

    Vampire.super.ctor(self, templateInfo)

    self.damageVal = 0

end

function Vampire:work(data, ownerPet, templateLevel)

    local damageRatio = data:getParamValue("伤害比例", templateLevel)
    damageRatio = BattleAidFunc.str2Percent(damageRatio)
    
    local value = BattleCotroller.getCurrentBattle().finaldamage * damageRatio *ownerPet:getAttribute(Proto.AT_HEALRATE)/1000
    value = BattleAidFunc.normalize(value)
    
    ownerPet:addBuffCure(value)

end

function Vampire:getSkillDesc(data, templateLevel)

    local damageRatio = data:getParamValue("伤害比例", templateLevel)
    damageRatio = BattleAidFunc.str2Percent(damageRatio)
    return BattleAidFunc.getSkillDesc(data, templateLevel, {["伤害比例"] = (damageRatio*100).."%%"})

end

return Vampire