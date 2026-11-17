local StealAttribute = class("StealAttribute", BattleTemplate)

function StealAttribute:ctor(templateInfo)

    StealAttribute.super.ctor(self, templateInfo)

end

function StealAttribute:work(data, ownerPet, templateLevel)
    local attType = data:getParamValue("偷取属性", templateLevel)
    local attEnum = BattleAidFunc.str2Enum(attType)
    if (nil == ownerPet:getAttribute(attEnum)) then
        printError("StealAttribute:buffActive() can not find attribute of " .. attType)
    end

    local attAdjust = data:getParamValue("强度修正", templateLevel)
    attAdjust = BattleAidFunc.str2Percent(attAdjust)

    attAdjust, templateLevel = BattleInfo.getSkillAttAdjust(data, attAdjust, templateLevel)

    local enemyPet = BattleCotroller.getCurrentBattle():getEnemy(ownerPet)
    local attVal = enemyPet:_getAttribute(attEnum)
    local ownerVal = ownerPet:getAttribute(attEnum)
    local improveEntry = AttributeStarImproveInfoConfig.readEntryByID(attEnum)
    --local stealValue = attVal * (improveEntry.starList[templateLevel].proportion / 100 * attAdjust)
    local stealValue = attVal * (1 - 1 / (1 + improveEntry.starList[templateLevel].proportion / 100 * attAdjust))
    printFileLog(string.format("%s:偷取(StealAttribute):%s %d", ownerPet.name, attType,stealValue))
    --enemyPet:reduceAttribute(attEnum, stealValue)
    enemyPet:setStealAttribute(attEnum, stealValue)
    ownerPet:addAttribute(attEnum, stealValue)
    printFileLog(string.format("%s:属性变化(StealAttribute):%s %d->%d", enemyPet.name, attType, attVal, enemyPet:getAttribute(attEnum)))
    printFileLog(string.format("%s:属性变化(StealAttribute):%s %d->%d", ownerPet.name, attType, ownerVal, ownerPet:getAttribute(attEnum)))
end

function StealAttribute:getSkillDesc(data, templateLevel)

    local attType = data:getParamValue("偷取属性", templateLevel)
    local attEnum = BattleAidFunc.str2Enum(attType)

    local attAdjust = data:getParamValue("强度修正", templateLevel)
    attAdjust = BattleAidFunc.str2Percent(attAdjust)

    attAdjust, templateLevel = BattleInfo.getSkillAttAdjust(data, attAdjust, templateLevel)

    local improveEntry = AttributeStarImproveInfoConfig.readEntryByID(attEnum)
    
    local stealValue = 1 - 1 / (1 + improveEntry.starList[templateLevel].proportion / 100 * attAdjust)
    stealValue = math.floor(stealValue * 1000) / 10

    return BattleAidFunc.getSkillDesc(data, templateLevel, nil, stealValue.."%%")

end

return StealAttribute