local ActivityHalloweenViewMgr = {}

local resName = ""
local resNameItem = ""
local resNameBG = ""
local resNameAward = ""
local itemNodes = {}
local ActivitiesData = nil
local compoundPetInfo = {}
local ActivityInterface = require("src.GameMgr.Item.ActivityInterface")

function ActivityHalloweenViewMgr.Init()
    resName = "Item/ActivityHalloween/HalloweenView.csb"
    resNameItem = "Item/ActivityHalloween/HalloweenItem.csb"
    resNameBG = "Pet/Formation/FormationBGNew.csb"
    resNameAward = "Item/Activity/ActivityRewardList.csb"
    itemNodes = {}
    compoundPetInfo = {}
    CSResourceMgr.createRes(nil, resNameItem, nil, true)
end

function ActivityHalloweenViewMgr.setActivitiesData(vec)
    ActivitiesData = vec
end

function ActivityHalloweenViewMgr.getActivitiesData()
    return ActivitiesData
end

function ActivityHalloweenViewMgr.getCompoundPetInfo()
    return compoundPetInfo
end

function ActivityHalloweenViewMgr.show(scene)
    if not NetInterface.isConnect then
        return
    end
    NetInterface.sendWithBlock("GC_GetActivitiesData_Ack", function()
        local ActivitySend = require("src.Net.Send.ActivitySend")
        ActivitySend.sendCG_GetActivitiesData_Req()
    end, function()
        UIStack.push("ActivityHalloweenViewMgr", ActivityHalloweenViewMgr.hide, true)
        ActivityHalloweenViewMgr.open(scene)
    end, function(code)
        TipsMgr.showError(scene, code)
    end)
end

function ActivityHalloweenViewMgr.open(scene)
    local function loadBG()
        local bgLayer = CSResourceMgr.createRes(scene, resNameBG, "ActivityHalloweenViewMgr")
        bgLayer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resNameBG, 320, 480, "ActivityHalloweenViewMgr")
        bgLayer:setOpacity(0)
        transition.fadeIn(bgLayer, {time=0.3})
    end

    local function loadCSB()
        local curLayer = CSResourceMgr.createRes(scene, resName)
        curLayer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resName, 320, 480)

        local diff = CocosModuleMgr.getScreenSizeDiff()
        local list = CSResourceMgr.getNodeByName(resName, "list")
        local ltsize = list:getContentSize()
        local ltposy = list:getPositionY()
        list:setPositionY(ltposy+diff/2.5)
        list:setContentSize(ltsize.width, ltsize.height+diff)
        local titleBG = CSResourceMgr.getNodeByName(resName, "titleBG")
        local tpposy = titleBG:getPositionY()
        titleBG:setPositionY(tpposy+diff/2.5)

        local title = CSResourceMgr.getNodeByName(resName, "title")
        CSResourceMgr.setLabelStringByNode(title, "activity56", {r=0,g=0,b=0,a=255})

        ActivityHalloweenViewMgr.setHalloweenItem()
    end

    local function playCSB()
        CocosModuleMgr.showUIAnimation(CSResourceMgr.getNodeByName(resName,"diban"),"down")
        StatusBarMgr.showTopInfoBar(function()
            ActivityHalloweenViewMgr.hide()
        end)
    end

    local funcTable = {loadBG, loadCSB, playCSB}
    loadBG()
    loadCSB()
    playCSB()
end

function ActivityHalloweenViewMgr.hide()
    StatusBarMgr.hideTopInfoBar()
    CSResourceMgr.removeList(resName, "list")
    itemNodes = {}
    compoundPetInfo = {}
    CSResourceMgr.removeCSObjectByTag(resNameBG, "ActivityHalloweenViewMgr")
    CSResourceMgr.removeCSObjectByTag(resNameAward)
    CSResourceMgr.removeCSObjectByTag(resName)
    UIStack.pop("ActivityHalloweenViewMgr")
end

