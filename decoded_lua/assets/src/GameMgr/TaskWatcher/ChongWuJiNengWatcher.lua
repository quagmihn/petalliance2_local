--region ChongWuJiNengWatcher.lua
--Date 
--任意一只宠物A级技能达到五级 三只宠物任意技能达到三级
--此文件由[BabeLua]插件自动生成
local TaskWatcherBase = require("src.GameMgr.TaskWatcher.TaskWatcherBase")
local ChongWuJiNengWatcher = class("ChongWuJiNengWatcher",TaskWatcherBase)

function ChongWuJiNengWatcher:ctor(taskData)
    ChongWuJiNengWatcher.super.ctor(self,taskData,"ChongWuJiNengWatcher")
    self.btaskComplete = false
    local grade = taskData.needCondition[3]
    local skilllv = taskData.needCondition[4]
    SevenDayPetData.addChongWuJiNengShengJi(grade,skilllv,self)
end

--获得王珂接口
function ChongWuJiNengWatcher:getConditionFromServerSaveparams(params)
	-- print("self.taskData.id is ........................."..self.taskData.id)
	if TaskWatcherManager.completeTaskTable[self.taskData.id] == nil then 
		self.btaskComplete = false
	else
		self.btaskComplete = true
	end
end

--直接去宠物列表界面
function ChongWuJiNengWatcher:goToProcess()
	UIStack.closeAllUI()
	PetFormationMgr.show(SceneMgr.getRunningScene)
end

function ChongWuJiNengWatcher:canTakeTaskPrize()
    self:getConditionFromServerSaveparams()
    return self.btaskComplete
end

return ChongWuJiNengWatcher


--endregion
