local AdventureInfo = {}

local AdventureInfoConfig = nil
local SceneInfoConfig = nil
local MonstrosityInfoConfig = nil
local DBossInfoConfig = nil
local DropInfoConfig = nil
local RewardInfoConfig = nil
local EventInfoConfig = nil
local MonsterGroupManInfoConfig = nil
local DisposableInfoConfig = nil
local ResetInfoConfig = nil -- 副本扫荡重置信息
local MapStarAwarConfig = nil
local AdvAwardConfig = nil

local AdvLevelLimitInfoConfig = nil
local firstAidTable = {}

local AdventureInfoTbl = {}
local SceneInfoTbl = {}
local MonstrosityInfoTbl = {}
local DBossInfoTbl = {}
local DropInfoTbl = {}
local RewardInfoTbl = {}
local EventInfoTbl = {}
local finished = {}
local highestAdvs = {}

local MapEventTbl = {}
local MyMapEventTbl = {}
local FamilyQuestInfo = nil

function AdventureInfo.Init()
    if AdventureInfoConfig==nil then
        AdventureInfoConfig = require("src.DatReader.AdventureInfoConfig")
        AdventureInfoConfig.init()
    end
    
    if SceneInfoConfig==nil then
        SceneInfoConfig = require("src.DatReader.SceneInfoConfig")
        SceneInfoConfig.init()
    end
    
    if MonstrosityInfoConfig==nil then
        MonstrosityInfoConfig = require("src.DatReader.MonstrosityInfoConfig")
        MonstrosityInfoConfig.init()
    end
    
    if DBossInfoConfig==nil then
        DBossInfoConfig = require("src.DatReader.DBossInfoConfig")
        DBossInfoConfig.init()
    end
    
    if DropInfoConfig==nil then
        DropInfoConfig = require("src.DatReader.DropInfoConfig")
        DropInfoConfig.init()
    end
    
    if RewardInfoConfig==nil then
        RewardInfoConfig = require("src.DatReader.RewardInfoConfig")
        RewardInfoConfig.init()
    end
    
    if EventInfoConfig==nil then
        EventInfoConfig = require("src.DatReader.EventInfoConfig")
        EventInfoConfig.init()
    end
    
    if MonsterGroupManInfoConfig==nil then
        MonsterGroupManInfoConfig = require("src.DatReader.MonsterGroupManInfoConfig")
        MonsterGroupManInfoConfig.init()
    end
    
    if DisposableInfoConfig==nil then
        DisposableInfoConfig = require("src.DatReader.DisposableInfoConfig")
        DisposableInfoConfig.init()
    end
    
    if ResetInfoConfig==nil then
        ResetInfoConfig = require("src.DatReader.ResetInfoConfig")
        ResetInfoConfig.init()
    end
    
    if MapStarAwarConfig==nil then
        MapStarAwarConfig = require("src.DatReader.MapStarAwardConfig")
        MapStarAwarConfig.init()
    end
    
    if AdvAwardConfig==nil then
        AdvAwardConfig = require("src.DatReader.AdvAwardConfig")
        AdvAwardConfig.init()
    end
    
    if AdvLevelLimitInfoConfig==nil then
        AdvLevelLimitInfoConfig = TxtReader.new("Config/firstfb.txt")
        local firstAidInfo = AdvLevelLimitInfoConfig.init({"aid"},1)
        
        firstAidTable = {}
        for key, var in pairs(firstAidInfo) do
            firstAidTable[tonumber(var.aid)] = true
        end
    end
    
    finished = {}  --星数清空
    
    highestAdvs = {0, 0, 0}  --最高关卡信息
    
    MapEventTbl = {}
    MyMapEventTbl = {}
    FamilyQuestInfo = nil
end

