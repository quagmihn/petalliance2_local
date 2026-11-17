--region SHJiNengJieSuoWatcher.lua
--Date 
--此文件由[BabeLua]插件自动生成
local TaskWatcherBase = require("src.GameMgr.TaskWatcher.TaskWatcherBase")
local SHJiNengJieSuoWatcher = class("SHJiNengJieSuoWatcher",TaskWatcherBase)

function SHJiNengJieSuoWatcher:ctor(taskData)
    SHJiNengJieSuoWatcher.super.ctor(self,taskData,"SHJiNengJieSuoWatcher")
    self.btaskComplete = false
end


--我提供生活技能解锁的接口,返回可以制造的物品数量
function SHJiNengJieSuoWatcher:getConditionFromOtherSystem(params)
    self.currentnum = 0
    if TaskWatcherManager.lifeskillInfo == nil then 
        self.btaskComplete = false
        return 
    end 

    if TaskWatcherManager.lifeskillInfo.drawings ==nil then 
        self.btaskComplete = false
        return
    end


    if TaskWatcherManager.lifeskillInfo.drawings~=nil then 
        local number = #TaskWatcherManager.lifeskillInfo.drawings
        local neednum = self.taskData.needCondition[1]
        self.currentnum =  number  
        if number >= neednum then 
            self.btaskComplete = true
        else
            self.btaskComplete = false
        end
    end

     
end

function SHJiNengJieSuoWatcher:canTakeTaskPrize()
    self:getConditionFromOtherSystem()
    return self.btaskComplete
end

function SHJiNengJieSuoWatcher:goToProcess()
    MapSeekerMgr.autoSeekPath("TownScene", "b3")
end

return SHJiNengJieSuoWatcher


--endregion
