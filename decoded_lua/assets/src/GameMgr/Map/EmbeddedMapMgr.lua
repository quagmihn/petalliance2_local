local EmbeddedMapMgr = {}

EmbeddedMapMgr.DEFAULT_EMAP_WIDTH = 640             --地图默认宽度
EmbeddedMapMgr.DEFAULT_EMAP_HEIGHT = 400            --地图默认高度
EmbeddedMapMgr.MAP_CLIP_OPTION = false              --是否开启地图裁剪

EmbeddedMapMgr.DEFAULT_SPEED = 250                  --人物移动速度(pix/s)
EmbeddedMapMgr.DEFAULT_PET_DISTANCE = 130           --宠物距离主人的距离

EmbeddedMapMgr.SPINE_POSY = 60
EmbeddedMapMgr.MOVE_POSY_DIFF = 60
EmbeddedMapMgr.NPC_MAXNUM = 1

local parent = nil
local parentPosY = 0
local mapTbl = {}
local mapParamTbl = {}
local clipMapTbl = {}
local mapActionTbl = {}
local isLoadingMap = false
local isMoving = false
local mapRes = ""
local petRes = ""
local npcPetRes = {}
local weatherRes = {}
local charTagStr = ""
local charPetTagStr = ""
local npcTagStr = ""
local npcPetTagStr = ""
local eventResPet = ""
local eventResGift = ""
local eventTag = ""
local eventTagA = ""
local eventTagB = ""
local eventTagC = ""

local mapPosx = 0
local mapPosy = 0
local mapInitFunc = nil
local mapCommonRes = ""
local mapCommonBackRes = ""
local curWeatherType = 1

function EmbeddedMapMgr.Init()
    print("EmbeddedMapMgr初始化")
    
    parent = nil
    parentPosY = 0
    mapTbl = {}
    mapParamTbl = {}
    clipMapTbl = {}
    mapActionTbl = {}
    isLoadingMap = false
    isMoving = false
    mapRes = ""
    petRes = ""
    npcPetRes = {}
    weatherRes = 
    {
            {"Gaf/weather/cloud.gaf", "Spine/effects/Ui_dadituyangguang.png"},
            {"Gaf/weather/cloud.gaf", "Gaf/weather/rain.plist"},
            {"Gaf/weather/cloud.gaf", "Gaf/weather/snow1.plist", "Gaf/weather/snow2.plist"},
            {"Gaf/weather/cloud.gaf", "Gaf/weather/mao.plist"},
    }
    charTagStr = PlayerAnimeMgr.SELF_TAG_STRING
    charPetTagStr = PlayerAnimeMgr.SELF_TAG_STRING.."-pet"
    npcTagStr = PlayerAnimeMgr.SELF_TAG_STRING.."-NPC"
    npcPetTagStr = PlayerAnimeMgr.SELF_TAG_STRING.."-NPC's pet"
    eventResPet = ""
    eventResGift = ""
    eventTag = "EmbeddedMapMgr.addEvent"
    eventTagA = eventTag.."-A"
    eventTagB = eventTag.."-B"
    eventTagC = eventTag.."-C"
    
    mapPosx = 0
    mapPosy = 0
    mapInitFunc = nil
    mapCommonRes = "Map/EmbeddedMap/default.csb"
    mapCommonBackRes = "Map/EmbeddedMap/default_back.csb"
    curWeatherType = 1
end

function EmbeddedMapMgr.getMapResByID(id)
    if id then
        return "Map/EmbeddedMap/map_"..id..".png"
    end
    return mapRes
end

