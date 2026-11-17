local RemoveBuffOnSelf = class("RemoveBuffOnSelf", BattleTemplate)

function RemoveBuffOnSelf:ctor(templateInfo)

    RemoveBuffOnSelf.super.ctor(self, templateInfo)

end

function RemoveBuffOnSelf:work(data, ownerPet, templateLevel)

    local tagName = data:getParamValue("buff名", templateLevel)

    if (nil ~= tagName) then
        ownerPet:removeBuffByTag(tagName)
    end

end

function RemoveBuffOnSelf:getSkillDesc(data, templateLevel)

    return BattleAidFunc.getSkillDesc(data, templateLevel)

end

return RemoveBuffOnSelf