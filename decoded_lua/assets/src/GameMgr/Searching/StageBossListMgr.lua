local StageBossListMgr = {}

StageBossListMgr.RANK_LIST_SIZE = 20
StageBossListMgr.RANK_REQUEST_TIMEINTERVAL = 60

StageBossListMgr.listNum = 0
StageBossListMgr.currentDataNum = 0
StageBossListMgr.listLoadCallback = nil

local resName = ""
local resNameA = ""
local resNameB = ""
local resNameC = ""
local resNameD = ""
local resNameBG = ""

local tagC = "tabC"
local tagD = "tabD"

local tabSortVec = {}
local tabname = {}
local timeInfoVec = {}
local playerNameLabelVec = {}
local playerNameStrVec = {}
local curTab = 1
local requestRankTime = 0

local myStageVec = {}
local stageItems = {}
local openList   = {}
local nearList   = {}
local closeList  = {}

local labelColor = {
    {r=0,g=0,b=0,a=255},
    {r=255,g=252,b=0,a=255},
    {r=166,g=243,b=255,a=255},
    {r=255,g=243,b=227,a=255},
    {r=227,g=233,b=255,a=255},--5
    {r=108,g=122,b=144,a=255},
    {r=196,g=230,b=252,a=255},
    {r=144,g=161,b=176,a=255},
}

local outlineColor = {
    {r=0,g=0,b=0,a=255},
    {r=0,g=0,b=0,a=255,w=1,s=1},
    {r=0,g=0,b=0,a=255,w=1,s=2},
    {r=89,g=47,b=5,a=255,w=1,s=2},
    {r=10,g=22,b=65,a=255,w=1,s=2},--5
    {r=194,g=86,b=71,a=255,s=2},
}

function StageBossListMgr.Init()
    resName = "Searching/StageBoss/StageBossList.csb"
    resNameA = "Searching/StageBoss/StageTabA.csb"
    resNameB = "Searching/StageBoss/StageTabBNew.csb"
    resNameC = "Searching/StageBoss/StageTabA.csb"
    resNameD = "Searching/StageBoss/StageTabA.csb"
    resNameBG = "Pet/Formation/FormationBGNew.csb"
    
    tabSortVec = {}
    tabname = {"stageboss2", "stageboss15", "stageboss16", "stageboss3"}
    timeInfoVec = {}
    playerNameLabelVec = {}
    playerNameStrVec = {}
    curTab = 1
    requestRankTime = 0
    
    myStageVec = {}
    stageItems = {}
    openList  = {}
    nearList  = {}
    closeList = {}
end

function StageBossListMgr.setQueryCallback(infoVec, queryDidFinishFunc)
    local myStageIDVec = {}
    for k,v in pairs(infoVec) do 
        table.insert(myStageIDVec, v.id) 
    end

    StageBossListMgr.listLoadCallback = function()
        local info, stageID
        for i = 1, #myStageIDVec do
            stageID = myStageIDVec[i]
            info = TerritorialInfo.getStageBossInfo_NOPETS(stageID)
            if info then
                playerNameStrVec[stageID] = info.nickname or ""
            end
        end
        if queryDidFinishFunc then queryDidFinishFunc() end
    end

    NetInterface.sendWithBlock("GC_TERRITORYINFONOPETS_ACK", function()
        local TerritorialSend = require("src.Net.Send.TerritorialSend")
        TerritorialSend.sendCG_TerritoryInfoNoPets_Req(myStageIDVec)
    end, function()
    end)
end

function StageBossListMgr.show(scene)
    tabSortVec = {2,3,1,4}
    timeInfoVec = {}
    playerNameLabelVec = {}
    curTab = tabSortVec[1]
    
    myStageVec = {}
    stageItems = {}
    openList  = {}
    nearList  = {}
    closeList = {}

    local function checkTab()
        StageBossListMgr.setTabA(curTab==1)
        StageBossListMgr.setTabB(curTab==4)
        StageBossListMgr.setTabC(curTab==2)
        StageBossListMgr.setTabD(curTab==3)
    end

    UIStack.push("StageBossListMgr", StageBossListMgr.hide, true)

    local function loadBG()
        local bgLayer = CSResourceMgr.createRes(scene, resNameBG, "StageBossListMgr")
        bgLayer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resNameBG, 320, 480, "StageBossListMgr")
        bgLayer:setOpacity(0)
        transition.fadeIn(bgLayer, {time=0.3})
    end

    local function loadCSB()
        CSResourceMgr.createRes(scene, resName):setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resName, 320, 480)
        CSResourceMgr.getCsbObj(resName):setVisible(false)

        local diff = CocosModuleMgr.getScreenSizeDiff()
        local frame = CSResourceMgr.getNodeByName(resName, "frame")
        local fsize = frame:getContentSize()
        frame:setContentSize(fsize.width, fsize.height+diff)
        local db = CSResourceMgr.getNodeByName(resName, "db")
        local dsize = db:getContentSize()
        db:setContentSize(dsize.width, dsize.height+diff)
        db:setLocalZOrder(4)
        local diban = CSResourceMgr.getNodeByName(resName, "diban")
        local dbsize = diban:getContentSize()
        diban:setContentSize(dbsize.width, dbsize.height+diff)
        diban:setLocalZOrder(5)

        CSResourceMgr.getNodeByName(resName,"help"):setVisible(false)
        CSResourceMgr.getNodeByName(resName,"split"):setLocalZOrder(5)

        local function movefunc(cellname)
            local node = CSResourceMgr.getNodeByName(resName, cellname)
            local nposy = node:getPositionY()
            node:setPositionY(nposy+diff)
            return nposy+diff
        end
        local nodeVec = {"title", "help", "close","split"}
        for var=1, #nodeVec do
            movefunc(nodeVec[var])
        end
        local tabposY = 0
        for var=1, #tabname do
            tabposY = movefunc("tab"..var)
        end
        
        -- resort tabs
        local tabposX = {}
        for var=1, #tabname do
            tabposX[var] = CSResourceMgr.getNodeByName(resName, "tab"..var):getPositionX()
        end
        for i = 1, #tabSortVec do
            local node = CSResourceMgr.getNodeByName(resName, "tab"..tabSortVec[i])
            node:setPositionX(tabposX[i])
        end

        CSResourceMgr.setLabelColor(resName, "title", {r=166,g=243,b=255,a=255})
        CSResourceMgr.setLabelString(resName, "title", "stageboss1", "", {r=37,g=54,b=75,a=255}, nil, 150)
        CSResourceMgr.clickEventBinding(resName, "close", function()
            StageBossListMgr.hide()
        end)
        CSResourceMgr.clickEventBinding(resName, "help", function()
            print("stage boss help")
        end, "", 1)
        local textColor = {{r=82,g=82,b=82,a=255}, {r=255,g=255,b=255,a=255}}
        local outlineColor = {{r=255,g=255,b=255,a=255}, {r=209,g=138,b=0,a=255}}
        for key=1, #tabname do
            local var = tabSortVec[key]
            CSResourceMgr.clickEventBinding(resName, "tab"..var, function()
                local n = curTab
                CSResourceMgr.setButtonEnabled(resName, "tab"..n, true)
                CSResourceMgr.setLabelString(resName, "tabtext"..n, tabname[n], "", outlineColor[1], nil, 150)
                CSResourceMgr.setLabelColor(resName, "tabtext"..n, textColor[1])
                CSResourceMgr.getNodeByName(resName, "tab"..n):setScale(1)
                CSResourceMgr.getNodeByName(resName, "tab"..n):setPositionY(tabposY)
                CSResourceMgr.getNodeByName(resName, "tab"..n):setLocalZOrder(0)
                for k=1, #tabname do
                    local kk = tabSortVec[k]
                    CSResourceMgr.getNodeByName(resName, "tab"..kk):setLocalZOrder(k<key and 3+k-key or 3-k+key)
                end
                curTab = var
                checkTab()
                CSResourceMgr.setButtonEnabled(resName, "tab"..var, false)
                CSResourceMgr.setLabelString(resName, "tabtext"..var, tabname[var], "", outlineColor[2], nil, 150)
                CSResourceMgr.setLabelColor(resName, "tabtext"..var, textColor[2])
                CSResourceMgr.getNodeByName(resName, "tab"..var):setScale(1.2)
                CSResourceMgr.getNodeByName(resName, "tab"..var):setPositionY(tabposY+8)
                -- CSResourceMgr.getNodeByName(resName, "tab"..var):setLocalZOrder(3)
            end)
            if var==curTab then
                CSResourceMgr.setButtonEnabled(resName, "tab"..var, false)
                CSResourceMgr.setLabelString(resName, "tabtext"..var, tabname[var], "", outlineColor[2], nil, 150)
                CSResourceMgr.setLabelColor(resName, "tabtext"..var, textColor[2])
                CSResourceMgr.getNodeByName(resName, "tab"..var):setScale(1.2)
                CSResourceMgr.getNodeByName(resName, "tab"..var):setPositionY(tabposY+8)
                CSResourceMgr.getNodeByName(resName, "tab"..var):setLocalZOrder(4-key)
            else
                CSResourceMgr.setButtonEnabled(resName, "tab"..var, true)
                CSResourceMgr.setLabelString(resName, "tabtext"..var, tabname[var], "", outlineColor[1], nil, 150)
                CSResourceMgr.setLabelColor(resName, "tabtext"..var, textColor[1])
                CSResourceMgr.getNodeByName(resName, "tab"..var):setScale(1)
                CSResourceMgr.getNodeByName(resName, "tab"..var):setPositionY(tabposY)
                CSResourceMgr.getNodeByName(resName, "tab"..var):setLocalZOrder(4-key)
            end
        end
    end

    local function initStageInfo()
        local allstageVec = TerritorialInfo.getAllTerritorialInfo()
        myStageVec = {}
        for key, var in pairs(allstageVec) do
            if WorldMapInfo.getLockInfoByAdvID(var.id%10000)<=CharInfo.get().maplock then
                table.insert(myStageVec, var)
            end
        end
        
        -- open/close info
        for _, var in pairs(myStageVec) do
            if var.boolOpen then
                openList[var.id] = {}
            end
        end
        for _, var in pairs(myStageVec) do
            if var.countdown <= 3600 and not var.boolOpen then
                nearList[var.id] = {}
            else
                closeList[var.id] = {}
            end
        end

        timeInfoVec = {}
        for index=1, #myStageVec do
            local var = myStageVec[index]
            local key = var.id
            timeInfoVec[key] = {mainIdx=index-1,openListIdx=nil,nearListIdx=nil,}
            timeInfoVec[key].openFunc = function()
            end
            timeInfoVec[key].closeFunc = function()
            end
        end
        StageBossListMgr.refreshServerTime()
    end
    
    local function playCSB()
        CSResourceMgr.getCsbObj(resName):setVisible(true)
        CocosModuleMgr.showUIAnimation(CSResourceMgr.getCsbObj(resName), "up", function()
            --checkTab()
        end)
        StageBossListMgr.setQueryCallback(myStageVec, function()
            checkTab()
        end)
    end
    UnblockLoader.load({loadBG, loadCSB, initStageInfo, playCSB}, "StageBossListMgr.show")
