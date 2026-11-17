function GameGuideMgr.createChar()
    SceneMgr.replaceScene(SceneMgr.getRunningScene, "CreateCharScene")
end

function GameGuideMgr.getPet()
    local function getPet(npcVec)        
        MapSeekerMgr.autoSeekPath("TownScene", npcVec.srh, function()
            CocosModuleMgr.setScreenTouch(true)
            NpcDialogueMgr.show(2, function()
                CocosModuleMgr.setScreenTouch(false)
                NpcMgr.moveNPC(GameGuideMgr.NPC_NAME[1], 300, function()
                    npcVec.node:setVisible(false)
                end)
                MapSeekerMgr.autoSeekPath("TownScene", "b2", function()
                    MapSeekerMgr.SeekFunc = function()
                        NpcMgr.addNPC(4, GameGuideMgr.NPC_NAME[1], GameGuideMgr.NPC_POSX[2], nil).ani:setScaleX(1)
                        TownMapMgr.Pet:setVisible(false)
                        CocosModuleMgr.setScreenTouch(false)
                        MapSeekerMgr.autoSeekPath("LabScene", "trainstone", function()
                            CocosModuleMgr.setScreenTouch(true) 
                            NpcDialogueMgr.show(3, function()
                                SceneMgr.mapEnterType = 99
                                BattleMapMgr.firstBattleShow()
                            end)
                        end)
                    end
                    local barBtn = CSResourceMgr.getNodeByName("Map/TownMap/town_01.csb", "b2")
                    CocosModuleMgr.setButtonGuide(barBtn, 2.5)
                end)
            end)
        end)
    end
    MapSeekerMgr.SeekFunc = function()
        GameGuideMgr.originalGuideStart = false
        TownMapMgr.Pet:setVisible(false)
        CocosModuleMgr.setScreenTouch(false)
        local npcVec = NpcMgr.addNPC(4, GameGuideMgr.NPC_NAME[1], GameGuideMgr.NPC_POSX[1], nil)
        -- if LuaSqlite.LANG_TYPE==1 then
        --     NpcMgr.addNPC(998, GameGuideMgr.NPC_NAME[2], 1600, nil)
        --     NpcDialogueMgr.show(8, function()
        --         getPet(npcVec)
        --     end)
        -- else
            getPet(npcVec)
        -- end
    end
    SceneMgr.mapEnterType = 3
    GameGuideMgr.originalGuideStart = true
    SceneMgr.replaceScene(SceneMgr.getRunningScene, "TownScene")
end

function GameGuideMgr.firstPet()
    --进度完成
    print("####新手引导1，获得第一只宠物")
    GameGuideMgr.finishProcess()
    if TownMapMgr.Pet then
        TownMapMgr.Pet:setVisible(true)
    end
end

