local LostTowerInfo = {}

local StationaryAwardInfoConfig = nil
local LostTowerAwardInfoConfig  = nil
local TransferInfoConfig        = nil
local RecoverStateInfoConfig    = nil
local RandomChestInfoConfig     = nil
local LostTowerBossInfoConfig   = nil
local LostTowerResetInfoConfig  = nil
local TransferDoorInfoConfig    = nil
local CollectionInfoConfig      = nil
local RecoverEffectInfoConfig   = nil
local ObstacleInfoConfig        = nil
local PickUpItemInfoConfig      = nil
local LostTowerMonsterManGroupInfoConfig = nil
local LostTowerMonsterInfoConfig = nil
local TrapInfoConfig            = nil
local AttributeChangeInfoConfig = nil
local EventListInfoConfig       = nil
local FloorRelationInfoConfig   = nil  -- 层数关联表
local LostTowerDropInfoConfig   = nil  -- 钥匙掉落信息
local LostTowerRankAwardInfoConfig = nil  -- 排行榜奖励信息
local EmptyEventInfoConfig      = nil  -- 千层塔空事件表现

local LostTowerInfoConfig       = nil -- 千层塔地图信息

local FloorRankingList = {}
local PointRankingList = {}

local scheduler = require("src.framework.scheduler")
local stepFullTipHandler = nil

function LostTowerInfo.Init()
    if StationaryAwardInfoConfig==nil then
        StationaryAwardInfoConfig = require("src.DatReader.StationaryAwardInfoConfig")
        StationaryAwardInfoConfig.init()
    end
    
    if LostTowerAwardInfoConfig==nil then
        LostTowerAwardInfoConfig = require("src.DatReader.LostTowerAwardInfoConfig")
        LostTowerAwardInfoConfig.init()
    end
    
    if TransferInfoConfig==nil then
        TransferInfoConfig = require("src.DatReader.TransferInfoConfig")
        TransferInfoConfig.init()
    end
    
    if RecoverStateInfoConfig==nil then
        RecoverStateInfoConfig = require("src.DatReader.RecoverStateInfoConfig")
        RecoverStateInfoConfig.init()
    end
    
    if RandomChestInfoConfig==nil then
        RandomChestInfoConfig = require("src.DatReader.RandomChestInfoConfig")
        RandomChestInfoConfig.init()
    end
    
    if LostTowerBossInfoConfig==nil then
        LostTowerBossInfoConfig = require("src.DatReader.LostTowerBossInfoConfig")
        LostTowerBossInfoConfig.init()
    end
    
    if LostTowerResetInfoConfig==nil then
        LostTowerResetInfoConfig = require("src.DatReader.LostTowerResetInfoConfig")
        LostTowerResetInfoConfig.init()
    end
    
    if TransferDoorInfoConfig==nil then
        TransferDoorInfoConfig = require("src.DatReader.TransferDoorInfoConfig")
        TransferDoorInfoConfig.init()
    end
    
    if CollectionInfoConfig==nil then
        CollectionInfoConfig = require("src.DatReader.CollectionInfoConfig")
        CollectionInfoConfig.init()
    end
    
    if RecoverEffectInfoConfig==nil then
        RecoverEffectInfoConfig = require("src.DatReader.RecoverEffectInfoConfig")
        RecoverEffectInfoConfig.init()
    end
    
    if ObstacleInfoConfig==nil then
        ObstacleInfoConfig = require("src.DatReader.ObstacleInfoConfig")
        ObstacleInfoConfig.init()
    end
    
    if PickUpItemInfoConfig==nil then
        PickUpItemInfoConfig = require("src.DatReader.PickUpItemInfoConfig")
        PickUpItemInfoConfig.init()
    end
    
    if LostTowerMonsterManGroupInfoConfig==nil then
        LostTowerMonsterManGroupInfoConfig = require("src.DatReader.LostTowerMonsterManGroupInfoConfig")
        LostTowerMonsterManGroupInfoConfig.init()
    end
    
    if LostTowerMonsterInfoConfig==nil then
        LostTowerMonsterInfoConfig = require("src.DatReader.LostTowerMonsterInfoConfig")
        LostTowerMonsterInfoConfig.init()
    end
    
    if TrapInfoConfig==nil then
        TrapInfoConfig = require("src.DatReader.TrapInfoConfig")
        TrapInfoConfig.init()
    end
    
    if LostTowerInfoConfig==nil then
        LostTowerInfoConfig = require("src.DatReader.LostTowerInfoConfig")
        LostTowerInfoConfig.init()
    end
    
    if AttributeChangeInfoConfig==nil then
        AttributeChangeInfoConfig = require("src.DatReader.AttributeChangeInfoConfig")
        AttributeChangeInfoConfig.init()
    end
    
    if EventListInfoConfig==nil then
        EventListInfoConfig = require("src.DatReader.EventListInfoConfig")
        EventListInfoConfig.init()
    end
    
    if FloorRelationInfoConfig==nil then
        FloorRelationInfoConfig = require("src.DatReader.FloorRelationInfoConfig")
        FloorRelationInfoConfig.init()
    end
    
    if LostTowerDropInfoConfig==nil then
        LostTowerDropInfoConfig = require("src.DatReader.LostTowerDropInfoConfig")
        LostTowerDropInfoConfig.init()
    end
    
    if LostTowerRankAwardInfoConfig==nil then
        LostTowerRankAwardInfoConfig = require("src.DatReader.LostTowerRankAwardInfoConfig")
        LostTowerRankAwardInfoConfig.init()
    end
    
    if EmptyEventInfoConfig==nil then
        EmptyEventInfoConfig = require("src.DatReader.EmptyEventInfoConfig")
        EmptyEventInfoConfig.init()
    end
    
    if stepFullTipHandler then
        scheduler.unscheduleGlobal(stepFullTipHandler)
        stepFullTipHandler = nil
    end