end

function StageBossListMgr.hide()
    HighPerformList.resetAllSchedule()
    transition.stopTarget(CSResourceMgr.getCsbObj(resName))
    UnblockLoader.cancel("StageBossListMgr.setTabA")
    UnblockLoader.cancel("StageBossListMgr.setTabB-rank")
    UnblockLoader.cancel("StageBossListMgr.setTabB")
    UnblockLoader.cancel("StageBossListMgr.setTabC")
    UnblockLoader.cancel("StageBossListMgr.setTabD")
    UnblockLoader.cancel("StageBossListMgr.show")
    timeInfoVec = {}
    playerNameLabelVec = {}
    playerNameStrVec = {}
    myStageVec = {}
    stageItems = {}
    openList  = {}
    nearList  = {}
    closeList = {}
    local list1 = CSResourceMgr.getNodeByName(resNameA, "list")
    if list1 then
        list1:removeAllItems()
    end
    local list2 = CSResourceMgr.getNodeByName(resNameB, "list")
    if list2 then
        list2:removeAllItems()
    end
    local list3 = CSResourceMgr.getNodeByName(resNameC, "list", tagC)
    if list3 then
        list3:removeAllItems()
    end
    local list4 = CSResourceMgr.getNodeByName(resNameD, "list", tagD)
    if list4 then
        list4:removeAllItems()
    end
    CSResourceMgr.removeCSObjectByTag(resNameA)
    CSResourceMgr.removeCSObjectByTag(resNameB)
    CSResourceMgr.removeCSObjectByTag(resNameC,tagC)
    CSResourceMgr.removeCSObjectByTag(resNameD,tagD)
    CSResourceMgr.removeCSObjectByTag(resName)
    CSResourceMgr.removeCSObjectByTag(resNameBG, "StageBossListMgr")
    UIStack.pop("StageBossListMgr")
end

-- @param  id number
-- @return timeStr string
function StageBossListMgr.getStageBeginTime(stageID)
    local info = TerritorialInfo.getTerritorialInfoByID(stageID).territorialList[1]
    if info then
        return string.gsub(info.beginTime,"%.",":")
    end
    return ""
end

local function setStageBossAwards(parent, awardVec, advID)
    if not parent.awarditems then parent.awarditems = {} end

    for k,v in pairs(parent.awarditems) do
        pcall(function() v:removeFromParent() end)
    end
    parent.awarditems = {}

    local tbl = {}
    for k,v in pairs(awardVec) do
        local data = TerritorialInfo.getTerritorialAwardInfoByID(v)
        table.insert(tbl,{data.itemID, data.count})
    end
    local terrInfo = TerritorialInfo.getTerritorialInfoByID(advID).territorialList[1]
    if terrInfo and terrInfo.winPoint then
        table.insert(tbl, {9991, terrInfo.winPoint})
    end

    for k,v in pairs(tbl) do
        local itemID = tonumber(v[1])
        local itemNum = v[2]
        local itemInfo = ItemInfo.getItemInfoById(itemID)
        local sbicon = ItemInfo.getItemIconById(itemID, itemNum, nil, LuaSqlite.LANG_TYPE == 1)
        parent:addChild(sbicon)
        sbicon:setPosition(250+tonumber(k)*70, 43)
        sbicon:setScale(64 / sbicon:getContentSize().width)
        CSResourceMgr.seekNodeByName(sbicon,"name"):setVisible(false)
        
        CSResourceMgr.clickEventBindingByNode(sbicon,function()
            local itemDescViewMgr = require("src.GameMgr.Item.ItemInfoViewMgr")
            itemDescViewMgr.show(itemInfo,false)
        end)

        table.insert(parent.awarditems, sbicon)
    end
end

