local ImmuneBuff = class("ImmuneBuff", BattleTemplate)

function ImmuneBuff:ctor(templateInfo)

    ImmuneBuff.super.ctor(self,templateInfo)

end

function ImmuneBuff:work(data, ownerPet, templateLevel)

    local tag = data:getParamValue("免疫类型", templateLevel)
    if (true == ownerPet.currentAddBuff:hasTag(tag)) then
        ownerPet.canAddBuff = false
    end

end

function ImmuneBuff:getSkillDesc(data, templateLevel)

    return BattleAidFunc.getSkillDesc(data, templateLevel)

end

return ImmuneBuff