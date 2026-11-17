--region ZhanDouLiWatcher.lua
--Date
--此文件由[BabeLua]插件自动生成
local TaskWatcherBase = require("src.GameMgr.TaskWatcher.TaskWatcherBase")
local ZhanDouLiWatcher = class("ZhanDouLiWatcher",TaskWatcherBase)

function ZhanDouLiWatcher:ctor(taskData)
    ZhanDouLiWatcher.super.ctor(self,taskData,"ZhanDouLiWatcher")
    self.btaskComplete = false
end

function ZhanDouLiWatcher:getConditionFromOtherSystem(params)
    local power = PokemonInfo.getFightPointByObjID(PokemonInfo.getPetArmy(1))
    local needpower = self.taskData.needCondition[1]
    if power >= needpower then
        self.btaskComplete = true
    else
        self.btaskComplete = false
    end
end


function ZhanDouLiWatcher:canTakeTaskPrize()
    self:getConditionFromOtherSystem()
    return self.btaskComplete
end

return ZhanDouLiWatcher


--endregion