-- adi, playerNameStr, boolOpen, type
local function updateStageBossItem(parent,info,tabid,isInit)
    tabid = tabid or 1
    local aid = info.aid
    local playerNameStr = info.playerNameStr
    
    local icon = CSResourceMgr.seekNodeByName(parent, "icon")
    local iconPath = PetExploreMgr.ICON_PATH..ExploreInfo.getExploreInfoDataByID(aid).icon
    CSResourceMgr.setSpriteTextureByNode(icon, iconPath)
    icon:setScale(0.6)
    local name = CSResourceMgr.seekNodeByName(parent, "name")
    CSResourceMgr.setLabelColorByNode(name, {r=0,g=174,b=255,a=255})
    local aInfo = AdventureInfo.getAdventureInfoByID(aid) or {}
    CSResourceMgr.setLabelStringByNode(name, aInfo.name or "NULL", {r=4,g=62,b=76,a=255}, nil, 140)
    local title1 = CSResourceMgr.seekNodeByName(parent, "title1")
    CSResourceMgr.setLabelColorByNode(title1, {r=60,g=66,b=62,a=255})
    CSResourceMgr.setLabelStringByNode(title1, "stageboss9", nil, nil, 180)
    local playername = CSResourceMgr.seekNodeByName(parent, "playername")
    CSResourceMgr.setLabelColorByNode(playername, {r=250,g=212,b=3,a=255})
    CSResourceMgr.setLabelStringByNode(playername, playerNameStr, nil, nil, 200)
    playername:enableOutline({r=32,g=31,b=31,a=255}, 1)
    
    local stateLabel = CSResourceMgr.seekNodeByName(parent,"stageState")

    local title2 = CSResourceMgr.seekNodeByName(parent, "title2")
    CSResourceMgr.setLabelColorByNode(title2, {r=60,g=66,b=62,a=255})
    local time = CSResourceMgr.seekNodeByName(parent, "time")
    local search = CSResourceMgr.seekNodeByName(parent, "goto")

    local title3 = CSResourceMgr.seekNodeByName(parent, "title3")
    CSResourceMgr.setLabelColorByNode(title3, {r=60,g=66,b=62,a=255})
    CSResourceMgr.setLabelStringByNode(title3, "Territorialtext2",nil,nil,88)
    
    local function close()
        CSResourceMgr.setLabelStringByNode(title2, "stageboss10", nil, nil, 180)
        CSResourceMgr.setLabelColorByNode(time, {r=255,g=0,b=0,a=255})
        CSResourceMgr.setButtonEnabledByNode(search, false)
        CSResourceMgr.setButtonStringColorByNode(search, {r=211,g=211,b=211,a=255})
        CSResourceMgr.setButtonStringByNode(search, "stageboss11", {r=121,g=121,b=121,a=255})

        CSResourceMgr.setLabelColorByNode(stateLabel, {r=255,g=0,b=0,a=255})
        --CSResourceMgr.setLabelStringByNode(stateLabel,"stageboss17",nil,nil)
    end
    local function open()
        CSResourceMgr.setLabelStringByNode(title2, "stageboss14", nil, nil, 180)
        CSResourceMgr.setLabelColorByNode(time, {r=63,g=127,b=4,a=255})
        CSResourceMgr.setButtonEnabledByNode(search, true)
        CSResourceMgr.setButtonStringColorByNode(search, {r=255,g=255,b=255,a=255})
        CSResourceMgr.setButtonStringByNode(search, "stageboss11", {r=61,g=126,b=0,a=255})
        CSResourceMgr.clickEventBindingByNode(search, function()
            WorldMapMgr.searchAdventureNode(aid, 4)
        end)

        CSResourceMgr.setLabelColorByNode(stateLabel, {r=63,g=127,b=4,a=255})
        --CSResourceMgr.setLabelStringByNode(stateLabel,"stageboss15",nil,nil)
    end
    if info.boolOpen then
        open()
    else
        close()
    end
    if info.type == 1 then
        title2:setVisible(false)
        time:setVisible(false)
        CSResourceMgr.seekNodeByName(parent,"stageState"):setVisible(true)
    elseif info.type == 2 then
        title2:setVisible(true)
        time:setVisible(true)
        CSResourceMgr.seekNodeByName(parent,"stageState"):setVisible(false)
    end
    
    if isInit then
        -- timeInfoVec[aid] = {label=time, closeFunc=close, openFunc=open}
        playerNameLabelVec["tab"..tabid][aid] = playername
    end
    
    local timeStr = StageBossListMgr.getStageBeginTime(aid)
    CSResourceMgr.setLabelStringByNode(stateLabel,CocosModuleMgr.createStringWithFormat({"Territorialtext13",timeStr}))
    
    parent:setCascadeOpacityEnabled(true)
end

function StageBossListMgr.setTabA(boolVisible)
    local parent = CSResourceMgr.getNodeByName(resName, "diban")
    local curNode = CSResourceMgr.getCsbObj(resNameA)
    if curNode then
        curNode:setVisible(boolVisible)
    else
        if boolVisible then
            local function loadCSB()
                local layer = CSResourceMgr.createRes(parent, resNameA)

                local diff = CocosModuleMgr.getScreenSizeDiff()
                local list = CSResourceMgr.getNodeByName(resNameA, "list")
                local lsize = list:getContentSize()
                list:setContentSize(lsize.width, lsize.height+diff)
            end

            local funcTable = {loadCSB}
            local parentVec = {}
            playerNameLabelVec["tab1"] = {}
            local stageIDVec = {}
            -- timeInfoVec = {}
            
--            local allstageVec = TerritorialInfo.getAllTerritorialInfo()
--            myStageVec = {}
--            local stageVec = {}
--            for key, var in pairs(allstageVec) do
--                if WorldMapInfo.getLockInfoByAdvID(var.id%10000)<=CharInfo.get().maplock then
--                    table.insert(myStageVec, var)
--                end
--            end

            --            for key, var in pairs(tmpstageVec) do
            --                if var.boolOpen then
            --                    table.insert(stageVec, var)
            --                end
            --            end
            --            for key, var in pairs(tmpstageVec) do
            --                if not var.boolOpen then
            --                    table.insert(stageVec, var)
            --                end
            --            end
            
            local index = 0
--            for _, var in pairs(myStageVec) do
--                if var.boolOpen then
--                    openList[var.id] = {}
--                end
--            end
--            for _, var in pairs(myStageVec) do
--                if var.countdown <= 3600 and not var.boolOpen then
--                    nearList[var.id] = {}
--                else
--                    closeList[var.id] = {}
--                end
--            end
            
            local RANK_NUM = 1
            local spawncount = 7
            local countperline = 1
            local allnum = countperline*spawncount

            for index=1, #myStageVec do
                if index > allnum then break end

                local var = myStageVec[index]
                local key = var.id
                table.insert(stageIDVec, var.id)
                table.insert(funcTable, function()
                    -- local item = CSResourceMgr.getNodeByName(resNameA, "example"):clone()
                    local parent = CSResourceMgr.createRes(nil,"Searching/StageBoss/StageBossItem.csb","tabA"..index)
                    local item = CSResourceMgr.seekNodeByName(parent,"example")
                    item:removeFromParent()
                    parentVec[key] = item
                    CSResourceMgr.getNodeByName(resNameA, "list"):pushBackCustomItem(item)
                end)
                table.insert(funcTable, function()
                    local parent = parentVec[key]
                    local icon = CSResourceMgr.seekNodeByName(parent, "icon")
                    local iconPath = PetExploreMgr.ICON_PATH..ExploreInfo.getExploreInfoDataByID(key).icon
                    CSResourceMgr.setSpriteTextureByNode(icon, iconPath)
                    icon:setScale(0.6)
                    local name = CSResourceMgr.seekNodeByName(parent, "name")
                    CSResourceMgr.setLabelColorByNode(name, {r=0,g=174,b=255,a=255})
                    local aInfo = AdventureInfo.getAdventureInfoByID(key) or {}
                    CSResourceMgr.setLabelStringByNode(name, aInfo.name or "NULL", {r=4,g=62,b=76,a=255}, nil, 140)
                    local title1 = CSResourceMgr.seekNodeByName(parent, "title1")
                    CSResourceMgr.setLabelColorByNode(title1, {r=60,g=66,b=62,a=255})
                    CSResourceMgr.setLabelStringByNode(title1, "stageboss9", nil, nil, 180)
                    local title2 = CSResourceMgr.seekNodeByName(parent, "title2")
                    CSResourceMgr.setLabelColorByNode(title2, {r=60,g=66,b=62,a=255})
                    local playername = CSResourceMgr.seekNodeByName(parent, "playername")
                    playerNameLabelVec["tab1"][var.id] = playername
                    CSResourceMgr.setLabelColorByNode(playername, {r=250,g=212,b=3,a=255})
                    CSResourceMgr.setLabelStringByNode(playername, playerNameStrVec[var.id] or "", nil, nil, 200)
                    playername:enableOutline({r=32,g=31,b=31,a=255}, 1)
                    local time = CSResourceMgr.seekNodeByName(parent, "time")
                    local search = CSResourceMgr.seekNodeByName(parent, "goto")

                    local title3 = CSResourceMgr.seekNodeByName(parent, "title3")
                    CSResourceMgr.setLabelColorByNode(title3, {r=60,g=66,b=62,a=255})
                    CSResourceMgr.setLabelStringByNode(title3, "Territorialtext2",nil,nil,88)

                    title2:setVisible(false)
                    time:setVisible(false)
                    local stateLabel = CSResourceMgr.seekNodeByName(parent,"stageState")
                    stateLabel:setVisible(true)
                    CSResourceMgr.setLabelColorByNode(stateLabel, {r=60,g=66,b=62,a=255})
                    
                    local function close()
                        CSResourceMgr.setLabelStringByNode(title2, "stageboss10", nil, nil, 180)
                        CSResourceMgr.setLabelColorByNode(time, {r=255,g=0,b=0,a=255})
                        CSResourceMgr.setButtonEnabledByNode(search, false)
                        CSResourceMgr.setButtonStringColorByNode(search, {r=211,g=211,b=211,a=255})
                        CSResourceMgr.setButtonStringByNode(search, "stageboss11", {r=121,g=121,b=121,a=255})

                        CSResourceMgr.setLabelColorByNode(stateLabel, {r=255,g=0,b=0,a=255})
                        --CSResourceMgr.setLabelStringByNode(stateLabel,"stageboss17",nil,nil)
                    end
                    local function open()
                        CSResourceMgr.setLabelStringByNode(title2, "stageboss14", nil, nil, 180)
                        CSResourceMgr.setLabelColorByNode(time, {r=63,g=127,b=4,a=255})
                        CSResourceMgr.setButtonEnabledByNode(search, true)
                        CSResourceMgr.setButtonStringColorByNode(search, {r=255,g=255,b=255,a=255})
                        CSResourceMgr.setButtonStringByNode(search, "stageboss11", {r=61,g=126,b=0,a=255})
                        CSResourceMgr.clickEventBindingByNode(search, function()
                            StageBossListMgr.hide()
                            WorldMapMgr.searchAdventureNode(key, 4)
                        end)

                        CSResourceMgr.setLabelColorByNode(stateLabel, {r=63,g=127,b=4,a=255})
                        --CSResourceMgr.setLabelStringByNode(stateLabel,"stageboss15",nil,nil)
                    end
                    if var.boolOpen then
                        open()
                    else
                        close()
                    end
                    --timeInfoVec[key] = {label=time, closeFunc=close, openFunc=open}
                    
                    local timeStr = StageBossListMgr.getStageBeginTime(var.id)
                    CSResourceMgr.setLabelStringByNode(stateLabel,CocosModuleMgr.createStringWithFormat({"Territorialtext13",timeStr}))

                    parent:setCascadeOpacityEnabled(true)
                    
                    setStageBossAwards(parent, var.awardVec, var.id)
                end)
                table.insert(funcTable, function()
                    parentVec[key]:setVisible(true)
                    parentVec[key]:setScaleY(0)
                    transition.scaleTo(parentVec[key], {scale=1, time=0.2})
                    
                    stageItems[index] = {index=index, aid=key, node=parentVec[key]}
                end)
            end
            
            local HighPerformListFunc = function()
                if #myStageVec <= allnum then return end
                HighPerformList.makeHighPerFormVerticalList(CSResourceMgr.getNodeByName(resNameA, "list"),spawncount,5,countperline,236,216,myStageVec,
                function(item,currentindex)
                    local info = myStageVec[currentindex]
                    updateStageBossItem(item,{aid=info.id,playerNameStr=playerNameStrVec[info.id] or "",boolOpen=info.boolOpen,type=1})
                    setStageBossAwards(item, info.awardVec, info.id)
                    if currentindex > stageItems[spawncount].index then
                        table.insert(stageItems, {index=currentindex, aid=info.id,node=item})
                        table.remove(stageItems,1)
                    elseif currentindex < stageItems[1].index then
                        table.insert(stageItems, 1, {index=currentindex, aid=info.id,node=item})
                        table.remove(stageItems)
                    end
                end)
            end
            table.insert(funcTable, HighPerformListFunc)
            
            UnblockLoader.load(funcTable, "StageBossListMgr.setTabA")
            
