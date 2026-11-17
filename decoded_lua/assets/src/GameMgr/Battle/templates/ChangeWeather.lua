local ChangeWeather = class("ChangeWeather", BattleTemplate)

function ChangeWeather:ctor(templateInfo)

    ChangeWeather.super.ctor(self, templateInfo)

end

function ChangeWeather:work(data, ownerPet, templateLevel)
    
    local weatherType = data:getParamValue("目标环境", templateLevel)
    local weatherEnum = BattleAidFunc.str2Enum(weatherType)
    BattleCotroller.getCurrentBattle():changeWeather(weatherEnum)

end

function ChangeWeather:getSkillDesc(data, templateLevel)

    return BattleAidFunc.getSkillDesc(data, templateLevel)

end

return ChangeWeather