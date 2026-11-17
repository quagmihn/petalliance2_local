--created on 2015-07-23

local SearchingMapMgr = {}

SearchingMapMgr.EVENT_VOID          = 0  --空事件
SearchingMapMgr.EVENT_PICKING       = 1  --拾取事件
SearchingMapMgr.EVENT_MONSTER       = 2  --野怪战斗事件
SearchingMapMgr.EVENT_OBSTRUCTION   = 3  --障碍事件
SearchingMapMgr.EVENT_EXIT          = 4  --出口事件
SearchingMapMgr.EVENT_ENTERANCE     = 5  --入口事件
SearchingMapMgr.EVENT_SWITCH        = 6  --机关(开关)事件
SearchingMapMgr.EVENT_PORTAL        = 7  --传送门事件
SearchingMapMgr.EVENT_TRAINER       = 8  --训练师战斗

SearchingMapMgr.EVENT_TYPES = {
    SearchingMapMgr.EVENT_VOID,         --1[idx]
    SearchingMapMgr.EVENT_PICKING,      --2[idx]
    SearchingMapMgr.EVENT_MONSTER,      --3[idx]
    SearchingMapMgr.EVENT_OBSTRUCTION,  --4[idx]
    SearchingMapMgr.EVENT_EXIT,         --5[idx]
    SearchingMapMgr.EVENT_ENTERANCE,    --6[idx]
    SearchingMapMgr.EVENT_SWITCH ,      --7[idx]
    SearchingMapMgr.EVENT_PORTAL,       --8[idx]
    SearchingMapMgr.EVENT_TRAINER,      --9[idx]
}

--配置表读取用
local fogInfo
local itemsInfo
local obstructionInfo
local goalsInfo
local billboardInfo
local fbpickupInfo
local switchInfo
local teleportInfo
local fbnpcInfo

--当前副本信息
SearchingMapMgr.currAdvInfo = {}

--副本场景数据
SearchingMapMgr.adventureData = {}
SearchingMapMgr.adventureShopData = {}

--当前副本
--当前层
--战斗发生位置
SearchingMapMgr.currAdventure = nil
SearchingMapMgr.currFloor = nil

--战斗发生位置，战斗返回时初始地图用
SearchingMapMgr.battlePos = 0
SearchingMapMgr.battleResult = false

SearchingMapMgr.floorSize = {}

SearchingMapMgr.floorEnvTable = {
}

SearchingMapMgr.floorMapInfoTbl = {
--    floor1 = {},
--    floor2 = {},
--    floor3 = {},
--    ...
}

SearchingMapMgr.floorEventTbl = {
--    floor1 = {},
--    floor2 = {},
--    floor3 = {},
--    ...
}

--事件觸發狀態
SearchingMapMgr.floorEventStateTbl = {
--    floor1 = {},
--    floor2 = {},
--    floor3 = {},
--    ...
}
SearchingMapMgr.disposablePoint = 0
SearchingMapMgr.disposableFireFlag = false
SearchingMapMgr.firedDisposableEvents = {}


SearchingMapMgr.floorItemTbl = {
--    floor1 = {},
--    floor2 = {},
--    floor3 = {},
--    ...
}

SearchingMapMgr.floorMstrDefendTbl = {
    --    floor1 = {},
    --    floor2 = {},
    --    floor3 = {},
    --    ...
}

SearchingMapMgr.floorTargetBlocks = {
--    floor1 = {},
--    floor2 = {},
--    floor3 = {},
--    ...
}

SearchingMapMgr.floorEnterance = {
--    floor1 = nil,
--    floor2 = nil,
--    floor3 = nil,
--    ...
}

SearchingMapMgr.floorExit = {
--    floor1 = nil,
--    floor2 = nil,
--    floor3 = nil,
--    ...
}

--scenesInfo.dat 中的id
SearchingMapMgr.sceneID = {}

SearchingMapMgr.OriginalData = {}

SearchingMapMgr.itemsCount = 0
SearchingMapMgr.allItems = {
--    prop1 = nil,
--    prop2 = nil,
--    prop3 = nil,
--    prop4 = nil,
}

SearchingMapMgr.firstAdventure = false
SearchingMapMgr.tutorialFlag = false
SearchingMapMgr.guideCallback = nil

SearchingMapMgr.dropTable = {}