function ActivityHalloweenViewMgr.setHalloweenItem()
    local list = CSResourceMgr.getNodeByName(resName, "list")
    list:removeAllItems()

    local ActivityItemProcessor = require("src.GameMgr.Item.ActivityItemProcessor")
    local tabTable, activityParams = ActivityViewMgr.getActivitiesData()

    for k,v in pairs(tabTable[4]) do
        local res, loginTime, beginTime, lastTime = ActivityInfo.checkActivityValid(v)
        if res then
            itemNodes[v.id] = CSResourceMgr.getNodeByName(resNameItem, "diban"):clone()
            ActivityItemProcessor.process(v, itemNodes, lastTime)
            list:pushBackCustomItem(itemNodes[v.id])
        end
    end
end

function ActivityHalloweenViewMgr.showSkillBookInfo(id, aType, boolOld)
    local tabTable,activityParams = ActivityViewMgr.getActivitiesData()
    local curEfx = CSResourceMgr.createRes(SceneMgr.getRunningScene, resNameAward)
    curEfx:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
    CSResourceMgr.setFullScreen(resNameAward)
    local panel_1 = CSResourceMgr.getNodeByName(resNameAward,"panel_1")
    CocosModuleMgr.showUIAnimation(panel_1,"down")

    local title = CSResourceMgr.getNodeByName(resNameAward, "title")
    CSResourceMgr.setLabelStringByNode(title, "activity8", {r=0,g=0,b=0,a=255,w=1,s=2}, nil, 250)
    CSResourceMgr.setLabelColorByNode(title, {r=255,g=234,b=0,a=255})

    local btn = CSResourceMgr.getNodeByName(resNameAward, "btn")
    CSResourceMgr.clickEventBindingByNode(btn, function()
        CSResourceMgr.removeList(resNameAward, "list")
        CSResourceMgr.removeCSObjectByTag(resNameAward)
    end)

    local btn_close = CSResourceMgr.getNodeByName(resNameAward, "btn_close")
    CSResourceMgr.clickEventBindingByNode(btn_close, function()
        CSResourceMgr.removeList(resNameAward, "list")
        CSResourceMgr.removeCSObjectByTag(resNameAward)
    end)

    local list = CSResourceMgr.getNodeByName(resNameAward, "list")
    list:removeAllItems()
    local reward = CSResourceMgr.getNodeByName(resNameAward, "reward")
    for var=1,#activityParams[id] do
        if next(activityParams[id][var].awardVec) then
            local parent = reward:clone()
            list:pushBackCustomItem(parent)
            local bg1 = CSResourceMgr.seekNodeByName(parent, "bg1")
            bg1:setColor({r=24,g=44,b=58,a=255})
            local bg2 = CSResourceMgr.seekNodeByName(parent, "bg2")
            local reward_title = CSResourceMgr.seekNodeByName(parent, "reward_title")
            if aType == ActivityInfo.PurchaseAward then
                local richLabel = CocosModuleMgr.createRichLabel(reward_title, CocosModuleMgr.createStringWithFormat({"activity9", activityParams[id][var].mCash}),
                 24, "cuyuan_GBK.ttf", TownChatMgr.MAX_LABEL_WIDTH,nil,-15,nil,true)
            elseif aType == ActivityInfo.FetchUpgrade or aType == ActivityInfo.GrowthFund then
                local richLabel = CocosModuleMgr.createRichLabel(reward_title, CocosModuleMgr.createStringWithFormat({"activity10", activityParams[id][var].level}),
                 24, "cuyuan_GBK.ttf", TownChatMgr.MAX_LABEL_WIDTH,nil,-15,nil,true)
            elseif aType == ActivityInfo.ConsumeRebate then
                local richLabel = CocosModuleMgr.createRichLabel(reward_title, CocosModuleMgr.createStringWithFormat({"activity11", activityParams[id][var].mCash}),
                 24, "cuyuan_GBK.ttf", TownChatMgr.MAX_LABEL_WIDTH,nil,-15,nil,true)
            elseif aType == ActivityInfo.BossCombo then
                CSResourceMgr.setLabelStringByNode(reward_title, CocosModuleMgr.createStringWithFormat({"activity67", 
                    activityParams[id][var].count}))
            elseif aType == ActivityInfo.BossAttackCount then
                CSResourceMgr.setLabelStringByNode(reward_title, CocosModuleMgr.createStringWithFormat({"activity69", 
                    activityParams[id][var].count}))
            elseif aType == ActivityInfo.BossKillTime then
                CSResourceMgr.setLabelStringByNode(reward_title, CocosModuleMgr.createStringWithFormat({"activity68", 
                    activityParams[id][var].spendTime}))
            elseif aType == ActivityInfo.LifeSkill then
                if var == 1 then
                    CSResourceMgr.setLabelStringByNode(reward_title, CocosModuleMgr.createStringWithFormat({"activity70", 
                        activityParams[id][var].lifeSkillLv,activityParams[id][var].lifeSkillCount}))
                else
                    CSResourceMgr.setLabelStringByNode(reward_title, CocosModuleMgr.createStringWithFormat({"activity71", 
                        activityParams[id][var].lifeSkillLv,activityParams[id][var].lifeSkillCount}))
                end
            elseif aType == ActivityInfo.SurvivalBattle then
                CSResourceMgr.setLabelStringByNode(reward_title, CocosModuleMgr.createStringWithFormat({"activity104", 
                    activityParams[id][var].count}))
            elseif aType == ActivityInfo.FetchLogin then
                CSResourceMgr.setLabelStringByNode(reward_title, CocosModuleMgr.createStringWithFormat({"activity107", 
                    activityParams[id][var].days}))
            elseif aType == ActivityInfo.ExpeditionWin then
                CSResourceMgr.setLabelStringByNode(reward_title, CocosModuleMgr.createStringWithFormat({"activity115", 
                    activityParams[id][var].count}))
            end
            CSResourceMgr.setLabelColorByNode(reward_title, {r=255,g=234,b=0,a=255,w=1,w=2})

            for k,v in pairs(activityParams[id][var].awardVec) do
                local itemInfo,petType = ActivityViewMgr.getItemInfo(tonumber(v[1]))
                if petType == Proto.AET_PET then
                    local awardElementInfo = ItemInfo.getAwardElementInfoById(tonumber(v[1]))
                    local nodeBtn = CSResourceMgr.seekNodeByName(parent, "petBtn")
                    local itemBtn = nodeBtn:clone()
                    itemBtn:show()
                    local pokeInfo = PokemonInfo.getPokemonInfoByID(awardElementInfo.elementID)
                    local path = "Pet/BasicPetList_2/Stage/"..pokeInfo.rarePoint..".png"
                    local icon = CSResourceMgr.seekNodeByName(itemBtn, "icon")
                    icon:setScale(0.78)
                    itemBtn:setScale(1.08)
                    CSResourceMgr.setSpriteTextureByNode(icon, itemInfo.icon)
                    CSResourceMgr.setButtonTextureByNode(itemBtn,path,path,path)
                    local posX = 295 + (k - 2) * 120
                    local posY = 65
                    itemBtn:setPosition(posX, posY)
                    itemBtn:removeFromParent()
                    itemBtn:addTo(bg2)
                    CSResourceMgr.clickEventBindingByNode(itemBtn, function()
                        StatusBarMgr.hideTopInfoBar()
                        PetInfoViewMgr.show(SceneMgr.getRunningScene, awardElementInfo.elementID, function()
                            StatusBarMgr.showTopInfoBar(function()
                                if not boolOld then
                                    ActivityHalloweenViewMgr.hide()
                                else
                                    ActivityViewMgr.hide()
                                end
                            end)
                        end)
                    end)
                else
                    local itemBtn = ItemInfo.getItemIconById(itemInfo.id, v[2])
                    local posX = 295 + (k - 2) * 120
                    local posY = 65
                    itemBtn:setPosition(posX, posY)
                    itemBtn:removeFromParent()
                    itemBtn:addTo(bg2)
                    itemBtn:setScale(0.7)
                    CSResourceMgr.clickEventBindingByNode(itemBtn, function()
                        ItemInfoViewMgr.show({id = itemInfo.id}, false)
                    end)
                end
            end
        end
    end
