local CheckAttCompare = class("CheckAttCompare", BattleTemplate)

function CheckAttCompare:ctor(templateInfo)

    CheckAttCompare.super.ctor(self,templateInfo)

end

function CheckAttCompare:checkCondition(data, ownerPet, templateLevel)

	printFileLog("------------CheckAttCompare:checkCondition")

    local selfAtt = data:getParamValue("自身属性", templateLevel)
    local selfAttEnum = BattleAidFunc.str2Enum(selfAtt)
    local enemyAtt = data:getParamValue("敌方属性", templateLevel)
    local enemyAttEnum = BattleAidFunc.str2Enum(enemyAtt)
    if (nil == selfAttEnum or nil == enemyAttEnum) then
    	printError("CheckAttCompare:checkCondition() can not find attribute of " .. selfAtt .. " and " .. enemyAtt)
    	return false
    end

    local operator = data:getParamValue("大小关系", templateLevel)
    local enemy = BattleCotroller.getCurrentBattle():getEnemy(ownerPet)
    if ("大于" == operator) then
    	local res = ownerPet.attributes[selfAttEnum] > enemy.attributes[enemyAttEnum]
    	printFileLog(selfAttEnum, ownerPet.attributes[selfAttEnum], enemyAttEnum, enemy.attributes[enemyAttEnum], res)
    	return (ownerPet.attributes[selfAttEnum] > enemy.attributes[enemyAttEnum])
    elseif ("小于" == operator) then
    	printFileLog(2)
    	return (ownerPet.attributes[selfAttEnum] < enemy.attributes[enemyAttEnum])
    elseif ("等于" == operator) then
    	printFileLog(3)
    	return (ownerPet.attributes[selfAttEnum] == enemy.attributes[enemyAttEnum])
    end

    return false

end

return CheckAttCompare