SearchingMapMgr.currSkill = nil
SearchingMapMgr.currItem  = nil

SearchingMapMgr.currCoinNum = 0
SearchingMapMgr.currGainNum = 0

SearchingMapMgr.pickingRecord = {}
SearchingMapMgr.propUseRecord = {}

SearchingMapMgr.GoalTable = {
    goal1 = {decs=nil, eventType=nil, eId=nil, goal=nil, count=0, clear=false, clear_b = false},
    goal2 = {},
    goal3 = {},
}

-- 皇冠成就完成记录
-- struct:  {eType, eID, count}
SearchingMapMgr.GoalRecord = {}

SearchingMapMgr.weatherType = {}  -- 天气参数
SearchingMapMgr.fieldType   = {}  -- 场地参数


--迷霧資源路徑
SearchingMapMgr.fogRes = {
    active = nil,
    locked = {
        common  = nil, 
        monster = nil
    }
}

--地砖资源
SearchingMapMgr.groundRes = {
    img = nil,
    imgX = nil,
}

--人物资源
SearchingMapMgr.playerResTbl = {
    ani = {
        "Gaf/char/ts_01.gaf", --"Gaf/npc/ts_003.gaf",
        "Gaf/char/ts_02.gaf",
    },
    avatar = {
        "Searching/advclear/ditu_nan.png",
        "Searching/advclear/ditu_nv.png",
    },
}
SearchingMapMgr.playerRes = nil

SearchingMapMgr.fbFloorNameConfig = nil
local isTxtInited = false

---重新初始化SearchingMapMgr，用于动态lua调试
function SearchingMapMgr.Init()
    print("SearchingMapMgr初始化")

    SearchingMapMgr.firstAdventure = false
    SearchingMapMgr.battleResult = false
    
    SearchingMapMgr.currAdvInfo = {}
    
    SearchingMapMgr.disposablePoint = 0
    SearchingMapMgr.disposableFireFlag = false
    
    SearchingMapMgr.weatherType = {}  -- 天气参数
    SearchingMapMgr.fieldType   = {}  -- 场地参数
    
    if isTxtInited==false then
        SearchingMapMgr.fbFloorNameConfig = TxtReader.new("Config/fbfloorname.txt")
        SearchingMapMgr.fbFloorNameConfig.init({"advid", "floors", "f1", "f2", "f3", "f4"}, 1)
        isTxtInited = true
    end
end

---初始化副本数据
function SearchingMapMgr.initAdventure()
    SearchingMgr.canGiveUp = true

    SearchingMapMgr.currCoinNum = 0
    SearchingMapMgr.currGainNum = 0
    SearchingMapMgr.itemsCount = 0
    SearchingMapMgr.allItems = {}
    SearchingMgr.awardsTbl = {}
    
    SearchingMgr.isFailed = false
    SearchingMgr.canMove = true
    SearchingUIMgr.FALL = false
    
    --副本星数record初始
    AdvStarMgr.setStarRecords(0)
    
    --pets init
    AdvPetsMgr.reset()

end

-- 清空一次性事件列表
function SearchingMapMgr.clearDispEvents()
    SearchingMapMgr.firedDisposableEvents = {}
    for i = 1, SearchingMgr.floors do
        SearchingMapMgr.firedDisposableEvents[i] = {}
    end
end


--创建地图探索场景
function SearchingMapMgr.createSearchingMap(scene)

