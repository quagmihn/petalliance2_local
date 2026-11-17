--region CWJiBanXingJiWatcher.lua
--Date
--此文件由[BabeLua]插件自动生成
local TaskWatcherBase = require("src.GameMgr.TaskWatcher.TaskWatcherBase")
local CWJiBanXingJiWatcher = class("CWJiBanXingJiWatcher",TaskWatcherBase)

function CWJiBanXingJiWatcher:ctor(taskData)
    CWJiBanXingJiWatcher.super.ctor(self,taskData,"CWJiBanXingJiWatcher")
    self.btaskComplete = false

    local yokeStar = taskData.needCondition[3]
    SevenDayPetData.addChongWuJiBanStar(yokeStar, self)
end

function CWJiBanXingJiWatcher:getConditionFromServerSaveparams(params)
    if TaskWatcherManager.completeTaskTable[self.taskData.id] == nil then 
        self.btaskComplete = false
   else
        self.btaskComplete = true
   end        
end

--直接去宠物列表界面
function CWJiBanXingJiWatcher:goToProcess()
	UIStack.closeAllUI()
	PetFormationMgr.show(SceneMgr.getRunningScene)
end

function CWJiBanXingJiWatcher:canTakeTaskPrize()
    self:getConditionFromServerSaveparams()
    return self.btaskComplete
end

return CWJiBanXingJiWatcher
--endregion
