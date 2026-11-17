local TerritorialInfo = {}

local TerritorialInfoConfig = nil
local TerritorialRankInfoConfig = nil
local TerritorialAwardInfoConfig = nil

local MyStageID = 0
local MyRankInfo = {}
local MyFamilyTerritorialIDs = {}
local StageBossInfo = {}
local StageBossInfoNoPets = {}
local RankListInfo = {}
local BattleInfo = {}

local ChallengeInfo = {}

function TerritorialInfo.Init()
    if TerritorialInfoConfig==nil then
        TerritorialInfoConfig = require("src.DatReader.TerritorialInfoConfig")
        TerritorialInfoConfig.init()
    end
    
    if TerritorialRankInfoConfig==nil then
        TerritorialRankInfoConfig = require("src.DatReader.TerritorialRankInfoConfig")
        TerritorialRankInfoConfig.init()
    end
    
    if TerritorialAwardInfoConfig==nil then
        TerritorialAwardInfoConfig = require("src.DatReader.TerritorialAwardInfoConfig")
        TerritorialAwardInfoConfig.init()
    end

    MyStageID = 0
    MyRankInfo = {}
    MyFamilyTerritorialIDs = {}
    StageBossInfo = {}
    StageBossInfoNoPets = {}
    RankListInfo = {}
    BattleInfo = {}
    
    ChallengeInfo = {}
end

function TerritorialInfo.setMyStageID(id)
    print("TerritorialInfo.setMyStageID", id)
	MyStageID = id
end

function TerritorialInfo.getMyStageID()
    return MyStageID
end

