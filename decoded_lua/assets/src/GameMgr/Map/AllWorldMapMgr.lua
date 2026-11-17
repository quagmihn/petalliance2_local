local AllWorldMapMgr = {}

local resName = ""
local resNameBG = ""
local worldTable = {}
local mapScale = 1
local playerAniNode = nil
local scrollwidth = 0
local scrollheight = 0
local playerPosMapX = 0
local playerPosMapY = 0
local playerParent = nil

function AllWorldMapMgr.Init()
    resName = "Map/WorldMap/AllWorldMapLayer.csb"
    resNameBG = "Pet/Formation/FormationBG.csb"
    worldTable = {}
    playerAniNode = nil
    scrollwidth = 0
    scrollheight = 0
    playerPosMapX = 0
    playerPosMapY = 0
    playerParent = nil
end

function AllWorldMapMgr.show(scene)
    SceneMgr.setMapVisible(false)
    local function loadBG()
        local bgLayer = CSResourceMgr.createRes(scene, resNameBG)
        bgLayer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resNameBG, 320, 480)
        bgLayer:setOpacity(0)
        transition.fadeIn(bgLayer, {time=0.3})
    end
    
    local function loadCSB()
        local layer = CSResourceMgr.createRes(scene, resName)
        layer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resName, 320, 480)
        layer:setVisible(false)
        --...
        local sizediff = CocosModuleMgr.getScreenSizeDiff()
        local scrollview = CSResourceMgr.getNodeByName(resName, "scrollview")
        scrollwidth = scrollview:getContentSize().width
        local oringinheight = scrollview:getContentSize().height
        scrollheight = oringinheight+sizediff
        scrollview:setContentSize(scrollwidth, scrollheight)
        mapSize = scrollview:getInnerContainerSize()
        local sposy = scrollview:getPositionY()
        scrollview:setPositionY(sposy+sizediff/2)   
        local parent = CSResourceMgr.getNodeByName(resName, "map")
        local bg = CSResourceMgr.getNodeByName(resName, "bg")
        local bsize = bg:getContentSize()
        bg:setContentSize(bsize.width, bsize.height+sizediff)
        local bposy = bg:getPositionY()
        bg:setPositionY(bposy+sizediff/2)   
        local title = CSResourceMgr.getNodeByName(resName, "title")
        local tposy = title:getPositionY()
        title:setPositionY(tposy+sizediff) 
        CSResourceMgr.setLabelColor(resName, "title", {r=160,g=235,b=250,a=255})
        CSResourceMgr.setLabelString(resName, "title", "AllWorldMap", "", {r=37,g=54,b=75,a=255})
        local close = CSResourceMgr.getNodeByName(resName, "close")
        local cposy = close:getPositionY()
        close:setPositionY(cposy+sizediff)

        CSResourceMgr.clickEventBinding(resName, "close", function()
            AllWorldMapMgr.hide()
        end)
    end

    local function playCSB()
        CSResourceMgr.getCsbObj(resName):setVisible(true)
        CocosModuleMgr.showUIAnimation(CSResourceMgr.getCsbObj(resName), "up")
        AllWorldMapMgr.resetAllWorld()
    end

    local funcTable = {loadBG, loadCSB, playCSB}
    UnblockLoader.load(funcTable, "AllWorldMapMgr.show")
end

function AllWorldMapMgr.hide()
    UnblockLoader.cancel("AllWorldMapMgr.show")
    worldTable = {}
    scrollwidth = 0
    scrollheight = 0
    playerAniNode = nil
    local player = PlayerAnimeMgr.createPlayer(playerParent, {gender=CharInfo.getSex(), 
            x=playerPosMapX,y=playerPosMapY,skin=CharInfo.getCurfashion()},PlayerAnimeMgr.SELF_TAG_STRING)
    playerPosMapX = 0
    playerPosMapY = 0
    playerParent = nil
    SceneMgr.setMapVisible(true)
    CSResourceMgr.removeCSObjectByTag(resName)
    CSResourceMgr.removeCSObjectByTag(resNameBG)
end

---地图滚动至某处
--@param px float 填0-100之间
--@param py float 填0-100之间
function AllWorldMapMgr.scrollMapTo(px, py, time)
    local scrollview = CSResourceMgr.getNodeByName(resName, "scrollview")
    --scrollview:jumpToPercentHorizontal(px)
    --scrollview:jumpToPercentVertical(py)
    --print("now map scroll to "..px..", "..py)
    if time<=0 then
        scrollview:jumpToPercentHorizontal(px)
        scrollview:jumpToPercentVertical(py)
    else
        scrollview:scrollToPercentBothDirection({x=px, y=py}, time, true)
    end
end

