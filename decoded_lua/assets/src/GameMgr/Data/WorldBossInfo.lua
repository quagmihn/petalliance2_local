local WorldBossInfo = {}

local WorldBossInfoConfig = nil
local BossKillAwardInfoConfig = nil
local WorldBossWeekAwardInfo = nil
local BossStartTime = 0
local BossMaxDuration = 0
local BossLevelLimit = 0
local WeekResetTime = 0
local WeekResetDay = 0
local curBossInfo = nil
local enableAttackBoss = true

local scheduler = require("src.framework.scheduler")
local checkBossTimeHandler = nil
local checkBossTimeEndHandler = nil
local worldBossIsOpen = false

local damageFromServer = 0
local damageOwner = 0
local weekChampionData = nil

function WorldBossInfo.Init()
    if WorldBossInfoConfig==nil then
        WorldBossInfoConfig = require("src.DatReader.WorldBossInfoConfig")
        WorldBossInfoConfig.init()
    end
    
    if BossKillAwardInfoConfig==nil then
    	BossKillAwardInfoConfig = require("src.DatReader.BossKillAwardInfoConfig")
    	BossKillAwardInfoConfig.init()
    end
    
    if WorldBossWeekAwardInfo==nil then
    	local WorldBossWeekAwardInfoConfig = require("src.DatReader.WorldBossWeekAwardInfoConfig")
    	WorldBossWeekAwardInfoConfig.init()
    	WorldBossWeekAwardInfo = {}
        for var=1, WorldBossWeekAwardInfoConfig.getEntryCount() do
            local id = WorldBossWeekAwardInfoConfig.getEntryID(var)
            local data = WorldBossWeekAwardInfoConfig.readEntryByID(id)
            table.insert(WorldBossWeekAwardInfo, data)
        end
    end
    
    if checkBossTimeHandler then
        scheduler.unscheduleGlobal(checkBossTimeHandler)
        checkBossTimeHandler = nil
    end
    
    if checkBossTimeEndHandler then
        scheduler.unscheduleGlobal(checkBossTimeEndHandler)
        checkBossTimeEndHandler = nil
    end
    
    curBossInfo = nil
    BossStartTime = SystemInfo.getGlobalConfigAddInfoByID(82).values[1]
    BossMaxDuration = SystemInfo.getGlobalConfigAddInfoByID(83).values[1]
    BossLevelLimit = SystemInfo.getGlobalConfigAddInfoByID(86).values[1]
    WeekResetTime = SystemInfo.getGlobalConfigAddInfoByID(87).values[2]*3600
    WeekResetDay = SystemInfo.getGlobalConfigAddInfoByID(87).values[1]
    worldBossIsOpen = false
    
    enableAttackBoss = true
    
    damageFromServer = 0
    damageOwner = 0
    weekChampionData = nil
end

--[[
data.id=Proto.parseDWORD(entry); -- bossID
data.bossName=Proto.parseString(entry); -- boss名称
data.property=Proto.parseDWORD(entry); -- boss属性
data.model=Proto.parseString(entry); -- BOSS模型
data.mapList=Proto.parseVector(entry,Proto.parseDWORD); -- 所在地图
data.skill=Proto.parseString(entry); -- BOSS技能
data.awardID=Proto.parseDWORD(entry); -- 结算奖励
]]
function WorldBossInfo.getWorldBossInfoByID(bossid)
    return WorldBossInfoConfig.readEntryByID(bossid)
end

--[[
data.id=Proto.parseDWORD(entry); -- ID
data.mailID=Proto.parseDWORD(entry); -- 邮件ID
data.awardList=Proto.parseVector(entry,Proto.parseWorldBossAwardList); -- 奖励列表
]]
function WorldBossInfo.getBossKillAwardInfoByID(id)
    return BossKillAwardInfoConfig.readEntryByID(id)
end

