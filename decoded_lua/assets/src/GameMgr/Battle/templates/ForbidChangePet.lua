local ForbidChangePet = class("ForbidChangePet", BattleTemplate)

function ForbidChangePet:ctor(templateInfo)

    ForbidChangePet.super.ctor(self, templateInfo)

end

function ForbidChangePet:work(data, ownerPet, templateLevel)
    ownerPet.attributes.canChangePet = false
end

function ForbidChangePet:getSkillDesc(data, templateLevel)

    return BattleAidFunc.getSkillDesc(data, templateLevel)

end

return ForbidChangePet