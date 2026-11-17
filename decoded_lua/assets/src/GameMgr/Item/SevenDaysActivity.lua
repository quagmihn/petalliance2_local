--region SevenDayActivity.lua
--Date 2016/10/14
--此文件由[BabeLua]插件自动生成
--由于7日活动和正常的活动走的不是同一个逻辑，所以加了这个文件

local SevenDaysActivity = {}
local acitivityresName = "Item/Activity/ActivityView.csb"
local acitivityListTemplate = "Item/Activity/SevenDaysItem.csb"
local AwardSelectViewMgr = require("src.GameMgr.Item.AwardSelectViewMgr")
local SevenDayInfoConfig = nil
local sevenDaysTaskData = {}
local oneDayNameArray = {} --按顺序的活动类型的名单
local oneDayTaskDataMapByName = {} --按关键字排的单日活动
local rewardItemInfo = {}
local sevenDaysQuestTag = {} --记录任务标签id
local curDayTab = nil
local isOpen = true --屏蔽天数限制开关
local oneDayQusetTagRedPoint =  {} --红点集合
local curTabid = 1
local daylimit = true -- 添加天数领取

local function loadQuestTagIndex()
    local function loadOneDayQuestTag(dayindex)
        oneDayNameArray = {}
        for i = 1,#sevenDaysTaskData[dayindex] do 
            local data = sevenDaysTaskData[dayindex][i]
            local insertflag = true
            for j=1,#oneDayNameArray do 
                if oneDayNameArray[j] == data.questTabTag then 
                    insertflag = false
                    break
                end
            end

            if insertflag == true then 
                insertflag = false
                sevenDaysQuestTag[data.questTabTag] = #oneDayNameArray+1
            end
        end
    end

    for j=1,7 do 
        loadOneDayQuestTag(j)
    end
end


local function loadOneDayQuestInfo(dayindex)
    local list = CSResourceMgr.getNodeByName(acitivityresName, "list2")
    list:removeAllItems()
    for i=1,7 do 
        local btn = CSResourceMgr.getNodeByName(acitivityresName,"btn_day"..i)
        CSResourceMgr.setButtonEnabledByNode(btn,true)
    end

    oneDayNameArray = {}
    oneDayTaskDataMapByName= {}
    oneDayQusetTagRedPoint = {}
    for i = 1,#sevenDaysTaskData[dayindex] do 
        local data = sevenDaysTaskData[dayindex][i]
        local insertflag = true

        if  SevenDayRedPointManager.getShowTabRedPoint(dayindex,data.id) then 
            oneDayQusetTagRedPoint[data.questTabTag] = 1
        end

        for j=1,#oneDayNameArray do 
            if oneDayNameArray[j] == data.questTabTag then 
                insertflag = false
                break
            end
        end

        if insertflag == true then 
            insertflag = false
            table.insert(oneDayNameArray,data.questTabTag)
        end
        if oneDayTaskDataMapByName[data.questTabTag] == nil then 
            local datatable = {}
            table.insert(datatable,data)
            oneDayTaskDataMapByName[data.questTabTag] = datatable
        else
            table.insert(oneDayTaskDataMapByName[data.questTabTag],data)
        end
    end

    local btn2 = CSResourceMgr.getNodeByName(acitivityresName,"btn_day"..dayindex)
    CSResourceMgr.setButtonEnabledByNode(btn2,false)

    for i = 1,#oneDayNameArray do 
        local tabtext = CSResourceMgr.getNodeByName(acitivityresName, "txt_select"..i)
        CSResourceMgr.setLabelStringByNode(tabtext, oneDayNameArray[i], {r=0,g=0,b=0,a=255}) 
        SevenDaysActivity.setTabsRedPoint(i,acitivityresName,false) 
        if  oneDayQusetTagRedPoint[oneDayNameArray[i]] == 1 then 
            SevenDaysActivity.setTabsRedPoint(i,acitivityresName,true)
        end     
    end
