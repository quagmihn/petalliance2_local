local PetFormationMgr = {}

PetFormationMgr.MAX_PET_NUM = 3

PetFormationMgr.TEAM_NUM = 1
PetFormationMgr.PET_NUM = 6
PetFormationMgr.WIDTH_DIFF = 98

PetFormationMgr.SEL_PET_NUM = 3
PetFormationMgr.HELP_PET_NUM = 3

local useunblockloader = true --是否使用携程，方便调试
local resName = ""
local resNameBtn = ""
local resNameBG = ""
local resNameDB = ""
local resNameSort = ""
local imageRes = ""
local tabNode = {}
local helpNode = {}
local selPet = {}
local helpPet = {}
local tabIsInit = {}
local curTab = 1
local lockInfoId = 0
local curTeamButton = {}
local curTeamPetInfo = {}
local dragSign = true

local closeCallback = nil
local dragListener = nil

local moveDiffTable = {
    93,
    93,
    124,
    93,
    93
}

function PetFormationMgr.Init()
    print("PetFormationMgr Init!")
    
    resName = "Pet/Formation/FormationView.csb"
    resNameBG = "Pet/Formation/FormationBGNew.csb"
    resNameSort = "Pet/Formation/SortView.csb"
    resNameBtn = "Pet/Formation/SortBtnView.csb"
    CSResourceMgr.createRes(nil, resName, nil, true)
    CSResourceMgr.createRes(nil, resNameBG, nil, true)
    resNameDB = "Scene/CommonShade.csb"
    imageRes = "UI/CommonFiles/kuang2.png"
    curTab = 1
    lockInfoId = 0
    for var=1, PetFormationMgr.TEAM_NUM do
    	tabNode[var] = {}
        helpNode[var] = {}
        selPet[var] = {}
        helpPet[var] = {}
        tabIsInit[var] = false
    end
    curTeamButton = {}
    curTeamPetInfo = {}
    closeCallback = nil
    dragListener = nil
    dragSign = true
end

function PetFormationMgr.closeUI()
    local isChange = false
    local petVec = PokemonInfo.getPetArmy(PetFormationMgr.getCurTab())
    local petHelpVec = PokemonInfo.getPetHelpArmy()
    if #petVec == #selPet[curTab] and #petHelpVec == #helpPet[curTab] then
        for var=1, #selPet[curTab] do
            if petVec[var] ~= selPet[curTab][var].objID then
                isChange = true
            end
        end
        for var=1, #helpPet[curTab] do
            if petHelpVec[var] ~= helpPet[curTab][var].objID then
                isChange = true
            end
        end
    else
        isChange = true
    end
    if isChange then
        PetListMgr.savePetTeam()
    end
    PetFormationMgr.hide()
    PetFreeListMgr.hide()
end

