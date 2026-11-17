--region JingJiChangWatcher.lua
--Date 2016.10.7 竞技场排名
--罗伟
--此文件由[BabeLua]插件自动生成
local TaskWatcherBase = require("src.GameMgr.TaskWatcher.TaskWatcherBase")
local JingJiChangWatcher = class("JingJiChangWatcher",TaskWatcherBase)

function JingJiChangWatcher:ctor(taskData)
    JingJiChangWatcher.super.ctor(self,taskData,"JingJiChangWatcher")
    self.btaskComplete = false
end

function JingJiChangWatcher:getConditionFromOtherSystem(params)
    local toprank =  CharInfo.getArenaTopRank()--没有的话等于0
    if toprank == 0 then toprank = 100000 end

    local needrank = self.taskData.needCondition[1]
    self.currentnum =  toprank
    if toprank <= needrank then 
        self.btaskComplete = true
    else
        self.btaskComplete = false
    end
end

function JingJiChangWatcher:canTakeTaskPrize()
    self:getConditionFromOtherSystem()
    return self.btaskComplete
end

return JingJiChangWatcher


--endregion
