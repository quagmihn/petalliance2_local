local WorldMapMgr = {}

---min width 920 
---min height 1650
WorldMapMgr.DEFAULT_MOVE_SPEED = 90     --移动速度，不要设置太大
WorldMapMgr.PLAYER_SCALE = 0.4

WorldMapMgr.curMapID = 0
WorldMapMgr.curP = 0
WorldMapMgr.isRouteChanged = false
WorldMapMgr.isMoving = false
WorldMapMgr.curAID = 1

local resName = ""
local cloudRes = ""
local shadeRes = ""
local headTagStr = ""
local floatResTable = {}
local starBoardResTable = {}
local roadResTable = {}
local bossTipRes = ""

local mapScale = 1
local mapSize = {}
local routeLineObjs = {}
local routeLineObjs_bak = {}
local checkScroll = nil
local mapMoveInfo = {}
local floatAwards = {}
local refreshFloatAwards = nil

local perW = 0
local perH = 0

local mapMoveFinishFunc = nil
local moveNextP = nil

local charGaf = nil

function WorldMapMgr.Init()
    resName = ""
    cloudRes = "Map/WorldMap/WorldMapCloud.csb"
    shadeRes = "Map/WorldMap/MapShadow.csb"
    headTagStr = PlayerAnimeMgr.WORLDMAP_TAG_STRING
    floatResTable = {"Map/WorldMap/HomeTips.csb", "Map/WorldMap/EventTips.csb", "Map/WorldMap/MissionTips.csb", 
        "Map/WorldMap/ConfraTips.csb"}
    starBoardResTable = {"Map/WorldMap/StarBoard1.csb", "Map/WorldMap/StarBoard2.csb", "Map/WorldMap/StarBoard3.csb"}
    roadResTable = {"Map/WorldMap/point.png", "Map/WorldMap/point_.png", "empty.png"}
    bossTipRes = "Map/WorldMap/BossStartTip.csb"
    
    WorldMapMgr.curMapID = 0
    WorldMapMgr.curP = 0
    WorldMapMgr.isRouteChanged = false
    WorldMapMgr.isMoving = false
    WorldMapMgr.checkEvent = function() end
    
    mapScale = UserSettings.get("Scale",7) or 0.9
    mapSize = {}
    checkScroll = function() end
    mapMoveInfo = {isSending = false}
    floatAwards = {}
    refreshFloatAwards = nil
    perW = 0
    perH = 0
    
    mapMoveFinishFunc = nil
    moveNextP = nil
end