--            local myStageIDVec = {}
--            for k,v in pairs(myStageVec) do 
--                table.insert(myStageIDVec, v.id) 
--            end
--            
--            StageBossListMgr.listLoadCallback = function()
--                local info, stageID
--                for i = 1, #myStageIDVec do
--                    stageID = myStageIDVec[i]
--                    info = TerritorialInfo.getStageBossInfo_NOPETS(stageID)
--                    if info then
--                        playerNameStrVec[stageID] = info.nickname or ""
--                    end
--                end
--                UnblockLoader.load(funcTable, "StageBossListMgr.setTabA")
--            end
--            
--            
--            NetInterface.sendWithBlock("GC_TERRITORYINFONOPETS_ACK", function()
            --                local TerritorialSend = require("src.Net.Send.TerritorialSend")
            --                TerritorialSend.sendCG_TerritoryInfoNoPets_Req(myStageIDVec)
            --            end, function()
--            end)
            
        end
    end
end

function StageBossListMgr.setTabB(boolVisible)
    local parent = CSResourceMgr.getNodeByName(resName, "diban")
    local curNode = CSResourceMgr.getCsbObj(resNameB)
    if curNode then
        curNode:setVisible(boolVisible)
    else
        if boolVisible then
            local function loadCSB()
                local layer = CSResourceMgr.createRes(parent, resNameB)

                --                CSResourceMgr.setLabelColor(resNameB, "infotext", {r=197,g=225,b=239,a=255})
                --                CSResourceMgr.setLabelString(resNameB, "infotext", "stageboss4", "", {r=38,g=54,b=76,a=255}, nil, 400)
                --                CSResourceMgr.setLabelColor(resNameB, "mytitle", {r=166,g=243,b=255,a=255})
                --                CSResourceMgr.setLabelString(resNameB, "mytitle", "stageboss7", "", {r=38,g=54,b=76,a=255}, nil, 300)
                CSResourceMgr.setLabelString(resNameB, "title1", "stageboss8", "", {r=194,g=86,b=71,a=255}, nil, 230)

                local btnRewardList = CSResourceMgr.seekNodeByName(layer, "btn_rewardInfo")
                local rewardTitle = CSResourceMgr.seekNodeByName(btnRewardList, "reward_title")
                CSResourceMgr.setLabelStringByNode(rewardTitle, "arena52", outlineColor[3], nil, 135)
                CSResourceMgr.clickEventBindingByNode(btnRewardList, function ()    
                    local _t = TerritorialInfo.getTerritorialRankInfo()  --LostTowerInfo.getLostTowerRankAwardInfoById(2).awardList
                    local t = {}
                    for i, _ in pairs(_t) do
                        t[i] = {id = i, awardItems = {}}
                        for k, v in pairs(_t[i].award) do
                            local _info = TerritorialInfo.getTerritorialAwardInfoByID(v)
                            t[i].awardItems[k] = {
                                elementID = _info.itemID,
                                count     = _info.count,
                            }
                        end
                    end
                    LtRankAwardList.show(SceneMgr.getRunningScene, t, 2)
                end)

                local diff = CocosModuleMgr.getScreenSizeDiff()
                local list = CSResourceMgr.getNodeByName(resNameB, "list")
                local lsize = list:getContentSize()
                list:setContentSize(lsize.width, lsize.height+diff)
                local listdb = CSResourceMgr.getNodeByName(resNameB, "bg3")  -- CSResourceMgr.getNodeByName(resNameB, "listdb")
                local ldbsize = listdb:getContentSize()
                listdb:setContentSize(ldbsize.width, ldbsize.height+diff)
                local function movefunc(cellname)
                    local node = CSResourceMgr.getNodeByName(resNameB, cellname)
                    local nposy = node:getPositionY()
                    node:setPositionY(nposy+diff)
                end
                local nodeVec = {"frame_gradient", "player_info", "diban", "btn_rewardInfo"} -- {"ranktitledb", "mydb"}
                for var=1, #nodeVec do
                    movefunc(nodeVec[var])
                end
            end

            ---设置玩家自己排名
            local function setMyRank(panel1, info)
                local labelName  = CSResourceMgr.seekNodeByName(panel1, "char_name")
                local labelVip   = CSResourceMgr.seekNodeByName(panel1, "vip_level")
                local labelLv    = CSResourceMgr.seekNodeByName(panel1, "char_level")
                local labelTitle = CSResourceMgr.seekNodeByName(panel1, "rank_title")
                local labelRank  = CSResourceMgr.seekNodeByName(panel1, "rank_num")
                local spriteIcon = CSResourceMgr.seekNodeByName(panel1, "char_icon")

                -- vip 0 时隐藏
                CSResourceMgr.seekNodeByName(panel1,"vip_title"):setVisible(CharInfo.getVIPLevel() > 1)
                labelVip:setVisible(CharInfo.getVIPLevel() > 1)

                CSResourceMgr.setLabelStringByNode(labelName, info.name, outlineColor[3], nil, 161)
                CSResourceMgr.setLabelStringByNode(labelVip, info.vipLevel, outlineColor[3])
                CSResourceMgr.setLabelStringByNode(labelLv, "Lv."..CharInfo.getLevel(), outlineColor[3])
                CSResourceMgr.setLabelStringByNode(labelTitle, "arena7", outlineColor[2], nil, 160)
                -- CSResourceMgr.setLabelStringByNode(labelRank, info.rank, outlineColor[1], nil, 138)

                CSResourceMgr.setLabelColorByNode(labelName,  labelColor[2])
                CSResourceMgr.setLabelColorByNode(labelVip,   labelColor[2])
                CSResourceMgr.setLabelColorByNode(labelTitle, labelColor[3])

                CSResourceMgr.setSpriteTextureByNode(spriteIcon, CharInfo.getHeadIcon(CharInfo.getCurfashion()))
                spriteIcon:setScale(1.5)
                spriteIcon:setPositionY(70)

                if info.rank <= 0 or info.rank >= 999 then
                    CSResourceMgr.setLabelStringByNode(labelRank, "stageboss6", outlineColor[1], nil, 138)
                else
                    CSResourceMgr.setLabelStringByNode(labelRank, info.rank, outlineColor[1], nil, 138)
                end

                local wp_icon  = CSResourceMgr.seekNodeByName(panel1,"winPoint_icon")
                local wp_label = CSResourceMgr.seekNodeByName(panel1,"wPointLabel")
                wp_icon:loadTexture(ItemInfo.getItemInfoById(9991).icon)
                wp_icon:setScale(50 / wp_icon:getContentSize().width)
                local score =  TerritorialInfo.getMyRankInfo().score or 0
                CSResourceMgr.setLabelStringByNode(wp_label,score,outlineColor[1],nil)
            end

            local rankPetListOpen = {}
            local function setRankCell(parent, info)
                local icdb = CSResourceMgr.seekNodeByName(parent, "icdb")
                local rank = CSResourceMgr.seekNodeByName(parent, "rank")
                local rankpic = CSResourceMgr.seekNodeByName(parent, "rankpic")
                local rankdesc = CSResourceMgr.seekNodeByName(parent, "rankdesc")
                local line = CSResourceMgr.seekNodeByName(parent, "line")
                line:setColor({r=99,g=115,b=114})
                local vipdb = CSResourceMgr.seekNodeByName(parent, "vipdb")
                vipdb:setColor({r=67,g=85,b=100})
                local frame = CSResourceMgr.seekNodeByName(parent, "frame")
                frame:setColor({r=128,g=161,b=172})
                local infodb = CSResourceMgr.seekNodeByName(parent, "infodb")
                infodb:setColor({r=67,g=85,b=100})
                local playername = CSResourceMgr.seekNodeByName(parent, "playername")
                CSResourceMgr.setLabelStringByNode(playername, info.name, nil, nil, 180)
                playername:enableOutline({r=67,g=85,b=100,a=255}, 1)
                if info.rank==1 then
                    CSResourceMgr.setSpriteTextureByNode(icdb, "UI/CommonFiles/ranking_substrate_gold_su.png")
                    CSResourceMgr.setSpriteTextureByNode(rankpic, "UI/CommonFiles/share_calligraphy_1st.png")
                    line:setColor({r=225,g=176,b=3})
                    vipdb:setColor({r=181,g=122,b=9})
                    frame:setColor({r=220,g=167,b=6})
                    infodb:setColor({r=181,g=122,b=9})
                    playername:enableOutline({r=181,g=122,b=9,a=255}, 1)
                elseif info.rank==2 then
                    CSResourceMgr.setSpriteTextureByNode(icdb, "UI/CommonFiles/ranking_substrate_silver_su.png")
                    CSResourceMgr.setSpriteTextureByNode(rankpic, "UI/CommonFiles/share_calligraphy_2nd.png")
                    line:setColor({r=102,g=175,b=204})
                    vipdb:setColor({r=4,g=122,b=161})
                    frame:setColor({r=92,g=172,b=198})
                    infodb:setColor({r=4,g=122,b=161})
                    playername:enableOutline({r=4,g=122,b=161,a=255}, 1)
                elseif info.rank==3 then
                    CSResourceMgr.setSpriteTextureByNode(icdb, "UI/CommonFiles/ranking_substrate_copper_su.png")
                    CSResourceMgr.setSpriteTextureByNode(rankpic, "UI/CommonFiles/share_calligraphy_3rd.png")
                    line:setColor({r=222,g=154,b=63})
                    vipdb:setColor({r=164,g=107,b=6})
                    frame:setColor({r=220,g=161,b=64})
                    infodb:setColor({r=164,g=107,b=6})
                    playername:enableOutline({r=164,g=107,b=6,a=255}, 1)
                elseif info.rank<=20 and info.rank>0 then
                    CSResourceMgr.setLabelStringByNode(rank, info.rank, {r=10,g=69,b=89,a=255}, nil, 60)
                else
                    CSResourceMgr.setLabelStringByNode(rankdesc, "stageboss6", {r=10,g=69,b=89,a=255}, nil, 60)
                end
                local charIcon = CSResourceMgr.seekNodeByName(parent, "head")
                if info.gender==0 then
                    CSResourceMgr.setSpriteTextureByNode(charIcon, "Charactor/Head/ditu_nv.png")
                else
                    CSResourceMgr.setSpriteTextureByNode(charIcon, "Charactor/Head/ditu_nan.png")
                end
                local vip = CSResourceMgr.seekNodeByName(parent, "vip")
                CSResourceMgr.setLabelStringByNode(vip, info.vipLevel)
                vip:enableOutline({r=0,g=0,b=0,a=255}, 1)
                local level = CSResourceMgr.seekNodeByName(parent, "level")
                CSResourceMgr.setLabelStringByNode(level, "LV "..info.level, {r=0,g=0,b=0,a=255})
                local hourtitle = CSResourceMgr.seekNodeByName(parent, "hourtitle")
                CSResourceMgr.setLabelStringByNode(hourtitle, "stageboss5", nil, nil, 50)
                local hour = CSResourceMgr.seekNodeByName(parent, "hour")
                CSResourceMgr.setLabelStringByNode(hour, info.time, nil, nil, 100)
                local petdb = CSResourceMgr.seekNodeByName(parent, "petdb")
                petdb:setVisible(false)
                local arrow = CSResourceMgr.seekNodeByName(parent, "arrow")
                arrow:setVisible(false)
                local button = CSResourceMgr.seekNodeByName(parent, "button")
                CSResourceMgr.setButtonEnabledByNode(button, false)
                button:setLocalZOrder(1)
                CSResourceMgr.clickEventBindingByNode(button, function()
                    local list = CSResourceMgr.getNodeByName(resNameB, "list")
                    local function resfreshListCell(diff)--收起
                        local children = parent:getChildren()
                        for var=1, #children do
                            local tmpPosy = children[var]:getPositionY()
                            children[var]:setPositionY(tmpPosy+diff)
                        end                            
                        list:refreshView()
                    end
                    if rankPetListOpen[info.rank] then
                        rankPetListOpen[info.rank] = false
                        parent:setContentSize(540, 100)
                        petdb:removeAllChildren()
                        petdb:setVisible(false)
                        resfreshListCell(-100)
                        CSResourceMgr.setButtonEnabledByNode(arrow, true)
                    else
                        local function loadPetsFunc()--展开
                            local petInfos = PokemonInfo.getActivePets()
                            if not petInfos then
                                TipsMgr.show(nil, "arena30")
                                return
                            end

                            rankPetListOpen[info.rank] = true
                            parent:setContentSize(540, 200)

                            local petDiffx = 88
                            local petOffsetPosY = 17
                            for var=1, #petInfos do
                                local petInfo = petInfos[var]
                                local tag = "stagebossrank"..info.rank..var
                                local pNode = PetListMgr.createPetNode(petInfo, tag)

                                local cloneNode = pNode.node
                                cloneNode:setLocalZOrder(-1)
                                cloneNode:addTo(petdb)
                                cloneNode:setPositionX(pNode.node:getPositionX()+petDiffx*(var-1))
                                cloneNode:setPositionY(pNode.node:getPositionY()+petOffsetPosY)
                                cloneNode:setScale(0.7)
                            end
                            petdb:setScaleY(0)
                            petdb:setVisible(true)
                            transition.scaleTo(petdb, {scaleY=1, time=0.1})

                            resfreshListCell(100)
                            CSResourceMgr.setButtonEnabledByNode(arrow, false)
                        end
                        loadPetsFunc()
                        --[[
                        NetInterface.sendWithBlock("GC_QueryArenaSoldierDetail_Ack", function()
                            local ArenaSend = require("src.Net.Send.ArenaSend")
                            ArenaSend.sendCG_QueryArenaSoldierDetail_Req({
                                charID=ArenaInfo.getWorldRankListInfo(info.rank)._id, 
                                teamID=ArenaInfo.getWorldRankListInfo(info.rank).teamID, 
                            })
                        end, function()
                            loadPetsFunc()
                        end, function(code)
                            TipsMgr.showError(nil, code)
                        end)]]
                    end
                end)
            	return parent
            end
            local function cellNodeAni(cellNode)
                cellNode:setVisible(true)
                cellNode:setScaleY(0)
                transition.scaleTo(cellNode, {scale=1, time=0.2})
            end
            
            local function setRankCellNew(node, info)
                local rankNum = info.rank
                local faimly = info.faimly or nil
                local diban = CSResourceMgr.seekNodeByName(node, "player_diban")
                local bg11 = CSResourceMgr.seekNodeByName(node, "bg11")
                local bg21 = CSResourceMgr.seekNodeByName(node, "bg21")
                local bg14 = CSResourceMgr.seekNodeByName(node, "bg14")
                local fmbg = CSResourceMgr.seekNodeByName(node, "family_bg")
                local rankTex = CSResourceMgr.seekNodeByName(node, "rank_num_sprite")
                local rankLab = CSResourceMgr.seekNodeByName(node, "rank_num_label")
                local playerIcon = CSResourceMgr.seekNodeByName(node, "player_icon")
                local vip = CSResourceMgr.seekNodeByName(node, "player_vip")
                local playerLv = CSResourceMgr.seekNodeByName(node, "player_level")
                local playerName = CSResourceMgr.seekNodeByName(node, "player_name")
                local fc = CSResourceMgr.seekNodeByName(node, "fc")
                local familyNode = CSResourceMgr.seekNodeByName(node, "family")
                
                CSResourceMgr.seekNodeByName(node,"bg13"):setVisible(info.vipLevel > 1)
                vip:setVisible(info.vipLevel > 1)

                playerIcon:setScale(1.0)
                CSResourceMgr.setSpriteTextureByNode(playerIcon, info.charIcon)
                
                local icon = CSResourceMgr.seekNodeByName(node, "bg15")
                icon:loadTexture(ItemInfo.getItemInfoById(9991).icon)
                icon:setScale(50 / icon:getContentSize().width)
                -- CSResourceMgr.seekNodeByName(node, "bg15"):setVisible(false)
            
                if rankNum <= 3 then
                    rankLab:setVisible(false)
                    CSResourceMgr.setSpriteTextureByNode(rankTex, ArenaViewMgr.PlayerRankNumTex[rankNum])
                else
                    rankTex:setVisible(false)
                    CSResourceMgr.setLabelStringByNode(rankLab, rankNum, outlineColor[3])
                    CSResourceMgr.setLabelColorByNode(rankLab, labelColor[3])
                end
            
                if rankNum > 3 then rankNum = 4 end
                CSResourceMgr.setSpriteTextureByNode(diban, ArenaViewMgr.PlayerRankBackgroudTex[rankNum])
                bg11:setColor(ArenaViewMgr.BGTexColor1[rankNum])
                bg21:setColor(ArenaViewMgr.BGTexColor2[rankNum])
                bg14:setColor(ArenaViewMgr.BGTexColor3[rankNum])
                fmbg:setColor(ArenaViewMgr.BGTexColor2[rankNum])
                
                local vipLv = CharInfo.getVipInfoByID(info.vipLevel).viplevel
                CSResourceMgr.setLabelStringByNode(vip, vipLv, outlineColor[2])
                CSResourceMgr.setLabelStringByNode(playerLv, "Lv."..info.level)
                CSResourceMgr.setLabelStringByNode(playerName, info.name, outlineColor[2], nil, 198)
                
                local str = LuaSqlite.getLanguageByKey("stageboss5")
                local timeText = info.score or 0  -- CocosModuleMgr.createStringWithFormat({"<1> "..str, info.time})
                CSResourceMgr.setLabelStringByNode(fc, timeText, outlineColor[2], nil, 112)
                fc:setAnchorPoint(0.5, 0.5)
            
                CSResourceMgr.setLabelColorByNode(vip, labelColor[2])
                CSResourceMgr.setLabelColorByNode(playerLv, ArenaViewMgr.PlayerLvColor[rankNum])
            
                if faimly then

                else
                    familyNode:setVisible(false)
                end
            end
            
            local funcTable = {loadCSB}
            local myNode = nil
            local rankNode = {}
            table.insert(funcTable, function()
                --myNode = CSResourceMgr.getNodeByName(resNameB, "mdiban"):clone()
                --local mydb = CSResourceMgr.getNodeByName(resNameB, "mydb")
                --mydb:removeAllChildren()
                --myNode:addTo(mydb)
                --myNode:setPosition(mydb:getContentSize().width/2, mydb:getContentSize().height/2)
                
                myNode = CSResourceMgr.getNodeByName(resNameB, "player_info")
            end)
            table.insert(funcTable, function()
                setMyRank(myNode, {
                    rank = TerritorialInfo.getMyRankInfo().rank or 999, 
                    name = CharInfo.getNickName(), 
                    level = CharInfo.getLevel(), 
                    gender = CharInfo.getSex(),
                    vipLevel = CharInfo.getVipInfoByID(CharInfo.getVIPLevel()).viplevel,
                    time = TerritorialInfo.getMyRankInfo().lTime or 0,
                })
            end)
            table.insert(funcTable, function()
                --cellNodeAni(myNode)
            end)
            
            table.insert(funcTable, function()
            	local ranklistFunc = {}
                local rankListInfo = TerritorialInfo.getRankList()
                for var=1, #rankListInfo do
                    local info = rankListInfo[var]
                    
                    local _icon = 1001
                    if info.fashion and info.fashion.curFashion then
                        _icon = info.fashion.curFashion[1]
                        if _icon == 0 then _icon = 1001 end
                    end
                    
                    table.insert(ranklistFunc, function()
                        -- rankNode[var] = CSResourceMgr.getNodeByName(resNameB, "mdiban"):clone()
                        local itemCSB = "LostTower/Menu/RankingItemA1.csb"
                        local sample = CSResourceMgr.createRes(nil,itemCSB)
                        rankNode[var] = CSResourceMgr.seekNodeByName(sample, "btn_item"):clone()
                        local list = CSResourceMgr.getNodeByName(resNameB, "list")
                        list:pushBackCustomItem(rankNode[var])
                        
                        rankNode[var]:setVisible(false)
                    end)
                    table.insert(ranklistFunc, function()
                        setRankCellNew(rankNode[var], {
                            rank = info.rank or 999, 
                            name = info.nickname or "", 
                            level = info.Level or 1, 
                            gender = info.gender or 1,
                            vipLevel = info.vipLevel or 1,
                            time = info.lTime or 0,
                            score = info.score or 0,
                            charIcon = ItemInfo.getFashionItemInfoById(_icon).filePath,
                        })
                    end)
                    table.insert(ranklistFunc, function()
                        cellNodeAni(rankNode[var])
                    end)
                end
                UnblockLoader.load(ranklistFunc, "StageBossListMgr.setTabB-rank")
            end)
            
            if requestRankTime+StageBossListMgr.RANK_REQUEST_TIMEINTERVAL<CharInfo.getServerTime() then
                NetInterface.sendWithBlock("GC_SelfTerritoryInfo_Ack", function()
                    local TerritorialSend = require("src.Net.Send.TerritorialSend")
                    TerritorialSend.sendCG_SelfTerritoryInfo_Req()
                end, function()
                    NetInterface.sendWithBlock("GC_TerritoryRankInfo_Ack", function()
                        local TerritorialSend = require("src.Net.Send.TerritorialSend")
                        TerritorialSend.sendCG_TerritoryRankInfo_Req()
                    end, function()
                        requestRankTime = CharInfo.getServerTime()
                        UnblockLoader.load(funcTable, "StageBossListMgr.setTabB")
                    end, function(code)
                        TipsMgr.showError(SceneMgr.getRunningScene, code)
                    end)
                end, function(code)
                    TipsMgr.showError(SceneMgr.getRunningScene, code)
                end)
            else
                UnblockLoader.load(funcTable, "StageBossListMgr.setTabB")
            end
        end
    end
