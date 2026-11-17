local LtPickPetViewMgr = {}

local useUnblockLoader = true

local resName = "LostTower/Menu/PetChangeView.csb"

local currentPet    = 0
local currentSelect = 0

local lastSelectNode = nil

local currType = 0   -- 0 空槽, 1 出战, 2 援助

LtPickPetViewMgr.isShown = false

function LtPickPetViewMgr.Init()
    currentPet    = 0
    currentSelect = 0
    LtPickPetViewMgr.isShown = false
end

--- 设置宠物状态
-- @param pNode node target_node
-- @param type number 0:无状态-- 1:千层塔底栏选中宠物[光圈]-- 2:list中选中宠物[打勾]-- 3:上场-- 4:阵亡--
function LtPickPetViewMgr.setPetStatus(pNode, type)
    if type == 0 then       --无状态
    elseif type == 1 then   --千层塔底栏选中宠物[光圈]
    elseif type == 2 then   --list中选中宠物[打勾]
    elseif type == 3 then   --上场
    elseif type == 4 then   --阵亡
    end
end

--- set current pet
function LtPickPetViewMgr.setCurrentPet(objID, _currType)
    print("~~~~~~~~~~~~  setCurrentPet  ~~~~~~~~~~~",objID, _currType)

    currentPet = objID
    currType   = _currType
    
    if _currType == 0 then
        if lastSelectNode then lastSelectNode:setScale(1.0) end
    end
end
--- get current pet
function LtPickPetViewMgr.getCurrentPet()
    return currentPet
end