--    if not NetInterface.isConnect then
--        SearchingMapMgr.adventureData = {}
--        for i = 1, LtMapOption.getMapSize() do
--            local col, row = LtMapOption.convertToCoord(i)
--        
--            local var = {}
--            var["sceneID"] = i
--            var["flo"]     = 1
--            var["eventID"] = 0
--            var["x"]       = row
--            var["y"]       = col
--            var["type"]    = 0
--            
--            table.insert(SearchingMapMgr.adventureData,var)
--        end
--    end
    
    if SearchingMgr.isAdventureEnd() then
        SearchingMapMgr.currFloor = 1
        SearchingMapMgr.currAdvInfo = clone(AdventureInfo.getAdventureInfoByID(SearchingMapMgr.currAdventure))
        SearchingMapMgr.setCurrFloorSize(SearchingMapMgr.currAdvInfo, SearchingMapMgr.currFloor)
        SearchingMapMgr.getInfoFromDat(scene)
        SearchingMgr.initMapInfo()
        SearchingUIMgr.addUI(scene)
        SearchingMgr.dungeonClear = false
        
        if SearchingMgr.guideFunc ~= nil then   --引导函式
            scene:performWithDelay(function()
                SearchingMgr.guideFunc()
                SearchingMgr.guideFunc = nil
            end,0.5)
        else
            if not AdvStarMgr.checkClearFlag(SearchingMapMgr.currAdventure) then
                SearchingMgr.optionalTutorial()
            end
            if SearchingMgr.guideFunc then
                scene:performWithDelay(function()
                    SearchingMgr.guideFunc()
                    SearchingMgr.guideFunc = nil
                end,0.5)
            end
        end
    else
        SearchingMapMgr.setCurrFloorSize(SearchingMapMgr.currAdvInfo, SearchingMapMgr.currFloor)
        SearchingMgr.initMapInfo()
        SearchingUIMgr.addUI(scene)
    end
    
    GameAudio.playMusic2("exploring"..WorldMapMgr.curMapID)
    
end

---字符串分割为：资源table
function SearchingMapMgr.getResFromStr(str)
    if str == nil then return nil end
    if type(str) == "table" then
        return str
    end
    
    local tbl = string.split(str, ",")
    for key in pairs(tbl) do
        if tbl[key] == "nil" then 
            tbl[key] = "nil"
        else 
            if tbl[key] == "jinbi"      then tbl[key] = "coin" end
            if tbl[key] == "baoxiang"   then tbl[key] = "box" end
            if tbl[key] == "shitou"     then tbl[key] = "stone" end
            if tbl[key] == "anniu"      then tbl[key] = "switch" end
            if tbl[key] == "anniu2"     then tbl[key] = "switchX" end
            if tbl[key] == "kabishou"   then tbl[key] = "kbs" end
            if tbl[key] == "chukou"     then tbl[key] = "exit" end
            if tbl[key] == "csm"        then tbl[key] = "portal1" end
            if tbl[key] == "csm2"       then tbl[key] = "portal2" end
        end
    end
    
    return tbl
end


---目标方格字符串分割
function SearchingMapMgr.getTargetBlocks(string)
    if string == "0" or string == "99" or string == "88" then return string end
    
    local str = clone(string)
    local result = {}
    local startP = 1
    local endP = 0
    local coordStr = ""
    while coordStr ~= nil do
        startP, endP, coordStr = string.find(str,"(%d+,%d+,%d+,%d+)",endP+1)
        if coordStr ~= nil then
            coordStr = string.split(coordStr,",")
        end
        table.insert(result, coordStr)
    end
    
    return result
end


---障碍解锁条件字串处理
function SearchingMapMgr.getObClearConds(string)
    local result = {}
    local startP = 1
    local endP = 0
    local _str = ""
    while _str ~= nil do
        startP, endP, _str = string.find(string,"(%d+,%d+)",endP+1)
        if _str ~= nil then
            _str = string.split(_str,",")
        end
        table.insert(result, _str)
    end
    return result
end


---decode json string from server
function SearchingMapMgr.getDataFromServer(jsonStr)
    --服务器请求到的数据清空
    SearchingMapMgr.adventureData = {}
    SearchingMapMgr.adventureShopData = {}
    
    local str = jsonStr
    local cjson = require("cjson")
    local tbl = cjson.decode(str)
    if tbl["advID"] == SearchingMapMgr.currAdventure then
        for _, var in pairs(tbl["events"]) do
            local e = clone(var)
            table.insert(SearchingMapMgr.adventureData, e)
        end
        
        SearchingMapMgr.adventureShopData = tbl["npcShop"]
    end
end


---txt配置表数据初始
function SearchingMapMgr.initTxtData()
    local Readers = LtEventOption.getTxtData()

    goalsInfo       = Readers.goalsInfo
    fogInfo         = Readers.fogInfo
    itemsInfo       = Readers.itemsInfo
    obstructionInfo = Readers.obstructionInfo
    billboardInfo   = Readers.billboardInfo
    fbpickupInfo    = Readers.fbpickupInfo
    switchInfo      = Readers.switchInfo
    teleportInfo    = Readers.teleportInfo
    fbnpcInfo       = Readers.fbnpcInfo
