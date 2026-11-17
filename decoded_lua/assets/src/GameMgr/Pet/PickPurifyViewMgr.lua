local PickPurifyViewMgr = {}

local resName = ""
local input = nil
local expRequire = nil
local pickedPurifyID = {}
local MAX_PICKED_NUM = 4

function PickPurifyViewMgr.Init()
    resName = "Pet/Equipment/PickPurifyView.csb"
    local input = nil
    expRequire = nil
    pickedPurifyID = {}
    MAX_PICKED_NUM = 4
end

function PickPurifyViewMgr.hideUI()
    UnblockLoader.cancel("PickPurifyViewMgr.show")
    CSResourceMgr.removeCSObjectByTag(resName)
    UIStack.pop("PickPurifyViewMgr")
end

local function updateTip()
    if expRequire then
        local exp = 0
        for k, v in pairs(pickedPurifyID) do
            local materialInfo = v
            if not materialInfo[3] then
                exp = exp + SystemInfo.getGlobalConfigAddInfoByID(60001).values[4] * materialInfo[2]
            else
                exp = exp + PetEquipInfo.getPetEquipPurifyExpInfoById(PetEquipInfo.getPetEquipInfoById(materialInfo[1]).quality).exp
            end
        end
        CSResourceMgr.setLabelString(resName, {"db","tip2"}, CocosModuleMgr.createStringWithFormat({"PetEquip40", exp, expRequire}), nil, {r=0,g=0,b=0,a=255})
    end
end

local function initStaticData(itemStone, expMax)
    CSResourceMgr.setLabelString(resName, {"db", "txt_title"}, "PetEquip31", nil, {r=0,g=0,b=0,a=255})
    CSResourceMgr.setLabelString(resName, {"db", "tip1"}, "PetEquip41", nil, {r=0,g=0,b=0,a=255})
    CSResourceMgr.setLabelString(resName, "count", "train211", nil, {r=0,g=0,b=0,a=255})
    local max = CSResourceMgr.getNodeByName(resName, "btn_max")
    CSResourceMgr.setButtonStringByNode(max, "MAX", {r=0,g=0,b=0,a=255})
    CSResourceMgr.setButtonEnabledByNode(max, itemStone and true or false)
    CSResourceMgr.clickEventBindingByNode(max, function()
        local expNum = 0
        local stoneIndex = nil
        for k, v in pairs(pickedPurifyID) do
            if not v[3] then
                stoneIndex = k
            else
                expNum = expNum + PetEquipInfo.getPetEquipPurifyExpInfoById(PetEquipInfo.getPetEquipInfoById(v[1]).quality).exp
            end
        end
        if #pickedPurifyID < MAX_PICKED_NUM or stoneIndex then
            local stoneNum = math.ceil((expMax-expNum)/SystemInfo.getGlobalConfigAddInfoByID(60001).values[4])
            if stoneNum>itemStone[2] then
            	stoneNum = itemStone[2]
            end
            if stoneIndex then
                pickedPurifyID[stoneIndex] = {itemStone[1], stoneNum}
            else
                table.insert(pickedPurifyID, {itemStone[1], stoneNum})
            end
            input:setText(stoneNum)
        else
            input:setText("0")
        end
        
        updateTip()
    end, 3)
    CSResourceMgr.setButtonString(resName, "btn_ok", "tips3", nil, {r=0,g=0,b=0,a=255})
    if itemStone then
        local input_bg = CSResourceMgr.getNodeByName(resName, "input_bg")
        input = CocosModuleMgr.newTextEditor(CSResourceMgr.getNodeByName(resName, "db"), 
            "empty.png", input_bg:getContentSize().width, input_bg:getContentSize().height, input_bg:getPositionX(), input_bg:getPositionY(), 24, 10, "0", 2, function()
                local txt = input:getText()
                if txt ~= "" then
                    local stoneNum = tonumber(txt)
                    if stoneNum <= 0 then
                        input:setText("0")
                        for k, v in pairs(pickedPurifyID) do
                            if itemStone[1] == v[1] then
                                table.remove(pickedPurifyID, k)
                                updateTip()
                                return
                            end
                        end
                    else
                        if stoneNum > itemStone[2] then
                            stoneNum = itemStone[2]
                            input:setText(tostring(stoneNum))
                        end
                        for k, v in pairs(pickedPurifyID) do
                            if itemStone[1] == v[1] then
                                v[2] = stoneNum
                                updateTip()
                                return
                            end
                        end
                        if #pickedPurifyID < MAX_PICKED_NUM then
                            table.insert(pickedPurifyID, {itemStone[1], stoneNum})
                            updateTip()
                        else
                            input:setText("0")
                        end
                    end
                else
                    input:setText("0")
                    for k, v in pairs(pickedPurifyID) do
                        if itemStone[1] == v[1] then
                            table.remove(pickedPurifyID, k)
                            updateTip()
                            return
                        end
                    end
                end
            end)
    end
