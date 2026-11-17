local ChangeWeatherRandom = class("ChangeWeatherRandom", BattleTemplate)

function ChangeWeatherRandom:ctor(templateInfo)

    ChangeWeatherRandom.super.ctor(self, templateInfo)

end

function ChangeWeatherRandom:work(data, ownerPet, templateLevel)

	local curBattle = BattleCotroller.getCurrentBattle()

	local curWeather = curBattle:getCurWeather()
	local allWeatherEnums = curBattle:getAllWeatherEnums()
	
	for i = 1, #allWeatherEnums do
		if (allWeatherEnums[i] == curWeather) then
			if (1 ~= i) then
				allWeatherEnums[i] = allWeatherEnums[1]
				allWeatherEnums[1] = curWeather
			end 
			break
		end
	end

	local changedWeather = allWeatherEnums[GetRandom.random(2, #allWeatherEnums)]
	curBattle:changeWeather(changedWeather)

end

function ChangeWeatherRandom:getSkillDesc(data, templateLevel)

    return BattleAidFunc.getSkillDesc(data, templateLevel)

end

return ChangeWeatherRandom