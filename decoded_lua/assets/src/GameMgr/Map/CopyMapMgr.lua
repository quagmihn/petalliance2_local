local CopyMapMgr = {}

local CopyAStar = require("src.GameMgr.Map.CopyAStar")

CopyMapMgr.MAP_TYPE = { NONE = 0,GRASS = 1,ROCK = 2,DESERT = 3,ICE = 4,INDOOR = 7 }

CopyMapMgr.TERRAIN_TYPE = { NONE = 0,GRASS = 1,BORDER = 2,ROCK = 3,TREE = 4,TREASURE = 5,MONSTER = 6,BUFF = 7,PLAYER = 8,HPBAR = 9,
                            DOOR_BACKWARD = 10,DOOR_FORWARD = 11,BOSS_TIP = 12,REVIVAL_BOTTLE = 13,WATER = 14,WORLD_BOSS = 15 }

local MAX_MAP_WIDTH = 20
local GRID_WIDTH = 104
local OWNER_PLAYER_SCALE = 0.7
local mapRes = ""
local bossTipRes = ""
local mapWidth = 0
local mapHeight = 0
local playerPool = {}
local mapMatrix = {}

function CopyMapMgr.Init()
    print("CopyMapMgr初始化")
    MAX_MAP_WIDTH = 20
    GRID_WIDTH = 104
    OWNER_PLAYER_SCALE = 0.7
    mapRes = ""
    bossTipRes = "Map/WorldMap/TeamBossTips.csb"
    mapWidth = 0
    mapHeight = 0
    playerPool = {}
    mapMatrix = {}
end

local function getTextureByType(type)
    if type == CopyMapMgr.TERRAIN_TYPE.ROCK then
        return "Searching/env/ysd/stone.png"
    elseif type == CopyMapMgr.TERRAIN_TYPE.TREE then
        return "Searching/env/ysd/blockbg.png"
    elseif type == CopyMapMgr.TERRAIN_TYPE.TREASURE then
        return "Searching/env/ysd/box.png"
    elseif type == CopyMapMgr.TERRAIN_TYPE.BUFF then
        return "Searching/env/ysd/csm.png"
    elseif type == CopyMapMgr.TERRAIN_TYPE.DOOR_BACKWARD then
        return "Searching/env/by/leftdownstair.png"
    elseif type == CopyMapMgr.TERRAIN_TYPE.DOOR_FORWARD then
        return "Searching/env/by/rightupstair.png"
    elseif type == CopyMapMgr.TERRAIN_TYPE.REVIVAL_BOTTLE then
        return "Item/ItemIcon/icon_revitalizer.png"
    else
        return "empty.png"
    end
end

local function getTerrainComponent(mapType)
    local scrollView = CSResourceMgr.getNodeByName(mapRes,"scrollView")
    local res = nil
    if mapType == CopyMapMgr.MAP_TYPE.GRASS then
        res = CSResourceMgr.getNodeByName(mapRes, "grass"):clone()
    elseif mapType == CopyMapMgr.MAP_TYPE.ROCK then
        res = CSResourceMgr.getNodeByName(mapRes, "rock"):clone()
    elseif mapType == CopyMapMgr.MAP_TYPE.DESERT then
        res = CSResourceMgr.getNodeByName(mapRes, "desert"):clone()
    elseif mapType == CopyMapMgr.MAP_TYPE.ICE then
        res = CSResourceMgr.getNodeByName(mapRes, "ice"):clone()
    elseif mapType == CopyMapMgr.MAP_TYPE.INDOOR then
        res = CSResourceMgr.getNodeByName(mapRes, "indoor"):clone()
    end
    res:setVisible(true)
    scrollView:addChild(res)
    return res
end

local function getBorderComponent()
    local scrollView = CSResourceMgr.getNodeByName(mapRes,"scrollView")
    local res = display.newSprite()
    scrollView:addChild(res)
    return res
end

local function getPlayerComponent(charID)
    local scrollView = CSResourceMgr.getNodeByName(mapRes,"scrollView")
    local player = CSResourceMgr.getNodeByName(mapRes, "player"):clone()
    player:setVisible(true)
    player.currentIndex = 0
    player.targetIndex = 0
    player.targetIndexDirty = false
    player.path = {}
    playerPool[charID] = player
    scrollView:addChild(player)
    return player
end

local function getHpBarComponent()
    local scrollView = CSResourceMgr.getNodeByName(mapRes,"scrollView")
    local hpBar = CSResourceMgr.getNodeByName(mapRes, "hpbar"):clone()
    hpBar:setVisible(true)
    scrollView:addChild(hpBar)
    return hpBar
end

local function createMapMatrix()
    mapMatrix = {}
    for h=1, mapHeight do
        local blockInfo = {}
        for w=1, mapWidth do
            blockInfo[w] = 0
            --[[
            if h==3 then
                blockInfo[w] = 1
            end
            ]]
        end
        mapMatrix[h] = blockInfo
    end
    --print("@@@@@@@@@@@mapMatrix=",sz_T2S(mapMatrix))
end

local function getGridCenter(gridIndex)
    local scrollView = CSResourceMgr.getNodeByName(mapRes,"scrollView")
    local grass = scrollView:getChildByTag(CopyMapMgr.TERRAIN_TYPE.GRASS*1000000 + gridIndex)
    --print("grass=",grass,grass:getTag())
    local pick = CSResourceMgr.seekNodeByName(grass, "pick")
    --print("pick=",grass:getPositionX() + pick:getPositionX(),grass:getPositionY() + pick:getPositionX())
    --local effAni = AnimationMgr.createAni(grass, "Spine/effects/UI-fubendianji.png", pick:getPositionX(), pick:getPositionY())
    --AnimationMgr.playAniWithCallback(effAni.res, "animation", nil, nil, true)
    return grass:getPositionX() + pick:getPositionX(), grass:getPositionY() + pick:getPositionY()
end

function CopyMapMgr.playDisplayGridEffect(gridX, gridY)
    if not CSResourceMgr.getCsbObj(mapRes) then
        return
    end
    
    local scrollView = CSResourceMgr.getNodeByName(mapRes,"scrollView")
    local gridIndex = (gridX - 1)*mapWidth + gridY
    local x, y = getGridCenter(gridIndex)
    local tag = "Effect_"..gridIndex
    local aniEff = AnimationMgr.createAni(nil, "Gaf/Searching/tansuo_shuiye.gaf", x, y + 850, tag)
    aniEff:setLocalZOrder(CocosModuleMgr.ZORDER_GUIDE)
    scrollView:addChild(aniEff)
    --AnimationMgr.playAni("Gaf/Searching/tansuo_shuiye.gaf", "do", true, tag)
    AnimationMgr.playAniWithCallback(aniEff.res, "do", function()
        AnimationMgr.removeGafObjectByTag(aniEff.res, tag)
    end, tag, true)
end

