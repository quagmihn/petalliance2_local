local MiniMapMgr = {}

MiniMapMgr.status = 0

local curRes = ""
local curLayerRes = ""
local headTagStr = ""

local charGaf = nil

local curSelectedPoint = 0
local mapInfo = {}
local mapSize = {}
local mapScale = 1
local mapOpacity = 255

function MiniMapMgr.Init()
    --[[
    MiniMapMgr.status = 0
    
    curRes = "UI/MiniMap/miniMapBtn.csb"
    curLayerRes = "UI/MiniMap/miniMapLayer.csb"
    headTagStr = "miniMap's head"
    curSelectedPoint = 0
    
    charGaf = nil
    
    mapInfo = {
        {"净土", "简介：韩寒会画画后悔画韩红，韩寒会画画后悔画韩红。", "TestScene"}, 
        {"天星宫殿", "简介：无", "MainScene"}, 
        {"国道301", "简介：无", "ForestScene"},
        {"水路208", "简介：无", "WaterScene"},
        {"大操园", "简介：无", "SecondScene"},
        {"净土副本", "简介：无", "TownScene"}
              }
    mapSize = {}
    mapScale = UserSettings.get("Scale",5) or 1
    mapOpacity = UserSettings.get("Opacity",5) or 255*0.8]]
end

