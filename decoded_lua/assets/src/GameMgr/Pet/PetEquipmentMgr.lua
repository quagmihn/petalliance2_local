local PetEquipmentMgr = {}

local resName = ""
local resNameDownBar = ""
local resNameBG = ""
local aniPetRes = nil
local aniPetTag = nil
local isCurPetEquiped = false
local nothingTip = nil
local orderString = {}
local petEquipmentFromServer = {}
local allPetUnwearEquipment = {}
local allPetWearEquipment = {}
local allPetEquipment2Evaluate = {}
local tabFuncTex = {}
local tabTypeTex = {}
local allPetEquipmentBag = {} --宠物装备备包
local MAX_STRENGTHEN_LEVEL = 10
local MAX_PURIFY_LEVEL = 10

function PetEquipmentMgr.Init()
    resName = "Pet/Equipment/PetEquipment.csb"
    resNameDownBar = "Pet/Equipment/PetEquipmentDownBar.csb"
    resNameBG = "Pet/Formation/FormationBGNew.csb"
    aniPetRes = nil
    aniPetTag = nil
    isCurPetEquiped = false
    nothingTip = nil
    orderString = {
        [1] = "Pet/Education/c.png",
        [2] = "Pet/Education/b.png",
        [3] = "Pet/Education/a.png",
        [4] = "Pet/Education/s.png",
        [5] = "Pet/Education/2s.png",
        [6] = "Pet/Education/3s.png",
    }
    petEquipmentFromServer = {}
    allPetUnwearEquipment = {}
    allPetWearEquipment = {}
    allPetEquipment2Evaluate = {}
    tabFuncTex = {
        "Pet/Education/cwxx_yeqian_1.png",
        "Pet/Education/cwxx_yeqian_2.png",
    }
    tabTypeTex = {
        "UI/CommonFiles/share_paging_unchecked_05.png",
        "UI/CommonFiles/share_paging_05.png",
    }
    
    allPetEquipmentBag={}
    MAX_STRENGTHEN_LEVEL = 10
    MAX_PURIFY_LEVEL = 10
end

local function setItemButtonEvent(button, itemID)
    local resImg = ItemInfo.getItemRareBGImage(itemID)
    CSResourceMgr.setButtonTextureByNode(button, resImg, resImg, resImg)
    CSResourceMgr.clickEventBindingByNode(button, function()
        ItemInfoViewMgr.show({id = itemID}, false)
    end, 1)
end

local function updatePetStageFc(petInfo)
    local newInfo = PokemonInfo.getPetInfoByObjID(petInfo.objID)
    local petStage = CSResourceMgr.getNodeByName(resName, {"frame","bg","petStage"})
    local fc = CSResourceMgr.seekNodeByName(petStage, "fight_txt")
    CSResourceMgr.setLabelStringByNode(fc, newInfo.fc, {r=0,g=0,b=0,a=255})
end

local function updatePetStage(petInfo)
    --宠物动画
    local petStage = CSResourceMgr.getNodeByName(resName, {"frame","bg","petStage"})
    if not petStage.petInfo or petStage.petInfo.pokeID ~= petInfo.pokeID then
        if aniPetRes ~= nil then
            AnimationMgr.removeGafObjectByTag(aniPetRes, aniPetTag)
        end
        aniPetRes = PokemonInfo.getPokemonResByID(petInfo.pokeID)
        aniPetTag = "Pet_Equipment_"..petInfo.pokeID
        local petAniNode = CSResourceMgr.seekNodeByName(petStage, "petAni")
        local aniRes = AnimationMgr.createAni(petAniNode, aniPetRes, 0, 0, aniPetTag)
        aniRes:setScale(0.65)
        AnimationMgr.playAni(aniPetRes, "idle", true, aniPetTag)
        AnimationMgr.setSkin(aniPetRes, petInfo.skin, aniPetTag)
    end
    petStage.petInfo = petInfo
    --宠物信息
    CSResourceMgr.seekNodeByName(petStage, "orderString"):loadTexture(orderString[petInfo.rarePoint])
    for i=1, 5 do
        local star = CSResourceMgr.seekNodeByName(petStage, "star"..i)
        if i <= (petInfo.star or 0) then
            CSResourceMgr.setSpriteTextureByNode(star, "Pet/Education/xing.png")
        else
            CSResourceMgr.setSpriteTextureByNode(star, "UI/CommonFiles/xing_null.png")
        end
    end
    local level = CSResourceMgr.seekNodeByName(petStage, "level")
    CSResourceMgr.setLabelStringByNode(level, "Lv."..petInfo.level, {r=0,g=0,b=0,a=255})
    updatePetStageFc(petInfo)
    local s_type = CSResourceMgr.seekNodeByName(petStage, "sub_type")
    local pokeInfo = PokemonInfo.getPokemonInfoByID(petInfo.pokeID)
    s_type:setVisible(pokeInfo.elementAtt2 ~= 0)
    if pokeInfo.elementAtt2 ~= 0 then
        local ic = CSResourceMgr.seekNodeByName(s_type,"att_icon")
        ic:loadTexture("UI/CommonFiles/"..pokeInfo.elementAtt2..".png")
        ic:setScale(0.48)
    end
    
    local name_bg = CSResourceMgr.seekNodeByName(petStage, "name_bg")
    local icon1 = "UI/CommonFiles/"..pokeInfo.elementAtt1..".png"
    CSResourceMgr.seekNodeByName(name_bg,"att_icon"):loadTexture(icon1)
    local name = CSResourceMgr.seekNodeByName(name_bg,"name_txt")
    local stage = petInfo.Stage or 0
    if stage > 0 then
        CSResourceMgr.setLabelStringByNode(name, PetEducationMgr.getPetName(petInfo).."+"..stage, {r=0,g=0,b=0,a=255})
    else
        CSResourceMgr.setLabelStringByNode(name, PetEducationMgr.getPetName(petInfo), {r=0,g=0,b=0,a=255})
    end
    CSResourceMgr.setLabelColorByNode(name, PokemonInfo.COLOR[petInfo.rarePoint])
end

local function updatePetAttributeData(petInfo)
    print("++++++++updatePetAttributeData!!!!!!!!!!!!!!petInfo=",sz_T2S(PokemonInfo.getPetInfoByObjID(petInfo.objID)))
    PetEducationMgr.refreshMainPageAtts(resName, PokemonInfo.getPetInfoByObjID(petInfo.objID), nil, nil, {"frame", "bg", "equipmentSheet1", "container", "attr_list"}, {"frame", "attr_listexample"})
end

local function showItemInfo(equipmentInfo)
    PetEquipmentEvaluateMgr.show(SceneMgr.getRunningScene, equipmentInfo)
end

local function showEquipmentInfo(item, equipmentInfo, isTip)
    local petStage = CSResourceMgr.getNodeByName(resName, {"frame","bg","petStage"})
    if not equipmentInfo.pet then
        if petStage.petInfo then
            local isReplace = false
            for i=1, #allPetWearEquipment do
                local info = allPetWearEquipment[i]
                if petStage.petInfo.objID == info.pet.objID then
                    local pos1 = PetEquipInfo.getPetEquipInfoById(info.equips.equipID).pos
                    local pos2 = PetEquipInfo.getPetEquipInfoById(equipmentInfo.equips.equipID).pos
                    if pos1 == pos2 then
                        isReplace = true
                        break
                    end
                end
            end
            PetEquipmentOperationMgr.show(SceneMgr.getRunningScene, petStage.petInfo, equipmentInfo.equips, isReplace == true and "PetEquip18" or "PetEquip17", isTip, function()
                --CSResourceMgr.seekNodeByName(item, "status"):setVisible(true)
                --equipmentInfo.pet = petStage.petInfo
                PetEquipInfo.getPetEquip()
                updatePetAttributeData(petStage.petInfo)
                updatePetStageFc(petStage.petInfo)
            end)
        end
    else
        PetEquipmentOperationMgr.show(SceneMgr.getRunningScene, equipmentInfo.pet, equipmentInfo.equips, "PetEquip19", isTip, function()
            --CSResourceMgr.seekNodeByName(item, "status"):setVisible(false)
            --equipmentInfo.pet = nil
            --CSResourceMgr.seekNodeByName(item, "num"):hide()
            PetEquipInfo.getPetEquip()
            if petStage.petInfo then
                updatePetAttributeData(petStage.petInfo)
                updatePetStageFc(petStage.petInfo)
            end
        end)
    end
end

local function setItemInfo(item, equipmentInfo)
    local itemRes = ItemInfo.getItemRareBGImage(equipmentInfo[1])
    CSResourceMgr.setButtonTextureByNode(item, itemRes, itemRes, itemRes)
    local icon = CSResourceMgr.seekNodeByName(item, "icon")
    local iconRes = ItemInfo.getItemInfoById(equipmentInfo[1]).icon
    CSResourceMgr.setSpriteTextureByNode(icon, iconRes)
    --local status = CSResourceMgr.seekNodeByName(item, "status")
    local num = CSResourceMgr.seekNodeByName(item, "num")
    CSResourceMgr.setLabelStringByNode(num, equipmentInfo[2], {r=0,g=0,b=0,a=255})
    --status:setVisible(false)
    num:setVisible(true)
    local hook = CSResourceMgr.seekNodeByName(item, "hook")
    CSResourceMgr.setSpriteTextureByNode(hook, "Item/zhuangbei/weijianding.png")
    hook:pos(item:getContentSize().width/2, item:getContentSize().height/2)
    hook:show()
    
    CSResourceMgr.setButtonEnabledByNode(item, true)
    CSResourceMgr.clickEventBindingByNode(item, function()
        showItemInfo(equipmentInfo)
    end, 3)
end

local function getSelectedEquipmentFunc()
    local node = CSResourceMgr.getNodeByName(resName, {"frame", "bg", "equipmentFunc"})
    for i=1, 3 do
        local func = CSResourceMgr.seekNodeByName(node, "tab"..i)
        local scaleX = func:getScaleX()
        if scaleX > 1.05 then
            return i
        end
    end
end

local function checkStrengthenAttrList(list, total)
    if not CSResourceMgr.getCsbObj(resName) then
        return
    end

    local current = #(list:getItems())
    if current < total then
        for i=1, total-current do
            local cell = CSResourceMgr.getNodeByName(resName,"strengthen_listexample"):clone()
            local background1   = CSResourceMgr.seekNodeByName(cell, "att_background_1")
            local background2   = CSResourceMgr.seekNodeByName(cell, "att_background_2")
            local background3   = CSResourceMgr.seekNodeByName(cell, "att_background_3")
            cell:setColor({r=37,g=53,b=69,a=255})
            background1:setColor({r=26,g=38,b=49,a=255})
            background2:setColor({r=26,g=38,b=49,a=255})
            background3:setColor({r=26,g=38,b=49,a=255})
            cell:setVisible(true)
            list:pushBackCustomItem(cell)
        end
    elseif current > total then
        for i=1, current-total do
            list:removeItem(current - i)
        end
    end
end

local function checkPurifyAttrList(list, total)
    if not CSResourceMgr.getCsbObj(resName) then
        return
    end
    
    local current = #(list:getItems())
    if current < total then
        for i=1, total-current do
            local cell = CSResourceMgr.getNodeByName(resName,"purify_listexample"):clone()
            local background1   = CSResourceMgr.seekNodeByName(cell, "att_background_1")
            local background2   = CSResourceMgr.seekNodeByName(cell, "att_background_2")
            local background3   = CSResourceMgr.seekNodeByName(cell, "att_background_3")
            cell:setColor({r=37,g=53,b=69,a=255})
            background1:setColor({r=26,g=38,b=49,a=255})
            background2:setColor({r=26,g=38,b=49,a=255})
            background3:setColor({r=26,g=38,b=49,a=255})
            cell:setVisible(true)
            list:pushBackCustomItem(cell)
        end
    elseif current > total then
        for i=1, current-total do
            list:removeItem(current - i)
        end
    end
end

local function getEquipmentStrengthenInfo(equipmentInfo, strengthenLevel)
    if strengthenLevel <= 0 then
        return {rate = 100, itemCost = 0, moneyCost = 0, effect = 0}
    elseif strengthenLevel > MAX_STRENGTHEN_LEVEL then
        strengthenLevel = MAX_STRENGTHEN_LEVEL
    end
    local quality = PetEquipInfo.getPetEquipInfoById(equipmentInfo.equips.equipID).quality
    return PetEquipInfo.getPetEquipStrengthenInfoById(quality).infos[strengthenLevel]
end

local function getEquipmentPurifyInfo(equipmentInfo, purifyLevel)
    if purifyLevel <= 0 then
        return {first = 0, second = 0}
    elseif purifyLevel > MAX_PURIFY_LEVEL then
        purifyLevel = MAX_PURIFY_LEVEL
    end
    local quality = PetEquipInfo.getPetEquipInfoById(equipmentInfo.equips.equipID).quality
    return PetEquipInfo.getPetEquipPurifyInfoById(quality).expAndpercents[purifyLevel]
end

local function getEquipmentPurifyMaxExp(equipmentInfo, curPurifyLevel, curExp)
    local curMaxLevel = PetEquipInfo.getPetEquipInfoById(equipmentInfo.equips.equipID).purifyMax
    local needExp = 0
    for var=curPurifyLevel+1, curMaxLevel do
        local purifyInfo = getEquipmentPurifyInfo(equipmentInfo, var)
        needExp = needExp + purifyInfo.first
    end
    if needExp>0 then
        needExp = needExp - curExp
    end
    return needExp
end

local function setLuckyStone(luckyStoneID)
    local luckyStone = CSResourceMgr.getNodeByName(resName, {"frame", "bg", "equipmentSheet2", "element", "adaptation", "stone"})
    luckyStone.luckyStoneID = luckyStoneID
    local click = CSResourceMgr.seekNodeByName(luckyStone, "click") 
    local icon = CSResourceMgr.seekNodeByName(luckyStone, "icon")
    if luckyStoneID then
        local itemRes = ItemInfo.getItemRareBGImage(luckyStoneID)
        CSResourceMgr.setButtonTextureByNode(luckyStone, itemRes, itemRes, ItemInfo.getItemRareBGImage())
        click:setVisible(false)
        local iconRes = ItemInfo.getItemInfoById(luckyStoneID).icon
        CSResourceMgr.setSpriteTextureByNode(icon, iconRes)
    else
        local itemRes = "Item/ItemRare/2.png"
        CSResourceMgr.setButtonTextureByNode(luckyStone, itemRes, itemRes, ItemInfo.getItemRareBGImage())
        click:setVisible(true)
        CSResourceMgr.setSpriteTextureByNode(icon, "empty.png")
    end
