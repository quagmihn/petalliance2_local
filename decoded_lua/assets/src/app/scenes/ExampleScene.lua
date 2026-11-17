local ExampleScene = class("ExampleScene", function()
    return display.newScene("ExampleScene")
end)

function ExampleScene:ctor()


end

function ExampleScene:onEnter()
    SceneMgr.clearScene(self)
end

function ExampleScene:onExit()
    --SceneMgr.onSceneExit(self)
end

return ExampleScene