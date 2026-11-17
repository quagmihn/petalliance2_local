local MArenaViewMgr = {}

MArenaViewMgr.LABLE_OUTLINE_THICK = 1
MArenaViewMgr.LABLE_OUTLINE_FAT = 3
MArenaViewMgr.TAB_NUM = 4
MArenaViewMgr.PLAYER_NUM = 3
MArenaViewMgr.MAX_PET_NUM = 6
MArenaViewMgr.getShop = false
MArenaViewMgr.resetShop = false
MArenaViewMgr.systemRefresh = false
MArenaViewMgr.EnemyTable = {}
MArenaViewMgr.closeCallBack = nil
MArenaViewMgr.ArenaInfoTable = {}
MArenaViewMgr.rankInfo = {}
MArenaViewMgr.isNew = 0
MArenaViewMgr.PlayerDetailIndex = 1
MArenaViewMgr.sendFriendDetail = false

local resName = ""
local resNameTab = {}
local resNameBG = ""
local resNameDB = ""
local resNamePets = ""
local resNameTopBar = ""
local tag = ""
local curTab = 1

local isRequested = false
local petNodes = {}
local playerNodes = {}
local rankListObj = nil
local getRankCell = nil

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

MArenaViewMgr.PlayerRankNumTex = {
    "UI/CommonFiles/share_calligraphy_1st.png",
    "UI/CommonFiles/share_calligraphy_2nd.png",
    "UI/CommonFiles/share_calligraphy_3rd.png"
}

MArenaViewMgr.PlayerRankBackgroudTex = {
    "UI/CommonFiles/ranking_substrate_gold_su.png",
    "UI/CommonFiles/ranking_substrate_silver_su.png",
    "UI/CommonFiles/ranking_substrate_copper_su.png",
    "UI/CommonFiles/frame_substrate_normal_su_01.png"
}

MArenaViewMgr.DirIconPath = {
    "UI/CommonFiles/menu_roundness_green_nomal_01.png",
    "UI/CommonFiles/menu_roundness_green_press_02.png"
}

function MArenaViewMgr.Init()
    print("MArenaViewMgr初始化")
	
    resName = "Player/Arena/ArenaViewNew.csb"
    resNameTab = {"Player/Arena/TabANew.csb", "Player/Arena/TabBNew.csb", "Player/Arena/TabC.csb" ,"Player/Arena/TabD.csb"}
    resNameBG = "Pet/Formation/FormationBGNew.csb"
    resNameDB = "Scene/CommonShade.csb"
    resNamePets = "Player/Arena/TeamInfoView.csb"
    resNameTopBar = ""
    tag = "ArenaViewMgr"
    
    isRequested = false
    petNodes = {}
    playerNodes = {}
    rankListObj = nil
    getRankCell = nil

    MArenaViewMgr.closeCallBack = nil
    MArenaViewMgr.isNew = 0

    MArenaViewMgr.ArenaInfoTable = ArenaInfo.getArenaAwardAllChildren()
end

function MArenaViewMgr.request(scene)
    if not NetInterface.isConnect then
    	return
    end
    local function requireArenaRecode()
        NetInterface.sendWithBlock("GC_GetMArenaRecode_Ack", function()
            local ArenaSend = require("src.Net.Send.ArenaSend")
            ArenaSend.sendCG_GetMArenaRecode_Req({startIndex = 0,endIndex = 1})
        end, function ()
            MArenaViewMgr.show(scene)
        end, function ()
            TipsMgr.showError(scene, code)
        end)
    end
    local function requestRankStore()
        MArenaViewMgr.getShop = true
        NetInterface.sendWithBlock("GC_GETSHOP_ACK", function()
            local CommonShopSend = require("src.Net.Send.CommonShopSend")
            CommonShopSend.sendCG_getShop_Req({type = 1,})
        end, function()
            local function sendSystemRefreshGoodes()
                local index = 0
                MArenaViewMgr.getShop = false
                local timePoints = SystemInfo.getGlobalConfigAddInfoByID(34).values
                for i=1,#timePoints do
                    offsetTime = 3600 * timePoints[i]
                    dayDiff = CocosModuleMgr.getDayTimeDiff(ArenaExchangeMgr.systemReflashTime, CharInfo.getServerTime(), offsetTime)
                    if dayDiff ~= 0 then
                        MArenaViewMgr.systemRefresh = true
                        NetInterface.sendWithBlock("GC_SYSTEMREFRESHGOODS_ACK",function()
                            local CommonShopSend = require("src.Net.Send.CommonShopSend")
                            CommonShopSend.sendCG_SystemRefreshGoods_Req({type = 1,})
                        end,function()
                            MArenaViewMgr.systemRefresh = false
                            ArenaExchangeMgr.systemReflashTime = CharInfo.getServerTime()
                            if CSResourceMgr.getCsbObj("Player/Arena/ArenaExchange.csb") then
                                ArenaExchangeMgr.show(scene)
                            else
                                -- MArenaViewMgr.show(scene)
                                requireArenaRecode()
                            end
                        end,function(code)
                            TipsMgr.showError(scene, code)
                        end)
                        return
                    else
                        index = index + 1
                    end
                end
                if index == #timePoints then
                    -- MArenaViewMgr.show(scene)
                    requireArenaRecode()
                end
            end
            local offsetTime = SystemInfo.getGlobalConfigAddInfoByID(36).values[1] * 3600
            local dayDiff = CocosModuleMgr.getDayTimeDiff(ArenaExchangeMgr.shopResetTime, CharInfo.getServerTime(), offsetTime)
            if dayDiff ~= 0 then
                MArenaViewMgr.resetShop = true
                NetInterface.sendWithBlock("GC_RESETSHOP_ACK", function()
                    local CommonShopSend = require("src.Net.Send.CommonShopSend")
                    CommonShopSend.sendCG_ResetShop_Req({type = 1,})
                end, function()
                    MArenaViewMgr.resetShop = false
                    ArenaExchangeMgr.shopResetTime = CharInfo.getServerTime()
                    sendSystemRefreshGoodes()
                end, function(code)
                    TipsMgr.showError(scene, code)
                end)
            else
                sendSystemRefreshGoodes()
            end
            
        end, function(code)
            TipsMgr.showError(scene, code)
        end)
    end
    if isRequested then
        -- MArenaViewMgr.show(scene)
        requestRankStore()
    else
        local function requestColdDownTime()
            NetInterface.sendWithBlock("GC_GetCharacterValues_Ack", function()
                local LoginSend = require("src.Net.Send.LoginSend")
                LoginSend.sendCG_GetCharacterValues_Req({
                    "todayMArenaFightTimes",
                    "marenaUpdateTime",
                    "todayMArenaFightRefreshTimes",
                    "todayMArenaFightCDEndTime",
                    "arenaScore",
                    "topRank"})
            end, function()
                -- MArenaViewMgr.show(scene)
                requestRankStore()
            end, function(code)
                TipsMgr.showError(scene, code)
            end)
        end
        NetInterface.sendWithBlock("GC_QueryMArenaData_Ack", function()
            local ArenaSend = require("src.Net.Send.ArenaSend")
            ArenaSend.sendCG_QueryMArenaData_Req()
        end, function()
            requestColdDownTime()
        end, function(code)
            print("GC_QueryArenaData_Ack error code", code)
            if code==400 then
                NetInterface.sendWithBlock("GC_JoinMArena_Ack", function()
                    local ArenaSend = require("src.Net.Send.ArenaSend")
                    ArenaSend.sendCG_JoinMArena_Req()
                end, function()
                    requestColdDownTime()
                end, function(code)
                    DialogBoxMgr.showSmallDialogBox(scene, 1, "arena23")
                end)
            else
                DialogBoxMgr.showSmallDialogBox(scene, 1, "arena23")
            end
        end)
    end
end

