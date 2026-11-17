local BossTopBarMgr = {}

local resName = ""
local resNameDownBar = ""
local cacheCards = {}
local CARDS_MAX = 5
local clickedCardIndex = nil
local lastTickTime = 0

function BossTopBarMgr.Init()
    resName = "Player/Boss/BossTopBar.csb"
    resNameDownBar = "Player/Boss/BossDownBar.csb"
    cacheCards = {}
    CARDS_MAX = 5
    clickedCardIndex = nil
    lastTickTime = os.time()
end

local function tickBossProgress(bar, icon, remainTime, totalTime)
    if CSResourceMgr.getCsbObj(resName) then
        if remainTime > 0 then
            bar:setPercent(remainTime/totalTime * 100.0)
            
            bar:performWithDelay(function()
                local ct = os.time()
                local diff = ct - lastTickTime
                lastTickTime = ct
                --print("diff time=",diff)
                tickBossProgress(bar, icon, remainTime - diff, totalTime)
            end, 1)
        else
            BossMapMgr.setBossKilled(true)
            BossBattleMgr.stop()
            
            bar:setPercent(0.0)
            local actionExam = cc.TintTo:create(0.1,100,100,100)
            icon:runAction(actionExam)
            WorldBossInfo.TakeAward()
            
            local bossNode = BossMapMgr.getBossNode()
            if bossNode then
                transition.scaleTo(bossNode, {scale=-0.1,time=0.2})
                transition.fadeTo(bossNode, {opacity=100,time=0.2})
                bossNode:performWithDelay(function()
                    if SceneMgr.currentScene == "BossMapScene" then
                        --BossMapMgr.removeBoss()
                        bossNode:setVisible(false)
                        DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 1, "worldboss13", function()
                            BossTopBarMgr.hideUI()
                        end)
                    end
                end, 0.2)
            end
        end
    end
end

function BossTopBarMgr.stopTickBallProgress()
    if CSResourceMgr.getCsbObj(resNameDownBar) then
        local bar = CSResourceMgr.getNodeByName(resNameDownBar,"bar")
        bar:setPercent(0.0)
        transition.stopTarget(bar)
        BossMapMgr.forbiddenPlayerMoving(CharInfo.getCharID(), false)
        BattleUIMgr.cancelBall()
    end
end

local function checkBossFailedParams()
    BossFailedMgr.enableShow(true)
    local params = BossFailedMgr.getBossFailedParams()
    if params then
        BossFailedMgr.show(SceneMgr.getRunningScene, params.diamond, params.btnTxt1, params.btnTxt2)
    end
end

local function tickBallProgress(objID, bar, remainTime, totalTime, damage, state, restraint, successCallback, failCallback)
    if CSResourceMgr.getCsbObj(resNameDownBar) then
        if remainTime > 0 then
            BossMapMgr.forbiddenPlayerMoving(CharInfo.getCharID(), true)
            bar:setPercent(100.0 - remainTime/totalTime * 100.0)
            
            bar:performWithDelay(function()
                tickBallProgress(objID, bar, remainTime - 0.05, totalTime, damage, state, restraint, successCallback, failCallback)
            end, 0.05)
        else
            BossMapMgr.forbiddenPlayerMoving(CharInfo.getCharID(), false)
            bar:setPercent(100.0)
            --[[
            WorldBossInfo.AttackBoss(objID, damage, function()
                if successCallback then successCallback() end
                BattleUIMgr.playBall(state, function()
                    local node = BossMapMgr.getBossNode()
                    if node then
                        --print("=====showBossBattleDamage ",node, damage, restraint)
                        BattleUIMgr.showBossBattleDamage(node, damage, restraint)
                    end
                end)
                bar:setPercent(0.0)
            end, function()
                if failCallback then failCallback() end
                bar:setPercent(0.0)
            end)
            ]]
            BossFailedMgr.enableShow(false)
            WorldBossInfo.AttackBoss(objID, BossMapMgr.getPlayerOwnerGridIndex(), function()
                BattleUIMgr.playBallSucess(state, clickedCardIndex, function()
                    local node = BossMapMgr.getBossNode()
                    if node then
                        --print("=====showBossBattleDamage ",node, damage, restraint)
                        BattleUIMgr.showBossBattleDamage(node, WorldBossInfo.getDamageFromServer(), state, restraint)
                    end
                end)
                bar:setPercent(0.0)
                if successCallback then successCallback() end
                checkBossFailedParams()
            end, function()
                BattleUIMgr.playBallFail(state, clickedCardIndex)
                bar:setPercent(0.0)
                if failCallback then failCallback() end
                checkBossFailedParams()
            end)
        end
    end
