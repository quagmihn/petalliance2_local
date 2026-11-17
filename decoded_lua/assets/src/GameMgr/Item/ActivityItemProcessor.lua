local ActivityItemProcessor = {}
local ActivityInterface = require("src.GameMgr.Item.ActivityInterface")

local function showGetPet()
    local compoundPetInfo = ActivityHalloweenViewMgr.getCompoundPetInfo()
    for k,v in pairs(compoundPetInfo) do
        GachaViewMgr.playGetAPet(v.pokeID, v, function ()
            showGetPet()
        end)
        table.remove(compoundPetInfo, 1)
        return
    end
end

local function setLabelProgress(node, formatStringVec, posx, posy)
    CSResourceMgr.setLabelStringByNode(node, CocosModuleMgr.createStringWithFormat(formatStringVec), 
        {r=0,g=0,b=0,a=255})
    node:setPosition(posx, posy)
end

function ActivityItemProcessor.process(v, itemNodes, lastTime)
    local tabTable, activityParams = ActivityViewMgr.getActivitiesData()
    local ActivitiesData = ActivityHalloweenViewMgr.getActivitiesData()
    
    CSResourceMgr.setSpriteTextureByNode(itemNodes[v.id], CocosModuleMgr.getWordImage(v.image), false)
    local lq_Btn = CSResourceMgr.seekNodeByName(itemNodes[v.id], "lq_Btn")
    local infoBtn = CSResourceMgr.seekNodeByName(itemNodes[v.id], "infoBtn")
    local labelProcess = CSResourceMgr.seekNodeByName(itemNodes[v.id], "count3")
    if v.type == ActivityInfo.CapsuleEgg then
        lq_Btn:setContentSize(200,70)
        lq_Btn:setAnchorPoint(1,0)
        lq_Btn:setPosition(620,12)
        
        local timeVec, str = ActivityHalloweenViewMgr.turnTimeDiff(lastTime)
        local dayCount = ""
        local costItemCount =  ItemInfo.getCharItemNum(9987)
        local marketInfo   = ItemInfo.getMarketInfoById(202)
        for n=1, #timeVec do
            dayCount = dayCount..timeVec[n]
        end
        local function checkEnoughCountColor()
            if costItemCount < activityParams[v.id][1].mCash then
                return {r=255,g=0,b=0,a=255}
            else
                return {r=255,g=255,b=255,a=255}
            end
        end
        local myItemOwnCountL = CSResourceMgr.seekNodeByName(itemNodes[v.id], "label1"):clone()
        myItemOwnCountL:pos(540, 50)
        myItemOwnCountL:addTo(itemNodes[v.id])
        myItemOwnCountL:show()
        CSResourceMgr.setLabelStringByNode(myItemOwnCountL,costItemCount, {r=0,g=0,b=0,a=255,s=1,w=1}, nil, 70)
        myItemOwnCountL:setTextColor(checkEnoughCountColor())
        myItemOwnCountL:setAnchorPoint(1.0,0.5)
        local myItemNeedCountL = CSResourceMgr.seekNodeByName(itemNodes[v.id], "label1"):clone()
        myItemNeedCountL:pos(540, 50) 
        myItemNeedCountL:addTo(itemNodes[v.id])
        myItemNeedCountL:show()
        CSResourceMgr.setLabelStringByNode(myItemNeedCountL, "/"..activityParams[v.id][1].mCash, {r=0,g=0,b=0,a=255,s=1,w=1}, nil, 70)
        myItemNeedCountL:setAnchorPoint(0,0.5)
        
        dayCount = dayCount..str
        ActivityHalloweenViewMgr.setTimeNodes(itemNodes[v.id], lastTime, 220, 50, 250, 50, 275, 45)
        ActivityHalloweenViewMgr.setGoToButton(itemNodes[v.id], function() 
            if costItemCount < activityParams[v.id][1].mCash then
                BuyItemViewMgr.show(SceneMgr.getRunningScene, 9987, 2, marketInfo.num, 100000, 202,function()
                        costItemCount =  ItemInfo.getCharItemNum(9987)
                        CSResourceMgr.setLabelStringByNode(myItemOwnCountL,costItemCount, {r=0,g=0,b=0,a=255,s=1,w=1}, nil, 70)
                        myItemOwnCountL:setTextColor(checkEnoughCountColor())
                    end)
            else
                local params = {}
                params.aID = v.id
                params.atype = 3
                NetInterface.sendWithBlock("GC_TimeLimitCapsuleEgg_Ack", function()
                    ActivityCapsuleEggView.setIsCapsuling(true)
                    local ActivitySend = require("src.Net.Send.ActivitySend")
                    ActivitySend.sendCG_TimeLimitCapsuleEgg_Req(params)
                end,function()
                    costItemCount =  ItemInfo.getCharItemNum(9987)
                    CSResourceMgr.setLabelStringByNode(myItemOwnCountL,costItemCount, {r=0,g=0,b=0,a=255,s=1,w=1}, nil, 70)
                    myItemOwnCountL:setTextColor(checkEnoughCountColor())
 
                end,function(code)

                end) 
            end
        end, "    ")
        local iconVec = ActivityHalloweenViewMgr.setAwardsInfoNew(v.id, ActivityCapsuleEggView.getGachaAwardsInfo(), 50, 100, 60)
        for var=1, 3 do
            if iconVec[var] then
            	iconVec[var]:pos(40, 247-var*47)
                local label = CSResourceMgr.seekNodeByName(itemNodes[v.id], "label1"):clone()
                label:pos(75, 247-var*47)
                label:addTo(itemNodes[v.id])
                label:show()
                CSResourceMgr.setLabelStringByNode(label, "activity"..(109+var), {r=0,g=0,b=0,a=255,s=1,w=1}, nil, 200)
            end
        end
        for var=1, 5 do
            if iconVec[var+3] then
            	iconVec[var+3]:pos(290+var*60, 167)
            end
        end
        for var=1, 5 do
            if iconVec[var+8] then
            	iconVec[var+8]:pos(290+var*60, 112)
            end
        end
        for var=1, #iconVec do
            local iscale = iconVec[var]:getScaleY()
            iconVec[var]:scale(iscale*0.7)
        end
        local costItemInfo = ItemInfo.getItemInfoById(9987)
        local costIcon = display.newSprite(costItemInfo.icon)
        costIcon:addTo(itemNodes[v.id])
        costIcon:scale(0.7)
        costIcon:pos(460, 50)
    elseif v.type == ActivityInfo.FetchUpgrade then
        local awardsVec, upgradeVec = {}, {}
        local maxIndex = #activityParams[v.id]
        if maxIndex>1 then
            infoBtn:show()
            CSResourceMgr.clickEventBindingByNode(infoBtn, function()
                ActivityViewMgr.showSkillBookInfo(v.id, ActivityInfo.FetchUpgrade)
            end)
        end
        local function checkToken(level)
            if upgradeVec[level] then
            	return true
            end
            if ActivitiesData then
                if ActivitiesData.upgrade then
                    for k1,v1 in pairs(ActivitiesData.upgrade) do
                        local l = tonumber(k1)
                        if l==level then
                            return v1.token
                        end
                    end
                end
            end
            return false
        end
        local function resetItem(lvIndex)
            awardsVec = {}
            local vec = nil
            if not activityParams[v.id][lvIndex] then
                lvIndex = maxIndex
                CSResourceMgr.setButtonStringByNode(lq_Btn, "recharge27", {r=0,g=0,b=0,a=255})
            else
                CSResourceMgr.setButtonStringByNode(lq_Btn, "recharge26", {r=0,g=0,b=0,a=255})
            end
            vec = activityParams[v.id][lvIndex].awardVec
            awardsVec = ActivityHalloweenViewMgr.setAwardsInfo(v.id, vec)
            local level = activityParams[v.id][lvIndex].level
            setLabelProgress(labelProcess, {"activity117", math.min(level, CharInfo.getLevel()), level}, 320, 51)
            if CharInfo.getLevel()<level then
                CSResourceMgr.setButtonEnabledByNode(lq_Btn, false)
            end
        end
        local function refreshUpgrade()
            local hasItem = false
            for var=1, maxIndex do
                local level = activityParams[v.id][var].level
                if not checkToken(level) then
                    CSResourceMgr.setButtonEnabledByNode(lq_Btn, true)
                    resetItem(var)
                    CSResourceMgr.clickEventBindingByNode(lq_Btn, function()
                        NetInterface.sendWithBlock("GC_FetchUpgradeAwards_Ack", function()
                            local ActivitySend = require("src.Net.Send.ActivitySend")
                            ActivitySend.sendCG_FetchUpgradeAwards_Req(level)
                        end, function()
                            AwardsListMgr.show(SceneMgr.getRunningScene, awardsVec)
                            if PetEducationMgr.getTableLength(awardsVec) > 0 then
                                showGetPet()
                            end
                            upgradeVec[level] = true
                            refreshUpgrade()
                        end, function(code)
                            TipsMgr.showError(nil, code)
                        end, nil, false)
                    end)
                    hasItem = true
                	break
                end
            end
            if not hasItem then
                resetItem(maxIndex+1)
                CSResourceMgr.setButtonEnabledByNode(lq_Btn, false)
            end
        end
        refreshUpgrade()
    elseif v.type == ActivityInfo.Activity then
        local lq_Btn = ActivityHalloweenViewMgr.setGoToButton(itemNodes[v.id])
        if v.id == 141 then
            ActivityHalloweenViewMgr.setTimeNodes(itemNodes[v.id], lastTime, 470, 185, 500, 185, 525, 180)
            CSResourceMgr.clickEventBindingByNode(lq_Btn, function()
                ActivitySnatch.goToSnatch()
            end)
        elseif v.id == 221 then
            ActivityHalloweenViewMgr.setTimeNodes(itemNodes[v.id], lastTime, 385, 52, 415, 52, 440, 47)
            CSResourceMgr.clickEventBindingByNode(lq_Btn, function()
                ActivityHalloweenViewMgr.hide()
                MissionListMgr.show(SceneMgr.getRunningScene, 2)
            end)
        elseif v.id == 234 then
            CSResourceMgr.clickEventBindingByNode(lq_Btn, function()
                ActivityHalloweenViewMgr.hide()
                ActivityViewMgr.show(SceneMgr.getRunningScene)
            end)
        elseif v.id == 235 then
            ActivityHalloweenViewMgr.setTimeNodes(itemNodes[v.id], lastTime, 385, 52, 415, 52, 440, 47)
            if ActivitiesData then
                if ActivitiesData.recharge then
                    if ActivitiesData.recharge["6"] then
                        if ActivitiesData.recharge["6"]["1"] then
                            local isCheck = RechargeViewMgr.checkRechargeTime(ActivitiesData.recharge["6"]["1"].time)
                            CSResourceMgr.setButtonEnabledByNode(lq_Btn, isCheck)
                        end
                    end
                end
            end
            CSResourceMgr.clickEventBindingByNode(lq_Btn, function()
                ActivityHalloweenViewMgr.hide()
                RechargeViewMgr.show(SceneMgr.getRunningScene)
            end)
        elseif v.id == 203 then
            lq_Btn:hide()
            ActivityHalloweenViewMgr.setTimeNodes(itemNodes[v.id], lastTime, 435, 172, 465, 172, 490, 167)
        elseif v.id == 241 or v.id == 246 or v.id == 263 then
            lq_Btn:hide()
        elseif v.id == 242 then
            CSResourceMgr.clickEventBindingByNode(lq_Btn, function()
                ActivityHalloweenViewMgr.hide()
                ExploreViewMgr.show(SceneMgr.getRunningScene)
            end)
            ActivityHalloweenViewMgr.setTimeNodes(itemNodes[v.id], lastTime, 380, 52, 410, 52, 435, 47)
        elseif v.id == 247 then
            CSResourceMgr.clickEventBindingByNode(lq_Btn, function()
                ActivityHalloweenViewMgr.hide()
                MapSeekerMgr.autoSeekPath("TownScene", "b5")
            end)
            ActivityHalloweenViewMgr.setTimeNodes(itemNodes[v.id], lastTime, 405, 62, 435, 62, 460, 57)
        elseif v.id == 264 then
            CSResourceMgr.clickEventBindingByNode(lq_Btn, function()
                ActivityHalloweenViewMgr.hide()
                PurchaseViewMgr.show(SceneMgr.getRunningScene, nil, 2)
            end)
            ActivityHalloweenViewMgr.setTimeNodes(itemNodes[v.id], lastTime, 405, 62, 435, 62, 460, 57)
        elseif v.id == 250 then
            lq_Btn:hide()
            ActivityHalloweenViewMgr.setTimeNodes(itemNodes[v.id], lastTime, 390, 55, 420, 55, 445, 50)
        elseif v.id == 161 then
            --三宠预告
            lq_Btn:hide()
            local petVec = {199, 192, 190}
            local posVec = {115, 350, 560}
            for var=1, 3 do
                local infoBtn = lq_Btn:clone()
                infoBtn:show()
                infoBtn:addTo(lq_Btn:getParent())
                infoBtn:pos(posVec[var], 50)
                infoBtn:setContentSize(120, 50)
                CSResourceMgr.setButtonStringByNode(infoBtn, "activity99", {r=0,g=0,b=0,a=255,w=1,s=1})
                local petID = petVec[var]
                if petID then
                    CSResourceMgr.setButtonEnabledByNode(infoBtn, true)
                    CSResourceMgr.clickEventBindingByNode(infoBtn, function()
                        StatusBarMgr.hideTopInfoBar()
                        PetInfoViewMgr.show(SceneMgr.getRunningScene, petID, function()
                            StatusBarMgr.showTopInfoBar(function()
                                ActivityHalloweenViewMgr.hide()
                            end)
                        end)
                    end)
                else
                    CSResourceMgr.setButtonEnabledByNode(infoBtn, false)
                end
            end
        elseif v.id == 211 then
            ActivityHalloweenViewMgr.setTimeNodes(itemNodes[v.id], lastTime, 345, 50, 375, 50, 400, 45)
            CSResourceMgr.clickEventBindingByNode(lq_Btn, function()
                local url = "http://192.168.240.1:8080/forum.php?gid=101"
                if device.platform=="ios" then
                    iOSFunction.showWebPage(url, true, true)
                elseif device.platform=="android" then
                    AndroidFunction.showWebPage(url, true, true)
                end
            end)
        end
    elseif v.type == ActivityInfo.FetchLogin then
        ActivityHalloweenViewMgr.setTimeNodes(itemNodes[v.id], lastTime, 535, 190, 565, 190, 590, 185)
        infoBtn:show()
        CSResourceMgr.clickEventBindingByNode(infoBtn, function()
            ActivityViewMgr.showSkillBookInfo(v.id, ActivityInfo.FetchLogin)
        end)
        local function refreshLoginCount()
            local loginDay = 1
            local getedDays = 0
            local awardsVec = {}
            if ActivitiesData.login.days then
                getedDays = ActivityViewMgr.getTableCount(ActivitiesData.login.days)
                loginDay = getedDays + 1
            end

            local daydiff = ActivityInterface.getDayDiff(CharInfo.get().activity.login.yday)
            local dayIndex = ActivitiesData.login.count
            if daydiff~=0 then
                dayIndex = dayIndex+1
            end

            if daydiff~=0 or getedDays<ActivitiesData.login.count then
                CSResourceMgr.setButtonStringByNode(lq_Btn, "recharge26", {r=0,g=0,b=0,a=255})
                CSResourceMgr.setButtonEnabledByNode(lq_Btn, true)
            else
                CSResourceMgr.setButtonStringByNode(lq_Btn, "recharge27", {r=0,g=0,b=0,a=255})
                CSResourceMgr.setButtonEnabledByNode(lq_Btn, false)
            end

            local paramsVec = activityParams[v.id][loginDay]
            if paramsVec==nil then
                paramsVec = activityParams[v.id][#activityParams[v.id]]
            end
            local awardsVec = ActivityHalloweenViewMgr.setAwardsInfo(v.id, paramsVec.awardVec)
            CSResourceMgr.clickEventBindingByNode(lq_Btn, function ()
                NetInterface.sendWithBlock("GC_FetchLoginAwards_Ack", function()
                    local ActivitySend = require("src.Net.Send.ActivitySend")
                    ActivitySend.sendCG_FetchLoginAwards_Req(loginDay)
                end, function ()
                    if ActivitiesData.login.days then
                        table.insert(ActivitiesData.login.days, true)
                    else
                        ActivitiesData.login.days = {true}
                    end
                    refreshLoginCount()
                    AwardsListMgr.show(SceneMgr.getRunningScene, awardsVec)
                end, function (code)
                    TipsMgr.showError(nil, code)
                end)
            end)
            setLabelProgress(labelProcess, {"activity106", dayIndex}, 300, 51)
        end
        refreshLoginCount()
    elseif v.type == ActivityInfo.GetPower then
        local lvIcon = CSResourceMgr.seekNodeByName(itemNodes[v.id], "lvIcon")
        lvIcon:show()
        lvIcon:setPosition(388,80)
        CSResourceMgr.setSpriteTextureByNode(lvIcon, "Item/Activity/activity_figure_parts_120.png")
        --ActivityViewMgr.refreshServerTime()
        local infoVec = lua_string_split(v.params[1], ",")
        local startH = string.gsub(infoVec[1], ":00:00", "")
        local endH = string.gsub(infoVec[2], ":00:00", "")
        CSResourceMgr.setButtonStringByNode(lq_Btn, "recharge26", {r=0,g=0,b=0,a=255})
        CSResourceMgr.clickEventBindingByNode(lq_Btn, function()
            local nowH = tonumber(CocosModuleMgr.getTimeStr(CharInfo.getServerTime(), 2))
            if tonumber(startH)<=nowH and tonumber(endH)>nowH then
                NetInterface.sendWithBlock("GC_FetchDailyActionValue_Ack", function()
                    local ActivitySend = require("src.Net.Send.ActivitySend")
                    ActivitySend.sendCG_FetchDailyActionValue_Req()
                end, function()
                    StandardTipsMgr.show(0, "family111")
                    NetInterface.sendWithBlock("GC_GetActivitiesData_Ack", function()
                        local ActivitySend = require("src.Net.Send.ActivitySend")
                        ActivitySend.sendCG_GetActivitiesData_Req()
                    end, function()
                        CSResourceMgr.setButtonEnabledByNode(lq_Btn, false)
                    end, function(code)
                        TipsMgr.showError(nil, code)
                    end)
                end, function(code)
                    TipsMgr.showError(nil, code)
                end, nil, false)
            else
                StandardTipsMgr.show(1, "activity105")
            end
        end)
        ActivityHalloweenViewMgr.setTimeNodes(itemNodes[v.id], lastTime, 520, 215, 550, 215, 575, 210)
    elseif v.type == ActivityInfo.PurchaseAward or v.type == ActivityInfo.ConsumeRebate then
        local tagStr, tagString, numPosx = "consume", "Consume", 80
        if v.type == ActivityInfo.PurchaseAward then
            tagStr, tagString, numPosx = "recharge", "Recharge", 40
        end
        CSResourceMgr.setButtonStringByNode(lq_Btn, "activity44", {r=0,g=0,b=0,a=255})
        local nodesVec, awardsVec = {}, {}
        local function resetItem(aID)
            if activityParams[v.id][1].type==3 then
                awardsVec = ActivityHalloweenViewMgr.setAwardsInfo(v.id, activityParams[v.id][#activityParams[v.id]].awardVec)
                if not activityParams[v.id][aID] then
                    CSResourceMgr.setButtonStringByNode(lq_Btn, "recharge27", {r=0,g=0,b=0,a=255})
                    CSResourceMgr.setButtonEnabledByNode(lq_Btn, false)
                end
            else
                local vec = nil
                local mCash = nil
                local showNum = true
                if not activityParams[v.id][aID] then
                    vec = {}--activityParams[v.id][#activityParams[v.id]].awardVec
                    CSResourceMgr.setButtonStringByNode(lq_Btn, "recharge27", {r=0,g=0,b=0,a=255})
                    CSResourceMgr.setButtonEnabledByNode(lq_Btn, false)
                    mCash = 0--activityParams[v.id][#activityParams[v.id]].mCash
                    showNum = false
                    local maskNode = display.newSprite("Item/ActivityHalloween/activity_mask_"..tagStr..".png")
                    maskNode:addTo(itemNodes[v.id])
                    maskNode:setAnchorPoint(0, 0)
                    maskNode:pos(0, 0)
                else
                    vec = activityParams[v.id][aID].awardVec
                    mCash = activityParams[v.id][aID].mCash
                end
                local strVec = ActivityInterface.changeStrToTable(tostring(mCash))
                ActivityHalloweenViewMgr.setNumList(strVec, v.id, v.type, {x=numPosx, y=40}, 0.4):setVisible(showNum)
                for var=1, #nodesVec do
                    nodesVec[var]:removeFromParent(true)
                end
                nodesVec, awardsVec = ActivityHalloweenViewMgr.setAwardsInfoNew(v.id, vec, 270, 50, 80)
            end
        end
        local function refreshUpgrade()
            local canTake = false
            local aID = 1
            for k1, v1 in pairs(ActivitiesData[tagStr][tostring(v.id)]) do
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
                    ActivityInterface["fetch"..tagString.."Awards"](v.id,activityParams[v.id][aID].mCash, function()
                        ActivitiesData[tagStr][tostring(v.id)][tostring(activityParams[v.id][aID].mCash)] = {}
                        ActivitiesData[tagStr][tostring(v.id)][tostring(activityParams[v.id][aID].mCash)].token = true
                        AwardsListMgr.show(SceneMgr.getRunningScene, awardsVec)
                        if PetEducationMgr.getTableLength(awardsVec) > 0 then
                            showGetPet()
                        end
                        canTake = false
                        refreshUpgrade()
                    end)
                end)
            else
                CSResourceMgr.setButtonEnabledByNode(lq_Btn, false)
            end
        end
        local curNum = 0
        local isValid = false
        if ActivitiesData then
            if ActivitiesData[tagStr] then
                if ActivitiesData[tagStr][tostring(v.id)] then
                    local data = ActivitiesData[tagStr][tostring(v.id)]
                    local time = ActivitiesData[tagStr].yday
                    local daydiff = ActivityInterface.getDayDiff(time)
                    if daydiff==0 or tonumber(activityParams[v.id][1].type) ~= 3 then
                    	isValid = true
                    end
                end
            end
        end
        if isValid then
            refreshUpgrade()
            curNum = ActivitiesData[tagStr][tostring(v.id)].total or 0
        else
            resetItem(1)
            CSResourceMgr.setButtonEnabledByNode(lq_Btn, false)
        end
        if activityParams[v.id][1].type==3 then
            ActivityHalloweenViewMgr.setTimeNodes(itemNodes[v.id], lastTime, 450, 200, 480, 200, 505, 195)
            setLabelProgress(labelProcess, {"activity116", curNum, activityParams[v.id][1].mCash}, 300, 51)
        else
            local symbol = nil
            if v.type == ActivityInfo.PurchaseAward then
                symbol = display.newSprite("Item/Activity/activity_number_yuan.png")
                symbol:scale(0.8)
                symbol:pos(600, 120)
            else
                symbol = display.newSprite("UI/CommonFiles/ico_lanzuan.png")
                symbol:scale(0.5)
                symbol:pos(316, 120)
            end
            symbol:addTo(itemNodes[v.id])
            symbol:zorder(100)

            infoBtn:show()
            infoBtn:setPositionY(307)
            CSResourceMgr.clickEventBindingByNode(infoBtn, function()
                ActivityHalloweenViewMgr.showSkillBookInfo(v.id, v.type)
            end)
            local finalVec = activityParams[v.id][#activityParams[v.id]].awardVec
            ActivityHalloweenViewMgr.setAwardsInfo(v.id, finalVec, nil, false)
            ActivityHalloweenViewMgr.setAwardsInfoPos(v.id, 340, 190, 110)
            ActivityHalloweenViewMgr.addProcessBar(v.id, curNum, activityParams[v.id][#activityParams[v.id]].mCash, {x=460, y=115})
            ActivityHalloweenViewMgr.setTimeNodes(itemNodes[v.id], lastTime, 140, 120, 170, 120, 195, 115)
        end
    elseif v.type == ActivityInfo.PVPArenaGradePoint or v.type == ActivityInfo.TeamDungeon or v.type == ActivityInfo.WorldBoss then
        local infos = {
            [ActivityInfo.PVPArenaGradePoint]   = {"pvpArenaGradePoint", "PVPArenaGradePoint", {505, 210, 534, 212, 555, 208}},
            [ActivityInfo.TeamDungeon]          = {"teamDungeon", "TeamDungeon", {505, 210, 534, 212, 555, 208}},
            [ActivityInfo.WorldBoss]            = {"worldBoss", "WorldBoss", {505, 203, 534, 205, 555, 203}},
        }
        local tagStr1, tagStr2 = infos[v.type][1], infos[v.type][2]
        local posVec = infos[v.type][3]
        local awardsVec = ActivityHalloweenViewMgr.setAwardsInfo(v.id, activityParams[v.id][1].awardVec)
        CSResourceMgr.setButtonStringByNode(lq_Btn, "recharge26", {r=0,g=0,b=0,a=255})
        local isToday = false
        local haveFinish = false
        local haveToken = false
        local finishTimes = 0
        local needFinishTimes = activityParams[v.id][1].count
        if ActivitiesData and ActivitiesData[tagStr1] and ActivitiesData[tagStr1][tostring(v.id)] then
            local time  = ActivitiesData[tagStr1][tostring(v.id)].time
            local times = ActivitiesData[tagStr1][tostring(v.id)].times
            local token = ActivitiesData[tagStr1][tostring(v.id)].token
            haveToken = CocosModuleMgr.getDayTimeDiff(CharInfo.getServerTime(), token, 21600) == 0
            isToday = CocosModuleMgr.getDayTimeDiff(CharInfo.getServerTime(), time, 21600) == 0
            haveFinish = times >= needFinishTimes
            finishTimes = isToday == true and times or 0
            if isToday == true and haveFinish == true and haveToken == false then
                CSResourceMgr.setButtonEnabledByNode(lq_Btn, true)
            else
                if isToday == true and haveFinish == true and haveToken == true then
                    CSResourceMgr.setButtonStringByNode(lq_Btn, "recharge27", {r=0,g=0,b=0,a=255})
                end
                CSResourceMgr.setButtonEnabledByNode(lq_Btn, false)
            end
        else
            CSResourceMgr.setButtonEnabledByNode(lq_Btn, false)
        end
        CSResourceMgr.clickEventBindingByNode(lq_Btn, function ()
            NetInterface.sendWithBlock("GC_FETCH"..string.upper(tagStr1).."AWARDS_ACK", function()
                local activitySend = require("src/Net/Send/ActivitySend.lua")
                activitySend["sendCG_Fetch"..tagStr2.."Awards_Req"]({
                    aID = v.id,
                })
            end, function ()
                CSResourceMgr.setButtonStringByNode(lq_Btn, "recharge27", {r=0,g=0,b=0,a=255})
                CSResourceMgr.setButtonEnabledByNode(lq_Btn, false)
                AwardsListMgr.show(SceneMgr.getRunningScene, awardsVec)
            end, function ()
            end)
        end)
        setLabelProgress(labelProcess, {"activity55", math.min(finishTimes,needFinishTimes), needFinishTimes}, 320, 51)
        if posVec then
        	ActivityHalloweenViewMgr.setTimeNodes(itemNodes[v.id], lastTime, posVec)
        end
    elseif v.type == ActivityInfo.CollectPet then
        ActivityHalloweenViewMgr.setGoToButton(itemNodes[v.id], function()
            CollectPetActivityViewMgr.show(SceneMgr.getRunningScene)
        end)
        ActivityHalloweenViewMgr.setTimeNodes(itemNodes[v.id], lastTime, 470, 170, 500, 170, 525, 165)
    elseif v.type == ActivityInfo.ContinueLogin then
        local awardsVec = ActivityHalloweenViewMgr.setAwardsInfo(v.id, activityParams[v.id][1].awardVec)
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
            end, function (code)
                TipsMgr.showError(nil, code)
            end)
        end)
        setLabelProgress(labelProcess, {"activity66", math.min(count,needDays), needDays}, 320, 51)
    elseif v.type == ActivityInfo.BossAttackCount or v.type == ActivityInfo.BossCombo 
        or v.type == ActivityInfo.PVPArena or v.type == ActivityInfo.SurvivalBattle or v.type == ActivityInfo.ExpeditionClear
        or v.type == ActivityInfo.ExpeditionJoin or v.type == ActivityInfo.ExpeditionWin then
        local posVec = {
            [ActivityInfo.BossCombo]        = {320, {505, 203, 534, 205, 555, 203}},
            [ActivityInfo.BossAttackCount]  = {300, {505, 203, 534, 205, 555, 203}},
            [ActivityInfo.PVPArena]         = {320, {505, 203, 534, 205, 555, 203}},
            [ActivityInfo.SurvivalBattle]   = {300, {480, 200, 510, 200, 535, 195}},
            [ActivityInfo.ExpeditionClear]  = {300, {510, 182, 540, 182, 565, 177}},
            [ActivityInfo.ExpeditionJoin]   = {300, {510, 182, 540, 182, 565, 177}},
            [ActivityInfo.ExpeditionWin]    = {300, {510, 182, 540, 182, 565, 177}},
        }
        local stringVec = {
            [ActivityInfo.BossCombo]        = "activity65",
            [ActivityInfo.BossAttackCount]  = "activity65",
            [ActivityInfo.PVPArena]         = "activity109",
            [ActivityInfo.SurvivalBattle]   = "activity103",
            [ActivityInfo.ExpeditionClear]  = "activity113",
            [ActivityInfo.ExpeditionJoin]   = "activity114",
            [ActivityInfo.ExpeditionWin]    = "activity113",
        }
        ActivityHalloweenViewMgr.setTimeNodes(itemNodes[v.id], lastTime, posVec[v.type][2])
        if #activityParams[v.id]>1 then
        	infoBtn:show()
        end
        CSResourceMgr.clickEventBindingByNode(infoBtn, function()
            ActivityViewMgr.showSkillBookInfo(v.id, v.type)
        end)

        local nextAID = 0
        local function refreshCount()
            CSResourceMgr.setButtonStringByNode(lq_Btn, "recharge26", {r=0,g=0,b=0,a=255})
            local isToday = false
            local haveFinish = false
            local haveToken = false
            local finishTimes = 0
            local aID = 1
            local cnt = 0
            local needFinishTimes = activityParams[v.id][aID].count
            local paramCnt = PetEducationMgr.getTableLength(activityParams[v.id])
            if ActivitiesData and ActivitiesData.dailycount and ActivitiesData.dailycount[tostring(v.id)] then
                local time  = ActivitiesData.dailycount[tostring(v.id)].t
                isToday = CocosModuleMgr.getDayTimeDiff(CharInfo.getServerTime(), time, 21600) == 0
                for k2,v2 in pairs(activityParams[v.id]) do
                    if isToday == true then
                        needFinishTimes = activityParams[v.id][aID].count
                        local fn1 = tostring("f"..needFinishTimes)
                        local token1 = ActivitiesData.dailycount[tostring(v.id)][fn1] or false
                        if token1 == true then
                            aID = math.min(aID + 1, paramCnt)
                        else
                            break
                        end
                    end
                end
                if nextAID ~= 0 then
                    aID = math.min(nextAID + 1, paramCnt)
                    needFinishTimes = activityParams[v.id][aID].count
                end
                local fn = tostring("f"..needFinishTimes)
                if nextAID ~= 0 and nextAID >= paramCnt then
                    ActivitiesData.dailycount[tostring(v.id)][fn] = true
                end
                cnt = ActivitiesData.dailycount[tostring(v.id)].count
                local token = ActivitiesData.dailycount[tostring(v.id)][fn] or false
                haveToken = token
                finishTimes = isToday == true and cnt or 0
                haveFinish = cnt >= needFinishTimes
                if isToday == true and haveFinish == true and haveToken == false then
                    CSResourceMgr.setButtonEnabledByNode(lq_Btn, true)
                else
                    if isToday == true and haveFinish == true and haveToken == true then
                        CSResourceMgr.setButtonStringByNode(lq_Btn, "recharge27", {r=0,g=0,b=0,a=255})
                    end
                    CSResourceMgr.setButtonEnabledByNode(lq_Btn, false)
                end
            else
                CSResourceMgr.setButtonEnabledByNode(lq_Btn, false)
            end

            local awardsVec = ActivityHalloweenViewMgr.setAwardsInfo(v.id, activityParams[v.id][aID].awardVec)
            CSResourceMgr.clickEventBindingByNode(lq_Btn, function ()
                NetInterface.sendWithBlock("GC_FETCHDAILYCOUNTACTIVITYAWARD_ACK", function()
                    local activitySend = require("src/Net/Send/ActivitySend.lua")
                    activitySend.sendCG_FetchDailyCountActivityAward_Req({
                        aID = v.id,
                        count = needFinishTimes,
                    })
                end, function ()
                    nextAID = aID
                    refreshCount()
                    AwardsListMgr.show(SceneMgr.getRunningScene, awardsVec)
                end, function ()
                end)
            end)
            setLabelProgress(labelProcess, {stringVec[v.type], math.min(finishTimes,needFinishTimes), needFinishTimes}, 
                posVec[v.type][1], 51)
        end
        refreshCount()
    elseif v.type == ActivityInfo.BossKillTime then
        infoBtn:show()
        CSResourceMgr.clickEventBindingByNode(infoBtn, function()
            ActivityViewMgr.showSkillBookInfo(v.id, v.type)
        end)
        CSResourceMgr.setButtonEnabledByNode(lq_Btn, false)
        local function refreshBossKillTime()
            CSResourceMgr.setButtonStringByNode(lq_Btn, "recharge26", {r=0,g=0,b=0,a=255})
            local isToday = false
            local token = false
            local sendCnt = 1000
            local haveFinish = false
            local index = 1
            if ActivitiesData and ActivitiesData.dailycount and ActivitiesData.dailycount[tostring(v.id)] then
                local time = ActivitiesData.dailycount[tostring(v.id)].t
                isToday = CocosModuleMgr.getDayTimeDiff(time, CharInfo.getServerTime(), 21600) == 0
                for k2,v2 in pairs(activityParams[v.id]) do
                    local fn = tostring("f"..v2.spendTime)
                    token = ActivitiesData.dailycount[tostring(v.id)][fn] or false
                    if isToday == true and token == true then
                        CSResourceMgr.setButtonEnabledByNode(lq_Btn, false)
                        CSResourceMgr.setButtonStringByNode(lq_Btn, "recharge27", {r=0,g=0,b=0,a=255})
                        break
                    end
                end
            end
            local curInfo = WorldBossInfo.getCurBossInfo()
            if curInfo ~= nil then
                haveFinish = curInfo.duration / 60 ~= 0 and curInfo.createTime + curInfo.duration <= CharInfo.getServerTime()
                if isToday == false and token == false and haveFinish == true then
                    index = 1000
                    sendCnt = math.ceil(curInfo.duration / 60)
                    sendCnt = math.max(sendCnt, activityParams[v.id][1].spendTime)
                    for k2,v2 in pairs(activityParams[v.id]) do
                        if curInfo.duration / 60 <= v2.spendTime then
                            index = math.min(index, k2)
                        end
                    end
                    if index ~= 1000 then
                        sendCnt = activityParams[v.id][index].spendTime
                        CSResourceMgr.setButtonEnabledByNode(lq_Btn, true)
                    else
                        index = 1
                    end
                end
            end

            local awardsVec = ActivityHalloweenViewMgr.setAwardsInfo(v.id, activityParams[v.id][index].awardVec, false)
            CSResourceMgr.clickEventBindingByNode(lq_Btn, function ()
                NetInterface.sendWithBlock("GC_FETCHDAILYCOUNTACTIVITYAWARD_ACK", function()
                    local activitySend = require("src/Net/Send/ActivitySend.lua")
                    activitySend.sendCG_FetchDailyCountActivityAward_Req({
                        aID = v.id,
                        count = sendCnt,
                    })
                end, function ()
                    CSResourceMgr.setButtonStringByNode(lq_Btn, "recharge27", {r=0,g=0,b=0,a=255})
                    CSResourceMgr.setButtonEnabledByNode(lq_Btn, false)
                    AwardsListMgr.show(SceneMgr.getRunningScene, awardsVec)
                end, function ()
                end)
            end)

            ActivityHalloweenViewMgr.setTimeNodes(itemNodes[v.id], lastTime, 505, 203, 534, 205, 555, 203)
        end
        refreshBossKillTime()
    elseif v.type == ActivityInfo.LifeSkill then
        infoBtn:show()
        CSResourceMgr.clickEventBindingByNode(infoBtn, function()
            ActivityViewMgr.showSkillBookInfo(v.id, v.type)
        end)
        local awardsVec = {}
        local function resetItem(aID)
            awardsVec = ActivityHalloweenViewMgr.setAwardsInfo(v.id, activityParams[v.id][aID].awardVec)
        end

        local function refreshUpgrade(countID)
            CSResourceMgr.setButtonStringByNode(lq_Btn, "activity44", {r=0,g=0,b=0,a=255})
            CSResourceMgr.clickEventBindingByNode(lq_Btn, function()
                NetInterface.sendWithBlock("GC_FetchDailyCountActivityAward_Ack", function()
                    local activitySend = require("src/Net/Send/ActivitySend.lua")
                    activitySend.sendCG_FetchDailyCountActivityAward_Req({
                        aID = v.id,
                        count = countID-1
                    })
                end, function()
                    AwardsListMgr.show(SceneMgr.getRunningScene, awardsVec)
                    if countID == 3 then
                        resetItem(3)
                        labelProcess:hide()
                        CSResourceMgr.setButtonStringByNode(lq_Btn, "recharge27", {r=0,g=0,b=0,a=255})
                        CSResourceMgr.setButtonEnabledByNode(lq_Btn, false)
                    else
                        setLabelProgress(labelProcess, {"activity73", activityParams[v.id][countID+1].lifeSkillLv, 0, 
                            activityParams[v.id][countID+1].lifeSkillCount}, 320, 51)
                        resetItem(countID+1)
                        CSResourceMgr.setButtonStringByNode(lq_Btn, "activity44", {r=0,g=0,b=0,a=255})
                        CSResourceMgr.setButtonEnabledByNode(lq_Btn, false)
                    end
                end, function(code)
                    TipsMgr.showError(nil, code)
                end)
            end)
        end

        ActivityHalloweenViewMgr.setTimeNodes(itemNodes[v.id], lastTime, 450, 200, 480, 200, 505, 195)

        if ActivitiesData and ActivitiesData.dailycount and ActivitiesData.dailycount[tostring(v.id)] then
            if CocosModuleMgr.getDayTimeDiff(CharInfo.getServerTime(),tonumber(ActivitiesData.dailycount[tostring(v.id)].t),21600) == 0 then
                local a1,a2,a3 = false
                for k,v in pairs(ActivitiesData.dailycount[tostring(v.id)]) do
                    if "f0" == k then
                        a1 = true
                    end
                    if "f1" == k then
                        a2 = true
                    end
                    if "f2" == k then
                        a3 = true
                    end
                end
                if a1 then
                    if a2 then
                        if a3 then
                            resetItem(3)
                            CSResourceMgr.setButtonStringByNode(lq_Btn, "recharge27", {r=0,g=0,b=0,a=255})
                            CSResourceMgr.setButtonEnabledByNode(lq_Btn, false)
                        else
                            if ActivitiesData.dailycount[tostring(v.id)].count >= activityParams[v.id][3].lifeSkillCount then
                                setLabelProgress(labelProcess, {"activity73", activityParams[v.id][3].lifeSkillLv, 
                                    ActivitiesData.dailycount[tostring(v.id)].count, activityParams[v.id][3].lifeSkillCount}, 320, 51)
                                resetItem(3)
                                refreshUpgrade(3)
                            else
                                setLabelProgress(labelProcess, {"activity73", activityParams[v.id][3].lifeSkillLv, 
                                    ActivitiesData.dailycount[tostring(v.id)].count, activityParams[v.id][3].lifeSkillCount}, 320, 51)
                                resetItem(3)
                                CSResourceMgr.setButtonStringByNode(lq_Btn, "activity44", {r=0,g=0,b=0,a=255})
                                CSResourceMgr.setButtonEnabledByNode(lq_Btn, false)
                            end
                        end
                    else
                        if ActivitiesData.dailycount[tostring(v.id)].count >= activityParams[v.id][2].lifeSkillCount then
                            setLabelProgress(labelProcess, {"activity73", activityParams[v.id][2].lifeSkillLv, 
                                ActivitiesData.dailycount[tostring(v.id)].count, activityParams[v.id][2].lifeSkillCount}, 320, 51)
                            resetItem(2)
                            refreshUpgrade(2)
                        else
                            setLabelProgress(labelProcess, {"activity73", activityParams[v.id][2].lifeSkillLv, 
                                ActivitiesData.dailycount[tostring(v.id)].count, activityParams[v.id][2].lifeSkillCount}, 320, 51)
                            resetItem(2)
                            CSResourceMgr.setButtonStringByNode(lq_Btn, "activity44", {r=0,g=0,b=0,a=255})
                            CSResourceMgr.setButtonEnabledByNode(lq_Btn, false)
                        end
                    end
                else
                    if ActivitiesData.dailycount[tostring(v.id)].count >= activityParams[v.id][1].lifeSkillCount then
                        setLabelProgress(labelProcess, {"activity73", activityParams[v.id][1].lifeSkillLv, 
                            ActivitiesData.dailycount[tostring(v.id)].count, activityParams[v.id][1].lifeSkillCount}, 320, 51)
                        resetItem(1)
                        refreshUpgrade(1)
                    else
                        setLabelProgress(labelProcess, {"activity73", activityParams[v.id][1].lifeSkillLv, 
                            ActivitiesData.dailycount[tostring(v.id)].count, activityParams[v.id][1].lifeSkillCount}, 320, 51)
                        resetItem(1)
                        CSResourceMgr.setButtonStringByNode(lq_Btn, "activity44", {r=0,g=0,b=0,a=255})
                        CSResourceMgr.setButtonEnabledByNode(lq_Btn, false)
                    end
                end
            else
                setLabelProgress(labelProcess, {"activity73", activityParams[v.id][1].lifeSkillLv, 0, 
                    activityParams[v.id][1].lifeSkillCount}, 320, 51)
                resetItem(1)
                CSResourceMgr.setButtonStringByNode(lq_Btn, "activity44", {r=0,g=0,b=0,a=255})
                CSResourceMgr.setButtonEnabledByNode(lq_Btn, false)
            end
        else
            setLabelProgress(labelProcess, {"activity73", activityParams[v.id][1].lifeSkillLv, 0, 
                activityParams[v.id][1].lifeSkillCount}, 320, 51)
            resetItem(1)
            CSResourceMgr.setButtonStringByNode(lq_Btn, "activity44", {r=0,g=0,b=0,a=255})
            CSResourceMgr.setButtonEnabledByNode(lq_Btn, false)
        end
    elseif v.type == ActivityInfo.CatchPet then
        lq_Btn:hide()
        ActivityHalloweenViewMgr.setTimeNodes(itemNodes[v.id], lastTime, 520, 245, 550, 245, 575, 240)
        local catchCount = CharInfo.get().catchrateaddcount or 0
        setLabelProgress(labelProcess, {"activity72", catchCount}, 500, 51)
    elseif v.type == ActivityInfo.SurvivalBattleIntro then
        ActivityHalloweenViewMgr.setTimeNodes(itemNodes[v.id], lastTime, 370, 55, 400, 55, 425, 50)
        ActivityHalloweenViewMgr.setGoToButton(itemNodes[v.id], function()
            MapSeekerMgr.autoSeekPath("TownScene", "b4")
            ActivityHalloweenViewMgr.hide()
        end)
    elseif v.type == ActivityInfo.ActivityShop then
        ActivityHalloweenViewMgr.setTimeNodes(itemNodes[v.id], lastTime, 370, 55, 400, 55, 425, 50)
        ActivityHalloweenViewMgr.setGoToButton(itemNodes[v.id], function()
            MapSeekerMgr.autoSeekPath("TownScene", "b4")
            ActivityHalloweenViewMgr.hide()
        end)
    else
        print("未处理活动类型", v.type)
    end
end

return ActivityItemProcessor