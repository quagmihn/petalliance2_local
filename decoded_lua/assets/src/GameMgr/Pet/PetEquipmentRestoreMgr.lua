local PetEquipmentRestoreMgr = {}

local resName = ""
local richLabel = nil

function PetEquipmentRestoreMgr.Init()
    resName = "Pet/Equipment/PetEquipmentRestore.csb"
    richLabel = nil
end

function PetEquipmentRestoreMgr.hideUI()
    UnblockLoader.cancel("PetEquipmentRestoreMgr.show")
    if richLabel then
        richLabel:removeFromParent(true)
        richLabel = nil
    end
    CSResourceMgr.removeCSObjectByTag(resName)
    UIStack.pop("PetEquipmentRestoreMgr")
end

local function initStaticData(diamond, equipID)
    CSResourceMgr.setLabelString(resName, {"db", "title"}, "PetEquip14", nil, {r=0,g=0,b=0,a=255,w=1})
    CSResourceMgr.setButtonString(resName, {"db", "btn_ok"}, "tips3", nil, {r=0,g=0,b=0,a=255})
    CSResourceMgr.setButtonString(resName, {"db", "btn_cancel"}, "tips4", nil, {r=0,g=0,b=0,a=255})
    
    local tip = CSResourceMgr.getNodeByName(resName, {"db", "tip1"})
    local equipInfo = PetEquipInfo.getPetEquipInfoById(equipID)
    local quality = equipInfo.quality
    local color = ItemInfo.COLOR_16[quality + 1] or ItemInfo.COLOR_16[1]
    local tipStr = CocosModuleMgr.createStringWithFormat({"PetEquip15", diamond, equipInfo.name, color})
    if CocosModuleMgr.checkIsRichLabelString(tipStr) then
        tip:setVisible(false)
        local db = CSResourceMgr.getNodeByName(resName, "db")
        local fontSize = tip:getFontSize()
        local x, y = tip:getPosition()
        richLabel = CocosModuleMgr.createRichLabel(db, tipStr, fontSize, "cuyuan_GBK.ttf", 470, x - 470/2, 0, nil, true)
        richLabel:setPositionY(y - richLabel:getBoundingBox().height/2)
    else
        local size = tip:getContentSize()
        CSResourceMgr.setLabelMaxWidthByNode(tip, 470)
        tip:setContentSize(size.width, size.height * 3)
        tip:setString(tipStr)
    end
    
    CSResourceMgr.setLabelString(resName, {"db", "tip2"}, "PetEquip16", nil, {r=0,g=0,b=0,a=255,w=1})
end

local function initDynamicData(itemsVec, funcTable)
    local itemsNum = #itemsVec
    if itemsNum > 0 then
        local list = CSResourceMgr.getNodeByName(resName, "list")
        list:removeAllItems()
        for i=1, itemsNum do
            local itemInfo = itemsVec[i]
            table.insert(funcTable, function()
                local item = CSResourceMgr.getNodeByName(resName,"item_listexample"):clone()
                local itemRes = ItemInfo.getItemRareBGImage(itemInfo[1])
                CSResourceMgr.setButtonTextureByNode(item, itemRes, itemRes, ItemInfo.getItemRareBGImage())
                local icon = CSResourceMgr.seekNodeByName(item, "icon")
                local iconRes = ItemInfo.getItemInfoById(itemInfo[1]).icon
                CSResourceMgr.setSpriteTextureByNode(icon, iconRes)
                local num = CSResourceMgr.seekNodeByName(item, "num")
                CSResourceMgr.setLabelStringByNode(num, itemInfo[2], {r=0,g=0,b=0,a=255})
                num:setVisible(true)
                item.itemID = itemInfo[1]
                item:setVisible(true)
                list:pushBackCustomItem(item)
                item:setScale(0)
                transition.scaleTo(item, {scale=1, time=0.2})
            end)
        end
    end
end

function PetEquipmentRestoreMgr.show(scene, diamond, equipID, itemsVec, funcOK)
    if CSResourceMgr.getCsbObj(resName) then
        return  
    end

    UIStack.push("PetEquipmentRestoreMgr",PetEquipmentRestoreMgr.hideUI,false)
    local funcTable = {}
    local function loadCSB()
        local curLayer = CSResourceMgr.createRes(scene, resName)
        curLayer:setLocalZOrder(CocosModuleMgr.ZORDER_FLOAT)
        CSResourceMgr.setRelativePosition(resName, 320, 480)
        CSResourceMgr.getNodeByName(resName, "db"):setVisible(false)

        CSResourceMgr.clickEventBinding(resName, "close", function()
            PetEquipmentRestoreMgr.hideUI()
        end)

        CSResourceMgr.clickEventBinding(resName, "btn_ok", function()
            PetEquipmentRestoreMgr.hideUI()
            if funcOK then funcOK() end
        end)

        CSResourceMgr.clickEventBinding(resName, "btn_cancel", function()
            PetEquipmentRestoreMgr.hideUI()
        end)

        initStaticData(diamond, equipID)

        initDynamicData(itemsVec, funcTable)
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

    UnblockLoader.load(funcTable, "PetEquipmentRestoreMgr.show")
end

return PetEquipmentRestoreMgr