end


--itemStone:{itemID, itemNum} petEquip:{equipID, objID, showTip}
local function initDynamicData(itemStone, itemsVec, defaultItemsID, exp, funcTable)
    pickedPurifyID = defaultItemsID
    expRequire = exp
    if itemStone then
        local stoneInfo = ItemInfo.getItemInfoById(itemStone[1])
        local name = CSResourceMgr.getNodeByName(resName,"name")
        CSResourceMgr.setLabelStringByNode(name, stoneInfo.name, {r=0,g=0,b=0,a=255})
        
        local stone = CSResourceMgr.getNodeByName(resName,"item")
        local itemRes = ItemInfo.getItemRareBGImage(itemStone[1])
        CSResourceMgr.setButtonTextureByNode(stone, itemRes, itemRes, itemRes)
        CSResourceMgr.clickEventBindingByNode(stone, function()
            ItemInfoViewMgr.show({id = itemStone[1]}, false)
        end, 1)
        local icon = CSResourceMgr.seekNodeByName(stone, "icon")
        local iconRes = stoneInfo.icon
        CSResourceMgr.setSpriteTextureByNode(icon, iconRes)
        local num = CSResourceMgr.seekNodeByName(stone, "num")
        num:setVisible(itemStone[2] > 0)
        if itemStone[2] > 0 then
            CSResourceMgr.setLabelStringByNode(num, itemStone[2], {r=0,g=0,b=0,a=255})
        end
        
        for k, v in pairs(pickedPurifyID) do
            if itemStone[1] == v[1] and input then
                input:setText(tostring(v[2]))
                break
            end
        end
    else
        local icon = CSResourceMgr.getNodeByName(resName, {"db", "item", "icon"})
        local iconRes = ItemInfo.getItemInfoById(SystemInfo.getGlobalConfigAddInfoByID(60001).values[3]).icon
        CSResourceMgr.setSpriteTextureByNode(icon, iconRes)
        local actionExam = cc.TintTo:create(0.1,100,100,100)
        icon:runAction(actionExam)
    end

    if #itemsVec > 0 then
        local list = CSResourceMgr.getNodeByName(resName, "list")
        list:removeAllItems()
        for i=1, #itemsVec do
            local itemInfo = itemsVec[i]
            table.insert(funcTable, function()
                local item = CSResourceMgr.getNodeByName(resName,"item_clone"):clone()
                local itemRes = PetEquipInfo.getEquipQualityBGImage(itemInfo[1])
                CSResourceMgr.setButtonTextureByNode(item, itemRes, itemRes, itemRes)
                local icon = CSResourceMgr.seekNodeByName(item, "icon")
                local iconRes = PetEquipInfo.getPetEquipInfoById(itemInfo[1]).icon
                CSResourceMgr.setSpriteTextureByNode(icon, iconRes)
                local num = CSResourceMgr.seekNodeByName(item, "num")
                num:setVisible(false)
                local strengthenLevel = itemInfo[3].strengthen or 0
                if strengthenLevel > 0 then
                    num:show()
                    CSResourceMgr.setLabelStringByNode(num, "+"..strengthenLevel, {r=0,g=0,b=0,a=255})
                end
                
                local elemAttr = itemInfo[3].elemAttr or {}
                local attrNum = PetEquipInfo.getPetEquipInfoById(itemInfo[3].equipID).elemAttrNum
                if attrNum==9 then
                    local sprite = display.newSprite("Pet/Equipment/all.png")
                    sprite:setScale(0.5)
                    sprite:setPosition(15, 80)
                    sprite:setAnchorPoint(0.5, 0.5)
                    item:addChild(sprite)
                else
                    for i=1, #elemAttr do
                        local tex = "UI/CommonFiles/"..elemAttr[i]..".png"
                        local sprite = display.newSprite(tex)
                        sprite:setScale(0.5)
                        local w = sprite:getContentSize().width * 0.4
                        sprite:setPosition(15+(i-1)*w, 80)
                        sprite:setAnchorPoint(0.5, 0.5)
                        item:addChild(sprite)
                    end
                end
                
                for k, v in pairs(pickedPurifyID) do
                    if itemInfo[1] == v[1] and itemInfo[2] == v[2] then
                        CSResourceMgr.seekNodeByName(item, "hook"):setVisible(true)
                        break
                    end
                end
                item:setVisible(true)
                CSResourceMgr.longtouchEventBindingByNode(item, function()
                    PetEquipmentOperationMgr.show(SceneMgr.getRunningScene, nil, itemInfo[3], "", "null")
                end, function()
                    local pickedIndex = nil
                    for k, v in pairs(pickedPurifyID) do
                        if itemInfo[1] == v[1] and itemInfo[2] == v[2] then
                            pickedIndex = k
                            break
                        end
                    end
                    if not pickedIndex then
                        if #pickedPurifyID < MAX_PICKED_NUM then
                            table.insert(pickedPurifyID, {itemInfo[1], itemInfo[2], itemInfo[3]})
                            CSResourceMgr.seekNodeByName(item, "hook"):setVisible(true)
                            local strengthenLevel = itemInfo[3].strengthen or 0
                            local purifyLevel = 0
                            if itemInfo[3].purify then
                                purifyLevel = itemInfo[3].purify.level or 0
                            end
                            if strengthenLevel > 0 or purifyLevel > 0 then
                                StandardTipsMgr.show(1, "PetEquip42")
                            else
                                local quality = PetEquipInfo.getPetEquipInfoById(itemInfo[3].equipID).quality
                                if quality >= 5 then
                                    StandardTipsMgr.show(1, "PetEquip51")
                                end
                            end
                        end
                    else
                        table.remove(pickedPurifyID, pickedIndex)
                        CSResourceMgr.seekNodeByName(item, "hook"):setVisible(false)
                    end     
                    updateTip()
                end)
                list:pushBackCustomItem(item)
                item:setScale(0)
                transition.scaleTo(item, {scale=1, time=0.2})
            end)
        end
    end
    
    updateTip()