end

function ActivityHalloweenViewMgr.turnTimeDiff(lastTime)
    local loginTime = CharInfo.getServerTime()
    local dayCount = CocosModuleMgr.getDayTimeDiff(loginTime, lastTime, 21600)
    --print("ActivityHalloweenViewMgr.turnTimeDiff", dayCount)
    local str = nil
    if dayCount > 1 then
        local timeVec = ActivityInterface.changeStrToTable(tostring(dayCount))
        str = LuaSqlite.getLanguageByKey("activity48")
        return timeVec,str
    else
        local time1 = lastTime - loginTime
        local timeStr = math.floor(time1/3600)
        if timeStr > 0 then
            local timeVec = ActivityInterface.changeStrToTable(tostring(timeStr))
            str = LuaSqlite.getLanguageByKey("activity49")
            return timeVec,str
        else
            timeStr = math.floor(time1/60)
            local timeVec = ActivityInterface.changeStrToTable(tostring(timeStr))
            str = LuaSqlite.getLanguageByKey("activity50")
            return timeVec,str
        end
    end
end

function ActivityHalloweenViewMgr.setTimeNodes(parent, lastTime, x1, y1, x2, y2, x3, y3)
    if type(x1)=="table" then
    	local posvec = x1
        x1 = posvec[1]
        y1 = posvec[2]
        x2 = posvec[3]
        y2 = posvec[4]
        x3 = posvec[5]
        y3 = posvec[6]
    end
    local timeVec,str = ActivityHalloweenViewMgr.turnTimeDiff(lastTime)
    local timeIcon = CSResourceMgr.seekNodeByName(parent, "timeIcon")   --个位
    local timeLabel = CSResourceMgr.seekNodeByName(parent, "timeLabel") --单位
    local lvIcon = CSResourceMgr.seekNodeByName(parent, "lvIcon")       --十位
    timeIcon:setPosition(x2, y2)
    timeLabel:setPosition(x3, y3)
    timeLabel:show()
    timeIcon:show()
    timeIcon:setScale(0.5)
    if #timeVec > 1 then
        lvIcon:setPosition(x1, y1)
        lvIcon:setScale(0.5)
        lvIcon:show()
        CSResourceMgr.setSpriteTextureByNode(lvIcon, "Item/Activity/activity_number_"..timeVec[1]..".png")
        CSResourceMgr.setSpriteTextureByNode(timeIcon, "Item/Activity/activity_number_"..timeVec[2]..".png")
        CSResourceMgr.setLabelStringByNode(timeLabel, str, {r=68,g=22,b=5,a=255})
    else
        CSResourceMgr.setSpriteTextureByNode(timeIcon, "Item/Activity/activity_number_"..timeVec[1]..".png")
        CSResourceMgr.setLabelStringByNode(timeLabel, str, {r=68,g=22,b=5,a=255})
    end
