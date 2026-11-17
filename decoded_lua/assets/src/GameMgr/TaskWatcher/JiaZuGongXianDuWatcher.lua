--region JiaZuGongXianDuWatcher.lua
--Date
--此文件由[BabeLua]插件自动生成
local TaskWatcherBase = require("src.GameMgr.TaskWatcher.TaskWatcherBase")
local JiaZuGongXianDuWatcher = class("JiaZuGongXianDuWatcher",TaskWatcherBase)

function JiaZuGongXianDuWatcher:ctor(taskData)
    JiaZuGongXianDuWatcher.super.ctor(self,taskData,"JiaZuGongXianDuWatcher")
    self.btaskComplete = false
end

--上官嘉良提供接口，返回家族贡献度
function JiaZuGongXianDuWatcher:getConditionFromOtherSystem(params)
    local devotePoint = 0
    local membersInfo =  FamilyInfo.GetLocalFamilyMembersInfo()
    if CharInfo.getFamilyID() ~= nil and membersInfo ~= nil then
        devotePoint = membersInfo[tostring(CharInfo.getCharID())].devotePoint or 0
    end

    local needdevotePoint = self.taskData.needCondition[1]
    self.currentnum =  devotePoint
    if devotePoint >= needdevotePoint then 
        self.btaskComplete = true
    else
        self.btaskComplete = false
    end
end

function JiaZuGongXianDuWatcher:canTakeTaskPrize()
    self:getConditionFromOtherSystem()
    return self.btaskComplete
end

function JiaZuGongXianDuWatcher:goToProcess()
     FamilyInfo.GoHome()
end

return JiaZuGongXianDuWatcher



--endregion
