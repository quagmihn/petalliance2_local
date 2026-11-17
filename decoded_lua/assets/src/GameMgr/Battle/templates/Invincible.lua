local Invincible = class("Invincible", BattleTemplate)

function Invincible:ctor(templateInfo)

    Invincible.super.ctor(self,templateInfo)

end

function Invincible:work(data, ownerPet, templateLevel)

    ownerPet.attributes.invincible = true

end

function Invincible:getSkillDesc(data, templateLevel)

    return BattleAidFunc.getSkillDesc(data, templateLevel)

end

return Invincible