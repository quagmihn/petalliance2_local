--region SHSHJiNengZhiZhuoWatcher.lua
--Date
--此文件由[BabeLua]插件自动生成
local TaskWatcherBase = require("src.GameMgr.TaskWatcher.TaskWatcherBase")
local SHJiNengZhiZhuoWatcher = class("SHJiNengZhiZhuoWatcher",TaskWatcherBase)

function SHJiNengZhiZhuoWatcher:ctor(taskData)
    SHJiNengZhiZhuoWatcher.super.ctor(self,taskData,"SHJiNengZhiZhuoWatcher")
    self.btaskComplete = false
    self.currentnum = 0
    if taskData.keyName == "" then 
        SevenDayPetData.addshJiNengZhiZuoZiSe(self)
    else
       SevenDayPetData.addShJiNengShuliang(self)
    end
end

function SHJiNengZhiZhuoWatcher:getConditionFromServerSaveparams(params)
    if TaskWatcherManager.completeTaskTable[self.taskData.id] == nil then 
        self.btaskComplete = false
   else
        self.btaskComplete = true
   end     
end

function SHJiNengZhiZhuoWatcher:getConditionFromServerKeyWords(params)
    local teamAdvNum =  self.taskData.needCondition[1]
    local keyname = (self.taskData.keyName)
    print("keyname is........................",keyname,TaskWatcherManager.sevenDaysQuestPrizeTable[keyname])
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

function SHJiNengZhiZhuoWatcher:canTakeTaskPrize()
    if self.taskData.keyName ~= "" then 
        self:getConditionFromServerKeyWords()
    else
        self:getConditionFromServerSaveparams()
    end

    return self.btaskComplete
end

--直接去宠物列表界面
function SHJiNengZhiZhuoWatcher:goToProcess()
    MapSeekerMgr.autoSeekPath("TownScene", "b3")
end

return SHJiNengZhiZhuoWatcher


--endregion