---
--@param scene node scene
--@param currPet number 底部队伍中选中宠物[或者空槽位置]
--@param type numver 0:空槽, 1:出战宠, 2:支援宠
function LtPickPetViewMgr.show(scene, currPet, type)
    if not LtPickPetViewMgr.isShown then
        LtPickPetViewMgr.isShown = true

        UIStack.push("LtPickPetViewMgr",LtPickPetViewMgr.hide)
        GameAudio.playUISound("popup")
    else
        LtPickPetViewMgr.setCurrentPet(currPet, type)
        return
    end
    
    currType = type
    currentPet = currPet
    
    if type == 0 then
        if lastSelectNode then lastSelectNode:setScale(1.0) end
    end
    
    local function loadCSB()

        local layer = CSResourceMgr.createRes(scene,resName)
        layer:setPosition(-320,0)
        
        local db = CSResourceMgr.getNodeByName(resName,"db")
        db:setVisible(false)
        
        local diff = CocosModuleMgr.getScreenSizeDiff()
        local scale = CSResourceMgr.getCsbObj(LostTowerUIMgr.bottomResName):getScale()
        local height_fix = 960 + diff - scale*db:getContentSize().height - 36
        
        db:setPositionY(height_fix)
        
        local button_db = CSResourceMgr.getNodeByName(resName,{"db","button_db"})
        button_db:setCascadeOpacityEnabled(false)
        button_db:setCascadeColorEnabled(false)
        button_db:setColor({r=24,g=36,b=50,a=255})
        
        button_db:setPositionY(180 - height_fix)
        
        local list = CSResourceMgr.getNodeByName(resName,{"db","petList"})
        list:setContentSize(624, 720 - (180 - height_fix))
        list:setPositionY(130 + (180 - height_fix))

        local c0 = {r=0,g=0,b=0,a=255,w=1}

        local title_textColor = {r=144,g=238,b=255,a=255}
        local title_outline   = {r=38,g=54,b=76,a=255}

        CSResourceMgr.setLabelColor(resName,{"db","changePet_t"},title_textColor)
        CSResourceMgr.setLabelString(resName,{"db","changePet_t"},"LtPickTitle","",title_outline)

        local tips_textColor = {r=90,g=118,b=138,a=255}
        CSResourceMgr.setLabelColor(resName,{"db","tips"},tips_textColor)
        CSResourceMgr.setLabelString(resName,{"db","tips"},"LtTips1")    -- "宠物由战斗力高低排序"

        --CSResourceMgr.setButtonString(resName,{"db","button1"},"LtPickBtn1","",c0)
        CSResourceMgr.setButtonString(resName,{"db","button_db","button2"},"LtPickBtn2","",c0)
        CSResourceMgr.setButtonString(resName,{"db","button_db","button3"},"LtPickBtn3","",c0)
        
    end

    local function playCSB()
        CSResourceMgr.getNodeByName(resName,"db"):setVisible(true)
        CocosModuleMgr.showUIAnimation(CSResourceMgr.getNodeByName(resName,"db"), "up")
    end

    local function initPet()
        local pets = {}
        local isMainPet = {}
        local isHelpPet = {}
        local isYokePet = {}
        
        local tenMillion = 10000000
        
        for k,v in pairs(LtPetsMgr.LtPets) do
            table.insert(pets,{objID = k, hp = v,})
            
            for i = 1,#LtPetsMgr.LtArmy do
                if LtPetsMgr.LtArmy[i] == k then
                    isMainPet[k] = true
                end
            end
            
            for i = 1,#LtPetsMgr.LtHelpArmy do
                if LtPetsMgr.LtHelpArmy[i] == k then
                    isHelpPet[k] = true
                end
            end
            
            local petInfo = PokemonInfo.getPetInfoByObjID(k)
            if petInfo.yoke then
                if petInfo.yoke.bindTo then
                    isYokePet[k] = true
                end
            end
        end
        
        LtPickPetViewMgr.reset(pets, function(pets)
        
            local function compare(aa,bb)
                local fc1 = PokemonInfo.getPetInfoByObjID(aa.objID).fc
                local fc2 = PokemonInfo.getPetInfoByObjID(bb.objID).fc
                
                if isMainPet[aa.objID] then fc1 = fc1 + tenMillion + tenMillion end
                if isHelpPet[aa.objID] then fc1 = fc1 + tenMillion end
                if isMainPet[bb.objID] then fc2 = fc2 + tenMillion + tenMillion end
                if isHelpPet[bb.objID] then fc2 = fc2 + tenMillion end
                
                if isYokePet[aa.objID] then fc1 = fc1 - tenMillion end
                if isYokePet[bb.objID] then fc2 = fc2 - tenMillion end
                
                return fc1 < fc2
            end
            
            -- Bubble Sort
            for i = 1, #pets do
                for k = 1, #pets - i do
                    if compare(pets[k], pets[k+1]) then
                        pets[k], pets[k+1] = pets[k+1], pets[k]
                    end
                end
            end

            return pets
            
        end)
    end
    
    local function buttonBinding()
        CSResourceMgr.clickEventBinding(resName,{"db","button1"},function()  --取消
            LtPickPetViewMgr.hide()
        end)
        CSResourceMgr.clickEventBinding(resName,{"db","button_db","button2"},function()  --卸下
            if currType and currType == 0 then
                StandardTipsMgr.show(1, "LtTips7")    -- "未选中任何宠物..."
                return
            end
            
            local pos1
            for i=1, #LtPetsMgr.LtArmy do
                if currentPet == LtPetsMgr.LtArmy[i] then
                    pos1 = i
                end
            end
            if pos1 then
                if #LtPetsMgr.LtArmy == 1 then
                    StandardTipsMgr.show(1, "LtTips8")    -- "至少要有一只出战宠..."
                    return
                else
                    table.remove(LtPetsMgr.LtArmy, pos1)
                end
            end
            
            local pos2
            for i=1, #LtPetsMgr.LtHelpArmy do
                if currentPet == LtPetsMgr.LtHelpArmy[i] then
                    pos2 = i
                end
            end
            if pos2 then
                table.remove(LtPetsMgr.LtHelpArmy, pos2)
            end
            
            NetInterface.sendWithBlock("GC_CHANGEREADYPET_ACK", function()
                local LostTowerSend = require("src.Net.Send.LostTowerSend")
                LostTowerSend.sendCG_changeReadyPet_Req({
                    activityArmysList = LtPetsMgr.LtArmy,
                    activityHelpArmysList = LtPetsMgr.LtHelpArmy,
                })
            end, function()
                lastSelectNode = nil
                LtPickPetViewMgr.removePet(pos1, pos2)
                LtPickPetViewMgr.hide()
            end)
        end)
        CSResourceMgr.clickEventBinding(resName,{"db","button_db","button3"},function()  --替换
            local pos1, pos2
            local actionType = 1  -- 1:add /  2:replace

            if currentSelect == 0 then
                StandardTipsMgr.show(1, "LtTips7")
                return
            end
            
            local function checkDuplicatePet(pInfo, curOID)
                for i=1, #LtPetsMgr.LtArmy do
                    local _info = PokemonInfo.getPetInfoByObjID(LtPetsMgr.LtArmy[i])
                    if _info.pokeID == pInfo.pokeID and curOID ~= LtPetsMgr.LtArmy[i] then
                        return true
                    end
                end
                for i=1, #LtPetsMgr.LtHelpArmy do
                    local _info = PokemonInfo.getPetInfoByObjID(LtPetsMgr.LtHelpArmy[i])
                    if _info.pokeID == pInfo.pokeID and curOID ~= LtPetsMgr.LtHelpArmy[i] then
                        return true
                    end
                end
                
                return false
            end
            
            if currType and currType == 0 then
                actionType = 1
                
                print(currentPet, currentSelect)
                
                local petInfo = PokemonInfo.getPetInfoByObjID(currentSelect)
                if checkDuplicatePet(petInfo, 0) then
                    StandardTipsMgr.show(1, "tips59")
                    return
                end
                
                if currentPet <= 3 then
                    table.insert(LtPetsMgr.LtArmy, currentSelect)
                elseif currentPet >= 4 then
                    table.insert(LtPetsMgr.LtHelpArmy, currentSelect)
                end
            else
                local petInfo  = PokemonInfo.getPetInfoByObjID(currentSelect)
                if checkDuplicatePet(petInfo, currentPet) then
                    StandardTipsMgr.show(1, "tips59")
                    return
                end
            
                for i=1, #LtPetsMgr.LtArmy do
                    if currentPet == LtPetsMgr.LtArmy[i] then
                        pos1 = i
                        actionType = 2
                        LtPetsMgr.LtArmy[i] = currentSelect -- replace
                    end
                end
                for i=1, #LtPetsMgr.LtHelpArmy do
                    if currentPet == LtPetsMgr.LtHelpArmy[i] then
                        pos2 = i
                        actionType = 2
                        LtPetsMgr.LtHelpArmy[i] = currentSelect -- replace
                    end
                end
            end
            
            NetInterface.sendWithBlock("GC_CHANGEREADYPET_ACK", function()
                local LostTowerSend = require("src.Net.Send.LostTowerSend")
                LostTowerSend.sendCG_changeReadyPet_Req({
                    activityArmysList = LtPetsMgr.LtArmy,
                    activityHelpArmysList = LtPetsMgr.LtHelpArmy,
                })
            end, function()
                -- replace
                if actionType == 1 then
                    LtPickPetViewMgr.addPet(currentSelect, currentPet)
                    LtPickPetViewMgr.hide()
                elseif actionType == 2 then
                    lastSelectNode = nil
                    LtPickPetViewMgr.replacePet(currentSelect, pos1, pos2)
                    LtPickPetViewMgr.hide()
                end
            end)
        end)
    end

    local funcTable = {loadCSB, playCSB, initPet, buttonBinding}

    if useUnblockLoader then
        UnblockLoader.load(funcTable,"LtPickPetViewMgr")
    else
        for i=1,#funcTable do
            funcTable[i]()
        end
    end
    
