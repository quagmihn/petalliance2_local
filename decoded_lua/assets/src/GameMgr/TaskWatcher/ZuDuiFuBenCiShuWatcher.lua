--region ZuDuiFuBenCiShuWatcher.lua
--Date 2016.10.7
--此文件由[BabeLua]插件自动生成
local TaskWatcherBase = require("src.GameMgr.TaskWatcher.TaskWatcherBase")
local ZuDuiFuBenCiShuWatcher = class("ZuDuiFuBenCiShuWatcher",TaskWatcherBase)

function ZuDuiFuBenCiShuWatcher:ctor(taskData)
    ZuDuiFuBenCiShuWatcher.super.ctor(self,taskData,"ZuDuiFuBenCiShuWatcher")
    self.btaskComplete = false
end

function ZuDuiFuBenCiShuWatcher:getConditionFromServerKeyWords(params)
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


function ZuDuiFuBenCiShuWatcher:canTakeTaskPrize()
    self:getConditionFromServerKeyWords()
    return self.btaskComplete
end

function ZuDuiFuBenCiShuWatcher:goToProcess()
     UIStack.closeAllUI()
     MapSeekerMgr.autoSeekPath("TownScene", "b8")
end

return ZuDuiFuBenCiShuWatcher



--endregion
