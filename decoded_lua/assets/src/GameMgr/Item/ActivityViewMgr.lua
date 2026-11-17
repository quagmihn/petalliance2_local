local ActivityViewMgr = {}

ActivityViewMgr.TAB_NUM = ActivityInfo.TAB_NUM

local resName = ""
local resNameItem = ""
local resNameBG = ""
local resNameAward = ""
local itemNodes = {}
local curTab = 1
local tabTable = nil
local activityParams = nil
local ActivityCInfoReader = nil
local ActivityCInfo = nil
local ActivitiesData = nil
local loginDay = nil
local hasToken = false
local upgradeVec = nil
local growfund = nil
local ActivityInterface = require("src.GameMgr.Item.ActivityInterface")
local scheduler = require("src.framework.scheduler")
local tabRedPoint = {false,false,false}
local activityHandler1 = nil
local activityHandler2 = nil
local activityHandler3 = nil
local activityHandler4 = nil
local compoundPetInfo = {}
local eggFlag = false
local showRedPoint = false
local GMCount = 0
local GMParams = {}
local compoundPetInfo = {}

local iconPathVec = {
    "Item/Activity/activity_figure_parts_lv10.png",
    "Item/Activity/activity_figure_parts_lv15.png",
    "Item/Activity/activity_figure_parts_lv20.png",
    "Item/Activity/activity_figure_parts_lv25.png",
    "Item/Activity/activity_figure_parts_lv30.png",
    "Item/Activity/activity_figure_parts_lv35.png",
    "Item/Activity/activity_figure_parts_lv40.png"
}

local iconPathVec2 = {
    "Item/Activity/activity_figure_parts_lv10.png",
    "Item/Activity/activity_figure_parts_lv15.png",
    "Item/Activity/activity_figure_parts_lv25.png",
    "Item/Activity/activity_figure_parts_lv30.png",
    "Item/Activity/activity_figure_parts_lv35.png",
    "Item/Activity/activity_figure_parts_lv40.png",
    "Item/Activity/activity_figure_parts_lv45.png",
    "Item/Activity/activity_figure_parts_lv50.png"
}

SevenDaysActivity = require("src.GameMgr.Item.SevenDaysActivity")
local sevenDaysActivity = SevenDaysActivity
function ActivityViewMgr.setActivitiesData(vec)
    ActivitiesData = vec
end

function ActivityViewMgr.getActivitiesData()
    return tabTable,activityParams
end

function ActivityViewMgr.getCatchPetValue()
    if not activityParams[133] then
    	return {value=0}
    end
    if not activityParams[133][1] then
        return {value=0}
    end
    return activityParams[133][1]
end

function ActivityViewMgr.getCompoundPetInfo()
    return compoundPetInfo
end

function ActivityViewMgr.setGMParamsActivity(vec)
    table.insert(GMParams,vec)
    if #GMParams == GMCount then
        UIStack.push("ActivityViewMgr", ActivityViewMgr.hide, true)
        ActivityViewMgr.open(SceneMgr.getRunningScene)
    end
end

function ActivityViewMgr.setGMCount(num)
    GMCount = num
    if num == 0 then
        UIStack.push("ActivityViewMgr", ActivityViewMgr.hide, true)
        ActivityViewMgr.open(SceneMgr.getRunningScene)
    end
end

function ActivityViewMgr.Init()
    resName = "Item/Activity/ActivityView.csb"
    resNameItem = "Item/Activity/ActivityItem.csb"
    resNameBG = "Pet/Formation/FormationBGNew.csb"
    resNameAward = "Item/Activity/ActivityRewardList.csb"
    CSResourceMgr.createRes(nil, resNameItem, nil, true)
    itemNodes = {}
    GMParams = {}
    curTab = 1
    loginDay = 1
    hasToken = false
    upgradeVec = nil
    growfund = nil
    GMCount = 0
    tabRedPoint = {false,false,false}
    activityHandler1 = nil
    activityHandler2 = nil
    activityHandler3 = nil
    activityHandler4 = nil
    showRedPoint = false
    compoundPetInfo = {}
    eggFlag = false

    if ActivityCInfoReader==nil then
        ActivityCInfoReader = TxtReader.new("Config/activityC.txt")
        ActivityCInfo = ActivityCInfoReader.init({"id", "name", "icon"}, 1)
    end

    if not tabTable then
        tabTable, activityParams = ActivityInfo.getActivitiesData()
    end

    sevenDaysActivity.initData()
end

function ActivityViewMgr.show(scene)
    if not NetInterface.isConnect then
        return
    end
    NetInterface.sendWithBlock("GC_GetActivitiesData_Ack", function()
        local ActivitySend = require("src.Net.Send.ActivitySend")
        ActivitySend.sendCG_GetActivitiesData_Req()
    end, function()
        UIStack.push("ActivityViewMgr", ActivityViewMgr.hide, true)
        ActivityViewMgr.open(scene)
    end, function(code)
        TipsMgr.showError(scene, code)
    end)
    -- GMParams = {}
    -- if not NetInterface.isConnect then
    --     return
    -- end
    -- NetInterface.sendWithBlock("GC_GetGMActivities_Ack", function()
    --     local ActivitySend = require("src.Net.Send.ActivitySend")
    --     ActivitySend.sendCG_GetGMActivities_Req(0)
    -- end, function()
    --     NetInterface.sendWithBlock("GC_GetActivitiesData_Ack", function()
    --         local ActivitySend = require("src.Net.Send.ActivitySend")
    --         ActivitySend.sendCG_GetActivitiesData_Req()
    --     end, nil, function(code)
    --         TipsMgr.showError(scene, code)
    --     end)
    -- end, function(code)
    --     TipsMgr.showError(scene, code)
    -- end)
end

function ActivityViewMgr.open(scene)
    if next(GMParams) then
        for k,v in pairs(GMParams) do
            activityParams[v.id] = {}
            local vec = lua_string_split(v.params,"@")
            for k1,v1 in pairs(vec) do
                activityParams[v.id][k1] = {}
                activityParams[v.id][k1].awardVec = {}
                activityParams[v.id][k1].mCash = {}
                local vec1 = lua_string_split(v1,",")
                if v.type == ActivityInfo.PurchaseAward then
                    local tempID = 2
                    if k1 == 1 then
                        tempID = 4
                    end
                    activityParams[v.id][k1].mCash = tonumber(vec1[tempID])
                    local vec2 = lua_string_split(vec1[tempID+2],"&")
                    for k2,v2 in pairs(vec2) do
                        local vec2 = lua_string_split(v2,"_")
                        table.insert(activityParams[v.id][k1].awardVec,vec2)
                    end
                end
            end
            local isSert = true
            for k1,v1 in pairs(tabTable[v.page]) do
                if v1.id == v.id then
                    isSert = false
                end
            end
            if isSert then
                table.insert(tabTable[v.page],v)
            end
        end
    end

    local function loadBG()
        local bgLayer = CSResourceMgr.createRes(scene, resNameBG, "ActivityViewMgr")
        bgLayer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resNameBG, 320, 480, "ActivityViewMgr")
        bgLayer:setOpacity(0)
        transition.fadeIn(bgLayer, {time=0.3})
    end

    local function loadCSB()
        local curLayer = CSResourceMgr.createRes(scene, resName)
        curLayer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resName, 320, 480)

        ActivityViewMgr.setRedPoint()

        local diff = CocosModuleMgr.getScreenSizeDiff()
        local list = CSResourceMgr.getNodeByName(resName, "list")
        local ltsize = list:getContentSize()
        local ltposy = list:getPositionY()
        list:setPositionY(ltposy+diff/2.5)
        list:setContentSize(ltsize.width, ltsize.height+diff)
        local topTab = CSResourceMgr.getNodeByName(resName, "topTab")
        local tpposy = topTab:getPositionY()
        topTab:setPositionY(tpposy+diff/2.5)

        --【【这里是七日活动的地盘
        sevenDaysActivity.onInitUI(curLayer)

        CSResourceMgr.clickEventBinding(resName, "tab4", function()
            local icon = CSResourceMgr.getNodeByName(resName, "icon4")
            icon:setPositionY(52)
            icon:setScale(1.3)
            if curTab ~= var then
                local icon = CSResourceMgr.getNodeByName(resName, "icon"..curTab)
                icon:setPositionY(44)
                icon:setScale(1)
            end
            curTab = 4
            sevenDaysActivity.onTabChange(4,resName,list)
        end)
        ---------------------------------------------------------------------
        for var=1, ActivityViewMgr.TAB_NUM do
            if #tabTable[var] == 0 then
                local btn = CSResourceMgr.getNodeByName(resName, "tab"..var)
                btn:setVisible(false)
            else
                local tabtext = CSResourceMgr.getNodeByName(resName, "Label"..var)
                CSResourceMgr.setLabelColorByNode(tabtext, {r=255,g=255,b=255,a=255})
                CSResourceMgr.setLabelStringByNode(tabtext, ActivityCInfo[var].name, {r=0,g=0,b=0,a=255})
                local icon = CSResourceMgr.getNodeByName(resName, "icon"..var)
                CSResourceMgr.setSpriteTextureByNode(icon, ActivityCInfo[var].icon)
            end
        end

        for i=1,3 do
            CSResourceMgr.getNodeByName(resName, "redpoint"..i):setVisible(tabRedPoint[i])
        end

        for var=1, ActivityViewMgr.TAB_NUM do
            if var == 1 then
                local icon = CSResourceMgr.getNodeByName(resName, "icon1")
                icon:setPositionY(52)
                icon:setScale(1.3)
            end
            local icon = CSResourceMgr.getNodeByName(resName, "icon"..var)
            CSResourceMgr.clickEventBinding(resName, "tab"..var, function()
                icon:setPositionY(52)
                icon:setScale(1.3)
                if curTab ~= var then
                    local icon = CSResourceMgr.getNodeByName(resName, "icon"..curTab)
                    icon:setPositionY(44)
                    icon:setScale(1)
                end
                curTab = var
                ActivityViewMgr.changeTab(var)
            end)
        end
        
        local dayCount = SevenDaysActivity.getRoleCreateDay()
        if dayCount < 8 then 
            sevenDaysActivity.onTabChange(4,resName,list)
            curTab = 4
         else 
            curTab = 1
            ActivityViewMgr.changeTab(curTab)
         end

    end

    local function playCSB()
        CocosModuleMgr.showUIAnimation(CSResourceMgr.getNodeByName(resName,"diban"),"down")
        StatusBarMgr.showTopInfoBar(function()
            ActivityViewMgr.hide()
        end)
    end

    local funcTable = {loadBG, loadCSB, playCSB}
    loadBG()
    loadCSB()
    playCSB()
