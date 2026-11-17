local BossMapMgr = {}

BossMapMgr.MAP_ID = { NONE = 0,GRASS = 1,DESERT = 2 }

local resName = ""
local mapID = BossMapMgr.MAP_ID.NONE
local bossID = 0
local mapWidth = 0
local mapHeight = 0
local gridNum = 0
local walkableGridIndex = {}
local bossGridIndex = 29
local bornGridIndex = 49
local playerOwnerHP = 0
local isBossKilled = false
local isPlayerOwnerBallsEmpty = false
local isPetRevived = false
local rootNodeX, rootNodeY
local randomFashion = { {1010, 2010, 3010},
                        {1005, 2005, 3005},
                        {1018, 2018, 3018},
                        {1028, 2028, 3028},
                        {1024, 2024, 3024},
                        {1030, 2030, 3030},
                        {1038, 2038, 3038},
                        {1037, 2037, 3037},
                        {1005, 2005, 3005}}

function BossMapMgr.Init()
    print("BossMapMgr初始化")
    resName = "Map/Family/CopyMap.csb"
    mapID = BossMapMgr.MAP_ID.NONE
    bossID = 0
    mapWidth = 6
    mapHeight = 9
    gridNum = mapWidth*mapHeight
    walkableGridIndex = {   25,26,27,
                            31,32,33,
                            37,38,39,40,41,42,
                            43,44,45,46,47,48,
                            50,51,52,53,54}
    bossGridIndex = 29
    bornGridIndex = 49
    playerOwnerHP = CharInfo.getLevel()
    isBossKilled = false
    isPlayerOwnerBallsEmpty = false
    isPetRevived = false
    rootNodeX = nil
    rootNodeY = nil
end

function BossMapMgr.enterBossMap()
    if WorldBossInfo.getCurBossInfo() then
        WorldBossInfo.GetSelfWorldBossData()
        BossMapMgr.cleanLocalBossMapInfo()
        BossFailedMgr.enableShow(true, true)
        SceneMgr.replaceScene(SceneMgr.getRunningScene, "BossMapScene")
    end
end

local function cleanMap()
    CopyMapMgr.cleanMap()
end

function BossMapMgr.cleanLocalBossMapInfo()
    cleanMap()

    mapWidth = 6
    mapHeight = 9
    gridNum = mapWidth*mapHeight
    walkableGridIndex = {   25,26,27,
                            31,32,33,
                            37,38,39,40,41,42,
                            43,44,45,46,47,48,
                            50,51,52,53,54}
    playerOwnerHP = CharInfo.getLevel()
    isBossKilled = false
    isPlayerOwnerBallsEmpty = false
    isPetRevived = false
    rootNodeX = nil
    rootNodeY = nil
end

function BossMapMgr.addLocalBossMapInfo(map, boss)
    mapID = map
    bossID = boss
    CopyMapMgr.createBossMapWithRes(SceneMgr.getRunningScene, resName, mapWidth, mapHeight)
    CopyMapMgr.setBossMapTexture("Player/Boss/boss_map"..mapID..".png")
    CopyMapMgr.setGridBlock(bossGridIndex, CopyMapMgr.TERRAIN_TYPE.WORLD_BOSS, nil, bossID)
    local blockGrid = { 1,2,3,4,5,6,
                        7,8,9,10,11,12,
                        13,14,15,16,17,18,
                        19,20,21,22,23,24,
                        28,30, 
                        34,35,36}
    for k, v in pairs(blockGrid) do
        CopyMapMgr.setGridBlock(v, CopyMapMgr.TERRAIN_TYPE.WORLD_BOSS)
    end
end

function BossMapMgr.addLocalMembersInfo(hp, hpMax, bossID, remainTime, totalTime)
    playerOwnerHP = hp
    local playerOwner = CopyMapMgr.createBossMapPlayer(CharInfo.getCharID(), CharInfo.getNickName(), CharInfo.getSex(), CharInfo.getCurfashion(), 20.0, bornGridIndex, true, nil, true, hp, hpMax)
    if playerOwner then
        playerOwner:setLocalZOrder(CocosModuleMgr.ZORDER_GUIDE)
        BossMapMgr.enableSecurityRegion(true)
    end
    BossTopBarMgr.show(SceneMgr.getRunningScene, bossID, remainTime, totalTime, PetEducationMgr.getPetWithOutYoke(PokemonInfo.getAllPets()))
end

function BossMapMgr.getWalkableGridIndex()
    return walkableGridIndex
end

function BossMapMgr.showWarningByGridIndex(gridIndex, seconds, callback)
    for i=1, #gridIndex do
        CopyMapMgr.showBossMapWarning(gridIndex[i], seconds)
    end
    
    local rootNode = BossMapMgr.getMapRootNode()
    if rootNode and seconds > 0 and callback then
        rootNode:performWithDelay(function()
            if callback then callback() end
        end, seconds)
    end
