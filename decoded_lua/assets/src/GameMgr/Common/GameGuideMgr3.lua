function GameGuideMgr.newEvolutionPre()
    local function clickMission()
        local missionbtn = CSResourceMgr.getNodeByName("Charactor/extendLayer.csb", "Button_rw")
        MissionListMgr.setTab(1)
        CocosModuleMgr.setButtonGuide(missionbtn, 3.5, function()
            CocosModuleMgr.setScreenTouch(false)
            UnblockLoader.addCallback("MissionListMgr.setTabA", function()
                local msButton = nil
                for key, var in pairs(GameGuideMgr.GLOW_MISSION_ID_EVO) do
                    msButton = MissionListMgr.getMissionItemNodeByID(var)
                    if msButton then
                		break
                	end
                end
                if msButton then
                	local posx = msButton:getContentSize().width/2
                    local posy = msButton:getContentSize().height/2
                    local aniObj = AnimationMgr.createAni(msButton, "Spine/effects/UI_renwutishi.png", posx, posy)
                    AnimationMgr.playAni(aniObj.res, "animation", true, aniObj.tag)
                end
                CocosModuleMgr.setScreenTouch(true)
                NpcDialogueMgr.show(1367, function()
                    --进度完成
                    GameGuideMgr.finishProcess()
                end)
            end)
        end)
    end
    GameGuideMgr.checkScene("MainScene", function()
        NpcDialogueMgr.show(1366, function()
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
    end)
end

function GameGuideMgr.newEvolution(process)
    --GameGuideMgr.GLOW_MISSION_ID_EVO
    local petInfo = PokemonInfo.getPetInfoByObjID(1)
    if petInfo.pokeID ~= 1 and petInfo.pokeID ~= 4 and petInfo.pokeID ~= 7 then
        GameGuideMgr.finishProcess()
        return
    end
    local flag = false
    if petInfo.level >= 12 then
        flag = true
    end
    if flag then
        local function checkHaveEnoughRes()
            local evoInfo = PokemonInfo.getPetEvoInfoByID(petInfo.pokeID)
            local needLevel = evoInfo.PetEvoLevelInfoVec[1].level
            local lvEnough = needLevel <= petInfo.level
            local stageCons = evoInfo.PetEvoLevelInfoVec[1].stageCons
            local isResEnough = true
            for k,v in pairs(stageCons) do
                local elementInfo = ItemInfo.getConsumeElementInfoById(v)
                local needNum = elementInfo.num
                local elementID = elementInfo.elementID
                if elementInfo.elementType == 1 then
                    have = CharInfo.getGCash()
                elseif elementInfo.elementType == 2 then
                    have = CharInfo.getMCash()
                elseif elementInfo.elementType == 3 then
                    have = ItemInfo.getCharItemNum(elementInfo.elementID)
                end

                if have < needNum then
                    isResEnough = false
                    break
                end
            end
            return isResEnough and lvEnough
        end
        local function evolutionGuide()
            local btnEvolution = CSResourceMgr.getNodeByName("Pet/Education/PetsEducationNew.csb", "tab4")
            CocosModuleMgr.showUnlockAnimation(btnEvolution, function ()
                CocosModuleMgr.setButtonGuide(btnEvolution, 3.5, function ()
                    CocosModuleMgr.setScreenTouch(false)
                    UnblockLoader.addCallback("PetEducationMgr-evolutionPageInit", function ()
                        CocosModuleMgr.setScreenTouch(true)
                        if checkHaveEnoughRes() == true then
                            NpcDialogueMgr.show(1369, function ()
                                local bottom = CSResourceMgr.getNodeByName("Pet/Education/EvolutionPageA.csb", "bottom")
                                local btnEvolution = CSResourceMgr.seekNodeByName(bottom, "btn_strength")
                                CocosModuleMgr.setButtonGuide(btnEvolution, 3.5, function ()
                                    GameGuideMgr.finishProcess()
                                end)
                            end, 1)
                        else
                            GameGuideMgr.finishProcess()
                        end
                    end)
                end, 1)
            end, 1)
        end
        local function openListMgr()
            local btnPetList = CSResourceMgr.getNodeByName("Charactor/Menu/MainMenu.csb", "b1")
            CocosModuleMgr.setButtonGuide(btnPetList, 1.5, function ()
                CocosModuleMgr.setScreenTouch(false)
                UnblockLoader.addCallback("PetListMgr-reset", function ()
                    CocosModuleMgr.setScreenTouch(true)
                    local petNode = PetListMgr.getPetListNode(petInfo.objID)
                    if petNode then
                        local list = CSResourceMgr.getNodeByName("Pet/BasicPetList_2/PetList.csb", "list")
                        local index = PetListMgr.CheckPetIdxVec(petInfo.objID)
                        local totleLine = math.floor(PetEducationMgr.getTableLength(PokemonInfo.getAllPets()) / 4 + 
                                (PetEducationMgr.getTableLength(PokemonInfo.getAllPets()) % 4 > 0 and 1 or 0))
                        local trueLine = math.floor(index / 4 + (index % 4 > 0 and 1 or 0) - 1)
                        local percent = trueLine / totleLine * 100
                        list:jumpToPercentVertical(percent)
                        local btnNode = PetListMgr.getPetListNode(petInfo.objID).node
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
            local function openMailMgr2()
                local missionbtn = CSResourceMgr.getNodeByName("Charactor/extendLayer.csb", "Button_rw")
                MissionListMgr.setTab(1)
                CocosModuleMgr.setButtonGuide(missionbtn, 3.5, function()
                    CocosModuleMgr.setScreenTouch(false)
                    UnblockLoader.addCallback("MissionListMgr.setTabA", function()
                        CocosModuleMgr.setScreenTouch(true)
                        NpcDialogueMgr.show(1368, function ()
                            local msButton = nil
                            for key, var in pairs(GameGuideMgr.GLOW_MISSION_ID_EVO) do
                                msButton = MissionListMgr.getMissionItemNodeByID(var)
                                if msButton then
                                    break
                                end
                            end
                            local function closeFunc()
                                local closebtn = CSResourceMgr.getNodeByName("Charactor/TopInfoLayer.csb", "close")
                                CocosModuleMgr.setButtonGuide(closebtn, 3.5, function()
                                    openListMgr()
                                end)
                            end
                            if not msButton then
                                closeFunc()
                            else
                                local clickbtn = CSResourceMgr.seekNodeByName(msButton, "clain")
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
                                end
                            end
                        end)
                    end)
                end)
            end
            if SystemOptionsMgr.getOption(1) then
                openMailMgr2()
            else
                local statusball = CSResourceMgr.getNodeByName("Charactor/extendLayer.csb", "Button_List")
                CocosModuleMgr.setButtonGuide(statusball, 3.5, function()
                    CocosModuleMgr.setScreenTouch(false)
                    statusball:performWithDelay(function()
                        CocosModuleMgr.setScreenTouch(true)
                        openMailMgr2()
                    end, 0.5)
                end)
            end
        end
        UIStack.closeAllUI()
        openMailMgr()
    else
        return true
    end
end

function GameGuideMgr.newStarUpPre()
    local function clickMission()
        local missionbtn = CSResourceMgr.getNodeByName("Charactor/extendLayer.csb", "Button_rw")
        MissionListMgr.setTab(1)
        CocosModuleMgr.setButtonGuide(missionbtn, 3.5, function()
            CocosModuleMgr.setScreenTouch(false)
            UnblockLoader.addCallback("MissionListMgr.setTabA", function()
                local msButton = nil
                for key, var in pairs(GameGuideMgr.GLOW_MISSION_ID_STU) do
                    msButton = MissionListMgr.getMissionItemNodeByID(var)
                    if msButton then
                        break
                    end
                end
                if msButton then
                    local posx = msButton:getContentSize().width/2
                    local posy = msButton:getContentSize().height/2
                    local aniObj = AnimationMgr.createAni(msButton, "Spine/effects/UI_renwutishi.png", posx, posy)
                    AnimationMgr.playAni(aniObj.res, "animation", true, aniObj.tag)
                end
                CocosModuleMgr.setScreenTouch(true)
                NpcDialogueMgr.show(1371, function()
                    --进度完成
                    GameGuideMgr.finishProcess()
                end)
            end)
        end)
    end
    GameGuideMgr.checkScene("MainScene", function()
        NpcDialogueMgr.show(1370, function()
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
    end)
end

function GameGuideMgr.checkHaveEnoughRes()
    local petInfo = PokemonInfo.getPetInfoByObjID(1)
    local petStarupInfo = PokemonInfo.getPetStarUpInfoByID(petInfo.pokeID)
    local needStrength = petStarupInfo.limit[petInfo.star+1]
    local needResID = petStarupInfo.costItem[petInfo.star+1]
    local needResCount = petStarupInfo.num1[petInfo.star+1]
    local haveResCount = ItemInfo.getCharItemNum(needResID)
    local haveResPet = false
    local haveResEnough = haveResCount >= needResCount
    for k,v in pairs(PokemonInfo.getAllPets()) do
        if v.objID ~= 1 and v.pokeID == petInfo.pokeID then--假设宠物材料==自己
            haveResPet = true
            break
        end
    end
    local enable = haveResPet == true and haveResEnough == true and petInfo.Stage >= needStrength
    return enable
end
function GameGuideMgr.starUpGuide()
    local btnStarUpTab = CSResourceMgr.getNodeByName("Pet/Education/PetsEducationNew.csb", "tab3")
    CocosModuleMgr.showUnlockAnimation(btnStarUpTab, function()
        CocosModuleMgr.setButtonGuide(btnStarUpTab, 3.5, function ()
            CocosModuleMgr.setScreenTouch(false)
            UnblockLoader.addCallback("PetStarUpMgr", function ()
                CocosModuleMgr.setScreenTouch(true)
                if GameGuideMgr.checkHaveEnoughRes() == true then
                    NpcDialogueMgr.show(1373, function ()
                        local btnRes1 = PetStarUpMgr.getNeedPetNodeByIndex(2)
                        CocosModuleMgr.setButtonGuide(btnRes1, 3.5, function ()
                            CocosModuleMgr.setScreenTouch(false)
                            UnblockLoader.addCallback("PetCommonListViewMgr", function ()
                                CocosModuleMgr.setScreenTouch(true)
                                local btnRes2 = PetCommonListViewMgr.getPetNodesByIndex(1)
                                CocosModuleMgr.setButtonGuide(btnRes2, 3.5, function ()
                                    local bottom = CSResourceMgr.getNodeByName("Pet/Education/StarupPageNew.csb", "bottom")
                                    local btnStarUp = CSResourceMgr.seekNodeByName(bottom, "btn_strength")
                                    CocosModuleMgr.setButtonGuide(btnStarUp, 3.5, function ()
                                        GameGuideMgr.finishProcess()
                                    end)
                                end)
                            end)
                        end)
                    end)
                else
                    GameGuideMgr.finishProcess()
                end
            end)
        end)
    end)
end

function GameGuideMgr.selectPetNode()
    local petNode = PetListMgr.getPetListNode(1)
    if petNode then
        local list = CSResourceMgr.getNodeByName("Pet/BasicPetList_2/PetList.csb", "list")
        local index = PetListMgr.CheckPetIdxVec(1)
        local totleLine = math.floor(PetEducationMgr.getTableLength(PokemonInfo.getAllPets()) / 4 + 
                (PetEducationMgr.getTableLength(PokemonInfo.getAllPets()) % 4 > 0 and 1 or 0))
        local trueLine = math.floor(index / 4 + (index % 4 > 0 and 1 or 0) - 1)
        local percent = trueLine / totleLine * 100
        list:jumpToPercentVertical(percent)
        local btnNode = PetListMgr.getPetListNode(1).node
        CocosModuleMgr.setButtonGuide(btnNode, 3.5, function ()
            CocosModuleMgr.setScreenTouch(false)
            UnblockLoader.addCallback("PetEducationMgr", function ()
                CocosModuleMgr.setScreenTouch(true)
                GameGuideMgr.starUpGuide()
            end, 1)
        end, 1)
    else
        PetEducationMgr.show(SceneMgr.getRunningScene, 1)
        CocosModuleMgr.setScreenTouch(false)
        UnblockLoader.addCallback("PetEducationMgr", function ()
            CocosModuleMgr.setScreenTouch(true)
            GameGuideMgr.starUpGuide()
        end, 1)
    end
end

function GameGuideMgr.starUpCallBack()
    UnblockLoader.addCallback("PetListMgr-reset", function ()
        CocosModuleMgr.setScreenTouch(true)
        PetListMgr.haveGuideStarUp = false
        GameGuideMgr.selectPetNode()            
    end)
end

function GameGuideMgr.newStarUp(process)
    -- GameGuideMgr.GLOW_MISSION_ID_STU
    local petInfo = PokemonInfo.getPetInfoByObjID(1)
    if petInfo.star >= 1 then
        GameGuideMgr.finishProcess()
        return
    end
    local flag = false
    if petInfo.Stage >= 5 then
        flag = true
    end
    if flag then
        local function checkHaveNeedPetInBattleList()--检查出战宠物里有没有1级的升星宠物
            local pokeID = petInfo.pokeID
            local battleList = PokemonInfo.getActivePets()
            for k,v in pairs(battleList) do
                if v.pokeID == pokeID and v.level == 1 then
                    return true, v.objID
                end
            end
            return false, 0
        end
        local function movePetFromBattleList()
            local btnTab1 = CSResourceMgr.getNodeByName("Pet/BasicPetList_2/PetList.csb", "tab1")
            local btnTab2 = CSResourceMgr.getNodeByName("Pet/BasicPetList_2/PetList.csb", "tab2")
            CocosModuleMgr.setButtonGuide(btnTab2, 3.5, function ()
                local haveNeedPet, petObj = checkHaveNeedPetInBattleList()
                local btnNode = PetListMgr.getPetListNode(petObj).node
                CocosModuleMgr.setButtonGuide(btnNode, 3.5, function ()
                    CocosModuleMgr.setButtonGuide(btnTab1, 3.5, function ()
                        CocosModuleMgr.setScreenTouch(false)
                        PetListMgr.haveGuideStarUp = true
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
                    local haveNeedPet, petObj = checkHaveNeedPetInBattleList()
                    if haveNeedPet == true then
                        movePetFromBattleList()
                    else
                        GameGuideMgr.selectPetNode()
                    end
                end, 1)
            end, 1)
        end
        local function openMailMgr()
            local function openMailMgr2()
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
                                if msButton then
                                    break
                                end
                            end
                            local function closeFunc()
                                local closebtn = CSResourceMgr.getNodeByName("Charactor/TopInfoLayer.csb", "close")
                                CocosModuleMgr.setButtonGuide(closebtn, 3.5, function()
                                    openListMgr()
                                end)
                            end
                            if not msButton then
                                closeFunc()
                            else
                                local clickbtn = CSResourceMgr.seekNodeByName(msButton, "clain")
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
                                end
                            end
                        end)
                    end)
                end)
            end
            if SystemOptionsMgr.getOption(1) then
                openMailMgr2()
            else
                local statusball = CSResourceMgr.getNodeByName("Charactor/extendLayer.csb", "Button_List")
                CocosModuleMgr.setButtonGuide(statusball, 3.5, function()
                    CocosModuleMgr.setScreenTouch(false)
                    statusball:performWithDelay(function()
                        CocosModuleMgr.setScreenTouch(true)
                        openMailMgr2()
                    end, 0.5)
                end)
            end
        end
        UIStack.closeAllUI()
        openMailMgr()
    else
        return true
    end
end

function GameGuideMgr.battleBookGuide()
    if ItemInfo.getCharItemNum(11100) <=0 then
        GameGuideMgr.finishProcess()
        return
    end
    local function clickBattleBook()
        local bookBtn = CSResourceMgr.getNodeByName("Charactor/extendLayer.csb", "Button_sz")
        CocosModuleMgr.showUnlockAnimation(bookBtn, function ()
            CocosModuleMgr.setButtonGuide(bookBtn, 3.5, function()
                CocosModuleMgr.setScreenTouch(false)
                UnblockLoader.addCallback("PokedexMenuViewMgr", function()
                    CocosModuleMgr.setScreenTouch(true)
                    local battleBook = CSResourceMgr.getNodeByName("Charactor/PokedexMenu.csb", "pokedex_view")
                    CocosModuleMgr.setButtonGuide(battleBook, 3.5, function()
                        CocosModuleMgr.setButtonGuide(item, 3.5, function()
                            CocosModuleMgr.setScreenTouch(false)
                            UnblockLoader.addCallback("BattleManualMgr", function()
                                CocosModuleMgr.setScreenTouch(true)
                                NpcDialogueMgr.show(1376, function()
                                    --进度完成
                                    GameGuideMgr.finishProcess()
                                end)
                            end)
                        end)
                    end)
                end)
            end)
        end)
    end

    NpcDialogueMgr.show(1375, function()
        if SystemOptionsMgr.getOption(1) then
            clickBattleBook()
        else
            local statusball = CSResourceMgr.getNodeByName("Charactor/extendLayer.csb", "Button_List")
            CocosModuleMgr.setButtonGuide(statusball, 3.5, function()
                CocosModuleMgr.setScreenTouch(false)
                statusball:performWithDelay(function()
                    CocosModuleMgr.setScreenTouch(true)
                    clickBattleBook()
                end, 0.5)
            end)
        end
    end)
end

function GameGuideMgr.firstSkillPromote()
    local function getPandaObjID()
        for k,v in pairs(PokemonInfo.getAllPets()) do
            if v.pokeID == 45 then
                return v.objID
            end
        end
        return 3
    end
    local function checkPetSkillNeedLvUp()
        local objID = getPandaObjID()
        local petInfo = PokemonInfo.getPetInfoByObjID(objID)
        local skillID = petInfo.skills[2]
        local skillInfo = PokemonInfo.getPetSkillInfoById(skillID)
        local skillLv = skillInfo.id % 10
        return skillLv < 2
    end
    local function GuideSkillLvUp()
        local btnSkill = PetEducationMgr.getMainPageSkillNodeByIndex(2)
        CocosModuleMgr.setButtonGuide(btnSkill, 3.5, function ()
            CocosModuleMgr.setScreenTouch(false)
            UnblockLoader.addCallback("skillInfoPage", function ()
                CocosModuleMgr.setScreenTouch(true)
                local btnExchange = CSResourceMgr.getNodeByName(LuaSqlite.LANG_TYPE ~= 1 and "Pet/Education/SkillInfoViewUS.csb" or "Pet/Education/SkillInfoViewUS.csb", "btn_exchange")
                local btnLvUp = CSResourceMgr.getNodeByName(LuaSqlite.LANG_TYPE ~= 1 and "Pet/Education/SkillInfoViewUS.csb" or "Pet/Education/SkillInfoViewUS.csb", "btn_lvup")
                CocosModuleMgr.showUnlockAnimation(btnExchange, function ()

                end)
                CocosModuleMgr.showUnlockAnimation(btnLvUp, function ()
                    NpcDialogueMgr.show(1380, function()
                        CocosModuleMgr.setButtonGuide(btnLvUp, 3.5, function ()
                            CocosModuleMgr.setScreenTouch(false)
                            UnblockLoader.addCallback("skillLvUpPage", function ()
                                CocosModuleMgr.setScreenTouch(true)
                                local btnGuide = CSResourceMgr.getNodeByName(LuaSqlite.LANG_TYPE ~= 1 and "Pet/Education/SkillLvUpUS.csb" or "Pet/Education/SkillLvUpUS.csb", "node_guide")
                                local btnSure = CSResourceMgr.getNodeByName(LuaSqlite.LANG_TYPE ~= 1 and "Pet/Education/SkillLvUpUS.csb" or "Pet/Education/SkillLvUpUS.csb", "btn_lvup")
                                CocosModuleMgr.setNodeHint(btnGuide, 0, function ()
                                    NpcDialogueMgr.show(1380, function()
                                        CocosModuleMgr.setButtonGuide(btnSure, 3.5, function ()
                                            GameGuideMgr.finishProcess()
                                        end)
                                    end)
                                end)
                            end)
                        end)
                    end)
                end)
            end)
        end)
    end
    local function GuideOpenListMgr()
        local btnPetList = CSResourceMgr.getNodeByName("Charactor/Menu/MainMenu.csb", "b1")
        CocosModuleMgr.setButtonGuide(btnPetList, 1.5, function ()
            CocosModuleMgr.setScreenTouch(false)
            UnblockLoader.addCallback("PetListMgr-reset", function ()
                CocosModuleMgr.setScreenTouch(true)
                local petNode = PetListMgr.getPetListNode(getPandaObjID())
                if petNode then
                    local btnNode = petNode.node
                    local list = CSResourceMgr.getNodeByName("Pet/BasicPetList_2/PetList.csb", "list")
                    local index = PetListMgr.CheckPetIdxVec(getPandaObjID())
                    local totleLine = math.floor(PetEducationMgr.getTableLength(PokemonInfo.getAllPets()) / 4 + 
                            (PetEducationMgr.getTableLength(PokemonInfo.getAllPets()) % 4 > 0 and 1 or 0))
                    local trueLine = math.floor(index / 4 + (index % 4 > 0 and 1 or 0) - 1)
                    local percent = trueLine / totleLine * 100
                    list:jumpToPercentVertical(percent)
                    CocosModuleMgr.setButtonGuide(btnNode, 3.5, function ()
                        CocosModuleMgr.setScreenTouch(false)
                        UnblockLoader.addCallback("PetEducationMgr-homePageInit", function ()
                            CocosModuleMgr.setScreenTouch(true)
                            GuideSkillLvUp()
                        end, 1)
                    end, 1)
                else
                    PetEducationMgr.show(SceneMgr.getRunningScene, getPandaObjID())
                    CocosModuleMgr.setScreenTouch(false)
                    UnblockLoader.addCallback("PetEducationMgr-homePageInit", function ()
                        CocosModuleMgr.setScreenTouch(true)
                        GuideSkillLvUp()
                    end, 1)
                end
            end, 1)
        end, 1)
    end
    local function guideFunc()
    	NpcDialogueMgr.show(1379, function()
            if checkPetSkillNeedLvUp() == true then
                GuideOpenListMgr()
            else
                GameGuideMgr.finishProcess()
            end
    	end)
    end
    CocosModuleMgr.setScreenTouch(false)
    SceneMgr.getRunningScene:performWithDelay(function()
        local okbtn = CSResourceMgr.getNodeByName("Item/awardInfoView.csb", "ok")
        if okbtn then
            CocosModuleMgr.setScreenTouch(true)
            CocosModuleMgr.setButtonGuide(okbtn, 2.5, function()
                guideFunc()
            end)
        else
            guideFunc()
        end
    end, 1)
end

function GameGuideMgr.firstTeam()
    if not TeamInfo.checkLock(1) then
        local eInfoVec = WorldMapInfo.getTeamMapInfo()
        for key, var in pairs(eInfoVec) do
            if TeamInfo.checkLock(key) then
                --引导结束
                GameGuideMgr.finishProcess()
                return
            end
        end
    	return true
    end
    
    local nodeID = 67
    local function firstTeam()
        local pNode = WorldMapMgr.getMapPointNode(nodeID)
        CocosModuleMgr.showUnlockAnimation(pNode, function()
            NpcDialogueMgr.show(1382, function()
                CocosModuleMgr.setButtonGuide(pNode, 2.5, function()
                    UnblockLoader.addCallback("TeamViewMgr", function()
                        CocosModuleMgr.setScreenTouch(true)
                        NpcDialogueMgr.show(1383, function()
                            local dropBtn = CSResourceMgr.getNodeByName("Player/Team/TeamTopBar.csb", "drop")
                            CocosModuleMgr.setNodeHint(dropBtn, 2.5, function()
                                NpcDialogueMgr.show(1384, function()
                                    local lockt = CSResourceMgr.getNodeByName("Player/Team/TeamMain.csb", "locktitle")
                                    CocosModuleMgr.setNodeHint(lockt, 2.5, function()
                                        NpcDialogueMgr.show(1385, function()
                                            local b1 = CSResourceMgr.getNodeByName("Player/Team/TeamMain.csb", "create")
                                            local b2 = CSResourceMgr.getNodeByName("Player/Team/TeamMain.csb", "auto")
                                            CocosModuleMgr.setNodeHint(b1, 3, function()
                                                NpcDialogueMgr.show(1386, function()
                                                    NpcDialogueMgr.show(1387, function()
                                                        --引导结束
                                                        GameGuideMgr.finishProcess()
                                                    end)
                                                end)
                                            end)
                                            CocosModuleMgr.setNodeHint(b2, 3)
                                        end)
                                    end)
                                end)
                            end)
                        end)
                    end)
                    local go = CSResourceMgr.getNodeByName("Map/WorldMap/MoveTips.csb", "go")
                    if go then
                        CocosModuleMgr.setButtonGuide(go, 2.5, function()
                            CocosModuleMgr.setScreenTouch(false)
                        end)
                    else
                        CocosModuleMgr.setScreenTouch(false)
                    end
                end)
            end)
        end, 2)
        pNode:performWithDelay(function()
            WorldMapMgr.locateToPoint(nodeID)
        end, 0.1)
    end
    if WorldMapMgr.curMapID==1 then
        GameGuideMgr.checkScene("MainScene", firstTeam)
    else
        WorldMapMgr.setMapIDandPos(1, nodeID)
        SceneMgr.replaceScene(SceneMgr.getRunningScene, "MainScene", nil, firstTeam)
    end
end

function GameGuideMgr.firstPieceGuide()
    local function pieceGuide()
        NpcDialogueMgr.show(57, function()
            local itemList = CSResourceMgr.getNodeByName("Item/Bag/BagView.csb", "list")
            local panel = itemList:getItem(0)
            local item = CSResourceMgr.seekNodeByName(panel,"b1")
            CocosModuleMgr.setButtonGuide(item, 3.5, function()
                CocosModuleMgr.setScreenTouch(false)
                UnblockLoader.addCallback("ItemInfoViewMgr", function()
                    CocosModuleMgr.setScreenTouch(true)
                    local useBtn = CSResourceMgr.getNodeByName("Item/InfoTips/ObjectInfo.csb", "use")
                    CocosModuleMgr.setButtonGuide(useBtn, 3.5, function()
                        --进度完成
                        BagViewMgr.INGUIDE = false
                        GameGuideMgr.finishProcess()
                    end)
                end)
            end)
        end)
    end
    NpcDialogueMgr.show(56, function()
        BagViewMgr.INGUIDE = true
        local bagBtn = CSResourceMgr.getNodeByName("Charactor/Menu/MainMenu.csb", "b2")
        CocosModuleMgr.setButtonGuide(bagBtn, 3.5, function()
            CocosModuleMgr.setScreenTouch(false)
            UnblockLoader.addCallback("BagViewMgr", function()
            CocosModuleMgr.setScreenTouch(true)
                if BagViewMgr.getCurTab()~=5 then
                    local pieceBtn = CSResourceMgr.getNodeByName("Item/Bag/BagView.csb", "tab5")
                    CocosModuleMgr.setButtonGuide(pieceBtn, 3.5, function()
                        pieceGuide()
                    end)
                else
                    pieceGuide()
                end
            end)
        end)
    end)
end

function GameGuideMgr.firstPetEquip()
	local missionbtn = CSResourceMgr.getNodeByName("Charactor/extendLayer.csb", "Button_zb")
    CocosModuleMgr.showUnlockAnimation(missionbtn, function()
        GameGuideMgr.finishProcess()
    end)
end