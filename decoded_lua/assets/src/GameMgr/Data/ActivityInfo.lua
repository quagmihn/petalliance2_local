local ActivityInfo = {}

ActivityInfo.TAB_NUM = 3

--活动类型
ActivityInfo.FetchUpgrade = 0
ActivityInfo.Activity = 1
ActivityInfo.FetchLogin = 3
ActivityInfo.GrowthFund = 6
ActivityInfo.FirstLogin = 10
ActivityInfo.GetPower = 11
ActivityInfo.PurchaseAward = 12
ActivityInfo.ConsumeRebate = 13
ActivityInfo.GetRebate = 14
ActivityInfo.GetAward = 15
ActivityInfo.LuoTianYi = 17
ActivityInfo.CapsuleEgg = 18
ActivityInfo.LostTower = 19
ActivityInfo.PVPArenaGradePoint = 20
ActivityInfo.TeamDungeon = 21
ActivityInfo.CollectPet = 22
ActivityInfo.WorldBoss = 23
ActivityInfo.ContinueLogin = 24
ActivityInfo.BossCombo = 25
ActivityInfo.BossAttackCount = 26
ActivityInfo.BossKillTime = 27
ActivityInfo.LifeSkill = 28
ActivityInfo.CatchPet = 29
ActivityInfo.SurvivalBattleIntro = 30
ActivityInfo.ActivityShop = 31
ActivityInfo.SurvivalBattle = 32
ActivityInfo.PVPArena = 33
ActivityInfo.ExpeditionClear = 34
ActivityInfo.ExpeditionJoin = 35
ActivityInfo.ExpeditionWin = 36
ActivityInfo.ActLostTower = 37

local ActivityInfoClientConfig = nil
local ActivityPokemonAchievementInfoConfig = nil
local SurvivalBattleAwardInfoConfig = nil
local ActivityShopInfoConfig = nil

function ActivityInfo.Init()

    if ActivityInfoClientConfig==nil then
        ActivityInfoClientConfig = require("src.DatReader.ActivityInfoClientConfig")
        ActivityInfoClientConfig.init()
    end

    if ActivityPokemonAchievementInfoConfig==nil then
        ActivityPokemonAchievementInfoConfig = require("src.DatReader.ActivityPokemonAchievementInfoConfig")
        ActivityPokemonAchievementInfoConfig.init()
    end

    if SurvivalBattleAwardInfoConfig == nil then
        SurvivalBattleAwardInfoConfig = require("src.DatReader.SurvivalBattleAwardInfoConfig")
        SurvivalBattleAwardInfoConfig.init()
    end

    if ActivityShopInfoConfig == nil then
        ActivityShopInfoConfig = require("src.DatReader.ActivityShopInfoConfig")
        ActivityShopInfoConfig.init()
    end
end

--[[
data.id=Proto.parseint(entry); -- 活动ID
data.name=Proto.parsestring(entry); -- 活动名称
data.beginTime=Proto.parsestring(entry); -- 开始时间
data.openServerDays=Proto.parseint(entry); -- 开服天数
data.lastTime=Proto.parseint(entry); -- 持续时间
data.isPeriod=Proto.parseint(entry); -- 是否循环
data.image=Proto.parsestring(entry); -- 活动图片
data.page=Proto.parseint(entry); -- 活动分页
data.type=Proto.parseint(entry); -- 类型
data.drawType=Proto.parsestring(entry); -- 领取方式
data.describe=Proto.parsestring(entry); -- 活动详情
data.androidDescribe=Proto.parsestring(entry); -- 安卓活动详情
data.params=Proto.parseVarArray(entry,Proto.parsestring,Proto.parseWORD); -- 参数
]]
function ActivityInfo.getActivityInfoById(id)
    return ActivityInfoClientConfig.readEntryByID(id)
end

function ActivityInfo.getActivityAllInfo()
    local vec = {}
    for var=1, ActivityInfoClientConfig.getEntryCount() do
        local id = ActivityInfoClientConfig.getEntryID(var)
        table.insert(vec, ActivityInfo.getActivityInfoById(id))
    end
    return vec
end

--[[
data.id=Proto.parseWORD(entry); -- 
data.name=Proto.parseString(entry); -- 
data.desc=Proto.parseString(entry); -- 
data.icon=Proto.parseString(entry); -- 
data.effect=Proto.parseString(entry); -- 效果
data.petIDs=Proto.parseVector(entry,Proto.parseDWORD); -- 宠物ID
data.awardIDs=Proto.parseVector(entry,Proto.parseDWORD); -- 奖励元素ID
data.count=Proto.parseVector(entry,Proto.parseDWORD); -- 奖励数量
]]

function ActivityInfo.getActivityPokemonAchievementInfoById(id)
    return ActivityPokemonAchievementInfoConfig.readEntryByID(id)
end

