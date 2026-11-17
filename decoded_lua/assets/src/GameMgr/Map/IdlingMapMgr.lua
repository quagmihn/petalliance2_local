local IdlingMapMgr = {}

IdlingMapMgr.RANK_NUM = 6
IdlingMapMgr.PET_NUM = 3
IdlingMapMgr.PETPOS_DIFF = 100

IdlingMapMgr.MAX_LABEL_WIDTH = 440
IdlingMapMgr.LABEL_FONT_SIZE = 20

local resNameA = ""
local resNameB = ""
local resNameC = ""
local mapResPathex = ""

local selInfo = {}
local isMoving = false
local isPaused = false
local petNode = {}
local timeLabel = nil
local mapTbl = {}
local awardsInfo = {}
local panelTable = {}
local eventStrTable = {}

function IdlingMapMgr.Init()
    print("IdlingMapMgr初始化")
    
    resNameA = "Map/IdlingMap/IdlingUIA.csb"
    resNameB = "Map/IdlingMap/IdlingUIB.csb"
    resNameC = "Map/IdlingMap/IdlingUIC.csb"
    mapResPathex = "Map/IdlingMap/"
    
    selInfo = {selType=0, selId=1, selPetInfo={}, endTime=0}
    isMoving = false
    isPaused = false
    petNode = {}
    timeLabel = nil
    mapTbl = {}
    awardsInfo = {}
    panelTable = {}
    eventStrTable = {}
end

function IdlingMapMgr.setPetInfo(params)
    selInfo = params
end

