
require("config")
require("cocos.init")
require("framework.init")
require("LogConfig")

local MyApp = class("MyApp", cc.mvc.AppBase)

function MyApp:ctor()
    MyApp.super.ctor(self)
end

function MyApp:run()
    cc.FileUtils:getInstance():addSearchPath("res/")
    
    GameConfig.setResourcePath()
    self:setSearchPath()
    
    local updateMgr = require("src.GameMgr.Update.UpdateMgr")
    local updateScene = updateMgr:new()
    local transition = display.wrapSceneWithTransition(updateScene, "fade", 0.5)
    display.replaceScene(transition)
end

function MyApp:setSearchPath()
    local searchPaths = cc.FileUtils:getInstance():getSearchPaths()
    if searchPaths[1]~=CONFIG_STORE_PATH then
        table.insert(searchPaths, 1, CONFIG_STORE_PATH)
    end
    cc.FileUtils:getInstance():setSearchPaths(searchPaths)
end

return MyApp
