local LostTowerMgr = {}

LostTowerMgr.LtMapID = 0

-- 千层塔事件未触发补救检查
LostTowerMgr.preCheckData = {}

LostTowerMgr.LtMapData = {}

LostTowerMgr.playerPosition = 0

LostTowerMgr.firstSend  = true

LostTowerMgr.newCells   = {}  -- 改善移动协议
LostTowerMgr.movedCells = {}
LostTowerMgr.firedCells = {}

LostTowerMgr.currentFloor = 1
LostTowerMgr.weekMaxFloor = 1
LostTowerMgr.maxFloor     = 1

LostTowerMgr.previousStepNum    = -1
LostTowerMgr.stepNumber         = 0
LostTowerMgr.stepAdded          = 0   -- 定时恢复步数
LostTowerMgr.previousPoint      = -1
LostTowerMgr.points             = 0   -- 成就点数
LostTowerMgr.weekMaxPoints      = 0

LostTowerMgr.battleAwards = nil

LostTowerMgr.stepMaxAdditional  = 0   -- 步数上限附加

LostTowerMgr.stepRefreshTime = nil

LostTowerMgr.recordingPoint = 1

LostTowerMgr._CLOSED     = 0
LostTowerMgr._INGAME     = LostTowerMgr._CLOSED + 1    -- 游戏中
LostTowerMgr._BATTLING   = LostTowerMgr._INGAME + 1  -- 战斗

LostTowerMgr.STATE = LostTowerMgr._CLOSED

local LtMapOption = require("src.GameMgr.LostTower.LtMapOption")

---副本[方格所有信息]初始化
local function initAllInfos()
    local floors = 1
    for j=1, floors do
        SearchingMapMgr.floorEventStateTbl["floor"..j] = {}
        SearchingMapMgr.floorTargetBlocks["floor"..j] = {}
        SearchingMapMgr.floorMapInfoTbl["floor"..j] = {}
        SearchingMapMgr.floorEventTbl["floor"..j] = {}
        SearchingMapMgr.floorItemTbl["floor"..j] = {}
        SearchingMapMgr.floorMstrDefendTbl["floor"..j] = {}
        SearchingMapMgr.floorEnvTable["floor"..j] = {}
        SearchingMapMgr.sceneID["floor"..j] = {}
        for k=1 ,LtMapOption.getMapSize() do
            SearchingMapMgr.floorMapInfoTbl["floor"..j][k] = 2
            SearchingMapMgr.floorEventTbl["floor"..j][k] = 0
            SearchingMapMgr.floorEventStateTbl["floor"..j][k] = 1
            SearchingMapMgr.floorItemTbl["floor"..j][k] = {}
            SearchingMapMgr.floorTargetBlocks["floor"..j][k] = "0"
            SearchingMapMgr.floorMstrDefendTbl["floor"..j][k] = 0
            SearchingMapMgr.floorEnvTable["floor"..j][k] = {fogRes = "",terrRes = "",}
            SearchingMapMgr.sceneID["floor"..j][k] = 0
        end
    end
end

function LostTowerMgr.Init()
    LostTowerMgr.playerPosition     = 0
    LostTowerMgr.currentFloor       = 1
    LostTowerMgr.maxFloor           = 1
    LostTowerMgr.stepNumber         = 0
    LostTowerMgr.stepAdded          = 0
    LostTowerMgr.points             = 0
    LostTowerMgr.weekMaxPoints      = 0
    LostTowerMgr.stepRefreshTime    = nil
    
    -- 战斗奖励
    LostTowerMgr.battleAwards = nil
    
    LostTowerMgr.stepMaxAdditional  = 0

    LostTowerMgr.newCells   = {}
    LostTowerMgr.firedCells = {}
end

local globalhandler

local REQ_SUCCESS = 0

function LostTowerMgr.sendRecoverStepReq(callback)
    NetInterface.send("GC_RECOVERSTEPNUMBER_ACK", function()
        local LostTowerSend = require("src.Net.Send.LostTowerSend")
        LostTowerSend.sendCG_RecoverStepNumber_Req()
    end, function()
        if callback then callback() end
    end)