function CopyMapMgr.setGridRandomDecoration(gridIndex)
    local rand = GetRandom.random(1, 100)
    if not CSResourceMgr.getCsbObj(mapRes) or rand > 10 then
        return
    end
    
    local scrollView = CSResourceMgr.getNodeByName(mapRes,"scrollView")
    local grass = scrollView:getChildByTag(CopyMapMgr.TERRAIN_TYPE.GRASS*1000000 + gridIndex)
    local object = CSResourceMgr.seekNodeByName(grass, "object")
    object:setVisible(true)
    local tag = "Decoration_"..gridIndex
    
    local imgIndex = GetRandom.random(1, 3)
    local img = "Searching/spine/hua"..imgIndex..".png"
    local hua = AnimationMgr.createAni(object, img, -GRID_WIDTH/4, GRID_WIDTH/4, tag)
    --hua:setLocalZOrder(CocosModuleMgr.ZORDER_GUIDE)
    --scrollView:addChild(hua)
    AnimationMgr.playAni(hua.res, "idle", true, tag)
end

function CopyMapMgr.setGridBackground(gridIndex, bgRes)
    if not CSResourceMgr.getCsbObj(mapRes) then
        return
    end
    
    local scrollView = CSResourceMgr.getNodeByName(mapRes,"scrollView")
    local grass = scrollView:getChildByTag(CopyMapMgr.TERRAIN_TYPE.GRASS*1000000 + gridIndex)
    CSResourceMgr.setSpriteTextureByNode(grass, bgRes, false)
end

function CopyMapMgr.setGridBlock(gridIndex, blockType, blockRes, monsterID, isLocked, isBoss, hpPercent)
    if not CSResourceMgr.getCsbObj(mapRes) then
        return
    end
    
    local scrollView = CSResourceMgr.getNodeByName(mapRes,"scrollView")
    local grass = scrollView:getChildByTag(CopyMapMgr.TERRAIN_TYPE.GRASS*1000000 + gridIndex)
    local object = CSResourceMgr.seekNodeByName(grass, "object")
    if blockType == CopyMapMgr.TERRAIN_TYPE.ROCK or blockType == CopyMapMgr.TERRAIN_TYPE.TREE or 
       blockType == CopyMapMgr.TERRAIN_TYPE.TREASURE or blockType == CopyMapMgr.TERRAIN_TYPE.BUFF or
       blockType == CopyMapMgr.TERRAIN_TYPE.DOOR_BACKWARD or blockType == CopyMapMgr.TERRAIN_TYPE.DOOR_FORWARD or
       blockType == CopyMapMgr.TERRAIN_TYPE.REVIVAL_BOTTLE or blockType == CopyMapMgr.TERRAIN_TYPE.NONE or 
       blockType == CopyMapMgr.TERRAIN_TYPE.WATER then
        CSResourceMgr.setSpriteTextureByNode(object, blockRes or getTextureByType(blockType), false)
        object:setVisible(true)
        if blockType == CopyMapMgr.TERRAIN_TYPE.TREASURE or blockType == CopyMapMgr.TERRAIN_TYPE.BUFF then
            local x, y = getGridCenter(gridIndex)
            local tag = "Effect_"..gridIndex
            local aniEff = AnimationMgr.createAni(nil, "Spine/effects/UI_wupinshanshuo.png", x, y - GRID_WIDTH/2.0, tag)
            aniEff:setLocalZOrder(CocosModuleMgr.ZORDER_GUIDE)
            scrollView:addChild(aniEff)
            AnimationMgr.playAni(aniEff.res, "animation", true, tag)
        elseif blockType == CopyMapMgr.TERRAIN_TYPE.REVIVAL_BOTTLE then
            local n = CSResourceMgr.seekNodeByName(grass,"name")
            CSResourceMgr.setLabelStringByNode(n,"team46",{r=0,g=0,b=0,a=255,w=1})
            n:setVisible(true)
        elseif blockType == CopyMapMgr.TERRAIN_TYPE.WATER then
            --local x, y = getGridCenter(gridIndex)
            CSResourceMgr.setSpriteTextureByNode(grass, "empty.png", false)
            local tag = "Effect_"..gridIndex
            local aniEff = AnimationMgr.createAni(object, "Gaf/Searching/water.gaf", 517, 345, tag)
            --aniEff:setLocalZOrder(CocosModuleMgr.ZORDER_GUIDE)
            --scrollView:addChild(aniEff)
            AnimationMgr.playAni(aniEff.res, "do", true, tag)
            AnimationMgr.setSpeedRate(aniEff.res ,0.6, tag)
        end
    elseif blockType == CopyMapMgr.TERRAIN_TYPE.MONSTER and monsterID ~= nil then
        local x, y = getGridCenter(gridIndex)
        CSResourceMgr.setSpriteTextureByNode(object, blockRes or getTextureByType(blockType), false)
        local aniPetRes = PokemonInfo.getPokemonResByID(monsterID)
        local aniPetTag = "Monster_"..gridIndex
        local aniRes = AnimationMgr.createAni(nil, aniPetRes, x, y - GRID_WIDTH/1.5, aniPetTag)
        aniRes:setScale(0.5)
        aniRes:setLocalZOrder(CocosModuleMgr.ZORDER_GUIDE)
        scrollView:addChild(aniRes)
        AnimationMgr.playAni(aniPetRes, "idle", true, aniPetTag)
        AnimationMgr.setSkin(aniPetRes, 0, aniPetTag)
        --hpbar
        local hpbar = getHpBarComponent()
        hpbar:setTag(CopyMapMgr.TERRAIN_TYPE.HPBAR*1000000 + gridIndex)
        local petInfo = PokemonInfo.getPokemonInfoByID(monsterID)
        --[[
        local level = CSResourceMgr.seekNodeByName(hpbar,"level")
        CSResourceMgr.setSpriteTextureByNode(level, PetEducationMgr.getRareIcon(petInfo.rarePoint))
        level:setScale(0.4)
        local name = CSResourceMgr.seekNodeByName(hpbar,"name")
        CSResourceMgr.setLabelStringByNode(name, petInfo.name, {r=0,g=0,b=0,a=255,w=1})
        ]]
        hpbar:setPosition(x, y - GRID_WIDTH/1.5)
        hpbar:setLocalZOrder(CocosModuleMgr.ZORDER_HUD)
        CSResourceMgr.seekNodeByName(hpbar,"bar"):setPercent(hpPercent or 100.0)
        local state = CSResourceMgr.seekNodeByName(hpbar,"state")
        if isLocked == 1 then
            CSResourceMgr.setLabelStringByNode(state, "family94", {r=0,g=0,b=0,a=255,w=1})
            state:setVisible(true)
        else
            state:setVisible(false)
        end
        
        if isBoss == true then
            local tips = CSResourceMgr.createRes(nil, bossTipRes)
            local t = CSResourceMgr.seekNodeByName(tips,"tip")
            CSResourceMgr.setLabelStringByNode(t, "team44", {r=0,g=0,b=0,a=255,w=1})
            scrollView:addChild(tips)
            tips:setTag(CopyMapMgr.TERRAIN_TYPE.BOSS_TIP*1000000 + gridIndex)
            CSResourceMgr.playAllFrame(bossTipRes, true)
            tips:setAnchorPoint(0.5, 0.5)
            tips:setPosition(x, y)
            tips:setLocalZOrder(CocosModuleMgr.ZORDER_HUD)
        end
        object:setVisible(false)
    elseif blockType == CopyMapMgr.TERRAIN_TYPE.WORLD_BOSS and monsterID ~= nil then
        local x, y = getGridCenter(gridIndex)
        CSResourceMgr.setSpriteTextureByNode(object, blockRes or getTextureByType(blockType), false)
        local aniPetRes = PokemonInfo.getPokemonResByID(monsterID)
        local aniPetTag = "Monster_"..gridIndex
        local aniRes = AnimationMgr.createAni(nil, aniPetRes, x, y - GRID_WIDTH/1.5, aniPetTag)
        aniRes:setScale(-1.5, 1.5)
        aniRes:setLocalZOrder(CocosModuleMgr.ZORDER_TIPS)
        scrollView:addChild(aniRes)
        AnimationMgr.playAni(aniPetRes, "idle", true, aniPetTag)
        AnimationMgr.setSkin(aniPetRes, 0, aniPetTag)
        object:setVisible(false)
    end
    
    local x = math.ceil(gridIndex/mapWidth)
    local y = (gridIndex%mapWidth == 0 and mapWidth or gridIndex%mapWidth)
    if blockType == CopyMapMgr.TERRAIN_TYPE.DOOR_BACKWARD or blockType == CopyMapMgr.TERRAIN_TYPE.DOOR_FORWARD or blockType == CopyMapMgr.TERRAIN_TYPE.NONE then
        mapMatrix[x][y] = 0
    else
        mapMatrix[x][y] = 1
    end