end

local function initStaticData(bossID, remainTime, totalTime)
    CSResourceMgr.setLabelString(resName, "surrend", "worldboss3", nil, {r=0,g=0,b=0,a=255,w=1})
    local bossInfo = CSResourceMgr.getNodeByName(resName, "boss_info")
    if bossInfo then
        local fileName = string.format("Pet/PetIcon/%d.png", WorldBossInfo.getWorldBossInfoByID(bossID).model)
        local icon = CSResourceMgr.seekNodeByName(bossInfo, "icon")
        CSResourceMgr.setButtonTextureByNode(icon, fileName, fileName, fileName)
        icon:setScale(0.45,0.45)
        local name = CSResourceMgr.seekNodeByName(bossInfo, "name")
        --CSResourceMgr.setLabelStringByNode(name, PokemonInfo.getPokemonInfoByID(bossID).name, {r=0,g=0,b=0,a=255,w=2})
        CSResourceMgr.setLabelStringByNode(name, WorldBossInfo.getWorldBossInfoByID(bossID).bossName, {r=0,g=0,b=0,a=255,w=2})
        
        lastTickTime = os.time()
        local bar = CSResourceMgr.seekNodeByName(bossInfo, "bar")
        tickBossProgress(bar, icon, remainTime, totalTime)
    end
    
    CSResourceMgr.setLabelString(resNameDownBar, "tip1", "worldboss5", nil, {r=0,g=0,b=0,a=255,w=1})
    CSResourceMgr.setLabelString(resNameDownBar, "tip2", "worldboss6", nil, {r=0,g=0,b=0,a=255,w=1})
    --local list = CSResourceMgr.getNodeByName(resNameDownBar,"list")
    --list:setInnerContainerSize({width = list:getContentSize().width,height = list:getContentSize().height})
    --list:setDirection(cc.SCROLLVIEW_DIRECTION_NONE)
end

local function initDynamicData()
    local rank = CSResourceMgr.getNodeByName(resName, {"rank_info", "rank"})
    if rank then
        local name = CSResourceMgr.seekNodeByName(rank, "name")
        CSResourceMgr.setLabelStringByNode(name, CharInfo.getNickName(), {r=0,g=0,b=0,a=255,w=1})
        CSResourceMgr.setLabelColorByNode(name, {r=0,g=204,b=255,a=255})
        local damage = CSResourceMgr.seekNodeByName(rank, "damage")
        CSResourceMgr.setLabelStringByNode(damage, WorldBossInfo.getDamageOwner(), {r=0,g=0,b=0,a=255,w=2})
        rank.charID = CharInfo.getCharID()        
    end
end

local function fadeOutCard(cell, card, time)
    if CSResourceMgr.getCsbObj(resNameDownBar) then
        transition.fadeTo(card.button, {opacity=100,time=time})
        transition.fadeTo(card.head, {opacity=100,time=time})
        transition.fadeTo(card.headBK, {opacity=100,time=time})
        transition.fadeTo(card.level, {opacity=100,time=time})
        transition.fadeTo(card.attri, {opacity=100,time=time})
        transition.fadeTo(card.rare, {opacity=100,time=time})
        transition.fadeTo(card.str, {opacity=100,time=time})
        transition.fadeTo(CSResourceMgr.seekNodeByName(cell, "bg"), {opacity=100,time=time})
        transition.fadeTo(CSResourceMgr.seekNodeByName(cell, "icon"), {opacity=100,time=time})
        transition.fadeTo(CSResourceMgr.seekNodeByName(cell, "txt"), {opacity=100,time=time})
        for k, v in pairs(card.stars) do
            transition.fadeTo(v, {opacity=100,time=time})
        end
    end
end

local function fadeInCard(cell, card, time)
    if CSResourceMgr.getCsbObj(resNameDownBar) then
        transition.stopTarget(card.button)
        transition.fadeIn(card.button, {time=time})
        transition.stopTarget(card.head)
        transition.fadeIn(card.head, {time=time})
        transition.stopTarget(card.headBK)
        transition.fadeIn(card.headBK, {time=time})
        transition.stopTarget(card.level)
        transition.fadeIn(card.level, {time=time})
        transition.stopTarget(card.attri)
        transition.fadeIn(card.attri, {time=time})
        transition.stopTarget(card.rare)
        transition.fadeIn(card.rare, {time=time})
        transition.stopTarget(card.str)
        transition.fadeIn(card.str, {time=time})
        transition.stopTarget(CSResourceMgr.seekNodeByName(cell, "bg"))
        transition.fadeIn(CSResourceMgr.seekNodeByName(cell, "bg"), {time=time})
        transition.stopTarget(CSResourceMgr.seekNodeByName(cell, "icon"))
        transition.fadeIn(CSResourceMgr.seekNodeByName(cell, "icon"), {time=time})
        transition.stopTarget(CSResourceMgr.seekNodeByName(cell, "txt"))
        transition.fadeIn(CSResourceMgr.seekNodeByName(cell, "txt"), {time=time})
        for k, v in pairs(card.stars) do
            transition.stopTarget(v)
            transition.fadeIn(v, {time=time})
        end
    end