end

LostTowerMgr.eventNumber = 0
LostTowerMgr.enterFunc = nil

function LostTowerMgr.sendCreateReq(callback)
    SearchingMapMgr.currAdventure = 1
--    if not NetInterface.isConnect then
--        local cjson = require("cjson")
--        local LostTowerData = "{\"armys\":{\"0\":{\"objID\":1},\"1\":{\"objID\":2},\"2\":{\"objID\":4},\"3\":{\"objID\":5},\"4\":{\"objID\":20}},\"currentFloor\":1,\"events\":{\"0\":{\"eventID\":1,\"flo\":0,\"sceneID\":8,\"type\":15,\"x\":1,\"xyID\":6,\"y\":1},\"1\":{\"eventID\":0,\"flo\":0,\"sceneID\":8,\"type\":0,\"x\":1,\"xyID\":12,\"y\":2},\"10\":{\"eventID\":66,\"flo\":0,\"sceneID\":8,\"type\":2,\"x\":2,\"xyID\":13,\"y\":2},\"11\":{\"eventID\":0,\"flo\":0,\"sceneID\":8,\"type\":0,\"x\":2,\"xyID\":19,\"y\":3},\"12\":{\"eventID\":66,\"flo\":0,\"sceneID\":8,\"type\":2,\"x\":2,\"xyID\":25,\"y\":4},\"13\":{\"eventID\":8000,\"flo\":0,\"sceneID\":8,\"type\":8,\"x\":2,\"xyID\":31,\"y\":5},\"14\":{\"eventID\":2,\"flo\":0,\"sceneID\":8,\"type\":3,\"x\":2,\"xyID\":37,\"y\":6},\"15\":{\"eventID\":10,\"flo\":0,\"sceneID\":8,\"type\":3,\"x\":2,\"xyID\":43,\"y\":7},\"16\":{\"eventID\":0,\"flo\":0,\"sceneID\":8,\"type\":0,\"x\":2,\"xyID\":49,\"y\":8},\"17\":{\"eventID\":0,\"flo\":0,\"sceneID\":8,\"type\":0,\"x\":2,\"xyID\":55,\"y\":9},\"18\":{\"eventID\":2,\"flo\":0,\"sceneID\":8,\"type\":3,\"x\":3,\"xyID\":8,\"y\":1},\"19\":{\"eventID\":8000,\"flo\":0,\"sceneID\":8,\"type\":8,\"x\":3,\"xyID\":14,\"y\":2},\"2\":{\"eventID\":1,\"flo\":0,\"sceneID\":8,\"type\":1,\"x\":1,\"xyID\":18,\"y\":3},\"20\":{\"eventID\":2,\"flo\":0,\"sceneID\":8,\"type\":3,\"x\":3,\"xyID\":20,\"y\":3},\"21\":{\"eventID\":2,\"flo\":0,\"sceneID\":8,\"type\":3,\"x\":3,\"xyID\":26,\"y\":4},\"22\":{\"eventID\":2,\"flo\":0,\"sceneID\":8,\"type\":15,\"x\":3,\"xyID\":32,\"y\":5},\"23\":{\"eventID\":0,\"flo\":0,\"sceneID\":8,\"type\":0,\"x\":3,\"xyID\":38,\"y\":6},\"24\":{\"eventID\":0,\"flo\":0,\"sceneID\":8,\"type\":0,\"x\":3,\"xyID\":44,\"y\":7},\"25\":{\"eventID\":2,\"flo\":0,\"sceneID\":8,\"type\":3,\"x\":3,\"xyID\":50,\"y\":8},\"26\":{\"eventID\":1,\"flo\":0,\"sceneID\":8,\"type\":1,\"x\":3,\"xyID\":56,\"y\":9},\"27\":{\"eventID\":2,\"flo\":0,\"sceneID\":8,\"type\":3,\"x\":4,\"xyID\":9,\"y\":1},\"28\":{\"eventID\":0,\"flo\":0,\"sceneID\":8,\"type\":0,\"x\":4,\"xyID\":15,\"y\":2},\"29\":{\"eventID\":1,\"flo\":0,\"sceneID\":8,\"type\":1,\"x\":4,\"xyID\":21,\"y\":3},\"3\":{\"eventID\":10,\"flo\":0,\"sceneID\":8,\"type\":3,\"x\":1,\"xyID\":24,\"y\":4},\"30\":{\"eventID\":2,\"flo\":0,\"sceneID\":8,\"type\":3,\"x\":4,\"xyID\":27,\"y\":4},\"31\":{\"eventID\":66,\"flo\":0,\"sceneID\":8,\"type\":2,\"x\":4,\"xyID\":33,\"y\":5},\"32\":{\"eventID\":0,\"flo\":0,\"sceneID\":8,\"type\":0,\"x\":4,\"xyID\":39,\"y\":6},\"33\":{\"eventID\":2,\"flo\":0,\"sceneID\":8,\"type\":15,\"x\":4,\"xyID\":45,\"y\":7},\"34\":{\"eventID\":2,\"flo\":0,\"sceneID\":8,\"type\":3,\"x\":4,\"xyID\":51,\"y\":8},\"35\":{\"eventID\":2,\"flo\":0,\"sceneID\":8,\"type\":3,\"x\":4,\"xyID\":57,\"y\":9},\"36\":{\"eventID\":0,\"flo\":0,\"sceneID\":8,\"type\":0,\"x\":5,\"xyID\":10,\"y\":1},\"37\":{\"eventID\":2,\"flo\":0,\"sceneID\":8,\"type\":15,\"x\":5,\"xyID\":16,\"y\":2},\"38\":{\"eventID\":2,\"flo\":0,\"sceneID\":8,\"type\":3,\"x\":5,\"xyID\":22,\"y\":3},\"39\":{\"eventID\":0,\"flo\":0,\"sceneID\":8,\"type\":0,\"x\":5,\"xyID\":28,\"y\":4},\"4\":{\"eventID\":0,\"flo\":0,\"sceneID\":8,\"type\":0,\"x\":1,\"xyID\":30,\"y\":5},\"40\":{\"eventID\":0,\"flo\":0,\"sceneID\":8,\"type\":0,\"x\":5,\"xyID\":34,\"y\":5},\"41\":{\"eventID\":2,\"flo\":0,\"sceneID\":8,\"type\":3,\"x\":5,\"xyID\":40,\"y\":6},\"42\":{\"eventID\":8000,\"flo\":0,\"sceneID\":8,\"type\":8,\"x\":5,\"xyID\":46,\"y\":7},\"43\":{\"eventID\":66,\"flo\":0,\"sceneID\":8,\"type\":2,\"x\":5,\"xyID\":52,\"y\":8},\"44\":{\"eventID\":0,\"flo\":0,\"sceneID\":8,\"type\":0,\"x\":5,\"xyID\":58,\"y\":9},\"45\":{\"eventID\":5,\"flo\":0,\"sceneID\":8,\"type\":5,\"x\":6,\"xyID\":11,\"y\":1},\"46\":{\"eventID\":0,\"flo\":0,\"sceneID\":8,\"type\":0,\"x\":6,\"xyID\":17,\"y\":2},\"47\":{\"eventID\":10,\"flo\":0,\"sceneID\":8,\"type\":3,\"x\":6,\"xyID\":23,\"y\":3},\"48\":{\"eventID\":1,\"flo\":0,\"sceneID\":8,\"type\":15,\"x\":6,\"xyID\":29,\"y\":4},\"49\":{\"eventID\":66,\"flo\":0,\"sceneID\":8,\"type\":2,\"x\":6,\"xyID\":35,\"y\":5},\"5\":{\"eventID\":1,\"flo\":0,\"sceneID\":8,\"type\":15,\"x\":1,\"xyID\":36,\"y\":6},\"50\":{\"eventID\":2,\"flo\":0,\"sceneID\":8,\"type\":3,\"x\":6,\"xyID\":41,\"y\":6},\"51\":{\"eventID\":1,\"flo\":0,\"sceneID\":8,\"type\":15,\"x\":6,\"xyID\":47,\"y\":7},\"52\":{\"eventID\":0,\"flo\":0,\"sceneID\":8,\"type\":0,\"x\":6,\"xyID\":53,\"y\":8},\"53\":{\"eventID\":1,\"flo\":0,\"sceneID\":8,\"type\":15,\"x\":6,\"xyID\":59,\"y\":9},\"6\":{\"eventID\":66,\"flo\":0,\"sceneID\":8,\"type\":2,\"x\":1,\"xyID\":42,\"y\":7},\"7\":{\"eventID\":2,\"flo\":0,\"sceneID\":8,\"type\":3,\"x\":1,\"xyID\":48,\"y\":8},\"8\":{\"eventID\":6,\"flo\":0,\"sceneID\":8,\"type\":4,\"x\":1,\"xyID\":54,\"y\":9},\"9\":{\"eventID\":0,\"flo\":0,\"sceneID\":8,\"type\":0,\"x\":2,\"xyID\":7,\"y\":1}},\"firedEventCell\":[{\"x\":4,\"y\":3}],\"lastUpdateStepNumberTime\":1456304785,\"maxFloor\":1,\"pets\":{\"0\":{\"hp\":2043,\"objID\":1},\"1\":{\"hp\":112,\"objID\":10},\"10\":{\"hp\":522,\"objID\":19},\"11\":{\"hp\":548,\"objID\":2},\"12\":{\"hp\":812,\"objID\":20},\"13\":{\"hp\":719,\"objID\":21},\"14\":{\"hp\":155,\"objID\":22},\"15\":{\"hp\":1188,\"objID\":23},\"16\":{\"hp\":540,\"objID\":24},\"17\":{\"hp\":530,\"objID\":25},\"18\":{\"hp\":171,\"objID\":26},\"19\":{\"hp\":537,\"objID\":27},\"2\":{\"hp\":112,\"objID\":11},\"20\":{\"hp\":203,\"objID\":28},\"21\":{\"hp\":203,\"objID\":29},\"22\":{\"hp\":370,\"objID\":3},\"23\":{\"hp\":441,\"objID\":30},\"24\":{\"hp\":171,\"objID\":31},\"25\":{\"hp\":116,\"objID\":32},\"26\":{\"hp\":330,\"objID\":4},\"27\":{\"hp\":525,\"objID\":5},\"28\":{\"hp\":296,\"objID\":6},\"29\":{\"hp\":267,\"objID\":7},\"3\":{\"hp\":187,\"objID\":12},\"30\":{\"hp\":307,\"objID\":8},\"31\":{\"hp\":187,\"objID\":9},\"4\":{\"hp\":100,\"objID\":13},\"5\":{\"hp\":187,\"objID\":14},\"6\":{\"hp\":171,\"objID\":15},\"7\":{\"hp\":181,\"objID\":16},\"8\":{\"hp\":649,\"objID\":17},\"9\":{\"hp\":522,\"objID\":18}},\"pickupItem\":[{\"itemID\":1}],\"points\":0,\"recordingPoint\":1,\"resetCount\":0,\"resetTime\":1456304785,\"stepNumber\":50}"
--        local tbl = cjson.decode(LostTowerData)
--        LostTowerMgr.LtMapData = clone( tbl.events )
--        if tbl.pets then
--            LtPetsMgr.LtPets = {}
--            for k,v in pairs(tbl.pets) do
--                LtPetsMgr.LtPets[v.objID] = v.hp
--            end
--        end
--        
--        if callback then callback() end
--        return
--    end
    
    NetInterface.sendWithBlock("GC_GETLOSTTOWERDATA_ACK", function()
        local LostTowerSend = require("src/Net/Send/LostTowerSend.lua")
        LostTowerSend.sendCG_GetLostTowerData_Req()
    end, function()
        if not LostTowerMgr.enterFunc then
            LostTowerMgr.enterFunc = callback
        end
        
        NetInterface.send("GC_RECOVERSTEPNUMBER_ACK", function()
            local LostTowerSend = require("src.Net.Send.LostTowerSend")
            LostTowerSend.sendCG_RecoverStepNumber_Req()
        end, function()
            LostTowerMgr.stepMaxAdditional = CharInfo.get().furniturelosttowermaxstepnumber or 0

            -- if callback then callback() end
        end)
    end)
