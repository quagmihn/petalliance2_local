local ReduceEnergy = class("ReduceEnergy", BattleTemplate)

function ReduceEnergy:ctor(templateInfo)

    ReduceEnergy.super.ctor(self, templateInfo)
    
end

function ReduceEnergy:work(data, ownerPet, templateLevel)

	local val_1 = tonumber(data:getParamValue("减少量", 1))
    if (nil == val_1) then
        return
    end

    local val = tonumber(data:getParamValue("减少量", templateLevel))
    if (nil == val) then
        return
    end

    val = GetRandom.random(val_1,val)
    BattleCotroller.getCurrentBattle():getEnemy(ownerPet).team:reduceEnergyDirectly(val)

end

function ReduceEnergy:getSkillDesc(data, templateLevel)

	local val_1 = tonumber(data:getParamValue("减少量", 1))
    local val = tonumber(data:getParamValue("减少量", templateLevel))
    local value = val_1.."-"..val
    if val_1 == val then
    	value = val
    end
    return BattleAidFunc.getSkillDesc(data, templateLevel, {["减少量"] = value})

end

return ReduceEnergy