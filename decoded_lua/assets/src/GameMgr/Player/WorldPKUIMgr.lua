local WorldPKUIMgr = class("WorldPKUIMgr")
local WorldPKDataMgr    = require("src.GameMgr.Player.WorldPKDataMgr")
local resBK         = "Pet/Formation/FormationBGNew.csb"
local selectUIRes   = "Player/WorldArenaPK/selectWorldPK.csb"
local rankUIRes     = "Player/WorldArenaPK/RankWorldPK.csb"
local recordUIRes   = "Player/WorldArenaPK/recordWorldPK.csb"
local scene = nil

function WorldPKUIMgr:setPlayerItem(itemTeam,index,info)
	local copeItem       = self.item:clone()
	local btn = CSResourceMgr.seekNodeByName(copeItem,"btn")
	local score = CSResourceMgr.seekNodeByName(copeItem,"score")
	local Level = CSResourceMgr.seekNodeByName(copeItem,"Level")
	local areaStr = CSResourceMgr.seekNodeByName(copeItem,"areaStr")
	local ItemName = CSResourceMgr.seekNodeByName(copeItem,"ItemName")
	local wenhao   = CSResourceMgr.seekNodeByName(copeItem,"wenhao")
	local fashion  = info.fashion
	local Ani   = PlayerAnimeMgr.createPlayer(nil, {skin=fashion.curFashion},info.name..info.rank)
	-- if device.platform == "ios" then
	-- 	areaStr:setString("CrossServerWar14")
	-- end
	local areaT = self.data.AreaTxt.get(info.world)
	local areaS = ""
	if nil == areaT then
		areaS = self.data.AreaTxt.get(0).area
	else
		areaS = areaT.area
	end
	resetLabelStr(btn,true,nil,{r=53,g=89,b=43,a=255},2)
	resetLabelStr(score,false,nil,{r=48,g=48,b=48,a=255},2,info.rank)
	resetLabelStr(Level,false,{r=255,g=252,b=0,a=255},nil,2,"Lv."..info.level)
	resetLabelStr(areaStr,false,{r=254,g=199,b=26,a=255},nil,2,areaS) 
	resetLabelStr(ItemName,false,nil,{r=0,g=0,b=0,a=255},2,info.name)
	CSResourceMgr.setSpriteTextureByNode(wenhao,"empty.png")
	Ani:addTo(wenhao)
	Ani:setPosition(0,-60)
	copeItem:addTo(itemTeam)
	copeItem:setPosition(163+(index-1)*282,145)
	CSResourceMgr.clickEventBindingByNode(btn, function()

		if self.data.PKtimes <= 0 then
			local willBuyTime = self.data.buyPKTimes+1
			local money = SystemInfo.getGlobalConfigAddInfoByID(64002).values[willBuyTime]
			 
			if nil == money then
				local MaxIndex = #(SystemInfo.getGlobalConfigAddInfoByID(64002).values)
				money = SystemInfo.getGlobalConfigAddInfoByID(64002).values[MaxIndex]
			end
			local str = string.gsub(LuaSqlite.getLanguageByKey("tips63"),"<1>",money)
			DialogBoxMgr.showSmallDialogBox(scene,2,str,function()             
                   	self.data.WorldPKServerMgr:buyPKTimeToBattle(info.rank)
                end,nil,nil,false)
		else
			CSResourceMgr.setButtonEnabledByNode(btn,false)
			self.data:fight(info.rank)
		end
		
	end, 1)
end

function WorldPKUIMgr:refreshPlayerItems(event)

	if event.enemys then
		table.sort(event.enemys, function(a, b)
	        return a.rank < b.rank
	    end)
		self.enemyList:removeAllItems()
		self.firstItemTeam  = self.itemTeam:clone()
		self.secondItemTeam = self.itemTeam:clone()
		for i = 1,#event.enemys do
			if i > 4 then
				break
			end
			if i < 3 then
				self:setPlayerItem(self.firstItemTeam,i,event.enemys[i])
			else
				local index = i - 2
				self:setPlayerItem(self.secondItemTeam,index,event.enemys[i])
			end
			
		end
		self.enemyList:pushBackCustomItem(self.firstItemTeam)
		self.enemyList:pushBackCustomItem(self.secondItemTeam)

	end
end

