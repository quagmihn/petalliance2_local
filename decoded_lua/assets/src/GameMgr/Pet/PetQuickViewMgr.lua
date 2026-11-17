local PetQuickViewMgr = {}

local resName = ""

local needPetNode = {}
local selectedPetsInfo = {}
local selectedPetIndex = 0

local curPetInfo = nil

local labelColor = {
    {r=255,g=255,b=255,a=255},
    {r=166,g=243,b=255,a=255},
    {r=255,g=72,b=0,a=255},
}

local outlineColor = {
    {r=0,g=0,b=0,a=255},
    {r=0,g=0,b=0,a=255,w=1,s=1},
    {r=0,g=0,b=0,a=255,w=1,s=2},
}

function PetQuickViewMgr.Init()
    resName = "Pet/Education/PetQuickView.csb"
    needPetNode = {}
    selectedPetsInfo = {}
    selectedPetIndex = 0
    
    curPetInfo = nil
end

function PetQuickViewMgr.hide()
    selectedPetsInfo = {}
    selectedPetIndex = 0
    UnblockLoader.cancel("PetQuickViewMgr")
    CSResourceMgr.removeCSObjectByTag(resName)
    UIStack.pop("PetQuickViewMgr")
end

function PetQuickViewMgr.show(scene, objID, closeCallBack)
    UIStack.push("PetQuickViewMgr", PetQuickViewMgr.hide, false)
    local panel = nil
    local function loadCSB()
        local layer = CSResourceMgr.createRes(scene, resName)
        layer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setFullScreen(resName)
        CSResourceMgr.setRelativePosition(resName, 320, 480)
        CSResourceMgr.clickEventBinding(resName, "btn_close", function()
            PetQuickViewMgr.hide()
            if closeCallBack then closeCallBack() end
        end)

        panel = CSResourceMgr.getNodeByName(resName, "panel_1")
        panel:setVisible(false)

        local diff = CocosModuleMgr.getScreenSizeDiff()
        ViewMgrUtils.vFitSetPos(-diff, {panel})
    end

    local function loadUI()
        local petInfo = PokemonInfo.getPetInfoByObjID(objID)
        PetQuickViewMgr.refreshUI(petInfo)
    end

    local function playAction()
        panel:setVisible(true)
        CocosModuleMgr.showUIAnimation(panel, "up")
    end

    local funcTable = {loadCSB, loadUI, playAction}
    UnblockLoader.load(funcTable, "PetQuickViewMgr")
end

function PetQuickViewMgr.refreshGold()
    local labelGold = CSResourceMgr.getNodeByName(resName, {"panel_1","top_left","background5","label_jinbi"})
    CSResourceMgr.setLabelStringByNode(labelGold, CharInfo.getGCash(), outlineColor[2], nil, 140)
end

function PetQuickViewMgr.refreshUI(petInfo)
    if not CSResourceMgr.getCsbObj(resName) then
        return
    end
    if not petInfo then
        petInfo = curPetInfo
    end
    curPetInfo = petInfo
    PetQuickViewMgr.refreshGold()
    PetQuickViewMgr.refreshPetInfo(petInfo)
    PetQuickViewMgr.refreshFeedUI(petInfo)
    PetQuickViewMgr.refreshStengthUI(petInfo)
    PetQuickViewMgr.refreshStarUpUI(petInfo)
end

