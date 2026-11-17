local ExploreScene = class("ExploreScene", function()
    return display.newScene("ExploreScene")
end)

function ExploreScene:ctor()
    ExploreMapMgr.show(self)
end

function ExploreScene:onEnter()
    SceneMgr.clearScene(self)
end

function ExploreScene:onExit()
end

return ExploreScene