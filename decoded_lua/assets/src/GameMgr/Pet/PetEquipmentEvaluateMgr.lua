local PetEquipmentEvaluateMgr = {}

local resName = ""

function PetEquipmentEvaluateMgr.Init()
    resName = "Pet/Equipment/PetEquipmentEvaluate.csb"
end

function PetEquipmentEvaluateMgr.hideUI()
    UnblockLoader.cancel("PetEquipmentEvaluateMgr.show")
    CSResourceMgr.removeCSObjectByTag(resName)
    UIStack.pop("PetEquipmentEvaluateMgr")
end

local function initStaticData()
    CSResourceMgr.setLabelString(resName, {"db","txt_title"}, "PetEquip47", nil, {r=0,g=0,b=0,a=255,w=1})
    CSResourceMgr.setLabelString(resName, {"db", "series"}, "PetEquip22", nil, {r=0,g=0,b=0,a=255,w=1})
    CSResourceMgr.setButtonString(resName, {"db","btn_evaluate"}, "PetEquip43", nil, {r=0,g=0,b=0,a=255,w=1})
    CSResourceMgr.setLabelString(resName, {"db","base_attr","txt"}, "PetEquip44", nil, {r=0,g=0,b=0,a=255,w=1})
    CSResourceMgr.setLabelString(resName, {"db","purify_level","txt"}, "PetEquip45", nil, {r=0,g=0,b=0,a=255,w=1})
    CSResourceMgr.setLabelString(resName, {"db","strengthen_effect","txt"}, "PetEquip46", nil, {r=0,g=0,b=0,a=255,w=1})
end