end

local function addRewardInfoItems(itemNode,rewardIdTables)
    local index = 0
    rewardItemInfo={}
    local petList = {}

    local startx =61
    local starty = 91
    local jiangge = 110
    for i = 1,#rewardIdTables do
        
        local rewardInfo = AdventureInfo.getRewardInfoByID(rewardIdTables[i])
        local itemInfoID = 0
        local itemicon = nil
        for j=1,#(rewardInfo.element) do
            local num = rewardInfo.nReward[j]
            local awardElementInfo = ItemInfo.getAwardElementInfoById(rewardInfo.element[j])
            if awardElementInfo.elementType == 1 then
                itemInfoID = 9998
                itemicon = ItemInfo.getItemIconById(itemInfoID,num,nil,true,false)
            elseif awardElementInfo.elementType == 2 then
                itemInfoID = 9999
                itemicon = ItemInfo.getItemIconById(itemInfoID,num,nil,true,false)
            elseif awardElementInfo.elementType == 11 then
                itemInfoID = 9996
                itemicon = ItemInfo.getItemIconById(itemInfoID,num,nil,true,false)
            elseif awardElementInfo.elementType == Proto.AET_PET then--宠物
                itemInfoID = awardElementInfo.elementID
                local petInfo = PokemonInfo.getPokemonInfoByID(awardElementInfo.elementID)
                petList[index+1] = petInfo
                itemicon = ItemInfo.getPetIconById2(itemInfoID,num,nil,true,false)
            else
                itemInfoID = awardElementInfo.elementID
                itemicon = ItemInfo.getItemIconById(itemInfoID,num,nil,true,false)
            end
            --print("iteminfo......................,itemnum:"..itemInfoID,num)
            itemNode:addChild(itemicon)
            itemicon:setScale(0.75)

            itemicon:setPosition(startx+(index)*jiangge,starty)
            index = index+1

            CSResourceMgr.clickEventBindingByNode(itemicon,function() 
                if awardElementInfo.elementType == Proto.AET_PET then 
                    StatusBarMgr.hideTopInfoBar()
                    PetInfoViewMgr.show(SceneMgr.getRunningScene, awardElementInfo.elementID, function ()
                        StatusBarMgr.showTopInfoBar(function()
                            ActivityViewMgr.hide()
                        end)
                    end)
                    
                else
                    local iteminfo = ItemInfo.getItemInfoById(itemInfoID)
                    ItemInfoViewMgr.show(iteminfo,false)
                end
       

            end,3)
        end
    end

    return petList
end

