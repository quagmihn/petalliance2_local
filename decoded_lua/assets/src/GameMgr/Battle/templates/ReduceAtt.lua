local ReduceAtt = class("ReduceAtt", BattleTemplate)

function ReduceAtt:ctor(templateInfo)

    ReduceAtt.super.ctor(self, templateInfo)
    
end

function ReduceAtt:work(data, ownerPet, templateLevel)

    local attType = data:getParamValue("减弱属性", templateLevel)
    local attEnum = BattleAidFunc.str2Enum(attType)
    if (nil == ownerPet:getAttribute(attEnum)) then
        printError("ReduceAtt:buffActive() can not find attribute of " .. attType)
    end

    local attAdjust = data:getParamValue("强度修正", templateLevel)
    attAdjust = BattleAidFunc.str2Percent(attAdjust)

    attAdjust, templateLevel = BattleInfo.getSkillAttAdjust(data, attAdjust, templateLevel)

    local attVal = ownerPet:getAttribute(attEnum)
    local improveEntry = AttributeStarImproveInfoConfig.readEntryByID(attEnum)
    ownerPet:reduceAttribute(attEnum, improveEntry.starList[templateLevel].value * attAdjust)
    printFileLog(string.format("%s:属性变化(ReduceAtt):%s %d->%d", ownerPet.name, attType, attVal, ownerPet:getAttribute(attEnum)))

end

function ReduceAtt:getSkillDesc(data, templateLevel)

    local attType = data:getParamValue("减弱属性", templateLevel)
    local attEnum = BattleAidFunc.str2Enum(attType)

    local attAdjust = data:getParamValue("强度修正", templateLevel)
    attAdjust = BattleAidFunc.str2Percent(attAdjust)

    attAdjust, templateLevel = BattleInfo.getSkillAttAdjust(data, attAdjust, templateLevel)

    local improveEntry = AttributeStarImproveInfoConfig.readEntryByID(attEnum)
    local ration = ""
    if attType == "AT_RATE" or attType == "AT_CRT" or attType == "AT_EVD" or attType == "AT_CRTHURT" or attType == "AT_HEALRATE" then
        ration = "%%"
    end

    local ra2 = 1
    if attType == "AT_HEALRATE" then
        ra2 = 10
    end

    return BattleAidFunc.getSkillDesc(data, templateLevel, nil, (improveEntry.starList[templateLevel].value * attAdjust/ra2)..ration)

end

return ReduceAtt