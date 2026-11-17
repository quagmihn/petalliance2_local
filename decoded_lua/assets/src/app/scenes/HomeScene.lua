local HomeScene = class("HomeScene", function()
    return display.newScene("HomeScene")
end)

function HomeScene:ctor()

    local homeRes = "Map/TownMap/home_01.csb"   --以后读表
    HomeMapMgr.createWithRes(self, homeRes, nil, nil)
    HomeMapMgr.setMapButton("door", function()
        --SceneMgr.mapEnterType = 99
        SceneMgr.replaceScene(self, "MainScene")
        TownMapMgr.setPetScale(0.5)
        TownMapMgr.setPlayerScale(0.7)
        TownMapMgr.Pet:setLocalZOrder(CocosModuleMgr.ZORDER_PLAYER)
        TownMapMgr.Pet:setScale(TownMapMgr.DEFAULT_PET_SCALE, TownMapMgr.DEFAULT_PET_SCALE)
        TownMapMgr.Player:setLocalZOrder(CocosModuleMgr.ZORDER_PLAYER)
    end)
    
    CSResourceMgr.clickEventBinding(homeRes, "tablet_2", function()
        if HomeInfo.GetCurrentHomeCharID() == CharInfo.getCharID() then
            DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 3, "home004", function()
                if DialogBoxMgr.GetInputText() ~= "" then
                    GameAudio.playUISound("success")
                    CSResourceMgr.setButtonString(homeRes, "tablet_2", DialogBoxMgr.GetInputText(), nil, {r=0,g=0,b=0,a=255,w=1})
                    HomeInfo.SetHomeInfo(DialogBoxMgr.GetInputText(), 0, 0, 0, 0, 0)
                else
                    StandardTipsMgr.show(1, "home019")
                end
            end)
        end
    end)
    
    local btn_up = CSResourceMgr.getNodeByName(homeRes, {"home_01","middle_home","elevator_up"})
    local btn_down = CSResourceMgr.getNodeByName(homeRes, {"home_01","middle_home","elevator_down"})
    local btn_floor = CSResourceMgr.getNodeByName(homeRes, {"home_01","middle_home","elevator_floor"})
    
    CSResourceMgr.clickEventBindingByNode(btn_up, function()
        if FurnitureViewMgr.IsOpen() == false then
            GameAudio.playUISound("homeEnter")
            CSResourceMgr.setButtonEnabledByNode(btn_up, false)
            CSResourceMgr.setButtonEnabledByNode(btn_down, false)
            FurnitureViewMgr.upStairs()
        end
    end, 3)
    CSResourceMgr.setButtonEnabledByNode(btn_up, false)
    
    CSResourceMgr.clickEventBindingByNode(btn_down, function()
        if FurnitureViewMgr.IsOpen() == false then
            GameAudio.playUISound("homeEnter")
            CSResourceMgr.setButtonEnabledByNode(btn_up, false)
            CSResourceMgr.setButtonEnabledByNode(btn_down, false)
            FurnitureViewMgr.downStairs()
        end
    end, 3)
    CSResourceMgr.setButtonEnabledByNode(btn_down, false)
    
    CSResourceMgr.clickEventBindingByNode(btn_floor, function()
        if FurnitureViewMgr.IsOpen() == false then
            FamilyFloorInfoMgr.show(SceneMgr.getRunningScene)
            --FurnitureViewMgr.snapShot()
        end
    end, 3)

    StatusBarMgr.addStatusBar(self)
    HomeMenuMgr.addBasicMenu(self)

end

function HomeScene:RandomFurniture()
    for var=1, #HomeInfo.getFurnitureInfo() do
        local FurnitureName,FurnitureWidth,FurnitureAnchor_x,FurnitureAnchor_y,FurnitureRespath = HomeInfo.getFurnitureInfoByID(var)
        local sprite = nil
        sprite = display.newSprite(FurnitureRespath)
        if sprite ~= nil then
            sprite:addTo(TownMapMgr.Map)
            sprite:setPosition((var + 1) * 200, 570)
            sprite:setAnchorPoint(FurnitureAnchor_x, FurnitureAnchor_y)
            sprite:setLocalZOrder(CocosModuleMgr.ZORDER_MAP_BACK)
            --print("@@@@@@@@@@@@@@@@@@@@@@@@@FurnitureRespath="..FurnitureRespath.."FurnitureAnchor_x="..tostring(FurnitureAnchor_x))
        end
    end
end

function HomeScene:onEnter()
    --HomeScene:RandomFurniture()
    SceneMgr.clearScene(self)
    HomeInfo.ClearLocalPlayerInfo()
    HomeInfo.clearAllSortedFamilyMembers()
    FurnitureViewMgr.clearFurnituresPool()
    HomeInfo.GetHomeInfo()
    HomeInfo.GetNeighborHomeInfo()
    
    local ChatSend = require("src.Net.Send.ChatSend")
    ChatSend.sendCG_ChangeChannel_Req({channel = "Home_"..tostring(HomeInfo.GetCurrentHomeCharID() == 0 and "yard_"..(CharInfo.getFamilyID() or 0) or HomeInfo.GetCurrentHomeCharID()),data = "{}"})
    
    HomeInfo.BroadcastHomePlayerUpdateMsg(tostring(CharInfo.getLevel()), FamilyInfo.GetMyFamilyName(), CharInfo.getNickName(), PokemonInfo.getFollowPokemonID(), CharInfo.getNickName().."的宠物", 260, 300, CharInfo.getCurfashion())
    
    if CharInfo.getFamilyID() ~= nil then
        FamilyInfo.GetFamilyCopyResetTime()
    end
end

function HomeScene:onExit()
    --print("##################Exit HomeScene")
    HomeInfo.BroadcastHomePlayerLeaveMsg(CharInfo.getNickName())
    HomeInfo.ClearLocalPlayerInfo()
    
    local ChannelTable = TownChatMgr.GetChannelTable()
    local ChatSend = require("src.Net.Send.ChatSend")
    ChatSend.sendCG_ChangeChannel_Req({channel = ChannelTable[6],data = "{}"})
    SceneMgr.onSceneExit(self)
end

return HomeScene