function MArenaViewMgr.show(scene, closeCallBack)
    UIStack.push("MArenaViewMgr", MArenaViewMgr.hide, true)
    if closeCallBack ~= nil then
        MArenaViewMgr.closeCallBack = closeCallBack
    end

    SceneMgr.setMapVisible(false)
    ViewMgrUtils.WrapViewMgr(MArenaViewMgr)
    isRequested = true
    curTab = 1

    StatusBarMgr.showArenaTopBar(SceneMgr.getRunningScene, function ()
        if curTab == 3 then
            ArenaExchangeMgr.hide()
        elseif curTab == 4 then
            ArenaRecordMgr.hide()
        end
        MArenaViewMgr.hide()
    end, 1)
    
    local loadTab = {
            function()--1
                local curLayerA = CSResourceMgr.createRes(scene, resNameTab[1])
                CSResourceMgr.setFullScreen(resNameTab[1])
                curLayerA:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
                curLayerA:setOpacity(0)

                -- local panel2 = CSResourceMgr.getNodeByName(resNameTab[1], "panel_2")
                -- CocosModuleMgr.setRelativePosition(curLayerA, 320, 480)
                -- CocosModuleMgr.setEdgeDistance(panel2, nil, nil, nil, 0, false)

                MArenaViewMgr.createPlayerNode()
                MArenaViewMgr.showArenaPageOne()
                transition.fadeIn(curLayerA, {time=0.5})

                local panel1 = CSResourceMgr.getNodeByName(resNameTab[1], "panel_1")
                local panel2 = CSResourceMgr.getNodeByName(resNameTab[1], "panel_2")
                local list   = CSResourceMgr.seekNodeByName(panel1, "list")
                local diff = CocosModuleMgr.getScreenSizeDiff() > 0 and CocosModuleMgr.getScreenSizeDiff() or 0
                ViewMgrUtils.vFitSetPos(diff,  {panel1})
                ViewMgrUtils.vFitSetPos(-diff, {panel2})
                ViewMgrUtils.vFitStretch(diff, {list})
            end, 
            function()--2
                local curLayerB = CSResourceMgr.createRes(scene, resNameTab[2])
                CSResourceMgr.setFullScreen(resNameTab[2])
                curLayerB:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
                curLayerB:setOpacity(0)
                
                MArenaViewMgr.refreshRankPlayerSelfInfo()
                MArenaViewMgr.refreshRankTop()

                local list = CSResourceMgr.getNodeByName(resNameTab[2], "list")
                local rankPetListOpen = {false, false, false, false, false}
                function getRankCell(info)
                    local parent = CSResourceMgr.getNodeByName(resNameTab[2], "btn_item"):clone()
                    local btnDir = CSResourceMgr.seekNodeByName(parent, "btn_info")
                    local button = parent

                    if info == nil or PetEducationMgr.getTableLength(info) <= 0 then return parent end

                    MArenaViewMgr.setSingleRankItem(parent, info)

                    if info.rank>=1 and info.rank<=5 then
                        CSResourceMgr.setButtonTextureByNode(btnDir, MArenaViewMgr.DirIconPath[1], 
                            MArenaViewMgr.DirIconPath[1], MArenaViewMgr.DirIconPath[1])
                        CSResourceMgr.clickEventBindingByNode(button, function()
                            local function resfreshListCell(diff)--收起
                                local children = parent:getChildren()
                                print("children num", #children)
                                for var=1, #children do
                                    local tmpPosy = children[var]:getPositionY()
                                    children[var]:setPositionY(tmpPosy+diff)
                                end                            
                                list:refreshView()
                            end
                            if rankPetListOpen[info.rank] then
                                rankPetListOpen[info.rank] = false
                                parent:setContentSize(580, 126)
                                local petPanel = CSResourceMgr.seekNodeByName(parent, "pet_diban")
                                petPanel:setVisible(false)
                                resfreshListCell(-170)
                                CSResourceMgr.setButtonTextureByNode(btnDir, MArenaViewMgr.DirIconPath[1], 
                                    MArenaViewMgr.DirIconPath[1], MArenaViewMgr.DirIconPath[1])
                            else
                                local function loadPetsFunc()--展开
                                    local petInfos = ArenaInfo.getRankListPets(ArenaInfo.getWorldRankListInfo(info.rank)._id)
                                    local helperPetInfos = ArenaInfo.getRankListHelperPets(ArenaInfo.getWorldRankListInfo(info.rank)._id)
                                    if not petInfos then
                                        TipsMgr.show(scene, "arena30")
                                        return
                                    end
                                    
                                    rankPetListOpen[info.rank] = true
                                    parent:setContentSize(580, 296)
                                    
                                    local petPanel = CSResourceMgr.seekNodeByName(parent, "pet_diban")
                                    -- -- local petNode = CSResourceMgr.seekNodeByName(parent, "pet_bg")
                                    -- local petDiffx = 88
                                    -- local petOffsetPosY = 17
                                    -- for var=1, #petInfos do
                                    --     local petInfo = petInfos[var]
                                    --     local tag = info.rank * 10 + var
                                    --     local pNode = PetListMgr.createPetNode(petInfo, tag)

                                    --     local cloneNode = pNode.node
                                    --     cloneNode:addTo(petPanel)
                                    --     cloneNode:setPositionX(pNode.node:getPositionX()+petDiffx*(var-1))
                                    --     cloneNode:setPositionY(pNode.node:getPositionY()+petOffsetPosY)
                                    --     cloneNode:setScale(0.7)
                                    -- end
                                    -- petPanel:setScaleY(0)
                                    -- petPanel:setVisible(true)
                                    -- transition.scaleTo(petPanel, {scaleY=1, time=0.1})

                                    local petBG1 = CSResourceMgr.seekNodeByName(petPanel, "dikuang1")
                                    local petBG2 = CSResourceMgr.seekNodeByName(petPanel, "dikuang2")
                                    local strLeft = CSResourceMgr.seekNodeByName(petPanel, "str_left")
                                    local strRight = CSResourceMgr.seekNodeByName(petPanel, "str_right")

                                    CSResourceMgr.setLabelStringByNode(strLeft, "train122", nil, nil, 56)
                                    CSResourceMgr.setLabelStringByNode(strRight, "train123", nil, nil, 56)
                                    CSResourceMgr.setLabelColorByNode(strLeft, labelColor[6])
                                    CSResourceMgr.setLabelColorByNode(strRight, labelColor[6])

                                    for var=1, #petInfos do
                                        local petInfo = petInfos[var]
                                        local tag = info.rank * 10 + var
                                        local pNode = PetListMgr.createPetNodeByPetInfo(petInfo, tag)

                                        local cloneNode = pNode.node
                                        cloneNode:addTo(petBG1)
                                        cloneNode:setAnchorPoint(0, 0)
                                        cloneNode:setPosition((cloneNode:getContentSize().width - 45) * (var - 1) + 2, 5)
                                        cloneNode:setOpacity(0)
                                        transition.fadeIn(cloneNode, {time=0.5})
                                    end
                                    for var=1, #helperPetInfos do
                                        local petInfo = helperPetInfos[var]
                                        local tag = info.rank * 10 + var
                                        local pNode = PetListMgr.createPetNodeByPetInfo(petInfo, tag)

                                        local cloneNode = pNode.node
                                        cloneNode:addTo(petBG2)
                                        cloneNode:setAnchorPoint(0, 0)
                                        cloneNode:setPosition((cloneNode:getContentSize().width - 45) * (var - 1) + 2, 5)
                                        cloneNode:setOpacity(0)
                                        transition.fadeIn(cloneNode, {time=0.5})
                                    end
                                    petPanel:setScaleY(0)
                                    petPanel:setVisible(true)
                                    transition.scaleTo(petPanel, {scaleY=1, time=0.1})

                                    resfreshListCell(170)

                                    CSResourceMgr.setButtonTextureByNode(btnDir, MArenaViewMgr.DirIconPath[2], 
                                        MArenaViewMgr.DirIconPath[2], MArenaViewMgr.DirIconPath[2])
                                end
                                NetInterface.sendWithBlock("GC_QueryMArenaSoldierDetail_Ack", function()
                                    local ArenaSend = require("src.Net.Send.ArenaSend")
                                    ArenaSend.sendCG_QueryMArenaSoldierDetail_Req({
                                        charID=ArenaInfo.getWorldRankListInfo(info.rank)._id, 
                                        teamID=1,
                                    })
                                end, function()
                                    loadPetsFunc()
                                end, function()
                                    TipsMgr.show(scene, "arena30")
                                end)
                            end
                        end)
                    end
                    --CSResourceMgr.setLabelStringByNode(levelLB, info.level)
                    parent:setCascadeOpacityEnabled(true)
                    --CSResourceMgr.seekNodeByName(parent, "info_image"):setCascadeOpacityEnabled(true)
                    --CSResourceMgr.seekNodeByName(parent, "info_chardb"):setCascadeOpacityEnabled(true)
                    --CSResourceMgr.seekNodeByName(parent, "info_lvdb"):setCascadeOpacityEnabled(true)
                    CSResourceMgr.seekNodeByName(parent, "pet_diban"):setCascadeOpacityEnabled(true)
                    -- CSResourceMgr.seekNodeByName(parent, "pet_bg"):setCascadeOpacityEnabled(true)
                    -- CSResourceMgr.seekNodeByName(parent, "pet_frame"):setCascadeOpacityEnabled(true)
                    -- CSResourceMgr.seekNodeByName(parent, "pet_attrdb"):setCascadeOpacityEnabled(true)
                    return parent
                end--getRankCellEnd
                
                local requestRankProcess = 1
                local showSize = 10
                local currentRankList = ArenaInfo.getWorldRankList()
                rankListObj = CSResourceMgr.setCommonListInfo(currentRankList, resNameTab[2], "list", "", showSize, nil, function(id, var)
                    local cellNode = getRankCell(var)
                    cellNode:setVisible(true)
                    list:pushBackCustomItem(cellNode)
                    cellNode:setScaleY(0)
                    transition.scaleTo(cellNode, {scaleY = 1, time = 0.1})
                    return cellNode
                end, function(callback)
                    local function completeFunc()
                        requestRankProcess = 1+showSize
                        rankPetListOpen = {false, false, false, false, false}
                        callback()
                    end
                    if ArenaInfo.checkRefreshRankTime() then
                        NetInterface.send("GC_QueryMArenaRank_Ack", function()
                            ArenaInfo.clearWorldRankList()
                            ArenaInfo.setRefreshRankTime()
                            local ArenaSend = require("src.Net.Send.ArenaSend")
                            ArenaSend.sendCG_QueryMArenaRank_Req({min=1, max=showSize})
                        end, function()
                            if rankListObj then
                                rankListObj.setContent(ArenaInfo.getWorldRankList())
                            end
                            completeFunc()
                        end, function()
                            TipsMgr.show(scene, "arena29")
                        end)
                    else
                        completeFunc()
                        TipsMgr.show(scene, "arena29")
                    end
                end, function(callback)
                    if requestRankProcess>100 then
                        callback()
                        return
                    end
                    local function completeFunc()
                        requestRankProcess = requestRankProcess+showSize
                        callback()
                    end
                    if ArenaInfo.getWorldRankListInfo(requestRankProcess) then
                        completeFunc()
                    else
                        NetInterface.send("GC_QueryMArenaRank_Ack", function()
                            local ArenaSend = require("src.Net.Send.ArenaSend")
                            ArenaSend.sendCG_QueryMArenaRank_Req({min=requestRankProcess, max=requestRankProcess+showSize-1})
                        end, function()
                            if rankListObj then
                                rankListObj.setContent(ArenaInfo.getWorldRankList())
                            end
                            completeFunc()
                        end, function()
                            TipsMgr.show(scene, "arena29")
                        end)
                    end
                end)

                local panel1 = CSResourceMgr.getNodeByName(resNameTab[2], "panel_1")
                local panel2 = CSResourceMgr.getNodeByName(resNameTab[2], "panel_2")
                local list = CSResourceMgr.seekNodeByName(panel1, "list")
                local bg3 = CSResourceMgr.seekNodeByName(panel1, "bg3")
                local diff = CocosModuleMgr.getScreenSizeDiff() > 0 and CocosModuleMgr.getScreenSizeDiff() or 0
                ViewMgrUtils.vFitSetPos(diff, {panel1})
                ViewMgrUtils.vFitSetPos(-diff, {panel2})
                ViewMgrUtils.vFitStretch(diff, {list,bg3})

                transition.fadeIn(curLayerB, {time=0.5})
            end, 
            function()--3
                ArenaExchangeMgr.show(scene)
            end,
            function()--4
                MArenaViewMgr.isNew = 0
                MArenaViewMgr.showTab4RedPoint(false)
                ArenaRecordMgr.show(scene)
            end
        }
    
    local function changeTab(tabid)
        GameAudio.playUISound("sheetClick")
        for i = 1, 4 do
            CSResourceMgr.getNodeByName(resName, "tab"..i):setLocalZOrder(4-i)
        end
        local curTabLabel = CSResourceMgr.getNodeByName(resName, "tabtext"..curTab)
        -- curTabLabel:setPositionY(24)
        CSResourceMgr.setLabelString(resName, "tabtext"..curTab, "arena"..(2+curTab), "", {r=230,g=230,b=230,a=255})
        CSResourceMgr.setLabelColor(resName, "tabtext"..curTab, {r=82,g=82,b=82,a=255})
        CSResourceMgr.setButtonEnabled(resName, "tab"..curTab, true)
        local tmpNode1 = CSResourceMgr.getCsbObj(resNameTab[curTab])
        if tmpNode1 then
            transition.stopTarget(tmpNode1)
            transition.fadeOut(tmpNode1, {time=0.5})
            tmpNode1:performWithDelay(function()
                tmpNode1:setVisible(false)
            end, 0.5)
        end
        local spriteTab = CSResourceMgr.getNodeByName(resName, "tab"..curTab)
        -- spriteTab:setPositionY(870)
        spriteTab:setScale(1)

        if curTab == 3 then
            ArenaExchangeMgr.hide()
        elseif curTab == 4 then
            ArenaRecordMgr.hide()
        end

        curTab = tabid
        curTabLabel = CSResourceMgr.getNodeByName(resName, "tabtext"..curTab)
        -- curTabLabel:setPositionY(24)
        CSResourceMgr.getNodeByName(resName, "tab"..curTab):setLocalZOrder(MArenaViewMgr.TAB_NUM+1)
        CSResourceMgr.setLabelString(resName, "tabtext"..curTab, "arena"..(2+curTab), "", outlineColor[3])
        CSResourceMgr.setLabelColor(resName, "tabtext"..curTab, {r=255,g=255,b=255,a=255})
        CSResourceMgr.setButtonEnabled(resName, "tab"..curTab, false)

        local tmpNode2 = CSResourceMgr.getCsbObj(resNameTab[curTab])
        if tmpNode2 then
            transition.stopTarget(tmpNode2)
            tmpNode2:setVisible(true)
            transition.fadeIn(tmpNode2, {time=0.5})
            if curTab == 1 then
                MArenaViewMgr.refreshArenaScore()
            end
        else
            loadTab[curTab]()
        end
        spriteTab = CSResourceMgr.getNodeByName(resName, "tab"..curTab)
        spriteTab:setScale(1.2)

        local bg = CSResourceMgr.getNodeByName(resName, "background2")
        bg:setVisible(tabid ~= 3 and tabid ~= 4)
    end

    local function loadA()
        local curLayerBG = CSResourceMgr.createRes(scene, resNameBG, tag)
        curLayerBG:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resNameBG, 320, 480, tag)
        local curLayerDB = CSResourceMgr.createRes(scene, resNameDB, tag)
        curLayerDB:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resNameDB, 320, 480, tag)
        local curLayer = CSResourceMgr.createRes(scene, resName)
        curLayer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setFullScreen(resName)

        local aniPanel1 = CSResourceMgr.getNodeByName(resName, "ts_dit2")
        aniPanel1:setVisible(false)

        local btnQianli = CSResourceMgr.getNodeByName(resName, {"ts_dit2", "qianli"})
        local diff = CocosModuleMgr.getScreenSizeDiff() > 0 and CocosModuleMgr.getScreenSizeDiff() or 0
        ViewMgrUtils.vFitSetPos(diff, {btnQianli})

        local background = CSResourceMgr.getNodeByName(resName, {"ts_dit2", "background"})
        MArenaViewMgr.addStretchNode(background)
        MArenaViewMgr.addPosNode(background)

        local background2 = CSResourceMgr.getNodeByName(resName, {"ts_dit2", "background2"})
        MArenaViewMgr.addPosNode(background2)

        local background3 = CSResourceMgr.getNodeByName(resName, {"ts_dit2", "background3"})
        background3:setLocalZOrder(10)
        MArenaViewMgr.addPosNode(background3)

        local labelTitle = CSResourceMgr.getNodeByName(resName, "title")
        CSResourceMgr.setLabelStringByNode(labelTitle, "arena1", {r=38,g=54,b=76,a=255})
        CSResourceMgr.setLabelColorByNode(labelTitle, {r=214,g=245,b=250,a=255})
        MArenaViewMgr.addPosNode(labelTitle)
        for var=1, MArenaViewMgr.TAB_NUM do
        	local tabNode = CSResourceMgr.getNodeByName(resName, "tab"..var)
            tabNode:setLocalZOrder(0)
            MArenaViewMgr.addPosNode(tabNode)
        	CSResourceMgr.setLabelString(resName, "tabtext"..var, "arena"..(2+var), "", {r=255,g=255,b=255,a=255})
            CSResourceMgr.setLabelColor(resName, "tabtext"..var, {r=82,g=82,b=82,a=255})
            CSResourceMgr.setButtonTexture(resName, "tab"..var, "Pet/Education/cwxx_yeqian_1.png", 
                "Pet/Education/cwxx_yeqian_2.png", "Pet/Education/cwxx_yeqian_2.png")
            CSResourceMgr.clickEventBinding(resName, "tab"..var, function()
                changeTab(var)
            end)
        end

        if MArenaViewMgr.isNew == 1 then
            MArenaViewMgr.showTab4RedPoint(true)
        end
    end
    
    local function loadB()
        CSResourceMgr.playAllFrameWithCallback(resName, 1, function()
            -- changeTab(curTab)
        end, "", 0.1)
        changeTab(curTab)

        local aniPanel2 = CSResourceMgr.getNodeByName(resNameTab[1], "panel_1")
        local aniPanel3 = CSResourceMgr.getNodeByName(resNameTab[1], "panel_2")
        aniPanel2:setVisible(false)
        aniPanel3:setVisible(false)
    end

    local function playerAction()
        local aniPanel1 = CSResourceMgr.getNodeByName(resName, "ts_dit2")
        local aniPanel2 = CSResourceMgr.getNodeByName(resNameTab[1], "panel_1")
        local aniPanel3 = CSResourceMgr.getNodeByName(resNameTab[1], "panel_2")
        aniPanel1:setVisible(true)
        aniPanel2:setVisible(true)
        aniPanel3:setVisible(true)
        CocosModuleMgr.showUIAnimation(aniPanel1, "up")
        CocosModuleMgr.showUIAnimation(aniPanel2, "up")
        CocosModuleMgr.showUIAnimation(aniPanel3, "up")
    end

    local funcTable = {loadA, loadB, playerAction}
    UnblockLoader.load(funcTable, tag)

    ViewMgrUtils.AutoFit(MArenaViewMgr)
