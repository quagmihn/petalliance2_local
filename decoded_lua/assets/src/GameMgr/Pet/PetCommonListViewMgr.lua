local PetCommonListViewMgr = {}
PetCommonListViewMgr.LABLE_OUTLINE_THICK = 1
PetCommonListViewMgr.ROW = 4
PetCommonListViewMgr.LINE = 5
local resName = ""
local petNodes = {}
local selectedPetInfo = {}
local selectedYokedPetInfo = {}
local petNodesPosY = 80
local useHighPerformList = false

local textColor = {
    {r=0,   g=0,    b=0,    a=255},
    {r=255, g=255,  b=255,  a=255},
    {r=166, g=243,  b=255,  a=255},--title
    {r=161, g=236,  b=248,  a=255},--desc
}
local outlineColor = {
    {r=0,   g=0,    b=0,    a=255},
    {r=255, g=255,  b=255,  a=255},
    {r=38,  g=54,   b=76,   a=255},--title
}

function PetCommonListViewMgr.Init()
    print("PetCommonListViewMgr初始化")
    resName = "Pet/Education/PetListNew.csb"
    petNodes = {}
    selectedPetInfo = {}
    selectedYokedPetInfo = {}
    useHighPerformList = false
end

local function checkEquipIcon(btn, petInfo)
    local equiped = btn:getChildByName("equiped")
    equiped:setVisible(PetEquipmentMgr.isPetEquiped(petInfo))
end

local function getAllConformPet(pokeID)
    local conformTable = {}
    local tempTable = {}
    local petTable = PokemonInfo.getUnactivePets()
    local army = PokemonInfo.getPetArmy(PetFormationMgr.getCurTab())
    local resPetList = PetStarUpMgr.getStarUpResList(pokeID)
    for k,v in pairs(petTable) do
        if v.pokeID == pokeID then
            local canSelect = true
            for k1,v1 in pairs(army) do
                if v1 == v.objID then
                    canSelect = false
                    break
                end
            end
            if canSelect == true then
                table.insert(conformTable, v)
            end
        else
            for k1,v1 in pairs(resPetList) do
                if v.pokeID == v1 then
                    --local pInfo = PokemonInfo.getPetInfoByObjID(v)
                    table.insert(tempTable, v)
                end
            end
        end
    end
    for k,v in pairs(tempTable) do
        table.insert(conformTable, 1, v)
    end
    tempTable = {}
    return conformTable
end

local function loadUI()
    local labelTitle = CSResourceMgr.getNodeByName(resName, {"db","title"})
    CSResourceMgr.setLabelStringByNode(labelTitle, "train60")--选择宠物
    CSResourceMgr.setLabelColorByNode(labelTitle, textColor[3])
    labelTitle:enableOutline(outlineColor[3], CSResourceMgr.DEFAULT_LABEL_OUTLINE_BORDER)

    local labelDesc = CSResourceMgr.getNodeByName(resName, {"db","desc"})
    CSResourceMgr.setLabelStringByNode(labelDesc, "train61")--点击需要宠物
    CSResourceMgr.setLabelColorByNode(labelDesc, textColor[4])
    labelDesc:enableOutline(outlineColor[3], PetCommonListViewMgr.LABLE_OUTLINE_THICK)

    local btn = CSResourceMgr.getNodeByName(resName, {"db","btn"})
    CSResourceMgr.clickEventBindingByNode(btn, function ()
        PetCommonListViewMgr.hide()
    end)
end

local function loadAction()
    CSResourceMgr.getCsbObj(resName):setVisible(true)
    CocosModuleMgr.showUIAnimation(CSResourceMgr.getNodeByName(resName, "db"), "down")
end