local function createListCell(data,list)
    local listTemplate = CSResourceMgr.createRes(nil, acitivityListTemplate)
    local itemNode = CSResourceMgr.seekNodeByName(listTemplate,"img_base"):clone()
    local image_topline = CSResourceMgr.seekNodeByName(itemNode,"image_topline")
    image_topline:setColor({r=4,g=64,b=74})
    local txt_title = CSResourceMgr.seekNodeByName(itemNode,"txt_title")
    CSResourceMgr.setLabelColorByNode(txt_title, {r=255,g=255,b=255,a=255})
    CSResourceMgr.setLabelStringByNode(txt_title, data.sevenQuestName, {r=0,g=0,b=0,a=255,w=1,s=2})
    --print("data prize name is.............................."..data.sevenQuestName)
    local petList = addRewardInfoItems(itemNode,data.rewardInfos)
    list:pushBackCustomItem(itemNode)

    local dayCount = SevenDaysActivity.getRoleCreateDay()
    local isEnd = dayCount < 8
    if not isOpen then
        isEnd = true
    end
    local isVisible = dayCount >= curDayTab
    local btn_lingqu = CSResourceMgr.seekNodeByName(itemNode, "btn_lingqu")
    btn_lingqu:setVisible(false)
    local btn_qianwang = CSResourceMgr.seekNodeByName(itemNode, "btn_qianwang")
    local DoneSign = CSResourceMgr.seekNodeByName(itemNode, "DoneSign")
    DoneSign:loadTexture(CocosModuleMgr.getWordImage("rw_yiwancheng.png"))
    local loadingbar = CSResourceMgr.seekNodeByName(itemNode,"loadingbar")
    local img_loadingbarbg = CSResourceMgr.seekNodeByName(itemNode,"img_loadingbarbg")
    local txt_qianwang = CSResourceMgr.seekNodeByName(itemNode,"txt_qianwang")
    CSResourceMgr.setLabelColorByNode(txt_qianwang, {r=255,g=255,b=255,a=255})
    CSResourceMgr.setLabelStringByNode(txt_qianwang, "activity45", {r=0,g=0,b=0,a=255,w=1,s=2})
    local txt_lingqu = CSResourceMgr.seekNodeByName(itemNode,"txt_lingqu")
    CSResourceMgr.setLabelColorByNode(txt_lingqu, {r=255,g=255,b=255,a=255})
    CSResourceMgr.setLabelStringByNode(txt_lingqu, "activity44", {r=0,g=0,b=0,a=255,w=1,s=2})

    local function goToProcess()
        StandardTipsMgr.show(1, "activity43")
        UIStack.closeAllUI()
        PurchaseViewMgr.show(SceneMgr.getRunningScene)
    end
    loadingbar:setVisible(false)
    img_loadingbarbg:setVisible(false)

    if isOpen then
        btn_qianwang:setVisible(isVisible)
        btn_lingqu:setVisible(isVisible)

        if not isVisible then
            return
        end
    end

    local check = TaskWatcherManager.checkTaskComplete(data)
    local isGet = TaskWatcherManager.isPrizeAlreadyGet(data.id)
    if not isGet then
        local ret = TaskWatcherManager.checkTaskProgress(data)
        if data.useMoney > 0 then
            txt_qianwang:setVisible(false)
            local moneyTip = CSResourceMgr.seekNodeByName(itemNode,"moneyTip")
            moneyTip:setVisible(true)
            local oldMoney = CSResourceMgr.seekNodeByName(itemNode,"oldMoney")
            local useMoney = CSResourceMgr.seekNodeByName(itemNode,"useMoney")
            CSResourceMgr.setLabelStringByNode(oldMoney, data.oldMoney, {r=0,g=0,b=0,a=255,w=1,s=2})
            CSResourceMgr.setLabelStringByNode(useMoney, data.useMoney, {r=0,g=0,b=0,a=255,w=1,s=2})
            local curMCash = CharInfo.getMCash()
            local canBuy = curMCash >= data.useMoney
            local params = {}
            params.sevenDayID = data.id
            if data.wayToGetReward[1] == 1 then
                CSResourceMgr.clickEventBindingByNode(btn_qianwang,function()
                    if isEnd then
                        if canBuy then
                            AwardSelectViewMgr.show(SceneMgr.getRunningScene,petList,function(selectIndex)
                                NetInterface.sendWithBlock("GC_GetSevenDayAward_Ack", function()
                                    params.selectIndex = selectIndex - 1
                                    local ActivitySend = require("src.Net.Send.ActivitySend")
                                    ActivitySend.sendCG_GetSevenDayAward_Req(params)
                                end, function()
                                    TaskWatcherManager.onGetPrizeFromServer(data,curDayTab)
                                    TaskWatcherManager.setUserGetPriceSuccess(data.id)
                                    TaskWatcherManager.removeRedPointData(data)
                                    DoneSign:setVisible(true)
                                    moneyTip:setVisible(false)
                                    btn_qianwang:setVisible(false)
                                end, function(code)
                                    TipsMgr.showError(scene, code)
                                end)
                            end)
                        else
                            goToProcess()
                        end
                    else
                        StandardTipsMgr.show(1, "activity42")
                    end
                end)
            else
                CSResourceMgr.clickEventBindingByNode(btn_qianwang,function()
                    if isEnd then
                        if canBuy then
                            NetInterface.sendWithBlock("GC_GetSevenDayAward_Ack", function()
                                params.selectIndex = 0
                                local ActivitySend = require("src.Net.Send.ActivitySend")
                                ActivitySend.sendCG_GetSevenDayAward_Req(params)
                            end, function()
                                TaskWatcherManager.onGetPrizeFromServer(data,curDayTab)
                                TaskWatcherManager.setUserGetPriceSuccess(data.id)
                                TaskWatcherManager.removeRedPointData(data)
                                DoneSign:setVisible(true)
                                moneyTip:setVisible(false)
                                btn_qianwang:setVisible(false)
                            end, function(code)
                                TipsMgr.showError(scene, code)
                            end)
                        else
                            goToProcess()
                        end
                    else
                        StandardTipsMgr.show(1, "activity42")
                    end
                end)
            end
        end

        if data.numberMax > 0 then
            if type(ret) == "number" then
                if ret >= data.numberMax then
                    ret = data.numberMax
                    btn_lingqu:setVisible(true)
                    btn_qianwang:setVisible(false)
                else
                    btn_lingqu:setVisible(false)
                    btn_qianwang:setVisible(true)
                end
            else
                if check then
                    local params = {}
                    params.sevenDayID = data.id
                    params.selectIndex = 0
                    CSResourceMgr.clickEventBindingByNode(btn_lingqu,function()
                        local dayCount = SevenDaysActivity.getRoleCreateDay()
                        if dayCount < 8 then 
                            NetInterface.sendWithBlock("GC_GetSevenDayAward_Ack", function()
                                local ActivitySend = require("src.Net.Send.ActivitySend")
                                ActivitySend.sendCG_GetSevenDayAward_Req(params)
                            end, function()
                                TaskWatcherManager.onGetPrizeFromServer(data,curDayTab)
                                TaskWatcherManager.setUserGetPriceSuccess(data.id)
                                TaskWatcherManager.removeRedPointData(data)
                                DoneSign:setVisible(true)
                                btn_lingqu:setVisible(false)
                            end, function(code)
                                TipsMgr.showError(scene, code)
                            end)
                        else
                             StandardTipsMgr.show(1, "activity42")
                        end
                    end)
                else
                    CSResourceMgr.setButtonEnabledByNode(btn_lingqu,false)
                end
            end
            loadingbar:setVisible(true)
            img_loadingbarbg:setVisible(true)
            local txt_progressnum = CSResourceMgr.seekNodeByName(itemNode,"txt_progressnum")
            CSResourceMgr.setLabelColorByNode(txt_progressnum, {r=255,g=255,b=255,a=255})
            CSResourceMgr.setLabelStringByNode(txt_progressnum, ret.."/"..data.numberMax, {r=0,g=0,b=0,a=255,w=1,s=2})
            loadingbar:setPercent((ret/data.numberMax)*100)

            if type(ret) == "number" and ret >= data.numberMax then
                local params = {}
                params.sevenDayID = data.id
                params.selectIndex = 0
                CSResourceMgr.clickEventBindingByNode(btn_lingqu,function()
                    local dayCount = SevenDaysActivity.getRoleCreateDay()
                    if dayCount < 8 then 
                        NetInterface.sendWithBlock("GC_GetSevenDayAward_Ack", function()
                            local ActivitySend = require("src.Net.Send.ActivitySend")
                            ActivitySend.sendCG_GetSevenDayAward_Req(params)
                        end, function()
                            TaskWatcherManager.onGetPrizeFromServer(data,curDayTab)
                            TaskWatcherManager.setUserGetPriceSuccess(data.id)
                            TaskWatcherManager.removeRedPointData(data)
                            DoneSign:setVisible(true)
                            btn_lingqu:setVisible(false)
                        end, function(code)
                            TipsMgr.showError(scene, code)
                        end)
                     else
                        StandardTipsMgr.show(1, "activity42")
                    end
                end)
            end
        end

        if data.useMoney < 0 and data.oldMoney < 0 and data.numberMax < 0 then
            btn_lingqu:setVisible(true)
            btn_qianwang:setVisible(false)
            local params = {}
            params.sevenDayID = data.id
            if data.wayToGetReward[1] ~= 1 then
                params.selectIndex = 0
            end
            if check then
                CSResourceMgr.clickEventBindingByNode(btn_lingqu,function()
                    local dayCount = SevenDaysActivity.getRoleCreateDay()
                    if dayCount < 8 then 
                        NetInterface.sendWithBlock("GC_GetSevenDayAward_Ack", function()
                            local ActivitySend = require("src.Net.Send.ActivitySend")
                            ActivitySend.sendCG_GetSevenDayAward_Req(params)
                        end, function()
                            TaskWatcherManager.onGetPrizeFromServer(data,curDayTab)
                            TaskWatcherManager.setUserGetPriceSuccess(data.id)
                            TaskWatcherManager.removeRedPointData(data)
                            DoneSign:setVisible(true)
                            btn_lingqu:setVisible(false)
                        end, function(code)
                            TipsMgr.showError(scene, code)
                        end)
                     else
                        StandardTipsMgr.show(1, "activity42")
                    end
                end)
            else
                CSResourceMgr.setButtonEnabledByNode(btn_lingqu,false)
            end
        end

        if data.numberMax > 0 then 
            CSResourceMgr.clickEventBindingByNode(btn_qianwang,function()
                if isEnd then
                    data.objectInst:goToProcess()
                else
                    StandardTipsMgr.show(1, "activity42")
                end
            end)           
        end
    else
        btn_lingqu:setVisible(false)
        btn_qianwang:setVisible(false)
        loadingbar:setVisible(false)
        img_loadingbarbg:setVisible(false)
        DoneSign:setVisible(true)
    end
