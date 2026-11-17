local RewardListView = class("RewardListView")

function RewardListView:ctor(data)
	self.resName = "Player/Arena/ArenaRewardList.csb"
	self.rewards = data
	local bgNode = {}
    local itemNode = {}
	local function playAction()
	    local panel1 = CSResourceMgr.getNodeByName(self.resName, "panel_1")
	    local panel2 = CSResourceMgr.getNodeByName(self.resName, "panel_2")
	    panel1:setVisible(true)
	    panel2:setVisible(true)
	    CocosModuleMgr.showUIAnimation(panel1, "down")
	    CocosModuleMgr.showUIAnimation(panel2, "down")
	end

	local function turnToTop()
	    CSResourceMgr.getNodeByName(self.resName, "list"):jumpToTop()
	end
	UIStack.push("ArenaRewardList", self.hide, false)
	-- if CSResourceMgr.getCsbObj(self.resName) ~= nil then
	--     self.Layer:setVisible(true)
	--     turnToTop()
	--     playAction()
	--     return
	-- end

	local function loadCSB()
	    self.Layer = CSResourceMgr.createRes(SceneMgr.getRunningScene, self.resName)
	    CSResourceMgr.setFullScreen(self.resName)
	    self.Layer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW + 2)
	    -- self.Layer:setOpacity(0)

	    local panel1 = CSResourceMgr.getNodeByName(self.resName, "panel_1")
	    local panel2 = CSResourceMgr.getNodeByName(self.resName, "panel_2")
	    local list = CSResourceMgr.seekNodeByName(panel1, "list")
	    local bg1  = CSResourceMgr.seekNodeByName(panel1, "bg1")
	    local diff = CocosModuleMgr.getScreenSizeDiff()-- > 0 and CocosModuleMgr.getScreenSizeDiff() or 0
	    ViewMgrUtils.vFitSetPos(diff, {panel1})
	    ViewMgrUtils.vFitSetPos(-diff, {panel2})
	    ViewMgrUtils.vFitStretch(diff, {list, bg1})

	    panel1:setVisible(false)
	    panel2:setVisible(false)

	    -- transition.fadeIn(self.Layer, {time=0.5})
	end

	local function loadUI()
	    local title = CSResourceMgr.getNodeByName(self.resName, "title")
	    local btnClose = CSResourceMgr.getNodeByName(self.resName, "btn_close")
	    local rewardInfo = CSResourceMgr.getNodeByName(self.resName, "reward_info")
	    local btnBG = CSResourceMgr.getNodeByName(self.resName, "btn")

	    CSResourceMgr.setLabelStringByNode(title, "arena52", {r=0,g=0,b=0,a=255,w=1,s=2}, nil, 250)
	    CSResourceMgr.setLabelStringByNode(rewardInfo, "CrossServerWar18", {r=0,g=0,b=0,a=255,w=1,s=2}, nil, 505)
	    CSResourceMgr.setLabelColorByNode(title, {r=255,g=234,b=0,a=255})
	    CSResourceMgr.setLabelColorByNode(rewardInfo, {r=144,g=238,b=255,a=255})

	    CSResourceMgr.clickEventBindingByNode(btnClose, function ()
	        self:hide()
	    end)
	    CSResourceMgr.clickEventBindingByNode(btnBG, function ()
	        self:hide()
	    end)
	end
	
	local function getAwardItemID(id)
		local element = ItemInfo.getAwardElementInfoById(id)
		if element.elementType ==3 then
			return element.elementID
		else
			return ItemInfo.AWARD[element.elementType]
		end
	end
	
	local function loadItems()
	    local list = CSResourceMgr.getNodeByName(self.resName, "list")
	    local parent = CSResourceMgr.getNodeByName(self.resName, "reward")

	    local i = 1
	    for k,v in pairs(self.rewards) do
	        bgNode[i] = parent:clone()

	        local info = v
	        local rankNum = info.rankIDPre
	        local gap     = info.rankID - info.rankIDPre
	        local bg1 = CSResourceMgr.seekNodeByName(bgNode[i], "bg1")
	        local bg2 = CSResourceMgr.seekNodeByName(bgNode[i], "bg2")
	        local title = CSResourceMgr.seekNodeByName(bgNode[i], "reward_title")
	        bg1:setColor({r=24,g=44,b=58,a=255})

	        local strRankNum = CocosModuleMgr.createStringWithFormat({LuaSqlite.getLanguageByKey("arena54"), rankNum})
	        if gap > 0 then
	        	local rankNum2 = info.rankID
	        	strRankNum = strRankNum.."~"..CocosModuleMgr.createStringWithFormat({LuaSqlite.getLanguageByKey("arena54"), rankNum2})
	        end

	        -- if i ~= #ArenaViewMgr.ArenaInfoTable then--不是最后一个
	        --     if rankNum ~= (ArenaViewMgr.ArenaInfoTable[i + 1].id - 1) then--有差值
	        --         local rankNum2 = (ArenaViewMgr.ArenaInfoTable[i + 1].id - 1)
	        --         strRankNum = strRankNum.."~"..CocosModuleMgr.createStringWithFormat({LuaSqlite.getLanguageByKey("arena54"), rankNum2})
	        --     end
	        -- else
	        --     strRankNum = CocosModuleMgr.createStringWithFormat({LuaSqlite.getLanguageByKey("arena55"), rankNum})
	        -- end
	        CSResourceMgr.setLabelStringByNode(title, strRankNum)
	        CSResourceMgr.setLabelColorByNode(title, {r=255,g=234,b=0,a=255,w=1,w=2})

	        local awardInfo = ArenaInfo.getArenaAwardInfo(rankNum)
	        local numCol = {r=255,g=255,b=255,a=255}
	  
	        for var = 1, 2 do
	            local elementID = getAwardItemID(v[var].id)
	            itemNode[var] = ItemInfo.getItemIconById(elementID, v[var].num, numCol)
	            -- if var == 1 then
	            --     elementID = 9998
	            --     itemNode[var] = ItemInfo.getItemIconById(elementID, awardInfo.gcash, numCol)
	            -- elseif var == 2 then
	            --     elementID = awardInfo.awardItems[1]
	            --     itemNode[var] = ItemInfo.getItemIconById(elementID, awardInfo.awardItems[2], numCol)
	            -- elseif var == 3 then
	            --     elementID = 9995
	            --     itemNode[var] = ItemInfo.getItemIconById(elementID, awardInfo.arenaPoint, numCol)
	            -- end
	            local posX = 335 + (var - 2) * 120 + (var-1)*50
	            local posY = 65
	            itemNode[var]:setPosition(posX, posY)
	            itemNode[var]:removeFromParent()
	            itemNode[var]:addTo(bg2)
	            itemNode[var]:setScale(0.7)

	            CSResourceMgr.clickEventBindingByNode(itemNode[var], function ()
	                ItemInfoViewMgr.show({id = elementID}, false)
	            end)
	        end
	        list:pushBackCustomItem(bgNode[i])

	        i = i + 1
	    end
	end

	local funcTable = {loadCSB, loadUI, loadItems, playAction}
	for key,var in pairs(funcTable) do
		var()
	end
	-- UnblockLoader.load(funcTable,"ArenaRewardList")

end

function RewardListView:hide()
	CSResourceMgr.removeCSObjectByTag(self.resName)
    UIStack.pop("ArenaRewardList")
end

return RewardListView