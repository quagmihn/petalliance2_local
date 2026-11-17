--region CWJiNengXueXiWatcher.lua
--Date
--此文件由[BabeLua]插件自动生成
local TaskWatcherBase = require("src.GameMgr.TaskWatcher.TaskWatcherBase")
local CWJiNengXueXiWatcher = class("CWJiNengXueXiWatcher",TaskWatcherBase)

function CWJiNengXueXiWatcher:ctor(taskData)
    CWJiNengXueXiWatcher.super.ctor(self,taskData,"CWJiNengXueXiWatcher")
    self.btaskComplete = false
    SevenDayPetData.addJinengXueXi(self)
end

function CWJiNengXueXiWatcher:getConditionFromServerSaveparams(params)
    if TaskWatcherManager.completeTaskTable[self.taskData.id] == nil then 
        self.btaskComplete = false
   else
        self.btaskComplete = true
   end       
end


--直接去宠物列表界面
function CWJiNengXueXiWatcher:goToProcess()
	UIStack.closeAllUI()
	PetFormationMgr.show(SceneMgr.getRunningScene)
end

function CWJiNengXueXiWatcher:canTakeTaskPrize()
    self:getConditionFromServerSaveparams()
    return self.btaskComplete
end

return CWJiNengXueXiWatcher


--endregion
