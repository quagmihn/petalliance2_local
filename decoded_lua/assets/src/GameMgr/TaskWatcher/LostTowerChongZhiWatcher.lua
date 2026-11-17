--region LostTowerChongZhiWatcher.lua
--Date
--此文件由[BabeLua]插件自动生成
local TaskWatcherBase = require("src.GameMgr.TaskWatcher.TaskWatcherBase")
local LostTowerChongZhiWatcher = class("LostTowerChongZhiWatcher",TaskWatcherBase)

function LostTowerChongZhiWatcher:ctor(taskData)
    LostTowerChongZhiWatcher.super.ctor(self,taskData,"LostTowerChongZhiWatcher")
    self.btaskComplete = false
    SevenDayPetData.addLostTowerChongZhi(self)
end

function LostTowerChongZhiWatcher:getConditionFromServerSaveparams(params)
   if TaskWatcherManager.completeTaskTable[self.taskData.id] == nil then 
        self.btaskComplete = false
   else
        self.btaskComplete = true
   end       
end

function LostTowerChongZhiWatcher:canTakeTaskPrize()
    self:getConditionFromServerSaveparams()
    return self.btaskComplete
end

return LostTowerChongZhiWatcher


--endregion
