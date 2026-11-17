--region LostTowerCengShuWatcher.lua
--Date
--此文件由[BabeLua]插件自动生成
local TaskWatcherBase = require("src.GameMgr.TaskWatcher.TaskWatcherBase")
local LostTowerCengShuWatcher = class("LostTowerCengShuWatcher",TaskWatcherBase)

function LostTowerCengShuWatcher:ctor(taskData)
    LostTowerCengShuWatcher.super.ctor(self,taskData,"LostTowerCengShuWatcher")
    self.btaskComplete = false
end

--洪晓峰，返回迷失之塔层数
function LostTowerCengShuWatcher:getConditionFromOtherSystem(params)
    local topfloor =  CharInfo.get().losttowerfloor or 0--没有的话等于0
    local needfloor = self.taskData.needCondition[1]
    self.currentnum =  topfloor
    if topfloor >= needfloor then 
        self.btaskComplete = true
    else
        self.btaskComplete = false
    end
end

--洪晓峰，前往迷失之塔
function LostTowerCengShuWatcher:goToProcess()
    ExploreViewMgr.show(SceneMgr.getRunningScene)
end

function LostTowerCengShuWatcher:canTakeTaskPrize()
    self:getConditionFromOtherSystem()
    return self.btaskComplete
end

return LostTowerCengShuWatcher


--endregion
