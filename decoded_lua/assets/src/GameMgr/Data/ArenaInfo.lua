local ArenaInfo = {}

ArenaInfo.REQUEST_TIMEDIFF = 60

local info = {}
local enemyInfo = {}
local battleInfo = {}
local rankList = {}
local rankListPets = {}
local rankListHelperPets = {}
local refreshRankTime = 0
local colddownTime = 0
local challengeTimes = 0
local ArenaAwardInfoConfig = nil
local PVPArenaGradeInfoConfig = nil
local PVPArenaRank = {}
local myPVPArenaRank = 0

local scheduler = require("src.framework.scheduler")
local checkPVPAwardsHandler = nil

function ArenaInfo.Init()
    info = {
        rank = 0,
        teamID = 1,
        armyID = 1,
        point = 0,
    }
    enemyInfo = {}
    battleInfo = {}
    rankList = {}
    rankListPets = {}
    rankListHelperPets = {}
    refreshRankTime = 0
    colddownTime = 0
    challengeTimes = 0

    PVPArenaRank = {}
    myPVPArenaRank = 0

    if ArenaAwardInfoConfig==nil then
        ArenaAwardInfoConfig = require("src.DatReader.ArenaAwardInfoConfig")
        ArenaAwardInfoConfig.init()
    end
    
    if PVPArenaGradeInfoConfig==nil then
        PVPArenaGradeInfoConfig = require("src.DatReader.PVPArenaGradeInfoConfig")
        PVPArenaGradeInfoConfig.init()
    end
    
    if checkPVPAwardsHandler then
        scheduler.unscheduleGlobal(checkPVPAwardsHandler)
        checkPVPAwardsHandler = nil
    end
end

function ArenaInfo.update(params)
    for key, var in pairs(params) do
        info[key] = var
		if key=="armyID" then
            CharInfo.setLocalSettings({ArenaAttackArmyID=var})
        elseif key=="rank" then
            -- ArenaViewMgr.refreshArenaRank()
		end
	end
end

function ArenaInfo.getRank()
	return info.rank
end

function ArenaInfo.getTopRank()
    return info.topRank
end

function ArenaInfo.getAttackArmyID()
    local aid = CharInfo.getLocalSettings("ArenaAttackArmyID") or info.armyID
    if aid<1 or aid>5 then
    	return 1
    end
    return aid
end

function ArenaInfo.getDefenceArmyID()
    return info.teamID
end

function ArenaInfo.getArenaPoint()
    return info.point
end

function ArenaInfo.getChallengeTimes()
    local usetimes = tonumber(CharInfo.get().todayarenafighttimes) or 0
    local buytimes = tonumber(CharInfo.get().todayarenafightrefreshtimes) or 0
    local refresht = tonumber(CharInfo.get().arenaupdatetime) or 0
    local refreshtTime = SystemInfo.getGlobalConfigAddInfoByID(6900).values[1]
    local dayDiff = CocosModuleMgr.getDayTimeDiff(refresht, CharInfo.getServerTime(), refreshtTime)
    if dayDiff~=0 then
    	usetimes = 0
    	buytimes = 0
    end
    challengeTimes = SystemInfo.getGlobalConfigAddInfoByID(7004).values[1]-usetimes--+buytimes
    return challengeTimes
end

function ArenaInfo.getMChallengeTimes()
    local usetimes = tonumber(CharInfo.get().todaymarenafighttimes) or 0
    local buytimes = tonumber(CharInfo.get().todaymarenafightrefreshtimes) or 0
    local refresht = tonumber(CharInfo.get().marenaupdatetime) or 0
    local refreshtTime = SystemInfo.getGlobalConfigAddInfoByID(6900).values[1]
    local dayDiff = CocosModuleMgr.getDayTimeDiff(refresht, CharInfo.getServerTime(), refreshtTime)
    if dayDiff~=0 then
        usetimes = 0
        buytimes = 0
    end
    challengeTimes = SystemInfo.getGlobalConfigAddInfoByID(7004).values[1]-usetimes--+buytimes
    return challengeTimes
end

function ArenaInfo.getColdDownTime()
    colddownTime = tonumber(CharInfo.get().todayarenafightcdendtime)
    if not colddownTime then
    	colddownTime = 0
    end
    return colddownTime
end

function ArenaInfo.getMColdDownTime()
    colddownTime = tonumber(CharInfo.get().todaymarenafightcdendtime)
    if not colddownTime then
        colddownTime = 0
    end
    return colddownTime
end

function ArenaInfo.setEnemys(vec)
    enemyInfo = {}
    local cjson = require("cjson")
    for var=1, #vec do
        print("GC_RandomArenaEnemys_Ack", vec[var])
        local tbl = cjson.decode(vec[var])
        enemyInfo[var] = tbl
        --_id, petObjIDs, teamID, gender, rank, zoneID, level, fightPoint, name
    end
end

function ArenaInfo.getEnemys()
    return enemyInfo
end

function ArenaInfo.setBattleInfo(val)
	battleInfo = val
end

function ArenaInfo.getBattleInfo()
    return battleInfo
end

function ArenaInfo.setRefreshRankTime()
    refreshRankTime = CharInfo.getServerTime()+ArenaInfo.REQUEST_TIMEDIFF
end

function ArenaInfo.checkRefreshRankTime()
    if CharInfo.getServerTime()>refreshRankTime then
		return true
	end
	return false
end

function ArenaInfo.clearWorldRankList()
	rankList = {}
end

function ArenaInfo.setWorldRankList(vec)
    local cjson = require("cjson")
    for k,v in pairs(vec) do
        local tbl = cjson.decode(v)
        rankList[tbl.rank] = tbl
        --_id, fightPoint, gender, level, name, petObjIDs, rank, rankLog, teamID, zoneID
    end