end

function MArenaViewMgr.showArenaPageOne()
    MArenaViewMgr.refreshPlayerSelfInfo()
    MArenaViewMgr.refreshAttackPetsInfo()
    MArenaViewMgr.refreshChallengPlayersInfo()
    MArenaViewMgr.refreshChallengTimes()
    -- MArenaViewMgr.refreshServerTime()
end

function MArenaViewMgr.refreshPlayerSelfInfo()
    local panel1     = CSResourceMgr.getNodeByName(resNameTab[1], "panel_1")
    local labelName  = CSResourceMgr.seekNodeByName(panel1, "char_name")
    local spriteVip  = CSResourceMgr.seekNodeByName(panel1, "vip_title")
    local labelVip   = CSResourceMgr.seekNodeByName(panel1, "vip_level")
    local labelLv    = CSResourceMgr.seekNodeByName(panel1, "char_level")
    local labelTitle = CSResourceMgr.seekNodeByName(panel1, "rank_title")
    local labelRank  = CSResourceMgr.seekNodeByName(panel1, "rank_num")
    local spriteIcon = CSResourceMgr.seekNodeByName(panel1, "char_icon")

    local vipLv = CharInfo.getVipInfoByID(CharInfo.getVIPLevel()).viplevel

    spriteVip:setVisible(vipLv ~= 0)
    labelLv:setVisible(vipLv ~= 0)

    CSResourceMgr.setLabelStringByNode(labelName, CharInfo.getNickName(), outlineColor[3], nil, 161)
    CSResourceMgr.setLabelStringByNode(labelVip, vipLv, outlineColor[3])
    CSResourceMgr.setLabelStringByNode(labelLv, "Lv."..CharInfo.getLevel(), outlineColor[3])
    CSResourceMgr.setLabelStringByNode(labelTitle, "arena7", outlineColor[2], nil, 160)
    CSResourceMgr.setLabelStringByNode(labelRank, ArenaInfo.getRank(), outlineColor[1], nil, 138)

    CSResourceMgr.setLabelColorByNode(labelName,  labelColor[2])
    CSResourceMgr.setLabelColorByNode(labelVip,   labelColor[2])
    CSResourceMgr.setLabelColorByNode(labelTitle, labelColor[3])

    CSResourceMgr.setSpriteTextureByNode(spriteIcon, CharInfo.getHeadIcon(CharInfo.getCurfashion()))
    spriteIcon:setScale(1.5)
    spriteIcon:setPositionY(70)

    MArenaViewMgr.setPlayerRankAward()