function PetQuickViewMgr.refreshPetInfo(petInfo)
    local petNode       = CSResourceMgr.getNodeByName(resName, {"panel_1","pet_node"})
    local spriteIcon    = CSResourceMgr.seekNodeByName(petNode, "pet_icon")
    local labelLv       = CSResourceMgr.seekNodeByName(petNode, "pet_lv")
    local labelName     = CSResourceMgr.seekNodeByName(petNode, "pet_name")
    local background6   = CSResourceMgr.seekNodeByName(petNode, "background6")
    local spriteStar    = CSResourceMgr.seekNodeByName(petNode, "pet_star")

    local pokeInfo = PokemonInfo.getPokemonInfoByID(petInfo.pokeID)
    local petIcon = pokeInfo.icon
    local petName = PetEducationMgr.getPetName(petInfo)..(petInfo.Stage ~= 0 and "+"..petInfo.Stage or "")
    local petLv   = petInfo.level
    local petRare = pokeInfo.rarePoint
    local petNameColor = PokemonInfo.COLOR[petRare]
    local petStars = petInfo.star

    CSResourceMgr.setSpriteTextureByNode(petNode, "Pet/petcards/stage/"..petRare..".png")
    CSResourceMgr.setSpriteTextureByNode(spriteIcon, "Pet/PetIcon/"..petIcon..".png")
    CSResourceMgr.setLabelStringByNode(labelName, petName, outlineColor[2])
    CSResourceMgr.setLabelStringByNode(labelLv, "Lv."..petLv, outlineColor[2])
    CSResourceMgr.setLabelColorByNode(labelName, petNameColor)

    for k,v in pairs(background6:getChildren()) do
        background6:removeChild(v)
    end

    local diffX = 18
    local midIndex = petStars / 2 + 0.5
    for i = 1, petStars do
        local starNode = spriteStar:clone()
        starNode:addTo(background6)
        starNode:setPosition(diffX * (i - midIndex) + 54, 6)
        starNode:setVisible(true)
    end
end

function PetQuickViewMgr.refreshFeedUI(petInfo)
    local btnFeed = CSResourceMgr.getNodeByName(resName, "btnFeed")
    local strFeed = CSResourceMgr.seekNodeByName(btnFeed, "str_feed")

    CSResourceMgr.setLabelStringByNode(strFeed, "train50", outlineColor[2], nil, 176)

    CSResourceMgr.clickEventBindingByNode(btnFeed, function ()
        PetFeedViewMgr.show(SceneMgr.getRunningScene, petInfo, function ()
            petInfo = PokemonInfo.getPetInfoByObjID(petInfo.objID)
            PetQuickViewMgr.refreshUI(petInfo)
        end)
    end)
end