function GameGuideMgr.firstBattle()
    local function firstBattle()
        print("####新手引导2，战斗练习")
        local npcVec = NpcMgr.addNPC(4, GameGuideMgr.NPC_NAME[1], GameGuideMgr.NPC_POSX[2], nil)
        npcVec.ani:setScaleX(1)
        CocosModuleMgr.setScreenTouch(true)
        NpcDialogueMgr.show(5, function()
            NpcMgr.moveNPC(GameGuideMgr.NPC_NAME[1], -250, function()
                npcVec.node:setVisible(false)
            end)
            local step1 = CSResourceMgr.getNodeByName("Map/TownMap/lab_01.csb", "step1")
            step1:setVisible(true)
            CocosModuleMgr.setButtonGuide(step1, 2.5, function()
                CocosModuleMgr.setScreenTouch(false)
                MapSeekerMgr.autoSeekPath("LabScene", "step1", function()
                    CocosModuleMgr.setScreenTouch(true)
                    local step2 = CSResourceMgr.getNodeByName("Map/TownMap/lab_01.csb", "step2")
                    step2:setVisible(true)
                    CocosModuleMgr.setButtonGuide(step2, 2.5, function()
                        CocosModuleMgr.setScreenTouch(false)
                        MapSeekerMgr.autoSeekPath("LabScene", "step2", function()
                            CocosModuleMgr.setScreenTouch(true)
                            local step3 = CSResourceMgr.getNodeByName("Map/TownMap/lab_01.csb", "step3")
                            step3:setVisible(true)
                            CocosModuleMgr.setButtonGuide(step3, 2.5, function()
                                CocosModuleMgr.setScreenTouch(false)
                                MapSeekerMgr.autoSeekPath("LabScene", "step3", nil)
                                MapSeekerMgr.SeekFunc = function()
                                    CocosModuleMgr.setScreenTouch(false)
                                    local npcVec = NpcMgr.addNPC(4, GameGuideMgr.NPC_NAME[1], GameGuideMgr.NPC_POSX[1], nil)
                                    MapSeekerMgr.autoSeekPath("TownScene", npcVec.srh, function()
                                        TownMapMgr.Player:setScaleX(1)
                                        TownMapMgr.PlayerNameLabel:setScale(1)
                                        CocosModuleMgr.setScreenTouch(true)
                                        NpcDialogueMgr.show(30004, function()
                                            BattleUIMgr.firstBattle = 1
                                            local function callFunc(detail)
                                                
                                                BattleMapMgr.sendGameOver(detail.result,detail.me)
                                                --进度完成 
                                                -- GameGuideMgr.sendQuestFinished() 
                                                GameGuideMgr.finishProcess() 
                                                CocosModuleMgr.setScreenTouch(true)
                                                MapSeekerMgr.SeekFunc = function()
                                                    GameGuideMgr.checkProcess()
                                                    NpcMgr.addNPC(4, GameGuideMgr.NPC_NAME[1], GameGuideMgr.NPC_POSX[1], nil)
                                                end
                                            end

                                            local function guideOne()  
                                                BattleUIMgr.setStopAction(false)
                                                SceneMgr.getRunningScene:performWithDelay(function()
                                                    BattleCCSB.UPBLOOD.guidePet:show()
                                                    CocosModuleMgr.setButtonGuide(BattleCCSB.UPBLOOD.guidePet, 2.5, function()
                                                        BattleCCSB.UPBLOOD.guidePet:hide()
                                                        NpcDialogueMgr.show(1314, function()
                                                            SceneMgr.getRunningScene:performWithDelay(function()
                                                                BattleCCSB.DOWNBLOOD.guidePet:show()
                                                                CocosModuleMgr.setButtonGuide(BattleCCSB.DOWNBLOOD.guidePet, 2.5, function()
                                                                    BattleCCSB.DOWNBLOOD.guidePet:hide()
                                                                    NpcDialogueMgr.show(1315, function()
                                                                        CocosModuleMgr.setButtonGuide(BattleCCSB.DOWNEDGE.enerGuide, 2.5, function()
                                                                                NpcDialogueMgr.show(1034, function()
                                                                                        BattleCotroller.judgeNextBattle()
                                                                                    end)
                                                                            end)
                                                                    end)
                                                                end)
                                                            end, 0.5)
                                                        end)
                                                    end)
                                                end, 0.5)

                                                BattleGuide.isGuide = true
                                                BattleGuide.funcs[GUIDE_FIRST] = nil
                                            end

                                            local function guideFour()
                                                
                                                if BattleCCSB.DOWNEDGE.angersNum >= BattleCCSB.DOWNEDGE.angersNumMax then
                                                    BattleUIMgr.setStopAction(false)
                                                    NpcDialogueMgr.show(1037, function()
                                                        BattleUIMgr.setStopAction(true) 
                                                        CocosModuleMgr.setButtonGuide(BattleCCSB.DOWNEDGE.skillBtn[4], 2.5, function()
                                                            end)
                                                    end)
                                                    BattleGuide.funcs[GUIDE_SECOND] = nil
                                                end
                                            end

                                            local function guideThree()
                                                if BattleCCSB.DOWNEDGE.energiesNum >= GUIDE_ENERGY_MAX_2 then
                                                    BattleUIMgr.setStopAction(false)
                                                    NpcDialogueMgr.show(1035, function()
                                                            BattleUIMgr.setStopAction(true) 
                                                            BattleGuide.funcs[GUIDE_SECOND] = guideFour
                                                            CocosModuleMgr.setButtonGuide(BattleCCSB.DOWNEDGE.skillBtn[2], 2.5, function()
                                                                end)
                                                        end)
                                                    
                                                end
                                            end

                                            local function guideTwo()
                                                    BattleUIMgr.setStopAction(false)
                                                    NpcDialogueMgr.show(1036, function() 
                                                            BattleUIMgr.setStopAction(true)
                                                            -- BattleCotroller.judgeNextBattle()
                                                            CocosModuleMgr.setButtonGuide(BattleCCSB.DOWNEDGE.skillBtn[1], 1.0, function()
                                                                    BattleGuide.funcs[GUIDE_SECOND] = guideThree
                                                                end)
                                                        end)

                                            end

                                            BattleGuide.funcs[GUIDE_FIRST]  = guideOne
                                            BattleGuide.funcs[GUIDE_SECOND] = guideTwo 
                                            BattleCCSB.stopAutoBattle()
                                            local info  = {true,{name = "敌人", type = Proto.BTT_MONSTER_MAN_GROUP,
                                                pets = {1}, seniorFigure = 4, GroupID = 99998, callback = callFunc}}
                                            BattleMapMgr.sendReBattleServe(info)
                                        end)
                                    end)
                                end
                            end)
                        end)
                    end)
                end)
            end)
        end)
    end
    GameGuideMgr.checkScene("LabScene", firstBattle)
end