end

--[[
Proto.writeDWORD(msg,data.id); -- ID
Proto.writeDWORD(msg,data.awardID); -- 奖励ID
--]]
function LostTowerInfo.getStationaryAwardInfoById(id)
    return StationaryAwardInfoConfig.readEntryByID(id)
end

--[[
data.id=Proto.parseDWORD(entry); -- ID
data.rate=Proto.parseDWORD(entry); -- 概率
data.itemID=Proto.parseDWORD(entry); -- 道具ID
data.count=Proto.parseDWORD(entry); -- 奖励次数
--]]
function LostTowerInfo.getLostTowerAwardInfoById(id)
    return LostTowerAwardInfoConfig.readEntryByID(id)
end

--[[
data.id=Proto.parseDWORD(entry); -- 层数ID
data.consume=Proto.parseDWORD(entry); -- 消耗ID
--]]
function LostTowerInfo.getTransferInfoById(id)
    return TransferInfoConfig.readEntryByID(id)
end

--[[
data.id=Proto.parseDWORD(entry); -- 次数
data.consume=Proto.parseDWORD(entry); -- 消耗
--]]
function LostTowerInfo.getRecoverStateInfoById(id)
    return RecoverStateInfoConfig.readEntryByID(id)
end

--[[
data.id=Proto.parseDWORD(entry); -- ID
data.openCondition=Proto.parseDWORD(entry); -- 打开宝箱需要道具，0表示不需要
data.randomAwardIDFirst=Proto.parseVector(entry,Proto.parseDWORD); -- 随机奖励1
data.randomAwardIDSecond=Proto.parseVector(entry,Proto.parseDWORD); -- 随机奖励2
data.randomAwardIDThird=Proto.parseVector(entry,Proto.parseDWORD); -- 随机奖励3
data.randomAwardIDFourth=Proto.parseVector(entry,Proto.parseDWORD); -- 随机奖励4
data.openBeforPath=Proto.parseString(entry); -- 宝箱打开前路径
data.openAfterPath=Proto.parseString(entry); -- 宝箱打开后路径
--]]
function LostTowerInfo.getRandomChestInfoById(id)
    return RandomChestInfoConfig.readEntryByID(id)
end

--[[
Proto.writeDWORD(msg,data.id); -- ID
Proto.writeString(msg,data.groupCode); -- 训练师代号
Proto.writeString(msg,data.name); -- 训练师名字
Proto.writeVector(msg,data.pokemons,Proto.writeDWORD); -- 携带宠物
Proto.writeString(msg,data.seniorFigure); -- 立绘形象
Proto.writeString(msg,data.figure); -- 形象
Proto.writeDWORD(msg,data.dir); -- 朝向
Proto.writeDWORD(msg,data.autoAttack); -- 主动出击
Proto.writeVector(msg,data.patrol,Proto.writeDWORD); -- 巡逻路径
Proto.writeDWORD(msg,data.disappear); -- 消失
--]]
function LostTowerInfo.getLostTowerBossInfoById(id)
    return LostTowerBossInfoConfig.readEntryByID(id)
end

--- 千层塔排行
function LostTowerInfo.setRankingList(string, type)

    type = type or 1
    local cjson = require("cjson")
    if type == 1 then     -- floor ranking list
        FloorRankingList = cjson.decode(string)
    elseif type == 2 then -- point ranking list
        PointRankingList = cjson.decode(string)
    end
    
