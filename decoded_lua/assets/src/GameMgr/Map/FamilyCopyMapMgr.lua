local FamilyCopyMapMgr = {}

local resName = ""
local mapWidth = 0
local mapHeight = 0
local gridNum = 0
local buffNum = 0
local membersNum = 0
local battleNum = 0
local localCopyMapInfo = {}
local ownerBornIndexTbl = {}
local localBuffInfo = {}
local localMembersInfo = {}
local localBattleInfo = {}
local ownerPlayerPVEBattleInfo = {}
local ownerPlayerPVEBattleCD = 5 * 60
local ownerPlayerCurrentFloor = 0

function FamilyCopyMapMgr.Init()
    print("FamilyCopyMapMgr初始化")
    resName = "Map/Family/CopyMap.csb"
    mapWidth = 0
    mapHeight = 0
    gridNum = 0
    buffNum = 0
    membersNum = 0
    battleNum = 0
    localCopyMapInfo = {}
    ownerBornIndexTbl = {}
    localBuffInfo[Proto.FBT_PHYSICALATTACK] = 0
    localBuffInfo[Proto.FBT_PHYSICALDEFENSE] = 0
    localBuffInfo[Proto.FBT_MAGICATTACK] = 0
    localBuffInfo[Proto.FBT_MAGICDEFENSE] = 0
    localBuffInfo[Proto.FBT_HP] = 0
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
                CopyMapMgr.removeMonster(idx, FamilyDataInfo.getFamilyMonsterInfoById(localCopyMapInfo[idx].eventID).petnumber)
            end
        end
    end

    CopyMapMgr.cleanMap()
end

function FamilyCopyMapMgr.getLocalCopyMapSize()
    return mapWidth, mapHeight
end

function FamilyCopyMapMgr.cleanLocalCopyMapInfo()
    FamilyInfo.reset()
    cleanMap()
    
    mapWidth = 0
    mapHeight = 0
    gridNum = 0
    buffNum = 0
    membersNum = 0
    battleNum = 0
    localCopyMapInfo = {}
    ownerBornIndexTbl = {}
    localBuffInfo[Proto.FBT_PHYSICALATTACK] = 0
    localBuffInfo[Proto.FBT_PHYSICALDEFENSE] = 0
    localBuffInfo[Proto.FBT_MAGICATTACK] = 0
    localBuffInfo[Proto.FBT_MAGICDEFENSE] = 0
    localBuffInfo[Proto.FBT_HP] = 0
    localMembersInfo = {}
    localBattleInfo = {}
    --ownerPlayerPVEBattleInfo = {}
    ownerPlayerCurrentFloor = 0
end

function FamilyCopyMapMgr.quitMap()
    CopyMapMgr.quitMap()
    
    mapWidth = 0
    mapHeight = 0
    gridNum = 0
    buffNum = 0
    membersNum = 0
    battleNum = 0
    localCopyMapInfo = {}
    ownerBornIndexTbl = {}
    localBuffInfo[Proto.FBT_PHYSICALATTACK] = 0
    localBuffInfo[Proto.FBT_PHYSICALDEFENSE] = 0
    localBuffInfo[Proto.FBT_MAGICATTACK] = 0
    localBuffInfo[Proto.FBT_MAGICDEFENSE] = 0
    localBuffInfo[Proto.FBT_HP] = 0
    localMembersInfo = {}
    localBattleInfo = {}
    --ownerPlayerPVEBattleInfo = {}
    ownerPlayerCurrentFloor = 0
end

function FamilyCopyMapMgr.setGridNum(num)
    gridNum = num
    localCopyMapInfo = {}
    ownerBornIndexTbl = {}
    CopyMapLoadingMgr.show(SceneMgr.getRunningScene, num/60, "FamilyCopyMapLoading")
end

function FamilyCopyMapMgr.setBuffNum(num)
    buffNum = num
    localBuffInfo[Proto.FBT_PHYSICALATTACK] = 0
    localBuffInfo[Proto.FBT_PHYSICALDEFENSE] = 0
    localBuffInfo[Proto.FBT_MAGICATTACK] = 0
    localBuffInfo[Proto.FBT_MAGICDEFENSE] = 0
    localBuffInfo[Proto.FBT_HP] = 0
end

function FamilyCopyMapMgr.setMembersNum(num)
    membersNum = num
    localMembersInfo = {}