function EmbeddedMapMgr.show(scene)
    TownMapMgr.setPetScale(0.5)

    mapRes = EmbeddedMapMgr.getMapResByID(WorldMapMgr.getCurEmbeddedMapID() or 1)
    petRes = PokemonInfo.getFollowPokemonRes()
	
    isMoving = false
    isLoadingMap = false
    
    parent = display.newSprite("empty.png")
    parent:addTo(scene)
    parent:setLocalZOrder(CocosModuleMgr.ZORDER_CHARACTOR)
    CocosModuleMgr.setRelativePosition(parent, 320, 480)
    CocosModuleMgr.setEdgeDistance(parent, nil, nil, nil, 0, false)
    parentPosY = parent:getPositionY()+EmbeddedMapMgr.MOVE_POSY_DIFF
    parent:setPositionY(parentPosY)
	
    function mapInitFunc(resName, useCoroutine)
        mapTbl = {}
        mapParamTbl = {}
        clipMapTbl = {}
        
	    local funcTbl = {}
	    
	    local function initMap(resName, tag, i, csbRes)
            local mapobj = CSResourceMgr.createRes(nil, csbRes, tag)
            CSResourceMgr.setSpriteTexture(csbRes, "default", resName, tag, false)
            --CSResourceMgr.getNodeByName(mapCommonRes, "default", tag):setColor({r=111,g=111,b=111})
            mapTbl[i] = mapobj
            
            if mapobj then
                local var = mapobj
                local key = i
                var:setPosition(-var:getContentSize().width/2, 0)
                local oringinPosx = var:getPositionX()
                local oringinPosy = var:getPositionY()
                mapPosx = var:getPositionX()
                if key%2==0 then
                    local size = CSResourceMgr.getNodeByName(csbRes, "default", tag):getContentSize()
                    local posx = var:getPositionX()
                    var:setPositionX(posx+size.width)
                end
                
                local clip = nil
                if EmbeddedMapMgr.MAP_CLIP_OPTION then
                    clip = CocosModuleMgr.maskSprite(parent, var, "Map/EmbeddedMap/map_mask.png", {x=oringinPosx, y=oringinPosy})
                else
                    clip = var
                    var:addTo(parent)
                end
                
                if key==3 or key==4 then
                    --动画
                    --local arrowAniLeft = AnimationMgr.createAni(mapobj, "Spine/effects/maparrow.png", 320, 200, key)
                    --AnimationMgr.playAni(arrowAniLeft.res, "idle", true, arrowAniLeft.tag)
                    --arrowAniLeft:setScaleX(-1)
                else
                    CSResourceMgr.getNodeByName(csbRes, "block", tag):setVisible(false)
                end
                
                if key<=4 then
                    clip:setLocalZOrder(CocosModuleMgr.ZORDER_MAP_BACK)
                else
                    clip:setLocalZOrder(CocosModuleMgr.ZORDER_MAP_FRONT)
                end
                
                clipMapTbl[key] = clip
                var:setOpacity(0)
            end
	    end
	    
	    mapParamTbl = 
	    {
                {string.gsub(resName, ".png", "_back.png"), resName.."back1", mapCommonBackRes},
                {string.gsub(resName, ".png", "_back.png"), resName.."back2", mapCommonBackRes},
                {resName, resName.."1", mapCommonRes},
                {resName, resName.."2", mapCommonRes},
                {string.gsub(resName, ".png", "_front.png"), resName.."front1", mapCommonRes},
                {string.gsub(resName, ".png", "_front.png"), resName.."front2", mapCommonRes}
        }
        
        for key, var in pairs(mapParamTbl) do
            local function tmpInit()
                initMap(var[1], var[2], key, var[3])
        	end
            table.insert(funcTbl, tmpInit)
        end

        local function setMove()
        	if isMoving then
        		isMoving = false
        		EmbeddedMapMgr.move()
        	end
        end
        table.insert(funcTbl, setMove)
        
        local function fadeIn()
            for key, var in pairs(mapTbl) do
                if var then
                    transition.fadeIn(var, {time=0.5})
                end
        	end
        end
        table.insert(funcTbl, fadeIn)
        
        if useCoroutine then
            UnblockLoader.load(funcTbl, "EmbeddedMapMgr-mapInitFunc")
        else
            for key, var in pairs(funcTbl) do
            	var()
            end
        end
        
	end
	
    mapInitFunc(mapRes)
    
    --天气效果
    curWeatherType = GetRandom.randomWithProbability({80, 20})
    EmbeddedMapMgr.addWeatherEffect(parent, curWeatherType)
    
    --人物宠物动画
    local petGafObj = AnimationMgr.createAni(parent, petRes, -EmbeddedMapMgr.DEFAULT_PET_DISTANCE/2, 
        EmbeddedMapMgr.SPINE_POSY, charPetTagStr)
    local charGafObj = PlayerAnimeMgr.createPlayer(parent, {gender=CharInfo.getSex(), x=EmbeddedMapMgr.DEFAULT_PET_DISTANCE/2, 
        y=EmbeddedMapMgr.SPINE_POSY, skin=CharInfo.getCurfashion()}, charTagStr)
    charGafObj:setScale(1, 1)

    PlayerAnimeMgr.showWorldPKEffect(charGafObj,CharInfo.getVIPLevel())

    petGafObj:setLocalZOrder(CocosModuleMgr.ZORDER_CHARACTOR)
    charGafObj:setLocalZOrder(CocosModuleMgr.ZORDER_CHARACTOR)
    petGafObj:setScale(TownMapMgr.DEFAULT_PET_SCALE, TownMapMgr.DEFAULT_PET_SCALE)
    AnimationMgr.playAni(petRes, "idle", true, charPetTagStr)
    local petid, petskin = PokemonInfo.getFollowPokemonID()
    AnimationMgr.setSkin(petGafObj.res, petskin, petGafObj.tag)
    
    --NPC动画
    EmbeddedMapMgr.checkNPC()
