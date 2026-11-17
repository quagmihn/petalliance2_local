--region KuoJianJiaYuanWatcher.lua
--Date
--此文件由[BabeLua]插件自动生成
local TaskWatcherBase = require("src.GameMgr.TaskWatcher.TaskWatcherBase")
local KuoJianJiaYuanWatcher = class("KuoJianJiaYuanWatcher",TaskWatcherBase)

function KuoJianJiaYuanWatcher:ctor(taskData)
    KuoJianJiaYuanWatcher.super.ctor(self,taskData,"KuoJianJiaYuanWatcher")
    self.btaskComplete = false
end


--上官提供接口(返回家园扩建等级:1--未扩建,2,3,4)
function KuoJianJiaYuanWatcher:getConditionFromOtherSystem(params)
    local expandlevel = FurnitureViewMgr.GetOwnerExpandLevel()
    if  expandlevel >1 then 
        self.btaskComplete = true
    else
        self.btaskComplete = false
    end 
end

--直接去家园界面
function KuoJianJiaYuanWatcher:goToProcess()
    FamilyInfo.GoHome()
end

function KuoJianJiaYuanWatcher:canTakeTaskPrize()
    self:getConditionFromOtherSystem()
    return self.btaskComplete
end

return KuoJianJiaYuanWatcher


--endregion