end

local function onTabChange(index)
    curTabid = index
    UnblockLoader.cancel("SevenDaysActivity.setTab")
    for i = 1,4 do
        local btn = CSResourceMgr.getNodeByName(acitivityresName,"btn_select"..i)
        CSResourceMgr.setButtonEnabledByNode(btn,true)
    end 
    local btn2 = CSResourceMgr.getNodeByName(acitivityresName,"btn_select"..index)
    CSResourceMgr.setButtonEnabledByNode(btn2,false)

    local list = CSResourceMgr.getNodeByName(acitivityresName, "list2")
    --print("oneDayNameArray is ......."..oneDayNameArray[index])
    local datatable = oneDayTaskDataMapByName[oneDayNameArray[index]]
    list:removeAllItems()
    local funcTable = {}

    for j=1,#datatable do 
        function loadData()
            local data = datatable[j]
            createListCell(data,list,index)
        end
        table.insert(funcTable,loadData)
    end
    UnblockLoader.load(funcTable, "SevenDaysActivity.setTab",0.05)
end

function SevenDaysActivity.onInitUI(csbres,tabtxt)
    TaskWatcherManager.showAllRedPoint()
    SevenDayRedPointManager.showSevenDayRedPoint()
    local days = SevenDayRedPointManager.getShowDaysRedPoint()
    for i = 1,7 do 
        
        if days[i] == 1 then
            SevenDaysActivity.setDaysRedPoint(i,csbres,true)
        else
            SevenDaysActivity.setDaysRedPoint(i,csbres,false)
        end 
    end
    tabtxt = tabtext or "activity51"--"七日"
    local diff = CocosModuleMgr.getScreenSizeDiff()
    local seventab = CSResourceMgr.seekNodeByName(csbres, "img_seventab") 
    local tposy = seventab:getPositionY()
    seventab:setPositionY(tposy+diff/2.5)
    local list = CSResourceMgr.seekNodeByName(csbres, "list2")
    local ltsize = list:getContentSize()
    list:setContentSize(ltsize.width, ltsize.height+diff)

    --local linebg = CSResourceMgr.seekNodeByName(csbres, "img_line1")
    --local linebgsize = linebg:getContentSize()
    --linebg:setContentSize(linebgsize.width, linebgsize.height+diff)

    local tabtext = CSResourceMgr.seekNodeByName(csbres, "Label4")
    CSResourceMgr.setLabelColorByNode(tabtext, {r=227,g=233,b=255,a=255})
    CSResourceMgr.setLabelStringByNode(tabtext, tabtxt, {r=10,g=22,b=65,a=255,w=1,s=1})
    seventab:setVisible(false)


    local dayCount = SevenDaysActivity.getRoleCreateDay()
    local currentDayTab = 1
    if dayCount < 8 then currentDayTab = dayCount end
    curDayTab = currentDayTab
    loadOneDayQuestInfo(currentDayTab)
    onTabChange(1)


    local daysTip = CSResourceMgr.seekNodeByName(csbres, "daysTip")
    local daystiptitle = CSResourceMgr.seekNodeByName(csbres,"daystiptitle")
    if 8-dayCount >= 0 then  
        CSResourceMgr.setLabelStringByNode(daysTip, CocosModuleMgr.createStringWithFormat({"activity46", 8-dayCount}), {r=10,g=22,b=65,a=255,w=1,s=1})
        if dayCount < 8 then 
            local seconds = SevenDaysActivity.getRoleCreateDaySeconds()
            CSResourceMgr.setLabelStringByNode(daystiptitle,  CocosModuleMgr.createStringWithFormat({"activity108", dayCount+1}), {r=10,g=22,b=65,a=255,w=1,s=1})
            CocosModuleMgr.setTimeLabelCountDown(daysTip,seconds,function()
            end)
        else
          CSResourceMgr.setLabelStringByNode(daystiptitle, CocosModuleMgr.createStringWithFormat({"activity46", 8-dayCount}), {r=10,g=22,b=65,a=255,w=1,s=1})
        end
    else
        CSResourceMgr.setLabelStringByNode(daystiptitle, "activity47", {r=10,g=22,b=65,a=255,w=1,s=1})
    end
    
    --[[
    for k,v in pairs(TaskWatcherManager.tabIndex[1]) do
        SevenDaysActivity.setTabsRedPoint(v,csbres,true)
    end

    for k,v in pairs(TaskWatcherManager.tabIndex) do
        if next(v) and dayCount >= k then
            SevenDaysActivity.setDaysRedPoint(k,csbres,true)
            ActivityViewMgr.setSevenDayRedPoint(true)
        else
            SevenDaysActivity.setDaysRedPoint(k,csbres,false)
        end
    end
    ]]
    if dayCount < 8 then
        local btn_day = CSResourceMgr.seekNodeByName(csbres, "btn_day"..dayCount)
        local effAni = AnimationMgr.createAni(btn_day, "Spine/effects/UI_7tianhuodong.png",
            btn_day:getContentSize().width-10, btn_day:getContentSize().height-10)
        AnimationMgr.playAni(effAni.res, "animation", true, effAni.tag)
    end
    --[[
    local parent = CSResourceMgr.createRes(nil, acitivityListTemplate)
    for i =1,5 do 
        local itemNode = CSResourceMgr.getNodeByName(acitivityListTemplate,"img_base"):clone()
        local image_topline = CSResourceMgr.seekNodeByName(itemNode,"image_topline")
        image_topline:setColor({r=5,g=23,b=43})
        list:pushBackCustomItem(itemNode)
    end
    ]]

    --clickbinding
    for i = 1,4 do 
        local btn = CSResourceMgr.getNodeByName(acitivityresName,"btn_select"..i)
        CSResourceMgr.clickEventBindingByNode(btn,function()
            onTabChange(i)
        end)
    end

    for i=1,7 do 
        local btn = CSResourceMgr.getNodeByName(acitivityresName,"btn_day"..i)
        CSResourceMgr.clickEventBindingByNode(btn,function()
            curDayTab = i
            loadOneDayQuestInfo(i)
            onTabChange(1)
        end)
    end
    if LuaSqlite.LANG_TYPE ~= 1 then
        for i=1,7 do 
            local img = CSResourceMgr.getNodeByName(acitivityresName,"img_day"..i)
            img:loadTexture(CocosModuleMgr.getWordImage("activity_menu_day2_0"..i..".png"))
            img:setScale(1)
            CSResourceMgr.getNodeByName(acitivityresName,"txt_day"..i.."di"):setString("")
            CSResourceMgr.getNodeByName(acitivityresName,"txt_day"..i.."tian"):setString("")
        end        
    end