end

function EmbeddedMapMgr.changeAvatar()
    if SceneMgr.currentScene~="MainScene" then
        return
    end
    PlayerAnimeMgr.setPlayerSkins(charTagStr, CharInfo.getCurfashion())
end

function EmbeddedMapMgr.setCharactorPet(pid, skinid)
    if SceneMgr.currentScene~="MainScene" then
        return
    end
    if not AnimationMgr.getGafObj(petRes, charPetTagStr) then
    	return
    end
    AnimationMgr.removeGafObjectByTag(petRes, charPetTagStr)
    petRes = PokemonInfo.getPokemonResByID(pid)
    local petGafObj = AnimationMgr.createAni(parent, petRes, 
        -EmbeddedMapMgr.DEFAULT_PET_DISTANCE/2, EmbeddedMapMgr.SPINE_POSY, charPetTagStr)
    petGafObj:setLocalZOrder(CocosModuleMgr.ZORDER_CHARACTOR)
    petGafObj:setScale(TownMapMgr.DEFAULT_PET_SCALE, TownMapMgr.DEFAULT_PET_SCALE)
    AnimationMgr.playAni(petRes, "idle", true, charPetTagStr)
    AnimationMgr.setSkin(petGafObj.res, skinid, petGafObj.tag)
end

function EmbeddedMapMgr.checkNPC()
    if SceneMgr.currentScene~="MainScene" then
        return
    end
    local lockID = CharInfo.get().maplock
    local npcInfo = WorldMapInfo.getCurNpcInfo(lockID)
    print("EmbeddedMapMgr.checkNPC()", lockID)
    if not npcInfo then
        for var=1, EmbeddedMapMgr.NPC_MAXNUM do
            local eventMoveDiff = 720
            local petGafObj = AnimationMgr.getGafObj(npcPetRes[var], npcPetTagStr..var)
            if petGafObj then
                transition.stopTarget(petGafObj)
                AnimationMgr.playAni(npcPetRes[var], "walk", true, npcPetTagStr..var)
                transition.moveTo(petGafObj, {x=eventMoveDiff, time=2})
                petGafObj:performWithDelay(function()
                    AnimationMgr.removeGafObjectByTag(npcPetRes[var], npcPetTagStr..var)
                end, 2)
            end
            local charGafObj = PlayerAnimeMgr.getPlayer(npcTagStr..var)
            if charGafObj then
                transition.stopTarget(charGafObj)
                PlayerAnimeMgr.playAni(npcTagStr..var, "walk", true)
                transition.moveTo(charGafObj, {x=eventMoveDiff+EmbeddedMapMgr.DEFAULT_PET_DISTANCE, time=2})
                charGafObj:performWithDelay(function()
                    PlayerAnimeMgr.removePlayerByTag(npcTagStr..var, true)
                end, 2)
            end
        end
    	return
    end
    local eventMoveDiff = 270
    local loadFunc = {}
    for var=1, EmbeddedMapMgr.NPC_MAXNUM do
    	if npcInfo["npc"..var] then
            print("EmbeddedMapMgr.checkNPC()", npcInfo["npc"..var], npcInfo["pet"..var])
            table.insert(loadFunc, function()
                if AnimationMgr.getGafObj(npcPetRes[var], npcPetTagStr..var) then
                    return
                    --AnimationMgr.removeGafObjectByTag(npcPetRes[var], npcPetTagStr..var)
                end
                npcPetRes[var] = PokemonInfo.getPokemonResByID(npcInfo["pet"..var])
                local petGafObj = AnimationMgr.createAni(parent, npcPetRes[var], 
                    -(var+1)*EmbeddedMapMgr.DEFAULT_PET_DISTANCE-eventMoveDiff, EmbeddedMapMgr.SPINE_POSY+10, npcPetTagStr..var)
                petGafObj:setLocalZOrder(CocosModuleMgr.ZORDER_PLAYER)
                petGafObj:setScale(TownMapMgr.DEFAULT_PET_SCALE, TownMapMgr.DEFAULT_PET_SCALE)
                AnimationMgr.playAni(npcPetRes[var], "walk", true, npcPetTagStr..var)
                AnimationMgr.setSkin(petGafObj.res, 0, petGafObj.tag)
                transition.moveBy(petGafObj, {x=eventMoveDiff, time=1})
                petGafObj:performWithDelay(function()
                    AnimationMgr.playAni(npcPetRes[var], "idle", true, npcPetTagStr..var)
                end, 1)
            end)
            table.insert(loadFunc, function()
                if PlayerAnimeMgr.getPlayer(npcTagStr..var) then
                    return
                    --PlayerAnimeMgr.removePlayerByTag(npcTagStr..var, true)
                end
                local charGafObj = PlayerAnimeMgr.createPlayer(parent, {x=-var*EmbeddedMapMgr.DEFAULT_PET_DISTANCE-eventMoveDiff, 
                    y=EmbeddedMapMgr.SPINE_POSY+10, skin=npcInfo["npc"..var]}, npcTagStr..var)
                charGafObj:setLocalZOrder(CocosModuleMgr.ZORDER_PLAYER)
                PlayerAnimeMgr.playAni(npcTagStr..var, "walk", true)
                transition.moveBy(charGafObj, {x=eventMoveDiff, time=1})
                charGafObj:performWithDelay(function()
                    PlayerAnimeMgr.playAni(npcTagStr..var, "idle", true)
                end, 1)
            end)
    	end
    end
    UnblockLoader.cancel("EmbeddedMapMgr.checkNPC()")
    UnblockLoader.load(loadFunc, "EmbeddedMapMgr.checkNPC()")