end

function PickPurifyViewMgr.show(scene, itemStone, itemsVec, defaultItemsID, exp, expMax, funcOK)
    if CSResourceMgr.getCsbObj(resName) then
        return  
    end

    UIStack.push("PickPurifyViewMgr",PickPurifyViewMgr.hideUI,false)
    local funcTable = {}
    local function loadCSB()
        local curLayer = CSResourceMgr.createRes(scene, resName)
        curLayer:setLocalZOrder(CocosModuleMgr.ZORDER_FLOAT)
        CSResourceMgr.setRelativePosition(resName, 320, 480)
        CSResourceMgr.getNodeByName(resName, "db"):setVisible(false)

        CSResourceMgr.clickEventBinding(resName, "close", function()
            PickPurifyViewMgr.hideUI()
        end)

        CSResourceMgr.clickEventBinding(resName, "btn_ok", function()
            PickPurifyViewMgr.hideUI()
            if funcOK then funcOK() end
        end)

        initStaticData(itemStone, expMax)

        initDynamicData(itemStone, itemsVec, defaultItemsID, exp, funcTable)
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

    UnblockLoader.load(funcTable, "PickPurifyViewMgr.show")
end

function PickPurifyViewMgr.getPickedPurifyID()
    return pickedPurifyID
end

function PickPurifyViewMgr.setPickedPurifyID(val)
	pickedPurifyID = val
end

return PickPurifyViewMgr