end

function LtPickPetViewMgr.hide()
    UIStack.pop("LtPickPetViewMgr")
    GameAudio.playUISound("retract")

    LtPickPetViewMgr.isShown = false
    currentPet    = 0
    currentSelect = 0
    currType      = 0
    if lastSelectNode then 
        lastSelectNode:setScale(1.0)
        lastSelectNode = nil
    end
    CSResourceMgr.getNodeByName(LostTowerUIMgr.bottomResName,"light_square"):setVisible(false)
    UnblockLoader.cancel("LtPickPetViewMgr")
    UnblockLoader.cancel("LtPickPetViewMgr-reset")
    CSResourceMgr.removeCSObjectByTag(resName)
    
    HighPerformList.resetAllSchedule()
    
    BattleFuncMgr.endCreatePetCard()
end

function LtPickPetViewMgr.setHelpPetCard(pNode)
    pNode:setContentSize(92,118)
    local petLevel      = pNode:getChildByName("level")
    local diban         = pNode:getChildByName("diban")
    local icon          = pNode:getChildByName("icon")
    local rarei         = pNode:getChildByName("rarei")
    local attribution   = pNode:getChildByName("attri")

    local tbl = {petLevel, diban, icon, rarei, attribution}
    for i = 1, #tbl do
        tbl[i]:setPositionY(tbl[i]:getPositionY()+12)
    end

    if pNode.stars and type(pNode.stars) == "table" then
        for i = 1, #pNode.stars do
            local star = pNode.stars[i]
            star:setPositionY(star:getPositionY()+12)
        end
    end
end

---
--@param pNode node node
--@param type number 1:有血条; 2:无血条
function LtPickPetViewMgr.resizePetNode(pNode, _type)
    if _type == 1 then
        if LtMapOption.getMapType() == "ADVENTURE" then
            if pNode:getContentSize().height == 118 then return end
            pNode:setContentSize(92,118)
            local petLevel      = pNode:getChildByName("level")
            local diban         = pNode:getChildByName("diban")
            local icon          = pNode:getChildByName("icon")
            local rarei         = pNode:getChildByName("rarei")
            local attribution   = pNode:getChildByName("attri")

            local tbl = {petLevel, diban, icon, rarei, attribution}

            for i = 1, #tbl do
                tbl[i]:setPositionY(tbl[i]:getPositionY()+12)
            end
        elseif LtMapOption.getMapType() == "LOSTTOWER" then
            if pNode.stars and type(pNode.stars) == "table" then
                for i = 1, #pNode.stars do
                    local star = pNode.stars[i]
                    star:setPositionY(star:getPositionY()-12)
                end
            end
        end
        
        CSResourceMgr.seekNodeByName(pNode, "barBK"):setVisible(true)
        CSResourceMgr.seekNodeByName(pNode, "bar"):setVisible(true)
    elseif _type == 2 then
        if LtMapOption.getMapType() == "ADVENTURE" then
            if pNode:getContentSize().height == 108 then return end
            pNode:setContentSize(92,108)
            local petLevel      = pNode:getChildByName("level")
            local diban         = pNode:getChildByName("diban")
            local icon          = pNode:getChildByName("icon")
            local rarei         = pNode:getChildByName("rarei")
            local attribution   = pNode:getChildByName("attri")

            local tbl = {petLevel, diban, icon, rarei, attribution}

            for i = 1, #tbl do
                tbl[i]:setPositionY(tbl[i]:getPositionY()-12)
            end
        elseif LtMapOption.getMapType() == "LOSTTOWER" then
            if pNode.stars and type(pNode.stars) == "table" then
                for i = 1, #pNode.stars do
                    local star = pNode.stars[i]
                    star:setPositionY(star:getPositionY()+12)
                end
            end
        end
        
        CSResourceMgr.seekNodeByName(pNode, "barBK"):setVisible(false)
        CSResourceMgr.seekNodeByName(pNode, "bar"):setVisible(false)
    end
end