end

local function clickCard(list, cell, card, objID)
    local items = list:getItems()
    clickedCardIndex = 0
    for i=1, #items do
        if items[i] == cell then
            clickedCardIndex = i - 1
            break
        end
    end
    --effect
    local eff = display.newSprite("Player/Boss/card.png")
    eff:setTag(111111)
    eff:setLocalZOrder(-1)
    --eff:setAnchorPoint(1.0,1.0)
    --eff:setScale(1.2)
    eff:setPosition(45, 20)
    eff:setOpacity(0)
    cell:addChild(eff)
    transition.fadeIn(eff, {time=0.1})
    transition.moveBy(eff, {x=0, y=50, time=0.1})
    --motion
    --local nodeCard = CSResourceMgr.seekNodeByName(cell, "card")
    local originX, originY = cell:getPosition()
    transition.moveBy(cell, {x=0, y=50, time=0.1})
    transition.scaleTo(cell, {scale=1.1,time=0.1})
    --[[
    cell:performWithDelay(function()
        transition.moveBy(cell, {x=0, y=-50, time=0.05})
    end, 0.1)
    ]]
    fadeOutCard(cell, card, 2.0)
    
    local damage, state, restraint = BossBattleMgr.fight(objID)
    BattleUIMgr.playBall(state, clickedCardIndex)
    tickBallProgress(objID, CSResourceMgr.getNodeByName(resNameDownBar,"bar"), 1.2, 1.2, damage, state, restraint, function()
        if clickedCardIndex then
            GameAudio.playBattleSound("bosssucceeball")
            list:removeItem(clickedCardIndex)
            clickedCardIndex = nil
            BossTopBarMgr.refreshCandidateCards()
            BossTopBarMgr.refreshNextCard()
        end
    end, function()
        if clickedCardIndex then
            GameAudio.playBattleSound("bossfailball")
            cell:removeChildByTag(111111, true)
            local currentX, currentY = cell:getPosition()
            transition.moveBy(cell, {x=0, y=originY-currentY, time=0.05})
            transition.scaleTo(cell, {scale=1.0,time=0.05})
            cell:performWithDelay(function()
                fadeInCard(cell, card, 0.1)
                clickedCardIndex = nil
            end, 0.05)
        end
    end)
end