end

function MArenaViewMgr.getArenaAwardInfoIDByRank(rankNum)
    if rankNum == 0 then
        rankNum = 2001
    end
    local id = 1
    local tableCnt = #MArenaViewMgr.ArenaInfoTable
    for k,v in pairs(MArenaViewMgr.ArenaInfoTable) do
        print(k,v)
    end
    if rankNum >= MArenaViewMgr.ArenaInfoTable[tableCnt].id then
        return MArenaViewMgr.ArenaInfoTable[tableCnt].id
    end
    for i = 1, tableCnt do
        if rankNum < MArenaViewMgr.ArenaInfoTable[i].id then
            id = MArenaViewMgr.ArenaInfoTable[i-1].id
            break
        elseif rankNum == MArenaViewMgr.ArenaInfoTable[i].id then
            id = MArenaViewMgr.ArenaInfoTable[i].id
            break
        end
    end
    return id
end

function MArenaViewMgr.setPlayerRankAward()
    local rankNum = ArenaInfo.getRank() == 0 and 2001 or ArenaInfo.getRank()
    local id = MArenaViewMgr.getArenaAwardInfoIDByRank(rankNum)
    local awardInfo = ArenaInfo.getArenaAwardInfo(id)
    local node = CSResourceMgr.getNodeByName(resNameTab[1], "reward_node")

    local upInfo,skillNum = AchievementListMgr.getSkillUpInfo("JJC")
    local numCol = upInfo ~= nil and {r=174,g=254,b=6,a=255} or {r=255,g=255,b=255,a=255}
    local btnQianli = CSResourceMgr.getNodeByName(resName, "qianli")
    btnQianli:setVisible(upInfo ~= nil)
    if upInfo ~= nil then
        local qianliIcon = CSResourceMgr.seekNodeByName(btnQianli, "qianli_icon")
        local qianliLv = CSResourceMgr.seekNodeByName(btnQianli, "qianli_lv")
        CSResourceMgr.setLabelStringByNode(qianliLv, "Lv"..skillNum, {r=0,g=0,b=0,a=255,w=1,s=1})
        CSResourceMgr.setSpriteTextureByNode(qianliIcon, "Battle/skillIcon/"..upInfo.icon)
        qianliIcon:setScale(0.5)
        CSResourceMgr.clickEventBindingByNode(btnQianli, function()
            AchievementListMgr.showSkillInfo(upInfo, false, false, nil)
        end, 3)

        if rankNum <= MArenaViewMgr.ArenaInfoTable[#MArenaViewMgr.ArenaInfoTable].id then
            for i=1,3 do
                local up = CSResourceMgr.getNodeByName(resNameTab[1], "up"..i)
                up:setVisible(true)
                up:setPosition((i - 1) * (-80) + 538 + 40, 4)
            end
        end
    end

    if rankNum <= MArenaViewMgr.ArenaInfoTable[#MArenaViewMgr.ArenaInfoTable].id then
        for i=1,3 do
            local item, elementID
            if i == 1 then
                elementID = 9998
                item = ItemInfo.getItemIconById(elementID, awardInfo.gcash, numCol)
            elseif i == 2 then
                elementID = awardInfo.awardItems[1]
                item = ItemInfo.getItemIconById(elementID, awardInfo.awardItems[2], numCol)
            elseif i == 3 then
                elementID = 9995
                item = ItemInfo.getItemIconById(elementID, awardInfo.arenaPoint, numCol)
            end
            local posX = (i - 1) * (-80)
            item:setPosition(posX, 0)
            item:removeFromParent()
            item:addTo(node)
            item:setScale(0.5)

            CSResourceMgr.clickEventBindingByNode(item, function ()
                ItemInfoViewMgr.show({id = elementID}, false)
            end)
        end
    end
end

function MArenaViewMgr.refreshAttackPetsInfo()
    local panel1       = CSResourceMgr.getNodeByName(resNameTab[1], "panel_1")
    local btnAtk       = CSResourceMgr.seekNodeByName(panel1, "tab_attack")
    local btnDef       = CSResourceMgr.seekNodeByName(panel1, "tab_defence")
    local labelAtk     = CSResourceMgr.seekNodeByName(btnAtk, "label_atk")
    local labelDef     = CSResourceMgr.seekNodeByName(btnDef, "label_def")
    local labelPower   = CSResourceMgr.seekNodeByName(panel1, "power_num")
    local labelMain    = CSResourceMgr.seekNodeByName(panel1, "zhuzhan")
    local labelSupp    = CSResourceMgr.seekNodeByName(panel1, "support")
    local btnChange    = CSResourceMgr.seekNodeByName(panel1, "change_team")
    local labelChange  = CSResourceMgr.seekNodeByName(btnChange, "str_change")

    local fightPoint = 0
    local info = PokemonInfo.getPetArmy(ArenaInfo.getAttackArmyID())
    for var=1, #info do
        local objID = info[var]
        local petInfo = PokemonInfo.getPetInfoByObjID(objID)
        fightPoint = fightPoint + PokemonInfo.getFightPoint({petInfo})
    end

    CSResourceMgr.setLabelStringByNode(labelPower, fightPoint, outlineColor[3], nil, 140)
    CSResourceMgr.setLabelStringByNode(labelMain,  "train122", nil, nil, 56)
    CSResourceMgr.setLabelStringByNode(labelSupp,  "train123", nil, nil, 56)
    CSResourceMgr.setLabelStringByNode(labelChange,"arena11", outlineColor[2], nil, 120)

    CSResourceMgr.setLabelColorByNode(labelPower, labelColor[2])
    CSResourceMgr.setLabelColorByNode(labelMain,  labelColor[6])
    CSResourceMgr.setLabelColorByNode(labelSupp,  labelColor[6])

    local function setBtnState(selectedBtn, lastSelectedBtn, selectedBtnName, lastSelectedBtnName, selectedStr, lastSelectedStr)
        CSResourceMgr.setButtonEnabledByNode(selectedBtn, false)
        CSResourceMgr.setButtonEnabledByNode(lastSelectedBtn, true)

        CSResourceMgr.setLabelStringByNode(selectedBtnName, selectedStr, outlineColor[4])
        CSResourceMgr.setLabelStringByNode(lastSelectedBtnName, lastSelectedStr, outlineColor[5])

        CSResourceMgr.setLabelColorByNode(selectedBtnName, labelColor[4])
        CSResourceMgr.setLabelColorByNode(lastSelectedBtnName, labelColor[5])

        local diff = CocosModuleMgr.getScreenSizeDiff() > 0 and CocosModuleMgr.getScreenSizeDiff() or 0
        selectedBtn:setPositionY(220)
        lastSelectedBtn:setPositionY(212)
    end

    setBtnState(btnAtk, btnDef, labelAtk, labelDef, "arena9", "arena10")
    MArenaViewMgr.refreshPets(ArenaInfo.getAttackArmyID())

    local teamType = 0
    CSResourceMgr.clickEventBindingByNode(btnAtk, function ()
        GameAudio.playUISound("sheetClick")
        setBtnState(btnAtk, btnDef, labelAtk, labelDef, "arena9", "arena10")
        MArenaViewMgr.refreshPets(ArenaInfo.getAttackArmyID())
        teamType = 0
    end)

    CSResourceMgr.clickEventBindingByNode(btnDef, function ()
        GameAudio.playUISound("sheetClick")
        setBtnState(btnDef, btnAtk, labelDef, labelAtk, "arena10", "arena9")
        MArenaViewMgr.refreshPets(ArenaInfo.getDefenceArmyID())
        teamType = 1
    end)

    btnChange:setVisible(false)
    CSResourceMgr.clickEventBindingByNode(btnChange, function ()
        ArenaTeamViewMgr.show(SceneMgr.getRunningScene, 1, teamType)
    end)
end

function MArenaViewMgr.createPlayerNode()
    local list  = CSResourceMgr.getNodeByName(resNameTab[1], "list")
    local diban = CSResourceMgr.getNodeByName(resNameTab[1], "banzi")
    local node  = CSResourceMgr.getNodeByName(resNameTab[1], "player_card")
    local petDiffx = 195
    for var=1, MArenaViewMgr.PLAYER_NUM do
        playerNodes[var] = node:clone()
        playerNodes[var]:addTo(diban)
        playerNodes[var]:setPosition(100+petDiffx*(var-1), 190)
        print("create playerNodes !!!")
    end
    diban:removeFromParent(false)
    list:pushBackCustomItem(diban)
end

function MArenaViewMgr.refreshChallengPlayersInfo()
    if PetEducationMgr.getTableLength(MArenaViewMgr.EnemyTable) > 0 then
        MArenaViewMgr.refreshPlayers(MArenaViewMgr.EnemyTable)
    else
        MArenaViewMgr.refreshArenaEnemys()
    end
end

function MArenaViewMgr.refreshChallengTimes()
    local panel2         = CSResourceMgr.getNodeByName(resNameTab[1], "panel_2")
    local labelTimeTitle = CSResourceMgr.seekNodeByName(panel2, "times_title")
    local labelTimes     = CSResourceMgr.seekNodeByName(panel2, "times_num")
    local btnAddTimes    = CSResourceMgr.seekNodeByName(panel2, "addtimes")
    local btnChange      = CSResourceMgr.seekNodeByName(panel2, "refresh")
    local labelChange    = CSResourceMgr.seekNodeByName(btnChange, "str_refresh")

    local timesAll = SystemInfo.getGlobalConfigAddInfoByID(7004).values[1]
    local timesRemain = ArenaInfo.getMChallengeTimes()

    CSResourceMgr.setLabelStringByNode(labelTimeTitle, "arena20", outlineColor[3])
    CSResourceMgr.setLabelStringByNode(labelTimes, timesRemain.."/"..timesAll, outlineColor[3])
    CSResourceMgr.setLabelStringByNode(labelChange, "arena14", outlineColor[3])

    CSResourceMgr.setLabelColorByNode(labelTimeTitle, labelColor[3])

    CSResourceMgr.clickEventBindingByNode(btnAddTimes, function ()
        local cost = SystemInfo.getGlobalConfigAddInfoByID(7001).values[1]
        DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 2, CocosModuleMgr.createStringWithFormat({"train102", cost}), function()
            if cost > CharInfo.getMCash() then
                DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 1, "arena50")
                return
            elseif timesRemain >= timesAll then
                StandardTipsMgr.show(1, "arena61")
                return
            end
            NetInterface.sendWithBlock("GC_BUYMARENAFIGHTTIMES_ACK", function()
                local ArenaSend = require("src.Net.Send.ArenaSend")
                ArenaSend.sendCG_BuyMArenaFightTimes_Req()
            end, function ()
                -- MArenaViewMgr.show(scene)
                timesRemain = timesRemain + 1
                CSResourceMgr.setLabelStringByNode(labelTimes, timesRemain.."/"..timesAll, outlineColor[3])
                MArenaViewMgr.setChallengeBtnEnable(true)
                MArenaViewMgr.refreshPlayers(ArenaInfo.getEnemys())
            end, function (code)
                if code == 457 then
                    DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 1, "arena51")
                end
            end)
        end)
    end)

    CSResourceMgr.clickEventBindingByNode(btnChange, function ()
        MArenaViewMgr.refreshArenaEnemys()
    end)