--[[
data.id=Proto.parseDWORD(entry); -- ID
data.name=Proto.parseString(entry); -- 副本名称
data.prompt_1=Proto.parseString(entry); -- 副本提示1
data.prompt_2=Proto.parseString(entry); -- 副本提示2
data.prompt_3=Proto.parseString(entry); -- 副本提示3
data.floor=Proto.parseDWORD(entry); -- 副本层数
data.scene=Proto.parseDWORD(entry); -- 副本场景
data.weather=Proto.parseDWORD(entry); -- 副本天气
data.Exp_rewards=Proto.parseDWORD(entry); -- 主角经验奖励
data.prepose=Proto.parseDWORD(entry); -- 前置副本
data.power=Proto.parseDWORD(entry); -- 体力消耗
data.level=Proto.parseDWORD(entry); -- 主角等级要求
data.type=Proto.parseDWORD(entry); -- 副本类型
data.prop=Proto.parseString(entry); -- 进入道具需求
data.prop_amount=Proto.parseDWORD(entry); -- 进入道具需求数
data.resurgence=Proto.parseBYTE(entry); -- 是否可复活
data.resurgence_cost=Proto.parseDWORD(entry); -- 复活代价
data.target=Proto.parseDWORD(entry); -- 副本目标
data.target_parameter=Proto.parseString(entry); -- 副本目标参数
data.rewards=Proto.parseDWORD(entry); -- 副本奖励
data.rewards_Icon=Proto.parseString(entry); -- 副本通关奖励Icon
data.diffcultType=Proto.parseDWORD(entry); -- 难度种类 1-普通 2-普通+精英 3-普通+精英+英雄
data.fightWarning=Proto.parseString(entry); -- 遇敌提醒
--]]
function AdventureInfo.getAdventureInfoByID(id)
    return AdventureInfoConfig.readEntryByID(id)
end

--[[
data.id=Proto.parseDWORD(entry); -- ID
data.number=Proto.parseDWORD(entry); -- 副本编号
data.name=Proto.parseString(entry); -- 场景名称
data.event=Proto.parseDWORD(entry); -- 事件编号
data.eventX=Proto.parseDWORD(entry); -- 事件X坐标
data.eventY=Proto.parseDWORD(entry); -- 事件Y坐标
data.floor=Proto.parseDWORD(entry); -- 层数
--]]
function AdventureInfo.getSceneInfoByID(id)
    return SceneInfoConfig.readEntryByID(id)
end

--[[
data.id=Proto.parseDWORD(entry); -- ID
data.number=Proto.parseString(entry); -- 怪物编号
data.level=Proto.parseVector(entry,Proto.parseDWORD); -- 怪物等级
data.petnumber=Proto.parseDWORD(entry); -- 宠物编号
data.petStage=Proto.parseDWORD(entry); -- 宠物阶数
data.petStar=Proto.parseDWORD(entry); -- 宠物星数
data.amendmentHP=Proto.parseDWORD(entry); -- HP修正比例
data.amendmentSPD=Proto.parseDWORD(entry); -- SPD修正比例
data.amendmentATK=Proto.parseDWORD(entry); -- ATK修正比例
data.amendmentDEF=Proto.parseDWORD(entry); -- DEF修正比例
data.amendmentSATK=Proto.parseDWORD(entry); -- SATK修正比例
data.amendmentSDEF=Proto.parseDWORD(entry); -- SDEF修正比例
data.dropnumber=Proto.parseDWORD(entry); -- 掉落编号
data.skill1=Proto.parseVector(entry,Proto.parseDWORD); -- 怪物技能1
data.skill2=Proto.parseVector(entry,Proto.parseDWORD); -- 怪物技能2
data.skill3=Proto.parseVector(entry,Proto.parseDWORD); -- 怪物技能3
data.skill4=Proto.parseDWORD(entry); -- 怪物技能4
data.skill1_pro=Proto.parseDWORD(entry); -- 怪物技能1发动概率
data.skill2_pro=Proto.parseDWORD(entry); -- 怪物技能2发动概率
data.skill3_pro=Proto.parseDWORD(entry); -- 怪物技能3发动概率
data.skill4_pro=Proto.parseDWORD(entry); -- 怪物技能4发动概率
data.catchRate=Proto.parseDWORD(entry); -- 捕获率
data.away=Proto.parseDWORD(entry); -- 逃跑率
data.capture=Proto.parseDWORD(entry); -- 最大捕获机会
--]]
function AdventureInfo.getMonstrosityInfoByID(id)
    return MonstrosityInfoConfig.readEntryByID(id)
