local CommonPetBar = {}

local resName = "Pet/CommonPetBar.csb"
local tag = ""

local mainArmy = {}
local helpArmy = {}

local mainPetInfo = {}
local helpPetInfo = {}

local emptyNodes = {}
local mainPetNodes = {}
local helpPetNodes = {}

function CommonPetBar.Init()
    mainArmy = {}
    helpArmy = {}
    emptyNodes = {}
    mainPetNodes = {}
    helpPetNodes = {}
    
    mainPetInfo = {} 
    helpPetInfo = {}
end

-- 获取当前宠物队伍
function CommonPetBar.getCurrentArmy()
    return mainArmy, helpArmy
end

-- 通过队伍获取所有宠物info
function CommonPetBar.getAllPetInfoWithArmy(m_army, h_army)
    local mainret = {}
    local helpRet = {}
    for i=1, #m_army do
        local objID = m_army[i]
        local petInfo = clone( PokemonInfo.getPetInfoByObjID(objID) )
        table.insert(mainret,petInfo)
    end
    for i=1, #h_army do
        local objID = h_army[i]
        local petInfo = clone( PokemonInfo.getPetInfoByObjID(objID) )
        table.insert(helpRet,petInfo)
    end
    return mainret, helpRet
end

function CommonPetBar.getAllPetInfo()
    return CommonPetBar.getAllPetInfoWithArmy(mainArmy, helpArmy)
end

-- 获取宠物栏所有宠物卡片node
function CommonPetBar.getPetNodes()
    return mainPetNodes, helpPetNodes
end

--- 获取血条控件
--@param pNode node 宠物卡片node
function CommonPetBar.getPetHPBar(pNode)
    return pNode:getChildByName("bar")
end

---
--@param scene node 父节点
--@param petInfoTable table {[1]:主战宠, [2]:援助宠} //此参数不传默认取玩家当前队伍
--@param _tag string csb资源创建标识
--@param changeCallback function 队伍拖拽变换后执行该回调
function CommonPetBar.show(scene, petInfoTable, _tag, changeCallback)
    scene = scene or SceneMgr.getRunningScene
    tag = _tag or tag

    local bottomBar = CSResourceMgr.createRes(scene, resName, tag)
    CSResourceMgr.setFullScreen(resName, tag)
    CocosModuleMgr.setEdgeDistance(bottomBar, nil, nil, nil, 0, false)
    bottomBar:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)

    local petList = CSResourceMgr.getNodeByName(resName,"petQue", tag)

    local m_label = CSResourceMgr.getNodeByName(resName, {"mainPets", "m_pet_label"}, tag)
    local h_label = CSResourceMgr.getNodeByName(resName, {"helpPets", "h_pet_label"}, tag)
    CSResourceMgr.setLabelStringByNode(m_label,"train107")
    CSResourceMgr.setLabelStringByNode(h_label,"train108")
    
    if petInfoTable then
        mainPetInfo = petInfoTable[1]
        helpPetInfo = petInfoTable[2]
    else
        mainPetInfo = clone(PokemonInfo.getActivePets())
        helpPetInfo = clone(PokemonInfo.getActiveHelperPets())
    end
    
    mainArmy = {}
    for i = 1, #mainPetInfo do
        mainArmy[i] = mainPetInfo[i].objID
    end
    helpArmy = {}
    for i = 1, #helpPetInfo do
        helpArmy[i] = helpPetInfo[i].objID
    end

    -- 宠物卡片空槽
    emptyNodes = {}
    for i = 1, 6 do
        local emptyNode = CSResourceMgr.getNodeByName(resName,"emptyPet", tag):clone()
        petList:addChild(emptyNode)
        if i <= 3 then
            emptyNode:setPosition(55+98*(i-1), 2)
        else
            emptyNode:setPosition(320+55+98*(i-3-1), 2)
        end
        CSResourceMgr.clickEventBindingByNode(emptyNode,function(sender)
        end)
        table.insert(emptyNodes, emptyNode)
    end


    local BattleFuncMgr = require("src.GameMgr.Battle.BattleFuncMgr")

    -- 宠物卡片
    mainPetNodes = {}
    for i=1, #mainPetInfo do
        local petInfo = mainPetInfo[i]

        local p
        if i <= 3 then
            p = BattleFuncMgr.startCreatePetCard(petInfo, 1)
            p.button:setPosition(55+98*(i-1),2)
        else
            p = BattleFuncMgr.startCreatePetCard(petInfo, 2)
            p.button:setPosition(320+55+98*(i-3-1),2)
        end
        petList:addChild(p.button)
        p.button:setAnchorPoint(0.5,0.0)

        if petInfo.hp <= 0 then
            CommonPetBar.makeCardGray(p, false)
        else
            CommonPetBar.makeCardGray(p, true)
        end

        CommonPetBar.bindPetNodeEvent(p.button, changeCallback)

        CSResourceMgr.setButtonEnabledByNode(emptyNodes[i], false)

        p.button.parent = p
        table.insert(mainPetNodes, p.button)
    end

    helpPetNodes = {}
    for i=1, #helpPetInfo do
        local petInfo = helpPetInfo[i]

        local p
        p = BattleFuncMgr.startCreatePetCard(petInfo, 2)
        p.button:setPosition(320+55+98*(i-1),2)
        LtPickPetViewMgr.setHelpPetCard(p.button)

        petList:addChild(p.button)
        p.button:setAnchorPoint(0.5,0.0)

        if petInfo.hp <= 0 then
            CommonPetBar.makeCardGray(p, false)
        else
            CommonPetBar.makeCardGray(p, true)
        end

        CommonPetBar.bindPetNodeEvent(p.button, changeCallback)

        CSResourceMgr.setButtonEnabledByNode(emptyNodes[3+i], false)

        p.button.parent = p
        table.insert(helpPetNodes, p.button)
    end

    BattleFuncMgr.endCreatePetCard()