function GameGuideMgr.firstAdventure()
    local nodeID = 2
    local function firstAdventure()
        print("####新手引导3，副本冒险")
        NpcMgr.addNPC(4, GameGuideMgr.NPC_NAME[1], GameGuideMgr.NPC_POSX[1], nil)
        --NpcMgr.addMood(GameGuideMgr.NPC_NAME[1], 1)
        local goOut = CSResourceMgr.getNodeByName("Charactor/Menu/MainMenu.csb", "b5")
        CSResourceMgr.setSpriteTexture("Charactor/Menu/MainMenu.csb", "bb5", "UI/CommonFiles/anniu1.png")
        NpcDialogueMgr.show(30005, function()
            CocosModuleMgr.setScreenTouch(false)
            NpcMgr.moveNPC(GameGuideMgr.NPC_NAME[1], 350)
            MapSeekerMgr.autoSeekPath("TownScene", "guide", function()
                CocosModuleMgr.setScreenTouch(true)
                CocosModuleMgr.playVideo("Video/take1.mp4", function()
                    SceneMgr.replaceScene(SceneMgr.getRunningScene, "MainScene")
                end,false,true)
                MapSeekerMgr.SeekFunc = function()
                    local pNode = WorldMapMgr.getMapPointNode(nodeID)
                    CocosModuleMgr.showUnlockAnimation(pNode, function()
                        NpcDialogueMgr.show(11, function()
                            NpcDialogueMgr.show(45, function()
                                if CharInfo.getLevel()>=2 then
                                    --进度完成
                                    GameGuideMgr.finishProcess()
                                else
                                    CocosModuleMgr.setButtonGuide(pNode, 2.5, function()
                                        local function guideFunc()
                                            local closeBtn = CSResourceMgr.getNodeByName("Searching/advConfirm/advConfirmNewUIC.csb", "TanSuoBtn")
                                            CocosModuleMgr.setButtonGuide(closeBtn, 2.5, function()
                                                SearchingMgr.adventureGuide(function()
                                                    MapSeekerMgr.SeekFunc = function()
                                                        --进度完成
                                                        GameGuideMgr.finishProcess()
                                                    end
                                                end)
                                            end)
                                        end
                                        local go = CSResourceMgr.getNodeByName("Map/WorldMap/MoveTips.csb", "go")
                                        if go then
                                            CocosModuleMgr.setButtonGuide(go, 2.5, function()
                                                CocosModuleMgr.setScreenTouch(false)
                                                WorldMapMgr.setMapMoveFinishFunc(function()
                                                    CocosModuleMgr.setScreenTouch(true)
                                                    guideFunc()
                                                end)
                                            end)
                                        else
                                            guideFunc()
                                        end
                                    end)
                                    WorldMapMgr.locateToPoint(nodeID)
                                end
                            end)
                        end)
                    end, 2)
                end
            end)
        end)
    end
    GameGuideMgr.checkScene("TownScene", firstAdventure)
end

function GameGuideMgr.firstMission()
    local function clickMission()
        print("####新手引导4，交任务")
        local missionbtn = CSResourceMgr.getNodeByName("Charactor/extendLayer.csb", "Button_rw")
        MissionListMgr.setTab(1)
        CocosModuleMgr.showUnlockAnimation(missionbtn, function()
            CocosModuleMgr.setButtonGuide(missionbtn, 3.5, function()
                CocosModuleMgr.setScreenTouch(false)
                UnblockLoader.addCallback("MissionListMgr.setTabA", function()
                    CocosModuleMgr.setScreenTouch(true)
                    local list = CSResourceMgr.getNodeByName("Player/MissionTabA.csb", "list")
                    local item = list:getItem(0)
                    local clickbtn = CSResourceMgr.seekNodeByName(item, "clain")
                    local function closeFunc()
                        local closebtn = CSResourceMgr.getNodeByName("Charactor/TopInfoLayer.csb", "close")
                        CocosModuleMgr.setButtonGuide(closebtn, 3.5, function()
                            --进度完成
                            GameGuideMgr.finishProcess()
                            --暂时先加在这里
                            CSResourceMgr.setSpriteTexture("Charactor/Menu/MainMenu.csb", "bb2", "UI/CommonFiles/anniu4.png")
                            CocosModuleMgr.showUnlockAnimation(CSResourceMgr.getNodeByName("Charactor/Menu/MainMenu.csb", "b2"))
                        end)
                    end
                    if clickbtn:isVisible()==true then
                        CocosModuleMgr.setButtonGuide(clickbtn, 2.5, function()
                            CocosModuleMgr.setScreenTouch(false)
                            UnblockLoader.addCallback("AwardsListMgr-reset", function()
                                CocosModuleMgr.setScreenTouch(true)
                                local okbtn = CSResourceMgr.getNodeByName("Item/awardInfoView.csb", "ok")
                                CocosModuleMgr.setButtonGuide(okbtn, 2.5, function()
                                    closeFunc()
                                end)
                            end, 1)
                        end, 1)
                    else
                        closeFunc()
                    end
                end)
            end)
        end)
    end
    GameGuideMgr.checkScene("MainScene", function()
        local pNode = WorldMapMgr.getMapPointNode(5)
        CocosModuleMgr.showUnlockAnimation(pNode, function()
            NpcDialogueMgr.show(17, function()
                if SystemOptionsMgr.getOption(1) then
                    clickMission()
                else
                    local statusball = CSResourceMgr.getNodeByName("Charactor/extendLayer.csb", "Button_List")
                    CocosModuleMgr.setButtonGuide(statusball, 3.5, function()
                        CocosModuleMgr.setScreenTouch(false)
                        statusball:performWithDelay(function()
                            CocosModuleMgr.setScreenTouch(true)
                            clickMission()
                        end, 0.5)
                    end)
                end
            end)
        end, 3)
    end)
end

