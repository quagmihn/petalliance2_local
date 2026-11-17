local AddAttribute = class("AddAttribute", BattleTemplate)

function AddAttribute:ctor(templateInfo)

    AddAttribute.super.ctor(self, templateInfo)
    
end

function AddAttribute:work(data, ownerPet, templateLevel)
    local attType = data:getParamValue("增强属性", templateLevel)
    local attEnum = BattleAidFunc.str2Enum(attType)
    if (nil == ownerPet:getAttribute(attEnum)) then
        printError("AddAttribute:buffActive() can not find attribute of " .. attType)
    end

    local attAdjust = data:getParamValue("强度修正", templateLevel)
    attAdjust = BattleAidFunc.str2Percent(attAdjust)

    attAdjust, templateLevel = BattleInfo.getSkillAttAdjust(data, attAdjust, templateLevel)

    local attVal = ownerPet:getAttribute(attEnum)
    local improveEntry = AttributeStarImproveInfoConfig.readEntryByID(attEnum)
    ownerPet:addAttribute(attEnum, improveEntry.starList[templateLevel].value * attAdjust, true)
    if attEnum == Proto.AT_HP then
        if ownerPet.addhp_limit == nil then
            ownerPet.addhp_limit = {}
        end
        if not ownerPet.addhp_limit[data.skillid] then
            ownerPet.addhp_limit[data.skillid] = 1
            ownerPet:getCure(ownerPet:getAttribute(attEnum) - attVal)
        end
    end
    printFileLog(string.format("%s:属性变化(AddAttribute):%s %d->%d", ownerPet.name, attType, attVal, ownerPet:getAttribute(attEnum)))
end

function AddAttribute:getSkillDesc(data, templateLevel)
    
    local attType = data:getParamValue("增强属性", templateLevel)
    local attEnum = BattleAidFunc.str2Enum(attType)

    local attAdjust = data:getParamValue("强度修正", templateLevel)
    attAdjust = BattleAidFunc.str2Percent(attAdjust)

    attAdjust, templateLevel = BattleInfo.getSkillAttAdjust(data, attAdjust, templateLevel)

    local improveEntry = AttributeStarImproveInfoConfig.readEntryByID(attEnum)
    local ration = ""
    if attType == "AT_RATE" or attType == "AT_CRT" or attType == "AT_EVD" or attType == "AT_CRTHURT" or attType == "AT_HEALRATE" 
    or attType == "AT_PENETRATION" or attType == "AT_SPENETRATION" or attType == "AT_ANTICRT" then
        ration = "%%"
    end

    local ra2 = 1
    if attType == "AT_HEALRATE" then
        ra2 = 10
    end
    return BattleAidFunc.getSkillDesc(data, templateLevel, nil, (improveEntry.starList[templateLevel].value * attAdjust/ra2)..ration)

end

function AddAttribute:getSkillAttribute(data, templateLevel)
    
    local attType = data:getParamValue("增强属性", templateLevel)
    local attEnum = BattleAidFunc.str2Enum(attType)

    local attAdjust = data:getParamValue("强度修正", templateLevel)
    attAdjust = BattleAidFunc.str2Percent(attAdjust)

    attAdjust, templateLevel = BattleInfo.getSkillAttAdjust(data, attAdjust, templateLevel)

    local improveEntry = AttributeStarImproveInfoConfig.readEntryByID(attEnum)
    return { type = attEnum, value = improveEntry.starList[templateLevel].value * attAdjust }

end

return AddAttribute