end

function MArenaViewMgr.sendFriendDetailFunc()
    MArenaViewMgr.PlayerDetailIndex = 1
    local function send()
        local pInfo = MArenaViewMgr.EnemyTable[MArenaViewMgr.PlayerDetailIndex]
        if not pInfo then
            MArenaViewMgr.refreshPlayers(MArenaViewMgr.EnemyTable)
        	return
        end
        MArenaViewMgr.sendFriendDetail = true
        NetInterface.sendWithBlock("GC_GetFriendDetail_Ack", function()
            local ChatUserSend = require("src.Net.Send.ChatUserSend")
            ChatUserSend.sendCG_GetFriendDetail_Req({friendID = pInfo.charID})
        end, function()
            MArenaViewMgr.PlayerDetailIndex = MArenaViewMgr.PlayerDetailIndex + 1
            send()
        end)
    end
    send()
end

function MArenaViewMgr.setEnemyList(enemyInfo)
    if MArenaViewMgr.sendFriendDetail == true then
        MArenaViewMgr.sendFriendDetail = false
        if not MArenaViewMgr.EnemyTable[MArenaViewMgr.PlayerDetailIndex] then
        	return
        end
        for k,v in pairs(enemyInfo) do
            MArenaViewMgr.EnemyTable[MArenaViewMgr.PlayerDetailIndex][k] = v
        end
    end
end

function MArenaViewMgr.refreshArenaEnemys()
    NetInterface.sendWithBlock("GC_RandomMArenaEnemys_Ack", function()
        local ArenaSend = require("src.Net.Send.ArenaSend")
        ArenaSend.sendCG_RandomMArenaEnemys_Req()
    end, function()
        MArenaViewMgr.EnemyTable = ArenaInfo.getEnemys()
        -- MArenaViewMgr.refreshPlayers(ArenaInfo.getEnemys())
        MArenaViewMgr.sendFriendDetailFunc()
    end)
end

function MArenaViewMgr.hide()
    UnblockLoader.cancel(tag)
    UnblockLoader.cancel("MArenaViewMgr-loadTeamPets")
    -- for var=1, PetFormationMgr.PET_NUM do
    --     petNodes[var]:removeFromParent(true)
    -- end
    for var=1, MArenaViewMgr.PLAYER_NUM do
        -- playerNodes[var]:removeFromParent(true)
    end
    petNodes = {}
    playerNodes = {}
    rankListObj = nil
    getRankCell = nil
    local list = CSResourceMgr.getNodeByName(resNameTab[2], "list")
    if list then
        list:removeAllItems()
    end
	CSResourceMgr.removeCSObjectByTag(resName)
    for var=1, MArenaViewMgr.TAB_NUM do
        CSResourceMgr.removeCSObjectByTag(resNameTab[var])
	end
    if curTab == 3 then
        ArenaExchangeMgr.hide()
    elseif curTab == 4 then
        ArenaRecordMgr.hide()
    end
    curTab = 1
    CSResourceMgr.removeCSObjectByTag(resNameBG, tag)
    CSResourceMgr.removeCSObjectByTag(resNameDB, tag)
    CSResourceMgr.removeCSObjectByTag(resNamePets)
    SceneMgr.setMapVisible(true)
    --StatusBarMgr.hideArenaTopBar()
    StatusBarMgr.hide()
    if MArenaViewMgr.closeCallBack then
        MArenaViewMgr.closeCallBack()
    end
    MArenaViewMgr.isNew = 0

    local params = {}
    params.topRank = CharInfo.getArenaTopRank()
    TaskWatcherManager.onJingJiChangClose(params)

    UIStack.pop("MArenaViewMgr")
end

function MArenaViewMgr.setPetNode(node, index, objID)
    local icon  = CSResourceMgr.seekNodeByName(node, "lock_icon")
    local str1  = CSResourceMgr.seekNodeByName(node, "lock_str1")
    local str2  = CSResourceMgr.seekNodeByName(node, "lock_str2")
    local pNode = CSResourceMgr.seekNodeByName(node, "pet_node")

    local unlockLv = (index - 2) * 10
    local isLocked = index > 2 and unlockLv > CharInfo.getLevel()
    icon:setVisible(isLocked)
    str1:setVisible(isLocked)
    str2:setVisible(isLocked)
    CSResourceMgr.setLabelStringByNode(str1, "arena12", outlineColor[3])
    CSResourceMgr.setLabelColorByNode(str1, labelColor[8])
    CSResourceMgr.setLabelStringByNode(str2, "Lv."..unlockLv, outlineColor[3])
    CSResourceMgr.setLabelColorByNode(str2, labelColor[8])

    if not objID then return end
    local petInfo = PokemonInfo.getPetInfoByObjID(objID)
    local card = PetListMgr.createPetNode(petInfo)
    card.node:addTo(pNode)
    card.node:setPosition(0, 0)
    card.node:setAnchorPoint(0, 0)
    card.node:setOpacity(0)
    transition.fadeIn(card.node, {time=0.5})
end