end

function LostTowerInfo.clearRankingList()
    FloorRankingList = {}
    PointRankingList = {}
end

function LostTowerInfo.getFloorRankingList()
    return FloorRankingList
end

function LostTowerInfo.getFloorRankingListInfo(id)
    return FloorRankingList[id]
end

function LostTowerInfo.getPointRankingList()
    return PointRankingList
end

function LostTowerInfo.getPointRankingListInfo(id)
    return PointRankingList[id]
end

--[[
Proto.writeDWORD(msg,data.id); -- 次数ID
Proto.writeDWORD(msg,data.consume); -- 消耗ID
--]]
function LostTowerInfo.getLostTowerResetInfoById(id)
    return LostTowerResetInfoConfig.readEntryByID(id)
end

--[[
Proto.writeDWORD(msg,data.id); -- ID
Proto.writeDWORD(msg,data.x); -- x坐标
Proto.writeDWORD(msg,data.y); -- y坐标
Proto.writeString(msg,data.path); -- 资源路径
--]]
function LostTowerInfo.getTransferDoorInfoById(id)
    return TransferDoorInfoConfig.readEntryByID(id)
end

--[[
Proto.writeDWORD(msg,data.id); -- ID
Proto.writeDWORD(msg,data.needLevel); -- 需要生活职业等级
Proto.writeString(msg,data.beforeRes); -- 采集前资源
Proto.writeString(msg,data.afterRes); -- 采集后资源
Proto.writeVector(msg,data.dropList,Proto.writeDropList); -- 掉落列表
--]]
function LostTowerInfo.getCollectionInfoById(id)
    return CollectionInfoConfig.readEntryByID(id)
end

--[[
Proto.writeDWORD(msg,data.id); -- ID
Proto.writeDWORD(msg,data.type); -- 类型1表示百分比，2表示数值
Proto.writeDWORD(msg,data.value); -- 具体值
Proto.writeString(msg,data.expressionRes); -- 副本表现资源
Proto.writeString(msg,data.expressionEffect); -- 人物表现特效
]]
function LostTowerInfo.getRecoverEffectInfoById(id)
    return RecoverEffectInfoConfig.readEntryByID(id)
end

--[[
data.id=Proto.parseDWORD(entry); -- ID
data.type=Proto.parseDWORD(entry); -- 类型
data.conditionList=Proto.parseVector(entry,Proto.parseConditionList); -- 条件列表
data.terrainRes=Proto.parseDWORD(entry); -- 地形资源
data.clickReaction=Proto.parseString(entry); -- 点击反应
data.path=Proto.parseString(entry); -- 图片资源
data.flashEffect=Proto.parseString(entry); -- 动画效果
]]
function LostTowerInfo.getObstacleInfoById(id)
    return ObstacleInfoConfig.readEntryByID(id)
end

--[[
data.id=Proto.parseDWORD(entry); -- ID
data.desc=Proto.parseString(entry); -- 描述
data.path=Proto.parseString(entry); -- 资源路径
data.effectObj=Proto.parseDWORD(entry); -- 作用对象
]]
function LostTowerInfo.getPickUpItemInfoById(id)
    return PickUpItemInfoConfig.readEntryByID(id)
end

--[[
Proto.writeDWORD(msg,data.id); -- ID
Proto.writeString(msg,data.groupCode); -- 训练师代号
Proto.writeString(msg,data.name); -- 训练师名字
Proto.writeVector(msg,data.fightPokemons,Proto.writeDWORD); -- 战斗宠物
Proto.writeVector(msg,data.aidPokemons,Proto.writeDWORD); -- 援助宠物
Proto.writeString(msg,data.seniorFigure); -- 立绘形象
Proto.writeString(msg,data.figure); -- 形象
Proto.writeDWORD(msg,data.dir); -- 朝向
Proto.writeDWORD(msg,data.autoAttack); -- 主动出击
Proto.writeVector(msg,data.patrol,Proto.writeDWORD); -- 巡逻路径
Proto.writeString(msg,data.commingTalk); -- 训练师登场对话
Proto.writeString(msg,data.deadTalk); -- 训练师失败对话
Proto.writeDWORD(msg,data.disappear); -- 消失
Proto.writeDWORD(msg,data.dropType); -- 掉落类型
]]--
function LostTowerInfo.getLostTowerMonsterManGroupInfoById(id)
    return LostTowerMonsterManGroupInfoConfig.readEntryByID(id)
end