function WorldPKUIMgr:showSelectUI()
	local layer = nil
	local function loadStatusBar()
		StatusBarMgr.showTopInfoBar(function ()
	        self:hide()
	        StatusBarMgr.hideTopInfoBar()
	    end)
	end
	local function loadDB()
		local layerDB = CSResourceMgr.createRes(scene,resBK)
		CocosModuleMgr.setRelativePosition(layerDB,320,480)
		layerDB:zorder(CocosModuleMgr.ZORDER_CHAT)
	end

	local function setTeam()
		local petArmy = PokemonInfo.getPetArmy(1)
    	local petHelpVec = PokemonInfo.getPetHelpArmy()
    	for key,var in pairs(petArmy) do
    		if key > 3 then break end
    		local info    = PokemonInfo.getPetInfoByObjID(var)
    		local petCard = PetListMgr.createPetNode(info, key)
    		petCard.node:addTo(layer)
    		petCard.node:setPosition(self.petDK[key]:getPositionX()-50,self.petDK[key]:getPositionY()-57)
    	end
    	local helpIndex = 4 
    	-- print("petHelpVec",sz_T2S(petHelpVec))
		for key,var in pairs(petHelpVec) do
			if helpIndex > 6 then break end
			local info    = PokemonInfo.getPetInfoByObjID(var)
    		local petCard = PetListMgr.createPetNode(info, helpIndex)
    		petCard.node:addTo(layer)
    		petCard.node:setPosition(self.petDK[helpIndex]:getPositionX()-50,self.petDK[helpIndex]:getPositionY()-57)
			helpIndex = helpIndex + 1
		end
	end

	local function loadCSB()
		layer = CSResourceMgr.createRes(scene,selectUIRes)
		CocosModuleMgr.setRelativePosition(layer,320,480)
		CocosModuleMgr.setEdgeDistance(layer, nil, nil, 5, nil, false)
		layer:zorder(CocosModuleMgr.ZORDER_CHAT) 
		local diff 		   = CocosModuleMgr.getScreenSizeDiff()
		local title     = CSResourceMgr.getNodeByName(selectUIRes,"title")
		self.restTime   = CSResourceMgr.getNodeByName(selectUIRes,"restTime")
		local teamTitle = CSResourceMgr.getNodeByName(selectUIRes,"teamTitle")
		local limit     = CSResourceMgr.getNodeByName(selectUIRes,"Text_37")
		local rule      = CSResourceMgr.getNodeByName(selectUIRes,"rule")
		local rank      = CSResourceMgr.getNodeByName(selectUIRes,"rank")
		local record    = CSResourceMgr.getNodeByName(selectUIRes,"record")
		local change    = CSResourceMgr.getNodeByName(selectUIRes,"change")
		local outpetStr    = CSResourceMgr.getNodeByName(selectUIRes,"outpetStr")
		local assistpetStr = CSResourceMgr.getNodeByName(selectUIRes,"assistpetStr")
		local downEdge     = CSResourceMgr.getNodeByName(selectUIRes,"downEdge")
		local change       = CSResourceMgr.getNodeByName(selectUIRes,"change")
		local select_dk    = CSResourceMgr.getNodeByName(selectUIRes,"select_dk")
		local myRankStr    = CSResourceMgr.getNodeByName(selectUIRes,"myRankStr")
		self.petDK = {}
		self.itemTeam     = CSResourceMgr.getNodeByName(selectUIRes,"itemTeam")
		self.item         = CSResourceMgr.getNodeByName(selectUIRes,"item")
		self.enemyList    = CSResourceMgr.getNodeByName(selectUIRes,"list")
		for i = 1, 6 do
			self.petDK[i] = CSResourceMgr.getNodeByName(selectUIRes,"petDK_"..i)
		end
		resetLabelStr(title,false,{r=175,g=241,b=255,a=255},{r=31,g=56,b=78,a=255},1)
		resetLabelStr(teamTitle,false,nil,{r=209,g=138,b=0,a=255},1)
		-- resetLabelStr(self.restTime,false,{r=175,g=241,b=255,a=255},{r=31,g=56,b=78,a=255},1)
		resetLabelStr(limit,false,{r=175,g=241,b=255,a=255},nil,nil,nil,self.data.PKtimes.."/"..self.data.PKtimeMax)
		resetLabelStr(rule,true,nil,{r=48,g=48,b=48,a=255},1)
		resetLabelStr(rank,true,nil,{r=48,g=48,b=48,a=255},1)
		resetLabelStr(record,true,nil,{r=48,g=48,b=48,a=255},1)
		resetLabelStr(change,true,nil,{r=48,g=48,b=48,a=255},1)
		resetLabelStr(outpetStr,false,nil,nil,1)
		resetLabelStr(assistpetStr,false,nil,nil,1)
		resetLabelStr(myRankStr,false,nil,nil,1,nil,self.data.data.rank)
		
		self:setRestTime()

		self.enemyList:setContentSize(600,440+diff)
		select_dk:setContentSize(603,840+diff)
		downEdge:setPositionY(146-1*diff)

		CSResourceMgr.clickEventBindingByNode(change, function()
			self.data:randomEnemys()
		end, 1)
		CSResourceMgr.clickEventBindingByNode(rank, function()
			self:setButtonEnabledByNode(false)
			self:showRankUI()
		end, 1)
		CSResourceMgr.clickEventBindingByNode(record, function()
			self:setButtonEnabledByNode(false)
			self:showRecordUI()
		end, 1)

		CSResourceMgr.clickEventBindingByNode(rule, function()
			DialogBoxMgr.showSmallDialogBox(scene,1,"CrossServerWar15",function()             
                    end,nil,nil,true)
		end, 1)

		setTeam()
		self.data:randomEnemys()
	end
	local function Animation()
		CocosModuleMgr.showUIAnimation(layer, "down")
	end

	local funcTable = {loadStatusBar,loadDB,loadCSB,Animation}
	for key,var in pairs(funcTable) do
		var()
	end
