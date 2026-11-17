local AddAttRandom = class("AddAttRandom", BattleTemplate)

function AddAttRandom:ctor(templateInfo)

    AddAttRandom.super.ctor(self, templateInfo)

end

function AddAttRandom:work(data, ownerPet, templateLevel)

    local countStr = data:getParamValue("属性数量", templateLevel)
    count = tonumber(countStr)
    if (nil == count) then
        printError("Can not get 属性数量 " .. countStr)
    end

    local atts = {
        "AT_ATK",
        "AT_DEF",
        "AT_SATK",
        "AT_SDEF",
        "AT_SPEED",
    }
    for i = 1, count do
        local rand = GetRandom.random(i, #atts)
        local tmp = atts[rand]
        atts[rand] = atts[i]
        atts[i] = tmp
    end    

    local attAdjust = data:getParamValue("强度修正", templateLevel)
    attAdjust = BattleAidFunc.str2Percent(attAdjust)

    attAdjust, templateLevel = BattleInfo.getSkillAttAdjust(data, attAdjust, templateLevel)

    for i = 1, count do
        local attEnum = BattleAidFunc.str2Enum(atts[i])
        local attVal = ownerPet:getAttribute(attEnum)
        local improveEntry = AttributeStarImproveInfoConfig.readEntryByID(attEnum)
        ownerPet:setAttribute(attEnum, attVal * (1 + improveEntry.starList[templateLevel].proportion / 100 * attAdjust))
        printFileLog(string.format("%s:属性增加随机(AddAttRandom):Proto.%s %d->%d", ownerPet.name, atts[i], attVal, ownerPet:getAttribute(attEnum)))
    end

end

function AddAttRandom:getSkillDesc(data, templateLevel)
    
    local count = tonumber(data:getParamValue("属性数量", templateLevel))

    return BattleAidFunc.getSkillDesc(data, templateLevel, {["属性数量"] = count})
end

return AddAttRandom