end

function EmbeddedMapMgr.change(mapID)
    EmbeddedMapMgr.removeEvent()
    
    local resName = EmbeddedMapMgr.getMapResByID(mapID)
    if not resName then
    	return
    end
    if resName==mapRes then
    	return
    end
    if isLoadingMap then
    	return
    end
    
    isLoadingMap = true
    UnblockLoader.cancel("EmbeddedMapMgr-mapInitFunc")
    
    local curMapTbl = mapTbl
    for key, var in pairs(curMapTbl) do
        if var then
            local curRes = mapParamTbl[key][1]
            local curTag = mapParamTbl[key][2]
            local curMapNode = var
            transition.fadeOut(curMapNode, {time=1})
            SceneMgr.getRunningScene:performWithDelay(function()
                transition.stopTarget(curMapNode)
                CSResourceMgr.removeCSObjectByTag(curRes, curTag)
                isLoadingMap = false
                --clipMapTbl[key]:removeFromParent(true)
            end, 1)
        end
    end
    
    mapRes = resName
    mapInitFunc(resName, true)
end

function EmbeddedMapMgr.move()
    if isMoving then
    	return
    end
    
    BasicMenuMgr.hide()
    StatusBarMgr.enabledWorldBtn(false)
    
    local function moveDown(node, posy)
        if node then
            transition.moveTo(node, {y=posy-EmbeddedMapMgr.MOVE_POSY_DIFF, time=0.1})
        end
    end
    moveDown(parent, parentPosY)
    
    if PlayerAnimeMgr.getPlayerCurMotionName(charTagStr)~="walk" then
        PlayerAnimeMgr.playAni(charTagStr, "walk", true)
    end
    if AnimationMgr.getGafObjCurMotionName(petRes, charPetTagStr)~="walk" then
        AnimationMgr.playAni(petRes, "walk", true, charPetTagStr)
    end
    for var=1, EmbeddedMapMgr.NPC_MAXNUM do
        if PlayerAnimeMgr.getPlayerCurMotionName(npcTagStr..var)~="walk" then
            PlayerAnimeMgr.playAni(npcTagStr..var, "walk", true)
        end
        if AnimationMgr.getGafObj(npcPetRes[var], npcPetTagStr..var) then
            if AnimationMgr.getGafObjCurMotionName(npcPetRes[var], npcPetTagStr..var)~="walk" then
                AnimationMgr.playAni(npcPetRes[var], "walk", true, npcPetTagStr..var)
            end
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
    
    for key, var in pairs(mapTbl) do
        if var then
        	local size = var:getContentSize()
            local time = size.width/speedTbl[key]
        	local posx = var:getPositionX()
            local posy = var:getPositionY()
            local destin = mapPosx
            if key%2==1 then
                destin = mapPosx-size.width
            end
            local tmptime = math.abs(destin-posx)/speedTbl[key]
            local tmpseq = transition.sequence({
                cc.MoveTo:create(tmptime, cc.p(destin, posy)),
                cc.CallFunc:create(function()
                    var:setPositionX(destin+size.width)
                    local sequence = transition.sequence({
                        cc.MoveBy:create(time, cc.p(-size.width, 0)),
                        cc.CallFunc:create(function()
                            var:setPositionX(destin+size.width)
                        end),
                    })
                    local action = cc.RepeatForever:create(sequence)
                    var:runAction(action)
                    table.insert(mapActionTbl, action)
                end),
            })
            var:runAction(tmpseq)
            table.insert(mapActionTbl, tmpseq)
        end
    end
    isMoving = true
