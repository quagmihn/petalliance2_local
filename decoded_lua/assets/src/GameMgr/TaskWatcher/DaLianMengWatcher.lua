--region DaLianMengWatcher.lua
--Date
--此文件由[BabeLua]插件自动生成
local TaskWatcherBase = require("src.GameMgr.TaskWatcher.TaskWatcherBase")
local DaLianMengWatcher = class("DaLianMengWatcher",TaskWatcherBase)

function DaLianMengWatcher:ctor(taskData)
    DaLianMengWatcher.super.ctor(self,taskData,"DaLianMengWatcher")
    self.btaskComplete = false
    SevenDayFuBenData.addDaLianMengData(self)
end

function DaLianMengWatcher:getConditionFromServerKeyWords(params)
    local teamAdvNum =  self.taskData.needCondition[1]
    local keyname = (self.taskData.keyName)
    local serverAdvNum = tonumber(TaskWatcherManager.sevenDaysQuestPrizeTable[keyname])
    self.currentnum =  serverAdvNum
    if type(serverAdvNum) == "number" then 
        if serverAdvNum >=teamAdvNum then 
            self.btaskComplete = true
        else
            self.btaskComplete = false
        end
    else 
        self.btaskComplete = false
    end      
end

function DaLianMengWatcher:canTakeTaskPrize()
    self:getConditionFromServerKeyWords()
    return self.btaskComplete
end

function DaLianMengWatcher:goToProcess()
    MapSeekerMgr.autoSeekPath("TownScene", "b1")
end

return DaLianMengWatcher


--endregion
