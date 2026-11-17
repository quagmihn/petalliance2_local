local RateImmune = class("RateImmune", BattleTemplate)

function RateImmune:ctor(templateInfo)

    RateImmune.super.ctor(self,templateInfo)

end

function RateImmune:checkCondition(data, ownerPet, templateLevel)

    local tag = data:getParamValue("免疫类型", templateLevel)

    if true == ownerPet.currentAddBuff:hasTag(tag) then
        ownerPet.canAddBuff = false
        return true
    end
    return false

end

return RateImmune