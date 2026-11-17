-- 通用地图生成
-- create on 2016-05-25 by hxf

local DungeonMapMgr = {}

local DungeonTestMapMgr = require("src.GameMgr.CommonDungeon.DungeonTestMapMgr")

-- 方向参数
local DIR_UP    = 1
local DIR_DOWN  = 2
local DIR_LEFT  = 3
local DIR_RIGHT = 4

-- 屏幕区大小
DungeonMapMgr.MIN_MAP_ROWS = 6
DungeonMapMgr.MIN_MAP_COLS = 5

-- 缓冲区大小
DungeonMapMgr.MAX_MAP_ROWS = 9
DungeonMapMgr.MAX_MAP_COLS = 9

-- 屏幕区中心座标
DungeonMapMgr.SCREEN_CENTER_C = 3
DungeonMapMgr.SCREEN_CENTER_R = 3

-- 缓冲区中心座标
DungeonMapMgr.BUFFER_CENTER_C = 5
DungeonMapMgr.BUFFER_CENTER_R = 5

-- 0:默认 1:缓冲区方格 2:屏幕区方格
DungeonMapMgr.cellInfo = {}

-- 玩家信息
DungeonMapMgr.playerMapPos    = {r = 1, c = 1}
DungeonMapMgr.playerScreenPos = {r = 1, c = 1}

DungeonMapMgr.playerUpdateFlag = true

DungeonMapMgr.centerResName = "LostTower/LostTowerCenterNew.csb"

DungeonMapMgr.frameItems = {}
DungeonMapMgr.backgroundItems = {}

function DungeonMapMgr.getCenter(pPos)
    local centerC, centerR

    local c, r = LtMapOption.convertToCoord(pPos)

    local cc = DungeonMapMgr.SCREEN_CENTER_C
    local cols = LtMapOption.getMapCols()
    if c <= cc then
        centerC = cc
    end
    if c > cols - cc then
        centerC = cols - cc + 1
    end
    if c > cc and c <= cols - cc then
        centerC = c
    end

    local rr = DungeonMapMgr.SCREEN_CENTER_R
    local rows = LtMapOption.getMapRows()
    if r <= rr then
        centerR = rr
    end
    if r > rows - rr then
        centerR = rows - rr
    end
    if r > rr and r <= rows - rr then
        centerR = r
    end

    return centerC, centerR
end


function DungeonMapMgr.updateScreenCells(_cells, pPos, centerC, centerR)
    local cc = DungeonMapMgr.SCREEN_CENTER_C
    local rr = DungeonMapMgr.SCREEN_CENTER_R

    for _r = 1, DungeonMapMgr.MIN_MAP_ROWS do
        for _c = 1, DungeonMapMgr.MIN_MAP_COLS do
            local c0, r0
            r0 = _r + centerR - rr
            c0 = _c + centerC - cc
            
            _cells[r0][c0] = 2
        end
    end
    _cells[centerR][centerC] = 1
end


function DungeonMapMgr.initCellsInfo(pPos, _cells)
    for _r = 1, LtMapOption.getMapRows() do
        _cells[_r] = {}
        for _c = 1, LtMapOption.getMapCols() do
            _cells[_r][_c] = 0
        end
    end
    
    local c_c, r_r = DungeonMapMgr.getCenter(pPos)
    DungeonMapMgr.updateScreenCells(_cells, pPos, c_c, r_r)
end


function DungeonMapMgr.Init()
end

