--region ZuDuiFuBenWatcher.lua
--Date 2016.10.7
--此文件由[BabeLua]插件自动生成
local TaskWatcherBase = require("src.GameMgr.TaskWatcher.TaskWatcherBase")
local ZuDuiFuBenWatcher = class("ZuDuiFuBenWatcher",TaskWatcherBase)

function ZuDuiFuBenWatcher:ctor(taskData)
    ZuDuiFuBenWatcher.super.ctor(self,taskData,"ZuDuiFuBenWatcher")
    self.btaskComplete = false
end

function ZuDuiFuBenWatcher:getConditionFromServerSave(params)
   if TaskWatcherManager.completeTaskTable[self.taskData.id] == nil then 
        self.btaskComplete = false
   else
        self.btaskComplete = true
   end     
end

function ZuDuiFuBenWatcher:canTakeTaskPrize()
    self:getConditionFromServerSave()
    return self.btaskComplete
end

function ZuDuiFuBenWatcher:goToProcess()
     UIStack.closeAllUI()
     MapSeekerMgr.autoSeekPath("TownScene", "b8")
end


return ZuDuiFuBenWatcher


--endregion