end

function WorldPKUIMgr:setRestTime()
	local todayTime   = CharInfo.getServerTime()
    local todayInfo   = os.date("*t",todayTime)
	-- {year=2005, month=11, day=6, hour=22,min=18,sec=30}
    local lastTime    = 0 
    local w = (os.date("%w", CharInfo.getServerTime())==0 and 7) or os.date("%w", CharInfo.getServerTime())
    local todaysTottalSec = todayInfo.hour * 3600 + todayInfo.min * 60 + todayInfo.sec
    local GlobalWeek = SystemInfo.getGlobalConfigAddInfoByID(64001).values[1]
    local GlobalSec  = SystemInfo.getGlobalConfigAddInfoByID(64001).values[2]
    local restWD = GlobalWeek - w

    if restWD > 0 then
        todayInfo.day = todayInfo.day + restWD
    elseif restWD < 0 then
    	todayInfo.day = todayInfo.day + 7 - w + GlobalWeek
    	restWD = 7 - w + GlobalWeek
    elseif restWD == 0 and todaysTottalSec > GlobalSec then
        todayInfo.day = todayInfo.day + 7 - w + GlobalWeek
        restWD = 7 - w + GlobalWeek	
    end

    todayInfo.hour = math.floor(GlobalSec/3600)
    todayInfo.min  = math.floor((GlobalSec - todayInfo.hour*3600)/60)
    todayInfo.sec  = GlobalSec - todayInfo.hour*3600 - todayInfo.min*60
    lastTime   = os.time(todayInfo)

    local restWholeTime = lastTime - todayTime
    local d = math.floor(restWholeTime/86400)
    local h = math.floor((restWholeTime - d*86400)/3600)
    local m = math.floor((restWholeTime - d*86400 - h*3600)/60)
    local s = restWholeTime - d*86400 - h*3600 - m*60

    -- print(sz_T2S(os.date("*t", lastTime)))
    if d > 0 then
    	local str = restWD..LuaSqlite.getLanguageByKey("activity48") 
        resetLabelStr(self.restTime,false,{r=175,g=241,b=255,a=255},
		{r=31,g=56,b=78,a=255},1,nil,str)
    elseif h > 0 then
        local str = h..LuaSqlite.getLanguageByKey("activity49") 
        resetLabelStr(self.restTime,false,{r=175,g=241,b=255,a=255},
		{r=31,g=56,b=78,a=255},1,nil,str)
    elseif m > 0 then
        local str = m..LuaSqlite.getLanguageByKey("activity50")
        resetLabelStr(self.restTime,false,{r=175,g=241,b=255,a=255},
		{r=31,g=56,b=78,a=255},1,nil,str)
    else
        local str = s..LuaSqlite.getLanguageByKey("welfare9")
        resetLabelStr(self.restTime,false,{r=175,g=241,b=255,a=255},
		{r=31,g=56,b=78,a=255},1,nil,str)
    end

end

function WorldPKUIMgr:setButtonEnabledByNode(boolEnable)
	CSResourceMgr.setButtonEnabled(selectUIRes,"rank",boolEnable)
	CSResourceMgr.setButtonEnabled(selectUIRes,"rule",boolEnable)
	CSResourceMgr.setButtonEnabled(selectUIRes,"record",boolEnable)
end