--[[
data.id=Proto.parseDWORD(entry); -- ID
data.number=Proto.parseString(entry); -- 怪物编号
data.petnumber=Proto.parseDWORD(entry); -- 宠物编号
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
data.paSkills=Proto.parseVector(entry,Proto.parseDWORD); -- 被动技能
data.petGeneID=Proto.parseDWORD(entry); -- 宠物生成ID
]]
function LostTowerInfo.getLostTowerMonsterInfoById(id)
    return LostTowerMonsterInfoConfig.readEntryByID(id)
end

--[[
data.id=Proto.parseDWORD(entry); -- ID
data.type=Proto.parseDWORD(entry); -- 类型
data.value=Proto.parseDWORD(entry); -- 具体值
]]--
function LostTowerInfo.getTrapInfoById(id)
    return TrapInfoConfig.readEntryByID(id)
end

--[[
data.id=Proto.parseDWORD(entry); -- ID
data.type=Proto.parseDWORD(entry); -- 增加类型1表示百分比，2表示数值
data.value=Proto.parseint(entry); -- 具体数值
data.stepNumber=Proto.parseDWORD(entry); -- 持续步数
]]--
function LostTowerInfo.getExBuffInfoById(id)
    return AttributeChangeInfoConfig.readEntryByID(id)
end

--[[
data.id=Proto.parseDWORD(entry); -- ID
data.eventList=Proto.parseVector(entry,Proto.parseEventList); -- 
    data.eventType=Proto.parseDWORD(entry); -- 事件类型
    data.event=Proto.parseDWORD(entry); -- 事件表现
    data.rate=Proto.parseDWORD(entry); -- 概率
]]--
function LostTowerInfo.getEventListInfoById(id)
    return EventListInfoConfig.readEntryByID(id)
end

--[[
data.id=Proto.parseDWORD(entry); -- ID
data.boss=Proto.parseDWORD(entry); -- 守关BOSS
data.award=Proto.parseDWORD(entry); -- 奖励
data.monster=Proto.parseDWORD(entry); -- 野生怪物
data.trainer=Proto.parseDWORD(entry); -- 训练师
data.chest=Proto.parseDWORD(entry); -- 随机宝箱
data.collection=Proto.parseDWORD(entry); -- 采集
data.petLevel=Proto.parseDWORD(entry); -- 宠物等级
data.petStage=Proto.parseDWORD(entry); -- 宠物强化等级
data.petStar=Proto.parseDWORD(entry); -- 宠物星数
data.normalDrop=Proto.parseVector(entry,Proto.parseDWORD); -- 普通掉落
data.eliteDrop=Proto.parseVector(entry,Proto.parseDWORD); -- 精英掉落
data.bossDrop=Proto.parseVector(entry,Proto.parseDWORD); -- BOSS掉落
data.monsterExp=Proto.parseDWORD(entry); -- 怪物经验
data.trainerExp=Proto.parseDWORD(entry); -- 训练师经验
data.bossExp=Proto.parseDWORD(entry); -- BOSS经验
]]
function LostTowerInfo.getFloorRelationInfoById(id)
    return FloorRelationInfoConfig.readEntryByID(id)
end

--[[
data.id=Proto.parseDWORD(entry); -- ID
data.dropList=Proto.parseVector(entry,Proto.parseDropDetail); -- 掉落列表
    data.itemID=Proto.parseDWORD(entry); -- 道具ID
    data.count=Proto.parseDWORD(entry); -- 道具个数
    data.rate=Proto.parseDWORD(entry); -- 概率
]]--
function LostTowerInfo.getLostTowerDropInfoById(id)
    return LostTowerDropInfoConfig.readEntryByID(id)
end

--[[
data.id=Proto.parseDWORD(entry); -- ID
data.awardList=Proto.parseVector(entry,Proto.parseRankAwardList); -- 排行奖励详细列表
    data.mailID=Proto.parseDWORD(entry); -- 邮件ID
    data.awardItems=Proto.parseVector(entry,Proto.parseDWORD); -- 奖励元素信息
]]--
function LostTowerInfo.getLostTowerRankAwardInfoById(id)
    return LostTowerRankAwardInfoConfig.readEntryByID(id)
end

--[[
data.id=Proto.parseDWORD(entry); -- ID
data.type=Proto.parseDWORD(entry); -- 类型
data.animationEffects=Proto.parseString(entry); -- 动画效果
data.terrainRes=Proto.parseString(entry); -- 地形资源
data.isGround=Proto.parseDWORD(entry); -- 代替地砖
data.backup=Proto.parseString(entry); -- 补充
]]
function LostTowerInfo.getEmptyEventInfoById(id)
    return EmptyEventInfoConfig.readEntryByID(id)