function ActivityInfo.getActivityPokemonAchievementAllInfo()
    local vec = {}
    for var=1, ActivityPokemonAchievementInfoConfig.getEntryCount() do
        local id = ActivityPokemonAchievementInfoConfig.getEntryID(var)
        table.insert(vec, ActivityInfo.getActivityPokemonAchievementInfoById(id))
    end
    return vec
end

--[[
data.id=Proto.parseDWORD(entry); -- ID
data.awardList=Proto.parseVector(entry,Proto.parseAwardList); -- 奖励列表
]]
function ActivityInfo.getSurvivalBattleAwardInfoById(id)
    return SurvivalBattleAwardInfoConfig.readEntryByID(id)
end

--[[
data.id=Proto.parseDWORD(entry); -- ID
data.itemID=Proto.parseDWORD(entry); -- 奖励元素ID
data.count=Proto.parseDWORD(entry); -- 购买个数
data.buyCount=Proto.parseDWORD(entry); -- 购买次数
data.price=Proto.parseDWORD(entry); -- 价格
]]
function ActivityInfo.getActivityShopInfoById(id)
    return ActivityShopInfoConfig.readEntryByID(id)
end

function ActivityInfo.getActivityShopAllInfo()
    local vec = {}
    for var=1, ActivityShopInfoConfig.getEntryCount() do
        local id = ActivityShopInfoConfig.getEntryID(var)
        table.insert(vec, ActivityInfo.getActivityShopInfoById(id))
    end
    return vec
end

