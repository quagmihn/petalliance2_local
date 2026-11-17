local TeamCopyMapMgr = {}

local PLAYER_STATE = {PLAYER_DEAD = 0,PLAYER_ALIVE = 1}

local resName = ""
local mapWidth = 0
local mapHeight = 0
local gridNum = 0
local membersNum = 0
local battleNum = 0
local copyID = 0
local revivalNum = 0
local killMonsterNum = 0
local localCopyMapInfo = {}
local ownerBornIndexTbl = {}
local localMembersInfo = {}
local localBattleInfo = {}
local ownerPlayerPVEBattleInfo = {}
local ownerPlayerPVEBattleCD = 5 * 60
local ownerPlayerCurrentFloor = 0

function TeamCopyMapMgr.Init()
    print("TeamCopyMapMgr初始化")
    resName = "Map/Family/CopyMap.csb"
    mapWidth = 0
    mapHeight = 0
    gridNum = 0
    membersNum = 0
    battleNum = 0
    copyID = 0
    revivalNum = 0
    killMonsterNum = 0
    localCopyMapInfo = {}
    ownerBornIndexTbl = {}
    localMembersInfo = {}
    localBattleInfo = {}
    ownerPlayerPVEBattleInfo = {}
    ownerPlayerPVEBattleCD = 5 * 60
    ownerPlayerCurrentFloor = 0
end

local function cleanMap()
    for h=1,mapHeight do
        for w=1,mapWidth do
            local idx = (h - 1)*mapWidth + w
            if localCopyMapInfo[idx].eventType == Proto.FDET_PVE and localCopyMapInfo[idx].isDisplay == 0 then
                CopyMapMgr.removeMonster(idx, TeamMapInfo.getTeamMonsterInfoById(localCopyMapInfo[idx].eventID).petnumber)
            end
        end
    end

    CopyMapMgr.cleanMap()
end

function TeamCopyMapMgr.getLocalCopyMapSize()
    return mapWidth, mapHeight
end

function TeamCopyMapMgr.cleanLocalCopyMapInfo()
    TeamCopyInfo.reset()
    cleanMap()

    mapWidth = 0
    mapHeight = 0
    gridNum = 0
    membersNum = 0
    battleNum = 0
    copyID = 0
    revivalNum = 0
    killMonsterNum = 0
    localCopyMapInfo = {}
    ownerBornIndexTbl = {}
    localMembersInfo = {}
    localBattleInfo = {}
    --ownerPlayerPVEBattleInfo = {}
    ownerPlayerCurrentFloor = 0
end

function TeamCopyMapMgr.quitMap()
    CopyMapMgr.quitMap()

    mapWidth = 0
    mapHeight = 0
    gridNum = 0
    membersNum = 0
    battleNum = 0
    copyID = 0
    revivalNum = 0
    killMonsterNum = 0
    localCopyMapInfo = {}
    ownerBornIndexTbl = {}
    localMembersInfo = {}
    localBattleInfo = {}
    --ownerPlayerPVEBattleInfo = {}
    ownerPlayerCurrentFloor = 0
end

function TeamCopyMapMgr.setGridNum(num)
    gridNum = num
    localCopyMapInfo = {}
    ownerBornIndexTbl = {}
    CopyMapLoadingMgr.show(SceneMgr.getRunningScene, 3.0, "TeamCopyMapLoading")
end

function TeamCopyMapMgr.setMembersNum(num)
    membersNum = num
    localMembersInfo = {}
end

function TeamCopyMapMgr.setBattleNum(num)
    battleNum = num
    localBattleInfo = {}
end

function TeamCopyMapMgr.setCopyID(id)
    copyID = id
end

function TeamCopyMapMgr.getCopyID()
    return copyID
end

function TeamCopyMapMgr.setKillMonsterNum(num, bCheckBoss)
    if bCheckBoss == nil then
        bCheckBoss = true
    end
    killMonsterNum = num
    if copyID > 0 and SceneMgr.currentScene == "TeamCopyMapScene" and bCheckBoss then
        local floorInfo = TeamMapInfo.getTeamFloorInfoById(copyID)
        TeamCopyTopBarMgr.updateBossInfo(killMonsterNum, floorInfo.maxKill)
        if killMonsterNum >= floorInfo.maxKill then
            TeamCopyMapMgr.showLocalBoss()
            TeamCopyTopBarMgr.showBoss()
        end
    end
end

function TeamCopyMapMgr.incKillMonsterNum()
    TeamCopyMapMgr.setKillMonsterNum(killMonsterNum + 1)
end

