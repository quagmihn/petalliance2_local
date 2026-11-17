local AddAttXP = class("AddAttXP", BattleTemplate)

function AddAttXP:ctor(templateInfo)

    AddAttXP.super.ctor(self, templateInfo)
    
end

function AddAttXP:work(data, ownerPet, templateLevel)

    local attType = data:getParamValue("增强属性", templateLevel)
    local attEnum = BattleAidFunc.str2Enum(attType)
    if (nil == ownerPet:getAttribute(attEnum)) then
        printError("AddAttXP:buffActive() can not find attribute of " .. attType)
    end

    local attAdjust = data:getParamValue("强度修正", templateLevel)
    attAdjust = BattleAidFunc.str2Percent(attAdjust)

    local attVal = ownerPet:getAttribute(attEnum)
    local improveEntry = AttributeStarImproveInfoConfig.readEntryByID(attEnum)
    ownerPet:addAttribute(attEnum, improveEntry.starList[templateLevel].value * attAdjust)
    ownerPet:_addAttribute(attEnum, improveEntry.starList[templateLevel].value * attAdjust)
    printFileLog(string.format("%s:永久属性变化(AddAttXP):%s %d->%d", ownerPet.name, attType, attVal, ownerPet:getAttribute(attEnum)))
    
end

function AddAttXP:getSkillDesc(data, templateLevel)
    
    local attType = data:getParamValue("增强属性", templateLevel)
    local attEnum = BattleAidFunc.str2Enum(attType)

    local attAdjust = data:getParamValue("强度修正", templateLevel)
    attAdjust = BattleAidFunc.str2Percent(attAdjust)

    local improveEntry = AttributeStarImproveInfoConfig.readEntryByID(attEnum)
    local ration = ""
    if attType == "AT_RATE" or attType == "AT_CRT" or attType == "AT_EVD" or attType == "AT_CRTHURT" then
        ration = "%%"
    end
    return BattleAidFunc.getSkillDesc(data, templateLevel, nil, (improveEntry.starList[templateLevel].value * attAdjust)..ration)

end

return AddAttXP