end

function SevenDaysActivity.onTabChange(tabid,resname,otherres)
    local seventab = CSResourceMgr.getNodeByName(resname, "img_seventab")  
    if tabid == 4 then 
        for var=1, ActivityViewMgr.TAB_NUM do
            CSResourceMgr.setButtonEnabled(resname, "tab"..var, true)
        end        
        seventab:setVisible(true)
        otherres:setVisible(false)
        CSResourceMgr.setButtonEnabled(resname, "tab4", false)
    else
        seventab:setVisible(false)
        otherres:setVisible(true)
        CSResourceMgr.setButtonEnabled(resname, "tab4", true)
    end
end

function SevenDaysActivity.initData()
    
    for i = 1,7 do 
        local sevendaysData = {}
        sevenDaysTaskData[i] = sevendaysData
    end
    if SevenDayInfoConfig == nil then 
        SevenDayInfoConfig = require("src.DatReader.SevenDayInfoConfig")
        SevenDayInfoConfig.init()
    end

    SevenDaysActivity.initSevenDayAllQuest()
    loadQuestTagIndex()
end

function SevenDaysActivity.getQuestTagIndex(questTag)   

    return sevenDaysQuestTag[questTag]
end

--[[
	data.id=Proto.parseDWORD(entry); -- 七日任务ID
	data.sevenQuestType=Proto.parseDWORD(entry); -- 七日任务类型
	data.linkQuestId=Proto.parseDWORD(entry); -- 关联原任务系统id
	data.openDay=Proto.parseDWORD(entry); -- 第几天开放
	data.rewardInfos=Proto.parseVector(entry,Proto.parseDWORD); -- 奖励id数组
	data.sevenQuestName=Proto.parseString(entry); -- 七日任务名称
	data.questTabTag=Proto.parseString(entry); -- 7日活动tab标签
	data.needCondition=Proto.parseVector(entry,Proto.parseDWORD); -- 完成任务的条件
	data.wayToGetReward=Proto.parseVector(entry,Proto.parseDWORD); -- 获得奖励的方式
	data.keyName=Proto.parseString(entry); -- 关键字
    ]]