end

function ActivityViewMgr.hide()
    StatusBarMgr.hideTopInfoBar()
    local list = CSResourceMgr.getNodeByName(resName, "list")
    list:removeAllItems()
    itemNodes = {}
    compoundPetInfo = {}
    CSResourceMgr.removeCSObjectByTag(resNameBG, "ActivityViewMgr")
    CSResourceMgr.removeCSObjectByTag(resNameAward)
	CSResourceMgr.removeCSObjectByTag(resName)
    UIStack.pop("ActivityViewMgr")
end

function ActivityViewMgr.getTableCount(table)
    local i = 0
    for k,v in pairs(table) do
        i = i + 1
    end
    return i
end

function ActivityViewMgr.getItemInfo(id)
    local itemInfo = {}
    local awardElementInfo = ItemInfo.getAwardElementInfoById(id)
    local rType = awardElementInfo.elementType
    
    if rType==3 then
        itemInfo = ItemInfo.getItemInfoById(awardElementInfo.elementID)
    elseif rType==5 then
        local pokeInfo = PokemonInfo.getPokemonInfoByID(awardElementInfo.elementID)
        itemInfo.icon = "Pet/PetIcon/"..pokeInfo.icon..".png"
        itemInfo.name = pokeInfo.name
        itemInfo.itemRare = pokeInfo.rarePoint
        itemInfo.pokeID = awardElementInfo.elementID
    else
        local itemId = ItemInfo.AWARD[rType]
        if itemId==0 then
        	itemId = 1
        end
        itemInfo = ItemInfo.getItemInfoById(itemId)
    end
    
    return itemInfo, rType
end

