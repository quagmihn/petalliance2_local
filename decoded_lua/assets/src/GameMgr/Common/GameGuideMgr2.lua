function GameGuideMgr.firstFreePet()
    local updatebtn = CSResourceMgr.getNodeByName("Charactor/Menu/MainMenu.csb", "b1")
    CocosModuleMgr.setButtonGuide(updatebtn, 1.5, function()
        CocosModuleMgr.setScreenTouch(false)
        UnblockLoader.addCallback("PetListMgr-reset", function ()
            CocosModuleMgr.setScreenTouch(true)
            local teambtn = CSResourceMgr.getNodeByName("Pet/BasicPetList_2/PetList.csb", "tab3")
            CocosModuleMgr.showUnlockAnimation(teambtn, function()
                CocosModuleMgr.setButtonGuide(teambtn, 3.5, function()
                    CocosModuleMgr.setScreenTouch(false)
                    NpcDialogueMgr.show(1374, function()
                        CocosModuleMgr.setScreenTouch(true)
                        GameGuideMgr.finishProcess()
                    end)
                end)
            end)
        end, 1)
    end)
end

function GameGuideMgr.firstLostTower()
    local nodeID = 60
    local function GoToWorldMap()
        CocosModuleMgr.setScreenTouch(false)
        local btn = WorldMapMgr.getMapPointNode(nodeID)
        CSResourceMgr.setButtonEnabledByNode(btn, false)
        SceneMgr.getRunningScene:performWithDelay(function()
            WorldMapMgr.locateToPoint(nodeID)
            CocosModuleMgr.showUnlockAnimation(btn, function()
                CocosModuleMgr.setScreenTouch(false)
                CocosModuleMgr.setButtonGuide(btn, 3.5, function()
                    MapSeekerMgr.SeekFunc = function()
                        --进入千层塔
                        require("src.GameMgr.LostTower.LTGuideMgr").FirstGuide(function()
                            GameGuideMgr.finishProcess()
                        end)
                    end
                end)
            end, 2)
        end, 0.5)
    end
    GameGuideMgr.checkScene("MainScene", function()
        GoToWorldMap()
    end)
end

function GameGuideMgr.firstStageBoss()
    local nodeID = 52
    local function firstStageBoss()
        WorldMapMgr.curMapID = 1
        WorldMapMgr.curP = nodeID
        MapSeekerMgr.SeekFunc = function()
            CocosModuleMgr.setScreenTouch(false)
            local btn = WorldMapMgr.getMapPointNode(nodeID)
            SceneMgr.getRunningScene:performWithDelay(function()
                WorldMapMgr.locateToPoint(nodeID)
            end, 0.1)

            CocosModuleMgr.setButtonGuide(btn, 3.5, function()
                local lzBtn = CSResourceMgr.getNodeByName("Searching/advConfirm/advConfirmNewUIB.csb", "lztab")
                lzBtn:setVisible(true)
                CocosModuleMgr.showUnlockAnimation(lzBtn,function()
                    CocosModuleMgr.setButtonGuide(lzBtn, 3.5, function()
                        NpcDialogueMgr.show(1362,function()
                            NpcDialogueMgr.show(1363,function()
                                local closeBtn = CSResourceMgr.getNodeByName("Searching/advConfirm/top_right.csb", "btn_close", "advConfirNewTopRight")
                                CocosModuleMgr.setButtonGuide(closeBtn, 3.5, function()
                                    CocosModuleMgr.setScreenTouch(true)
                                    GameGuideMgr.finishProcess()
                                end)
                            end)
                        end)
                        --                        local diban1 = CSResourceMgr.getNodeByName("Searching/advConfirm/advConfirmNewUIB.csb","middlenode")
                        --                        local diban2 = CSResourceMgr.getNodeByName("Searching/advConfirm/advConfirmNewUIB.csb","diaoluodb")
                        --                        local lzcountdown = CSResourceMgr.getNodeByName("Searching/advConfirm/advConfirmNewUIC.csb","lzcountdown")
                        --                        CocosModuleMgr.setNodeHint(diban1,3.5,function()
                        --                            CocosModuleMgr.setNodeHint(lzcountdown,0.5,function()
                        --                                NpcDialogueMgr.show(1016,function()
                        --                                    CocosModuleMgr.setNodeHint(diban2,3.5,function()
                        --                                        NpcDialogueMgr.show(1017,function()
                        --                                            GameGuideMgr.finishProcess()
                        --                                        end)
                        --                                    end)
                        --                                end)
                        --                            end)
                        --                        end)
                    end)
                end)
            end)
        end
        SceneMgr.replaceScene(SceneMgr.getRunningScene, "MainScene")
    end
    GameGuideMgr.checkLevelUpView(firstStageBoss)
end