end

LostTowerMgr.movedCellString      = nil
LostTowerMgr.firedEventCellString = nil


local cjson = require("cjson")

function LostTowerMgr.setMovedCells(data)
    if not data then return end
    
    LostTowerMgr.movedCells = {}
    for k,v in pairs(data) do
        local pos = cjson.decode(v)
        local cellID = LtMapOption.convertToIndex(pos.y,pos.x)
        if cellID then
            LostTowerMgr.movedCells[cellID] = true
        end
    end
end

function LostTowerMgr.setFiredEvent(data)
    if not data then return end
    
    LostTowerMgr.firedCells = {}
    for k,v in pairs(data) do
        local pos = cjson.decode(v)
        local cellID = LtMapOption.convertToIndex(pos.y,pos.x)
        if cellID then
            LostTowerMgr.firedCells[cellID] = true
        end
    end
end

function LostTowerMgr.setLostTowerData(data)

    local cjson = require("cjson")
    local tbl = data   -- cjson.decode(data)
    
    for k,v in pairs(tbl) do
        print(k,v)
    end
    
    LostTowerMgr.eventNumber = tbl.eventNum or 0
    
    -- currentFloor/maxFloor/stepNumber/points
    LostTowerMgr.currentFloor       = tbl.currentFloor or 1
    LostTowerMgr.weekMaxFloor       = tbl.weekMaxFloor or 1
    LostTowerMgr.maxFloor           = tbl.maxFloor or 1
    LostTowerMgr.stepNumber         = tbl.stepNumber or 50
    LostTowerMgr.previousStepNum    = -1
    LostTowerMgr.points             = tbl.points or 0
    LostTowerMgr.previousPoint      = -1
    LostTowerMgr.weekMaxPoints      = tbl.weekMaxPoint or 0
    LostTowerMgr.stepRefreshTime    = tbl.lastUpdateStepNumberTime
    
    if tbl.position then
        local pPos = cjson.decode(tbl.position)
        LostTowerMgr.playerPosition = pPos or 0
    end
    
    LostTowerMgr.recordingPoint = tbl.recordingPoint or 1
    
    -- events
