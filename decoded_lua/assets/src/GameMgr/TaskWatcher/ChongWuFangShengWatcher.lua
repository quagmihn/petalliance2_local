--region ChongWuFangShengWatcher.lua
--Date
--此文件由[BabeLua]插件自动生成
local TaskWatcherBase = require("src.GameMgr.TaskWatcher.TaskWatcherBase")
local ChongWuFangShengWatcher = class("ChongWuFangShengWatcher",TaskWatcherBase)

function ChongWuFangShengWatcher:ctor(taskData)
    ChongWuFangShengWatcher.super.ctor(self,taskData,"ChongWuFangShengWatcher")
    self.btaskComplete = false
    SevenDayFuBenData.addFangShengCWCiShu(self)
end

--服务器关键字:petFreedomNum
function ChongWuFangShengWatcher:getConditionFromServerKeyWords(params)
    local petFreedomNum =  self.taskData.needCondition[1]
    local keyname = (self.taskData.keyName)
    local serverpetFreedomNum = tonumber(TaskWatcherManager.sevenDaysQuestPrizeTable[keyname])
    self.currentnum = serverpetFreedomNum
    if type(serverpetFreedomNum) == "number" then 
        if serverpetFreedomNum >=petFreedomNum then 
            self.btaskComplete = true
        else
            self.btaskComplete = false
        end
    else 
        self.btaskComplete = false
    end
end


--直接去宠物列表界面
function ChongWuFangShengWatcher:goToProcess()
	UIStack.closeAllUI()
	PetFormationMgr.show(SceneMgr.getRunningScene)
end

function ChongWuFangShengWatcher:canTakeTaskPrize()
    self:getConditionFromServerKeyWords()
    return self.btaskComplete
end

return ChongWuFangShengWatcher


--endregion
