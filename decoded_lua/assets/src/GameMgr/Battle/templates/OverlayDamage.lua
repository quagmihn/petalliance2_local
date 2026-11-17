local OverlayDamage = class("OverlayDamage", BattleTemplate)

function OverlayDamage:ctor(templateInfo)

    OverlayDamage.super.ctor(self,templateInfo)

end

function OverlayDamage:work(data, ownerPet, templateLevel)
	BattleCotroller.getCurrentBattle().attackTarget = BattleCotroller.getCurrentBattle().defencePet
    BattleCotroller.getCurrentBattle().attackType = ATTACK_ATTACK
	local count = ownerPet:getSkillUseCount(data.skillid)
	local countMax = tonumber(data:getParamValue("使用次数", templateLevel))
	if count > countMax then
		count = countMax
	end
	local damageRatio = data:getParamValue("伤害比例", count)
    if damageRatio == nil then
        return
    end
    local damageRate = BattleAidFunc.str2Percent(damageRatio)
    BattleCotroller.getCurrentBattle():fight(damageRate)
end

function OverlayDamage:getSkillDesc(data, templateLevel) 
    local damageRatio = data:getParamValue("伤害比例", 1)
    damageRatio = BattleAidFunc.str2Percent(damageRatio)
    damageRatio = tonumber(damageRatio)
    local count = data:getParamValue("使用次数", templateLevel)
	count = tonumber(count)
    return BattleAidFunc.getSkillDesc(data, templateLevel, {["伤害比例"] = (damageRatio*100).."%%",["使用次数"]=count})

end
return OverlayDamage