function GameGuideMgr.firstBag()
    GameGuideMgr.checkScene("MainScene", function()
        print("####新手引导5，开背包")
        NpcDialogueMgr.show(18, function()
            local bagbtn = CSResourceMgr.getNodeByName("Charactor/Menu/MainMenu.csb", "b2")
            CocosModuleMgr.showUnlockAnimation(bagbtn, function()
                CocosModuleMgr.setButtonGuide(bagbtn, 1.5, function()
                    CocosModuleMgr.setScreenTouch(false)
                    UnblockLoader.addCallback("BagViewMgr-reset", function()
                        CocosModuleMgr.setScreenTouch(true)
                        local itembtn = BagViewMgr.getItemButton(154)
                        local function closeFunc()
                            local closebtn = CSResourceMgr.getNodeByName("Item/Bag/BagView.csb", "close")
                            CocosModuleMgr.setButtonGuide(closebtn, 3.5, function()
                                --进度完成
                                GameGuideMgr.finishProcess()
                            end)
                        end
                        if itembtn then
                            CocosModuleMgr.setButtonGuide(itembtn, 2.5, function()
                                CocosModuleMgr.setScreenTouch(false)
                                UnblockLoader.addCallback("ItemInfoViewMgr", function()
                                    CocosModuleMgr.setScreenTouch(true)
                                    NpcDialogueMgr.show(38, function()
                                        local closebtn = CSResourceMgr.getNodeByName("Item/InfoTips/ObjectInfo.csb", "close")
                                        CocosModuleMgr.setButtonGuide(closebtn, 3.5, function()
                                            closeFunc()
                                        end)
                                    end)
                                end)
                            end, 1)
                        else
                            closeFunc()
                        end
                    end)
                end)
            end)
        end)
    end)
end

function GameGuideMgr.guideFeedAfterSendProcess()
    NpcDialogueMgr.show(20, function ()
        GameGuideMgr.finishProcess()
    end, 1)
end
function GameGuideMgr.firstFeed()
    print("####新手引导6，喂食")
    local petInfo = PokemonInfo.getPetInfoByObjID(1)
    if petInfo.level > 1 then
        GameGuideMgr.finishProcess()
        return
    end
    local btnPetList = CSResourceMgr.getNodeByName("Charactor/Menu/MainMenu.csb", "b1")
    CSResourceMgr.setSpriteTexture("Charactor/Menu/MainMenu.csb", "bb1", "UI/CommonFiles/anniu4.png")
    CocosModuleMgr.showUnlockAnimation(btnPetList, function()
        CocosModuleMgr.setButtonGuide(btnPetList, 1.5, function ()
            CocosModuleMgr.setScreenTouch(false)
            UnblockLoader.addCallback("PetListMgr-reset", function ()
                CocosModuleMgr.setScreenTouch(true)
                local petList = PokemonInfo.getAllPets()
                local btnNode = PetListMgr.getPetListNode(1).node
                CocosModuleMgr.setButtonGuide(btnNode, 3.5, function ()
                    CocosModuleMgr.setScreenTouch(false)
                    UnblockLoader.addCallback("PetEducationMgr", function ()
                        CocosModuleMgr.setScreenTouch(true)
                        local btnMainPage = CSResourceMgr.getNodeByName("Pet/Education/PetsEducationNew.csb", "tab1")
                        local btnFeed     = CSResourceMgr.getNodeByName("Pet/Education/HomePageNew.csb", "feedBtn")
                        CocosModuleMgr.setButtonGuide(btnFeed, 3.5, function ()
                            CocosModuleMgr.setScreenTouch(false)
                            UnblockLoader.addCallback("PetFeedViewMgr", function ()
                                CocosModuleMgr.setScreenTouch(true)
                                NpcDialogueMgr.show(19, function ()
                                    local list    = CSResourceMgr.getNodeByName("Pet/Education/PetFeedPageNew.csb", "conList")
                                    local btnSure = CSResourceMgr.getNodeByName("Pet/Education/PetFeedPageNew.csb", "confirm")
                                    local btnItem = (list:getItems())[1]
                                    CocosModuleMgr.setButtonGuide(btnItem, 3.5, function ()
                                        PetFeedViewMgr.haveGuideFeed = true
                                        CocosModuleMgr.setButtonGuide(btnSure, 3.5, function ()
                                            --喂食那边调 GameGuideMgr.guideFeedAfterSendProcess()
                                        end, 1)
                                    end, 1)
                                end)
                            end)
                        end)
                    end)
                end, 1)
            end)
        end)
    end)
end