end

function StageBossListMgr.setTabC(boolVisible)
    local parent = CSResourceMgr.getNodeByName(resName, "diban")
    local curNode = CSResourceMgr.getCsbObj(resNameC, tagC)
    if curNode then
        curNode:setVisible(boolVisible)
    else
        local allstageVec = TerritorialInfo.getAllTerritorialInfo()
        local tmpstageVec = {}
        local infoVec = {}
        for key, var in pairs(allstageVec) do
            if WorldMapInfo.getLockInfoByAdvID(var.id%10000)<=CharInfo.get().maplock then
                table.insert(tmpstageVec, var)
            end
        end
        for _, var in pairs(tmpstageVec) do
            if openList[var.id] then
                openList[var.id].listIdx = #infoVec
                table.insert(infoVec, var)
            end
        end
    
        if boolVisible then
            local function loadCSB()
                local layer = CSResourceMgr.createRes(parent, resNameC, tagC)

                local diff = CocosModuleMgr.getScreenSizeDiff()
                local list = CSResourceMgr.getNodeByName(resNameC, "list", tagC)
                local lsize = list:getContentSize()
                list:setContentSize(lsize.width, lsize.height+diff)
            end
            
            local funcTable = {loadCSB}
            local parentVec = {}
            playerNameLabelVec["tab2"] = {}
            local stageIDVec = {}
            -- timeInfoVec = {}

            for index=1, #infoVec do
                local var = infoVec[index]
                local key = var.id
                table.insert(stageIDVec, var.id)
                table.insert(funcTable, function()
                    local parent = CSResourceMgr.createRes(nil,"Searching/StageBoss/StageBossItem.csb","tabC"..index)
                    local item = CSResourceMgr.seekNodeByName(parent,"example")
                    item:removeFromParent()
                    parentVec[key] = item
                    CSResourceMgr.getNodeByName(resNameC, "list", tagC):pushBackCustomItem(item)
                end)
                table.insert(funcTable, function()
                    local parent = parentVec[key]
                    updateStageBossItem(parent,{aid=key,palyerNameStr="",boolOpen=var.boolOpen,type=2},2,true)
                    setStageBossAwards(parent, var.awardVec, key)
                end)
                table.insert(funcTable, function()
                    parentVec[key]:setVisible(true)
                    parentVec[key]:setScaleY(0)
                    transition.scaleTo(parentVec[key], {scale=1, time=0.2})
                end)
            end
            table.insert(funcTable, function()
                -- StageBossListMgr.refreshServerTime()
                
                local stageID
                for i = 1, #stageIDVec do
                    stageID = stageIDVec[i]
                    local name = playerNameStrVec[stageID] or ""
                    CSResourceMgr.setLabelStringByNode(playerNameLabelVec["tab2"][stageID], playerNameStrVec[stageID], nil, nil, 200)
                end
            end)
            
            UnblockLoader.load(funcTable, "StageBossListMgr.setTabC")
        end
    end
