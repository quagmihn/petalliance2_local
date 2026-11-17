local CollectPetActivityViewMgr = {}

local resName = ""
local itemNodes = {}
local ActivityPokemonInfo = nil
local petWikiActivity = {}
local pokeAchievementIDs = {}
local petWikiNum = 0

function CollectPetActivityViewMgr.Init()
    resName = "Item/Activity/CollectPetActivityView.csb"
    itemNodes = {}
    petWikiActivity = {}
    pokeAchievementIDs = {}
    petWikiNum = 0

    ActivityPokemonInfo = ActivityInfo.getActivityPokemonAchievementAllInfo()
end

function CollectPetActivityViewMgr.setPetWikiActivity(pokeID)
    table.insert(petWikiActivity,pokeID)
    if #petWikiActivity == petWikiNum then
        CollectPetActivityViewMgr.open(SceneMgr.getRunningScene)
    end
end

function CollectPetActivityViewMgr.setPokeAchievementIDs(vec)
    pokeAchievementIDs = vec
end

function CollectPetActivityViewMgr.setPetWikiNum(num)
    petWikiNum = num
end

function CollectPetActivityViewMgr.show(scene)
    if not NetInterface.isConnect then
        return
    end
    NetInterface.sendWithBlock("GC_GetPokemonAchievementsAct_Ack", function()
        local ActivitySend = require("src.Net.Send.ActivitySend")
        ActivitySend.sendCG_GetPokemonAchievementsAct_Req()
    end, function()
        NetInterface.sendWithBlock("GC_GetPetWikiActivity_Ack", function()
            local ActivitySend = require("src.Net.Send.ActivitySend")
            ActivitySend.sendCG_GetPetWikiActivity_Req()
        end, nil, function(code)
            TipsMgr.showError(scene, code)
        end)
    end, function(code)
        TipsMgr.showError(scene, code)
    end)
end

function CollectPetActivityViewMgr.open(scene)
    HalloweenCapsuleEggView.hideTopInfoBar(false)
    UIStack.push("CollectPetActivityViewMgr", CollectPetActivityViewMgr.hide, false)
    local function loadCSB()
        local curLayer = CSResourceMgr.createRes(scene, resName)
        curLayer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resName, 320, 480)

        local title = CSResourceMgr.getNodeByName(resName, "title")
        CSResourceMgr.setLabelStringByNode(title, "collectPet1", {r=0,g=0,b=0,a=255})
        title:setFontSize(28)

        local closeBtn = CSResourceMgr.getNodeByName(resName, "closeBtn")
        CSResourceMgr.clickEventBindingByNode(closeBtn, function()
            CollectPetActivityViewMgr.hide()
        end)

        CollectPetActivityViewMgr.setAchievementItem()
    end

    local function playCSB()
        CocosModuleMgr.showUIAnimation(CSResourceMgr.getNodeByName(resName,"diban"),"down")
    end

    loadCSB()
    playCSB()
end

function CollectPetActivityViewMgr.hide()
    local list = CSResourceMgr.getNodeByName(resName, "list")
    list:removeAllItems()
    itemNodes = {}
    petWikiActivity = {}
    pokeAchievementIDs = {}
    petWikiNum = 0
    HalloweenCapsuleEggView.hideTopInfoBar(true)
    CSResourceMgr.removeCSObjectByTag(resName)
    UIStack.pop("CollectPetActivityViewMgr")
end