end

local function setLuckyRate(equipmentInfo, luckyStoneID)
    local rate_num = CSResourceMgr.getNodeByName(resName, {"frame", "bg", "equipmentSheet2", "element", "adaptation", "rate_num"})
    if not equipmentInfo then
        CSResourceMgr.setLabelStringByNode(rate_num, "", {r=0,g=0,b=0,a=255})
    else
        local strengthenLevel = equipmentInfo.equips.strengthen or 0
        if strengthenLevel<MAX_STRENGTHEN_LEVEL then
            local info = getEquipmentStrengthenInfo(equipmentInfo, strengthenLevel + 1)
            if luckyStoneID > 0 then
                local addRate = ItemInfo.getItemInfoById(luckyStoneID).paramA
                CSResourceMgr.setLabelStringByNode(rate_num, info.rate.."%".."+"..addRate.."%", {r=0,g=0,b=0,a=255})
            else
                CSResourceMgr.setLabelStringByNode(rate_num, info.rate.."%", {r=0,g=0,b=0,a=255})
            end
        else
            CSResourceMgr.setLabelStringByNode(rate_num, "--", {r=0,g=0,b=0,a=255})
        end
    end
end

local function getLuckyStone()
    local luckyStone = CSResourceMgr.getNodeByName(resName, {"frame", "bg", "equipmentSheet2", "element", "adaptation", "stone"})
    return luckyStone.luckyStoneID or 0
end

local function sortEquips(equipList)
    table.sort(equipList, function(a, b)
        local aQuality = PetEquipInfo.getPetEquipInfoById(a.equips.equipID).quality
        local bQuality = PetEquipInfo.getPetEquipInfoById(b.equips.equipID).quality
        if aQuality ~= bQuality then
            return aQuality > bQuality
        else
            local aStrengthenLevel = a.equips.strengthen or 0
            local bStrengthenLevel = b.equips.strengthen or 0
            return aStrengthenLevel > bStrengthenLevel
        end
    end)
end

local function sortItems(itemList)
    table.sort(itemList, function(a, b)
        local aRare = ItemInfo.getItemInfoById(a[1]).itemRare
        local bRare = ItemInfo.getItemInfoById(b[1]).itemRare
        return aRare > bRare
    end)
end

local function sortPurifyMaterials(materialList)
    table.sort(materialList, function(a, b)
        local aStrengthenLevel = a.equips.strengthen or 0
        local bStrengthenLevel = b.equips.strengthen or 0 
        if aStrengthenLevel ~= bStrengthenLevel then
            return aStrengthenLevel < bStrengthenLevel
        else
            local aPurifyLevel = 0
            if a.equips.purify then
                aPurifyLevel = a.equips.purify.level or 0
            end
            local bPurifyLevel = 0
            if b.equips.purify then
                bPurifyLevel = b.equips.purify.level or 0
            end
            if aPurifyLevel ~= bPurifyLevel then
                return aPurifyLevel < bPurifyLevel
            else
                local aQuality = PetEquipInfo.getPetEquipInfoById(a.equips.equipID).quality
                local bQuality = PetEquipInfo.getPetEquipInfoById(b.equips.equipID).quality
                if aQuality ~= bQuality then
                    return aQuality < bQuality
                else
                    local aObjID = a.equips.objID or 0
                    local bObjID = b.equips.objID or 0
                    return aObjID < bObjID
                end
            end
        end
    end)
end

local function updateStrengthenSheet(equipmentInfo)
    if not equipmentInfo then
        local element = CSResourceMgr.getNodeByName(resName, {"frame", "bg", "equipmentSheet2", "element"})
        local item = CSResourceMgr.seekNodeByName(element, "item")
        local itemRes = PetEquipInfo.getEquipQualityBGImage()
        CSResourceMgr.setButtonTextureByNode(item, itemRes, itemRes, itemRes)
        CSResourceMgr.clickEventBindingByNode(item, function() end)
        local icon = CSResourceMgr.seekNodeByName(item, "icon")
        CSResourceMgr.setSpriteTextureByNode(icon, "empty.png")
        local name = CSResourceMgr.seekNodeByName(element, "name")
        CSResourceMgr.setLabelStringByNode(name, "", {r=0,g=0,b=0,a=255})
        local pos = CSResourceMgr.seekNodeByName(element, "pos")
        CSResourceMgr.setLabelStringByNode(pos, "", {r=0,g=0,b=0,a=255})
        local seriesIcon = CSResourceMgr.seekNodeByName(element, "seriesIcon")
        seriesIcon:removeAllChildren()
        local list = CSResourceMgr.getNodeByName(resName, {"frame", "bg", "equipmentSheet2", "container", "attr_list"})
        list:removeAllItems()
        local adaptation = CSResourceMgr.seekNodeByName(element, "adaptation")
        local effect_txt = CSResourceMgr.seekNodeByName(adaptation, "effect_txt")
        CSResourceMgr.setLabelStringByNode(effect_txt, "", {r=0,g=0,b=0,a=255})
        local cost_stone = CSResourceMgr.seekNodeByName(adaptation, "cost_stone")
        CSResourceMgr.setLabelStringByNode(cost_stone, "", {r=0,g=0,b=0,a=255})
        local cost_money = CSResourceMgr.seekNodeByName(adaptation, "cost_money")
        CSResourceMgr.setLabelStringByNode(cost_money, "", {r=0,g=0,b=0,a=255})
        local luckyStone = CSResourceMgr.seekNodeByName(adaptation, "stone")
        CSResourceMgr.setButtonEnabledByNode(luckyStone, false)
        local rate_num = CSResourceMgr.seekNodeByName(adaptation, "rate_num")
        CSResourceMgr.setLabelStringByNode(rate_num, "", {r=0,g=0,b=0,a=255})
        local btn_strengthen = CSResourceMgr.seekNodeByName(adaptation, "btn_strengthen")
        CSResourceMgr.setButtonEnabledByNode(btn_strengthen, false)
    else
        local element = CSResourceMgr.getNodeByName(resName, {"frame", "bg", "equipmentSheet2", "element"})
        local itemRes = PetEquipInfo.getEquipQualityBGImage(equipmentInfo.equips.equipID)
        local item = CSResourceMgr.seekNodeByName(element, "item")
        CSResourceMgr.setButtonTextureByNode(item, itemRes, itemRes, PetEquipInfo.getEquipQualityBGImage())
        CSResourceMgr.clickEventBindingByNode(item, function()
            PetEquipmentOperationMgr.show(SceneMgr.getRunningScene, nil, equipmentInfo.equips, "", "null")
        end, 3)
        local icon = CSResourceMgr.seekNodeByName(item, "icon")
        local iconRes = PetEquipInfo.getPetEquipInfoById(equipmentInfo.equips.equipID).icon
        CSResourceMgr.setSpriteTextureByNode(icon, iconRes)
        local name = CSResourceMgr.seekNodeByName(element, "name")
        CSResourceMgr.setLabelStringByNode(name, PetEquipInfo.getPetEquipInfoById(equipmentInfo.equips.equipID).name, {r=0,g=0,b=0,a=255})
        local posTxt = {"PetEquip6", "PetEquip7", "PetEquip8"}
        local pos = CSResourceMgr.seekNodeByName(element, "pos")
        CSResourceMgr.setLabelStringByNode(pos, LuaSqlite.getLanguageByKey("PetEquip21")..LuaSqlite.getLanguageByKey(posTxt[PetEquipInfo.getPetEquipInfoById(equipmentInfo.equips.equipID).pos]), {r=0,g=0,b=0,a=255})
        local seriesIcon = CSResourceMgr.seekNodeByName(element, "seriesIcon")
        seriesIcon:removeAllChildren()
        local elemAttrNum = PetEquipInfo.getPetEquipInfoById(equipmentInfo.equips.equipID).elemAttrNum
        if elemAttrNum == 9 then
            local sprite = display.newSprite("Pet/Equipment/all.png")
            sprite:setScale(0.5)
            sprite:setPosition(0, 2)
            sprite:setAnchorPoint(0.5, 0.5)
            seriesIcon:addChild(sprite)
        else
            local elemAttr = equipmentInfo.equips.elemAttr or {}
            for i=1, #elemAttr do
                local tex = "UI/CommonFiles/"..elemAttr[i]..".png"
                local sprite = display.newSprite(tex)
                sprite:setScale(0.5)
                local w = sprite:getContentSize().width * 0.5
                sprite:setPosition((i-1) * w, 2)
                sprite:setAnchorPoint(0.5, 0.5)
                seriesIcon:addChild(sprite)
            end
        end
        
        local strengthenLevel = equipmentInfo.equips.strengthen or 0
        local purifyLevel = 0
        if equipmentInfo.equips.purify then
            purifyLevel = equipmentInfo.equips.purify.level or 0
        end
        local purifyInfo = getEquipmentPurifyInfo(equipmentInfo, purifyLevel)
        
        local text = {"train11","train12","train14","train16","train15","train13",}
        local num  = {
            equipmentInfo.equips.hp > 0 and equipmentInfo.equips.hp + math.floor(equipmentInfo.equips.hp*(purifyInfo.second/100.0)) or 0,
            equipmentInfo.equips.atk > 0 and equipmentInfo.equips.atk + math.floor(equipmentInfo.equips.atk*(purifyInfo.second/100.0)) or 0,
            equipmentInfo.equips.satk > 0 and equipmentInfo.equips.satk + math.floor(equipmentInfo.equips.satk*(purifyInfo.second/100.0)) or 0,
            equipmentInfo.equips.speed > 0 and equipmentInfo.equips.speed + math.floor(equipmentInfo.equips.speed*(purifyInfo.second/100.0)) or 0,
            equipmentInfo.equips.sdef > 0 and equipmentInfo.equips.sdef + math.floor(equipmentInfo.equips.sdef*(purifyInfo.second/100.0)) or 0,
            equipmentInfo.equips.def > 0 and equipmentInfo.equips.def + math.floor(equipmentInfo.equips.def*(purifyInfo.second/100.0)) or 0,
        }
        --print("========num=",sz_T2S(num))
        local list = CSResourceMgr.getNodeByName(resName, {"frame", "bg", "equipmentSheet2", "container", "attr_list"})
        local totalAttrNum = 1
        for i=1, #num do
            if num[i] > 0 then
                totalAttrNum = totalAttrNum + 1
            end
        end
        checkStrengthenAttrList(list, totalAttrNum)
        local items = list:getItems()
        for i=1, totalAttrNum do
            local item = items[i]
            local att_arrow  = CSResourceMgr.seekNodeByName(item, "att_arrow")
            local attrNameLeft  = CSResourceMgr.seekNodeByName(item, "attr_text")
            local attrNumLeft   = CSResourceMgr.seekNodeByName(item, "attr_num")
            local attrAddLeft   = CSResourceMgr.seekNodeByName(item, "attr_add_num")
            local attrNumRight  = CSResourceMgr.seekNodeByName(item, "next_attr_num")
            local attrAddRight  = CSResourceMgr.seekNodeByName(item, "next_attr_add_num")
            local background1   = CSResourceMgr.seekNodeByName(item, "att_background_1")
            local background2   = CSResourceMgr.seekNodeByName(item, "att_background_2")
            local background3   = CSResourceMgr.seekNodeByName(item, "att_background_3")
            if i==1 then
                CSResourceMgr.setLabelStringByNode(attrNameLeft, "PetEquip28", {r=0,g=0,b=0,a=255})
                CSResourceMgr.setLabelColorByNode(attrNameLeft, {r=254,g=243,b=57,a=255})
                CSResourceMgr.setLabelStringByNode(attrNumLeft, "", {r=0,g=0,b=0,a=255})
                CSResourceMgr.setLabelStringByNode(attrAddLeft, "+"..strengthenLevel, {r=0,g=0,b=0,a=255})
                local width = attrAddLeft:getBoundingBox().width * 0.5
                local addWidth = attrNumLeft:getBoundingBox().width * 0.5
                attrNumLeft:setPositionX(background2:getPositionX() - width)
                attrAddLeft:setPositionX(attrNumLeft:getPositionX() + addWidth)
                if strengthenLevel < MAX_STRENGTHEN_LEVEL then
                    att_arrow:setVisible(true)
                    CSResourceMgr.setLabelStringByNode(attrNumRight, "", {r=0,g=0,b=0,a=255})
                    attrNumRight:setVisible(false)
                    CSResourceMgr.setLabelStringByNode(attrAddRight, "+"..strengthenLevel+1, {r=0,g=0,b=0,a=255})
                    attrAddRight:setVisible(true)
                    local width = attrAddRight:getBoundingBox().width * 0.5
                    local addWidth = attrNumRight:getBoundingBox().width * 0.5
                    attrNumRight:setPositionX(background3:getPositionX() - width)
                    attrAddRight:setPositionX(attrNumRight:getPositionX() + addWidth)
                else
                    att_arrow:setVisible(false)
                    attrNumRight:setVisible(false)
                    attrAddRight:setVisible(false)
                end
            else
                for k, v in pairs(num) do
                    if v > 0 then
                        CSResourceMgr.setLabelStringByNode(attrNameLeft, text[k], {r=0,g=0,b=0,a=255})
                        CSResourceMgr.setLabelColorByNode(attrNameLeft, {r=254,g=243,b=57,a=255})
                        CSResourceMgr.setLabelStringByNode(attrNumLeft, v, {r=0,g=0,b=0,a=255})
                        if strengthenLevel == 0 then
                            CSResourceMgr.setLabelStringByNode(attrAddLeft, "+0", {r=0,g=0,b=0,a=255})
                        else
                            local info = getEquipmentStrengthenInfo(equipmentInfo, strengthenLevel)
                            CSResourceMgr.setLabelStringByNode(attrAddLeft, "+"..math.floor(v*(info.effect/100.0)), {r=0,g=0,b=0,a=255})
                        end
                        local width = attrAddLeft:getBoundingBox().width * 0.5
                        local addWidth = attrNumLeft:getBoundingBox().width * 0.5
                        attrNumLeft:setPositionX(background2:getPositionX() - width)
                        attrAddLeft:setPositionX(attrNumLeft:getPositionX() + addWidth)
                        if strengthenLevel < MAX_STRENGTHEN_LEVEL then
                            att_arrow:setVisible(true)
                            CSResourceMgr.setLabelStringByNode(attrNumRight, v, {r=0,g=0,b=0,a=255})
                            attrNumRight:setVisible(true)
                            local info = getEquipmentStrengthenInfo(equipmentInfo, strengthenLevel + 1)
                            CSResourceMgr.setLabelStringByNode(attrAddRight, "+"..math.floor(v*(info.effect/100.0)), {r=0,g=0,b=0,a=255})
                            attrAddRight:setVisible(true)
                            local width = attrAddRight:getBoundingBox().width * 0.5
                            local addWidth = attrNumRight:getBoundingBox().width * 0.5
                            attrNumRight:setPositionX(background3:getPositionX() - width)
                            attrAddRight:setPositionX(attrNumRight:getPositionX() + addWidth)
                        else
                            att_arrow:setVisible(false)
                            attrNumRight:setVisible(false)
                            attrAddRight:setVisible(false)
                        end
                        num[k] = 0
                        break
                    end
                end
            end
        end
        
        local adaptation = CSResourceMgr.seekNodeByName(element, "adaptation")
        local effect_txt = CSResourceMgr.seekNodeByName(adaptation, "effect_txt")
        CSResourceMgr.setLabelStringByNode(effect_txt, "", {r=0,g=0,b=0,a=255})
        if strengthenLevel < MAX_STRENGTHEN_LEVEL and equipmentInfo.equips.effects then
            local effect = equipmentInfo.equips.effects[tostring(strengthenLevel + 1)]
            if effect then
                local info = PetEquipInfo.getPetEquipEffectInfoById(effect.ID)
                CSResourceMgr.setLabelStringByNode(effect_txt, CocosModuleMgr.createStringWithFormat({info.name, effect.value or 0}), {r=0,g=0,b=0,a=255})
            end
        end
        
        local info = getEquipmentStrengthenInfo(equipmentInfo, strengthenLevel + 1)
        local strengthenStone = ItemInfo.getCharItemNum(SystemInfo.getGlobalConfigAddInfoByID(60001).values[2])
        local cost_stone = CSResourceMgr.seekNodeByName(adaptation, "cost_stone")
        local costStr1 = info.itemCost.."/"..strengthenStone
        local costStr2 = info.moneyCost
        if strengthenLevel >= MAX_STRENGTHEN_LEVEL then
            costStr1 = "-/-"
            costStr2 = "-/-"
        end
        CSResourceMgr.setLabelStringByNode(cost_stone, costStr1, {r=0,g=0,b=0,a=255}, nil, 90)
        if info.itemCost <= strengthenStone then
            CSResourceMgr.setLabelColorByNode(cost_stone, {r=255,g=255,b=255,a=255})
        else
            CSResourceMgr.setLabelColorByNode(cost_stone, {r=255,g=0,b=0,a=255})
        end
        local cost_money = CSResourceMgr.seekNodeByName(adaptation, "cost_money")
        CSResourceMgr.setLabelStringByNode(cost_money, costStr2, {r=0,g=0,b=0,a=255}, nil, 90)
        if info.moneyCost <= CharInfo.getGCash() or costStr2=="-/-" then
            CSResourceMgr.setLabelColorByNode(cost_money, {r=255,g=255,b=255,a=255})
        else
            CSResourceMgr.setLabelColorByNode(cost_money, {r=255,g=0,b=0,a=255})
        end
        local luckyStone = CSResourceMgr.seekNodeByName(adaptation, "stone")
        CSResourceMgr.setButtonEnabledByNode(luckyStone, strengthenLevel < MAX_STRENGTHEN_LEVEL)
        CSResourceMgr.clickEventBindingByNode(luckyStone, function()
            PickItemViewMgr.show(SceneMgr.getRunningScene, {{60001,ItemInfo.getCharItemNum(60001)}, {60002,ItemInfo.getCharItemNum(60002)},{60003,ItemInfo.getCharItemNum(60003)}, {60004,ItemInfo.getCharItemNum(60004)}}, luckyStone.luckyStoneID, function()
                setLuckyStone(PickItemViewMgr.getPickedItemID())
                setLuckyRate(equipmentInfo, getLuckyStone())
            end)
        end)
        setLuckyRate(equipmentInfo, getLuckyStone())
        
        local btn_strengthen = CSResourceMgr.seekNodeByName(adaptation, "btn_strengthen")
        if strengthenStone < info.itemCost or CharInfo.getGCash() < info.moneyCost or strengthenLevel >= MAX_STRENGTHEN_LEVEL then
            CSResourceMgr.setButtonEnabledByNode(btn_strengthen, false)
        else
            CSResourceMgr.setButtonEnabledByNode(btn_strengthen, true)
        end
        CSResourceMgr.clickEventBindingByNode(btn_strengthen, function()
            local petStage = CSResourceMgr.getNodeByName(resName, {"frame","bg","petStage"})
            if petStage.petInfo then
                PetEquipInfo.petEquipStrengthen(petStage.petInfo.objID, PetEquipInfo.getPetEquipInfoById(equipmentInfo.equips.equipID).pos, getLuckyStone(), function()
                    PetEquipmentStrengthenEffectMgr.show(SceneMgr.getRunningScene, 
                        CocosModuleMgr.getWordImage("equipment/UI_duanzao_success.png"), 
                        "equip"..equipmentInfo.equips.equipID, function()
                            setLuckyStone(nil)
                            PetEquipInfo.getPetEquip()
                            updatePetAttributeData(petStage.petInfo)
                            updatePetStageFc(petStage.petInfo)
                        end, function()
                        	GameAudio.playUISound("itemCollect")
                        end)
                end, function()
                    PetEquipmentStrengthenEffectMgr.show(SceneMgr.getRunningScene, 
                        CocosModuleMgr.getWordImage("equipment/UI_duanzao_Fail.png"), 
                        "equip"..equipmentInfo.equips.equipID, function()
                            local pickId = PickItemViewMgr.getPickedItemID()
                            if pickId then
                                local num = ItemInfo.getCharItemNum(pickId)
                                print("remain item:", pickId, num)
                                if num<=0 then
                                    setLuckyStone(nil)
                                end
                            end
                            PetEquipInfo.getPetEquip()
                        end, function()
                        	GameAudio.playBattleSound("battleEnd")
                        end)
                end)
            end
        end)
    end
