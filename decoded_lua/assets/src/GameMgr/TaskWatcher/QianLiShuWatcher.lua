--region QianLiShuWatcher.lua
--Date
--此文件由[BabeLua]插件自动生成
local TaskWatcherBase = require("src.GameMgr.TaskWatcher.TaskWatcherBase")
local QianLiShuWatcher = class("QianLiShuWatcher",TaskWatcherBase)

function QianLiShuWatcher:ctor(taskData)
    QianLiShuWatcher.super.ctor(self,taskData,"QianLiShuWatcher")
    self.btaskComplete = false
end

function QianLiShuWatcher:getConditionFromOtherSystem(params)

    local toprank =  AchievementListMgr.getFinishSkillNum()--没有的话等于0
    local needrank = self.taskData.needCondition[1]
    self.currentnum =  toprank
    if toprank >= needrank then 
        self.btaskComplete = true
    else
        self.btaskComplete = false
    end
    --xxfuntion(params.num) return bool
end

function QianLiShuWatcher:canTakeTaskPrize()
    self:getConditionFromOtherSystem()
    return self.btaskComplete
end

function QianLiShuWatcher:goToProcess()
	UIStack.closeAllUI()
	AchievementListMgr.show(SceneMgr.getRunningScene,1)
end



return QianLiShuWatcher


--endregion