end

--[[
data.id=Proto.parseDWORD(entry); -- ID
data.lostTowerList=Proto.parseVector(entry,Proto.parseLostTowerList); 
    data.x=Proto.parseWORD(entry); -- X坐标
    data.y=Proto.parseWORD(entry); -- Y坐标
    data.type=Proto.parseDWORD(entry); -- 事件类型
    data.eventListID=Proto.parseDWORD(entry); -- 事件列表ID
    data.terrRes=Proto.parseDWORD(entry); -- 地形资源
]]
function LostTowerInfo.getLostTowerMapInfoById(id)
    return LostTowerInfoConfig.readEntryByID(id)
end

-- 计算千层塔当前步数
function LostTowerInfo.getCurrentStepNumber()
    if not LostTowerMgr.stepRefreshTime or LostTowerMgr.stepRefreshTime == 0 then return 0 end
    
    local stepNumMax  = CharInfo.getVipInfoByID(CharInfo.getVIPLevel()).ltSetpNumber + LostTowerMgr.stepMaxAdditional 
    local timep = CharInfo.getVipInfoByID(CharInfo.getVIPLevel()).lostTowerRecoverTime -- SystemInfo.getGlobalConfigAddInfoByID(32).values[1]
    
    local stepNumAdded = 0

    local passTime = CharInfo.getServerTime() - LostTowerMgr.stepRefreshTime
    
    stepNumAdded = math.floor( passTime/timep )
    
    if LostTowerMgr.stepNumber >= stepNumMax then
        stepNumAdded = 0
    else
        if LostTowerMgr.stepNumber + stepNumAdded >= stepNumMax then
            stepNumAdded = stepNumMax - LostTowerMgr.stepNumber
        end
    end
    
    return LostTowerMgr.stepNumber + stepNumAdded
end

function LostTowerInfo.refreshServerTime()
    if not LostTowerMgr.stepRefreshTime then return end
    if LostTowerMgr.stepRefreshTime == 0 then return end

    local stepNumber = LostTowerMgr.stepNumber

    local stepMaxAdditional = CharInfo.get().furniturelosttowermaxstepnumber or 0
    local stepNumberMax = CharInfo.getVipInfoByID(CharInfo.getVIPLevel()).ltSetpNumber + stepMaxAdditional
    
    local function check()
        if stepNumber >= stepNumberMax then
            ExploreViewMgr.addRedPoint(2)
        else
            ExploreViewMgr.hideRedPoint(2)
        
            if stepFullTipHandler then
                scheduler.unscheduleGlobal(stepFullTipHandler)
            end
            
            local passTime = CharInfo.getServerTime() - LostTowerMgr.stepRefreshTime
            local timep = CharInfo.getVipInfoByID(CharInfo.getVIPLevel()).lostTowerRecoverTime -- SystemInfo.getGlobalConfigAddInfoByID(32).values[1]  -- 刷新时间间隔
            local timediff = timep - (passTime % timep)
            timediff = timediff + (stepNumberMax - stepNumber - 1) * timep
            print(timediff.."秒后，步数加满...")
            if timediff < 0 then
                ExploreViewMgr.addRedPoint(2)
            else
                stepFullTipHandler = scheduler.performWithDelayGlobal(function()
                    print("步数加满了")
                    ExploreViewMgr.addRedPoint(2)
                end, timediff)
                BaseFunction.cancelLocalNotificationWithKey(4)
                BaseFunction.registerLocalNotification(os.time()+timediff, nil, "idling30", "", 4, 0)
            end
        end
    end
    check()
    
end

function LostTowerInfo.checkLTActivity()
    local tabinfo, params = ActivityViewMgr.getActivitiesData()

    local function check(id)
        local acInfo = params[id]
        if not acInfo then return false end
        for key, var in pairs(tabinfo[3]) do
            if var.id==id then
                local res, loginTime, beginTime, lastTime = ActivityInfo.checkActivityValid(var)
                if not res then
                    return false
                end
            end
        end

        local wDay = tonumber(CocosModuleMgr.getTimeStr(nil,6))
        local hour = tonumber(CocosModuleMgr.getTimeStr(nil,2))

        for _,v in pairs(acInfo) do
            if v.weekDay == wDay then
                if hour >= v.startTime and hour < v.endTime then
                    --print(hour, v.startTime, v.endTime)
                    return true
                end 
            end
        end
        return false
    end
    
    if check(16) or check(21) then
    	return true
    end
    return false
end

return LostTowerInfo