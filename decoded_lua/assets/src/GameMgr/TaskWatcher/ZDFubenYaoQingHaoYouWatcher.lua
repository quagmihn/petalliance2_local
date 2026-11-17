--region ZDFubenYaoQingHaoYouWatcher.lua
--Date 2016.10.7
--上官给接口
--此文件由[BabeLua]插件自动生成
local TaskWatcherBase = require("src.GameMgr.TaskWatcher.TaskWatcherBase")
local ZDFubenYaoQingHaoYouWatcher = class("ZDFubenYaoQingHaoYouWatcher",TaskWatcherBase)

function ZDFubenYaoQingHaoYouWatcher:ctor(taskData)
    ZDFubenYaoQingHaoYouWatcher.super.ctor(self,taskData,"ZDFubenYaoQingHaoYouWatcher")
    self.btaskComplete = false
end

function ZDFubenYaoQingHaoYouWatcher:getConditionFromServerSaveparams(params)
   if TaskWatcherManager.completeTaskTable[self.taskData.id] == nil then 
        self.btaskComplete = false
   else
        self.btaskComplete = true
   end 
end

function ZDFubenYaoQingHaoYouWatcher:canTakeTaskPrize()
    self:getConditionFromServerSaveparams()
    return self.btaskComplete
end


return ZDFubenYaoQingHaoYouWatcher


--endregion
