local expeditionalViewMgr = require("src.GameMgr.Activity.expeditionalViewMgr")

local ExpeditionScene = class("ExpeditionScene", function()
    return display.newScene("ExpeditionScene")
end)

function ExpeditionScene:ctor()
	expeditionalViewMgr.Init()
    expeditionalViewMgr.OpenMap(self) 
    -- StatusBarMgr.addStatusBar(self)
    -- BasicMenuMgr.addBasicMenu(self)
end

function ExpeditionScene:onEnter()
	SceneMgr.clearScene(self)
end

function ExpeditionScene:onExit()
end 

return ExpeditionScene