function IdlingMapMgr.createMap(scene)
    isMoving = false
    isPaused = false
    petNode = {}
    mapTbl = {}
    awardsInfo = {}
    panelTable = {}
    eventStrTable = {}
    
    local mapAttr = ExploreInfo.get(selInfo.selId).currentAttr
    local floorID = selInfo.selType+1
    local useSeconds = SystemInfo.getGlobalConfigAddInfoByID(11100).values[floorID]*3600
    for key, var in pairs(ExploreInfo.get(selInfo.selId).events) do
        eventStrTable[key] = var
    end

    local layerB = CSResourceMgr.createRes(scene, resNameB)
    CSResourceMgr.setRelativePosition(resNameB, 320, 480)
    CocosModuleMgr.setEdgeDistance(layerB, nil, nil, 0, nil)
    local layerC = CSResourceMgr.createRes(layerB, resNameC)
    local lbDB = CSResourceMgr.getNodeByName(resNameB, "db")
    local lbPosy = lbDB:getPositionY()
    layerC:setPosition(0, lbPosy-lbDB:getContentSize().height)
    local layerA = CSResourceMgr.createRes(scene, resNameA)
    CSResourceMgr.setRelativePosition(resNameA, 320, 480)
    CocosModuleMgr.setEdgeDistance(layerA, nil, nil, nil, 0)
    
    if ExploreInfo.getExploreInfoDataByID(mapAttr).mapb then
        CSResourceMgr.setSpriteTexture(resNameA, "ma1", mapResPathex..ExploreInfo.getExploreInfoDataByID(mapAttr).mapb)
        CSResourceMgr.setSpriteTexture(resNameA, "mb1", mapResPathex..ExploreInfo.getExploreInfoDataByID(mapAttr).mapb)
    end
    if ExploreInfo.getExploreInfoDataByID(mapAttr).map then
        CSResourceMgr.setSpriteTexture(resNameA, "ma2", mapResPathex..ExploreInfo.getExploreInfoDataByID(mapAttr).map)
        CSResourceMgr.setSpriteTexture(resNameA, "mb2", mapResPathex..ExploreInfo.getExploreInfoDataByID(mapAttr).map)
    end
    if ExploreInfo.getExploreInfoDataByID(mapAttr).mapf then
        CSResourceMgr.setSpriteTexture(resNameA, "ma3", mapResPathex..ExploreInfo.getExploreInfoDataByID(mapAttr).mapf)
        CSResourceMgr.setSpriteTexture(resNameA, "mb3", mapResPathex..ExploreInfo.getExploreInfoDataByID(mapAttr).mapf)
    end
    mapTbl = 
    {
            CSResourceMgr.getNodeByName(resNameA, "ma1"),
            CSResourceMgr.getNodeByName(resNameA, "mb1"),
            CSResourceMgr.getNodeByName(resNameA, "ma2"),
            CSResourceMgr.getNodeByName(resNameA, "mb2"),
            CSResourceMgr.getNodeByName(resNameA, "ma3"),
            CSResourceMgr.getNodeByName(resNameA, "mb3"),
    }
        
    CSResourceMgr.setSpriteTexture(resNameB, "idleattr", "Pet/AttriIcon/"..mapAttr..".png")
    CSResourceMgr.setLabelString(resNameB, "b2title", "idling13", "", {r=0,g=0,b=0,a=255})
    CSResourceMgr.setLabelString(resNameB, "title", ExploreInfo.getExploreInfoDataByID(mapAttr).name, "", {r=153,g=0,b=0,a=255})
    
    CSResourceMgr.clickEventBinding(resNameB, "b2", function()
    	SceneMgr.replaceScene(scene, "MainScene")
    end, "", true)
    CSResourceMgr.clickEventBinding(resNameA, "eb2", function()
        --[[
        if isMoving then
            IdlingMapMgr.stop()
            --探索完
            --CSResourceMgr.setLabelString(resNameB, "title", "idling15", "", {r=153,g=0,b=0,a=255})
        else
            IdlingMapMgr.move()
            --探索中
            --CSResourceMgr.setLabelString(resNameB, "title", "idling12", "", {r=153,g=0,b=0,a=255})
        end
        --]]
        
        NetInterface.sendWithBlock("GC_EndExplore_Ack", function()
        	local ExploreSend = require("src.Net.Send.ExploreSend")
            ExploreSend.sendCG_EndExplore_Req({exploreIndex = selInfo.selId})
        end, function()
        	DialogBoxMgr.showSmallDialogBox(scene, 1, "结算成功", function()
                SceneMgr.replaceScene(scene, "MainScene")
        	end)
        end, function(code)
        	TipsMgr.showError(scene, code)
        end)
    end)
    CSResourceMgr.setButtonEnabled(resNameA, "eb2", false)
    CSResourceMgr.setButtonString(resNameA, "eb2", "idling19", "", {r=153,g=153,b=153,a=255})
    
    --加载宠物
    local petDB = CSResourceMgr.getNodeByName(resNameA, "petdb")
    if #selInfo.selPetInfo==0 then
    	selInfo.isComplete = true
    else
        for var=1, IdlingMapMgr.PET_NUM do
            if selInfo.selPetInfo[var] then
                local petRes = PokemonInfo.getPokemonResByID(selInfo.selPetInfo[var].pokeID)
                petNode[var] = AnimationMgr.createAni(petDB, petRes, -(var-1)*IdlingMapMgr.PETPOS_DIFF, -40, var)
                petNode[var]:setScale(TownMapMgr.DEFAULT_PET_SCALE)
                AnimationMgr.playAni(petRes, "idle", true, var)
            end
        end
    end
    
    --根据屏幕分辨率设置列表高度
    local list = CSResourceMgr.getNodeByName(resNameC, "list")
    local listdb = CSResourceMgr.getNodeByName(resNameC, "db")
    local lsize = list:getInnerContainerSize()
    local lbsize = listdb:getContentSize()
    local hdiff = CocosModuleMgr.getScreenSizeDiff()
    local dbposy = listdb:getPositionY()
    listdb:setContentSize({width=lbsize.width, height=lbsize.height+hdiff})
    list:setContentSize({width=lsize.width, height=lsize.height+hdiff-20})
    
    --倒计时
    IdlingMapMgr.addEvent(nil, selInfo.endTime-useSeconds, "idling23")
    IdlingMapMgr.refreshServerTime(CharInfo.getServerTime())
    
    CocosModuleMgr.addTouchEffect(scene)
    
    if not selInfo.isComplete then
        print("挂机未完成")
        IdlingMapMgr.move()
    end
end

