--MeiRiLiBaoWatcher.lua
--Date 2016.10.6
--每日礼包可以直接拿，不需要接口
--此文件由[BabeLua]插件自动生成
--每日礼包任务
local TaskWatcherBase = require("src.GameMgr.TaskWatcher.TaskWatcherBase")
local MeiRiLiBaoWatcher = class("MeiRiLiBaoWatcher",TaskWatcherBase)

function MeiRiLiBaoWatcher:ctor(taskData)
    MeiRiLiBaoWatcher.super.ctor(self,taskData,"MeiRiLiBaoWatcher")
    self.btaskComplete = true
end


return MeiRiLiBaoWatcher





--endregion
