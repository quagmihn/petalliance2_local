local BattleWeather = {}
local weatherRes = {
}
--"Battle/weather/snow1.plist"
weatherRes[2] = "Battle/weather/rain.plist"
BattleWeather.weatherInfo = 
{
	{"weather1","weatherDesc1"},  --炎热
	{"weather2","weatherDesc2"},  --下雨
	{"weather3","weatherDesc3"},  --刮风
	{"weather4","weatherDesc4"},  --地穴
	{"weather5","weatherDesc5"},  --打雷
	{"weather6","weatherDesc6"},  --沼泽
	{"weather7","weatherDesc7"}   --晴天
}
 
BattleWeather.node 		= nil
BattleWeather.zorder 	= 6

function BattleWeather.createWeather(parent,weather) 
	if weatherRes[weather] then
		if BattleWeather.node then
			BattleWeather.node:removeFromParent()
			BattleWeather.node = nil
		end
		BattleWeather.node = CSResourceMgr.createParticle(parent, weatherRes[weather], display.cx, 2*display.cy-150) 
    	BattleWeather.node:zorder(BattleWeather.zorder)
    else
    	if BattleWeather.node then
			BattleWeather.node:removeFromParent()
			BattleWeather.node = nil
		end
	end
end

function BattleWeather.cleanWeather()
	if BattleWeather.node then
		BattleWeather.node:removeFromParent()
		BattleWeather.node = nil
	end
end

return BattleWeather