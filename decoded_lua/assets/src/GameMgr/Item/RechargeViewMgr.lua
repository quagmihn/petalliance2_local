local RechargeViewMgr = {}

local resName = ""
local resNameBG = ""
local tabTable = nil
local activityParams = nil
local RechargeCInfoReader = nil
local RechargeCInfo = nil
local RechargeData = nil

function RechargeViewMgr.Init()
    resName = "Item/Recharge/RechargeView.csb"
    resNameBG = "Pet/Formation/FormationBGNew.csb"
    tabTable,activityParams = ActivityViewMgr.getActivitiesData()

    if RechargeCInfoReader==nil then
        RechargeCInfoReader = TxtReader.new("Config/firstRecharge.txt")
        RechargeCInfo = RechargeCInfoReader.init({"id", "name", "icon", "cost"}, 1)
    end
end

function RechargeViewMgr.setActivitiesData(vec)
    RechargeData = vec
end

function RechargeViewMgr.show(scene)
    if not NetInterface.isConnect then
        return
    end
    NetInterface.sendWithBlock("GC_GetActivitiesData_Ack", function()
        local ActivitySend = require("src.Net.Send.ActivitySend")
        ActivitySend.sendCG_GetActivitiesData_Req()
    end, function()
        UIStack.push("RechargeViewMgr", RechargeViewMgr.hide, true)
        RechargeViewMgr.open(scene)
    end, function(code)
        TipsMgr.showError(scene, code)
    end)
end

function RechargeViewMgr.open(scene)
    
    local function loadBG()
        local bgLayer = CSResourceMgr.createRes(scene, resNameBG, "RechargeViewMgr")
        bgLayer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resNameBG, 320, 480, "RechargeViewMgr")
        bgLayer:setOpacity(0)
        transition.fadeIn(bgLayer, {time=0.3})
    end

    local function loadCSB()
        local curLayer = CSResourceMgr.createRes(scene, resName)
        curLayer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resName, 320, 480)
        CSResourceMgr.setFullScreen(resName)

        local rechargeID = 0
        local getBtn = CSResourceMgr.getNodeByName(resName, "getBtn")
        CSResourceMgr.setButtonStringByNode(getBtn, "activity6", {r=0,g=0,b=0,a=255})
        CSResourceMgr.clickEventBindingByNode(getBtn, function()
            RechargeViewMgr.hide()
            PurchaseViewMgr.show(SceneMgr.getRunningScene)
        end)
        if RechargeData then
            if RechargeData.recharge then
                if RechargeData.recharge["3"]["1"].token then
                    rechargeID = 6
                else
                    rechargeID = 3
                end
            else
                rechargeID = 3
            end
        else
            rechargeID = 3
        end

        local title = CSResourceMgr.getNodeByName(resName, "title")
        CSResourceMgr.setLabelStringByNode(title, RechargeCInfo[rechargeID].name,{r=0,g=0,b=0,a=255})
        local giftBG = CSResourceMgr.getNodeByName(resName, "giftBG")
        CSResourceMgr.setSpriteTextureByNode(giftBG, RechargeCInfo[rechargeID].icon)
        local tips = CSResourceMgr.getNodeByName(resName, "tips")
        CSResourceMgr.setLabelStringByNode(tips, CocosModuleMgr.createStringWithFormat({"activity7", RechargeCInfo[rechargeID].cost}),{r=0,g=0,b=0,a=255})
        local getTips = CSResourceMgr.getNodeByName(resName, "getTips")
        CSResourceMgr.setLabelStringByNode(getTips, "activity41",{r=0,g=0,b=0,a=255})

        RechargeViewMgr.setAwardsItem(rechargeID)
    end

    local function playCSB()
        CocosModuleMgr.showUIAnimation(CSResourceMgr.getNodeByName(resName,"db"),"down")
        StatusBarMgr.showTopInfoBar(function()
            RechargeViewMgr.hide()
        end)
    end

    local funcTable = {loadBG, loadCSB, playCSB}
    loadBG()
    loadCSB()
    playCSB()
end

function RechargeViewMgr.hide()
    StatusBarMgr.hideTopInfoBar()
    CSResourceMgr.removeCSObjectByTag(resNameBG, "RechargeViewMgr")
	CSResourceMgr.removeCSObjectByTag(resName)
    UIStack.pop("RechargeViewMgr")
end