local function addUI(scene)
    local advNodePool = require("src.GameMgr.Searching.advNodePool")
    
    local centerResName

    if LtMapOption.getMapType() == "ADVENTURE" then
        SearchingUIMgr.eventNodePool = advNodePool.create()
        SearchingUIMgr.tileNodePool  = advNodePool.create()
        
        SearchingUIMgr.setCenterBlock(scene)
        
        centerResName = SearchingUIMgr.centerResName
    else
        LostTowerUIMgr.eventNodePool = advNodePool.create()
        LostTowerUIMgr.tileNodePool  = advNodePool.create()
        
        local LtMapNodeMgr = require("src.GameMgr.LostTower.LtMapNodeMgr")
        LtMapNodeMgr.CreateMapWithSize(scene, DungeonMapMgr.centerResName)
        
        centerResName = LostTowerUIMgr.centerResName
    end
    
    local prepath = AdvEnvironmentMgr.getPrepath()
    local function initSlab()
        for i=1, LtMapOption.getMapSize() do
            local etype = SearchingMgr.eventInfoTable[i]
            local b_node = SearchingUIMgr.getBlockNode(i)
            local zorder = SearchingUIMgr.calcZOrderAt(i)
            b_node:setLocalZOrder( zorder ) --物品Z軸

            local g_node = SearchingUIMgr.getGroundNode(i)
            local img = prepath.."dz1.png"
            CSResourceMgr.setButtonTextureByNode(g_node,  img,  img,  img)

            local b_node = SearchingUIMgr.getBlockNode(i)
            local img_b = "Searching/empty.png"
            CSResourceMgr.setButtonTextureByNode(b_node, img_b, img_b, img_b)

            if 0 == SearchingMgr.mapInfoTable[i] then
                LtEventOption.createEvent(i)
            end
            if SearchingMgr.mapInfoTable[i] == 2 then
                if SearchingMgr.monsterDefendInfo[i] > 0 then 
                    SearchingUIMgr.monsterLock(i)
                else
                    SearchingUIMgr.coverSlab(i)
                end
            end
        end
    end

    initSlab()
    
    DungeonPlayerMgr.initPlayer()
    
    local scrollview = CSResourceMgr.getNodeByName(centerResName,"fog")
    DungeonMapMgr.scrollMapWithCellID(scrollview, SearchingMgr.playerCurrPosition)
    
    scrollview:setPositionY(scrollview:getPositionY() + 50)
end

function DungeonMapMgr.setBackground(parent, playerPos)

    local prePath
    local leftSpNumber = 3

    if LtMapOption.getMapType() == "ADVENTURE" then
        prePath = AdvEnvironmentMgr.getPrepath()
    elseif LtMapOption.getMapType() == "LOSTTOWER" then
        leftSpNumber = 2
        prePath = "CommonDungeon/"
    else
        prePath = AdvEnvironmentMgr.getPrepath()
    end

    local c_c, r_r = DungeonMapMgr.getCenter(playerPos)
    local cPos_x, cPos_y = 104*(3-1)+52, LtMapOption.getMapRows()*104+52-104*3
    
    local corners = {}
    local top_frame = {}
    local bottom_frame = {}
    local left_frame = {}
    local right_frame = {}
    
    local zorder_base = -100

    -- corners
    local topCorner_1 = display.newSprite(prePath.."tCorner_bg_0.png")
    parent:addChild(topCorner_1)
    topCorner_1:setLocalZOrder(zorder_base-1)
    topCorner_1:setAnchorPoint(0.5,0.5)
    topCorner_1:setPosition(cPos_x + 104*(0 - c_c), cPos_y - 104*(0 - r_r))
    table.insert(corners, topCorner_1)

    local topCorner_2 = display.newSprite(prePath.."tCorner_bg_"..(LtMapOption.getMapCols()%2)..".png")
    parent:addChild(topCorner_2)
    topCorner_2:setLocalZOrder(zorder_base-1)
    topCorner_2:setAnchorPoint(0.5,0.5)
    topCorner_2:setScaleX(-1.0)
    topCorner_2:setPosition(cPos_x + 104*(LtMapOption.getMapCols() + 1 - c_c), cPos_y - 104*(0 - r_r))
    table.insert(corners, topCorner_2)

    local bCorner_1 = display.newSprite(prePath.."bCorner_bg_0.png")
    parent:addChild(bCorner_1)
    bCorner_1:setLocalZOrder(zorder_base-1)
    bCorner_1:setAnchorPoint(0.5,0.5)
    bCorner_1:setPosition(cPos_x + 104*(0 - c_c), cPos_y - 104*(LtMapOption.getMapRows() + 1 - r_r))
    table.insert(corners, bCorner_1)

    local bCorner_2 = display.newSprite(prePath.."bCorner_bg_"..(LtMapOption.getMapCols()%2)..".png")
    parent:addChild(bCorner_2)
    bCorner_2:setLocalZOrder(-1)
    bCorner_2:setAnchorPoint(0.5,0.5)
    bCorner_2:setScaleX(-1.0)
    bCorner_2:setPosition(cPos_x + 104*(LtMapOption.getMapCols() + 1 - c_c), cPos_y - 104*(LtMapOption.getMapRows() + 1 - r_r))
    table.insert(corners, bCorner_2)


    -- top
    for i = 1, LtMapOption.getMapCols(), 1 do
        local sp = display.newSprite(prePath.."top_bg_"..(i%2)..".png")
        parent:addChild(sp)
        sp:setLocalZOrder(zorder_base-1)
        table.insert(top_frame, sp)
    end
    for i = 1, #top_frame do
        top_frame[i]:setAnchorPoint(0.5, 0.5)
        top_frame[i]:setPosition(cPos_x + 104*(i - c_c), cPos_y - 104*(0 - r_r))
    end

    -- bottom
    for i = 1, LtMapOption.getMapCols(), 1 do
        local sp = display.newSprite(prePath.."bottom_bg_"..(i%2)..".png")
        parent:addChild(sp)
        sp:setLocalZOrder(zorder_base-1)
        table.insert(bottom_frame, sp)
    end
    for i = 1, #bottom_frame do
        bottom_frame[i]:setAnchorPoint(0.5, 0.5)
        bottom_frame[i]:setPosition(cPos_x + 104*(i - c_c), cPos_y - 104*(LtMapOption.getMapRows() + 1 - r_r))
    end

    -- left
    for i = 1, LtMapOption.getMapRows(), 1 do
        local sp = display.newSprite(prePath.."left_bg_"..(i%leftSpNumber)..".png")
        parent:addChild(sp)
        sp:setLocalZOrder(zorder_base-1)
        table.insert(left_frame, sp)
    end
    for i = 1, #left_frame do
        left_frame[i]:setAnchorPoint(0.5, 0.5)
        left_frame[i]:setPosition(cPos_x + 104*(0 - c_c), cPos_y - 104*(i - r_r))
    end

    -- right
    for i = 1, LtMapOption.getMapRows(), 1 do
        local sp = display.newSprite(prePath.."left_bg_"..(i%leftSpNumber)..".png")
        parent:addChild(sp)
        sp:setLocalZOrder(zorder_base-1)
        table.insert(right_frame, sp)
    end
    for i = 1, #left_frame do
        right_frame[i]:setAnchorPoint(0.5, 0.5)
        right_frame[i]:setScaleX(-1.0)
        right_frame[i]:setPosition(cPos_x + 104*(LtMapOption.getMapCols() + 1 - c_c), cPos_y - 104*(i - r_r))
    end

    DungeonMapMgr.backgroundItems = {
        corners = corners      ,
        top     = top_frame    ,
        bottom  = bottom_frame ,
        left    = left_frame   ,
        right   = right_frame  ,
    }
    
