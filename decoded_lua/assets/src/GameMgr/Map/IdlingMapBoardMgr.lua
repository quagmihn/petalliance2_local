local IdlingMapBoardMgr = {}

IdlingMapBoardMgr.SELMAX_NUM = 6
IdlingMapBoardMgr.RANK_NUM = 6
IdlingMapBoardMgr.PETPOS_DIFF = 105

local resName = ""
local resNameBG = ""
local resNameA = ""
local resNameB = ""
local resNameC = ""
local resNameD = ""
local mapResPathex = ""

local selInfo = {}
local petInfo = {}
local petNode = {}
local petListNode = {}

local mapAttr = 1
local expVec = {}
local goldVec = {}
local levelVec = {}

function IdlingMapBoardMgr.Init()
    print("IdlingMapBoardMgr初始化")
    
    resName = "Map/IdlingMap/SelectUI.csb"
    resNameBG = "Map/IdlingMap/SelectBG.csb"
    resNameA = "Map/IdlingMap/SelectUIA.csb"
    resNameB = "Map/IdlingMap/SelectUIB.csb"
    resNameC = "Map/IdlingMap/SelectUIC.csb"
    resNameD = "Map/IdlingMap/SelectUID.csb"
    mapResPathex = "Map/IdlingMap/"
    
    selInfo = {}
    petInfo = {}
    petListNode = {}
    
    mapAttr = 1
    expVec = {}
    goldVec = {}
    levelVec = {}
end

