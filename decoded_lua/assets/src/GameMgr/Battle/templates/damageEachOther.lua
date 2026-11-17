local damageEachOther = class("damageEachOther", BattleTemplate)
function damageEachOther:ctor(templateInfo)

    damageEachOther.super.ctor(self,templateInfo)

end

function damageEachOther:work(data,ownerPet,templateLevel)
    local damageRatio  = data:getParamValue("伤害比例", templateLevel)
    local doamgeRatioH = data:getParamValue("对面比例",templateLevel)
    damageRatio = BattleAidFunc.str2Percent(damageRatio)
    doamgeRatioH = BattleAidFunc.str2Percent(doamgeRatioH)
    
    ownerPet.damageRatio = damageRatio
	
	local targetPet = BattleCotroller.getCurrentBattle():getEnemy(ownerPet)
	targetPet.damageRatio = doamgeRatioH
    local dmgageType = data:getParamValue("伤害类型",templateLevel)

    if dmgageType == "物攻" then
        ownerPet.damage  = ownerPet:getAttribute(Proto.AT_ATK) * damageRatio
        targetPet.damage = ownerPet.damage * doamgeRatioH
    elseif dmgageType == "魔攻" then
        ownerPet.damage = ownerPet:getAttribute(Proto.AT_SATK) * damageRatio
        targetPet.damage = ownerPet.damage * doamgeRatioH 
    elseif dmgageType == "血量上限" then 
        ownerPet.damage   = ownerPet:getAttribute(Proto.AT_HP) * damageRatio
        targetPet.damage  = ownerPet.damage * doamgeRatioH
    end
    BattleCotroller.getCurrentBattle():fightByDamageValue(ownerPet,targetPet)
    
end

function damageEachOther:getSkillDesc(data, templateLevel)

	local damageRatio = data:getParamValue("伤害比例", templateLevel)
	damageRatio = BattleAidFunc.str2Percent(damageRatio)
	local doamgeRatioH = data:getParamValue("对面比例",templateLevel)
	doamgeRatioH = BattleAidFunc.str2Percent(doamgeRatioH)
    return BattleAidFunc.getSkillDesc(data, templateLevel, {["伤害比例"] = (damageRatio*100).."%%",
    	["对面比例"] = (doamgeRatioH*100).."%%"})

end

return damageEachOther