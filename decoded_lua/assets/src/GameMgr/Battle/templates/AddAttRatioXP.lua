local AddAttRatioXP = class("AddAttRatioXP", BattleTemplate)


function AddAttRatioXP:ctor(templateInfo)

    AddAttRatioXP.super.ctor(self, templateInfo)

end

function AddAttRatioXP:work(data, ownerPet, templateLevel)

    local attType = data:getParamValue("增强属性", templateLevel)
    local attEnum = BattleAidFunc.str2Enum(attType)
    if (nil == ownerPet:getAttribute(attEnum)) then
        printError("AddAttRatioXP:buffActive() can not find attribute of " .. attType)
    end

    local attAdjust = data:getParamValue("强度修正", templateLevel)
    attAdjust = BattleAidFunc.str2Percent(attAdjust)
    
    local attVal = ownerPet:getAttribute(attEnum)
    local improveEntry = AttributeStarImproveInfoConfig.readEntryByID(attEnum)
    ownerPet:setAttribute(attEnum, attVal * (1 + improveEntry.starList[templateLevel].proportion / 100 * attAdjust))
    ownerPet:_setAttribute(attEnum, ownerPet:_getAttribute(attEnum) * (1 + improveEntry.starList[templateLevel].proportion / 100 * attAdjust))
    printFileLog(string.format("%s:永久属性变化(AddAttRatioXP):%s %d->%d", ownerPet.name, attType, attVal, ownerPet:getAttribute(attEnum)))

end

function AddAttRatioXP:getSkillDesc(data, templateLevel)
    
    local attType = data:getParamValue("增强属性", templateLevel)
    local attEnum = BattleAidFunc.str2Enum(attType)

    local attAdjust = data:getParamValue("强度修正", templateLevel)
    attAdjust = BattleAidFunc.str2Percent(attAdjust)

    local improveEntry = AttributeStarImproveInfoConfig.readEntryByID(attEnum)
    return BattleAidFunc.getSkillDesc(data, templateLevel, nil, (improveEntry.starList[templateLevel].proportion*attAdjust).."%%")

end

return AddAttRatioXP