local function initDynamicData(itemInfo, funcTable)
    local info = ItemInfo.getItemInfoById(itemInfo[1])
    local equipInfo = PetEquipInfo.getPetEquipInfoById(info.paramA)
    local item = CSResourceMgr.getNodeByName(resName, {"db", "item"})
    local itemRes = ItemInfo.getItemRareBGImage(itemInfo[1])
    CSResourceMgr.setButtonTextureByNode(item, itemRes, itemRes, itemRes)
    local icon = CSResourceMgr.seekNodeByName(item, "icon")
    CSResourceMgr.setSpriteTextureByNode(icon, info.icon)
    local hook = icon:clone()
    CSResourceMgr.setSpriteTextureByNode(hook, "Item/zhuangbei/weijianding.png")
    hook:addTo(item)
    local name = CSResourceMgr.getNodeByName(resName, {"db", "name"})
    CSResourceMgr.setLabelStringByNode(name, info.name, {r=0,g=0,b=0,a=255})
    local posTxt = {"PetEquip6", "PetEquip7", "PetEquip8"}
    local pos = CSResourceMgr.getNodeByName(resName, {"db", "pos"})
    local quality = ItemInfo.getItemInfoById(itemInfo[1]).itemRare
    if quality>=5 then
        local qTip = pos:clone()
        qTip:addTo(pos:getParent())
        qTip:setPositionY(700)
        CSResourceMgr.setLabelStringByNode(qTip, "PetEquip52", {r=0,g=0,b=0,a=255})
    end
    CSResourceMgr.setLabelStringByNode(pos, LuaSqlite.getLanguageByKey("PetEquip21")..LuaSqlite.getLanguageByKey(posTxt[equipInfo.pos]), {r=0,g=0,b=0,a=255})
    local seriesIcon = CSResourceMgr.getNodeByName(resName, {"db", "seriesIcon"})
    seriesIcon:removeAllChildren()
    local sprite = nil
    if equipInfo.elemAttrNum == 9 then
        sprite = display.newSprite("Pet/Equipment/all.png")
    else
        sprite = display.newSprite("Pet/Equipment/unknown.png")
    end
    sprite:setScale(0.5)
    sprite:setPosition(0, 2)
    sprite:setAnchorPoint(0.5, 0.5)
    seriesIcon:addChild(sprite)
    
    local text = {"train11","train12","train13","train14","train15","train16",}
    local listData = {}
    if equipInfo.hpMax > 0 then
        table.insert(listData, {text[1], equipInfo.hpMin.."~"..equipInfo.hpMax})
    end
    if equipInfo.atkMax > 0 then
        table.insert(listData, {text[2], equipInfo.atkMin.."~"..equipInfo.atkMax})
    end
    if equipInfo.defMax > 0 then
        table.insert(listData, {text[3], equipInfo.defMin.."~"..equipInfo.defMax})
    end
    if equipInfo.satkMax > 0 then
        table.insert(listData, {text[4], equipInfo.satkMin.."~"..equipInfo.satkMax})
    end
    if equipInfo.sdefMax > 0 then
        table.insert(listData, {text[5], equipInfo.sdefMin.."~"..equipInfo.sdefMax})
    end
    if equipInfo.speedMax > 0 then
        table.insert(listData, {text[6], equipInfo.speedMin.."~"..equipInfo.speedMax})
    end
    local attr_list = CSResourceMgr.getNodeByName(resName, {"db", "attr_list"})
    attr_list:removeAllItems()
    for k, v in pairs(listData) do
        table.insert(funcTable, function()
            local cell = CSResourceMgr.getNodeByName(resName,"attr_listexample"):clone()
            local background = CSResourceMgr.seekNodeByName(cell, "att_background")
            local attr_text = CSResourceMgr.seekNodeByName(cell, "attr_text")
            local attr_num = CSResourceMgr.seekNodeByName(cell, "attr_num")
            cell:setColor({r=37,g=53,b=69,a=255})
            background:setColor({r=26,g=38,b=49,a=255})
            CSResourceMgr.setLabelStringByNode(attr_text, v[1], {r=0,g=0,b=0,a=255})
            CSResourceMgr.setLabelColorByNode(attr_text, {r=254,g=243,b=57,a=255})
            CSResourceMgr.setLabelStringByNode(attr_num, v[2], {r=0,g=0,b=0,a=255})
            cell:setVisible(true)
            attr_list:pushBackCustomItem(cell)
        end)
    end
    
    local level = CSResourceMgr.getNodeByName(resName, {"db", "level"})
    for i=1, 10 do
        local star = CSResourceMgr.seekNodeByName(level, "star"..i)
        if i <= equipInfo.purifyMax then
            CSResourceMgr.setSpriteTextureByNode(star, "Pet/Education/starup/kong.png")
        else
            star:setVisible(false)
        end
    end
    
    local effect_list = CSResourceMgr.getNodeByName(resName, {"db", "effect_list"})
    effect_list:removeAllItems()
    for k, v in pairs(equipInfo.effects) do
        if v > 0 then
            table.insert(funcTable, function()
                local cell = CSResourceMgr.getNodeByName(resName,"effect_listexample"):clone()
                local attr_text = CSResourceMgr.seekNodeByName(cell, "attr_text")
                CSResourceMgr.setLabelStringByNode(attr_text, "+"..k..":"..LuaSqlite.getLanguageByKey(PetEquipInfo.getPetEquipEffectSetInfoById(v).wordPoolName), {r=0,g=0,b=0,a=255})
                CSResourceMgr.setLabelColorByNode(attr_text, {r=128,g=128,b=128,a=255})
                cell:setVisible(true)
                effect_list:pushBackCustomItem(cell)
            end)
        end
    end
end

function PetEquipmentEvaluateMgr.show(scene, itemInfo,bhideBtn)
    if CSResourceMgr.getCsbObj(resName) then
        return  
    end
    
    UIStack.push("PetEquipmentEvaluateMgr",PetEquipmentEvaluateMgr.hideUI,false)
    local funcTable = {}
    local function loadCSB()
        local curLayer = CSResourceMgr.createRes(scene, resName)
        curLayer:setLocalZOrder(CocosModuleMgr.ZORDER_FLOAT)
        CSResourceMgr.setRelativePosition(resName, 320, 480)
        CSResourceMgr.getNodeByName(resName, "db"):setVisible(false)

        CSResourceMgr.clickEventBinding(resName, "close", function()
            PetEquipmentEvaluateMgr.hideUI()
        end)

        CSResourceMgr.clickEventBinding(resName, "btn_evaluate", function()
            if #PetEquipmentMgr.getAllPetUnwearEquipment()>=50 then
                StandardTipsMgr.show(1, "PetEquip57")
            else
                PetEquipmentEvaluateMgr.hideUI()
                PetEquipInfo.petEquipAppraise(itemInfo[1], function()
                    PetEquipInfo.getPetEquip()
                end)
            end
        end)

        if bhideBtn == true then 
             CSResourceMgr.getNodeByName(resName, "btn_evaluate"):setVisible(false)
        end
        initStaticData()

        initDynamicData(itemInfo, funcTable)
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

    UnblockLoader.load(funcTable, "PetEquipmentEvaluateMgr.show")
end

return PetEquipmentEvaluateMgr