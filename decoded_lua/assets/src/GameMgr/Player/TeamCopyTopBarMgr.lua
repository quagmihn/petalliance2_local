local TeamCopyTopBarMgr = {}

local resName = ""
local armyPetOwner = nil
local armyPetPlayer1 = nil
local armyPetPlayer2 = nil
local petCardsPlayer1 = {}
local petCardsPlayer2 = {}

function TeamCopyTopBarMgr.Init()
    resName = "Player/Team/TeamCopyTopBar.csb"
    armyPetOwner = nil
    armyPetPlayer1 = nil
    armyPetPlayer2 = nil
    petCardsPlayer1 = {}
    petCardsPlayer2 = {}
end

local function initStaticData(copyID, revivalNum)
    if copyID then
        local floorInfo = TeamMapInfo.getTeamFloorInfoById(copyID)
        CSResourceMgr.setLabelString(resName, "mapName", floorInfo.name, nil, {r=0,g=0,b=0,a=255,w=1})
    end
    
    CSResourceMgr.setLabelString(resName, "boss_txt", "team42", nil, {r=0,g=0,b=0,a=255,w=1})
    
    local pic = TeamMapInfo.getTeamItemInfoById(1).picRes
    CSResourceMgr.setButtonTexture(resName, "revival_icon", pic, pic, pic)
    TeamCopyTopBarMgr.updateRevivalNum(revivalNum)
end

local function getPetByObjID(mPets, hPets, ObjID)
    if mPets then
        for i=1,#mPets do
            if mPets[i].objID == ObjID then
                return mPets[i]
            end
        end
    end
    
    if hPets then
        for i=1,#hPets do
            if hPets[i].objID == ObjID then
                return hPets[i]
            end
        end
    end
    
    return nil
end

local function changeOwnerArmyPet()
    local m, h = CommonPetBar.getCurrentArmy()
    TeamCopyInfo.ChangeArmyPet(m, h)
    print("=================changeOwnerArmyPet army=",sz_T2S(m),sz_T2S(h))
    
    if armyPetOwner then
        local mPets = {}
        local hPets = {}
        
        for i=1,#m do
            local p = getPetByObjID(armyPetOwner[1], armyPetOwner[2], m[i])
            if p then
                table.insert(mPets, p)
            end
        end
        
        for i=1,#h do
            local p = getPetByObjID(armyPetOwner[1], armyPetOwner[2], h[i])
            if p then
                table.insert(hPets, p)
            end
        end
        --print("help pets before=",sz_T2S(armyPetOwner[2]))
        armyPetOwner = {}
        armyPetOwner[1] = mPets
        armyPetOwner[2] = hPets
        --print("help pets after=",sz_T2S(armyPetOwner[2]))
        TeamCopyMapMgr.updateLocalMembersPets(CharInfo.getCharID(), mPets, hPets)
    end
end

local function setMiniCardState(card, hpPercent, tag, bNeedPlayEff)
    if card then
        local hpBar = CSResourceMgr.seekNodeByName(card, "bar")
        local oldPercent = hpBar:getPercent()
        hpBar:setPercent(hpPercent)
        
        local red = 255
        local green = 255
        local blue = 255
        if hpPercent < 0.001 then
            red = 100
            green = 100
            blue = 100
        elseif bNeedPlayEff == true and hpPercent > 99.999 and oldPercent < 0.001 then
            local eff = AnimationMgr.createAni(card,"Spine/effects/Ui_chongwuhuixue.png",20,25,tag)
            eff:setScale(0.5,0.5)
            AnimationMgr.playAniWithCallback(eff.res, "animation", nil, eff.tag, true)
        end
        -- transition.stopTarget(card)
        local actionExam = cc.TintTo:create(0.1,red,green,blue)
        card:runAction(actionExam)
    end
end

local function refreshMiniCardPets(player, armyPet, tag)
    for idx = 1, #armyPet.m_pets do
        local pet = armyPet.m_pets[idx]
        local petInfo = PokemonInfo.getPokemonInfoByID(pet.pokeID)
        local rareRes = BattleFuncMgr.getStagePics(petInfo.rarePoint)
        local petCard = CSResourceMgr.seekNodeByName(player, "pet_"..idx)
        CSResourceMgr.setSpriteTextureByNode(petCard, rareRes.p1)
        petCard:setVisible(true)
        local icon = CSResourceMgr.seekNodeByName(petCard, "icon")
        CSResourceMgr.setSpriteTextureByNode(icon, PokemonInfo.getPokemonIconByID(pet.pokeID))
        icon:setScale(0.3, 0.3)

        local maxHp = pet.hpmax
        local hp = pet.hp
        setMiniCardState(petCard, hp/maxHp * 100.0, tag.."_minicard"..idx, false)
    end
