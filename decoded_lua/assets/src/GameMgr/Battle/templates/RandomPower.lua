local RandomPower = class("RandomPower", BattleTemplate)


function RandomPower:ctor(templateInfo)

    RandomPower.super.ctor(self, templateInfo)

end

function RandomPower:work(data, ownerPet, templateLevel)

    local power = data:getParamValue("浮动威力", templateLevel)
    power = tonumber(power)
    local value = GetRandom.random(0,power)
    if nil ~= ownerPet:getSelectedSkill() then
        ownerPet:getSelectedSkill().addPower = value
        printFileLog(string.format("%s:增加浮动威力(RandomPower):%d", ownerPet.name, value))
    end
end

function RandomPower:getSkillDesc(data, templateLevel)

	local power = data:getParamValue("浮动威力", templateLevel)
	power = tonumber(power)
    return BattleAidFunc.getSkillDesc(data, templateLevel, {["浮动威力"] = power})

end

return RandomPower