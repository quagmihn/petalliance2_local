--region FubenTongGuanWatcher.lua
--Date 2016.10.7
--此文件由[BabeLua]插件自动生成
local TaskWatcherBase = require("src.GameMgr.TaskWatcher.TaskWatcherBase")
local FubenTongGuanWatcher = class("FubenTongGuanWatcher",TaskWatcherBase)

function FubenTongGuanWatcher:ctor(taskData)
    FubenTongGuanWatcher.super.ctor(self,taskData,"FubenTongGuanWatcher")
    self.btaskComplete = false
    SevenDayFuBenData.addFuBenTongGuanData(self)
end

--小强给的接口
function FubenTongGuanWatcher:getConditionFromOtherSystem(params)
    local fubenid = self.taskData.needCondition[1]
    local guankaid = fubenid%10000
    local leixingid = math.floor(fubenid/10000+1)
    local starNum, starMax = AdvStarMgr.getWorldMapStarNum(guankaid)
    --print("starNum is................ leixingid is...........",starNum,guankaid)
    if starNum >= leixingid then 
        self.btaskComplete = true
    else
        self.btaskComplete = false
    end
end

--进入该关卡
function FubenTongGuanWatcher:goToProcess()
    GameGuideMgr.checkScene("MainScene")
end

function FubenTongGuanWatcher:canTakeTaskPrize()
    self:getConditionFromOtherSystem()
    return self.btaskComplete
end

return FubenTongGuanWatcher


--endregion