function GameGuideMgr.firstStrength()
    print("####新手引导6，强化")
    local petInfo = PokemonInfo.getPetInfoByObjID(1)
    if petInfo.Stage >= 1 then
        GameGuideMgr.finishProcess()
        return
    end
    local petList = PokemonInfo.getAllPets()
    local isCsbCreate = CSResourceMgr.getCsbObj("Pet/Education/PetsEducationNew.csb")
    if isCsbCreate then
        local btnStrengthPage = CSResourceMgr.getNodeByName("Pet/Education/PetsEducationNew.csb", "tab2")
        local btnClose        = CSResourceMgr.getNodeByName("Searching/advConfirm/top_right.csb", "btn_close", "PetEducationMgr-TopRight")
        local btnClose2       = CSResourceMgr.getNodeByName("Pet/Formation/FormationView.csb", "closeBtn")
        btnStrengthPage:setVisible(true)
        CocosModuleMgr.showUnlockAnimation(btnStrengthPage, function ()
            CocosModuleMgr.setButtonGuide(btnStrengthPage, 3.5, function ()
                NpcDialogueMgr.show(21, function ()
                    local btnStrength = CSResourceMgr.getNodeByName("Pet/Education/UpgradePage.csb", "btn_strength")
                    CocosModuleMgr.setButtonGuide(btnStrength, 3.5, function ()
                        NpcDialogueMgr.show(22, function ()
                            CocosModuleMgr.setButtonGuide(btnClose, 3.5, function ()
                                CocosModuleMgr.setButtonGuide(btnClose2, 3.5, function ()
                                    GameGuideMgr.finishProcess()
                                end, 1)
                            end, 1)
                        end, 1)
                    end, 1)
                end, 1)
            end, 1)
        end)
    else
        if petList[1].Stage > 0 then GameGuideMgr.finishProcess() end
        local btnPetList = CSResourceMgr.getNodeByName("Charactor/Menu/MainMenu.csb", "b1")
        CocosModuleMgr.setButtonGuide(btnPetList, 1.5, function ()
            CocosModuleMgr.setScreenTouch(false)
            UnblockLoader.addCallback("PetListMgr-reset", function ()
                CocosModuleMgr.setScreenTouch(true)
                local btnNode = PetListMgr.getPetListNode(petList[1].objID).node
                CocosModuleMgr.setButtonGuide(btnNode, 3.5, function ()
                    CocosModuleMgr.setScreenTouch(false)
                    UnblockLoader.addCallback("PetEducationMgr", function ()
                        CocosModuleMgr.setScreenTouch(true)
                        local btnStrengthPage = CSResourceMgr.getNodeByName("Pet/Education/PetsEducationNew.csb", "tab2")
                        local btnClose        = CSResourceMgr.getNodeByName("Searching/advConfirm/top_right.csb", "btn_close", "PetEducationMgr-TopRight")
                        local btnClose2       = CSResourceMgr.getNodeByName("Pet/Formation/FormationView.csb", "closeBtn")
                        btnStrengthPage:setVisible(true)
                        CocosModuleMgr.showUnlockAnimation(btnStrengthPage, function ()
                            CocosModuleMgr.setButtonGuide(btnStrengthPage, 3.5, function ()
                                NpcDialogueMgr.show(21, function ()
                                    local btnStrength = CSResourceMgr.getNodeByName("Pet/Education/UpgradePage.csb", "btn_strength")
                                    CocosModuleMgr.setButtonGuide(btnStrength, 3.5, function ()
                                        CocosModuleMgr.setButtonGuide(btnClose, 3.5, function ()
                                            CocosModuleMgr.setButtonGuide(btnClose2, 3.5, function ()
                                                GameGuideMgr.finishProcess()
                                            end, 1)
                                        end, 1)
                                    end, 1)
                                end, 1)
                            end, 1)
                        end)
                    end, 1)
                end, 1)
            end, 1)
        end, 1)
    end
end

function GameGuideMgr.secondBattle()
    local nodeID = 5
    local function secondBattle()
        print("####新手引导7，被嘲讽")
        local function guideFunc()
            CocosModuleMgr.setScreenTouch(false)
            local eventBtn = EmbeddedMapMgr.addEvent({
                type=1,
                emoji=7,
                param=99999,
            })
            eventBtn:performWithDelay(function()
                CocosModuleMgr.setScreenTouch(true)
                NpcDialogueMgr.show(23, function()
                    -- BattleUIMgr.firstBattle = 3
                    CocosModuleMgr.setButtonGuide(eventBtn, 3.5, function()
                        BattleMapMgr.setBattleCallback(function()
                            MapSeekerMgr.SeekFunc = function()
                                NpcDialogueMgr.show(24, function()
                                    NpcDialogueMgr.show(46, function()
                                        --进度完成
                                        GameGuideMgr.finishProcess()
                                    end)
                                end)
                            end
                        end)
                    end)
                end)
            end, 1)
        end
        WorldMapMgr.setMapMoveFinishFunc(function()
            guideFunc()
        end)
        local pNode = WorldMapMgr.getMapPointNode(nodeID)
        CocosModuleMgr.setButtonGuide(pNode, 2.5, function()
            local go = CSResourceMgr.getNodeByName("Map/WorldMap/MoveTips.csb", "go")
            if go then
                CocosModuleMgr.setButtonGuide(go, 2.5, function()
                    CocosModuleMgr.setScreenTouch(false)
                end)
            end
        end)
        pNode:performWithDelay(function()
            WorldMapMgr.locateToPoint(nodeID)
        end, 0.1)
        WorldMapMgr.addEvent(2, nodeID)
    end
    GameGuideMgr.checkScene("MainScene", secondBattle)
end

