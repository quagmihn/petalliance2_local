local CheckEnemyHPRatio = class("CheckEnemyHPRatio", BattleTemplate)

function CheckEnemyHPRatio:ctor(templateInfo)

    CheckEnemyHPRatio.super.ctor(self,templateInfo)

end

function CheckEnemyHPRatio:checkCondition(data, ownerPet, templateLevel)

    local attRatio = BattleAidFunc.str2Percent(data:getParamValue("属性比例", templateLevel))

    local enemyPet = BattleCotroller.getCurrentBattle():getEnemy(ownerPet)
    local operator = data:getParamValue("大小关系", templateLevel)
    local res = false
    if ("大于" == operator) then
        res = (enemyPet.hp / enemyPet:getAttribute(Proto.AT_HP)) > attRatio
    elseif ("大于等于" == operator) then
        res = (enemyPet.hp / enemyPet:getAttribute(Proto.AT_HP)) >= attRatio
    elseif ("小于" == operator) then
        res = (enemyPet.hp / enemyPet:getAttribute(Proto.AT_HP)) < attRatio
    elseif ("小于等于" == operator) then
        res = (enemyPet.hp / enemyPet:getAttribute(Proto.AT_HP)) <= attRatio
    elseif ("等于" == operator) then
        res = (enemyPet.hp / enemyPet:getAttribute(Proto.AT_HP)) == attRatio
    end

    printFileLog("敌方当前血量的百分比(%s)：%f, 目标百分比：%f, 当前血量：%d, 最大血量：%d", operator, enemyPet.hp / enemyPet:getAttribute(Proto.AT_HP), attRatio, enemyPet.hp, enemyPet:getAttribute(Proto.AT_HP))
    
    return res

end

function CheckEnemyHPRatio:getSkillDesc(data, templateLevel)

    local attRatio = BattleAidFunc.str2Percent(data:getParamValue("属性比例", templateLevel))
    return (attRatio*100).."%%"

end

return CheckEnemyHPRatio