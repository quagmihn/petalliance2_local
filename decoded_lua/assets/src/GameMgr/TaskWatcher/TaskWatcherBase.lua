--TaskWatcherBase.lua
--Date 2016.10.6
--此文件由[BabeLua]插件自动生成
--这是任务观察器的基类


local TaskWatcherBase = class("TaskWatcherBase")
function TaskWatcherBase:ctor(taskData,name)
    self.taskData = taskData
    self.taskTypeName = name
    self.btaskComplete = false
    self.currentnum = "0"
    if self.taskData.keyName~="" then 
        --print("taskData.keyName is ............................"..self.taskData.keyName)
        local keyname = (self.taskData.keyName)
        TaskWatcherManager.sevenDaysQuestPrizeTable[keyname] = 0
    end
end

function TaskWatcherBase:getTaskTypeName()
    --print("taskTypeName is:"..self.taskTypeName)
    --print("taskData is :"..self.taskData.sevenQuestName)
    return self.taskTypeName
end

function TaskWatcherBase:canTakeTaskPrize()
    return self.btaskComplete
end



function TaskWatcherBase:getConditionFromOtherSystem(params) --need ask
    return nil
end

function TaskWatcherBase:getConditionFromServerKeyWords(params) --ask server
    return nil 
end

function TaskWatcherBase:getConditionFromServerSaveparams(params) --need notify
    return nil
end

function TaskWatcherBase:goToProcess() --去界面

    return nil
end

function TaskWatcherBase:setCurrentNum(val)
    print("setCurrentNum is ..............................................."..val)
    self.currentnum = val
end

function TaskWatcherBase:getCurrentNum()
    return self.currentnum
end


return TaskWatcherBase

--endregion