end

function FamilyCopyMapMgr.setBattleNum(num)
    battleNum = num
    localBattleInfo = {}
end

function FamilyCopyMapMgr.addLocalCopyMapInfo(info)
    local cjson = require("cjson")
    for i=1, #info do
        localCopyMapInfo[#localCopyMapInfo + 1] = cjson.decode(info[i])
    end
    if #localCopyMapInfo == gridNum then
        print("localCopyMapInfo=",sz_T2S(localCopyMapInfo))
        mapWidth = localCopyMapInfo[gridNum].y
        mapHeight = localCopyMapInfo[gridNum].x
        --print("addLocalMapInfo",mapWidth,mapHeight)
        CopyMapMgr.createWithRes(SceneMgr.getRunningScene, resName, mapWidth, mapHeight, 1)
        ownerBornIndexTbl = {}
        for h=1,mapHeight do
            for w=1,mapWidth do
                local idx = (h - 1)*mapWidth + w
                if localCopyMapInfo[idx].eventType == Proto.FDET_OBSTACLE then
                    localCopyMapInfo[idx].isDisplay = 0
                    CopyMapMgr.setGridBlock(idx, CopyMapMgr.TERRAIN_TYPE.ROCK, FamilyDataInfo.getFamilyObstacleInfoById(localCopyMapInfo[idx].eventID).iconRes)
                elseif localCopyMapInfo[idx].eventType == Proto.FDET_START then
                    localCopyMapInfo[idx].isDisplay = 0
                    ownerBornIndexTbl[#ownerBornIndexTbl + 1] = idx
                else
                    if localCopyMapInfo[idx].isDisplay == 1 then
                        CopyMapMgr.setGridBlock(idx, CopyMapMgr.TERRAIN_TYPE.TREE)
                    else
                        if localCopyMapInfo[idx].eventType == Proto.FDET_PVE then
                            CopyMapMgr.setGridBlock(idx, CopyMapMgr.TERRAIN_TYPE.MONSTER, nil, FamilyDataInfo.getFamilyMonsterInfoById(localCopyMapInfo[idx].eventID).petnumber, localCopyMapInfo[idx].data, false, localCopyMapInfo[idx].hpPercent)
                        elseif localCopyMapInfo[idx].eventType == Proto.FDET_ATTRIBUTECHANGE then
                            CopyMapMgr.setGridBlock(idx, CopyMapMgr.TERRAIN_TYPE.BUFF)
                        elseif localCopyMapInfo[idx].eventType == Proto.FDET_RANDOMCHEST then
                            CopyMapMgr.setGridBlock(idx, CopyMapMgr.TERRAIN_TYPE.TREASURE, FamilyDataInfo.getFamilyRandomChestInfoById(localCopyMapInfo[idx].eventID).picRes)
                        elseif localCopyMapInfo[idx].eventType == Proto.FDET_TRANS then
                            local type = (FamilyDataInfo.getFamilyTransferInfoById(localCopyMapInfo[idx].eventID).type == 1 and CopyMapMgr.TERRAIN_TYPE.DOOR_FORWARD or CopyMapMgr.TERRAIN_TYPE.DOOR_BACKWARD)
                            CopyMapMgr.setGridBlock(idx, type, FamilyDataInfo.getFamilyTransferInfoById(localCopyMapInfo[idx].eventID).picRes)
                        end
                    end
                end
            end
        end
    end
end

local function updateBuffCount()
    FamilyCopyTopBarMgr.refreshBuffInfo(localBuffInfo)
end

function FamilyCopyMapMgr.addLocalBuffInfo(info, bIncBuffNum)
    if bIncBuffNum then
        buffNum = buffNum + 1
    end
    for i=1, #info do
        local buffType = FamilyDataInfo.getFamilyAttributeChangeInfoById(tonumber(info[i])).type
        if localBuffInfo[buffType] == nil then
            localBuffInfo[buffType] = 1
        else
            localBuffInfo[buffType] = localBuffInfo[buffType] + 1
        end
    end
    
    if SceneMgr.currentScene == "FamilyCopyMapScene" then
        local localBuffCount = 0
        for k, v in pairs(localBuffInfo) do
            localBuffCount = localBuffCount + v
        end

        if localBuffCount == buffNum then
            updateBuffCount()
        end
    end
end

local function setOwnerPlayerCurrentFloor(floor)
    ownerPlayerCurrentFloor = floor
    FamilyCopyTopBarMgr.setCurrentFloor(floor + 1)
end

function FamilyCopyMapMgr.incOwnerPlayerCurrentFloor()
    setOwnerPlayerCurrentFloor(ownerPlayerCurrentFloor + 1)
end

function FamilyCopyMapMgr.decOwnerPlayerCurrentFloor()
    setOwnerPlayerCurrentFloor(ownerPlayerCurrentFloor - 1)
end

function FamilyCopyMapMgr.addLocalMembersInfo(info)
    local cjson = require("cjson")
    for i=1, #info do
        localMembersInfo[#localMembersInfo + 1] = cjson.decode(info[i])
        if localMembersInfo[#localMembersInfo].charID == CharInfo.getCharID() then
            setOwnerPlayerCurrentFloor(localMembersInfo[#localMembersInfo].floor)
        end
    end
    
    if #localMembersInfo == membersNum then
        for k, v in pairs(localMembersInfo) do
            if v.charID == CharInfo.getCharID() then
                if v.x < 1 or v.y < 1 then
                    CopyMapMgr.createPlayer(CharInfo.getCharID(), CharInfo.getNickName(), CharInfo.getSex(), CharInfo.getCurfashion(), 0, ownerBornIndexTbl[math.random(1,#ownerBornIndexTbl)])
                else
                    CopyMapMgr.createPlayer(CharInfo.getCharID(), CharInfo.getNickName(), CharInfo.getSex(), CharInfo.getCurfashion(), 0, (v.x - 1)*mapWidth + v.y)
                end
            else
                if v.x > 0 and v.y > 0 and v.floor == ownerPlayerCurrentFloor then
                    CopyMapMgr.createPlayer(v.charID, v.name, v.gender, v.fashions, 0, (v.x - 1)*mapWidth + v.y)
                end
            end
        end
    end
    
    CopyMapMgr.focusPlayer(CharInfo.getCharID())
end

local function setMonsterHpByBattleInfo(bInfo)
    for h=1,mapHeight do
        for w=1,mapWidth do
            local idx = (h - 1)*mapWidth + w
            local mInfo = localCopyMapInfo[idx]
            if mInfo.isDisplay == 0 and mInfo.eventType == Proto.FDET_PVE and mInfo.eventID == bInfo.monsterID then
                FamilyCopyMapMgr.updateMonsterHp(h, w, bInfo.hp)
                return
            end
        end
    end
end

function FamilyCopyMapMgr.addLocalBattleInfo(info)
    local cjson = require("cjson")
    for i=1, #info do
        local bInfo = cjson.decode(info[i])
        localBattleInfo[#localBattleInfo + 1] = bInfo

        if bInfo.hp > 0 then
            setMonsterHpByBattleInfo(bInfo)
        end
    end
end

function FamilyCopyMapMgr.setMemberMoveTarget(info)
    if info.floor ~= ownerPlayerCurrentFloor then
        return
    end
    local isNewPlayer = true
    for i=1, #localMembersInfo do
        if localMembersInfo[i].charID == info.charID then
            if localMembersInfo[i].x > 0 and localMembersInfo[i].y > 0 and localMembersInfo[i].floor == ownerPlayerCurrentFloor then
                localMembersInfo[i].x = info.x
                localMembersInfo[i].y = info.y
                isNewPlayer = false
            else
                localMembersInfo[i].x = info.x
                localMembersInfo[i].y = info.y
                localMembersInfo[i].floor = info.floor
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
        if SceneMgr.currentScene == "FamilyCopyMapScene" then
            CopyMapMgr.createPlayer(info.charID, info.name, info.gender, info.fashions, 0, (info.x - 1)*mapWidth + info.y)
        end
    elseif info.charID ~= CharInfo.getCharID() then
        if SceneMgr.currentScene == "FamilyCopyMapScene" then
            CopyMapMgr.setPlayerTargetPosition(info.charID, (info.x - 1)*mapWidth + info.y)
        end
    end
end

function FamilyCopyMapMgr.localMemberLeaveFloor(charID)
    for i=1, #localMembersInfo do
        if localMembersInfo[i].charID == charID then
            localMembersInfo[i].x = 0
            localMembersInfo[i].y = 0
            --table.remove(localMembersInfo, i)
            --membersNum = membersNum - 1
            if SceneMgr.currentScene == "FamilyCopyMapScene" then
                CopyMapMgr.removePlayer(charID)
            end
            break
        end
    end
end

function FamilyCopyMapMgr.syncMoving(targetIndex)
    FamilyInfo.FamilyCopyMovingGrid(targetIndex, mapWidth)
end

local function monsterBattleCallback(detail)
    print("++++++++++monsterBattleCallback detail=",sz_T2S(detail))
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
                --[[
                local info =  FamilyInfo.GetLocalFamilyMembersInfo()
                if CharInfo.getFamilyID() ~= nil and info ~= nil then
                    local devote = FamilyDataInfo.getFamilyMonsterInfoById(eventID).contribute
                    info[tostring(CharInfo.getCharID())].devotePoint = (info[tostring(CharInfo.getCharID())].devotePoint or 0) + devote
                    FamilyCopyTopBarMgr.updateDevote()
                end
                ]]
            else
                monsterHp = detail.enemy.hp[1]
            end
            local dps = 200
            FamilyInfo.FamilyBattleEnd(detail.result, eventID, monsterHp, dps, x, y)
        end
    end
end

local function isOwnerPlayerInPVEBattleCD(index)
    local timestamp
    if localCopyMapInfo[index].data == 1 then
        timestamp = localCopyMapInfo[index].lockedTime or 0
        if CharInfo.getServerTime() - timestamp >= ownerPlayerPVEBattleCD then
            return false
        end
    else
        timestamp = ownerPlayerPVEBattleInfo.timestamp or 0
        if index == ownerPlayerPVEBattleInfo.index then
            if CharInfo.getServerTime() - timestamp >= ownerPlayerPVEBattleCD then
                return false
            end
        else
            return false
        end
    end
    return true
end

local function isOwnerPlayerInChestAwardCD(index)
    local timestamp = localCopyMapInfo[index].lockedTime or 0
    if CharInfo.getServerTime() - timestamp >= ownerPlayerPVEBattleCD then
        return false
    end
    return true
end

function FamilyCopyMapMgr.notifyDisplayOrTriggerGrid(x, y)
    local index = (x - 1)*mapWidth + y
    if localCopyMapInfo[index].isDisplay == 1 then
        if CharInfo.getFamilyDungeonStepNumber() < 1 then
            StandardTipsMgr.show(1,"family102")
            return
        end
        FamilyInfo.FamilyCopyDisplayGrid(x, y)
    else
        if localCopyMapInfo[index].eventType == Proto.FDET_PVE then
            if CharInfo.getFamilyDungeonStepNumber() < 1 then
                StandardTipsMgr.show(1,"family102")
                return
            end
            if not isOwnerPlayerInPVEBattleCD(index) then
                local info = {true,{type = Proto.BTT_FAMILYDUNGEON_MONSTER, pets = {localCopyMapInfo[index].eventID}, callback = monsterBattleCallback}}
                ownerPlayerPVEBattleInfo = {timestamp = CharInfo.getServerTime(), eventID = localCopyMapInfo[index].eventID, x = x, y = y}
                --print("++++++++++start PVE battle ownerPlayerPVEBattleInfo=",sz_T2S(ownerPlayerPVEBattleInfo))
                BattleMapMgr.sendReBattleServe(info)
            else
                print("###############localCopyMapInfo PVE lock or in cd!!!index=",index)
            end
        elseif localCopyMapInfo[index].eventType == Proto.FDET_RANDOMCHEST then
            if CharInfo.getFamilyDungeonStepNumber() < 1 then
                StandardTipsMgr.show(1,"family102")
                return
            end
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
            if CharInfo.getFamilyDungeonStepNumber() < 1 then
                StandardTipsMgr.show(1,"family102")
                return
            end
            FamilyInfo.FamilyCopyTriggerGrid(x, y)
        end
    end
end

function FamilyCopyMapMgr.notifyChangeFloor(x, y)
    local isChangeFloor = false
    local index = (x - 1)*mapWidth + y
    if localCopyMapInfo[index].eventType == Proto.FDET_TRANS and localCopyMapInfo[index].isDisplay == 0 then
        local type = FamilyDataInfo.getFamilyTransferInfoById(localCopyMapInfo[index].eventID).type
        FamilyInfo.FamilyChangeFloor(type)
        isChangeFloor = true
    end
    return isChangeFloor
end

function FamilyCopyMapMgr.displayGrid(x, y)
    if #localCopyMapInfo > 0 then
        local index = (x - 1)*mapWidth + y
        localCopyMapInfo[index].isDisplay = 0
        if SceneMgr.currentScene == "FamilyCopyMapScene" then
            if localCopyMapInfo[index].eventType == Proto.FDET_NONE then
                CopyMapMgr.clearGridBlock(index)
            elseif localCopyMapInfo[index].eventType == Proto.FDET_PVE then
                CopyMapMgr.setGridBlock(index, CopyMapMgr.TERRAIN_TYPE.MONSTER, nil, FamilyDataInfo.getFamilyMonsterInfoById(localCopyMapInfo[index].eventID).petnumber)
            elseif localCopyMapInfo[index].eventType == Proto.FDET_ATTRIBUTECHANGE then
                CopyMapMgr.setGridBlock(index, CopyMapMgr.TERRAIN_TYPE.BUFF)
            elseif localCopyMapInfo[index].eventType == Proto.FDET_RANDOMCHEST then
                CopyMapMgr.setGridBlock(index, CopyMapMgr.TERRAIN_TYPE.TREASURE, FamilyDataInfo.getFamilyRandomChestInfoById(localCopyMapInfo[index].eventID).picRes)
            elseif localCopyMapInfo[index].eventType == Proto.FDET_TRANS then
                local type = (FamilyDataInfo.getFamilyTransferInfoById(localCopyMapInfo[index].eventID).type == 1 and CopyMapMgr.TERRAIN_TYPE.DOOR_FORWARD or CopyMapMgr.TERRAIN_TYPE.DOOR_BACKWARD)
                CopyMapMgr.setGridBlock(index, type, FamilyDataInfo.getFamilyTransferInfoById(localCopyMapInfo[index].eventID).picRes)
            end
        end
    end
end

function FamilyCopyMapMgr.setLockPVEGrid(x, y, isLocked, lockedTime)
    if #localCopyMapInfo > 0 then
        local index = (x - 1)*mapWidth + y
        if localCopyMapInfo[index].eventType == Proto.FDET_PVE then
            localCopyMapInfo[index].data = isLocked
            localCopyMapInfo[index].lockedTime = lockedTime
            if SceneMgr.currentScene == "FamilyCopyMapScene" then
                CopyMapMgr.setHpBarState(index, isLocked)
            end
        end
    end
end

function FamilyCopyMapMgr.updateMonsterHp(x, y, hp)
    if #localCopyMapInfo > 0 then
        local index = (x - 1)*mapWidth + y
        if localCopyMapInfo[index].eventType == Proto.FDET_PVE then
            local maxHp = FamilyDataInfo.getFamilyMonsterInfoById(localCopyMapInfo[index].eventID).maxHP
            localCopyMapInfo[index].hpPercent = hp/maxHp * 100.0
            if SceneMgr.currentScene == "FamilyCopyMapScene" then
                CopyMapMgr.setHpBarState(index, nil, localCopyMapInfo[index].hpPercent)
            end
        end
    end
end

function FamilyCopyMapMgr.cleanGrid(x, y)
    if #localCopyMapInfo > 0 then
        local index = (x - 1)*mapWidth + y
        if SceneMgr.currentScene == "FamilyCopyMapScene" then
            if localCopyMapInfo[index].eventType == Proto.FDET_PVE then
                CopyMapMgr.removeMonster(index, FamilyDataInfo.getFamilyMonsterInfoById(localCopyMapInfo[index].eventID).petnumber)
            elseif localCopyMapInfo[index].eventType == Proto.FDET_ATTRIBUTECHANGE or localCopyMapInfo[index].eventType == Proto.FDET_RANDOMCHEST then
                CopyMapMgr.removeEffect(index)
            end
            CopyMapMgr.clearGridBlock(index)
        end
        localCopyMapInfo[index].eventType = Proto.FDET_NONE
    end
end

function FamilyCopyMapMgr.playDisplayGridEffect(x, y)
    CopyMapMgr.playDisplayGridEffect(x, y)
end

function FamilyCopyMapMgr.playChangeFloorEffect()
    CopyMapMgr.playChangeFloorEffect(CharInfo.getCharID())
end

return FamilyCopyMapMgr