end


--- 副本目标初始
local function initGoals()

    if goalsInfo == nil then
        print("ADV_ERROR_INFO : init goalsInfo first!")
        return
    end
    
    local advInfo = SearchingMapMgr.currAdvInfo
    
    local targetTable = advInfo.target or {}
    
    for i = 1, #targetTable do
        local goal = goalsInfo.get(targetTable[i])
        local tbl = {
            mID       = tonumber(targetTable[i]),  -- 副本任务ID
            desc      = goal.desc, 
            eventType = tonumber(goal.eType), 
            eId       = goal.eId, 
            goal      = tonumber(goal.arg), 
            count     = 0, 
            clear     = false,
            clear_b   = AdvStarMgr.getRecordByKey(i),
        }
        SearchingMapMgr.GoalTable["goal"..i] = clone(tbl)
    end
    
    AdvStarMgr.currAdvMissions = {}
    for i = 1, #targetTable do
        AdvStarMgr.currAdvMissions[tonumber(targetTable[i])] = 0 -- 任务初始为未提交状态
    end
    
end


---副本[方格所有信息]初始化
local function initAllInfos()
    local _advInfo = SearchingMapMgr.currAdvInfo

    SearchingMgr.floors = _advInfo.floor
    local floors = SearchingMgr.floors
    for j=1, floors do
        SearchingMapMgr.floorEventStateTbl["floor"..j] = {}
        SearchingMapMgr.floorTargetBlocks["floor"..j] = {}
        SearchingMapMgr.floorMapInfoTbl["floor"..j] = {}
        SearchingMapMgr.floorEventTbl["floor"..j] = {}
        SearchingMapMgr.floorItemTbl["floor"..j] = {}
        SearchingMapMgr.floorMstrDefendTbl["floor"..j] = {}
        SearchingMapMgr.floorEnvTable["floor"..j] = {}
        SearchingMapMgr.sceneID["floor"..j] = {}
        
        local _mapSize = SearchingMapMgr.floorSize[j].cols * SearchingMapMgr.floorSize[j].rows
        for k=1 , _mapSize do
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
    
    for i = 1, floors do
        SearchingMapMgr.GoalRecord[i]    = {}
        SearchingMapMgr.pickingRecord[i] = {}
        SearchingMapMgr.propUseRecord[i] = {}
    end
    
    SearchingMapMgr.weatherType = _advInfo.weather
    SearchingMapMgr.fieldType   = _advInfo.scene
end

function SearchingMapMgr.initFloorSize()
    local _advInfo = clone(AdventureInfo.getAdventureInfoByID(SearchingMapMgr.currAdventure))
    SearchingMapMgr.floorSize = {}
    for i = 1, _advInfo.floor do
        SearchingMapMgr.floorSize[i] = {
            cols = _advInfo.floorsizes[i]["item"][1] or 5,
            rows = _advInfo.floorsizes[i]["item"][2] or 6,
        }
    end
end

function SearchingMapMgr.setCurrFloorSize(_advInfo, _currFloor)
    local _cols = _advInfo.floorsizes[_currFloor]["item"][1] or 5
    local _rows = _advInfo.floorsizes[_currFloor]["item"][2] or 6
    
    LtMapOption.setMapSize(_rows, _cols)
end

