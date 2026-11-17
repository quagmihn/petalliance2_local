--region ChongWuShengXingWatcher.lua
--Date
--此文件由[BabeLua]插件自动生成
local TaskWatcherBase = require("src.GameMgr.TaskWatcher.TaskWatcherBase")
local ChongWuShengXingWatcher = class("ChongWuShengXingWatcher",TaskWatcherBase)

function ChongWuShengXingWatcher:ctor(taskData)
    ChongWuShengXingWatcher.super.ctor(self,taskData,"ChongWuShengXingWatcher")
    self.btaskComplete = false
    SevenDayPetData.addShengXingData(self.taskData.needCondition[1],self.taskData.needCondition[2],self)
end


--宠物升星判断 一只宠物达到三星 三只宠物达到一星 罗伟
function ChongWuShengXingWatcher:getConditionFromOtherSystem(params)
    --function xx(params.petnum,params.star) return bool

      if self.btaskComplete == true then return end 
       print("self.currentnum is........................"..self.currentnum)
      if tonumber(self.currentnum) >=  tonumber(self.taskData.needCondition[1]) then 
            self.btaskComplete = true
      else
            self.btaskComplete = false
      end
    --[[
    if params == nil then return false end
    local pets = PokemonInfo.getAllPets()
    local count = 0

    for k,v in pairs(pets) do
    	if v.star >= params.star then
    		count = count + 1
    	end
    	if count >= params.petnum then
    		return true
    	end
    end

    return false
    ]]
end

--直接去宠物列表界面
function ChongWuShengXingWatcher:goToProcess()
	UIStack.closeAllUI()
	PetFormationMgr.show(SceneMgr.getRunningScene)
end

function ChongWuShengXingWatcher:canTakeTaskPrize()
    self:getConditionFromOtherSystem()
    return self.btaskComplete
end

return ChongWuShengXingWatcher


--endregion