function MArenaViewMgr.refreshPets(armyID)
	if not CSResourceMgr.getCsbObj(resNameTab[1]) then
		return
	end
    local mainPetsTable = PokemonInfo.getPetArmy(armyID)
    local suppPetsTable = PokemonInfo.getPetHelpArmy()

    local block1 = CSResourceMgr.getNodeByName(resNameTab[1], "bg7")
    local block2 = CSResourceMgr.getNodeByName(resNameTab[1], "bg8")
    local petCard = CSResourceMgr.getNodeByName(resNameTab[1], "pet_card")

    block1:removeAllChildren()
    block2:removeAllChildren()

    for i=1,3 do
        petNodes[i] = petCard:clone()
        petNodes[i]:addTo(block1)
        petNodes[i]:setPosition(52 + 93*(i-1), 59)
        MArenaViewMgr.setPetNode(petNodes[i], i, mainPetsTable[i])
    end

    for i=4,6 do
        petNodes[i] = petCard:clone()
        petNodes[i]:addTo(block2)
        petNodes[i]:setPosition(52 + 93*(i-4), 59)
        MArenaViewMgr.setPetNode(petNodes[i], i, suppPetsTable[i-3])
    end
end

function MArenaViewMgr.refreshPlayers(info)
    if not CSResourceMgr.getCsbObj(resNameTab[1]) then
        return
    end
    local list  = CSResourceMgr.getNodeByName(resNameTab[1], "list")
    local diban = CSResourceMgr.getNodeByName(resNameTab[1], "banzi")
    local node  = CSResourceMgr.getNodeByName(resNameTab[1], "player_card")
    local petDiffx = 195
    for var=1, MArenaViewMgr.PLAYER_NUM do
        if playerNodes[var] == nil then
            
            playerNodes[var] = node:clone()
            playerNodes[var]:addTo(diban)
            playerNodes[var]:setPosition(100+petDiffx*(var-1), 190)
            -- diban:removeFromParent(false)
            -- list:pushBackCustomItem(diban)

        end
        playerNodes[var]:setVisible(false)
    end
    local function rankSort(a,b)
        return tonumber(a.rank) < tonumber(b.rank)
    end
    table.sort(info, rankSort)
    local esize = #info
    if esize>MArenaViewMgr.PLAYER_NUM then
        esize = MArenaViewMgr.PLAYER_NUM
    end
    for var=1, esize do
        local playerCard = playerNodes[var]
        local playerInfo = info[var]
        local parent = playerNodes[var]

        local playerName   = CSResourceMgr.seekNodeByName(playerCard, "name")
        local playerRand   = CSResourceMgr.seekNodeByName(playerCard, "rank")
        local playerAtk    = CSResourceMgr.seekNodeByName(playerCard, "atk")
        local playerLv     = CSResourceMgr.seekNodeByName(playerCard, "level")
        local awardTitle   = CSResourceMgr.seekNodeByName(playerCard, "award_title")
        local awardnum     = CSResourceMgr.seekNodeByName(playerCard, "award_num")
        local btnChallenge = CSResourceMgr.seekNodeByName(playerCard, "btn_challeng")
        local strChallenge = CSResourceMgr.seekNodeByName(playerCard, "str_challeng")
        local playerAni    = CSResourceMgr.seekNodeByName(playerCard, "player_ani")
        local bg           = CSResourceMgr.seekNodeByName(playerCard, "bg22")

        local oldRank = CharInfo.getArenaTopRank() ~= 0 and CharInfo.getArenaTopRank() or ArenaInfo.getRank()
        local newRank = playerInfo.rank
        local rankAward = MArenaViewMgr.calcArenaMCash(oldRank, newRank)

        CSResourceMgr.setLabelStringByNode(playerName, playerInfo.name,         outlineColor[3], nil, 170)
        CSResourceMgr.setLabelStringByNode(playerRand, playerInfo.rank,         outlineColor[3], nil, 90)
        CSResourceMgr.setLabelStringByNode(playerAtk , playerInfo.fightPoint,   outlineColor[3], nil, 104)
        CSResourceMgr.setLabelStringByNode(playerLv  , "Lv."..playerInfo.level, outlineColor[3])
        CSResourceMgr.setLabelStringByNode(awardTitle, "arena18",               outlineColor[3], nil, 162)
        CSResourceMgr.setLabelStringByNode(awardnum  , "x"..rankAward,          outlineColor[3])
        CSResourceMgr.setLabelStringByNode(strChallenge,"arena15",              outlineColor[3], nil, 120)

        CSResourceMgr.setLabelColorByNode(playerName, labelColor[7])
        CSResourceMgr.setLabelColorByNode(playerAtk,  labelColor[2])
        CSResourceMgr.setLabelColorByNode(awardTitle, labelColor[3])

        bg:setColor({r=14,g=23,b=32,a=255})

        local params = {}
        params.skin = playerInfo.fashion.curFashion
        -- params.gender = charSex
        PlayerAnimeMgr.removePlayerByTag("ArenaPlayerAvatar"..var)
        local ani = PlayerAnimeMgr.createPlayer(playerAni, params, "ArenaPlayerAvatar"..var, true)
        local diff = CocosModuleMgr.getScreenSizeDiff() > 0 and CocosModuleMgr.getScreenSizeDiff() or 0
        ani:setScale(0.6 + diff * 0.001)
        ani:setOpacity(0)
        transition.fadeIn(ani, {time=0.3})

        CSResourceMgr.clickEventBindingByNode(btnChallenge, function()
            MArenaViewMgr.setChallengeBtnEnable(false)
            MArenaViewMgr.rankInfo.oldRank = oldRank
            MArenaViewMgr.rankInfo.newRank = newRank
            MArenaViewMgr.rankInfo.rankAward = rankAward

            local function challengeFunc()
                NetInterface.sendWithBlock("GC_MArenaRankFight_Ack", function()
                    local ArenaSend = require("src.Net.Send.ArenaSend")
                    ArenaSend.sendCG_MArenaRankFight_Req(playerInfo.charID)
                end, function()
                    if BattleCotroller.enterBattleScene then
                        GameAudio.playUISound("mapchange2")
                        --得到服务器 result 胜利则刷新玩家列表
                        print("star battle------------------------------------------------")
                        if #ArenaInfo.getBattleInfo().self==0 or #ArenaInfo.getBattleInfo().enemys==0 then
                            -- sendFunc(0)
                            DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 1, "arena25")
                        else
                            local function arenaBattleOver()
                                MArenaViewMgr.EnemyTable = {}
                                MArenaViewMgr.show(SceneMgr.getRunningScene, function ()
                                    GameGuideMgr.checkProcessInTown()
                                end)
                                GameGuideMgr.backToArena()

                                oldRank = CharInfo.getArenaTopRank() ~= 0 and CharInfo.getArenaTopRank() or ArenaInfo.getRank()
                                if oldRank < MArenaViewMgr.rankInfo.oldRank then
                                    ArenaWinViewMgr.show(SceneMgr.getRunningScene, MArenaViewMgr.rankInfo.oldRank,
                                        MArenaViewMgr.rankInfo.newRank, MArenaViewMgr.rankInfo.rankAward)
                                end
                            end
                            BattleCotroller.setRecordName(CharInfo.getNickName(), playerInfo.name)
                            BattlePVPMgr.mIsPVPBattle = true 
                            BattlePVPMgr.mPVPIsChallenger = true
                            BattleMapMgr.setArenaBattle(ArenaInfo.getBattleInfo().self, ArenaInfo.getBattleInfo().enemys, function()
                                --JJC战斗回调
                                MapSeekerMgr.setSeekFunc(arenaBattleOver)
                            end)
                        end
                        BattleCotroller.setEnterBattleScene(false)
                    end
                end, function(code)
                    TipsMgr.showError(nil, code)
                end, 2)
            end
            
            -- if CharInfo.getServerTime()>=ArenaInfo.getMColdDownTime() then
                if ArenaInfo.getMChallengeTimes()>0 then
                    challengeFunc()
                    -- print("challengeFunc........"..sz_T2S(ArenaInfo.getBattleInfo()))
                else
                    MArenaViewMgr.setChallengeBtnEnable(true)
                    TipsMgr.show(nil, "arena32") 
                end
            -- else
            --     local cost = SystemInfo.getGlobalConfigAddInfoByID(7000).values[1]
            --     DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 2, CocosModuleMgr.createStringWithFormat({"arena21", cost}), function()
            --         if cost > CharInfo.getMCash() then
            --             DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 1, "arena50")
            --             return
            --         end
            --         NetInterface.sendWithBlock("GC_CLEARARENACD_ACK", function()
            --             local ArenaSend = require("src.Net.Send.ArenaSend")
            --             ArenaSend.sendCG_ClearArenaCD_Req()
            --         end, function ()
            --             local timesAll = SystemInfo.getGlobalConfigAddInfoByID(7004).values[1]
            --             local timesRemain = ArenaInfo.getMChallengeTimes()
            --             MArenaViewMgr.setArenaChallengeTimes(false, timesRemain, timesAll)
            --         end, function (code)
            --             print("shi bai : ",code)
            --         end)
            --     end)
            -- end
        end, 2)
        local info = CSResourceMgr.seekNodeByName(parent, "player_btn")
        CSResourceMgr.clickEventBindingByNode(info, function()
            local function loadPetsFunc()
                local petInfos = ArenaInfo.getRankListPets(playerInfo._id)
                if not petInfos then
                    TipsMgr.show(SceneMgr.getRunningScene, "arena30")
                    return
                end
                
                local function loadCSB()
                    -- local petLayer = CSResourceMgr.createRes(SceneMgr.getRunningScene, resNamePets)
                    -- CSResourceMgr.setRelativePosition(resNamePets, 320, 480)
                    -- petLayer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
                    -- CSResourceMgr.clickEventBinding(resNamePets, "close", function()
                    --     CSResourceMgr.playActionWithCallback(resNamePets, 50, 55, 1, function()
                    --         CSResourceMgr.removeCSObjectByTag(resNamePets)
                    --     end)
                    -- end)
                    -- local petPanel = CSResourceMgr.seekNodeByName(petLayer, "pet_diban")
                    -- local petNode = CSResourceMgr.seekNodeByName(petLayer, "pet_bg")
                    -- local petDiffx = 79.3
                    -- for var=1, #petInfos do
                    --     -- local 
                    --     local petInfo = petInfos[var]
                    --     local pparent = petNode
                    --     if var>=2 then
                    --         local cloneNode = petNode:clone()
                    --         -- local cloneNode = pNode:clone()
                    --         cloneNode:addTo(petPanel)
                    --         cloneNode:setPositionX(petNode:getPositionX()+petDiffx*(var-1))
                    --         pparent = cloneNode
                    --     end
                    --     if petInfo.star then
                    --         for var=1, tonumber(petInfo.star) do
                    --             local starSp = CSResourceMgr.seekNodeByName(pparent, "star"..var)
                    --             starSp:setVisible(true)
                    --             starSp:setLocalZOrder(1)
                    --         end
                    --     end
                    --     local sprite = CSResourceMgr.seekNodeByName(pparent, "pet_icon")
                    --     CSResourceMgr.setSpriteTextureByNode(sprite, PokemonInfo.getPokemonIconByID(petInfo.pokeID))
                    --     local attri = CSResourceMgr.seekNodeByName(pparent, "pet_attr")
                    --     local attriinfo = tonumber(PokemonInfo.getPokemonInfoByID(petInfo.pokeID).elementAtt1)
                    --     CSResourceMgr.setSpriteTextureByNode(attri, "Pet/AttriIcon/"..attriinfo..".png")
                    --     local stage = CSResourceMgr.seekNodeByName(pparent, "pet_frame")
                    --     local attridb = CSResourceMgr.seekNodeByName(pparent, "pet_attrdb")
                    --     if petInfo.Stage then
                    --         local pvec = PokemonInfo.getStagePics(petInfo.Stage)
                    --         CSResourceMgr.setSpriteTextureByNode(stage, pvec.p1)
                    --         CSResourceMgr.setSpriteTextureByNode(attridb, pvec.p2)
                    --         if pvec.p3 then
                    --             local satgeFrame = display.newSprite(pvec.p3)
                    --             satgeFrame:addTo(stage)
                    --             satgeFrame:setPosition(stage:getContentSize().width/2, stage:getContentSize().height/2)
                    --         end
                    --     end
                    --     local level = CSResourceMgr.seekNodeByName(pparent, "pet_level")
                    --     CSResourceMgr.setLabelStringByNode(level, "Lv"..petInfo.level, MArenaViewMgr.LABLE_OUTLINE_THICK)
                    --     CSResourceMgr.setLabelColorByNode(level, {r=255,g=255,b=0,a=255})
                    -- end
                end
                
                local function playCSB()
                	CSResourceMgr.playAction(resNamePets, 0, 5, false)
                end
                
                local tmpFunc = {loadCSB, playCSB}
                UnblockLoader.load(tmpFunc, "MArenaViewMgr-loadTeamPets")
            end
            NetInterface.sendWithBlock("GC_QueryMArenaSoldierDetail_Ack", function()
                local ArenaSend = require("src.Net.Send.ArenaSend")
                ArenaSend.sendCG_QueryMArenaSoldierDetail_Req({
                    charID=playerInfo._id, 
                    teamID=playerInfo.teamID, 
                })
            end, function()
                loadPetsFunc()
            end, function()
                TipsMgr.show(nil, "arena30")
            end)
        end)
        playerNodes[var]:setCascadeOpacityEnabled(true)
        -- CSResourceMgr.seekNodeByName(parent, "jsdiban"):setCascadeOpacityEnabled(true)
        --CSResourceMgr.seekNodeByName(parent, "plvdiban"):setCascadeOpacityEnabled(true)
        playerNodes[var]:setOpacity(0)
        playerNodes[var]:setVisible(true)
        transition.fadeIn(playerNodes[var], {time=0.3})
    end
