local AddAnger = class("AddAnger", BattleTemplate)

function AddAnger:ctor(templateInfo)

    AddAnger.super.ctor(self, templateInfo)
    
end

function AddAnger:work(data, ownerPet, templateLevel)

    local val = tonumber(data:getParamValue("增加量", templateLevel))
    if (nil == val) then
        return
    end
    ownerPet:addAngerDirectly(val)

end

function AddAnger:getSkillDesc(data, templateLevel)

    local val = tonumber(data:getParamValue("增加量", templateLevel))
    return BattleAidFunc.getSkillDesc(data, templateLevel, {["增加量"] = val})

end

return AddAnger