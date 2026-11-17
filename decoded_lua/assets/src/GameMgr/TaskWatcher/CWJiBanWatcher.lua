--region CWJiBanWatcher.lua
--Date
--此文件由[BabeLua]插件自动生成
local TaskWatcherBase = require("src.GameMgr.TaskWatcher.TaskWatcherBase")
local CWJiBanWatcher = class("CWJiBanWatcher",TaskWatcherBase)

function CWJiBanWatcher:ctor(taskData)
    CWJiBanWatcher.super.ctor(self,taskData,"CWJiBanWatcher")
    self.btaskComplete = false

    local yokeCnt = taskData.needCondition[2]
    SevenDayPetData.addChongWuJiBanCnt(yokeCnt, self)
end

function CWJiBanWatcher:getConditionFromServerSaveparams(params)
    if TaskWatcherManager.completeTaskTable[self.taskData.id] == nil then 
        self.btaskComplete = false
   else
        self.btaskComplete = true
   end    
end

function CWJiBanWatcher:canTakeTaskPrize()
    self:getConditionFromServerSaveparams()
    return self.btaskComplete
end

--直接去宠物列表界面
function CWJiBanWatcher:goToProcess()
	UIStack.closeAllUI()
	PetFormationMgr.show(SceneMgr.getRunningScene)
end

return CWJiBanWatcher


--endregion