end

function TeamCopyTopBarMgr.changePlayerArmyPet(armyInfo)
    if armyInfo then
        local m = armyInfo.pets or {}
        local h = armyInfo.helperPets or {}
        
        if armyInfo.charID == (armyPetPlayer1 and armyPetPlayer1.charID or 0) then
            if armyPetPlayer1 then
                local mPets = {}
                local hPets = {}
                
                for i=1,#m do
                    local p = getPetByObjID(armyPetPlayer1.m_pets, armyPetPlayer1.h_pets, m[i])
                    if p then
                        table.insert(mPets, p)
                    end
                end
                
                for i=1,#h do
                    local p = getPetByObjID(armyPetPlayer1.m_pets, armyPetPlayer1.h_pets, h[i])
                    if p then
                        table.insert(hPets, p)
                    end
                end
                
                --armyPetPlayer1 = {}
                armyPetPlayer1.m_pets = mPets
                armyPetPlayer1.h_pets = hPets
                TeamCopyMapMgr.updateLocalMembersPets(armyInfo.charID, mPets, hPets)
                
                --update cards
                if SceneMgr.currentScene == "TeamCopyMapScene" and CSResourceMgr.getCsbObj(resName) then
                    local newArmyPet = {[1] = m, [2] = h}
                    petCardsPlayer1 = CommonPetBar.updateTeamBoard(petCardsPlayer1, newArmyPet)
                    
                    local player = CSResourceMgr.getNodeByName(resName, "player_1")
                    refreshMiniCardPets(player, armyPetPlayer1, "player_1")
                end
            end
        elseif armyInfo.charID == (armyPetPlayer2 and armyPetPlayer2.charID or 0) then
            if armyPetPlayer2 then
                local mPets = {}
                local hPets = {}
                
                for i=1,#m do
                    local p = getPetByObjID(armyPetPlayer2.m_pets, armyPetPlayer2.h_pets, m[i])
                    if p then
                        table.insert(mPets, p)
                    end
                end

                for i=1,#h do
                    local p = getPetByObjID(armyPetPlayer2.m_pets, armyPetPlayer2.h_pets, h[i])
                    if p then
                        table.insert(hPets, p)
                    end
                end
                
                --armyPetPlayer2 = {}
                armyPetPlayer2.m_pets = mPets
                armyPetPlayer2.h_pets = hPets
                TeamCopyMapMgr.updateLocalMembersPets(armyInfo.charID, mPets, hPets)
                
                --update cards
                if SceneMgr.currentScene == "TeamCopyMapScene" and CSResourceMgr.getCsbObj(resName) then
                    local newArmyPet = {[1] = m, [2] = h}
                    petCardsPlayer2 = CommonPetBar.updateTeamBoard(petCardsPlayer2, newArmyPet)
                    
                    local player = CSResourceMgr.getNodeByName(resName, "player_2")
                    refreshMiniCardPets(player, armyPetPlayer2, "player_2")
                end
            end
        end
    end
end

local function initOwnerDynamicData(armyPet)
    armyPetOwner = nil
    
    if armyPet then
        armyPetOwner = armyPet
        print("==========CommonPetBar.show armyPetOwner=",armyPetOwner and sz_T2S(armyPetOwner) or armyPetOwner)
        CommonPetBar.show(SceneMgr.getRunningScene, armyPet, nil, changeOwnerArmyPet)
    else
        CommonPetBar.show(SceneMgr.getRunningScene, {[1] = {}, [2] = {}})
    end
end