function PetQuickViewMgr.refreshStengthUI(petInfo)
    local strengthNode      = CSResourceMgr.getNodeByName(resName, {"panel_1","strength"})
    local labelResName      = CSResourceMgr.seekNodeByName(strengthNode, "need_res_name")
    local labelLvName       = CSResourceMgr.seekNodeByName(strengthNode, "need_lv_name")
    local labelLv           = CSResourceMgr.seekNodeByName(strengthNode, "need_lv")
    local btnStrength       = CSResourceMgr.seekNodeByName(strengthNode, "btnStrength")
    local background8       = CSResourceMgr.seekNodeByName(strengthNode, "background8")
    local labelStrength     = CSResourceMgr.seekNodeByName(btnStrength, "str")

    local pokeInfo      = PokemonInfo.getPokemonInfoByID(petInfo.pokeID)
    local maxStage      = math.floor(pokeInfo.topLevel / 2)
    local needLevel     = (petInfo.Stage + 1) * 2
    local petLevel      = petInfo.level
    local haveEnoughRes = true

    CSResourceMgr.setLabelStringByNode(labelResName, "train167", outlineColor[2])
    CSResourceMgr.setLabelStringByNode(labelLvName, LuaSqlite.getLanguageByKey("train28").."：", outlineColor[2])
    CSResourceMgr.setLabelStringByNode(labelLv, needLevel, outlineColor[2])
    CSResourceMgr.setLabelStringByNode(labelStrength, "train2", outlineColor[2], nil, 290)

    CSResourceMgr.setLabelColorByNode(labelResName, labelColor[2])
    CSResourceMgr.setLabelColorByNode(labelLvName, labelColor[2])
    CSResourceMgr.setLabelColorByNode(labelLv, needLevel <= petLevel and labelColor[1] or labelColor[3])

    local petRp = pokeInfo.elementAtt1--rarePoint
    local advanceInfo = PokemonInfo.getPetAdvanceInfo(petInfo.Stage+1)
    local itemTable = advanceInfo.stageCons[petRp]
    local needLevel = (petInfo.Stage + 1) * 2
    local petLevel = petInfo.level
    local maxPetCanStangeLevel = pokeInfo.topLevel

    local parent   = CSResourceMgr.seekNodeByName(strengthNode, "background8")
    local itemNode = CSResourceMgr.getNodeByName(resName, "btn_res")
    for k,v in pairs(parent:getChildren()) do
        if v ~= itemNode then parent:removeChild(v) end
    end
    local index = 1
    for k,v in pairs(itemTable.costs) do
        local node = itemNode:clone()
        node:setVisible(true)
        node:addTo(parent)
        if #itemTable.costs % 2 ~= 0 then--奇数
            node:setPosition(323 + ((index - 1) - (#itemTable.costs - 1) / 2) * 100, 52)
        else
            node:setPosition(323 + ((index - (#itemTable.costs / 2)) * 100 - 60), 52)
        end

        local spriteIcon = CSResourceMgr.seekNodeByName(node, "res_icon")
        local labelRes = CSResourceMgr.seekNodeByName(node, "res_num")
        local consumeInfo = ItemInfo.getConsumeElementInfoById(v)
        local itemId = consumeInfo.elementID
        local itemInfo = ItemInfo.getItemInfoById(itemId)
        local background = ItemInfo.getItemRareBGImage((itemId == 0) and {} or itemId)
        local iconPath = "empty.png"
        local needResCount = consumeInfo.num
        local haveResCount = 0
        local strNeedRes = tostring(needResCount)
        if consumeInfo.elementType == 1 then
            iconPath = "Searching/topBar/jinbi.png"
            haveResCount = CharInfo.getGCash()
            itemId = 9998
        elseif consumeInfo.elementType == 2 then
            haveResCount = CharInfo.getMCash()
            strNeedRes = haveResCount.."/"..needResCount
            itemId = 9999
        elseif consumeInfo.elementType == 3 then
            iconPath = itemInfo.icon
            haveResCount = ItemInfo.getCharItemNum(itemId)
            strNeedRes = haveResCount.."/"..needResCount
        end
        local iNode = ItemInfo.getItemIconById(itemId, nil)
        iNode:setPosition(0, 0)
        iNode:removeFromParent()
        iNode:addTo(spriteIcon)
        iNode:setScale(node:getContentSize().width / iNode:getContentSize().width)

        CSResourceMgr.setLabelStringByNode(labelRes, strNeedRes, outlineColor[2], 1, 80)
        CSResourceMgr.setLabelColorByNode(labelRes, (haveResCount >= needResCount) and labelColor[1] or labelColor[3])
        haveEnoughRes = haveResCount >= needResCount

        CSResourceMgr.clickEventBindingByNode(iNode, function ()
            if itemId ~= 0 then
                ItemInfoViewMgr.show({id = itemId}, false)
            end
        end)
        index = index + 1
    end

    local btnStrengthenEnable = haveEnoughRes and petInfo.Stage < maxStage and needLevel <= petLevel
    CSResourceMgr.setButtonEnabledByNode(btnStrength, btnStrengthenEnable)
    CSResourceMgr.clickEventBindingByNode(btnStrength, function ()
        NetInterface.sendWithBlock("GC_POKEMONADVASTAGELEVEL_ACK", function()
            local PetEducationSend = require("src/Net/Send/PetEducationSend.lua")
            PetEducationSend.sendCG_PokemonAdvaStageLevel_Req({
                objID = petInfo.objID,
            })
        end, function()
            GameAudio.playUISound("success")

            petInfo.Stage = petInfo.Stage + 1
            PetQuickViewMgr.refreshUI(petInfo)
            PetEducationMgr.needUpdateSevenDayPetYoke = true
            -- PetEducationMgr.updateSevenDayPetYoke(petInfo.objID)

            PetListMgr.setUpdateFlag("stage")
        end
        , function()
        end)
    end)
end

function PetQuickViewMgr.refreshStarUpUI(petInfo)
    local starUpNode        = CSResourceMgr.getNodeByName(resName, {"panel_1","starup"})
    local labelResName      = CSResourceMgr.seekNodeByName(starUpNode, "need_res_name")
    local labelLvName       = CSResourceMgr.seekNodeByName(starUpNode, "need_lv_name")
    local labelLv           = CSResourceMgr.seekNodeByName(starUpNode, "need_lv")
    local background10      = CSResourceMgr.seekNodeByName(starUpNode, "background10")
    local btnStarUp         = CSResourceMgr.seekNodeByName(starUpNode, "btnStarup")
    local labelStarUp       = CSResourceMgr.seekNodeByName(btnStarUp, "str")

    local panel = CSResourceMgr.seekNodeByName(starUpNode, "background10")
    for k,v in pairs(panel:getChildren()) do
        panel:removeChild(v)
    end
    
    if petInfo.star == 5 then
        btnStarUp:setVisible(false)
        return
    end

    local petStarupInfo = PokemonInfo.getPetStarUpInfoByID(petInfo.pokeID)

    local havePetCount  = 0
    local needStrength  = petStarupInfo.limit[petInfo.star+1]
    local needPetID     = petStarupInfo.costPet[petInfo.star+1]
    local needPetCount  = petStarupInfo.num2[petInfo.star+1]
    local needPetInfo   = PokemonInfo.getPokemonInfoByID(needPetID)
    local needPetIcon   = needPetInfo.icon
    local needPetName   = needPetInfo.name
    local needPetQuality= needPetInfo.rarePoint

    CSResourceMgr.setLabelStringByNode(labelResName, "train168", outlineColor[2])
    CSResourceMgr.setLabelStringByNode(labelLvName, "train95", outlineColor[2])
    CSResourceMgr.setLabelStringByNode(labelLv, "+"..needStrength, outlineColor[2])
    CSResourceMgr.setLabelStringByNode(labelStarUp, "train5", outlineColor[2], nil, 290)

    CSResourceMgr.setLabelColorByNode(labelResName, labelColor[2])
    CSResourceMgr.setLabelColorByNode(labelLvName, labelColor[2])
    CSResourceMgr.setLabelColorByNode(labelLv, (petInfo.Stage >= needStrength) and labelColor[1] or labelColor[3])

    local needResID = petStarupInfo.costItem[petInfo.star+1]
    local needResCount = petStarupInfo.num1[petInfo.star+1]
    local haveResCount = ItemInfo.getCharItemNum(needResID)
    local itemInfo = ItemInfo.getItemInfoById(needResID)

    local btnRes = CSResourceMgr.getNodeByName(resName, "btn_res")
    local showItemCount = needPetCount + 1
    needPetNode = {}
    for i = 1, showItemCount do
        needPetNode[i] = btnRes:clone()
        needPetNode[i]:addTo(panel)
        needPetNode[i]:setVisible(true)
        if showItemCount % 2 ~= 0 then--奇数
            needPetNode[i]:setPosition(323 + ((i - 1) - (showItemCount - 1) / 2) * 100, 50)
        else
            needPetNode[i]:setPosition(323 + ((i - (showItemCount / 2)) * 100 - 60), 50)
        end

        local petBg   = CSResourceMgr.seekNodeByName(needPetNode[i], "res_bg")
        local petIcon = CSResourceMgr.seekNodeByName(needPetNode[i], "res_icon")
        local petName = CSResourceMgr.seekNodeByName(needPetNode[i], "res_num")
        local petAdd  = CSResourceMgr.seekNodeByName(needPetNode[i], "res_add")

        if i == 1 then
            petAdd:setVisible(false)

            local iNode = ItemInfo.getItemIconById(needResID, nil)
            local scale = needPetNode[i]:getContentSize().width / iNode:getContentSize().width
            iNode:setPosition(0, 0)
            iNode:removeFromParent()
            iNode:addTo(petIcon)
            iNode:setScale(scale)

            CSResourceMgr.setLabelStringByNode(petName, haveResCount.."/"..needResCount, outlineColor[1], nil, 92)
            CSResourceMgr.setLabelColorByNode(petName, (haveResCount >= needResCount) and labelColor[1] or labelColor[3])
            CSResourceMgr.clickEventBindingByNode(iNode, function ()
                ItemInfoViewMgr.show({id = needResID}, false)
            end)
        else
            local havePet = selectedPetsInfo[i] and true or false
            petAdd:setVisible(not havePet)
            petBg:setColor(havePet and {r=255,g=255,b=255} or {r=77,g=77,b=77})
            petIcon:setColor(havePet and {r=255,g=255,b=255} or {r=77,g=77,b=77})
            petIcon:setScaleX(0.80)
            petIcon:setScaleY(0.84)

            local iconPath = "Pet/petcards/stage/"..needPetQuality..".png"
            CSResourceMgr.setSpriteTextureByNode(petBg, iconPath)
            CSResourceMgr.setSpriteTextureByNode(petIcon, "Pet/PetIcon/"..needPetIcon..".png")
            
            CSResourceMgr.setLabelStringByNode(petName, needPetInfo.name, outlineColor[1], nil, 92)
            CSResourceMgr.setLabelColorByNode(petName, havePet == true and PokemonInfo.COLOR[needPetQuality] or PokemonInfo.DARKCOLOR[needPetQuality])
            CSResourceMgr.clickEventBindingByNode(needPetNode[i], function ()
                local conformTable = PetStarUpMgr.getCanStarUpPets(needPetID, petInfo.objID)
                local conformLength = PetStarUpMgr.getTableLength(conformTable)
                if conformLength > 0 then
                    if PetStarUpMgr.getTableLength(selectedPetsInfo) >= conformLength and selectedPetsInfo[i] == nil then
                        PetGetViewMgr.show(SceneMgr.getRunningScene, needPetID)
                    else
                        selectedPetIndex = i
                        PetCommonListViewMgr.show(SceneMgr.getRunningScene, petInfo, needPetID, selectedPetsInfo, selectedPetsInfo[i], function ()
                            PetQuickViewMgr.refreshUI(petInfo)
                        end)
                    end
                else
                    PetGetViewMgr.show(SceneMgr.getRunningScene, needPetID)
                end
            end)
        end
    end

    local enable = (needPetCount <= PetEducationMgr.getTableLength(selectedPetsInfo)) and (petInfo.Stage >= needStrength)
    CSResourceMgr.setButtonEnabledByNode(btnStarUp, enable)
    CSResourceMgr.clickEventBindingByNode(btnStarUp, function ()
        local sendPetObjIDTable = {}
        for k,v in pairs(selectedPetsInfo) do
            table.insert(sendPetObjIDTable, v.objID)
        end
        NetInterface.sendWithBlock("GC_PETSTARUP_ACK", function()
            local PetEducationSend = require("src/Net/Send/PetEducationSend.lua")
            print("sendCG_PetStarUp_Req")
            PetEducationSend.sendCG_PetStarUp_Req({
                petObjID = petInfo.objID,
                costPetObjIDs = sendPetObjIDTable
                })
            end,function ()
                selectedPetsInfo = {}
                GameAudio.playUISound("success")
                petInfo.star = petInfo.star + 1
                PetQuickViewMgr.refreshUI(petInfo)
                PetEducationMgr.needUpdateSevenDayPetYoke = true
                -- PetEducationMgr.updateSevenDayPetYoke(petInfo.objID)
                PetListMgr.setUpdateFlag("star")
            end,function ()
                
            end)
    end)
end

function PetQuickViewMgr.OnSelectPet(petInfo)
    if PetEducationMgr.getTableLength(petInfo) > 0 then
        selectedPetsInfo[selectedPetIndex] = petInfo
    else
        selectedPetsInfo[selectedPetIndex] = nil
    end
end

return PetQuickViewMgr