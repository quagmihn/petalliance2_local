local ReduceAttRatio = class("ReduceAttRatio", BattleTemplate)

function ReduceAttRatio:ctor(templateInfo)

    ReduceAttRatio.super.ctor(self, templateInfo)

end

function ReduceAttRatio:work(data, ownerPet, templateLevel)

    local attType = data:getParamValue("减弱属性", templateLevel)
    local attEnum = BattleAidFunc.str2Enum(attType)
    if (nil == ownerPet:getAttribute(attEnum)) then
        printError("ReduceAttRatio:buffActive() can not find attribute of " .. attType)
    end

    local attAdjust = data:getParamValue("强度修正", templateLevel)
    attAdjust = BattleAidFunc.str2Percent(attAdjust)

    attAdjust, templateLevel = BattleInfo.getSkillAttAdjust(data, attAdjust, templateLevel)

    local attVal = ownerPet:_getAttribute(attEnum)
    local improveEntry = AttributeStarImproveInfoConfig.readEntryByID(attEnum)
    ownerPet:reduceAttribute(attEnum, attVal * (1 - 1 / (1 + improveEntry.starList[templateLevel].proportion / 100 * attAdjust)))
    printFileLog(string.format("%s:属性变化(ReduceAttRatio):%s %d->%d", ownerPet.name, attType, attVal, ownerPet:getAttribute(attEnum)))

end

function ReduceAttRatio:getSkillDesc(data, templateLevel)

    local attType = data:getParamValue("减弱属性", templateLevel)
    local attEnum = BattleAidFunc.str2Enum(attType)

    local attAdjust = data:getParamValue("强度修正", templateLevel)
    attAdjust = BattleAidFunc.str2Percent(attAdjust)

    attAdjust, templateLevel = BattleInfo.getSkillAttAdjust(data, attAdjust, templateLevel)

    local improveEntry = AttributeStarImproveInfoConfig.readEntryByID(attEnum)
    local val = 1 - 1 / (1 + improveEntry.starList[templateLevel].proportion / 100 * attAdjust)
    val = math.floor(val * 1000) / 10
    return BattleAidFunc.getSkillDesc(data, templateLevel, nil, val .."%%")

end

return ReduceAttRatio