local function addTeamBoard(player, armyPet, playerTag)
    local name = CSResourceMgr.seekNodeByName(player, "name")
    CSResourceMgr.setLabelStringByNode(name, armyPet.playername, {r=0,g=0,b=0,a=255,w=1})
    local petPanel = CSResourceMgr.seekNodeByName(player, "petPanel")
    local petNode = CSResourceMgr.seekNodeByName(petPanel, "petNode")
    --print("==========CommonPetBar.createTeamBoard armyPetPlayer1=",armyPetPlayer1 and sz_T2S(armyPetPlayer1) or armyPetPlayer1)
    local petBar, petCards = CommonPetBar.createTeamBoard(armyPet, playerTag)
    petBar:addTo(petNode)
    petBar:setPosition(-320, -90)
    --petPanel:setScale(0.0, 0.0)
    petPanel:setVisible(false)
    player:setVisible(true)

    refreshMiniCardPets(player, armyPet, playerTag)
    return petCards
end

local function initPlayerDynamicData(armyPet1, armyPet2)
    armyPetPlayer1 = nil
    armyPetPlayer2 = nil
    petCardsPlayer1 = {}
    petCardsPlayer2 = {}
    
    if armyPet1 then
        armyPetPlayer1 = armyPet1
        local player = CSResourceMgr.getNodeByName(resName, "player_1")
        petCardsPlayer1 = addTeamBoard(player, armyPet1, "player_1")
    end
    
    if armyPet2 then
        armyPetPlayer2 = armyPet2
        local player = CSResourceMgr.getNodeByName(resName, "player_2")
        petCardsPlayer2 = addTeamBoard(player, armyPet2, "player_2")
    end
end

function TeamCopyTopBarMgr.addPlayerDynamicData(armyPetPlayer)
    if armyPetPlayer then
        if armyPetPlayer1 == nil then
            armyPetPlayer1 = armyPetPlayer
            local player = CSResourceMgr.getNodeByName(resName, "player_1")
            petCardsPlayer1 = addTeamBoard(player, armyPetPlayer, "player_1")
        elseif armyPetPlayer2 == nil then
            armyPetPlayer2 = armyPetPlayer
            local player = CSResourceMgr.getNodeByName(resName, "player_2")
            petCardsPlayer2 = addTeamBoard(player, armyPetPlayer, "player_2")
        end
    end
end

function TeamCopyTopBarMgr.hideUI()
    TeamCopyMapMgr.cleanLocalCopyMapInfo()
    TeamCopyInfo.LeaveTeamCopy()
    if CSResourceMgr.getCsbObj(resName) then
        CSResourceMgr.removeCSObjectByTag(resName)
    end
    TownChatMgr.isTeamChat(false)
    --TownChatMgr.teamBattleChat(false)
    TownChatMgr.setExitTeamBattle()
    SceneMgr.replaceScene(SceneMgr.getRunningScene, "TownScene")
end

local function clickRevivalIcon()
    StandardTipsMgr.show(1, "team55")
end

local function togglePetPanel(player1, player2, playerIndex)
    if player1 and player2 then
        local petPanel1 = CSResourceMgr.seekNodeByName(player1,"petPanel")
        local petPanel2 = CSResourceMgr.seekNodeByName(player2,"petPanel")
        
        if playerIndex == 1 then
            --[[
            if petPanel1:getScaleX() < 1.0 then
                transition.scaleTo(petPanel1,{scaleX=1.0,scaleY=1.0,time=0.1})
            else
                transition.scaleTo(petPanel1,{scaleX=0.0,scaleY=0.0,time=0.1})
            end
            
            if petPanel2:getScaleX() > 0.0 then
                petPanel2:setScale(0.0, 0.0)
                --transition.scaleTo(petPanel2,{scaleX=0.0,scaleY=0.0,time=0.05})
            end
            ]]
            petPanel1:setVisible(not petPanel1:isVisible())
            petPanel2:setVisible(false)
        else
            --[[
            if petPanel2:getScaleX() < 1.0 then
                transition.scaleTo(petPanel2,{scaleX=1.0,scaleY=1.0,time=0.1})
            else
                transition.scaleTo(petPanel2,{scaleX=0.0,scaleY=0.0,time=0.1})
            end
            
            if petPanel1:getScaleX() > 0.0 then
                petPanel1:setScale(0.0, 0.0)
                --transition.scaleTo(petPanel1,{scaleX=0.0,scaleY=0.0,time=0.05})
            end
            ]]
            petPanel2:setVisible(not petPanel2:isVisible())
            petPanel1:setVisible(false)
        end
    end
end