end

function StageBossListMgr.setTabD(boolVisible)
    local parent = CSResourceMgr.getNodeByName(resName, "diban")
    local curNode = CSResourceMgr.getCsbObj(resNameD, tagD)
    if curNode then
        curNode:setVisible(boolVisible)
    else
        if boolVisible then
            local allstageVec = TerritorialInfo.getAllTerritorialInfo()
            local tmpstageVec = {}
            local infoVec = {}
            for _, var in pairs(allstageVec) do
                if WorldMapInfo.getLockInfoByAdvID(var.id%10000)<=CharInfo.get().maplock then
                    table.insert(tmpstageVec, var)
                end
            end
            for key, var in pairs(tmpstageVec) do
                if nearList[var.id] then
                    nearList[var.id].listIdx = #infoVec
                    table.insert(infoVec, var)
                end
            end
        
            local function loadCSB()
                local layer = CSResourceMgr.createRes(parent, resNameD, tagD)

                local diff = CocosModuleMgr.getScreenSizeDiff()
                local list = CSResourceMgr.getNodeByName(resNameD, "list", tagD)
                local lsize = list:getContentSize()
                list:setContentSize(lsize.width, lsize.height+diff)
            end
            
            local funcTable = {loadCSB}
            local parentVec = {}
            playerNameLabelVec["tab3"] = {}
            local stageIDVec = {}
            -- timeInfoVec = {}

            for index=1, #infoVec do
                local var = infoVec[index]
                local key = var.id
                table.insert(stageIDVec, var.id)
                table.insert(funcTable, function()
                    local parent = CSResourceMgr.createRes(nil,"Searching/StageBoss/StageBossItem.csb","tabD"..index)
                    local item = CSResourceMgr.seekNodeByName(parent,"example")
                    item:removeFromParent()
                    parentVec[key] = item
                    CSResourceMgr.getNodeByName(resNameD, "list", tagD):pushBackCustomItem(item)
                end)
                table.insert(funcTable, function()
                    local parent = parentVec[key]
                    updateStageBossItem(parent,{aid=key,palyerNameStr="",boolOpen=var.boolOpen,type=2},3,true)
                    setStageBossAwards(parent, var.awardVec, var.id)
                end)
                table.insert(funcTable, function()
                    parentVec[key]:setVisible(true)
                    parentVec[key]:setScaleY(0)
                    transition.scaleTo(parentVec[key], {scale=1, time=0.2})
                end)
            end
            table.insert(funcTable, function()
                -- StageBossListMgr.refreshServerTime()
                
                local stageID
                for i = 1, #stageIDVec do
                    stageID = stageIDVec[i]
                    local name = playerNameStrVec[stageID] or ""
                    CSResourceMgr.setLabelStringByNode(playerNameLabelVec["tab3"][stageID], playerNameStrVec[stageID], nil, nil, 200)
                end
            end)
            
            UnblockLoader.load(funcTable, "StageBossListMgr.setTabD")
        end
    end