function PetFormationMgr.show(scene, callback)
    UIStack.push("PetFormationMgr", PetFormationMgr.closeUI, true)
    SceneMgr.setMapVisible(false)

    curTab = 1
    closeCallback = callback
    for var=1, PetFormationMgr.TEAM_NUM do
        tabNode[var] = {}
        helpNode[var] = {}
        selPet[var] = {}
        helpPet[var] = {}
        tabIsInit[var] = false
    end
    curTeamButton = {}
    curTeamPetInfo = {}

    for var=1, PetFormationMgr.TEAM_NUM do
        local tmpPetArmyVec = PokemonInfo.getPetArmy(var)
        for i=1, #tmpPetArmyVec do
        	local tmpPinfo = PokemonInfo.getActivePetsByObjID(tmpPetArmyVec[i])
            if not tmpPinfo then
                tmpPinfo = PokemonInfo.getUnactivePetsByObjID(tmpPetArmyVec[i])
        	end
            if tmpPinfo then
                selPet[var][i] = tmpPinfo
            -- else
            --     TipsMgr.show(scene, "Pet"..tmpPetArmyVec[i].." not find!")
            --     break
        	end
        end
        local tempHelpArmyVec = PokemonInfo.getPetHelpArmy()
        if #tempHelpArmyVec > 0 then
            for i=1, #tempHelpArmyVec do
                local tempInfo = PokemonInfo.getActiveHelperPetsByObjID(tempHelpArmyVec[i])
                helpPet[var][i] = tempInfo
            end
        end
    end
    --[[
    for var=1, #PokemonInfo.getActivePets() do
        selPet[1][var] = PokemonInfo.getActivePets()[var]
    end]]
    
    local function loadCSB()
        local curLayerBG = CSResourceMgr.createRes(scene, resNameBG, "PetFormationMgr")
        curLayerBG:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resNameBG, 320, 480, "PetFormationMgr")

        --curLayerBG:setOpacity(0)
        --transition.fadeIn(curLayerBG, {time=1})
        local curLayerDB = CSResourceMgr.createRes(scene, resNameDB, "PetFormationMgr")
        curLayerDB:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resNameDB, 320, 480, "PetFormationMgr")

        local curLayer = CSResourceMgr.createRes(scene, resName)
        curLayer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setFullScreen(resName)
        CocosModuleMgr.setEdgeDistance(curLayer, nil, nil, 0, nil)
        CSResourceMgr.getNodeByName(resName, "qh_xcd"):setVisible(false)
        CSResourceMgr.getNodeByName(resName,"bd_di"):setVisible(false)
        CSResourceMgr.getNodeByName(resName,"closeBtn"):setVisible(false)
    
        -- CSResourceMgr.setLabelColor(resName,"fightLabel",{r=144,g=238,b=255,a=255})
        -- CSResourceMgr.setLabelString(resName,"fightLabel","train52","",{r=0,g=0,b=0,a=255})

        PetFormationMgr.PET_NUM = PetFormationMgr.getMaxPetCount()
        if PetFormationMgr.PET_NUM>=PetFormationMgr.MAX_PET_NUM then
            PetFormationMgr.SEL_PET_NUM = PetFormationMgr.MAX_PET_NUM
            PetFormationMgr.HELP_PET_NUM = PetFormationMgr.PET_NUM - PetFormationMgr.MAX_PET_NUM
        else
            PetFormationMgr.SEL_PET_NUM = PetFormationMgr.PET_NUM
            PetFormationMgr.HELP_PET_NUM = 0
        end

        CSResourceMgr.getNodeByName(resName, "bd_di"):setLocalZOrder(50)
        CSResourceMgr.getNodeByName(resName, "bd_di"):setPositionY(810)

        CSResourceMgr.setButtonStringColor(resName, "b1", {r=255,g=255,b=255,a=255})
        CSResourceMgr.setButtonString(resName, "b1", "train69","", {r=209,g=138,b=0,a=255})

        local armyBG = CSResourceMgr.getNodeByName(resName,"armyBG")
        armyBG:setLocalZOrder(0)
        local helpBG = CSResourceMgr.getNodeByName(resName,"helpBG")
        helpBG:setLocalZOrder(0)
        -- PetFormationMgr.setFormationBtn()
        CSResourceMgr.setLabelColor(resName, "armyLabel", {r=107,g=124,b=144,a=255})
        CSResourceMgr.setLabelString(resName, "armyLabel", "train107")
        CSResourceMgr.setLabelColor(resName, "helpLabel", {r=107,g=124,b=144,a=255})
        CSResourceMgr.setLabelString(resName, "helpLabel", "train108")
        
        CSResourceMgr.clickEventBinding(resName, "closeBtn", function()
              PetFormationMgr.closeUI()
--            local isChange = false
--            local petVec = PokemonInfo.getPetArmy(PetFormationMgr.getCurTab())
--            local petHelpVec = PokemonInfo.getPetHelpArmy()
--            if #petVec == #selPet[curTab] and #petHelpVec == #helpPet[curTab] then
--                for var=1, #selPet[curTab] do
--                    if petVec[var] ~= selPet[curTab][var].objID then
--                        isChange = true
--                    end
--                end
--                for var=1, #helpPet[curTab] do
--                    if petHelpVec[var] ~= helpPet[curTab][var].objID then
--                        isChange = true
--                    end
--                end
--            else
--                isChange = true
--            end
--            if isChange then
--                PetListMgr.savePetTeam()
--            end
--            PetFormationMgr.hide()
--            PetFreeListMgr.hide()
        end)
    end

    function PetFormationMgr.sortAll()
        CSResourceMgr.getNodeByName(resNameBtn, "frame"):setVisible(false)
        local filename = "UI/CommonFiles/summary_filter_01.png"
        CSResourceMgr.setButtonTexture(resNameBtn,"sortBtn",filename,filename,filename)
    end

    function PetFormationMgr.sortPet(elementAtt)
        CSResourceMgr.removeCSObjectByTag(resNameSort)
        --PetListMgr.hide()
        local petVec = {}
        local myPets = PokemonInfo.getAllPets(nil, PetListMgr.isShowYokePets())
        if elementAtt ~= 0 then
            for k,v in pairs(myPets) do
                local petInfo = PokemonInfo.getPokemonInfoByID(v.pokeID)
                if petInfo.elementAtt1 == elementAtt then
                    table.insert(petVec,v)
                end
            end
        else
            petVec = myPets
        end
        PetFormationMgr.SORT_ELEMENT = elementAtt
        local tempTab = PetListMgr.getTempTab()
        local tmpnode = CSResourceMgr.getNodeByName(resName, "qh_xcd")
        local selPetVec = PetListMgr.selPetVec()
        petVec = PetListMgr.sortPetList(petVec)
        UnblockLoader.cancel("PetListMgr-reset")
        PetListMgr.reset(petVec, nil, function(petInfo)
            if tempTab == 3 then
                for index = 1 ,#selPetVec do
                    PetListMgr.setStatus(selPetVec[index], true, false, true)   
                end
            end
            for var=1, #selPet[curTab] do
                if petInfo.objID==selPet[curTab][var].objID then
                    if tempTab == 2 then
                        PetListMgr.setStatusLabel(selPet[curTab][var].objID, false)
                        PetListMgr.setStatus(selPet[curTab][var].objID, true, true, false, false)
                    else
                        PetListMgr.setStatusLabel(selPet[curTab][var].objID, true)
                    end
                    break
                end
            end
            for var=1, #helpPet[curTab] do
                if petInfo.objID==helpPet[curTab][var].objID then
                    if tempTab == 2 then
                        PetListMgr.setStatusLabel(helpPet[curTab][var].objID, false)
                        PetListMgr.setStatus(helpPet[curTab][var].objID, true, true, false, false)
                    else
                        PetListMgr.setStatusLabel(helpPet[curTab][var].objID, true)
                    end
                    break
                end
            end
            if PetEducationMgr.isPetYoked(petInfo) then
                PetListMgr.setStatusYoke(petInfo.objID, true)
            end
        end)
        --[[
        PetListMgr.show(CSResourceMgr.getNodeByName(resName, "db"),function(petInfo)
            PetEducationMgr.show(SceneMgr.getRunningScene, petInfo.objID)
        end,function()
            PetListMgr.changeTab(tempTab)
        end,nil,{x=tmpnode:getPositionX()-320, y=tmpnode:getPositionY()-480},petVec)
        ]]
    end
    
    local function playAni()
        CSResourceMgr.getNodeByName(resName,"bd_di"):setVisible(true)
        CSResourceMgr.getNodeByName(resName,"closeBtn"):setVisible(true)
        CocosModuleMgr.showUIAnimation(CSResourceMgr.getNodeByName(resName,"bd_di"),"down")
        CocosModuleMgr.showUIAnimation(CSResourceMgr.getNodeByName(resName,"closeBtn"),"down")
    end
    
    local function setTab()
        PetFormationMgr.changeTab(curTab)
    end

    local function addPetList()
        local tmpnode = CSResourceMgr.getNodeByName(resName, "qh_xcd")
        PetListMgr.show(SceneMgr.getRunningScene, function(petInfo)
            PetListMgr.setResVisible(false)
            PetEducationMgr.show(SceneMgr.getRunningScene, petInfo.objID, 1, function()
                PetListMgr.setResVisible(true)
                PetListMgr.refresh(PokemonInfo.getPetInfoByObjID(petInfo.objID))
            end)
        end, function(petInfo)
            for var=1, #selPet[curTab] do
                if petInfo.objID==selPet[curTab][var].objID then
                    PetListMgr.setStatusLabel(petInfo.objID,true)
                    return
                end
            end
            for var=1, #helpPet[curTab] do
                if petInfo.objID==helpPet[curTab][var].objID then
                    PetListMgr.setStatusLabel(petInfo.objID,true)
                    return
                end
            end
            if petInfo.yoke then
                if petInfo.yoke.bindTo then
                    PetListMgr.setStatusYoke(petInfo.objID,true)
                end
            end
        end, nil, {x=tmpnode:getPositionX()-320, y=tmpnode:getPositionY()-480})
    end

    local function setSortBtn()
        local curLayerBtn = CSResourceMgr.createRes(scene, resNameBtn)
        curLayerBtn:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resNameBtn, 320, 480)
        CocosModuleMgr.setEdgeDistance(curLayerBtn, nil, nil, nil, 0)

        local sortBtn = CSResourceMgr.getNodeByName(resNameBtn, "sortBtn")

        local function setSortView()
            CSResourceMgr.clickEventBinding(resNameSort, "allBtn", function()
                GameAudio.playUISound("sheetClick")
                PetFormationMgr.sortPet(0)
                PetFormationMgr.sortAll()
            end)
            CSResourceMgr.clickEventBinding(resNameSort, "commonBtn", function()
                GameAudio.playUISound("sheetClick")
                PetFormationMgr.sortPet(1)
                CSResourceMgr.getNodeByName(resNameBtn, "frame"):setVisible(true)
                local filename = "UI/CommonFiles/1.png"
                CSResourceMgr.setButtonTextureByNode(sortBtn,filename,filename,filename)
            end)
            CSResourceMgr.clickEventBinding(resNameSort, "fireBtn", function()
                GameAudio.playUISound("sheetClick")
                PetFormationMgr.sortPet(10)
                CSResourceMgr.getNodeByName(resNameBtn, "frame"):setVisible(true)
                local filename = "UI/CommonFiles/10.png"
                CSResourceMgr.setButtonTextureByNode(sortBtn,filename,filename,filename)
            end)
            CSResourceMgr.clickEventBinding(resNameSort, "waterBtn", function()
                GameAudio.playUISound("sheetClick")
                PetFormationMgr.sortPet(11)
                local filename = "UI/CommonFiles/11.png"
                CSResourceMgr.getNodeByName(resNameBtn, "frame"):setVisible(true)
                CSResourceMgr.setButtonTextureByNode(sortBtn,filename,filename,filename)
            end)
            CSResourceMgr.clickEventBinding(resNameSort, "groundBtn", function()
                GameAudio.playUISound("sheetClick")
                PetFormationMgr.sortPet(5)
                CSResourceMgr.getNodeByName(resNameBtn, "frame"):setVisible(true)
                local filename = "UI/CommonFiles/5.png"
                CSResourceMgr.setButtonTextureByNode(sortBtn,filename,filename,filename)
            end)
            CSResourceMgr.clickEventBinding(resNameSort, "windBtn", function()
                GameAudio.playUISound("sheetClick")
                PetFormationMgr.sortPet(3)
                CSResourceMgr.getNodeByName(resNameBtn, "frame"):setVisible(true)
                local filename = "UI/CommonFiles/3.png"
                CSResourceMgr.setButtonTextureByNode(sortBtn,filename,filename,filename)
            end)
            CSResourceMgr.clickEventBinding(resNameSort, "grassBtn", function()
                GameAudio.playUISound("sheetClick")
                PetFormationMgr.sortPet(12)
                CSResourceMgr.getNodeByName(resNameBtn, "frame"):setVisible(true)
                local filename = "UI/CommonFiles/12.png"
                CSResourceMgr.setButtonTextureByNode(sortBtn,filename,filename,filename)
            end)
            CSResourceMgr.clickEventBinding(resNameSort, "electBtn", function()
                GameAudio.playUISound("sheetClick")
                PetFormationMgr.sortPet(13)
                CSResourceMgr.getNodeByName(resNameBtn, "frame"):setVisible(true)
                local filename = "UI/CommonFiles/13.png"
                CSResourceMgr.setButtonTextureByNode(sortBtn,filename,filename,filename)
            end)
            CSResourceMgr.clickEventBinding(resNameSort, "dragonBtn", function()
                GameAudio.playUISound("sheetClick")
                PetFormationMgr.sortPet(16)
                CSResourceMgr.getNodeByName(resNameBtn, "frame"):setVisible(true)
                local filename = "UI/CommonFiles/16.png"
                CSResourceMgr.setButtonTextureByNode(sortBtn,filename,filename,filename)
            end)
            CSResourceMgr.clickEventBinding(resNameSort, "demonBtn", function()
                GameAudio.playUISound("sheetClick")
                PetFormationMgr.sortPet(18)
                CSResourceMgr.getNodeByName(resNameBtn, "frame"):setVisible(true)
                local filename = "UI/CommonFiles/18.png"
                CSResourceMgr.setButtonTextureByNode(sortBtn,filename,filename,filename)
            end)
            CSResourceMgr.clickEventBinding(resNameSort, "cover", function()
                CSResourceMgr.removeCSObjectByTag(resNameSort)
            end)
        end

        CSResourceMgr.clickEventBindingByNode(sortBtn, function()
            local curLayerSort = CSResourceMgr.createRes(scene, resNameSort)
            curLayerSort:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
            CSResourceMgr.setRelativePosition(resNameSort, 320, 480)
            curLayerSort:setPositionY(390)
            CSResourceMgr.setLabelColor(resNameSort,"Title",{r=166,g=243,b=255,a=255})
            CSResourceMgr.setLabelString(resNameSort,"Title","train127","",{r=38,g=54,b=76,a=255})
            CSResourceMgr.setLabelString(resNameSort,"allLabel","train189")
            CSResourceMgr.setLabelString(resNameSort,"commonLabel","train190")
            CSResourceMgr.setLabelString(resNameSort,"fireLabel","train191")
            CSResourceMgr.setLabelString(resNameSort,"waterLabel","train192")
            CSResourceMgr.setLabelString(resNameSort,"groundLabel","train193")
            CSResourceMgr.setLabelString(resNameSort,"windLabel","train194")
            CSResourceMgr.setLabelString(resNameSort,"grassLabel","train195")
            CSResourceMgr.setLabelString(resNameSort,"electLabel","train196")
            CSResourceMgr.setLabelString(resNameSort,"dragonLabel","train197")
            CSResourceMgr.setLabelString(resNameSort,"demonLabel","train198")
            setSortView()
            CSResourceMgr.playAction(resNameSort, 0, 5, false)
        end)
    end
    
    if useunblockloader then
        local funcTable = {loadCSB, playAni, setTab, addPetList,setSortBtn}
        UnblockLoader.load(funcTable, "PetFormationMgr")
    else
        loadCSB()
        playAni()
        setTab()
        addPetList()
        setSortBtn()
    end