end

function CopyMapMgr.setHpBarState(gridIndex, isLocked, percent)
    if not CSResourceMgr.getCsbObj(mapRes) then
        return
    end
    
    local scrollView = CSResourceMgr.getNodeByName(mapRes,"scrollView")
    if scrollView ~= nil then
        local hpbar = scrollView:getChildByTag(CopyMapMgr.TERRAIN_TYPE.HPBAR*1000000 + gridIndex)
        if hpbar ~= nil then
            local state = CSResourceMgr.seekNodeByName(hpbar,"state")
            if isLocked == 1 then
                CSResourceMgr.setLabelStringByNode(state, "family94", {r=0,g=0,b=0,a=255,w=1})
                state:setVisible(true)
            elseif isLocked == 0 then
                state:setVisible(false)
            end
            
            if percent then
                local bar = CSResourceMgr.seekNodeByName(hpbar,"bar")
                bar:setPercent(percent)
            end
        end
    end
end

function CopyMapMgr.clearGridBlock(gridIndex)
    if not CSResourceMgr.getCsbObj(mapRes) then
        return
    end
    
    local scrollView = CSResourceMgr.getNodeByName(mapRes,"scrollView")
    if scrollView ~= nil then
        local grass = scrollView:getChildByTag(CopyMapMgr.TERRAIN_TYPE.GRASS*1000000 + gridIndex)
        local object = CSResourceMgr.seekNodeByName(grass, "object")
        object:setVisible(false)
        local n = CSResourceMgr.seekNodeByName(grass,"name")
        n:setVisible(false)
    end
    
    local x = math.ceil(gridIndex/mapWidth)
    local y = (gridIndex%mapWidth == 0 and mapWidth or gridIndex%mapWidth)
    mapMatrix[x][y] = 0
end

function CopyMapMgr.removeMonster(gridIndex, monsterID, isBoss)
    if not CSResourceMgr.getCsbObj(mapRes) then
        return
    end
    
    local scrollView = CSResourceMgr.getNodeByName(mapRes,"scrollView")
    if scrollView ~= nil then
        local aniPetRes = PokemonInfo.getPokemonResByID(monsterID)
        local aniPetTag = "Monster_"..gridIndex
        AnimationMgr.removeGafObjectByTag(aniPetRes, aniPetTag)
        --hpbar
        local hpbar = scrollView:getChildByTag(CopyMapMgr.TERRAIN_TYPE.HPBAR*1000000 + gridIndex)
        if hpbar ~= nil then
            scrollView:removeChild(hpbar)
        end
        
        if isBoss == true then
            local tips = scrollView:getChildByTag(CopyMapMgr.TERRAIN_TYPE.BOSS_TIP*1000000 + gridIndex)
            if tips ~= nil then
                scrollView:removeChild(tips)
            end
        end
    end
end

function CopyMapMgr.removeEffect(gridIndex)
    AnimationMgr.removeGafObjectByTag("Spine/effects/UI_wupinshanshuo.png", "Effect_"..gridIndex)
end

local function randomMapBlock()
    for i=1, 160 do
        local index = math.random(2, mapWidth*mapHeight)
        CopyMapMgr.setGridBlock(index, CopyMapMgr.TERRAIN_TYPE.ROCK)
    end
end

local function getPlayer(charID)
    local scrollView = CSResourceMgr.getNodeByName(mapRes,"scrollView")
    local player = scrollView:getChildByTag(charID)
    return player
end

local function setPlayerPath(charID, path)
    if #path > 0 then
        local player = getPlayer(charID)
        if player ~= nil then
            player.path = path
        end
    end
end

local function checkDisplayOrTriggerGrid(player)
    if not player.targetIndexDirty then
        local cx = math.ceil(player.currentIndex/mapWidth)
        local cy = (player.currentIndex%mapWidth == 0 and mapWidth or player.currentIndex%mapWidth)
        
        local tx = math.ceil(player.targetIndex/mapWidth)
        local ty = (player.targetIndex%mapWidth == 0 and mapWidth or player.targetIndex%mapWidth)
        if mapMatrix[tx][ty] ~= 0 then
            if math.abs(cx-tx)+math.abs(cy-ty) == 1 then
                if SceneMgr.currentScene == "FamilyCopyMapScene" then
                    FamilyCopyMapMgr.notifyDisplayOrTriggerGrid(tx, ty)
                elseif SceneMgr.currentScene == "TeamCopyMapScene" then
                    TeamCopyMapMgr.notifyDisplayOrTriggerGrid(tx, ty)
                end
            end
        else
            if math.abs(cx-tx)+math.abs(cy-ty) == 0 then
                if SceneMgr.currentScene == "FamilyCopyMapScene" then
                    FamilyCopyMapMgr.notifyChangeFloor(tx, ty)
                elseif SceneMgr.currentScene == "TeamCopyMapScene" then
                    TeamCopyMapMgr.notifyChangeFloor(tx, ty)
                end
            end
        end
    end
end

local function playerLeaveGrid(currentPlayer)
    currentPlayer:setVisible(true)
    local player = nil
    local player2Show = nil
    for k, v in pairs(playerPool) do
        player = v
        if player ~= currentPlayer and player.currentIndex == currentPlayer.currentIndex then
            if player2Show == nil or player:getTag() == CharInfo.getCharID() then
                player2Show = player
                break
            end
        end
    end
    if player2Show then
        player2Show:setVisible(true)
    end
end

local function playerEnterGrid(currentPlayer)
    if #currentPlayer.path <= 1 then
        currentPlayer:setVisible(true)
        local currentPlayerIsOwner = (currentPlayer:getTag() == CharInfo.getCharID() and true or false)
        local player = nil
        for k, v in pairs(playerPool) do
            player = v
            if player ~= currentPlayer and player.currentIndex == currentPlayer.currentIndex then
                if currentPlayerIsOwner then
                    player:setVisible(false)
                else
                    if player:getTag() == CharInfo.getCharID() then
                        currentPlayer:setVisible(false)
                        player:setVisible(true)
                    else
                        player:setVisible(false)
                    end
                end
            end
        end
    end
end