function CollectPetActivityViewMgr.setAchievementItem()
    UnblockLoader.cancel("CollectPetActivityViewMgr")
    local funcTable = {}
    local list = CSResourceMgr.getNodeByName(resName, "list")
    list:removeAllItems()

    local function setButtonGray(parent)
        parent:setColor({r=88,g=88,b=88,a=255})
        CSResourceMgr.seekNodeByName(parent,"s"):setColor({r=88,g=88,b=88,a=255})
    end

    local function revertButton(parent)
        parent:setColor({r=255,g=255,b=255,a=255})
        CSResourceMgr.seekNodeByName(parent,"s"):setColor({r=255,g=255,b=255,a=255})
    end

    local tempVec1,tempVec2,tempVec3 = CollectPetActivityViewMgr.checkPokeAchievement(ActivityPokemonInfo)

    if next(tempVec1) then
        for k,v in pairs(tempVec1) do
            table.insert(funcTable, function()
                itemNodes[v.id] = CSResourceMgr.getNodeByName(resName, "collectItem"):clone()
                itemNodes[v.id]:setVisible(true)
                list:pushBackCustomItem(itemNodes[v.id])

                for var=1,2 do
                    local frame = CSResourceMgr.seekNodeByName(itemNodes[v.id], "frame"..var)
                    frame:setColor({r=6,g=47,b=64})
                end

                local tips1 = CSResourceMgr.seekNodeByName(itemNodes[v.id], "tips1")
                CSResourceMgr.setLabelColorByNode(tips1, {r=120,g=203,b=245,a=255})
                CSResourceMgr.setLabelStringByNode(tips1, v.name, {r=0,g=0,b=0,a=255})
                local tips2 = CSResourceMgr.seekNodeByName(itemNodes[v.id], "tips2")
                CSResourceMgr.setLabelColorByNode(tips2, {r=255,g=255,b=0,a=255})
                CSResourceMgr.setLabelStringByNode(tips2, "collectPet2", {r=0,g=0,b=0,a=255})

                for k1,v1 in pairs(v.petIDs) do
                    local item = ItemInfo.getPetIconById2(v1, nil, nil, true)
                    CSResourceMgr.seekNodeByName(item,"attr"):hide()
                    CSResourceMgr.seekNodeByName(item,"attrBack"):hide()
                    CSResourceMgr.seekNodeByName(item,"rare"):hide()
                    CSResourceMgr.seekNodeByName(item,"rareBack"):hide()
                    item:addTo(itemNodes[v.id])
                    item:setScale(0.7,0.7)
                    item:setPosition(100+(tonumber(k1)-1)*110,245)
                    local itemname = CSResourceMgr.seekNodeByName(item,"name")
                    itemname:setPosition(70,-8)
                    itemname:setFontSize(24)

                    CSResourceMgr.clickEventBindingByNode(item, function()
                        PetInfoViewMgr.show(SceneMgr.getRunningScene, v1)
                    end)
                end

                local awardsVec = {}
                for k1,v1 in pairs(v.awardIDs) do
                    local awardElementInfo = ItemInfo.getAwardElementInfoById(v1)
                    local itemInfo = {}
                    if awardElementInfo.elementType == 1 then
                        itemInfo = ItemInfo.getItemInfoById(9998)
                    elseif awardElementInfo.elementType == 2 then
                        itemInfo = ItemInfo.getItemInfoById(9999)
                    elseif awardElementInfo.elementType == 11 then
                        itemInfo = ItemInfo.getItemInfoById(9996)
                    else
                        itemInfo = ItemInfo.getItemInfoById(awardElementInfo.elementID)
                    end
                    local item = ItemInfo.getItemIconById(itemInfo.id, v.count[k1], nil, true) 
                    item:addTo(itemNodes[v.id])
                    item:setScale(0.6,0.6)
                    item:setPosition(100+(tonumber(k1)-1)*100,75)

                    CSResourceMgr.clickEventBindingByNode(item, function()
                        ItemInfoViewMgr.show({id = itemInfo.id,type = 1}, false)
                    end)
                    table.insert(awardsVec,{itemInfo.id,v.count[k1]})
                end

                local lq_Btn = CSResourceMgr.seekNodeByName(itemNodes[v.id], "lq_Btn")
                CSResourceMgr.setButtonStringByNode(lq_Btn, "collectPet3", {r=0,g=0,b=0,a=255})
                CSResourceMgr.clickEventBindingByNode(lq_Btn, function()
                    NetInterface.sendWithBlock("GC_FinishPokemonAchievementActivity_Ack", function()
                        local ActivitySend = require("src.Net.Send.ActivitySend")
                        ActivitySend.sendCG_FinishPokemonAchievementActivity_Req(v.id)
                    end, function()
                        CSResourceMgr.setButtonEnabledByNode(lq_Btn, false)
                        CSResourceMgr.setButtonStringByNode(lq_Btn, "collectPet4", {r=0,g=0,b=0,a=255})
                        AwardsListMgr.show(SceneMgr.getRunningScene, awardsVec)
                    end, function(code)
                        TipsMgr.showError(scene, code)
                    end)
                end)
            end)
        end
    end

    if next(tempVec2) then
        for k,v in pairs(tempVec2) do
            table.insert(funcTable, function()
                itemNodes[v.id] = CSResourceMgr.getNodeByName(resName, "collectItem"):clone()
                itemNodes[v.id]:setVisible(true)
                list:pushBackCustomItem(itemNodes[v.id])

                for var=1,2 do
                    local frame = CSResourceMgr.seekNodeByName(itemNodes[v.id], "frame"..var)
                    frame:setColor({r=6,g=47,b=64})
                end

                local tips1 = CSResourceMgr.seekNodeByName(itemNodes[v.id], "tips1")
                CSResourceMgr.setLabelColorByNode(tips1, {r=120,g=203,b=245,a=255})
                CSResourceMgr.setLabelStringByNode(tips1, v.name, {r=0,g=0,b=0,a=255})
                local tips2 = CSResourceMgr.seekNodeByName(itemNodes[v.id], "tips2")
                CSResourceMgr.setLabelColorByNode(tips2, {r=255,g=255,b=0,a=255})
                CSResourceMgr.setLabelStringByNode(tips2, "collectPet2", {r=0,g=0,b=0,a=255})

                for k1,v1 in pairs(v.petIDs) do
                    local item = ItemInfo.getPetIconById2(v1, nil, nil, true)
                    CSResourceMgr.seekNodeByName(item,"attr"):hide()
                    CSResourceMgr.seekNodeByName(item,"attrBack"):hide()
                    CSResourceMgr.seekNodeByName(item,"rare"):hide()
                    CSResourceMgr.seekNodeByName(item,"rareBack"):hide()
                    item:addTo(itemNodes[v.id])
                    item:setScale(0.7,0.7)
                    item:setPosition(100+(tonumber(k1)-1)*110,245)
                    local itemname = CSResourceMgr.seekNodeByName(item,"name")
                    itemname:setPosition(70,-8)
                    itemname:setFontSize(24)

                    setButtonGray(item)
                    for k2,v2 in pairs(petWikiActivity) do
                        if v1 == v2 then
                            revertButton(item)
                        end
                    end

                    CSResourceMgr.clickEventBindingByNode(item, function()
                        PetInfoViewMgr.show(SceneMgr.getRunningScene, v1)
                    end)
                end

                for k1,v1 in pairs(v.awardIDs) do
                    local awardElementInfo = ItemInfo.getAwardElementInfoById(v1)
                    local itemInfo = {}
                    if awardElementInfo.elementType == 1 then
                        itemInfo = ItemInfo.getItemInfoById(9998)
                    elseif awardElementInfo.elementType == 2 then
                        itemInfo = ItemInfo.getItemInfoById(9999)
                    elseif awardElementInfo.elementType == 11 then
                        itemInfo = ItemInfo.getItemInfoById(9996)
                    else
                        itemInfo = ItemInfo.getItemInfoById(awardElementInfo.elementID)
                    end
                    local item = ItemInfo.getItemIconById(itemInfo.id, v.count[k1], nil, true) 
                    item:addTo(itemNodes[v.id])
                    item:setScale(0.6,0.6)
                    item:setPosition(100+(tonumber(k1)-1)*100,75)

                    CSResourceMgr.clickEventBindingByNode(item, function()
                        ItemInfoViewMgr.show({id = itemInfo.id,type = 1}, false)
                    end)
                end

                local lq_Btn = CSResourceMgr.seekNodeByName(itemNodes[v.id], "lq_Btn")
                CSResourceMgr.setButtonEnabledByNode(lq_Btn, false)
                CSResourceMgr.setButtonStringByNode(lq_Btn, "collectPet3", {r=0,g=0,b=0,a=255})
            end)
        end
    end

    if next(tempVec3) then
        for k,v in pairs(tempVec3) do
            table.insert(funcTable, function()
                itemNodes[v.id] = CSResourceMgr.getNodeByName(resName, "collectItem"):clone()
                itemNodes[v.id]:setVisible(true)
                list:pushBackCustomItem(itemNodes[v.id])

                for var=1,2 do
                    local frame = CSResourceMgr.seekNodeByName(itemNodes[v.id], "frame"..var)
                    frame:setColor({r=6,g=47,b=64})
                end

                local tips1 = CSResourceMgr.seekNodeByName(itemNodes[v.id], "tips1")
                CSResourceMgr.setLabelColorByNode(tips1, {r=120,g=203,b=245,a=255})
                CSResourceMgr.setLabelStringByNode(tips1, v.name, {r=0,g=0,b=0,a=255})
                local tips2 = CSResourceMgr.seekNodeByName(itemNodes[v.id], "tips2")
                CSResourceMgr.setLabelColorByNode(tips2, {r=255,g=255,b=0,a=255})
                CSResourceMgr.setLabelStringByNode(tips2, "collectPet2", {r=0,g=0,b=0,a=255})

                for k1,v1 in pairs(v.petIDs) do
                    local item = ItemInfo.getPetIconById2(v1, nil, nil, true)
                    CSResourceMgr.seekNodeByName(item,"attr"):hide()
                    CSResourceMgr.seekNodeByName(item,"attrBack"):hide()
                    CSResourceMgr.seekNodeByName(item,"rare"):hide()
                    CSResourceMgr.seekNodeByName(item,"rareBack"):hide()
                    item:addTo(itemNodes[v.id])
                    item:setScale(0.7,0.7)
                    item:setPosition(100+(tonumber(k1)-1)*110,245)
                    local itemname = CSResourceMgr.seekNodeByName(item,"name")
                    itemname:setPosition(70,-8)
                    itemname:setFontSize(24)

                    CSResourceMgr.clickEventBindingByNode(item, function()
                        PetInfoViewMgr.show(SceneMgr.getRunningScene, v1)
                    end)
                end

                for k1,v1 in pairs(v.awardIDs) do
                    local awardElementInfo = ItemInfo.getAwardElementInfoById(v1)
                    local itemInfo = {}
                    if awardElementInfo.elementType == 1 then
                        itemInfo = ItemInfo.getItemInfoById(9998)
                    elseif awardElementInfo.elementType == 2 then
                        itemInfo = ItemInfo.getItemInfoById(9999)
                    elseif awardElementInfo.elementType == 11 then
                        itemInfo = ItemInfo.getItemInfoById(9996)
                    else
                        itemInfo = ItemInfo.getItemInfoById(awardElementInfo.elementID)
                    end
                    local item = ItemInfo.getItemIconById(itemInfo.id, v.count[k1], nil, true) 
                    item:addTo(itemNodes[v.id])
                    item:setScale(0.6,0.6)
                    item:setPosition(100+(tonumber(k1)-1)*100,75)

                    CSResourceMgr.clickEventBindingByNode(item, function()
                        ItemInfoViewMgr.show({id = itemInfo.id,type = 1}, false)
                    end)
                end

                local lq_Btn = CSResourceMgr.seekNodeByName(itemNodes[v.id], "lq_Btn")
                CSResourceMgr.setButtonEnabledByNode(lq_Btn, false)
                CSResourceMgr.setButtonStringByNode(lq_Btn, "collectPet4", {r=0,g=0,b=0,a=255})
            end)
        end
    end
    UnblockLoader.load(funcTable, "CollectPetActivityViewMgr")
end

function CollectPetActivityViewMgr.checkPokeAchievement(vec)
    local tempVec1 = {}
    local tempVec2 = {}
    local tempVec3 = {}

    for k,v in pairs(vec) do
        local getCount = 0
        for k1,v1 in pairs(v.petIDs) do
            for k2,v2 in pairs(petWikiActivity) do
                if v1 == v2 then
                    getCount = getCount + 1
                end
            end
        end

        local canGet = true
        if #v.petIDs == getCount then
            for k1,v1 in pairs(pokeAchievementIDs) do
                if v.id == v1 then
                    canGet = false
                    table.insert(tempVec3,v)
                end
            end
            if canGet then
                table.insert(tempVec1,v)
            end
        else
            table.insert(tempVec2,v)
        end
    end

    return tempVec1,tempVec2,tempVec3
end

return CollectPetActivityViewMgr