end

function PetFormationMgr.moveView(offset1,offset2)
    transition.moveTo(CSResourceMgr.getNodeByName(resName,"bd_di"), {y=offset1, time=0.2})
    transition.moveTo(CSResourceMgr.getNodeByName(resNameBtn,"db"), {y=offset2, time=0.2})
end

function PetFormationMgr.hide()
    SceneMgr.setMapVisible(true)
    UnblockLoader.cancel("PetFormationMgr")
    UnblockLoader.cancel("PetFormationMgr-changeTab")
    for var=1, PetFormationMgr.TEAM_NUM do
        for i=1, PetFormationMgr.SEL_PET_NUM do
    		if tabNode[var][i] then
                CSResourceMgr.removeCSObjectByTag(tabNode[var][i].res, tabNode[var][i].tag)
    		end
    	end
    end
    tabNode = {}
    for var=1, PetFormationMgr.TEAM_NUM do
        for i=1, PetFormationMgr.HELP_PET_NUM do
            if helpNode[var][i] then
                CSResourceMgr.removeCSObjectByTag(helpNode[var][i].res, helpNode[var][i].tag)
            end
        end
    end
    helpNode = {}
    curTab = 1
    PetListMgr.hide()
    PetFreeListMgr.hide()
	CSResourceMgr.removeCSObjectByTag(resName)
    CSResourceMgr.removeCSObjectByTag(resNameBtn)
    CSResourceMgr.removeCSObjectByTag(resNameBG, "PetFormationMgr")
    CSResourceMgr.removeCSObjectByTag(resNameDB, "PetFormationMgr")
    if closeCallback then
        closeCallback()
        closeCallback = nil
    end
    dragListener = nil
    for var=1, PetFormationMgr.TEAM_NUM do
        tabNode[var] = {}
        helpNode[var] = {}
    end
    GameAudio.playUISound("retract")
    UIStack.pop("PetFormationMgr")