end

function CommonPetBar.hide()
    mainArmy = {}
    helpArmy = {}
    emptyNodes = {}
    mainPetNodes = {}
    helpPetNodes = {}
    
    CSResourceMgr.removeCSObjectByTag(resName,tag)
end

local function swapPet(currSelect, target)
end

function CommonPetBar.bindPetNodeEvent(pNode, changeCallback)
    local isChange = false
    local px
    local py = 2
    local pxOffset
    local isMoved = false  -- 是否移动
    local beganPosition

    pNode:addTouchEventListener(function(sender, state)
        local currSelect
        local pos1, pos2
        for i=1,#mainPetNodes do
            if mainPetNodes[i] == sender then
                currSelect = i
            end
        end
        for i=1,#helpPetNodes do
            if helpPetNodes[i] == sender then
                currSelect = i + 3 
            end
        end
        
        -- 后面的宠只是站着吆呼哦~
        if currSelect > 3 then return end

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
            local pos = pNode:getTouchMovePosition()
            pNode:setPosition(pos.x + pxOffset,py)
            pNode:setLocalZOrder(21)

            if math.abs(pos.x - beganPosition.x) > 6 then
                isMoved = true
            end
        end
        if state == 2 then --click
            pNode:setTouchEnabled(false)

            if not isMoved then  -- 移动过后不响应点击事件
                local pos
                local _objID, _type
                for k=1 , #mainPetNodes do
                    if mainPetNodes[k] == pNode then
                        pos = k
                        _objID = mainArmy[pos]
                    end
                end
                for k=1 , #helpPetNodes do
                    if helpPetNodes[k] == pNode then
                        pos = k
                        _objID = helpArmy[pos]
                    end
                end
            end

            local tagX
            for i=1, #emptyNodes do
                local tmpNode
                if i <= 3 then
                    tmpNode = mainPetNodes[i]
                elseif i>= 4 then
                    tmpNode = helpPetNodes[i-3]
                end

                if tmpNode and i ~= currSelect then
                    local t = emptyNodes[i]:getPositionX()-pNode:getPositionX()
                    if (t>=0 and t<50) or (t<=0 and t>-50) then
                        -- 后面的宠只是站着吆呼哦~
                        if i > 3 then break end

                        if currSelect <= 3 and i >= 4 then
                            -- LtPickPetViewMgr.resizePetNode(mainPetNodes[currSelect],2)
                            -- LtPickPetViewMgr.resizePetNode(helpPetNodes[i-3],1)

                            tagX = helpPetNodes[i-3]:getPositionX()
                            helpPetNodes[i-3]:setPosition(px,py)
                            helpPetNodes[i-3],mainPetNodes[currSelect] = mainPetNodes[currSelect],helpPetNodes[i-3]
                            helpArmy[i-3],mainArmy[currSelect] = mainArmy[currSelect],helpArmy[i-3]
                        elseif currSelect >= 4 and i <= 3 then
                            -- LtPickPetViewMgr.resizePetNode(helpPetNodes[currSelect-3],1)
                            -- LtPickPetViewMgr.resizePetNode(mainPetNodes[i],2)

                            tagX = mainPetNodes[i]:getPositionX()
                            mainPetNodes[i]:setPosition(px,py)
                            mainPetNodes[i],helpPetNodes[currSelect-3] = helpPetNodes[currSelect-3],mainPetNodes[i]
                            mainArmy[i],helpArmy[currSelect-3] = helpArmy[currSelect-3],mainArmy[i]
                        elseif currSelect <= 3 and i <= 3 then
                            tagX = mainPetNodes[i]:getPositionX()
                            mainPetNodes[i]:setPosition(px,py)
                            mainPetNodes[i],mainPetNodes[currSelect] = mainPetNodes[currSelect],mainPetNodes[i]
                            mainArmy[i],mainArmy[currSelect] = mainArmy[currSelect],mainArmy[i]
                        elseif currSelect >= 4 and i >= 4 then
                            tagX = helpPetNodes[i-3]:getPositionX()
                            helpPetNodes[i-3]:setPosition(px,py)
                            helpPetNodes[i-3],helpPetNodes[currSelect-3] = helpPetNodes[currSelect-3],helpPetNodes[i-3]
                            helpArmy[i-3],helpArmy[currSelect-3] = helpArmy[currSelect-3],helpArmy[i-3]
                        end

                        if changeCallback then changeCallback() end
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
                isChange = false
                pNode:setTouchEnabled(true)

                GameAudio.playUISound("petDrag")
            end,dt)

            isMoved = false
            pNode:setLocalZOrder(20)
        end
        if state == 3 then  --cancel
            pNode:setTouchEnabled(false)

            local dt = 0.1 + 0.0002*math.abs(pNode:getPositionX() - px)
            transition.moveTo(pNode,{x=px,y=py,time=dt})
            pNode:performWithDelay(function()
                isChange = false
                isMoved = false
                pNode:setTouchEnabled(true)
            end,dt)

            pNode:setLocalZOrder(20)
        end
    end)
