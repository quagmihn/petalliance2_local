local RefreshEnemyBuffRound = class("RefreshEnemyBuffRound", BattleTemplate)

function RefreshEnemyBuffRound:ctor(templateInfo)

    RefreshEnemyBuffRound.super.ctor(self, templateInfo)

end

function RefreshEnemyBuffRound:work(data,ownerPet,templateLevel)

    local tagName = data:getParamValue("buff名", templateLevel)
    local targetPet = BattleCotroller.getCurrentBattle():getEnemy(ownerPet)
    targetPet:resetBuffsRoundByTag(tagName)

end

function RefreshEnemyBuffRound:getSkillDesc(data, templateLevel)

    return BattleAidFunc.getSkillDesc(data, templateLevel)

end

return RefreshEnemyBuffRound