end

--[[
data.id=Proto.parseDWORD(entry); -- ID
data.number=Proto.parseDWORD(entry); -- BOSS编号
data.name=Proto.parseString(entry); -- BOSS名称
data.skin=Proto.parseDWORD(entry); -- BOSS皮肤
data.serial=Proto.parseDWORD(entry); -- BOSS宠物序号
data.petNumber=Proto.parseDWORD(entry); -- BOSS宠物编号
data.petLevel=Proto.parseDWORD(entry); -- BOSS宠物等级
data.petSkill1=Proto.parseDWORD(entry); -- BOSS宠物技能1
data.petSkill2=Proto.parseDWORD(entry); -- BOSS宠物技能2
data.petSkill3=Proto.parseDWORD(entry); -- BOSS宠物技能3
data.skill1_pro=Proto.parseDWORD(entry); -- BOSS宠物技能1发动概率
data.skill2_pro=Proto.parseDWORD(entry); -- BOSS宠物技能2发动概率
data.skill3_pro=Proto.parseDWORD(entry); -- BOSS宠物技能3发动概率
data.prologue=Proto.parseString(entry); -- BOSS开场白
data.closing=Proto.parseString(entry); -- BOSS结束语
data.dropnumber=Proto.parseDWORD(entry); -- 掉落编号
--]]
function AdventureInfo.getDBossInfoByID(id)
    return DBossInfoConfig.readEntryByID(id)
end

--[[
data.id=Proto.parseDWORD(entry); -- ID
data.dropnumber=Proto.parseString(entry); -- 掉落编号
data.reNumber=Proto.parseVector(entry,Proto.parseWORD); -- 奖池编号
data.count=Proto.parseVector(entry,Proto.parseWORD); -- 抽取次数
data.ticket=Proto.parseDWORD(entry); -- 奖券支付
data.nTicket=Proto.parseDWORD(entry); -- 奖券支付数
--]]
function AdventureInfo.getDropInfoByID(id)
    return DropInfoConfig.readEntryByID(id)
end

--[[
data.id=Proto.parseDWORD(entry); -- ID
data.number=Proto.parseString(entry); -- 奖池编号
data.element=Proto.parseVector(entry,Proto.parseDWORD); -- 奖励元素
data.nReward=Proto.parseVector(entry,Proto.parseDWORD); -- 奖励数
data.probability=Proto.parseVector(entry,Proto.parseDWORD); -- 获得概率
--]]
function AdventureInfo.getRewardInfoByID(id)
    return RewardInfoConfig.readEntryByID(id)
end

--[[
data.id=Proto.parseDWORD(entry); -- ID
data.number=Proto.parseString(entry); -- 事件编号
data.type=Proto.parseDWORD(entry); -- 事件类型
data.eventA=Proto.parseString(entry); -- 事件参数A
data.eventB=Proto.parseString(entry); -- 事件参数B
data.eventC=Proto.parseString(entry); -- 事件参数C
data.eventD=Proto.parseString(entry); -- 事件参数D
data.eventE=Proto.parseString(entry); -- 事件参数E
--]]
function AdventureInfo.getEventInfoByID(id)
    return EventInfoConfig.readEntryByID(id)
end

