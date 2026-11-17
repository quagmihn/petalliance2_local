require("src.GameMgr.GameInit")

local IdlingMapScene = class("IdlingMapScene", function()
    return display.newScene("IdlingMapScene")
end)

function IdlingMapScene:ctor()
    IdlingMapMgr.createMap(self)
end

function IdlingMapScene:onEnter()
    SceneMgr.clearScene(self)
end

function IdlingMapScene:onExit()
    --SceneMgr.onSceneExit(self)
end

return IdlingMapScene