function MiniMapMgr.addMiniMapUI(scene)
    if not SystemOptionsMgr.getOption(4) then
        print("玩家设置不打开地图按钮")
        return false
    end
    
    MiniMapMgr.setLocalOptions()
    curSelectedPoint = 0
    
    local miniBtn = CSResourceMgr.createRes(scene, curRes)
    miniBtn:setLocalZOrder(11)
    CSResourceMgr.createRes(scene, curLayerRes):setLocalZOrder(11)
    CocosModuleMgr.setEdgeDistance(miniBtn, nil, 0, 0, nil, true, 0.5)
    CSResourceMgr.setRelativePosition(curLayerRes, 320, 480)
    
    MiniMapMgr.status = 0
    
    local scrollview = CSResourceMgr.getNodeByName(curLayerRes, "map")
    local scrollwidth = scrollview:getContentSize().width
    local scrollheight = scrollview:getContentSize().height
    mapSize = scrollview:getInnerContainerSize()
    scrollview:addEventListener(function(sender, state)
    end)
    CSResourceMgr.clickEventBinding(curRes, "Button", function()
        MiniMapMgr.showMiniMapUI()
        ChatUIMgr.hideChatUI()
        for var=1, table.getn(mapInfo) do
            if SceneMgr.currentScene==mapInfo[var][3] then
                local diffx = mapInfo[var][4].x*mapScale-scrollwidth/2
                local diffw = mapSize.width*mapScale-scrollwidth
                local ratex = diffx/diffw*100
                if ratex<0 then
                    ratex = 0
                elseif ratex>100 then
                    ratex = 100
                end
                local diffy = mapSize.height*mapScale-mapInfo[var][4].y*mapScale-scrollheight/2
                local diffh = mapSize.height*mapScale-scrollheight
                local ratey = diffy/diffh*100
                if ratey<0 then
                    ratey = 0
                elseif ratey>100 then
                    ratey = 100
                end
                MiniMapMgr.scrollMapTo(ratex, ratey)
                --print("\ndiffx="..diffx..",diffw="..diffw..",diffy="..diffy..",diffh="..diffh)
        	end
        end
    end)
    CSResourceMgr.clickEventBinding(curLayerRes, {"frame", "Button"}, function()
        MiniMapMgr.hideMiniMapUI()
    end)
    CSResourceMgr.clickEventBinding(curLayerRes, {"frame", "fly"}, function()
        DialogBoxMgr.showSmallDialogBox(scene, 2, CocosModuleMgr.createStringWithFormat({"是否使用飞天技能，飞到地图-<1>？", mapInfo[curSelectedPoint][1]}), function()
            MiniMapMgr.setLocalOptions()
            SceneMgr.mapEnterType = 3
            SceneMgr.replaceScene(scene, mapInfo[curSelectedPoint][3])
        end)
    end)
    CSResourceMgr.clickEventBinding(curLayerRes, {"frame", "cloud"}, function()
        mapScale = mapScale + 0.2
        MiniMapMgr.setMapScale(mapScale)
        CSResourceMgr.setButtonEnabled(curLayerRes, {"frame", "star"}, true)
        if mapScale>=3 then
            CSResourceMgr.setButtonEnabled(curLayerRes, {"frame", "cloud"}, false)
        end
        --local node = CSResourceMgr.getNodeByName(curLayerRes, {"map", "worldmap", "test_1"})
        --local pos = node:getPositionX()
    end)
    CSResourceMgr.clickEventBinding(curLayerRes, {"frame", "star"}, function()
        mapScale = mapScale - 0.2
        MiniMapMgr.setMapScale(mapScale)
        CSResourceMgr.setButtonEnabled(curLayerRes, {"frame", "cloud"}, true)
        if mapScale<=0.8 then
            CSResourceMgr.setButtonEnabled(curLayerRes, {"frame", "star"}, false)
        end
    end)
    
    for var=1, table.getn(mapInfo) do
        local node = CSResourceMgr.getNodeByName(curLayerRes, {"map", "worldmap", "test_"..var})
        local px = node:getPositionX()
        local py = node:getPositionY()
        mapInfo[var][4] = {x=px, y=py}
        --当前所处地图加特效并显示信息
        if SceneMgr.currentScene==mapInfo[var][3] then
            CocosModuleMgr.showShiningToNode(node, 2)
        
            --添加人物形象
            local nodeSize = node:getContentSize()
            local nodeScale = node:getScaleX()
            charGaf = AnimationMgr.createAni(node, CharInfo.getAvatar(), nodeSize.width*nodeScale/2, 450, headTagStr)
            charGaf:setScale(0.5, 0.5)
            AnimationMgr.playAni(CharInfo.getAvatar(), "idle", true, headTagStr)
            
            CSResourceMgr.setButtonEnabled(curLayerRes, {"frame", "fly"}, false)
            curSelectedPoint = var
            CSResourceMgr.setLabelString(curLayerRes, {"frame", "diban", "info"}, 
                CocosModuleMgr.createStringWithFormat({"<1> - <2>", mapInfo[curSelectedPoint][1], mapInfo[curSelectedPoint][2]}), "", 
                CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
            CSResourceMgr.setLabelMaxWidth(curLayerRes, {"frame", "diban", "info"}, 370)
        end
        --地图按钮点击事件
        CSResourceMgr.clickEventBinding(curLayerRes, {"map", "worldmap", "test_"..var}, function()
            if curSelectedPoint==var then
            	return false
            end
            if SceneMgr.currentScene~=mapInfo[curSelectedPoint][3] then
                CocosModuleMgr.hideShiningToNode(CSResourceMgr.getNodeByName("UI/MiniMap/miniMapLayer.csb", {"map", "worldmap", "test_"..curSelectedPoint}))
            end
            local node = CSResourceMgr.getNodeByName(curLayerRes, {"map", "worldmap", "test_"..var})      
            CSResourceMgr.setButtonEnabled(curLayerRes, {"frame", "fly"}, true)
            curSelectedPoint = var
            CSResourceMgr.setLabelString(curLayerRes, {"frame", "diban", "info"}, 
                CocosModuleMgr.createStringWithFormat({"<1> - <2>", mapInfo[curSelectedPoint][1], mapInfo[curSelectedPoint][2]}), "", 
                CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
            CSResourceMgr.setLabelMaxWidth(curLayerRes, {"frame", "diban", "info"}, 370)
            if SceneMgr.currentScene==mapInfo[var][3] then
                CSResourceMgr.setButtonEnabled(curLayerRes, {"frame", "fly"}, false)
            else
                CocosModuleMgr.showShiningToNode(node, 1)
            end
        end)
    end
    
    local minAlpha = 128
    local rangeAlpha = 255-minAlpha
    local slider = CSResourceMgr.getNodeByName(curLayerRes, {"frame", "slider"})
    slider:setPercent((mapOpacity-minAlpha)*100/rangeAlpha)
    slider:addEventListener(function(sender, state)
        CSResourceMgr.getNodeByName(curLayerRes, {"map", "worldmap"}):setOpacity(slider:getPercent()/100*rangeAlpha+minAlpha)
        mapOpacity = slider:getPercent()/100*rangeAlpha+minAlpha
    end)
    
    CSResourceMgr.setButtonEnabled(curLayerRes, {"frame"}, false)
    CSResourceMgr.getNodeByName(curLayerRes, {"map", "worldmap"}):setOpacity(mapOpacity)
    MiniMapMgr.setMapScale(mapScale)
    if mapScale<=0.8 then
        CSResourceMgr.setButtonEnabled(curLayerRes, {"frame", "star"}, false)
    end
end

function MiniMapMgr.setLocalOptions()
    UserSettings.set({Opacity = mapOpacity, Scale = mapScale}, 5)
end

function MiniMapMgr.remove()
    if MiniMapMgr.status==1 then
        CSResourceMgr.removeCSObjectByTag(curRes)
        CSResourceMgr.playActionWithCallback(curLayerRes, 50, 60, 1, function()
            CSResourceMgr.removeCSObjectByTag(curLayerRes)
        end)
    else
        CSResourceMgr.removeCSObjectByTag(curLayerRes)
        CSResourceMgr.playActionWithCallback(curRes, 15, 25, 1, function()
            CSResourceMgr.removeCSObjectByTag(curRes)
        end)
    end
    MiniMapMgr.status = 0
    AnimationMgr.removeGafObjectByTag(CharInfo.getAvatar(), headTagStr)
end

function MiniMapMgr.showMiniMapUI()
    if MiniMapMgr.status ~= 1 then
        CSResourceMgr.playAction(curRes, 15, 25, false)
        CSResourceMgr.playAction(curLayerRes, 0, 10, false)
        MiniMapMgr.status = 1
    end
end

function MiniMapMgr.hideMiniMapUI()
    if MiniMapMgr.status ~= 0 then
        CSResourceMgr.playAction(curRes, 0, 10, false)
        CSResourceMgr.playAction(curLayerRes, 50, 60, false)
        MiniMapMgr.status = 0
        MiniMapMgr.setLocalOptions()
    end    
end

function MiniMapMgr.setMapScale(s)
    local scrollview = CSResourceMgr.getNodeByName(curLayerRes, "map")
    local size = mapSize
    scrollview:setInnerContainerSize({width=size.width*s, height=size.height*s})
    local mapLayer = CSResourceMgr.getNodeByName(curLayerRes, {"map", "worldmap"})
    mapLayer:setScale(s, s)
    mapLayer:setPosition(0, size.height*s)
end

---地图滚动至某处
--@param px float 填0-100之间
--@param py float 填0-100之间
function MiniMapMgr.scrollMapTo(px, py)
    local scrollview = CSResourceMgr.getNodeByName(curLayerRes, "map")
    scrollview:jumpToPercentHorizontal(px)
    scrollview:jumpToPercentVertical(py)
    print("now map scroll to "..px..", "..py)
    --scrollview:scrollToPercentHorizontal(px,1,true)
    --scrollview:scrollToPercentVertical(py,1,true)
end

return MiniMapMgr