function IdlingMapMgr.move()
    if isMoving then
    	return
    end
    
    for var=1, IdlingMapMgr.PET_NUM do
        if petNode[var] then
            AnimationMgr.playAni(petNode[var].res, "walk", true, var)
        end
    end
    
    local diffRate = 0.6
    local speedTbl = 
        {
            EmbeddedMapMgr.DEFAULT_SPEED*diffRate, 
            EmbeddedMapMgr.DEFAULT_SPEED*diffRate, 
            EmbeddedMapMgr.DEFAULT_SPEED, 
            EmbeddedMapMgr.DEFAULT_SPEED, 
            EmbeddedMapMgr.DEFAULT_SPEED/diffRate, 
            EmbeddedMapMgr.DEFAULT_SPEED/diffRate
        }
    local emyNode = CSResourceMgr.getNodeByName(resNameA, "emydb")
    if isPaused then
        for key, var in pairs(mapTbl) do
            transition.resumeTarget(var)
        end
        transition.resumeTarget(emyNode)
    else
        for key, var in pairs(mapTbl) do
            if var then
                local size = var:getContentSize()
                local time = size.width/speedTbl[key]
                local posx = var:getPositionX()
                local sequence = transition.sequence({
                    cc.MoveBy:create(time, cc.p(-size.width, 0)),
                    cc.CallFunc:create(function()
                        var:setPositionX(posx)
                    end),
                })
                local action = cc.RepeatForever:create(sequence)
                var:runAction(action)
            end
        end
        local moveDiff = 580
        local time = moveDiff/speedTbl[3]
        local bposx = emyNode:getPositionX()
        local bposy = emyNode:getPositionY()
        local sequence = transition.sequence({
            cc.CallFunc:create(function()
                emyNode:setScale(1)
                emyNode:setPosition(bposx, bposy)
                emyNode:setRotation(0)
                local ani = AnimationMgr.createAni(emyNode, PokemonInfo.getRandomPokemonRes(), 0, -40, "emy"..os.time())
                ani:setScale(-TownMapMgr.DEFAULT_PET_SCALE, TownMapMgr.DEFAULT_PET_SCALE)
                AnimationMgr.playAni(ani.res, "idle", true, ani.tag)
                emyNode:performWithDelay(function()
                    AnimationMgr.removeGafObjectByTag(ani.res, ani.tag)
                end, time*2)
            end),
            cc.MoveBy:create(time, cc.p(-moveDiff, 0)),
            cc.CallFunc:create(function()
                local rand = GetRandom.random(1, 2)
                local scale = 0
                local movePosy = GetRandom.random(220,300)
                if rand==1 then
                	scale = 4
                	movePosy = -GetRandom.random(0,100)
                end
                transition.moveBy(emyNode, {time=time/3, x=moveDiff, y=movePosy})
                transition.scaleTo(emyNode, {time=time/2, scale=scale})
                transition.rotateTo(emyNode, {time=time/5, rotate=180})
            end),
            cc.DelayTime:create(time),
        })
        local action = cc.RepeatForever:create(sequence)
        emyNode:runAction(action)
    end
    isMoving = true
end

function IdlingMapMgr.stop()
    if not isMoving then
        return
    end
    
    for var=1, IdlingMapMgr.PET_NUM do
        if petNode[var] then
            AnimationMgr.playAni(petNode[var].res, "idle", true, var)
        end
    end
    
    for key, var in pairs(mapTbl) do
        transition.pauseTarget(var)
    end
    transition.pauseTarget(CSResourceMgr.getNodeByName(resNameA, "emydb"))
    isPaused = true
    isMoving = false
end

function IdlingMapMgr.addEvent(eventID, time, msg)
    local petID = 1
    if selInfo.selPetInfo[1] then
    	petID = selInfo.selPetInfo[1].pokeID
    end
    local message = ""
    if msg then
        message = CocosModuleMgr.createStringWithFormat({msg, PokemonInfo.getPokemonInfoByID(petID).name})
    elseif eventID then
        message = CocosModuleMgr.createStringWithFormat({
            ExploreInfo.getExploreEventSInfoByID(eventID).describe, PokemonInfo.getPokemonInfoByID(petID).name})
    end
    time = CocosModuleMgr.getTimeStr(time, 1)
    
    local list = CSResourceMgr.getNodeByName(resNameA, "list")

    local timeLable = CSResourceMgr.getNodeByName(resNameA, "message"):clone()
    timeLable:setString(time)
    timeLable:setTextAreaSize({width = IdlingMapMgr.MAX_LABEL_WIDTH, height = IdlingMapMgr.LABEL_FONT_SIZE})
    timeLable:ignoreContentAdaptWithSize(false)
    timeLable:setTextHorizontalAlignment(2)
    list:insertCustomItem(timeLable, 1)

    local label = CSResourceMgr.getNodeByName(resNameA, "message"):clone()
    local richLabel = CocosModuleMgr.createRichLabel(label, message, IdlingMapMgr.LABEL_FONT_SIZE, 
        "cuyuan_GBK.ttf", IdlingMapMgr.MAX_LABEL_WIDTH)
    label:setString(" ")
    label:setTextAreaSize({width = 0, height = richLabel.realHeight})
    label:ignoreContentAdaptWithSize(false)
    list:insertCustomItem(label, 1)
    
    label:performWithDelay(function()
        list:jumpToTop()
    end, 0.1)
end

