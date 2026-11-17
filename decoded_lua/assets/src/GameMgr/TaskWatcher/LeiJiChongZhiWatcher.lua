--region LeiJiChongZhiWatcher.lua
--Date 2016.10.7
--此文件由[BabeLua]插件自动生成
--累积充值
local TaskWatcherBase = require("src.GameMgr.TaskWatcher.TaskWatcherBase")
local LeiJiChongZhiWatcher = class("LeiJiChongZhiWatcher",TaskWatcherBase)

function LeiJiChongZhiWatcher:ctor(taskData)
    LeiJiChongZhiWatcher.super.ctor(self,taskData,"LeiJiChongZhiWatcher")
    self.btaskComplete = false
end

--王珂给接口
function LeiJiChongZhiWatcher:getConditionFromOtherSystem(params)
	local totalmoney = 0
    if CharInfo.get().recharge then
        totalmoney = CharInfo.get().recharge.totalMoney
    end
    return totalmoney
end

--直接打开充值界面
function LeiJiChongZhiWatcher:goToProcess()
	UIStack.closeAllUI()
	PurchaseViewMgr.show(SceneMgr.getRunningScene)
end

return LeiJiChongZhiWatcher


--endregion
