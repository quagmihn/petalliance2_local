local PetEquipmentOperationMgr = {}

local resName = ""
local MAX_STRENGTHEN_LEVEL = 10
local MAX_PURIFY_LEVEL = 10

function PetEquipmentOperationMgr.Init()
    resName = "Pet/Equipment/PetEquipmentOperation.csb"
    MAX_STRENGTHEN_LEVEL = 10
    MAX_PURIFY_LEVEL = 10
end

function PetEquipmentOperationMgr.hideUI()
    UnblockLoader.cancel("PetEquipmentOperationMgr.show")
    CSResourceMgr.removeCSObjectByTag(resName)
    UIStack.pop("PetEquipmentOperationMgr")
end

local function initStaticData(operationTxt, isTip)
    CSResourceMgr.setLabelString(resName, {"db","txt_title"}, "PetEquip48", nil, {r=0,g=0,b=0,a=255,w=1})
    CSResourceMgr.setLabelString(resName, {"db", "series"}, "PetEquip22", nil, {r=0,g=0,b=0,a=255,w=1})
    local btnOperation = CSResourceMgr.getNodeByName(resName, {"db", "btn_operation"})
    btnOperation:setVisible(not isTip)
    local btnRestore = CSResourceMgr.getNodeByName(resName, {"db", "btn_restore"})
    btnRestore:setVisible(not isTip)
    if not isTip then
        CSResourceMgr.setButtonStringByNode(btnOperation, operationTxt, {r=0,g=0,b=0,a=255})
        CSResourceMgr.setButtonStringByNode(btnRestore, "PetEquip20", {r=0,g=0,b=0,a=255})
    end
    CSResourceMgr.setLabelString(resName, {"db","base_attr","txt"}, "PetEquip44", nil, {r=0,g=0,b=0,a=255,w=1})
    CSResourceMgr.setLabelString(resName, {"db","purify_level","txt"}, "PetEquip45", nil, {r=0,g=0,b=0,a=255,w=1})
    CSResourceMgr.setLabelString(resName, {"db","strengthen_effect","txt"}, "PetEquip46", nil, {r=0,g=0,b=0,a=255,w=1})
end

local function getEquipmentStrengthenInfo(equipInfo, strengthenLevel)
    if strengthenLevel <= 0 then
        return {rate = 100, itemCost = 0, moneyCost = 0, effect = 0}
    elseif strengthenLevel > MAX_STRENGTHEN_LEVEL then
        strengthenLevel = MAX_STRENGTHEN_LEVEL
    end
    local quality = PetEquipInfo.getPetEquipInfoById(equipInfo.equipID).quality
    return PetEquipInfo.getPetEquipStrengthenInfoById(quality).infos[strengthenLevel]
end

local function getEquipmentPurifyInfo(equipInfo, purifyLevel)
    if purifyLevel <= 0 then
        return {first = 0, second = 0}
    elseif purifyLevel > MAX_PURIFY_LEVEL then
        purifyLevel = MAX_PURIFY_LEVEL
    end
    local quality = PetEquipInfo.getPetEquipInfoById(equipInfo.equipID).quality
    return PetEquipInfo.getPetEquipPurifyInfoById(quality).expAndpercents[purifyLevel]
end

