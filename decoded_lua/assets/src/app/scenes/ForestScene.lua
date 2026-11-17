require("src.GameMgr.GameInit")

local ForestScene = class("ForestScene", function()
    return display.newScene("ForestScene")
end)

function ForestScene:ctor()

    TownMapMgr.createWithRes(self, "Map/m1/map_1_1.csb",
        function()
            SceneMgr.replaceScene(self, "MainScene")
        end,
        function()
            SceneMgr.replaceScene(self, "WaterScene")
            print("right")
        end)
    local node = CSResourceMgr.getNodeByName("Map/m1/map_1_1_front.csb", "013")
    local posx = node:getPositionX()
    node:setPositionX(posx+500)
    TownMapMgr.setMapObstacle("013")
    
    --TownMapMgr.setMapObstacle("015") 
    --TownMapMgr.setMapObstacle("016")
    
    local node = CSResourceMgr.getNodeByName("Map/m1/map_1_1_front.csb", "099")
    local posx = node:getPositionX()
    node:setPositionX(posx-500)
    TownMapMgr.setMapObstacle("099")
    
    local function tmpFunc(string)
        TownMapMgr.setMapButtonEvent(string, function()
            DialogBoxMgr.showSmallDialogBox(self, 2, "是否清除障碍物？", function()
                TownMapMgr.removeMapObstacle(string)
            end)
        end)
    end
    
    tmpFunc("013")
    --tmpFunc("015")
    --tmpFunc("016")
    tmpFunc("099")
    

    StatusBarMgr.addStatusBar(self)
    
    MiniMapMgr.addMiniMapUI(self)
    
    BasicMenuMgr.addBasicMenu(self)
    
end

function ForestScene:onEnter()
    SceneMgr.clearScene(self)
end

function ForestScene:onExit()
    --SceneMgr.onSceneExit(self)
end

return ForestScene