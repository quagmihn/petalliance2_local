local RateRemoveBuff = class("RateRemoveBuff", BattleTemplate)

function RateRemoveBuff:ctor(templateInfo)

    RateRemoveBuff.super.ctor(self, templateInfo)

end

function RateRemoveBuff:checkCondition(data, ownerPet, templateLevel)

    local tag = data:getParamValue("buff名", templateLevel)

    return ownerPet:haveBuffByTag(tag)

end

return RateRemoveBuff