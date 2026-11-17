local MustKill = class("MustKill", BattleTemplate)

function MustKill:ctor(templateInfo)

    MustKill.super.ctor(self, templateInfo)

end

function MustKill:work(data, ownerPet, templateLevel)
    local attackType = BattleCotroller.getCurrentBattle().attackType

    local enemyPet = BattleCotroller.getCurrentBattle():getEnemy(ownerPet)
    enemyPet.attributes.ignoreDef = true
	enemyPet.attributes.mustDie = true
    enemyPet:addBuffDamage(enemyPet.hp)
        -- BattleCotroller.getCurrentBattle().finaldamage = enemyPet.hp
        -- print("finaldamage   ",enemyPet.hp)

end

function MustKill:getSkillDesc(data, templateLevel)

    return BattleAidFunc.getSkillDesc(data, templateLevel)

end

return MustKill