function IdlingMapMgr.addAward(eventID)
    local function addItemFunc(itemID, num)
        itemID = itemID or GetRandom.random(1, 28)
        num = num or GetRandom.random(1, 20)
        for var=1, #awardsInfo do
            if awardsInfo[var].id==itemID then
                awardsInfo[var].sum = awardsInfo[var].sum+num
                CSResourceMgr.setLabelStringByNode(awardsInfo[var].label, awardsInfo[var].sum, CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
                return
            end
        end
        local list = CSResourceMgr.getNodeByName(resNameC, "list")
        local i = #awardsInfo+1
        awardsInfo[i] = {id=itemID, sum=num}
        local row = math.ceil(i/IdlingMapMgr.RANK_NUM)
        local rank = i%IdlingMapMgr.RANK_NUM
        if rank==0 then
            rank = IdlingMapMgr.RANK_NUM
        end
        if rank==1 then
            local panel = CSResourceMgr.getNodeByName(resNameC, "panel"):clone()
            table.insert(panelTable, panel)
            list:pushBackCustomItem(panel)
            list:performWithDelay(function()
                list:jumpToTop()
            end, 0.5)
        end
        local bagItemInfo = awardsInfo[i]
        local parent = panelTable[row]
        local label = CSResourceMgr.seekNodeByName(parent, "l"..rank)
        awardsInfo[i].label = label
        if bagItemInfo[2]==1 then
            CSResourceMgr.setLabelStringByNode(label, "", CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
        else
            CSResourceMgr.setLabelStringByNode(label, bagItemInfo.sum, CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
        end
        local sprite = CSResourceMgr.seekNodeByName(parent, "s"..rank)
        local iconpath = ItemInfo.getItemInfoById(bagItemInfo.id).icon
        CSResourceMgr.setButtonTextureByNode(sprite, iconpath, iconpath, iconpath)
        sprite:setScale(0, 0)
        sprite:setRotation(180)
        transition.scaleTo(sprite, {scale = 1, time = 0.2})
        transition.rotateTo(sprite, {rotate = 360, time = 0.2})
        local diban = CSResourceMgr.seekNodeByName(parent, "b"..rank)
        diban:setScale(0, 0)
        diban:setVisible(true)
        transition.scaleTo(diban, {scale = 1, time = 0.1})
        CSResourceMgr.clickEventBindingByNode(diban, function()
            ItemInfoViewMgr.show({id = bagItemInfo.id, sum = bagItemInfo.sum}, false)
        end)
    end
    
    local tmpFunc = {}
    local function insertFunc(eid)
        local awardsItemVec = ExploreInfo.getExploreEventSInfoByID(eid).rewardElement
        local awardsNumVec = ExploreInfo.getExploreEventSInfoByID(eid).rewardNum
        for var=1, #awardsItemVec do
            table.insert(tmpFunc, function()
                addItemFunc(awardsItemVec[var], awardsNumVec[var])
            end)
        end
    end
    if type(eventID)=="table" then
        for var=1, #eventID do
            insertFunc(eventID[var])
        end
    else
        insertFunc(eventID)
    end
    
    if #tmpFunc>0 then
        UnblockLoader.load(tmpFunc, "IdlingMapMgr.addAward")
    end
end

function IdlingMapMgr.refreshServerTime()
    timeLabel = CSResourceMgr.getNodeByName(resNameA, "timeinfo")
    if timeLabel then
        transition.stopTarget(timeLabel)
        local time = selInfo.endTime-CharInfo.getServerTime()
        if time>0 then
            local h = math.floor(time/3600)
            local m = math.floor((time-h*3600)/60)
            local s = time-h*3600-m*60
            IdlingMapMgr.updateTime(h, m, s)
        else
            IdlingMapMgr.updateTime(0, 0, 0)
            selInfo.isComplete = true
        end
	end
end

function IdlingMapMgr.updateTime(h, m, s)
    local tmpAwardsEvent = {}
    for key, var in pairs(eventStrTable) do
        local localTime = CharInfo.getServerTime()
        local eventTime = var.time
        if localTime>=eventTime then
            IdlingMapMgr.addEvent(var.eID, eventTime)
            table.insert(tmpAwardsEvent, var.eID)
            table.remove(eventStrTable, key)
            eventStrTable[key] = nil
        end
    end
    IdlingMapMgr.addAward(tmpAwardsEvent)
    
    local h_str = string.format("%02d", h)
    local m_str = string.format("%02d", m)
    local s_str = string.format("%02d", s)
    CSResourceMgr.setLabelStringByNode(timeLabel, h_str..":"..m_str..":"..s_str, CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
    timeLabel:performWithDelay(function()
        IdlingMapMgr.updateTime(h, m, s)
    end, 1)
    s=s-1
    if s<0 then
    	s=59
    	m=m-1
    	if m<0 then
    		m=59
    		h=h-1
    		if h<0 then
    			h=0
    			m=0
    			s=0
                transition.stopTarget(timeLabel)
                
                IdlingMapMgr.stop()
                --探索完
                --CSResourceMgr.setLabelString(resNameB, "title", "idling15", "", {r=153,g=0,b=0,a=255})
                IdlingMapMgr.addEvent(nil, selInfo.endTime, "idling24")
                CSResourceMgr.setButtonEnabled(resNameA, "eb2", true)
                CSResourceMgr.setButtonString(resNameA, "eb2", "idling19", "", {r=153,g=0,b=0,a=255})
    		end
    	end
    end
end

return IdlingMapMgr