end

local function gatherAllMaterials(adaptation)
    local allMaterials = {}
    if adaptation then
        for i=1, 4 do
            local itemMaterial = CSResourceMgr.seekNodeByName(adaptation, "material"..i)
            local materialInfo = itemMaterial.materialInfo
            if materialInfo then
                table.insert(allMaterials, materialInfo)
            end
        end
    end
    
    return allMaterials
end

local function refreshAllMaterials(adaptation, allMaterials)
    if adaptation then
        local exp = 0
        for i=1, 4 do
            local itemMaterial = CSResourceMgr.seekNodeByName(adaptation, "material"..i)
            local icon = CSResourceMgr.seekNodeByName(itemMaterial, "icon")
            icon:pos(46.5, 47.5)
            icon:setRotation(0)
            icon:scale(1)
            if icon.attrVec then
                for k=1, #icon.attrVec do
            		icon.attrVec[k]:removeFromParent(true)
            	end
            end
            icon.attrVec = nil
            local num = CSResourceMgr.seekNodeByName(itemMaterial, "num")
            local itemRes
            local iconRes
            if i <= #allMaterials then
                local materialInfo = allMaterials[i]
                if not materialInfo[3] then
                    exp = exp + SystemInfo.getGlobalConfigAddInfoByID(60001).values[4] * materialInfo[2]
                    itemRes = ItemInfo.getItemRareBGImage(materialInfo[1])
                    iconRes = ItemInfo.getItemInfoById(materialInfo[1]).icon
                    CSResourceMgr.setButtonTextureByNode(itemMaterial, itemRes, itemRes, ItemInfo.getItemRareBGImage())
                    CSResourceMgr.setSpriteTextureByNode(icon, iconRes)
                    CSResourceMgr.setLabelStringByNode(num, materialInfo[2], {r=0,g=0,b=0,a=255})
                    num:show()
                else
                    exp = exp + PetEquipInfo.getPetEquipPurifyExpInfoById(PetEquipInfo.getPetEquipInfoById(materialInfo[1]).quality).exp
                    itemRes = PetEquipInfo.getEquipQualityBGImage(materialInfo[1])
                    iconRes = PetEquipInfo.getPetEquipInfoById(materialInfo[1]).icon
                    CSResourceMgr.setButtonTextureByNode(itemMaterial, itemRes, itemRes, ItemInfo.getItemRareBGImage())
                    CSResourceMgr.setSpriteTextureByNode(icon, iconRes)
                    local strengthenLevel = materialInfo[3].strengthen or 0
                    if strengthenLevel > 0 then
                        num:show()
                        CSResourceMgr.setLabelStringByNode(num, "+"..strengthenLevel, {r=0,g=0,b=0,a=255})
                    else
                        num:hide()
                    end
                    
                    local elemAttr = materialInfo[3].elemAttr or {}
                    local spriteVec = {}
                    local attrNum = PetEquipInfo.getPetEquipInfoById(materialInfo[3].equipID).elemAttrNum
                    if attrNum==9 then
                        local sprite = display.newSprite("Pet/Equipment/all.png")
                        sprite:setScale(0.5)
                        sprite:setPosition(5, 70)
                        sprite:setAnchorPoint(0.5, 0.5)
                        icon:addChild(sprite)
                        table.insert(spriteVec, sprite)
                    else
                        for i=1, #elemAttr do
                            local tex = "UI/CommonFiles/"..elemAttr[i]..".png"
                            local sprite = display.newSprite(tex)
                            sprite:setScale(0.5)
                            local w = sprite:getContentSize().width * 0.4
                            sprite:setPosition(5+(i-1)*w, 70)
                            sprite:setAnchorPoint(0.5, 0.5)
                            icon:addChild(sprite)
                            table.insert(spriteVec, sprite)
                        end
                    end
                    icon.attrVec = spriteVec
                end
                itemMaterial.materialInfo = materialInfo
            else
                itemRes = "Item/ItemRare/2.png"
                iconRes = "empty.png"
                CSResourceMgr.setButtonTextureByNode(itemMaterial, itemRes, itemRes, ItemInfo.getItemRareBGImage())
                CSResourceMgr.setSpriteTextureByNode(icon, iconRes)
                num:setVisible(false)
                itemMaterial.materialInfo = nil
            end
        end
        
        local exp_num = CSResourceMgr.seekNodeByName(adaptation, "exp_num")
        CSResourceMgr.setLabelStringByNode(exp_num, exp, {r=0,g=0,b=0,a=255})
    end
end

local function getPetEquipByPos(objID, pos)
    local allPets = PokemonInfo.getAllPets()
    for k, v in pairs(allPets) do
        if v.objID == objID then
            if v.equips then
                return v.equips[tostring(pos)]
            end
            break
        end
    end

    return nil
end

local function playPurifyEff(purifyLevel, callback)
    --print("!!!playPurifyEff purifyLevel=",purifyLevel)
    if purifyLevel > 0 then
        local star = CSResourceMgr.getNodeByName(resName, {"frame", "bg", "equipmentSheet3", "element", "level", "star"..purifyLevel})
        if star then
            local aniRes = "Gaf/effect/starupEffect.gaf"
            local tag = "purifyLevel"..purifyLevel
            local ani = AnimationMgr.createAni(star, aniRes, 0+15, 650+7, tag)
            ani:setGlobalZOrder(100)
            AnimationMgr.playAniWithCallback(aniRes, "do", function()
                AnimationMgr.removeGafObjectByTag(aniRes, tag)
                cc.Director:getInstance():getTextureCache():removeUnusedTextures()
                if callback then
                	callback()
                end
            end, tag)
            return ani
        end
    end
end

