--region LostTowerHuiFuWatcher.lua
--Date
--此文件由[BabeLua]插件自动生成
local TaskWatcherBase = require("src.GameMgr.TaskWatcher.TaskWatcherBase")
local LostTowerHuiFuWatcher = class("LostTowerHuiFuWatcher",TaskWatcherBase)

function LostTowerHuiFuWatcher:ctor(taskData)
    LostTowerHuiFuWatcher.super.ctor(self,taskData,"LostTowerHuiFuWatcher")
    self.btaskComplete = false
    SevenDayPetData.addLostTowerHuiFu(self)
end

function LostTowerHuiFuWatcher:getConditionFromServerSaveparams(params)
   if TaskWatcherManager.completeTaskTable[self.taskData.id] == nil then 
        self.btaskComplete = false
   else
        self.btaskComplete = true
   end  
end

function LostTowerHuiFuWatcher:canTakeTaskPrize()
    self:getConditionFromServerSaveparams()
    return self.btaskComplete
end

return LostTowerHuiFuWatcher


--endregion