end

function PetFormationMgr.changeTab(tabid, useUnblockLoader)
    local preTabid = curTab
    local function t1()
        for var=1, PetFormationMgr.TEAM_NUM do
            --CSResourceMgr.setButtonString(resName, "b"..var, CocosModuleMgr.createStringWithFormat({"队伍<1>", var}), "",
            --    {r=102,g=51,b=0,a=255})
            CSResourceMgr.setButtonEnabled(resName, "b"..var, true)
        end
        --CSResourceMgr.setButtonString(resName, "b"..tabid, CocosModuleMgr.createStringWithFormat({"队伍<1>", tabid}), "",
        --    {r=51,g=0,b=0,a=255})
        CSResourceMgr.setButtonEnabled(resName, "b"..tabid, false)
        for var=1, #tabNode[curTab] do
            tabNode[curTab][var]:setVisible(false)
        end
        for var=1, #helpNode[curTab] do
            helpNode[curTab][var]:setVisible(false)
        end
        curTab = tabid
        for var=1, #tabNode[curTab] do
            tabNode[curTab][var]:setVisible(true)
        end
        for var=1, #helpNode[curTab] do
            helpNode[curTab][var]:setVisible(true)
        end
    end
    
    local function t2()
        --[[
        for var=1, PetFormationMgr.TEAM_NUM do
            for i=1, #selPet[var] do
                if var==curTab then
                    BasicPetListMgr.setStatus(selPet[var][i].objID, true, true, false,false)
                else
                    BasicPetListMgr.setStatus(selPet[var][i].objID, false, false, false,true)
                end
            end
        end]]
        local tab = PetListMgr.getTempTab()
        if tab == 2 then
            local isChange = false
            local petVec = PokemonInfo.getPetArmy(PetFormationMgr.getCurTab())
            local petHelpVec = PokemonInfo.getPetHelpArmy()
            if #petVec == #selPet[curTab] and #petHelpVec == #helpPet[curTab] then
                for var=1, #selPet[curTab] do
                    if petVec[var] ~= selPet[curTab][var].objID then
                        isChange = true
                    end
                end
                for var=1, #helpPet[curTab] do
                    if petHelpVec[var] ~= helpPet[curTab][var].objID then
                        isChange = true
                    end
                end
            else
                isChange = true
            end
            if isChange then
                PetListMgr.savePetTeam()
            end
            for var=1, #selPet[curTab] do
                PetListMgr.setStatusLabel(selPet[curTab][var].objID, false)
            end
            for var=1, #helpPet[curTab] do
                PetListMgr.setStatusLabel(helpPet[curTab][var].objID, false)
            end
            for var=1, #selPet[curTab] do
                PetListMgr.setStatus(selPet[curTab][var].objID, true, true, false, false)
            end
            for var=1, #helpPet[curTab] do
                PetListMgr.setStatus(helpPet[curTab][var].objID, true, true, false, false)
            end
        else
            if #selPet[curTab] == 0 then
                for var=1, #selPet[curTab] do
                    PetListMgr.setStatusLabel(selPet[curTab][var].objID, false)
                end
            else
                for var=1, #selPet[curTab] do
                    PetListMgr.setStatusLabel(selPet[curTab][var].objID, true)
                end
            end
            if #helpPet[curTab] == 0 then
                for var=1, #helpPet[curTab] do
                    PetListMgr.setStatusLabel(helpPet[curTab][var].objID, false)
                end
            else
                for var=1, #helpPet[curTab] do
                    PetListMgr.setStatusLabel(helpPet[curTab][var].objID, true)
                end
            end
            for var=1, #selPet[curTab] do
                PetListMgr.setStatus(selPet[curTab][var].objID, true, false, false, false)
            end
            for var=1, #helpPet[curTab] do
                PetListMgr.setStatus(helpPet[curTab][var].objID, true, false, false, false)
            end
        end
        local myPets = PokemonInfo.getAllPets()
        for k,v in pairs(myPets) do
            if v.yoke then
                if v.yoke.bindTo then
                    PetListMgr.setStatusYoke(v.objID,true)
                end
            end
        end
    end
    
    local function t3()
        PetFormationMgr.setFightPower(PokemonInfo.getFightPoint(selPet[curTab]))
        PetListMgr.setPnum()

        if not tabIsInit[curTab] then
            curTeamButton = {}
            curTeamPetInfo = {}
            for key, var in pairs(tabNode[curTab]) do
                CSResourceMgr.removeCSObjectByTag(var.res, var.tag)
            end
            for key, var in pairs(helpNode[curTab]) do
                CSResourceMgr.removeCSObjectByTag(var.res, var.tag)
            end
            tabNode[curTab] = {}
            helpNode[curTab] = {}
            for var=1, #selPet[curTab] do
                local petInfo = selPet[curTab][var] 
                local pNode = PetListMgr.createPetNode(petInfo, curTab)
                pNode.node:addTo(CSResourceMgr.getNodeByName(resName, "teamdb"..#tabNode[curTab]+1))
                pNode.node:setPosition(0, 0)
                pNode.node:setAnchorPoint(0, 0)
                curTeamButton[var] = pNode.button
                curTeamPetInfo[var] = petInfo
                tabNode[curTab][#tabNode[curTab]+1] = pNode.node
            end
            for var=1, #helpPet[curTab] do
                local petInfo = helpPet[curTab][var] 
                local pNode = PetListMgr.createPetNode(petInfo, curTab)
                pNode.node:addTo(CSResourceMgr.getNodeByName(resName, "teamdb"..#helpNode[curTab]+1+PetFormationMgr.MAX_PET_NUM))
                pNode.node:setPosition(0, 0)
                pNode.node:setAnchorPoint(0, 0)
                curTeamButton[var+PetFormationMgr.MAX_PET_NUM] = pNode.button
                curTeamPetInfo[var+PetFormationMgr.MAX_PET_NUM] = petInfo
                helpNode[curTab][#helpNode[curTab]+1] = pNode.node
            end
            tabIsInit[curTab] = true
        end
        for var=1, #selPet[curTab] do
            curTeamButton[var] = CSResourceMgr.seekNodeByName(tabNode[curTab][var], "diban")
            curTeamPetInfo[var] = selPet[curTab][var]
            local tmpBtn = curTeamButton[var]
            local tmpInfo = curTeamPetInfo[var]
            local tab = PetListMgr.getTempTab()
            if tab == 2 then
                PetFormationMgr.dragEventBinding(tmpBtn, tmpInfo)
            else
                CSResourceMgr.clickEventBindingByNode(tmpBtn, function()
                    PetEducationMgr.show(SceneMgr.getRunningScene, tmpInfo.objID)
                end, 3)
            end
        end
        for var=1, #helpPet[curTab] do
            curTeamButton[var+PetFormationMgr.MAX_PET_NUM] = CSResourceMgr.seekNodeByName(helpNode[curTab][var], "diban")
            curTeamPetInfo[var+PetFormationMgr.MAX_PET_NUM] = helpPet[curTab][var]
            local tmpBtn = curTeamButton[var+PetFormationMgr.MAX_PET_NUM]
            local tmpInfo = curTeamPetInfo[var+PetFormationMgr.MAX_PET_NUM]
            local tab = PetListMgr.getTempTab()
            if tab == 2 then
                PetFormationMgr.dragEventBinding(tmpBtn, tmpInfo)
            else
                CSResourceMgr.clickEventBindingByNode(tmpBtn, function()
                    PetEducationMgr.show(SceneMgr.getRunningScene, tmpInfo.objID)
                end, 3)
            end
        end
    end
    
    local function t4()
        -- CSResourceMgr.setSpriteTexture(resName, "teamdb1", "empty.png")
        -- CSResourceMgr.setSpriteTexture(resName, "teamdb"..#tabNode[preTabid]+1, "empty.png")
        for i=(#tabNode[curTab]+1), PetFormationMgr.MAX_PET_NUM do
            CSResourceMgr.setSpriteTexture(resName, "teamdb"..i, imageRes)
        end
        for i=(#helpNode[curTab]+1), PetFormationMgr.MAX_PET_NUM do
            CSResourceMgr.setSpriteTexture(resName, "teamdb"..i+PetFormationMgr.MAX_PET_NUM, imageRes)
        end

        for i=3,PetFormationMgr.PET_NUM do
            CSResourceMgr.getNodeByName(resName, "lock"..i):setVisible(false)
        end
        for i=PetFormationMgr.PET_NUM+1, PetFormationMgr.MAX_PET_NUM*2 do
            CSResourceMgr.getNodeByName(resName, "lock"..i):setVisible(true)
        end
        local var = PetFormationMgr.PET_NUM+1
        for i=3,var-1 do
            CSResourceMgr.setLabelString(resName, "tip"..i ," ")
        end
        if lockInfoId >= 9001 and lockInfoId <= 9004 then
            for i=lockInfoId,9004 do
                local lockInfo = SystemInfo.getGlobalConfigAddInfoByID(i)
                for k,v in pairs(lockInfo.values) do
                    CSResourceMgr.setLabelString(resName, "tip"..var ,CocosModuleMgr.createStringWithFormat({"train51", v}))
                    CSResourceMgr.setLabelColor(resName, "tip"..var ,{r=144,g=161,b=176,a=255})
                    var = var + 1
                end
            end
        end
    end
    
    if useUnblockLoader then
    	UnblockLoader.load({t1, t2, t3, t4}, "PetFormationMgr-changeTab", 0.01)
    else
        t1()
        t3()
        t2()
        t4()
    end
end

function PetFormationMgr.setDragListener(listener)
    dragListener = listener
end

function PetFormationMgr.leaveTeam(petInfo)
    for var=1, #selPet[curTab] do
        if selPet[curTab][var].objID==petInfo.objID then
            if #selPet[curTab] > 1 then
                CSResourceMgr.removeCSObjectByTag(tabNode[curTab][var].res, tabNode[curTab][var].tag)
                table.remove(selPet[curTab], var)
                table.remove(tabNode[curTab], var)
                curTeamButton[var] = nil
                curTeamPetInfo[var] = nil
                for i=var, #tabNode[curTab] do
                    curTeamButton[i] = curTeamButton[i+1]
                end
                for i=var, #tabNode[curTab] do
                    curTeamPetInfo[i] = curTeamPetInfo[i+1]
                end
                for i=#tabNode[curTab]+1,PetFormationMgr.MAX_PET_NUM do
                    curTeamButton[i] = nil
                end
                for i=#tabNode[curTab]+1,PetFormationMgr.MAX_PET_NUM do
                    curTeamPetInfo[i] = nil
                end

                local moveFlag = false
                for i=var, #selPet[curTab] do
                    transition.moveBy(tabNode[curTab][i], {x=-moveDiffTable[i], time=0.2})
                    tabNode[curTab][i]:setTouchEnabled(false)
                    moveFlag = true
                end
                local function setPlusTag()
                    CSResourceMgr.setSpriteTexture(resName, "teamdb"..#tabNode[curTab]+1, "empty.png")
                    for i=(#tabNode[curTab]+1),PetFormationMgr.MAX_PET_NUM do
                        CSResourceMgr.setSpriteTexture(resName, "teamdb"..i, imageRes)
                    end
                end
                if moveFlag then
                    CSResourceMgr.getCsbObj(resName):performWithDelay(function()
                        setPlusTag()
                        PetFormationMgr.setFightPower(PokemonInfo.getFightPoint(selPet[curTab]))
                        for i=var, #selPet[curTab] do
                            tabNode[curTab][i]:setTouchEnabled(true)
                        end
                    end, 0.2)
                else
                    setPlusTag()
                    PetFormationMgr.setFightPower(PokemonInfo.getFightPoint(selPet[curTab]))
                end
            else
                DialogBoxMgr.showSmallDialogBox(nil, 1, "train53")
                curTeamButton[1]:setPosition(curTeamButton[1]:getContentSize().width/1.68, curTeamButton[1]:getContentSize().height/1.32)
            end
            return
        end
    end
    if #helpPet[curTab] > 0 then
        for var=1, #helpPet[curTab] do
            if helpPet[curTab][var].objID==petInfo.objID then
                CSResourceMgr.removeCSObjectByTag(helpNode[curTab][var].res, helpNode[curTab][var].tag)
                table.remove(helpPet[curTab], var)
                table.remove(helpNode[curTab], var)
                curTeamButton[var+PetFormationMgr.MAX_PET_NUM] = nil
                curTeamPetInfo[var+PetFormationMgr.MAX_PET_NUM] = nil
                for i=var, #helpNode[curTab] do
                    curTeamButton[i+PetFormationMgr.MAX_PET_NUM] = curTeamButton[i+PetFormationMgr.MAX_PET_NUM+1]
                end
                for i=var, #helpNode[curTab] do
                    curTeamPetInfo[i+PetFormationMgr.MAX_PET_NUM] = curTeamPetInfo[i+PetFormationMgr.MAX_PET_NUM+1]
                end
                for i=#helpNode[curTab]+1,PetFormationMgr.MAX_PET_NUM*2 do
                    curTeamButton[i+PetFormationMgr.MAX_PET_NUM] = nil
                end
                for i=#helpNode[curTab]+1,PetFormationMgr.MAX_PET_NUM*2 do
                    curTeamPetInfo[i+PetFormationMgr.MAX_PET_NUM] = nil
                end

                local moveFlag = false
                for i=var, #helpPet[curTab] do
                    transition.moveBy(helpNode[curTab][i], {x=-moveDiffTable[i], time=0.2})
                    helpNode[curTab][i]:setTouchEnabled(false)
                    moveFlag = true
                end
                local function setPlusTag()
                    CSResourceMgr.setSpriteTexture(resName, "teamdb"..#helpNode[curTab]+PetFormationMgr.MAX_PET_NUM+1, "empty.png")
                    for i=(#helpNode[curTab]+1),PetFormationMgr.MAX_PET_NUM do
                        CSResourceMgr.setSpriteTexture(resName, "teamdb"..i+PetFormationMgr.MAX_PET_NUM, imageRes)
                    end
                end
                if moveFlag then
                    CSResourceMgr.getCsbObj(resName):performWithDelay(function()
                        setPlusTag()
                        for i=var, #helpPet[curTab] do
                            helpNode[curTab][i]:setTouchEnabled(true)
                        end
                    end, 0.2)
                else
                    setPlusTag()
                end
            end
        end
    end
end

function PetFormationMgr.dragEventBinding(button, petInfo)
    local curPetPos = {x=0, y=0}
    
    local cancelFunc = function()
        if not button then
            return
        end
        local originPet = nil
        local originPetNode = nil
        local idx = 0
        for var=1, #selPet[curTab] do
            if selPet[curTab][var].objID==petInfo.objID then
                idx = var
                originPet = selPet[curTab][var]
                originPetNode = tabNode[curTab][var]
            end
        end
        for var=1, #helpPet[curTab] do
            if helpPet[curTab][var].objID==petInfo.objID then
                idx = var+PetFormationMgr.MAX_PET_NUM
                originPet = helpPet[curTab][var]
                originPetNode = helpNode[curTab][var]
            end
        end
        if idx==0 then
            return
        end
        
        local exchangePetID = 0
        if button:getParent() then
            button:getParent():getParent():setLocalZOrder(50)
        else
            return
        end
        local moveidx = 0
        local posx = button:getPositionX()
        local posy = button:getPositionY()
        moveidx = math.floor(posx/PetFormationMgr.WIDTH_DIFF)
        if posy<-100 and dragSign then
            if PetListMgr.getPetListNode(petInfo.objID)~=nil then
                CSResourceMgr.ButtonFuncTable[PetListMgr.getPetListNode(petInfo.objID).node](petInfo)
            else
                PetFormationMgr.leaveTeam(petInfo)
            end
            return
        end

        local terminalIndex = idx+moveidx
        local terminalPet = selPet[curTab][terminalIndex]
        local terminalPetNode = tabNode[curTab][terminalIndex]
        if terminalIndex>PetFormationMgr.MAX_PET_NUM and PetFormationMgr.HELP_PET_NUM > 0 then
            terminalPet = helpPet[curTab][terminalIndex-PetFormationMgr.MAX_PET_NUM]
            terminalPetNode = helpNode[curTab][terminalIndex-PetFormationMgr.MAX_PET_NUM]
            if not helpNode[curTab][terminalIndex-PetFormationMgr.MAX_PET_NUM] and idx < 4 and #tabNode[curTab] > 1 and #helpNode[curTab] < PetFormationMgr.PET_NUM - PetFormationMgr.MAX_PET_NUM then
                GameAudio.playUISound("petDrag")
                CSResourceMgr.setSpriteTexture(resName, "teamdb"..idx, imageRes)
                CSResourceMgr.setSpriteTexture(resName, "teamdb"..#helpNode[curTab]+1+PetFormationMgr.MAX_PET_NUM, "empty.png")
                local pNode = PetListMgr.createPetNode(petInfo, curTab)
                pNode.node:addTo(CSResourceMgr.getNodeByName(resName, "teamdb"..#helpNode[curTab]+1+PetFormationMgr.MAX_PET_NUM))
                pNode.node:setPosition(0, 0)
                pNode.node:setAnchorPoint(0, 0)
                helpNode[curTab][#helpNode[curTab]+1] = pNode.node
                helpPet[curTab][#helpPet[curTab]+1] = petInfo
                PetFormationMgr.dragEventBinding(pNode.button, petInfo)
                curTeamButton[#helpNode[curTab]+PetFormationMgr.MAX_PET_NUM] = pNode.button
                curTeamPetInfo[#helpNode[curTab]+PetFormationMgr.MAX_PET_NUM] = petInfo
                table.remove(tabNode[curTab], idx)
                table.remove(selPet[curTab], idx)
                curTeamButton[idx] = nil
                curTeamPetInfo[idx] = nil

                for i=idx, #tabNode[curTab] do
                    curTeamButton[i] = curTeamButton[i+1]
                end
                for i=idx, #tabNode[curTab] do
                    curTeamPetInfo[i] = curTeamPetInfo[i+1]
                end
                for i=#tabNode[curTab]+1,PetFormationMgr.MAX_PET_NUM do
                    curTeamButton[i] = nil
                end
                for i=#tabNode[curTab]+1,PetFormationMgr.MAX_PET_NUM do
                    curTeamPetInfo[i] = nil
                end
                local moveFlag = false
                CSResourceMgr.setSpriteTexture(resName, "teamdb"..idx, "empty.png")
                for i=idx, #selPet[curTab] do
                    transition.moveBy(tabNode[curTab][i], {x=-93, time=0.2})
                    tabNode[curTab][i]:setTouchEnabled(false)
                    moveFlag = true
                end
                local function setPlusTag()
                    for i=(#tabNode[curTab]+1),PetFormationMgr.MAX_PET_NUM do
                        CSResourceMgr.setSpriteTexture(resName, "teamdb"..i, imageRes)
                    end
                end
                if moveFlag then
                    CSResourceMgr.getCsbObj(resName):performWithDelay(function()
                        setPlusTag()
                        PetFormationMgr.setFightPower(PokemonInfo.getFightPoint(selPet[curTab]))
                        for i=idx, #selPet[curTab] do
                            tabNode[curTab][i]:setTouchEnabled(true)
                        end
                    end, 0.2)
                else
                    setPlusTag()
                end
            end
        else
            if not tabNode[curTab][terminalIndex] and idx > 3 then
                GameAudio.playUISound("petDrag")
                CSResourceMgr.setSpriteTexture(resName, "teamdb"..#helpNode[curTab]+PetFormationMgr.MAX_PET_NUM, imageRes)
                CSResourceMgr.setSpriteTexture(resName, "teamdb"..#tabNode[curTab]+1, "empty.png")
                local pNode = PetListMgr.createPetNode(petInfo, curTab)
                pNode.node:addTo(CSResourceMgr.getNodeByName(resName, "teamdb"..#tabNode[curTab]+1))
                pNode.node:setPosition(0, 0)
                pNode.node:setAnchorPoint(0, 0)
                tabNode[curTab][#tabNode[curTab]+1] = pNode.node
                selPet[curTab][#selPet[curTab]+1] = petInfo
                PetFormationMgr.dragEventBinding(pNode.button, petInfo)
                curTeamButton[#tabNode[curTab]] = pNode.button
                curTeamPetInfo[#tabNode[curTab]] = petInfo
                table.remove(helpNode[curTab], idx-PetFormationMgr.MAX_PET_NUM)
                table.remove(helpPet[curTab], idx-PetFormationMgr.MAX_PET_NUM)
                curTeamButton[idx] = nil
                curTeamPetInfo[idx] = nil

                for i=idx-PetFormationMgr.MAX_PET_NUM, #helpNode[curTab] do
                    curTeamButton[i+PetFormationMgr.MAX_PET_NUM] = curTeamButton[i+PetFormationMgr.MAX_PET_NUM+1]
                end
                for i=idx-PetFormationMgr.MAX_PET_NUM, #helpNode[curTab] do
                    curTeamPetInfo[i+PetFormationMgr.MAX_PET_NUM] = curTeamPetInfo[i+PetFormationMgr.MAX_PET_NUM+1]
                end
                for i=#helpNode[curTab]+1,PetFormationMgr.MAX_PET_NUM*2 do
                    curTeamButton[i+PetFormationMgr.MAX_PET_NUM] = nil
                end
                for i=#helpNode[curTab]+1,PetFormationMgr.MAX_PET_NUM*2 do
                    curTeamPetInfo[i+PetFormationMgr.MAX_PET_NUM] = nil
                end
                local moveFlag = false
                CSResourceMgr.setSpriteTexture(resName, "teamdb"..idx, "empty.png")
                for i=idx-PetFormationMgr.MAX_PET_NUM, #helpPet[curTab] do
                    transition.moveBy(helpNode[curTab][i], {x=-93, time=0.2})
                    helpNode[curTab][i]:setTouchEnabled(false)
                    moveFlag = true
                end
                local function setPlusTag()
                    for i=(#helpNode[curTab]+1),PetFormationMgr.MAX_PET_NUM do
                        CSResourceMgr.setSpriteTexture(resName, "teamdb"..i+PetFormationMgr.MAX_PET_NUM, imageRes)
                    end
                end
                if moveFlag then
                    CSResourceMgr.getCsbObj(resName):performWithDelay(function()
                        setPlusTag()
                        for i=idx-PetFormationMgr.MAX_PET_NUM, #helpPet[curTab] do
                            helpNode[curTab][i]:setTouchEnabled(true)
                        end
                    end, 0.2)
                else
                    setPlusTag()
                end
            end
        end

        if not terminalPet or moveidx==0 then
            button:setPosition(curPetPos.x, curPetPos.y)
        else
            GameAudio.playUISound("petDrag")
            local p1 = originPetNode
            local p2 = terminalPetNode
            local s1 = originPet
            local s2 = terminalPet
            p1:removeFromParent(true)
            p2:removeFromParent(true)
            if idx>PetFormationMgr.MAX_PET_NUM then
                helpPet[curTab][idx-PetFormationMgr.MAX_PET_NUM] = s2
            else
                selPet[curTab][idx] = s2
            end
            if terminalIndex>PetFormationMgr.MAX_PET_NUM then
                helpPet[curTab][terminalIndex-PetFormationMgr.MAX_PET_NUM] = s1
            else
                selPet[curTab][terminalIndex] = s1
            end
            local pNode1 = PetListMgr.createPetNode(s1, curTab)
            pNode1.node:addTo(CSResourceMgr.getNodeByName(resName, "teamdb"..idx+moveidx))
            pNode1.node:setPosition(0, 0)
            pNode1.node:setAnchorPoint(0, 0)
            pNode1.node:setTouchEnabled(false)
            pNode1.node:getParent():getParent():setLocalZOrder(70)
            PetFormationMgr.dragEventBinding(pNode1.button, s1)
            local pNode2 = PetListMgr.createPetNode(s2, curTab)
            pNode2.node:addTo(CSResourceMgr.getNodeByName(resName, "teamdb"..idx))
            pNode2.node:setPosition(moveidx*PetFormationMgr.WIDTH_DIFF, 0)
            pNode2.node:setAnchorPoint(0, 0)
            pNode2.node:setTouchEnabled(false)
            pNode2.node:getParent():getParent():setLocalZOrder(60)
            PetFormationMgr.dragEventBinding(pNode2.button, s2)
            if idx>PetFormationMgr.MAX_PET_NUM then
                helpNode[curTab][idx-PetFormationMgr.MAX_PET_NUM] = pNode2.node
            else
                tabNode[curTab][idx] = pNode2.node
            end
            if terminalIndex>PetFormationMgr.MAX_PET_NUM then
                helpNode[curTab][terminalIndex-PetFormationMgr.MAX_PET_NUM] = pNode1.node
            else
                tabNode[curTab][terminalIndex] = pNode1.node
            end
            transition.moveTo(pNode2.node, {x=0, time=0.2})
            pNode1.node:performWithDelay(function()
                pNode1.node:setTouchEnabled(true)
                pNode1.node:getParent():getParent():setLocalZOrder(50)
            end, 0.2)
            pNode2.node:performWithDelay(function()
                pNode2.node:setTouchEnabled(true)
                pNode2.node:getParent():getParent():setLocalZOrder(50)
            end, 0.2)
            --exchange teaminfo
            curTeamButton[idx] = pNode2.button
            curTeamButton[idx+moveidx] = pNode1.button;
            
            curTeamPetInfo[idx] = s2
            curTeamPetInfo[idx+moveidx] = s1
        end
        if dragListener then
        	dragListener()
        end
    end
    
    CSResourceMgr.buttonEventBindingByNode(button, function()
        if not button then
            return
        end
        local px = button:getPositionX()
        local py = button:getPositionY()
        curPetPos = {x=px, y=py}
        button:getParent():getParent():setLocalZOrder(60)
    end, function(sender)
        cancelFunc()
    end, function(sender)
        if not button then
            return
        end
        if sender~=nil then
            local event = {x = 0, y = 0}
            local bx = sender:getTouchBeganPosition().x
            local by = sender:getTouchBeganPosition().y
            local x = sender:getTouchMovePosition().x
            local y = sender:getTouchMovePosition().y
            button:setPosition(curPetPos.x-bx+x, curPetPos.y-by+y)
        end
    end, function(sender)
        cancelFunc()
    end)
end

function PetFormationMgr.getSelPet()
    return selPet
end

function PetFormationMgr.getHelpPet()
    return helpPet
end

function PetFormationMgr.getTabNode()
    return tabNode
end

function PetFormationMgr.getHelpNode()
	return helpNode
end

function PetFormationMgr.getCurTab()
	return curTab
end

function PetFormationMgr.getTabIsInit()
    return tabIsInit
end

function PetFormationMgr.getCurTeamInfo()
    return curTeamButton,curTeamPetInfo
end

function PetFormationMgr.setFightPower(count)
    CSResourceMgr.setLabelColor(resName,"fightPower",{r=255,g=252,b=0,a=255})
    CSResourceMgr.setLabelString(resName,"fightPower",count)
end
function PetFormationMgr.getMaxPetCount()
    local level = CharInfo.getLevel()
    local enable = true
    local maxPetCnt = 0
    lockInfoId = 0

    for i=9001,9004 do
        local lockInfo = SystemInfo.getGlobalConfigAddInfoByID(i)
        for k,v in pairs(lockInfo.values) do
            if level < v and enable then
                lockInfoId = i
                enable = false
            end
        end
    end

    if lockInfoId == 9001 then
        maxPetCnt = 2
    elseif lockInfoId == 9002 then
        maxPetCnt = 3
    elseif lockInfoId == 9003 then
        maxPetCnt = 4
    elseif lockInfoId == 9004 then
        maxPetCnt = 5
    else
        maxPetCnt = 6
    end

    return maxPetCnt
end

function PetFormationMgr.addPetArmy(level)
    local enable = true
    for i=9001,9004 do
        local lockInfo = SystemInfo.getGlobalConfigAddInfoByID(i)
        for k,v in pairs(lockInfo.values) do
            if level == v then
                enable = true
            end
        end
    end
    local petArmy = PokemonInfo.getPetArmy(1)
    local petHelpVec = PokemonInfo.getPetHelpArmy()
    local count = PetFormationMgr.getMaxPetCount()
    local unactivePets = PokemonInfo.getUnactivePets()
    local petTable = {}
    local selCount = 0
    local helpCount = 0
    if count >= PetFormationMgr.MAX_PET_NUM then
        selCount = PetFormationMgr.MAX_PET_NUM - #petArmy
        helpCount = count - PetFormationMgr.MAX_PET_NUM - #petHelpVec
    else
        selCount = count - #petArmy
        helpCount = 0
    end
    for k,v in pairs(unactivePets) do
        local isRepeat = false
        for k1,v1 in pairs(selPet[curTab]) do
            if v1.pokeID == v.pokeID then
                isRepeat = true
            end
        end
        for k1,v1 in pairs(helpPet[curTab]) do
            if v1.pokeID == v.pokeID then
                isRepeat = true
            end
        end
        if not isRepeat then
            table.insert(petTable,v.objID)
        end
    end
    if enable and #petTable > 0 and count > 0 then
        if selCount > 0 then
            for i=1,selCount do
                table.insert(petArmy, petTable[i])
            end
        end
        if helpCount > 0 then
            for i=1,helpCount do
                table.insert(petHelpVec, petTable[i+selCount])
            end
        end
        NetInterface.sendWithBlock("GC_UpdatePetArmys_Ack", function()
            local PetSend = require("src.Net.Send.PetSend")
            PetSend.sendCG_UpdatePetArmys_Req({petArmys={{armyIndex=1, armyMembers=petArmy,helpArmyMembers = petHelpVec}}})
        end, function()
            PokemonInfo.setPetArmyByIdx(1,petArmy)
            for k,v in pairs(petHelpVec) do
                table.filter(unactivePets, function(v, k)
                   return v.objID ~= petHelpVec
                end)
            end
            PokemonInfo.setHelpArmy(petHelpVec)
        end, function(code)
            TipsMgr.showError(nil, code)
        end)
    end
end

function PetFormationMgr.setResVisible(enable)
    if not CSResourceMgr.getCsbObj(resName) then
        return
    end
    resName:setVisible(enable)
end

function PetFormationMgr.setDragEvent(enable)
    dragSign = enable
 end 

return PetFormationMgr