local function updatePurifySheet(equipmentInfo)
    if not equipmentInfo then
        local element = CSResourceMgr.getNodeByName(resName, {"frame", "bg", "equipmentSheet3", "element"})
        local item = CSResourceMgr.seekNodeByName(element, "item")
        local itemRes = PetEquipInfo.getEquipQualityBGImage()
        CSResourceMgr.setButtonTextureByNode(item, itemRes, itemRes, itemRes)
        CSResourceMgr.clickEventBindingByNode(item, function() end)
        local icon = CSResourceMgr.seekNodeByName(item, "icon")
        CSResourceMgr.setSpriteTextureByNode(icon, "empty.png")
        local name = CSResourceMgr.seekNodeByName(element, "name")
        CSResourceMgr.setLabelStringByNode(name, "", {r=0,g=0,b=0,a=255})
        local pos = CSResourceMgr.seekNodeByName(element, "pos")
        CSResourceMgr.setLabelStringByNode(pos, "", {r=0,g=0,b=0,a=255})
        local seriesIcon = CSResourceMgr.seekNodeByName(element, "seriesIcon")
        seriesIcon:removeAllChildren()
        local level = CSResourceMgr.seekNodeByName(element, "level")
        level:setVisible(false)
        local progress = CSResourceMgr.seekNodeByName(element, "progress")
        local bar = CSResourceMgr.seekNodeByName(progress, "bar")
        bar:setPercent(0.0)
        local percent = CSResourceMgr.seekNodeByName(progress, "num")
        CSResourceMgr.setLabelStringByNode(percent, "", {r=0,g=0,b=0,a=255})
        local list = CSResourceMgr.getNodeByName(resName, {"frame", "bg", "equipmentSheet3", "container", "attr_list"})
        list:removeAllItems()
        local adaptation = CSResourceMgr.seekNodeByName(element, "adaptation")
        local exp_num = CSResourceMgr.seekNodeByName(adaptation, "exp_num")
        CSResourceMgr.setLabelStringByNode(exp_num, "", {r=0,g=0,b=0,a=255})
        for i=1, 4 do
            local itemMaterial = CSResourceMgr.seekNodeByName(adaptation, "material"..i)
            local icon = CSResourceMgr.seekNodeByName(itemMaterial, "icon")
            local num = CSResourceMgr.seekNodeByName(itemMaterial, "num")
            itemRes = "Item/ItemRare/2.png"
            CSResourceMgr.setButtonTextureByNode(itemMaterial, itemRes, itemRes, ItemInfo.getItemRareBGImage())
            CSResourceMgr.setSpriteTextureByNode(icon, "empty.png")
            num:setVisible(false)
            itemMaterial.materialInfo = nil
            CSResourceMgr.setButtonEnabledByNode(itemMaterial, false)
        end
        local btn_purify = CSResourceMgr.seekNodeByName(adaptation, "btn_purify")
        CSResourceMgr.setButtonEnabledByNode(btn_purify, false)
        local btn_quick = CSResourceMgr.seekNodeByName(adaptation, "btn_quick")
        CSResourceMgr.setButtonEnabledByNode(btn_quick, false)
    else
        local element = CSResourceMgr.getNodeByName(resName, {"frame", "bg", "equipmentSheet3", "element"})
        local itemRes = PetEquipInfo.getEquipQualityBGImage(equipmentInfo.equips.equipID)
        local item = CSResourceMgr.seekNodeByName(element, "item")
        CSResourceMgr.setButtonTextureByNode(item, itemRes, itemRes, PetEquipInfo.getEquipQualityBGImage())
        CSResourceMgr.clickEventBindingByNode(item, function()
            PetEquipmentOperationMgr.show(SceneMgr.getRunningScene, nil, equipmentInfo.equips, "", "null")
        end, 3)
        local icon = CSResourceMgr.seekNodeByName(item, "icon")
        local iconRes = PetEquipInfo.getPetEquipInfoById(equipmentInfo.equips.equipID).icon
        CSResourceMgr.setSpriteTextureByNode(icon, iconRes)
        local name = CSResourceMgr.seekNodeByName(element, "name")
        CSResourceMgr.setLabelStringByNode(name, PetEquipInfo.getPetEquipInfoById(equipmentInfo.equips.equipID).name, {r=0,g=0,b=0,a=255})
        local posTxt = {"PetEquip6", "PetEquip7", "PetEquip8"}
        local pos = CSResourceMgr.seekNodeByName(element, "pos")
        CSResourceMgr.setLabelStringByNode(pos, LuaSqlite.getLanguageByKey("PetEquip21")..LuaSqlite.getLanguageByKey(posTxt[PetEquipInfo.getPetEquipInfoById(equipmentInfo.equips.equipID).pos]), {r=0,g=0,b=0,a=255})
        local seriesIcon = CSResourceMgr.seekNodeByName(element, "seriesIcon")
        seriesIcon:removeAllChildren()
        local elemAttrNum = PetEquipInfo.getPetEquipInfoById(equipmentInfo.equips.equipID).elemAttrNum
        if elemAttrNum == 9 then
            local sprite = display.newSprite("Pet/Equipment/all.png")
            sprite:setScale(0.5)
            sprite:setPosition(0, 2)
            sprite:setAnchorPoint(0.5, 0.5)
            seriesIcon:addChild(sprite)
        else
            local elemAttr = equipmentInfo.equips.elemAttr or {}
            for i=1, #elemAttr do
                local tex = "UI/CommonFiles/"..elemAttr[i]..".png"
                local sprite = display.newSprite(tex)
                sprite:setScale(0.5)
                local w = sprite:getContentSize().width * 0.5
                sprite:setPosition((i-1) * w, 2)
                sprite:setAnchorPoint(0.5, 0.5)
                seriesIcon:addChild(sprite)
            end
        end
        
        local strengthenLevel = equipmentInfo.equips.strengthen or 0
        local purifyLevel = 0
        local purifyExp = 0
        if equipmentInfo.equips.purify then
            purifyLevel = equipmentInfo.equips.purify.level or 0
            purifyExp = equipmentInfo.equips.purify.exp or 0
        end
        
        local level = CSResourceMgr.seekNodeByName(element, "level")
        level:setVisible(true)
        local curMaxLevel = PetEquipInfo.getPetEquipInfoById(equipmentInfo.equips.equipID).purifyMax
        for i=1, MAX_PURIFY_LEVEL do
            local star = CSResourceMgr.seekNodeByName(level, "star"..i)
            if i <= purifyLevel then
                CSResourceMgr.setSpriteTextureByNode(star, "Pet/Education/xing.png")
                star:setVisible(true)
            else
                if i <= PetEquipInfo.getPetEquipInfoById(equipmentInfo.equips.equipID).purifyMax then
                    CSResourceMgr.setSpriteTextureByNode(star, "UI/CommonFiles/xing_null.png")
                    star:setVisible(true)
                else
                    star:setVisible(false)
                end
            end
        end
        local progress = CSResourceMgr.seekNodeByName(element, "progress")
        local bar = CSResourceMgr.seekNodeByName(progress, "bar")
        local percent = CSResourceMgr.seekNodeByName(progress, "num")
        local curEqID = equipmentInfo.equips.equipID..equipmentInfo.pet.objID
        if purifyLevel >= curMaxLevel then
            bar:setPercent(0.0)
            CSResourceMgr.setLabelStringByNode(percent, "PetEquip55", {r=0,g=0,b=0,a=255})
        else
            local purifyInfo = getEquipmentPurifyInfo(equipmentInfo, purifyLevel + 1)
            local percentNum = math.floor(purifyExp/purifyInfo.first * 100.0)
            local curPercent = bar:getPercent()
            --print("========",sz_T2S(equipmentInfo))
            --print("final data:", percentNum, curPercent, purifyExp, bar.eqID, curEqID)
            if bar.eqID==curEqID and bar.exp and curPercent~=percentNum and percentNum~=0 then
                if curPercent>percentNum then
                    bar:setPercent(0.0)
                    curPercent = 0
                end
                local expDiff = purifyExp-bar.exp
                --print("===", expDiff, purifyExp, bar.exp)
                if expDiff<0 then
                    expDiff = purifyExp
                    bar.exp = 0
                end
                local perDiff = percentNum-curPercent
                local addDiff = 0.5
                if perDiff>20 then
                	addDiff = 1
                elseif perDiff>40 then
                    addDiff = 2
                end
                local curExp = bar.exp
                CocosModuleMgr.setLoadingBarPercent(bar, percentNum, addDiff, function(p)
                    local rate = (p-curPercent)/perDiff
                    local setExp = curExp+math.floor(rate*expDiff)
                    if p==percentNum then
                    	setExp = purifyExp
                    end
                    --print("---", p, setExp, expDiff, curExp, rate)
                    CSResourceMgr.setLabelStringByNode(percent, setExp.."/"..purifyInfo.first, {r=0,g=0,b=0,a=255})
                end)
            else
                bar:setPercent(percentNum)
                CSResourceMgr.setLabelStringByNode(percent, purifyExp.."/"..purifyInfo.first, {r=0,g=0,b=0,a=255})
            end
        end
        bar.eqID = curEqID
        bar.exp = purifyExp
        
        local text = {"train11","train12","train14","train16","train15","train13",}
        local num  = {
            equipmentInfo.equips.hp or 0,
            equipmentInfo.equips.atk or 0,
            equipmentInfo.equips.satk or 0,
            equipmentInfo.equips.speed or 0,
            equipmentInfo.equips.sdef or 0,
            equipmentInfo.equips.def or 0,
        }
        local list = CSResourceMgr.getNodeByName(resName, {"frame", "bg", "equipmentSheet3", "container", "attr_list"})
        local totalAttrNum = 0
        for i=1, #num do
            if num[i] > 0 then
                totalAttrNum = totalAttrNum + 1
            end
        end
        checkPurifyAttrList(list, totalAttrNum)
        local items = list:getItems()
        for i=1, totalAttrNum do
            local item = items[i]
            local att_arrow  = CSResourceMgr.seekNodeByName(item, "att_arrow")
            local attrNameLeft  = CSResourceMgr.seekNodeByName(item, "attr_text")
            local attrNumLeft   = CSResourceMgr.seekNodeByName(item, "attr_num")
            local attrAddLeft   = CSResourceMgr.seekNodeByName(item, "attr_add_num")
            local attrNumRight  = CSResourceMgr.seekNodeByName(item, "next_attr_num")
            local attrAddRight  = CSResourceMgr.seekNodeByName(item, "next_attr_add_num")
            local background1   = CSResourceMgr.seekNodeByName(item, "att_background_1")
            local background2   = CSResourceMgr.seekNodeByName(item, "att_background_2")
            local background3   = CSResourceMgr.seekNodeByName(item, "att_background_3")
            for k, v in pairs(num) do
                if v > 0 then
                    local currentPurifyInfo = getEquipmentPurifyInfo(equipmentInfo, purifyLevel)
                    local nextPurifyInfo = getEquipmentPurifyInfo(equipmentInfo, purifyLevel + 1)
                    local currentAttrNum = v + math.floor(v*(currentPurifyInfo.second/100.0))
                    local nextAttrNum = v + math.floor(v*(nextPurifyInfo.second/100.0))
                    CSResourceMgr.setLabelStringByNode(attrNameLeft, text[k], {r=0,g=0,b=0,a=255})
                    CSResourceMgr.setLabelColorByNode(attrNameLeft, {r=254,g=243,b=57,a=255})
                    CSResourceMgr.setLabelStringByNode(attrNumLeft, currentAttrNum, {r=0,g=0,b=0,a=255})
                    if strengthenLevel == 0 then
                        CSResourceMgr.setLabelStringByNode(attrAddLeft, "+0", {r=0,g=0,b=0,a=255})
                    else
                        local info = getEquipmentStrengthenInfo(equipmentInfo, strengthenLevel)
                        CSResourceMgr.setLabelStringByNode(attrAddLeft, "+"..math.floor(currentAttrNum*(info.effect/100.0)), {r=0,g=0,b=0,a=255})
                    end
                    local width = attrAddLeft:getBoundingBox().width * 0.5
                    local addWidth = attrNumLeft:getBoundingBox().width * 0.5
                    attrNumLeft:setPositionX(background2:getPositionX() - width)
                    attrAddLeft:setPositionX(attrNumLeft:getPositionX() + addWidth)
                    if purifyLevel < curMaxLevel then
                        att_arrow:setVisible(true)
                        CSResourceMgr.setLabelStringByNode(attrNumRight, nextAttrNum, {r=0,g=0,b=0,a=255})
                        attrNumRight:setVisible(true)
                        local info = getEquipmentStrengthenInfo(equipmentInfo, strengthenLevel)
                        CSResourceMgr.setLabelStringByNode(attrAddRight, "+"..math.floor(nextAttrNum*(info.effect/100.0)), {r=0,g=0,b=0,a=255})
                        attrAddRight:setVisible(true)
                        local width = attrAddRight:getBoundingBox().width * 0.5
                        local addWidth = attrNumRight:getBoundingBox().width * 0.5
                        attrNumRight:setPositionX(background3:getPositionX() - width)
                        attrAddRight:setPositionX(attrNumRight:getPositionX() + addWidth)
                    else
                        att_arrow:setVisible(false)
                        attrNumRight:setVisible(false)
                        attrAddRight:setVisible(false)
                    end
                    num[k] = 0
                    break
                end
            end
        end
        
        local curExpMax = getEquipmentPurifyMaxExp(equipmentInfo, purifyLevel, purifyExp)
        local adaptation = CSResourceMgr.seekNodeByName(element, "adaptation")
        local exp_num = CSResourceMgr.seekNodeByName(adaptation, "exp_num")
        CSResourceMgr.setLabelStringByNode(exp_num, "", {r=0,g=0,b=0,a=255})
        for i=1, 4 do
            local itemMaterial = CSResourceMgr.seekNodeByName(adaptation, "material"..i)
            local icon = CSResourceMgr.seekNodeByName(itemMaterial, "icon")
            if icon.attrVec then
                for k=1, #icon.attrVec do
                    icon.attrVec[k]:removeFromParent(true)
                end
            end
            icon.attrVec = nil
            local num = CSResourceMgr.seekNodeByName(itemMaterial, "num")
            itemRes = "Item/ItemRare/2.png"
            CSResourceMgr.setButtonTextureByNode(itemMaterial, itemRes, itemRes, ItemInfo.getItemRareBGImage())
            CSResourceMgr.setSpriteTextureByNode(icon, "empty.png")
            num:setVisible(false)
            itemMaterial.materialInfo = nil
            CSResourceMgr.setButtonEnabledByNode(itemMaterial, purifyLevel < curMaxLevel)
            CSResourceMgr.longtouchEventBindingByNode(itemMaterial, function()
                local pickedVec = PickPurifyViewMgr.getPickedPurifyID()
                if pickedVec[i] then
                    if pickedVec[i][3] then
                        PetEquipmentOperationMgr.show(SceneMgr.getRunningScene, nil, pickedVec[i][3], "", "null")
                	end
                end
            end, function()
                local purifyStone = nil
                local purifyStoneNum = ItemInfo.getCharItemNum(SystemInfo.getGlobalConfigAddInfoByID(60001).values[3])
                if purifyStoneNum > 0 then
                    purifyStone = {SystemInfo.getGlobalConfigAddInfoByID(60001).values[3], purifyStoneNum}
                end
                
                sortPurifyMaterials(allPetUnwearEquipment)
                local allEquips = {}
                for i=1, #allPetUnwearEquipment do
                    local equipInfo = allPetUnwearEquipment[i]
                    table.insert(allEquips, {equipInfo.equips.equipID, equipInfo.equips.objID, equipInfo.equips})
                end
                
                local purifyInfo = getEquipmentPurifyInfo(equipmentInfo, purifyLevel + 1)
                PickPurifyViewMgr.show(SceneMgr.getRunningScene, purifyStone, allEquips, gatherAllMaterials(adaptation), purifyLevel < curMaxLevel and purifyInfo.first - purifyExp or nil, curExpMax, function()
                    refreshAllMaterials(adaptation, PickPurifyViewMgr.getPickedPurifyID())
                end)
            end)
        end
        local btn_purify = CSResourceMgr.seekNodeByName(adaptation, "btn_purify")
        CSResourceMgr.setButtonEnabledByNode(btn_purify, purifyLevel < curMaxLevel)
        CSResourceMgr.clickEventBindingByNode(btn_purify, function()
            local allMaterials = gatherAllMaterials(adaptation)
            if #allMaterials <= 0 then
                StandardTipsMgr.show(1, "PetEquip35")
                return
            end
            local pos = PetEquipInfo.getPetEquipInfoById(equipmentInfo.equips.equipID).pos
            local purifyStoneNum = 0
            local equips = {}
            for k, v in pairs(allMaterials) do
                if not v[3] then
                    purifyStoneNum = v[2]
                else
                    table.insert(equips, v[2])
                end
            end
            
            local petStage = CSResourceMgr.getNodeByName(resName, {"frame","bg","petStage"})
            if petStage.petInfo then
                PetEquipInfo.petEquipPurify(petStage.petInfo.objID, pos, purifyStoneNum, equips, function()
                    GameAudio.playUISound("success")
                    GameAudio.playUISound("exp")
                    local equip = getPetEquipByPos(petStage.petInfo.objID, pos)
                    local aniTime = 0.5
                    local index = 0
                    if equip then
                        local newPurifyLevel = 0
                        if equip.purify then
                            newPurifyLevel = equip.purify.level or 0
                        end
                        if newPurifyLevel > purifyLevel then
                            for i=purifyLevel+1, newPurifyLevel do
                                petStage:performWithDelay(function()
                                    playPurifyEff(i)
                                end, 0.3*index)
                                index = index+1
                            end
                        end
                    end
                    
                    CocosModuleMgr.setScreenTouch(false, "petEquipPurify")
                    local posVec = {350, 230, 110, -10}
                    local posY = 240
                    local diff = CocosModuleMgr.getScreenSizeDiff()
                    if diff>0 then
                        posY = posY+diff
                    end
                    for i=1, 4 do
                        local itemMaterial = CSResourceMgr.seekNodeByName(adaptation, "material"..i)
                        local icon = CSResourceMgr.seekNodeByName(itemMaterial, "icon")
                        local num = CSResourceMgr.seekNodeByName(itemMaterial, "num")
                        num:hide()
                        transition.moveBy(icon, {x=posVec[i], y=posY, time=aniTime})
                        transition.rotateTo(icon, {rotate=180, time=aniTime})
                        transition.scaleTo(icon, {scale=0, time=aniTime})
                    end
                    petStage:performWithDelay(function()
                        CocosModuleMgr.setScreenTouch(true, "petEquipPurify")
                        refreshAllMaterials(adaptation, {})
                        PetEquipInfo.getPetEquip()
                        updatePetAttributeData(petStage.petInfo)
                        updatePetStageFc(petStage.petInfo)
                        PickPurifyViewMgr.setPickedPurifyID({})
                    end, aniTime)
                end)
            end
        end)
        
        local btn_quick = CSResourceMgr.seekNodeByName(adaptation, "btn_quick")
        CSResourceMgr.setButtonEnabledByNode(btn_quick, purifyLevel < curMaxLevel)
        CSResourceMgr.clickEventBindingByNode(btn_quick, function()
            local allMaterials = {}
            local purifyStoneNum = ItemInfo.getCharItemNum(SystemInfo.getGlobalConfigAddInfoByID(60001).values[3])
            local needStoneNum = math.ceil(curExpMax/SystemInfo.getGlobalConfigAddInfoByID(60001).values[4])
            local remainExp = curExpMax
            if purifyStoneNum > 0 then
                if needStoneNum>purifyStoneNum then
                    remainExp = curExpMax-SystemInfo.getGlobalConfigAddInfoByID(60001).values[4]*purifyStoneNum
                	table.insert(allMaterials, {SystemInfo.getGlobalConfigAddInfoByID(60001).values[3], purifyStoneNum})
                else
                    remainExp = 0
                    table.insert(allMaterials, {SystemInfo.getGlobalConfigAddInfoByID(60001).values[3], needStoneNum})
                end
            end
            
            if remainExp>0 then
                sortPurifyMaterials(allPetUnwearEquipment)
                for i=1, #allPetUnwearEquipment do
                    local equipInfo = allPetUnwearEquipment[i]
                    local strengthenLevel = equipInfo.equips.strengthen or 0
                    local purifyLevel = 0
                    if equipInfo.equips.purify then
                        purifyLevel = equipInfo.equips.purify.level or 0
                    end
                    local quality = PetEquipInfo.getPetEquipInfoById(equipInfo.equips.equipID).quality

                    if strengthenLevel <= 0 and purifyLevel <= 0 and quality < 5 then
                        local eqExp = PetEquipInfo.getPetEquipPurifyExpInfoById(PetEquipInfo.getPetEquipInfoById(equipInfo.equips.equipID).quality).exp
                        table.insert(allMaterials, {equipInfo.equips.equipID, equipInfo.equips.objID, equipInfo.equips})
                        remainExp = remainExp-eqExp
                        if #allMaterials >= 4 or remainExp <= 0 then
                            break
                        end
                    end
                end
            end
            PickPurifyViewMgr.setPickedPurifyID(allMaterials)
            refreshAllMaterials(adaptation, allMaterials)
        end)
    end