end

function EmbeddedMapMgr.stop()
    if not isMoving then
        return
    end
    
    BasicMenuMgr.show()
    StatusBarMgr.enabledWorldBtn(true)
    
    local function moveUp(node, posy)
        if node then
            transition.moveTo(node, {y=posy, time=0.1})
        end
    end
    moveUp(parent, parentPosY)
    
    if PlayerAnimeMgr.getPlayerCurMotionName(charTagStr)~="idle" then
        PlayerAnimeMgr.playAni(charTagStr, "idle", true)
    end
    if AnimationMgr.getGafObjCurMotionName(petRes, charPetTagStr)~="idle" then
        AnimationMgr.playAni(petRes, "idle", true, charPetTagStr)
    end
    for var=1, EmbeddedMapMgr.NPC_MAXNUM do
        if PlayerAnimeMgr.getPlayerCurMotionName(npcTagStr..var)~="idle" then
            PlayerAnimeMgr.playAni(npcTagStr..var, "idle", true)
        end
        if AnimationMgr.getGafObj(npcPetRes[var], npcPetTagStr..var) then
            if AnimationMgr.getGafObjCurMotionName(npcPetRes[var], npcPetTagStr..var)~="idle" then
                AnimationMgr.playAni(npcPetRes[var], "idle", true, npcPetTagStr..var)
            end
        end
    end

    for key, var in pairs(mapActionTbl) do
        if var then
            transition.removeAction(var)
        end
    end
    
    isMoving = false
end

function EmbeddedMapMgr.removeEvent()
    PlayerAnimeMgr.removePlayerByTag(eventTagA)
    AnimationMgr.removeGafObjectByTag(eventResPet, eventTagB)
    eventResPet = ""
    CSResourceMgr.removeCSObjectByTag(eventResGift, eventTagC)
    eventResGift = ""

    --[[
    local fadeOutTime = 0.3
    
    local objA = PlayerAnimeMgr.getPlayer(eventTagA)
    if objA then
        transition.fadeOut(objA, {time=fadeOutTime})
        objA:performWithDelay(function()
            PlayerAnimeMgr.removePlayerByTag(eventTagA)
            eventResA = ""
        end, fadeOutTime)
    end
    
    local objB = AnimationMgr.getGafObj(eventResPet, eventTagB)
    if objB then
        transition.fadeOut(objB, {time=fadeOutTime})
        objB:performWithDelay(function()
            AnimationMgr.removeGafObjectByTag(eventResPet, eventTagB)
            eventResPet = ""
        end, fadeOutTime)
    end
    
    local objC = CSResourceMgr.getCsbObj(eventResGift, eventTagC)
    if objC then
        transition.fadeOut(objC, {time=fadeOutTime})
        objC:performWithDelay(function()
            CSResourceMgr.removeCSObjectByTag(eventResGift, eventTagC)
            eventResGift = ""
        end, fadeOutTime)
    end
    --]] 
end

