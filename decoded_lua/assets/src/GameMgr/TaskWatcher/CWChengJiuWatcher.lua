--region CWChengJiuWatcher.lua
--Date
--此文件由[BabeLua]插件自动生成
local TaskWatcherBase = require("src.GameMgr.TaskWatcher.TaskWatcherBase")
local CWChengJiuWatcher = class("CWChengJiuWatcher",TaskWatcherBase)

function CWChengJiuWatcher:ctor(taskData)
    CWChengJiuWatcher.super.ctor(self,taskData,"CWChengJiuWatcher")
    self.btaskComplete = false
end

--杜家其
function CWChengJiuWatcher:getConditionFromOtherSystem(params)

    local toprank =  AchievementListMgr.getFinishPetAchieveNum()--没有的话等于0
    self.currentnum = toprank
    local needrank = self.taskData.needCondition[1]
    if toprank >= needrank then 
        self.btaskComplete = true
    else
        self.btaskComplete = false
    end
    --return num>=params.num
    --xxfunction(params.num) return bool
end

function CWChengJiuWatcher:goToProcess()
	UIStack.closeAllUI()
	AchievementListMgr.show(SceneMgr.getRunningScene,1)
end

function CWChengJiuWatcher:canTakeTaskPrize()
    self:getConditionFromOtherSystem()
    return self.btaskComplete
end

return CWChengJiuWatcher


--endregion
