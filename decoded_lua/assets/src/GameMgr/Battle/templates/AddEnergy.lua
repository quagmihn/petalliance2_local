local AddEnergy = class("AddEnergy", BattleTemplate)

function AddEnergy:ctor(templateInfo)

    AddEnergy.super.ctor(self, templateInfo)
    
end

function AddEnergy:work(data, ownerPet, templateLevel)

	local val_1 = tonumber(data:getParamValue("增加量", 1))
    if (nil == val_1) then
        return
    end

    local val = tonumber(data:getParamValue("增加量", templateLevel))
    if (nil == val) then
        return
    end
    val = GetRandom.random(val_1,val)
    ownerPet.team:addEnergyDirectly(val)

end

function AddEnergy:getSkillDesc(data, templateLevel)

	local val_1 = tonumber(data:getParamValue("增加量", 1))
    local val = tonumber(data:getParamValue("增加量", templateLevel))
    local value = val_1.."-"..val
    if val_1 == val then
    	value = val
    end
    return BattleAidFunc.getSkillDesc(data, templateLevel, {["增加量"] = value})

end

return AddEnergy