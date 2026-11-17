local ArenaPKViewMgr = {}

local resNameBG = ""
local resNameTop = ""
local resNameA = ""
local resNameB = ""
local resNameAwards = ""
local aniVec = {}
local tag = ""

local openTime = {}

function ArenaPKViewMgr.Init()
    resNameBG = "Pet/Formation/FormationBGNew.csb"
    resNameTop = "Player/ArenaPK/ArenaTopBar.csb"
    resNameA = "Player/ArenaPK/ArenaMain1.csb"
    resNameB = "Player/ArenaPK/ArenaMain2.csb"
    resNameAwards = "Player/ArenaPK/ArenaAwards.csb"
    aniVec = {}
    tag = "ArenaPKViewMgr"
    
    openTime = {}
    local info = SystemInfo.getGlobalConfigAddInfoByID(61001)
    if info then
    	local vec = info.values
        for var=1, math.floor(#vec/2) do
            local t1 = vec[var*2-1]
            local t2 = vec[var*2]
            table.insert(openTime, {open=t1, close=t2})
    	end
    end
end

function ArenaPKViewMgr.show(scene)
    UIStack.push(tag, ArenaPKViewMgr.hide, true)
    scene = scene or SceneMgr.getRunningScene
    aniVec = {}
    local diff = CocosModuleMgr.getScreenSizeDiff()
    local PVPSend = require("src.Net.Send.PVPSend")
    
    local curArenaPoint = ArenaInfo.getPVPArenaPoint()
    local curArenaLevel = ArenaInfo.getPVPArenaLevel()
    local curArenaInfo = ArenaInfo.getPVPArenaGradeInfoById(curArenaLevel)
    local nextArenaInfo = ArenaInfo.getPVPArenaGradeInfoById(curArenaLevel+1)
    
    local function loadCSBA()
        local layerBG = CSResourceMgr.createRes(scene, resNameBG, tag)
        layerBG:zorder(CocosModuleMgr.ZORDER_WINDOW)
        CocosModuleMgr.setRelativePosition(layerBG, 320, 480)
        
    	local layer = CSResourceMgr.createRes(scene, resNameA)
    	CSResourceMgr.setFullScreen(resNameA)
    	layer:zorder(CocosModuleMgr.ZORDER_WINDOW)
        layer:hide()
    	if diff>0 then
    		CocosModuleMgr.setEdgeDistance(layer, nil, nil, 0, nil)
    	end
    	
        --大联盟赛积分信息
        local point = 0
        if nextArenaInfo then
            point = nextArenaInfo.startPoint - curArenaPoint
        end
        local str1 = CocosModuleMgr.createStringWithFormat({"arenapk16", curArenaPoint, point})
        local point2 = CharInfo.getFixPvpArenaPoint()*(1-0.1*curArenaInfo.fixPointParam)
        local str2 = CocosModuleMgr.createStringWithFormat({"arenapk17", point2})
        CSResourceMgr.setLabelColor(resNameA, "info", {r=135,g=209,b=224,a=255})
        CSResourceMgr.setLabelString(resNameA, "info", str1.."\n"..str2, "", {r=26,g=37,b=48,a=255})
        --CSResourceMgr.setLabelMaxWidth(resNameA, "info", 500)
        local sp = CSResourceMgr.getNodeByName(resNameA, "info")
        sp:setPositionX(35)
        sp:setAnchorPoint(0, 1)
    	
        CSResourceMgr.setLabelColor(resNameA, "title", {r=214,g=245,b=251,a=255})
        CSResourceMgr.setLabelString(resNameA, "title", "arenapk1", "", {r=26,g=37,b=48,a=255})
        CSResourceMgr.setLabelString(resNameA, "info1", CocosModuleMgr.createStringWithFormat({"arenapk2", curArenaInfo.gradeName}), "",
            {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 300)
        CSResourceMgr.setLabelString(resNameA, "info2", CocosModuleMgr.createStringWithFormat({"arenapk3", curArenaPoint}), "",
            {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 300)
        CSResourceMgr.setLabelString(resNameA, "medal", curArenaInfo.gradeName, "", CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS, nil, 200)
        CSResourceMgr.setButtonString(resNameA, "awards", "arenapk4", "", {r=0,g=0,b=0,a=255,w=1,s=1})

        CSResourceMgr.setLabelColor(resNameA, "task_txt", {r=254,g=250,b=175,a=255})
        CSResourceMgr.setLabelString(resNameA, "task_txt", "pvptasktips1", "", {r=0,g=0,b=0,a=255})

        CSResourceMgr.setLabelColor(resNameA, "rank_txt", {r=254,g=250,b=175,a=255})
        CSResourceMgr.setLabelString(resNameA, "rank_txt", "LtMenu3", "", {r=0,g=0,b=0,a=255})

        CSResourceMgr.setLabelColor(resNameA, "shop_txt", {r=254,g=250,b=175,a=255})
        CSResourceMgr.setLabelString(resNameA, "shop_txt", "LtMenu4", "", {r=0,g=0,b=0,a=255})

        local listTitleStr = "arenapk5"
        if not nextArenaInfo then
            listTitleStr = "arenapk15"
        end
        CSResourceMgr.setLabelString(resNameA, "listtitle", listTitleStr, "", {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 300)
        
        CSResourceMgr.clickEventBinding(resNameA, "awards", function()
        	ArenaPKViewMgr.showAwardsInfo(scene)
        end)

        CSResourceMgr.clickEventBinding(resNameA, "task", function()
            PVPQuestListMgr.show(SceneMgr.getRunningScene)
        end, "", 3)

        CSResourceMgr.clickEventBinding(resNameA, "rank", function()
            PVPQuestRank.show(SceneMgr.getRunningScene)
        end, "", 3)
        
        CSResourceMgr.clickEventBinding(resNameA, "shop", function()
            PVPQuestShopMgr.show(SceneMgr.getRunningScene)
        end, "", 3)
    end
    
    local function playCSBA()
        local layer = CSResourceMgr.getCsbObj(resNameA)
        layer:show()
        CocosModuleMgr.showUIAnimation(layer, "down", function()
            local pAni = AnimationMgr.createAni(CSResourceMgr.getNodeByName(resNameA, "ani"), 
                PokemonInfo.getPokemonResByID(curArenaInfo.watchPet), 0, 40, tag)
            AnimationMgr.playAni(pAni.res, "idle", true, pAni.tag)
            AnimationMgr.setSkin(pAni.res, 0, pAni.tag)
            pAni:scale(0)
            local scaleFinal = 1
            if curArenaLevel>=6 then
                scaleFinal = 0.8
            end
            local sequence = transition.sequence({
                cc.ScaleTo:create(0.15, 1.3*scaleFinal),
                cc.ScaleTo:create(0.05, 0.9*scaleFinal),
                cc.ScaleTo:create(0.05, 1.1*scaleFinal),
                cc.ScaleTo:create(0.05, 1.0*scaleFinal),
            })
            pAni:runAction(sequence)
            local circle = CSResourceMgr.getNodeByName(resNameA, "circle")
            local size = circle:getContentSize()
            local sAni = AnimationMgr.createAni(circle, "Spine/effects/Ui_zhandoujiesuanguangxiao.png", size.width/2, size.height/2, tag)
            AnimationMgr.playAni(sAni.res, "animation", true, sAni.tag)
            sAni:scale(0.8)
            sAni:zorder(-1)
            table.insert(aniVec, pAni)
            table.insert(aniVec, sAni)
        end)
    end
    
    local function loadCSBB()
    	local layer1 = CSResourceMgr.createRes(scene, resNameTop)
    	CocosModuleMgr.setEdgeDistance(layer1, nil, 0, 0, nil)
    	layer1:zorder(CocosModuleMgr.ZORDER_WINDOW)
    	local layer2 = CSResourceMgr.createRes(scene, resNameB)
    	CSResourceMgr.setFullScreen(resNameB)
    	CocosModuleMgr.setEdgeDistance(layer2, nil, nil, nil, 0)
        layer2:zorder(CocosModuleMgr.ZORDER_WINDOW)
        if diff>0 then
            CocosModuleMgr.setEdgeDistance(layer2, nil, nil, nil, diff/2)
        end
        
        CSResourceMgr.setLabelString(resNameB, "tips", "arenapk7", "", nil, nil, 500)
        CSResourceMgr.setButtonString(resNameB, "enter", "arenapk6", "", {r=0,g=0,b=0,a=255,w=1,s=1})
        CSResourceMgr.setLabelString(resNameB, "str1", "arenapk8", "", {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 500)
        CSResourceMgr.setLabelString(resNameB, "str2", "", "", {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 500)

        CSResourceMgr.clickEventBinding(resNameB, "black", function()
            NetInterface.sendWithBlock("GC_CancelJoinPVPArena_Ack", function()
            	PVPSend.sendCG_CancelJoinPVPArena_Req()
            end, function()
                local block = CSResourceMgr.getNodeByName(resNameB, "block")
                if block then
                    block:hide()
                end
                local strNode = CSResourceMgr.getNodeByName(resNameB, "str2")
                if strNode then
                    transition.stopTarget(strNode)
                end                
            end, function(code)
            	TipsMgr.showError(nil, code)
            end)
        end)
        CSResourceMgr.clickEventBinding(resNameB, "enter", function()
            local isOpen = false
            for var=1, #openTime do
            	local t = openTime[var]
            	local hourStr = CocosModuleMgr.getTimeStr(CharInfo.getServerTime(), 2)
            	local hour = tonumber(hourStr)
            	print("------arena pk time:", t.open, t.close)
            	if hour>=t.open and hour<t.close then
                    isOpen = true
            		break
            	end
            end
            if not isOpen then
                StandardTipsMgr.show(1, "arenapk18")
            	return
            end
            local levelRank = {10, 20, 25, 30, 35, 40, 45, 50, 55}
            local isSending = false
            local function autoJoin()
                NetInterface.sendWithBlock("GC_JoinPVPArena_Ack", function()
                    PVPSend.sendCG_JoinPVPArena_Req(0)
                end, function()
                    local function wait(second)
                        local time = second+1
                        CSResourceMgr.setLabelString(resNameB, "str2", CocosModuleMgr.createStringWithFormat({"arenapk9", second}))
                        if second>=120 then
                            --匹配超时
                            StandardTipsMgr.show(1, "arenapk13")
                            CSResourceMgr.callButtonFunc(resNameB, "black")
                            return
                        else
                            --[[
                            if not isSending then
                                for n=1, #levelRank do
                                    if levelRank[n]==second then
                                        NetInterface.send("GC_JoinPVPArena_Ack", function()
                                            isSending = true
                                            PVPSend.sendCG_JoinPVPArena_Req(n)
                                        end, function()
                                            isSending = false
                                        end, function(code)
                                            isSending = false
                                            if code==508 then
                                                BattlePVPMgr.sendLeaveBattleCommand()
                                            end
                                        end)
                                        break
                                    end
                                end
                            end
                            ]]
                        end
                        CSResourceMgr.getNodeByName(resNameB, "str2"):performWithDelay(function()
                            wait(time)
                        end, 1)
                    end
                    wait(0)
                    CSResourceMgr.getNodeByName(resNameB, "block"):show()
                end, function(code)
                    if code==508 then
                        BattlePVPMgr.sendLeaveBattleCommand()
                    else
                        TipsMgr.showError(nil, code)
                    end
                end)
            end
            autoJoin()
        end)
        CSResourceMgr.clickEventBinding(resNameTop, "close", function()
        	ArenaPKViewMgr.hide()
        end)
        
        CocosModuleMgr.showUIAnimation(layer1, "down")
        CocosModuleMgr.showUIAnimation(layer2, "up")
    end    
    
    local funcTable = {loadCSBA, playCSBA, loadCSBB}
    local itemIDs = {}
    if nextArenaInfo then
        itemIDs = ArenaInfo.getPVPArenaAwards(nextArenaInfo.rewardElement)--ItemInfo.getAwardElementsItem(curArenaInfo.rewardElement)
    end    
    table.insert(funcTable, function()
        local list = CSResourceMgr.getNodeByName(resNameA, "list")
        local widthL = list:getContentSize().width        
        local margin = list:getItemsMargin()
        local itemWidth = CSResourceMgr.getNodeByName(resNameA, "idb"):getContentSize().width
        local widthI = #itemIDs*itemWidth+margin*(#itemIDs-1)
        if widthI>0 and widthI<widthL then
            list:setContentSize(widthI, list:getContentSize().height)
        end
        print(widthI, widthL)
    end)
    for var=1, #itemIDs do
    	table.insert(funcTable, function()
            local parent = ItemInfo.getItemIconById(itemIDs[var][1], itemIDs[var][2])
            local idb = CSResourceMgr.getNodeByName(resNameA, "idb"):clone()
            idb:show()
            parent:addTo(idb)
            parent:pos(idb:getContentSize().width/2, idb:getContentSize().height/2)
            CSResourceMgr.getNodeByName(resNameA, "list"):pushBackCustomItem(idb)
            CSResourceMgr.clickEventBindingByNode(parent, function()
                ItemInfoViewMgr.show({id=itemIDs[var][1], sum=itemIDs[var][2]}, false)
            end, 1)
            parent:scale(0)
            transition.scaleTo(parent, {scale=0.8, time=0.1})
    	end)
    end
    
    UnblockLoader.load(funcTable, tag)
end

function ArenaPKViewMgr.hide()
	if CSResourceMgr.getCsbObj(resNameB) then
		if CSResourceMgr.getNodeByName(resNameB, "block"):isVisible() then
			return
		end
	end
    UnblockLoader.cancel(tag)
    for var=1, #aniVec do
        AnimationMgr.removeGafObjectByTag(aniVec[var].res, aniVec[var].tag)
    end
    CSResourceMgr.removeList(resNameA, "list")
    CSResourceMgr.removeCSObjectByTag(resNameBG, tag)
    CSResourceMgr.removeCSObjectByTag(resNameTop)
    CSResourceMgr.removeCSObjectByTag(resNameA)
    CSResourceMgr.removeCSObjectByTag(resNameB)
    aniVec = {}
    UIStack.pop(tag)
    TaskWatcherManager.saveDaLianMengCloseState()
end

function ArenaPKViewMgr.showAwardsInfo(scene)
    UIStack.push(tag.."A", ArenaPKViewMgr.hideAwardsInfo, false)
	scene = scene or SceneMgr.getRunningScene
	
	local function loadCSB()
		local layer = CSResourceMgr.createRes(scene, resNameAwards)
		CSResourceMgr.setRelativePosition(resNameAwards, 320, 480)
		layer:zorder(CocosModuleMgr.ZORDER_WINDOW)
		
        CSResourceMgr.setLabelString(resNameAwards, "title", "arenapk10", "", {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 250)
        --CSResourceMgr.setLabelString(resNameAwards, "tips", "arenapk11", "", {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 500)

        CSResourceMgr.setLabelString(resNameAwards, "desc", "pvptasktips16", "", {r=0,g=0,b=0,a=255,w=1,s=1})
		
		CSResourceMgr.clickEventBinding(resNameAwards, "close", function()
			ArenaPKViewMgr.hideAwardsInfo()
		end)
        CSResourceMgr.clickEventBinding(resNameAwards, "bg", function()
            ArenaPKViewMgr.hideAwardsInfo()
        end)
		
		CocosModuleMgr.showUIAnimation(CSResourceMgr.getNodeByName(resNameAwards, "db"), "down")
	end
	
    local funcTable = {loadCSB}
    local aInfo = ArenaInfo.getAllPVPArenaGradeInfo()
    local panelVec = {}
    for var=2, #aInfo do
        local info = aInfo[var]
        table.insert(funcTable, function()
        	local parent = CSResourceMgr.getNodeByName(resNameAwards, "example"):clone()
            CSResourceMgr.getNodeByName(resNameAwards, "list"):pushBackCustomItem(parent)
            local name = CSResourceMgr.seekNodeByName(parent, "name")
            CSResourceMgr.setLabelColorByNode(name, {r=255,g=234,b=0,a=255})
            local infoStr = CocosModuleMgr.createStringWithFormat({"<1>: <2>+", info.gradeName, info.startPoint})
            CSResourceMgr.setLabelStringByNode(name, infoStr, {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 300)
            local tdb = CSResourceMgr.seekNodeByName(parent, "tdb")
            tdb:setColor({r=24,g=44,b=58})
            tdb:zorder(-1)
            panelVec[var] = parent
            parent:setScaleY(0)
            transition.scaleTo(parent, {scale=1, time=0.1})
            parent:show()
        end)
        table.insert(funcTable, function()
            local parent = panelVec[var]
            local itemVec = ArenaInfo.getPVPArenaAwards(info.rewardElement)--ItemInfo.getAwardElementsItem(info.rewardElement)
            local aList = CSResourceMgr.seekNodeByName(parent, "alist")
            aList:setTouchEnabled(true)
            aList:setSwallowTouches(false)
            for n=1, #itemVec do
                local iInfo = itemVec[n]
                local itemBtn = ItemInfo.getItemIconById(iInfo[1], iInfo[2])
                itemBtn:scale(0.75)
                local idb = CSResourceMgr.getNodeByName(resNameAwards, "idb"):clone()
                idb:show()
                itemBtn:addTo(idb)
                itemBtn:pos(idb:getContentSize().width/2, idb:getContentSize().height/2)
                aList:pushBackCustomItem(idb)
                itemBtn:scale(0)
                itemBtn:setSwallowTouches(false)
                transition.scaleTo(itemBtn, {scale=0.75, time=0.1})
                CSResourceMgr.clickEventBindingByNode(itemBtn, function()
                    ItemInfoViewMgr.show({id=iInfo[1], sum=iInfo[2]}, false)
                end, 1)
        	end
        end)
    end
	UnblockLoader.load(funcTable, tag.."A")
end

function ArenaPKViewMgr.hideAwardsInfo()
    UnblockLoader.cancel(tag.."A")
    CSResourceMgr.removeList(resNameAwards, "list")
    CSResourceMgr.removeCSObjectByTag(resNameAwards)
    UIStack.pop(tag.."A")
end

function ArenaPKViewMgr.refreshServerTime()
    --取消每日请求奖励
    --ArenaInfo.checkPVPAwardsTime()
end

return ArenaPKViewMgr