local function setPlayerCurrentPositionByPlayer(player, currentIndex)
    local isChangeFloor = false
    if player ~= nil and player.currentIndex ~= currentIndex then
        if SceneMgr.currentScene == "FamilyCopyMapScene" or SceneMgr.currentScene == "TeamCopyMapScene" then
            playerLeaveGrid(player)
        end
        if player:getTag() == CharInfo.getCharID() and player.currentIndex == 0 then
            if SceneMgr.currentScene == "FamilyCopyMapScene" then
                FamilyCopyMapMgr.syncMoving(currentIndex)
            elseif SceneMgr.currentScene == "TeamCopyMapScene" then
                TeamCopyMapMgr.syncMoving(currentIndex)
            end
        end
        player.currentIndex = currentIndex
        if SceneMgr.currentScene == "FamilyCopyMapScene" or SceneMgr.currentScene == "TeamCopyMapScene" then
            playerEnterGrid(player)
        elseif player:getTag() == CharInfo.getCharID() and SceneMgr.currentScene == "BossMapScene" then
            BossMapMgr.enableSecurityRegion(false, currentIndex)
        end
        --if player:getTag() == CharInfo.getCharID() and SceneMgr.currentScene == "FamilyCopyMapScene" and #player.path <= 1 then
        --    FamilyCopyMapMgr.syncMoving(player.currentIndex)
        --end
        if player:getTag() == CharInfo.getCharID() then
            if SceneMgr.currentScene == "FamilyCopyMapScene" then
                local x = math.ceil(currentIndex/mapWidth)
                local y = (currentIndex%mapWidth == 0 and mapWidth or currentIndex%mapWidth)
                isChangeFloor = FamilyCopyMapMgr.notifyChangeFloor(x, y)
                if not isChangeFloor then
                    CopyMapMgr.focusPlayer(CharInfo.getCharID())
                end
            elseif SceneMgr.currentScene == "TeamCopyMapScene" then
                local x = math.ceil(currentIndex/mapWidth)
                local y = (currentIndex%mapWidth == 0 and mapWidth or currentIndex%mapWidth)
                isChangeFloor = TeamCopyMapMgr.notifyChangeFloor(x, y)
                if not isChangeFloor then
                    CopyMapMgr.focusPlayer(CharInfo.getCharID())
                end
            end
        end
    end
    return isChangeFloor
end

local function startPlayerMove(charID)
    if not CSResourceMgr.getCsbObj(mapRes) then
        return
    end
    
    local player = getPlayer(charID)
    if not player then return end
    
    if player.isAlive == false or player.forbiddenMove == true then
        player.path = {}
        player.targetIndexDirty = false
        if PlayerAnimeMgr.getPlayerCurMotionName("copy_player_"..charID) == "walk" then
            PlayerAnimeMgr.playAni("copy_player_"..charID, "idle", true)
        end
        return
    end
    
    if PlayerAnimeMgr.getPlayer("copy_player_"..charID) ~= nil then
        if #player.path > 1 then
            local x1, y1 = getGridCenter(player.path[1])
            local x2, y2 = getGridCenter(player.path[2])
            transition.moveBy(player, {x=x2-x1, y=y2-y1, time=0.25})
            table.remove(player.path,1)
            if PlayerAnimeMgr.getPlayerCurMotionName("copy_player_"..charID) ~= "walk" then
                PlayerAnimeMgr.playAni("copy_player_"..charID, "walk", true)
            end
            if x2 < x1 then
                PlayerAnimeMgr.getPlayer("copy_player_"..charID):setScaleX(-OWNER_PLAYER_SCALE)
            else
                PlayerAnimeMgr.getPlayer("copy_player_"..charID):setScaleX(OWNER_PLAYER_SCALE)
            end
            player:performWithDelay(function()
                --player.currentIndex = player.path[1]
                local isChangeFloor = setPlayerCurrentPositionByPlayer(player, player.path[1])
                if not isChangeFloor then
                    if player.targetIndexDirty then
                        player.path = {}
                        CopyMapMgr.getPlayerPath(charID)
                    else
                        startPlayerMove(charID)
                    end
                end
            end,0.25)
        else
            player.path = {}
            if PlayerAnimeMgr.getPlayerCurMotionName("copy_player_"..charID) ~= "idle" then
                PlayerAnimeMgr.playAni("copy_player_"..charID, "idle", true)
            end
            if player:getTag() == CharInfo.getCharID() then
                checkDisplayOrTriggerGrid(player)
            end
        end
    end
end

