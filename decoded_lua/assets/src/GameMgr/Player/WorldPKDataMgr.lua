local WorldPKDataMgr = class("WorldPKDataMgr")
local WorldPKServerMgr = require("src.GameMgr.Player.WorldPKServerMgr")
WorldPKDataMgr.OPEN      		= "OPEN"
WorldPKDataMgr.ENEMYS           = "ENEMYS"
WorldPKDataMgr.RANK             = "RANK"
WorldPKDataMgr.FIGHT            = "FIGHT"
WorldPKDataMgr.RECORDS          = "RECORDS"
local WArenaRankAwardConfig     = nil
WorldPKDataMgr.AreaTxt          = nil

function WorldPKDataMgr:ctor()
	self.data   = {}
	self.enemys = {}
	self.rankPlayers  = {}
	self.recordPlayer = {}
	self.rewards      = {}
	self.PKtimeMax,self.PKtimes,self.buyPKTimes  = ArenaMainMgr.getWAreaUseTimes()

	if WArenaRankAwardConfig==nil then
        WArenaRankAwardConfig = require("src.DatReader.WArenaRankAwardConfig")
        WArenaRankAwardConfig.init()
    end
    self.rankAwardLastIndex = 0
    for i = 1,WArenaRankAwardConfig.entryCount do
    	self.rewards[i] = {}
    	local info = WArenaRankAwardConfig.readEntryByID(i)
    	local rewardItem = {}
    	if info.rewardElement[1] then
    		rewardItem[1] = {id = info.rewardElement[1],num = info.rewardElement[2]}
    	end
    	if info.rewardElement[3] then
    		rewardItem[2] = {id = info.rewardElement[3],num = info.rewardElement[4]}
    	end
    	rewardItem.rankIDPre = info.rankRange[1]
    	rewardItem.rankID = info.rankRange[2]
    	self.rewards[i] = rewardItem
    	self.rankAwardLastIndex = info.rankRange[2]
    end

    if nil == WorldPKDataMgr.AreaTxt then
        WorldPKDataMgr.AreaTxt   = TxtReader.new("Config/ServerId.txt")
        WorldPKDataMgr.AreaTxt.init({"id","area"},1,{id=1})
    end

	cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
	self.WorldPKServerMgr = WorldPKServerMgr.new()
	self.WorldPKServerMgr:registerScriptHandler(handler(self,self.openSuccess),
		self.WorldPKServerMgr.OPEN)
	self.WorldPKServerMgr:registerScriptHandler(handler(self,self.randomEnemysSuccess),
		self.WorldPKServerMgr.REQENEMYS)
	self.WorldPKServerMgr:registerScriptHandler(handler(self,self.rankSuccess),
		self.WorldPKServerMgr.RANK)
	self.WorldPKServerMgr:registerScriptHandler(handler(self,self.fightSuccess),
		self.WorldPKServerMgr.FIGHT)
	self.WorldPKServerMgr:registerScriptHandler(handler(self,self.openRecordsSuccess),
		self.WorldPKServerMgr.OPENCODE)
	self.WorldPKServerMgr:registerScriptHandler(handler(self,self.playRecordsSuccess),
		self.WorldPKServerMgr.PLAYCODE)

end 

function WorldPKDataMgr:getWArenaRankAwardByID(id)
	return WArenaRankAwardConfig.readEntryByID(id) 
end

function WorldPKDataMgr:checkIfSameTime()
	local updateTime  = CharInfo.getWArenaUpdateTime()
	local todayTime   = CharInfo.getServerTime()
	if nil == updateTime then
		return false
	end
	local dateUpdateTime = os.date("*t",updateTime)
	local dateTodayTime  = os.date("*t",todayTime)
	if dateUpdateTime.year == dateTodayTime.year
	and dateUpdateTime.day == dateTodayTime.day
	and dateUpdateTime.month == dateTodayTime.month then
		return true
	else
		return false
	end
end

function WorldPKDataMgr:playRecordsSuccess()

end

function WorldPKDataMgr:playRecords(battleTime,isWin)
	self.WorldPKServerMgr:playRecords(battleTime,isWin)
end

function WorldPKDataMgr:openRecordsSuccess(recordPlayer)
	self.recordPlayer = recordPlayer
	print(sz_T2S(self.recordPlayer))

	self:dispatchEvent({name =  WorldPKDataMgr.RECORDS})
end

function WorldPKDataMgr:openRecords()
	self.WorldPKServerMgr:getWArenaRecode()
end

function WorldPKDataMgr:fight(fightRank)
	self.WorldPKServerMgr:fight(fightRank)
end

function WorldPKDataMgr:fightSuccess(fightInfo)
	self:dispatchEvent({name =  WorldPKDataMgr.FIGHT,fightInfo = fightInfo})
end

function WorldPKDataMgr:randomEnemys()
	self.WorldPKServerMgr:randomEnemys()
end

function WorldPKDataMgr:randomEnemysSuccess(enemys)
	self:dispatchEvent({name =  WorldPKDataMgr.ENEMYS,enemys = enemys})
end

function WorldPKDataMgr:rank(min,max)
	self.WorldPKServerMgr:rank(min,max)
end

function WorldPKDataMgr:rankSuccess(rankPlayers)
	self.rankPlayers = rankPlayers
	self:dispatchEvent({name =  WorldPKDataMgr.RANK})
end

function WorldPKDataMgr:openSuccess(data)
	-- print("openSuccess",sz_T2S(data))
	self.data = data
	self:dispatchEvent({name =  WorldPKDataMgr.OPEN})
end

return WorldPKDataMgr