end

local function markHookOnEquipment(hookItem)
    local node = CSResourceMgr.getNodeByName(resName, {"frame", "bg", "petEquipment"})
    for i=1, 3 do
        local item = CSResourceMgr.seekNodeByName(node, "icdb"..i)
        CSResourceMgr.seekNodeByName(item, "hook"):setVisible(item == hookItem)
    end
    
    if not hookItem then
        updateStrengthenSheet()
        updatePurifySheet()
    end
end

local function setEquipmentInfo(item, equipmentInfo)
    local itemRes = PetEquipInfo.getEquipQualityBGImage(equipmentInfo.equips.equipID)
    CSResourceMgr.setButtonTextureByNode(item, itemRes, itemRes, PetEquipInfo.getEquipQualityBGImage())
    local icon = CSResourceMgr.seekNodeByName(item, "icon")
    local iconRes = PetEquipInfo.getPetEquipInfoById(equipmentInfo.equips.equipID).icon
    CSResourceMgr.setSpriteTextureByNode(icon, iconRes)
    --local status = CSResourceMgr.seekNodeByName(item, "status")
    local num = CSResourceMgr.seekNodeByName(item, "num")
    --CSResourceMgr.setLabelStringByNode(status, "fashion13", {r=0,g=0,b=0,a=255})
    --status:setVisible(equipmentInfo.pet and true or false)
    num:hide()
    local strengthenLevel = equipmentInfo.equips.strengthen or 0
    if strengthenLevel > 0 then
        num:show()
        CSResourceMgr.setLabelStringByNode(num, "+"..strengthenLevel, {r=0,g=0,b=0,a=255})
    end
    local series = CSResourceMgr.seekNodeByName(item, "series")
    series:removeAllChildren()
    local elemAttrNum = PetEquipInfo.getPetEquipInfoById(equipmentInfo.equips.equipID).elemAttrNum
    if elemAttrNum == 9 then
        local sprite = display.newSprite("Pet/Equipment/all.png")
        sprite:setScale(0.5)
        sprite:setPosition(6, 0)
        sprite:setAnchorPoint(0.5, 0.5)
        series:addChild(sprite)
    else
        local elemAttr = equipmentInfo.equips.elemAttr or {}
        for i=1, #elemAttr do
            local tex = "UI/CommonFiles/"..elemAttr[i]..".png"
            local sprite = display.newSprite(tex)
            sprite:setScale(0.5)
            local w = sprite:getContentSize().width * 0.4
            sprite:setPosition((i-1) * w, 0)
            sprite:setAnchorPoint(0.5, 0.5)
            series:addChild(sprite)
        end
    end
    series:setVisible(true)
    
    CSResourceMgr.setButtonEnabledByNode(item, true)
    CSResourceMgr.longtouchEventBindingByNode(item, function()
        local selectedEquipmentFunc = getSelectedEquipmentFunc()
        if selectedEquipmentFunc >= 2 then
            showEquipmentInfo(item, equipmentInfo, "null")
        end
    end, function()
        local selectedEquipmentFunc = getSelectedEquipmentFunc()
        if selectedEquipmentFunc == 1 then
            showEquipmentInfo(item, equipmentInfo, false)
        elseif selectedEquipmentFunc >= 2 then
            markHookOnEquipment(item)
            updateStrengthenSheet(equipmentInfo)
            updatePurifySheet(equipmentInfo)
        end
    end)
end

local function updatePetEquipmentData(petInfo)
    --print("+++++++++++petInfo=",sz_T2S(petInfo))
    for i=1, 3 do
        local node = CSResourceMgr.getNodeByName(resName, {"frame", "bg", "petEquipment"})
        local item = CSResourceMgr.seekNodeByName(node, "icdb"..i)
        local itemRes = "Pet/Equipment/pos"..i..".png"
        CSResourceMgr.setButtonTextureByNode(item, itemRes, itemRes, itemRes)
        local icon = CSResourceMgr.seekNodeByName(item, "icon")
        CSResourceMgr.setSpriteTextureByNode(icon, "empty.png")
        CSResourceMgr.setButtonEnabledByNode(item, false)
        local series = CSResourceMgr.seekNodeByName(item, "series")
        series:setVisible(false)
    end

    isCurPetEquiped = false
    local petEquipedInfo = nil
    local isUpdateStrengthenPurifySheet = false
    local hasItemVec = {}
    for i=1, #allPetWearEquipment do
        local equipmentInfo = allPetWearEquipment[i]
        if petInfo.objID == equipmentInfo.pet.objID then
            local pos = PetEquipInfo.getPetEquipInfoById(equipmentInfo.equips.equipID).pos
            local node = CSResourceMgr.getNodeByName(resName, {"frame", "bg", "petEquipment"})
            local item = CSResourceMgr.seekNodeByName(node, "icdb"..pos)
            hasItemVec[pos] = true
            if item then
                isCurPetEquiped = true
                if petEquipedInfo==nil then
                    petEquipedInfo = {item=item, info=equipmentInfo}
                end
                setEquipmentInfo(item, equipmentInfo)
                if CSResourceMgr.seekNodeByName(item, "hook"):isVisible() then
                    updateStrengthenSheet(equipmentInfo)                
                    updatePurifySheet(equipmentInfo)
                    isUpdateStrengthenPurifySheet = true
                end
            end
        end
    end
    for i=1, 3 do
        if not hasItemVec[i] then
            local node = CSResourceMgr.getNodeByName(resName, {"frame", "bg", "petEquipment"})
            local item = CSResourceMgr.seekNodeByName(node, "icdb"..i)
            CSResourceMgr.seekNodeByName(item, "hook"):hide()
            CSResourceMgr.seekNodeByName(item, "num"):hide()
    	end
    end
    
    local list = CSResourceMgr.getNodeByName(resNameDownBar, "pet_list")
    local items = list:getItems()
    for i=1, #items do
        local item = items[i]
        if item.objID == petInfo.objID then
            local equiped = item:getChildByName("equiped")
            equiped:setVisible(isCurPetEquiped)
            break
        end
    end
    if not isCurPetEquiped then
        CSResourceMgr.callButtonFunc(resName, {"frame", "bg", "equipmentFunc", "tab1"})
    end
    
    if not isUpdateStrengthenPurifySheet then
        if petEquipedInfo then
            CSResourceMgr.seekNodeByName(petEquipedInfo.item, "hook"):show()
            updateStrengthenSheet(petEquipedInfo.info)
            updatePurifySheet(petEquipedInfo.info)
        else
            markHookOnEquipment()
        end
    end
end

local function createItemsList(funcTable, node, parent, equipmentInfo, index, size, margin)
    if not CSResourceMgr.getCsbObj(resName) then
        return
    end
    
    local item = parent:getChildren()[index]
    if not item then
        table.insert(funcTable, function()
            item = node:clone()
            item:setPositionX((index - 1)*(size.width + margin))
            item:setVisible(true)
            parent:addChild(item)
            setItemInfo(item, equipmentInfo)
        end)
    else
        setItemInfo(item, equipmentInfo)
    end
end

local function verifyListSize(parent, requireSize)
    if not CSResourceMgr.getCsbObj(resName) then
        return
    end

    local child = parent:getChildren()
    local currentSize = #child
    if currentSize > requireSize then
        for i=1, currentSize-requireSize do
            parent:removeChild(child[currentSize - i])
        end
    end
end

local function createEquipmentList(funcTable, node, parent, equipmentInfo, index, size, margin)
    if not CSResourceMgr.getCsbObj(resName) then
        return
    end
    
    local item = parent:getChildren()[index]
    if not item then
        table.insert(funcTable, function()
            item = node:clone()
            item:setPositionX((index - 1)*(size.width + margin))
            item:setVisible(true)
            parent:addChild(item)
            setEquipmentInfo(item, equipmentInfo)
        end)
    else
        setEquipmentInfo(item, equipmentInfo)
    end
end

