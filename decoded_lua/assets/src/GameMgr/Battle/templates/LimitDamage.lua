local LimitDamage = class("LimitDamage", BattleTemplate)

function LimitDamage:ctor(templateInfo)

    LimitDamage.super.ctor(self,templateInfo)

end

function LimitDamage:work(data, ownerPet, templateLevel)

	local limitRatio = data:getParamValue("最大承受比例", templateLevel)
    limitRatio = BattleAidFunc.str2Percent(limitRatio)

    ownerPet.attributes.limitDamage = math.floor(ownerPet:getAttribute(Proto.AT_HP)*limitRatio)

end

function LimitDamage:getSkillDesc(data, templateLevel)
    
    local limitRatio = data:getParamValue("最大承受比例", templateLevel)
    limitRatio = BattleAidFunc.str2Percent(limitRatio)

    return BattleAidFunc.getSkillDesc(data, templateLevel, {["最大承受比例"] = (limitRatio*100).."%%"})

end

return LimitDamage