end

function BossMapMgr.getBossNode()
    if SceneMgr.currentScene == "BossMapScene" then
        return CopyMapMgr.getWorldBossNode(bossID, bossGridIndex)
    end
    return nil
end

function BossMapMgr.getPlayerOwnerNode()
    local player, isAlive = CopyMapMgr.getPlayerNode(CharInfo.getCharID())
    if isAlive == true then
        return player
    else
        return nil
    end
end

function BossMapMgr.getMapRootNode()
    if SceneMgr.currentScene == "BossMapScene" then
        local rootNode, mapNode, containerNode = CopyMapMgr.getMapRootNode()
        if not rootNodeX or not rootNodeY then
            rootNodeX, rootNodeY = rootNode:getPosition()
        end
        return rootNode, mapNode, containerNode
    else
        return nil, nil, nil
    end
end

function BossMapMgr.getMapNodeByGridIndex(gridIndex)
    if SceneMgr.currentScene == "BossMapScene" then
        return CopyMapMgr.getMapNodeByGridIndex(gridIndex)
    end
    return {}
end

function BossMapMgr.getPlayerOwnerGridIndex()
    return CopyMapMgr.getPlayerCurrentIndex(CharInfo.getCharID())
end

function BossMapMgr.getAllPlayerNodeByGridIndex(gridIndex)
    return CopyMapMgr.getAllPlayerNodeByGridIndex(gridIndex)
end

function BossMapMgr.setPlayerHpByDamage(charID, damage)
    playerOwnerHP = playerOwnerHP - damage
    if playerOwnerHP < 0 then playerOwnerHP = 0 end
    CopyMapMgr.setPlayerHp(charID, playerOwnerHP, CharInfo.getLevel())
end

function BossMapMgr.setPlayerHp(charID, hp)
    playerOwnerHP = hp
    CopyMapMgr.setPlayerHp(charID, playerOwnerHP, CharInfo.getLevel())
end

function BossMapMgr.changePlayerCurrentState(charID, newState)
    CopyMapMgr.changePlayerState(charID, newState)
    if charID == CharInfo.getCharID() then
        BossMapMgr.setPlayerHp(charID, newState == true and CharInfo.getLevel() or 0)
    end
end

function BossMapMgr.getPlayerOwnerBornGridIndex()
    return {bornGridIndex}
end