function ActivityInfo.getActivitiesData()
    local tabTable = {}
    local tempTable = {}
    local activityParams = {}
    for i=0, ActivityInfo.TAB_NUM+1 do
        tabTable[i] = {}
    end
    for i=0, ActivityInfo.TAB_NUM+1 do
        tempTable[i] = {}
    end

    local activityInfoTabel = ActivityInfo.getActivityAllInfo()
    for k,v in pairs(activityInfoTabel) do
        activityParams[v.id] = {}
        for k1,v1 in pairs(v.params) do
            activityParams[v.id][k1] = {}
            activityParams[v.id][k1].awardVec = {}
            activityParams[v.id][k1].days = {}
            activityParams[v.id][k1].level = {}
            activityParams[v.id][k1].startTime = {}
            activityParams[v.id][k1].endTime = {}
            activityParams[v.id][k1].mCash = {}
            activityParams[v.id][k1].vipLv = {}
            activityParams[v.id][k1].weekDay = {}
            activityParams[v.id][k1].count = {}
            activityParams[v.id][k1].spendTime = {}
            activityParams[v.id][k1].lifeSkillLv = {}
            activityParams[v.id][k1].lifeSkillCount = {}
            activityParams[v.id][k1].value = {}
            local vec = lua_string_split(v1,",")
            if v.type == ActivityInfo.FirstLogin then
                local vec1 = lua_string_split(vec[1],"&")
                for k2,v2 in pairs(vec1) do
                    local vec2 = lua_string_split(v2,"_")
                    table.insert(activityParams[v.id][k1].awardVec,vec2)
                end
            elseif v.type == ActivityInfo.FetchLogin then
                activityParams[v.id][k1].days = tonumber(vec[2])
                local vec1 = lua_string_split(vec[1],"&")
                for k2,v2 in pairs(vec1) do
                    local vec2 = lua_string_split(v2,"_")
                    table.insert(activityParams[v.id][k1].awardVec,vec2)
                end
            elseif v.type == ActivityInfo.FetchUpgrade then
                activityParams[v.id][k1].level = tonumber(vec[2])
                local vec1 = lua_string_split(vec[3],"&")
                for k2,v2 in pairs(vec1) do
                    local vec2 = lua_string_split(v2,"_")
                    table.insert(activityParams[v.id][k1].awardVec,vec2)
                end
            elseif v.type == ActivityInfo.GetPower then
                activityParams[v.id][k1].startTime = tonumber(vec[1])
                activityParams[v.id][k1].endTime = tonumber(vec[2])
                activityParams[v.id][k1].awardVec = tonumber(vec[3])
            elseif v.type == ActivityInfo.PurchaseAward or v.type == ActivityInfo.ConsumeRebate then
                local tempID = 1
                if k1 == 1 then
                    activityParams[v.id][1].type = tonumber(vec[1])
                    tempID = 2
                end
                activityParams[v.id][k1].mCash = tonumber(vec[tempID])
                local vec1 = lua_string_split(vec[tempID+1],"&")
                for k2,v2 in pairs(vec1) do
                    local vec2 = lua_string_split(v2,"_")
                    table.insert(activityParams[v.id][k1].awardVec,vec2)
                end
            elseif v.type == ActivityInfo.GrowthFund then
                if k1 == 1 then
                    activityParams[v.id][k1].vipLv = tonumber(vec[1])
                    activityParams[v.id][k1].mCash = tonumber(vec[2])
                else
                    activityParams[v.id][k1-1].level = tonumber(vec[1])
                    local vec1 = lua_string_split(vec[2],"&")
                    for k2,v2 in pairs(vec1) do
                        local vec2 = lua_string_split(v2,"_")
                        table.insert(activityParams[v.id][k1-1].awardVec,vec2)
                    end
                end
            elseif v.type == ActivityInfo.CapsuleEgg then
                activityParams[v.id][k1].mCash = tonumber(vec[2])
            elseif v.type == ActivityInfo.LostTower or v.type == ActivityInfo.ActLostTower then
                activityParams[v.id][k1].weekDay = tonumber(vec[1])
                activityParams[v.id][k1].startTime = tonumber(vec[2])
                activityParams[v.id][k1].endTime = tonumber(vec[3])
            elseif v.type == ActivityInfo.PVPArenaGradePoint or v.type == ActivityInfo.TeamDungeon
                or v.type == ActivityInfo.WorldBoss or v.type == ActivityInfo.ContinueLogin then
                activityParams[v.id][k1].count = tonumber(vec[1])
                local vec1 = lua_string_split(vec[2],"&")
                for k2,v2 in pairs(vec1) do
                    local vec2 = lua_string_split(v2,"_")
                    table.insert(activityParams[v.id][k1].awardVec,vec2)
                end
            elseif v.type == ActivityInfo.BossCombo or v.type == ActivityInfo.BossAttackCount
                or v.type == ActivityInfo.PVPArena or v.type == ActivityInfo.ExpeditionClear
                or v.type == ActivityInfo.ExpeditionJoin or v.type == ActivityInfo.ExpeditionWin then
                activityParams[v.id][k1].count = tonumber(vec[2])
                local vec1 = lua_string_split(vec[1],"&")
                for k2,v2 in pairs(vec1) do
                    local vec2 = lua_string_split(v2,"_")
                    table.insert(activityParams[v.id][k1].awardVec,vec2)
                end
            elseif v.type == ActivityInfo.BossKillTime then
                activityParams[v.id][k1].spendTime = tonumber(vec[2])
                local vec1 = lua_string_split(vec[1],"&")
                for k2,v2 in pairs(vec1) do
                    local vec2 = lua_string_split(v2,"_")
                    table.insert(activityParams[v.id][k1].awardVec,vec2)
                end
            elseif v.type == ActivityInfo.LifeSkill then
                activityParams[v.id][k1].lifeSkillLv = tonumber(vec[2])
                activityParams[v.id][k1].lifeSkillCount = tonumber(vec[3])
                local vec1 = lua_string_split(vec[1],"&")
                for k2,v2 in pairs(vec1) do
                    local vec2 = lua_string_split(v2,"_")
                    table.insert(activityParams[v.id][k1].awardVec,vec2)
                end
            elseif v.type == ActivityInfo.CatchPet then
                activityParams[v.id][k1].count = tonumber(vec[1])
                activityParams[v.id][k1].value = tonumber(vec[2])
            elseif v.type == ActivityInfo.SurvivalBattleIntro then
                activityParams[v.id][k1].startTime = tonumber(v.beginTime)
                activityParams[v.id][k1].endTime = tonumber(v.beginTime + v.lastTime)
            elseif v.type == ActivityInfo.SurvivalBattle then
                activityParams[v.id][k1].count = tonumber(vec[2])
                local vec1 = lua_string_split(vec[1],"&")
                for k2,v2 in pairs(vec1) do
                    local vec2 = lua_string_split(v2,"_")
                    table.insert(activityParams[v.id][k1].awardVec,vec2)
                end
                activityParams[v.id][k1].startTime = tonumber(v.beginTime)
                activityParams[v.id][k1].endTime = tonumber(v.beginTime + v.lastTime)
            end
        end
        if v.type == ActivityInfo.CapsuleEgg then
            table.insert(tabTable[v.page],v)
        else
            table.insert(tempTable[v.page],v)
        end
    end
    for var=0, ActivityInfo.TAB_NUM+1 do
        if #tempTable[var] then
            for k,v in pairs(tempTable[var]) do
                table.insert(tabTable[var],v)
            end
        end
    end
    return tabTable, activityParams
end

function ActivityInfo.checkActivityValid(aInfo)
    local v = aInfo
    local platform = device.platform
    local loginTime = CharInfo.getServerTime()
    local beginTime = v.beginTime
    local lastTime = v.beginTime + v.lastTime
    local isPlat = true
    print("--------------")
    print("id", v.id, v.openServerDays)
    if v.openServerDays>=1 then
        beginTime = CharInfo.getServerOpenTime()+(v.openServerDays-1)*86400
        lastTime = beginTime + v.lastTime
    end
    if platform ~= "windows" then
        if v.plat ~= "all" then
            if v.plat ~= platform then
                isPlat = false
            end
        end
    end
    print("check activity type", v.type, v.image, loginTime, beginTime, lastTime)
    if loginTime <= lastTime and loginTime >= beginTime and isPlat then
        print("活动已开始")
        print("--------------")
        return true, loginTime, beginTime, lastTime
    end
    print("活动未开始或已结束")
    print("--------------")
    return false, loginTime, beginTime, lastTime
end

return ActivityInfo