function GameGuideMgr.firstExplore()
    local function firstExplore()
        NpcDialogueMgr.show(1011, function()
            local btn = CSResourceMgr.getNodeByName("Charactor/Menu/MainMenu.csb", "b3")
            CSResourceMgr.setSpriteTexture("Charactor/Menu/MainMenu.csb", "bb3", "UI/CommonFiles/anniu4.png")
            CocosModuleMgr.showUnlockAnimation(btn, function()
                GameGuideMgr.EXPLORE_ID = 5
                CocosModuleMgr.setButtonGuide(btn, 1.5, function()
                    CocosModuleMgr.setScreenTouch(false)
                    UnblockLoader.addCallback("ExploreViewMgr.show", function()
                        CocosModuleMgr.setScreenTouch(true)
                        local eBtn = CSResourceMgr.getNodeByName("Player/ExploreMain.csb", "b1")
                        CocosModuleMgr.setButtonGuide(eBtn, 2.5, function()
                            GameGuideMgr.EXPLORE_ID = nil
                            CocosModuleMgr.setScreenTouch(false)
                            UnblockLoader.addCallback("PetExploreMgr.show", function()
                                CocosModuleMgr.setScreenTouch(true)
                                NpcDialogueMgr.show(1012, function()
                                    local function guideFunc()
                                        CocosModuleMgr.setNodeHint(CSResourceMgr.getNodeByName("Pet/Explore/ExploreUIC.csb", "time"), 0.5, function()
                                            NpcDialogueMgr.show(1013, function()
                                                local function otherFunc()
                                                    CocosModuleMgr.setNodeHint(CSResourceMgr.getNodeByName("Pet/Explore/ExploreUID.csb", "listtitledb"), 2.5, function()
                                                        NpcDialogueMgr.show(1030, function()
                                                            NpcDialogueMgr.show(1031, function()
                                                                local droptitledb = CSResourceMgr.getNodeByName("Pet/Explore/ExploreUID.csb", "droptitledb")
                                                                CocosModuleMgr.setNodeHint(droptitledb, 3.5, function()
                                                                    NpcDialogueMgr.show(1032, function()
                                                                        --进度完成
                                                                        GameGuideMgr.finishProcess()
                                                                    end)
                                                                end)
                                                            end)
                                                        end)
                                                    end)
                                                end
                                                if CharInfo.get().explorepacketnum<11 then
                                                    CSResourceMgr.getNodeByName("Pet/Explore/ExploreUIC.csb", "bagdb"):setGlobalZOrder(1)
                                                    local addbagBtn = CSResourceMgr.getNodeByName("Pet/Explore/ExploreUIC.csb", "addbag")
                                                    CocosModuleMgr.setButtonGuide(addbagBtn, 3.5, function()
                                                        CSResourceMgr.getNodeByName("Pet/Explore/ExploreUIC.csb", "bagdb"):setGlobalZOrder(0)
                                                        CocosModuleMgr.setScreenTouch(false)
                                                        UnblockLoader.addCallback("DialogBoxMgr_small", function()
                                                            CocosModuleMgr.setScreenTouch(true)
                                                            local okBtn = CSResourceMgr.getNodeByName("UI/DialogBox/SmallDialogBox.csb", "b1")
                                                            CocosModuleMgr.setButtonGuide(okBtn, 3.5, function()
                                                                CocosModuleMgr.setScreenTouch(false)
                                                                SceneMgr.getRunningScene:performWithDelay(function()
                                                                    CocosModuleMgr.setScreenTouch(true)
                                                                    otherFunc()
                                                                end, 1)
                                                            end, 1)
                                                        end)
                                                    end)
                                                else
                                                    otherFunc()
                                                end
                                            end)
                                        end)
                                    end
                                    local startBtn = CSResourceMgr.getNodeByName("Pet/Explore/ExploreUIC.csb", "start")
                                    if startBtn:isTouchEnabled() then
                                        CocosModuleMgr.setButtonGuide(startBtn, 3.5, function()
                                            CocosModuleMgr.setScreenTouch(false)
                                            SceneMgr.getRunningScene:performWithDelay(function()
                                                CocosModuleMgr.setScreenTouch(true)
                                                guideFunc()
                                            end, 1)
                                        end)
                                    else
                                        guideFunc()
                                    end
                                end)
                            end)
                        end)
                    end)
                end)
            end)
        end)
    end
    GameGuideMgr.checkScene("MainScene", firstExplore)
end

function GameGuideMgr.firstEliteAdventure()
    local nodeID = 35
    local function firstEliteAdventure()
        print("####新手引导11，精英副本")
        local pNode = WorldMapMgr.getMapPointNode(nodeID)
        CocosModuleMgr.setButtonGuide(pNode, 3.5, function()
            local function guideFunc()

                local jyBtn = CSResourceMgr.getNodeByName("Searching/advConfirm/advConfirmNewUIB.csb", "jytab")
                --jyBtn:setVisible(false)
                jyBtn:setVisible(true)
                CocosModuleMgr.showUnlockAnimation(jyBtn,function()

                        CocosModuleMgr.setButtonGuide(jyBtn, 3.5, function()
                            local tansuoBtn = CSResourceMgr.getNodeByName("Searching/advConfirm/advConfirmNewUIC.csb", "TanSuoBtn")
                            CocosModuleMgr.setButtonGuide(tansuoBtn,1,function()
                                --进度完成

                                GameGuideMgr.finishProcess()
                            end)


                        end)

                end)
                --[[
                NpcDialogueMgr.show(1014,function()
                jyBtn:setVisible(true)
                CocosModuleMgr.showUnlockAnimation(jyBtn,function()

                CocosModuleMgr.setButtonGuide(jyBtn, 3.5, function()
                --进度完成
                GameGuideMgr.finishProcess()

                end)

                end)
                end)
                ]]
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
        NpcDialogueMgr.show(1014, function()
            firstEliteAdventure()
        end)
    end)
end

