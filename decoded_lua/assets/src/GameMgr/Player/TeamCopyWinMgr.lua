local TeamCopyWinMgr = {}

local resName = ""
local resNameBG = ""
local boxTbl = nil
local currentSelChestIdx = 1
local treasureBoxNodes = {}
local treasureBoxVipLock = nil
local boxFull = true
local chestLabelTbl = {}

function TeamCopyWinMgr.Init()
    resName = "Player/Team/TeamCopyWin.csb"
    resNameBG = "Pet/Formation/FormationBGNew.csb"
    boxTbl = nil
    currentSelChestIdx = 1
    treasureBoxNodes = {}
    if treasureBoxVipLock==nil then
        treasureBoxVipLock = SystemInfo.getGlobalConfigAddInfoByID(71).values
    end
    boxFull = true
    chestLabelTbl = {}
end

local function setCurrentSelChestIdx(idx)
    currentSelChestIdx = idx
    for i=1, 3 do
        local sel =  CSResourceMgr.getNodeByName(resName, {"db", "box"..i, "selected"})
        if i == idx then
            sel:setVisible(true)
        else
            sel:setVisible(false)
        end
    end
end

local function getBoxIndex()
    local box = CSResourceMgr.getNodeByName(resName, {"db", "box"..currentSelChestIdx})
    
    for k,v in pairs(boxTbl) do
        if v == box.boxID then
            return k-1
        end
    end
    return 0
end

