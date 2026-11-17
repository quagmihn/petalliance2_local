--region BaiFangJiaJuWatcher.lua
--Date
--此文件由[BabeLua]插件自动生成
local TaskWatcherBase = require("src.GameMgr.TaskWatcher.TaskWatcherBase")
local BaiFangJiaJuWatcher = class("BaiFangJiaJuWatcher",TaskWatcherBase)

function BaiFangJiaJuWatcher:ctor(taskData)
    BaiFangJiaJuWatcher.super.ctor(self,taskData,"BaiFangJiaJuWatcher")
    self.btaskComplete = false
end

--接口上官嘉良 获得家具数量
function BaiFangJiaJuWatcher:getConditionFromOtherSystem(params)
    
 
    local furnitureNum =  HomeInfo.GetLocalHomeFurnitureNum()--没有的话等于0
    local needNum = self.taskData.needCondition[1]
    self.currentnum = furnitureNum
    if furnitureNum >= needNum then 
        self.btaskComplete = true
    else
        self.btaskComplete = false
    end
end

--直接去家园的前往
function BaiFangJiaJuWatcher:goToProcess()
    FamilyInfo.GoHome()
end

function BaiFangJiaJuWatcher:canTakeTaskPrize()
    self:getConditionFromOtherSystem()
    return self.btaskComplete
end


return BaiFangJiaJuWatcher


--endregion
