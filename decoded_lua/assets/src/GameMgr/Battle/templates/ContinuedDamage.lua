local ContinuedDamage = class("ContinuedDamage", BattleTemplate)

function ContinuedDamage:ctor(templateInfo)

    ContinuedDamage.super.ctor(self, templateInfo)

end

function ContinuedDamage:work(data, ownerPet, templateLevel)

    ownerPet:addBuffDamage(ownerPet.triggerBuff.damageValue)

end

function ContinuedDamage:getSkillDesc(data, templateLevel)

    return BattleAidFunc.getSkillDesc(data, templateLevel)

end

return ContinuedDamage