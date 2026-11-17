--region SuiPianHeChengWatcher.lua
--Date
--此文件由[BabeLua]插件自动生成
local TaskWatcherBase = require("src.GameMgr.TaskWatcher.TaskWatcherBase")
local SuiPianHeChengWatcher = class("SuiPianHeChengWatcher",TaskWatcherBase)

function SuiPianHeChengWatcher:ctor(taskData)
    SuiPianHeChengWatcher.super.ctor(self,taskData,"SuiPianHeChengWatcher")
    self.btaskComplete = false
    SevenDayFuBenData.addSuiPianHeChengData(self)
end


--根据服务器关键字获取
function SuiPianHeChengWatcher:getConditionFromServerKeyWords(params)
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

function SuiPianHeChengWatcher:canTakeTaskPrize()
    self:getConditionFromServerKeyWords()
    return self.btaskComplete
end

--直接去宠物列表界面
function SuiPianHeChengWatcher:goToProcess()
	UIStack.closeAllUI()
	PetFormationMgr.show(SceneMgr.getRunningScene)
end

return SuiPianHeChengWatcher


--endregion