--    if tbl.events then
--        LostTowerMgr.LtMapData = clone( tbl.events )
--    end
    LostTowerMgr.preCheckData = {}
    LostTowerMgr.LtMapData = {}
    
    -- pets
    if tbl.pets then
        LtPetsMgr.LtPets = {}
        for k,v in pairs(tbl.pets) do
            local pet = cjson.decode(v)
            local petInfo = PokemonInfo.getPetInfoByObjID(pet.objID)
            if petInfo and petInfo.hpmax then
                local percent = pet.hp
                LtPetsMgr.LtPets[pet.objID] = math.floor(percent * petInfo.hpmax / 10000)
            end
        end
    end
    
    -- army
    if tbl.activityArmys then
        LtPetsMgr.LtArmy = {}
        for key, value in pairs(tbl.activityArmys) do
            LtPetsMgr.LtArmy[key] = value
        end
    end
    if tbl.activityHelpArmys then
        LtPetsMgr.LtHelpArmy = {}
        for key, value in pairs(tbl.activityHelpArmys) do
            LtPetsMgr.LtHelpArmy[key] = value
        end
    end

--    if tbl.movedCellHigh and tbl.movedCellLow then
--        LostTowerMgr.movedCells = {}
--        
--        print(type(tbl.movedCellHigh),tbl.movedCellHigh)
--        print(type(tbl.movedCellLow),tbl.movedCellLow)
--        
--        local data64_h = tonumber(tbl.movedCellHigh)%(2^32)
--        local data64_l = tonumber(tbl.movedCellLow)%(2^32)
--        
--        local movedCellBits_h = bit._d2b(data64_h)
--        local movedCellBits_l = bit._d2b(data64_l)
--        
--        for i = 1, 32 do 
--            if movedCellBits_l[i] == 1 then
--                LostTowerMgr.movedCells[32-(i-1)] = true
--                --table.insert(LostTowerMgr.movedCells, 32-(i-1))
--            end
--            if movedCellBits_h[i] == 1 then
--                LostTowerMgr.movedCells[64-(i-1)] = true
--                --table.insert(LostTowerMgr.movedCells, 64-(i-1))
--            end
--        end
--    end

    if tbl.movedCell then
        LostTowerMgr.movedCellString = tbl.movedCell
    end

    if tbl.firedEventCell then
