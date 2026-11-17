--region ChaoZhiLiBaoWatcherWatcher.lua
--Date 2016.10.7
--此文件由[BabeLua]插件自动生成
local TaskWatcherBase = require("src.GameMgr.TaskWatcher.TaskWatcherBase")
local ChaoZhiLiBaoWatcher = class("ChaoZhiLiBaoWatcher",TaskWatcherBase)

--直接购买，没有接口调用
function ChaoZhiLiBaoWatcher:ctor(taskData)
    ChaoZhiLiBaoWatcher.super.ctor(self,taskData,"ChaoZhiLiBaoWatcher")
    self.btaskComplete = true
end



return ChaoZhiLiBaoWatcher

--endregion