end

function CommonPetBar.updateCardInfo(card, hpPercent, tag)
    if card then
        local hp = CommonPetBar.getPetHPBar(card.button)
        if hp then
            local oldPercent = hp:getPercent()
            hp:setPercent(hpPercent)
            if hpPercent < 0.001 then
                CommonPetBar.makeCardGray(card, false)
            else
                CommonPetBar.makeCardGray(card, true)
                if hpPercent > 99.999 and oldPercent < 0.001 then
                    local eff = AnimationMgr.createAni(card.button,"Spine/effects/Ui_chongwuhuixue.png",49,85,tag)
                    AnimationMgr.playAniWithCallback(eff.res, "animation", nil, eff.tag, true)
                end
            end
        end
    end
end

function CommonPetBar.makeCardGray(card, bGray)
    if card and card.head then
        BattleFuncMgr.setNodeGray(card.head, bGray)
    end
end

--- 
--@param cards table 传入卡片 {[1] = {}, [2] = {}}
--@param newArmy table 更新的队伍 {[1] = {}, [2] = {}}
--@return #table newCards
function CommonPetBar.updateTeamBoard(cards, newArmy)
    for key, army in pairs(newArmy) do
        for i = 1, #army do
            for k = 1, #cards[1] do
                if army[i] == cards[1][k].objID then
                    cards[1][k].aid   = key
                    cards[1][k].index = i
                    break
                end
            end
            for k = 1, #cards[2] do
                if army[i] == cards[2][k].objID then
                    cards[2][k].aid   = key
                    cards[2][k].index = i
                    break
                end
            end
        end
    end
    
    local offset = {0, 320}
    local p
    for i=1, #cards[1] do
        p = cards[1][i]
        p.button:setPosition(offset[p.aid]+55+98*(p.index-1),2)
    end
    for i=1, #cards[2] do
        p = cards[2][i]
        p.button:setPosition(offset[p.aid]+55+98*(p.index-1),2)
    end
    
    local newCards = {[1]={},[2]={}}
    for _, var in pairs(cards) do
        for i = 1, #var do
            local aid   = var[i].aid
            local index = var[i].index
            var[i].aid   = nil
            var[i].index = nil
            newCards[aid][index] = var[i]
            
            if aid == 1 then
                newCards[aid][index].button:getChildByName("bar"):setVisible(true)
                newCards[aid][index].button:getChildByName("barBK"):setVisible(true)
            elseif aid == 2 then
                newCards[aid][index].button:getChildByName("bar"):setVisible(false)
                newCards[aid][index].button:getChildByName("barBK"):setVisible(false)
            end
        end
    end
    
    return newCards
end