function BossTopBarMgr.refreshCandidateCards()
    local list = CSResourceMgr.getNodeByName(resNameDownBar,"list")
    local items = list:getItems()
    local itemsNum = #items
    if itemsNum < CARDS_MAX then
        if #cacheCards > 0 then
            for i=1, CARDS_MAX - itemsNum do
                if #cacheCards > 0 then
                    local card = BattleFuncMgr.startCreatePetCard(cacheCards[1], 3, true)
                    local cell = CSResourceMgr.getNodeByName(resNameDownBar,"btn_listexample"):clone()
                    local nodeCard = CSResourceMgr.seekNodeByName(cell, "card")
                    nodeCard:addChild(card.button)
                    local bRevived = BossMapMgr.isPetRevived()
                    if bRevived then
                        --[[
                        local effect = CSResourceMgr.createCCBI(nodeCard, "texture/ui_dc_25.ccbi", 0, 0)
                        nodeCard:performWithDelay(function()
                            nodeCard:removeChild(effect)
                        end, 1.0)
                        ]]
                        AnimationMgr.createAni(nodeCard, "Words/cn/worldboss/Bosszhan_zhanliup.png", 0, 10, "petCard"..i)
                        AnimationMgr.playAni("Words/cn/worldboss/Bosszhan_zhanliup.png", "animation", false, "petCard"..i)
                        nodeCard:performWithDelay(function()
                            AnimationMgr.removeGafObjectByTag("Words/cn/worldboss/Bosszhan_zhanliup.png", "petCard"..i)
                        end, 1.0)
                    end
                    local pokeInfo = PokemonInfo.getPokemonInfoByID(cacheCards[1].pokeID)
                    local petFC = PetEducationMgr.getPetFC(pokeInfo, cacheCards[1])
                    local txt = CSResourceMgr.seekNodeByName(cell, "txt")
                    CSResourceMgr.setLabelStringByNode(txt, petFC * (bRevived and 2 or 1), {r=0,g=0,b=0,a=255,w=1})
                    if bRevived then
                        CSResourceMgr.setLabelColorByNode(txt, {r=0,g=255,b=0,a=255})
                    end
                    local objID = cacheCards[1].objID
                    local restraint = CSResourceMgr.seekNodeByName(cell, "restraint")
                    local res = BossBattleMgr.getRestraint(objID)
                    if res == 1 then
                        restraint:setVisible(false)
                    elseif res == 2 then
                        CSResourceMgr.setSpriteTextureByNode(restraint, "Battle/downEdge_A/arrow2.png")
                    else
                        CSResourceMgr.setSpriteTextureByNode(restraint, "Battle/downEdge_A/arrow.png")
                    end
                    cell:setVisible(true)
                    CSResourceMgr.clickEventBindingByNode(card.button, function()
                        if BossMapMgr.isPlayerOwnerInSecurityRegion(BossMapMgr.getPlayerOwnerBornGridIndex()) == false then
                            if clickedCardIndex == nil then
                                clickCard(list, cell, card, objID)
                            else
                                StandardTipsMgr.show(1,"worldboss7")
                            end
                        else
                            StandardTipsMgr.show(1,"worldboss10")
                        end
                    end, 1)
                    list:pushBackCustomItem(cell)
                    table.remove(cacheCards, 1)
                else
                    break
                end
            end
            BattleFuncMgr.endCreatePetCard()
        elseif itemsNum == 0 then
            BossMapMgr.setPlayerOwnerBallsEmpty(true)
            BossFailedMgr.show(SceneMgr.getRunningScene, SystemInfo.getGlobalConfigAddInfoByID(80).values[1], "worldboss9", "worldboss2")
        end
    end
end

function BossTopBarMgr.refreshNextCard()
    local nodeNext = CSResourceMgr.getNodeByName(resNameDownBar,"next")
    local restraint = CSResourceMgr.getNodeByName(resNameDownBar, {"panel", "restraint"})
    nodeNext:removeAllChildren()
    if #cacheCards > 0 then
        local card = BattleFuncMgr.startCreatePetCard(cacheCards[1], 2)
        nodeNext:addChild(card.button)
        nodeNext:setScale(0.7,0.7)
        BattleFuncMgr.endCreatePetCard()
        nodeNext:setVisible(true)
        
        local res = BossBattleMgr.getRestraint(cacheCards[1].objID)
        if res == 1 then
            restraint:setVisible(false)
        elseif res == 2 then
            CSResourceMgr.setSpriteTextureByNode(restraint, "Battle/downEdge_A/arrow2.png")
            restraint:setVisible(true)
        else
            CSResourceMgr.setSpriteTextureByNode(restraint, "Battle/downEdge_A/arrow.png")
            restraint:setVisible(true)
        end
        restraint:setScale(0.7,0.7)
    else
        nodeNext:setVisible(false)
        restraint:setVisible(false)
    end
end