function GameGuideMgr.firstStarUp()
    print("####新手引导15，升星")
    local allpets = PokemonInfo.getAllPets()
    local flag = false
    local petInfo = {}
    for var=1, #allpets do
        local info = allpets[var]
        if info.Stage then
            if (info.pokeID == 1 or info.pokeID == 4 or info.pokeID == 7) and info.Stage >= 5 then
                flag = true
                petInfo = info
                break
            end
        end
    end
    if flag then
        local function starUpGuide()
            local btnStarUpTab = CSResourceMgr.getNodeByName("Pet/Education/PetsEducationNew.csb", "tab3")
            CocosModuleMgr.showUnlockAnimation(btnStarUpTab, function()
                CocosModuleMgr.setButtonGuide(btnStarUpTab, 3.5, function ()
                    NpcDialogueMgr.show(1373, function ()
                        local btnRes1 = PetStarUpMgr.getNeedPetNodeByIndex(2)
                        CocosModuleMgr.setButtonGuide(btnRes1, function ()
                            CocosModuleMgr.setScreenTouch(false)
                            UnblockLoader.addCallback("PetCommonListViewMgr", function ()
                                CocosModuleMgr.setScreenTouch(true)
                                local btnRes2 = PetCommonListViewMgr.getPetNodesByIndex(1)
                                CocosModuleMgr.setButtonGuide(btnRes2, function ()
                                    local bottom = CSResourceMgr.getNodeByName("Pet/Education/StarupPageNew.csb", bottom)
                                    local btnStarUp = CSResourceMgr.seekNodeByName(bottom, "btn_strength")
                                    CocosModuleMgr.setButtonGuide(btnStarUp, function ()
                                        GameGuideMgr.finishProcess()
                                    end)
                                end)
                            end)
                        end)
                        -- local btnClose1 = CSResourceMgr.getNodeByName("Pet/Education/PetsEducationNew.csb", "close")
                        -- CocosModuleMgr.setButtonGuide(btnClose1, 3.5, function ()
                        --     local btnClose2 = CSResourceMgr.getNodeByName("Pet/Formation/FormationView.csb", "closeBtn")
                        --     CocosModuleMgr.setButtonGuide(btnClose2, 3.5, function ()
                        --         GameGuideMgr.finishProcess()
                        --     end)
                        -- end)
                    end)
                end)
            end)
        end
        local function openListMgr()
            local btnPetList = CSResourceMgr.getNodeByName("Charactor/Menu/MainMenu.csb", "b1")
            CocosModuleMgr.setButtonGuide(btnPetList, 1.5, function ()
                CocosModuleMgr.setScreenTouch(false)
                UnblockLoader.addCallback("PetListMgr-reset", function ()
                    CocosModuleMgr.setScreenTouch(true)
                    local btnNode = PetListMgr.getPetListNode(petInfo.objID).node
                    if btnNode then
                        CocosModuleMgr.setButtonGuide(btnNode, 3.5, function ()
                            CocosModuleMgr.setScreenTouch(false)
                            UnblockLoader.addCallback("PetEducationMgr", function ()
                                CocosModuleMgr.setScreenTouch(true)
                                starUpGuide()
                            end, 1)
                        end, 1)
                    else
                        PetEducationMgr.show(SceneMgr.getRunningScene, petInfo.objID)
                        CocosModuleMgr.setScreenTouch(false)
                        UnblockLoader.addCallback("PetEducationMgr", function ()
                            CocosModuleMgr.setScreenTouch(true)
                            starUpGuide()
                        end, 1)
                    end
                end, 1)
            end, 1)
        end
        local function openMailMgr()
            local missionbtn = CSResourceMgr.getNodeByName("Charactor/extendLayer.csb", "Button_rw")
            MissionListMgr.setTab(1)
            CocosModuleMgr.setButtonGuide(missionbtn, 3.5, function()
                CocosModuleMgr.setScreenTouch(false)
                UnblockLoader.addCallback("MissionListMgr.setTabA", function()
                    CocosModuleMgr.setScreenTouch(true)
                    NpcDialogueMgr.show(1372, function ()
                        local msButton = nil
                        for key, var in pairs(GameGuideMgr.GLOW_MISSION_ID_STU) do
                            msButton = MissionListMgr.getMissionItemNodeByID(var)
                            break
                        end
                        if not msButton then
                            closeFunc()
                        end
                        local clickbtn = CSResourceMgr.seekNodeByName(msButton, "clain")
                        local function closeFunc()
                            local closebtn = CSResourceMgr.getNodeByName("Charactor/TopInfoLayer.csb", "close")
                            CocosModuleMgr.setButtonGuide(closebtn, 3.5, function()
                                openListMgr()
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
        UIStack.closeAllUI()
        openMailMgr()
    else
        return true
    end
end

function GameGuideMgr.firstStarUpEnd()
    GameGuideMgr.checkScene("MainScene", function()
        NpcDialogueMgr.show(1309, function ()
            local function touchMissionBtn()
                local missionbtn = CSResourceMgr.getNodeByName("Charactor/extendLayer.csb", "Button_rw")
                MissionListMgr.setTab(1)
                CocosModuleMgr.setButtonGuide(missionbtn, 3.5, function ()
                    CocosModuleMgr.setScreenTouch(false)
                    UnblockLoader.addCallback("MissionListMgr.setTabA", function ()
                        CocosModuleMgr.setScreenTouch(true)
                        local item = MissionListMgr.getMissionItemNodeByID(10025) or
                            MissionListMgr.getMissionItemNodeByID(10026) or
                            MissionListMgr.getMissionItemNodeByID(10027)
                        if item then
                            local clickbtn = CSResourceMgr.seekNodeByName(item, "guide")
                            CocosModuleMgr.setNodeHint(clickbtn, 3.5, function ()
                                NpcDialogueMgr.show(1310, function ()
                                    GameGuideMgr.finishProcess()
                                end)
                            end)
                        else
                            NpcDialogueMgr.show(1310, function ()
                                GameGuideMgr.finishProcess()
                            end)
                        end
                    end)
                end)
            end
            if SystemOptionsMgr.getOption(1) then
                touchMissionBtn()
            else
                local statusball = CSResourceMgr.getNodeByName("Charactor/extendLayer.csb", "Button_List")
                CocosModuleMgr.setButtonGuide(statusball, 3.5, function()
                    CocosModuleMgr.setScreenTouch(false)
                    statusball:performWithDelay(function()
                        CocosModuleMgr.setScreenTouch(true)
                        touchMissionBtn()
                    end, 0.5)
                end)
            end
        end)
    end)
end

function GameGuideMgr.firstEvolution()
    print("####新手引导14，进化")
    local allpets = PokemonInfo.getAllPets()
    local flag = false
    local petInfo = {}
    for var=1, #allpets do
        local info = allpets[var]
        if (info.pokeID == 1 or info.pokeID == 4 or info.pokeID == 7) and info.level >= 12 then
            flag = true
            petInfo = info
            break
        end
    end
    flag = true
    if flag then
        local function evolutionGuide()
            local btnEvolution = CSResourceMgr.getNodeByName("Pet/Education/PetsEducationNew.csb", "tab4")
            CocosModuleMgr.showUnlockAnimation(btnEvolution, function ()
                NpcDialogueMgr.show(1369, function ()
                    CocosModuleMgr.setButtonGuide(btnEvolution, 3.5, function ()
                        GameGuideMgr.finishProcess()
                    end, 1)
                end, 1)
            end, 1)
        end
        local function openListMgr()
            local btnPetList = CSResourceMgr.getNodeByName("Charactor/Menu/MainMenu.csb", "b1")
            CocosModuleMgr.setButtonGuide(btnPetList, 1.5, function ()
                CocosModuleMgr.setScreenTouch(false)
                UnblockLoader.addCallback("PetListMgr-reset", function ()
                    CocosModuleMgr.setScreenTouch(true)
                    
                    local btnNode = PetListMgr.getPetListNode(petInfo.objID).node
                    if btnNode then
                        CocosModuleMgr.setButtonGuide(btnNode, 3.5, function ()
                            CocosModuleMgr.setScreenTouch(false)
                            UnblockLoader.addCallback("PetEducationMgr", function ()
                                CocosModuleMgr.setScreenTouch(true)
                                evolutionGuide()
                            end, 1)
                        end, 1)
                    else
                        PetEducationMgr.show(SceneMgr.getRunningScene, petInfo.objID)
                        CocosModuleMgr.setScreenTouch(false)
                        UnblockLoader.addCallback("PetEducationMgr", function ()
                            CocosModuleMgr.setScreenTouch(true)
                            evolutionGuide()
                        end, 1)
                    end
                end, 1)
            end, 1)
        end
        local function openMailMgr()
            local missionbtn = CSResourceMgr.getNodeByName("Charactor/extendLayer.csb", "Button_rw")
            MissionListMgr.setTab(1)
            CocosModuleMgr.setButtonGuide(missionbtn, 3.5, function()
                CocosModuleMgr.setScreenTouch(false)
                UnblockLoader.addCallback("MissionListMgr.setTabA", function()
                    CocosModuleMgr.setScreenTouch(true)
                    NpcDialogueMgr.show(1368, function ()
                        local msButton = nil
                        for key, var in pairs(GameGuideMgr.GLOW_MISSION_ID_STU) do
                            msButton = MissionListMgr.getMissionItemNodeByID(var)
                            break
                        end
                        if not msButton then
                            closeFunc()
                        end
                        local clickbtn = CSResourceMgr.seekNodeByName(msButton, "clain")
                        local function closeFunc()
                            local closebtn = CSResourceMgr.getNodeByName("Charactor/TopInfoLayer.csb", "close")
                            CocosModuleMgr.setButtonGuide(closebtn, 3.5, function()
                                openListMgr()
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
        UIStack.closeAllUI()
        openMailMgr()
    else
        return true
    end
end

function GameGuideMgr.firstEvolutionEnd()
    GameGuideMgr.checkScene("MainScene", function()
        NpcDialogueMgr.show(1312, function ()
            local function touchMissionBtn()
                local missionbtn = CSResourceMgr.getNodeByName("Charactor/extendLayer.csb", "Button_rw")
                MissionListMgr.setTab(1)
                CocosModuleMgr.setButtonGuide(missionbtn, 3.5, function ()
                    CocosModuleMgr.setScreenTouch(false)
                    UnblockLoader.addCallback("MissionListMgr.setTabA", function ()
                        CocosModuleMgr.setScreenTouch(true)
                        local item = MissionListMgr.getMissionItemNodeByID(10028) or
                            MissionListMgr.getMissionItemNodeByID(10029) or
                            MissionListMgr.getMissionItemNodeByID(10030)
                        if item then
                            local clickbtn = CSResourceMgr.seekNodeByName(item, "guide")
                            CocosModuleMgr.setNodeHint(clickbtn, 3.5, function ()
                                NpcDialogueMgr.show(1313, function ()
                                    GameGuideMgr.finishProcess()
                                end)
                            end)
                        else
                            NpcDialogueMgr.show(1313, function ()
                                GameGuideMgr.finishProcess()
                            end)
                        end
                    end)
                end)
            end
            if SystemOptionsMgr.getOption(1) then
                touchMissionBtn()
            else
                local statusball = CSResourceMgr.getNodeByName("Charactor/extendLayer.csb", "Button_List")
                CocosModuleMgr.setButtonGuide(statusball, 3.5, function()
                    CocosModuleMgr.setScreenTouch(false)
                    statusball:performWithDelay(function()
                        CocosModuleMgr.setScreenTouch(true)
                        touchMissionBtn()
                    end, 0.5)
                end)
            end
        end)
    end)
end

function GameGuideMgr.firstAchievement()
    local function clickAchievement()
        print("####新手引导12，交成就")
        local achievementbtn = CSResourceMgr.getNodeByName("Charactor/extendLayer.csb", "Button_hd")
        CocosModuleMgr.showUnlockAnimation(achievementbtn, function()
            CocosModuleMgr.setButtonGuide(achievementbtn, 3.5, function()
                CocosModuleMgr.setScreenTouch(false)
                UnblockLoader.addCallback("AchievementListMgr.show", function()
                    if AchievementListMgr.finishAchieveNum()>0 then
                        CocosModuleMgr.setScreenTouch(true)
                        --进度完成
                        GameGuideMgr.finishProcess()
                    else
                        CocosModuleMgr.setScreenTouch(true)
                        NpcDialogueMgr.show(1015, function()
                            local list = CSResourceMgr.getNodeByName("Player/AchievementTabA.csb", "ListView")
                            local item = list:getItem(0)
                            local clickbtn = CSResourceMgr.seekNodeByName(item, "lingqu")
                            CocosModuleMgr.setNodeHint(clickbtn, 3.5)
                            -- if item then
                            --     local posx = item:getContentSize().width/2
                            --     local posy = item:getContentSize().height/2
                            --     local aniObj = AnimationMgr.createAni(item, "Spine/effects/UI_renwutishi.png", posx, posy)
                            --     AnimationMgr.playAni(aniObj.res, "animation", true, aniObj.tag)
                            -- end
                            GameGuideMgr.finishProcess()
                            -- CocosModuleMgr.setButtonGuide(clickbtn, 3.5, function()
                            --     CocosModuleMgr.setScreenTouch(false)
                            --     list:performWithDelay(function()
                            --         CocosModuleMgr.setScreenTouch(true)
                            --         --进度完成
                            --         GameGuideMgr.finishProcess()
                            --     end,1)
                            -- end)
                        end)
                    end
                end)
            end)
        end)
    end
    GameGuideMgr.checkScene("MainScene", function()
        if SystemOptionsMgr.getOption(1) then
            clickAchievement()
        else
            local statusball = CSResourceMgr.getNodeByName("Charactor/extendLayer.csb", "Button_List")
            CocosModuleMgr.setButtonGuide(statusball, 3.5, function()
                CocosModuleMgr.setScreenTouch(false)
                statusball:performWithDelay(function()
                    CocosModuleMgr.setScreenTouch(true)
                    clickAchievement()
                end, 0.5)
            end)
        end
    end)
end

function GameGuideMgr.firstFriend()
    if SceneMgr.currentScene=="LostTowerScene" or SceneMgr.currentScene=="BattleScene" then
    	return true
    end
    local function firstFriend()
        if CSResourceMgr.getCsbObj("Player/AchievementList.csb") then
            AchievementListMgr.hide()
        end
        GameGuideMgr.checkScene("MainScene", function()
            local function clickFriend()
                local missionbtn = CSResourceMgr.getNodeByName("Charactor/extendLayer.csb", "Button_hy")
                if LuaSqlite.LANG_TYPE==1 then --阿杜修改英文版不显示
                    CSResourceMgr.getNodeByName("Charactor/extendLayer.csb", "Text4"):setVisible(true)
                end
                CocosModuleMgr.showUnlockAnimation(missionbtn, function()
                    CocosModuleMgr.setButtonGuide(missionbtn, 3.5, function()
                        NpcDialogueMgr.show(1353, function()
                            GameGuideMgr.finishProcess()
                        end)
                    end)
                end)
            end
            if SystemOptionsMgr.getOption(1) then
                clickFriend()
            else
                local statusball = CSResourceMgr.getNodeByName("Charactor/extendLayer.csb", "Button_List")
                CocosModuleMgr.setButtonGuide(statusball, 3.5, function()
                    CocosModuleMgr.setScreenTouch(false)
                    statusball:performWithDelay(function()
                        CocosModuleMgr.setScreenTouch(true)
                        clickFriend()
                    end, 0.5)
                end)
            end
        end)
    end
    GameGuideMgr.checkLevelUpView(firstFriend)
end

function GameGuideMgr.firstQuickClear()
    print("####新手引导16，副本扫荡")
    local nodeID = 35

    local function showDialog(_callback)
        NpcDialogueMgr.show(53, function()
            if _callback then _callback() end
        end)
    end

    local function firstQuickClear()
        local pNode = WorldMapMgr.getMapPointNode(nodeID)
        CocosModuleMgr.setButtonGuide(pNode, 3.5, function()
            local function guideFunc()

                local saodangbtn = CSResourceMgr.getNodeByName("Searching/advConfirm/advConfirmNewUIC.csb", "saodangbtn")
                local saodangtenbtn = CSResourceMgr.getNodeByName("Searching/advConfirm/advConfirmNewUIC.csb","saodangtenbtn")

                CocosModuleMgr.showUnlockAnimation(saodangbtn,function()
                    CSResourceMgr.setButtonEnabledByNode(saodangbtn,true)
                end)

                CocosModuleMgr.showUnlockAnimation(saodangtenbtn,function()
                    CSResourceMgr.setButtonEnabledByNode(saodangtenbtn,true)
                    showDialog(function()
                        --local closeBtn = CSResourceMgr.getNodeByName("Searching/advConfirm/top_right.csb", "btn_close", "advConfirNewTopRight")
                        --CocosModuleMgr.setButtonGuide(closeBtn, 3.5, function()
                        --    GameGuideMgr.finishProcess()
                        --end)

                        GameGuideMgr.finishProcess()
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
        firstQuickClear()
    end)
end

function GameGuideMgr.firstBuff()
    local nodeID = 11
    local function firstBuff()
        print("####新手引导17，BUFF技能")
        BattleCCSB.stopQuitBattle()
        local function guideFunc()
            CocosModuleMgr.setScreenTouch(false)
            local eventBtn = EmbeddedMapMgr.addEvent({
                type=1,
                emoji=1,
                param=2003,
            })
            eventBtn:performWithDelay(function()
                CocosModuleMgr.setScreenTouch(true)
                CocosModuleMgr.setButtonGuide(eventBtn, 3.5, function()
                    --设计下次战斗buff说明的引导 
                    local callback = nil
                    local function afterEnergy()
                        CSResourceMgr.playActionWithCallback("Battle/PVPTime/PVPtime.csb", 35, 60, 0.9, function()
                            if callback then
                                callback()
                            end
                        end)
                    end
                    local function guideTwo()
                        for key,var in pairs(BattleCotroller.petBuffers[0]) do
                            BattleCCSB.DOWNBLOOD.guideState:setVisible(true)
                            local function overState()
                                transition.stopTarget(BattleCCSB.DOWNBLOOD.guideState)
                                BattleCCSB.DOWNBLOOD.guideState:setVisible(false)
                            end
                            local callfunc = cc.CallFunc:create(overState)
                            local blindAct = cc.Blink:create(5,5)
                            local seq  = cc.Sequence:create(blindAct,callfunc)
                            BattleCCSB.DOWNBLOOD.guideState:runAction(seq)
                            SceneMgr.getRunningScene:performWithDelay(function()

                                end, 0.5)
                            callback = function()
                                BattleUIMgr.setStopAction(true)
                                --                    CocosModuleMgr.setNodeHint(BattleCCSB.DOWNBLOOD.showBuff, 2.5, nil)
                                local sp  = CSResourceMgr.getNodeByName(BattleCCSB.DOWNBLOOD.res,"buffguide")
                                CocosModuleMgr.setNodeHint(sp, 2.5, nil)
                                NpcDialogueMgr.show(1325, function()
                                    end)
                            end
                            BattleUIMgr.goAddEnergy(afterEnergy)
                            BattleGuide.isGuide = true
                            BattleGuide.funcs[GUIDE_SECOND] = nil
                            break
                        end

                    end

                    local function guideOne()
                        callback = function()
                            NpcDialogueMgr.show(1324, function()
                                BattleUIMgr.setStopAction(true)
                                CocosModuleMgr.setButtonGuide(BattleCCSB.DOWNEDGE.skillBtn[2], 2.5, function()
                                    end)
                            end)
                        end
                        BattleUIMgr.goAddEnergy(afterEnergy)
                        BattleUIMgr.setStopAction()

                        BattleGuide.funcs[GUIDE_FIRST] = nil
                    end

                    local function guideThree()
                        for key,var in pairs(BattleCotroller.petBuffers[1]) do
                            BattleCCSB.UPBLOOD.guideState:setVisible(true)
                            local function overState()
                                transition.stopTarget(BattleCCSB.UPBLOOD.guideState)
                                BattleCCSB.UPBLOOD.guideState:setVisible(false)
                            end
                            local callfunc = cc.CallFunc:create(overState)
                            local blindAct = cc.Blink:create(5,5)
                            local seq  = cc.Sequence:create(blindAct,callfunc)
                            BattleCCSB.UPBLOOD.guideState:runAction(seq)
                            SceneMgr.getRunningScene:performWithDelay(function()

                                    callback = function()
                                        BattleUIMgr.setStopAction(true)
                                        NpcDialogueMgr.show(1326, function()
                                            end)
                                        local sp  = CSResourceMgr.getNodeByName(BattleCCSB.UPBLOOD.res,"buffguide")
                                        CocosModuleMgr.setNodeHint(sp, 2.5, nil)
                                    end
                                    BattleUIMgr.goAddEnergy(afterEnergy)
                            end, 0.5)

                            BattleGuide.isGuide = true
                            BattleGuide.funcs[GUIDE_THIRD] = nil
                            break
                        end
                    end

                    local function changePet()
                        if BattleCCSB.CARDS.outCard[2] then
                            NpcDialogueMgr.show(54, function() 
                                CocosModuleMgr.setButtonGuide(BattleCCSB.CARDS.outCard[2].button, 2.5, nil)
                            end)
                            
                        end
                        BattleGuide.funcs[GUIDE_SECOND] = nil
                    end

                    local function guideOver() 
                        GameGuideMgr.finishProcess()
                    end
                    local function outBattle()
                        guideOver()
                        --MapSeekerMgr.setSeekFunc(guideOver)
                    end 
                    BattleUIMgr.firstBattle = 1 
                    BattleGuide.funcs[GUIDE_FIRST]  = nil
                    BattleGuide.funcs[GUIDE_SECOND] = changePet
                    BattleGuide.funcs[GUIDE_THIRD]  = nil
                    BattleGuide.funcs[GUIDE_FINISH] = outBattle
                    
                    --进入战斗
                    --进度完成
                    BattleCCSB.stopAutoBattle()
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
    GameGuideMgr.checkScene("MainScene", firstBuff)
end

function GameGuideMgr.backToArena()
    local function GuideAreanStore()
        NpcDialogueMgr.show(1351, function ()
            local btnArenaStore = CSResourceMgr.getNodeByName("Player/Arena/ArenaViewNew.csb", "tab3")
            CocosModuleMgr.setButtonGuide(btnArenaStore, 3.5, function ()
                CocosModuleMgr.setScreenTouch(false)
                UnblockLoader.addCallback("ArenaExchangeMgr", function ()
                    CocosModuleMgr.setScreenTouch(true)
                    NpcDialogueMgr.show(1352, function ()
                        GameGuideMgr.finishProcess()
                    end)
                end)
            end)
        end)
    end
    if GameGuideMgr.arenaGuideStart == false then return end
    GameGuideMgr.arenaGuideStart = false
    CocosModuleMgr.setScreenTouch(false)
    UnblockLoader.addCallback("ArenaViewMgr", function ()
        CocosModuleMgr.setScreenTouch(true)
        if CSResourceMgr.getCsbObj("Player/Arena/ArenaWinView.csb") then
            SceneMgr.getRunningScene:performWithDelay(function()
                local btnReturn = CSResourceMgr.getNodeByName("Player/Arena/ArenaWinView.csb", "btn_exit")
                CocosModuleMgr.setButtonGuide(btnReturn, 3.5, function ()
                    GuideAreanStore()
                end)
            end, 0.1)
        else
            GuideAreanStore()
        end
    end)
end

function GameGuideMgr.firstArena()
    local function ArenaGuide()
        CocosModuleMgr.setScreenTouch(false)
        UnblockLoader.addCallback("ArenaMainMgr.show", function()
            CocosModuleMgr.setScreenTouch(true)
            local arenaBtn = CSResourceMgr.getNodeByName("Player/ArenaMain.csb", "b1")
            CocosModuleMgr.setButtonGuide(arenaBtn, 2.5, function()
                CocosModuleMgr.setScreenTouch(false)
                UnblockLoader.addCallback("ArenaViewMgr", function()
                    CocosModuleMgr.setScreenTouch(true)
                    NpcDialogueMgr.show(1350, function()
                        local node = ArenaViewMgr.getPlayerNodeByIndex(3) or MArenaViewMgr.getPlayerNodeByIndex(3)
                        CSResourceMgr.getNodeByName("Player/Arena/TabANew.csb", "list"):jumpToBottom()
                        local btnAtk = CSResourceMgr.seekNodeByName(node, "btn_challeng")
                        CocosModuleMgr.setButtonGuide(btnAtk, 3.5, function()
                            --battle start
                            GameGuideMgr.arenaGuideStart = true
                        end)
                    end)
                end)
            end)
        end)
    end
    MapSeekerMgr.autoSeekPath("TownScene", "b7", function()
        CocosModuleMgr.setScreenTouch(true)
        TownMapMgr.setBuildingUnlock(7, function()
            local barBtn = CSResourceMgr.getNodeByName("Map/TownMap/town_01.csb", "b7")
            CocosModuleMgr.setButtonGuide(barBtn, 2.5, function()
                ArenaGuide()
                -- GameGuideMgr.finishProcess()
            end)
        end)
    end, function()
        CocosModuleMgr.setScreenTouch(false)
        TownMapMgr.setBuildingLock(7)
    end)
end

function GameGuideMgr.firstAuction()
    local buildingID = 5
    local function firstAuction()
        --开始引导交易所
        GameGuideMgr.checkScene("TownScene", function()
            print("####交易所引导")
            CocosModuleMgr.setScreenTouch(false)
            UnblockLoader.addCallback("AuctionMgrNew.show", function()
                CocosModuleMgr.setScreenTouch(true)
                --local tab2 = CSResourceMgr.getNodeByName("Item/Auction/AuctionMainView.csb", "btn_tab2")
                --CocosModuleMgr.setButtonGuide(tab2, 1.5, function()
                --local tab12 = CSResourceMgr.getNodeByName("Item/Auction/AuctionMainView.csb", "btn_tab12")
                --CocosModuleMgr.setButtonGuide(tab12, 1.5, function()
                NpcDialogueMgr.show(1338,function()
                    --local close = CSResourceMgr.getNodeByName("Item/Auction/AuctionMainView.csb", "close")
                    --CocosModuleMgr.setButtonGuide(close, 1.5, function()
                    --进度完成
                    GameGuideMgr.finishProcess()
                    --end)
                end)
                --end)
                --end)
            end)
        end)
    end
    MapSeekerMgr.autoSeekPath("TownScene", "b"..buildingID, function()
        CocosModuleMgr.setScreenTouch(true)
        TownMapMgr.setBuildingUnlock(buildingID, function()
            local barBtn = CSResourceMgr.getNodeByName("Map/TownMap/town_01.csb", "b"..buildingID)
            CocosModuleMgr.setButtonGuide(barBtn, 2.5, function()
                firstAuction()
            end)
        end)
    end, function()
        CocosModuleMgr.setScreenTouch(false)
        TownMapMgr.setBuildingLock(buildingID)
    end)
end

function GameGuideMgr.firstAuctionClose()
   GameGuideMgr.finishProcess()
end

function GameGuideMgr.firstLifeSkill()
    local buildingID = 3
    local function firstLifeSkill()
        --开始引导生活技能
        GameGuideMgr.checkScene("TownScene", function()
            print("####生活技能引导")
            if CharInfo.getLifeSkillCareer() == 0 then
                CocosModuleMgr.setScreenTouch(false)
                UnblockLoader.addCallback("LifeSkillSelViewMgr.show", function()
                    CocosModuleMgr.setScreenTouch(true)
                    local job1 = CSResourceMgr.getNodeByName("Player/LifeSkill/LifeSkillSelJob.csb", "btn_db1")
                    CocosModuleMgr.setNodeHint(job1, 3.5, function()
                        NpcDialogueMgr.show(1332,function()
                            local job2 = CSResourceMgr.getNodeByName("Player/LifeSkill/LifeSkillSelJob.csb", "btn_db2")
                            CocosModuleMgr.setNodeHint(job2, 3.5, function()
                                NpcDialogueMgr.show(1333,function()
                                    local job3 = CSResourceMgr.getNodeByName("Player/LifeSkill/LifeSkillSelJob.csb", "btn_db3")
                                    CocosModuleMgr.setNodeHint(job3, 3.5, function()
                                        NpcDialogueMgr.show(1334,function()
                                            --local close = CSResourceMgr.getNodeByName("Player/LifeSkill/LifeSkillSelJob.csb", "btn_close")
                                            --CocosModuleMgr.setButtonGuide(close, 1.5, function()
                                            --进度完成
                                            GameGuideMgr.finishProcess()
                                            --end)
                                        end)
                                    end)
                                end)
                            end)
                        end)
                    end)
                    --CocosModuleMgr.setScreenTouch(true)
                end, 2)
            else
                GameGuideMgr.finishProcess()
                --print("####生活技能引导完成")
            end 
        end)
    end
    MapSeekerMgr.autoSeekPath("TownScene", "b"..buildingID, function()
        CocosModuleMgr.setScreenTouch(true)
        TownMapMgr.setBuildingUnlock(buildingID, function()
            local barBtn = CSResourceMgr.getNodeByName("Map/TownMap/town_01.csb", "b"..buildingID)
            CocosModuleMgr.setButtonGuide(barBtn, 2.5, function()
                firstLifeSkill()
            end)
        end)
    end, function()
        CocosModuleMgr.setScreenTouch(false)
        TownMapMgr.setBuildingLock(buildingID)
    end)
end

function GameGuideMgr.firstFamily()

end

function GameGuideMgr.firstStarRoad()

end

function GameGuideMgr.firstSignIn()
    GameGuideMgr.finishProcess()
    -- local function firstSignIn()
    --     GameGuideMgr.checkScene("MainScene", function()
    --         local function clickSignIn()
    --             local missionbtn = CSResourceMgr.getNodeByName("Charactor/extendLayer.csb", "Button_qd")
    --             if LuaSqlite.LANG_TYPE~=3 then --阿杜修改英文版不显示
    --                 CSResourceMgr.getNodeByName("Charactor/extendLayer.csb", "Text9"):setVisible(true)
    --             end
    --             CocosModuleMgr.showUnlockAnimation(missionbtn, function()
    --                 NpcDialogueMgr.show(1327, function()
    --                     CocosModuleMgr.setButtonGuide(missionbtn, 3.5, function()
    --                         GameGuideMgr.finishProcess()
    --                     end)
    --                 end)
    --             end)
    --         end
    --         if SystemOptionsMgr.getOption(1) then
    --             clickSignIn()
    --         else
    --             local statusball = CSResourceMgr.getNodeByName("Charactor/extendLayer.csb", "Button_List")
    --             CocosModuleMgr.setButtonGuide(statusball, 3.5, function()
    --                 CocosModuleMgr.setScreenTouch(false)
    --                 statusball:performWithDelay(function()
    --                     CocosModuleMgr.setScreenTouch(true)
    --                     clickSignIn()
    --                 end, 0.5)
    --             end)
    --         end
    --     end)
    -- end
    -- GameGuideMgr.checkLevelUpView(firstSignIn)
end

function GameGuideMgr.firstHome()
    local function homeGuide()
        NpcDialogueMgr.show(1328, function()
            local layoutBtn = CSResourceMgr.getNodeByName("Charactor/Menu/HomeMenu.csb", "BtnLayout")
            CocosModuleMgr.setButtonGuide(layoutBtn, 1.5, function()
                CocosModuleMgr.setScreenTouch(false)
                UnblockLoader.addCallback("FurnitureViewMgr-reset", function()
                    NpcDialogueMgr.show(1329, function()
                        CocosModuleMgr.setScreenTouch(true)
                        local itembtn = FurnitureViewMgr.getFirstFurniture()
                        if itembtn ~= nil then
                            CocosModuleMgr.setButtonGuide(itembtn, 1.5, function()
                                NpcDialogueMgr.show(1330, function()
                                    local furniture = FurnitureViewMgr.GetFurnitureForGuide()
                                    if furniture ~= nil then
                                        local effAni = AnimationMgr.createAni(furniture, "Spine/effects/Ui_xinshouyindaoshouzhi_2.png",
                                            furniture:getContentSize().width / 2, furniture:getContentSize().height / 2)
                                        --furniture:setLocalZOrder(CocosModuleMgr.ZORDER_GUIDE - 4)
                                        AnimationMgr.playAni(effAni.res, "animation", true, effAni.tag)
                                        --CocosModuleMgr.setScreenTouch(false)
                                        CocosModuleMgr.setNodeHint(furniture, 1.5, function()
                                            AnimationMgr.removeGafObjectByTag(effAni.res, effAni.tag)
                                            local finishBtn = CSResourceMgr.getNodeByName("Item/Bag/FurnitureView.csb", "finish")
                                            CocosModuleMgr.setButtonGuide(finishBtn, 1.5, function()
                                                --local expandBtn = CSResourceMgr.getNodeByName("Charactor/Menu/HomeMenu.csb", "BtnExpand")
                                                --CocosModuleMgr.setNodeHint(expandBtn, 3.5, function()
                                                --NpcDialogueMgr.show(1331, function()
                                                local exitBtn = CSResourceMgr.getNodeByName("Charactor/Menu/HomeMenu.csb", "BtnExit")
                                                CocosModuleMgr.setButtonGuide(exitBtn, 1.5, function()
                                                    --进度完成
                                                    --HomeMenuMgr.SetInGameGuide(false)
                                                    GameGuideMgr.finishProcess()
                                                end)
                                                --end)
                                                --end, 1, 2)
                                            end)
                                        end, 0, 2)
                                    end
                                end)
                            end)
                        end
                    end)
                end)
            end)
        end)
    end
    local function firstHome()
        local isExist = ItemInfo.isSofaExist()
        if isExist == false then
            GameGuideMgr.finishProcess()
            return
        end
        local homeBtn = CSResourceMgr.getNodeByName("Charactor/Menu/MainMenu.csb", "b4")
        CSResourceMgr.setSpriteTexture("Charactor/Menu/MainMenu.csb", "bb4", "UI/CommonFiles/anniu4.png")
        CSResourceMgr.getNodeByName("Charactor/Menu/MainMenu.csb", "t4"):setVisible(true)
        CocosModuleMgr.showUnlockAnimation(homeBtn, function()
            CocosModuleMgr.setButtonGuide(homeBtn, 0.5, function()
                --进入家园
                GameGuideMgr.checkScene("HomeScene", function()
                    print("####家园引导")
                    HomeMenuMgr.SetInGameGuide(true)
                    if CharInfo.getFamilyID() ~= nil then
                        local homeBtn = CSResourceMgr.getNodeByName("Charactor/Menu/HomeMenu.csb", "BtnHome")
                        CocosModuleMgr.setButtonGuide(homeBtn, 1.5, function()
                            homeGuide()
                        end)
                    else
                        homeGuide()
                    end
                end)
            end)
        end)
    end
    GameGuideMgr.checkLevelUpView(firstHome)
end

--时装引导
function GameGuideMgr.firstFashion()
    local function firstFashion()
        local HeadButton = CSResourceMgr.getNodeByName("Charactor/CharactorLayer.csb", "HeadButton")
        CocosModuleMgr.setButtonGuide(HeadButton, 3.5, function()
            CocosModuleMgr.setScreenTouch(false)
            UnblockLoader.addCallback("PersonalCenterMgr", function()
                CocosModuleMgr.setScreenTouch(true)
                local fashionBtn = CSResourceMgr.getNodeByName("Charactor/CharactorBoard.csb", "fashionBtn")
                CocosModuleMgr.showUnlockAnimation(fashionBtn, function()
                    CocosModuleMgr.setButtonGuide(fashionBtn, 3.5, function()
                        CocosModuleMgr.setScreenTouch(false)
                        UnblockLoader.addCallback("AvatarViewMgr.changeTab", function()
                            CocosModuleMgr.setScreenTouch(true)
                            local list = CSResourceMgr.getNodeByName("Player/Avatar/AvatarView.csb", "list")
                            local item = list:getItem(1)
                            CocosModuleMgr.showUnlockAnimation(item, function()
                                CocosModuleMgr.setButtonGuide(item, 3.5, function()
                                    --引导结束
                                    GameGuideMgr.finishProcess()
                                end)
                            end,1)
                        end)
                    end)
                end, 1)
            end) 
        end)
    end
    GameGuideMgr.checkLevelUpView(firstFashion)
end

--大地图传送引导
function GameGuideMgr.firstMapTransfer()
    local nodeID = 61
    local function firstMapTransfer()
        local pNode = WorldMapMgr.getMapPointNode(nodeID)
        NpcDialogueMgr.show(1364, function()
            CocosModuleMgr.setButtonGuide(pNode, 2.5, function()
                local go = CSResourceMgr.getNodeByName("Map/WorldMap/MoveTips.csb", "go")
                if go then
                    CocosModuleMgr.setButtonGuide(go, 2.5, function()
                        CocosModuleMgr.setScreenTouch(false, "firstMapTransfer")
                        --引导结束
                        GameGuideMgr.finishProcess()
                    end)
                else
                    --引导结束
                    GameGuideMgr.finishProcess()
                end
            end)
        end)
        pNode:performWithDelay(function()
            WorldMapMgr.locateToPoint(nodeID)
        end, 0.1)
    end
    if WorldMapMgr.curMapID==1 then
        GameGuideMgr.checkScene("MainScene", firstMapTransfer)
    else
        WorldMapMgr.setMapIDandPos(1, 52)
        SceneMgr.replaceScene(SceneMgr.getRunningScene, "MainScene", nil, firstMapTransfer)
    end
end