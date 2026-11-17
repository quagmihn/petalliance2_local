local CheckEnemyNoBuff = class("CheckEnemyNoBuff", BattleTemplate)

function CheckEnemyNoBuff:ctor(templateInfo)

    CheckEnemyNoBuff.super.ctor(self,templateInfo)

end

function CheckEnemyNoBuff:checkCondition(data, ownerPet, templateLevel)

    local buffName = data:getParamValue("buff名", templateLevel)
    return (not BattleCotroller.getCurrentBattle():getEnemy(ownerPet):hasBuffTag(buffName))

end

function CheckEnemyNoBuff:getSkillDesc(data, templateLevel)

    local buffName = data:getParamValue("buff名", templateLevel)
    return buffName

end

return CheckEnemyNoBuff