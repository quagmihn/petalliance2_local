local CheckWeather = class("CheckWeather", BattleTemplate)

function CheckWeather:ctor(templateInfo)

    CheckWeather.super.ctor(self, templateInfo)

    -- self:registerEvent(CHECK_CONDITION, CheckWeather.checkCondition)
    self:registerEvent(GET_SKILL_DESC, CheckWeather.getSkillDesc)

end

function CheckWeather:checkCondition(data, ownerPet, templateLevel)

    local triggerWeather = data:getParamValue("触发天气", templateLevel)
    local weatherEnum = BattleAidFunc.str2Enum(triggerWeather)
    if (BattleCotroller.getCurrentBattle():getCurWeather() ~= weatherEnum) then
        return false
    end
    return true
    
end

function CheckWeather:getSkillDesc(data, templateLevel)

    local triggerWeather = data:getParamValue("触发天气", templateLevel)
    local weatherEnum = BattleAidFunc.str2Enum(triggerWeather)

    return triggerWeather

end

return CheckWeather