function SevenDaysActivity.readSevenDayQuestInfoById(id)
    return SevenDayInfoConfig.readEntryByID(id)
end

function SevenDaysActivity.initSevenDayAllQuest()
    sevenDaysTaskData = {}
    TaskWatcherManager.allSevenDayTaskInfo={}
    for var = 1,SevenDayInfoConfig.getEntryCount() do 
        local id = SevenDayInfoConfig.getEntryID(var)
        local data = SevenDaysActivity.readSevenDayQuestInfoById(id)
        --print("day & name is:",data.openDay,data.sevenQuestName,data.questTabTag,data.rewardInfos[1],data.wayToGetReward[1])
        if sevenDaysTaskData[data.openDay] == nil then 
            sevenDaysTaskData[data.openDay] = {}
        end
        local objectInst = TaskWatcherManager.createTaskObject(data)
        if objectInst == nil then 
            print("TaskWatcherManager.createTaskObject error.........................:"..data.sevenQuestType)
        end

        data.objectInst = objectInst
        
        table.insert(sevenDaysTaskData[data.openDay],data)

        local keystr = "seven"..data.id
        TaskWatcherManager.sevenDaysQuestPrizeTable[keystr] = 0
    end    
end


function SevenDaysActivity.getSevenDaysAllQuest()
    local vec = {}
    for var = 1,SevenDayInfoConfig.getEntryCount() do 
        local id = SevenDayInfoConfig.getEntryID(var)
        local data = SevenDaysActivity.readSevenDayQuestInfoById(id)
        --print("day & name is:",data.openDay,data.sevenQuestName,data.questTabTag,data.rewardInfos[1],data.wayToGetReward[1])
        --[[
        local MeiRiLiBaoWatcher = require("src.GameMgr.TaskWatcher.MeiRiLiBaoWatcher")
        local meirilibao = MeiRiLiBaoWatcher.new(data)
        print("meirilibaoname is............................................:"..meirilibao:getTaskTypeName())
        ]]
        table.insert(vec,data)
    end

    return vec;