--[[
data.id=Proto.parseDWORD(entry); -- ID
data.damageCondition=Proto.parseDWORD(entry); -- 伤害条件
data.awardList=Proto.parseVector(entry,Proto.parseWeekAwardList); -- 奖励列表
    data.itemID=Proto.parseDWORD(entry); -- 物品ID
    data.count=Proto.parseDWORD(entry); -- 个数
]]
function WorldBossInfo.getWorldBossWeekAwardInfo()
    return WorldBossWeekAwardInfo
end

--[[
data.bossID=Proto.parseDWORD(entry); -- bossID
data.mapID=Proto.parseDWORD(entry); -- 地图ID
data.duration=Proto.parseDWORD(entry); -- 持续时间
data.isLive=Proto.parseDWORD(entry); -- 是否存活0死1活
data.createTime=Proto.parseDWORD(entry); -- 创建时间
]]
function WorldBossInfo.getCurBossInfo()
    --return {bossID=1, mapID=1, duration=3600, createTime=CharInfo.getServerTime(), isLive=1}
    return curBossInfo
end

function WorldBossInfo.getEnterLevel()
    return BossLevelLimit
end

function WorldBossInfo.getMainBossStartTime()
    return WeekResetTime
end

function WorldBossInfo.getMainBossStartDay()
    return WeekResetDay
end

function WorldBossInfo.getBossIconRes(bossID)
    local bInfo = WorldBossInfo.getWorldBossInfoByID(bossID)
    if bInfo then
        local pokeid = bInfo.model or 1
        return string.format("Pet/PetIcon/%d.png", pokeid)
    end
end

function WorldBossInfo.setCurBossInfo(data)
    if data.bossID==0 then
		curBossInfo = nil
	else
	    curBossInfo = data
        if CharInfo.getServerTime()<curBossInfo.createTime+curBossInfo.duration then
            WorldBossInfo.refreshServerTime()
	    end
	end
end

function WorldBossInfo.checkWorldBossTakeAward()
    --take award
    local t1 = CharInfo.getWorldBossTime() or 0
    if t1 > 0 then
        local offsetTime = 24*3600
        local t2 = CharInfo.getServerTime()
        local dayDiff = CocosModuleMgr.getDayTimeDiff(t1,t2,offsetTime)
        if dayDiff ~= 0 then -- 非同一天
            WorldBossInfo.TakeAward()
        else
            if curBossInfo and curBossInfo.isLive == 0 then
                WorldBossInfo.TakeAward()
            end
        end
    end
end

function WorldBossInfo.refreshServerTime()
    local timediff = 5  --延迟时间
    local curInfo = WorldBossInfo.getCurBossInfo()
    
    --开始时间监听
    local boolCheck = false
    if checkBossTimeHandler then
        scheduler.unscheduleGlobal(checkBossTimeHandler)
        boolCheck = true
    end
    local todaySec = (CharInfo.getServerTime()+CharInfo.getServerTimeZone())%86400
    local delayTime = BossStartTime-todaySec
    local function sendMsg()
        NetInterface.sendWithBlock("GC_GETWORLDBOSS_ACK", function()
            local BossSend = require("src.Net.Send.WorldBossSend")
            BossSend.sendCG_GetWorldBoss_Req()
        end, function()
            WorldMapMgr.refreshWorldBoss()
        end)
        checkBossTimeHandler = nil
    end
    print("WorldBossInfo.checkBossTimeHandler() wait sec:", delayTime, BossMaxDuration, boolCheck)
    if delayTime<=0 then
        if boolCheck and math.abs(delayTime)<BossMaxDuration then
            if curInfo then
                if CharInfo.getServerTime()>curInfo.createTime+curInfo.duration then
                    sendMsg()
            	end
            else
                sendMsg()
            end
        end
        delayTime = delayTime+86400
    end
    print("WorldBossInfo.checkBossTimeHandler() wait sec2:", delayTime)
    checkBossTimeHandler = scheduler.performWithDelayGlobal(function()
        sendMsg()
    end, delayTime+timediff)
    
    --结束时间监听
    local function checkEnd()
    	if worldBossIsOpen then
    	    --添加结束公告
    	    print("播放BOSS战结束公告")
            WorldBossInfo.TakeAward()
            TownChatMgr.bossBattleEnd()
            worldBossIsOpen = false
    	end
        WorldMapMgr.refreshWorldBoss()
    end
    if checkBossTimeEndHandler then
        scheduler.unscheduleGlobal(checkBossTimeEndHandler)
        checkBossTimeEndHandler = nil
    end
    if curInfo then
        if CharInfo.getServerTime()<curInfo.createTime+curInfo.duration then
            checkBossTimeEndHandler = scheduler.performWithDelayGlobal(function()
                checkEnd()
            end, curInfo.createTime+curInfo.duration-CharInfo.getServerTime())
            if not worldBossIsOpen then
                worldBossIsOpen = true
            end
    	else
            checkEnd()
    	end
    else
        checkEnd()
    end
    
    --入口面板刷新
    WorldMapMoveMgr.refreshServerTime()