function TerritorialInfo.setFamilyTerritorialInfo(eIDs)
    print("TerritorialInfo.updateFamilyTerritorialInfo count:", #eIDs)
    MyFamilyTerritorialIDs = {}
    for key, var in pairs(eIDs) do
        print("exploreID:", var)
        MyFamilyTerritorialIDs[var] = true
    end
end

function TerritorialInfo.getFamilyTerritorialInfo()
    return MyFamilyTerritorialIDs
end

function TerritorialInfo.setChallengeInfo(res)
    print("setChallengeInfo...........".. res.Tcount)
    ChallengeInfo = {tcount = res.Tcount, buyCount = res.buyCount, maxCount = res.maxCount}
end

function TerritorialInfo.getChallengeInfo()
    return ChallengeInfo;
end 

function TerritorialInfo.setBattleInfo(res)
    BattleInfo = {id = res.territoryBattleID, self = res.self, selfHelp = res.selfHelp, enemy = res.enemy, enemyHelp = res.enemyHelp}
end

function TerritorialInfo.getBattleInfo()
    return BattleInfo
end

function TerritorialInfo.updateMyRankInfo(jsStr)
    local cjson = require("cjson")
    print("GC_SelfTerritoryInfo_Ack", jsStr)
    local j = cjson.decode(jsStr)
    MyRankInfo = j or {}
    --if j.lTime then
    --	j.lTime = math.floor(j.lTime/3600)
    --end
end

function TerritorialInfo.getMyRankInfo()
    local tmpVec = MyRankInfo
    return tmpVec
end

function TerritorialInfo.updateRankList(jsVec)
    RankListInfo = {}
    local cjson = require("cjson")
    for var=1, #jsVec do
    	local jsStr = jsVec[var]
    	print("GC_TerritoryRankInfo_Ack", jsStr)
        local j = cjson.decode(jsStr)
        -- j.lTime = math.floor(j.lTime/3600)
        table.insert(RankListInfo, j)
        if j._id==CharInfo.getCharID() then
        	MyRankInfo.rank = j.rank or 999
        end
    end
end

---_id, gender, lTime, name, zoneID
function TerritorialInfo.getRankList()
    local tmpVec = RankListInfo
    return RankListInfo
end

---adventureID, charID, gender, name, pets, recordTime, zoneID
function TerritorialInfo.updateStageBossInfo(strVec)
	if not type(strVec)=="table" then
		return
	end
	local cjson = require("cjson")
	for key, var in pairs(strVec) do
		print("updateStageBossInfo", var)
        local j = cjson.decode(var)
        if j and j.adventureID then
            StageBossInfo[j.adventureID] = j
            if j.charID==0 then
                StageBossInfo[j.adventureID] = {adventureID=j.adventureID}
            end
        else
            print("ERROR: j is null, or j.adventureID is null...")
        end
	end
end

---获取领主信息adventureID, charID, gender, name, pets, recordTime, zoneID
--@param stageID int 副本id
--@param callback function 会传领主信息的参数，需要自行判断stageID是否一致
function TerritorialInfo.getStageBossInfo(stageID, callback)
--    if StageBossInfo[stageID] then
--        if callback then
--            callback(StageBossInfo[stageID])
--        end
--        return StageBossInfo[stageID]
--    end
    if TerritorialInfo.NONE_TERR_MODE then
    	return
    end
    NetInterface.send("GC_TerritoryInfo_Ack", function()
        local TerritorialSend = require("src.Net.Send.TerritorialSend")
        TerritorialSend.sendCG_TerritoryInfo_Req({stageID})
    end, function()
        if callback and StageBossInfo[stageID] then
            callback(StageBossInfo[stageID])
        end
    end)
    return StageBossInfo[stageID]
end

---adventureID, charID, gender, name, recordTime, zoneID
function TerritorialInfo.updateStageBossInfo_NOPETS(strVec)
    if not type(strVec)=="table" then
        return
    end
    local cjson = require("cjson")
    for key, var in pairs(strVec) do
        print("updateNoPetStageBossInfo", var)
        local j = cjson.decode(var)
        if j and j.adventureID then
            StageBossInfoNoPets[j.adventureID] = j
            if j.charID==0 then
                StageBossInfoNoPets[j.adventureID] = {adventureID=j.adventureID}
            end
        else
            print("ERROR: j is null, or j.adventureID is null...")
        end
    end
end

---获取领主信息adventureID, charID, gender, name, recordTime, zoneID 不包含宠物数据，通过ntf获取
--@param stageID int 副本id
function TerritorialInfo.getStageBossInfo_NOPETS(stageID)
    if StageBossInfoNoPets[stageID] then
        return StageBossInfoNoPets[stageID] or {}
    end
end

function TerritorialInfo.getAdventureTerritorialInfo(stageID)
    local timeSec = CharInfo.getServerTime()+CharInfo.getServerTimeZone()
    --print("-----TerritorialInfo server time:", CharInfo.getServerTime(), CocosModuleMgr.getTimeStr(CharInfo.getServerTime()))
    local daySec = timeSec%86400
    local data = TerritorialInfoConfig.readEntryByID(stageID)
    local vec = {id=data.id, level=data.territorialList[1].level, lock=data.territorialList[1].lock, awardVec=data.territorialList[1].award,
        star=data.territorialList[1].limit, begintime={}, lasttime={}, period={}, interval={}, timepoints={}}
    local beginsecVec = {}
    for k, v in pairs(data.territorialList) do
        local timeVec = lua_string_split(v.beginTime, "%.")
        local hour = tonumber(timeVec[1]) or 0
        local minute = tonumber(timeVec[2]) or 0
        local beginsec = hour*3600 + minute*60
        local lasttime = v.lastTime
        local begintime = 0
        if daySec>beginsec+lasttime then
            begintime = beginsec+86400-daySec
        elseif daySec>beginsec then
            begintime = 0
            lasttime = beginsec+lasttime-daySec
        else
            begintime = beginsec-daySec
        end
        beginsecVec[k] = beginsec
        table.insert(vec.begintime, begintime) --当前剩余开始时间秒数
        table.insert(vec.lasttime, lasttime)   --当前剩余结束时间秒数
        table.insert(vec.period, v.lastTime)   --持续时间秒数
        table.insert(vec.timepoints, beginsec)  --每日开启时间点
        --print("----", stageID, v.beginTime, timeVec[1], timeVec[2], begintime, lasttime, v.lastTime)
    end
    for k, v in pairs(data.territorialList) do
        local endsec = beginsecVec[k] + v.lastTime
        local needNewDay = false
        local minTime = 86400
        for n, j in pairs(beginsecVec) do
            local tmptime = j - endsec
            if tmptime<0 then
                tmptime = tmptime + 86400
            end
            if minTime>tmptime then
                minTime = tmptime
            end
        end
        table.insert(vec.interval, minTime)    --下次开启的间隔秒数
        --print("====", minTime)
    end
    
    local openIdx = 0
    local minTime = 86400
    for k, v in pairs(vec.begintime) do
        if v==0 then
            openIdx = k
            vec.openIdx = k
            break
        end
        if minTime>v then
            minTime = v
            vec.openIdx = k
        end
    end
    if openIdx==0 then
        vec.boolOpen = false
        vec.countdown = minTime
    else
        vec.boolOpen = true
        vec.countdown = vec.lasttime[openIdx]
    end
    return vec
end

function TerritorialInfo.getAllTerritorialInfo()
    --local timeSec = CharInfo.getServerTime()+CharInfo.getServerTimeZone()
    --local daySec = timeSec%86400
    local vec = {}
    for var=1, TerritorialInfoConfig.getEntryCount() do
        local id = TerritorialInfoConfig.getEntryID(var)
        table.insert(vec, TerritorialInfo.getAdventureTerritorialInfo(id))
        --[[
        local id = TerritorialInfoConfig.getEntryID(var)
        local data = TerritorialInfoConfig.readEntryByID(id)
        table.insert(vec, {id=data.id, level=data.territorialList[1].level, lock=data.territorialList[1].lock,
            star=data.territorialList[1].limit, begintime={}, lasttime={}, period={}, interval={}})
        local beginsecVec = {}
        for k, v in pairs(data.territorialList) do
            local timeVec = lua_string_split(v.beginTime, "%:")
            local hour = tonumber(timeVec[1]) or 0
            local second = tonumber(timeVec[2]) or 0
            local beginsec = hour*3600 + second
            local lasttime = v.lastTime
            local begintime = 0
            if daySec>beginsec+lasttime then
                begintime = beginsec+86400-daySec
            elseif daySec>beginsec then
                begintime = 0
                lasttime = beginsec+lasttime-daySec
            else
                begintime = beginsec-daySec
            end
            beginsecVec[k] = beginsec
            table.insert(vec[var].begintime, begintime) --当前剩余开始时间秒数
            table.insert(vec[var].lasttime, lasttime)   --当前剩余结束时间秒数
            table.insert(vec[var].period, v.lastTime)   --持续时间秒数
            --print("----", begintime, lasttime, v.lastTime)
        end
        for k, v in pairs(data.territorialList) do
            local endsec = beginsecVec[k] + v.lastTime
            local needNewDay = false
            local minTime = 86400
            for n, j in pairs(beginsecVec) do
                local tmptime = j - endsec
                if tmptime<0 then
                	tmptime = tmptime + 86400
                end
                if minTime>tmptime then
                    minTime = tmptime
            	end
            end
            table.insert(vec[var].interval, minTime)    --下次开启的间隔秒数
            --print("====", minTime)
        end
        ]]
        --[[
        print(data.id, data.territorialList[1].level, data.territorialList[1].limit, data.territorialList[1].lock, 
            data.territorialList[1].beginTime,data.territorialList[1].lastTime, #data.territorialList[1].award, 
            data.territorialList[1].rate)]]
    end
    return vec
end

--[[
data.id=Proto.parseDWORD(entry); -- 副本ID
data.territorialList=Proto.parseVector(entry,Proto.parseTerritorialListInfo); -- 信息列表
<<
    data.level=Proto.parseDWORD(entry); -- 玩家等级
    data.lock=Proto.parseDWORD(entry); -- 解锁难度
    data.limit=Proto.parseDWORD(entry); -- 解锁要求
    data.beginTime=Proto.parseString(entry); -- 开启时间
    data.lastTime=Proto.parseDWORD(entry); -- 持续时间(秒)
    data.award=Proto.parseVector(entry,Proto.parseDWORD); -- 奖励ID
    data.rate=Proto.parseDWORD(entry); -- 挂机收益
>>
]]
function TerritorialInfo.getTerritorialInfoByID(id)
    return TerritorialInfoConfig.readEntryByID(id)
end

--[[
data.id=Proto.parseDWORD(entry); -- 副本ID
data.award=Proto.parseVector(entry,Proto.parseDWORD); -- 奖励ID
]]
function TerritorialInfo.getTerritorialRankInfoByID(id)
    return TerritorialRankInfoConfig.readEntryByID(id)
end

function TerritorialInfo.getTerritorialRankInfo()
    local tbl = {}
    for var=1, TerritorialRankInfoConfig.getEntryCount() do
        local id = TerritorialRankInfoConfig.getEntryID(var)
        local data = TerritorialRankInfoConfig.readEntryByID(id)
        tbl[id] = data
    end
    return tbl
end

--[[
data.id=Proto.parseDWORD(entry); -- 副本ID
data.itemID=Proto.parseDWORD(entry); -- 道具ID
data.count=Proto.parseDWORD(entry); -- 数量
]]
function TerritorialInfo.getTerritorialAwardInfoByID(id)
    return TerritorialAwardInfoConfig.readEntryByID(id)
end

return TerritorialInfo