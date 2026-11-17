local AddDamageByHp = class("AddDamageByHp", BattleTemplate)

function AddDamageByHp:ctor(templateInfo)

    AddDamageByHp.super.ctor(self, templateInfo)

end

function AddDamageByHp:work(data, ownerPet, templateLevel)

	local ratio = 1 - ownerPet.hp/ownerPet:getMaxHP()

    if ratio < 0 then
        ratio = 0
    end

	local hpRate = data:getParamValue("血量比例", templateLevel)
    hpRate = BattleAidFunc.str2Percent(hpRate)

    local rate = data:getParamValue("增伤比例", templateLevel)
    rate = BattleAidFunc.str2Percent(rate)

    ownerPet.attributes.damageRate = ownerPet.attributes.damageRate + rate*math.floor(ratio/hpRate)
    
end

function AddDamageByHp:getSkillDesc(data, templateLevel)

	local hpRate = data:getParamValue("血量比例", templateLevel)
    hpRate = BattleAidFunc.str2Percent(hpRate)

    local rate = data:getParamValue("增伤比例", templateLevel)
    rate = BattleAidFunc.str2Percent(rate)
    
    return BattleAidFunc.getSkillDesc(data, templateLevel, {["血量比例"] = (hpRate*100).."%%",
    	["增伤比例"] = (rate*100).."%%"})

end

return AddDamageByHp