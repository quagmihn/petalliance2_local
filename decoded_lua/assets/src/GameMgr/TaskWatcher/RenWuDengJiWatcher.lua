--region RenWuDengJiWatcher.lua
--Date
--此文件由[BabeLua]插件自动生成
local TaskWatcherBase = require("src.GameMgr.TaskWatcher.TaskWatcherBase")
local RenWuDengJiWatcher = class("RenWuDengJiWatcher",TaskWatcherBase)

function RenWuDengJiWatcher:ctor(taskData)
    RenWuDengJiWatcher.super.ctor(self,taskData,"RenWuDengJiWatcher")
    self.btaskComplete = false
end

function RenWuDengJiWatcher:getConditionFromOtherSystem(params)

    local charlevel =  CharInfo.getLevel()--没有的话等于0
    local needlevel = self.taskData.needCondition[1]
    self.currentnum =  charlevel
    if charlevel >= needlevel then 
        self.btaskComplete = true
    else
        self.btaskComplete = false
    end
end


function RenWuDengJiWatcher:canTakeTaskPrize()
    self:getConditionFromOtherSystem()
    return self.btaskComplete
end


return RenWuDengJiWatcher


--endregion