--        LostTowerMgr.firedCells = {}
--        for k,v in pairs(tbl.firedEventCell) do
--            local pos = cjson.decode(v)
--            local cellID = LtMapOption.convertToIndex(pos.y,pos.x)
--            LostTowerMgr.firedCells[cellID] = true
--        end
        
        LostTowerMgr.firedEventCellString = tbl.firedEventCell
    end
    
    if tbl.pickupItems then LtPropMgr.setPropTable(tbl.pickupItems) end
    if tbl.buff then LtExBufferMgr.setBufferTable(tbl.buff) end
    
    
    LtHealViewMgr.recoverCount = tbl.recoverCount
    LtResetViewMgr.resetCount  = tbl.resetCount
    LtResetViewMgr.resetTime   = tbl.resetTime or 0
end

function LostTowerMgr.enterLostTower(callback)
end

function LostTowerMgr.leaveLostTower()
end

function LostTowerMgr.closeLostTower(callback)
    LostTowerMgr.preCheckData = {}
    LostTowerMgr.LtMapData = {}

    SearchingMapMgr.currFloor = 1
    SearchingMgr.floorClear = true
    SearchingMgr.dungeonClear = true
    SearchingMapMgr.floorEventTbl = {}
    SearchingMapMgr.floorMapInfoTbl = {}
    SearchingMapMgr.floorEventStateTbl = {}
    LostTowerMgr.STATE = LostTowerMgr._CLOSED
    
    LostTowerMgr.firedCells = {}
    LostTowerMgr.newCells   = {}
    
    LostTowerMgr.sendRecoverStepReq(function()
        LostTowerInfo.refreshServerTime()
    end)
    
    LtWarFogMgr.clear()
    
    LtPropMgr.removeShadowNode()