end

function DungeonMapMgr.setFrame(parent, playerPos)

    local prePath
    local leftSpNumber = 3
    
    if LtMapOption.getMapType() == "ADVENTURE" then
        prePath = AdvEnvironmentMgr.getPrepath()
    elseif LtMapOption.getMapType() == "LOSTTOWER" then
        leftSpNumber = 2
        prePath = "CommonDungeon/"
    else
        prePath = AdvEnvironmentMgr.getPrepath()
    end

    local c_c, r_r = DungeonMapMgr.getCenter(playerPos)
    local cPos_x, cPos_y = 104*(3-1)+52, LtMapOption.getMapRows()*104+52-104*3
    
    local corners = {}
    local top_frame = {}
    local bottom_frame = {}
    local left_frame = {}
    local right_frame = {}
    
    -- corners
    local topCorner_1 = display.newSprite(prePath.."topCorner_0.png")
    parent:addChild(topCorner_1)
    topCorner_1:setAnchorPoint(0.5,0.5)
    topCorner_1:setPosition(cPos_x + 104*(0 - c_c), cPos_y - 104*(0 - r_r))
    table.insert(corners, topCorner_1)

    local topCorner_2 = display.newSprite(prePath.."topCorner_"..(LtMapOption.getMapCols()%2)..".png")
    parent:addChild(topCorner_2)
    topCorner_2:setAnchorPoint(0.5,0.5)
    topCorner_2:setScaleX(-1.0)
    topCorner_2:setPosition(cPos_x + 104*(LtMapOption.getMapCols() + 1 - c_c), cPos_y - 104*(0 - r_r))
    table.insert(corners, topCorner_2)
    
    local bCorner_1 = display.newSprite(prePath.."bottomCorner_0.png")
    parent:addChild(bCorner_1)
    bCorner_1:setLocalZOrder(4 * LtMapOption.getMapRows() + 1)
    bCorner_1:setAnchorPoint(0.5,0.5)
    bCorner_1:setPosition(cPos_x + 104*(0 - c_c), cPos_y - 104*(LtMapOption.getMapRows() + 1 - r_r))
    table.insert(corners, bCorner_1)

    local bCorner_2 = display.newSprite(prePath.."bottomCorner_"..(LtMapOption.getMapCols()%2)..".png")
    parent:addChild(bCorner_2)
    bCorner_2:setLocalZOrder(4 * LtMapOption.getMapRows() + 1)
    bCorner_2:setAnchorPoint(0.5,0.5)
    bCorner_2:setScaleX(-1.0)
    bCorner_2:setPosition(cPos_x + 104*(LtMapOption.getMapCols() + 1 - c_c), cPos_y - 104*(LtMapOption.getMapRows() + 1 - r_r))
    table.insert(corners, bCorner_2)
    
    
    -- top
    for i = 1, LtMapOption.getMapCols(), 1 do
        local sp = display.newSprite(prePath.."top_"..(i%2)..".png")
        parent:addChild(sp)
        table.insert(top_frame, sp)
    end
    for i = 1, #top_frame do
        top_frame[i]:setAnchorPoint(0.5, 0.5)
        top_frame[i]:setPosition(cPos_x + 104*(i - c_c), cPos_y - 104*(0 - r_r))
    end
    
    -- bottom
    for i = 1, LtMapOption.getMapCols(), 1 do
        local sp = display.newSprite(prePath.."bottom_"..(i%2)..".png")
        parent:addChild(sp)
        sp:setLocalZOrder(4 * LtMapOption.getMapRows() + 1)
        table.insert(bottom_frame, sp)
    end
    for i = 1, #bottom_frame do
        bottom_frame[i]:setAnchorPoint(0.5, 0.5)
        bottom_frame[i]:setPosition(cPos_x + 104*(i - c_c), cPos_y - 104*(LtMapOption.getMapRows() + 1 - r_r))
    end
    
    -- left
    for i = 1, LtMapOption.getMapRows(), 1 do
        local sp = display.newSprite(prePath.."left_"..(i%leftSpNumber)..".png")
        parent:addChild(sp)
        sp:setLocalZOrder(4 * LtMapOption.getMapRows())
        table.insert(left_frame, sp)
    end
    for i = 1, #left_frame do
        left_frame[i]:setAnchorPoint(0.5, 0.5)
        left_frame[i]:setPosition(cPos_x + 104*(0 - c_c), cPos_y - 104*(i - r_r))
    end
    
    -- right
    for i = 1, LtMapOption.getMapRows(), 1 do
        local sp = display.newSprite(prePath.."left_"..(i%leftSpNumber)..".png")
        parent:addChild(sp)
        sp:setLocalZOrder(4 * LtMapOption.getMapRows())
        table.insert(right_frame, sp)
    end
    for i = 1, #right_frame do
        right_frame[i]:setAnchorPoint(0.5, 0.5)
        right_frame[i]:setScaleX(-1.0)
        right_frame[i]:setPosition(cPos_x + 104*(LtMapOption.getMapCols() + 1 - c_c), cPos_y - 104*(i - r_r))
    end
    
    DungeonMapMgr.frameItems = {
        corners = corners      ,
        top     = top_frame    ,
        bottom  = bottom_frame ,
        left    = left_frame   ,
        right   = right_frame  ,
    }
