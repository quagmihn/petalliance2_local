local ReduceEnergyIncrement = class("ReduceEnergyIncrement", BattleTemplate)

function ReduceEnergyIncrement:ctor(templateInfo)

    ReduceEnergyIncrement.super.ctor(self, templateInfo)
    
end

function ReduceEnergyIncrement:work(data, ownerPet, templateLevel)

    local val = tonumber(data:getParamValue("降低值", templateLevel))
    if (nil == val) then
        return
    end

    ownerPet.team:reduceEnergyIncrement(val)

end

function ReduceEnergyIncrement:getSkillDesc(data, templateLevel)

	local val = tonumber(data:getParamValue("降低值", templateLevel))
    return BattleAidFunc.getSkillDesc(data, templateLevel, {["降低值"] = val})

end

return ReduceEnergyIncrement