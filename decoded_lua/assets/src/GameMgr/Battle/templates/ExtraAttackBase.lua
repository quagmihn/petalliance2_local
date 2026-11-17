local ExtraAttackBase = class("ExtraAttackBase", BattleTemplate)

function ExtraAttackBase:ctor(templateInfo)

    ExtraAttackBase.super.ctor(self,templateInfo)

end

function ExtraAttackBase:getExtraCount(data,ownerPet,templateLevel)

    local speedRate = BattleAidFunc.str2Percent(data:getParamValue("速度放大比", templateLevel))

    local attackSpeed = ownerPet:getAttribute(Proto.AT_SPEED)
    local defencePet = BattleCotroller.getCurrentBattle():getEnemy(ownerPet)
    local defenceSpeed = defencePet:getAttribute(Proto.AT_SPEED)

    local round = 0
    if (0 == defenceSpeed) then
        printError("Speed of defence pet is 0")
        round = templateLevel + 2
    else
        round = attackSpeed * (1 + speedRate) / defenceSpeed - 1
        if round > templateLevel + 2 then
            round = templateLevel + 2
        end
    end

    printFileLog("ExtraAttackBase:getExtraCount()", "speedRate:" .. speedRate, "attackSpeed:" .. attackSpeed, "defenceSpeed:" .. defenceSpeed, "round:" .. round)

    local result = math.floor(round)
    if result < 0 then
    	result = 0
    end

    if result > templateLevel then
        result = templateLevel
    end
    return result

end

function ExtraAttackBase:getFinalCount(extraCount, templateLevel)

    return math.min(extraCount, templateLevel + 2)

end

return ExtraAttackBase