end

function ActivityHalloweenViewMgr.setGoToButton(parent, listener, title)
    local lq_Btn = CSResourceMgr.seekNodeByName(parent, "lq_Btn")
    CSResourceMgr.setButtonStringByNode(lq_Btn, title or "activity35", {r=0,g=0,b=0,a=255})
    local path1 = "Item/Activity/menu_blue_normal_su_05.png"
    local path2 = "Item/Activity/menu_blue_normal_su_05_ed.png"
    local path3 = "Item/Activity/menu_gray_normal_su_05.png"
    CSResourceMgr.setButtonTextureByNode(lq_Btn, path1, path2, path3)
    if listener then
        CSResourceMgr.clickEventBindingByNode(lq_Btn, listener)
    end
    return lq_Btn
end

function ActivityHalloweenViewMgr.setCompoundPetInfo(jsStr)
    if CSResourceMgr.getCsbObj(resName) then
        local cjson = require("cjson")
        local tbl = cjson.decode(jsStr)
        table.insert(compoundPetInfo, tbl)
    end
end

function ActivityHalloweenViewMgr.setNumList(vec, id, atype, pos, scale)
    local numList = CSResourceMgr.seekNodeByName(itemNodes[id], "numList")
    if atype == ActivityInfo.PurchaseAward then
        local numY = CSResourceMgr.seekNodeByName(itemNodes[id], "numY")
        numY:show()
        numY:setPositionX(52.5*#vec)
        numList:setPosition(400,160)
    end
    for var=1, #vec do
        local num = CSResourceMgr.seekNodeByName(itemNodes[id], "num"..var)
        num:show()
        CSResourceMgr.setSpriteTextureByNode(num, "Item/Activity/activity_number_"..vec[var]..".png")
    end
    if pos then
    	numList:pos(pos.x, pos.y)
    end
    if scale then
    	numList:setScale(scale)
    end
    return numList
end

function ActivityHalloweenViewMgr.setAwardsInfo(id, awardsInfo, showNum, showName)
    local awardsVec = {}
    if showNum==nil then
    	showNum = true
    end
    if showName==nil then
        showName = true
    end
    for k2, v2 in pairs(awardsInfo) do
        local itemInfo, petType = ActivityViewMgr.getItemInfo(tonumber(v2[1]))
        local label = CSResourceMgr.seekNodeByName(itemNodes[id], "label"..k2)
        local awardIcon = CSResourceMgr.seekNodeByName(itemNodes[id], "awardIcon"..k2)
        local count = CSResourceMgr.seekNodeByName(itemNodes[id], "count"..k2)
        if not showName and label then
        	label:hide()
        end
        if not showNum and count then
        	count:hide()
        end
        if petType == Proto.AET_PET then
            if awardIcon then
                CSResourceMgr.setSpriteTextureByNode(awardIcon, itemInfo.icon)
                awardIcon:setScale(0.8)
            end
            if showName and label then
            	CSResourceMgr.setLabelColorByNode(label, ItemInfo.COLOR[itemInfo.itemRare+1])
                CSResourceMgr.setLabelStringByNode(label, itemInfo.name, {r=0,g=0,b=0,a=255})
            end
            if showNum and count then
                CSResourceMgr.setLabelStringByNode(count, "X"..v2[2], {r=0,g=0,b=0,a=255})
            end
            table.insert(awardsVec, {"pet", itemInfo.pokeID})
        else
            local mask = CSResourceMgr.seekNodeByName(itemNodes[id], "mask"..k2)
            local itemType = ItemInfo.getItemType(itemInfo.id)
            local awardIconPath = nil
            if awardIcon and mask then
                if itemType == 4 then
                    local petPieceInfo = ItemInfo.getPetPieceInfoById(itemInfo.id)
                    local pokemonInfo = PokemonInfo.getPokemonInfoByID(PokemonInfo.getGeneInfoByID(petPieceInfo.pokeID).petID)
                    awardIconPath =  "Pet/PetIcon/"..pokemonInfo.icon..".png"
                    awardIcon:setScale(0.68)
                    mask:show()
                    mask:setScale(0.9)
                else
                    awardIconPath = itemInfo.icon
                    awardIcon:setScale(1)
                    mask:hide()
                    mask:setScale(1)
                end
                CSResourceMgr.setSpriteTextureByNode(awardIcon, awardIconPath)
            end
            if showName and label then
            	CSResourceMgr.setLabelColorByNode(label, ItemInfo.COLOR[itemInfo.itemRare+1])
                CSResourceMgr.setLabelStringByNode(label, itemInfo.name, {r=0,g=0,b=0,a=255})
            end
            if showNum and v2[2] and count then
                CSResourceMgr.setLabelStringByNode(count, "X"..v2[2], {r=0,g=0,b=0,a=255})
            end
            table.insert(awardsVec, {itemInfo.id, v2[2]})
        end
    end
    return awardsVec
end

function ActivityHalloweenViewMgr.setAwardsInfoPos(id, startPosx, startPosy, xDiff)
	local awardsNodeNum = 3
    for var=1, awardsNodeNum do
        local icon = CSResourceMgr.seekNodeByName(itemNodes[id], "awardIcon"..var)
        local label = CSResourceMgr.seekNodeByName(itemNodes[id], "label"..var)
        local count = CSResourceMgr.seekNodeByName(itemNodes[id], "count"..var)
        icon:pos(startPosx+(var-1)*xDiff, startPosy)
        label:pos(startPosx+(var-1)*xDiff-30, startPosy-51)
        count:pos(startPosx+(var-1)*xDiff+15, startPosy-34)
	end
end

function ActivityHalloweenViewMgr.setAwardsInfoNew(id, awardsInfo, startPosx, startPosy, xDiff)
    local nodesVec, awardsVec = {}, {}
    for k2, v2 in pairs(awardsInfo) do
        local itemInfo, petType = ActivityViewMgr.getItemInfo(tonumber(v2[1]))
        local num = tonumber(v2[2])
        local node = nil
        if petType == Proto.AET_PET then
            node = ItemInfo.getPetIconById(itemInfo.pokeID, "ActivityHalloweenViewMgr.setAwardsInfoNew"..k2)
            CSResourceMgr.clickEventBindingByNode(node, function()
                StatusBarMgr.hideTopInfoBar()
                PetInfoViewMgr.show(SceneMgr.getRunningScene, itemInfo.pokeID, function()
                    StatusBarMgr.showTopInfoBar(function()
                        ActivityHalloweenViewMgr.hide()
                    end)
                end)
            end, 1)
            node:setScale(0.85)
            table.insert(awardsVec, {"pet", itemInfo.pokeID})
        else
            node = ItemInfo.getItemIconById(itemInfo.id, num, nil, false, false)
            CSResourceMgr.clickEventBindingByNode(node, function()
                ItemInfoViewMgr.show({id=itemInfo.id, sum=num}, false)
            end, 1)
            node:setScale(0.5)
            table.insert(awardsVec, {itemInfo.id, num})
        end
        node:addTo(itemNodes[id])
        node:pos(startPosx+(k2-1)*xDiff, startPosy)
        table.insert(nodesVec, node)
    end
    return nodesVec, awardsVec
end

function ActivityHalloweenViewMgr.addProcessBar(id, curNum, totalNum, pos)
    local bg = display.newSprite("Item/Activity/jindu1.png")
    local progressTimer = cc.ProgressTimer:create(display.newSprite("Item/Activity/jindu2.png"))
    progressTimer:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    local perNum = math.floor((curNum*100.0)/totalNum)
    progressTimer:setMidpoint({x=0, y=0})
    progressTimer:setBarChangeRate({x=1, y=0})
    progressTimer:setPercentage(perNum)
    progressTimer:setPosition(bg:getContentSize().width/2, bg:getContentSize().height/2) 
    bg:addChild(progressTimer, 140)
    bg:addTo(itemNodes[id])
    bg:pos(pos.x, pos.y)
    
    local label = CSResourceMgr.seekNodeByName(itemNodes[id], "label1"):clone()
    CSResourceMgr.setLabelStringByNode(label, curNum.."/"..totalNum, {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 250)
    label:addTo(itemNodes[id])
    label:pos(pos.x, pos.y)
    label:setAnchorPoint(0.5, 0.5)
    label:show()
    return progressTimer, label
end

return ActivityHalloweenViewMgr