end

function ArenaInfo.getWorldRankList()
    return rankList
end

function ArenaInfo.getWorldRankListInfo(rankID)
    return rankList[rankID]
end

function ArenaInfo.setRankListPets(charID, vec)
    local cjson = require("cjson")
    rankListPets[charID] = {}
    for var=1, #vec do
        local tbl = cjson.decode(vec[var])
        rankListPets[charID][var] = tbl
    end
end

function ArenaInfo.setRankListHelperPets(charID, vec)
    local cjson = require("cjson")
    rankListHelperPets[charID] = {}
    for var=1, #vec do
        local tbl = cjson.decode(vec[var])
        rankListHelperPets[charID][var] = tbl
    end
end

function ArenaInfo.getRankListPets(charID)
    return rankListPets[charID]
end

function ArenaInfo.getRankListHelperPets(charID)
    return rankListHelperPets[charID]
end

function ArenaInfo.getArenaAwardInfo(id)
    return ArenaAwardInfoConfig.readEntryByID(id)
end

function ArenaInfo.getArenaAwardInfoCount()
    return ArenaAwardInfoConfig.getEntryCount()
end

function ArenaInfo.getArenaAwardAllChildren()
    local vec = {}
    for var=1, ArenaAwardInfoConfig.getEntryCount() do
        local id = ArenaAwardInfoConfig.getEntryID(var)
        local data = ArenaInfo.getArenaAwardInfo(id)
        table.insert(vec, data)
    end
    return vec
end

function ArenaInfo.getPVPArenaPoint()
    return CharInfo.get().pvparenapoint
end

function ArenaInfo.getPVPArenaLevel()
    if CharInfo.get().pvparenagrade==0 then
    	return 1
    end
    return CharInfo.get().pvparenagrade
    --[[
    local PVPArenaPoint = ArenaInfo.getPVPArenaPoint()
    local level = 1
    for var=1, PVPArenaGradeInfoConfig.getEntryCount() do
        level = PVPArenaGradeInfoConfig.getEntryID(var)
        local data = ArenaInfo.getPVPArenaGradeInfoById(level)
        if data.startPoint<=PVPArenaPoint and data.topPoint>=PVPArenaPoint then
            return level
        end
    end
    return level
    ]]
end

--[[
data.id=Proto.parseDWORD(entry); -- 编号
data.gradeName=Proto.parseString(entry); -- 杯名
data.startPoint=Proto.parseDWORD(entry); -- 下分段
data.topPoint=Proto.parseDWORD(entry); -- 上分段
data.watchPet=Proto.parseDWORD(entry); -- 杯显示宠物
data.rewardElement=Proto.parseVector(entry,Proto.parseDWORD); -- 奖励类型
]]
function ArenaInfo.getPVPArenaGradeInfoById(id)
    return PVPArenaGradeInfoConfig.readEntryByID(id)
end

function ArenaInfo.getAllPVPArenaGradeInfo()
    local vec = {}
    for var=1, PVPArenaGradeInfoConfig.getEntryCount() do
        local id = PVPArenaGradeInfoConfig.getEntryID(var)
        local data = ArenaInfo.getPVPArenaGradeInfoById(id)
        table.insert(vec, data)
    end
    return vec
end

function ArenaInfo.getPVPArenaAwards(awardElement)
    local itemVec = {}
    for var=1, math.ceil(#awardElement/2) do
        local eleID = awardElement[var*2-1]
        local eleNum = awardElement[var*2] or 1
        local rInfo = ItemInfo.getAwardElementInfoById(eleID)
        local rType = rInfo.elementType
        local rID = rInfo.elementID
        if rType==3 then
            local iInfo = ItemInfo.getItemInfoById(rID)
            table.insert(itemVec, {rID, eleNum})
        elseif rType~=5 then
            table.insert(itemVec, {ItemInfo.AWARD[rType], eleNum})
        end
    end
    return itemVec
end

function ArenaInfo.checkPVPAwardsTime()
    local boolCheck = false
    if checkPVPAwardsHandler then
        scheduler.unscheduleGlobal(checkPVPAwardsHandler)
        boolCheck = true
    end
    local todaySec = (CharInfo.getServerTime()+CharInfo.getServerTimeZone())%86400
    local delayTime = 22*3600-todaySec
    local function sendMsg()
        NetInterface.send("GC_GetPVPArenaAward_Ack", function()
            local PVPSend = require("src.Net.Send.PVPSend")
            PVPSend.sendCG_GetPVPArenaAward_Req()
        end)
        checkPVPAwardsHandler = nil
    end
    print("ArenaInfo.checkPVPAwardsTime() wait sec:", delayTime)
    if delayTime<=0 then
        if boolCheck then
            sendMsg()
        end
    else
        checkPVPAwardsHandler = scheduler.performWithDelayGlobal(function()
            sendMsg()
        end, delayTime)
    end
end

function ArenaInfo.setPVPArenaRank(rank)
    PVPArenaRank = {}
    for i=1,#rank do
        local info = json.decode(rank[i])
        if info.pvpArenaPoint >= SystemInfo.getGlobalConfigAddInfoByID(62002).values[1] then
            table.insert(PVPArenaRank, info)
        end
    end
end

function ArenaInfo.getPVPArenaRank()
    return PVPArenaRank
end

function ArenaInfo.setMyPVPArenaRank(rank)
    myPVPArenaRank = rank
end

function ArenaInfo.getMyPVPArenaRank()
    return myPVPArenaRank
end

return ArenaInfo