local function initDynamicData(equipInfo, funcTable)
    local strengthenLevel = equipInfo.strengthen or 0
    local purifyLevel = 0
    if equipInfo.purify then
        purifyLevel = equipInfo.purify.level or 0
    end
    local purifyInfo = getEquipmentPurifyInfo(equipInfo, purifyLevel)
    
    local info = PetEquipInfo.getPetEquipInfoById(equipInfo.equipID)
    local item = CSResourceMgr.getNodeByName(resName, {"db", "item"})
    local itemRes = PetEquipInfo.getEquipQualityBGImage(equipInfo.equipID)
    CSResourceMgr.setButtonTextureByNode(item, itemRes, itemRes, itemRes)
    local icon = CSResourceMgr.seekNodeByName(item, "icon")
    CSResourceMgr.setSpriteTextureByNode(icon, info.icon)
    local name = CSResourceMgr.getNodeByName(resName, {"db", "name"})
    if strengthenLevel > 0 then
        CSResourceMgr.setLabelStringByNode(name, LuaSqlite.getLanguageByKey(info.name).." (+"..strengthenLevel..")", {r=0,g=0,b=0,a=255})
    else
        CSResourceMgr.setLabelStringByNode(name, LuaSqlite.getLanguageByKey(info.name), {r=0,g=0,b=0,a=255})
    end
    local posTxt = {"PetEquip6", "PetEquip7", "PetEquip8"}
    local pos = CSResourceMgr.getNodeByName(resName, {"db", "pos"})
    local quality = PetEquipInfo.getPetEquipInfoById(equipInfo.equipID).quality
    if quality>=5 then
    	local qTip = pos:clone()
    	qTip:addTo(pos:getParent())
    	qTip:setPositionY(700)
        CSResourceMgr.setLabelStringByNode(qTip, "PetEquip52", {r=0,g=0,b=0,a=255})
    end
    CSResourceMgr.setLabelStringByNode(pos, LuaSqlite.getLanguageByKey("PetEquip21")..LuaSqlite.getLanguageByKey(posTxt[info.pos]), {r=0,g=0,b=0,a=255})
    local seriesIcon = CSResourceMgr.getNodeByName(resName, {"db", "seriesIcon"})
    seriesIcon:removeAllChildren()
    if info.elemAttrNum == 9 then
        local sprite = display.newSprite("Pet/Equipment/all.png")
        sprite:setScale(0.5)
        sprite:setPosition(0, 2)
        sprite:setAnchorPoint(0.5, 0.5)
        seriesIcon:addChild(sprite)
    else
        local elemAttr = equipInfo.elemAttr or {}
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
    
    local text = {"train11","train12","train13","train14","train15","train16",}
    local listData = {}
    if equipInfo.hp > 0 then
        table.insert(listData, {text[1], equipInfo.hp + math.floor(equipInfo.hp*(purifyInfo.second/100.0))})
    end
    if equipInfo.atk > 0 then
        table.insert(listData, {text[2], equipInfo.atk + math.floor(equipInfo.atk*(purifyInfo.second/100.0))})
    end
    if equipInfo.def > 0 then
        table.insert(listData, {text[3], equipInfo.def + math.floor(equipInfo.def*(purifyInfo.second/100.0))})
    end
    if equipInfo.satk > 0 then
        table.insert(listData, {text[4], equipInfo.satk + math.floor(equipInfo.satk*(purifyInfo.second/100.0))})
    end
    if equipInfo.sdef > 0 then
        table.insert(listData, {text[5], equipInfo.sdef + math.floor(equipInfo.sdef*(purifyInfo.second/100.0))})
    end
    if equipInfo.speed > 0 then
        table.insert(listData, {text[6], equipInfo.speed + math.floor(equipInfo.speed*(purifyInfo.second/100.0))})
    end
    local attr_list = CSResourceMgr.getNodeByName(resName, {"db", "attr_list"})
    attr_list:removeAllItems()
    for k, v in pairs(listData) do
        table.insert(funcTable, function()
            local cell = CSResourceMgr.getNodeByName(resName,"attr_listexample"):clone()
            local background = CSResourceMgr.seekNodeByName(cell, "att_background")
            local attr_text = CSResourceMgr.seekNodeByName(cell, "attr_text")
            local attr_num = CSResourceMgr.seekNodeByName(cell, "attr_num")
            local attr_add_num = CSResourceMgr.seekNodeByName(cell, "attr_add_num")
            cell:setColor({r=37,g=53,b=69,a=255})
            background:setColor({r=26,g=38,b=49,a=255})
            CSResourceMgr.setLabelStringByNode(attr_text, v[1], {r=0,g=0,b=0,a=255})
            CSResourceMgr.setLabelColorByNode(attr_text, {r=254,g=243,b=57,a=255})
            CSResourceMgr.setLabelStringByNode(attr_num, v[2], {r=0,g=0,b=0,a=255})
            local strengthenInfo = getEquipmentStrengthenInfo(equipInfo, strengthenLevel)
            if strengthenInfo.effect > 0 then
                CSResourceMgr.setLabelStringByNode(attr_add_num, "+"..math.floor(v[2]*(strengthenInfo.effect/100.0)), {r=0,g=0,b=0,a=255})
                local width = attr_add_num:getBoundingBox().width * 0.5
                local addWidth = attr_num:getBoundingBox().width * 0.5
                attr_num:setPositionX(background:getPositionX() - width)
                attr_add_num:setPositionX(attr_num:getPositionX() + addWidth)
            end
            cell:setVisible(true)
            attr_list:pushBackCustomItem(cell)
        end)
    end
    
    local level = CSResourceMgr.getNodeByName(resName, {"db", "level"})
    for i=1, MAX_PURIFY_LEVEL do
        local star = CSResourceMgr.seekNodeByName(level, "star"..i)
        if i <= purifyLevel then
            CSResourceMgr.setSpriteTextureByNode(star, "Pet/Education/xing.png")
            star:setVisible(true)
        else
            if i <= info.purifyMax then
                CSResourceMgr.setSpriteTextureByNode(star, "UI/CommonFiles/xing_null.png")
                star:setVisible(true)
            else
                star:setVisible(false)
            end
        end
    end
    
    local tip = CSResourceMgr.getNodeByName(resName, {"db", "tip"})
    CSResourceMgr.setLabelStringByNode(tip, CocosModuleMgr.createStringWithFormat({"PetEquip49", purifyInfo.second}))
    
    local effect_list = CSResourceMgr.getNodeByName(resName, {"db", "effect_list"})
    effect_list:removeAllItems()
    if equipInfo.effects then
        for i=1, MAX_STRENGTHEN_LEVEL do
            local effect = equipInfo.effects[tostring(i)]
            if effect then
                table.insert(funcTable, function()
                    local cell = CSResourceMgr.getNodeByName(resName,"effect_listexample"):clone()
                    local attr_text = CSResourceMgr.seekNodeByName(cell, "attr_text")
                    local info = PetEquipInfo.getPetEquipEffectInfoById(effect.ID)
                    local top_text = ""
                    if info.type~=26 then
                        local baseString = "PetEquip54"
                        if string.sub(LuaSqlite.getLanguageByKey(info.name), -1, -1)=="%" then
                            baseString = "PetEquip56"
                        end
                        top_text = CocosModuleMgr.createStringWithFormat({baseString, info.valueMax})
                    end
                    CSResourceMgr.setLabelStringByNode(attr_text, "+"..i..":"..
                        CocosModuleMgr.createStringWithFormat({info.name, effect.value or 0})..top_text, {r=0,g=0,b=0,a=255})
                    if i <= strengthenLevel then
                        CSResourceMgr.setLabelColorByNode(attr_text, {r=0,g=255,b=0,a=255})
                    else
                        CSResourceMgr.setLabelColorByNode(attr_text, {r=128,g=128,b=128,a=255})
                    end
                    cell:setVisible(true)
                    effect_list:pushBackCustomItem(cell)
                end)
            end
        end
    end