--[[
data.id=Proto.parseDWORD(entry); -- ID
data.groupCode=Proto.parseString(entry); -- 训练师代号
data.name=Proto.parseString(entry); -- 训练师名字
data.pokemons=Proto.parseVector(entry,Proto.parseDWORD); -- 携带宠物
data.seniorFigure=Proto.parseString(entry); -- 立绘形象
data.figure=Proto.parseString(entry); -- 形象
data.dir=Proto.parseDWORD(entry); -- 朝向
data.autoAttack=Proto.parseDWORD(entry); -- 主动出击
data.patrol=Proto.parseVector(entry,Proto.parseDWORD); -- 巡逻路径
data.disappear=Proto.parseDWORD(entry); -- 消失
]]
function AdventureInfo.getMonsterGroupManInfoByID(id)
    return MonsterGroupManInfoConfig.readEntryByID(id)
end

--[[
data.id=Proto.parseDWORD(entry); -- ID
data.eventType=Proto.parseDWORD(entry); -- 事件类型
data.event=Proto.parseDWORD(entry); -- 事件表现
data.finishEventType=Proto.parseDWORD(entry); -- 结束后事件表现
data.finishEvent=Proto.parseDWORD(entry); -- 结束后事件类型
]]
function AdventureInfo.getDisposableInfoByID(id)
    return DisposableInfoConfig.readEntryByID(id)
end

--[[
data.id=Proto.parseDWORD(entry); -- 重置次数
data.cost=Proto.parseDWORD(entry); -- 花费钻石
]]
function AdventureInfo.getResetInfoByID(id)
    return ResetInfoConfig.readEntryByID(id)
end

--[[
data.id=Proto.parseDWORD(entry); -- ID
data.bMapID=Proto.parseDWORD(entry); -- 
data.level=Proto.parseDWORD(entry); -- 
data.needStar=Proto.parseDWORD(entry); -- 
data.awardElements=Proto.parseVector(entry,Proto.parseDWORD); -- 
data.awardElementNums=Proto.parseVector(entry,Proto.parseDWORD); -- 
]]
function AdventureInfo.getMapStarAwarByMapID(mapid)
    local tmpvec = {}
    for var=1, MapStarAwarConfig.getEntryCount() do
        local id = MapStarAwarConfig.getEntryID(var)
        local data = MapStarAwarConfig.readEntryByID(id)
        --print(data.id, data.bMapID, data.needStar)
        if tonumber(mapid)==tonumber(data.bMapID) then
            table.insert(tmpvec, data)
        end
    end
    return tmpvec
end

--[[
data.id=Proto.parseDWORD(entry); -- ID
data.petGeneID=Proto.parseDWORD(entry); --
]] 
function AdventureInfo.getAdvAwardByID(id)
    return AdvAwardConfig.readEntryByID(id)
end

---set all finished adventures
function AdventureInfo.setFinished(data)
    for key, value in pairs(data) do
        local id = value["advID"] --副本id
        local star = value["star"] --星数
        local qctimes = value["qcTimes"] --次数
        local hasEvent = value["hasEvent"] --一次性事件标记
        local qcupdatetime = value["qcUpdateTime"] --数据记录的时间点
        local qcrefreshtimes = value["qcRefreshTimes"] --扫荡重置次数
        if id ~= nil then
            print("set finishend..............."..id,qctimes)
            finished[id] = { star=star or 0, qctimes = qctimes or 0,qcupdatetime = qcupdatetime or 0,hasEvent = hasEvent or {},qcrefreshtimes = qcrefreshtimes or 0}
            
            local difficult = math.ceil( id / 10000 )
            if id > highestAdvs[difficult] then 
                highestAdvs[difficult] = id
                CharInfo.get()["advexp"..difficult] = AdventureInfo.getAdventureInfoByID(id).Exp_rewards
            end
            
            AdvConfirmMgrNew.refreshSaodangInfo(id)
        end
    end
end

---get finished by ID
function AdventureInfo.getFinishedByID(id)
    return finished[id] or {star=0,}
end

