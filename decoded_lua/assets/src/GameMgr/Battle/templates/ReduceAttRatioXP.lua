local ReduceAttRatioXP = class("ReduceAttRatioXP", BattleTemplate)

function ReduceAttRatioXP:ctor(templateInfo)

    ReduceAttRatioXP.super.ctor(self, templateInfo)

end

function ReduceAttRatioXP:work(data, ownerPet, templateLevel)

    local attType = data:getParamValue("减弱属性", templateLevel)
    local attEnum = BattleAidFunc.str2Enum(attType)
    if (nil == ownerPet:getAttribute(attEnum)) then
        printError("ReduceAttRatioXP:buffActive() can not find attribute of " .. attType)
    end

    local attAdjust = data:getParamValue("强度修正", templateLevel)
    attAdjust = BattleAidFunc.str2Percent(attAdjust)

    local attVal = ownerPet:getAttribute(attEnum)
    local improveEntry = AttributeStarImproveInfoConfig.readEntryByID(attEnum)
    ownerPet:setAttribute(attEnum, attVal / (1 + improveEntry.starList[templateLevel].proportion / 100 * attAdjust))
    ownerPet:_setAttribute(ownerPet:_getAttribute(attEnum), attVal / (1 + improveEntry.starList[templateLevel].proportion / 100 * attAdjust))
    printFileLog(string.format("%s:永久属性变化(ReduceAttRatioXP):%s %d->%d", ownerPet.name, attType, attVal, ownerPet:getAttribute(attEnum)))

end

function ReduceAttRatioXP:getSkillDesc(data, templateLevel)

    local attType = data:getParamValue("减弱属性", templateLevel)
    local attEnum = BattleAidFunc.str2Enum(attType)

    local attAdjust = data:getParamValue("强度修正", templateLevel)
    attAdjust = BattleAidFunc.str2Percent(attAdjust)

    local improveEntry = AttributeStarImproveInfoConfig.readEntryByID(attEnum)
    local val = 1 - 1 / (1 + improveEntry.starList[templateLevel].proportion / 100 * attAdjust)
    val = math.floor(val * 1000) / 10
    return BattleAidFunc.getSkillDesc(data, templateLevel, nil, val .."%%")

end

return ReduceAttRatioXP