end

function MArenaViewMgr.setChallengeBtnEnable(enable)
    for i = 1, 3 do
        local btnChallenge = CSResourceMgr.seekNodeByName(playerNodes[i], "btn_challeng")
        CSResourceMgr.setButtonEnabledByNode(btnChallenge, enable)
    end
end

function MArenaViewMgr.setArenaChallengeTimes(showCD, timesLeft, timesTotal)--挑战
    local panel2         = CSResourceMgr.getNodeByName(resNameTab[1], "panel_2")
    local labelTimeTitle = CSResourceMgr.seekNodeByName(panel2, "times_title")
    local labelTimes     = CSResourceMgr.seekNodeByName(panel2, "times_num")
    if showCD == false then
        transition.stopTarget(labelTimes)
        CSResourceMgr.setLabelStringByNode(labelTimeTitle, "arena20", outlineColor[3])
        CSResourceMgr.setLabelStringByNode(labelTimes, timesLeft.."/"..timesTotal, outlineColor[3])
        CSResourceMgr.setLabelColorByNode(labelTimeTitle, labelColor[3])
    end
end

function MArenaViewMgr.getPlayerNodeByIndex(index)
    return playerNodes[index]
end

-- function MArenaViewMgr.calcArenaMCash(oldRank, newRank)--竞技场最高名次刷新获得钻石数量计算
--     if newRank >= 50000 then
--         return 1--新名次大于等于5万时不论进多少名都给1钻
--     elseif oldRank >= 50000 then
--         return math.max(math.ceil(55000*(1/math.pow(newRank+10,0.5)-1/math.pow(50000+10,0.5))),0)
--         --新名次小于5万且老名次大于等于5万时，按老名次为5万来计算
--     else
--         return math.max(math.ceil(55000*(1/math.pow(newRank+10,0.5)-1/math.pow(oldRank+10,0.5))),0)
--         --新名次小于5万且老名次小于5万时，正常计算
--     end
--     return 0
-- end

function MArenaViewMgr.calcArenaMCash(oldRank, newRank)--竞技场最高名次刷新获得钻石数量计算
    if newRank >= 10000 or oldRank <= newRank then
        return 0--新名次大于等于1万时不论进多少名都给1钻
    else
        if oldRank >= 10000 then
            oldRank = 10000
        end
        return math.ceil(13000*(1/math.pow(newRank+12,0.35)-1/math.pow(oldRank+12,0.35)))
    end
    return 0
end

function MArenaViewMgr.refreshArenaRank()
	if CSResourceMgr.getCsbObj(resNameTab[1]) then
        CSResourceMgr.callButtonFunc(resNameTab[1], "refresh")
        CSResourceMgr.setLabelString(resNameTab[1], "rank_num", ArenaInfo.getRank())
	end
    local fp = 0
    local info = PokemonInfo.getPetArmy(ArenaInfo.getAttackArmyID())
    for var=1, #info do
        local objID = info[var]
        local petInfo = PokemonInfo.getPetInfoByObjID(objID)
        fp = fp + PokemonInfo.getFightPoint({petInfo})
    end
    if CSResourceMgr.getCsbObj(resNameTab[2]) and getRankCell then
        CSResourceMgr.getNodeByName(resNameTab[2], "self"):removeAllChildren()
        local cellNode = getRankCell({
            rank = ArenaInfo.getRank(), 
            name = CharInfo.getNickName(), 
            fightPoint = fp,
            level = CharInfo.getLevel(), 
            gender = CharInfo.getSex(),
        })
        cellNode:addTo(CSResourceMgr.getNodeByName(resNameTab[2], "self"))
        cellNode:setAnchorPoint(0.5, 0.5)
        cellNode:setPosition(0, 0)
        cellNode:setVisible(true)
        CSResourceMgr.setButtonEnabledByNode(CSResourceMgr.seekNodeByName(cellNode, "info_btn"), false)
        CSResourceMgr.seekNodeByName(cellNode, "info_arrow"):setVisible(false)
    end
end

function MArenaViewMgr.refreshServerTime()
    if not CSResourceMgr.getCsbObj(resNameTab[1]) then
        return
    end
    local timeLabel = CSResourceMgr.getNodeByName(resNameTab[1], "times_title")
    if timeLabel then
        transition.stopTarget(timeLabel)
        if CharInfo.getServerTime()<ArenaInfo.getMColdDownTime() then
            local time = ArenaInfo.getMColdDownTime()-CharInfo.getServerTime()
            local h = math.floor(time/3600)
            local m = math.floor((time-h*3600)/60)
            local s = time-h*3600-m*60
            CSResourceMgr.setLabelString(resNameTab[1], "times_num", "")
            MArenaViewMgr.updateTime(h, m, s)
        else
            MArenaViewMgr.updateTime(0, 0, 0)
        end
    end
end

function MArenaViewMgr.refreshArenaScore()
    CSResourceMgr.setLabelString(resNameTab[1], "point_num", CharInfo.getArenaScore(), "", outlineColor[1])
end