end

function WorldBossInfo.GetWorldBossMapInfo()
    local BossSend = require("src.Net.Send.WorldBossSend")
    
    NetInterface.sendWithBlock("GC_GETWORLDBOSS_ACK", function()
        print("!!!!!!!!!!!!!!!GetWorldBossMapInfo---sendCG_GetWorldBoss_Req")
        BossSend.sendCG_GetWorldBoss_Req()
    end,function()
    end, function(code)
        StandardTipsMgr.show(1,"GetWorldBossMapInfo failed code="..code)
    end)
end

function WorldBossInfo.GetSelfWorldBossData()
    local BossSend = require("src.Net.Send.WorldBossSend")

    damageOwner = 0
    NetInterface.sendWithBlock("GC_GETSELFWORLDBOSSDATA_ACK", function()
        print("!!!!!!!!!!!!!!!GetSelfWorldBossData---sendCG_GetSelfWorldBossData_Req")
        BossSend.sendCG_GetSelfWorldBossData_Req()
    end,function()
    end, function(code)
        StandardTipsMgr.show(1,"GetSelfWorldBossData failed code="..code)
    end)
end

function WorldBossInfo.AttackBoss(petObjID, pos, successCallback, failCallback)
    local BossSend = require("src.Net.Send.WorldBossSend")

    NetInterface.send("GC_ATTACKBOSS_ACK", function()
        print("!!!!!!!!!!!!!!!AttackBoss---sendCG_AttackBoss_Req")
        BossSend.sendCG_AttackBoss_Req({petObjID = petObjID, pos = pos})
    end,function()
        if successCallback then successCallback() end
    end, function(code)
        if failCallback then failCallback() end
        StandardTipsMgr.show(1,"worldboss8")
    end)
end

function WorldBossInfo.TakeAward()
    local BossSend = require("src.Net.Send.WorldBossSend")

    NetInterface.sendWithBlock("GC_TAKEAWARD_ACK", function()
        print("!!!!!!!!!!!!!!!TakeAward---sendCG_TakeAward_Req")
        BossSend.sendCG_TakeAward_Req()
    end,function()
    end, function(code)
        --StandardTipsMgr.show(1,"TakeAward failed code="..code)
    end)
end

function WorldBossInfo.DiamondRecoverPet(callback)
    local BossSend = require("src.Net.Send.WorldBossSend")

    NetInterface.sendWithBlock("GC_DIAMONDRECOVERPET_ACK", function()
        print("!!!!!!!!!!!!!!!DiamondRecoverPet---sendCG_DiamondRecoverPet_Req")
        BossSend.sendCG_DiamondRecoverPet_Req()
    end,function()
        if callback then callback() end
    end, function(code)
        StandardTipsMgr.show(1,"DiamondRecoverPet failed code="..code)
    end)
end

function WorldBossInfo.DiamondRecoverAll(callback)
    local BossSend = require("src.Net.Send.WorldBossSend")

    NetInterface.sendWithBlock("GC_DIAMONDRECOVERALL_ACK", function()
        print("!!!!!!!!!!!!!!!DiamondRecoverAll---sendCG_DiamondRecoverAll_Req")
        BossSend.sendCG_DiamondRecoverAll_Req()
    end,function()
        if callback then callback() end
    end, function(code)
        StandardTipsMgr.show(1,"DiamondRecoverAll failed code="..code)
    end)
