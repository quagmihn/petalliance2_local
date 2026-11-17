--created 2015-07-23

require("src.GameMgr.GameInit")
require("src.GameMgr.Searching.Point")
require("src.GameMgr.Searching.Astar")

local SearchingScene = class("SearchingScene", function()
    return display.newScene("SearchingScene")
end)

function SearchingScene:ctor()
    LtMapOption.setMapType("ADVENTURE")
    --LtMapOption.setMapSize(6, 5)
    
    if SearchingMgr.isAdventureEnd() then
        SearchingMapMgr.initAdventure()
    end

    --UI设置表清空
    SearchingUIMgr.clear()
    
    SearchingUIMgr.initEnvironmentParams()
    AdvEnvironmentMgr.initEnvironmentParams()

    SearchingMapMgr.createSearchingMap(self)
    
    if SceneMgr.previousScene == "BattleScene" then
        SearchingMgr.canMove = false
        self:performWithDelay(function()
            SearchingMgr.checkBattleResult(self)
            SearchingMgr.canMove = true
        end,0.1)
    end
    
    self:performWithDelay(function()
        if SearchingMgr.tutorialFunc then
            SearchingMgr.tutorialFunc(function()
            end)
        end
    end,0.1)
    
    SearchingMgr.SCH_GLOBAL_CHECK()

end

function SearchingScene:test_polygon(scene)

    local points = {}
    
    local sp = display.newSprite("Searching/background_0.png")
    scene:addChild(sp)
    sp:setPosition(320, 480)


    points = {}
    points[1] = cc.p(500, 300)
    points[2] = cc.p(600, 300)
    points[3] = cc.p(550, 400)
    local dnode0 = cc.DrawNode:create()
    sp:addChild(dnode0)  --add to parent first, or it will not show
    dnode0:drawTriangle(points[1],points[2],points[3],cc.c4f(1, 0, 0, 1))

    local quarLB = cc.p(display.cx/2, display.cy/2)
    local quarRT = cc.p(display.width - quarLB.x, display.height - quarLB.y)
    local dnode = cc.DrawNode:create()
    sp:addChild(dnode)
    dnode:drawLine(quarLB, quarRT, cc.c4f(0, 0, 1, 1))
    
    local origin = cc.p(320,480)
    points = {}
    points[1] = cc.p(origin.x+100, origin.y+200)
    points[2] = cc.p(origin.x+100, origin.y+100)
    points[3] = cc.p(origin.x+200, origin.y+100)
    points[4] = cc.p(origin.x+300, origin.y+150)
    
    local drawNode5 = cc.NVGDrawNode:create()
    sp:addChild(drawNode5)
    drawNode5:drawPolygon(points, 4, true, cc.c4f(0, 1, 1, 1))
    --drawNode5:setRotation(10)
    
    points = {}
    points[1] = cc.p(500, 400)
    points[2] = cc.p(600, 400)
    points[3] = cc.p(550, 500)
    local drawNode11 = cc.NVGDrawNode:create()
    sp:addChild(drawNode11)
    drawNode11:drawSolidPolygon(points, 3, cc.c4f(0.5, 0.5, 0, 1))
    
end

function SearchingScene:initUI(scene)

    local sp = display.newSprite("Searching/background_0.png")
    scene:addChild(sp)
    sp:setPosition(320, 480)
    
    
    --TODO CLIPPINGNODE
    local shadow = display.newSprite("Searching/shadow.png")  -- 底板
    
    local stencil = cc.Node:create()  -- 模板
    local mask = display.newSprite("Searching/ban.png")
    mask:setPosition(0, 0)
    local mask2 = display.newSprite("Searching/ban.png")
    mask2:setPosition(50, 50)
    mask2:setRotation(45)
    stencil:addChild(mask)
    stencil:addChild(mask2)
    
    local clippingNode = cc.ClippingNode:create(stencil)
    clippingNode:addChild(shadow)
    clippingNode:setStencil(stencil)
    clippingNode:setInverted(true)
    clippingNode:setAlphaThreshold(0.9)
    clippingNode:setPosition(320, 480)
    sp:addChild(clippingNode)
    
    local function onTouchBegan(touch, event)
        local location = touch:getLocation()
        mask:setPosition(location.x - 320, location.y - 480)
        print(location.x, location.y)
    end 
    
    local function onTouchEnded(touch, event)
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    -- 注册两个回调监听方法  
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = sp:getEventDispatcher()-- 时间派发器  
    -- 绑定触摸事件到层当中  
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, sp)
 
end

function SearchingScene:testUI(scene)

    local blockwidth = 104
    local blockheight = 104

    local c = CSResourceMgr.createRes(scene, "Searching/centerBlock_bak_bak.csb")
    
    local k = CSResourceMgr.seekNodeByName(c,"kuang")
    k:loadTexture("Searching/env/cd/kuang.png")
    
    local f = CSResourceMgr.seekNodeByName(c,"fog")
    local g = CSResourceMgr.seekNodeByName(c,"ground")
    local f_sample = CSResourceMgr.seekNodeByName(f,"blockSample")
    local g_sample = CSResourceMgr.seekNodeByName(g,"groundSample")

    f:setPosition(60, 235)
    g:setPosition(60, 225)
    
    local blocks = {}
    local grounds = {}
    
    for i=1, 30 do
        local f_ = f_sample:clone()
        f_:removeFromParent(true)
        f_:addTo(f)
        f_:setContentSize(104, 138)
        f_:setPosition(blockwidth/2+blockwidth*((i-1)%5), 639+52-(blockheight*math.ceil(i/5)))
        table.insert(blocks, f_)
        

        local g_ = g_sample:clone()
        g_:removeFromParent(true)
        g_:addTo(g)
        g_:setContentSize(114, 145)
        g_:setPosition(blockwidth/2+blockwidth*((i-1)%5), (624+52-blockheight*math.ceil(i/5)))
        table.insert(grounds, g_)
    end
    
end

function SearchingScene:onEnter()
    SceneMgr.clearScene(self)
end

function SearchingScene:onExit()
    SceneMgr.onSceneExit(self)
end

return SearchingScene