end

local function getItemFromList(resName,tag,index)
    if not CSResourceMgr.getCsbObj(resName, tag) then return end
    local list = CSResourceMgr.getNodeByName(resName, "list", tag)
    return list:getItem(index)
end

local function removeFromList(resName,tag,index)
    if not CSResourceMgr.getCsbObj(resName, tag) then return end
    local list = CSResourceMgr.getNodeByName(resName, "list", tag)
    local item = list:getItem(index)
    list:removeItem(index)
end

local function addToList(resName,tag,item,index)
    if not CSResourceMgr.getCsbObj(resName, tag) then return end
    local list = CSResourceMgr.getNodeByName(resName, "list", tag)
    list:insertCustomItem(item,index)
end

local function addNewItemToList(tabid,aid,index)
    local resName, tag
    if tabid == 2 then
        resName = resNameC
        tag     = tagC
    elseif tabid == 3 then
        resName = resNameD
        tag     = tagD
    end

    if not CSResourceMgr.getCsbObj(resName, tag) then return end
    
    local parent = CSResourceMgr.createRes(nil,"Searching/StageBoss/StageBossItem.csb",tag..index)
    local item = CSResourceMgr.seekNodeByName(parent,"example")
    item:removeFromParent()
    local var = TerritorialInfo.getAdventureTerritorialInfo(aid)
    updateStageBossItem(item,{aid=aid,palyerNameStr=playerNameStrVec[var.id] or "",boolOpen=var.boolOpen,type=2},tabid,true)
    setStageBossAwards(item, var.awardVec, var.id)
    addToList(resName,tag,item,index)
    item:setVisible(true)
end

function StageBossListMgr.closeStage(aid)
    if not openList[aid] then return end
    if CSResourceMgr.getCsbObj(resNameC, tagC) and openList[aid].listIdx then
        removeFromList(resNameC,tagC,openList[aid].listIdx)
        for key, var in pairs(openList) do
            if var.listIdx and var.listIdx > openList[aid].listIdx then
                openList[key].listIdx = openList[key].listIdx - 1
            end
        end
    end
    openList[aid] = nil
    
    for i = 1, #myStageVec do
        if myStageVec[i].id == aid then
            myStageVec[i] = TerritorialInfo.getAdventureTerritorialInfo(aid)
            break
        end
    end
    
    local parent
    for i = 1, #stageItems do
        if stageItems[i].aid == aid then
            parent = stageItems[i].node
            break
        end
    end
    if not parent then return end
    
    local title2 = CSResourceMgr.seekNodeByName(parent, "title2")
    local time = CSResourceMgr.seekNodeByName(parent, "time")
    local search = CSResourceMgr.seekNodeByName(parent, "goto")
    local stateLabel = CSResourceMgr.seekNodeByName(parent,"stageState")
    
    CSResourceMgr.setLabelStringByNode(title2, "stageboss10", nil, nil, 180)
    CSResourceMgr.setLabelColorByNode(time, {r=255,g=0,b=0,a=255})
    CSResourceMgr.setButtonEnabledByNode(search, false)
    CSResourceMgr.setButtonStringColorByNode(search, {r=211,g=211,b=211,a=255})
    CSResourceMgr.setButtonStringByNode(search, "stageboss11", {r=121,g=121,b=121,a=255})

    CSResourceMgr.setLabelColorByNode(stateLabel, {r=255,g=0,b=0,a=255})
    --CSResourceMgr.setLabelStringByNode(stateLabel,"stageboss17",nil,nil)
    
    local timeStr = StageBossListMgr.getStageBeginTime(aid)
    CSResourceMgr.setLabelStringByNode(stateLabel,CocosModuleMgr.createStringWithFormat({"Territorialtext13",timeStr}))
end

