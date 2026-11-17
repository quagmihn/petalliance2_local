--region ChongWuXunLianChongZhiWatcher.lua
--Date
--此文件由[BabeLua]插件自动生成
local TaskWatcherBase = require("src.GameMgr.TaskWatcher.TaskWatcherBase")
local ChongWuXunLianChongZhiWatcher = class("ChongWuXunLianChongZhiWatcher",TaskWatcherBase)

function ChongWuXunLianChongZhiWatcher:ctor(taskData)
    ChongWuXunLianChongZhiWatcher.super.ctor(self,taskData,"ChongWuXunLianChongZhiWatcher")
    self.btaskComplete = false
    SevenDayPetData.addXunlianChongZhi(self)
end

function ChongWuXunLianChongZhiWatcher:getConditionFromServerSaveparams(params)
   if TaskWatcherManager.completeTaskTable[self.taskData.id] == nil then 
        self.btaskComplete = false
   else
        self.btaskComplete = true
   end     
end

function ChongWuXunLianChongZhiWatcher:canTakeTaskPrize()
    self:getConditionFromServerSaveparams()
    return self.btaskComplete
end

return ChongWuXunLianChongZhiWatcher


--endregion