function EmbeddedMapMgr.addEvent(params)
    local tag = eventTag
    local tagA = eventTagA
    local tagB = eventTagB
    local tagC = eventTagC
    local eventMoveDiff = 270
    
    local completeFunc = params.battleCallback
    if params.mapid and params.pid then
        completeFunc = function(detail)
            print("Map Event Result:", detail.result)
            local function sendMsg()
                if params.mtype then
                    print("通关节点", params.mapid, params.pid)
                    --[[
                    QuestInfo.sendQuestUpdate(params.mtype, 1, function()
                        QuestInfo.sendQuestFinished(params.mtype, true)
                    end)]]
                    QuestInfo.sendQuestUpdate(params.mtype, 1)
                else
                    NetInterface.sendWithBlock("GC_TriggerNodeEvent_Ack", function()
                        local AdventureSend = require("src.Net.Send.AdventureSend")
                        AdventureSend.sendCG_TriggerNodeEvent_Req({mapid=params.mapid, pid=params.pid})
                    end, function()
                        print("随机事件结算完成 id:", params.mapid, params.pid)
                        AdventureInfo.removeMapEventInfo(params.mapid, params.pid)
                    end, function(code)
                        print("随机事件结算失败 code:", code, "id:", params.mapid, params.pid)
                        TipsMgr.showError(nil, code)
                        AdventureInfo.removeMapEventInfo(params.mapid, params.pid)
                    end)
                end
            end
            if detail.result==PLAYER_WIN then
                BattleMapMgr.sendGameOver(detail.result, detail.me)
                --[[
                MapSeekerMgr.setSeekFunc(function()
                    sendMsg()
                end)]]
                sendMsg()
            elseif detail.result==998 then
                sendMsg()
            end
    	end
    else
        if params.isFamilyQuest then
            completeFunc = function(detail)
                if detail.result==PLAYER_WIN then
                    BattleMapMgr.sendGameOver(detail.result, detail.me)
                end
            end
        end
    end
    if params.param then
        params.param = tonumber(params.param)
    end
    
	if params.type==1 then
	    local ManInfo = AdventureInfo.getMonsterGroupManInfoByID(params.param)
        local playerPetID = ManInfo.pokemons[1]
        local skinInfo = ManInfo.figure
        eventResPet = PokemonInfo.getPokemonResByID(AdventureInfo.getMonstrosityInfoByID(playerPetID).petnumber)
        local BtnRes = "Charactor/PressButton.csb"
        if not AnimationMgr.getGafObj(eventResPet, tagB) then
            local eventGafObjA = PlayerAnimeMgr.createPlayer(parent, 
                {x=EmbeddedMapMgr.DEFAULT_EMAP_WIDTH/2+EmbeddedMapMgr.DEFAULT_PET_DISTANCE, 
                    y=EmbeddedMapMgr.SPINE_POSY, skin=skinInfo}, tagA)
            local eventGafObjB = AnimationMgr.createAni(parent, eventResPet, 
                EmbeddedMapMgr.DEFAULT_EMAP_WIDTH/2+EmbeddedMapMgr.DEFAULT_PET_DISTANCE*2, 
                EmbeddedMapMgr.SPINE_POSY, tagB)
            eventGafObjA:setLocalZOrder(CocosModuleMgr.ZORDER_CHARACTOR)
            eventGafObjB:setLocalZOrder(CocosModuleMgr.ZORDER_CHARACTOR)
            eventGafObjA:setScaleX(-1)
            eventGafObjB:setScale(-TownMapMgr.DEFAULT_PET_SCALE, TownMapMgr.DEFAULT_PET_SCALE)
            PlayerAnimeMgr.playAni(tagA, "walk", true)
            AnimationMgr.playAni(eventResPet, "walk", true, tagB)
            transition.moveBy(eventGafObjA, {x=-eventMoveDiff, time=1})
            transition.moveBy(eventGafObjB, {x=-eventMoveDiff, time=1})
            eventGafObjA:performWithDelay(function()
                PlayerAnimeMgr.playAni(tagA,  "idle", true)
            end, 1)
            eventGafObjB:performWithDelay(function()
                AnimationMgr.playAni(eventResPet, "idle", true, tagB)
            end, 1)
            AnimationMgr.setSkin(eventGafObjB.res, params.skin, eventGafObjB.tag)
            local PressButton = CSResourceMgr.createRes(eventGafObjA, BtnRes, tag)
            PressButton:setAnchorPoint(0.5, 0)
            PressButton:setPosition(0, 40)
            PressButton:setLocalZOrder(10)
            CocosModuleMgr.showMood(PressButton, params.emoji, -120, 60, false)
            CSResourceMgr.clickEventBinding(BtnRes, "PressButton", function()
                --[[
                eventGafObjA:setScaleX(1)
                eventGafObjB:setScaleX(TownMapMgr.DEFAULT_PET_SCALE)
                PlayerAnimeMgr.playAni(tagA,  "walk", true)
                AnimationMgr.playAni(eventResPet, "walk", true, tagB)
                transition.moveBy(eventGafObjA, {x=eventMoveDiff, time=1})
                transition.moveBy(eventGafObjB, {x=eventMoveDiff, time=1})
                CSResourceMgr.setButtonEnabled(BtnRes, "PressButton", false, tag)]]
                
                local nameInfo = ManInfo.name
                local figureInfo = ManInfo.seniorFigure
                local type = nil
                if params.isFamilyQuest then
                    type = Proto.BTT_FAMILYQUEST_ARREST
                    print("偶遇家族通缉犯id", params.param, skinInfo)
                else
                    type = Proto.BTT_MONSTER_MAN_GROUP
                    print("偶遇训练家id", params.param, skinInfo)
                end
                BattleMapMgr.sendReBattleServe({true, {name = nameInfo, GroupID = params.param,
                    type = type, seniorFigure = figureInfo, callback = completeFunc, battleTypeSubID = params.index, 
                    field = WorldMapMgr.getCurEmbeddedMapID()}})
            end, tag)
            GameAudio.playUISound("actbattleMeet")
        end
        return CSResourceMgr.getNodeByName(BtnRes, "PressButton", tag)
	elseif params.type==2 then
        eventResPet = PokemonInfo.getPokemonResByID(AdventureInfo.getMonstrosityInfoByID(params.param).petnumber)
        local BtnRes = "Charactor/PressButton.csb"
        if not AnimationMgr.getGafObj(eventResPet, tagB) then
            local eventGafObjA = AnimationMgr.createAni(parent, eventResPet, 
                EmbeddedMapMgr.DEFAULT_EMAP_WIDTH/2+EmbeddedMapMgr.DEFAULT_PET_DISTANCE, 
                EmbeddedMapMgr.SPINE_POSY, tagB)
            eventGafObjA:setLocalZOrder(CocosModuleMgr.ZORDER_CHARACTOR)
            eventGafObjA:setScale(-TownMapMgr.DEFAULT_PET_SCALE, TownMapMgr.DEFAULT_PET_SCALE)
            AnimationMgr.playAni(eventResPet, "walk", true, tagB)
            transition.moveBy(eventGafObjA, {x=-eventMoveDiff, time=1})
            eventGafObjA:performWithDelay(function()
                AnimationMgr.playAni(eventResPet, "idle", true, tagB)
            end, 1)
            AnimationMgr.setSkin(eventGafObjA.res, params.skin, eventGafObjA.tag)
            local PressButton = CSResourceMgr.createRes(eventGafObjA, BtnRes, tag)
            PressButton:setAnchorPoint(0.5, 0)
            PressButton:setPosition(0, 0)
            PressButton:setScale(1/TownMapMgr.DEFAULT_PET_SCALE, 1/TownMapMgr.DEFAULT_PET_SCALE)
            PressButton:setLocalZOrder(10)
            CocosModuleMgr.showMood(PressButton, params.emoji, -100, 100, false)
            CSResourceMgr.clickEventBinding(BtnRes, "PressButton", function()
                --[[
                eventGafObjA:setScaleX(TownMapMgr.DEFAULT_PET_SCALE)
                AnimationMgr.playAni(eventResPet, "walk", true, tagB)
                transition.moveBy(eventGafObjA, {x=eventMoveDiff, time=1})
                CSResourceMgr.setButtonEnabled(BtnRes, "PressButton", false, tag)]]
                
                local type = nil
                if params.isFamilyQuest then
                    type = Proto.BTT_FAMILYQUEST_MONSTER
                    print("偶遇家族珍兽id", params.param)
                else
                    type = Proto.BTT_MONSTER
                    print("偶遇野怪id", params.param)
                end
                BattleMapMgr.sendReBattleServe({false, {name = "野生", battleTypeSubID = params.index,  
                    pets = {params.param}, type = type, seniorFigure = -1, callback = completeFunc, 
                    field = WorldMapMgr.getCurEmbeddedMapID()}})
            end, tag, nil, "mapchange2")
            GameAudio.playUISound("actbattleMeet")
        end
        return CSResourceMgr.getNodeByName(BtnRes, "PressButton", tag)
	elseif params.type==3 or params.type==4 then
        eventResGift = "Map/EmbeddedMap/EventObjects/gift_01.csb"
        local btnName = string.gsub(string.gsub(eventResGift, ".csb", ""), "Map/EmbeddedMap/EventObjects/", "")
        if not CSResourceMgr.getCsbObj(eventResGift, tagC) then
            local eventCsbObjA = CSResourceMgr.createRes(parent, eventResGift, tagC)
            eventCsbObjA:setAnchorPoint(0.5, 0.5)
            eventCsbObjA:setPosition(EmbeddedMapMgr.DEFAULT_EMAP_WIDTH/2+EmbeddedMapMgr.DEFAULT_PET_DISTANCE-eventMoveDiff, 
                EmbeddedMapMgr.SPINE_POSY+27)
            eventCsbObjA:setLocalZOrder(CocosModuleMgr.ZORDER_CHARACTOR)
            --CocosModuleMgr.showShiningToNode(eventCsbObjA, 1)
            if params.type==4 then
                local iconRes = ItemInfo.getItemInfoById(params.param).icon
                CSResourceMgr.setButtonTexture(eventResGift, btnName, iconRes, iconRes, iconRes, tagC)
            end
            CocosModuleMgr.showMood(eventCsbObjA, params.emoji, 180, 60, false):setScale(-1, 1)
            CSResourceMgr.playActionWithCallback(eventResGift, 0, 15, 1, function()
                CSResourceMgr.playAction(eventResGift, 30, 60, true, tagC)
            end, tagC)
            CSResourceMgr.clickEventBinding(eventResGift, btnName, function()
                transition.fadeOut(eventCsbObjA, {time=1})
                CSResourceMgr.setButtonEnabled(eventResGift, btnName, false, tagC)
                
                completeFunc({result=998})
            end, tagC, true)
            GameAudio.playUISound("eventMeet")
        end
        return CSResourceMgr.getNodeByName(eventResGift, btnName, tagC)
	end