function LtPickPetViewMgr.bindPetNodeEvent(pNode)
    local isChange = false
    local px
    local py = 2
    local pxOffset  --the offset between node position and cursor pos
    local isMoved = false  -- 是否移动
    local circle = CSResourceMgr.getNodeByName(LostTowerUIMgr.bottomResName,"light_square")
    local beganPosition
    
    pNode:addTouchEventListener(function(sender, state)
        local currSelect
        local pos1, pos2
        for i=1,#LtPetsMgr.LtArmyPetNodes do
            if LtPetsMgr.LtArmyPetNodes[i] == pNode then
                currSelect = i
            end
        end
        for i=1,#LtPetsMgr.LtHelpArmyNodes do
            if LtPetsMgr.LtHelpArmyNodes[i] == pNode then
                currSelect = i + 3 
            end
        end
        
        if state == 0 then  --touch
            if isChange then   --移動時不響應
                return 
            end

            isChange = true
            px = pNode:getPositionX()
            beganPosition = pNode:getTouchBeganPosition()
            pxOffset = px - beganPosition.x
        end
        if state == 1 then  --drag
            if LtPickPetViewMgr.isShown then return end
            
            -- 后面的宠只是站着吆呼哦~
            --if currSelect > 3 then return end
            
            local pos = pNode:getTouchMovePosition()
            pNode:setPosition(pos.x + pxOffset,py)
            pNode:setLocalZOrder(21)
            
            if math.abs(pos.x - beganPosition.x) > 6 then
                isMoved = true
            end

            circle:setVisible(false)
            pNode:setScale(1.0)
            circle:setScale(1.0)
        end
        if state == 2 then --click
            pNode:setTouchEnabled(false)

            if not isMoved then  -- 移动过后不响应点击事件
                local pos
                local _objID, _type
                for k=1 , #LtPetsMgr.LtArmyPetNodes do
                    if LtPetsMgr.LtArmyPetNodes[k] == pNode then
                        pos = k
                        _objID = LtPetsMgr.LtArmy[pos]
                    end
                end
                for k=1 , #LtPetsMgr.LtHelpArmyNodes do
                    if LtPetsMgr.LtHelpArmyNodes[k] == pNode then
                        pos = k
                        _objID = LtPetsMgr.LtHelpArmy[pos]
                    end
                end
                
                if lastSelectNode then lastSelectNode:setScale(1.0) end
                lastSelectNode = pNode
                
                circle:setVisible(true)
                pNode:setScale(1.1)
                circle:setScale(1.1)
                circle:setLocalZOrder(22) 
                if currSelect <= 3 then
                    circle:setContentSize(96, 118)
                    circle:setPosition(55+98*(currSelect-1),2)
                    _type = 1
                elseif currSelect >= 4 then
                    circle:setContentSize(98, 118)
                    circle:setPosition(320+55+98*(currSelect-3-1),2)
                    _type = 2
                end
                
                
                LtPickPetViewMgr.show(CSResourceMgr.getNodeByName(LostTowerUIMgr.bottomResName,"petPickingOrder"), _objID,_type)
            end
            
            local tagX
            for i=1, #LtPetsMgr.LtEmptyPetNodes do
                local tmpNode
                if i <= 3 then
                    tmpNode = LtPetsMgr.LtArmyPetNodes[i]
                elseif i>= 4 then
                    tmpNode = LtPetsMgr.LtHelpArmyNodes[i-3]
                end
                
                if tmpNode and i ~= currSelect then
                    local t = LtPetsMgr.LtEmptyPetNodes[i]:getPositionX()-pNode:getPositionX()
                    if (t>=0 and t<50) or (t<=0 and t>-50) then
                        -- 后面的宠只是站着吆呼哦~
                        --if i > 3 then break end

                        if currSelect <= 3 and i >= 4 then
                            LtPickPetViewMgr.resizePetNode(LtPetsMgr.LtArmyPetNodes[currSelect],2)
                            LtPickPetViewMgr.resizePetNode(LtPetsMgr.LtHelpArmyNodes[i-3],1)
                            
                            tagX = LtPetsMgr.LtHelpArmyNodes[i-3]:getPositionX()
                            LtPetsMgr.LtHelpArmyNodes[i-3]:setPosition(px,py)
                            LtPetsMgr.LtHelpArmyNodes[i-3],LtPetsMgr.LtArmyPetNodes[currSelect] = pNode,LtPetsMgr.LtHelpArmyNodes[i-3]
                            LtPetsMgr.LtHelpArmy[i-3],LtPetsMgr.LtArmy[currSelect] = LtPetsMgr.LtArmy[currSelect],LtPetsMgr.LtHelpArmy[i-3]
                        elseif currSelect >= 4 and i <= 3 then
                            LtPickPetViewMgr.resizePetNode(LtPetsMgr.LtHelpArmyNodes[currSelect-3],1)
                            LtPickPetViewMgr.resizePetNode(LtPetsMgr.LtArmyPetNodes[i],2)
                            
                            tagX = LtPetsMgr.LtArmyPetNodes[i]:getPositionX()
                            LtPetsMgr.LtArmyPetNodes[i]:setPosition(px,py)
                            LtPetsMgr.LtArmyPetNodes[i],LtPetsMgr.LtHelpArmyNodes[currSelect-3] = pNode,LtPetsMgr.LtArmyPetNodes[i]
                            LtPetsMgr.LtArmy[i],LtPetsMgr.LtHelpArmy[currSelect-3] = LtPetsMgr.LtHelpArmy[currSelect-3],LtPetsMgr.LtArmy[i]
                        elseif currSelect <= 3 and i <= 3 then
                            tagX = LtPetsMgr.LtArmyPetNodes[i]:getPositionX()
                            LtPetsMgr.LtArmyPetNodes[i]:setPosition(px,py)
                            LtPetsMgr.LtArmyPetNodes[i],LtPetsMgr.LtArmyPetNodes[currSelect] = pNode,LtPetsMgr.LtArmyPetNodes[i]
                            LtPetsMgr.LtArmy[i],LtPetsMgr.LtArmy[currSelect] = LtPetsMgr.LtArmy[currSelect],LtPetsMgr.LtArmy[i]
                        elseif currSelect >= 4 and i >= 4 then
                            tagX = LtPetsMgr.LtHelpArmyNodes[i-3]:getPositionX()
                            LtPetsMgr.LtHelpArmyNodes[i-3]:setPosition(px,py)
                            LtPetsMgr.LtHelpArmyNodes[i-3],LtPetsMgr.LtHelpArmyNodes[currSelect-3] = pNode,LtPetsMgr.LtHelpArmyNodes[i-3]
                            LtPetsMgr.LtHelpArmy[i-3],LtPetsMgr.LtHelpArmy[currSelect-3] = LtPetsMgr.LtHelpArmy[currSelect-3],LtPetsMgr.LtHelpArmy[i-3]
                        end
                    end
                end
            end
            
            local dt
            if tagX ~= nil then
                dt = 0.1 + 0.0002*math.abs(pNode:getPositionX() - tagX)
                transition.moveTo(pNode,{x=tagX,y=py,time=dt})
            else
                dt = 0.1 + 0.0002*math.abs(pNode:getPositionX() - px)
                transition.moveTo(pNode,{x=px,y=py,time=dt})
            end
            
            pNode:performWithDelay(function()
                if tagX then 
                    LtPetsMgr.resortArmy(LtPetsMgr.LtArmy, LtPetsMgr.LtHelpArmy)
                    GameAudio.playUISound("petDrag")
                end
                isChange = false
                pNode:setTouchEnabled(true)
            end,dt)

            isMoved = false
            pNode:setLocalZOrder(20)
        end
        if state == 3 then  --cancel
            if LtPickPetViewMgr.isShown then return end
            pNode:setTouchEnabled(false)
            
            local dt = 0.1 + 0.0002*math.abs(pNode:getPositionX() - px)
            transition.moveTo(pNode,{x=px,y=py,time=dt})
            pNode:performWithDelay(function()
                isChange = false
                isMoved = false
                circle:setVisible(false)
                pNode:setTouchEnabled(true)

                pNode:setScale(1.0)
                circle:setScale(1.0)
            end,dt)

            pNode:setLocalZOrder(20)
        end
    end)
