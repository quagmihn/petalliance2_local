local ForceChangePet = class("ForceChangePet", BattleTemplate)

function ForceChangePet:ctor(templateInfo)

    ForceChangePet.super.ctor(self, templateInfo)

end

function ForceChangePet:work(data, ownerPet, templateLevel)

    local enemyPet = BattleCotroller.getCurrentBattle():getEnemy(ownerPet)
    local changepet = enemyPet.team:forceChangePet()
    if changepet == -1 then
    	enemyPet:addBuffDamage(enemyPet.hp)
    	BattleCotroller.getCurrentBattle():addExtraDamage(enemyPet.hp)
    	enemyPet.attributes.ignoreDef = true
    else
	    BattleCotroller.getCurrentBattle():setState(STATE_ROUND_END)
	end

end

function ForceChangePet:getSkillDesc(data, templateLevel)

    return BattleAidFunc.getSkillDesc(data, templateLevel)

end

return ForceChangePet