end

function LostTowerMgr.preCheck(data)
    print(data["playerPos"])
    if not data or not data["playerPos"] then return end

    local i = data["playerPos"]
    local e = data["event"]
    
    if e == LtEventOption.EVENT_C_AWARDS or e == LtEventOption.EVENT_PICKING then
        SearchingMgr.eventStateInfoTable[i] = 1
        LtFuncMgr.pickingFunc(i)
    elseif e == LtEventOption.EVENT_BUFF then
        SearchingMgr.eventStateInfoTable[i] = 1
        LtFuncMgr.buffCommonFunc(i)
    elseif e == LtEventOption.EVENT_HEALPOINT then
        SearchingMgr.eventStateInfoTable[i] = 1
        LtFuncMgr.healPointFuncAt(i)
    elseif e == LtEventOption.EVENT_PORTAL then
        -- 重新创建传送阵
        SearchingMgr.eventStateInfoTable[i] = 1
        SearchingMgr.eventInfoTable[i] = LtEventOption.EVENT_PORTAL
        LtEventOption.createEvent(i)
        
        -- 传送
        LtFuncMgr.portalFunc(i)
    end
end

function LostTowerMgr.createMap(mapData)
    mapData = mapData or LostTowerMgr.LtMapData

    SearchingMgr.dungeonClear = false
    SearchingMgr.floorClear = false
    SearchingMgr.onmove = false
    SearchingMgr.canMove = true

    AdvCharMgr.resetTrainers()
    SearchingMgr.onbattle = false
    
    if LostTowerMgr.STATE == LostTowerMgr._CLOSED then
        LostTowerMgr.STATE = LostTowerMgr._INGAME
    else
        return
    end
    
    initAllInfos()
    
    SearchingMapMgr.currFloor = 1
    
    -- 如果服务器已经记录人物位置
    SearchingMgr.playerCurrPosition = 0  -- 清空人物位置信息
    if LostTowerMgr.playerPosition ~= 0 then
        SearchingMgr.playerCurrPosition = LtMapOption.convertToIndex(LostTowerMgr.playerPosition.y, LostTowerMgr.playerPosition.x)
    end

    for key, var in pairs(mapData) do
        local sceneId   = var["sceneID"]
        local floor     = 1  -- var["flo"]
        local resId     = var["eventID"]   --事件具体类型，如金币...
        local row       = var["x"]   --row
        local col       = var["y"]   --column
        local eType     = var["type"]
        local data      = var["data"]
        
        local block = LtMapOption.convertToIndex(col,row)

        SearchingMapMgr.sceneID["floor"..floor][block] = sceneId 
        
        --地形数据
        SearchingMapMgr.floorEnvTable["floor"..floor][block] = {
            fogRes = 1,
            terrRes = 1,
        }
        
        if LostTowerMgr.firedCells[block]  then  -- clear fired cell
            if LtEventOption.EVENT_DONT_DISAPEAR[eType] then
                SearchingMapMgr.floorEventStateTbl["floor"..floor][block] = 3
            else
                eType = LtEventOption.EVENT_VOID
                resId = 0
            end
        