function IdlingMapBoardMgr.show(scene, id)
    if ExploreInfo.get(id).petObjIDs then
        IdlingMapBoardMgr.enterIdlingScene(id)
        return
    end
    
    mapAttr = ExploreInfo.get(id).needAttr
    
    selInfo = {selType=-1, selId=id, selPet={}, selNum=0, selPetInfo={}, endTime=0}
    selInfo.selPet = {nil, nil, nil, nil, nil, nil}
    petNode = {nil, nil, nil, nil, nil, nil}
    petListNode = {}
    if NetInterface.isConnect then
        petInfo = PokemonInfo.getExplorePets()
    end
    local posyDiff = 0
    
    local function loadBG()
        local bgLayer = CSResourceMgr.createRes(scene, resNameBG)
        bgLayer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resNameBG, 320, 480)
        bgLayer:setOpacity(0)
        transition.fadeIn(bgLayer, {time=0.5})
    end
    
    local function loadCSBA()
        local layerA = CSResourceMgr.createRes(scene, resNameA)
        layerA:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        --CSResourceMgr.setFullScreen(resNameA)
        CSResourceMgr.setRelativePosition(resNameA, 320, 480)
        local posy1 = layerA:getPositionY()
        CocosModuleMgr.setEdgeDistance(layerA, nil, nil, nil, 0)
        local posy2 = layerA:getPositionY()
        posyDiff = posy2-posy1
        
        CSResourceMgr.setLabelString(resNameA, "bb4title", "idling18", "", {r=153,g=0,b=0,a=255})
        CSResourceMgr.setLabelString(resNameA, "seltitlelbl", "idling17", "", {r=102,g=0,b=0,a=255})
        CSResourceMgr.setLabelColor(resNameA, "bb4title", {r=254,g=254,b=203,a=255})
        
        expVec = SystemInfo.getGlobalConfigAddInfoByID(11001).values
        goldVec = SystemInfo.getGlobalConfigAddInfoByID(11022).values
        levelVec = SystemInfo.getGlobalConfigAddInfoByID(11018).values
        local hourVec = SystemInfo.getGlobalConfigAddInfoByID(11100).values
        local bossVec = {}
        
        --local mapAttrIndex = ExploreInfo.get(id).needAttrIndex+1
        local floorID = ExploreInfo.getDiffcult(id)
        local tmpDFuncVec = {}
        local tmpSender = nil
        local floorNum = #expVec
        local floorBossID = nil
        if floorID%2==1 then
            floorBossID = math.ceil(floorID/2)+1
            bossVec = SystemInfo.getGlobalConfigAddInfoByID(11023+floorBossID).values
        end
        for var=1, floorNum do
            local tmpDFunc = function()
                local floorBtn = CSResourceMgr.getNodeByName(resNameA, "dbf")
                local list = CSResourceMgr.getNodeByName(resNameA, "diflist")
                if var>1 then
                    floorBtn = CSResourceMgr.getNodeByName(resNameA, "dbf"):clone()
                    list:pushBackCustomItem(floorBtn)
                    list:performWithDelay(function()
                        list:jumpToTop()
                    end, 0.1)
                end
                CSResourceMgr.setButtonStringByNode(floorBtn, CocosModuleMgr.createStringWithFormat({"idling21", var, hourVec[var]}),
                     {r=0,g=0,b=0,a=255})
                CSResourceMgr.clickEventBindingByNode(floorBtn, function(sender)
                    if selInfo.selType~=-1 then
                        if tmpSender then
                            CSResourceMgr.setButtonEnabledByNode(tmpSender, true)
                        end
                        selInfo.selType = -1
                    end
                    if var==floorBossID then
                        --挑战守关Boss
                        --print("挑战守关Boss id:", bossVec[mapAttrIndex])
                        local function callFunc(detail)
                            BattleMapMgr.sendGameOver(detail.result,detail.me)
                        end
                        DialogBoxMgr.showSmallDialogBox(scene, 2, CocosModuleMgr.createStringWithFormat({"idling3", var}), function()
                            BattleMapMgr.sendReBattleServe({false, {name="野生", type=Proto.BTT_EXPLORE_DIFFCULT_UNLOCK, 
                                attr=mapAttr,callback = callFunc}})
                        end)
                    else
                        selInfo.selType = var-1
                        CSResourceMgr.setButtonEnabledByNode(sender, false)
                        tmpSender = sender
                        IdlingMapBoardMgr.awardsCal()
                    end
                end)
                if var==floorBossID then
                    local lockSp = CSResourceMgr.seekNodeByName(floorBtn, "dblock")
                    lockSp:setVisible(true)
                    CSResourceMgr.setSpriteTextureByNode(lockSp, "Map/IdlingMap/gj_boss.png")
                end
                if var>math.ceil(floorID/2)+1 then
                    local lockRes = "Map/IdlingMap/gj_weijiesuo.png"
                    CSResourceMgr.setButtonTextureByNode(floorBtn, lockRes, lockRes, lockRes)
                    CSResourceMgr.setButtonEnabledByNode(floorBtn, false)
                    CSResourceMgr.seekNodeByName(floorBtn, "dblock"):setVisible(true)
                end
            end
            table.insert(tmpDFuncVec, tmpDFunc)
        end
        UnblockLoader.load(tmpDFuncVec, "IdlingMapBoardMgr-loadCSBA")
        
        CSResourceMgr.clickEventBinding(resNameA, "bb4", function()
            if selInfo.selType==-1 then
                DialogBoxMgr.showSmallDialogBox(scene, 1, "idling1", nil, nil)
                return
            end
            if selInfo.selNum<=0 then
                DialogBoxMgr.showSmallDialogBox(scene, 1, "idling11", nil, nil)
                return
            end
            local petObjIDs = {}
            selInfo.selPetInfo = {}

            for var=1, IdlingMapBoardMgr.SELMAX_NUM do
                if selInfo.selPet[var] then
                    selInfo.selPetInfo[var] = petInfo[selInfo.selPet[var]]
                    petObjIDs[var] = petInfo[selInfo.selPet[var]].objID
                    if petInfo[selInfo.selPet[var]].level<levelVec[selInfo.selType+1] then
                        DialogBoxMgr.showSmallDialogBox(scene, 1, CocosModuleMgr.createStringWithFormat({
                            "idling22", selInfo.selType+1, levelVec[selInfo.selType+1]}))
                        return
                    end
                end
            end

            IdlingMapMgr.setPetInfo(selInfo)

            --发送探索请求
            if NetInterface.isConnect then
                NetInterface.sendWithBlock("GC_Explore_Ack", function()
                    local ExploreSend = require("src.Net.Send.ExploreSend")
                    print("发送探索请求\n坑位", selInfo.selId)
                    print("难度", selInfo.selType)
                    print("选项", "0")
                    print("宠物数量", #petObjIDs)
                    ExploreSend.sendCG_Explore_Req({
                        exploreIndex = selInfo.selId,
                        difficulty = selInfo.selType,
                        option = 0,
                        petObjIDs = petObjIDs,
                    })
                end, function()
                    IdlingMapBoardMgr.enterIdlingScene(id)
                end, function(code)
                    TipsMgr.showError(scene, code)
                end)
            else
                SceneMgr.replaceScene(scene, "IdlingMapScene", "_battle")
            end
        end)
        
        layerA:setOpacity(0)
        transition.fadeIn(layerA, {time=0.5})
    end
    
    local function loadCSBB()
        local layerB = CSResourceMgr.createRes(scene, resNameB)
        layerB:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        --CSResourceMgr.setFullScreen(resNameB)
        CSResourceMgr.setRelativePosition(resNameB, 320, 480)
        local posyB = layerB:getPositionY()
        layerB:setPositionY(posyB+posyDiff)
        
        --根据屏幕分辨率设置列表高度
        local list = CSResourceMgr.getNodeByName(resNameB, "list")
        local listdb = CSResourceMgr.getNodeByName(resNameB, "db1")
        local lsize = list:getInnerContainerSize()
        local lbsize = listdb:getContentSize()
        local hdiff = CocosModuleMgr.getScreenSizeDiff()
        local dbposy = listdb:getPositionY()
        listdb:setContentSize({width=lbsize.width, height=lbsize.height+hdiff})
        list:setContentSize({width=lsize.width, height=lsize.height+hdiff-20})
        
        layerB:setOpacity(0)
        transition.fadeIn(layerB, {time=0.5})
    end
    
    local function loadCSBC()
        local layerC = CSResourceMgr.createRes(scene, resNameC)
        layerC:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        --CSResourceMgr.setFullScreen(resNameC)
        CSResourceMgr.setRelativePosition(resNameC, 320, 480)
        CocosModuleMgr.setEdgeDistance(layerC, nil, nil, 0, nil)
        
        CSResourceMgr.setLabelString(resNameC, "exp", "0", "", CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
        CSResourceMgr.setLabelString(resNameC, "gold", "0", "", CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
        CSResourceMgr.setLabelString(resNameC, "idlename", ExploreInfo.getExploreInfoDataByID(mapAttr).name, "", {r=153,g=0,b=0,a=255})
        CSResourceMgr.setLabelString(resNameC, "b2title", "idling8", "", {r=0,g=0,b=0,a=255})
        CSResourceMgr.setLabelString(resNameC, "closetitle", "idling13", "", {r=0,g=0,b=0,a=255})
        CSResourceMgr.setLabelString(resNameC, "selnum", 
            CocosModuleMgr.createStringWithFormat({"<1>/<2>", selInfo.selNum, IdlingMapBoardMgr.SELMAX_NUM}), 
            "", CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
        CSResourceMgr.setLabelString(resNameC, "timeinfo", "05:00:00", "", CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
        CSResourceMgr.setLabelString(resNameC, "expinfo", CocosModuleMgr.createStringWithFormat({"idling10", "0"}), 
            "", CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
        CSResourceMgr.setLabelColor(resNameC, "idlename", {r=254,g=254,b=203,a=255})
        CSResourceMgr.setSpriteTexture(resNameC, "idleattr", "Pet/AttriIcon/"..mapAttr..".png")
        
        if ExploreInfo.getExploreInfoDataByID(mapAttr).mapb then
            CSResourceMgr.setSpriteTexture(resNameC, "map1", mapResPathex..ExploreInfo.getExploreInfoDataByID(mapAttr).mapb)
        end
        if ExploreInfo.getExploreInfoDataByID(mapAttr).map then
            CSResourceMgr.setSpriteTexture(resNameC, "map2", mapResPathex..ExploreInfo.getExploreInfoDataByID(mapAttr).map)
        end
        if ExploreInfo.getExploreInfoDataByID(mapAttr).mapf then
            CSResourceMgr.setSpriteTexture(resNameC, "map3", mapResPathex..ExploreInfo.getExploreInfoDataByID(mapAttr).mapf)
        end
        
        CSResourceMgr.clickEventBinding(resNameC, "close", function()
            IdlingMapBoardMgr.hide()
        end, "", true)
        CSResourceMgr.clickEventBinding(resNameC, "b2", function()
            TipsMgr.show(scene, "兑换被点击")
        end, "", true)
        
        layerC:setOpacity(0)
        transition.fadeIn(layerC, {time=0.5})
    end
    
    local function loadCSBD()
        local layerD = CSResourceMgr.createRes(scene, resNameD)
        layerD:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        --CSResourceMgr.setFullScreen(resNameD)
        CSResourceMgr.setRelativePosition(resNameD, 320, 480)
        CocosModuleMgr.setEdgeDistance(layerD, nil, nil, 0, nil)
        
        local curPetPos = {x=0, y=0}
        for var=1, IdlingMapBoardMgr.SELMAX_NUM do
            local cancelFunc = function()
                if not petNode[var] then
                    return
                end             
                local exchangePetID = 0
                petNode[var]:setLocalZOrder(0)
                local tmpPosx = petNode[var]:getPositionX()
                local tmpPosy = petNode[var]:getPositionY()
                if tmpPosy<-120 then
                    local selID = selInfo.selPet[var]
                    selInfo.selPet[var] = nil
                    IdlingMapBoardMgr.disselectPet(selID)
                    CSResourceMgr.seekNodeByName(petListNode[selID], "sel"):setVisible(false)
                    return
                end
                if tmpPosx>=0 and tmpPosx<=IdlingMapBoardMgr.PETPOS_DIFF then
                    exchangePetID = 6
                elseif tmpPosx>=IdlingMapBoardMgr.PETPOS_DIFF and tmpPosx<=IdlingMapBoardMgr.PETPOS_DIFF*2 then
                    exchangePetID = 5
                elseif tmpPosx>=IdlingMapBoardMgr.PETPOS_DIFF*2 and tmpPosx<=IdlingMapBoardMgr.PETPOS_DIFF*3 then
                    exchangePetID = 4
                elseif tmpPosx>=IdlingMapBoardMgr.PETPOS_DIFF*3 and tmpPosx<=IdlingMapBoardMgr.PETPOS_DIFF*4 then
                    exchangePetID = 3
                elseif tmpPosx>=IdlingMapBoardMgr.PETPOS_DIFF*4 and tmpPosx<=IdlingMapBoardMgr.PETPOS_DIFF*5 then
                    exchangePetID = 2
                elseif tmpPosx>=IdlingMapBoardMgr.PETPOS_DIFF*5 and tmpPosx<=IdlingMapBoardMgr.PETPOS_DIFF*6 then
                    exchangePetID = 1
                end
                if exchangePetID==0 or exchangePetID==var or not selInfo.selPet[exchangePetID] then
                    local tmpNode = CSResourceMgr.getNodeByName(resNameD, "ps"..var)
                    local posx = tmpNode:getPositionX()
                    local posy = tmpNode:getPositionY()
                    if petNode[var] then
                        petNode[var]:setPosition(posx, posy)
                    end
                else
                    local tmpNode1 = CSResourceMgr.getNodeByName(resNameD, "ps"..var)
                    local posx1 = tmpNode1:getPositionX()
                    local posy1 = tmpNode1:getPositionY()
                    local tmpNode2 = CSResourceMgr.getNodeByName(resNameD, "ps"..exchangePetID)
                    local posx2 = tmpNode2:getPositionX()
                    local posy2 = tmpNode2:getPositionY()
                    --整理selInfo.selPet
                    local selP1 = selInfo.selPet[var]
                    local selP2 = selInfo.selPet[exchangePetID]
                    selInfo.selPet[var] = selP2
                    selInfo.selPet[exchangePetID] = selP1

                    local attri1 = CSResourceMgr.getNodeByName(resNameD, "pattr"..var)
                    local attriinfo1 = tonumber(PokemonInfo.getPokemonInfoByID(petInfo[selInfo.selPet[var]].pokeID).elementAtt1)
                    CSResourceMgr.setSpriteTextureByNode(attri1, "Pet/AttriIcon/"..attriinfo1..".png")
                    local attri2 = CSResourceMgr.getNodeByName(resNameD, "pattr"..exchangePetID)
                    local attriinfo2 = tonumber(PokemonInfo.getPokemonInfoByID(petInfo[selInfo.selPet[exchangePetID]].pokeID).elementAtt1)
                    CSResourceMgr.setSpriteTextureByNode(attri2, "Pet/AttriIcon/"..attriinfo2..".png")

                    --整理petNode
                    local p1 = petNode[var]
                    local p2 = petNode[exchangePetID]
                    if petNode[var] then
                        transition.moveTo(petNode[var], {x=posx2, y=posy2, time=0.2})
                        --petNode[var]:setPosition(posx2, posy2)
                    end
                    if petNode[exchangePetID] then
                        transition.moveTo(petNode[exchangePetID], {x=posx1, y=posy1, time=0.1})
                        --petNode[exchangePetID]:setPosition(posx1, posy1)
                    end
                    CocosModuleMgr.setScreenTouch(false)
                    SceneMgr.getRunningScene:performWithDelay(function()
                        CocosModuleMgr.setScreenTouch(true)
                    end, 0.2)
                    petNode[exchangePetID] = p1
                    petNode[var] = p2
                end
            end
            CSResourceMgr.buttonEventBinding(resNameD, "pb"..var, function()
                if not petNode[var] then
                    return
                end
                local px = petNode[var]:getPositionX()
                local py = petNode[var]:getPositionY()
                curPetPos = {x=px, y=py}
                petNode[var]:setLocalZOrder(1)
            end, function(sender)
                cancelFunc()
            end, function(sender)
                if not petNode[var] then
                    return
                end
                if sender~=nil then
                    local event = {x = 0, y = 0}
                    local bx = sender:getTouchBeganPosition().x
                    local by = sender:getTouchBeganPosition().y
                    local x = sender:getTouchMovePosition().x
                    local y = sender:getTouchMovePosition().y
                    petNode[var]:setPosition(curPetPos.x-bx+x, curPetPos.y-by+y)
                end
            end, function(sender)
                cancelFunc()
            end)
        end
        
        layerD:setOpacity(0)
        transition.fadeIn(layerD, {time=0.5})
    end
    
    local function loadPet()
        IdlingMapBoardMgr.loadPet()
    end
    local funcTable = {loadBG, loadCSBA, loadCSBB, loadCSBC, loadCSBD, loadPet}

    UnblockLoader.load(funcTable, "IdlingMapBoardMgr")
end

function IdlingMapBoardMgr.hide()
    UnblockLoader.cancel("IdlingMapBoardMgr")
    UnblockLoader.cancel("IdlingMapBoardMgr-loadPet")
    UnblockLoader.cancel("IdlingMapBoardMgr-loadCSBA")
    for var=1, IdlingMapBoardMgr.SELMAX_NUM do
    	if petNode[var] then
            AnimationMgr.removeGafObjectByTag(petNode[var].res, petNode[var].tag)
    	end
    end
    CSResourceMgr.removeCSObjectByTag(resNameBG)
    CSResourceMgr.removeCSObjectByTag(resNameA)
    CSResourceMgr.removeCSObjectByTag(resNameB)
    CSResourceMgr.removeCSObjectByTag(resNameC)
    CSResourceMgr.removeCSObjectByTag(resNameD)
end

function IdlingMapBoardMgr.getSelInfo()
	return selInfo
end

function IdlingMapBoardMgr.loadPet()
    UnblockLoader.cancel("IdlingMapBoardMgr-loadPet")

    local funcTable = {}
    local panelTable = {}
    local list = CSResourceMgr.getNodeByName(resNameB, "list")
    list:removeAllItems()

    for i=1, #petInfo do
        local row = math.ceil(i/IdlingMapBoardMgr.RANK_NUM)
        local rank = i%IdlingMapBoardMgr.RANK_NUM
        if rank==0 then
            rank = IdlingMapBoardMgr.RANK_NUM
        end
        if rank==1 then
            local panel = CSResourceMgr.getNodeByName(resNameB, "panel"):clone()
            table.insert(panelTable, panel)
            list:pushBackCustomItem(panel)
        end
        local cpetInfo = petInfo[i]
        local function petFunc()
            local selID = i            
            local parent = CSResourceMgr.seekNodeByName(panelTable[row], "btn")
            if rank>1 then
                parent = CSResourceMgr.getNodeByName(resNameB, "btn"):clone()
                parent:addTo(panelTable[row])
                parent:setPositionX(103*(rank-1)+55)
            end
            if cpetInfo.star then
                for var=1, tonumber(cpetInfo.star) do
                    local starSp = CSResourceMgr.seekNodeByName(parent, "star"..var)
                    starSp:setVisible(true)
                    starSp:setLocalZOrder(1)
                end
            end
            local level = CSResourceMgr.seekNodeByName(parent, "level")
            CSResourceMgr.setLabelStringByNode(level, "Lv."..cpetInfo.level, {r=0,g=0,b=0,a=255})
            local levelbar = CSResourceMgr.seekNodeByName(parent, "levelbar")
            local rarePoint = PokemonInfo.getPokemonInfoByID(cpetInfo.pokeID).rarePoint
            local preExp = ExperienceInfo.getExperienceInfoByID(cpetInfo.level-1).petExpVec[rarePoint]
            local levelpercent = (cpetInfo.exp-preExp)*100/
                (ExperienceInfo.getExperienceInfoByID(cpetInfo.level).petExpVec[rarePoint]-preExp)
            levelbar:setPercent(levelpercent)
            local sprite = CSResourceMgr.seekNodeByName(parent, "icon")
            sprite:setScale(0.65)
            CSResourceMgr.setSpriteTextureByNode(sprite, PokemonInfo.getPokemonIconByID(cpetInfo.pokeID))
            local attri = CSResourceMgr.seekNodeByName(parent, "attri")
            local attriinfo = tonumber(PokemonInfo.getPokemonInfoByID(cpetInfo.pokeID).elementAtt1)
            CSResourceMgr.setSpriteTextureByNode(attri, "Pet/AttriIcon/"..attriinfo..".png")
            local selFlag = CSResourceMgr.seekNodeByName(parent, "sel")
            CSResourceMgr.clickEventBindingByNode(parent, function()
                local isContained = false
                local isContainedID = 0
                local isFull = true
                local isEmptyID = 0
                for var=1, IdlingMapBoardMgr.SELMAX_NUM do
                    if not selInfo.selPet[var] and isFull then
                        isFull = false
                        isEmptyID = var
                    end
                    if selInfo.selPet[var]==selID then
                        isContained = true
                        isContainedID = var
                    end
                end
                if isContained then
                    selInfo.selPet[isContainedID]=nil
                    IdlingMapBoardMgr.disselectPet(selID)
                    selFlag:setVisible(false)
                else
                    if not isFull then
                        selInfo.selPet[isEmptyID]=selID
                        IdlingMapBoardMgr.selectPet(selID, isEmptyID)
                        selFlag:setVisible(true)
                    else
                        TipsMgr.show(nil, "idling9")
                    end
                end
            end)
            local stage = CSResourceMgr.seekNodeByName(parent, "diban")
            local attridb = CSResourceMgr.seekNodeByName(parent, "attridiban")
            if cpetInfo.Stage then
                local pvec = PokemonInfo.getStagePics(cpetInfo.Stage)
                CSResourceMgr.setSpriteTextureByNode(stage, pvec.p1)
                CSResourceMgr.setSpriteTextureByNode(attridb, pvec.p2)
                if pvec.p3 then
                    local satgeFrame = display.newSprite(pvec.p3)
                    satgeFrame:addTo(stage)
                    satgeFrame:setPosition(stage:getContentSize().width/2, stage:getContentSize().height/2)
                end
            end

            parent:setScale(0, 0)
            transition.scaleTo(parent, {scale = 1, time = 0.2})
            parent:setVisible(true)
            petListNode[i] = parent
            
            if cpetInfo.inExplore==1 then
                CSResourceMgr.setButtonEnabledByNode(parent, false)
                sprite:setColor({r=100,g=100,b=100})
            end
        end
        table.insert(funcTable, petFunc)
    end
    list:performWithDelay(function()
        list:jumpToTop()
    end, 0.1)
    UnblockLoader.load(funcTable, "IdlingMapBoardMgr-loadPet", 0.01)
end

function IdlingMapBoardMgr.selectPet(id, pos)
    if selInfo.selNum>=IdlingMapBoardMgr.SELMAX_NUM then
    	return
    end
    if pos<1 or pos>IdlingMapBoardMgr.SELMAX_NUM then
    	return
    end
    selInfo.selNum = selInfo.selNum+1
    local tmpNode = CSResourceMgr.getNodeByName(resNameD, "ps"..pos)
    local posx = tmpNode:getPositionX()
    local posy = tmpNode:getPositionY()
    local petRes = PokemonInfo.getPokemonResByID(petInfo[id].pokeID)
    local petAni = AnimationMgr.createAni(CSResourceMgr.getNodeByName(resNameD, "db3"), petRes, posx, posy, id)
    AnimationMgr.playAni(petRes, "idle", true, id)
    petAni:setScale(0.5)
    petNode[pos] = petAni
    CSResourceMgr.setLabelString(resNameD, "selnum", 
        CocosModuleMgr.createStringWithFormat({"<1>/<2>", selInfo.selNum, IdlingMapBoardMgr.SELMAX_NUM}), 
        "", CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
    local attri = CSResourceMgr.getNodeByName(resNameD, "pattr"..pos)
    local attriinfo = tonumber(PokemonInfo.getPokemonInfoByID(petInfo[id].pokeID).elementAtt1)
    CSResourceMgr.setSpriteTextureByNode(attri, "Pet/AttriIcon/"..attriinfo..".png")
    IdlingMapBoardMgr.awardsCal()
end

function IdlingMapBoardMgr.disselectPet(id)
    if selInfo.selNum<=0 then
        return
    end
    selInfo.selNum = selInfo.selNum-1
    local petRes = PokemonInfo.getPokemonResByID(petInfo[id].pokeID)
    local isDeleted = false
    local isAnimated = false
    for var=1, IdlingMapBoardMgr.SELMAX_NUM do
        if petNode[var] then
            if isDeleted then
                --整理selInfo.selPet
                selInfo.selPet[var-1] = selInfo.selPet[var]
                selInfo.selPet[var] = nil
                --整理petNode
                petNode[var-1] = petNode[var]
                local posx = petNode[var-1]:getPositionX()
                --petNode[var-1]:setPositionX(posx+IdlingMapBoardMgr.PETPOS_DIFF)
                transition.moveTo(petNode[var-1], {x=posx+IdlingMapBoardMgr.PETPOS_DIFF, time=0.2})
                petNode[var] = nil
                
                local attri = CSResourceMgr.getNodeByName(resNameD, "pattr"..var-1)
                local attriinfo = tonumber(PokemonInfo.getPokemonInfoByID(petInfo[selInfo.selPet[var-1]].pokeID).elementAtt1)
                CSResourceMgr.setSpriteTextureByNode(attri, "Pet/AttriIcon/"..attriinfo..".png")
                CSResourceMgr.setSpriteTextureByNode(CSResourceMgr.getNodeByName(resNameD, "pattr"..var), "empty.png")
            elseif petNode[var].tag==id then
                petNode[var] = nil
                isDeleted = true
                CSResourceMgr.setSpriteTextureByNode(CSResourceMgr.getNodeByName(resNameD, "pattr"..var), "empty.png")
            end
        end
    end
    AnimationMgr.removeGafObjectByTag(petRes, id)
    if isAnimated then
        CocosModuleMgr.setScreenTouch(false)
        SceneMgr.getRunningScene:performWithDelay(function()
            CocosModuleMgr.setScreenTouch(true)
        end, 0.2)
    end
    IdlingMapBoardMgr.awardsCal()
end

function IdlingMapBoardMgr.awardsCal()
    if selInfo.selType==-1 then
    	return
    end
    local basicExpVal = expVec[selInfo.selType+1]
    local basicGoldVal = goldVec[selInfo.selType+1]
    local petAllNum = 0
    local petNum = 0
    for var=1, IdlingMapBoardMgr.SELMAX_NUM do
        if selInfo.selPet[var] then
            local petAttr = PokemonInfo.getPokemonInfoByID(petInfo[selInfo.selPet[var]].pokeID).elementAtt1
            if mapAttr==petAttr then
                petNum = petNum+1
            end
            petAllNum = petAllNum+1
        end
    end
    print("#######IdlingMapBoardMgr.awardsCal", basicExpVal, basicGoldVal, petNum, petAllNum)
    local exp = basicExpVal*petAllNum*(1+petNum/10)
    local gold = basicGoldVal*petAllNum*(1+petNum/10)
    CSResourceMgr.setLabelString(resNameC, "exp", exp)
    CSResourceMgr.setLabelString(resNameC, "gold", gold)
end

function IdlingMapBoardMgr.enterIdlingScene(id)
    local exploreInfo = ExploreInfo.get(id)
    local petVec = {}
    for var=1, #exploreInfo.petObjIDs do
        petVec[var] = PokemonInfo.getPetInfoByObjID(exploreInfo.petObjIDs[var])
    end
    IdlingMapMgr.setPetInfo({selType=exploreInfo.difficulty, selId=id, selPetInfo=petVec, endTime=exploreInfo.endTime})
    SceneMgr.replaceScene(SceneMgr.getRunningScene, "IdlingMapScene", "_battle")
end

return IdlingMapBoardMgr