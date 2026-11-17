local CheckEnemyBuff = class("CheckEnemyBuff", BattleTemplate)

function CheckEnemyBuff:ctor(templateInfo)

    CheckEnemyBuff.super.ctor(self,templateInfo)

end

function CheckEnemyBuff:checkCondition(data, ownerPet, templateLevel)

    local buffName = data:getParamValue("buff名", templateLevel)
    return BattleCotroller.getCurrentBattle():getEnemy(ownerPet):hasBuffTag(buffName)

end

function CheckEnemyBuff:getSkillDesc(data, templateLevel)
    
    local buffName = data:getParamValue("buff名", templateLevel)
    return LuaSqlite.getLanguageByKey(buffName)

end

return CheckEnemyBuff