function CopyMapMgr.getPlayerPath(charID)
    if not CSResourceMgr.getCsbObj(mapRes) or table.getn(mapMatrix) <= 0 then
        return
    end
    
    local player = getPlayer(charID)
    if not player then return end
    
    if player.isAlive == false or player.forbiddenMove == true then
        player.path = {}
        player.targetIndexDirty = false
        if PlayerAnimeMgr.getPlayerCurMotionName("copy_player_"..charID) == "walk" then
            PlayerAnimeMgr.playAni("copy_player_"..charID, "idle", true)
        end
        return
    end
    
    if player.targetIndexDirty then
        local currentIndex = player.currentIndex
        local targetIndex = player.targetIndex
        local px = (currentIndex%mapWidth == 0 and mapWidth or currentIndex%mapWidth)
        local py = math.ceil(currentIndex/mapWidth)
        local tx = (targetIndex%mapWidth == 0 and mapWidth or targetIndex%mapWidth)
        local ty = math.ceil(targetIndex/mapWidth)
        local closedList,last = CopyAStar.CalcMoves(mapMatrix, px, py, tx, ty)
        --print("##########getPlayerPath closedList=",sz_T2S(closedList))
        local path = CopyAStar.CalcPath(closedList,last)
        --print("##########getPlayerPath path=",sz_T2S(path))
        if path ~= nil and #path > 1 then
            for i=1, #path do
                local moveStep = path[i]
                player.path[i] = (moveStep.y - 1)*mapWidth + moveStep.x
            end
            
            if player:getTag() == CharInfo.getCharID() then
                if SceneMgr.currentScene == "FamilyCopyMapScene" then
                    FamilyCopyMapMgr.syncMoving(player.path[#player.path])
                elseif SceneMgr.currentScene == "TeamCopyMapScene" then
                    TeamCopyMapMgr.syncMoving(player.path[#player.path])
                end
            end
        end
        player.targetIndexDirty = false
        startPlayerMove(charID)
    end
end

function CopyMapMgr.setPlayerTargetPosition(charID, targetIndex)
    if not CSResourceMgr.getCsbObj(mapRes) then
        return
    end
    
    local player = getPlayer(charID)
    if player ~= nil and player.isAlive == true then
        --local canMove = (player.targetIndex == nil and true or false)
        player.targetIndex = targetIndex
        player.targetIndexDirty = true
        if #player.path == 0 then
            CopyMapMgr.getPlayerPath(charID)
        end
    end
end

function CopyMapMgr.getPlayerTargetPosition(charID)
    if not CSResourceMgr.getCsbObj(mapRes) then
        return nil
    end
    
    local player = getPlayer(charID)
    if player ~= nil then
        return player.targetIndex
    end
    return nil
end

local function setPlayerCurrentPositionByID(charID, currentIndex)
    local player = getPlayer(charID)
    setPlayerCurrentPositionByPlayer(player, currentIndex)
end

local function back2Family()
    FamilyInfo.GoHome()
end

local function pickMap(gridIndex, btn)
    print("!!!!!!!!!!pickMap gridIndex=", gridIndex)
    --if gridIndex == mapWidth*mapHeight then
    --    back2Family()
    --    return
    --end
    local effAni = AnimationMgr.createAni(btn, "Spine/effects/UI-fubendianji.png", btn:getContentSize().width/2, btn:getContentSize().height/2)
    AnimationMgr.playAniWithCallback(effAni.res, "animation", nil, nil, true)
    TownChatMgr.showBattleChat(false)
    if SceneMgr.currentScene ~= "BossMapScene" then
        BasicMenuMgr.setChatBtnEnable(true)
    end
    CopyMapMgr.setPlayerTargetPosition(CharInfo.getCharID(), gridIndex)
end

local function createBorder(w, h)
    local sp
    
    for i=1,h+2 do
        --left
        sp = getBorderComponent()
        if i%3 == 1 then
            CSResourceMgr.setSpriteTextureByNode(sp,"Searching/env/cd/left_0.png",false)
        elseif i%3 == 2 then
            CSResourceMgr.setSpriteTextureByNode(sp,"Searching/env/cd/left_2.png",false)
        else
            CSResourceMgr.setSpriteTextureByNode(sp,"Searching/env/cd/left_1.png",false)
        end
        sp:setTag(CopyMapMgr.TERRAIN_TYPE.BORDER*1000000 + i)
        sp:setAnchorPoint(0.0,0.0)
        sp:setScale(1.0,1.0)
        sp:setPosition(-50, (i - 1)*GRID_WIDTH)
        --right
        sp = getBorderComponent()
        if i%3 == 1 then
            CSResourceMgr.setSpriteTextureByNode(sp,"Searching/env/cd/left_0.png",false)
        elseif i%3 == 2 then
            CSResourceMgr.setSpriteTextureByNode(sp,"Searching/env/cd/left_2.png",false)
        else
            CSResourceMgr.setSpriteTextureByNode(sp,"Searching/env/cd/left_1.png",false)
        end
        sp:setTag(CopyMapMgr.TERRAIN_TYPE.BORDER*1000000 + i)
        sp:setAnchorPoint(0.0,0.0)
        sp:setScale(-1.0,1.0)
        sp:setPosition((w + 2)*GRID_WIDTH + 56, (i - 1)*GRID_WIDTH)
    end
    
    for i=1,w+2 do
        --top
        sp = getBorderComponent()
        if i%2 == 1 then
            CSResourceMgr.setSpriteTextureByNode(sp,"Searching/env/cd/top_0.png",false)
        else
            CSResourceMgr.setSpriteTextureByNode(sp,"Searching/env/cd/top_1.png",false)
        end
        sp:setTag(CopyMapMgr.TERRAIN_TYPE.BORDER*1000000 + i)
        sp:setAnchorPoint(0.0,0.0)
        sp:setScale(1.0,1.0)
        sp:setPosition((i - 1)*GRID_WIDTH, h*GRID_WIDTH + 10)
        --bottom
        sp = getBorderComponent()
        if i%2 == 1 then
            CSResourceMgr.setSpriteTextureByNode(sp,"Searching/env/cd/top_0.png",false)
        else
            CSResourceMgr.setSpriteTextureByNode(sp,"Searching/env/cd/top_1.png",false)
        end
        sp:setTag(CopyMapMgr.TERRAIN_TYPE.BORDER*1000000 + i)
        sp:setAnchorPoint(0.0,0.0)
        sp:setScale(1.0,-1.0)
        sp:setPosition((i - 1)*GRID_WIDTH, GRID_WIDTH*2)
    end
end

local function createMap(w, h, mapType)
    mapWidth = w
    mapHeight = h
    
    local scrollView = CSResourceMgr.getNodeByName(mapRes,"scrollView")
    scrollView:removeAllChildren()
    
    local grass = nil
    for row=1, mapHeight do
        for col=1, mapWidth do
            grass = getTerrainComponent(mapType)
            grass:setTag(CopyMapMgr.TERRAIN_TYPE.GRASS*1000000 + (row - 1)*mapWidth + col)
            grass:setPosition(col*GRID_WIDTH, (mapHeight - row + 1)*GRID_WIDTH)
            local pick = CSResourceMgr.seekNodeByName(grass, "pick")
            CSResourceMgr.clickEventBindingByNode(pick, function()
                pickMap((row - 1)*mapWidth + col, pick)
            end, true)
        end
    end
    
    scrollView:setInnerContainerSize({width = (mapWidth + 2)*GRID_WIDTH, height = (mapHeight + 2)*GRID_WIDTH})
    
    createMapMatrix()
    
    --randomMapBlock()
    createBorder(w, h)
end

function CopyMapMgr.quitMap()
    mapWidth = 0
    mapHeight = 0
    playerPool = {}
    mapMatrix = {}
end

function CopyMapMgr.cleanMap()    
    mapWidth = 0
    mapHeight = 0
    PlayerAnimeMgr.removeAllPlayer()
    AnimationMgr.removeAllGafObjects()
    playerPool = {}
    mapMatrix = {}
end

local function playDeadEffect(player)
    if player ~= nil then
        local res = "Spine/team/guihun.png"
        local eff = AnimationMgr.createAni(player, res, 52, 70, "EffectDead_"..player:getTag())
        if PlayerAnimeMgr.getPlayer("copy_player_"..player:getTag()):getScaleX() > 0.0 then
            eff:setScaleX(-1.0)
        else
            eff:setScaleX(1.0)
        end
        AnimationMgr.playAni(eff.res,"animation",true,eff.tag)
    end
end

local function addPlayer(charID, name, sex, fashion, offsetY, bornIndex, isAlive, inBattle)
    local player = getPlayer(charID)
    if player == nil then
        player = getPlayerComponent(charID)
        player:setTag(charID)
        local playerAni = PlayerAnimeMgr.createPlayer(player, 
            {gender=sex, x=GRID_WIDTH/2, y=offsetY+13,skin=fashion}, "copy_player_"..charID)
        playerAni:setScale(OWNER_PLAYER_SCALE, OWNER_PLAYER_SCALE)

        local nameLabel = CSResourceMgr.seekNodeByName(player,"playerName")
        CSResourceMgr.setLabelColorByNode(nameLabel,{r=141,g=217,b=219,a=255})
        CSResourceMgr.setLabelStringByNode(nameLabel,name,{r=0,g=0,b=0,a=255,w=1})
        nameLabel:setPositionY(150*OWNER_PLAYER_SCALE)
        nameLabel:setLocalZOrder(CocosModuleMgr.ZORDER_HUD)
        
        CSResourceMgr.clickEventBindingByNode(player, function()
            if SceneMgr.currentScene == "FamilyCopyMapScene" then
            elseif SceneMgr.currentScene == "TeamCopyMapScene" then
                TeamCopyMapMgr.pickPlayer(charID)
            end
        end)
    end
    
    local x, y = getGridCenter(bornIndex)
    player:setPosition(x, y)
    setPlayerCurrentPositionByID(charID, bornIndex)
    player.isAlive = isAlive
    player.forbiddenMove = false
    CSResourceMgr.setButtonEnabledByNode(player, not isAlive)
    if isAlive == false then
        PlayerAnimeMgr.playAni("copy_player_"..charID,"death",true)
        playDeadEffect(player)
    else
        PlayerAnimeMgr.playAni("copy_player_"..charID,"idle",true)
    end
    
    player.inBattle = inBattle
    local state = CSResourceMgr.seekNodeByName(player,"state")
    state:setLocalZOrder(CocosModuleMgr.ZORDER_HUD)
    state:setVisible(inBattle == 1)
    if inBattle == 1 then
        CSResourceMgr.setLabelStringByNode(state, "family94", {r=0,g=0,b=0,a=255,w=1})
    end
end

local function playRevivalEffect(player, withEffect)
    if player ~= nil then
        local res = "Spine/team/Ui_fuhuotexiao.png"
        AnimationMgr.removeGafObjectByTag("Spine/team/guihun.png", "EffectDead_"..player:getTag())
        if withEffect == nil then
            withEffect = true
        end 
        if withEffect then
            local eff = AnimationMgr.createAni(player, res, 52, 20, "EffectRevival_"..player:getTag())
            AnimationMgr.playAniWithCallback(eff.res,"animation",nil,eff.tag,true)
        end
    end
end

function CopyMapMgr.changePlayerState(charID, isAlive, withEffect)
    if not CSResourceMgr.getCsbObj(mapRes) then
        return
    end
    
    local player = getPlayer(charID)
    if player ~= nil then
        if isAlive == nil then
            isAlive = true
        end
        if SceneMgr.currentScene == "FamilyCopyMapScene" or SceneMgr.currentScene == "TeamCopyMapScene" then
            CSResourceMgr.setButtonEnabledByNode(player, not isAlive)
        end
        if isAlive == false then
            PlayerAnimeMgr.playAni("copy_player_"..charID,"death",true)
            playDeadEffect(player)
        else
            PlayerAnimeMgr.playAni("copy_player_"..charID,"idle",true)
            playRevivalEffect(player, withEffect)
        end
        
        player.isAlive = isAlive
    end
end

function CopyMapMgr.createPlayer(charID, name, sex, fashion, offsetY, bornIndex, isAlive, inBattle)
    if not CSResourceMgr.getCsbObj(mapRes) then
        return
    end
    
    if isAlive == nil then
        isAlive = true
    end
    addPlayer(charID, name, sex, fashion, offsetY, bornIndex, isAlive, inBattle or 0)
end

function CopyMapMgr.removePlayer(charID)
    if not CSResourceMgr.getCsbObj(mapRes) then
        return
    end
    
    local player = getPlayer(charID)
    if player ~= nil then
        PlayerAnimeMgr.removePlayerByTag("copy_player_"..charID)
        player:removeAllChildren()
        local scrollView = CSResourceMgr.getNodeByName(mapRes,"scrollView")
        scrollView:removeChild(player)
        table.remove(playerPool, charID)
    end
end

function CopyMapMgr.createWithRes(scene, res, width, height, mapType)
    CopyMapMgr.cleanMap()
    mapRes = res
    width = (width > MAX_MAP_WIDTH and MAX_MAP_WIDTH or width)
    height = (height > MAX_MAP_WIDTH and MAX_MAP_WIDTH or height)
    CSResourceMgr.createRes(scene, res)
    CSResourceMgr.setFullScreen(mapRes)
    --print("=========CopyMapMgr.createWithRes width=",width,"height=",height)
    createMap(width, height, mapType)
    --createOwnerPlayer()
end
--[[
function CopyMapMgr.focusPlayer(charID)
    local player = getPlayer(charID)
    if player ~= nil then
        local currentIndex = player.currentIndex
        local x, y = getGridCenter(currentIndex)
        local scrollView = CSResourceMgr.getNodeByName(mapRes,"scrollView")
        local width = (mapWidth + 2)*GRID_WIDTH
        local height = (mapHeight + 2)*GRID_WIDTH
        --print("focusPlayer",charID,currentIndex,x,y,x/width * 100.0,(1 - y/height) * 100.0)
        scrollView:scrollToPercentBothDirection({x=x/width * 100.0, y=(1 - y/height) * 100.0}, 0.5, true)
    end
end
]]
function CopyMapMgr.focusPlayer(charID)
    if not CSResourceMgr.getCsbObj(mapRes) then
        return
    end
    
    local player = getPlayer(charID)
    if player ~= nil then
        local sizediff = CocosModuleMgr.getScreenSizeDiff()
        local scrollView = CSResourceMgr.getNodeByName(mapRes,"scrollView")
        local scrollwidth = scrollView:getContentSize().width
        local oringinheight = scrollView:getContentSize().height
        local scrollheight = oringinheight+sizediff-200
        local mapSize = scrollView:getInnerContainerSize()
        local mapScale = 1.0
        local posx = player:getPositionX()
        local posy = player:getPositionY()
        local diffx = posx*mapScale-scrollwidth/2
        local diffw = mapSize.width*mapScale-scrollwidth
        local ratex = diffx/diffw*100.0
        if ratex<0 then
            ratex = 0.1
        elseif ratex>100.0 then
            ratex = 100.0
        end
        local diffy = mapSize.height*mapScale-posy*mapScale-scrollheight/2
        local diffh = mapSize.height*mapScale-scrollheight
        local ratey = diffy/diffh*100.0
        --ratey = ratey + 3/mapScale/mapScale*(oringinheight/scrollheight)
        if ratey<0 then
            ratey = 0.1
        elseif ratey>100.0 then
            ratey = 100.0
        end
        
        transition.stopTarget(scrollView)
        --scrollView:performWithDelay(function()
        --print("scrollToPercentBothDirection!!!",ratex,ratey)
            scrollView:scrollToPercentBothDirection({x=ratex, y=ratey}, 1.0, true)
        --end, 0.001)
    end
end

function CopyMapMgr.playChangeFloorEffect(charID)
    if not CSResourceMgr.getCsbObj(mapRes) then
        return
    end
    
    local player = getPlayer(charID)
    if player ~= nil then
        local aniEff = AnimationMgr.createAni(player, "Spine/effects/Ui_huicheng.png", 52, 20, "Effect_"..player.currentIndex)
        AnimationMgr.playAniWithCallback(aniEff.res,"animation",nil,aniEff.tag,true)
    end
end

function CopyMapMgr.setPlayerInBattle(charID, inBattle)
    if not CSResourceMgr.getCsbObj(mapRes) then
        return
    end
    
    local player = getPlayer(charID)
    if player ~= nil then
        inBattle = inBattle or 0
        local state = CSResourceMgr.seekNodeByName(player,"state")
        state:setVisible(inBattle == 1)
        if inBattle == 1 then
            CSResourceMgr.setLabelStringByNode(state, "family94", {r=0,g=0,b=0,a=255,w=1})
        end
        
        player.inBattle = inBattle
    end
end

--only 4 boss map

function CopyMapMgr.setBossMapTexture(tex)
    if not CSResourceMgr.getCsbObj(mapRes) then
        return
    end
    
    local mapNode = CSResourceMgr.getNodeByName(mapRes,"map")
    CSResourceMgr.setSpriteTextureByNode(mapNode, tex, false)
    mapNode:setVisible(true)
end

local function createBossMap(w, h, mapType)
    mapWidth = w
    mapHeight = h

    local scrollView = CSResourceMgr.getNodeByName(mapRes,"scrollView")
    scrollView:removeAllChildren()

    local grass = nil
    for row=1, mapHeight do
        for col=1, mapWidth do
            grass = getTerrainComponent(mapType)
            grass:setTag(CopyMapMgr.TERRAIN_TYPE.GRASS*1000000 + (row - 1)*mapWidth + col)
            grass:setPosition((col - 1)*GRID_WIDTH, (mapHeight - row)*GRID_WIDTH)
            CSResourceMgr.setSpriteTextureByNode(grass, "empty.png", false)
            local pick = CSResourceMgr.seekNodeByName(grass, "pick")
            CSResourceMgr.clickEventBindingByNode(pick, function()
                pickMap((row - 1)*mapWidth + col, pick)
            end, true)
        end
    end

    scrollView:setInnerContainerSize({width = (mapWidth)*GRID_WIDTH, height = (mapHeight)*GRID_WIDTH})
    scrollView:setBackGroundColorOpacity(0)

    createMapMatrix()

    --randomMapBlock()
    --createBorder(w, h)
    local diff = CocosModuleMgr.getScreenSizeDiff()
    --print("==============createBossMap diff=",diff)
    if diff < 0 then
        scrollView:setPositionY(scrollView:getPositionY() - diff)
    end
end

function CopyMapMgr.getMapRootNode()
    if not CSResourceMgr.getCsbObj(mapRes) then
        return nil, nil, nil
    end
    
    local mapNode = CSResourceMgr.getNodeByName(mapRes,"map")
    local containerNode = CSResourceMgr.getNodeByName(mapRes,"scrollView")
    
    return mapNode and mapNode:getParent() or nil, mapNode, containerNode
end

function CopyMapMgr.createBossMapWithRes(scene, res, width, height)
    CopyMapMgr.cleanMap()
    mapRes = res
    width = (width > MAX_MAP_WIDTH and MAX_MAP_WIDTH or width)
    height = (height > MAX_MAP_WIDTH and MAX_MAP_WIDTH or height)
    CSResourceMgr.createRes(scene, res)
    CSResourceMgr.setFullScreen(mapRes)
    --print("=========CopyMapMgr.createWithRes width=",width,"height=",height)
    createBossMap(width, height, CopyMapMgr.MAP_TYPE.GRASS)
    --createOwnerPlayer()
end

local function getHpBarComponent4BossMapPlayer(player)
    local scrollView = CSResourceMgr.getNodeByName(mapRes,"scrollView")
    local hpBar = CSResourceMgr.getNodeByName(mapRes, "hpbar"):clone()
    hpBar:setVisible(true)
    player:addChild(hpBar)
    return hpBar
end

local function addBossMapPlayer(charID, name, sex, fashion, offsetY, bornIndex, isAlive, inBattle, showHp, hp, hpMax)
    local player = getPlayer(charID)
    if player == nil then
        player = getPlayerComponent(charID)
        player:setTag(charID)
        local playerAni = PlayerAnimeMgr.createPlayer(player, 
            {gender=sex, x=GRID_WIDTH/2, y=offsetY+13,skin=fashion}, "copy_player_"..charID)
        playerAni:setScale(OWNER_PLAYER_SCALE, OWNER_PLAYER_SCALE)

        local nameLabel = CSResourceMgr.seekNodeByName(player,"playerName")
        CSResourceMgr.setLabelColorByNode(nameLabel,{r=141,g=217,b=219,a=255})
        CSResourceMgr.setLabelStringByNode(nameLabel,name,{r=0,g=0,b=0,a=255,w=1})
        nameLabel:setPositionY(150*OWNER_PLAYER_SCALE)
        nameLabel:setLocalZOrder(CocosModuleMgr.ZORDER_HUD)
        nameLabel:setVisible(false)
        --[[
        CSResourceMgr.clickEventBindingByNode(player, function()
            if SceneMgr.currentScene == "FamilyCopyMapScene" then
            elseif SceneMgr.currentScene == "TeamCopyMapScene" then
                TeamCopyMapMgr.pickPlayer(charID)
            end
        end)
        ]]
    else
        player.currentIndex = 0
        player.targetIndex = 0
        player.targetIndexDirty = false
        player.path = {}
        PlayerAnimeMgr.setPlayerSkins("copy_player_"..charID, PlayerAnimeMgr.skinInfoTransfer(fashion))
    end

    local x, y = getGridCenter(bornIndex)
    player:setPosition(x, y)
    setPlayerCurrentPositionByID(charID, bornIndex)
    player.isAlive = isAlive
    player.forbiddenMove = false
    player.isPowerOverwhelming = false
    CSResourceMgr.setButtonEnabledByNode(player, not isAlive)
    if isAlive == false then
        PlayerAnimeMgr.playAni("copy_player_"..charID,"death",true)
        playDeadEffect(player)
    else
        PlayerAnimeMgr.playAni("copy_player_"..charID,"idle",true)
    end

    player.inBattle = inBattle
    local state = CSResourceMgr.seekNodeByName(player,"state")
    state:setLocalZOrder(CocosModuleMgr.ZORDER_HUD)
    state:setVisible(inBattle == 1)
    if inBattle == 1 then
        CSResourceMgr.setLabelStringByNode(state, "family94", {r=0,g=0,b=0,a=255,w=1})
    end
    
    --hpbar
    if showHp == true then
        local hpbar = getHpBarComponent4BossMapPlayer(player)
        hpbar:setTag(CopyMapMgr.TERRAIN_TYPE.HPBAR)
        hpbar:setPosition(GRID_WIDTH/2.0, GRID_WIDTH/0.8 + 16)
        hpbar:setLocalZOrder(CocosModuleMgr.ZORDER_HUD)
        hpbar:setScale(0.8)
        CSResourceMgr.seekNodeByName(hpbar,"bar"):setPercent(hp/hpMax * 100.0)
        
        local arrow = CSResourceMgr.seekNodeByName(hpbar,"level")
        CSResourceMgr.setSpriteTextureByNode(arrow, "Player/Boss/arrow.png", false)
        arrow:setPositionX(35.0)
        arrow:setVisible(true)
    end
    
    return player
end

function CopyMapMgr.createBossMapPlayer(charID, name, sex, fashion, offsetY, bornIndex, isAlive, inBattle, showHp, hp, hpMax)
    if not CSResourceMgr.getCsbObj(mapRes) then
        return nil
    end

    if isAlive == nil then
        isAlive = true
    end
    local player = addBossMapPlayer(charID, name, sex, fashion, offsetY, bornIndex, isAlive, inBattle or 0, showHp, hp, hpMax)
    return player
end

function CopyMapMgr.showBossMapWarning(gridIndex, seconds)
    if not CSResourceMgr.getCsbObj(mapRes) or seconds <= 0 then
        return
    end
    
    local scrollView = CSResourceMgr.getNodeByName(mapRes,"scrollView")
    local grass = scrollView:getChildByTag(CopyMapMgr.TERRAIN_TYPE.GRASS*1000000 + gridIndex)
    local object = CSResourceMgr.seekNodeByName(grass, "object")
    CSResourceMgr.setSpriteTextureByNode(object, "Player/Boss/warning.png", false)
    object:setOpacity(0)
    object:setVisible(true)
    
    transition.fadeIn(object, {time=0.2})
    object:performWithDelay(function()
        object:fadeOut(0.2)
        object:performWithDelay(function()
            if CSResourceMgr.getCsbObj(mapRes) then
                object:setVisible(false)
            end
        end, 0.2)
    end, seconds - 0.2)
end

function CopyMapMgr.getMapNodeByGridIndex(gridIndex)
    if not CSResourceMgr.getCsbObj(mapRes) or #gridIndex <= 0 then
        return {}
    end
    
    local node = {}
    local scrollView = CSResourceMgr.getNodeByName(mapRes,"scrollView")
    for k, v in pairs(gridIndex) do
        local grass = scrollView:getChildByTag(CopyMapMgr.TERRAIN_TYPE.GRASS*1000000 + v)
        local object = CSResourceMgr.seekNodeByName(grass, "object")
        --object:removeAllChildren()
        CSResourceMgr.setSpriteTextureByNode(object, "empty.png", false)
        object:setVisible(true)
        table.insert(node, object)
    end
    
    return node
end

function CopyMapMgr.getWorldBossNode(monsterID, gridIndex)
    if not CSResourceMgr.getCsbObj(mapRes) then
        return nil
    end
    
    local aniPetRes = PokemonInfo.getPokemonResByID(monsterID)
    local aniPetTag = "Monster_"..gridIndex
    return AnimationMgr.getGafObj(aniPetRes, aniPetTag)
end

function CopyMapMgr.getPlayerNode(charID)
    if not CSResourceMgr.getCsbObj(mapRes) then
        return nil, nil
    end

    local player = getPlayer(charID)
    return player, player.isAlive
end

function CopyMapMgr.getPlayerCurrentIndex(charID)
    local player, isAlive = CopyMapMgr.getPlayerNode(charID)
    if player then
        return player.currentIndex
    end

    return nil
end

function CopyMapMgr.setPlayerHp(charID, hp, hpMax)
    if not CSResourceMgr.getCsbObj(mapRes) then
        return
    end
    
    local player = getPlayer(charID)
    local hpBar = player:getChildByTag(CopyMapMgr.TERRAIN_TYPE.HPBAR)
    if hpBar then
        CSResourceMgr.seekNodeByName(hpBar,"bar"):setPercent(hp/hpMax * 100.0)
    end
end

local function isPlayerInGridIndex(player, gridIndex)
    for k, v in pairs(gridIndex) do
        if player.currentIndex == v then
            return true
        end
    end
    
    return false
end

function CopyMapMgr.getAllPlayerNodeByGridIndex(gridIndex)
    local nodeAllPlayer = {}
    if CSResourceMgr.getCsbObj(mapRes) then
        for k, v in pairs(playerPool) do
            if v.isAlive == true and isPlayerInGridIndex(v, gridIndex) then
                table.insert(nodeAllPlayer, v)
            end
        end
    end
    return nodeAllPlayer
end

function CopyMapMgr.checkPlayerInGridIndex(charID, gridIndex)
    local player, isAlive = CopyMapMgr.getPlayerNode(charID)
    if player then
        for k, v in pairs(gridIndex) do
            if player.currentIndex == v then
                return true
            end
        end
    end
    
    return false
end

function CopyMapMgr.getScreenPositionByNode(node)
    local pos = nil
    
    if CSResourceMgr.getCsbObj(mapRes) then
        local scrollView = CSResourceMgr.getNodeByName(mapRes,"scrollView")
        pos = {x=scrollView:getPositionX() + node:getPositionX(), y=scrollView:getPositionY() + node:getPositionY()}
    end
    return pos
end

function CopyMapMgr.forbiddenPlayerMoving(charID, isForbidden)
    if CSResourceMgr.getCsbObj(mapRes) then
        local player = getPlayer(charID)
        if player then
            player.forbiddenMove = isForbidden
        end
    end
end

function CopyMapMgr.makePlayerOverwhelming(charID, seconds)
    if CSResourceMgr.getCsbObj(mapRes) then
        local player = getPlayer(charID)
        if player then
            player.isPowerOverwhelming = true
            local flag = display.newSprite("Player/Boss/security_flag.png")
            flag:setLocalZOrder(-1)
            flag:setPosition(50, 80)
            flag:setTag(111111)
            player:addChild(flag)
            CopyMapMgr.makeNodeAutoScale(flag, 0.5)
            local gaf = BattleFuncMgr.createGafAni("Gaf/bossEffect/BossEdge.gaf", player, 0.5, -0.5, 50, 130)
            gaf:setLocalZOrder(-1)
            gaf:setTag(222222)
            BattleFuncMgr.playGafAniWithSequenceAndCallBack(gaf,"Play",true)
            --object:setVisible(true)
            player:performWithDelay(function()
                player.isPowerOverwhelming = false
                player:removeChildByTag(111111, true)
                player:removeChildByTag(222222, true)
            end, seconds)
        end
    end
end

function CopyMapMgr.isPlayerOverwhelming(charID)
    if CSResourceMgr.getCsbObj(mapRes) then
        local player = getPlayer(charID)
        if player then
            return player.isPowerOverwhelming
        end
    end
    
    return false
end

function CopyMapMgr.makeNodeAutoScale(node, time)
    if CSResourceMgr.getCsbObj(mapRes) and node then
        local scale = node:getScale()
        transition.scaleTo(node, {scale=1.0-scale,time=time})
        node:performWithDelay(function()
            CopyMapMgr.makeNodeAutoScale(node, time)
        end, time)
    end
end

function CopyMapMgr.enableSecurityRegion(gridIndex, bEnable)
    if CSResourceMgr.getCsbObj(mapRes) then
        for k, v in pairs(gridIndex) do
            local scrollView = CSResourceMgr.getNodeByName(mapRes,"scrollView")
            local grass = scrollView:getChildByTag(CopyMapMgr.TERRAIN_TYPE.GRASS*1000000 + v)
            local object = CSResourceMgr.seekNodeByName(grass, "object")
            transition.stopTarget(object)
            
            if bEnable == true then
                local bg = display.newSprite("Player/Boss/security.png")
                local flag = display.newSprite("Player/Boss/security_flag.png")
                bg:setTag(111111)
                flag:setTag(222222)
                object:addChild(bg)
                object:addChild(flag)
                CopyMapMgr.makeNodeAutoScale(flag, 0.5)
                local gaf = BattleFuncMgr.createGafAni("Gaf/bossEffect/BossEdge.gaf", object, 0.5, -0.5, 0, 50)
                gaf:setTag(333333)
                BattleFuncMgr.playGafAniWithSequenceAndCallBack(gaf,"Play",true)
                object:setVisible(true)
            else
                --object:removeAllChildren()
                object:getChildByTag(111111):fadeOut(0.2)
                object:getChildByTag(222222):fadeOut(0.2)
                object:getChildByTag(333333):fadeOut(0.2)
                object:performWithDelay(function()
                    object:removeChildByTag(111111, true)
                    object:removeChildByTag(222222, true)
                    object:removeChildByTag(333333, true)
                    object:setVisible(false)
                end, 0.2)
            end
        end
    end
end

function CopyMapMgr.playMonsterAnimWithCallback(monsterID, gridIndex, animName, callback)
    local aniPetRes = PokemonInfo.getPokemonResByID(monsterID)
    local aniPetTag = "Monster_"..gridIndex
    AnimationMgr.playAniWithCallback(aniPetRes, animName, function()
        AnimationMgr.playAni(aniPetRes, "idle", true, aniPetTag)
        if callback then callback() end
    end, aniPetTag)
end

return CopyMapMgr