--            if eType == LtEventOption.EVENT_LTBOSS 
--            or eType == LtEventOption.EVENT_RANDOMBOX
--            then
--                SearchingMapMgr.floorEventStateTbl["floor"..floor][block] = 3
--            else
--                eType = LtEventOption.EVENT_VOID
--                resId = 0
--            end
        end
        
        SearchingMapMgr.floorMapInfoTbl["floor"..floor][block] = 0
        SearchingMapMgr.floorEventTbl["floor"..floor][block] = eType

        if eType == SearchingMapMgr.EVENT_ENTERANCE then
            if LostTowerMgr.playerPosition == 0 then 
                SearchingMgr.playerCurrPosition = block
            else
                if not SearchingMgr.playerCurrPosition then
                    SearchingMgr.playerCurrPosition = block
                end
            end
            SearchingMapMgr.floorEventStateTbl["floor"..floor][SearchingMgr.playerCurrPosition] = 3
        end
        
        if block == SearchingMgr.playerCurrPosition then
            LostTowerMgr.preCheckData = {}
            LostTowerMgr.preCheckData["playerPos"] = SearchingMgr.playerCurrPosition
            LostTowerMgr.preCheckData["event"]     = eType
            SearchingMapMgr.floorEventTbl["floor"..floor][block] = LtEventOption.EVENT_VOID
        end
        
        SearchingMapMgr.floorItemTbl["floor"..floor][block] = LtEventOption.getEventRes(eType,resId,data)
        
        if SearchingMapMgr.floorItemTbl["floor"..floor][block] then
            if SearchingMapMgr.floorItemTbl["floor"..floor][block].resName then
                SearchingMapMgr.floorItemTbl["floor"..floor][block].resName = SearchingMapMgr.getResFromStr(SearchingMapMgr.floorItemTbl["floor"..floor][block].resName)
            end
        end
    end
    
    local currFloor = SearchingMapMgr.currFloor
    SearchingMgr.mapInfoTable        = SearchingMapMgr.floorMapInfoTbl["floor"..currFloor]
    SearchingMgr.eventInfoTable      = SearchingMapMgr.floorEventTbl["floor"..currFloor]
    SearchingMgr.itemTypeTable       = SearchingMapMgr.floorItemTbl["floor"..currFloor]
    SearchingMgr.eventStateInfoTable = SearchingMapMgr.floorEventStateTbl["floor"..currFloor]
    SearchingMgr.monsterDefendInfo   = SearchingMapMgr.floorMstrDefendTbl["floor"..currFloor]
    
