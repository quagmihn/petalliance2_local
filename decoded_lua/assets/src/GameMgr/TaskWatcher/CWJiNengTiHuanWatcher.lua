--region CWJiNengTiHuanWatcher.lua
--Date
--此文件由[BabeLua]插件自动生成
local TaskWatcherBase = require("src.GameMgr.TaskWatcher.TaskWatcherBase")
local CWJiNengTiHuanWatcher = class("CWJiNengTiHuanWatcher",TaskWatcherBase)

function CWJiNengTiHuanWatcher:ctor(taskData)
    CWJiNengTiHuanWatcher.super.ctor(self,taskData,"CWJiNengTiHuanWatcher")
    self.btaskComplete = false
    SevenDayPetData.addJinengTiHuan(self)
end

function CWJiNengTiHuanWatcher:getConditionFromServerSaveparams(params)
   print("self.taskData.id is ........................."..self.taskData.id)
   if TaskWatcherManager.completeTaskTable[self.taskData.id] == nil then 
        self.btaskComplete = false
   else
        self.btaskComplete = true
   end      
end

--直接去宠物列表界面
function CWJiNengTiHuanWatcher:goToProcess()
	UIStack.closeAllUI()
	PetFormationMgr.show(SceneMgr.getRunningScene)
end

function CWJiNengTiHuanWatcher:canTakeTaskPrize()
    self:getConditionFromServerSaveparams()
    return self.btaskComplete
end

return CWJiNengTiHuanWatcher


--endregion