function TeamCopyTopBarMgr.show(scene, copyID, armyPet, armyPet1, armyPet2, revivalNum)
    if CSResourceMgr.getCsbObj(resName) then
        CSResourceMgr.removeCSObjectByTag(resName)
    end
    
    local function loadCSB()
        local curLayer = CSResourceMgr.createRes(scene, resName)
        CSResourceMgr.setFullScreen(resName)
        CocosModuleMgr.setEdgeDistance(curLayer, nil, nil, 0, nil, false)
        curLayer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)

        CSResourceMgr.clickEventBinding(resName, "close", function()
            DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 2, "team34", function()
                TeamCopyTopBarMgr.hideUI()
            end)
        end)

        CSResourceMgr.clickEventBinding(resName, "player_1", function()
        end)
        
        CSResourceMgr.clickEventBinding(resName, "revival_icon", function()
            clickRevivalIcon()
        end, nil, 3)
        
        local player1 = CSResourceMgr.getNodeByName(resName, "player_1")
        local player2 = CSResourceMgr.getNodeByName(resName, "player_2")
        
        CSResourceMgr.clickEventBindingByNode(player1, function()
            togglePetPanel(player1, player2, 1)
        end)
        
        CSResourceMgr.clickEventBindingByNode(player2, function()
            togglePetPanel(player1, player2, 2)
        end)

        initStaticData(copyID, revivalNum)

        initOwnerDynamicData(armyPet)
        
        initPlayerDynamicData(armyPet1, armyPet2)
        
        local chatBubble = CSResourceMgr.getNodeByName(resName, "chat")
        TownChatMgr.addChatIcon(chatBubble, 1)
    end

    loadCSB()
end

function TeamCopyTopBarMgr.showBoss()
    if CSResourceMgr.getCsbObj(resName) then
        --print("TeamCopyTopBarMgr.showBoss")
        GameAudio.pauseMusic()
        GameAudio.playUISound("bossAlert")
        local node = CSResourceMgr.getNodeByName(resName, "boss")
        node:setVisible(true)
        node:setOpacity(0)
        transition.fadeIn(node, {time=0.4})
        node:performWithDelay(function()
            transition.fadeOut(node, {time=0.4})
            node:performWithDelay(function()
                transition.fadeIn(node, {time=0.4})
                node:performWithDelay(function()
                    transition.fadeOut(node, {time=0.4})
                    node:performWithDelay(function()
                        transition.fadeIn(node, {time=0.4})
                        node:performWithDelay(function()
                            transition.fadeOut(node, {time=0.4})
                            node:performWithDelay(function()
                                node:setVisible(false)
                                GameAudio.resumeMusic()
                            end,0.4)
                        end,0.4)
                    end,0.4)
                end,0.4)
            end,0.4)
        end,0.4)
    end
end

function TeamCopyTopBarMgr.updateBossInfo(num, maxNum)
    if CSResourceMgr.getCsbObj(resName) then
        CSResourceMgr.setLabelString(resName, {"boss_info", "num"}, CocosModuleMgr.createStringWithFormat({"team43", num, maxNum}), nil, {r=0,g=0,b=0,a=255,w=1})
        local bar = CSResourceMgr.getNodeByName(resName, {"boss_info", "bar"})
        bar:setPercent(num/maxNum * 100.0)
    end
end

function TeamCopyTopBarMgr.updateRevivalNum(num)
    if CSResourceMgr.getCsbObj(resName) then
        CSResourceMgr.setLabelString(resName, "revival_num", "X"..num, nil, {r=0,g=0,b=0,a=255,w=1})
    end
end