end

function SevenDaysActivity.getRoleCreateDay()
    local time = CharInfo.getServerTime()
    local day = (time - GameLogMgr.roleInfo.roleCreateTime)/86400
    return math.floor(day) + 1
end

function SevenDaysActivity.getRoleCreateDaySeconds()
    local time = CharInfo.getServerTime()
    local passtime = (time-GameLogMgr.roleInfo.roleCreateTime)%86400
    local remainsecs = 86400 - passtime
    print("remainsecs is ..........",remainsecs)
    return remainsecs
end

function SevenDaysActivity.setDaysRedPoint(var,resname,enable)
    print("var is ,resname is,enable is......",var,resname,enable)

    local redpoint = CSResourceMgr.seekNodeByName(resname, "red_point"..var)
    redpoint:setVisible(enable)
end

function SevenDaysActivity.setDaysRedPoint2(var,resname,enable)
    print("var is ,resname is,enable is......",var,resname,enable)
  
    local redpoint = CSResourceMgr.getNodeByName(resname, "red_point"..var)
    redpoint:setVisible(enable)
end

function SevenDaysActivity.setTabsRedPoint(tabid,resname,enable)
    local redpoint = CSResourceMgr.getNodeByName(resname, "red_point1"..tabid)
    redpoint:setVisible(enable)
end

function SevenDaysActivity.refreshRedPoint()
    oneDayQusetTagRedPoint = {}
    local dayindex = curDayTab
    for i = 1,#sevenDaysTaskData[dayindex] do 
        local data = sevenDaysTaskData[dayindex][i]

        if  SevenDayRedPointManager.getShowTabRedPoint(dayindex,data.id) then 
            oneDayQusetTagRedPoint[data.questTabTag] = 1
        end

    end

    for i = 1,#oneDayNameArray do 
        SevenDaysActivity.setTabsRedPoint(i,acitivityresName,false) 
        if  oneDayQusetTagRedPoint[oneDayNameArray[i]] == 1 then 
            SevenDaysActivity.setTabsRedPoint(i,acitivityresName,true)
        end     
    end   

    local days = SevenDayRedPointManager.getShowDaysRedPoint()
    for i = 1,7 do 
        
        if days[i] == 1 then
            SevenDaysActivity.setDaysRedPoint2(i,acitivityresName,true)
        else
            SevenDaysActivity.setDaysRedPoint2(i,acitivityresName,false)
        end 
    end

    SevenDayRedPointManager.showSevenDayRedPoint()
end

return SevenDaysActivity


--endregion