end


local function clipMap(maxCols, maxRows)
    
end

function DungeonMapMgr.creareDungeon(params)

    SearchingMapMgr.currAdventure = params.adventureID
    DungeonTestMapMgr.xmlStartID  = params.xmlStartID
    

    LtMapOption.setMapType(params.mapType)
    LtMapOption.setMapSize(params.mapRows, params.mapCols)
    
    local envType = params.envType or 2
    AdvEnvironmentMgr.initEnvironmentParams(envType)
    
    -- make data
    local data = {}
    for i = 1, LtMapOption.getMapSize() do
        local col, row = LtMapOption.convertToCoord(i)

        local var = {}
        var["sceneID"] = i
        var["flo"]     = 1
        var["eventID"] = 0
        var["x"]       = row
        var["y"]       = col
        var["type"]    = 0

        data[i] = var
    end
    SearchingMgr.playerCurrPosition = 1
    SearchingMgr.floors = 1
    SearchingMapMgr.currFloor = 1
    
    LostTowerMgr.STATE = LostTowerMgr._CLOSED
    LostTowerMgr.createMap(data)
    
    addUI(SceneMgr.getRunningScene)
    
    DungeonTestMapMgr.addTestMenu(SceneMgr.getRunningScene)
    
end

local function scrollMapTo(scrollview, px, py, time)
    px = px or 0
    py = py or 0
    if time<=0 then
        scrollview:jumpToPercentHorizontal(px)
        scrollview:jumpToPercentVertical(py)
    else