function MArenaViewMgr.updateTime(h, m, s)
    local tmpAwardsEvent = {}
    local h_str = string.format("%02d", h)
    local m_str = string.format("%02d", m)
    local s_str = string.format("%02d", s)
    local timeTitle = CSResourceMgr.getNodeByName(resNameTab[1], "times_title")
    CSResourceMgr.setLabelStringByNode(timeTitle, "")
    local timeLabel = CSResourceMgr.getNodeByName(resNameTab[1], "times_num")
    CSResourceMgr.setLabelStringByNode(timeLabel, h_str..":"..m_str..":"..s_str)
    timeLabel:performWithDelay(function()
        MArenaViewMgr.updateTime(h, m, s)
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
                local timesAll = SystemInfo.getGlobalConfigAddInfoByID(7004).values[1]
                local timesRemain = ArenaInfo.getMChallengeTimes()
                CSResourceMgr.setLabelStringByNode(timeTitle, "arena20")
                CSResourceMgr.setLabelStringByNode(timeLabel, timesRemain.."/"..timesAll)
            end
        end
    end
end

--排行榜
function MArenaViewMgr.refreshRankPlayerSelfInfo()
    local panel1     = CSResourceMgr.getNodeByName(resNameTab[2], "panel_1")
    local labelName  = CSResourceMgr.seekNodeByName(panel1, "char_name")
    local spriteVip  = CSResourceMgr.seekNodeByName(panel1, "vip_title")
    local labelVip   = CSResourceMgr.seekNodeByName(panel1, "vip_level")
    local labelLv    = CSResourceMgr.seekNodeByName(panel1, "char_level")
    local labelTitle = CSResourceMgr.seekNodeByName(panel1, "rank_title")
    local labelRank  = CSResourceMgr.seekNodeByName(panel1, "rank_num")
    local spriteIcon = CSResourceMgr.seekNodeByName(panel1, "char_icon")

    local vipLv = CharInfo.getVipInfoByID(CharInfo.getVIPLevel()).viplevel

    spriteVip:setVisible(vipLv ~= 0)
    labelVip:setVisible(vipLv ~= 0)

    CSResourceMgr.setLabelStringByNode(labelName, CharInfo.getNickName(), outlineColor[3], nil, 161)
    CSResourceMgr.setLabelStringByNode(labelVip, vipLv, outlineColor[3])
    CSResourceMgr.setLabelStringByNode(labelLv, "Lv."..CharInfo.getLevel(), outlineColor[3])
    CSResourceMgr.setLabelStringByNode(labelTitle, "arena7", outlineColor[2], nil, 160)
    CSResourceMgr.setLabelStringByNode(labelRank, ArenaInfo.getRank(), outlineColor[1], nil, 138)

    CSResourceMgr.setLabelColorByNode(labelName,  labelColor[2])
    CSResourceMgr.setLabelColorByNode(labelVip,   labelColor[2])
    CSResourceMgr.setLabelColorByNode(labelTitle, labelColor[3])

    CSResourceMgr.setSpriteTextureByNode(spriteIcon, CharInfo.getHeadIcon(CharInfo.getCurfashion()))
    spriteIcon:setScale(1.5)
    spriteIcon:setPositionY(69)

    local btnRewardList = CSResourceMgr.seekNodeByName(panel1, "btn_rewardInfo")
    btnRewardList:setVisible(true)
    CSResourceMgr.clickEventBindingByNode(btnRewardList, function ()
        ArenaRewardList.show(SceneMgr.getRunningScene)
    end)

    local rewardTitle = CSResourceMgr.seekNodeByName(btnRewardList, "reward_title")
    CSResourceMgr.setLabelStringByNode(rewardTitle, "arena52", outlineColor[3], nil, 135)
end

function MArenaViewMgr.refreshRankTop()
    local panel = CSResourceMgr.getNodeByName(resNameTab[2], "panel_1")
    local labelTitle = CSResourceMgr.seekNodeByName(panel, "title1")
    local btnTitle = CSResourceMgr.seekNodeByName(panel, "topbtn")
    local list = CSResourceMgr.seekNodeByName(panel, "list")

    CSResourceMgr.setLabelStringByNode(labelTitle, "arena28", {r=221,g=82,b=26,a=255,w=2}, nil, 240)
    CSResourceMgr.clickEventBindingByNode(btnTitle, function ()
        list:scrollToTop(0.2, true)
    end)
end

MArenaViewMgr.BGTexColor1 = {
    {r=212,g=164,b=73 ,a=255},
    {r=93 ,g=183,b=209,a=255},
    {r=207,g=154,b=97 ,a=255},
    {r=154,g=180,b=188,a=255},
}

MArenaViewMgr.BGTexColor2 = {
    {r=226,g=187,b=91 ,a=255},
    {r=117,g=201,b=223,a=255},
    {r=223,g=177,b=126,a=255},
    {r=184,g=200,b=204,a=255},
}

MArenaViewMgr.BGTexColor3 = {
    {r=212,g=164,b=73 ,a=255},
    {r=93 ,g=183,b=209,a=255},
    {r=207,g=154,b=97 ,a=255},
    {r=154,g=180,b=188,a=255},
}

MArenaViewMgr.PlayerLvColor = {
    {r=206,g=159,b=71 ,a=255},
    {r=82 ,g=167,b=191,a=255},
    {r=195,g=144,b=89 ,a=255},
    {r=120,g=146,b=154,a=255},
}

function MArenaViewMgr.setSingleRankItem(node, playerInfo)
    local rankNum = playerInfo.rank
    local faimly = playerInfo.faimly or nil
    -- local gender = playerInfo.gender ~= 0 and "Charactor/Head/ditu_nv.png" or "Charactor/Head/ditu_nan.png"
    local diban = CSResourceMgr.seekNodeByName(node, "player_diban")
    local bg11 = CSResourceMgr.seekNodeByName(node, "bg11")
    local bg21 = CSResourceMgr.seekNodeByName(node, "bg21")
    local bg14 = CSResourceMgr.seekNodeByName(node, "bg14")
    local fmbg = CSResourceMgr.seekNodeByName(node, "family_bg")
    local rankTex = CSResourceMgr.seekNodeByName(node, "rank_num_sprite")
    local rankLab = CSResourceMgr.seekNodeByName(node, "rank_num_label")
    local playerIcon = CSResourceMgr.seekNodeByName(node, "player_icon")
    local spriteVip = CSResourceMgr.seekNodeByName(node, "bg13")
    local vip = CSResourceMgr.seekNodeByName(node, "player_vip")
    local playerLv = CSResourceMgr.seekNodeByName(node, "player_level")
    local playerName = CSResourceMgr.seekNodeByName(node, "player_name")
    local fc = CSResourceMgr.seekNodeByName(node, "fc")
    local familyNode = CSResourceMgr.seekNodeByName(node, "family")
    local btnDir = CSResourceMgr.seekNodeByName(node, "btn_info")

    if rankNum <= 3 then
        rankLab:setVisible(false)
        CSResourceMgr.setSpriteTextureByNode(rankTex, MArenaViewMgr.PlayerRankNumTex[rankNum])
    else
        rankTex:setVisible(false)
        CSResourceMgr.setLabelStringByNode(rankLab, rankNum, outlineColor[3])
        CSResourceMgr.setLabelColorByNode(rankLab, labelColor[3])
    end

    btnDir:setVisible(rankNum <= 5)

    if rankNum > 3 then rankNum = 4 end
    -- CSResourceMgr.setButtonTextureByNode(node, MArenaViewMgr.PlayerRankBackgroudTex[rankNum], 
    --     MArenaViewMgr.PlayerRankBackgroudTex[rankNum], MArenaViewMgr.PlayerRankBackgroudTex[rankNum])
    CSResourceMgr.setSpriteTextureByNode(playerIcon, CharInfo.getHeadIcon(playerInfo.fashion.curFashion))
    CSResourceMgr.setSpriteTextureByNode(diban, MArenaViewMgr.PlayerRankBackgroudTex[rankNum])
    bg11:setColor(MArenaViewMgr.BGTexColor1[rankNum])
    bg21:setColor(MArenaViewMgr.BGTexColor2[rankNum])
    bg14:setColor(MArenaViewMgr.BGTexColor3[rankNum])
    fmbg:setColor(MArenaViewMgr.BGTexColor2[rankNum])
    local vipLv = CharInfo.getVipInfoByID(playerInfo.vipLevel).viplevel
    CSResourceMgr.setLabelStringByNode(vip, vipLv, outlineColor[2])
    CSResourceMgr.setLabelStringByNode(playerLv, "Lv."..playerInfo.Level)
    CSResourceMgr.setLabelStringByNode(playerName, playerInfo.nickname, outlineColor[2], nil, 198)
    CSResourceMgr.setLabelStringByNode(fc, playerInfo.fightPoint, outlineColor[2], nil, 112)

    CSResourceMgr.setLabelColorByNode(vip, labelColor[2])
    CSResourceMgr.setLabelColorByNode(playerLv, MArenaViewMgr.PlayerLvColor[rankNum])

    spriteVip:setVisible(vipLv ~= 0)
    vip:setVisible(vipLv ~= 0)

    playerIcon:setScale(1)
    playerIcon:setPositionY(66)

    if faimly then

    else
        familyNode:setVisible(false)
    end
end

function MArenaViewMgr.showTab4RedPoint(show)
    CSResourceMgr.getNodeByName(resName,"RedPoint4"):setVisible(show)
end

return MArenaViewMgr