--- 副本获取事件信息
function SearchingMapMgr.getEventRes(type, subType, block)
    local ret
    
    if type == SearchingMapMgr.EVENT_ENTERANCE then
        ret = {id="#", name="empty", resName={"empty.png","empty.png","empty.png"},}
    end

    if type == SearchingMapMgr.EVENT_VOID then
        if subType == 0 then
            ret = {id="0", name="empty", resName={"empty.png","empty.png","empty.png"},}
        else
            local _info = clone(itemsInfo.get(subType)) or {id="#", name="empty", resName="nil,nil,nil",}
            local _t = SearchingMapMgr.getResFromStr(_info.resName)
            _info.res1 = _t[1]
            _info.res2 = _t[2]
            _info.res3 = _t[3]
            for key = 1, #_t do
                _t[key] = AdvEnvironmentMgr.makePath(_t[key])
            end
            _info.resName = _t
            ret = _info
        end
    end

    if type == SearchingMapMgr.EVENT_PICKING then
        local _info = clone(fbpickupInfo.get(subType))
        _info.resName = {
            [1] = AdvEnvironmentMgr.makePath(_info.res1, true),
            [2] = AdvEnvironmentMgr.makePath(_info.res2, true),
            [3] = AdvEnvironmentMgr.makePath(_info.res3, true),
        }

        local _s = string.sub(_info.target,2,-2)
        local _t = string.split(_s, ",")
        _info.targetType = tonumber(_t[1])
        _info.target     = tonumber(_t[2])

        _info.cond = (_info.cond == nil) and {} or SearchingMapMgr.getObClearConds(_info.cond)

        ret = _info
    end
    if type == SearchingMapMgr.EVENT_MONSTER then
        local monster = clone(AdventureInfo.getMonstrosityInfoByID(subType))
        monster.monsterID = subType
        ret = monster
    end
    if type == SearchingMapMgr.EVENT_TRAINER then
        local trainer = clone(AdventureInfo.getMonsterGroupManInfoByID(subType))

        ret = trainer
    end
    if type == SearchingMapMgr.EVENT_SWITCH then
        local _info = clone(switchInfo.get(subType)) or {}

        _info.name = _info.desc
        
        if _info.aniRes and _info.aniRes ~= "" then
            _info.aniRes = "Spine/searching/".._info.aniRes..".png"
        end
        
        _info.resName = {
            [1] = AdvEnvironmentMgr.makePath(_info.res1),
            [2] = AdvEnvironmentMgr.makePath(_info.res2),
            [3] = AdvEnvironmentMgr.makePath(_info.res3),
        }

        ret = _info
    end
    if type == SearchingMapMgr.EVENT_PORTAL then
        local _info = clone(teleportInfo.get(subType)) or {}

        _info.name = _info.desc
        
        if _info.aniRes and _info.aniRes ~= "" then
            _info.aniRes = "Spine/searching/".._info.aniRes..".png"
        end
        
        _info.resName = {
            [1] = AdvEnvironmentMgr.makePath(_info.res1),
            [2] = AdvEnvironmentMgr.makePath(_info.res2),
            [3] = AdvEnvironmentMgr.makePath(_info.res3),
        }

        ret = _info
    end
    if type == SearchingMapMgr.EVENT_OBSTRUCTION then
        local obInfo = clone( obstructionInfo.get(subType) ) or {}

        obInfo.id = tonumber(obInfo.id)
        obInfo.name = obInfo.desc
        obInfo.cond = (obInfo.cond == nil) and {} or SearchingMapMgr.getObClearConds(obInfo.cond)

        if obInfo.aniRes and obInfo.aniRes ~= "" then
            obInfo.aniRes = "Spine/searching/"..obInfo.aniRes..".png"
        end

        obInfo.resName = {
            [1] = AdvEnvironmentMgr.makePath(obInfo.res1),
            [2] = AdvEnvironmentMgr.makePath(obInfo.res2),
            [3] = AdvEnvironmentMgr.makePath(obInfo.res3),
        }

        ret = obInfo
    end
    if type == SearchingMapMgr.EVENT_EXIT then
        local _info = clone(itemsInfo.get(subType))

        local _t = SearchingMapMgr.getResFromStr(_info.resName)
        for key = 1, #_t do
            if _t[key] == "chukou" then _t[key] = "exit" end
            _t[key] = AdvEnvironmentMgr.makePath(_t[key])
        end

        ret = {
            id      = _info.id,
            name    = _info.name,
            resName = _t,
            res1    = "exit",
            res2    = "exit",
            res3    = "exit",
        }
    end
    if type == LtEventOption.EVENT_BILLBOARD then
        local _info = clone(billboardInfo.get(subType))

        _info.resName = {
            _info.res1,
            _info.res2,
            _info.res3,
        }

        ret = _info 
    end
    if type == LtEventOption.EVENT_ADV_NPC then
        ret = clone(fbnpcInfo.get(subType))
    end
    
    return ret
end