function GameGuideMgr.firstPetCatch()
    local nodeID = 8
    local function firstPetCatch()
        print("####新手引导8，抓宠偶遇")
        local function guideFunc()
            CocosModuleMgr.setScreenTouch(false)
            local petID = GetRandom.random(999997, 999999)
            local eventBtn = EmbeddedMapMgr.addEvent({
                type=2,
                emoji=1,
                param=petID,
            })
            eventBtn:performWithDelay(function()
                CocosModuleMgr.setScreenTouch(true)
                CocosModuleMgr.setButtonGuide(eventBtn, 3.5, function()
                    BattleUIMgr.firstBattle = 2
                    BattleMapMgr.setBattleCallback(function(detail)
                        BattleMapMgr.sendGameOver(detail.result, detail.me) 
                    end) 
                end)
            end, 1)
        end
        local pNode = WorldMapMgr.getMapPointNode(nodeID)
        WorldMapMgr.setMapMoveFinishFunc(function()
            guideFunc()
        end)
        CocosModuleMgr.setButtonGuide(pNode, 2.5, function()
            local go = CSResourceMgr.getNodeByName("Map/WorldMap/MoveTips.csb", "go")
            if go then
                CocosModuleMgr.setButtonGuide(go, 2.5, function()
                    CocosModuleMgr.setScreenTouch(false)
                end)
            end
        end)
        pNode:performWithDelay(function()
            WorldMapMgr.locateToPoint(nodeID)
        end, 0.1)
        WorldMapMgr.addEvent(2, nodeID)
    end
    GameGuideMgr.checkScene("MainScene", function()
        if WorldMapMgr.curP==nodeID then
            firstPetCatch()
        else
            CocosModuleMgr.showUnlockAnimation(WorldMapMgr.getMapPointNode(nodeID), firstPetCatch)
        end
    end)
end

function GameGuideMgr.secondAdventure()
    local nodeID = 10
    local function secondAdventure()
        print("####新手引导8，神秘小道")
        local pNode = WorldMapMgr.getMapPointNode(nodeID)
        CocosModuleMgr.setButtonGuide(pNode, 2.5, function()
            local function guideFunc()
                local closeBtn = CSResourceMgr.getNodeByName("Searching/advConfirm/advConfirmNewUIC.csb", "TanSuoBtn")
                CocosModuleMgr.setButtonGuide(closeBtn, 2.5, function()
                    SearchingMgr.adventureGuide(function()
                        MapSeekerMgr.SeekFunc = function()
                            --进度完成
                            GameGuideMgr.finishProcess()
                        end
                    end)
                end)
            end
            local go = CSResourceMgr.getNodeByName("Map/WorldMap/MoveTips.csb", "go")
            if go then
                CocosModuleMgr.setButtonGuide(go, 2.5, function()
                    CocosModuleMgr.setScreenTouch(false)
                    WorldMapMgr.setMapMoveFinishFunc(function()
                        CocosModuleMgr.setScreenTouch(true)
                        guideFunc()
                    end)
                end)
            else
                guideFunc()
            end
        end)
        pNode:performWithDelay(function()
            WorldMapMgr.locateToPoint(nodeID)
        end, 0.1)
    end
    GameGuideMgr.checkScene("MainScene", function()
        --CocosModuleMgr.showUnlockAnimation(WorldMapMgr.getMapPointNode(nodeID), secondAdventure, 2)
        secondAdventure()
    end)
end