local function initStaticData(boxID)
    local wordTex = CocosModuleMgr.getWordImage("adventureWin.png")
    CSResourceMgr.getNodeByName(resName,{"db", "title", "txt"}):loadTexture(wordTex)
    
    CSResourceMgr.setButtonString(resName, {"db", "exit"}, "home012", nil, {r=0,g=0,b=0,a=255,w=1})
    
    if boxID and #boxID > 0 then
        CSResourceMgr.setLabelString(resName, {"db", "tip"}, "team63", nil, {r=0,g=0,b=0,a=255,w=1})
        CSResourceMgr.setLabelString(resName, {"db", "tip1"}, "team65", nil, {r=0,g=0,b=0,a=255,w=1})
        local boxNum = #boxID
        for i=1, boxNum do
            local rand = GetRandom.random(1, #boxID)
            local tex = TreasureBoxInfo.getTreasureBoxInfoById(boxID[rand]).imagePath
            local box = CSResourceMgr.getNodeByName(resName, {"db", "box"..i})
            box.boxID = boxID[rand]
            local icon = CSResourceMgr.seekNodeByName(box, "icon")
            icon:setScale(1.5, 1.5)
            CSResourceMgr.setButtonTextureByNode(icon, tex, tex, tex)
            CSResourceMgr.clickEventBindingByNode(icon, function()
                --local awardTbl = {}
                --table.insert(awardTbl, TreasureBoxInfo.getTreasureBoxInfoById(boxID[i]).awards[1])
                --DropInfoViewMgr.showWithAwardElements(awardTbl)
                setCurrentSelChestIdx(i)
            end, 3)
            local name = CSResourceMgr.seekNodeByName(box, "name")
            CSResourceMgr.setLabelStringByNode(name, TreasureBoxInfo.getTreasureBoxInfoById(boxID[rand]).name, {r=0,g=0,b=0,a=255,w=1})
            table.remove(boxID, rand)
            if LuaSqlite.LANG_TYPE ~= 1 then
                name:setFontSize(24)
                local chestLabel = display.newTTFLabel({
                font = "cuyuan_GBK.ttf",
                text = "Chest",
                size = 24, 
                color = display.COLOR_WHITE
                })
                chestLabel:addTo(box)
                chestLabel:setPosition(0,-92)
                chestLabel:enableOutline({r=0,g=0,b=0,a=255},1)
            end
        end
        setCurrentSelChestIdx(1)
    else
        local overflow = CSResourceMgr.getNodeByName(resName, {"db", "overflow"})
        CSResourceMgr.setLabelStringByNode(overflow, "team49", {r=0,g=0,b=0,a=255,w=1})
        overflow:setVisible(true)
        CSResourceMgr.getNodeByName(resName, {"db", "tip"}):setVisible(false)
        CSResourceMgr.getNodeByName(resName, {"db", "box1"}):setVisible(false)
        CSResourceMgr.getNodeByName(resName, {"db", "box2"}):setVisible(false)
        CSResourceMgr.getNodeByName(resName, {"db", "box3"}):setVisible(false)
    end
end

local function initDynamicData()
    if not CSResourceMgr.getCsbObj(resName) then
        return
    end
    
    local tag = "TeamCopyWinMgr"
    UnblockLoader.cancel(tag.."T")
    TreasureBoxInfo.checkRedPoint()
    BaseFunction.cancelLocalNotificationWithKey(6)
    local TreasureBoxSend = require("src.Net.Send.TreasureBoxSend")
    local funcTable = {}
    local waitTime = {}
    local myBoxData = TreasureBoxInfo.getMyTreasureBoxData()
    local myBuyTimes = TreasureBoxInfo.getTodayBuyTimes()+1
    local imageIcon = {}
    local needTime = {}
    local awardPreIDs = {}
    local mPrice = {}
    local endTime = {}
    local boxName = {}
    if chestLabelTbl then
        for k,v in pairs(chestLabelTbl) do
            v:removeFromParent(true)
        end
    end
    chestLabelTbl = {}
    for key, var in pairs(myBoxData) do
        if var.type then
            local bInfo = TreasureBoxInfo.getTreasureBoxInfoById(var.type)
            imageIcon[key] = bInfo.imagePath
            needTime[key] = bInfo.CD
            awardPreIDs[key] = {bInfo.awards[1]}
            mPrice[key] = bInfo.speedSeconds[myBuyTimes] or bInfo.speedSeconds[#bInfo.speedSeconds]
            endTime[key] = var.time
            boxName[key] = bInfo.name
        end
    end
    local imageBackground = {"UI/CommonFiles/share_formation_selected_su_01.png", 
        "UI/CommonFiles/share_formation_substrate_su_04.png"}
    local boxPosy = {nil, 65, 115, 105}
    for var=1, TeamViewMgr.DEFAULT_AWARD_SIZE do
        table.insert(funcTable, function()
            local parent = treasureBoxNodes[var]
            local showAni = false
            if not parent then
                showAni = true
                parent = CSResourceMgr.getNodeByName(resName, "award"):clone()
                parent:addTo(CSResourceMgr.getNodeByName(resName, "state1"))
                parent:setPositionX(640/TeamViewMgr.DEFAULT_AWARD_SIZE*(var-0.5))
            end
            local vipLock = treasureBoxVipLock[var] or 0

            local button = CSResourceMgr.seekNodeByName(parent, "button")
            local empty = CSResourceMgr.seekNodeByName(parent, "empty")
            local lock = CSResourceMgr.seekNodeByName(parent, "lock")
            local unlock = CSResourceMgr.seekNodeByName(parent, "unlock")
            local open = CSResourceMgr.seekNodeByTag(parent, "open")
            local boxname = CSResourceMgr.seekNodeByName(parent, "boxname")
            if LuaSqlite.LANG_TYPE ~= 1 then
                local chestLabel = display.newTTFLabel({
                font = "cuyuan_GBK.ttf",
                text = "Chest",
                size = 16, 
                color = {r=69,g=165,b=209,a=255}
                })
                chestLabel:addTo(parent)
                chestLabel:setPosition(75,-30)
                chestLabel:enableOutline({r=0,g=0,b=0,a=255},1)
                chestLabel:enableShadow()
                chestLabelTbl[var] = chestLabel
                if imageIcon[var] then
                    chestLabel:setVisible(true)
                else
                    chestLabel:setVisible(false)
                end
            end
            CSResourceMgr.setLabelColorByNode(boxname, {r=69,g=165,b=209,a=255})
            CSResourceMgr.setLabelStringByNode(boxname, boxName[var] or "", {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 150)
            local nodeVec = {empty, lock, unlock, open}
            button:scale(1.3)
            button:setPressedActionEnabled(true)
            --状态1:空箱位/状态2:未开启/状态3:可开启/状态4:开启中
            local function setType(index)
                for v=1, #nodeVec do
                    nodeVec[v]:hide()
                end
                nodeVec[index]:show()
                if boxPosy[index] then
                    button:setPositionY(boxPosy[index])
                    button:show()
                else
                    button:hide()
                end
                if index==3 or index==4 then
                    CSResourceMgr.setSpriteTextureByNode(parent, imageBackground[1])
                else
                    CSResourceMgr.setSpriteTextureByNode(parent, imageBackground[2])
                end
                if index==1 then
                    waitTime[var] = nil
                    local showStr = ""
                    if CharInfo.getVIPLevel()>=vipLock then
                        CSResourceMgr.setLabelColorByNode(empty, {r=115,g=152,b=187,a=255})
                        showStr = "team4"
                        boxFull = false
                    else
                        CSResourceMgr.setSpriteTextureByNode(parent, "UI/CommonFiles/share_formation_selected_unlock.png")
                        CSResourceMgr.setLabelColorByNode(empty, {r=255,g=141,b=0,a=255})
                        local vipInfo = CharInfo.getVipInfoByID(vipLock)
                        showStr = CocosModuleMgr.createStringWithFormat({"team62", vipInfo.viplevel})
                    end
                    CSResourceMgr.setLabelStringByNode(empty, showStr, {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 150)
                elseif index==2 then
                    local lockstr = CSResourceMgr.seekNodeByName(parent, "lockstr")
                    CSResourceMgr.setLabelColorByNode(lockstr, {r=255,g=245,b=175,a=255})
                    CSResourceMgr.setLabelStringByNode(lockstr, "team5", {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 150)
                    local locktime = CSResourceMgr.seekNodeByName(parent, "locktime")
                    CSResourceMgr.setLabelStringByNode(locktime, CocosModuleMgr.createStringWithFormat({"team20", 
                        math.floor(needTime[var]/3600)}),{r=0,g=0,b=0,a=255,w=1,s=1}, nil, 150)
                    CSResourceMgr.longtouchEventBindingByNode(button, function()
                        DropInfoViewMgr.showWithAwardElements(awardPreIDs[var])
                    end, function()
                        for v=1, TeamViewMgr.DEFAULT_AWARD_SIZE do
                            if waitTime[v] then
                                StandardTipsMgr.show(1, "team19")
                                return
                            end
                        end
                        NetInterface.sendWithBlock("GC_UnlockTreasureBox_Ack", function()
                            TreasureBoxSend.sendCG_UnlockTreasureBox_Req({boxID=var-1})
                        end, function()
                            endTime[var] = CharInfo.getServerTime()+needTime[var]
                            waitTime[var] = needTime[var]
                            myBoxData[var].time = endTime[var]
                            setType(4)
                        end, function(code)
                            TipsMgr.showError(nil, code)
                        end)
                    end, "select1")
                elseif index==3 then
                    CSResourceMgr.setLabelStringByNode(unlock, "team7", {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 150)
                    CSResourceMgr.longtouchEventBindingByNode(button, function()
                        DropInfoViewMgr.showWithAwardElements(awardPreIDs[var])
                    end, function()
                        --TipsMgr.show(nil, "打开")
                        NetInterface.sendWithBlock("GC_OpenTreasureBox_Ack", function()
                            TreasureBoxSend.sendCG_OpenTreasureBox_Req({boxID=var-1, bFree=1})
                        end, function()
                            --setType(1)
                            myBoxData[var] = {}
                            initDynamicData()
                        end, function(code)
                            TipsMgr.showError(nil, code)
                        end)
                    end, "select1")
                elseif index==4 then
                    local timedb = CSResourceMgr.seekNodeByName(parent, "timedb")
                    timedb:setColor({r=151,g=190,b=240})
                    timedb:setOpacity(128)
                    local fast = CSResourceMgr.seekNodeByName(parent, "fast")
                    CSResourceMgr.setLabelColorByNode(fast, {r=166,g=243,b=255,a=255})
                    CSResourceMgr.setLabelStringByNode(fast, "team6", {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 120)
                    CSResourceMgr.longtouchEventBindingByNode(button, function()
                        DropInfoViewMgr.showWithAwardElements(awardPreIDs[var])
                    end, function()
                        --TipsMgr.show(nil, "快速打开")
                        local mcoin = math.ceil((endTime[var]-CharInfo.getServerTime())/mPrice[var])
                        DialogBoxMgr.showSmallDialogBox(nil, 2, CocosModuleMgr.createStringWithFormat({"team50", mcoin}), function()
                            NetInterface.sendWithBlock("GC_OpenTreasureBox_Ack", function()
                                TreasureBoxSend.sendCG_OpenTreasureBox_Req({boxID=var-1, bFree=0})
                            end, function()
                                --setType(1)
                                TreasureBoxInfo.addTodayBuyTimes()
                                myBoxData[var] = {}
                                initDynamicData()
                            end, function(code)
                                TipsMgr.showError(nil, code)
                            end)
                        end)
                    end, "select1")
                    local currentMcoin = math.ceil(waitTime[var]/mPrice[var])
                    local opentime = CSResourceMgr.seekNodeByName(parent, "opentime")
                    local mcoin = CSResourceMgr.seekNodeByName(parent, "mcoin")
                    CSResourceMgr.setLabelStringByNode(opentime, "", {r=0,g=0,b=0,a=255,w=1,s=1})
                    CocosModuleMgr.setTimeLabelCountDown(opentime, waitTime[var], function()
                        setType(3)
                    end, function(sec)
                        local cMcoin = math.ceil(sec/mPrice[var])
                        if cMcoin~=currentMcoin then
                            currentMcoin = cMcoin
                            CSResourceMgr.setLabelStringByNode(mcoin, currentMcoin, {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 80)
                        end
                    end)
                    CSResourceMgr.setLabelStringByNode(mcoin, currentMcoin, {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 80)
                    --添加推送                        
                    BaseFunction.registerLocalNotification(os.time()+waitTime[var], nil, "idling31", "", 6, 0)
                end
            end
            if endTime[var] then
                waitTime[var] = endTime[var]-CharInfo.getServerTime()
            end
            if imageIcon[var] then
                CSResourceMgr.setButtonTextureByNode(button, imageIcon[var], imageIcon[var], imageIcon[var])
                if waitTime[var] then
                    if waitTime[var]>0 then
                        setType(4)
                    else
                        setType(3)
                    end
                else
                    setType(2)
                end
            else
                setType(1)
            end

            if showAni then
                parent:show()
                parent:scale(0)
                transition.scaleTo(parent, {scale=1, time=0.2})
            end
            treasureBoxNodes[var] = parent
        end)
    end
    UnblockLoader.load(funcTable, tag.."T")
end

function TeamCopyWinMgr.getBoxes()
    return boxTbl
end

function TeamCopyWinMgr.clearBoxes()
    boxTbl = nil
end

function TeamCopyWinMgr.hideUI()
    chestLabelTbl = {}
    boxTbl = nil
    treasureBoxNodes = {}
    boxFull = true
    CSResourceMgr.removeCSObjectByTag(resName)
    CSResourceMgr.removeCSObjectByTag(resNameBG, "TeamCopyWinMgr")
    UIStack.pop("TeamCopyWinMgr")
    TeamCopyMapMgr.cleanLocalCopyMapInfo()
    --TownChatMgr.isTeamChat(false)
    --TownChatMgr.showBattleChat(false)
    TownChatMgr.setExitTeamBattle()
    MapSeekerMgr.setSeekFunc(function()
        TeamViewMgr.show(SceneMgr.getRunningScene, TeamInfo.getInfo(TeamInfo.KEY_ADVENTUREID), 2)
    end)
    SceneMgr.replaceScene(SceneMgr.getRunningScene, "TownScene")
end

local function getMyBoxNum()
    local num = 0
    local myBoxData = TreasureBoxInfo.getMyTreasureBoxData()
    for key, var in pairs(myBoxData) do
        if var.type then
            num = num + 1
        end
    end
    return num
end

function TeamCopyWinMgr.show(scene, boxID)
    boxTbl = {}
    for k,v in pairs(boxID) do
        boxTbl[k] = v
    end
    
    if CSResourceMgr.getCsbObj(resName) or SceneMgr.currentScene ~= "TeamCopyMapScene" or SceneMgr.isProcessing == true or CopyMapLoadingMgr.isOpen("TeamCopyPVELoading") == true then
        return  
    end
    
    local boxNum = #boxID
    print("@@@@@@@@@@@@@@@@@TeamCopyWinMgr.show boxID=",sz_T2S(boxID))
    UIStack.push("TeamCopyWinMgr",TeamCopyWinMgr.hideUI,true)
    local function loadBG()
        local bgLayer = CSResourceMgr.createRes(scene, resNameBG, "TeamCopyWinMgr")
        bgLayer:setLocalZOrder(CocosModuleMgr.ZORDER_FLOAT)
        CSResourceMgr.setRelativePosition(resNameBG, 320, 480, "TeamCopyWinMgr")
        bgLayer:setOpacity(0)
        transition.fadeIn(bgLayer, {time=0.3})
    end
    
    local function loadCSB()
        local curLayer = CSResourceMgr.createRes(scene, resName)
        curLayer:setLocalZOrder(CocosModuleMgr.ZORDER_FLOAT)
        CSResourceMgr.setFullScreen(resName)
        --CocosModuleMgr.setEdgeDistance(curLayer, nil, nil, 0, nil, false)
        CSResourceMgr.getNodeByName(resName, "db"):setVisible(false)
        
        local boxname = CSResourceMgr.getNodeByName(resName, "boxname")
        boxname:removeFromParent(false)
        boxname:addTo(CSResourceMgr.getNodeByName(resName, "award"))
        boxname:pos(75, -12)
        
        CSResourceMgr.clickEventBinding(resName, "exit", function()
            --TeamCopyWinMgr.hideUI()
            --local myBoxNum = getMyBoxNum()
            if not boxFull then
                local TreasureBoxSend = require("src.Net.Send.TreasureBoxSend")
                NetInterface.sendWithBlock("GC_SelectTreasureBox_Ack", function()
                    local boxIndex = getBoxIndex()
                    TreasureBoxSend.sendCG_SelectTreasureBox_Req({boxID=boxIndex})
                end, function()
                    StandardTipsMgr.show(0,"family111")
                    TeamCopyWinMgr.hideUI()
                end, function(code)
                    --TipsMgr.showError(nil, code)
                    StandardTipsMgr.show(1,LuaSqlite.getLanguageByKey("recharge22").." code="..code)
                    TeamCopyWinMgr.hideUI()
                end)
            else
                DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 2, "team66", function()
                    TeamCopyWinMgr.hideUI()
                end)
            end
        end)
        
        initStaticData(boxID)
        
        treasureBoxNodes = {}
        boxFull = true
        initDynamicData()
        --TreasureBoxInfo.GetTreasureBoxData(initDynamicData)
    end
    
    local function playCSB()
        local node = CSResourceMgr.getNodeByName(resName, "db")
        if node ~= nil then
            node:setVisible(true)
            CocosModuleMgr.showUIAnimation(node, "down")
        end
    end
    
    loadBG()
    loadCSB()
    playCSB()
    
    --TreasureBoxInfo.GetTreasureBoxData()
end

function TeamCopyWinMgr.showTreasureBox(id)
    if id and CSResourceMgr.getCsbObj(resName) then
        local tex = TreasureBoxInfo.getTreasureBoxInfoById(id).imagePath
        local box = CSResourceMgr.getNodeByName(resName, {"db", "box"})
        CSResourceMgr.setButtonTextureByNode(box, tex, tex, tex)
        CSResourceMgr.clickEventBindingByNode(box, function()
        end)
    end
end

return TeamCopyWinMgr