function PetCommonListViewMgr.show(scene, petInfo, needPokeID, selectedPetsInfo, curSelectedPetInfo, closeCallBack)
    UIStack.push("PetCommonListViewMgr",PetCommonListViewMgr.hide,false)
    -- print("PetCommonListViewMgr.show()")
    if curSelectedPetInfo == nil then
        curSelectedPetInfo = {}
    end
    local function loadCSB()
        print("loadCSB")
        local layer = CSResourceMgr.createRes(scene, resName)
        CSResourceMgr.setFullScreen(resName)
        layer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resName, 320, 480)
        layer:setVisible(false)
    end

    local function sortShowPet(pets)
        local petTable = {}
        for k,v in pairs(pets) do
            if PetCommonListViewMgr.getTableLength(curSelectedPetInfo) > 0 then
                if v.objID == curSelectedPetInfo.objID then
                    table.insert(petTable, v)
                end
            end
        end

        for k,v in pairs(pets) do
            if v.objID ~= 1 then
                if (not v.yoke) or (not v.yoke.bindTo and not v.yoke.yokeDetail) or (v.yoke.yokeDetail and PetEducationMgr.getTableLength(v.yoke.yokeDetail) == 0) then
                    if PetCommonListViewMgr.getTableLength(curSelectedPetInfo) > 0 then
                        if (v.objID ~= curSelectedPetInfo.objID) then
                            table.insert(petTable, v)
                        end
                    else
                        table.insert(petTable, v)
                    end
                end
            end
        end
        if PetCommonListViewMgr.getTableLength(selectedPetsInfo) > 0 then
            local function removeTable()
                for k,v in pairs(petTable) do
                    for k1,v1 in pairs(selectedPetsInfo) do
                        if (v.objID == v1.objID) and (v.objID ~= curSelectedPetInfo.objID) then
                            table.remove(petTable, k)
                            removeTable()
                        end
                    end
                end
            end
            removeTable()
        end
        return petTable
    end

    local function loadPetList()
        local list = CSResourceMgr.getNodeByName(resName, {"db","list"})
        local panel = CSResourceMgr.getNodeByName(resName, {"panel"})
        local item = CSResourceMgr.getNodeByName(resName, {"panel","btn"})
        local hook = CSResourceMgr.getNodeByName(resName, {"panel","hook"})
        local showPets = sortShowPet(getAllConformPet(needPokeID))
        local totalLine = math.ceil(#showPets / PetCommonListViewMgr.ROW)
        local diffX = 124
        local panelNodes = {}
        for i = 1, totalLine do
            panelNodes[i] = panel:clone()
            panelNodes[i]:addTo(list)
        end
        local index = 1
        for k,v in pairs(showPets) do
            if v.objID ~= petInfo.objID then--去掉自己
                local line = math.ceil(index / PetCommonListViewMgr.ROW)
                local row = index % PetCommonListViewMgr.ROW == 0 and PetCommonListViewMgr.ROW or index % PetCommonListViewMgr.ROW
                -- local petNode = BattleFuncMgr.createPetCardWithBlood(v,"CommonListPet"..index,true)
                local petNode = BattleFuncMgr.startCreatePetCard(v, 3, true)

                if v.skin ~= 0 then
                    CSResourceMgr.setLabelColorByNode(petNode.level, {r=96,g=255,b=0,a=255})
                end
                petNodes[index] = petNode.button
                petNodes[index]:setVisible(true)
                petNodes[index]:setScale(1.3, 1.3)
                petNodes[index]:addTo(panelNodes[line])
                petNodes[index]:setPosition(petNodes[index]:getPositionX() + (row - 1) * diffX + 72, petNodesPosY)

                petNodes[index].sel = hook:clone()
                petNodes[index].sel:addTo(petNodes[index])
                petNodes[index].sel:setPosition(70,105)
                petNodes[index].sel:setVisible(v.objID == curSelectedPetInfo.objID)
                petNodes[index].sel:setScale(0.9)

                CSResourceMgr.clickEventBindingByNode(petNodes[index], function ()
                    if PetEquipmentMgr.isPetEquiped(v) then
                        StandardTipsMgr.show(1, "PetEquip58")
                        return
                    end
                    if PetCommonListViewMgr.getTableLength(curSelectedPetInfo) > 0 then
                        if curSelectedPetInfo.objID == v.objID then
                            selectedPetInfo = {}
                        else
                            selectedPetInfo = v
                        end
                    else
                        selectedPetInfo = v
                    end
                    if CSResourceMgr.getCsbObj("Pet/Education/StarupPageNew.csb") then
                        PetStarUpMgr.onSelectCostPet(petInfo.Stage, selectedPetInfo)
                    elseif CSResourceMgr.getCsbObj("Pet/Education/PetQuickView.csb") then
                        PetQuickViewMgr.OnSelectPet(selectedPetInfo)
                    end
                    PetCommonListViewMgr.hide()
                    if closeCallBack then closeCallBack() end
                end,3)
                index = index + 1
                
                checkEquipIcon(petNode.button, v)
            end
        end
        BattleFuncMgr.endCreatePetCard()
    end

    local funcTable = {loadCSB, loadPetList, loadUI, loadAction}
    UnblockLoader.load(funcTable,"PetCommonListViewMgr")
end

local function getNeedPets(needID)
    local petsTable = {}
    local allPets = PokemonInfo.getUnactivePets()
    for k,v in pairs(allPets) do
        if needID == v.pokeID then
            table.insert(petsTable, v)
        end
    end
    return petsTable
end

function PetCommonListViewMgr.getYokePetTable(petInfo, needPokeID, yokeID, pos, isYoked)
    local petsTable = {}
    local allPets = PokemonInfo.getUnactivePets()
    if isYoked then
        for k,v in pairs(allPets) do
            if (v.yoke and v.yoke.bindTo and (v.yoke.bindTo == petInfo.objID)) then
                if v.pokeID == needPokeID then
                    table.insert(petsTable, v)
                    break
                end
            end
        end
    end
    for k,v in pairs(allPets) do
        if (not v.yoke) or (not v.yoke.bindTo and not v.yoke.yokeDetail) or (v.yoke.yokeDetail and PetEducationMgr.getTableLength(v.yoke.yokeDetail) == 0) then
        -- if (v.yoke and v.yoke.bindTo) or (v.yoke and v.yoke.yokeDetail) then

        -- elseif v.pokeID == needPokeID then
            if (v.yoke and v.yoke.bindTo and (v.yoke.bindTo == petInfo.objID)) then
                
            elseif v.pokeID == needPokeID then
                table.insert(petsTable, v)
            end
        end
    end
    return petsTable
end

local function getYokePetList(petInfo, yokeArgsVec, isYoked)
    local petsTable = {}
    local allPets = PokemonInfo.getUnactivePets()
    if isYoked then
        for k,v in pairs(allPets) do
            if (v.yoke and v.yoke.bindTo and (v.yoke.bindTo == petInfo.objID)) then
                table.insert(petsTable, v)
                break
            end
        end
    end
    local needPokeID = yokeArgsVec.needID
    local stage      = yokeArgsVec.arg1
    local star       = yokeArgsVec.arg2
    for k,v in pairs(allPets) do
        if (v.pokeID == needPokeID) then
            if v.yoke and v.yoke.bindTo then
                -- if v.yoke and v.yoke.yokeIDs then
                --     for k1,v1 in pairs(v.yoke.yokeIDs) do
                --         print("cao oooooooooooooooooooooooooo : "..v1)
                --     end
                -- elseif v.yoke and v.yoke.bindTo then
                --     print("md ddddddddddddddddddddddddd : "..v.objID.."          "..v.yoke.bindTo)
                -- end
            else
                if v.Stage >= stage and v.star >= star then
                    table.insert(petsTable, v)
                end
            end
        end
    end
    return petsTable
end

function PetCommonListViewMgr.showPetYokeList(scene, petInfo, needID, yokeID, yokeCellID, isYoked, closeCallBack)--yokeArgsVec, yokeID, yokeCellID, isYoked)
    UIStack.push("PetCommonListViewMgr",PetCommonListViewMgr.hide,false)
    -- print("PetCommonListViewMgr.showPetYokeList()")
    local function loadCSB()
        local layer = CSResourceMgr.createRes(scene, resName)
        CSResourceMgr.setFullScreen(resName)
        layer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resName, 320, 480)
        layer:setVisible(false)
    end

    local function loadPetList()
        local needPokeID = needID
        local list = CSResourceMgr.getNodeByName(resName, {"db","list"})
        local panel = CSResourceMgr.getNodeByName(resName, {"panel"})
        local item = CSResourceMgr.getNodeByName(resName, {"panel","btn"})
        local hook = CSResourceMgr.getNodeByName(resName, {"panel","hook"})
        local showPets = PetCommonListViewMgr.getYokePetTable(petInfo, needPokeID, yokeID, yokeCellID, isYoked)
        local totalLine = math.ceil(#showPets / PetCommonListViewMgr.ROW)
        local diffX = 124
        local panelNodes = {}
        for i = 1, totalLine do
            panelNodes[i] = panel:clone()
            panelNodes[i]:addTo(list)
        end
        local index = 1
        for k,v in pairs(showPets) do
            local line = math.ceil(index / PetCommonListViewMgr.ROW)
            local row = index % PetCommonListViewMgr.ROW == 0 and PetCommonListViewMgr.ROW or index % PetCommonListViewMgr.ROW
            local petNode = BattleFuncMgr.startCreatePetCard(v, 3, true)

            if v.skin ~= 0 then
                CSResourceMgr.setLabelColorByNode(petNode.level, {r=96,g=255,b=0,a=255})
            end
            petNodes[index] = petNode.button
            petNodes[index]:setVisible(true)
            petNodes[index]:setScale(1.3, 1.3)
            petNodes[index]:addTo(panelNodes[line])
            petNodes[index]:setPosition(petNodes[index]:getPositionX() + (row - 1) * diffX + 72, petNodesPosY)

            petNodes[index].sel = hook:clone()
            petNodes[index].sel:addTo(petNodes[index])
            petNodes[index].sel:setPosition(70,105)
            petNodes[index].sel:setVisible(isYoked and (index == 1))
            petNodes[index].sel:setScale(0.9)

            CSResourceMgr.clickEventBindingByNode(petNodes[index], function ()
                if isYoked then
                    if v.yoke and v.yoke.bindTo and v.yoke.bindTo == petInfo.objID then
                        -- print("delete yoke pet !")
                        PetEducationMgr.sendDelYokePet(petInfo.objID, yokeID, yokeCellID)
                    else
                        -- print("change yoke pet")
                        PetEducationMgr.sendChangeYokePet(petInfo.objID, yokeID, yokeCellID, v.objID)
                        PetEducationMgr.needUpdateSevenDayPetYoke = true
                    end
                else
                    -- print("add yoke pet")
                    PetEducationMgr.sendAddYokePet(petInfo.objID, yokeID, yokeCellID, v.objID)
                    PetEducationMgr.needUpdateSevenDayPetYoke = true
                end
                PetCommonListViewMgr.hide()
                if closeCallBack then closeCallBack() end
            end,3)
            index = index + 1
            
            checkEquipIcon(petNode.button, v)
        end
        BattleFuncMgr.endCreatePetCard()
    end

    local funcTable = {loadCSB, loadPetList, loadUI, loadAction}
    UnblockLoader.load(funcTable,"PetCommonListViewMgr")
end

--selType:1.mainPet, 2.eatPet
function PetCommonListViewMgr.showEatPetList(scene, petInfo, selectedPet, selType, closeCallBack)
    UIStack.push("PetCommonListViewMgr",PetCommonListViewMgr.hide,false)
    local function loadCSB()
        local layer = CSResourceMgr.createRes(scene, resName)
        CSResourceMgr.setFullScreen(resName)
        layer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resName, 320, 480)
        layer:setVisible(false)
    end

    local function getMainPetList()
        local mainPetList = {}
        local unSelectPetList = {}
        if selectedPet ~= nil then
            for k,v in pairs(PokemonInfo.getAllPets()) do
                if v.objID == selectedPet.objID then
                    table.insert(mainPetList, v)
                    break
                end
            end
            for k,v in pairs(PokemonInfo.getAllPets()) do
                if v.objID ~= selectedPet.objID then
                    table.insert(unSelectPetList, v)
                end
            end
            unSelectPetList = PetListMgr.sortPetList(unSelectPetList)
        else
            mainPetList = PetListMgr.sortPetList(PokemonInfo.getAllPets())
        end
        for k,v in pairs(unSelectPetList) do
            table.insert(mainPetList, v)
        end
        return mainPetList
    end

    local function getEatPetList()
        local eatPetList = {}
        local unSelectPetList = {}
        for k,v in pairs(PokemonInfo.getUnactivePets()) do
            if selectedPet and petInfo.objID == selectedPet.objID then
                table.insert(eatPetList, v)
                break
            end
        end
        for k,v in pairs(PokemonInfo.getUnactivePets()) do
            if v.objID ~= 1 and v.objID ~= petInfo.objID and v.pokeID == petInfo.pokeID then
                if (not v.yoke) or (not v.yoke.bindTo and not v.yoke.yokeDetail) or (v.yoke.yokeDetail and PetEducationMgr.getTableLength(v.yoke.yokeDetail) == 0) then
                    if v.skin ~= 0 and v.skin ~= petInfo.skin then
                        table.insert(unSelectPetList, v)
                    end
                end
            end
        end
        unSelectPetList = PetListMgr.sortPetList(unSelectPetList)
        for k,v in pairs(unSelectPetList) do
            table.insert(eatPetList, v)
        end
        return eatPetList
    end

    local function loadPetList()
        local needPokeID = needID
        local list = CSResourceMgr.getNodeByName(resName, {"db","list"})
        local panel = CSResourceMgr.getNodeByName(resName, {"panel"})
        local item = CSResourceMgr.getNodeByName(resName, {"panel","btn"})
        local hook = CSResourceMgr.getNodeByName(resName, {"panel","hook"})
        local showPets = selType == 1 and getMainPetList() or getEatPetList()
        local totalLine = math.ceil(#showPets / PetCommonListViewMgr.ROW)
        local showCnt = PetCommonListViewMgr.ROW * PetCommonListViewMgr.LINE
        local showLine = math.min(PetCommonListViewMgr.LINE, totalLine)
        local diffX = 124
        local panelNodes = {}
        list:removeAllItems()
        for i = 1, showLine do
            panelNodes[i] = panel:clone()
            list:pushBackCustomItem(panelNodes[i])
        end
        local index = 1
        for k,v in pairs(showPets) do
            if index > showCnt then break end
            local line = math.ceil(index / PetCommonListViewMgr.ROW)
            local row = index % PetCommonListViewMgr.ROW == 0 and PetCommonListViewMgr.ROW or index % PetCommonListViewMgr.ROW
            local petNode = BattleFuncMgr.startCreatePetCard(v, 3, true)
            local isSelected = selectedPet and selectedPet.objID == v.objID

            if v.skin ~= 0 then
                CSResourceMgr.setLabelColorByNode(petNode.level, {r=96,g=255,b=0,a=255})
            end
            petNodes[index] = petNode.button
            petNodes[index]:setVisible(true)
            petNodes[index]:setScale(1.3, 1.3)
            petNodes[index]:addTo(panelNodes[line])
            petNodes[index]:setPosition(petNodes[index]:getPositionX() + (row - 1) * diffX + 72, petNodesPosY)

            petNodes[index].sel = hook:clone()
            petNodes[index].sel:addTo(petNodes[index])
            petNodes[index].sel:setPosition(70,105)
            petNodes[index].sel:setVisible(isSelected)
            petNodes[index].sel:setScale(0.9)

            if not panelNodes[line].button then
                panelNodes[line].button = {}
            end
            -- panelNodes[line].button[row] = {}
            panelNodes[line].button[row] = petNodes[index]

            CSResourceMgr.clickEventBindingByNode(petNodes[index], function ()
                if selType == 1 then
                    PetEatPetViewMgr.setSelectMainPetInfo(v)
                else
                    if PetEquipmentMgr.isPetEquiped(v) then
                        StandardTipsMgr.show(1, "PetEquip58")
                        return
                    end
                    PetEatPetViewMgr.setSelectEatPetInfo(v)
                end
                PetCommonListViewMgr.hide()
                if closeCallBack then closeCallBack() end
            end,3)
            index = index + 1
            
            checkEquipIcon(petNode.button, v)
        end
        BattleFuncMgr.endCreatePetCard()

        useHighPerformList = true
        HighPerformList.makeHighPerFormVerticalList(list, PetCommonListViewMgr.LINE, 0, PetCommonListViewMgr.ROW, 200, 170, showPets,
            function(item, currentIndex)
                local row = currentIndex % PetCommonListViewMgr.ROW == 0 and PetCommonListViewMgr.ROW or currentIndex % PetCommonListViewMgr.ROW
                for i=1,PetCommonListViewMgr.ROW do
                    if currentIndex + i - 1 <= #showPets then--防止越界
                        item.button[i]:setVisible(true)
                        PetCommonListViewMgr.updateCard(showPets[currentIndex+i-1], item.button[i])
                        local isSelected = selectedPet and selectedPet.objID == showPets[currentIndex+i-1].objID
                        item.button[i].sel:setVisible(isSelected)
                    else
                        item.button[i]:setVisible(false)
                    end
                    CSResourceMgr.clickEventBindingByNode(item.button[i], function ()
                        if selType == 1 then
                            PetEatPetViewMgr.setSelectMainPetInfo(showPets[currentIndex+i-1])
                        else
                            PetEatPetViewMgr.setSelectEatPetInfo(showPets[currentIndex+i-1])
                        end
                        PetCommonListViewMgr.hide()
                        if closeCallBack then closeCallBack() end
                    end,3)
                end
            end)
    end

    local funcTable = {loadCSB, loadPetList, loadUI, loadAction}
    UnblockLoader.load(funcTable,"PetCommonListViewMgr")
end

function PetCommonListViewMgr.getTableLength(table)
    local index = 0
    for k,v in pairs(table) do
        index = index + 1
    end
    return index
end

function PetCommonListViewMgr.getPetNodesByIndex(index)
    return petNodes[index]
end

function PetCommonListViewMgr.hide()
    UnblockLoader.cancel("PetCommonListViewMgr")

    local nodeLength = #petNodes
    for var=1, nodeLength do
        petNodes[var]:removeFromParent(true)
    end
    petNodes = {}
    selectedPetInfo = {}

    local list = CSResourceMgr.getNodeByName(resName, {"db","list"})
    if list then list:removeAllItems() end
    if useHighPerformList then
    	HighPerformList.resetAllSchedule()
        useHighPerformList = false
    end

    CSResourceMgr.removeCSObjectByTag(resName)
    UIStack.pop("PetCommonListViewMgr")
end

function PetCommonListViewMgr.updateCard(petInfo, preNode)
    -- local layerBtn      = preNode.pButton
    local layerBtn      = preNode
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
    local starPosX,starPosY   = 46, star:getPositionY()
    local starSize      = 15

    petLevel:enableOutline({r = 0,g = 0,b = 0, a = 255}, 1) 
    str:enableOutline({r = 0,g = 0,b = 0, a = 255}, 1)

    str:setTextColor({r = 215,g = 216,b = 217, a = 255})

    petLevel:setString("Lv"..petInfo.level)
    str:setString("")
    CSResourceMgr.setLabelColorByNode(petLevel, petInfo.skin ~= 0 and {r=0,g=255,b=0,a=255} or {r=255,g=255,b=255,a=255})

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
            copeStar:setLocalZOrder(1)
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

    local nameStr = LuaSqlite.getLanguageByKey(petDatInfo.name)
    str:setTextColor(PokemonInfo.COLOR[rarePoint])
    nameStr = PetEducationMgr.getPetName(petInfo)
    str:setString(nameStr)
    
    checkEquipIcon(btn, petInfo)
end

return PetCommonListViewMgr