--region MapRoadWatcher.lua
--Date
--此文件由[BabeLua]插件自动生成
local TaskWatcherBase = require("src.GameMgr.TaskWatcher.TaskWatcherBase")
local MapRoadWatcher = class("MapRoadWatcher",TaskWatcherBase)

function MapRoadWatcher:ctor(taskData)
    MapRoadWatcher.super.ctor(self,taskData,"MapRoadWatcher")
    self.btaskComplete = false
end

--小强给的接口
function MapRoadWatcher:getConditionFromOtherSystem(params)
    local mapid = self.taskData.needCondition[1]
    local pid = self.taskData.needCondition[2]
    if WorldMapInfo.checkMapPointFinished(mapid, pid) == true then 
        self.btaskComplete = true
    else
        self.btaskComplete = false
    end
end


function MapRoadWatcher:canTakeTaskPrize()
    self:getConditionFromOtherSystem()
    return self.btaskComplete
end


return MapRoadWatcher


--endregion
