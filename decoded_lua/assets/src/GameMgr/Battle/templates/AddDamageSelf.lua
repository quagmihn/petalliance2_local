local AddDamageSelf = class("AddDamageSelf", BattleTemplate)

function AddDamageSelf:ctor(templateInfo)

    AddDamageSelf.super.ctor(self, templateInfo)

end

function AddDamageSelf:work(data, ownerPet, templateLevel)

	local rate = data:getParamValue("增伤比例", templateLevel)
    rate = BattleAidFunc.str2Percent(rate)

    local dmgageType = data:getParamValue("伤害类型",templateLevel)
    if dmgageType == "物理伤害" then
    	ownerPet.attributes.physicalDamageRate = ownerPet.attributes.physicalDamageRate + rate
	elseif dmgageType == "魔法伤害" then
		ownerPet.attributes.magicDamageRate = ownerPet.attributes.magicDamageRate + rate
	end
    
end

function AddDamageSelf:getSkillDesc(data, templateLevel)

    local rate = data:getParamValue("增伤比例", templateLevel)
    rate = BattleAidFunc.str2Percent(rate)
    
    return BattleAidFunc.getSkillDesc(data, templateLevel, {["增伤比例"] = (rate*100).."%%"})

end

return AddDamageSelf