function WorldPKUIMgr:hide()
	self:hideRankUI()
	self:hideRecordUI()
	CSResourceMgr.removeCSObjectByTag(resBK)
	CSResourceMgr.removeCSObjectByTag(selectUIRes)

	
end

function WorldPKUIMgr:hideRankUI()
	self:setButtonEnabledByNode(true)
	CSResourceMgr.removeCSObjectByTag(rankUIRes)
end

function WorldPKUIMgr:ctor(parent)
	scene = parent
	self.data = WorldPKDataMgr.new()
	self.data:addEventListener(WorldPKDataMgr.OPEN,handler(self,self.showSelectUI))
	self.data:addEventListener(WorldPKDataMgr.ENEMYS,handler(self,self.refreshPlayerItems))
	self.data:addEventListener(WorldPKDataMgr.RANK,handler(self,self.finishReqRankPlayers))
	self.data:addEventListener(WorldPKDataMgr.FIGHT,handler(self,self.finishFight))
	self.data:addEventListener(WorldPKDataMgr.RECORDS,handler(self,self.setRecordItem))
	self.showMax      = 10
	self.reqPlayerNum = 10
	self.recordIndex  = 1

	self.PlayerRankNumTex = {
		"UI/CommonFiles/share_calligraphy_1st.png",
	    "UI/CommonFiles/share_calligraphy_2nd.png",
	    "UI/CommonFiles/share_calligraphy_3rd.png"
	}
	
	self.ranktemBG = {
	    "Player/WorldArenaPK/kf_paiming1.png",
	    "Player/WorldArenaPK/kf_paiming2.png",
	    "Player/WorldArenaPK/kf_paiming3.png",
	    "Player/WorldArenaPK/kf_paiming4.png"
	}
	self.rankItemLvColor = {
		{r=206,g=159,b=71 ,a=255},
		{r=82 ,g=167,b=191,a=255},
		{r=195,g=144,b=89 ,a=255},
		{r=120,g=146,b=154,a=255}
	}
	self.areaStrColor = {
		{r=161,g=84,b=1 ,a=255},
		{r=14,g=114,b=143 ,a=255},
		{r=161,g=84,b=1 ,a=255},
		{r=101,g=116,b=121 ,a=255}
	}
	self.resultIconPath = {"UI/CommonFiles/buff2.png","UI/CommonFiles/buff1.png"}
	self.flagPath  = {"UI/CommonFiles/frame_playback_label_red_su.png",
		"UI/CommonFiles/frame_playback_label_green_su.png"}
end

function WorldPKUIMgr:finishFight(event)
end

function WorldPKUIMgr:getAwardItemID(id)
	local element = ItemInfo.getAwardElementInfoById(id)
	if element.elementType ==3 then
		return element.elementID
	else
		return ItemInfo.AWARD[element.elementType]
	end
end

