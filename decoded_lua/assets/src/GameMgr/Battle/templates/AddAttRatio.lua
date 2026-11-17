local AddAttRatio = class("AddAttRatio", BattleTemplate)


function AddAttRatio:ctor(templateInfo)

    AddAttRatio.super.ctor(self, templateInfo)

end

function AddAttRatio:work(data, ownerPet, templateLevel)

    local attType = data:getParamValue("增强属性", templateLevel)
    local attEnum = BattleAidFunc.str2Enum(attType)
    if (nil == ownerPet:getAttribute(attEnum)) then
        printError("AddAttRatio:buffActive() can not find attribute of " .. attType)
    end

    local attAdjust = data:getParamValue("强度修正", templateLevel)
    attAdjust = BattleAidFunc.str2Percent(attAdjust)

    attAdjust, templateLevel = BattleInfo.getSkillAttAdjust(data, attAdjust, templateLevel)
    
    local attVal = ownerPet:_getAttribute(attEnum)
    local attVal2 = ownerPet:getAttribute(attEnum)
    local improveEntry = AttributeStarImproveInfoConfig.readEntryByID(attEnum)

    ownerPet:addAttribute(attEnum, attVal * (improveEntry.starList[templateLevel].proportion / 100 * attAdjust), true, data.skillid)
    if attEnum == Proto.AT_HP then
        ownerPet.triggerBuff.notremove = true
        if ownerPet.addhp_limit == nil then
            ownerPet.addhp_limit = {}
        end
        if not ownerPet.addhp_limit[data.skillid] then
            ownerPet.addhp_limit[data.skillid] = 1
            ownerPet:getCure(ownerPet:getAttribute(attEnum) - attVal2)
        end
    end
    printFileLog(string.format("%s:属性变化(AddAttRatio):%s %d->%d", ownerPet.name, attType, attVal, ownerPet:getAttribute(attEnum)))

end

function AddAttRatio:getSkillDesc(data, templateLevel)
    
    local attType = data:getParamValue("增强属性", templateLevel)
    local attEnum = BattleAidFunc.str2Enum(attType)

    local attAdjust = data:getParamValue("强度修正", templateLevel)
    attAdjust = BattleAidFunc.str2Percent(attAdjust)

    attAdjust, templateLevel = BattleInfo.getSkillAttAdjust(data, attAdjust, templateLevel)

    local improveEntry = AttributeStarImproveInfoConfig.readEntryByID(attEnum)
    return BattleAidFunc.getSkillDesc(data, templateLevel, nil, (improveEntry.starList[templateLevel].proportion*attAdjust).."%%")

end

function AddAttRatio:getSkillAttribute(data, templateLevel)

    local attType = data:getParamValue("增强属性", templateLevel)
    local attEnum = BattleAidFunc.str2Enum(attType)

    local attAdjust = data:getParamValue("强度修正", templateLevel)
    attAdjust = BattleAidFunc.str2Percent(attAdjust)

    attAdjust, templateLevel = BattleInfo.getSkillAttAdjust(data, attAdjust, templateLevel)

    local improveEntry = AttributeStarImproveInfoConfig.readEntryByID(attEnum)

    local ctype = 0
    if attEnum == Proto.AT_HP or attEnum == Proto.AT_ATK or attEnum == Proto.AT_SATK 
        or attEnum == Proto.AT_DEF or attEnum == Proto.AT_SDEF or attEnum == Proto.AT_SPEED then
        ctype = 1
    end
    return { type = attEnum, value = improveEntry.starList[templateLevel].proportion*attAdjust, ctype = ctype }

end

return AddAttRatio