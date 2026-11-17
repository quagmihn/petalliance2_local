--region QiangHuaChongWuWatcher.lua
--Date
--此文件由[BabeLua]插件自动生成
local TaskWatcherBase = require("src.GameMgr.TaskWatcher.TaskWatcherBase")
local QiangHuaChongWuWatcher = class("QiangHuaChongWuWatcher",TaskWatcherBase)

function QiangHuaChongWuWatcher:ctor(taskData)
    QiangHuaChongWuWatcher.super.ctor(self,taskData,"QiangHuaChongWuWatcher")
    self.btaskComplete = false
    SevenDayPetData.addQiangHuaData(self.taskData.needCondition[1],self.taskData.needCondition[2],self)
end

--王珂提供接口
--[[
params.stage ---强化等级
params.count ---宠物数量
]]
function QiangHuaChongWuWatcher:getConditionFromOtherSystem(params)

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
    self.currentnum =  count
    for k,v in pairs(pets) do
    	if v.Stage >= params.stage then
    		count = count + 1
    	end
        self.currentnum =  count
    	if count >= params.count then
    		return true
    	end


    end

    return false
    ]]
end

--直接去宠物列表界面
function QiangHuaChongWuWatcher:goToProcess()
	UIStack.closeAllUI()
	PetFormationMgr.show(SceneMgr.getRunningScene)
end

function QiangHuaChongWuWatcher:canTakeTaskPrize()
    self:getConditionFromOtherSystem()
    return self.btaskComplete
end

return QiangHuaChongWuWatcher


--endregion