--扭蛋引导
function GameGuideMgr.firstGacha()
    local function clickGachaStepTwo()
        local eggM = CSResourceMgr.getNodeByName("Item/Gacha/gachaListView.csb", "Button_Enter2")
        CocosModuleMgr.setButtonGuide(eggM, 3.5, function()
            CocosModuleMgr.setScreenTouch(false)
            UnblockLoader.addCallback("GachaViewMgrA", function()
                CocosModuleMgr.setScreenTouch(true)
                local OneChou = CSResourceMgr.getNodeByName("Item/Gacha/gachaMachineView.csb", "OneChou")
                local oneDrawBtn = CSResourceMgr.seekNodeByName(OneChou,"Button_Go")
                CocosModuleMgr.setButtonGuide(oneDrawBtn, 3.5, function()
                    CocosModuleMgr.setScreenTouch(false)
                    UnblockLoader.addCallback("GachaViewMgrB", function()
                        local parent = CSResourceMgr.getNodeByName("Item/Gacha/oneDrawAwardView.csb","getItem_Copy")
                        parent:performWithDelay(function()
                            CocosModuleMgr.setScreenTouch(true)
                            NpcDialogueMgr.show(29, function()
                                CocosModuleMgr.setScreenTouch(false)
                                parent:performWithDelay(function()
                                    CocosModuleMgr.setScreenTouch(true)
                                    local ButtonScreen = CSResourceMgr.getNodeByName("Item/Gacha/getPetView.csb", "ButtonScreen")
                                    CocosModuleMgr.setButtonGuide(ButtonScreen, 3.5, function()
                                        local confirmBtn = CSResourceMgr.getNodeByName("Item/Gacha/oneDrawAwardView.csb", "Button_Confirm")
                                        CocosModuleMgr.setButtonGuide(confirmBtn, 3.5, function()
                                            local cancelBtn = CSResourceMgr.getNodeByName("Charactor/TopInfoLayer.csb", "close")
                                            CocosModuleMgr.setButtonGuide(cancelBtn, 3.5, function()
                                                local closeBtn = CSResourceMgr.getNodeByName("Charactor/TopInfoLayer.csb", "close")
                                                CocosModuleMgr.setButtonGuide(closeBtn, 3.5, function()
                                                    --进度完成
                                                    GameGuideMgr.finishProcess()
                                                end)
                                            end)
                                        end)
                                    end)
                                end,0.5)
                            end)
                        end,2)
                    end)
                end)
            end)
        end)
    end

    local function clickGachaStepOne()
        local eggG = CSResourceMgr.getNodeByName("Item/Gacha/gachaListView.csb", "Button_Enter1")
        CocosModuleMgr.setButtonGuide(eggG, 3.5, function()
            CocosModuleMgr.setScreenTouch(false)
            UnblockLoader.addCallback("GachaViewMgrA", function()
                CocosModuleMgr.setScreenTouch(true)
                local OneChou = CSResourceMgr.getNodeByName("Item/Gacha/gachaMachineView.csb", "OneChou")
                local oneDrawBtn = CSResourceMgr.seekNodeByName(OneChou,"Button_Go")
                CocosModuleMgr.setButtonGuide(oneDrawBtn, 3.5, function()
                    CocosModuleMgr.setScreenTouch(false)
                    UnblockLoader.addCallback("GachaViewMgrB", function()
                        local parent = CSResourceMgr.getNodeByName("Item/Gacha/oneDrawAwardView.csb","getItem_Copy")
                        parent:performWithDelay(function()
                            CocosModuleMgr.setScreenTouch(true)
                            NpcDialogueMgr.show(28, function()
                                local confirmBtn = CSResourceMgr.getNodeByName("Item/Gacha/oneDrawAwardView.csb", "Button_Confirm")
                                CocosModuleMgr.setButtonGuide(confirmBtn, 3.5, function()
                                    local cancelBtn = CSResourceMgr.getNodeByName("Charactor/TopInfoLayer.csb", "close")
                                    CocosModuleMgr.setButtonGuide(cancelBtn, 3.5, function()
                                        clickGachaStepTwo()
                                    end)
                                end)
                            end)
                        end,1)
                    end)
                end)
            end)
        end)
    end

    local function startGuide()
        local lastTime1,lastTime2 = GachaViewMgr.getLastTime()
        --已钻石扭蛋
        if lastTime2~=0 then
            NpcDialogueMgr.show(29, function()
                --进度完成
                GameGuideMgr.finishProcess()
            end)
        else
            GameGuideMgr.checkScene("MainScene", function()
                if SystemOptionsMgr.getOption(1) then
                    NpcDialogueMgr.show(lastTime1==0 and 27 or 28, function()
                        local gachabtn = CSResourceMgr.getNodeByName("Charactor/extendLayer.csb", "Button_nd")
                        CocosModuleMgr.showUnlockAnimation(gachabtn, function()
                            CocosModuleMgr.setButtonGuide(gachabtn, 3.5, function()
                                CocosModuleMgr.setScreenTouch(false)
                                UnblockLoader.addCallback("GachaViewMgr", function()
                                    CocosModuleMgr.setScreenTouch(true)
                                    if lastTime1==0 then
                                        --未金币扭蛋
                                        clickGachaStepOne()
                                    else
                                        --已金币扭蛋
                                        clickGachaStepTwo()
                                    end
                                end)
                            end)
                        end)
                    end)
                else
                    NpcDialogueMgr.show(lastTime1==0 and 27 or 28, function()
                        local statusball = CSResourceMgr.getNodeByName("Charactor/extendLayer.csb", "Button_List")
                        CocosModuleMgr.setButtonGuide(statusball, 3.5, function()
                            CocosModuleMgr.setScreenTouch(false)
                            statusball:performWithDelay(function()
                                CocosModuleMgr.setScreenTouch(true)
                                local gachabtn = CSResourceMgr.getNodeByName("Charactor/extendLayer.csb", "Button_nd")
                                CocosModuleMgr.showUnlockAnimation(gachabtn, function()
                                    CocosModuleMgr.setButtonGuide(gachabtn, 3.5, function()
                                        CocosModuleMgr.setScreenTouch(false)
                                        UnblockLoader.addCallback("GachaViewMgr", function()
                                            CocosModuleMgr.setScreenTouch(true)
                                            if lastTime1==0 then
                                                --未金币扭蛋
                                                clickGachaStepOne()
                                            else
                                                --已金币扭蛋
                                                clickGachaStepTwo()
                                            end
                                        end)
                                    end)
                                end)
                            end, 0.5)
                        end)
                    end)
                end
            end)
        end

    end
    --延迟引导0.5秒
    CocosModuleMgr.setScreenTouch(false)
    SceneMgr.getRunningScene:performWithDelay(function()
        CocosModuleMgr.setScreenTouch(true)
        NetInterface.sendWithBlock("GC_CapsuleEggCDs_Ack", function()
            local PetSend = require("src.Net.Send.PetSend")
            PetSend.sendCG_CapsuleEggCDs_Req()
        end, function()
            startGuide()
        end)
    end, 0.5)

end

