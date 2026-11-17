local ImmuneElementAttack = class("ImmuneElementAttack", BattleTemplate)

function ImmuneElementAttack:ctor(templateInfo)

    ImmuneElementAttack.super.ctor(self,templateInfo)

end

function ImmuneElementAttack:work(data, ownerPet, templateLevel)

    if (ownerPet.attributes.damageRateElement < 1) then
        ownerPet.attributes.damageRateElement = 1
    end

end

function ImmuneElementAttack:getSkillDesc(data, templateLevel)

    return BattleAidFunc.getSkillDesc(data, templateLevel)

end

return ImmuneElementAttack