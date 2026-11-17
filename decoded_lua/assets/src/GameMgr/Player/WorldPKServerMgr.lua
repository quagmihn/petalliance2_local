local WorldPKServerMgr = class("WorldPKServerMgr")
local data = {}
local randomEnemysInfo = {}
local rankPlayers = {}
local reqPlayerIndex = 1
local fightInfo   = {}
local recordPlayer    = {}
local listener   = nil
local recordNum  = -1
local records    = {}
local recordPetsInfo = {}
local recordIsWin  = 0

function WorldPKServerMgr:setRecords(index,recode)
	recordNum = recordNum - 1
    local var = loadstring("return "..recode)()
    records[index+1] = var
    if recordNum == 0 then
    	BattleMapMgr.setRecordToBattle(fightInfo.myself,fightInfo.enemy,
    		records,recordIsWin)
    	BattleMapMgr.setBattleCallback(function()
    			MapSeekerMgr.setSeekFunc(function() 
						local WorldPKUIMgr = require("src.GameMgr.Player.WorldPKUIMgr")
						WorldPKUIMgr.new(SceneMgr.getRunningScene) 
					end)
    		end)
    end
end

function WorldPKServerMgr:addRecordPetInfo(str)
	print("addRecordPetInfo11111111",str)
	local cjson = require("cjson")
    local var = cjson.decode(str)
    for k,v in pairs(var) do
        recordPetsInfo[k] = v
    end
end

function WorldPKServerMgr:addRecordPetInfo2(str)
	print("addRecordPetInfo222222222",str) 
	local cjson = require("cjson")
    local var = cjson.decode(str)
    if nil ~= var then
	    for k,v in pairs(var) do
	        recordPetsInfo[k] = v
	    end
	end
  	print("addRecordPetInfo2~~~",sz_T2S(recordPetsInfo))
    WorldPKServerMgr:setBattlePets(recordPetsInfo)
end

function WorldPKServerMgr:setBattlePets(jsStr)
    local cjson = require("cjson")
    -- local var = cjson.decode(jsStr)
    local var = jsStr
    fightInfo.myself  = {}
	fightInfo.enemy   = {}
	fightInfo.myself[INPETS]  = {}
	fightInfo.myself[OUTPETS] = {}
	fightInfo.enemy[INPETS]   = {}
	fightInfo.enemy[OUTPETS]  = {}
    for k,v in pairs(var.enemyPets) do
        fightInfo.myself[OUTPETS][tonumber(k)+1]=v
    end

    for k,v in pairs(var.enemyHelperPets or {}) do
        fightInfo.myself[INPETS][tonumber(k)+1]=v
    end

    for k,v in pairs(var.selfPets) do
        fightInfo.enemy[OUTPETS][tonumber(k)+1]=v
    end
 
    for k,v in pairs(var.selfHelperPets or {}) do
        fightInfo.enemy[INPETS][tonumber(k)+1]=v
    end

end

function WorldPKServerMgr:setRecordNum(num)
	recordNum = num
end

function WorldPKServerMgr:setData(res)
	data = res
end

function WorldPKServerMgr:setRecordPlayers(res,serverStr)
	if serverStr then
		print(serverStr)
	end
	local cjson = require("cjson")
	local info = {}
	info.isNew = res.isNew
	info.recodes = cjson.decode(res.recodes[1])
	recordPlayer = info 

	-- if #recordPlayers >= 10 then
		listener(recordPlayer)
	-- end
	print(sz_T2S(res))
end

function WorldPKServerMgr:setFightInfo(res)
	fightInfo.myself  = {}
	fightInfo.enemy   = {}
	fightInfo.myself[INPETS]  = {}
	fightInfo.myself[OUTPETS] = {}
	fightInfo.enemy[INPETS]   = {}
	fightInfo.enemy[OUTPETS]  = {}

	local cjson = require("cjson")
	for key,var in pairs(res.self) do
		fightInfo.myself[OUTPETS][key] = cjson.decode(var)
	end

	for key,var in pairs(res.enemys) do
		fightInfo.enemy[OUTPETS][key] = cjson.decode(var)
	end

	for key,var in pairs(res.selfHelper) do
		fightInfo.myself[INPETS][key] = cjson.decode(var)
	end

	for key,var in pairs(res.enemysHelper) do
		fightInfo.enemy[INPETS][key] = cjson.decode(var)
	end
end

function WorldPKServerMgr:setRankPlayers(players)
	local cjson = require("cjson")
	for key,var in pairs(players) do 
	    rankPlayers[reqPlayerIndex] = {}
		rankPlayers[reqPlayerIndex] = cjson.decode(var)
		-- rankPlayers[reqPlayerIndex].rank = reqPlayerIndex
		reqPlayerIndex = reqPlayerIndex + 1
		-- print("reqPlayerIndex ",reqPlayerIndex)
	end
end

function WorldPKServerMgr:setRandomEnemysInfo(res)
	local info = {}
	local cjson = require("cjson")
	for key,var in pairs(res.enemys) do
		info[key] = cjson.decode(var)
	end
 
	randomEnemysInfo   = info
	print("randomEnemysInfo  测试   ",sz_T2S(randomEnemysInfo))
end

function WorldPKServerMgr:ctor()
	self.listener_ = {}
	self.OPEN      = 1
	self.REQENEMYS = 2
	self.RANK      = 3
	self.FIGHT     = 4
	self.OPENCODE  = 5
	self.PLAYCODE  = 6
	self.state     = self.OPEN
	data = {}
	randomEnemysInfo = {}
	rankPlayers = {}
	reqPlayerIndex = 1
end

