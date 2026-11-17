local PickItemViewMgr = {}

local resName = ""
local pickedItemID = nil

function PickItemViewMgr.Init()
    resName = "Pet/Equipment/PickItemView.csb"
    pickedItemID = nil
end

function PickItemViewMgr.hideUI()
    UnblockLoader.cancel("PickItemViewMgr.show")
    CSResourceMgr.removeCSObjectByTag(resName)
    UIStack.pop("PickItemViewMgr")
end

local function initStaticData()
    CSResourceMgr.setLabelString(resName, {"db", "title"}, "PetEquip13", nil, {r=0,g=0,b=0,a=255,w=1})
    CSResourceMgr.setLabelString(resName, {"db", "tip1"}, "PetEquip39", nil, {r=0,g=0,b=0,a=255})
    CSResourceMgr.setButtonString(resName, {"db", "btn_ok"}, "tips3", nil, {r=0,g=0,b=0,a=255})
    CSResourceMgr.setButtonString(resName, {"db", "btn_cancel"}, "tips4", nil, {r=0,g=0,b=0,a=255})
end

local function markHookOnItem(list, item)
    local items = list:getItems()
    for i=1, #items do
        CSResourceMgr.seekNodeByName(items[i], "hook"):setVisible(items[i] == item)
    end
end

local function initDynamicData(itemsVec, defaultItemID, funcTable)
    local itemsNum = #itemsVec
    pickedItemID = defaultItemID
    if itemsNum > 0 then
        if not pickedItemID then
            for k, v in pairs(itemsVec) do
                if v[2] > 0 then
                    pickedItemID = v[1]
                    break
                end
            end
        end
        
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
                if itemInfo[2] > 0 then
                    local num = CSResourceMgr.seekNodeByName(item, "num")
                    CSResourceMgr.setLabelStringByNode(num, itemInfo[2], {r=0,g=0,b=0,a=255})
                    num:setVisible(true)
                else
                    local actionExam = cc.TintTo:create(0.1,100,100,100)
                    icon:runAction(actionExam)
                    CSResourceMgr.setButtonEnabledByNode(item, false)
                end
                if itemInfo[1] == pickedItemID then
                    CSResourceMgr.seekNodeByName(item, "hook"):setVisible(true)
                end
                local name = CSResourceMgr.seekNodeByName(item, "name")
                CSResourceMgr.setLabelStringByNode(name, ItemInfo.getItemInfoById(itemInfo[1]).name, {r=0,g=0,b=0,a=255})
                CSResourceMgr.setLabelColorByNode(name, ItemInfo.COLOR[ItemInfo.getItemInfoById(itemInfo[1]).itemRare+1])
                item:setVisible(true)
                CSResourceMgr.clickEventBindingByNode(item, function()
                    if pickedItemID ~= itemInfo[1] then
                        pickedItemID = itemInfo[1]
                        markHookOnItem(list, item)
                        CSResourceMgr.setLabelString(resName, {"db","tip2"}, CocosModuleMgr.createStringWithFormat({"PetEquip50", 
                            ItemInfo.getItemInfoById(pickedItemID).paramA}), nil, {r=0,g=0,b=0,a=255})
                    else
                        pickedItemID = nil
                        markHookOnItem(list, nil)
                        CSResourceMgr.setLabelString(resName, {"db","tip2"}, CocosModuleMgr.createStringWithFormat({"PetEquip50", 0}),
                            nil, {r=0,g=0,b=0,a=255})
                    end
                end, 1)
                list:pushBackCustomItem(item)
                item:setScale(0)
                transition.scaleTo(item, {scale=1, time=0.2})
            end)
        end

        if pickedItemID then
            CSResourceMgr.setLabelString(resName, {"db","tip2"}, CocosModuleMgr.createStringWithFormat({"PetEquip50", 
                ItemInfo.getItemInfoById(pickedItemID).paramA}), nil, {r=0,g=0,b=0,a=255})
        end
    end
end

function PickItemViewMgr.show(scene, itemsVec, defaultItemID, funcOK)
    if CSResourceMgr.getCsbObj(resName) then
        return  
    end
    
    UIStack.push("PickItemViewMgr",PickItemViewMgr.hideUI,false)
    local funcTable = {}
    local function loadCSB()
        local curLayer = CSResourceMgr.createRes(scene, resName)
        curLayer:setLocalZOrder(CocosModuleMgr.ZORDER_FLOAT)
        CSResourceMgr.setRelativePosition(resName, 320, 480)
        CSResourceMgr.getNodeByName(resName, "db"):setVisible(false)

        CSResourceMgr.clickEventBinding(resName, "close", function()
            PickItemViewMgr.hideUI()
        end)
        
        CSResourceMgr.clickEventBinding(resName, "btn_ok", function()
            PickItemViewMgr.hideUI()
            if funcOK then funcOK() end
        end)
        
        CSResourceMgr.clickEventBinding(resName, "btn_cancel", function()
            PickItemViewMgr.hideUI()
        end)
        
        initStaticData()
        
        initDynamicData(itemsVec, defaultItemID, funcTable)
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
    
    UnblockLoader.load(funcTable, "PickItemViewMgr.show")
end

function PickItemViewMgr.getPickedItemID()
    return pickedItemID
end

return PickItemViewMgr