end

function EmbeddedMapMgr.addWeatherEffect(pointNode, weatherType, tag, scale)
    weatherType = weatherType or curWeatherType
    tag = tag or ""
    scale = scale or 1
    local function addWeather(res, zorder)
        local gafObj = AnimationMgr.createAni(pointNode, res, 0, 0, tag)
        AnimationMgr.playAni(res, "idle", true, tag)
        gafObj:setLocalZOrder(zorder)
        gafObj:setContentSize(640, 400)
        gafObj:setPosition(0, 600*scale)
        gafObj:scale(scale)
        return gafObj
    end
    local function addWeatherSpine(res, zorder)
        local spObj = AnimationMgr.createAni(pointNode, res, -320*scale, 0, tag)
        AnimationMgr.playAni(res, "animation", true, tag)
        spObj:setLocalZOrder(zorder)
        spObj:scale(scale)
        return spObj
    end
    local function addWeatherParticle(res, zorder)
        local particle = CSResourceMgr.createParticle(pointNode, res, 0, 400*scale, tag)
        particle:setLocalZOrder(zorder)
        particle:scale(scale)
        return particle
    end
    if weatherType==1 then
        addWeather(weatherRes[weatherType][1], CocosModuleMgr.ZORDER_WORLDMAP)
        addWeatherSpine(weatherRes[weatherType][2], CocosModuleMgr.ZORDER_BOARD)
    elseif weatherType==2 then
        addWeather(weatherRes[weatherType][1], CocosModuleMgr.ZORDER_WORLDMAP)
        addWeatherParticle(weatherRes[weatherType][2], CocosModuleMgr.ZORDER_BOARD)
    elseif weatherType==3 then
        addWeather(weatherRes[weatherType][1], CocosModuleMgr.ZORDER_WORLDMAP)
        addWeatherParticle(weatherRes[weatherType][2], CocosModuleMgr.ZORDER_BOARD)
        addWeatherParticle(weatherRes[weatherType][3], CocosModuleMgr.ZORDER_BOARD)
    elseif weatherType==4 then
        addWeather(weatherRes[weatherType][1], CocosModuleMgr.ZORDER_WORLDMAP)
        addWeatherParticle(weatherRes[weatherType][2], CocosModuleMgr.ZORDER_BOARD)
    end    