function TeamCopyTopBarMgr.updatePetsHpPercent(hpInfo)
    if CSResourceMgr.getCsbObj(resName) then
        if hpInfo then
            if hpInfo.charID == CharInfo.getCharID() then
                if armyPetOwner then
                    for i=1, #hpInfo.pets do
                        local objID = hpInfo.pets[i].objID
                        local mPets = armyPetOwner[1]
                        for j=1, #mPets do
                            if mPets[j].objID == objID then
                                local maxHp = mPets[j].hpmax
                                local hp = hpInfo.pets[i].hp
                                mPets[j].hp = hp
                                local mPetNodes, hPetNodes = CommonPetBar.getPetNodes()
                                --CommonPetBar.getPetHPBar(mPetNodes[j]):setPercent(hp/maxHp * 100.0)
                                CommonPetBar.updateCardInfo(mPetNodes[j].parent, hp/maxHp * 100.0, "owner_mpets"..j)
                                break
                            end
                        end
                        
                        local hPets = armyPetOwner[2]
                        for j=1, #hPets do
                            if hPets[j].objID == objID then
                                local maxHp = hPets[j].hpmax
                                local hp = hpInfo.pets[i].hp
                                hPets[j].hp = hp
                                local mPetNodes, hPetNodes = CommonPetBar.getPetNodes()
                                --CommonPetBar.getPetHPBar(mPetNodes[j]):setPercent(hp/maxHp * 100.0)
                                CommonPetBar.updateCardInfo(hPetNodes[j].parent, hp/maxHp * 100.0, "owner_hpets"..j)
                                break
                            end
                        end
                    end
                end
            elseif hpInfo.charID == (armyPetPlayer1 and armyPetPlayer1.charID or 0) then
                if armyPetPlayer1 then
                    for i=1, #hpInfo.pets do
                        local objID = hpInfo.pets[i].objID
                        local mPets = armyPetPlayer1.m_pets
                        for j=1, #mPets do
                            if mPets[j].objID == objID then
                                local maxHp = mPets[j].hpmax
                                local hp = hpInfo.pets[i].hp
                                mPets[j].hp = hp
                                CommonPetBar.updateCardInfo(petCardsPlayer1[1][j], hp/maxHp * 100.0, "player_1_mpets"..j)
                                
                                local player = CSResourceMgr.getNodeByName(resName, "player_1")
                                local petCard = CSResourceMgr.seekNodeByName(player, "pet_"..j)
                                setMiniCardState(petCard, hp/maxHp * 100.0, "player_1_minicard"..j, true)
                                break
                            end
                        end
                        
                        local hPets = armyPetPlayer1.h_pets
                        for j=1, #hPets do
                            if hPets[j].objID == objID then
                                local maxHp = hPets[j].hpmax
                                local hp = hpInfo.pets[i].hp
                                hPets[j].hp = hp
                                CommonPetBar.updateCardInfo(petCardsPlayer1[2][j], hp/maxHp * 100.0, "player_1_hpets"..j)
                                break
                            end
                        end
                    end
                end
            elseif hpInfo.charID == (armyPetPlayer2 and armyPetPlayer2.charID or 0) then
                if armyPetPlayer2 then
                    for i=1, #hpInfo.pets do
                        local objID = hpInfo.pets[i].objID
                        local mPets = armyPetPlayer2.m_pets
                        for j=1, #mPets do
                            if mPets[j].objID == objID then
                                local maxHp = mPets[j].hpmax
                                local hp = hpInfo.pets[i].hp
                                mPets[j].hp = hp
                                CommonPetBar.updateCardInfo(petCardsPlayer2[1][j], hp/maxHp * 100.0, "player_2_mpets"..j)
                                
                                local player = CSResourceMgr.getNodeByName(resName, "player_2")
                                local petCard = CSResourceMgr.seekNodeByName(player, "pet_"..j)
                                setMiniCardState(petCard, hp/maxHp * 100.0, "player_2_minicard"..j, true)
                                break
                            end
                        end
                        
                        local hPets = armyPetPlayer2.h_pets
                        for j=1, #hPets do
                            if hPets[j].objID == objID then
                                local maxHp = hPets[j].hpmax
                                local hp = hpInfo.pets[i].hp
                                hPets[j].hp = hp
                                CommonPetBar.updateCardInfo(petCardsPlayer2[2][j], hp/maxHp * 100.0, "player_2_hpets"..j)
                                break
                            end
                        end
                    end
                end
            end
        end
    end
end

function TeamCopyTopBarMgr.removePlayerTeamBoard(charID)
    if charID and CSResourceMgr.getCsbObj(resName) then
        if charID == (armyPetPlayer1 and armyPetPlayer1.charID or 0) then
            local player = CSResourceMgr.getNodeByName(resName, "player_1")
            player:setVisible(false)
        elseif charID == (armyPetPlayer2 and armyPetPlayer2.charID or 0) then
            local player = CSResourceMgr.getNodeByName(resName, "player_2")
            player:setVisible(false)
        end
    end
end

return TeamCopyTopBarMgr