function RechargeViewMgr.setAwardsItem(id)
    if id == 6 then
        for var=1,3 do
            local gift = CSResourceMgr.getNodeByName(resName, "gift"..var)
            gift:setPositionX(-130+130*(var-1))
        end
        CSResourceMgr.getNodeByName(resName, "gift4"):setVisible(false)
    end
    for k,v in pairs(activityParams[id]) do
        for k1,v1 in pairs(v.awardVec) do
            local itemInfo,petType = RechargeViewMgr.getItemInfo(tonumber(v1[1]))
            if petType == Proto.AET_PET then
                local awardIcon = CSResourceMgr.getNodeByName(resName, "icon"..k1)
                CSResourceMgr.setSpriteTextureByNode(awardIcon, itemInfo.icon)
                awardIcon:setPosition(57,57)
                local count = CSResourceMgr.getNodeByName(resName, "count"..k1)
                CSResourceMgr.setLabelStringByNode(count, "X"..v1[2], {r=0,g=0,b=0,a=255})

                local awardElementInfo = ItemInfo.getAwardElementInfoById(tonumber(v1[1]))
                local pokeInfo = PokemonInfo.getPokemonInfoByID(awardElementInfo.elementID)
                local path = "Pet/BasicPetList_2/Stage/"..pokeInfo.rarePoint..".png"
                local gift = CSResourceMgr.getNodeByName(resName, "gift"..k1)
                gift:setScale(0.75)
                CSResourceMgr.setButtonTextureByNode(gift, path, path, path)

                CSResourceMgr.clickEventBindingByNode(gift, function()
                    StatusBarMgr.hideTopInfoBar()
                    PetInfoViewMgr.show(SceneMgr.getRunningScene, awardElementInfo.elementID, function()
                        StatusBarMgr.showTopInfoBar(function()
                            RechargeViewMgr.hide()
                        end)
                    end)
                end)
            else
                local itemType = ItemInfo.getItemType(itemInfo.id)
                local awardIcon = CSResourceMgr.getNodeByName(resName, "icon"..k1)
                local awardIconPath = nil
                if itemType == 4 then
                    local petPieceInfo = ItemInfo.getPetPieceInfoById(itemInfo.id)
                    local pokemonInfo = PokemonInfo.getPokemonInfoByID(PokemonInfo.getGeneInfoByID(petPieceInfo.pokeID).petID)
                    awardIconPath =  "Pet/PetIcon/"..pokemonInfo.icon..".png"
                    awardIcon:setScale(0.68)
                    local mask = CSResourceMgr.getNodeByName(resName, "mask"..k1)
                    mask:setVisible(true)
                    mask:setScale(0.65)
                else
                    awardIconPath = itemInfo.icon
                end
                CSResourceMgr.setSpriteTextureByNode(awardIcon, awardIconPath)

                local count = CSResourceMgr.getNodeByName(resName, "count"..k1)
                CSResourceMgr.setLabelStringByNode(count, "X"..v1[2], {r=0,g=0,b=0,a=255})

                local gift = CSResourceMgr.getNodeByName(resName, "gift"..k1)
                local path = ItemInfo.getItemRareBGImage(itemInfo.id)
                CSResourceMgr.setButtonTextureByNode(gift, path, path, path)

                CSResourceMgr.clickEventBindingByNode(gift, function()
                    ItemInfoViewMgr.show({id = itemInfo.id}, false)
                end)
            end
        end
    end
end

function RechargeViewMgr.getItemInfo(id)
    local itemInfo = {}
    local awardElementInfo = ItemInfo.getAwardElementInfoById(id)
    if awardElementInfo.elementType == 1 then
        itemInfo = ItemInfo.getItemInfoById(9998)
    elseif awardElementInfo.elementType == 2 then
        itemInfo = ItemInfo.getItemInfoById(9999)
    elseif awardElementInfo.elementType == 11 then
        itemInfo = ItemInfo.getItemInfoById(9996)
    elseif awardElementInfo.elementType == Proto.AET_PET then
        local pokeInfo = PokemonInfo.getPokemonInfoByID(awardElementInfo.elementID)
        itemInfo.icon = "Pet/PetIcon/"..pokeInfo.icon..".png"
        itemInfo.name = pokeInfo.name
        itemInfo.itemRare = pokeInfo.rarePoint
    else
        itemInfo = ItemInfo.getItemInfoById(awardElementInfo.elementID)
    end
    return itemInfo,awardElementInfo.elementType
end

function RechargeViewMgr.checkRechargeTime(timeS)
    local time = CharInfo.getServerTime()
    local timeM = RechargeViewMgr.turnTimeData(timeS)
    local dayCount = CocosModuleMgr.getDayTimeDiff(time, timeM, 21600)

    if dayCount == 0 then
        return false 
    else
        return true
    end
end

function RechargeViewMgr.turnTimeData(timeData)
    local timeVec = {}
    timeVec.year = string.sub(timeData,1,4)
    timeVec.month = string.sub(timeData,5,6)
    timeVec.day = string.sub(timeData,7,8)
    timeVec.hour = string.sub(timeData,9,10)

    return os.time({year=timeVec.year, month=timeVec.month, day=timeVec.day, hour=timeVec.hour})
end

function RechargeViewMgr.setRedPoint()
    StatusBarMgr.addRedPoint(7)
    if not RechargeData then
        return
    end
    if RechargeData.recharge then
        if RechargeViewMgr.checkRechargeTime(RechargeData.recharge["3"]["1"].time) then
            StatusBarMgr.hideRechargeBtn(true)
        else
            StatusBarMgr.hideRechargeBtn(false)
        end
        if RechargeData.recharge["6"] then
            if RechargeData.recharge["6"]["1"] then
                local isCheck = RechargeViewMgr.checkRechargeTime(RechargeData.recharge["6"]["1"].time)
                if not isCheck then
                    StatusBarMgr.hideRechargeBtn(false)
                else 
                    StatusBarMgr.hideRechargeBtn(true)    
                end
            end
        end
    end
end

return RechargeViewMgr