--- 获取最高通关关卡
-- @param difficult number 区分普通精英英雄
function AdventureInfo.getHighestAdv(difficult)
    return highestAdvs[difficult]
end

function AdventureInfo.setFinishedMapEventInfo(tbl)
    if not tbl then
    	return
    end
    if tbl.dailyEvents then
        MyMapEventTbl = {}
        for key, var in pairs(tbl.dailyEvents) do
            table.insert(MyMapEventTbl, {mapid=var.mapID, pid=var.nodeID})
        end
    end
end

function AdventureInfo.setMapEventInfo(params)
    print("AdventureInfo.setMapEventInfo", params)
    local cjson = require("cjson")
    local tbl = cjson.decode(params)
    if #MapEventTbl>0 then
        for var=1, #MapEventTbl do
            WorldMapMgr.removeEvent(MapEventTbl[var].mapid, MapEventTbl[var].pid)
        end
    end
    MapEventTbl = {}
    AdventureInfo.setFinishedMapEventInfo(tbl)
    --[[
    local dayDiff = CocosModuleMgr.getDayTimeDiff(LoginMsgMgr.getLoginTime(), CharInfo.getServerTime())
    if dayDiff~=0 then
    	MyMapEventTbl = {}
    end]]
    if not tbl.dailyEventsAll then
    	return
    end
    FurnitureTVMgr.setRefreshTimes(tbl.refreshTimes)
    for key, var in pairs(tbl.dailyEventsAll) do
        if type(var)=="table" then
            local finishFlag = false
            for i=1, #MyMapEventTbl do
                if MyMapEventTbl[i].mapid==var.mapID and MyMapEventTbl[i].pid==var.nodeID then
                    print("this map event is finished:", MyMapEventTbl[i].mapid, MyMapEventTbl[i].pid)
                    finishFlag = true
                    break
                end
            end
            if not finishFlag then
                table.insert(MapEventTbl, {index=key, mapid=var.mapID, pid=var.nodeID, eid=var.eventID, skin=var.skin})
                print("event info:", var.mapID, var.nodeID, var.eventID, var.skin)
            end
        end
    end
    WorldMapMgr.checkMapEventInfo()
end

function AdventureInfo.removeMapEventInfo(mapid, pid)
    for var=1, #MapEventTbl do
        if MapEventTbl[var].mapid==mapid and MapEventTbl[var].pid==pid then
            print("this map event is finished:", MapEventTbl[var].mapid, MapEventTbl[var].pid)
            table.insert(MyMapEventTbl, {mapid=mapid, pid=pid})
            WorldMapMgr.removeEvent(MapEventTbl[var].mapid, MapEventTbl[var].pid)
            table.remove(MapEventTbl, var)
            print("remain events num:", #MapEventTbl)
            return 
        end
    end
end

function AdventureInfo.getMapEventInfo(mapid)
    local eventVec = {}
    for var=1, #MapEventTbl do
        if MapEventTbl[var].mapid==mapid then
            table.insert(eventVec, MapEventTbl[var])
    	end
    end
    --print("cur map events num:", #eventVec)
    return eventVec
end

function AdventureInfo.getFamilyQuestInfo()
    local endTime = tonumber(CharInfo.getFamilyQuestFailedTime())
    if not endTime then
    	return nil
    end
    if CharInfo.getServerTime()>endTime then
    	return nil
    end
    return FamilyQuestInfo
end

function AdventureInfo.setFamilyQuestInfo(mapID, pID, trainerID, petID)
    if not trainerID and not petID then
    	FamilyQuestInfo = nil
    else
        if CharInfo.getFamilyQuestOK()~=1 then
            FamilyQuestInfo = {mapID = mapID, pID = pID, trainerID = trainerID, petID = petID}
            WorldMapMgr.checkConfraternityInfo()
        end        
    end
end

-- 副本是否需要限制等级
function AdventureInfo.isFirstAid(aid)
    return firstAidTable[aid]
end

return AdventureInfo