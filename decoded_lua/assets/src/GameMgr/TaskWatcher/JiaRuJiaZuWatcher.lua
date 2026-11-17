--region JiaRuJiaZuWatcher.lua
--Date
--此文件由[BabeLua]插件自动生成
local TaskWatcherBase = require("src.GameMgr.TaskWatcher.TaskWatcherBase")
local JiaRuJiaZuWatcher = class("JiaRuJiaZuWatcher",TaskWatcherBase)

function JiaRuJiaZuWatcher:ctor(taskData)
    JiaRuJiaZuWatcher.super.ctor(self,taskData,"JiaRuJiaZuWatcher")
    self.btaskComplete = false
end

--上官嘉良 获得家族id(0:无家族,非0:有家族)
function JiaRuJiaZuWatcher:getConditionFromOtherSystem(params)
    local familyID = CharInfo.getFamilyID()
    if familyID == nil then
        self.btaskComplete = false
    else
        self.btaskComplete = true
    end
end

function JiaRuJiaZuWatcher:canTakeTaskPrize()
    self:getConditionFromOtherSystem()
    return self.btaskComplete
end



return JiaRuJiaZuWatcher


--endregion