function StageBossListMgr.openStage(aid)
    if not nearList[aid] then return end
    if CSResourceMgr.getCsbObj(resNameD, tagD) and nearList[aid].listIdx then
        removeFromList(resNameD,tagD,nearList[aid].listIdx)
        for key, var in pairs(nearList) do
            if var.listIdx and var.listIdx > nearList[aid].listIdx then
                nearList[key].listIdx = nearList[key].listIdx - 1
            end
        end
    end
    nearList[aid] = nil
    
    if CSResourceMgr.getCsbObj(resNameC, tagC) then    
        local index = #CSResourceMgr.getNodeByName(resNameC, "list", tagC):getItems()
        addNewItemToList(2, aid, index)
        openList[aid] = {listIdx=index}
    else
        openList[aid] = {}
    end
    
    for i = 1, #myStageVec do
        if myStageVec[i].id == aid then
            myStageVec[i] = TerritorialInfo.getAdventureTerritorialInfo(aid)
            break
        end
    end
    
    local parent
    for i = 1, #stageItems do
        if stageItems[i].aid == aid then
            parent = stageItems[i].node
            break
        end
    end
    if not parent then return end
    
    local title2 = CSResourceMgr.seekNodeByName(parent, "title2")
    local time = CSResourceMgr.seekNodeByName(parent, "time")
    local search = CSResourceMgr.seekNodeByName(parent, "goto")
    local stateLabel = CSResourceMgr.seekNodeByName(parent,"stageState")

    CSResourceMgr.setLabelStringByNode(title2, "stageboss14", nil, nil, 180)
    CSResourceMgr.setLabelColorByNode(time, {r=63,g=127,b=4,a=255})
    CSResourceMgr.setButtonEnabledByNode(search, true)
    CSResourceMgr.setButtonStringColorByNode(search, {r=255,g=255,b=255,a=255})
    CSResourceMgr.setButtonStringByNode(search, "stageboss11", {r=61,g=126,b=0,a=255})
    CSResourceMgr.clickEventBindingByNode(search, function()
        WorldMapMgr.searchAdventureNode(aid, 4)
    end)

    CSResourceMgr.setLabelColorByNode(stateLabel, {r=63,g=127,b=4,a=255})
    --CSResourceMgr.setLabelStringByNode(stateLabel,"stageboss15",nil,nil)

    local timeStr = StageBossListMgr.getStageBeginTime(aid)
    CSResourceMgr.setLabelStringByNode(stateLabel,CocosModuleMgr.createStringWithFormat({"Territorialtext13",timeStr}))
end

function StageBossListMgr.comingStage(aid)
    if not aid then return end
    if not CSResourceMgr.getCsbObj(resNameD, tagD) then
        nearList[aid] = {}
        return 
    end

    local index = #CSResourceMgr.getNodeByName(resNameD, "list", tagD):getItems()
    addNewItemToList(3, aid, index)
    nearList[aid] = {listIdx=index}
end

function StageBossListMgr.refreshServerTime()
    local isInited = false
    for key, var in pairs(timeInfoVec) do
        isInited = true
        break
    end
    if not isInited then
    	return
    end
    
    local stageVec = TerritorialInfo.getAllTerritorialInfo()
    for key, var in pairs(stageVec) do
    	local sid = var.id
    	if timeInfoVec[sid]~= nil then
            if var.boolOpen then
                timeInfoVec[sid].openFunc()
            else
                timeInfoVec[sid].closeFunc()
            end
            timeInfoVec[sid].openIdx = var.openIdx
            timeInfoVec[sid].boolOpen = var.boolOpen
            timeInfoVec[sid].sec = var.countdown
            timeInfoVec[sid].period = var.period
            timeInfoVec[sid].interval = var.interval
        end
    end
    for key, var in pairs(timeInfoVec) do
    	local timeLabel, item
    	
    	if openList[key] and openList[key].listIdx then
    	   item = getItemFromList(resNameC,tagC,openList[key].listIdx)
    	   timeLabel = CSResourceMgr.seekNodeByName(item, "time")
    	elseif nearList[key] and nearList[key].listIdx then
           item = getItemFromList(resNameD,tagD,nearList[key].listIdx)
           timeLabel = CSResourceMgr.seekNodeByName(item, "time")
    	end
    	
        if timeLabel then
            transition.stopTarget(timeLabel)
            local time = var.sec
            local h,m,s
            if time>0 then
                h = math.floor(time/3600)
                m = math.floor((time-h*3600)/60)
                s = time-h*3600-m*60
            else
                h=0
                m=0
                s=0
            end
            local h_str = string.format("%02d", h)
            local m_str = string.format("%02d", m)
            local s_str = string.format("%02d", s)
            CSResourceMgr.setLabelStringByNode(timeLabel, h_str..":"..m_str..":"..s_str)
        end
    end
    
    local function update()
        local mainCSB = CSResourceMgr.getCsbObj(resName)
        mainCSB:performWithDelay(function()
            update()
        end, 1)
        for key, var in pairs(timeInfoVec) do
            timeInfoVec[key].sec = timeInfoVec[key].sec - 1
            if timeInfoVec[key].sec < 0 then 
                timeInfoVec[key].sec = 0
                if timeInfoVec[key].boolOpen then
                    -- timeInfoVec[key].closeFunc()
                    StageBossListMgr.closeStage(key)
                    timeInfoVec[key].sec = timeInfoVec[key].interval[timeInfoVec[key].openIdx]
                    timeInfoVec[key].openIdx = timeInfoVec[key].openIdx+1
                    if timeInfoVec[key].openIdx>#timeInfoVec[key].period then
                        timeInfoVec[key].openIdx = 1
                    end
                else
                    -- timeInfoVec[key].openFunc()
                    StageBossListMgr.openStage(key)
                    timeInfoVec[key].sec = timeInfoVec[key].period[timeInfoVec[key].openIdx]
                end
                timeInfoVec[key].boolOpen = not timeInfoVec[key].boolOpen
            elseif timeInfoVec[key].sec <= 3600 then
                if not nearList[key] and not timeInfoVec[key].boolOpen then
                    StageBossListMgr.comingStage(key)
                end
            end

            local _timeLabel, item
            if openList[key] and openList[key].listIdx then
                item = getItemFromList(resNameC,tagC,openList[key].listIdx)
                _timeLabel = CSResourceMgr.seekNodeByName(item, "time")
            elseif nearList[key] and nearList[key].listIdx then
                item = getItemFromList(resNameD,tagD,nearList[key].listIdx)
                _timeLabel = CSResourceMgr.seekNodeByName(item, "time")
            end
            if _timeLabel then
                transition.stopTarget(_timeLabel)
                local time = var.sec
                local h,m,s
                if time>0 then
                    h = math.floor(time/3600)
                    m = math.floor((time-h*3600)/60)
                    s = time-h*3600-m*60
                else
                    h=0
                    m=0
                    s=0
                end
                local h_str = string.format("%02d", h)
                local m_str = string.format("%02d", m)
                local s_str = string.format("%02d", s)
                CSResourceMgr.setLabelStringByNode(_timeLabel, h_str..":"..m_str..":"..s_str)
            end
        end
    end
    transition.stopTarget(CSResourceMgr.getCsbObj(resName))
    update()
end

function StageBossListMgr.set(aid, time)
    timeInfoVec[aid].sec = time
end

function StageBossListMgr.updateTime(key, h, m, s)
    if not timeInfoVec[key] then
    	return
    end
    local timeLabel = timeInfoVec[key].label
    local h_str = string.format("%02d", h)
    local m_str = string.format("%02d", m)
    local s_str = string.format("%02d", s)
    CSResourceMgr.setLabelStringByNode(timeLabel, h_str..":"..m_str..":"..s_str)
    timeLabel:performWithDelay(function()
        StageBossListMgr.updateTime(key, h, m, s)
    end, 1)
    s=s-1
    if s<0 then
        s=59
        m=m-1
        if m<0 then
            m=59
            h=h-1
            if h<0 then
                h=0
                m=0
                s=0
                transition.stopTarget(timeLabel)
                if timeInfoVec[key].boolOpen then
                    timeInfoVec[key].closeFunc()
                    timeInfoVec[key].sec = timeInfoVec[key].interval[timeInfoVec[key].openIdx]
                    timeInfoVec[key].openIdx = timeInfoVec[key].openIdx+1
                    if timeInfoVec[key].openIdx>#timeInfoVec[key].period then
                        timeInfoVec[key].openIdx = 1
                    end
                else
                    timeInfoVec[key].openFunc()
                    timeInfoVec[key].sec = timeInfoVec[key].period[timeInfoVec[key].openIdx]
                end
                h = math.floor(timeInfoVec[key].sec/3600)
                m = math.floor((timeInfoVec[key].sec-h*3600)/60)
                s = timeInfoVec[key].sec-h*3600-m*60
                StageBossListMgr.updateTime(key, h, m, s)
                timeInfoVec[key].boolOpen = not timeInfoVec[key].boolOpen
            end
        end
    end
end

--StageBossListMgr.Init()
--StageBossListMgr.show(SceneMgr.getRunningScene)

return StageBossListMgr