end

function WorldBossInfo.NormalRecover()
    local BossSend = require("src.Net.Send.WorldBossSend")

    NetInterface.sendWithBlock("GC_NORMALRECOVER_ACK", function()
        print("!!!!!!!!!!!!!!!NormalRecover---sendCG_NormalRecover_Req")
        BossSend.sendCG_NormalRecover_Req()
    end,function()
    end, function(code)
        StandardTipsMgr.show(1,"NormalRecover failed code="..code)
    end)
end

function WorldBossInfo.BossAttack(damage, successCallback, failCallback)
    if WorldBossInfo.NONE_HURT_MODE then
    	return
    end

    local BossSend = require("src.Net.Send.WorldBossSend")

    NetInterface.send("GC_BOSSATTACK_ACK", function()
        print("!!!!!!!!!!!!!!!BossAttack---sendCG_BossAttack_Req damage=",damage)
        BossSend.sendCG_BossAttack_Req({damage = damage})
    end,function()
        --print("WorldBossInfo.BossAttack success!!!!!!!!!!!!!",damage)
        if successCallback then successCallback() end
        BossMapMgr.setPlayerHpByDamage(CharInfo.getCharID(), damage)
    end, function(code)
        --print("WorldBossInfo.BossAttack failed!!!!!!!!!!!!!",damage)
        if failCallback then failCallback() end
        --StandardTipsMgr.show(1,"BossAttack failed code="..code)
    end)
end

function WorldBossInfo.GetDamageRank()
    local BossSend = require("src.Net.Send.WorldBossSend")

    NetInterface.send("GC_GETDAMAGERANK_ACK", function()
        print("!!!!!!!!!!!!!!!GetDamageRank---sendCG_GetDamageRank_Req")
        BossSend.sendCG_GetDamageRank_Req()
    end,function()
    end, function(code)
        --StandardTipsMgr.show(1,"GetDamageRank failed code="..code)
    end)
end

function WorldBossInfo.checkBossMapStatus()
    if SceneMgr.currentScene == "BossMapScene" then
        DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 1, "worldboss12", function()
            BossTopBarMgr.hideUI()
        end)
    end
end

function WorldBossInfo.setDamageFromServer(damage)
    damageFromServer = damage
end

function WorldBossInfo.getDamageFromServer()
    return damageFromServer
end

function WorldBossInfo.setDamageOwner(damage)
    damageOwner = damage
end

function WorldBossInfo.getDamageOwner()
    return damageOwner
end

function WorldBossInfo.setWeekChampionData(data)
	weekChampionData = data
end

--[[
data.charID=Proto.parseDWORD(entry); -- 玩家姓名
data.nickName=Proto.parseString(entry); -- 昵称
data.familyName=Proto.parseString(entry); -- 家族名称
data.fashions=Proto.parseVector(entry,Proto.parseDWORD); -- 时装信息
data.message=Proto.parseString(entry); -- 留言
]]
function WorldBossInfo.getWeekChampionData()
    if weekChampionData.charID==0 then
    	return nil
    end
    return weekChampionData
end

function WorldBossInfo.checkWeekTimeValid(timeSec)
    local weekDmgTime = timeSec or CharInfo.getServerTime()
    local wSec1 = CocosModuleMgr.getWeekRefreshTime(CharInfo.getServerTime(), WeekResetDay, WeekResetTime)
    local wSec2 = CocosModuleMgr.getWeekRefreshTime(weekDmgTime, WeekResetDay, WeekResetTime)
    return wSec1==wSec2
end

function WorldBossInfo.getWeekDamage()
	local weekDmg = CharInfo.get().weekdamage or 0
    if not WorldBossInfo.checkWeekTimeValid(CharInfo.get().weekdamagetime) then
		return 0
	end
    return weekDmg
end

return WorldBossInfo