---服务器获取数据
function SearchingMapMgr.getInfoFromDat(scene)
    
    SearchingMapMgr.currAdvInfo = clone(AdventureInfo.getAdventureInfoByID(SearchingMapMgr.currAdventure))

    if not SearchingMapMgr.currAdvInfo then
        print("ADV_DEBUG_INFO: get adventure info failed, make sure  that the file [AdventureInfo.dat] is correct.")
        return
    end
    
    --txt配置表数据初始
    SearchingMapMgr.initTxtData()
    
    --初始化副本目標
    initGoals()
    
    --初始化所有info表
    initAllInfos()
    
    SearchingMapMgr.disposablePoint = 0
    SearchingMapMgr.disposableFireFlag = false
    SearchingMapMgr.clearDispEvents()
    
    local tmpTable = {}
    local finishedInfo = AdventureInfo.getFinishedByID(SearchingMapMgr.currAdventure)
    if type(finishedInfo.hasEvent) == "table" then
        for k, v in pairs(finishedInfo.hasEvent) do
            tmpTable[v] = true
        end
    end
    
    for key, var in pairs(SearchingMapMgr.adventureData) do
        local floor     = var["flo"]
        local eType     = var["type"]
        local resId     = var["eventID"]
        
        -- for local debug
--        local sceneId   = var["sceneID"]
--        local _sceneInfo = AdventureInfo.getSceneInfoByID(sceneId)
--        floor = _sceneInfo.floor
--        eType = _sceneInfo.eventType
--        resId = _sceneInfo.event
        
        local maxCols = SearchingMapMgr.floorSize[floor].cols
        
        if eType == LtEventOption.EVENT_DISPOSABLE then
            local col, row = var["y"], var["x"]
            local block = maxCols*(row-1)+col
            
            SearchingMapMgr.disposablePoint = block
        
            local _info = AdventureInfo.getDisposableInfoByID(resId)
            
            if not tmpTable[resId] then
                var["type"] = _info.eventType
                var["eventID"] = _info.eventRandomID
                SearchingMapMgr.firedDisposableEvents[floor][block] = {eventID = resId, state = 0, fireFlag = false, condID = _info.conditionID or 0}
            else
                var["type"] = _info.finishEventType
                var["eventID"] = _info.finishEvent
                SearchingMapMgr.firedDisposableEvents[floor][block] = {eventID = resId, state = 1, fireFlag = false, condID = _info.conditionID or 0}
            end
            SearchingMapMgr.adventureData[key] = var
        end
    end
    
    for key, var in pairs(SearchingMapMgr.adventureData) do
        local sceneId   = var["sceneID"]
        local floor     = var["flo"]
        local resId     = var["eventID"]   --事件具体类型，如金币...
        local row       = var["x"]   --row
        local col       = var["y"]   --column
        local eType     = var["type"]
        local targets   = AdventureInfo.getSceneInfoByID(sceneId)["target"]
        local mistOpen  = AdventureInfo.getSceneInfoByID(sceneId)["isInitOpen"]
        local fogRes    = AdventureInfo.getSceneInfoByID(sceneId)["fogRes"]
        local terrRes   = AdventureInfo.getSceneInfoByID(sceneId)["terrRes"]
        
        -- for local debug
