--region JiaZuRenWuWatcher.lua
--Date
--此文件由[BabeLua]插件自动生成
local TaskWatcherBase = require("src.GameMgr.TaskWatcher.TaskWatcherBase")
local JiaZuRenWuWatcher = class("JiaZuRenWuWatcher",TaskWatcherBase)

function JiaZuRenWuWatcher:ctor(taskData)
    JiaZuRenWuWatcher.super.ctor(self,taskData,"JiaZuRenWuWatcher")
    self.btaskComplete = false
    SevenDayFuBenData.addJiaZuRenWuCiShu(taskData.needCondition[1],taskData.needCondition[2],self)
end
--服务器字段familySQuestNum
function JiaZuRenWuWatcher:getConditionFromServerKeyWords(params)
    local familySQuestNum =  self.taskData.needCondition[1]
    local keyname = (self.taskData.keyName)
    local serverSQuestNum = tonumber(TaskWatcherManager.sevenDaysQuestPrizeTable[keyname])
    self.currentnum =  serverSQuestNum
    if type(serverAdvNum) == "number" then 
        if serverSQuestNum >=familySQuestNum then 
            self.btaskComplete = true
        else
            self.btaskComplete = false
        end
    else 
        self.btaskComplete = false
    end    
end

function JiaZuRenWuWatcher:canTakeTaskPrize()
    self:getConditionFromServerKeyWords()
    return self.btaskComplete
end

function JiaZuRenWuWatcher:goToProcess()
     FamilyInfo.GoHome()
end

return JiaZuRenWuWatcher


--endregion