function WorldMapMgr.show(scene)
    WorldPlayerMgr.clear()

    if WorldMapMgr.curMapID==0 or WorldMapMgr.curP==0 then
        WorldMapMgr.curMapID = CharInfo.getLocalSettings("CurrentMapID") or 1
        WorldMapMgr.curP = CharInfo.getLocalSettings("CurrentMapPointID") or 1
    end
    local reqVec = {}
    local boxInfos = AdventureInfo.getMapStarAwarByMapID(WorldMapMgr.curMapID)
    for var=1, #boxInfos do
        table.insert(reqVec, WorldMapAwardsMgr.MAPINFO_STR..boxInfos[var].id)
    end
    floatAwards = {}

    WorldMapMgr.isRouteChanged = false
    WorldMapMgr.isMoving = false
    resName = WorldMapInfo.getWorldMapInfoByID(WorldMapMgr.curMapID).res

	local layer = CSResourceMgr.createRes(scene, resName)
	CSResourceMgr.setRelativePosition(resName, 320, 480)
	CocosModuleMgr.setEdgeDistance(layer, nil, nil, 0, nil)
	layer:setLocalZOrder(CocosModuleMgr.ZORDER_WORLDMAP)
	
    local shadeLayer = CSResourceMgr.createRes(scene, shadeRes)
    CSResourceMgr.setFullScreen(shadeRes)
    shadeLayer:setLocalZOrder(CocosModuleMgr.ZORDER_WORLDMAP)
	
	local cloudlayer = CSResourceMgr.createRes(scene, cloudRes)
    CSResourceMgr.setRelativePosition(cloudRes, 320, 480)
    cloudlayer:setLocalZOrder(CocosModuleMgr.ZORDER_WORLDMAP)
	
	local sizediff = CocosModuleMgr.getScreenSizeDiff()
    local scrollview = CSResourceMgr.getNodeByName(resName, "scrollview")
    local scrollwidth = scrollview:getContentSize().width
    local oringinheight = scrollview:getContentSize().height
    local scrollheight = oringinheight+sizediff-200
    scrollview:setContentSize(scrollwidth, scrollheight)
    mapSize = scrollview:getInnerContainerSize()
    local mapshade = CSResourceMgr.getNodeByName(shadeRes, "ditu_yinying")
    local mapShadeOrgScaleY = mapshade:getScaleY()
    local mapshadeH = mapshade:getContentSize().height*mapShadeOrgScaleY
    local layershadeH = shadeLayer:getContentSize().height
    local mapshadeDiff = sizediff-(mapshadeH-layershadeH)
    if mapshadeDiff>0 then
        mapshade:setScaleY((mapshadeH+mapshadeDiff)/mapshadeH*mapShadeOrgScaleY)
    end
    
    function checkScroll(i, time)
        local node = CSResourceMgr.getNodeByName(resName, "p"..i)
        if node then
            local posx = node:getPositionX()
            local posy = node:getPositionY()
            local diffx = posx*mapScale-scrollwidth/2
            local diffw = mapSize.width*mapScale-scrollwidth
            local ratex = diffx/diffw*100
            if ratex<0 then
                ratex = 0
            elseif ratex>100 then
                ratex = 100
            end
            local diffy = mapSize.height*mapScale-posy*mapScale-scrollheight/2
            local diffh = mapSize.height*mapScale-scrollheight
            local ratey = diffy/diffh*100
            --ratey = ratey + 3/mapScale/mapScale*(oringinheight/scrollheight)        --这个大地图往上偏
            if ratey<0 then
                ratey = 0
            elseif ratey>100 then
                ratey = 100
            end
            WorldMapMgr.scrollMapTo(ratex, ratey, time)
            --print("\ndiffx="..diffx..",diffw="..diffw..",diffy="..diffy..",diffh="..diffh)
        end
    end
    
    ---检查地图点对应的事件
    function WorldMapMgr.checkEvent(boolCheckEventOnly)
        if not CSResourceMgr.getCsbObj(resName) then
            return
        end
        CharInfo.setLocalSettings({CurrentMapID=WorldMapMgr.curMapID, CurrentMapPointID=WorldMapMgr.curP})
        local function checkMapMoveFinishFunc()
            if mapMoveFinishFunc then
                mapMoveFinishFunc()
                mapMoveFinishFunc = nil
                return true
            end
            return false
        end
        if boolCheckEventOnly==nil then
        	boolCheckEventOnly = false
        end
        if not boolCheckEventOnly then
            local pointInfo = WorldMapInfo.getPointInfoByID(WorldMapMgr.curMapID, WorldMapMgr.curP)
            if pointInfo.type==WorldMapInfo.POINT_TYPE_TOWN then
                --城镇入口
                local var = WorldMapInfo.getTownInfoByID(WorldMapMgr.curMapID)[WorldMapMgr.curP]
                SceneMgr.replaceScene(SceneMgr.getRunningScene, var.info)
                return
            elseif pointInfo.type==WorldMapInfo.POINT_TYPE_STAGE then
                --副本入口
                local var = WorldMapInfo.getSearchInfoByID(WorldMapMgr.curMapID)[WorldMapMgr.curP]
                GameAudio.playUISound("raidEnter")
                SearchingUIMgr.addAdvConfirmUI(SceneMgr.getRunningScene, var.info, nil, function()
                    checkMapMoveFinishFunc()
                end)
                return
            elseif pointInfo.type==WorldMapInfo.POINT_TYPE_TRANSFER then
                --传送入口
                local var = WorldMapInfo.getTransferInfoByID(WorldMapMgr.curMapID)[WorldMapMgr.curP]
                if var.info==WorldMapMgr.curMapID then
                    WorldMapMgr.flyToPoint(var.param, false)
                else
                    WorldMapMgr.setMapIDandPos(var.info, var.param)
                    SceneMgr.replaceScene(scene, "MainScene")
                end
                return
            elseif pointInfo.type==WorldMapInfo.POINT_TYPE_TEAM then
                --组队入口
                local var = WorldMapInfo.getTeamMapInfo()[WorldMapMgr.curMapID]
                TeamViewMgr.show(scene, var.aid)
                return
            elseif pointInfo.type==WorldMapInfo.POINT_TYPE_BOSS then
                --boss战入口
                local curInfo = WorldBossInfo.getCurBossInfo()
                if curInfo then
                	if CharInfo.getServerTime()<curInfo.createTime+curInfo.duration then
                        WorldMapMgr.setMapIDandPos(1, 1)
                        BossMapMgr.enterBossMap()
                	else
                        DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 1, "worldboss13")
                	end
                else
                    DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 1, "worldboss13")
                end
                return
            end
        end
        if checkMapMoveFinishFunc()==true then
        	return
        end
        local function addNodeEvent(eid, pid, mtype, skin, index)
            local eidinfo = WorldMapInfo.getEventInfoByID(eid)
            if not eidinfo then
            	return
            end
            local eventType = eidinfo.type
            local eventParam = eidinfo.name
            local eventEmoji = eidinfo.emoji
            print("随机事件 type:"..eventType, "param:", eventParam)
            EmbeddedMapMgr.addEvent({
                type = eventType+1, 
                emoji = eventEmoji,
                param = eventParam,
                mapid = WorldMapMgr.curMapID,
                pid = pid,
                mtype = mtype,
                skin = skin,
                index = index,
            })
        end
        --家族任务
        local familyQuestInfo = AdventureInfo.getFamilyQuestInfo()
        if familyQuestInfo then
            if familyQuestInfo.mapID==WorldMapMgr.curMapID and familyQuestInfo.pID==WorldMapMgr.curP then
                if familyQuestInfo.trainerID then
                    EmbeddedMapMgr.addEvent({
                        type = 1, 
                        emoji = 1,
                        param = familyQuestInfo.trainerID,
                        isFamilyQuest = true,
                    })
                    return
                elseif familyQuestInfo.petID then
                    EmbeddedMapMgr.addEvent({
                        type = 2, 
                        emoji = 1,
                        param = familyQuestInfo.petID,
                        isFamilyQuest = true,
                    })
                    return
                end
            end
        end
        --主线任务
        local questMseID = QuestInfo.checkProcessMapSmallPoint(WorldMapMgr.curMapID, WorldMapMgr.curP)
        if questMseID then
            local eventID = QuestInfo.getNewQuestInfoById(questMseID).objectiveList[1].finalID
            addNodeEvent(eventID, WorldMapMgr.curP, questMseID)
            return
        end
        --随机事件
        local todayEventTable = AdventureInfo.getMapEventInfo(WorldMapMgr.curMapID)
        for key, var in pairs(todayEventTable) do
            if WorldMapMgr.curP==var.pid then
                addNodeEvent(var.eid, var.pid, nil, var.skin, var.index)
                return
        	end
        end
    end
    
    layer:performWithDelay(function()
        checkScroll(WorldMapMgr.curP, 0)
        CSResourceMgr.playAllFrameWithCallback(cloudRes, 1, function()
            CSResourceMgr.removeCSObjectByTag(cloudRes)
        end, "", 1)
    end, 0.01)
    
    local function initMapButton(i)
        local btn = WorldMapMgr.getMapPointNode(i)
        if btn then
            local btnScaleX = btn:getScaleX()
            local btnScaleY = btn:getScaleY()
            if WorldMapInfo.getPointInfoByID(WorldMapMgr.curMapID, i).type==WorldMapInfo.POINT_TYPE_EMPTY then
            elseif WorldMapInfo.getPointInfoByID(WorldMapMgr.curMapID, i).type~=WorldMapInfo.POINT_TYPE_INVISIBLE then
                btn:setAnchorPoint(0.5, 0)
                local posy = btn:getPositionY()
                local posyDiff = btn:getContentSize().height*btnScaleY/2
                btn:setPositionY(posy-posyDiff)
            end
            CSResourceMgr.buttonEventBindingByNode(btn, function()
                print("地图建筑"..i.."被点击")
                if WorldMapInfo.getPointInfoByID(WorldMapMgr.curMapID, i).type==WorldMapInfo.POINT_TYPE_EMPTY then
                    local effAni = AnimationMgr.createAni(btn, "Spine/effects/Ui_dadituzhuazi.png", 
                        btn:getContentSize().width/2, btn:getContentSize().height/2)
                    AnimationMgr.playAniWithCallback(effAni.res, "animation", nil, effAni.tag, true)
                elseif WorldMapInfo.getPointInfoByID(WorldMapMgr.curMapID, i).type~=WorldMapInfo.POINT_TYPE_INVISIBLE then
                    transition.stopTarget(btn)
                    CocosModuleMgr.lightenNode(btn, 0)
                    local sequence = transition.sequence({
                        cc.ScaleTo:create(0.15, btnScaleX*1.05, btnScaleY*0.9),
                        cc.ScaleTo:create(0.1, btnScaleX*0.95, btnScaleY*1.12),
                        cc.ScaleTo:create(0.15, btnScaleX, btnScaleY*0.94),
                        cc.ScaleTo:create(0.1, btnScaleX, btnScaleY),
                    })
                    btn:performWithDelay(function()
                        CocosModuleMgr.lightenNode(btn, 0.5)
                    end, 0.15)
                    btn:performWithDelay(function()
                        CocosModuleMgr.lightenNode(btn, 0)
                    end, 0.25)
                    btn:runAction(sequence)
                end
            end, function()
                WorldMapMoveMgr.showMoveDlg(i)
            end)
            btn:setLocalZOrder(1)
            btn:setSwallowTouches(false)
        end
    end
    local mapPointVec = WorldMapInfo.getPointInfo(WorldMapMgr.curMapID)
    for key, var in pairs(mapPointVec) do
        initMapButton(key)
    end    
    
    WorldMapMoveMgr.createRoute()
    
    local sbRes = starBoardResTable
    local function addSBoard(sbtn, type, id)
        local sboard = CSResourceMgr.createRes(sbtn, sbRes[type], id)
        sboard:setPosition(sbtn:getContentSize().width/2, 0)
        sboard:setAnchorPoint(0.5, 0.5)
        sboard:setScale(1.3)
        CSResourceMgr.setLabelString(sboard.res, "name", WorldMapInfo.getPointNameByID(WorldMapMgr.curMapID, id), 
            sboard.tag, {r=13,g=47,b=60,a=255})
        CSResourceMgr.setLabelColor(sboard.res, "name", {r=234,g=254,b=255,a=255}, sboard.tag)
        return sboard
    end
    for key, var in pairs(WorldMapInfo.getTownInfoByID(WorldMapMgr.curMapID)) do
        local sbtn = WorldMapMgr.getMapPointNode(var.id)
        local sboard = addSBoard(sbtn, 1, var.id)
        CSResourceMgr.getNodeByName(sboard.res, "d1", sboard.tag):setVisible(false)
    end
    for key, var in pairs(WorldMapInfo.getSearchInfoByID(WorldMapMgr.curMapID)) do
        local sbtn = WorldMapMgr.getMapPointNode(var.id)
        local starNum, starMax = AdvStarMgr.getWorldMapStarNum(var.info)
        starNum = starNum or 0
        starMax = starMax or 1
        local sboard = addSBoard(sbtn, starMax, var.id)
        for i=1, starNum do
            CSResourceMgr.getNodeByName(sboard.res, "s"..i, sboard.tag):setVisible(true)
        end
        local advAwPet = AdventureInfo.getAdvAwardByID(var.info)
        if advAwPet then
            local advAwInfo = WorldMapAwardsMgr.getAwardsInfo(advAwPet.petGeneID, 1)
            table.insert(reqVec, WorldMapAwardsMgr.ADVINFO_STR..var.info)
            local tipsNode = WorldMapMgr.addEvent(0, var.id)
            floatAwards[var.info] = tipsNode
            tipsNode:hide()
            
            local home = CSResourceMgr.seekNodeByName(tipsNode, "home")
            local petNode = ItemInfo.getPetIconById(advAwInfo[2], "WorldMap"..var.info)
            CSResourceMgr.setButtonEnabledByNode(petNode, false)
            petNode:addTo(home)
            petNode:pos(41.5, 82)
            petNode:scale(0.8)
            CSResourceMgr.clickEventBindingByNode(home, function()
                NetInterface.sendWithBlock("GC_GetAdvAward_Ack", function()
                    local AdventureSend = require("src.Net.Send.AdventureSend")
                    AdventureSend.sendCG_GetAdvAward_Req({advID=var.info})
                end, function()
                    tipsNode:hide()
                end, function(code)
                    TipsMgr.showError(nil, code)
                end)
            end)            
            refreshFloatAwards = function(starnum, buttonTip)
                local infoText = CSResourceMgr.seekNodeByName(buttonTip, "info")
                local homeButton = CSResourceMgr.seekNodeByName(buttonTip, "home")
                if starnum==3 then
                    CSResourceMgr.setLabelColorByNode(infoText, {r=254,g=208,b=68,a=255})
                    CSResourceMgr.setLabelStringByNode(infoText, "family100", {r=0,g=0,b=0,a=255,w=2}, nil, 120)
                    CSResourceMgr.setButtonEnabledByNode(homeButton, true)
                else
                    CSResourceMgr.setLabelColorByNode(infoText, {r=62,g=226,b=255,a=255})
                    CSResourceMgr.setLabelStringByNode(infoText, "staraward1", {r=0,g=0,b=0,a=255,w=2}, nil, 120)
                    CSResourceMgr.setButtonEnabledByNode(homeButton, false)
                end
            end
            refreshFloatAwards(starNum, tipsNode)
        end
    end
    for key, var in pairs(WorldMapInfo.getExploreInfoByID(WorldMapMgr.curMapID)) do
        local sbtn = WorldMapMgr.getMapPointNode(var.id)
        local sboard = addSBoard(sbtn, 1, var.id)
        CSResourceMgr.getNodeByName(sboard.res, "d1", sboard.tag):setVisible(false)
    end
    for key, var in pairs(WorldMapInfo.getMapEventInfoByID(WorldMapMgr.curMapID)) do
        local bRes = roadResTable[1]
        local dRes = roadResTable[3]
        CSResourceMgr.setButtonTexture(resName, "p"..var.id, bRes, bRes, dRes)
        CSResourceMgr.setButtonEnabled(resName, "p"..var.id, true)
    end
    for key, var in pairs(WorldMapInfo.getInvisibleInfoByID(WorldMapMgr.curMapID)) do
        local bdRes = roadResTable[3]
        CSResourceMgr.setButtonTexture(resName, "p"..var.id, bdRes, bdRes, bdRes)
        CSResourceMgr.setButtonEnabled(resName, "p"..var.id, false)
    end
    for key, var in pairs(WorldMapInfo.getTransferInfoByID(WorldMapMgr.curMapID)) do
        local bdRes = roadResTable[3]
        CSResourceMgr.setButtonTexture(resName, "p"..var.id, bdRes, bdRes, bdRes)
        CSResourceMgr.setButtonEnabled(resName, "p"..var.id, false)
        local parent = WorldMapMgr.getMapPointNode(var.id)
        parent:pos(0, -50)
        local ccbiNode = CSResourceMgr.createCCBI(parent, "texture/ui_dc_06b.ccbi", parent:getContentSize().width/2, 50)
        ccbiNode:setScale(0.6)
        local ccbiPar = CSResourceMgr.getCCBIParticle(ccbiNode)[1]
        if ccbiPar then
        	ccbiPar:setPositionType(cc.POSITION_TYPE_GROUPED)
        end
    end
    local teamInfo = WorldMapInfo.getTeamMapInfo()[WorldMapMgr.curMapID]
    if teamInfo then
        local sbtn = WorldMapMgr.getMapPointNode(teamInfo.pid)
        local sboard = addSBoard(sbtn, 1, teamInfo.pid)
        sbtn:setUnifySizeEnabled(false)
        sbtn:setScale9Enabled(true)
        sbtn:ignoreContentAdaptWithSize(false)
        local disableIcon = string.gsub(teamInfo.icon, ".png", "_2.png")
        local aniRes = WorldMapInfo.getTeamSpineAniRes(WorldMapMgr.curMapID)
        if aniRes then
            local ani = AnimationMgr.createAni(sbtn, aniRes, sbtn:getContentSize().width/2, 
                sbtn:getContentSize().height/2, "WorldMap")
            AnimationMgr.playAni(ani.res, "animation", true, ani.tag)
            ani:hide()
        end
        CSResourceMgr.setButtonTextureByNode(sbtn, roadResTable[3], roadResTable[3], disableIcon)
        CSResourceMgr.getNodeByName(sboard.res, "d1", sboard.tag):hide()
        CSResourceMgr.getNodeByName(sboard.res, "sname", sboard.tag):show()
        CSResourceMgr.setLabelColor(sboard.res, "sname", {r=0,g=179,b=254,a=255}, sboard.tag)
        CSResourceMgr.setLabelString(sboard.res, "sname", "team48", sboard.tag, {r=0,g=0,b=0,a=255})
    end
    local bossPid = WorldMapInfo.getBossMapPoint(WorldMapMgr.curMapID)
    if bossPid then
        local bdRes = roadResTable[3]
        CSResourceMgr.setButtonTexture(resName, "p"..bossPid, bdRes, bdRes, bdRes)
    end
    
    WorldMapMgr.checkMapLockInfo()
    
    --添加地图特效
    WorldMapMgr.addMapAni()
    
    --添加小人
    local curMapButton = CSResourceMgr.getNodeByName(resName, "p"..WorldMapMgr.curP)
    if curMapButton then
        local parent = curMapButton:getParent()
        local nodePx = curMapButton:getPositionX()
        local nodePy = curMapButton:getPositionY()
        charGaf = PlayerAnimeMgr.createPlayer(parent, 
            {gender=CharInfo.getSex(), x=nodePx, y=nodePy, skin=CharInfo.getCurfashion()}, headTagStr)
        charGaf:setScale(WorldMapMgr.PLAYER_SCALE)
        charGaf:setLocalZOrder(3)
    end
    
    --双指缩放地图
    local touchPoint = 0
    local touchInfo = {}
    local touchInfoTmp = {}
    local touchDistance = 0
    local touchRate = 0
    local isTouchScaling = false
    local touchLayer = display.newLayer():addTo(scene)
    scrollview:setSwallowTouches(false)
    scrollview:setBounceEnabled(false)
    local listenner = cc.EventListenerTouchAllAtOnce:create()
    listenner:registerScriptHandler(function(touch, event)
        if TOUCH_PIPELINE_DIAGNOSTICS then
            local first = touch[1]
            local location = first and first:getLocation() or nil
            print(string.format("[TOUCH_DIAG] world_map_all_at_once phase=began touches=%d first_x=%s first_y=%s scene=%s scroll_swallow=false",
                #touch, tostring(location and location.x), tostring(location and location.y), tostring(SceneMgr.currentScene)))
        end
        touchPoint = touchPoint+#touch
        for key, var in pairs(touch) do
            if #touchInfo<2 then
                local x = touchLayer:convertToNodeSpace(var:getLocation()).x
                local y = touchLayer:convertToNodeSpace(var:getLocation()).y
                table.insert(touchInfo, {x=x, y=y})
                --print(x, y)
        	end
        end
        if #touchInfo==1 then
            local x = touchInfo[1].x
            local y = touchInfo[1].y
            --点击脚印效果
            local footPrintRes = "Spine/effects/Ui_jiemiandianji.png"
            local footPrint = AnimationMgr.createAni(scene, footPrintRes, x, y)
            AnimationMgr.playAniWithCallback(footPrintRes, "animation", nil, nil, true)
            footPrint:setLocalZOrder(CocosModuleMgr.ZORDER_TIPS)
            if CSResourceMgr.getCsbObj("UI/Chat/TownChatLayer.csb") then
                TownChatMgr.showChatView(false)
            end
        end
        if #touchInfo==2 and isTouchScaling==false then
            local x1 = touchInfo[1].x
            local y1 = touchInfo[1].y
            local x2 = touchInfo[2].x
            local y2 = touchInfo[2].y
            touchInfoTmp[1] = {x=x1, y=x2}
            touchInfoTmp[2] = {x=x2, y=y2}
        	touchDistance = math.sqrt(math.pow(x1-x2,2)+math.pow(y1-y2,2))
        	touchRate = mapScale
            isTouchScaling = true
            local w = scrollview:getInnerContainer():getContentSize().width-640
            perW = math.floor(scrollview:getInnerContainer():getPositionX()/w*(-100))
            local h = scrollview:getInnerContainer():getContentSize().height-1136
            perH = math.floor(100-(scrollview:getInnerContainer():getPositionY()/h*(-100)))
            if scrollview:getInnerContainer():getContentSize().width/640<1.2 then
            	perW = 50
            end
            if scrollview:getInnerContainer():getContentSize().height/1136<1.5 then
                perH = 40
            end
            print(scrollview:getInnerContainer():getContentSize().width, scrollview:getInnerContainer():getContentSize().height)
            print("touchDistance", touchDistance)
        end
        --print("EVENT_TOUCHES_BEGAN", #touch)
    end, cc.Handler.EVENT_TOUCHES_BEGAN)
    listenner:registerScriptHandler(function(touch, event)
        if TOUCH_PIPELINE_DIAGNOSTICS then
            print(string.format("[TOUCH_DIAG] world_map_all_at_once phase=moved touches=%d scene=%s", #touch, tostring(SceneMgr.currentScene)))
        end
        if touchPoint>=2 then
            for key, var in pairs(touch) do
                local mx = touchLayer:convertToNodeSpace(var:getLocation()).x
                local my = touchLayer:convertToNodeSpace(var:getLocation()).y
                local sx = touchLayer:convertToNodeSpace(var:getStartLocation()).x
                local sy = touchLayer:convertToNodeSpace(var:getStartLocation()).y
                if touchInfo[1].x==sx and touchInfo[1].y==sy then
                    touchInfoTmp[1] = {x=mx, y=my}
                elseif touchInfo[2].x==sx and touchInfo[2].y==sy then
                    touchInfoTmp[2] = {x=mx, y=my}
                end
            end
            local d = math.sqrt(math.pow(touchInfoTmp[1].x-touchInfoTmp[2].x,2)+math.pow(touchInfoTmp[1].y-touchInfoTmp[2].y,2))
            local rate = (d-touchDistance)*mapScale/300+touchRate
            if d>touchDistance then
                rate = (d-touchDistance)*mapScale/150+touchRate
            end
            print("MapScale", rate)
            WorldMapMgr.setMapScale(rate)
        end
        --print("EVENT_TOUCHES_MOVED", #touch)
    end, cc.Handler.EVENT_TOUCHES_MOVED)
    listenner:registerScriptHandler(function(touch, event)
        if TOUCH_PIPELINE_DIAGNOSTICS then
            print(string.format("[TOUCH_DIAG] world_map_all_at_once phase=ended touches=%d scene=%s", #touch, tostring(SceneMgr.currentScene)))
        end
        touchPoint = touchPoint-#touch
        if touchPoint<=0 then
            touchPoint = 0
            touchInfo = {}
            if isTouchScaling then
                UserSettings.set({Scale = mapScale}, 7)
                isTouchScaling = false
            end
        end
        --print("EVENT_TOUCHES_ENDED")  
    end, cc.Handler.EVENT_TOUCHES_ENDED)
    listenner:registerScriptHandler(function(touch, event)
        touchPoint = touchPoint-#touch
        if touchPoint<=0 then
            touchPoint = 0
            touchInfo = {}
            if isTouchScaling then
                UserSettings.set({Scale = mapScale}, 7)
                isTouchScaling = false
            end
        end
        --print("EVENT_TOUCHES_CANCELLED")  
    end, cc.Handler.EVENT_TOUCHES_CANCELLED)
    --[[
    scrollview:addEventListener(function(sender, state)
        if isTouchScaling then
            --scrollview:jumpToPercentHorizontal(perW)
            --scrollview:jumpToPercentVertical(perH)
            --scrollview:setPropagateTouchEvents(false)
        end
    end)]]
    local eventDispatcher = touchLayer:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, touchLayer)
    
    WorldMapMgr.setMapScale(mapScale)
    WorldMapAwardsMgr.setRequestVec(reqVec)
    
    --放背景音乐
    GameAudio.playMusic2("mapmusic"..WorldMapMgr.curMapID)
end

function WorldMapMgr.getCurEmbeddedMapID()
    return WorldMapInfo.getEmbeddedMapID(WorldMapMgr.curMapID, WorldMapMgr.curP)
end

function WorldMapMgr.refreshAdventureStars()
    if not CSResourceMgr.getCsbObj(resName) then return end
    for key, var in pairs(WorldMapInfo.getSearchInfoByID(WorldMapMgr.curMapID)) do
        local starNum, starMax = AdvStarMgr.getWorldMapStarNum(var.info)
        starNum = starNum or 0
        starMax = starMax or 3
        local sboard = CSResourceMgr.getCsbObj(starBoardResTable[starMax], var.id)
        for i=1, starNum do
            CSResourceMgr.getNodeByName(sboard.res, "s"..i, sboard.tag):setVisible(true)
        end
        local tipsNode = floatAwards[var.info]
        if tipsNode then
            refreshFloatAwards(starNum, tipsNode)
        end
    end
end

function WorldMapMgr.showFloatAwards(id)
    if not CSResourceMgr.getCsbObj(resName) then
        return
    end
    if floatAwards[id] then
    	floatAwards[id]:show()
    end
end

function WorldMapMgr.refreshWorldBoss(scene)
    if not (SceneMgr.currentScene=="MainScene" or SceneMgr.currentScene=="LabScene" or SceneMgr.currentScene=="TownScene"
        or SceneMgr.currentScene == "StarScene") then
    	return
    end
    local curBossInfo = WorldBossInfo.getCurBossInfo()
    local function closeWorldBoss()
        WorldMapMoveMgr.hideBossMoveDlg()
        CSResourceMgr.removeCSObjectByTag(bossTipRes)
        if CSResourceMgr.getCsbObj(resName) then
            local pid = WorldMapInfo.getBossMapPoint(WorldMapMgr.curMapID)
            if pid then
                WorldMapMgr.getMapPointNode(pid):hide()
            end
        end
    end
    if not curBossInfo then
        closeWorldBoss()
    	return
    end
    if curBossInfo.isLive==0 then
        closeWorldBoss()
        return
    end
    scene = scene or SceneMgr.getRunningScene
	if CharInfo.getServerTime()<curBossInfo.createTime+curBossInfo.duration then
        local bossInfo = WorldBossInfo.getWorldBossInfoByID(curBossInfo.bossID)
        local tipsNode = CSResourceMgr.createRes(scene, bossTipRes)
        CSResourceMgr.playAllFrame(bossTipRes, true)
        tipsNode:zorder(CocosModuleMgr.ZORDER_CHAT)
        local distance = 300
        if CocosModuleMgr.getScreenSizeDiff()<=10 then
        	distance = 130
        end
        if SceneMgr.currentScene=="MainScene" then
            CocosModuleMgr.setEdgeDistance(tipsNode, nil, 0, nil, distance)
            local terminalPosx = tipsNode:getPositionX()
            tipsNode:setPositionX(terminalPosx+300)
            transition.moveTo(tipsNode, {x=terminalPosx, time=0.3})
        else
            CocosModuleMgr.setEdgeDistance(tipsNode, 30, nil, 200, nil)
            local terminalPosx = tipsNode:getPositionX()
            tipsNode:setPositionX(terminalPosx-300)
            transition.moveTo(tipsNode, {x=terminalPosx, time=0.3})
        end
        tipsNode:performWithDelay(function()
            CSResourceMgr.clickEventBinding(bossTipRes, "button", function()
                if TeamInfo.getInfo(TeamInfo.KEY_TEAMID) then
                    print("当前已经在队伍中，无法去打boss")
                    StandardTipsMgr.show(1, "worldmapbosstip5")
                    return
                end 
                if SceneMgr.currentScene=="MainScene" then
                    if WorldMapMgr.curMapID==curBossInfo.mapID then
                        TipsMgr.show(scene, "worldmapbosstip1")
                        TipsMgr.show(scene, "worldmapbosstip2")
                	else
                        WorldMapMgr.setMapIDandPos(curBossInfo.mapID, 1)
                        SceneMgr.replaceScene(scene, "MainScene")
                	end
                else
                    if WorldMapMgr.curMapID~=curBossInfo.mapID then
                        WorldMapMgr.setMapIDandPos(curBossInfo.mapID, 1)
                    end                    
                    SceneMgr.replaceScene(scene, "MainScene")
                end
            end, nil, 1)
        end, 0.5)
        local iconRes = WorldBossInfo.getBossIconRes(curBossInfo.bossID)
        CSResourceMgr.setSpriteTexture(bossTipRes, "icon", iconRes)
        CSResourceMgr.setLabelString(bossTipRes, "info", "worldmapbosstip3", nil, {r=255,g=0,b=0,a=255}, nil, 120)
        if bossInfo then
            local attriinfo = tonumber(PokemonInfo.getPokemonInfoByID(bossInfo.model).elementAtt1)
            local attrNode = CSResourceMgr.getNodeByName(bossTipRes, "attr")
            CSResourceMgr.setSpriteTextureByNode(attrNode, "UI/CommonFiles/"..attriinfo..".png")
            attrNode:scale(0.4)
            local pvec = PokemonInfo.getStagePics("", attriinfo, "")
            CSResourceMgr.setSpriteTexture(bossTipRes, "attrdb", pvec.p2)
        end
        if CSResourceMgr.getCsbObj(resName) then
            if curBossInfo.mapID==WorldMapMgr.curMapID then
                WorldMapMoveMgr.showBoss(scene)
                local pid = WorldMapInfo.getBossMapPoint(WorldMapMgr.curMapID)
                if pid then
                	local pnode = WorldMapMgr.getMapPointNode(pid)
                	pnode:show()
                    local buttonRes = "Map/WorldMap/boss_button.png"
                    CSResourceMgr.setButtonTextureByNode(pnode, buttonRes, buttonRes, buttonRes)
                    local petRes = nil
                    if bossInfo then
                    	petRes = PokemonInfo.getPokemonResByID(bossInfo.model)
                    else
                        petRes = PokemonInfo.getPokemonResByID(1)
                    end
                    local petAni = AnimationMgr.createAni(pnode, petRes, pnode:getContentSize().width/2, 0, "worldmapbossani")
                    petAni:zorder(-2)
                    petAni:setScale(0.9)
                    local ballAni = AnimationMgr.createAni(pnode, "Gaf/effect/world_boss_eff.gaf", 320, 480, "worldmapbossani")
                    ballAni:scale(0.8)
                    AnimationMgr.playAni(ballAni.res, "idle", true, ballAni.tag)
                    AnimationMgr.setSkin(petAni.res, "0", petAni.tag)
                    AnimationMgr.playAni(petAni.res, "idle", true, petAni.tag)
                    CSResourceMgr.buttonEventBindingByNode(pnode, function()
                        CocosModuleMgr.lightenNode(petAni, 0.5)
                    end, function()
                        CocosModuleMgr.lightenNode(petAni, 0)
                        WorldMapMoveMgr.showBossMoveDlg(pid, curBossInfo.bossID)
                    end, nil, function()
                        CocosModuleMgr.lightenNode(petAni, 0)
                    end)
                    local playerNum = 6
                    local xDiff = math.floor((pnode:getContentSize().width)/playerNum)
                    local yDiff = math.floor(60/playerNum)
                    for var=1, playerNum do
                        local skinIndex = GetRandom.random(1, 50)
                        local kar = playerNum-var+1
                        local tar = 0
                        if var%2==1 then
                            tar = math.ceil(var/2)
                        else
                            tar = playerNum-var/2+1
                        end
                        --print("-------------", kar, tar)
                        local pTag = "worldmapbossani"..var
                        if not PlayerAnimeMgr.playerTable[pTag] then
                            local playerAni = PlayerAnimeMgr.createPlayer(pnode, {
                                skin={GetRandom.random(1, 10), 1000+skinIndex, 2000+skinIndex, 3000+skinIndex}, 
                                x=GetRandom.random((tar-1)*xDiff+5, tar*xDiff-5)-10, 
                                y=GetRandom.random((kar-1)*yDiff, kar*yDiff)-80,
                            }, pTag, false, false)
                            PlayerAnimeMgr.setPlayerAniScale(pTag, WorldMapMgr.PLAYER_SCALE*0.7)
                            if tar>playerNum/2 then
                                playerAni:setScaleX(-1)
                            end
                            local function attackAni()
                                PlayerAnimeMgr.playAniWithCallback(playerAni.tag, "attack", function()
                                    PlayerAnimeMgr.playAni(playerAni.tag, "idle", true)
                                end)
                                playerAni:performWithDelay(function()
                                    attackAni()
                                end, GetRandom.random(1, 5))
                            end
                            attackAni()
                        end                        
                    end
                end
            else
                local pid = WorldMapInfo.getBossMapPoint(WorldMapMgr.curMapID)
                if pid then
                    WorldMapMgr.getMapPointNode(pid):hide()
                end
            end
        end
	else
        closeWorldBoss()
	end
end

---获取移动路线
--@param id int 目标地图点
--@param sid int 起始地图点，不填则为当前地图点
function WorldMapMgr.searchRoute(id, sid)
    sid = sid or WorldMapMgr.curP
    local routeResult = {}
    local branchTbl = {}
    local error = false
    local function searchRoute(from, to)
        --print("add:"..from)
        table.insert(routeResult, from)
        local tmpTbl = {}
        for key, var in pairs(WorldMapInfo.getRouteInfoByID(WorldMapMgr.curMapID)) do
            if (var[1]==to and var[2]==from) or (var[2]==to and var[1]==from) then
                table.insert(routeResult, to)
                return
            end
            if var[1]==from then
                table.insert(tmpTbl, var[2])
            end
            if var[2]==from then
                table.insert(tmpTbl, var[1])
            end
        end
        for key, var in pairs(tmpTbl) do
            local isContained = false
            for k, v in pairs(routeResult) do
                if v==var then
                    isContained = true
                end
            end
            if isContained==true or var==sid then
                table.remove(tmpTbl, key)
            end
        end
        if #tmpTbl>1 then
            --走到分岔路
            table.insert(branchTbl, tmpTbl)
            searchRoute(tmpTbl[1], to)
        elseif #tmpTbl==0 then
            --走到末路
            if #branchTbl==0 then
                error = true
                print("找不到路线，请检查routeTable")
                return
            end
            local branchid = branchTbl[#branchTbl][1]

            local function resetRouteResult(bid)
                local bkey = #routeResult
                local tmpRouteTbl = {}
                for key, var in pairs(routeResult) do
                    if var==bid then
                        bkey = key
                    end
                    if key<bkey then
                        table.insert(tmpRouteTbl, var)
                    end
                end
                routeResult = tmpRouteTbl
            end

            resetRouteResult(branchid)
            
            local function removeBranch(boolRemove)
                if boolRemove then
                    resetRouteResult(branchTbl[#branchTbl][1])
                end
                table.remove(branchTbl[#branchTbl], 1)
                if #branchTbl[#branchTbl]==0 then
                    table.remove(routeResult, #routeResult)
                    table.remove(branchTbl, #branchTbl)
                    if #branchTbl==0 then
                        error = true
                        print("找不到路线，请检查routeTable")
                        return
                    end
                    removeBranch(true)
                end
            end
            removeBranch(false)
            if error then
            	return
            else
                searchRoute(branchTbl[#branchTbl][1], to)
            end
        else
            --走到直路
            searchRoute(tmpTbl[1], to)
        end
    end
    searchRoute(sid, id)
    if routeResult[1]==sid then
        table.remove(routeResult, 1)
    end
    if error then
    	return nil
    end
    return routeResult
end

function WorldMapMgr.moveTo(id)
    if WorldMapMgr.curP==id then
    	return
    end
    
    local distination = id
    local routeResult = WorldMapMgr.searchRoute(id)
    if not routeResult then
    	StandardTipsMgr.show(1, "tips48")
    	return
    end

    local function moveto(rTable, isFirst)
        WorldMapMgr.isMoving = true
        local id = rTable[1]
        EmbeddedMapMgr.change(WorldMapInfo.getEmbeddedMapID(WorldMapMgr.curMapID, id))
        local curMapButton = CSResourceMgr.getNodeByName(resName, "p"..WorldMapMgr.curP)
        local terMapButton = CSResourceMgr.getNodeByName(resName, "p"..id)
        local curPosx = curMapButton:getPositionX()
        local terPosx = terMapButton:getPositionX()
        local curPosy = curMapButton:getPositionY()
        local terPosy = terMapButton:getPositionY()
        local charHeadGaf = PlayerAnimeMgr.getPlayer(headTagStr)
        local curScalex = math.abs(charHeadGaf:getScaleX())
        local curScaley = math.abs(charHeadGaf:getScaleY())
        if terPosx-curPosx<0 then
            charHeadGaf:setScale(-curScalex, curScaley)
        else
            charHeadGaf:setScale(curScalex, curScaley)
        end
        local distance = math.sqrt(math.pow(terPosx-curPosx, 2)+math.pow(terPosy-curPosy, 2))
        local movetime = distance/WorldMapMgr.DEFAULT_MOVE_SPEED
        transition.moveBy(charHeadGaf, {x=terPosx-curPosx, y=terPosy-curPosy, time=movetime})

        PlayerAnimeMgr.playAni(headTagStr, "walk", true)
        charHeadGaf:performWithDelay(function()
            PlayerAnimeMgr.playAni(headTagStr, "idle", true)
            if moveNextP=="null" then
            	moveNextP = nil
            else
                WorldMapMgr.curP = id
            end
            table.remove(rTable, 1)
            WorldMapMgr.isMoving = false            
            if #rTable>0 and not WorldMapMgr.isRouteChanged then
                moveNextP = rTable[1]
                moveto(rTable)
            else
                moveNextP = nil
                EmbeddedMapMgr.stop()
            end
            if distination==WorldMapMgr.curP then
                WorldMapMgr.checkEvent()
            end
        end, movetime)
        if isFirst then
            checkScroll(WorldMapMgr.curP, 0.5)
            charHeadGaf:performWithDelay(function()
                checkScroll(id, movetime-0.5)
            end, 0.5)
        else
            checkScroll(id, movetime)
        end
    end
    
    for key, var in pairs(routeResult) do
        print("~~~~~~~~~~", key, var)
    end
    WorldMapMgr.isRouteChanged = false
    EmbeddedMapMgr.move()
    moveto(routeResult, true)
end

function WorldMapMgr.setMapScale(s)
    if s<0.7 or s>2 then
    	return
    end
    local scrollview = CSResourceMgr.getNodeByName(resName, "scrollview")
    
    local size = mapSize
    scrollview:setInnerContainerSize({width=size.width*s, height=size.height*s})
    local mapLayer = CSResourceMgr.getNodeByName(resName, "map")
    mapLayer:setScale(s, s)
    mapLayer:setPosition(0, 0)
    
    scrollview:jumpToPercentHorizontal(perW)
    scrollview:jumpToPercentVertical(perH)
    mapScale = s
end

---检查地图加锁信息
function WorldMapMgr.checkMapLockInfo(boolAnimate)
    if not CSResourceMgr.getCsbObj(resName) then
        return
    end
    if boolAnimate==nil then
    	boolAnimate = false
    end
    if WorldMapInfo.getLockInfoByID(WorldMapMgr.curMapID) then
        for key, var in pairs(WorldMapInfo.getLockInfoByID(WorldMapMgr.curMapID)) do
            if var then
                local btn = WorldMapMgr.getMapPointNode(key)
                local pType = WorldMapInfo.getPointInfoByID(WorldMapMgr.curMapID, key).type
                if pType==WorldMapInfo.POINT_TYPE_TEAM then
                    local aniRes = WorldMapInfo.getTeamSpineAniRes(WorldMapMgr.curMapID)
                    local ani = nil
                    if aniRes then
                        ani = AnimationMgr.getGafObj(aniRes, "WorldMap")
                    end
                    if TeamInfo.checkLock(WorldMapMgr.curMapID) then
                        CSResourceMgr.setButtonEnabledByNode(btn, true)
                        if ani then
                            ani:show()
                        end
                	else
                        CSResourceMgr.setButtonEnabledByNode(btn, false)
                        btn:setTouchEnabled(true)
                        if ani then
                            ani:hide()
                        end
                	end
                else
                    if var<=CharInfo.get().maplock then
                        if boolAnimate and not btn:isTouchEnabled() then
                            if pType==WorldMapInfo.POINT_TYPE_STAGE or pType==WorldMapInfo.POINT_TYPE_EXPLORE then
                                CocosModuleMgr.showUnlockAnimation(btn, nil, 2)
                            else
                                CocosModuleMgr.showUnlockAnimation(btn, nil, 3)
                            end
                            WorldMapMgr.locateToPoint(key)
                        else
                            CSResourceMgr.setButtonEnabledByNode(btn, true)
                        end
                    else
                        CSResourceMgr.setButtonEnabledByNode(btn, false)
                        if pType==WorldMapInfo.POINT_TYPE_TRANSFER then
                            btn:setTouchEnabled(true)
                        end
                    end
                end
            end
        end
        WorldMapMgr.checkMapEventInfo()
        WorldMapMgr.checkMapMissionInfo()
        WorldMapMgr.checkConfraternityInfo()
    end
end

function WorldMapMgr.setMapMoveFinishFunc(func)
	mapMoveFinishFunc = func
end

function WorldMapMgr.getMapPointNode(i)
    local mapnode = CSResourceMgr.getNodeByName(resName, {"scrollview", "map", "p"..i, "p"..i.."_"})
    if mapnode then
        return mapnode
    end
    return CSResourceMgr.getNodeByName(resName, {"scrollview", "map", "p"..i})
end

function WorldMapMgr.addMapAni()
    local aniResVec = WorldMapInfo.getWorldSpineAniRes(WorldMapMgr.curMapID)
    local aniParent = CSResourceMgr.getNodeByName(resName, "mapImage")
    for var=1, #aniResVec do
        local ani = AnimationMgr.createAni(aniParent, aniResVec[var].res, aniResVec[var].pos.x, aniResVec[var].pos.y, "WorldMap"..var)
        AnimationMgr.playAni(ani.res, "animation", true, ani.tag)
    end
end

---检查地图小节点随机事件
function WorldMapMgr.checkMapEventInfo()
	if not CSResourceMgr.getCsbObj(resName) then
		return
	end
    local eventVec = AdventureInfo.getMapEventInfo(WorldMapMgr.curMapID)
    for key, var in pairs(eventVec) do
        if var.mapid==WorldMapMgr.curMapID then
            local level = WorldMapInfo.getLockInfoByID(WorldMapMgr.curMapID)[var.pid]
            if level then
                if level<=CharInfo.get().maplock then
                    if not QuestInfo.checkProcessMapSmallPoint(WorldMapMgr.curMapID, var.pid) then
                        WorldMapMgr.addEvent(1, var.pid)
                    end
                end
            end
		end
	end
end

---检查地图小节点任务
function WorldMapMgr.checkMapMissionInfo()
    if not CSResourceMgr.getCsbObj(resName) then
        return
    end
    local eventVec = QuestInfo.getMapSmallPointQuestInfos()
    for key, var in pairs(eventVec) do
        if var.mapid==WorldMapMgr.curMapID then
            local level = WorldMapInfo.getLockInfoByID(WorldMapMgr.curMapID)[var.pid]
            if level then
                if level<=CharInfo.get().maplock then
                    WorldMapMgr.addEvent(2, var.pid)
                end
            end
        end
    end
end

---检查家族任务
function WorldMapMgr.checkConfraternityInfo()
	if not CSResourceMgr.getCsbObj(resName) then
        return
    end
    local mInfo = AdventureInfo.getFamilyQuestInfo()
    if mInfo then
        if mInfo.mapID==WorldMapMgr.curMapID then
            local level = WorldMapInfo.getLockInfoByID(mInfo.mapID)[mInfo.pID]
            if level then
                if level<=CharInfo.get().maplock then
                    WorldMapMgr.addEvent(3, mInfo.pID)
                end
            end
        end
    end
end

---添加地图悬浮标记
--@param type int 0家符号1问号2感叹号3家族任务
--@param pNum int 地图点id
--@return tips node
function WorldMapMgr.addEvent(type, pNum)
    local tipsRes = floatResTable[type+1]
    local nameVec = {
        [0] = "home",
        [1] = "event",
        [2] = "mission",
        [3] = "confra"
    }
    local btnName = nameVec[type]
    if not btnName then
    	return
    end
    local node = CSResourceMgr.getNodeByName(resName, "p"..pNum)
    if not node then
    	return
    end
    WorldMapMgr.removeEvent(WorldMapMgr.curMapID, pNum)
    CSResourceMgr.setButtonTextureByNode(node, roadResTable[2], roadResTable[2], roadResTable[3])
    local tips = CSResourceMgr.createRes(CSResourceMgr.getNodeByName(resName, "map"), tipsRes, pNum)
    CSResourceMgr.clickEventBinding(tipsRes, btnName, function()
        CSResourceMgr.callButtonFunc(resName, "p"..pNum)
    end, pNum)
    CSResourceMgr.playAllFrame(tipsRes, true, pNum)
	tips:setAnchorPoint(0.5, 0.5)
    tips:setPosition(node:getPositionX(), node:getPositionY()+20)
    tips:setLocalZOrder(2)
    return tips
end

---删除地图悬浮标记
--@param pNum int 地图点id
function WorldMapMgr.removeEvent(mapid, pNum)
    print("删除地图悬浮标记", mapid, pNum)
    if WorldMapMgr.curMapID~=mapid then
    	return
    end
    for var=1, #floatResTable do
        CSResourceMgr.removeCSObjectByTag(floatResTable[var], pNum)
    end
    local node = CSResourceMgr.getNodeByName(resName, "p"..pNum)
    if node then
        CSResourceMgr.setButtonTextureByNode(node, roadResTable[1], roadResTable[1], roadResTable[3])
    end
end

---定位主角
function WorldMapMgr.locateCharactor()
    checkScroll(WorldMapMgr.curP, 0.5)
end

---定位到地图上某一点
--@param pNum int 地图点id
function WorldMapMgr.locateToPoint(pNum)
    checkScroll(pNum, 0.5)
end

---地图滚动至某处
--@param px float 填0-100之间
--@param py float 填0-100之间
function WorldMapMgr.scrollMapTo(px, py, time)
    local scrollview = CSResourceMgr.getNodeByName(resName, "scrollview")
    --print("now map scroll to "..px..", "..py)
    if time<=0 then
        scrollview:jumpToPercentHorizontal(px)
        scrollview:jumpToPercentVertical(py)
    else
        transition.stopTarget(scrollview)
        scrollview:performWithDelay(function()
            scrollview:scrollToPercentBothDirection({x=px, y=py}, time, true)
        end, 0.001)
    end
end

---寻找副本
--@param aid int 副本id
--@param tab int tab页id
function WorldMapMgr.searchAdventureNode(aid, tab)
    tab = tab or math.ceil(aid / 10000)
    for key, var in pairs(WorldMapInfo.getSearchInfo()) do
		local mapid = key
		for pointID, info in pairs(var) do
			local pid = aid%10000
			if pid==info.info then
                local level = WorldMapInfo.getLockInfoByID(mapid)[info.id]
                print("已找到相应副本，解锁要求：", level, "aid:", aid, "tab:", tab)
                if level then
                    if level>CharInfo.get().maplock then
                        StandardTipsMgr.show(1, "tips22")
                    else
                        WorldMapMgr.curAID = aid
                        if SceneMgr.currentScene=="MainScene" and WorldMapMgr.curMapID==mapid then
                            WorldMapMgr.flyToPoint(info.id, false)
                            SearchingUIMgr.addAdvConfirmUI(SceneMgr.getRunningScene, aid, tab)
                        else
                            WorldMapMgr.curMapID = mapid
                            WorldMapMgr.curP = info.id
                            MapSeekerMgr.setSeekFunc(function()
                                SearchingUIMgr.addAdvConfirmUI(SceneMgr.getRunningScene, aid, tab)
                            end)
                            UIStack.closeAllUI()
                            SceneMgr.replaceScene(SceneMgr.getRunningScene, "MainScene")
                        end
                    end
                end
                break
			end
		end
	end
end

---飞去当前地图的某点
--@param pid int 地图点id
--@param boolCheckEvent bool 移动完成后是否检查事件
function WorldMapMgr.flyToPoint(pid, boolCheckEvent)
    local charHeadGaf = PlayerAnimeMgr.getPlayer(headTagStr)
    WorldMapMgr.isRouteChanged = true
    if WorldMapMgr.isMoving and moveNextP and moveNextP~="null" then
        WorldMapMgr.curP = moveNextP
        moveNextP = "null"
    end
    EmbeddedMapMgr.removeEvent()
    EmbeddedMapMgr.stop()
    local curMapButton = CSResourceMgr.getNodeByName(resName, "p"..WorldMapMgr.curP)
    local terMapButton = CSResourceMgr.getNodeByName(resName, "p"..pid)
    local curPosx = curMapButton:getPositionX()
    local terPosx = terMapButton:getPositionX()
    local curPosy = curMapButton:getPositionY()
    local terPosy = terMapButton:getPositionY()
    local curCharPosx = charHeadGaf:getPositionX()
    local curCharPosy = charHeadGaf:getPositionY()
    charHeadGaf:setPosition(curCharPosx+terPosx-curPosx, curCharPosy+terPosy-curPosy)
    WorldMapMgr.curP = pid
    WorldMapMgr.locateCharactor()
    EmbeddedMapMgr.change(WorldMapInfo.getEmbeddedMapID(WorldMapMgr.curMapID, WorldMapMgr.curP))
    if boolCheckEvent==nil then
    	boolCheckEvent = true
    end
    if boolCheckEvent then
        WorldMapMgr.checkEvent()
    end
end

---更换大地图主角时装
function WorldMapMgr.changeAvatar()
	PlayerAnimeMgr.setPlayerSkins(headTagStr, CharInfo.getCurfashion())
end

function WorldMapMgr.setVisible(val)
    local function setVisible(res)
        local layer = CSResourceMgr.getCsbObj(res)
        if layer then
            layer:setVisible(val)
        end
    end
    setVisible(resName)
    setVisible(bossTipRes)
end

function WorldMapMgr.setMapIDandPos(id, pos)
    WorldMapMgr.curMapID = id
    WorldMapMgr.curP = pos
end

function WorldMapMgr.sendSelfPosition(sid, eid)
    if not NetInterface.isConnect or CharInfo.getCharID()==0 then
        return
    end
    if mapMoveInfo.isSending then
        return
    end
    mapMoveInfo.isSending = true
    local function finishFunc()
        mapMoveInfo.isSending = false
    end
    NetInterface.send("GC_Chat_Ack", function()
        local cjson = require("cjson")
        local ChatSend = require("src.Net.Send.ChatSend")
        local str = cjson.encode({mapid = WorldMapMgr.curMapID, startP = sid, endP = eid, nickname = CharInfo.getNickName(), 
            playerSkin = CharInfo.getCurfashion(), petID = PokemonInfo.getFollowPokemonID(), king = TerritorialInfo.getMyStageID(), 
            level = CharInfo.getLevel()})
        ChatSend.sendCG_Chat_Req({charID = "", channel = TownChatMgr.GetChannelTable()[6], concent =str})
        --print("WorldMapMgr.sendSelfPosition channel", TownChatMgr.GetChannelTable()[6])
    end, function()
        finishFunc()
    end, function()
        finishFunc()
    end)
end

function WorldMapMgr.getCharGaf()
    return charGaf
end

return WorldMapMgr