end

function EmbeddedMapMgr.removeWeatherEffect(weatherType, tag)
    weatherType = weatherType or curWeatherType
    tag = tag or ""
    if weatherType==1 then
        AnimationMgr.removeGafObjectByTag(weatherRes[weatherType][1], tag)
        AnimationMgr.removeGafObjectByTag(weatherRes[weatherType][2], tag)
    elseif weatherType==2 then
        AnimationMgr.removeGafObjectByTag(weatherRes[weatherType][1], tag)
        CSResourceMgr.removeParticle(weatherRes[weatherType][2], tag)
    elseif weatherType==3 then
        AnimationMgr.removeGafObjectByTag(weatherRes[weatherType][1], tag)
        CSResourceMgr.removeParticle(weatherRes[weatherType][2], tag)
        CSResourceMgr.removeParticle(weatherRes[weatherType][3], tag)
    elseif weatherType==4 then
        AnimationMgr.removeGafObjectByTag(weatherRes[weatherType][1], tag)
        CSResourceMgr.removeParticle(weatherRes[weatherType][2], tag)
    end  
end

function EmbeddedMapMgr.setVisible(val)
    if SceneMgr.currentScene~="MainScene" then
        return
    end
    local ret, errMessage = pcall(function()
        parent:setVisible(val)
    end)
end

return EmbeddedMapMgr