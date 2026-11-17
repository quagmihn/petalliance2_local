local CreateCharScene = class("CreateCharScene", function()
    return display.newScene("CreateCharScene")
end)

function CreateCharScene:ctor()
    CreateCharViewMgr.show(self)
    CocosModuleMgr.addTouchEffect(self)
end

function CreateCharScene:onEnter()
    SceneMgr.clearScene(self)
    GameLogMgr.OnGameStateChange(GameLogMgr.UserGameState.STATE_LOADINGTOGAME)
end

function CreateCharScene:onExit()
    --SceneMgr.onSceneExit(self)
end

return CreateCharScene