--        local _sceneInfo = AdventureInfo.getSceneInfoByID(sceneId)
--        floor = _sceneInfo.floor
--        eType = _sceneInfo.eventType
--        resId = _sceneInfo.event

        
        --层数越界检查
        if floor > SearchingMgr.floors then
            print("层数越界，检查配置表...")
            print(floor, SearchingMgr.floors)
            return
        end
        
        local maxCols = SearchingMapMgr.floorSize[floor].cols
        local block = maxCols*(row-1)+col
        
        SearchingMapMgr.sceneID["floor"..floor][block] = sceneId 

        --地形数据
        SearchingMapMgr.floorEnvTable["floor"..floor][block] = {
            fogRes = fogRes,
            terrRes = terrRes,
        }

        --目标方格
        local tbl = SearchingMapMgr.getTargetBlocks(targets)
        if tbl ~= "0" and tbl ~= "99" and tbl ~= "88" then
            SearchingMapMgr.floorTargetBlocks["floor"..floor][block] = clone(tbl)
        else
            SearchingMapMgr.floorTargetBlocks["floor"..floor][block] = tbl
        end

        if mistOpen == 0 then
            SearchingMapMgr.floorMapInfoTbl["floor"..floor][block] = 0
        end

        SearchingMapMgr.floorEventTbl["floor"..floor][block] = eType

        if eType == SearchingMapMgr.EVENT_ENTERANCE then
            print("eType == SearchingMapMgr.EVENT_ENTERANCE:"..block)
            SearchingMapMgr.floorEnterance["floor"..floor] = block
            -- SearchingMapMgr.floorMapInfoTbl["floor"..floor][block] = 1
            -- SearchingMapMgr.floorEventStateTbl["floor"..floor][block] = 3    --入口默認觸發態

            SearchingMapMgr.floorMapInfoTbl["floor"..floor][block] = 0
            SearchingMapMgr.floorEventTbl["floor"..floor][block] = SearchingMapMgr.EVENT_VOID
            SearchingMapMgr.floorItemTbl["floor"..floor][block] = {id="#", name="empty", resName="empty,empty,empty",}
        end

        if eType == SearchingMapMgr.EVENT_VOID then
            if resId == 0 then
                SearchingMapMgr.floorItemTbl["floor"..floor][block] = {id="#", name="empty", resName="empty,empty,empty",}
            else
                local _info = clone(itemsInfo.get(resId)) or {id="#", name="empty", resName="nil,nil,nil",}
                local _t = SearchingMapMgr.getResFromStr(_info.resName)
                _info.res1 = _t[1]
                _info.res2 = _t[2]
                _info.res3 = _t[3]
                for key = 1, #_t do
                    _t[key] = AdvEnvironmentMgr.makePath(_t[key])
                end
                _info.resName = _t
                SearchingMapMgr.floorItemTbl["floor"..floor][block] = _info
            end
        end

        if eType == SearchingMapMgr.EVENT_PICKING then
            local _info = clone(fbpickupInfo.get(resId))
            _info.resName = {
                [1] = AdvEnvironmentMgr.makePath(_info.res1, true),
                [2] = AdvEnvironmentMgr.makePath(_info.res2, true),
                [3] = AdvEnvironmentMgr.makePath(_info.res3, true),
            }
            
            local _s = string.sub(_info.target,2,-2)
            local _t = string.split(_s, ",")
            _info.targetType = tonumber(_t[1])
            _info.target     = tonumber(_t[2])

            _info.cond = (_info.cond == nil) and {} or SearchingMapMgr.getObClearConds(_info.cond)
            
            SearchingMapMgr.floorItemTbl["floor"..floor][block] = _info
            
            local info = SearchingMapMgr.floorItemTbl["floor"..floor][block]
            if tonumber(info.type) == 4 and AdvStarMgr.checkClearFlag(SearchingMapMgr.currAdventure) then
                SearchingMapMgr.floorEventTbl["floor"..floor][block] = SearchingMapMgr.EVENT_VOID
                SearchingMapMgr.floorItemTbl["floor"..floor][block] = {id="#TUTORIAL", resName="empty,empty,empty",}
            end
        end
        if eType == SearchingMapMgr.EVENT_MONSTER then
            local monster = clone(AdventureInfo.getMonstrosityInfoByID(resId))
            monster.monsterID = resId
            SearchingMapMgr.floorItemTbl["floor"..floor][block] = monster
        end
        if eType == SearchingMapMgr.EVENT_TRAINER then
            local trainer = clone(AdventureInfo.getMonsterGroupManInfoByID(resId))
            
            trainer.floor = floor
            trainer.tag = block
            
            SearchingMapMgr.floorItemTbl["floor"..floor][block] = trainer
        end
        if eType == SearchingMapMgr.EVENT_SWITCH then
            local _info = clone(switchInfo.get(resId)) or {}
            
            _info.name = _info.desc

            if _info.aniRes and _info.aniRes ~= "" then
                _info.aniRes = "Spine/searching/".._info.aniRes..".png"
            end
            
            _info.resName = {
                [1] = AdvEnvironmentMgr.makePath(_info.res1),
                [2] = AdvEnvironmentMgr.makePath(_info.res2),
                [3] = AdvEnvironmentMgr.makePath(_info.res3),
            }

            SearchingMapMgr.floorItemTbl["floor"..floor][block] = _info
        end
        if eType == SearchingMapMgr.EVENT_PORTAL then
            local _info = clone(teleportInfo.get(resId)) or {}
            
            _info.name = _info.desc
            if _info.aniRes and _info.aniRes ~= "" then
                _info.aniRes = "Spine/searching/".._info.aniRes..".png"
            end
            _info.resName = {
                [1] = AdvEnvironmentMgr.makePath(_info.res1),
                [2] = AdvEnvironmentMgr.makePath(_info.res2),
                [3] = AdvEnvironmentMgr.makePath(_info.res3),
            }
            
            SearchingMapMgr.floorItemTbl["floor"..floor][block] = _info
        end
        if eType == SearchingMapMgr.EVENT_OBSTRUCTION then
            local obInfo = clone( obstructionInfo.get(resId) ) or {}
            
            obInfo.id = tonumber(obInfo.id)
            obInfo.name = obInfo.desc
            obInfo.cond = (obInfo.cond == nil) and {} or SearchingMapMgr.getObClearConds(obInfo.cond)

            if obInfo.aniRes and obInfo.aniRes ~= "" then
                obInfo.aniRes = "Spine/searching/"..obInfo.aniRes..".png"
            end
            
            obInfo.resName = {
                [1] = AdvEnvironmentMgr.makePath(obInfo.res1),
                [2] = AdvEnvironmentMgr.makePath(obInfo.res2),
                [3] = AdvEnvironmentMgr.makePath(obInfo.res3),
            }
            
            SearchingMapMgr.floorItemTbl["floor"..floor][block] = obInfo
        end
        if eType == SearchingMapMgr.EVENT_EXIT then
            local _info = clone(itemsInfo.get(resId))
            
            local _t = SearchingMapMgr.getResFromStr(_info.resName)
            for key = 1, #_t do
                if _t[key] == "chukou" then _t[key] = "exit" end
                _t[key] = AdvEnvironmentMgr.makePath(_t[key])
            end
        
            SearchingMapMgr.floorExit["floor"..floor] = block
            SearchingMapMgr.floorItemTbl["floor"..floor][block] = {
                id      = _info.id,
                name    = _info.name,
                resName = _t,
                res1    = "exit",
                res2    = "exit",
                res3    = "exit",
            }
        end
        if eType == LtEventOption.EVENT_BILLBOARD then
            local _info = clone(billboardInfo.get(resId))
            
            _info.resName = {
                _info.res1,
                _info.res2,
                _info.res3,
            }
            
            SearchingMapMgr.floorItemTbl["floor"..floor][block] = _info 
        end
        if eType == LtEventOption.EVENT_ADV_NPC then
            SearchingMapMgr.floorItemTbl["floor"..floor][block] = clone(fbnpcInfo.get(resId))
        end

        if SearchingMapMgr.floorItemTbl["floor"..floor][block] then
            if SearchingMapMgr.floorItemTbl["floor"..floor][block].resName then
                SearchingMapMgr.floorItemTbl["floor"..floor][block].resName = SearchingMapMgr.getResFromStr(SearchingMapMgr.floorItemTbl["floor"..floor][block].resName)
                
                if SearchingMgr.ADV_DEBUG then
                    print("get block resName at: [floor:"..floor..",block:"..block.."]")
                    local line = ""
                    for _, value in pairs(SearchingMapMgr.floorItemTbl["floor"..floor][block].resName) do
                        line = line..value..","
                    end
                    print("  #### resName:",line)
                end
            end
        else
            print("ADV_ERROR:事件类型错误或资源获取失败")
        end
    end
    
    scene:performWithDelay(function()
        SearchingMapMgr.OriginalData = {
            clone(SearchingMapMgr.floorMapInfoTbl)     ,
            clone(SearchingMapMgr.floorEventTbl)       ,
            clone(SearchingMapMgr.floorItemTbl)        ,
            clone(SearchingMapMgr.floorEventStateTbl)  ,
            clone(SearchingMapMgr.floorMstrDefendTbl)  ,
            clone(SearchingMapMgr.floorEnterance)      ,
        }
    end,0.5)

end

-- release data

function SearchingMapMgr.clearGoalData()
    SearchingMapMgr.GoalTable  = {}
    SearchingMapMgr.GoalRecord = {}
end

function SearchingMapMgr.clearPickingData()
    SearchingMapMgr.pickingRecord = {}
end

function SearchingMapMgr.clearPropUseData()
    SearchingMapMgr.propUseRecord = {}
end


return SearchingMapMgr
