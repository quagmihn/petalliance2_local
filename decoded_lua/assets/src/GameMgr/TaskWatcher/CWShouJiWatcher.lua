--region CWShouJiWatcher.lua
--Date
--此文件由[BabeLua]插件自动生成
local TaskWatcherBase = require("src.GameMgr.TaskWatcher.TaskWatcherBase")
local CWShouJiWatcher = class("CWShouJiWatcher",TaskWatcherBase)

function CWShouJiWatcher:ctor(taskData)
    CWShouJiWatcher.super.ctor(self,taskData,"CWShouJiWatcher")
    self.btaskComplete = false
end

--王珂给接口
function CWShouJiWatcher:getConditionFromOtherSystem(params)
    --xxfuntion shouji(params.petnum,params.grade) --grade:5表示ss,3表示a,0表示任意
    local paramdata = {}
    paramdata.grade = self.taskData.needCondition[2]
    paramdata.petnum = self.taskData.needCondition[1]
    params = paramdata
    local pets = PokemonInfo.getAllPets()
    local count = 0
    self.currentnum = count
    if params.grade ~= 0 then
	    for k,v in pairs(pets) do
	    	local pokemonInfo = PokemonInfo.getPokemonInfoByID(v.pokeID)
	    	if pokemonInfo.rarePoint == params.grade then
	    		count = count + 1
	    	end
            self.currentnum = count
	    	if count >= params.petnum then
	    		return true
	    	end
	    end
	else
        self.currentnum = #pets
		if #pets >= params.petnum then
			return true
		end
	end

    return false
end


function CWShouJiWatcher:goToProcess()
	UIStack.closeAllUI()
	PetFormationMgr.show(SceneMgr.getRunningScene)
end

function CWShouJiWatcher:canTakeTaskPrize()
    self:getConditionFromOtherSystem()
    return self.btaskComplete
end

return CWShouJiWatcher



--endregion
