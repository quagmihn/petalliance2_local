local SelfExplod = class("SelfExplod", BattleTemplate)

function SelfExplod:ctor(templateInfo)

    SelfExplod.super.ctor(self, templateInfo)

end

function SelfExplod:work(data, ownerPet, templateLevel)

    BattleCotroller.getCurrentBattle().attackTarget = BattleCotroller.getCurrentBattle().defencePet
    BattleCotroller.getCurrentBattle().attackType = ATTACK_ATTACK

	local selfDamageRatio = data:getParamValue("自身伤害比例", templateLevel)
	selfDamageRatio = BattleAidFunc.str2Percent(selfDamageRatio)
    
    local realDamage = BattleAidFunc.normalize(ownerPet:getMaxHP() * selfDamageRatio)
    if realDamage > ownerPet.hp then
        realDamage = ownerPet.hp
    end
    if ownerPet.attributes.limitDamage > 0 and realDamage > ownerPet.attributes.limitDamage then
		if ownerPet.attributes.mustDie then
			realDamage = realDamage
		else
			realDamage = ownerPet.attributes.limitDamage
		end
    end

    if (true == ownerPet.attributes.invincible) then
        realDamage = 0
    end
	ownerPet:addBuffDamage(BattleAidFunc.normalize(ownerPet:getMaxHP() * selfDamageRatio))
    ownerPet.killedBySelf = true

    local enemyDamageRatio = data:getParamValue("造成伤害比例", templateLevel)
    local damageRate = BattleAidFunc.str2Percent(enemyDamageRatio) * (realDamage / ownerPet:getMaxHP() + 0.5)
    BattleCotroller.getCurrentBattle():fight(damageRate)
    
end

function SelfExplod:getSkillDesc(data, templateLevel)

    local damageRatio = data:getParamValue("造成伤害比例", templateLevel)
    damageRatio = BattleAidFunc.str2Percent(damageRatio)
    return BattleAidFunc.getSkillDesc(data, templateLevel, {["造成伤害比例"] = (damageRatio*100).."%%"})

end

return SelfExplod