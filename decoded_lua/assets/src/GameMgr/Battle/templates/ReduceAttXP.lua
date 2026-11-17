local ReduceAttXP = class("ReduceAttXP", BattleTemplate)

function ReduceAttXP:ctor(templateInfo)

    ReduceAttXP.super.ctor(self, templateInfo)
    
end

function ReduceAttXP:work(data, ownerPet, templateLevel)

    local attType = data:getParamValue("减弱属性", templateLevel)
    local attEnum = BattleAidFunc.str2Enum(attType)
    if (nil == ownerPet:getAttribute(attEnum)) then
        printError("ReduceAttXP:buffActive() can not find attribute of " .. attType)
    end

    local attAdjust = data:getParamValue("强度修正", templateLevel)
    attAdjust = BattleAidFunc.str2Percent(attAdjust)

    local attVal = ownerPet:getAttribute(attEnum)
    local improveEntry = AttributeStarImproveInfoConfig.readEntryByID(attEnum)
    ownerPet:reduceAttribute(attEnum, improveEntry.starList[templateLevel].value * attAdjust)
    ownerPet:_reduceAttribute(attEnum, improveEntry.starList[templateLevel].value * attAdjust)
    printFileLog(string.format("%s:永久属性变化(ReduceAttXP):%s %d->%d", ownerPet.name, attType, attVal, ownerPet:getAttribute(attEnum)))

end

function ReduceAttXP:getSkillDesc(data, templateLevel)

    local attType = data:getParamValue("减弱属性", templateLevel)
    local attEnum = BattleAidFunc.str2Enum(attType)

    local attAdjust = data:getParamValue("强度修正", templateLevel)
    attAdjust = BattleAidFunc.str2Percent(attAdjust)

    local improveEntry = AttributeStarImproveInfoConfig.readEntryByID(attEnum)

    return BattleAidFunc.getSkillDesc(data, templateLevel, nil, improveEntry.starList[templateLevel].value * attAdjust)

end

return ReduceAttXP