function ActivityViewMgr.changeTab(tabid)
    for var=1, ActivityViewMgr.TAB_NUM do
        CSResourceMgr.setButtonEnabled(resName, "tab"..var, true)
    end
    CSResourceMgr.setButtonEnabled(resName, "tab"..tabid, false)

    local weekDay = tonumber(CocosModuleMgr.getTimeStr(nil,6))
    
    local list = CSResourceMgr.getNodeByName(resName, "list")
    list:removeAllItems()
    sevenDaysActivity.onTabChange(tabid,resName,list)
    for k,v in pairs(tabTable[tabid]) do
        local res, loginTime, beginTime, lastTime = ActivityInfo.checkActivityValid(v)
        if res then
            itemNodes[v.id] = CSResourceMgr.getNodeByName(resNameItem, "diban"):clone()
            list:pushBackCustomItem(itemNodes[v.id])
            local lq_Btn = CSResourceMgr.seekNodeByName(itemNodes[v.id], "lq_Btn")
            CSResourceMgr.setButtonStringByNode(lq_Btn, "recharge26", {r=0,g=0,b=0,a=255})
            if v.type == ActivityInfo.FirstLogin then
                local awardsVec = {}
                for k1,v1 in pairs(activityParams[v.id]) do
                    for k2,v2 in pairs(v1.awardVec) do
                        local itemInfo,petType = ActivityViewMgr.getItemInfo(tonumber(v2[1]))
                        if petType == Proto.AET_PET then
                            local awardIcon = CSResourceMgr.seekNodeByName(itemNodes[v.id], "awardIcon"..k2)
                            CSResourceMgr.setSpriteTextureByNode(awardIcon, itemInfo.icon)
                            awardIcon:setScale(0.8)
                            local label = CSResourceMgr.seekNodeByName(itemNodes[v.id], "label"..k2)
                            CSResourceMgr.setLabelColorByNode(label, ItemInfo.COLOR[itemInfo.itemRare+1])
                            CSResourceMgr.setLabelStringByNode(label, itemInfo.name, {r=0,g=0,b=0,a=255})
                            local count = CSResourceMgr.seekNodeByName(itemNodes[v.id], "count"..k2)
                            CSResourceMgr.setLabelStringByNode(count, "X"..v2[2], {r=0,g=0,b=0,a=255})
                        else
                            local awardIcon = CSResourceMgr.seekNodeByName(itemNodes[v.id], "awardIcon"..k2)
                            CSResourceMgr.setSpriteTextureByNode(awardIcon, itemInfo.icon)
                            local label = CSResourceMgr.seekNodeByName(itemNodes[v.id], "label"..k2)
                            CSResourceMgr.setLabelColorByNode(label, ItemInfo.COLOR[itemInfo.itemRare+1])
                            CSResourceMgr.setLabelStringByNode(label, itemInfo.name, {r=0,g=0,b=0,a=255})
                            local count = CSResourceMgr.seekNodeByName(itemNodes[v.id], "count"..k2)
                            CSResourceMgr.setLabelStringByNode(count, "X"..v2[2], {r=0,g=0,b=0,a=255})
                            table.insert(awardsVec,{itemInfo.id,v2[2]})
                        end
                    end
                end
                if ActivitiesData.firstLogin.token then
                    hasToken = true
                end
                if hasToken then
                    CSResourceMgr.setButtonStringByNode(lq_Btn, "recharge27", {r=0,g=0,b=0,a=255})
                    CSResourceMgr.setButtonEnabledByNode(lq_Btn, false)
                else
                    CSResourceMgr.clickEventBindingByNode(lq_Btn, function()
                        NetInterface.sendWithBlock("GC_FetchFirstLoginAwards_Ack", function()
                            local ActivitySend = require("src.Net.Send.ActivitySend")
                            ActivitySend.sendCG_FetchFirstLoginAwards_Req()
                        end, function()
                            ActivityViewMgr.showGetAwards(awardsVec)
                            hasToken = true
                            ActivityViewMgr.setRedPoint()
                            CSResourceMgr.setButtonEnabledByNode(lq_Btn, false)
                        end, function(code)
                            TipsMgr.showError(scene, code)
                        end,nil,false)
                    end)
                end
            elseif v.type == ActivityInfo.FetchLogin then
                local awardsVec = {}
                if ActivitiesData.login.days and loginDay <= ActivitiesData.login.count then
                    loginDay = ActivityViewMgr.getTableCount(ActivitiesData.login.days) + 1
                end
                local function setItemCover()
                    if loginDay > 1 then
                        for var=1,loginDay-1 do
                            local cover = CSResourceMgr.seekNodeByName(itemNodes[v.id], "cover"..var)
                            cover:setVisible(true)
                            local frame = CSResourceMgr.seekNodeByName(itemNodes[v.id], "frame"..var)
                            frame:setColor({r=0,g=0,b=0,a=255})
                            frame:setOpacity(160)
                        end
                    end
                end
                for var=1,7 do
                    for k1,v1 in pairs(activityParams[v.id][var].awardVec) do
                        local itemInfo,petType = ActivityViewMgr.getItemInfo(tonumber(v1[1]))
                        if petType == Proto.AET_PET then
                            local awardIcon = CSResourceMgr.seekNodeByName(itemNodes[v.id], "loginIcon"..var)
                            CSResourceMgr.setSpriteTextureByNode(awardIcon, itemInfo.icon)
                            awardIcon:setScale(0.6)
                            local label = CSResourceMgr.seekNodeByName(itemNodes[v.id], "loginLabel"..var)
                            CSResourceMgr.setLabelColorByNode(label, ItemInfo.COLOR[itemInfo.itemRare+1])
                            CSResourceMgr.setLabelStringByNode(label, itemInfo.name, {r=0,g=0,b=0,a=255})
                            local count = CSResourceMgr.seekNodeByName(itemNodes[v.id], "loginCount"..var)
                            CSResourceMgr.setLabelStringByNode(count, "X"..v1[2], {r=0,g=0,b=0,a=255})
                        else
                            local itemType = ItemInfo.getItemType(itemInfo.id)
                            local awardIcon = CSResourceMgr.seekNodeByName(itemNodes[v.id], "loginIcon"..var)
                            local awardIconPath = nil
                            if itemType == 4 then
                                local petPieceInfo = ItemInfo.getPetPieceInfoById(itemInfo.id)
                                local pokemonInfo = PokemonInfo.getPokemonInfoByID(PokemonInfo.getGeneInfoByID(petPieceInfo.pokeID).petID)
                                awardIconPath =  "Pet/PetIcon/"..pokemonInfo.icon..".png"
                                awardIcon:setScale(0.62)
                                local mask = CSResourceMgr.seekNodeByName(itemNodes[v.id], "mask"..var)
                                mask:setVisible(true)
                                mask:setScale(0.88)
                                local rareBG = CSResourceMgr.seekNodeByName(itemNodes[v.id], "rareBG"..var)
                                rareBG:setVisible(true)
                                rareBG:setScale(0.62)
                            else
                                awardIconPath = itemInfo.icon
                            end
                            CSResourceMgr.setSpriteTextureByNode(awardIcon, awardIconPath)
                            local label = CSResourceMgr.seekNodeByName(itemNodes[v.id], "loginLabel"..var)
                            CSResourceMgr.setLabelColorByNode(label, ItemInfo.COLOR[itemInfo.itemRare+1])
                            CSResourceMgr.setLabelStringByNode(label, itemInfo.name, {r=0,g=0,b=0,a=255})
                            local count = CSResourceMgr.seekNodeByName(itemNodes[v.id], "loginCount"..var)
                            CSResourceMgr.setLabelStringByNode(count, "X"..v1[2], {r=0,g=0,b=0,a=255})
                            awardsVec[var] = {{itemInfo.id,v1[2]}}
                        end
                    end
                end
                setItemCover()
                if loginDay > 7 then
                    CSResourceMgr.setButtonStringByNode(lq_Btn, "recharge27", {r=0,g=0,b=0,a=255})
                    CSResourceMgr.setButtonEnabledByNode(lq_Btn, false)
                    tabRedPoint[1] = false
                else
                    if loginDay > ActivitiesData.login.count then
                        CSResourceMgr.setButtonEnabledByNode(lq_Btn, false)
                        tabRedPoint[1] = false
                    else
                        CSResourceMgr.clickEventBindingByNode(lq_Btn, function()
                            NetInterface.sendWithBlock("GC_FetchLoginAwards_Ack", function()
                                local ActivitySend = require("src.Net.Send.ActivitySend")
                                ActivitySend.sendCG_FetchLoginAwards_Req(loginDay)
                            end, function()
                                ActivityViewMgr.showGetAwards(awardsVec[loginDay])
                                loginDay = loginDay + 1
                                if loginDay > ActivitiesData.login.count or loginDay > 7 then
                                    CSResourceMgr.setButtonEnabledByNode(lq_Btn, false)
                                    tabRedPoint[1] = false
                                end
                                if loginDay > 7 then
                                    CSResourceMgr.setButtonStringByNode(lq_Btn, "recharge27", {r=0,g=0,b=0,a=255})
                                end
                                setItemCover()
                                ActivityViewMgr.setRedPoint()
                            end, function(code)
                                TipsMgr.showError(scene, code)
                            end,nil,false)
                        end)
                    end
                end  
            elseif v.type == ActivityInfo.FetchUpgrade then
                local itemNode = itemNodes[v.id]
                local lvIcon = CSResourceMgr.seekNodeByName(itemNode, "lvIcon")
                lvIcon:setVisible(true)
                lvIcon:setScale(0.8)
                local infoBtn = CSResourceMgr.seekNodeByName(itemNode, "infoBtn")
                infoBtn:setVisible(true)
                CSResourceMgr.clickEventBindingByNode(infoBtn, function()
                    ActivityViewMgr.showSkillBookInfo(v.id,v.type)
                end)
                local awardsVec = {}
                local function resetItem(lvIndex)
                    awardsVec = {}
                    local vec = nil
                    if not activityParams[v.id][lvIndex] then
                        vec = activityParams[v.id][7].awardVec
                        CSResourceMgr.setButtonStringByNode(lq_Btn, "recharge27", {r=0,g=0,b=0,a=255})
                    else
                        vec = activityParams[v.id][lvIndex].awardVec
                    end
                    for k1,v1 in pairs(vec) do
                        local itemInfo,petType = ActivityViewMgr.getItemInfo(tonumber(v1[1]))
                        if petType == Proto.AET_PET then
                            local awardIcon = CSResourceMgr.seekNodeByName(itemNode, "awardIcon"..k1)
                            CSResourceMgr.setSpriteTextureByNode(awardIcon, itemInfo.icon)
                            awardIcon:setScale(0.8)
                            local label = CSResourceMgr.seekNodeByName(itemNode, "label"..k1)
                            CSResourceMgr.setLabelColorByNode(label, ItemInfo.COLOR[itemInfo.itemRare+1])
                            CSResourceMgr.setLabelStringByNode(label, itemInfo.name, {r=0,g=0,b=0,a=255})
                            local count = CSResourceMgr.seekNodeByName(itemNodes[v.id], "count"..k1)
                            CSResourceMgr.setLabelStringByNode(count, "X"..v1[2], {r=0,g=0,b=0,a=255})
                        else
                            local awardIcon = CSResourceMgr.seekNodeByName(itemNode, "awardIcon"..k1)
                            CSResourceMgr.setSpriteTextureByNode(awardIcon, itemInfo.icon)
                            local label = CSResourceMgr.seekNodeByName(itemNode, "label"..k1)
                            CSResourceMgr.setLabelColorByNode(label, ItemInfo.COLOR[itemInfo.itemRare+1])
                            CSResourceMgr.setLabelStringByNode(label, itemInfo.name, {r=0,g=0,b=0,a=255})
                            local count = CSResourceMgr.seekNodeByName(itemNodes[v.id], "count"..k1)
                            CSResourceMgr.setLabelStringByNode(count, "X"..v1[2], {r=0,g=0,b=0,a=255})
                            table.insert(awardsVec,{itemInfo.id,v1[2]})
                        end
                    end
                    CSResourceMgr.setSpriteTextureByNode(lvIcon, iconPathVec[lvIndex])
                end
                local function refreshUpgrade()
                    local lvIndex = 1
                    for k1,v1 in pairs(upgradeVec) do
                        if v1.token then
                            lvIndex = lvIndex + 1
                            resetItem(lvIndex)
                            CSResourceMgr.setButtonEnabledByNode(lq_Btn, false)
                            tabRedPoint[1] = false
                        else
                            resetItem(lvIndex)
                            CSResourceMgr.setButtonEnabledByNode(lq_Btn, true)
                            CSResourceMgr.clickEventBindingByNode(lq_Btn, function()
                                NetInterface.sendWithBlock("GC_FetchUpgradeAwards_Ack", function()
                                    local ActivitySend = require("src.Net.Send.ActivitySend")
                                    ActivitySend.sendCG_FetchUpgradeAwards_Req(v1.level)
                                end, function()
                                    ActivityViewMgr.showGetAwards(awardsVec)
                                    v1.token = true
                                    if lvIndex == 7 then
                                        CSResourceMgr.setButtonStringByNode(lq_Btn, "recharge27", {r=0,g=0,b=0,a=255})
                                    end
                                    ActivityViewMgr.setRedPoint()
                                    refreshUpgrade()
                                end, function(code)
                                    TipsMgr.showError(scene, code)
                                end,nil,false)
                            end)
                            break
                        end
                    end
                end
                if ActivitiesData then
                    if ActivitiesData.upgrade then
                        local idx = ActivityViewMgr.getTableCount(ActivitiesData.upgrade)
                        if not upgradeVec or #upgradeVec ~= idx then
                            upgradeVec = {}
                            for k1,v1 in pairs(ActivitiesData.upgrade) do
                                local vec1 = {}
                                vec1.level = k1
                                if v1.token then
                                    vec1.token = true
                                else
                                    vec1.token = false
                                end
                                upgradeVec[idx] = vec1
                                idx = idx - 1
                            end
                        end
                        upgradeVec = ActivityViewMgr.sortActivities(upgradeVec)
                        refreshUpgrade()
                    else
                        CSResourceMgr.setButtonEnabledByNode(lq_Btn, false)
                        tabRedPoint[1] = false
                        resetItem(1)
                    end
                else
                    CSResourceMgr.setButtonEnabledByNode(lq_Btn, false)
                    tabRedPoint[1] = false
                    resetItem(1)
                end
            elseif v.type == ActivityInfo.Activity then
                lq_Btn:setVisible(false)
                if v.id == 17 then
                    lq_Btn:setVisible(true)
                    CSResourceMgr.setButtonStringByNode(lq_Btn, "activity63", {r=0,g=0,b=0,a=255})
                    local path1 = "Item/Activity/menu_blue_normal_su_05.png"
                    local path2 = "Item/Activity/menu_blue_normal_su_05_ed.png"
                    local path3 = "Item/Activity/menu_gray_normal_su_05.png"
                    CSResourceMgr.setButtonTextureByNode(lq_Btn, path1, path2, path3)

                    CSResourceMgr.clickEventBindingByNode(lq_Btn, function()
                        StatusBarMgr.hideTopInfoBar()
                        PetInfoViewMgr.show(SceneMgr.getRunningScene, 134,function()
                            StatusBarMgr.showTopInfoBar(function()
                                ActivityViewMgr.hide()
                            end)
                        end)
                    end)
                elseif v.id == 19 then
                    lq_Btn:setVisible(true)
                    CSResourceMgr.setButtonStringByNode(lq_Btn, "activity35", {r=0,g=0,b=0,a=255})
                    local path1 = "Item/Activity/menu_blue_normal_su_05.png"
                    local path2 = "Item/Activity/menu_blue_normal_su_05_ed.png"
                    local path3 = "Item/Activity/menu_gray_normal_su_05.png"
                    CSResourceMgr.setButtonTextureByNode(lq_Btn, path1, path2, path3)

                    CSResourceMgr.clickEventBindingByNode(lq_Btn, function()
                        PurchaseViewMgr.show(SceneMgr.getRunningScene, nil, 2)
                    end)
                end
            elseif v.type == ActivityInfo.GetPower then
                local lvIcon = CSResourceMgr.seekNodeByName(itemNodes[v.id], "lvIcon")
                lvIcon:setVisible(true)
                lvIcon:setPosition(388,80)
                CSResourceMgr.setSpriteTextureByNode(lvIcon, "Item/Activity/activity_figure_parts_120.png")
                ActivityViewMgr.refreshServerTime()
                CSResourceMgr.clickEventBindingByNode(lq_Btn, function()
                    NetInterface.sendWithBlock("GC_FetchDailyActionValue_Ack", function()
                        local ActivitySend = require("src.Net.Send.ActivitySend")
                        ActivitySend.sendCG_FetchDailyActionValue_Req()
                    end, function()
                        StandardTipsMgr.show(0, "family111")
                        NetInterface.sendWithBlock("GC_GetActivitiesData_Ack", function()
                            local ActivitySend = require("src.Net.Send.ActivitySend")
                            ActivitySend.sendCG_GetActivitiesData_Req()
                        end, function()
                            tabRedPoint[3] = false
                            local redpoint = CSResourceMgr.getNodeByName(resName, "redpoint3")
                            if redpoint then
                                redpoint:setVisible(false)
                            end
                            CSResourceMgr.setButtonEnabledByNode(lq_Btn, false)
                        end, function(code)
                            TipsMgr.showError(scene, code)
                        end)
                    end, function(code)
                        StandardTipsMgr.show(1, "error code:"..code)
                        TipsMgr.showError(scene, code)
                    end,nil,false)
                end)
            elseif v.type == ActivityInfo.PurchaseAward then
                local itemNode = itemNodes[v.id]
                local infoBtn = CSResourceMgr.seekNodeByName(itemNode, "infoBtn")
                infoBtn:setVisible(true)
                CSResourceMgr.clickEventBindingByNode(infoBtn, function()
                    ActivityViewMgr.showSkillBookInfo(v.id,v.type)
                end)
                
                local timeVec,str = ActivityHalloweenViewMgr.turnTimeDiff(lastTime)
                local timeIcon = CSResourceMgr.seekNodeByName(itemNodes[v.id], "timeIcon")  --个位
                local timeLabel = CSResourceMgr.seekNodeByName(itemNodes[v.id], "timeLabel")
                local lvIcon = CSResourceMgr.seekNodeByName(itemNodes[v.id], "lvIcon")  --十位
                timeIcon:setPosition(555,135)
                timeLabel:setPosition(570,130)
                timeLabel:setVisible(true)
                timeIcon:setVisible(true)
                timeIcon:setScale(0.5)
                if #timeVec > 1 then
                    lvIcon:setPosition(525,135)
                    lvIcon:setScale(0.5)
                    lvIcon:setVisible(true)
                    CSResourceMgr.setSpriteTextureByNode(lvIcon, "Item/Activity/activity_number_"..timeVec[1]..".png")
                    CSResourceMgr.setSpriteTextureByNode(timeIcon, "Item/Activity/activity_number_"..timeVec[2]..".png")
                    CSResourceMgr.setLabelStringByNode(timeLabel, str, {r=68,g=22,b=5,a=255})
                else
                    CSResourceMgr.setSpriteTextureByNode(timeIcon, "Item/Activity/activity_number_"..timeVec[1]..".png")
                    CSResourceMgr.setLabelStringByNode(timeLabel, str, {r=68,g=22,b=5,a=255})
                end
                
                local awardsVec = {}
                local function resetItem(aID)
                    awardsVec = {}
                    local vec = nil
                    local mCash = nil
                    if not activityParams[v.id][aID] then
                        vec = activityParams[v.id][#activityParams[v.id]].awardVec
                        CSResourceMgr.setButtonStringByNode(lq_Btn, "recharge27", {r=0,g=0,b=0,a=255})
                        CSResourceMgr.setButtonEnabledByNode(lq_Btn, false)
                        mCash = activityParams[v.id][#activityParams[v.id]].mCash
                    else
                        vec = activityParams[v.id][aID].awardVec
                        mCash = activityParams[v.id][aID].mCash
                    end
                    local strVec = ActivityInterface.changeStrToTable(tostring(mCash))
                    ActivityViewMgr.setNumList(strVec,v.id)
                    for k2,v2 in pairs(vec) do
                        local itemInfo,petType = ActivityViewMgr.getItemInfo(tonumber(v2[1]))
                        if petType == Proto.AET_PET then
                            local awardIcon = CSResourceMgr.seekNodeByName(itemNodes[v.id], "awardIcon"..k2)
                            CSResourceMgr.setSpriteTextureByNode(awardIcon, itemInfo.icon)
                            awardIcon:setScale(0.8)
                            local label = CSResourceMgr.seekNodeByName(itemNodes[v.id], "label"..k2)
                            CSResourceMgr.setLabelColorByNode(label, ItemInfo.COLOR[itemInfo.itemRare+1])
                            CSResourceMgr.setLabelStringByNode(label, itemInfo.name, {r=0,g=0,b=0,a=255})
                            local count = CSResourceMgr.seekNodeByName(itemNodes[v.id], "count"..k2)
                            CSResourceMgr.setLabelStringByNode(count, "X"..v2[2], {r=0,g=0,b=0,a=255})
                        else
                            local itemType = ItemInfo.getItemType(itemInfo.id)
                            local awardIcon = CSResourceMgr.seekNodeByName(itemNodes[v.id], "awardIcon"..k2)
                            local awardIconPath = nil
                            if itemType == 4 then
                                local petPieceInfo = ItemInfo.getPetPieceInfoById(itemInfo.id)
                                local pokemonInfo = PokemonInfo.getPokemonInfoByID(PokemonInfo.getGeneInfoByID(petPieceInfo.pokeID).petID)
                                awardIconPath =  "Pet/PetIcon/"..pokemonInfo.icon..".png"
                                awardIcon:setScale(0.68)
                                local mask = CSResourceMgr.seekNodeByName(itemNodes[v.id], "mask")
                                mask:setVisible(true)
                                mask:setScale(0.9)
                                local rareBG = CSResourceMgr.seekNodeByName(itemNodes[v.id], "rareBG")
                                rareBG:setVisible(true)
                                rareBG:setScale(0.7)
                            else
                                awardIconPath = itemInfo.icon
                            end
                            CSResourceMgr.setSpriteTextureByNode(awardIcon, awardIconPath)
                            local label = CSResourceMgr.seekNodeByName(itemNodes[v.id], "label"..k2)
                            CSResourceMgr.setLabelColorByNode(label, ItemInfo.COLOR[itemInfo.itemRare+1])
                            CSResourceMgr.setLabelStringByNode(label, itemInfo.name, {r=0,g=0,b=0,a=255})
                            local count = CSResourceMgr.seekNodeByName(itemNodes[v.id], "count"..k2)
                            CSResourceMgr.setLabelStringByNode(count, "X"..v2[2], {r=0,g=0,b=0,a=255})
                            table.insert(awardsVec,{itemInfo.id,v2[2]})
                        end
                    end
                end
                local function refreshUpgrade()
                    local canTake = false
                    local aID = 1
                    for k1,v1 in pairs(ActivitiesData.recharge["8"]) do
                        if k1 ~= "total" then
                            if v1.token then
                                aID = aID+1
                            else
                                canTake = true
                            end
                        end
                    end
                    resetItem(aID)
                    if canTake then
                        CSResourceMgr.clickEventBindingByNode(lq_Btn, function()
                            ActivityInterface.fetchRechargeAwards(v.id,activityParams[v.id][aID].mCash,function()
                                ActivitiesData.recharge["8"][tostring(activityParams[v.id][aID].mCash)] = {}
                                ActivitiesData.recharge["8"][tostring(activityParams[v.id][aID].mCash)].token = true
                                ActivityViewMgr.showGetAwards(awardsVec)
                                ActivityViewMgr.setRedPoint()
                                canTake = false
                                refreshUpgrade()
                            end)
                        end)
                    else
                        CSResourceMgr.setButtonEnabledByNode(lq_Btn, false)
                    end
                end
                if ActivitiesData then
                    if ActivitiesData.recharge then
                        if ActivitiesData.recharge["8"] then
                            refreshUpgrade()
                        end
                    else
                        resetItem(1)
                        CSResourceMgr.setButtonEnabledByNode(lq_Btn, false)
                    end
                else
                    resetItem(1)
                    CSResourceMgr.setButtonEnabledByNode(lq_Btn, false)
                end
            elseif v.type == ActivityInfo.GetRebate then
                lq_Btn:setVisible(false)
            elseif v.type == ActivityInfo.GetAward then
                lq_Btn:setVisible(false)
            elseif v.type == ActivityInfo.ConsumeRebate then
                local itemNode = itemNodes[v.id]
                local infoBtn = CSResourceMgr.seekNodeByName(itemNode, "infoBtn")
                infoBtn:setVisible(true)
                CSResourceMgr.clickEventBindingByNode(infoBtn, function()
                    ActivityViewMgr.showSkillBookInfo(v.id,v.type)
                end)
                local awardsVec = {}
                local function resetItem(aID)
                    awardsVec = {}
                    local vec = nil
                    local mCash = nil
                    if not activityParams[v.id][aID] then
                        vec = activityParams[v.id][#activityParams[v.id]].awardVec
                        CSResourceMgr.setButtonStringByNode(lq_Btn, "recharge27", {r=0,g=0,b=0,a=255})
                        CSResourceMgr.setButtonEnabledByNode(lq_Btn, false)
                        mCash = activityParams[v.id][#activityParams[v.id]].mCash
                    else
                        vec = activityParams[v.id][aID].awardVec
                        mCash = activityParams[v.id][aID].mCash
                    end
                    local strVec = ActivityInterface.changeStrToTable(tostring(mCash))
                    ActivityViewMgr.setNumList(strVec,v.id)

                    for var=1,3 do
                        local awardIcon = CSResourceMgr.seekNodeByName(itemNodes[v.id], "awardIcon"..var)
                        CSResourceMgr.setSpriteTextureByNode(awardIcon, "empty.png")
                        local label = CSResourceMgr.seekNodeByName(itemNodes[v.id], "label"..var)
                        CSResourceMgr.setLabelStringByNode(label, " ")
                        local count = CSResourceMgr.seekNodeByName(itemNodes[v.id], "count"..var)
                        CSResourceMgr.setLabelStringByNode(count," ")
                    end

                    for k2,v2 in pairs(vec) do
                        local itemInfo,petType = ActivityViewMgr.getItemInfo(tonumber(v2[1]))
                        if petType == Proto.AET_PET then
                            local awardIcon = CSResourceMgr.seekNodeByName(itemNodes[v.id], "awardIcon"..k2)
                            CSResourceMgr.setSpriteTextureByNode(awardIcon, itemInfo.icon)
                            awardIcon:setScale(0.8)
                            local label = CSResourceMgr.seekNodeByName(itemNodes[v.id], "label"..k2)
                            CSResourceMgr.setLabelColorByNode(label, ItemInfo.COLOR[itemInfo.itemRare+1])
                            CSResourceMgr.setLabelStringByNode(label, itemInfo.name, {r=0,g=0,b=0,a=255})
                            local count = CSResourceMgr.seekNodeByName(itemNodes[v.id], "count"..k2)
                            CSResourceMgr.setLabelStringByNode(count, "X"..v2[2], {r=0,g=0,b=0,a=255})
                        else
                            local itemType = ItemInfo.getItemType(itemInfo.id)
                            local awardIcon = CSResourceMgr.seekNodeByName(itemNodes[v.id], "awardIcon"..k2)
                            local awardIconPath = nil
                            if itemType == 4 then
                                local petPieceInfo = ItemInfo.getPetPieceInfoById(itemInfo.id)
                                local pokemonInfo = PokemonInfo.getPokemonInfoByID(PokemonInfo.getGeneInfoByID(petPieceInfo.pokeID).petID)
                                awardIconPath =  "Pet/PetIcon/"..pokemonInfo.icon..".png"
                                awardIcon:setScale(0.68)
                                local mask = CSResourceMgr.seekNodeByName(itemNodes[v.id], "mask")
                                mask:setVisible(true)
                                mask:setScale(0.9)
                                local rareBG = CSResourceMgr.seekNodeByName(itemNodes[v.id], "rareBG")
                                rareBG:setVisible(true)
                                rareBG:setScale(0.7)
                            else
                                awardIconPath = itemInfo.icon
                            end
                            CSResourceMgr.setSpriteTextureByNode(awardIcon, awardIconPath)
                            local label = CSResourceMgr.seekNodeByName(itemNodes[v.id], "label"..k2)
                            CSResourceMgr.setLabelColorByNode(label, ItemInfo.COLOR[itemInfo.itemRare+1])
                            CSResourceMgr.setLabelStringByNode(label, itemInfo.name, {r=0,g=0,b=0,a=255})
                            local count = CSResourceMgr.seekNodeByName(itemNodes[v.id], "count"..k2)
                            CSResourceMgr.setLabelStringByNode(count, "X"..v2[2], {r=0,g=0,b=0,a=255})
                            table.insert(awardsVec,{itemInfo.id,v2[2]})
                        end
                    end
                end
                local function refreshUpgrade()
                    local canTake = false
                    local aID = 1
                    for k1,v1 in pairs(ActivitiesData.consume["9"]) do
                        if k1 ~= "total" then
                            if v1.token then
                                aID = aID+1
                            else
                                canTake = true
                            end
                        end
                    end
                    resetItem(aID)
                    if canTake then
                        CSResourceMgr.clickEventBindingByNode(lq_Btn, function()
                            ActivityInterface.fetchConsumeAwards(v.id,activityParams[v.id][aID].mCash,function()
                                ActivitiesData.consume["9"][tostring(activityParams[v.id][aID].mCash)] = {}
                                ActivitiesData.consume["9"][tostring(activityParams[v.id][aID].mCash)].token = true
                                ActivityViewMgr.showGetAwards(awardsVec)
                                ActivityViewMgr.setRedPoint()
                                canTake = false
                                refreshUpgrade()
                            end)
                        end)
                    else
                        CSResourceMgr.setButtonEnabledByNode(lq_Btn, false)
                    end
                end
                if ActivitiesData then
                    if ActivitiesData.consume then
                        if ActivitiesData.consume["9"] then
                            refreshUpgrade()
                        end
                    else
                        resetItem(1)
                        CSResourceMgr.setButtonEnabledByNode(lq_Btn, false)
                    end
                else
                    resetItem(1)
                    CSResourceMgr.setButtonEnabledByNode(lq_Btn, false)
                end
            elseif v.type == ActivityInfo.GrowthFund then
                local itemNode = itemNodes[v.id]
                local infoBtn = CSResourceMgr.seekNodeByName(itemNode, "infoBtn")
                infoBtn:setVisible(true)
                CSResourceMgr.clickEventBindingByNode(infoBtn, function()
                    ActivityViewMgr.showSkillBookInfo(v.id,v.type)
                end)
                local lvIcon = CSResourceMgr.seekNodeByName(itemNode, "lvIcon")
                lvIcon:setVisible(true)
                lvIcon:setScale(1)
                lvIcon:setPosition(440,185)
                lvIcon:setRotation(5)
                local vipIcon = CSResourceMgr.seekNodeByName(itemNodes[v.id], "vipIcon")
                vipIcon:setVisible(true)
                local strVec = ActivityInterface.changeStrToTable(tostring(6688))
                ActivityViewMgr.setCostList(strVec,v.id)
                local costLabel = CSResourceMgr.seekNodeByName(itemNodes[v.id], "costLabel")
                CSResourceMgr.setLabelStringByNode(costLabel, "x"..activityParams[v.id][1].mCash, {r=0,g=0,b=0,a=255})
                lq_Btn:setPosition(555,65)

                local awardsVec = {}
                local function resetItem(aID)
                    awardsVec = {}
                    local vec = nil
                    if not activityParams[v.id][aID] then
                        aID = #iconPathVec2 - 1
                        vec = activityParams[v.id][#activityParams[v.id][aID-1]].awardVec
                        CSResourceMgr.setButtonStringByNode(lq_Btn, "recharge27", {r=0,g=0,b=0,a=255})
                        CSResourceMgr.setButtonEnabledByNode(lq_Btn, false)
                    else
                        vec = activityParams[v.id][aID].awardVec
                    end

                    for var=1,3 do
                        local awardIcon = CSResourceMgr.seekNodeByName(itemNodes[v.id], "awardIcon"..var)
                        CSResourceMgr.setSpriteTextureByNode(awardIcon, "empty.png")
                        local label = CSResourceMgr.seekNodeByName(itemNodes[v.id], "label"..var)
                        CSResourceMgr.setLabelStringByNode(label, " ")
                        local count = CSResourceMgr.seekNodeByName(itemNodes[v.id], "count"..var)
                        CSResourceMgr.setLabelStringByNode(count," ")
                    end

                    for k2,v2 in pairs(vec) do
                        local itemInfo,petType = ActivityViewMgr.getItemInfo(tonumber(v2[1]))
                        if petType == Proto.AET_PET then
                            local awardIcon = CSResourceMgr.seekNodeByName(itemNodes[v.id], "awardIcon"..k2)
                            CSResourceMgr.setSpriteTextureByNode(awardIcon, itemInfo.icon)
                            awardIcon:setScale(0.8)
                            local label = CSResourceMgr.seekNodeByName(itemNodes[v.id], "label"..k2)
                            CSResourceMgr.setLabelColorByNode(label, ItemInfo.COLOR[itemInfo.itemRare+1])
                            CSResourceMgr.setLabelStringByNode(label, itemInfo.name, {r=0,g=0,b=0,a=255})
                            local count = CSResourceMgr.seekNodeByName(itemNodes[v.id], "count"..k2)
                            CSResourceMgr.setLabelStringByNode(count, "X"..v2[2], {r=0,g=0,b=0,a=255})
                        else
                            local itemType = ItemInfo.getItemType(itemInfo.id)
                            local awardIcon = CSResourceMgr.seekNodeByName(itemNodes[v.id], "awardIcon"..k2)
                            local awardIconPath = nil
                            if itemType == 4 then
                                local petPieceInfo = ItemInfo.getPetPieceInfoById(itemInfo.id)
                                local pokemonInfo = PokemonInfo.getPokemonInfoByID(PokemonInfo.getGeneInfoByID(petPieceInfo.pokeID).petID)
                                awardIconPath =  "Pet/PetIcon/"..pokemonInfo.icon..".png"
                                awardIcon:setScale(0.68)
                                local mask = CSResourceMgr.seekNodeByName(itemNodes[v.id], "mask")
                                mask:setVisible(true)
                                mask:setScale(0.9)
                                local rareBG = CSResourceMgr.seekNodeByName(itemNodes[v.id], "rareBG")
                                rareBG:setVisible(true)
                                rareBG:setScale(0.7)
                            else
                                awardIconPath = itemInfo.icon
                            end
                            CSResourceMgr.setSpriteTextureByNode(awardIcon, awardIconPath)
                            local label = CSResourceMgr.seekNodeByName(itemNodes[v.id], "label"..k2)
                            CSResourceMgr.setLabelColorByNode(label, ItemInfo.COLOR[itemInfo.itemRare+1])
                            CSResourceMgr.setLabelStringByNode(label, itemInfo.name, {r=0,g=0,b=0,a=255})
                            local count = CSResourceMgr.seekNodeByName(itemNodes[v.id], "count"..k2)
                            CSResourceMgr.setLabelStringByNode(count, "X"..v2[2], {r=0,g=0,b=0,a=255})
                            table.insert(awardsVec,{itemInfo.id,v2[2]})
                        end
                    end
                    CSResourceMgr.setSpriteTextureByNode(lvIcon, iconPathVec2[aID])
                end
                local function refreshUpgrade()
                    local aID = 1
                    for k1,v1 in pairs(growfund) do
                        if v1.token then
                            aID = aID + 1
                            resetItem(aID)
                            CSResourceMgr.setButtonEnabledByNode(lq_Btn, false)
                        else
                            resetItem(aID)
                            CSResourceMgr.setButtonEnabledByNode(lq_Btn, true)
                            CSResourceMgr.clickEventBindingByNode(lq_Btn, function()
                                ActivityInterface.fetchGrowthFundAwards(activityParams[v.id][aID].level,function()
                                    ActivityViewMgr.showGetAwards(awardsVec)
                                    v1.token = true
                                    refreshUpgrade()
                                    tabRedPoint[1] = false
                                    ActivityViewMgr.setRedPoint()
                                end)
                            end)
                            break
                        end
                    end
                end

                local vipLv = CharInfo.getVIPLevel()
                local vipInfo = CharInfo.getVipInfoByID(vipLv)
                local mCash = CharInfo.getMCash()
                local costList2 = CSResourceMgr.seekNodeByName(itemNodes[v.id], "costList2")
                local buyBtn = CSResourceMgr.seekNodeByName(itemNodes[v.id], "buyBtn")
                local costLabel1 = CSResourceMgr.seekNodeByName(itemNodes[v.id], "costLabel1")
                CSResourceMgr.setLabelStringByNode(costLabel1, "recharge36", {r=0,g=0,b=0,a=255})
                local vipLabel = CSResourceMgr.seekNodeByName(itemNodes[v.id], "vipLabel")
                CSResourceMgr.setLabelStringByNode(vipLabel, activityParams[v.id][1].vipLv, {r=83,g=16,b=0,a=255})
                local function checkGrowFund()
                    if ActivitiesData then
                        if ActivitiesData.growfund then
                            local idx = ActivityViewMgr.getTableCount(ActivitiesData.growfund)
                            if not growfund or #growfund ~= idx-1 then
                                growfund = {}
                                for k1,v1 in pairs(ActivitiesData.growfund) do
                                    if k1 ~= "b11" then
                                        local vec1 = {}
                                        vec1.level = k1
                                        if v1.token then
                                            vec1.token = true
                                        else
                                            vec1.token = false
                                        end
                                        table.insert(growfund,vec1)
                                    end
                                end
                            end
                            growfund = ActivityViewMgr.sortActivities(growfund)

                            if ActivitiesData.growfund.b11 then
                                if next(growfund) then
                                    refreshUpgrade()
                                else
                                    resetItem(1)
                                    CSResourceMgr.setButtonEnabledByNode(lq_Btn, false)
                                end
                            else
                                resetItem(1)
                                costList2:setVisible(true)
                                buyBtn:setVisible(true)
                                lq_Btn:setVisible(false)
                                CSResourceMgr.clickEventBindingByNode(buyBtn, function()
                                    if vipInfo.viplevel >= activityParams[v.id][1].vipLv and mCash >= activityParams[v.id][1].mCash then
                                        ActivityInterface.buyGrowthFund(v.id,function()
                                            NetInterface.sendWithBlock("GC_GetActivitiesData_Ack", function()
                                                local ActivitySend = require("src.Net.Send.ActivitySend")
                                                ActivitySend.sendCG_GetActivitiesData_Req()
                                            end, function()
                                                StandardTipsMgr.show(0, "LtTips6")
                                                costList2:setVisible(false)
                                                buyBtn:setVisible(false)
                                                lq_Btn:setVisible(true)
                                                CSResourceMgr.setButtonStringByNode(lq_Btn, "activity44", {r=0,g=0,b=0,a=255})
                                                checkGrowFund()
                                            end, function(code)
                                                TipsMgr.showError(scene, code)
                                            end)
                                        end)
                                    else
                                        if vipInfo.viplevel < activityParams[v.id][1].vipLv then
                                            StandardTipsMgr.show(1, "NetErrorText388")
                                        elseif mCash < activityParams[v.id][1].mCash then
                                            StandardTipsMgr.show(1, "activity43")
                                        end
                                    end
                                end)
                            end
                        else
                            resetItem(1)
                            costList2:setVisible(true)
                            buyBtn:setVisible(true)
                            lq_Btn:setVisible(false)
                            CSResourceMgr.clickEventBindingByNode(buyBtn, function()
                                if vipInfo.viplevel >= activityParams[v.id][1].vipLv and mCash >= activityParams[v.id][1].mCash then
                                    ActivityInterface.buyGrowthFund(v.id,function()
                                        NetInterface.sendWithBlock("GC_GetActivitiesData_Ack", function()
                                            local ActivitySend = require("src.Net.Send.ActivitySend")
                                            ActivitySend.sendCG_GetActivitiesData_Req()
                                        end, function()
                                            StandardTipsMgr.show(0, "LtTips6")
                                            costList2:setVisible(false)
                                            buyBtn:setVisible(false)
                                            lq_Btn:setVisible(true)
                                            CSResourceMgr.setButtonStringByNode(lq_Btn, "activity44", {r=0,g=0,b=0,a=255})
                                            checkGrowFund()
                                        end, function(code)
                                            TipsMgr.showError(scene, code)
                                        end)
                                    end)
                                else
                                    if vipInfo.viplevel < activityParams[v.id][1].vipLv then
                                        StandardTipsMgr.show(1, "NetErrorText388")
                                    elseif mCash < activityParams[v.id][1].mCash then
                                        StandardTipsMgr.show(1, "activity43")
                                    end
                                end
                            end)
                        end
                    else
                        resetItem(1)
                        costList2:setVisible(true)
                        buyBtn:setVisible(true)
                        lq_Btn:setVisible(false)
                        CSResourceMgr.clickEventBindingByNode(buyBtn, function()
                            if vipInfo.viplevel >= activityParams[v.id][1].vipLv and mCash >= activityParams[v.id][1].mCash then
                                CSResourceMgr.setButtonEnabledByNode(buyBtn,false)
                                ActivityInterface.buyGrowthFund(v.id,function()
                                    NetInterface.sendWithBlock("GC_GetActivitiesData_Ack", function()
                                        local ActivitySend = require("src.Net.Send.ActivitySend")
                                        ActivitySend.sendCG_GetActivitiesData_Req()
                                    end, function()
                                        StandardTipsMgr.show(0, "LtTips6")
                                        costList2:setVisible(false)
                                        buyBtn:setVisible(false)
                                        lq_Btn:setVisible(true)
                                        CSResourceMgr.setButtonStringByNode(lq_Btn, "activity44", {r=0,g=0,b=0,a=255})
                                        checkGrowFund()
                                    end, function(code)
                                        TipsMgr.showError(scene, code)
                                    end)
                                end)
                            else
                                if vipInfo.viplevel < activityParams[v.id][1].vipLv then
                                    StandardTipsMgr.show(1, "NetErrorText388")
                                elseif mCash < activityParams[v.id][1].mCash then
                                    StandardTipsMgr.show(1, "activity43")
                                end
                            end
                        end)
                    end
                end
                checkGrowFund()
            elseif v.type == ActivityInfo.CapsuleEgg then
                if eggFlag then
                    eggFlag = false
                    tabRedPoint[1] = false
                    local isShow = 0
                    if ActivitiesData then
                        if ActivitiesData.growfund then
                            if ActivitiesData.growfund.b11 then
                                if growfund then
                                    for k1,v1 in pairs(growfund) do
                                        if not v1.token then
                                            isShow = isShow + 1
                                        end
                                    end
                                    if isShow == 0 then
                                        CSResourceMgr.getNodeByName(resName, "redpoint1"):setVisible(false)
                                        SevenDayRedPointManager.removeActivityRedPoint()
                                        showRedPoint = false
                                    end
                                end
                            else
                                CSResourceMgr.getNodeByName(resName, "redpoint1"):setVisible(false)
                                SevenDayRedPointManager.removeActivityRedPoint()
                                showRedPoint = false
                            end
                        else
                            CSResourceMgr.getNodeByName(resName, "redpoint1"):setVisible(false)
                            SevenDayRedPointManager.removeActivityRedPoint()
                            showRedPoint = false
                        end
                    else
                        CSResourceMgr.getNodeByName(resName, "redpoint1"):setVisible(false)
                        SevenDayRedPointManager.removeActivityRedPoint()
                        showRedPoint = false
                    end
                end

                local itemNode = itemNodes[v.id]
                local lvIcon = CSResourceMgr.seekNodeByName(itemNode, "lvIcon")
                local timeIcon = CSResourceMgr.seekNodeByName(itemNode, "timeIcon")
                local timeLabel = CSResourceMgr.seekNodeByName(itemNode, "timeLabel")
                local dayCount = CocosModuleMgr.getDayTimeDiff(loginTime, lastTime,21600)
                local timeString = nil
                timeLabel:setVisible(true)
                timeIcon:setVisible(true)
                if dayCount > 1 then
                    local timeVec = ActivityInterface.changeStrToTable(tostring(dayCount))
                    if #timeVec > 1 then
                        lvIcon:setVisible(true)
                        CSResourceMgr.setSpriteTextureByNode(lvIcon, "Item/Activity/activity_number_"..timeVec[1]..".png")
                        CSResourceMgr.setSpriteTextureByNode(timeIcon, "Item/Activity/activity_number_"..timeVec[2]..".png")
                        CSResourceMgr.setLabelStringByNode(timeLabel, "activity48", {r=68,g=22,b=5,a=255})
                    else
                        CSResourceMgr.setSpriteTextureByNode(timeIcon, "Item/Activity/activity_number_"..timeVec[1]..".png")
                        CSResourceMgr.setLabelStringByNode(timeLabel, "activity48", {r=68,g=22,b=5,a=255})
                    end
                    local str1 = LuaSqlite.getLanguageByKey("activity48")
                    timeString = dayCount..str1
                else
                    local time1 = lastTime - loginTime
                    local timeStr = math.floor(time1/3600)
                    if timeStr > 0 then
                        local timeVec = ActivityInterface.changeStrToTable(tostring(timeStr))
                        if #timeVec > 1 then
                            lvIcon:setVisible(true)
                            CSResourceMgr.setSpriteTextureByNode(lvIcon, "Item/Activity/activity_number_"..timeVec[1]..".png")
                            CSResourceMgr.setSpriteTextureByNode(timeIcon, "Item/Activity/activity_number_"..timeVec[2]..".png")
                            CSResourceMgr.setLabelStringByNode(timeLabel, "activity49", {r=68,g=22,b=5,a=255})
                        else
                            CSResourceMgr.setSpriteTextureByNode(timeIcon, "Item/Activity/activity_number_"..timeVec[1]..".png")
                            CSResourceMgr.setLabelStringByNode(timeLabel, "activity49", {r=68,g=22,b=5,a=255})
                        end
                        local str1 = LuaSqlite.getLanguageByKey("activity49")
                        timeString = timeStr..str1
                    else
                        timeStr = math.floor(time1/60)
                        local timeVec = ActivityInterface.changeStrToTable(tostring(timeStr))
                        if #timeVec > 1 then
                            lvIcon:setVisible(true)
                            CSResourceMgr.setSpriteTextureByNode(lvIcon, "Item/Activity/activity_number_"..timeVec[1]..".png")
                            CSResourceMgr.setSpriteTextureByNode(timeIcon, "Item/Activity/activity_number_"..timeVec[2]..".png")
                            CSResourceMgr.setLabelStringByNode(timeLabel, "activity50", {r=68,g=22,b=5,a=255})
                        else
                            CSResourceMgr.setSpriteTextureByNode(timeIcon, "Item/Activity/activity_number_"..timeVec[1]..".png")
                            CSResourceMgr.setLabelStringByNode(timeLabel, "activity50", {r=68,g=22,b=5,a=255})
                        end
                        local str1 = LuaSqlite.getLanguageByKey("activity50")
                        timeString = timeStr..str1
                    end
                end
                CSResourceMgr.setButtonStringByNode(lq_Btn, "activity45", {r=0,g=0,b=0,a=255})
                local path1 = "Item/Activity/menu_blue_normal_su_05.png"
                local path2 = "Item/Activity/menu_blue_normal_su_05_ed.png"
                local path3 = "Item/Activity/menu_gray_normal_su_05.png"
                CSResourceMgr.setButtonTextureByNode(lq_Btn, path1, path2, path3)

                CSResourceMgr.clickEventBindingByNode(lq_Btn, function()
                    ActivityCapsuleEggView.show(SceneMgr.getRunningScene,timeString,v.id,activityParams[v.id])
                end)
            elseif v.type == ActivityInfo.LuoTianYi then
                lq_Btn:setVisible(false)
            elseif v.type == ActivityInfo.LostTower or v.type == ActivityInfo.ActLostTower then
                local isShow = false
                for k,v in pairs(activityParams[v.id]) do
                    if v.weekDay == weekDay then
                        isShow = true
                    end
                end
                if not isShow then
                    itemNodes[v.id]:setVisible(false)
                end
                lq_Btn:setVisible(false)
            elseif v.type == ActivityInfo.ContinueLogin then
                -- itemNodes[v.id] = CSResourceMgr.getNodeByName(resNameItem, "diban"):clone()
                -- list:pushBackCustomItem(itemNodes[v.id])
                -- CSResourceMgr.setSpriteTextureByNode(itemNodes[v.id], v.image,false)

                local awardsVec = {}
                for k2,v2 in pairs(activityParams[v.id][1].awardVec) do
                    local itemInfo,petType = ActivityViewMgr.getItemInfo(tonumber(v2[1]))
                    if petType == Proto.AET_PET then
                        local awardIcon = CSResourceMgr.seekNodeByName(itemNodes[v.id], "awardIcon"..k2)
                        CSResourceMgr.setSpriteTextureByNode(awardIcon, itemInfo.icon)
                        awardIcon:setScale(0.8)
                        local label = CSResourceMgr.seekNodeByName(itemNodes[v.id], "label"..k2)
                        CSResourceMgr.setLabelColorByNode(label, ItemInfo.COLOR[itemInfo.itemRare+1])
                        CSResourceMgr.setLabelStringByNode(label, itemInfo.name, {r=0,g=0,b=0,a=255})
                        local count = CSResourceMgr.seekNodeByName(itemNodes[v.id], "count"..k2)
                        CSResourceMgr.setLabelStringByNode(count, "X"..v2[2], {r=0,g=0,b=0,a=255})
                    else
                        local itemType = ItemInfo.getItemType(itemInfo.id)
                        local awardIcon = CSResourceMgr.seekNodeByName(itemNodes[v.id], "awardIcon"..k2)
                        local awardIconPath = nil
                        if itemType == 4 then
                            local petPieceInfo = ItemInfo.getPetPieceInfoById(itemInfo.id)
                            local pokemonInfo = PokemonInfo.getPokemonInfoByID(PokemonInfo.getGeneInfoByID(petPieceInfo.pokeID).petID)
                            awardIconPath =  "Pet/PetIcon/"..pokemonInfo.icon..".png"
                            awardIcon:setScale(0.68)
                            local mask = CSResourceMgr.seekNodeByName(itemNodes[v.id], "mask")
                            mask:setVisible(true)
                            mask:setScale(0.9)
                            local rareBG = CSResourceMgr.seekNodeByName(itemNodes[v.id], "rareBG")
                            rareBG:setVisible(true)
                            rareBG:setScale(0.7)
                        else
                            awardIconPath = itemInfo.icon
                        end
                        CSResourceMgr.setSpriteTextureByNode(awardIcon, awardIconPath)
                        local label = CSResourceMgr.seekNodeByName(itemNodes[v.id], "label"..k2)
                        CSResourceMgr.setLabelColorByNode(label, ItemInfo.COLOR[itemInfo.itemRare+1])
                        CSResourceMgr.setLabelStringByNode(label, itemInfo.name, {r=0,g=0,b=0,a=255})
                        local count = CSResourceMgr.seekNodeByName(itemNodes[v.id], "count"..k2)
                        CSResourceMgr.setLabelStringByNode(count, "X"..v2[2], {r=0,g=0,b=0,a=255})
                        table.insert(awardsVec,{itemInfo.id,v2[2]})
                    end
                end

                local lq_Btn = CSResourceMgr.seekNodeByName(itemNodes[v.id], "lq_Btn")
                CSResourceMgr.setButtonStringByNode(lq_Btn, "recharge26", {r=0,g=0,b=0,a=255})
                local count = 0
                local needDays = activityParams[v.id][1].count
                if ActivitiesData and ActivitiesData.clogin then
                    count = ActivitiesData.clogin.count
                    if count >= needDays then
                        CSResourceMgr.setButtonEnabledByNode(lq_Btn, true)
                    else
                        CSResourceMgr.setButtonEnabledByNode(lq_Btn, false)
                    end
                else
                    CSResourceMgr.setButtonEnabledByNode(lq_Btn, false)
                end
                CSResourceMgr.clickEventBindingByNode(lq_Btn, function ()
                    NetInterface.sendWithBlock("GC_FETCHCONTINUELOGINAWARDS_ACK", function()
                    local activitySend = require("src/Net/Send/ActivitySend.lua")
                    activitySend.sendCG_FetchContinueLoginAwards_Req({
                        aID = v.id,
                    })
                    end, function ()
                        CSResourceMgr.setButtonStringByNode(lq_Btn, "recharge27", {r=0,g=0,b=0,a=255})
                        CSResourceMgr.setButtonEnabledByNode(lq_Btn, false)
                        AwardsListMgr.show(SceneMgr.getRunningScene, awardsVec)
                    end, function ()
                    end)
                end)
                local labelProcess = CSResourceMgr.seekNodeByName(itemNodes[v.id], "count3")
                CSResourceMgr.setLabelStringByNode(labelProcess, CocosModuleMgr.createStringWithFormat({"activity66", math.min(count,needDays), needDays}), {r=0,g=0,b=0,a=255})
                labelProcess: setPosition(320, 51)
            else
                print("未处理活动类型")
            end
            CSResourceMgr.setSpriteTextureByNode(itemNodes[v.id], CocosModuleMgr.getWordImage(v.image),false)
			CSResourceMgr.setSpriteTextureByNode(CSResourceMgr.seekNodeByName(itemNodes[v.id],"numY"), CocosModuleMgr.getWordImage("activity_number_yuan.png"),false)
		end
    end
end

function ActivityViewMgr.setCostList(vec,id)
    local costList = CSResourceMgr.seekNodeByName(itemNodes[id], "costList")
    costList:setVisible(true)
    for var=1,#vec do
        local num = CSResourceMgr.seekNodeByName(itemNodes[id], "cost"..var)
        CSResourceMgr.setSpriteTextureByNode(num, "Item/Activity/activity_number_"..vec[var]..".png")
    end
end

function ActivityViewMgr.setNumList(vec,id)
    if id == 8 then
        local numY = CSResourceMgr.seekNodeByName(itemNodes[id], "numY")
        numY:setVisible(true)
        numY:setPositionX(52.5*#vec)
    end
    for var=1,#vec do
        local num = CSResourceMgr.seekNodeByName(itemNodes[id], "num"..var)
        num:setVisible(true)
        CSResourceMgr.setSpriteTextureByNode(num, "Item/Activity/activity_number_"..vec[var]..".png")
    end
end

function ActivityViewMgr.sortActivities(vec)
    table.sort(vec, function(a, b)
        local aIdx = a.level
        local bIdx = b.level
        return aIdx < bIdx
    end)
   
    return vec
end

function ActivityViewMgr.checkDailyAction(time1)
    local zoneTime = CharInfo.getServerTimeZone()
    local serverTime = CharInfo.getServerTime()
    local timeM = (zoneTime + serverTime)%86400
    if ActivitiesData then
        if ActivitiesData.dailyActionValue then
            if (serverTime+(time1-timeM)) <= ActivitiesData.dailyActionValue.fetchTime then
                return false
            else
                return true
            end
        else
            return true
        end
    else
        return true
    end
end

function ActivityViewMgr.refreshServerTime()
    local time = CharInfo.getServerTime() + CharInfo.getServerTimeZone()
    local timeC = time%86400

    if not CSResourceMgr.getCsbObj(resName) or curTab ~= 3 then
        return
    end

    if ActivitiesData then
        ActivityViewMgr.checkRedPoint()
    end

    local lq_Btn = CSResourceMgr.seekNodeByName(itemNodes[4], "lq_Btn")
    local label1 = CSResourceMgr.seekNodeByName(itemNodes[4], "label1")
    if label1 then
        label1:setVisible(false)
    end
    if timeC < 43200 then
        CSResourceMgr.getNodeByName(resName, "redpoint3"):setVisible(false)
        CSResourceMgr.setButtonEnabledByNode(lq_Btn, false)
        CocosModuleMgr.setTimeLabelCountDown(label1,43200 - timeC,function()
            ActivityViewMgr.refreshServerTime()
        end)
    elseif timeC >= 43200 and timeC <= 50400 then
        local isShow = ActivityViewMgr.checkDailyAction(43200)
        if isShow then
            CSResourceMgr.getNodeByName(resName, "redpoint3"):setVisible(true)
            CSResourceMgr.setButtonEnabledByNode(lq_Btn, true)
        else
            CSResourceMgr.getNodeByName(resName, "redpoint3"):setVisible(false)
            CSResourceMgr.setButtonEnabledByNode(lq_Btn, false)
        end
        CocosModuleMgr.setTimeLabelCountDown(label1,50400 - timeC,function()
            ActivityViewMgr.refreshServerTime()
        end)
    elseif timeC > 50400 and timeC < 64800 then
        CSResourceMgr.getNodeByName(resName, "redpoint3"):setVisible(false)
        CSResourceMgr.setButtonEnabledByNode(lq_Btn, false)
        CocosModuleMgr.setTimeLabelCountDown(label1,64800 - timeC,function()
            ActivityViewMgr.refreshServerTime()
        end)
    elseif timeC >= 64800 and timeC <= 72000 then
        local isShow = ActivityViewMgr.checkDailyAction(64800)
        if isShow then
            CSResourceMgr.getNodeByName(resName, "redpoint3"):setVisible(true)
            CSResourceMgr.setButtonEnabledByNode(lq_Btn, true)
        else
            CSResourceMgr.getNodeByName(resName, "redpoint3"):setVisible(false)
            CSResourceMgr.setButtonEnabledByNode(lq_Btn, false)
        end
        CocosModuleMgr.setTimeLabelCountDown(label1,72000 - timeC,function()
            ActivityViewMgr.refreshServerTime()
        end)
    elseif timeC > 72000 then
        CSResourceMgr.getNodeByName(resName, "redpoint3"):setVisible(false)
        CSResourceMgr.setButtonEnabledByNode(lq_Btn, false)
        CocosModuleMgr.setTimeLabelCountDown(label1,129600 - timeC,function()
            ActivityViewMgr.refreshServerTime()
        end)
    end
end

function ActivityViewMgr.showSkillBookInfo(id, aType)
    ActivityHalloweenViewMgr.showSkillBookInfo(id, aType, true)
end

function ActivityViewMgr.checkRedPoint()
    local time = CharInfo.getServerTime() + CharInfo.getServerTimeZone()
    local timeC = time%86400
    local showIdx = 0

    if timeC >= 43200 and timeC <= 50400 then
        local canGet = ActivityViewMgr.checkDailyAction(43200)
        if canGet then
            showIdx = showIdx + 1
            tabRedPoint[3] = true
            if activityHandler1 then
                scheduler.unscheduleGlobal(activityHandler1)
            end
            activityHandler1 = scheduler.performWithDelayGlobal(function()
                tabRedPoint[3] = false
                ActivityViewMgr.setRedPoint()
            end, 50400-timeC)
        end
    elseif timeC >= 64800 and timeC <= 72000 then
        local canGet = ActivityViewMgr.checkDailyAction(64800)
        if canGet then
            showIdx = showIdx + 1
            tabRedPoint[3] = true
            if activityHandler2 then
                scheduler.unscheduleGlobal(activityHandler2)
            end
            activityHandler2 = scheduler.performWithDelayGlobal(function()
                tabRedPoint[3] = false
                ActivityViewMgr.setRedPoint()
            end, 72000-timeC)
        end
    elseif timeC < 43200 then
        if activityHandler4 then
            scheduler.unscheduleGlobal(activityHandler4)
        end
        activityHandler4 = scheduler.performWithDelayGlobal(function()
            tabRedPoint[3] = true
            showRedPoint = true
            StatusBarMgr.addRedPoint(6)
        end, 43200-timeC)
    elseif timeC > 50400 and timeC < 64800 then
        if activityHandler4 then
            scheduler.unscheduleGlobal(activityHandler4)
        end
        activityHandler4 = scheduler.performWithDelayGlobal(function()
            tabRedPoint[3] = true
            showRedPoint = true
            StatusBarMgr.addRedPoint(6)
        end, 64800-timeC)
    elseif timeC > 72000 then
        if activityHandler4 then
            scheduler.unscheduleGlobal(activityHandler4)
        end
        activityHandler4 = scheduler.performWithDelayGlobal(function()
            tabRedPoint[3] = true
            showRedPoint = true
            StatusBarMgr.addRedPoint(6)
        end, 129600-timeC)
    end
    return showIdx
end

function ActivityViewMgr.setCompoundPetInfo(jsStr)
    if CSResourceMgr.getCsbObj(resName) then
        local cjson = require("cjson")
        local tbl = cjson.decode(jsStr)
        table.insert(compoundPetInfo, tbl)
    end
end

function ActivityViewMgr.setRedPoint()
    if not ActivitiesData then
        if eggFlag then
            if CSResourceMgr.getCsbObj(resName) then
                tabRedPoint[1] = true
            end
            StatusBarMgr.addRedPoint(6)
            showRedPoint = true
        end
        return
    end
    local time = CharInfo.getServerTime() + CharInfo.getServerTimeZone()
    local timeM = 86400 - time%86400

    if activityHandler3 then
        scheduler.unscheduleGlobal(activityHandler3)
    end
    if loginDay <= 7 then
        activityHandler3 = scheduler.performWithDelayGlobal(function()
            StatusBarMgr.addRedPoint(6)
            showRedPoint = true
        end, timeM)
    end
    local isShow = 0
    if eggFlag then
        isShow = isShow + 1
        tabRedPoint[1] = true
    end
    -- if ActivitiesData.login.days and loginDay == 1 then
    --     loginDay = ActivityViewMgr.getTableCount(ActivitiesData.login.days) + 1
    -- end
    -- if loginDay <= ActivitiesData.login.count and loginDay <= 7 and ActivitiesData.login.count <= 7 then
    --     isShow = isShow + 1
    --     tabRedPoint[1] = true
    -- end

    if ActivitiesData.upgrade then
        local idx = ActivityViewMgr.getTableCount(ActivitiesData.upgrade)
        if not upgradeVec or #upgradeVec ~= idx then
            upgradeVec = {}
            for k1,v1 in pairs(ActivitiesData.upgrade) do
                local vec1 = {}
                vec1.level = k1
                if v1.token then
                    vec1.token = true
                else
                    vec1.token = false
                end
                upgradeVec[idx] = vec1
                idx = idx - 1
            end
        end
        upgradeVec = ActivityViewMgr.sortActivities(upgradeVec)
    end
    if upgradeVec then
        for k1,v1 in pairs(upgradeVec) do
            if not v1.token then
                isShow = isShow + 1
                tabRedPoint[1] = true
            end
        end
    end

    if ActivitiesData.growfund then
        local idx = ActivityViewMgr.getTableCount(ActivitiesData.growfund)-1
        if not growfund or #growfund ~= idx then
            growfund = {}
            for k1,v1 in pairs(ActivitiesData.growfund) do
                if k1 ~= "b11" then
                    local vec1 = {}
                    vec1.level = k1
                    if v1.token then
                        vec1.token = true
                    else
                        vec1.token = false
                    end
                    table.insert(growfund,vec1)
                end
            end
        end
        growfund = ActivityViewMgr.sortActivities(growfund)
    end
    if ActivitiesData.growfund then
        if ActivitiesData.growfund.b11 then
            if growfund then
                for k1,v1 in pairs(growfund) do
                    if not v1.token then
                        isShow = isShow + 1
                        tabRedPoint[1] = true
                    end
                end
            end
        end
    end
    
    local tabTakon = 0
    local canTake = false
    local beginTime = 0
    local lastTime = 0
    if ActivitiesData.recharge then
        local rechargeInfo = {}
        local isActiveOpen = false
        local loginTime = CharInfo.getServerTime()
        for k2,v2 in pairs(tabTable[2]) do
            if v2.id == 8 or v2.id == "8" then
                rechargeInfo = v2
                break
            end
        end

        if ActivitiesData.recharge["8"] then
            for k1,v1 in pairs(ActivitiesData.recharge["8"]) do
                if PetEducationMgr.getTableLength(rechargeInfo) > 0 and rechargeInfo.id == 8 or rechargeInfo.id == "8" then
                    if rechargeInfo.openServerDays >= 1 then
                        beginTime = CharInfo.getServerOpenTime()+(rechargeInfo.openServerDays-1)*86400
                        lastTime = beginTime + rechargeInfo.lastTime
                        if loginTime <= lastTime and loginTime >= beginTime then
                            isActiveOpen = true
                        end
                    end
                end
                if k1 ~= "total" then
                    if not v1.token then
                        canTake = true
                    end
                end
            end
            if canTake and isActiveOpen == true then
                isShow = isShow + 1
                tabRedPoint[2] = true
            else
                tabTakon = tabTakon+1
            end
        end
    else
        tabTakon = tabTakon+1
    end

    canTake = false
    if ActivitiesData.consume then
	require("src.Utils.GenUtils").printTable(ActivitiesData.consume)
        for k1,v1 in pairs(ActivitiesData.consume[tostring(consumeRebateID)] or {}) do
            if k1 ~= "total" then
                if not v1.token then
                    canTake = true
                end
            end
        end
        if canTake then
            isShow = isShow + 1
            tabRedPoint[2] = true
        else
            tabTakon = tabTakon+1
        end
    else
        tabTakon = tabTakon+1
    end
    if tabTakon == 2 then
        tabRedPoint[2] = false
    end
    
    isShow = isShow + ActivityViewMgr.checkRedPoint()
    if isShow > 0 then
        StatusBarMgr.addRedPoint(6)
        showRedPoint = true
    else
        SevenDayRedPointManager.removeActivityRedPoint()
        showRedPoint = false
    end

    if CSResourceMgr.getCsbObj(resName) then
        for i=1,3 do
            CSResourceMgr.getNodeByName(resName, "redpoint"..i):setVisible(tabRedPoint[i])
        end
    end
end

function ActivityViewMgr.getRedPointIsShow()
    return showRedPoint
end

function ActivityViewMgr.setSevenDayRedPoint(enable)
    if CSResourceMgr.getCsbObj(resName) then
        CSResourceMgr.getNodeByName(resName, "redpoint4"):setVisible(enable)
    end
end

function ActivityViewMgr.showGetAwards(awardsVec)
    AwardsListMgr.show(SceneMgr.getRunningScene, awardsVec)
    local function showGetPet()
        for k,v in pairs(compoundPetInfo) do
            GachaViewMgr.playGetAPet(v.pokeID, v, function ()
                showGetPet()
            end)
            table.remove(compoundPetInfo, 1)
            return
        end
    end
    if PetEducationMgr.getTableLength(awardsVec) > 0 then
        showGetPet()
    end
end

return ActivityViewMgr