function GameGuideMgr.firstFormation()
    local function clickUpdatePetArmys()
        local updatebtn = CSResourceMgr.getNodeByName("Charactor/Menu/MainMenu.csb", "b1")
        CocosModuleMgr.setButtonGuide(updatebtn, 1.5, function()
                CocosModuleMgr.setScreenTouch(false)
                UnblockLoader.addCallback("PetListMgr-reset", function()
                NpcDialogueMgr.show(30, function()
                    CocosModuleMgr.setScreenTouch(true)
                    local teambtn = CSResourceMgr.getNodeByName("Pet/BasicPetList_2/PetList.csb", "tab2")
                    CocosModuleMgr.setButtonGuide(teambtn, 3.5, function()
                        local function save()
                            local closeBtn = CSResourceMgr.getNodeByName("Pet/Formation/FormationView.csb", "closeBtn")
                            CocosModuleMgr.setButtonGuide(closeBtn, 3.5, function()
                                --进度完成
                                GameGuideMgr.finishProcess()
                            end)
                        end
                        local function drag()
                            PetFormationMgr.setDragEvent(false)
                            local teamdb1 = CSResourceMgr.getNodeByName("Pet/Formation/FormationView.csb", "teamdb1")
                            local effAni = AnimationMgr.createAni(teamdb1, "Spine/effects/Ui_xinshouyindaoshouzhi_2.png",
                                teamdb1:getContentSize().width+57, teamdb1:getContentSize().height+57)
                            teamdb1:setLocalZOrder(CocosModuleMgr.ZORDER_GUIDE)
                            AnimationMgr.playAni(effAni.res, "animation", true, effAni.tag)
                            CocosModuleMgr.setScreenTouch(false)
                            if #PetFormationMgr.getTabNode()[1]<2 then
                                print("编队引导异常，当前队伍宠物少于2个")
                                save()
                            end
                            local function setZOrder(zorder)
                                PetFormationMgr.getCurTeamInfo()[1]:setGlobalZOrder(zorder)
                                PetFormationMgr.getCurTeamInfo()[2]:setGlobalZOrder(zorder)
                            end
                            setZOrder(CocosModuleMgr.ZORDER_GUIDE)
                            PetFormationMgr.setDragListener(function()
                                setZOrder(CocosModuleMgr.ZORDER_GUIDE)
                                local selPet = PetFormationMgr.getSelPet()[1][1].objID
                                local firstPetRare = PokemonInfo.getPokemonInfoByID(PokemonInfo.getPetInfoByObjID(selPet).pokeID).rarePoint
                                if firstPetRare>2 then
                                    print("编队移动已达成")
                                    PetFormationMgr.setDragEvent(true)
                                    AnimationMgr.removeGafObjectByTag(effAni.res, effAni.tag)
                                    CocosModuleMgr.setScreenTouch(true)
                                    setZOrder(0)
                                    save()
                                else
                                    print("编队移动未达成")
                                end
                            end)
                        end
                        local petArmyInfo = PokemonInfo.getPetArmy(1)
                        if #petArmyInfo<=2 then
                            --添加宠物教程
                            if #petArmyInfo==0 then
                                print("编队引导异常，当前队伍没有宠物")
                                save()
                            else
                                local function addPet()
                                    local petVec = PokemonInfo.getAllPets()
                                    local petObjID = nil
                                    for key, var in pairs(petVec) do
                                        if PokemonInfo.getPokemonInfoByID(var.pokeID).rarePoint>2 then
                                            petObjID = var.objID
                                            break
                                        end
                                    end
                                    if petObjID then
                                        local pBtn = PetListMgr.getPetListNode(petObjID).node
                                        CocosModuleMgr.setButtonGuide(pBtn, 2.5, function()
                                            --拖拽教程
                                            -- drag()
                                            local teamdb1 = CSResourceMgr.getNodeByName("Pet/Formation/FormationView.csb", "teamdb1")
                                            local effAni = AnimationMgr.createAni(teamdb1, "Spine/effects/Ui_xinshouyindaoshouzhi_2.png",
                                                teamdb1:getContentSize().width+57, teamdb1:getContentSize().height+57)
                                            teamdb1:setLocalZOrder(CocosModuleMgr.ZORDER_GUIDE)
                                            AnimationMgr.playAni(effAni.res, "animation", true, effAni.tag)
                                            NpcDialogueMgr.show(55, function()
                                                AnimationMgr.removeGafObjectByTag(effAni.res, effAni.tag)
                                                save()
                                            end)
                                        end)
                                    else
                                        print("编队引导异常，玩家没有A级以上宠物")
                                        save()
                                    end
                                end
                                local petArmy = PokemonInfo.getPetArmy(1)
                                if #petArmy==2 then
                                    local petObjID = petArmy[2]
                                    local pBtn = PetListMgr.getPetListNode(petObjID).node
                                    CocosModuleMgr.setButtonGuide(pBtn, 2.5, function()
                                        addPet()
                                    end)
                                else
                                    addPet()
                                end
                            end
                        else
                            print("编队引导异常，当前队伍有2个以上宠物")
                            save()
                        end
                    end)
                end)
            end)
        end)
    end
    clickUpdatePetArmys()
end