function TeamCopyMapMgr.setRevivalNum(num)
    revivalNum = num
    TeamCopyTopBarMgr.updateRevivalNum(revivalNum)
    for k, v in pairs(localMembersInfo) do
        if v.charID == CharInfo.getCharID() then
            if v.items then
                for key, val in pairs(v.items) do
                    if val.itemID == 1 then
                        val.num = revivalNum
                        return
                    end
                end
            else
                v.items = {}
            end
            table.insert(v.items, {itemID = 1, num = revivalNum})
            break
        end
    end
end

function TeamCopyMapMgr.setMemberBattleState(charID, inBattle)
    for k, v in pairs(localMembersInfo) do
        if v.charID == charID then
            v.inBattle = inBattle
            break
        end
    end
end

function TeamCopyMapMgr.addLocalCopyMapInfo(info)
    local cjson = require("cjson")
    for i=1, #info do
        localCopyMapInfo[#localCopyMapInfo + 1] = cjson.decode(info[i])
    end
    if #localCopyMapInfo == gridNum then
        local floorInfo = TeamMapInfo.getTeamFloorInfoById(copyID)
        --print("localCopyMapInfo=",sz_T2S(localCopyMapInfo))
        mapWidth = localCopyMapInfo[gridNum].y
        mapHeight = localCopyMapInfo[gridNum].x
        --print("addLocalMapInfo",mapWidth,mapHeight)
        if CSResourceMgr.getCsbObj(resName) then
            CSResourceMgr.removeCSObjectByTag(resName)
        end
        CopyMapMgr.createWithRes(SceneMgr.getRunningScene, resName, mapWidth, mapHeight, floorInfo.sence)
        ownerBornIndexTbl = {}
        for h=1,mapHeight do
            for w=1,mapWidth do
                local idx = (h - 1)*mapWidth + w
                --CopyMapMgr.setGridBackground(idx, AdvEnvironmentMgr.getFilePathWithParam(floorInfo.sence, "dz1"))
                if localCopyMapInfo[idx].eventType == Proto.FDET_OBSTACLE then
                    localCopyMapInfo[idx].isDisplay = 0
                    if localCopyMapInfo[idx].eventID == 1 or localCopyMapInfo[idx].eventID == 2 then
                        CopyMapMgr.setGridBlock(idx, CopyMapMgr.TERRAIN_TYPE.WATER)
                    else
                        CopyMapMgr.setGridBlock(idx, CopyMapMgr.TERRAIN_TYPE.ROCK, AdvEnvironmentMgr.getFilePathWithParam(floorInfo.sence, TeamMapInfo.getTeamObstacleInfoById(localCopyMapInfo[idx].eventID).iconRes))
                    end
                elseif localCopyMapInfo[idx].eventType == Proto.FDET_START then
                    localCopyMapInfo[idx].isDisplay = 0
                    ownerBornIndexTbl[#ownerBornIndexTbl + 1] = idx
                else
                    if localCopyMapInfo[idx].isDisplay == 1 then
                        CopyMapMgr.setGridBlock(idx, CopyMapMgr.TERRAIN_TYPE.TREE)
                    else
                        if localCopyMapInfo[idx].eventType == Proto.FDET_PVE then
                            CopyMapMgr.setGridBlock(idx, CopyMapMgr.TERRAIN_TYPE.MONSTER, nil, TeamMapInfo.getTeamMonsterInfoById(localCopyMapInfo[idx].eventID).petnumber, localCopyMapInfo[idx].data, false, localCopyMapInfo[idx].hpPercent)
                        elseif localCopyMapInfo[idx].eventType == Proto.FDET_ATTRIBUTECHANGE then
                            CopyMapMgr.setGridBlock(idx, CopyMapMgr.TERRAIN_TYPE.BUFF)
                        elseif localCopyMapInfo[idx].eventType == Proto.FDET_RANDOMCHEST then
                            CopyMapMgr.setGridBlock(idx, CopyMapMgr.TERRAIN_TYPE.TREASURE, FamilyDataInfo.getFamilyRandomChestInfoById(localCopyMapInfo[idx].eventID).picRes)
                        elseif localCopyMapInfo[idx].eventType == Proto.FDET_TRANS then
                            local type = (TeamMapInfo.getTeamTransferInfoById(localCopyMapInfo[idx].eventID).type == 1 and CopyMapMgr.TERRAIN_TYPE.DOOR_FORWARD or CopyMapMgr.TERRAIN_TYPE.DOOR_BACKWARD)
                            CopyMapMgr.setGridBlock(idx, type, TeamMapInfo.getTeamTransferInfoById(localCopyMapInfo[idx].eventID).picRes)
                        --[[
                        elseif localCopyMapInfo[idx].eventType == Proto.FDET_BOSS then
                            local floorInfo = TeamMapInfo.getTeamFloorInfoById(copyID)
                            if killMonsterNum >= floorInfo.maxKill then
                                CopyMapMgr.setGridBlock(idx, CopyMapMgr.TERRAIN_TYPE.MONSTER, nil, TeamMapInfo.getTeamMonsterInfoById(localCopyMapInfo[idx].eventID).petnumber, localCopyMapInfo[idx].data, true, localCopyMapInfo[idx].hpPercent)
                            end
                        ]]
                        elseif localCopyMapInfo[idx].eventType == Proto.FDET_PICKITEM then
                            local itemID = TeamMapInfo.getTeamPickUpItemInfoById(localCopyMapInfo[idx].eventID).itemID
                            if itemID == 1 then
                                CopyMapMgr.setGridBlock(idx, CopyMapMgr.TERRAIN_TYPE.REVIVAL_BOTTLE, TeamMapInfo.getTeamItemInfoById(itemID).picRes)
                            end
                        elseif localCopyMapInfo[idx].eventType == Proto.FDET_NONE then
                            if localCopyMapInfo[idx].eventID == 1 then
                                CopyMapMgr.setGridBlock(idx, CopyMapMgr.TERRAIN_TYPE.NONE, AdvEnvironmentMgr.getFilePathWithParam(floorInfo.sence, "frontupstep"))
                            elseif localCopyMapInfo[idx].eventID == 2 then
                                CopyMapMgr.setGridBlock(idx, CopyMapMgr.TERRAIN_TYPE.NONE, AdvEnvironmentMgr.getFilePathWithParam(floorInfo.sence, "leftupstep"))
                            elseif localCopyMapInfo[idx].eventID == 3 then
                                CopyMapMgr.setGridBlock(idx, CopyMapMgr.TERRAIN_TYPE.NONE, AdvEnvironmentMgr.getFilePathWithParam(floorInfo.sence, "rightupstep"))
                            elseif floorInfo.sence == 1 then
                                CopyMapMgr.setGridRandomDecoration(idx)
                            end
                        end
                    end
                end
            end
        end
        return true
    end
    return false
end

function TeamCopyMapMgr.showLocalBoss()
    if #localCopyMapInfo > 0 then
        if SceneMgr.currentScene == "TeamCopyMapScene" then
            for h=1,mapHeight do
                for w=1,mapWidth do
                    local idx = (h - 1)*mapWidth + w
                    if localCopyMapInfo[idx].eventType == Proto.FDET_BOSS then
                        CopyMapMgr.setGridBlock(idx, CopyMapMgr.TERRAIN_TYPE.MONSTER, nil, TeamMapInfo.getTeamMonsterInfoById(localCopyMapInfo[idx].eventID).petnumber, localCopyMapInfo[idx].data, true, localCopyMapInfo[idx].hpPercent)
                        break
                    end
                end
            end
        end
    end
end

local function setOwnerPlayerCurrentFloor(floor)
    ownerPlayerCurrentFloor = floor
    --FamilyCopyTopBarMgr.setCurrentFloor(floor + 1)
end

function TeamCopyMapMgr.incOwnerPlayerCurrentFloor()
    setOwnerPlayerCurrentFloor(ownerPlayerCurrentFloor + 1)
end

function TeamCopyMapMgr.decOwnerPlayerCurrentFloor()
    setOwnerPlayerCurrentFloor(ownerPlayerCurrentFloor - 1)
end

function TeamCopyMapMgr.isHaveFriend()
    for k, v in pairs(localMembersInfo) do
        if v.charID ~= CharInfo.getCharID() and FriendsViewMgr.isHaveFriend({friendID = v.charID}) then
            return true
        end
    end
    return false
end

function TeamCopyMapMgr.addLocalMembersInfo(info)
    local cjson = require("cjson")
    for i=1, #info do
        localMembersInfo[#localMembersInfo + 1] = cjson.decode(info[i])
        if localMembersInfo[#localMembersInfo].charID == CharInfo.getCharID() then
            setOwnerPlayerCurrentFloor(localMembersInfo[#localMembersInfo].floor)
        end
    end

    local armyPet = nil
    local armyPet1 = nil
    local armyPet2 = nil
    if #localMembersInfo == membersNum then
        print("localMembersInfo=",sz_T2S(localMembersInfo))
        for k, v in pairs(localMembersInfo) do
            local state = v.state or PLAYER_STATE.PLAYER_ALIVE
            if v.charID == CharInfo.getCharID() then
                if v.x < 1 or v.y < 1 or v.x > mapHeight or v.y > mapWidth then
                    CopyMapMgr.createPlayer(CharInfo.getCharID(), CharInfo.getNickName(), CharInfo.getSex(), v.fashions, 0, ownerBornIndexTbl[k] or ownerBornIndexTbl[1], (state == PLAYER_STATE.PLAYER_ALIVE), v.inBattle)
                else
                    CopyMapMgr.createPlayer(CharInfo.getCharID(), CharInfo.getNickName(), CharInfo.getSex(), v.fashions, 0, (v.x - 1)*mapWidth + v.y, (state == PLAYER_STATE.PLAYER_ALIVE), v.inBattle)
                end
                armyPet = {}
                armyPet[1] = v.pets or {}
                armyPet[2] = v.helperPets or {}
                --test data
                --[[
                armyPet1 = {}
                armyPet1.charID = v.charID
                armyPet1.playername = v.name
                armyPet1.m_pets = v.pets
                armyPet1.h_pets = v.helperPets
                armyPet2 = {}
                armyPet2.charID = v.charID
                armyPet2.playername = v.name
                armyPet2.m_pets = v.pets
                armyPet2.h_pets = v.helperPets
                ]]
                --CommonPetBar.show(SceneMgr.getRunningScene, armyPet)
                revivalNum = 0
                if v.items then
                    for key, val in pairs(v.items) do
                        if val.itemID == 1 then
                            revivalNum = val.num
                            break
                        end
                    end
                end
            else
                if v.x > 0 and v.y > 0 and v.x <= mapHeight and v.y <= mapWidth and v.floor == ownerPlayerCurrentFloor then
                    CopyMapMgr.createPlayer(v.charID, v.name, v.gender, v.fashions, 0, (v.x - 1)*mapWidth + v.y, (state == PLAYER_STATE.PLAYER_ALIVE), v.inBattle)
                end
                
                if not armyPet1 then
                    armyPet1 = {}
                    armyPet1.charID = v.charID
                    armyPet1.playername = v.name
                    armyPet1.m_pets = v.pets or {}
                    armyPet1.h_pets = v.helperPets or {}
                else
                    armyPet2 = {}
                    armyPet2.charID = v.charID
                    armyPet2.playername = v.name
                    armyPet2.m_pets = v.pets or {}
                    armyPet2.h_pets = v.helperPets or {}
                end
            end
        end
        
        TeamCopyTopBarMgr.show(SceneMgr.getRunningScene, copyID, armyPet, armyPet1, armyPet2, revivalNum)
        LtFuncMgr.showAdvName(nil, TeamMapInfo.getTeamFloorInfoById(copyID).name, ownerPlayerCurrentFloor + 1, false)
        TeamCopyMapMgr.setKillMonsterNum(killMonsterNum)
        CopyMapMgr.focusPlayer(CharInfo.getCharID())

        TeamCopyMapMgr.checkAllPlayerState()
        
        CopyMapLoadingMgr.hide("TeamCopyMapLoading")
    end
end

function TeamCopyMapMgr.updateLocalMembersPets(charID, mPets, hPets)
    for k, v in pairs(localMembersInfo) do
        if v.charID == charID then
            v.pets = mPets or {}
            v.helperPets = hPets or {}
            break
        end
    end
end

local function getLocalMembersPets(charID)
    for k, v in pairs(localMembersInfo) do
        if v.charID == charID then
            print("=====getLocalMembersPets v.pets=",sz_T2S(v.pets and v.pets or {}))
            return v.pets or {}, v.helperPets or {}
        end
    end
    return {}, {}
end

local function setPetsHp(pets, objID, hp)
    if pets then
        for i=1,#pets do
            if pets[i].objID == objID then
                pets[i].hp = hp
                return
            end
        end
    end
end

function TeamCopyMapMgr.updateLocalMembersPetsHp(charID, detail)
    for k, v in pairs(localMembersInfo) do
        if v.charID == charID then
            for i=1,#detail.objID do
                setPetsHp(v.pets, detail.objID[i], detail.hp[i])
            end
            break
        end
    end
end

local function setMonsterHpByBattleInfo(bInfo)
    for h=1,mapHeight do
        for w=1,mapWidth do
            local idx = (h - 1)*mapWidth + w
            local mInfo = localCopyMapInfo[idx]
            if mInfo.isDisplay == 0 and (mInfo.eventType == Proto.FDET_PVE or mInfo.eventType == Proto.FDET_BOSS) and mInfo.eventID == bInfo.monsterID then
                TeamCopyMapMgr.updateMonsterHp(h, w, bInfo.hp)
                return
            end
        end
    end
end

function TeamCopyMapMgr.addLocalBattleInfo(info)
    --local cjson = require("cjson")
    for i=1, #info do
        local bInfo = info[i]--cjson.decode(info[i])
        --localBattleInfo[#localBattleInfo + 1] = bInfo
        
        if bInfo.hp >= 0 then
            setMonsterHpByBattleInfo(bInfo)
        end
    end
end

function TeamCopyMapMgr.setMemberMoveTarget(info)
    if info.floor ~= ownerPlayerCurrentFloor then
        return
    end
    local isNewPlayer = true
    for i=1, #localMembersInfo do
        if localMembersInfo[i].charID == info.charID then
            if localMembersInfo[i].x > 0 and localMembersInfo[i].y > 0 and localMembersInfo[i].x <= mapHeight and localMembersInfo[i].y <= mapWidth and localMembersInfo[i].floor == ownerPlayerCurrentFloor then
                localMembersInfo[i].x = info.x
                localMembersInfo[i].y = info.y
                localMembersInfo[i].state = info.state or PLAYER_STATE.PLAYER_ALIVE
                isNewPlayer = false
            else
                localMembersInfo[i].x = info.x
                localMembersInfo[i].y = info.y
                localMembersInfo[i].floor = info.floor
                localMembersInfo[i].state = info.state or PLAYER_STATE.PLAYER_ALIVE
                isNewPlayer = true
                --table.remove(localMembersInfo, i)
                --membersNum = membersNum - 1
            end
            break
        end
    end

    if isNewPlayer then
        --localMembersInfo[#localMembersInfo + 1] = info
        --membersNum = membersNum + 1
        if SceneMgr.currentScene == "TeamCopyMapScene" then
            local state = info.state or PLAYER_STATE.PLAYER_ALIVE
            CopyMapMgr.createPlayer(info.charID, info.name, info.gender, info.fashions, 0, (info.x - 1)*mapWidth + info.y, (state == PLAYER_STATE.PLAYER_ALIVE))
        end
    elseif info.charID ~= CharInfo.getCharID() then
        if SceneMgr.currentScene == "TeamCopyMapScene" then
            CopyMapMgr.setPlayerTargetPosition(info.charID, (info.x - 1)*mapWidth + info.y)
        end
    end
end

function TeamCopyMapMgr.localMemberLeaveFloor(charID)
    for i=1, #localMembersInfo do
        if localMembersInfo[i].charID == charID then
            localMembersInfo[i].x = 0
            localMembersInfo[i].y = 0
            --table.remove(localMembersInfo, i)
            --membersNum = membersNum - 1
            if SceneMgr.currentScene == "TeamCopyMapScene" then
                CopyMapMgr.removePlayer(charID)
            end
            break
        end
    end
end

function TeamCopyMapMgr.localMemberLeaveTeam(charID)
    for i=1, #localMembersInfo do
        if localMembersInfo[i].charID == charID then
            table.remove(localMembersInfo, i)
            membersNum = membersNum - 1
            if SceneMgr.currentScene == "TeamCopyMapScene" then
                CopyMapMgr.removePlayer(charID)
                TeamCopyTopBarMgr.removePlayerTeamBoard(charID)
            end
            break
        end
    end
end

function TeamCopyMapMgr.syncMoving(targetIndex)
    TeamCopyInfo.TeamCopyMovingGrid(targetIndex, mapWidth)
end

local function monsterBattleCallback(detail)
    print("++++++++++monsterBattleCallback detail=",sz_T2S(detail))
    CopyMapLoadingMgr.hide("TeamCopyPVELoading")
    --[[
    if detail ~= nil then
        --BattleMapMgr.sendGameOver(detail.result,detail.me)
        local eventID = ownerPlayerPVEBattleInfo.eventID
        if eventID ~= nil then
            local x = ownerPlayerPVEBattleInfo.x
            local y = ownerPlayerPVEBattleInfo.y
            local monsterHp
            if detail.result == nil then
                detail.result = PLAYER_LOSE
                monsterHp = detail.enemy.hp[1]
            elseif detail.result == PLAYER_WIN then
                monsterHp = 0
            else
                monsterHp = detail.enemy.hp[1]
            end
            local battleDetails = {}
            if detail.me then
                for k,v in pairs(detail.me.objID) do
                    table.insert(battleDetails,detail.me.objID[k]..","..detail.me.hp[k])
                end
                
                TeamCopyMapMgr.updateLocalMembersPetsHp(CharInfo.getCharID(), detail.me)
            end
            TeamCopyInfo.TeamBattleEnd(detail.result, battleDetails, monsterHp, eventID, x, y)
        end
    end
    ]]
    --[[
    MapSeekerMgr.SeekFunc = function()
        if TeamCopyWinMgr.getChestID() then
            TeamCopyWinMgr.show(SceneMgr.getRunningScene, TeamCopyWinMgr.getChestID())
            TeamCopyWinMgr.setChestID(nil)
        end
    end
    ]]
end

local function isOwnerPlayerInPVEBattleCD(index)
    local timestamp
    if localCopyMapInfo[index].data == 1 then
        timestamp = localCopyMapInfo[index].lockedTime or 0
        if CharInfo.getServerTime() - timestamp >= ownerPlayerPVEBattleCD then
            return false
        end
    else
        return false
    end
    return true
end

local function isOwnerPlayerInChestAwardCD(index)
    return false
end

local function getPlayerCurrentState(charID)
    for k, v in pairs(localMembersInfo) do
        if v.charID == charID then
            return (v.state or PLAYER_STATE.PLAYER_ALIVE)
        end
    end
    return PLAYER_STATE.PLAYER_ALIVE
end

function TeamCopyMapMgr.notifyDisplayOrTriggerGrid(x, y)
    local index = (x - 1)*mapWidth + y
    if localCopyMapInfo[index].isDisplay == 1 then
        FamilyInfo.FamilyCopyDisplayGrid(x, y)
    elseif getPlayerCurrentState(CharInfo.getCharID()) == PLAYER_STATE.PLAYER_ALIVE then
        if localCopyMapInfo[index].eventType == Proto.FDET_PVE or localCopyMapInfo[index].eventType == Proto.FDET_BOSS then
            --if not isOwnerPlayerInPVEBattleCD(index) then
                --[[
                local mPets, hPets = getLocalMembersPets(CharInfo.getCharID())
                local mPets4Battle = {}
                for k, v in pairs(mPets) do
                    table.insert(mPets4Battle, v)
                end
                local hPets4Battle = {}
                for k, v in pairs(hPets) do
                    table.insert(hPets4Battle, v)
                end
                local monsterID4Battle = localCopyMapInfo[index].eventID
                local info = {true,{type = Proto.BTT_TEAMDUNGEON_MONSTER, pets = {monsterID4Battle}, mPets = mPets4Battle, hPets = hPets4Battle, callback = monsterBattleCallback}}
                ownerPlayerPVEBattleInfo = {timestamp = CharInfo.getServerTime(), eventID = localCopyMapInfo[index].eventID, x = x, y = y}
                print("++++++++++TeamCopyMap start PVE battle ownerPlayerPVEBattleInfo=",sz_T2S(info))
                BattleMapMgr.sendReBattleServe(info)
                ]]
                ownerPlayerPVEBattleInfo = {timestamp = CharInfo.getServerTime(), eventID = localCopyMapInfo[index].eventID, x = x, y = y}
                TeamCopyInfo.TeamDungeonBattleStart(localCopyMapInfo[index].eventID)
                BattleMapMgr.setBattleCallback(monsterBattleCallback)
            --else
            --    print("###############localCopyMapInfo PVE lock or in cd!!!index=",index)
            --end
        elseif localCopyMapInfo[index].eventType == Proto.FDET_RANDOMCHEST then
            if not isOwnerPlayerInChestAwardCD(index) then
                FamilyInfo.FamilyCopyTriggerGrid(x, y, function()
                    local info =  FamilyInfo.GetLocalFamilyMembersInfo()
                    if CharInfo.getFamilyID() ~= nil and info ~= nil then
                        local devote = FamilyDataInfo.getFamilyRandomChestInfoById(localCopyMapInfo[index].eventID).contribute
                        info[tostring(CharInfo.getCharID())].devotePoint = (info[tostring(CharInfo.getCharID())].devotePoint or 0) + devote
                        FamilyCopyTopBarMgr.updateDevote()
                    end
                end)
            end
        elseif localCopyMapInfo[index].eventType == Proto.FDET_ATTRIBUTECHANGE then
            FamilyInfo.FamilyCopyTriggerGrid(x, y)
        elseif localCopyMapInfo[index].eventType == Proto.FDET_PICKITEM then
            local itemID = TeamMapInfo.getTeamPickUpItemInfoById(localCopyMapInfo[index].eventID).itemID
            TeamCopyInfo.TeamCopyTriggerGrid(x, y, function()
                if itemID == 1 then
                    TeamCopyMapMgr.setRevivalNum(revivalNum + 1)
                end
            end)
        end
    end
end

function TeamCopyMapMgr.notifyChangeFloor(x, y)
    local isChangeFloor = false
    local index = (x - 1)*mapWidth + y
    if localCopyMapInfo[index].eventType == Proto.FDET_TRANS and localCopyMapInfo[index].isDisplay == 0 then
        local type = TeamMapInfo.getTeamTransferInfoById(localCopyMapInfo[index].eventID).type
        TeamCopyInfo.TeamChangeFloor(type)
        isChangeFloor = true
    end
    return isChangeFloor
end

function TeamCopyMapMgr.displayGrid(x, y)
    if #localCopyMapInfo > 0 then
        local index = (x - 1)*mapWidth + y
        localCopyMapInfo[index].isDisplay = 0
        if localCopyMapInfo[index].eventType == Proto.FDET_NONE then
            CopyMapMgr.clearGridBlock(index)
        elseif localCopyMapInfo[index].eventType == Proto.FDET_PVE then
            CopyMapMgr.setGridBlock(index, CopyMapMgr.TERRAIN_TYPE.MONSTER, nil, TeamMapInfo.getTeamMonsterInfoById(localCopyMapInfo[index].eventID).petnumber)
        elseif localCopyMapInfo[index].eventType == Proto.FDET_ATTRIBUTECHANGE then
            CopyMapMgr.setGridBlock(index, CopyMapMgr.TERRAIN_TYPE.BUFF)
        elseif localCopyMapInfo[index].eventType == Proto.FDET_RANDOMCHEST then
            CopyMapMgr.setGridBlock(index, CopyMapMgr.TERRAIN_TYPE.TREASURE, FamilyDataInfo.getFamilyRandomChestInfoById(localCopyMapInfo[index].eventID).picRes)
        elseif localCopyMapInfo[index].eventType == Proto.FDET_TRANS then
            local type = (TeamMapInfo.getTeamTransferInfoById(localCopyMapInfo[index].eventID).type == 1 and CopyMapMgr.TERRAIN_TYPE.DOOR_FORWARD or CopyMapMgr.TERRAIN_TYPE.DOOR_BACKWARD)
            CopyMapMgr.setGridBlock(index, type, TeamMapInfo.getTeamTransferInfoById(localCopyMapInfo[index].eventID).picRes)
        end
    end
end

function TeamCopyMapMgr.setLockPVEGrid(x, y, isLocked, lockedTime)
    if #localCopyMapInfo > 0 then
        local index = (x - 1)*mapWidth + y
        if localCopyMapInfo[index].eventType == Proto.FDET_PVE or localCopyMapInfo[index].eventType == Proto.FDET_BOSS then
            localCopyMapInfo[index].data = isLocked
            localCopyMapInfo[index].lockedTime = lockedTime
            if SceneMgr.currentScene == "TeamCopyMapScene" then
                CopyMapMgr.setHpBarState(index, isLocked)
            end
        end
    end
end

function TeamCopyMapMgr.setLockPVEGridByID(monsterID, charID, isLocked)
    TeamCopyMapMgr.setMemberBattleState(charID, isLocked)
    if SceneMgr.currentScene == "TeamCopyMapScene" then
        CopyMapMgr.setPlayerInBattle(charID, isLocked)
    end
    
    for h=1,mapHeight do
        for w=1,mapWidth do
            local index = (h - 1)*mapWidth + w
            if localCopyMapInfo[index].isDisplay == 0 and (localCopyMapInfo[index].eventType == Proto.FDET_PVE or localCopyMapInfo[index].eventType == Proto.FDET_BOSS) and localCopyMapInfo[index].eventID == monsterID then
                if isLocked == 1 then
                    localCopyMapInfo[index].battleCnt = (localCopyMapInfo[index].battleCnt or 0) + 1
                else
                    localCopyMapInfo[index].battleCnt = (localCopyMapInfo[index].battleCnt or 0) - 1
                    if localCopyMapInfo[index].battleCnt < 0 then
                        localCopyMapInfo[index].battleCnt = 0
                    end
                end
                if localCopyMapInfo[index].battleCnt > 0 then
                    localCopyMapInfo[index].data = 1
                else
                    localCopyMapInfo[index].data = 0
                end
                if SceneMgr.currentScene == "TeamCopyMapScene" then
                    CopyMapMgr.setHpBarState(index, localCopyMapInfo[index].data)
                end
                return
            end
        end
    end
end

function TeamCopyMapMgr.updateMonsterHp(x, y, hp)
    if #localCopyMapInfo > 0 then
        local index = (x - 1)*mapWidth + y
        if localCopyMapInfo[index].eventType == Proto.FDET_PVE or localCopyMapInfo[index].eventType == Proto.FDET_BOSS then
            local maxHp = TeamMapInfo.getTeamMonsterInfoById(localCopyMapInfo[index].eventID).maxHP
            localCopyMapInfo[index].hpPercent = hp/maxHp * 100.0
            if SceneMgr.currentScene == "TeamCopyMapScene" then
                CopyMapMgr.setHpBarState(index, nil, localCopyMapInfo[index].hpPercent)
            end
        end
    end
end

function TeamCopyMapMgr.cleanGrid(x, y)
    if #localCopyMapInfo > 0 then
        local index = (x - 1)*mapWidth + y
        if SceneMgr.currentScene == "TeamCopyMapScene" then
            if localCopyMapInfo[index].eventType == Proto.FDET_PVE then
                CopyMapMgr.removeMonster(index, TeamMapInfo.getTeamMonsterInfoById(localCopyMapInfo[index].eventID).petnumber)
            elseif localCopyMapInfo[index].eventType == Proto.FDET_ATTRIBUTECHANGE or localCopyMapInfo[index].eventType == Proto.FDET_RANDOMCHEST then
                CopyMapMgr.removeEffect(index)
            elseif localCopyMapInfo[index].eventType == Proto.FDET_BOSS then
                CopyMapMgr.removeMonster(index, TeamMapInfo.getTeamMonsterInfoById(localCopyMapInfo[index].eventID).petnumber, true)
            end
            CopyMapMgr.clearGridBlock(index)
            TeamCopyMapMgr.playCleanGridEffect(x, y)
        end
        localCopyMapInfo[index].eventType = Proto.FDET_NONE
        localCopyMapInfo[index].eventID = 0
    end
end

function TeamCopyMapMgr.playCleanGridEffect(x, y)
    CopyMapMgr.playDisplayGridEffect(x, y)
end

function TeamCopyMapMgr.playChangeFloorEffect()
    CopyMapMgr.playChangeFloorEffect(CharInfo.getCharID())
end

local function resetPetsHpByPlayerState(charID, state)
    if state then
        local info = {charID = charID, pets = {}}
        for k, v in pairs(localMembersInfo) do
            if v.charID == charID then
                for key, val in pairs(v.pets) do
                    val.hp = (state == PLAYER_STATE.PLAYER_ALIVE and val.hpmax or 0)
                    table.insert(info.pets, {hp = val.hp, objID = val.objID})
                end
                
                if state == PLAYER_STATE.PLAYER_ALIVE then
                    for key, val in pairs(v.helperPets) do
                        val.hp = val.hpmax
                        table.insert(info.pets, {hp = val.hp, objID = val.objID})
                    end
                end
                TeamCopyTopBarMgr.updatePetsHpPercent(info)
                break
            end
        end
    end
end

function TeamCopyMapMgr.checkAllPlayerState()
    for k, v in pairs(localMembersInfo) do
        local state = v.state or PLAYER_STATE.PLAYER_ALIVE
        if state == PLAYER_STATE.PLAYER_ALIVE then
            return
        end
    end

    DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 1, "team56", function()
        TeamCopyTopBarMgr.hideUI()
    end)
end

function TeamCopyMapMgr.changePlayerCurrentState(charID, newState)
    for k, v in pairs(localMembersInfo) do
        if v.charID == charID then
            v.state = newState
            if SceneMgr.currentScene == "TeamCopyMapScene" then
                CopyMapMgr.changePlayerState(charID, (newState == PLAYER_STATE.PLAYER_ALIVE))
            end
            --[[
            if newState == PLAYER_STATE.PLAYER_DEAD and charID == CharInfo.getCharID() and revivalNum > 0 then
                TeamCopyInfo.ReviveCharacter(charID, function()
                    TeamCopyMapMgr.setRevivalNum(revivalNum - 1)
                end)
            end
            ]]
            resetPetsHpByPlayerState(charID, newState)
            break
        end
    end
    
    if newState == PLAYER_STATE.PLAYER_DEAD then
        TeamCopyMapMgr.checkAllPlayerState()
    end
end

function TeamCopyMapMgr.pickPlayer(charID)
    if charID ~= CharInfo.getCharID() and getPlayerCurrentState(charID) == PLAYER_STATE.PLAYER_DEAD and revivalNum > 0 then
        DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 2, "team47", function()
            TeamCopyInfo.ReviveCharacter(charID, function()
                TeamCopyMapMgr.setRevivalNum(revivalNum - 1)
            end)
        end)
    end
end

function TeamCopyMapMgr.forceQuitTeamCopy()
    DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 1, "team53", function()
        TeamCopyMapMgr.cleanLocalCopyMapInfo()
        --TeamInfo.exitTeam()
        --TeamInfo.checkTeamWhenLogin()
        local TeamSend = require("src.Net.Send.TeamSend")
        NetInterface.sendWithBlock("GC_GetMyTeam_Ack", function()
            TeamSend.sendCG_GetMyTeam_Req({})
        end)
        TownChatMgr.isTeamChat(false)
        --TownChatMgr.teamBattleChat(false)
        TownChatMgr.setExitTeamBattle()
        SceneMgr.replaceScene(SceneMgr.getRunningScene, "TownScene")
    end)
end

return TeamCopyMapMgr