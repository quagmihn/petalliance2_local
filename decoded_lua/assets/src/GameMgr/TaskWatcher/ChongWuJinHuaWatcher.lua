--region ChongWuJinHuaWatcher.lua
--Date
--此文件由[BabeLua]插件自动生成
local TaskWatcherBase = require("src.GameMgr.TaskWatcher.TaskWatcherBase")
local ChongWuJinHuaWatcher = class("ChongWuJinHuaWatcher",TaskWatcherBase)

function ChongWuJinHuaWatcher:ctor(taskData)
    ChongWuJinHuaWatcher.super.ctor(self,taskData,"ChongWuJinHuaWatcher")
    self.btaskComplete = false
    SevenDayFuBenData.addChongWuJinHuaData(self)
end

--从服务器获取关键字
function ChongWuJinHuaWatcher:getConditionFromServerKeyWords(params)
    local teamAdvNum =  self.taskData.needCondition[1]
    local keyname = (self.taskData.keyName)
    local serverAdvNum = tonumber(TaskWatcherManager.sevenDaysQuestPrizeTable[keyname])
     self.currentnum  = serverAdvNum
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


function ChongWuJinHuaWatcher:canTakeTaskPrize()
    self:getConditionFromServerKeyWords()
    return self.btaskComplete
end

--直接去宠物列表界面
function ChongWuJinHuaWatcher:goToProcess()
	UIStack.closeAllUI()
	PetFormationMgr.show(SceneMgr.getRunningScene)
end

return ChongWuJinHuaWatcher


--endregion