local function isSecurityRegionWalkable()
    return (walkableGridIndex[#walkableGridIndex] == bornGridIndex and true or false)
end

function BossMapMgr.isPlayerOwnerInSecurityRegion(gridIndex)
    return (not isSecurityRegionWalkable() and CopyMapMgr.checkPlayerInGridIndex(CharInfo.getCharID(), gridIndex))
end

local function runIdleAction(player)
    if SceneMgr.currentScene == "BossMapScene" and CSResourceMgr.getCsbObj(resName) and player and not isBossKilled then
        BossMapMgr.randomPlayerAction(player)
    end
end

local function runMovingAction(player)
    if SceneMgr.currentScene == "BossMapScene" and CSResourceMgr.getCsbObj(resName) and player and not isBossKilled then
        local index = GetRandom.random(1, #walkableGridIndex)
        local charID = player:getTag()
        CopyMapMgr.setPlayerTargetPosition(charID, walkableGridIndex[index])
        BossMapMgr.randomPlayerAction(player)
    end
end

local function runCastingAction(player)
    if SceneMgr.currentScene == "BossMapScene" and CSResourceMgr.getCsbObj(resName) and player and not isBossKilled then
        PlayerAnimeMgr.getPlayer("copy_player_"..player:getTag()):setScaleX(0.7)
        PlayerAnimeMgr.playAniWithCallback("copy_player_"..player:getTag(), "attack", function()
            if PlayerAnimeMgr.getPlayerCurMotionName("copy_player_"..player:getTag()) ~= "death" then
                PlayerAnimeMgr.playAni("copy_player_"..player:getTag(), "idle", true)
            end
        end)
        GameAudio.playBattleSound("bossbotball")
        BattleUIMgr.playPlayerBall(player)
        BossMapMgr.randomPlayerAction(player)
    end
end

local function runRevivalAction(charID)
    if SceneMgr.currentScene == "BossMapScene" and CSResourceMgr.getCsbObj(resName) and not isBossKilled then
        --CopyMapMgr.removePlayer(charID)
        CopyMapMgr.changePlayerState(charID, true, false)
        local sex = GetRandom.random(0, 1)
        local fashion = GetRandom.random(1, #randomFashion)
        local index = bornGridIndex
        local player = BossMapMgr.createRandomPlayer(charID, sex, randomFashion[fashion], index)
        runMovingAction(player)
    end
end

local function runDeathAction(player)
    if SceneMgr.currentScene == "BossMapScene" and CSResourceMgr.getCsbObj(resName) and player and not isBossKilled then
        local charID = player:getTag()
        CopyMapMgr.changePlayerState(charID, false)
        --BossMapMgr.randomPlayerAction(player)
        player:performWithDelay(function()
            runRevivalAction(charID)
        end, GetRandom.random(4, 8))
    end
end

function BossMapMgr.randomPlayerAction(player)
    if SceneMgr.currentScene == "BossMapScene" and CSResourceMgr.getCsbObj(resName) and player and not isBossKilled then
        local action = {runIdleAction, runMovingAction, runCastingAction}
        
        player:performWithDelay(function()
            local actionIndex = GetRandom.random(1, #action)
            action[actionIndex](player)
        end, GetRandom.random(4, 8))
    end
end

function BossMapMgr.createRandomPlayer(charID, sex, fashion, index)
    if SceneMgr.currentScene == "BossMapScene" then
        return CopyMapMgr.createBossMapPlayer(charID, "", sex, fashion, 20.0, index, true, nil, false)
    end
    return nil
end

function BossMapMgr.createRandomPlayers(playerNum)
    local wgi = {}
    for k, v in pairs(walkableGridIndex) do
        wgi[k] = v
    end
    
    for i=1, playerNum do
        local sex = GetRandom.random(0, 1)
        local fashion = GetRandom.random(1, #randomFashion)
        local index = GetRandom.random(1, #wgi)
        local player = BossMapMgr.createRandomPlayer(i, sex, randomFashion[fashion], wgi[index])
        table.remove(wgi, index)
        BossMapMgr.randomPlayerAction(player)
    end
end

function BossMapMgr.forbiddenPlayerMoving(charID, isForbidden)
    if SceneMgr.currentScene == "BossMapScene" then
        CopyMapMgr.forbiddenPlayerMoving(charID, isForbidden)
    end
end

function BossMapMgr.makePlayerOwnerPowerOverwhelming(seconds)
    if SceneMgr.currentScene == "BossMapScene" then
        CopyMapMgr.makePlayerOverwhelming(CharInfo.getCharID(), seconds)
    end
end

function BossMapMgr.isPlayerOwnerPowerOverwhelming()
    if SceneMgr.currentScene == "BossMapScene" then
        return CopyMapMgr.isPlayerOverwhelming(CharInfo.getCharID())
    end
    return false
end

function BossMapMgr.enableSecurityRegion(bEnable, currentIndex)
    if bEnable == false and (currentIndex == bornGridIndex or isSecurityRegionWalkable()) then
        return
    end
    CopyMapMgr.enableSecurityRegion({bornGridIndex}, bEnable)
    if bEnable == false then
        table.insert(walkableGridIndex, bornGridIndex)
    end
end

function BossMapMgr.removeBoss()
    CopyMapMgr.removeMonster(bossGridIndex, bossID)
end

function BossMapMgr.setBossKilled(bKilled)
    isBossKilled = bKilled
end

function BossMapMgr.playBossAnimWithCallback(animName, callback)
    if SceneMgr.currentScene == "BossMapScene" and BossMapMgr.getBossNode() then
        CopyMapMgr.playMonsterAnimWithCallback(bossID, bossGridIndex, animName, callback)
    end
end

function BossMapMgr.playBossAnimByLoop(animName)
    local aniPetRes = PokemonInfo.getPokemonResByID(bossID)
    local aniPetTag = "Monster_"..bossGridIndex
    AnimationMgr.playAni(aniPetRes,animName, true, aniPetTag)
end

function BossMapMgr.setPlayerOwnerBallsEmpty(bEmpty)
    isPlayerOwnerBallsEmpty = bEmpty
end

function BossMapMgr.isPlayerOwnerBallsEmpty()
    return isPlayerOwnerBallsEmpty
end

function BossMapMgr.setPetRevived(bRevived)
    isPetRevived = bRevived
end

function BossMapMgr.isPetRevived()
    return isPetRevived
end

function BossMapMgr.getRootNodeXY()
    return rootNodeX, rootNodeY
end

function BossMapMgr.takeDamage(player)
    if SceneMgr.currentScene == "BossMapScene" and player and player:getTag() ~= CharInfo.getCharID() then
        local action = {runIdleAction, runMovingAction, runCastingAction, runIdleAction, runMovingAction, runCastingAction, runMovingAction, runDeathAction, runDeathAction, runDeathAction}
        local actionIndex = GetRandom.random(1, #action)
        if actionIndex > 7 and PlayerAnimeMgr.getPlayerCurMotionName("copy_player_"..player:getTag()) ~= "death" then
            transition.stopTarget(player)
            runDeathAction(player)
        end
    end
end

return BossMapMgr