function WorldPKServerMgr:registerScriptHandler(listener,state)
	-- self.nextListenerIndex = self.nextListenerIndex + 1
	if nil == self.listener_[state] then
		self.listener_[state] = {}
	end
	self.listener_[state] = listener
	if self.state == state and  self.OPEN == self.state then
		self:receiveData()
	end
end

function WorldPKServerMgr:playRecords(battleTime,isWin)
	if nil == self.listener_[self.PLAYCODE] then
		print("没有注册接收服务器接口")
	end
	self.state = self.PLAYCODE
	recordNum  = -1
	records    = {} 
	recordPetsInfo = {}
	recordIsWin    = isWin
	NetInterface.sendWithBlock("GC_PlayWArenaRecode_Ack", function()
	    local WArenaSend = require("src.Net.Send.WArenaSend")
	    WArenaSend.sendCG_PlayWArenaRecode_Req({t = battleTime}) 
	    end, function()
	    		-- BattleMapMgr.setArenaBattle(fightInfo.myself,fightInfo.enemy,function()
	    			-- 	MapSeekerMgr.setSeekFunc(function() 
	    			-- 			local WorldPKUIMgr = require("src.GameMgr.Player.WorldPKUIMgr")
								-- WorldPKUIMgr.new(SceneMgr.getRunningScene) 
	    			-- 		end)
	    			-- end,true) 
	    		
	        end, function(code)
	        TipsMgr.showError(nil, code)
	    end)

end

function WorldPKServerMgr:fight(fightRank)
	if nil == self.listener_[self.RANK] then
		print("没有注册接收服务器接口")
	end
	self.state = self.FIGHT
	NetInterface.sendWithBlock("GC_WArenaRankFight_Ack", function()
	    local WArenaSend = require("src.Net.Send.WArenaSend")
	    WArenaSend.sendCG_WArenaRankFight_Req({rank = fightRank}) 
	    end, function()
	    		BattleMapMgr.setArenaBattle(fightInfo.myself,fightInfo.enemy,function()
	    				MapSeekerMgr.setSeekFunc(function() 
	    						local WorldPKUIMgr = require("src.GameMgr.Player.WorldPKUIMgr")
								WorldPKUIMgr.new(SceneMgr.getRunningScene) 
	    					end)
	    			end,true) 
	    		
	        end, function(code)
	        TipsMgr.showError(nil, code)
	    end)
end

function WorldPKServerMgr:rank(min,max)
	if nil == self.listener_[self.RANK] then
		print("没有注册接收服务器接口")
	end
	self.state = self.RANK
	reqPlayerIndex = min 
	NetInterface.sendWithBlock("GC_QueryWArenaRank_Ack", function()
	    local WArenaSend = require("src.Net.Send.WArenaSend")
	    WArenaSend.sendCG_QueryWArenaRank_Req({rankMin = min,rankMax = max-1}) 
	    end, function()
	    		table.sort(rankPlayers,function(a,b)
	    				return a.rank < b.rank
	    			end)
	    		self.listener_[self.state](rankPlayers)
	        end, function(code)
	        TipsMgr.showError(nil, code)
	    end)
end

function WorldPKServerMgr:getWArenaRecode()
	if nil == self.listener_[self.OPENCODE] then
		print("没有注册接收服务器接口")
	end
	self.state = self.OPENCODE
	listener   = self.listener_[self.state]
	NetInterface.sendWithBlock("GC_GetWArenaRecode_Ack", function() 
	    local WArenaSend = require("src.Net.Send.WArenaSend")
	    WArenaSend.sendCG_GetWArenaRecode_Req({startIndex = 0,endIndex = 10}) 
	    end, function()
	        end, function(code)
	        TipsMgr.showError(nil, code)
	    end)
end

function WorldPKServerMgr:randomEnemys()
	if nil == self.listener_[self.REQENEMYS] then
		print("没有注册接收服务器接口")
	end
	self.state = self.REQENEMYS

	NetInterface.sendWithBlock("GC_RandomWArenaEnemys_Ack", function()
	    local WArenaSend = require("src.Net.Send.WArenaSend")
	    WArenaSend.sendCG_RandomWArenaEnemys_Req({nowRank = data.rank}) 
	    end, function()
	    		self.listener_[self.state](randomEnemysInfo)
	        end, function(code)
	        TipsMgr.showError(nil, code)
	    end)

end

function WorldPKServerMgr:buyPKTimeToBattle(fightRank)
	NetInterface.sendWithBlock("GC_BuyWArenaFightTimes_Ack", function()
	    local WArenaSend = require("src.Net.Send.WArenaSend")
	    WArenaSend.sendCG_BuyWArenaFightTimes_Req() 
	    end, function()
	    		self:fight(fightRank)
	        end, function(code)
	        TipsMgr.showError(nil, code)
	    end)
end

function WorldPKServerMgr:receiveData()
	if nil == self.listener_[self.OPEN] then
		print("没有注册接收服务器接口")
	end

    NetInterface.sendWithBlock("GC_JoinWArena_Ack", function()
	    local WArenaSend = require("src.Net.Send.WArenaSend")
	    WArenaSend.sendCG_JoinWArena_Req() 
	    end, function()
	    		NetInterface.sendWithBlock("GC_GetCharacterValues_Ack", function()
			    local LoginSend = require("src.Net.Send.LoginSend")
			    LoginSend.sendCG_GetCharacterValues_Req({"todayWArenaFightTimes",
			    	"todayWArenaFightRefreshTimes","wArenaUpdateTime"}) 
			    end, function()
			    		self.listener_[self.state](data)
			        end, function(code)
			        TipsMgr.showError(nil, code)
			    end)
	    		
	        end, function(code)
	        TipsMgr.showError(nil, code)
	    end)
end

return WorldPKServerMgr