end

--- 检查是否有或者的宠
function LostTowerMgr.haveAlivePets()
    for i = 1, #LtPetsMgr.LtArmy do
        local objID = LtPetsMgr.LtArmy[i]
        if LtPetsMgr.getHpByObjID(objID) > 0 then
            return true
        end
    end
    
    print("there is no alive pet.")
    StandardTipsMgr.show(1, "LtTips20")  -- "无法行动，宠物全部阵亡"
    return false 
end

--- 千层塔移动检查
function LostTowerMgr.canMove(i)
    if LostTowerMgr.getStepNumber() - 1 < 0 then
        local _etype = SearchingMgr.eventInfoTable[i]
        if LtEventOption.reachable[_etype] then
            StandardTipsMgr.show(1, "LtTips19")   -- "没有步数了"
            return false
        else
            if not SearchingMgr.checkPlayer(i) then
                StandardTipsMgr.show(1, "LtTips19")
                return false
            end
        end
    end
--    if not SearchingMgr.checkPlayer(i) then
--        StandardTipsMgr.show(1, "只能走一步！")
--        return false
--    end
    
    local flag = false
    for i = 1, #LtPetsMgr.LtArmy do
        local objID = LtPetsMgr.LtArmy[i]
        if LtPetsMgr.getHpByObjID(objID) > 0 then
            flag = true
            break
        end
    end
    if not flag then 
        StandardTipsMgr.show(1, "LtTips20")  -- "无法行动，宠物全部阵亡"
        return false 
    end
    
    return true
end

--- 千层塔移动回调
-- @param id number 移动后格子ID
function LostTowerMgr.LtMovedCallback(id)
    if not NetInterface.isConnect then 
        -- LostTowerUIMgr.scrollMapTo(id,0.25)
        return 
    end
    
    -- 更新待移动方格list
    table.insert(LostTowerMgr.newCells,id)
    SearchingMgr.playerLastPosition = SearchingMgr.playerCurrPosition
    
    for i = 1, #LostTowerMgr.newCells do
        print("LostTowerMgr.newCells", LostTowerMgr.newCells[i])
    end
    
    local stepNumMax  = CharInfo.getVipInfoByID(CharInfo.getVIPLevel()).ltSetpNumber + LostTowerMgr.stepMaxAdditional
    if LostTowerMgr.getStepNumber() == stepNumMax then
        LostTowerUIMgr.stepFlag = true
        LostTowerMgr.stepRefreshTime = CharInfo.getServerTime()
    end
    
--    LostTowerUIMgr.scrollMapTo(id,0.25)
    LostTowerMgr.stepNumber = LostTowerMgr.stepNumber - 1
    LostTowerUIMgr.updateStepNumber(LostTowerMgr.getStepNumber())
    
    LtWarFogMgr.refreshWarFog(LostTowerMgr.movedCells, id)
    
    --[[-- 服务器不记录movedCells
    for k,v in pairs(LostTowerMgr.movedCells) do
        if id == v then return end
    end
    --]]
    
    if LostTowerMgr.firstSend then
        print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  sendCG_moveNewCell_Req At", id)
        local _col, _row = LtMapOption.convertToCoord(id)
        NetInterface.send("GC_MOVENEWCELL_ACK", function()  -- 不block发协议
            local LostTowerSend = require("src/Net/Send/LostTowerSend.lua")
            LostTowerSend.sendCG_moveNewCell_Req({ x=_row, y=_col, })
        end, function()
        end,function(code)
        end)
        LostTowerMgr.firstSend = false
    end
end

function LostTowerMgr.getStepNumber()
    return LostTowerMgr.stepNumber + LostTowerMgr.stepAdded
end

function LostTowerMgr.hasEnoughSteps(floor)
    local step_number = LostTowerMgr.getStepNumber()
    local need_step_number = math.floor(floor / 20) + 1
    
    if step_number - need_step_number < 0 then
        return false
    end
    
    return true
end

return LostTowerMgr