function BossTopBarMgr.createCacheCards(petList)
    --print("=====BossTopBarMgr petList=",sz_T2S(petList))
    if not CSResourceMgr.getCsbObj(resNameDownBar) then
        return
    end
    
    local list = CSResourceMgr.getNodeByName(resNameDownBar,"list")
    list:removeAllItems()
    
    cacheCards = {}
    clickedCardIndex = nil
    local cardNum = #petList
    if cardNum > 0 then
        for i=1, cardNum do
            local rand = GetRandom.random(1, #petList)
            --local card = BattleFuncMgr.startCreatePetCard(petList[rand], 2)
            table.insert(cacheCards, petList[rand])
            table.remove(petList, rand)
        end
        --BattleFuncMgr.endCreatePetCard()
        
        BossTopBarMgr.refreshCandidateCards()
        BossTopBarMgr.refreshNextCard()
    else
        BossMapMgr.setPlayerOwnerBallsEmpty(true)
    end
end

local function checkRankList(list, rankTotal)
    if not CSResourceMgr.getCsbObj(resName) then
        return
    end
    
    local rankCurrent = #(list:getItems())
    if rankCurrent < rankTotal then
        for i=1, rankTotal-rankCurrent do
            local rank = CSResourceMgr.getNodeByName(resName, {"rank_info", "rank"}):clone()
            list:pushBackCustomItem(rank)
        end
    elseif rankCurrent > rankTotal then
        for i=1, rankCurrent-rankTotal do
            list:removeItem(rankCurrent - i)
        end
    end
end

local function limitRankList(rankList)
    local total = #rankList
    if total > 10 then
        for i=1, total-10 do
            table.remove(rankList, 11)
        end
    end
end

function BossTopBarMgr.updateRank(rankList)
    if not CSResourceMgr.getCsbObj(resName) then
        return
    end
    
    local rankInfo = CSResourceMgr.getNodeByName(resName, "rank_info")
    local list = CSResourceMgr.seekNodeByName(rankInfo, "list")
    
    limitRankList(rankList)
    checkRankList(list, #rankList)
    
    local items = list:getItems()
    for i=1, #rankList do
        local rank = items[i]
        if rank then
            local name = CSResourceMgr.seekNodeByName(rank, "name")
            CSResourceMgr.setLabelStringByNode(name, i.."."..rankList[i].nickname, {r=0,g=0,b=0,a=255,w=1})
            if rankList[i].charID == CharInfo.getCharID() then
                CSResourceMgr.setLabelColorByNode(name, {r=0,g=204,b=255,a=255})
            else
                CSResourceMgr.setLabelColorByNode(name, {r=255,g=255,b=255,a=255})
            end
            local damage = CSResourceMgr.seekNodeByName(rank, "damage")
            CSResourceMgr.setLabelStringByNode(damage, rankList[i].damage, {r=0,g=0,b=0,a=255,w=2})
            rank.charID = rankList[i].charID
            local top = CSResourceMgr.seekNodeByName(rank, "top")
            top:setVisible(i==1)
            if i==1 then
                local top = CSResourceMgr.getNodeByName(resName, {"rank_info", "rank", "top"})
                top:setVisible(rankList[i].charID == CharInfo.getCharID())
            end
        end
    end
    list:setVisible(#rankList > 0)
    rankInfo:performWithDelay(function()
        WorldBossInfo.GetDamageRank()
    end, 15.0)
end

function BossTopBarMgr.updateOwnerDamage()
    if CSResourceMgr.getCsbObj(resName) then
        local damage = CSResourceMgr.getNodeByName(resName, {"rank_info", "rank", "damage"})
        local currentDamage = tonumber(damage:getString())
        CSResourceMgr.setLabelStringByNode(damage, currentDamage + WorldBossInfo.getDamageFromServer(), {r=0,g=0,b=0,a=255,w=2})
    end
end

function BossTopBarMgr.hideUI()
    BossMapMgr.cleanLocalBossMapInfo()
    if CSResourceMgr.getCsbObj(resName) then
        CSResourceMgr.removeCSObjectByTag(resName)
        CSResourceMgr.removeCSObjectByTag(resNameDownBar)
    end
    if SceneMgr.currentScene == "BossMapScene" then
        SceneMgr.replaceScene(SceneMgr.getRunningScene, "TownScene")
    end
end

function BossTopBarMgr.show(scene, bossID, remainTime, totalTime, petList)
    if CSResourceMgr.getCsbObj(resName) then
        return
    end
    
    local function loadCSB()
        local curLayer = CSResourceMgr.createRes(scene, resName)
        CSResourceMgr.setFullScreen(resName)
        CocosModuleMgr.setEdgeDistance(curLayer, nil, nil, 0, nil, false)
        --curLayer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        
        curLayer = CSResourceMgr.createRes(scene, resNameDownBar)
        curLayer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CocosModuleMgr.setEdgeDistance(curLayer, 0, nil, nil, 0, false)
        curLayer:setVisible(false)

        CSResourceMgr.clickEventBinding(resName, "close", function()
            DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 2, "worldboss4", function()
                BossTopBarMgr.hideUI()
            end)
        end)
        
        initStaticData(bossID, remainTime, totalTime)
        
        initDynamicData()
        
        if #petList > 0 then
            BossMapMgr.setPlayerOwnerBallsEmpty(false)
            BossTopBarMgr.createCacheCards(petList)
        else
            BossMapMgr.setPlayerOwnerBallsEmpty(true)
            DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 1, "worldboss11", function()
                BossTopBarMgr.hideUI()
            end)
        end
    end
    
    local function playCSB()
        CSResourceMgr.getCsbObj(resNameDownBar):setVisible(true)
        CocosModuleMgr.showUIAnimation(CSResourceMgr.getCsbObj(resNameDownBar), "up")
    end
    
    loadCSB()
    playCSB()
end

return BossTopBarMgr