end

function LtPickPetViewMgr.addPet(objID, index)
    if #LtPetsMgr.LtArmy > 6 then
        return
    end
    
    -- local index = #LtPetsMgr.LtArmy

    local petList = CSResourceMgr.getNodeByName(LostTowerUIMgr.bottomResName,"petQue")
    
    local petInfo = clone( PokemonInfo.getPetInfoByObjID(objID) )
    petInfo.hp = LtPetsMgr.getHpByObjID(objID)
    local BattleFuncMgr = require("src.GameMgr.Battle.BattleFuncMgr")
    local p 
    if index <= 3 then
        p = BattleFuncMgr.startCreatePetCard(petInfo,1)
        p.button:setPosition(55+98*(#LtPetsMgr.LtArmyPetNodes),2)
        CSResourceMgr.setButtonEnabledByNode(LtPetsMgr.LtEmptyPetNodes[#LtPetsMgr.LtArmyPetNodes], false)
    else
        p = BattleFuncMgr.startCreatePetCard(petInfo,2)
        p.button:setPosition(320+55+98*(#LtPetsMgr.LtHelpArmyNodes),2)
        LtPickPetViewMgr.setHelpPetCard(p.button)
        CSResourceMgr.setButtonEnabledByNode(LtPetsMgr.LtEmptyPetNodes[#LtPetsMgr.LtHelpArmyNodes], false)
    end
    petList:addChild(p.button)
    p.button:setAnchorPoint(0.5,0.0)
    -- p.button:setScale(0.82)
    
    LtPickPetViewMgr.bindPetNodeEvent(p.button)
    
    if index <= 3 then
        table.insert(LtPetsMgr.LtArmyPetNodes, p.button)
    elseif index >= 4 then
        table.insert(LtPetsMgr.LtHelpArmyNodes, p.button)
    end
end

--- 移除队伍中pos位置上的宠物
function LtPickPetViewMgr.removePet(pos1, pos2)
    local index
    if pos1 then
        LtPetsMgr.LtArmyPetNodes[pos1]:removeFromParent()
        for i = pos1+1, #LtPetsMgr.LtArmyPetNodes do
            transition.moveBy(LtPetsMgr.LtArmyPetNodes[i],{x=-98,time=0.1})
        end
        table.remove(LtPetsMgr.LtArmyPetNodes, pos1)
        
        index = #LtPetsMgr.LtArmyPetNodes + 1
    end
    
    if pos2 then
        LtPetsMgr.LtHelpArmyNodes[pos2]:removeFromParent()
        for i = pos2+1, #LtPetsMgr.LtHelpArmyNodes do
            transition.moveBy(LtPetsMgr.LtHelpArmyNodes[i],{x=-98,time=0.1})
        end
        table.remove(LtPetsMgr.LtHelpArmyNodes, pos2)
        
        index = #LtPetsMgr.LtHelpArmyNodes + 1 + 3
    end
    CSResourceMgr.setButtonEnabledByNode(LtPetsMgr.LtEmptyPetNodes[index], true)
end

function LtPickPetViewMgr.replacePet(objID, index1, index2)
    if index1 then
        LtPetsMgr.LtArmyPetNodes[index1]:removeFromParent()
    end
    if index2 then
        LtPetsMgr.LtHelpArmyNodes[index2]:removeFromParent()
    end
    
    local petInfo = clone( PokemonInfo.getPetInfoByObjID(objID) )
    petInfo.hp = LtPetsMgr.getHpByObjID(objID)

    local petList = CSResourceMgr.getNodeByName(LostTowerUIMgr.bottomResName,"petQue")
    local BattleFuncMgr = require("src.GameMgr.Battle.BattleFuncMgr")
    local p
    if index1 then
        p = BattleFuncMgr.startCreatePetCard(petInfo, 1)
        p.button:setPosition(55+98*(index1-1),2)
    end
    if index2 then
        p = BattleFuncMgr.startCreatePetCard(petInfo, 2)
        p.button:setPosition(320+55+98*(index2-1),2)
        LtPickPetViewMgr.setHelpPetCard(p.button)
    end
    petList:addChild(p.button)
    p.button:setAnchorPoint(0.5,0.0)

    LtPickPetViewMgr.bindPetNodeEvent(p.button)
    if index1 then
        LtPetsMgr.LtArmyPetNodes[index1] = p.button
    end
    if index2 then
        LtPetsMgr.LtHelpArmyNodes[index2] = p.button
    end
end

-------创建卡片
--@param petInfo   table        宠信息
--@param cardType  int         1为有血卡  2无血卡 3 有名字卡 ---默认为有名字的卡]
local function createPetCard(petInfo,cardType,preNode)
    local petCard = {}
    local res     = "Pet/petcards/petcard.csb"
    local petCard = CSResourceMgr.createRes(nil,res)
    CSResourceMgr.setFrame(res, 0)

    local layerBtn      = petCard:getChildByName("btn")
    local isHaveBar     = true

    local btn           = layerBtn:clone()
    local petLevel      = btn:getChildByName("level")
    local diban         = btn:getChildByName("diban")
    local icon          = btn:getChildByName("icon")
    local rarei         = btn:getChildByName("rarei")
    local attribution   = btn:getChildByName("attri")
    local petBar        = btn:getChildByName("bar")
    local barBK         = btn:getChildByName("barBK")
    local str           = btn:getChildByName("str")
    local star          = btn:getChildByName("star") 
    local starTable     = {}
    local petDatInfo    = PokemonInfo.getPokemonInfoByID(petInfo.pokeID)
    local rarePoint     = petDatInfo.rarePoint
    local starPosX,starPosY   = 46, 14
    local starSize      = 15

    petLevel:enableOutline({r = 0,g = 0,b = 0, a = 255}, 1) 
    str:enableOutline({r = 0,g = 0,b = 0, a = 255}, 1)

    str:setTextColor({r = 215,g = 216,b = 217, a = 255})

    petLevel:setString("Lv"..petInfo.level)
    str:setString("")

    rarei:setScale(0.48)

    if not isHaveBar then
        barBK:hide()
        petBar:hide()
    end

    if petInfo.hp and petInfo.hpmax then
        local cardPer = 100*petInfo.hp/petInfo.hpmax
        petBar:setPercent(cardPer) 
    end

    if petInfo.star == 0 then
        star:hide()
    else
        local x = starPosX - (starSize*petInfo.star - starSize)/2
        star:setPosition(x,starPosY)
        starTable[1] = star
        local copyStars = petInfo.star-1
        for index = 1,copyStars do
            local copeStar = star:clone()
            starTable[1+index] = copeStar
            copeStar:addTo(btn)
            copeStar:setPosition(x+index*starSize,starPosY) 
        end
    end

    petCard = {stars = starTable,str = str,bar = petBar,barBK = barBK,node = layer,button = btn,level = petLevel,rare = rarei,
        attriBK = attridiban,attri = attribution,headBK = diban,head = icon,rarePoint = rarePoint} 

    local rareRes = BattleFuncMgr.getStagePics(rarePoint) 
    CSResourceMgr.setSpriteTextureByNode(petCard.headBK, rareRes.p1)
    local attriInfo     = tonumber(PokemonInfo.getPokemonInfoByID(petInfo.pokeID).elementAtt1)
    local attriRes      = "UI/CommonFiles/"..attriInfo..".png" 

    CSResourceMgr.setSpriteTextureByNode(petCard.rare, PetEducationMgr.getRareIcon(rarePoint))
    CSResourceMgr.setSpriteTextureByNode(petCard.head, PokemonInfo.getPokemonIconByID(petInfo.pokeID))
    CSResourceMgr.setSpriteTextureByNode(petCard.attri, attriRes) 
    petCard.button.stars = starTable

    return petCard
end


local function updateCard(petInfo, preNode)
    local layerBtn      = preNode.pButton
    local isHaveBar     = true

    local btn           = layerBtn
    local petLevel      = btn:getChildByName("level")
    local diban         = btn:getChildByName("diban")
    local icon          = btn:getChildByName("icon")
    local rarei         = btn:getChildByName("rarei")
    local attribution   = btn:getChildByName("attri")
    local petBar        = btn:getChildByName("bar")
    local barBK         = btn:getChildByName("barBK")
    local str           = btn:getChildByName("str")
    local star          = btn:getChildByName("star") 
    local starTable     = {}
    local petDatInfo    = PokemonInfo.getPokemonInfoByID(petInfo.pokeID)
    local rarePoint     = petDatInfo.rarePoint
    local starPosX,starPosY   = 46, 14
    local starSize      = 15

    petLevel:enableOutline({r = 0,g = 0,b = 0, a = 255}, 1) 
    str:enableOutline({r = 0,g = 0,b = 0, a = 255}, 1)

    str:setTextColor({r = 215,g = 216,b = 217, a = 255})

    petLevel:setString("Lv"..petInfo.level)
    str:setString("")

    rarei:setScale(0.48)

    if not isHaveBar then
        barBK:hide()
        petBar:hide()
    end

    if petInfo.hp and petInfo.hpmax then
        local cardPer = 100*petInfo.hp/petInfo.hpmax
        petBar:setPercent(cardPer) 
    end
    
    for i = 1, #layerBtn.stars do
        if i == 1 then
            layerBtn.stars[i]:setVisible(false)
        else
            pcall(function() layerBtn.stars[i]:removeFromParent() end)
        end
    end
    if petInfo.star == 0 then
        star:hide()
    else
        local x = starPosX - (starSize*petInfo.star - starSize)/2
        star:setPosition(x,starPosY)
        star:setVisible(true)
        starTable[1] = star
        local copyStars = petInfo.star-1
        for index = 1,copyStars do
            local copeStar = star:clone()
            starTable[1+index] = copeStar
            copeStar:addTo(btn)
            copeStar:setPosition(x+index*starSize,starPosY) 
        end
    end
    layerBtn.stars = starTable

    local rareRes = BattleFuncMgr.getStagePics(rarePoint) 
    CSResourceMgr.setSpriteTextureByNode(diban, rareRes.p1)  
    local attriInfo     = tonumber(PokemonInfo.getPokemonInfoByID(petInfo.pokeID).elementAtt1)
    local attriRes      = "UI/CommonFiles/"..attriInfo..".png" 

    CSResourceMgr.setSpriteTextureByNode(rarei, PetEducationMgr.getRareIcon(rarePoint))
    CSResourceMgr.setSpriteTextureByNode(icon, PokemonInfo.getPokemonIconByID(petInfo.pokeID))
    CSResourceMgr.setSpriteTextureByNode(attribution, attriRes)
end

function LtPickPetViewMgr.reset(pets, sortFunc)
    local list = CSResourceMgr.getNodeByName(resName,{"db","petList"})
    
    local funcTable = {}

    local RANK_NUM = 4
    local panelTable = {}
    local petTable   = {}

    local ranknum = RANK_NUM
    local spawncount = 6
    local countperline = 4
    local allnum = countperline*spawncount
    
    -- currentSelect = objID or 0
    
    -- resort pets
    if sortFunc then
        pets = sortFunc(pets)
    end
    
    local panelSample = CSResourceMgr.getNodeByName(resName, "Panel_1")
    local gap = 150
    local startPos = (gap + (panelSample:getContentSize().width - gap * RANK_NUM)) / 2
    
    panelSample:setCascadeOpacityEnabled(false)
    panelSample:setCascadeColorEnabled(false)
    panelSample:setOpacity(153)
    
    local panelColor = {
        [1] = {r=50,g=74,b=107,a=255},
        [0] = {r=41,g=64,b=87, a=255},
    }

    local function itemFunc(petInfo, row, rank, preNode)
        -- local petInfo = clone( PokemonInfo.getPetInfoByObjID(pets[i].objID) )
        petInfo.hp = LtPetsMgr.getHpByObjID(petInfo.objID)
        
        local p, pStatus, pButton
        if preNode then
            updateCard(petInfo, preNode)
            pStatus = preNode
            pButton =  pStatus.pButton
        else
            p = createPetCard(petInfo, 1)
            pStatus = CSResourceMgr.getNodeByName(resName, "pStatus"):clone()
            local pCard   = CSResourceMgr.seekNodeByName(pStatus,"petCard")
            pStatus.pButton = p.button
            pButton = p.button
            pButton:removeFromParent(true)
            pButton:setScale(130 / pButton:getContentSize().width)
    
            pCard:addChild(pButton)
            pStatus:setLocalZOrder(RANK_NUM-rank)  -- set card z-order
            pStatus:setPosition(gap*(rank-1)+startPos,106)
        end
        
        CSResourceMgr.seekNodeByName(pStatus,"selectIcon"):setVisible(currentSelect == petInfo.objID)

        -- status
        local label = CSResourceMgr.seekNodeByName(pStatus,"statusText")
        CSResourceMgr.seekNodeByName(pStatus,"statusText"):setVisible(false)
        for k=1,#LtPetsMgr.LtArmy do
            if LtPetsMgr.LtArmy[k] == petInfo.objID then
                CSResourceMgr.seekNodeByName(pStatus,"selectIcon"):setVisible(false)
                label:setVisible(true)
                CSResourceMgr.setLabelColorByNode(label,{r=173,g=255,b=15,a=255})
                CSResourceMgr.setLabelStringByNode(label,"LtText11",{r=0,g=0,b=0,a=255})
            end
        end
        for k=1,#LtPetsMgr.LtHelpArmy do
            if LtPetsMgr.LtHelpArmy[k] == petInfo.objID then
                CSResourceMgr.seekNodeByName(pStatus,"selectIcon"):setVisible(false)
                label:setVisible(true)
                CSResourceMgr.setLabelColorByNode(label,{r=173,g=255,b=15,a=255})
                CSResourceMgr.setLabelStringByNode(label,"LtText13",{r=0,g=0,b=0,a=255})
            end
        end
        if petInfo.yoke then
            if petInfo.yoke.bindTo then
                CSResourceMgr.seekNodeByName(pStatus,"selectIcon"):setVisible(false)
                label:setVisible(true)
                CSResourceMgr.setLabelColorByNode(label,{r=255,g=246,b=0,a=255})
                CSResourceMgr.setLabelStringByNode(label,"LtTips23",{r=0,g=0,b=0,a=255})
            end
        end
        -- dead pets
        if petInfo.hp <= 0 then
            pButton:setColor({r=130,g=130,b=130,a=255})

            label:setVisible(true)
            CSResourceMgr.seekNodeByName(pStatus,"selectIcon"):setVisible(false)
            CSResourceMgr.setLabelColorByNode(label,{r=251,g=11,b=11,a=255})
            CSResourceMgr.setLabelStringByNode(label,"LtText12",{r=0,g=0,b=0,a=255})
        end

        local pokeInfo = PokemonInfo.getPokemonInfoByID(petInfo.pokeID)
        local pNameLabel = CSResourceMgr.seekNodeByName(pStatus,"pName")
        CSResourceMgr.setLabelColorByNode(pNameLabel, PokemonInfo.COLOR[pokeInfo.rarePoint])
        CSResourceMgr.setLabelStringByNode(pNameLabel,PetEducationMgr.getPetName(petInfo),{r=0,g=0,b=0,a=255,w=1,s=1})

        petTable[petInfo.objID] = {pNode = pButton, pStatus = pStatus, }

        CSResourceMgr.clickEventBindingByNode(pButton, function()
            for k=1,#LtPetsMgr.LtArmy do
                if LtPetsMgr.LtArmy[k] == petInfo.objID then
                    print("作战中...")
                    return
                end
            end
            for k=1,#LtPetsMgr.LtHelpArmy do
                if LtPetsMgr.LtHelpArmy[k] == petInfo.objID then
                    print("援助中...")
                    return
                end
            end
            if petInfo.yoke then
                if petInfo.yoke.bindTo then
                    print("羁绊中...")
                    return
                end
            end
            if petInfo.hp <= 0 then
                StandardTipsMgr.show(1,"LtTips9")  -- "死亡宠无法再编入队伍~"
                return
            end
            if currentSelect ~= 0 then 
                CSResourceMgr.seekNodeByName(petTable[currentSelect].pStatus,"selectIcon"):setVisible(false)
            end
            currentSelect = petInfo.objID
            CSResourceMgr.seekNodeByName(petTable[currentSelect].pStatus,"selectIcon"):setVisible(true)
        end)
        
        return pStatus
    end
    
    for i=1, #pets do
        if i > allnum then break end
        local row = math.ceil(i/RANK_NUM)
        local rank = i%RANK_NUM
        if rank==0 then
            rank = RANK_NUM
        end
        if rank==1 then
            local panel = panelSample:clone()
            panel:setColor(panelColor[row % 2])
            
            table.insert(panelTable, panel)
            list:pushBackCustomItem(panel)
            panel.button = {}
        end
        table.insert(funcTable, function()
            local pInfo = clone( PokemonInfo.getPetInfoByObjID(pets[i].objID) )
            local pStatus = itemFunc(pInfo, row, rank)
            panelTable[row]:addChild(pStatus)
            panelTable[row].button[rank] = pStatus
        end)
    end
    
    local HighPerformListFunc = function()
        if #pets <= allnum then return end
        HighPerformList.makeHighPerFormVerticalList(list,spawncount,0,countperline,230,210,pets,
        function(item,currentindex)
            local row = math.ceil(currentindex/RANK_NUM)
            local rank = currentindex%RANK_NUM
            if rank==0 then
                rank = RANK_NUM
            end
            for j=1,countperline do 
                if pets[currentindex+j-1] == nil then 
                    item.button[j]:setVisible(false)
                else
                    local petInfo = clone( PokemonInfo.getPetInfoByObjID(pets[currentindex+j-1].objID) )
                    item:setVisible(true)
                    item.button[j]:setVisible(true)
                    local pStatus = itemFunc(petInfo,row,rank,item.button[j])
                end
            end
        end)
    end
    table.insert(funcTable, HighPerformListFunc)
    
    if useUnblockLoader then
        UnblockLoader.load(funcTable,"LtPickPetViewMgr-reset")
    else
        for i=1,#funcTable do
            funcTable[i]()
        end
    end   
end

return LtPickPetViewMgr