end

function PetEquipmentOperationMgr.show(scene, petInfo, equipInfo, operationTxt, isTip, funcOperationSuccess)
    if CSResourceMgr.getCsbObj(resName) then
        return  
    end

    UIStack.push("PetEquipmentOperationMgr",PetEquipmentOperationMgr.hideUI,false)
    local funcTable = {}
    local function loadCSB()
        local curLayer = CSResourceMgr.createRes(scene, resName)
        curLayer:setLocalZOrder(CocosModuleMgr.ZORDER_FLOAT)
        CSResourceMgr.setRelativePosition(resName, 320, 480)
        CSResourceMgr.getNodeByName(resName, "db"):setVisible(false)

        CSResourceMgr.clickEventBinding(resName, "close", function()
            PetEquipmentOperationMgr.hideUI()
        end)

        CSResourceMgr.clickEventBinding(resName, "btn_operation", function()
            PetEquipmentOperationMgr.hideUI()
            if operationTxt == "PetEquip17" or operationTxt == "PetEquip18" then
                local elemAttrEquip = equipInfo.elemAttr or {}
                local pokeInfo = PokemonInfo.getPokemonInfoByID(petInfo.pokeID)
                for k, v in pairs(elemAttrEquip) do
                    if v == pokeInfo.elementAtt1 or v == pokeInfo.elementAtt2 then
                        local quality = PetEquipInfo.getPetEquipInfoById(equipInfo.equipID).quality
                        if quality>=5 and pokeInfo.rarePoint<5 then
                            StandardTipsMgr.show(1, "PetEquip52")
                            return
                        end
                        if operationTxt == "PetEquip17" then
                            PetEquipInfo.petEquipOn(petInfo.objID, equipInfo.objID, funcOperationSuccess)
                        else
                            PetEquipInfo.petEquipOff(petInfo.objID, PetEquipInfo.getPetEquipInfoById(equipInfo.equipID).pos, function()
                                PetEquipInfo.petEquipOn(petInfo.objID, equipInfo.objID, funcOperationSuccess)
                            end)
                        end
                        return
                    end
                end
                StandardTipsMgr.show(1, "PetEquip36")
            elseif operationTxt == "PetEquip19" then
                PetEquipInfo.petEquipOff(petInfo.objID, PetEquipInfo.getPetEquipInfoById(equipInfo.equipID).pos, funcOperationSuccess)
            end
        end)
        
        CSResourceMgr.clickEventBinding(resName, "btn_restore", function()
            PetEquipmentOperationMgr.hideUI()
            local strengthenLevel = equipInfo.strengthen or 0
            local purifyLevel = 0
            if equipInfo.purify then
                purifyLevel = equipInfo.purify.level or 0
            end
            if strengthenLevel <= 0 and purifyLevel <= 0 then
                StandardTipsMgr.show(1, "PetEquip37")
            elseif CharInfo.getMCash() < SystemInfo.getGlobalConfigAddInfoByID(60001).values[1] then
                StandardTipsMgr.show(1, "tips14")
            else
                local allItems = {}
                local quality = PetEquipInfo.getPetEquipInfoById(equipInfo.equipID).quality
                if strengthenLevel > 0 then
                    local num = PetEquipInfo.getPetEquipRestoreStrengthenInfoById(quality).nums[strengthenLevel]
                    table.insert(allItems, {SystemInfo.getGlobalConfigAddInfoByID(60001).values[2], num})
                end
                if purifyLevel > 0 then
                    local num = PetEquipInfo.getPetEquipRestorePurifyInfoById(quality).nums[purifyLevel]
                    table.insert(allItems, {SystemInfo.getGlobalConfigAddInfoByID(60001).values[3], num})
                end
                PetEquipmentRestoreMgr.show(SceneMgr.getRunningScene, SystemInfo.getGlobalConfigAddInfoByID(60001).values[1], equipInfo.equipID, allItems, function()
                    if operationTxt == "PetEquip17" or operationTxt == "PetEquip18" then
                        PetEquipInfo.petEquipRestore(equipInfo.objID, 0, funcOperationSuccess)
                    elseif operationTxt == "PetEquip19" then
                        PetEquipInfo.petEquipRestore(petInfo.objID, PetEquipInfo.getPetEquipInfoById(equipInfo.equipID).pos, funcOperationSuccess)
                    end
                end)
            end
        end)
        
        if isTip==true then
            local item = CSResourceMgr.getNodeByName(resName, {"db", "item"})
            local ani = AnimationMgr.createAni(item, "Spine/effects/Ui_daojutuxian.png", 
                item:getContentSize().width/2, item:getContentSize().height/2)
            AnimationMgr.playAni(ani.res, "animation", true, ani.tag)
            ani:zorder(-1)
        elseif isTip=="null" then
            isTip = true
        end

        initStaticData(operationTxt, isTip)

        initDynamicData(equipInfo, funcTable)
    end

    local function playCSB()
        local node = CSResourceMgr.getNodeByName(resName, "db")
        if node ~= nil then
            node:setVisible(true)
            CocosModuleMgr.showUIAnimation(node, "down")
        end
    end

    loadCSB()
    playCSB()

    UnblockLoader.load(funcTable, "PetEquipmentOperationMgr.show")
end

return PetEquipmentOperationMgr