function WorldPKUIMgr:setRankItem(var,id) 
	local item = self.rankItem:clone()
	local itemLevel = CSResourceMgr.seekNodeByName(item, "itemLevel")
	local itemRankSp = CSResourceMgr.seekNodeByName(item, "itemRankSp")
	local itemVipLevel = CSResourceMgr.seekNodeByName(item, "itemVipLevel")
	local itemName     = CSResourceMgr.seekNodeByName(item, "itemName")
	local itemRankStr  = CSResourceMgr.seekNodeByName(item, "itemRankStr")
	local itemReward1  = CSResourceMgr.seekNodeByName(item, "itemReward1")
	local itemReward2  = CSResourceMgr.seekNodeByName(item, "itemReward2")
	local itemRewardNum1 = CSResourceMgr.seekNodeByName(item, "itemRewardNum1")
	local itemRewardNum2 = CSResourceMgr.seekNodeByName(item, "itemRewardNum2")
	local itemRankLabel  = CSResourceMgr.seekNodeByName(item, "itemRankLabel")
	local itemHead       = CSResourceMgr.seekNodeByName(item, "itemHead")
	local areaStr        = CSResourceMgr.seekNodeByName(item, "itemAreaStr")
	local rewardBtn1     = CSResourceMgr.seekNodeByName(item, "itemwardBtn1")
	local rewardBtn2     = CSResourceMgr.seekNodeByName(item, "itemwardBtn2")
	self.rankList:pushBackCustomItem(item)

	-- if device.platform == "ios" then
	-- 	areaStr:setString("CrossServerWar14")
	-- end

	local areaT = self.data.AreaTxt.get(var.world)
	local areaS = ""
	if nil == areaT then
		areaS = self.data.AreaTxt.get(0).area
	else
		areaS = areaT.area
	end

	local myReward = {}

	if id < self.data.rankAwardLastIndex then
		for k,v in pairs(self.data.rewards) do
			if id <= v.rankID then
				myReward = v
				break
			end
		end
	else
		myReward = self.data.rewards[#self.data.rewards]
	end
	

	if myReward[1] then
		local ItemID  = self:getAwardItemID(myReward[1].id)
		local iteminfo = ItemInfo.getItemInfoById(ItemID)
		itemRewardNum1:setString("X"..myReward[1].num)
		CSResourceMgr.setSpriteTextureByNode(itemReward1,iteminfo.icon)
		CSResourceMgr.clickEventBindingByNode(rewardBtn1, function()
				ItemInfoViewMgr.show({id = ItemID,type=1},false)
			end, 1)
	else
		itemRewardNum1:setString("")
		CSResourceMgr.setSpriteTextureByNode(itemReward1,"empty.png")
	end
	if myReward[2] then
		local ItemID  = self:getAwardItemID(myReward[2].id)
		local iteminfo = ItemInfo.getItemInfoById(ItemID)
		itemRewardNum2:setString("X"..myReward[2].num)
		CSResourceMgr.setSpriteTextureByNode(itemReward2,iteminfo.icon)
		CSResourceMgr.clickEventBindingByNode(rewardBtn2, function()
				ItemInfoViewMgr.show({id = ItemID,type=1},false)
			end, 1)
	else
		itemRewardNum2:setString("")
		CSResourceMgr.setSpriteTextureByNode(itemReward2,"empty.png")
	end
	-- {["fashion"] = 
	-- {["curFashion"] = {[1] = 1009,[2] = 2009,[3] = 3003,[4] = 0,[5] = 0,[6] = 15,},},
	-- ["name"] = "斯内克Ze",["_id"] = 111247,["level"] = 100,["vipLevel"] = 13,}
	if id < 4 then
		resetLabelStr(itemLevel,false,self.rankItemLvColor[id],nil,2,"Lv."..var.level)
		CSResourceMgr.setSpriteTextureByNode(item,self.ranktemBG[id])
		CSResourceMgr.setSpriteTextureByNode(itemRankSp,self.PlayerRankNumTex[id])
		resetLabelStr(areaStr,false,self.areaStrColor[id],nil,nil,areaS)
	else
		resetLabelStr(itemLevel,false,self.rankItemLvColor[4],nil,2,"Lv."..var.level)
		itemRankSp:hide()
		resetLabelStr(itemRankLabel,false,{r=166,g=243,b=255,a=255},{r=0,g=0,b=0,a=255},2,id..".")
		CSResourceMgr.setSpriteTextureByNode(item,self.ranktemBG[4])
		resetLabelStr(areaStr,false,self.areaStrColor[4],nil,nil,areaS)
	end

	if var.fashion then 
		CSResourceMgr.setSpriteTextureByNode(itemHead,
			CharInfo.getHeadIcon(var.fashion.curFashion))
        itemHead:setScale(1.2)
        itemHead:setPositionY(itemHead:getPositionY()-10)
    end

	resetLabelStr(itemName,false,nil,{r=0,g=0,b=0,a=255},1,var.name)
	resetLabelStr(itemVipLevel,false,{r=255,g=240,b=0,a=255},{r=0,g=0,b=0,a=255},2,var.vipLevel-1)
	resetLabelStr(itemRankStr,false,nil,{r=0,g=0,b=0,a=255},1,nil,id)
	resetLabelStr(itemRewardNum1,false,nil,{r=0,g=0,b=0,a=255},1)
	resetLabelStr(itemRewardNum2,false,nil,{r=0,g=0,b=0,a=255},1)
	
	return item
end

function WorldPKUIMgr:hideRecordUI()
	self:setButtonEnabledByNode(true)
	CSResourceMgr.removeCSObjectByTag(recordUIRes)
end

function WorldPKUIMgr:setRecordItem()
	local recordPlayer = self.data.recordPlayer.recodes
	local itemDB = self.recordItemDB:clone()
	local item   = self.recordItem:clone()
	local resultStr   = CSResourceMgr.seekNodeByName(item, "resultStr")
	local arenaScore  = CSResourceMgr.seekNodeByName(item, "arenaScore")
	local resultIcon  = CSResourceMgr.seekNodeByName(item, "resultIcon")
	local playerLevel = CSResourceMgr.seekNodeByName(item, "playerLevel")
	local playerName  = CSResourceMgr.seekNodeByName(item, "playerName")
	local rankStr     = CSResourceMgr.seekNodeByName(item, "rankStr")
	local vipLevelStr = CSResourceMgr.seekNodeByName(item, "vipLevelStr")
	local areaStr     = CSResourceMgr.seekNodeByName(item, "areaStr")
	local head        = CSResourceMgr.seekNodeByName(item, "head")
	local flag        = CSResourceMgr.seekNodeByName(item, "flag")
	local score       = recordPlayer.oldRank-recordPlayer.newRank

	-- if device.platform == "ios" then
	-- 	areaStr:setString("CrossServerWar14")
	-- end
	local areaT = self.data.AreaTxt.get(recordPlayer.otherParam.world)
	local areaS = ""
	if nil == areaT then
		areaS = self.data.AreaTxt.get(0).area
	else
		areaS = areaT.area
	end
	itemDB:setColor(self.recordItemDBColors[self.recordIndex%2+1])
	item:addTo(itemDB)
	item:setPosition(300,80)
	self.recordlist:pushBackCustomItem(itemDB)
	resetLabelStr(playerName,false,nil,{r=0,g=0,b=0,a=255},1,recordPlayer.otherParam.name)
	resetLabelStr(playerLevel,false,self.rankItemLvColor[4],nil,nil,"Lv."..recordPlayer.otherParam.level)
	resetLabelStr(rankStr,false,nil,{r=0,g=0,b=0,a=255},1,nil,recordPlayer.oldRank)
	CSResourceMgr.setLabelStringByNode(resultStr, 
		recordPlayer.isWin == 1 and "ArenaRecord2" or "ArenaRecord3", {r=0,g=0,b=0,a=255,w=1,s=1})
	
	resetLabelStr(arenaScore,false,
		recordPlayer.isWin == 1 and {r=255,g=0,b=0,a=255} or {r=0,g=255,b=0,a=255},{r=0,g=0,b=0,a=255},1,
		score)
	resetLabelStr(areaStr,false,self.rankItemLvColor[4],nil,nil,areaS)
	resetLabelStr(vipLevelStr,false,{r=240,g=255,b=0,a=255},{r=0,g=0,b=0,a=255},1,recordPlayer.otherParam.vipLevel-1)
	CSResourceMgr.setSpriteTextureByNode(resultIcon,
			recordPlayer.isWin == 1 and self.resultIconPath[1] or self.resultIconPath[2]) 

	CSResourceMgr.setSpriteTextureByNode(flag,
			recordPlayer.isWin == 1 and self.flagPath[1] or self.flagPath[2]) 
	if recordPlayer.otherParam.fashion then
		CSResourceMgr.setSpriteTextureByNode(head,
			CharInfo.getHeadIcon(recordPlayer.otherParam.fashion.curFashion))
        head:setScale(1.3)
        head:setPositionY(head:getPositionY()-30)
    end
	self.recordIndex = self.recordIndex + 1
	CSResourceMgr.clickEventBindingByNode(item, function()
			self.data:playRecords(recordPlayer.t,recordPlayer.isWin)
		end, 1)
end

function WorldPKUIMgr:showRecordUI()
	StatusBarMgr.hideTopInfoBar()
	local layer = nil
	local function loadCSB()
		layer = CSResourceMgr.createRes(scene,recordUIRes)
		CocosModuleMgr.setRelativePosition(layer,320,480)
		CocosModuleMgr.setEdgeDistance(layer, nil, nil, 5, nil, false)
		layer:zorder(CocosModuleMgr.ZORDER_CHAT)
		local diff 		   = CocosModuleMgr.getScreenSizeDiff()
		local tc_d         = CSResourceMgr.getNodeByName(recordUIRes,"tc_d")
		local recordTitle  = CSResourceMgr.getNodeByName(recordUIRes,"recordTitle")
		local close        = CSResourceMgr.getNodeByName(recordUIRes,"close")
		self.recordlist    = CSResourceMgr.getNodeByName(recordUIRes,"list")
		self.recordItem    = CSResourceMgr.getNodeByName(recordUIRes,"item")
		self.recordItemDB  = CSResourceMgr.getNodeByName(recordUIRes,"itemDB_1")
		self.recordItemDBColors = {
			{r=43,g=65,b=98,a=255},
			{r=3,g=23,b=49,a=255}
		}
		self.recordResultDB = {
			"UI/CommonFiles/frame_playback_label_green_su.png",
			"UI/CommonFiles/frame_playback_label_red_su.png"
		}

		tc_d:setContentSize(653,860+diff)
		self.recordlist:setContentSize(620,780+diff)
		self.recordIndex = 1
		resetLabelStr(recordTitle,false,nil,{r=194,g=86,b=71,a=255},2)

		self.data:openRecords()

		CSResourceMgr.clickEventBindingByNode(close, function()
			self:hideRecordUI()
			StatusBarMgr.showTopInfoBar(function ()
		        self:hide()
		        StatusBarMgr.hideTopInfoBar()
		    end)
		end, 1)

	end

	local function Animation()
		CocosModuleMgr.showUIAnimation(layer, "down")
	end
	loadCSB()
	Animation()
end

function WorldPKUIMgr:showRankUI()
	StatusBarMgr.hideTopInfoBar()
	local layer = nil
	local function loadCSB()
		layer = CSResourceMgr.createRes(scene,rankUIRes)
		CocosModuleMgr.setRelativePosition(layer,320,480)
		CocosModuleMgr.setEdgeDistance(layer, nil, nil, 5, nil, false)
		layer:zorder(CocosModuleMgr.ZORDER_CHAT)
		local diff 		   = CocosModuleMgr.getScreenSizeDiff()
		local db_3         = CSResourceMgr.getNodeByName(rankUIRes,"db_3")
		local close        = CSResourceMgr.getNodeByName(rankUIRes,"close")
		-- local titleStr     = CSResourceMgr.getNodeByName(rankUIRes,"titleStr")
		local rankStr      = CSResourceMgr.getNodeByName(rankUIRes,"rankStr")
		local playerLevel  = CSResourceMgr.getNodeByName(rankUIRes,"playerLevel")
		local nameStr      = CSResourceMgr.getNodeByName(rankUIRes,"nameStr")
		local rankNum      = CSResourceMgr.getNodeByName(rankUIRes,"rankNum")
		local vipLevel     = CSResourceMgr.getNodeByName(rankUIRes,"vipLevel")
		local playerHead   = CSResourceMgr.getNodeByName(rankUIRes,"playerHead")
		local rank         = CSResourceMgr.getNodeByName(rankUIRes,"rank")
		local rewardStr1   = CSResourceMgr.getNodeByName(rankUIRes,"rewardStr1")
		local rewardStr2   = CSResourceMgr.getNodeByName(rankUIRes,"rewardStr2")
		local reward1      = CSResourceMgr.getNodeByName(rankUIRes,"reward1")
		local reward2      = CSResourceMgr.getNodeByName(rankUIRes,"reward2")
		local areaStr      = CSResourceMgr.getNodeByName(rankUIRes,"areaStr")
		local rewardBtn1   = CSResourceMgr.getNodeByName(rankUIRes,"rewardBtn1")
		local rewardBtn2   = CSResourceMgr.getNodeByName(rankUIRes,"rewardBtn2")
		local vipLv = CharInfo.getVipInfoByID(CharInfo.getVIPLevel()).viplevel
		self.rankItem      = CSResourceMgr.getNodeByName(rankUIRes,"item") 
		self.rankList      = CSResourceMgr.getNodeByName(rankUIRes,"list")
		local RankRewardBtn = CSResourceMgr.getNodeByName(rankUIRes,"RankRewardBtn")

		db_3:setContentSize(652,900+diff)
		self.rankList:setContentSize(605,550+diff)
		-- if device.platform == "ios" then
		-- 	areaStr:setString("CrossServerWar14")
		-- end
		local areaT = self.data.AreaTxt.get(CharInfo.getCharWorld())
		local areaS = ""
		if nil == areaT then
			areaS = self.data.AreaTxt.get(0).area
		else
			areaS = areaT.area
		end
		-- resetLabelStr(titleStr,false,{r=175,g=241,b=255,a=255},{r=31,g=56,b=78,a=255},1)
		resetLabelStr(rankStr,false,{r=144,g=238,b=255,a=255},{r=0,g=0,b=0,a=255},2)
		resetLabelStr(rankNum,false,nil,{r=0,g=0,b=0,a=255},2,self.data.data.rank)
		resetLabelStr(playerLevel,false,nil,{r=0,g=0,b=0,a=255},2,"Lv."..CharInfo.getLevel())
		resetLabelStr(nameStr,false,{r=255,g=240,b=0,a=255},{r=0,g=0,b=0,a=255},2,CharInfo.getNickName())
		resetLabelStr(vipLevel,false,{r=255,g=240,b=0,a=255},{r=0,g=0,b=0,a=255},2,vipLv)
		resetLabelStr(rank,false,nil,{r=194,g=86,b=71,a=255},2)
		resetLabelStr(rewardStr1,false,nil,{r=0,g=0,b=0,a=255},2)
		resetLabelStr(rewardStr2,false,nil,{r=0,g=0,b=0,a=255},2)
		resetLabelStr(areaStr,nil,nil,nil,nil,areaS)
		resetLabelStr(RankRewardBtn,true,nil,{r=0,g=0,b=0,a=255},2)
		local myReward = {}

		-- if self.data.data.rank < self.data.rankAwardLastIndex then
		-- 	for key,var in pairs(self.data.rewards) do
		-- 		if self.data.data.rank <= key then
		-- 			myReward = var
		-- 			break
		-- 		end
		-- 	end
		-- else
		-- 	myReward = self.data.rewards[self.data.rankAwardLastIndex]
		-- end

		if self.data.data.rank < self.data.rankAwardLastIndex then
			for k,v in pairs(self.data.rewards) do
				if self.data.data.rank <= v.rankID then
					myReward = v
					break
				end
			end
		else
			myReward = self.data.rewards[#self.data.rewards]
		end
		
		if myReward[1] then
			local ItemID  = self:getAwardItemID(myReward[1].id)
			local iteminfo = ItemInfo.getItemInfoById(ItemID)
			rewardStr1:setString("X"..myReward[1].num)
			CSResourceMgr.setSpriteTextureByNode(reward1,iteminfo.icon)
			CSResourceMgr.clickEventBindingByNode(rewardBtn1, function()
				ItemInfoViewMgr.show({id = ItemID,type=1},false)
			end, 1)
		else
			rewardStr1:setString("")
			CSResourceMgr.setSpriteTextureByNode(reward1,"empty.png")
		end
		if myReward[2] then
			local ItemID  = self:getAwardItemID(myReward[2].id)
			local iteminfo = ItemInfo.getItemInfoById(ItemID)
			rewardStr2:setString("X"..myReward[2].num)
			CSResourceMgr.setSpriteTextureByNode(reward2,iteminfo.icon)
			CSResourceMgr.clickEventBindingByNode(rewardBtn2, function()
				ItemInfoViewMgr.show({id = ItemID,type=1},false)
			end, 1)
		else
			rewardStr2:setString("")
			CSResourceMgr.setSpriteTextureByNode(reward2,"empty.png")
		end

		if CharInfo.getHeadIcon(CharInfo.getCurfashion()) then
			playerHead:setScale(1.5,1.5)
			CSResourceMgr.setSpriteTextureByNode(playerHead, 
				CharInfo.getHeadIcon(CharInfo.getCurfashion()))
		end

		self.rankListObj  = nil
		self.rankCallback = nil

		self.rankListObj = CSResourceMgr.setCommonListInfo(self.data.rankPlayers,rankUIRes,
				"list","",self.showMax,nil,function(id,var)
			local cell = self:setRankItem(var,id)

			return cell
		end,function(callback)
			self.rankCallback = callback
			if self.reqPlayerNum > 10 then
				callback()
				return
			end

			self.data:rank(1,self.reqPlayerNum)
			
		end,function(callback)
			if self.reqPlayerNum > 100 then
				callback()
				return 
			end
			self.rankCallback = callback
			local minNum = self.reqPlayerNum - self.showMax + 1
			local maxNum = self.reqPlayerNum
			self.data:rank(minNum,maxNum)

		end)

		CSResourceMgr.clickEventBindingByNode(close, function()
			self:hideRankUI()
			StatusBarMgr.showTopInfoBar(function ()
		        self:hide()
		        StatusBarMgr.hideTopInfoBar()
		    end)
		end, 1)

		CSResourceMgr.clickEventBindingByNode(RankRewardBtn, function()
			local RewardListView = require("src.GameMgr.Player.RewardListView")
			RewardListView.new(self.data.rewards)
		end, 1)

	end
	local function Animation()
		CocosModuleMgr.showUIAnimation(layer, "down")
	end
	loadCSB()
	Animation()
end

function WorldPKUIMgr:calcPKRestTime()
	
end

function WorldPKUIMgr:finishReqRankPlayers()
	if self.rankListObj then
		self.rankListObj.setContent(self.data.rankPlayers)
	end
	-- if #self.rankData.rankPlayers >= self.reqPlayerNum then
		self.reqPlayerNum = self.reqPlayerNum + self.showMax
	-- end
	self.rankCallback()
end

return WorldPKUIMgr