require("src.GameMgr.GameInit")

local SecondScene = class("SecondScene", function()
    return display.newScene("SecondScene")
end)

function SecondScene:ctor()

    TownMapMgr.createWithRes(self, "Map/map_grass.csb",
    function()
            SceneMgr.replaceScene(self, "WaterScene")
    end,
    function()
            SceneMgr.replaceScene(self, "MainScene")
    end)
    
    StatusBarMgr.addStatusBar(self)
    
    MiniMapMgr.addMiniMapUI(self)
    
    BasicMenuMgr.addBasicMenu(self)

    TownMapMgr.setMapButton({"map_grass","farm"}, function()
        SceneMgr.mapEnterType = 99
        SceneMgr.replaceScene(self, "SecondScene")
    end)
    
    TownMapMgr.setMapButton({"map_grass","shop"}, function()
        if not self.shop then
            CocosModuleMgr.setButtonGuide(CSResourceMgr.getNodeByName("Map/map_grass.csb", "shop"), 1)
            self.shop = true
        else
            ShopListMgr.show(self, "Item/Shop/basicShopList.csb", nil)
            self.shop = false
        end
    end)
    
    --[[
    TownMapMgr.setMapButtonEvent({"map_grass","farm"}, function()
        CocosModuleMgr.CameraEffects(self, 0.5, 0)
    end, function()
        CSResourceMgr.playAction("Map/map_grass.csb", 10, 18, false)
    end)
    --]]
    
    --[[
    TownMapMgr.setMapButtonEvent({"map_grass","shop"}, function()
        --CocosModuleMgr.CameraEffects(self, 0.5, 0)
        TownMapMgr.makePlayerRandomMove("机器人01", true)
        TipsMgr.show(self, "哈哈哈")
    end, function()
        CSResourceMgr.playAction("Map/map_grass.csb", 0, 8, false)
    end)
    ]]--
    
    --[[
    CSResourceMgr.clickEventBinding("Map/map_farm.csb", {"map_farm","farm"}, function()
    end)
    CSResourceMgr.clickEventBinding("Map/map_farm.csb", {"map_farm","auction"}, function()
    end)
    ]]--

end

function SecondScene:onEnter()
    SceneMgr.clearScene(self)
end

function SecondScene:onExit()
    --SceneMgr.onSceneExit(self)
end

return SecondScene