local function initPetEquipmentList(pos)
    if not CSResourceMgr.getCsbObj(resName) then
        return
    end
    
    local currentTypePetEquipment = {}
    if pos < 4 then
        for i=1, #allPetUnwearEquipment do
            local equipmentInfo = allPetUnwearEquipment[i]
            if PetEquipInfo.getPetEquipInfoById(equipmentInfo.equips.equipID).pos == pos then
                table.insert(currentTypePetEquipment, equipmentInfo)
            end
        end
        
        --[[
        for i=1, #allPetWearEquipment do
            local equipmentInfo = allPetWearEquipment[i]
            if PetEquipInfo.getPetEquipInfoById(equipmentInfo.equips.equipID).pos == pos then
                table.insert(currentTypePetEquipment, equipmentInfo)
            end
        end
        ]]
        sortEquips(currentTypePetEquipment)
        
        local list = CSResourceMgr.getNodeByName(resName, "item_list")
        if #currentTypePetEquipment > 0 then
            local itemExample = CSResourceMgr.getNodeByName(resName,"item_listexample")
            local size = itemExample:getContentSize()
            local margin = list:getItemsMargin()
            local items = list:getItems()
            local funcTable = {}
            UnblockLoader.cancel("PetEquipmentMgr.initPetEquipmentList")
            local cell = nil
            --if #items <= 0 then
                list:removeAllItems()
                cell = itemExample:clone()
                cell:setVisible(true)
                list:pushBackCustomItem(cell)
            --else
            --    cell = items[1]
            --end
            cell:setContentSize(#currentTypePetEquipment*size.width + (#currentTypePetEquipment - 1)*margin, size.height)
            local parent = CSResourceMgr.seekNodeByName(cell, "item")
            local node = CSResourceMgr.getNodeByName(resName, {"frame", "bg", "petEquipment", "icdb_clone"})
            for i=1, #currentTypePetEquipment do
                local equipmentInfo = currentTypePetEquipment[i]
                createEquipmentList(funcTable, node, parent, equipmentInfo, i, size, margin)
            end
            verifyListSize(parent, #currentTypePetEquipment)
            UnblockLoader.load(funcTable, "PetEquipmentMgr.initPetEquipmentList")
            nothingTip:hide()
        else
            list:removeAllItems()
            nothingTip:show()
        end
    else
        for i=1, #allPetEquipment2Evaluate do
            local equipmentInfo = allPetEquipment2Evaluate[i]
            table.insert(currentTypePetEquipment, equipmentInfo)
        end
        
        sortItems(currentTypePetEquipment)
        
        local list = CSResourceMgr.getNodeByName(resName, "item_list")
        if #currentTypePetEquipment > 0 then
            local itemExample = CSResourceMgr.getNodeByName(resName,"item_listexample")
            local size = itemExample:getContentSize()
            local margin = list:getItemsMargin()
            local items = list:getItems()
            local funcTable = {}
            UnblockLoader.cancel("PetEquipmentMgr.initPetEquipmentList")
            local cell = nil
            --if #items <= 0 then
                list:removeAllItems()
                cell = itemExample:clone()
                cell:setVisible(true)
                list:pushBackCustomItem(cell)
            --else
            --    cell = items[1]
            --end
            cell:setContentSize(#currentTypePetEquipment*size.width + (#currentTypePetEquipment - 1)*margin, size.height)
            local parent = CSResourceMgr.seekNodeByName(cell, "item")
            local node = CSResourceMgr.getNodeByName(resName, {"frame", "bg", "petEquipment", "icdb_clone"})
            for i=1, #currentTypePetEquipment do
                local equipmentInfo = currentTypePetEquipment[i]
                createItemsList(funcTable, node, parent, equipmentInfo, i, size, margin)
            end
            verifyListSize(parent, #currentTypePetEquipment)
            UnblockLoader.load(funcTable, "PetEquipmentMgr.initPetEquipmentList")
            nothingTip:hide()
        else
            list:removeAllItems()
            nothingTip:show()
        end
    end
end

function PetEquipmentMgr.setPetEquipmentFromServer(petEquipment)
    petEquipmentFromServer = petEquipment or {}
    --print("==========petEquipmentFromServer=",sz_T2S(petEquipmentFromServer))
end

local function getAllPetWearEquipment()
    local allPets = PokemonInfo.getAllPets()
    allPetWearEquipment = {}
    for k, v in pairs(allPets) do
        if v.equips then
            for key, var in pairs(v.equips) do
                table.insert(allPetWearEquipment, {pet = v, equips = var})
            end
        end
    end
    
    --print("++++++++++++++allPetWearEquipment=",sz_T2S(allPetWearEquipment))
    
    local petStage = CSResourceMgr.getNodeByName(resName, {"frame","bg","petStage"})
    if petStage.petInfo then
        updatePetEquipmentData(petStage.petInfo)
    end
end

function PetEquipmentMgr.updateAllPetEquipment(updatePetEquipInfo)
    --print("++++++before updateAllPetEquipment allPetUnwearEquipment=",sz_T2S(allPetUnwearEquipment))
    local isDelete = updatePetEquipInfo.bDelete or 0
    local cjson = require("cjson")
    local updateEquipInfo = cjson.decode(updatePetEquipInfo.equipInfo)
    if isDelete == 0 or isDelete == 2 then
        for i=1, #allPetUnwearEquipment do
            if updateEquipInfo.objID == allPetUnwearEquipment[i].equips.objID then
                allPetUnwearEquipment[i].equips = updateEquipInfo
                return
            end
        end
        table.insert(allPetUnwearEquipment, {pet = nil, equips = updateEquipInfo})
        if isDelete == 2 then
            GameAudio.playUISound("petGet")
            PetEquipmentOperationMgr.show(SceneMgr.getRunningScene, nil, updateEquipInfo, "", true)
        end
    else
        for i=1, #allPetUnwearEquipment do
            local equipmentInfo = allPetUnwearEquipment[i]
            if updateEquipInfo.objID == equipmentInfo.equips.objID then
                table.remove(allPetUnwearEquipment, i)
                return
            end
        end
    end
    --print("++++++after updateAllPetEquipment allPetUnwearEquipment=",sz_T2S(allPetUnwearEquipment))
    
    --getAllPetWearEquipment()
end

function PetEquipmentMgr.getAllPetEquipment2Evaluate()
    allPetEquipment2Evaluate = {}
    
    local bagItemInfo = allPetEquipmentBag--BagViewMgr.getBagInfo()[5] or {}
    for k, v in pairs(bagItemInfo) do
        local itemType = ItemInfo.getItemInfoById(v[1]).itemType
        if itemType == Proto.IC_PETEQUIPPIECE then
            table.insert(allPetEquipment2Evaluate, {v[1], v[2]})
        end
    end

    return allPetEquipment2Evaluate
end

function PetEquipmentMgr.createAllPetEquipment()
    --[[
    --未穿戴装备信息从ntf获取
    allPetUnwearEquipment = {}
    for key, var in pairs(petEquipmentFromServer) do
        --local iteminfo = ItemInfo.getItemInfoById(key)
        table.insert(allPetUnwearEquipment, {pet = nil, equips = var})
    end]]
    
    getAllPetWearEquipment()
    
    --从背包中获取宠物未鉴定装备信息
    PetEquipmentMgr.getAllPetEquipment2Evaluate()
    --[[
    local bagItemInfo = ItemInfo.getCharItemInfo()
    --print("@@@@@@@@@@@@@bagItemInfo=",sz_T2S(bagItemInfo))
    for key, var in pairs(bagItemInfo) do
        --local iteminfo = ItemInfo.getItemInfoById(key)
        if type(var) == "number" and var > 0 then
            local itemType = ItemInfo.getItemInfoById(key).itemType
            if itemType == Proto.IC_PETEQUIPPIECE then
                table.insert(allPetEquipment2Evaluate, {key, var})
            end
        end
    end
    ]]
    --print("@@@@@@@@@@@@@allPetUnwearEquipment=",sz_T2S(allPetUnwearEquipment))
    local nodeType = CSResourceMgr.getNodeByName(resName, {"frame", "bg", "equipmentSheet1", "element", "type"})
    for pos=1, 4 do
        local tab = CSResourceMgr.seekNodeByName(nodeType, "tab"..pos)
        if tab.selected == true then
            initPetEquipmentList(pos)
            return
        end
    end 
end

local function isPetEquiped(petInfo)
    if petInfo.equips then
        if petInfo.equips["1"] or petInfo.equips["2"] or petInfo.equips["3"] then
            return true
        end
    end

    return false
end

local function setPetcard(card, petInfo, isReset)
    if isReset == true then
        local petLevel      = card:getChildByName("level")
        local diban         = card:getChildByName("diban")
        local icon          = card:getChildByName("icon")
        local rarei         = card:getChildByName("rarei")
        local attribution   = card:getChildByName("attri")
        local petBar        = card:getChildByName("bar")
        local barBK         = card:getChildByName("barBK")
        local str           = card:getChildByName("str")
        local star          = card:getChildByName("star") 
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

        rarei:setScale(0.48)

        if petInfo.hp and petInfo.hpmax then
            local cardPer = 100*petInfo.hp/petInfo.hpmax
            petBar:setPercent(cardPer) 
        end
        
        for i = 1, #(card.stars) do
            if i == 1 then
                card.stars[i]:setVisible(false)
            else
                card.stars[i]:removeFromParent()
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
                copeStar:addTo(card)
                copeStar:setPosition(x+index*starSize,starPosY) 
            end
        end
        card.stars = starTable
        
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
    end

    local status = card:getChildByName("status")
    local isInBattle = PetListMgr.isPetInBattle(petInfo) or PetListMgr.isPetInHelp(petInfo)
    if isInBattle then
        CSResourceMgr.setLabelStringByNode(status, "train68", {r=0,g=0,b=0,a=255})
        CSResourceMgr.setLabelColorByNode(status, {r=2,g=210,b=255,a=255})
        status:setVisible(true)
    else
        local isInYoke = PetListMgr.isPetInYoke(petInfo)
        if isInYoke then
            CSResourceMgr.setLabelStringByNode(status, "train173", {r=0,g=0,b=0,a=255})
            CSResourceMgr.setLabelColorByNode(status, {r=255,g=246,b=0,a=255})
            status:setVisible(true)
        else
            status:setVisible(false)
        end
    end
    local equiped = card:getChildByName("equiped")
    equiped:setVisible(isPetEquiped(petInfo))
    card.objID = petInfo.objID
    --nodeCard:addChild(card.button)
    CSResourceMgr.clickEventBindingByNode(card, function()
        local petStage = CSResourceMgr.getNodeByName(resName, {"frame","bg","petStage"})
        if not petStage.petInfo or petStage.petInfo.objID ~= petInfo.objID then
            updatePetStage(petInfo)
            updatePetAttributeData(petInfo)
            --markHookOnEquipment()
            updatePetEquipmentData(petInfo)
        end
        if not isPetEquiped(PokemonInfo.getPetInfoByObjID(petInfo.objID)) then
        	--判断分页是否归1
            CSResourceMgr.callButtonFunc(resName, {"frame", "bg", "equipmentFunc", "tab1"})
        end
    end, 1)
end

local function initPetList()
    local list = CSResourceMgr.getNodeByName(resNameDownBar, "pet_list")
    list:removeAllItems()
    local funcTable = {}
    local allPets = PetListMgr.sortPetList(PokemonInfo.getAllPets(true))
    local allPetsNum = #allPets
    if allPetsNum > 0 then
        --local cell = CSResourceMgr.getNodeByName(resNameDownBar,"pet_listexample")
        --local nodeCard = CSResourceMgr.seekNodeByName(cell, "card")
        --local size = cell:getContentSize()
        local margin = list:getItemsMargin()
        --cell:setContentSize(allPetsNum*size.width + (allPetsNum - 1)*margin, size.height)
        local showCount = math.min(8, allPetsNum)
        for i=1, showCount do
            table.insert(funcTable, function()
                local petInfo = allPets[i]
                --local returnObjectArray = ObjectPool.getObjectFromPool("PetEquipmentMgr.petcard", 1)
                --local object = returnObjectArray[1]
                local card = BattleFuncMgr.startCreatePetCard(petInfo, 3, true)
                --card.button:setPositionX((i - 1)*(size.width + margin))
                --card.button.parent = card
                setPetcard(card.button, petInfo, false)
                list:pushBackCustomItem(card.button)
                if i == showCount then
                    BattleFuncMgr.endCreatePetCard()
                    HighPerformList.makeHighPerFormHorizontalList(list, 8, margin, 1, 110, 92, allPets, function(item, currentIndex)
                        --print("%%%%%%%%%%%%%item, currentIndex=",item, currentIndex)
                        setPetcard(item, allPets[currentIndex], true)
                    end)
                end
            end)
        end
        --cell:setVisible(true)
        --list:pushBackCustomItem(cell)
    end
    UnblockLoader.load(funcTable, "PetEquipmentMgr.initPetList")
    
    CSResourceMgr.getNodeByName(resName, {"frame","bg","petStage"}):setVisible(allPetsNum > 0)
    if allPetsNum > 0 then
        updatePetStage(allPets[1])
        updatePetAttributeData(allPets[1])
    end
end

local function reSize(reSizeTable, diff)
    for i= 1,#reSizeTable do
        local reSizeCell = reSizeTable[i]
        local size = reSizeCell:getContentSize()
        reSizeCell:setContentSize(size.width, size.height+diff)
    end
end

local function setPosY(setPosYTable, diff)
    for i= 1,#setPosYTable do
        local setPosYCell = setPosYTable[i]
        local posY = setPosYCell:getPositionY()
        setPosYCell:setPositionY(posY+diff)
    end
end

local function setPosYEx(setPosYTable, diff)
    for i= 1,#setPosYTable do
        local setPosYCell = setPosYTable[i]
        local posY = setPosYCell:getPositionY()
        setPosYCell:setPositionY(posY-diff)
    end
end

--根据屏幕适配尺寸
local function adaptation()
    local diff = CocosModuleMgr.getScreenSizeDiff()
    
    local reSizeTable = {}
    table.insert(reSizeTable, CSResourceMgr.getNodeByName(resName, "frame"))
    table.insert(reSizeTable, CSResourceMgr.getNodeByName(resName, {"frame", "bg"}))
    --table.insert(reSizeTable, CSResourceMgr.getNodeByName(resName, {"frame", "bg", "pet_list"}))
    table.insert(reSizeTable, CSResourceMgr.getNodeByName(resName, {"frame", "bg", "equipmentSheet1", "container", "bg"}))
    table.insert(reSizeTable, CSResourceMgr.getNodeByName(resName, {"frame", "bg", "equipmentSheet1", "container", "attr_list"}))
    
    table.insert(reSizeTable, CSResourceMgr.getNodeByName(resName, {"frame", "bg", "equipmentSheet2", "container", "bg"}))
    table.insert(reSizeTable, CSResourceMgr.getNodeByName(resName, {"frame", "bg", "equipmentSheet2", "container", "attr_list"}))
    reSize(reSizeTable, diff)
    
    local setPosYTable = {}
    table.insert(setPosYTable, CSResourceMgr.getNodeByName(resName, {"frame", "bg", "title"}))
    table.insert(setPosYTable, CSResourceMgr.getNodeByName(resName, {"frame", "bg", "petStage"}))
    table.insert(setPosYTable, CSResourceMgr.getNodeByName(resName, {"frame", "bg", "petEquipment"}))
    table.insert(setPosYTable, CSResourceMgr.getNodeByName(resName, {"frame", "bg", "equipmentFunc"}))
    table.insert(setPosYTable, CSResourceMgr.getNodeByName(resName, {"frame", "bg", "equipmentSheet1", "element", "main_attr"}))
    table.insert(setPosYTable, CSResourceMgr.getNodeByName(resName, {"frame", "bg", "equipmentSheet1", "element", "sub_attr"}))
    table.insert(setPosYTable, CSResourceMgr.getNodeByName(resName, {"frame", "bg", "equipmentSheet2", "element", "current_attr"}))
    table.insert(setPosYTable, CSResourceMgr.getNodeByName(resName, {"frame", "bg", "equipmentSheet2", "element", "item"}))
    table.insert(setPosYTable, CSResourceMgr.getNodeByName(resName, {"frame", "bg", "equipmentSheet2", "element", "name"}))
    table.insert(setPosYTable, CSResourceMgr.getNodeByName(resName, {"frame", "bg", "equipmentSheet2", "element", "pos"}))
    table.insert(setPosYTable, CSResourceMgr.getNodeByName(resName, {"frame", "bg", "equipmentSheet2", "element", "series"}))
    setPosY(setPosYTable, diff)
end

local function adaptationEx()
    local diff = CocosModuleMgr.getScreenSizeDiff()
    if diff > 0 then
        local reSizeTable = {}
        --sheet1
        table.insert(reSizeTable, CSResourceMgr.getNodeByName(resName, {"frame", "bg", "equipmentSheet1", "container", "bg"}))
        table.insert(reSizeTable, CSResourceMgr.getNodeByName(resName, {"frame", "bg", "equipmentSheet1", "container", "attr_list"}))
        --sheet2
        table.insert(reSizeTable, CSResourceMgr.getNodeByName(resName, {"frame", "bg", "equipmentSheet2", "container", "bg"}))
        table.insert(reSizeTable, CSResourceMgr.getNodeByName(resName, {"frame", "bg", "equipmentSheet2", "container", "attr_list"}))
        --sheet3
        table.insert(reSizeTable, CSResourceMgr.getNodeByName(resName, {"frame", "bg", "equipmentSheet3", "container", "bg"}))
        table.insert(reSizeTable, CSResourceMgr.getNodeByName(resName, {"frame", "bg", "equipmentSheet3", "container", "attr_list"}))
        reSize(reSizeTable, diff)
        
        local setPosYTable = {}
        --sheet1
        table.insert(setPosYTable, CSResourceMgr.getNodeByName(resName, {"frame", "bg", "equipmentSheet1", "container", "item_list"}))
        table.insert(setPosYTable, CSResourceMgr.getNodeByName(resName, {"frame", "bg", "equipmentSheet1", "element", "type"}))
        table.insert(setPosYTable, CSResourceMgr.getNodeByName(resName, {"frame", "bg", "equipmentSheet1", "element", "line"}))
        --sheet2
        table.insert(setPosYTable, CSResourceMgr.getNodeByName(resName, {"frame", "bg", "equipmentSheet2", "element", "adaptation"}))
        --sheet3
        table.insert(setPosYTable, CSResourceMgr.getNodeByName(resName, {"frame", "bg", "equipmentSheet3", "element", "adaptation"}))
        setPosYEx(setPosYTable, diff)
    end
end

function PetEquipmentMgr.hideUI()
    GameAudio.playUISound("retract")
    UnblockLoader.cancel("PetEquipmentMgr.initPetList")
    UnblockLoader.cancel("PetEquipmentMgr.initPetEquipmentList")
    StatusBarMgr.hideTopInfoBar()
    CSResourceMgr.removeCSObjectByTag(resName)
    CSResourceMgr.removeCSObjectByTag(resNameDownBar)
    CSResourceMgr.removeCSObjectByTag(resNameBG, "PetEquipmentMgr")
    UIStack.pop("PetEquipmentMgr")
    HighPerformList.resetAllSchedule()
    SceneMgr.setMapVisible(true)
end

local function initStaticData()
    --sheet1
    CSResourceMgr.setLabelString(resName, {"frame","bg","title"}, "PetEquip1", nil, {r=0,g=0,b=0,a=255,w=1})
    
    local tabFunc1 = CSResourceMgr.getNodeByName(resName, {"frame", "bg", "equipmentFunc", "tab1"})
    CSResourceMgr.setButtonStringByNode(tabFunc1, "PetEquip2", {r=0,g=0,b=0,a=255,w=1})
    tabFunc1:setScale(1.1,1.1)
    local tabFunc2 = CSResourceMgr.getNodeByName(resName, {"frame", "bg", "equipmentFunc", "tab2"})
    CSResourceMgr.setButtonStringByNode(tabFunc2, "PetEquip3", {r=0,g=0,b=0,a=255,w=1})
    local tabFunc3 = CSResourceMgr.getNodeByName(resName, {"frame", "bg", "equipmentFunc", "tab3"})
    CSResourceMgr.setButtonStringByNode(tabFunc3, "PetEquip4", {r=0,g=0,b=0,a=255,w=1})
    local tabFunc4 = CSResourceMgr.getNodeByName(resName, {"frame", "bg", "equipmentFunc", "tab4"})
    CSResourceMgr.setButtonStringByNode(tabFunc4, "PetEquip5", {r=0,g=0,b=0,a=255,w=1})
    
    local function setHook(boolVisible)
        for i=1, 3 do
            local item = CSResourceMgr.seekNodeByName(CSResourceMgr.getNodeByName(resName, {"frame", "bg", "petEquipment"}), "icdb"..i)
            local hook = CSResourceMgr.seekNodeByName(item, "hook")
            if boolVisible then
            	hook:setOpacity(255)
            else
                hook:setOpacity(0)
            end
        end
    end
    setHook(false)
    
    CSResourceMgr.clickEventBinding(resName, {"frame", "bg", "equipmentFunc", "tab1"}, function()
        CSResourceMgr.setButtonTextureByNode(tabFunc1, tabFuncTex[2], tabFuncTex[2], tabFuncTex[2])
        tabFunc1:setScale(1.1,1.1)
        tabFunc1:setLocalZOrder(-1)
        CSResourceMgr.setButtonTextureByNode(tabFunc2, tabFuncTex[1], tabFuncTex[2], tabFuncTex[1])
        tabFunc2:setScale(1.0,1.0)
        tabFunc2:setLocalZOrder(-2)
        CSResourceMgr.setButtonTextureByNode(tabFunc3, tabFuncTex[1], tabFuncTex[2], tabFuncTex[1])
        tabFunc3:setScale(1.0,1.0)
        tabFunc3:setLocalZOrder(-3)
        CSResourceMgr.setButtonTextureByNode(tabFunc4, tabFuncTex[1], tabFuncTex[2], tabFuncTex[1])
        tabFunc4:setScale(1.0,1.0)
        tabFunc4:setLocalZOrder(-4)
        
        setHook(false)
        
        CSResourceMgr.getNodeByName(resName, {"frame", "bg", "equipmentSheet1"}):setVisible(true)
        CSResourceMgr.getNodeByName(resName, {"frame", "bg", "equipmentSheet2"}):setVisible(false)
        CSResourceMgr.getNodeByName(resName, {"frame", "bg", "equipmentSheet3"}):setVisible(false)
    end)
    
    CSResourceMgr.clickEventBinding(resName, {"frame", "bg", "equipmentFunc", "tab2"}, function()
        if not isCurPetEquiped then
            StandardTipsMgr.show(1, "PetEquip38")
        	return
        end
        CSResourceMgr.setButtonTextureByNode(tabFunc1, tabFuncTex[1], tabFuncTex[2], tabFuncTex[1])
        tabFunc1:setScale(1.0,1.0)
        tabFunc1:setLocalZOrder(-2)
        CSResourceMgr.setButtonTextureByNode(tabFunc2, tabFuncTex[2], tabFuncTex[2], tabFuncTex[2])
        tabFunc2:setScale(1.1,1.1)
        tabFunc2:setLocalZOrder(-1)
        CSResourceMgr.setButtonTextureByNode(tabFunc3, tabFuncTex[1], tabFuncTex[2], tabFuncTex[1])
        tabFunc3:setScale(1.0,1.0)
        tabFunc3:setLocalZOrder(-3)
        CSResourceMgr.setButtonTextureByNode(tabFunc4, tabFuncTex[1], tabFuncTex[2], tabFuncTex[1])
        tabFunc4:setScale(1.0,1.0)
        tabFunc4:setLocalZOrder(-4)
        
        setHook(true)
        
        CSResourceMgr.getNodeByName(resName, {"frame", "bg", "equipmentSheet1"}):setVisible(false)
        CSResourceMgr.getNodeByName(resName, {"frame", "bg", "equipmentSheet2"}):setVisible(true)
        CSResourceMgr.getNodeByName(resName, {"frame", "bg", "equipmentSheet3"}):setVisible(false)
    end)
    
    CSResourceMgr.clickEventBinding(resName, {"frame", "bg", "equipmentFunc", "tab3"}, function()
        if not isCurPetEquiped then
            StandardTipsMgr.show(1, "PetEquip38")
            return
        end
        CSResourceMgr.setButtonTextureByNode(tabFunc1, tabFuncTex[1], tabFuncTex[2], tabFuncTex[1])
        tabFunc1:setScale(1.0,1.0)
        tabFunc1:setLocalZOrder(-2)
        CSResourceMgr.setButtonTextureByNode(tabFunc2, tabFuncTex[1], tabFuncTex[2], tabFuncTex[1])
        tabFunc2:setScale(1.0,1.0)
        tabFunc2:setLocalZOrder(-3)
        CSResourceMgr.setButtonTextureByNode(tabFunc3, tabFuncTex[2], tabFuncTex[2], tabFuncTex[2])
        tabFunc3:setScale(1.1,1.1)
        tabFunc3:setLocalZOrder(-1)
        CSResourceMgr.setButtonTextureByNode(tabFunc4, tabFuncTex[1], tabFuncTex[2], tabFuncTex[1])
        tabFunc4:setScale(1.0,1.0)
        tabFunc4:setLocalZOrder(-4)
        
        setHook(true)
        
        CSResourceMgr.getNodeByName(resName, {"frame", "bg", "equipmentSheet1"}):setVisible(false)
        CSResourceMgr.getNodeByName(resName, {"frame", "bg", "equipmentSheet2"}):setVisible(false)
        CSResourceMgr.getNodeByName(resName, {"frame", "bg", "equipmentSheet3"}):setVisible(true)
    end)
    
    CSResourceMgr.clickEventBinding(resName, {"frame", "bg", "equipmentFunc", "tab4"}, function()
        if not isCurPetEquiped then
            StandardTipsMgr.show(1, "PetEquip38")
            return
        end
        CSResourceMgr.setButtonTextureByNode(tabFunc1, tabFuncTex[1], tabFuncTex[2], tabFuncTex[1])
        tabFunc1:setScale(1.0,1.0)
        tabFunc1:setLocalZOrder(-2)
        CSResourceMgr.setButtonTextureByNode(tabFunc2, tabFuncTex[1], tabFuncTex[2], tabFuncTex[1])
        tabFunc2:setScale(1.0,1.0)
        tabFunc2:setLocalZOrder(-3)
        CSResourceMgr.setButtonTextureByNode(tabFunc3, tabFuncTex[1], tabFuncTex[2], tabFuncTex[1])
        tabFunc3:setScale(1.0,1.0)
        tabFunc3:setLocalZOrder(-4)
        CSResourceMgr.setButtonTextureByNode(tabFunc4, tabFuncTex[2], tabFuncTex[2], tabFuncTex[2])
        tabFunc4:setScale(1.1,1.1)
        tabFunc4:setLocalZOrder(-1)
        
        setHook(true)
    end)
    
    CSResourceMgr.setLabelString(resName, {"frame", "bg", "equipmentSheet1", "element", "main_attr", "txt"}, "PetEquip11", nil, {r=0,g=0,b=0,a=255,w=1})
    CSResourceMgr.setLabelString(resName, {"frame", "bg", "equipmentSheet1", "element", "sub_attr", "txt"}, "PetEquip12", nil, {r=0,g=0,b=0,a=255,w=1})
    
    local tabType1 = CSResourceMgr.getNodeByName(resName, {"frame", "bg", "equipmentSheet1", "element", "type", "tab1"})
    CSResourceMgr.setButtonStringByNode(tabType1, "PetEquip6", {r=0,g=0,b=0,a=255,w=1})
    tabType1.selected = true
    local tabType2 = CSResourceMgr.getNodeByName(resName, {"frame", "bg", "equipmentSheet1", "element", "type", "tab2"})
    CSResourceMgr.setButtonStringByNode(tabType2, "PetEquip7", {r=0,g=0,b=0,a=255,w=1})
    local tabType3 = CSResourceMgr.getNodeByName(resName, {"frame", "bg", "equipmentSheet1", "element", "type", "tab3"})
    CSResourceMgr.setButtonStringByNode(tabType3, "PetEquip8", {r=0,g=0,b=0,a=255,w=1})
    local tabType4 = CSResourceMgr.getNodeByName(resName, {"frame", "bg", "equipmentSheet1", "element", "type", "tab4"})
    CSResourceMgr.setButtonStringByNode(tabType4, "PetEquip9", {r=0,g=0,b=0,a=255,w=1})
    
    CSResourceMgr.clickEventBindingByNode(tabType1, function()
        if not tabType1.selected then
            CSResourceMgr.setButtonTextureByNode(tabType1, tabTypeTex[2], tabTypeTex[2], tabTypeTex[2])
            CSResourceMgr.setButtonTextureByNode(tabType2, tabTypeTex[1], tabTypeTex[2], tabTypeTex[1])
            CSResourceMgr.setButtonTextureByNode(tabType3, tabTypeTex[1], tabTypeTex[2], tabTypeTex[1])
            CSResourceMgr.setButtonTextureByNode(tabType4, tabTypeTex[1], tabTypeTex[2], tabTypeTex[1])
            
            initPetEquipmentList(1)
            
            tabType1.selected = true
            tabType2.selected = false
            tabType3.selected = false
            tabType4.selected = false
        end
    end)
    
    CSResourceMgr.clickEventBindingByNode(tabType2, function()
        if not tabType2.selected then
            CSResourceMgr.setButtonTextureByNode(tabType1, tabTypeTex[1], tabTypeTex[2], tabTypeTex[1])
            CSResourceMgr.setButtonTextureByNode(tabType2, tabTypeTex[2], tabTypeTex[2], tabTypeTex[2])
            CSResourceMgr.setButtonTextureByNode(tabType3, tabTypeTex[1], tabTypeTex[2], tabTypeTex[1])
            CSResourceMgr.setButtonTextureByNode(tabType4, tabTypeTex[1], tabTypeTex[2], tabTypeTex[1])
            
            initPetEquipmentList(2)
            
            tabType1.selected = false
            tabType2.selected = true
            tabType3.selected = false
            tabType4.selected = false
        end
    end)
        
    CSResourceMgr.clickEventBindingByNode(tabType3, function()
        if not tabType3.selected then
            CSResourceMgr.setButtonTextureByNode(tabType1, tabTypeTex[1], tabTypeTex[2], tabTypeTex[1])
            CSResourceMgr.setButtonTextureByNode(tabType2, tabTypeTex[1], tabTypeTex[2], tabTypeTex[1])
            CSResourceMgr.setButtonTextureByNode(tabType3, tabTypeTex[2], tabTypeTex[2], tabTypeTex[2])
            CSResourceMgr.setButtonTextureByNode(tabType4, tabTypeTex[1], tabTypeTex[2], tabTypeTex[1])
            
            initPetEquipmentList(3)
            
            tabType1.selected = false
            tabType2.selected = false
            tabType3.selected = true
            tabType4.selected = false
        end
    end)
        
    CSResourceMgr.clickEventBindingByNode(tabType4, function()
        if not tabType4.selected then
            CSResourceMgr.setButtonTextureByNode(tabType1, tabTypeTex[1], tabTypeTex[2], tabTypeTex[1])
            CSResourceMgr.setButtonTextureByNode(tabType2, tabTypeTex[1], tabTypeTex[2], tabTypeTex[1])
            CSResourceMgr.setButtonTextureByNode(tabType3, tabTypeTex[1], tabTypeTex[2], tabTypeTex[1])
            CSResourceMgr.setButtonTextureByNode(tabType4, tabTypeTex[2], tabTypeTex[2], tabTypeTex[2])
            
            initPetEquipmentList(4)
            
            tabType1.selected = false
            tabType2.selected = false
            tabType3.selected = false
            tabType4.selected = true
        end
    end)
    
    CSResourceMgr.setLabelString(resNameDownBar, {"frame", "tip"}, "PetEquip10", nil, {r=0,g=0,b=0,a=255,w=1})
    --sheet1
    local diff = CocosModuleMgr.getScreenSizeDiff()
    local posY = -270
    if diff>0 then
        posY = posY-diff
    end
    nothingTip = CSResourceMgr.getNodeByName(resNameDownBar, {"frame", "tip"}):clone()
    nothingTip:addTo(CSResourceMgr.getNodeByName(resName, {"frame", "bg", "equipmentSheet1", "container"}))
    nothingTip:pos(215, posY)
    nothingTip:hide()
    CSResourceMgr.setLabelStringByNode(nothingTip, "PetEquip53", {r=0,g=0,b=0,a=255,w=1}, nil, 300)
    CSResourceMgr.setLabelColorByNode(nothingTip, {r=188,g=188,b=188,a=255})
    --sheet2
    --CSResourceMgr.setLabelString(resName, {"frame", "bg", "equipmentSheet2", "element", "pos"}, "PetEquip21", nil, {r=0,g=0,b=0,a=255,w=1})
    CSResourceMgr.setLabelString(resName, {"frame", "bg", "equipmentSheet2", "element", "series"}, "PetEquip22", nil, {r=0,g=0,b=0,a=255,w=1})
    CSResourceMgr.setLabelString(resName, {"frame", "bg", "equipmentSheet2", "element", "current_attr", "txt"}, "PetEquip34", nil, {r=0,g=0,b=0,a=255,w=1})
    CSResourceMgr.setLabelString(resName, {"frame", "bg", "equipmentSheet2", "element", "adaptation", "effect"}, "PetEquip24", nil, {r=0,g=0,b=0,a=255,w=1})
    CSResourceMgr.setLabelString(resName, {"frame", "bg", "equipmentSheet2", "element", "adaptation", "cost"}, "PetEquip25", nil, {r=0,g=0,b=0,a=255,w=1})
    CSResourceMgr.setLabelString(resName, {"frame", "bg", "equipmentSheet2", "element", "adaptation", "rate"}, "PetEquip26", nil, {r=0,g=0,b=0,a=255,w=1})
    CSResourceMgr.setLabelString(resName, {"frame", "bg", "equipmentSheet2", "element", "adaptation", "stone", "click"}, "PetEquip27", nil, {r=0,g=0,b=0,a=255,w=1})
    local btn_strengthen = CSResourceMgr.getNodeByName(resName, {"frame", "bg", "equipmentSheet2", "element", "adaptation", "btn_strengthen"})
    CSResourceMgr.setButtonStringByNode(btn_strengthen, "PetEquip3", {r=0,g=0,b=0,a=255})
    CSResourceMgr.setButtonEnabledByNode(btn_strengthen, false)
    local stoneItemID = SystemInfo.getGlobalConfigAddInfoByID(60001).values[2]
    local iconRes = ItemInfo.getItemInfoById(stoneItemID).icon
    CSResourceMgr.setSpriteTexture(resName, {"frame", "bg", "equipmentSheet2", "element", "adaptation", "icon_stone"}, iconRes)
    CSResourceMgr.setButtonEnabled(resName, {"frame", "bg", "equipmentSheet2", "element", "adaptation", "stone"}, false)
    setItemButtonEvent(CSResourceMgr.getNodeByName(resName, {"frame", "bg", "equipmentSheet2", "element", "adaptation", "btn_stone"}), stoneItemID)
    setItemButtonEvent(CSResourceMgr.getNodeByName(resName, {"frame", "bg", "equipmentSheet2", "element", "adaptation", "btn_money"}), 9998)
    --sheet3
    CSResourceMgr.setLabelString(resName, {"frame", "bg", "equipmentSheet3", "element", "series"}, "PetEquip22", nil, {r=0,g=0,b=0,a=255,w=1})
    CSResourceMgr.setLabelString(resName, {"frame", "bg", "equipmentSheet3", "element", "effect"}, "PetEquip29", nil, {r=0,g=0,b=0,a=255,w=1})
    CSResourceMgr.setLabelString(resName, {"frame", "bg", "equipmentSheet3", "element", "purify_effect", "txt"}, "PetEquip30", nil, {r=0,g=0,b=0,a=255,w=1})
    CSResourceMgr.setLabelString(resName, {"frame", "bg", "equipmentSheet3", "element", "adaptation", "purify_material", "txt"}, "PetEquip31", nil, {r=0,g=0,b=0,a=255,w=1})
    CSResourceMgr.setLabelString(resName, {"frame", "bg", "equipmentSheet3", "element", "adaptation", "add_exp"}, "PetEquip33", nil, {r=0,g=0,b=0,a=255,w=1})
    local btn_purify = CSResourceMgr.getNodeByName(resName, {"frame", "bg", "equipmentSheet3", "element", "adaptation", "btn_purify"})
    CSResourceMgr.setButtonStringByNode(btn_purify, "PetEquip4", {r=0,g=0,b=0,a=255})
    CSResourceMgr.setButtonEnabledByNode(btn_purify, false)
    local btn_quick = CSResourceMgr.getNodeByName(resName, {"frame", "bg", "equipmentSheet3", "element", "adaptation", "btn_quick"})
    CSResourceMgr.setButtonStringByNode(btn_quick, "PetEquip32", {r=0,g=0,b=0,a=255})
    CSResourceMgr.setButtonEnabledByNode(btn_quick, false)
end

function PetEquipmentMgr.show(scene)
    if CSResourceMgr.getCsbObj(resName) then
        return  
    end
    
    GameAudio.playUISound("popup")
    UIStack.push("PetEquipmentMgr",PetEquipmentMgr.hideUI,true)
    local function loadBG()
        local bgLayer = CSResourceMgr.createRes(scene, resNameBG, "PetEquipmentMgr")
        bgLayer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resNameBG, 320, 480, "PetEquipmentMgr")
        bgLayer:setOpacity(0)
        transition.fadeIn(bgLayer, {time=0.3})
    end
    
    local function loadCSB()
        local curLayer = CSResourceMgr.createRes(scene, resName)
        curLayer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setFullScreen(resName)
        CocosModuleMgr.setEdgeDistance(curLayer, nil, nil, 0, nil)
        CSResourceMgr.getNodeByName(resName, "frame"):setVisible(false)
        
        curLayer = CSResourceMgr.createRes(scene, resNameDownBar)
        curLayer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setFullScreen(resNameDownBar)
        CocosModuleMgr.setEdgeDistance(curLayer, nil, nil, nil, -10)
        CSResourceMgr.getNodeByName(resNameDownBar, "frame"):setVisible(false)
        
        --adaptation()
        
        adaptationEx()
        
        initStaticData()
        
        initPetList()
    end
    
    local function playCSB()
        local node = CSResourceMgr.getNodeByName(resName, "frame")
        if node ~= nil then
            node:setVisible(true)
            CocosModuleMgr.showUIAnimation(node, "down")
        end
        
        node = CSResourceMgr.getNodeByName(resNameDownBar, "frame")
        if node ~= nil then
            node:setVisible(true)
            CocosModuleMgr.showUIAnimation(node, "up")
        end
        
        StatusBarMgr.showTopInfoBar(function()
            PetEquipmentMgr.hideUI()
        end)
    end
    
    loadBG()
    loadCSB()
    playCSB()
    
    SceneMgr.setMapVisible(false)
    
    --PetEquipmentMgr.createAllPetEquipment()
    PetEquipInfo.getPetEquip()
end


---添加装备进装备背包
--@param equipitemid 装备id
--@param equipitemnum 装备数量
--@return result bool 如果添加成功，返回true，添加失败,返回false
function PetEquipmentMgr.addPetEquipment(equipitemid,equipitemnum)
    
    local itemtype = ItemInfo.getItemInfoById(equipitemid).itemType
    print("PetEquipmentMgr.addPetEquipment itemtype is......................",itemtype,equipitemid,equipitemnum)
    if itemtype ~= Proto.IC_PETEQUIPPIECE then 
        return false
    end
    local needInsertTable = true
    for i=1,#allPetEquipmentBag do 
        if allPetEquipmentBag[i][1] == equipitemid then
            if equipitemnum > 0 then
                allPetEquipmentBag[i][2] = equipitemnum
            else
                table.remove(allPetEquipmentBag, i)
            end
            needInsertTable = false
            break
        end
    end

    if needInsertTable and equipitemnum > 0 then 
        table.insert(allPetEquipmentBag,{equipitemid,equipitemnum})
    end

    return true;
end

function PetEquipmentMgr.calcAllAttr(petInfo)
    local calcAttr = {}
    for i=Proto.PEET_HP, PetEquipInfo.ATTR_NUM do
        calcAttr[i] = 0
    end
    
    if petInfo and petInfo.equips then
        for key, val in pairs(petInfo.equips) do
            local numBase = {
                val.hp or 0,
                val.atk or 0,
                val.def or 0,
                val.satk or 0,
                val.sdef or 0,
                val.speed or 0,
            }
            local strengthenLevel = val.strengthen or 0
            local purifyLevel = 0
            if val.purify then
                purifyLevel = val.purify.level or 0
            end
            local purifyInfo = getEquipmentPurifyInfo({equips = val}, purifyLevel)
            local strengthenInfo = getEquipmentStrengthenInfo({equips = val}, strengthenLevel)
            
            local numAfter = {}
            --if purifyLevel > 0 then
                for k, v in pairs(numBase) do
                    if v > 0 then
                        numAfter[k] = v + math.floor(v*(purifyInfo.second/100.0))
                    else
                        numAfter[k] = v
                    end
                end
            --end         
            if strengthenLevel > 0 then
                for k, v in pairs(numAfter) do
                    if v > 0 then
                        numAfter[k] = v + math.floor(v*(strengthenInfo.effect/100.0))
                    end
                end
            end          
            for k, v in pairs(numAfter) do
                calcAttr[Proto.PEET_HP + k - 1] = calcAttr[Proto.PEET_HP + k - 1] + v
            end
            
            if val.effects then
                for i=1, MAX_STRENGTHEN_LEVEL do
                    local effect = val.effects[tostring(i)]
                    if effect and i <= strengthenLevel then
                        local effectInfo = PetEquipInfo.getPetEquipEffectInfoById(effect.ID)
                        calcAttr[Proto.PEET_NONE + effectInfo.type] = calcAttr[Proto.PEET_NONE + effectInfo.type] + (effect.value or 0)
                    end
                end
            end
        end
    end
    
    return calcAttr
end

function PetEquipmentMgr.calcAllAttrByObjID(objID)
    return PetEquipmentMgr.calcAllAttr(PokemonInfo.getPetInfoByObjID(objID))
end

function PetEquipmentMgr.getAllPetUnwearEquipment()
    return allPetUnwearEquipment
end

function PetEquipmentMgr.isPetEquiped(petInfo)
	return isPetEquiped(petInfo)
end

return PetEquipmentMgr