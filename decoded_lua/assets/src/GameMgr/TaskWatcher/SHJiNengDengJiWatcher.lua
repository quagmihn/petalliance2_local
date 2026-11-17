--region SHJiNengDengJiWatcher.lua
--Date
--此文件由[BabeLua]插件自动生成
local TaskWatcherBase = require("src.GameMgr.TaskWatcher.TaskWatcherBase")
local SHJiNengDengJiWatcher = class("SHJiNengDengJiWatcher",TaskWatcherBase)

function SHJiNengDengJiWatcher:ctor(taskData)
    SHJiNengDengJiWatcher.super.ctor(self,taskData,"SHJiNengDengJiWatcher")
    self.btaskComplete = false
end


--我做
function SHJiNengDengJiWatcher:getConditionFromOtherSystem(params)
    local toprank = 0
    if TaskWatcherManager.lifeskillInfo == nil then 
        toprank = 0
    elseif TaskWatcherManager.lifeskillInfo.level == nil then 
        toprank = 0
    else
        toprank =  TaskWatcherManager.lifeskillInfo.level
    end
    local needrank = self.taskData.needCondition[1]
    self.currentnum =  toprank
    if toprank >= needrank then 
        self.btaskComplete = true
    else
        self.btaskComplete = false
    end
end

function SHJiNengDengJiWatcher:canTakeTaskPrize()
    self:getConditionFromOtherSystem()
    return self.btaskComplete
end

return SHJiNengDengJiWatcher


--endregion