function CommonPetBar.updateMyTeamBoard(newArmy)
    local cards = {mainPetNodes, helpPetNodes}
    local currArmy = {mainArmy, helpArmy}
    
    for key, army in pairs(newArmy) do
        for i = 1, #army do
            for k = 1, #cards[1] do
                if army[i] == currArmy[1][k] then
                    cards[1][k].aid   = key
                    cards[1][k].index = i
                    break
                end
            end
            for k = 1, #cards[2] do
                if army[i] == currArmy[2][k] then
                    cards[2][k].aid   = key
                    cards[2][k].index = i
                    break
                end
            end
        end
    end
    
    local offset = {0, 320}
    local pButton
    for i=1, #cards[1] do
        pButton = cards[1][i]
        pButton:setPosition(offset[pButton.aid]+55+98*(pButton.index-1),2)
    end
    for i=1, #cards[2] do
        pButton = cards[2][i]
        pButton:setPosition(offset[pButton.aid]+55+98*(pButton.index-1),2)
    end
    
    local newCards = {[1]={},[2]={}}
    for _, var in pairs(cards) do
        for i = 1, #var do
            local aid   = var[i].aid
            local index = var[i].index
            var[i].aid   = nil
            var[i].index = nil
            newCards[aid][index] = var[i]
    
            if aid == 1 then
                newCards[aid][index]:getChildByName("bar"):setVisible(true)
                newCards[aid][index]:getChildByName("barBK"):setVisible(true)
            elseif aid == 2 then
                newCards[aid][index]:getChildByName("bar"):setVisible(false)
                newCards[aid][index]:getChildByName("barBK"):setVisible(false)
            end
        end
    end

    mainPetNodes, helpPetNodes = newCards[1], newCards[2]
    mainArmy, helpArmy = newArmy[1], newArmy[2]
end

function CommonPetBar.createTeamBoard(pets, tag)

    local bottomBar = CSResourceMgr.createRes(nil, resName, tag)
    local cards = {}
    
    bottomBar:setAnchorPoint(0.0, 0.0)
    
    CSResourceMgr.getNodeByName(resName,"board",tag):removeFromParent()
    CSResourceMgr.getNodeByName(resName,"frame",tag):removeFromParent()

    local petList = CSResourceMgr.getNodeByName(resName,"petQue", tag)

    local m_label = CSResourceMgr.getNodeByName(resName, {"mainPets", "m_pet_label"}, tag)
    local h_label = CSResourceMgr.getNodeByName(resName, {"helpPets", "h_pet_label"}, tag)
    CSResourceMgr.setLabelStringByNode(m_label,"train107")
    CSResourceMgr.setLabelStringByNode(h_label,"train108")

    local m_pet = pets["m_pets"]
    local h_pet = pets["h_pets"]

    -- 宠物卡片空槽
    for i = 1, 6 do
        local emptyNode = CSResourceMgr.getNodeByName(resName,"emptyPet", tag):clone()
        petList:addChild(emptyNode)
        if i <= 3 then
            emptyNode:setPosition(55+98*(i-1), 2)
        else
            emptyNode:setPosition(320+55+98*(i-3-1), 2)
        end
    end

    local BattleFuncMgr = require("src.GameMgr.Battle.BattleFuncMgr")

    -- 宠物卡片
    cards[1] = {}
    for i=1, #m_pet do
        local petInfo = m_pet[i]

        local p
        if i <= 3 then
            p = BattleFuncMgr.startCreatePetCard(petInfo, 1)
            p.button:setPosition(55+98*(i-1),2)
        else
            p = BattleFuncMgr.startCreatePetCard(petInfo, 2)
            p.button:setPosition(320+55+98*(i-3-1),2)
        end
        petList:addChild(p.button)
        p.button:setAnchorPoint(0.5,0.0)

        if petInfo.hp <= 0 then
            CommonPetBar.makeCardGray(p, false)
        else
            CommonPetBar.makeCardGray(p, true)
        end
        p.objID = petInfo.objID
        table.insert(cards[1],p)
    end
    
    cards[2] = {}
    for i=1, #h_pet do
        local petInfo = h_pet[i]

        local p
        p = BattleFuncMgr.startCreatePetCard(petInfo, 2)
        p.button:setPosition(320+55+98*(i-1),2)
        LtPickPetViewMgr.setHelpPetCard(p.button)

        petList:addChild(p.button)
        p.button:setAnchorPoint(0.5,0.0)

        if petInfo.hp <= 0 then
            CommonPetBar.makeCardGray(p, false)
        else
            CommonPetBar.makeCardGray(p, true)
        end
        p.objID = petInfo.objID
        table.insert(cards[2],p)
    end

    BattleFuncMgr.endCreatePetCard()
    
    return bottomBar, cards

end

return CommonPetBar