--        transition.stopTarget(scrollview)
--        scrollview:scrollToPercentBothDirection({x=px, y=py}, time, true)
        
        local container = scrollview:getInnerContainer()
        
        local minY = scrollview:getContentSize().height - scrollview:getInnerContainerSize().height
        local h = - minY
        local w = scrollview:getInnerContainerSize().width - scrollview:getContentSize().width
        transition.moveTo(container, {x = -(px * w / 100), y = minY + py * h  / 100, time = time})
    end
end

function DungeonMapMgr.scrollMapWithCellID(scrollview, cellID, time)
    time = time or 0.25
    
    local posx, posy = SearchingUIMgr.getGroundNode(cellID):getPosition()

    local scrollwidth = scrollview:getContentSize().width
    local scrollheight = scrollview:getContentSize().height
    local mapSize = scrollview:getInnerContainerSize()
    local mapScale = 1.0

    local diffx = posx*mapScale-scrollwidth/2
    local diffw = mapSize.width*mapScale-scrollwidth
    local ratex
    if diffw ~= 0 then
        ratex = diffx/diffw*100
        if ratex<0 then
            ratex = 0
        elseif ratex>100 then
            ratex = 100
        end
    end
    local diffy = mapSize.height*mapScale-posy*mapScale-scrollheight/2
    local diffh = mapSize.height*mapScale-scrollheight
    local ratey
    if diffh ~= 0 then
        ratey = diffy/diffh*100
        if ratey<0 then
            ratey = 0
        elseif ratey>100 then
            ratey = 100
        end
    end

    scrollMapTo(scrollview, ratex, ratey, time)
end

function DungeonMapMgr.checkScrollNew(scrollview, nextID)
    
    local playerx, playery = SearchingUIMgr.getGroundNode(SearchingMgr.playerCurrPosition):getPosition()
    local nextx, nexty = SearchingUIMgr.getGroundNode(nextID):getPosition()
    
    local posx, posy = SearchingUIMgr.getGroundNode(nextID):getPosition()  -- (nextx+playerx)/2, (nexty+playery)/2
    
    local scrollwidth = scrollview:getContentSize().width
    local scrollheight = scrollview:getContentSize().height
    local mapSize = scrollview:getInnerContainerSize()
    local mapScale = 1.0
    
    local diffx = posx*mapScale-scrollwidth/2
    local diffw = mapSize.width*mapScale-scrollwidth
    local ratex
    if diffw ~= 0 then
        ratex = diffx/diffw*100
        if ratex<0 then
            ratex = 0
        elseif ratex>100 then
            ratex = 100
        end
    end
    local diffy = mapSize.height*mapScale-posy*mapScale-scrollheight/2
    local diffh = mapSize.height*mapScale-scrollheight
    local ratey
    if diffh ~= 0 then
        ratey = diffy/diffh*100
        if ratey<0 then
            ratey = 0
        elseif ratey>100 then
            ratey = 100
        end
    end
    
    scrollMapTo(scrollview, ratex, ratey, 0.25)
    
    DungeonMapMgr.playerUpdateFlag = true
end

function DungeonMapMgr.checkScroll(nextID)
    if LtMapOption.getMapType() == "ADVENTURE" then
        DungeonMapMgr.playerUpdateFlag = true
        
        local scrollview = CSResourceMgr.getNodeByName(SearchingUIMgr.centerResName,"fog")
        DungeonMapMgr.checkScrollNew(scrollview, nextID)
        return
    elseif LtMapOption.getMapType() == "LOSTTOWER" then
        DungeonMapMgr.playerUpdateFlag = true

        local scrollview = CSResourceMgr.getNodeByName(LostTowerUIMgr.centerResName,"fog")
        DungeonMapMgr.checkScrollNew(scrollview, nextID)
        return
    end
end

return DungeonMapMgr