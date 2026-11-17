local MustKillByRound = class("MustKillByRound", BattleTemplate)

function MustKillByRound:ctor(templateInfo)

    MustKillByRound.super.ctor(self, templateInfo)

end

function MustKillByRound:work(data, ownerPet, templateLevel)

    local enemyPet = BattleCotroller.getCurrentBattle():getEnemy(ownerPet)
    enemyPet.attributes.ignoreDef = true
	enemyPet.attributes.mustDie = true
    enemyPet:addBuffDamage(enemyPet.hp)

end

function MustKillByRound:getSkillDesc(data, templateLevel)

    return BattleAidFunc.getSkillDesc(data, templateLevel)

end

return MustKillByRound