function AllWorldMapMgr.resetAllWorld()
    local funcTable = {}
    local worldNum = WorldMapInfo.getWorldNum()
    local parent = CSResourceMgr.getNodeByName(resName, "map")
    local charLock = CharInfo.get().maplock
    --设置地图按钮
    for i=1,worldNum do
        -- table.insert(funcTable,function()
            local worldMapInfo = WorldMapInfo.getWorldMapInfoByID(i)
            local world = CSResourceMgr.getNodeByName(resName, "world"):clone()
            worldTable[i] = world
            CSResourceMgr.setButtonTextureByNode(world, worldMapInfo.mapResPath, worldMapInfo.mapResPath, worldMapInfo.mapResPath)
            world:setPosition(worldMapInfo.mapPosX,worldMapInfo.mapPosY)
            world:setVisible(true)
            world:addTo(parent)
            local size = world:getContentSize()
            local world2 = CSResourceMgr.seekNodeByName(world,"world2")
            CSResourceMgr.setSpriteTextureByNode(world2, worldMapInfo.mapResPath)
            world2:setPosition(size.width/2,size.height/2)
            local worldName = CSResourceMgr.seekNodeByName(world,"worldName")
            CSResourceMgr.setLabelStringByNode(worldName,worldMapInfo.name,{r=88,g=124,b=110,a=255,w=2})
			if LuaSqlite.LANG_TYPE ~= 1 and LuaSqlite.LANG_TYPE ~= 2 then
				worldName:setFontSize(worldName:getFontSize()-2)
			end
            local unlockID = tonumber(worldMapInfo.unlockID) or 0
            if i == 6 then
                local sp = display.newSprite("Map/WholeWorldIcon/ysj_1.png")
                sp:addTo(world)
                sp:setPosition(120,90)
            end
            if i == 7 then
                local sp = display.newSprite("Map/WholeWorldIcon/dxsj_1.png")
                sp:addTo(world)
                sp:setPosition(100,-45)
            end
            if charLock>=unlockID then
                CSResourceMgr.clickEventBindingByNode(world, function()
                    CocosModuleMgr.setScreenTouch(false)
                    world2:setOpacity(180)
                    transition.scaleTo(world2, {scale=1.2, time=0.5})
                    transition.scaleTo(world, {scale=0.9, time=0.5})
                    transition.fadeOut(world2, {time = 0.5})
                    world:setColor({r=255,g=250,b=128})
                    world:tintTo(0.5, 255, 255, 255)
                    world:performWithDelay(function()
                        world2:setVisible(false)
                        local curPosx = playerAniNode:getPositionX()
                        local terPosx = worldMapInfo.mapPosX
                        local curPosy = playerAniNode:getPositionY()
                        local terPosy = worldMapInfo.mapPosY
                        local curScalex = math.abs(playerAniNode:getScaleX())
                        local curScaley = math.abs(playerAniNode:getScaleY())
                        local distance = math.sqrt(math.pow(terPosx-curPosx, 2)+math.pow(terPosy-curPosy, 2))
                        local movetime = distance/(WorldMapMgr.DEFAULT_MOVE_SPEED*2)
                        if terPosx-curPosx<0 then
                            playerAniNode:setScale(-curScalex, curScaley)
                        else
                            playerAniNode:setScale(curScalex, curScaley)
                        end
                        transition.moveBy(playerAniNode, {x=terPosx-curPosx, y=terPosy-curPosy, time=movetime})
                        PlayerAnimeMgr.playAni(PlayerAnimeMgr.SELF_TAG_STRING, "fly", true)
                        checkScroll(playerAniNode, 0.5)
                        for i=0,movetime/0.5,0.5 do
                            parent:performWithDelay(function()
                                checkScroll(playerAniNode, 0.5)
                            end, i)
                        end
                        world:performWithDelay(function()
                            AllWorldMapMgr.hide()
                            WorldMapMgr.setMapIDandPos(i,1)
                            SceneMgr.replaceScene(scene, "MainScene")
                        end, movetime)
                    end,0.5)
                end)
            else
                if i == 6 or i == 7 then
                    world:setVisible(false)
                else
                    local lock = CSResourceMgr.seekNodeByName(world,"lock")
                    lock:setVisible(true)
                    lock:setPosition(size.width/2,size.height/2)
                    CSResourceMgr.setButtonEnabledByNode(world, false)
                end
            end
        -- end)
    end

    --设置千层塔按钮
    -- table.insert(funcTable,function()
        local tower = CSResourceMgr.getNodeByName(resName, "tower"):clone()
        tower:addTo(parent)
        local size = tower:getContentSize()
        local unlockID = SystemInfo.getGlobalConfigAddInfoByID(25000).values[1]
        local towerPosX = SystemInfo.getGlobalConfigAddInfoByID(25001).values[1]
        local towerPosY = SystemInfo.getGlobalConfigAddInfoByID(25002).values[1]
        tower:setPosition(towerPosX,towerPosY)
        local tower2 = CSResourceMgr.seekNodeByName(tower,"tower2")
        local towerName = CSResourceMgr.seekNodeByName(tower,"towerName")
        tower2:setPosition(size.width/2,size.height/2)
        CSResourceMgr.setLabelStringByNode(towerName,"worldqct",{r=88,g=124,b=110,a=255,w=2})
        if charLock>=unlockID then
            CSResourceMgr.clickEventBindingByNode(tower, function()
                CocosModuleMgr.setScreenTouch(false)
                tower2:setOpacity(180)
                transition.scaleTo(tower2, {scale=1.2, time=0.5})
                transition.scaleTo(tower, {scale=0.9, time=0.5})
                transition.fadeOut(tower2, {time = 0.5})
                tower:setColor({r=255,g=250,b=128})
                tower:tintTo(0.5, 255, 255, 255)
                tower:performWithDelay(function()
                    tower2:setVisible(false)
                    local curPosx = playerAniNode:getPositionX()
                    local terPosx = 444
                    local curPosy = playerAniNode:getPositionY()
                    local terPosy = 594
                    local curScalex = math.abs(playerAniNode:getScaleX())
                    local curScaley = math.abs(playerAniNode:getScaleY())
                    local distance = math.sqrt(math.pow(terPosx-curPosx, 2)+math.pow(terPosy-curPosy, 2))
                    local movetime = distance/(WorldMapMgr.DEFAULT_MOVE_SPEED*2)
                    if terPosx-curPosx<0 then
                        playerAniNode:setScale(-curScalex, curScaley)
                    else
                        playerAniNode:setScale(curScalex, curScaley)
                    end
                    transition.moveBy(playerAniNode, {x=terPosx-curPosx, y=terPosy-curPosy, time=movetime})
                    PlayerAnimeMgr.playAni(PlayerAnimeMgr.SELF_TAG_STRING, "fly", true)
                    checkScroll(playerAniNode, 0.5)
                    for i=0,movetime/0.5,0.5 do
                        parent:performWithDelay(function()
                            checkScroll(playerAniNode, 0.5)
                        end, i)
                    end
                    tower:performWithDelay(function()
                        LostTowerMgr.sendCreateReq(function()
                            SceneMgr.replaceScene(SceneMgr.getRunningScene, "LostTowerScene")
                        end)
                    end, movetime)
                end,0.5)
            end)
        else
            local lock = CSResourceMgr.seekNodeByName(tower,"lock")
            lock:setVisible(true)
            lock:setPosition(size.width/2,size.height/2)
            CSResourceMgr.setButtonEnabledByNode(tower, false)
        end
    -- end)

    --这个方法抄袭大地图作者
    function checkScroll(node, time)
        if node then
            local posx = node:getPositionX()
            local posy = node:getPositionY()
            local diffx = posx*mapScale-scrollwidth/2
            local diffw = mapSize.width*mapScale-scrollwidth
            local ratex = diffx/diffw*100
            if ratex<0 then
                ratex = 0
            elseif ratex>100 then
                ratex = 100
            end
            local diffy = mapSize.height*mapScale-posy*mapScale-scrollheight/2
            local diffh = mapSize.height*mapScale-scrollheight
            local ratey = diffy/diffh*100
            --ratey = ratey + 3/mapScale/mapScale*(oringinheight/scrollheight)        --这个大地图往上偏
            if ratey<0 then
                ratey = 0
            elseif ratey>100 then
                ratey = 100
            end
            AllWorldMapMgr.scrollMapTo(ratex, ratey, time)
            --print("\ndiffx="..diffx..",diffw="..diffw..",diffy="..diffy..",diffh="..diffh)
        end
    end

    -- table.insert(funcTable,function()
        playerParent = PlayerAnimeMgr.getPlayer(PlayerAnimeMgr.SELF_TAG_STRING):getParent()
        playerPosMapX,playerPosMapY = PlayerAnimeMgr.getPlayer(PlayerAnimeMgr.SELF_TAG_STRING):getPosition()
        local curWorldMapInfo = WorldMapInfo.getWorldMapInfoByID(WorldMapMgr.curMapID)
        playerAniNode = PlayerAnimeMgr.createPlayer(parent, {gender=CharInfo.getSex(), 
                x=curWorldMapInfo.mapPosX,y=curWorldMapInfo.mapPosY,skin=CharInfo.getCurfashion()},PlayerAnimeMgr.SELF_TAG_STRING)
        playerAniNode:setScale(0.7, 0.7)

        checkScroll(worldTable[WorldMapMgr.curMapID], 0)
    -- end)

    table.insert(funcTable,function()
        for i=1,16 do
            local back = CSResourceMgr.getNodeByName(resName,tostring(i))
            CSResourceMgr.setSpriteTextureByNode(back, "Map/WorldMap/images/worldmap_"..i..".png")
        end
    end)

    UnblockLoader.load(funcTable, "AllWorldMapMgr.resetAllWorld")
end

return AllWorldMapMgr