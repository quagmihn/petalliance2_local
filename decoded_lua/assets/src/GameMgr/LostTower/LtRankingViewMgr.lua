local LtRankingViewMgr = {}

LtRankingViewMgr.LABLE_OUTLINE_THICK = 1
LtRankingViewMgr.LABLE_OUTLINE_FAT = 3
LtRankingViewMgr.TAB_NUM = 2
LtRankingViewMgr.MAX_PET_NUM = 6

local resName = ""
local resNameTab = {}
local tag = ""

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

local itemCSB = {
    "LostTower/Menu/RankingItemA1.csb",
    "LostTower/Menu/RankingItemA1.csb",
}

function LtRankingViewMgr.Init()
    print("LtRankingViewMgr初始化")

    resName = "LostTower/Menu/RankingList.csb"
    resNameTab = {"LostTower/Menu/RankingTabNew.csb", "LostTower/Menu/RankingTabNew.csb", }
    tag = "LtRankingViewMgr"

    isRequested = false
    petNodes = {}
    playerNodes = {}
    rankListObj = nil
    getRankCell = nil
end

---设置玩家自己排名
function LtRankingViewMgr.refreshPlayerSelfInfo(resName, tag, info)
    local panel1     = CSResourceMgr.getNodeByName(resName, "panel_1", tag)
    local labelName  = CSResourceMgr.seekNodeByName(panel1, "char_name")
    local labelVip   = CSResourceMgr.seekNodeByName(panel1, "vip_level")
    local labelLv    = CSResourceMgr.seekNodeByName(panel1, "char_level")
    local labelTitle = CSResourceMgr.seekNodeByName(panel1, "rank_title")
    local labelRank  = CSResourceMgr.seekNodeByName(panel1, "rank_num")
    local spriteIcon = CSResourceMgr.seekNodeByName(panel1, "char_icon")
    
    CSResourceMgr.seekNodeByName(panel1,"vip_title"):setVisible(CharInfo.getVIPLevel() > 1)
    labelVip:setVisible(CharInfo.getVIPLevel() > 1)

    CSResourceMgr.setLabelStringByNode(labelName, info.name, outlineColor[3], nil, 161)
    CSResourceMgr.setLabelStringByNode(labelVip, info.vipLevel, outlineColor[3])
    CSResourceMgr.setLabelStringByNode(labelLv, "Lv."..CharInfo.getLevel(), outlineColor[3])
    CSResourceMgr.setLabelStringByNode(labelTitle, "arena7", outlineColor[2], nil, 160)
    CSResourceMgr.setLabelStringByNode(labelRank, info.rank, outlineColor[1], nil, 138)

    CSResourceMgr.setLabelColorByNode(labelName,  labelColor[2])
    CSResourceMgr.setLabelColorByNode(labelVip,   labelColor[2])
    CSResourceMgr.setLabelColorByNode(labelTitle, labelColor[3])

    CSResourceMgr.setSpriteTextureByNode(spriteIcon, CharInfo.getHeadIcon(CharInfo.getCurfashion()))
    spriteIcon:setScale(1.5)
    spriteIcon:setPositionY(70)

    if info.rank >= 99999 then
        CSResourceMgr.setLabelStringByNode(labelRank, "LtText21", nil, nil, 136)
    end
end

---创建rankList cell
--@param info table {rank = ..., name = ..., level = ..., vipLevel = ..., fightPoint = ..., } 
--@param type number 1:itemA 2:itemB
function LtRankingViewMgr.createRankingItem(info, type)
    type = type or 1
    
    local itemCSB = {
        "LostTower/Menu/RankingItemA.csb",
        "LostTower/Menu/RankingItemB.csb",
    }
    local sample = CSResourceMgr.createRes(nil,itemCSB[type])
    local parent = CSResourceMgr.seekNodeByName(sample, "info_diban"):clone()

    local leftDB = CSResourceMgr.seekNodeByName(parent, "info_rankdiban")    -- 左边排名底板
    local nameDB = CSResourceMgr.seekNodeByName(parent, "info_namediban")
    local vipDB = CSResourceMgr.seekNodeByName(parent, "info_vipdiban")
    local rankDB = CSResourceMgr.seekNodeByName(parent, "info_image")

    local rankNum = CSResourceMgr.seekNodeByName(parent, "info_rankNum")
    local vipLB = CSResourceMgr.seekNodeByName(parent, "info_vip")
    local levelLB = CSResourceMgr.seekNodeByName(parent, "info_level")
    local nameLB = CSResourceMgr.seekNodeByName(parent, "info_name")
    

    local Strip = CSResourceMgr.seekNodeByName(parent, "info_background1")   -- 分割线或者底板
    local powerLB = CSResourceMgr.seekNodeByName(parent, "info_power")       -- ranking point (层数或者积分)
    
    -- ranking point底板
    local rightDB = CSResourceMgr.seekNodeByName(parent, "info_background2")

    local rankID = CSResourceMgr.seekNodeByName(parent, "info_rank")--排名图片
    local charIcon = CSResourceMgr.seekNodeByName(parent, "info_icon")--玩家
    local button = CSResourceMgr.seekNodeByName(parent, "info_btn")
    local dirIcon = CSResourceMgr.seekNodeByName(parent, "info_dir")--方向

    -- 宠物需求不要了
    dirIcon:setVisible(false)

    local palyerNameOutlineColorTab = {          --玩家名字、战斗力描边
        {r=160,g=86,b=0,a=255},
        {r=5,g=94,b=139,a=255},
        {r=113,g=65,b=17,a=255},
        {r=5,g=48,b=84,a=255}
    }
    local playerNameBackgroundColorTab = {       --玩家名字、VIP背景
        {r=181,g=122,b=9,a=255},
        {r=4,g=122,b=161,a=255},
        {r=164,g=107,b=6,a=255},
        {r=67,g=85,b=100,a=255}
    }
    local playerRankNumBackgroundColorTab = {    --排名衬底
        {r=220,g=167,b=6,a=255},
        {r=92,g=172,b=198,a=255},
        {r=220,g=161,b=64,a=255},
        {r=67,g=85,b=100,a=255}
    }
    local playerStripColorTab = {                --分割线颜色
        {r=225,g=176,b=3,a=255},
        {r=102,g=175,b=204,a=255},
        {r=222,g=154,b=63,a=255},
        {r=99,g=115,b=114,a=255}
    }
    local playerAtkBackgroundColorTab = {        --战斗力背景
        {r=181,g=122,b=9,a=255},
        {r=4,g=122,b=161,a=255},
        {r=164,g=107,b=6,a=255},
        {r=67,g=85,b=100,a=255}
    }
    local playerRankNumTex = {
        "UI/CommonFiles/share_calligraphy_1st.png",
        "UI/CommonFiles/share_calligraphy_2nd.png",
        "UI/CommonFiles/share_calligraphy_3rd.png",
    }
    local playerRankBackgroudTex = {
        "UI/CommonFiles/ranking_substrate_gold_su.png",
        "UI/CommonFiles/ranking_substrate_silver_su.png",
        "UI/CommonFiles/ranking_substrate_copper_su.png",
        "UI/CommonFiles/ranking_substrate_normal_su.png",
    }
    
    local vipLv = info.vipLevel and info.vipLevel or 1
    if info.rank >= 99999 then
        CSResourceMgr.setLabelStringByNode(rankNum, "LtText21", nil, nil, 48)
    else
        CSResourceMgr.setLabelStringByNode(rankNum, info.rank)
    end

    if type == 1 then
        local _label = CSResourceMgr.seekNodeByName(parent, "info_power_t")
        CSResourceMgr.setLabelStringByNode(_label, "LtText22")
    end
    
    CSResourceMgr.setLabelStringByNode(vipLB, vipLv)
    CSResourceMgr.setLabelStringByNode(levelLB, "Lv"..info.level)
    CSResourceMgr.setLabelStringByNode(nameLB, info.name)
    CSResourceMgr.setLabelStringByNode(powerLB, info.fightPoint)
    rankNum:enableOutline({r=10,g=69,b=89,a=255}, LtRankingViewMgr.LABLE_OUTLINE_FAT)
    vipLB:enableOutline(outlineColor[1], LtRankingViewMgr.LABLE_OUTLINE_THICK)
    levelLB:enableOutline(outlineColor[1], CSResourceMgr.DEFAULT_LABEL_OUTLINE_BORDER)
    if info.rank >= 1 and info.rank <= 3 then
        leftDB:setColor(playerRankNumBackgroundColorTab[info.rank])
        nameDB:setColor(palyerNameOutlineColorTab[info.rank])
        vipDB:setColor(playerNameBackgroundColorTab[info.rank])
        Strip:setColor(playerStripColorTab[info.rank])
        rightDB:setColor(playerAtkBackgroundColorTab[info.rank])
        nameLB:enableOutline(palyerNameOutlineColorTab[info.rank], LtRankingViewMgr.LABLE_OUTLINE_THICK)
        powerLB:enableOutline(palyerNameOutlineColorTab[info.rank], LtRankingViewMgr.LABLE_OUTLINE_THICK)
        CSResourceMgr.setSpriteTextureByNode(rankDB,playerRankBackgroudTex[info.rank])
        CSResourceMgr.setSpriteTextureByNode(rankID, playerRankNumTex[info.rank])
        rankNum:setVisible(false)
        --dirIcon:setVisible(true)
    elseif info.rank >= 4 then
        leftDB:setColor(playerRankNumBackgroundColorTab[4])
        nameDB:setColor(palyerNameOutlineColorTab[4])
        vipDB:setColor(playerNameBackgroundColorTab[4])
        Strip:setColor(playerStripColorTab[4])
        rightDB:setColor(playerAtkBackgroundColorTab[4])
        nameLB:enableOutline(palyerNameOutlineColorTab[4], LtRankingViewMgr.LABLE_OUTLINE_THICK)
        powerLB:enableOutline(palyerNameOutlineColorTab[4], LtRankingViewMgr.LABLE_OUTLINE_THICK)
        rankID:setVisible(false)
        --dirIcon:setVisible(info.rank <= 5)
        CSResourceMgr.setButtonEnabledByNode(button, info.rank <= 5)
        CSResourceMgr.setSpriteTextureByNode(rankDB,playerRankBackgroudTex[4])
    end
    
    charIcon:setScale(0.80)
    CSResourceMgr.setSpriteTextureByNode(charIcon, info.charIcon)
        
    parent:setCascadeOpacityEnabled(true)
    CSResourceMgr.seekNodeByName(parent, "pet_diban"):setCascadeOpacityEnabled(true)
    
    return parent
end

---创建rankList cell
--@param info table {rank = ..., name = ..., level = ..., vipLevel = ..., fightPoint = ..., } 
--@param type number 1:itemA 2:itemB
function LtRankingViewMgr.createRankingItemNew(playerInfo, type)
    local sample = CSResourceMgr.createRes(nil,itemCSB[type])
    local node = CSResourceMgr.seekNodeByName(sample, "btn_item"):clone()

    local rankNum = playerInfo.rank
    local faimly = playerInfo.faimly or nil
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
    
    CSResourceMgr.seekNodeByName(node,"bg13"):setVisible(playerInfo.vipLevel > 1)
    vip:setVisible(playerInfo.vipLevel > 1)

    playerIcon:setScale(1.0)
    CSResourceMgr.setSpriteTextureByNode(playerIcon, playerInfo.charIcon)

    if type == 1 then
        local icon = CSResourceMgr.seekNodeByName(node, "bg15")
        icon:loadTexture("UI/CommonFiles/mishitachengshu.png")
    end
    if type == 2 then
        local icon = CSResourceMgr.seekNodeByName(node, "bg15")
        icon:loadTexture("UI/CommonFiles/tower_integral_01.png")
    end

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
    
    local vipLv = CharInfo.getVipInfoByID(playerInfo.vipLevel).viplevel
    CSResourceMgr.setLabelStringByNode(vip, vipLv, outlineColor[2])
    CSResourceMgr.setLabelStringByNode(playerLv, "Lv."..playerInfo.level)
    CSResourceMgr.setLabelStringByNode(playerName, playerInfo.name, outlineColor[2], nil, 198)
    CSResourceMgr.setLabelStringByNode(fc, playerInfo.fightPoint, outlineColor[2], nil, 112)

    CSResourceMgr.setLabelColorByNode(vip, labelColor[2])
    CSResourceMgr.setLabelColorByNode(playerLv, ArenaViewMgr.PlayerLvColor[rankNum])

    if faimly then

    else
        familyNode:setVisible(false)
    end
    
    return node
end


function LtRankingViewMgr.showNew(scene)
    UIStack.push("LtRankingViewMgr",LtRankingViewMgr.hide)

    isRequested = true
    local curTab = 1
    
    local loadTab = {
        function()
            local tagA = "LtRankingTab1"
            local curLayerA = CSResourceMgr.createRes(scene, resNameTab[1],tagA)
            CSResourceMgr.setFullScreen(resNameTab[1],tagA)
            curLayerA:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
            curLayerA:setOpacity(0)

            local panel = CSResourceMgr.getNodeByName(resNameTab[1], "panel_1", tagA)
            local labelTitle = CSResourceMgr.seekNodeByName(panel, "title1")
            CSResourceMgr.setLabelStringByNode(labelTitle, "arena28", {r=221,g=82,b=26,a=255,w=2}, nil, 240)
            
            local btnRewardList = CSResourceMgr.seekNodeByName(panel, "btn_rewardInfo")
            local rewardTitle = CSResourceMgr.seekNodeByName(btnRewardList, "reward_title")
            CSResourceMgr.setLabelStringByNode(rewardTitle, "arena52", outlineColor[3], nil, 135)
            CSResourceMgr.clickEventBindingByNode(btnRewardList, function ()    
                local _t = LostTowerInfo.getLostTowerRankAwardInfoById(1).awardList
                local t = {}
                for i, value in pairs(_t) do
                    t[i] = {id = value.rank, awardItems = {}}
                    for k, v in pairs(value.awardItems) do
                        local _info = LostTowerInfo.getLostTowerAwardInfoById(v)
                        t[i].awardItems[k] = {
                            elementID = _info.itemID,
                            count     = _info.count,
                        }
                    end
                end
                LtRankAwardList.show(SceneMgr.getRunningScene, t, 1)
            end)
            
            local list = CSResourceMgr.getNodeByName(resNameTab[1], "list",tagA)
            
            local requestRankProcess = 1
            local showSize = 10
            local currentRankList = LostTowerInfo.getFloorRankingList() or {}
            rankListObj = CSResourceMgr.setCommonListInfo(currentRankList, resNameTab[1], "list", tagA, showSize, nil, function(id, var)
                local _icon = currentRankList[id].icon == 0 and 1001 or currentRankList[id].icon
                local cellNode = LtRankingViewMgr.createRankingItemNew({
                    name = currentRankList[id].nickname,
                    level = currentRankList[id].level,
                    vipLevel = currentRankList[id].viplevel,
                    fightPoint = currentRankList[id].floor,
                    rank = id,
                    charIcon = ItemInfo.getFashionItemInfoById(_icon).filePath,
                }, 1)
                cellNode:setVisible(true)
                list:pushBackCustomItem(cellNode)
                cellNode:setScaleY(0)
                transition.scaleTo(cellNode, {scaleY = 1, time = 0.1})
                return cellNode
            end, function(callback)
                local function completeFunc()
                    requestRankProcess = 1+showSize
                    callback()
                end
                callback()
            end, function(callback)   -- request more
                if requestRankProcess>100 then
                    callback()
                    return
            end
            local function completeFunc()
                    requestRankProcess = requestRankProcess+showSize
                    callback()
                end
                if LostTowerInfo.getFloorRankingListInfo(requestRankProcess) then
                    completeFunc()
            else
                    completeFunc()
                end
            end)

            local myRank
            for i = 1, #currentRankList do
                local charID = currentRankList[i].charID or 0
                if charID == CharInfo.getCharID() then
                    myRank = i
                    break
                end
            end
            if not myRank then
                myRank = 99999
            end
            LtRankingViewMgr.refreshPlayerSelfInfo(resNameTab[1],tagA,{
                rank = myRank, 
                name = CharInfo.getNickName(), 
                fightPoint = LostTowerMgr.weekMaxFloor,
                level = CharInfo.getLevel(), 
                gender = CharInfo.getSex(),
                vipLevel = CharInfo.getVipInfoByID(CharInfo.getVIPLevel()).viplevel,
                charIcon = CharInfo.getHeadIcon(CharInfo.getCurfashion()),
            })
            
            transition.fadeIn(curLayerA, {time=0.5})
        end,
        function()
            local tagB = "LtRankingTab2"
            local curLayerB = CSResourceMgr.createRes(scene, resNameTab[2],tagB)
            CSResourceMgr.setFullScreen(resNameTab[2],tagB)
            curLayerB:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
            curLayerB:setOpacity(0)

            local panel = CSResourceMgr.getNodeByName(resNameTab[2], "panel_1",tagB)
            local labelTitle = CSResourceMgr.seekNodeByName(panel, "title1")
            CSResourceMgr.setLabelStringByNode(labelTitle, "arena28", {r=221,g=82,b=26,a=255,w=2}, nil, 240)

            local btnRewardList = CSResourceMgr.seekNodeByName(panel, "btn_rewardInfo")
            local rewardTitle = CSResourceMgr.seekNodeByName(btnRewardList, "reward_title")
            CSResourceMgr.setLabelStringByNode(rewardTitle, "arena52", outlineColor[3], nil, 135)
            CSResourceMgr.clickEventBindingByNode(btnRewardList, function ()    
                local _t = LostTowerInfo.getLostTowerRankAwardInfoById(2).awardList
                local t = {}
                for i = 1, #_t do
                    t[i] = {id = i, awardItems = {}}
                    for k, v in pairs(_t[i].awardItems) do
                        local _info = LostTowerInfo.getLostTowerAwardInfoById(v)
                        t[i].awardItems[k] = {
                            elementID = _info.itemID,
                            count     = _info.count,
                        }
                    end
                end
                LtRankAwardList.show(SceneMgr.getRunningScene, t, 1)
            end)
            
            local list = CSResourceMgr.getNodeByName(resNameTab[2], "list",tagB)
            
            local requestRankProcess = 1
            local showSize = 10
            local currentRankList = LostTowerInfo.getPointRankingList() or {}
            rankListObj = CSResourceMgr.setCommonListInfo(currentRankList, resNameTab[2], "list", tagB, showSize, nil, function(id, var)
                local _icon = currentRankList[id].icon == 0 and 1001 or currentRankList[id].icon
                local cellNode = LtRankingViewMgr.createRankingItemNew({
                    name = currentRankList[id].nickname,
                    level = currentRankList[id].level,
                    vipLevel = currentRankList[id].viplevel,
                    fightPoint = currentRankList[id].point,
                    rank = id,
                    charIcon = ItemInfo.getFashionItemInfoById(_icon).filePath,
                }, 2)
                cellNode:setVisible(true)
                list:pushBackCustomItem(cellNode)
                cellNode:setScaleY(0)
                transition.scaleTo(cellNode, {scaleY = 1, time = 0.1})
                return cellNode
            end, function(callback)
                local function completeFunc()
                    requestRankProcess = 1+showSize
                    callback()
                end
                callback()
            end, function(callback)   -- request more
                if requestRankProcess>100 then
                    callback()
                    return
                end
                local function completeFunc()
                    requestRankProcess = requestRankProcess+showSize
                    callback()
                end
                if LostTowerInfo.getFloorRankingListInfo(requestRankProcess) then
                    completeFunc()
                else
                    completeFunc()
                end
            end)
            
            local myRank
            for i = 1, #currentRankList do
                local charID = currentRankList[i].charID or 0
                if charID == CharInfo.getCharID() then
                	myRank = i
                	break
                end
            end
            if not myRank then
                myRank = 99999
            end
            
            LtRankingViewMgr.refreshPlayerSelfInfo(resNameTab[2],tagB,{
                rank = myRank, 
                name = CharInfo.getNickName(), 
                fightPoint = LostTowerMgr.weekMaxPoints,
                level = CharInfo.getLevel(), 
                gender = CharInfo.getSex(),
                vipLevel = CharInfo.getVipInfoByID(CharInfo.getVIPLevel()).viplevel,
                charIcon = CharInfo.getHeadIcon(CharInfo.getCurfashion()),
            })
            
            transition.fadeIn(curLayerB, {time=0.5})
        end,
    }
    
    local function changeTab(tabid)
    
        -- set last tab button
        CSResourceMgr.getNodeByName(resName, "frame_split"):setLocalZOrder(2)
        CSResourceMgr.getNodeByName(resName, "tab"..curTab):setLocalZOrder(0)
        CSResourceMgr.setLabelString(resName, "tabtext"..curTab, "LtRankT"..curTab, "", {r=255,g=255,b=255,a=255})
        CSResourceMgr.setLabelColor(resName, "tabtext"..curTab, {r=82,g=82,b=82,a=255})
        CSResourceMgr.setButtonEnabled(resName, "tab"..curTab, true)

        -- hide last tab content
        local tmpNode1 = CSResourceMgr.getCsbObj(resNameTab[curTab],"LtRankingTab"..curTab)
        if tmpNode1 then
            transition.stopTarget(tmpNode1)
            transition.fadeOut(tmpNode1, {time=0.5})
            tmpNode1:performWithDelay(function()
                tmpNode1:setVisible(false)
            end, 0.5)
        end
        local spriteTab = CSResourceMgr.getNodeByName(resName, "tab"..curTab)
        spriteTab:setPositionY(830)
        spriteTab:setScale(1)

        curTab = tabid
        
        -- set current tab button
        CSResourceMgr.getNodeByName(resName, "tab"..curTab):setLocalZOrder(1)
        CSResourceMgr.setLabelString(resName, "tabtext"..curTab, "LtRankT"..curTab, "", {r=210,g=138,b=2,a=255})
        CSResourceMgr.setLabelColor(resName, "tabtext"..curTab, {r=255,g=255,b=255,a=255})
        CSResourceMgr.setButtonEnabled(resName, "tab"..curTab, false)
        
        -- show current tab content
        local tmpNode2 = CSResourceMgr.getCsbObj(resNameTab[curTab],"LtRankingTab"..curTab)
        if tmpNode2 then
            transition.stopTarget(tmpNode2)
            tmpNode2:setVisible(true)
            transition.fadeIn(tmpNode2, {time=0.5})
        else
            loadTab[curTab]()
        end
        spriteTab = CSResourceMgr.getNodeByName(resName, "tab"..curTab)
        spriteTab:setPositionY(834)
        spriteTab:setScale(1.25)

    end

    local function loadA()
        local curLayer = CSResourceMgr.createRes(scene, resName)
        curLayer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setFullScreen(resName)

        CSResourceMgr.clickEventBinding(resName, "close", function()
            LtRankingViewMgr.hide()
        end)

        --title
        CSResourceMgr.setLabelColor(resName,{"frame","title"},{r=144,g=238,b=255,a=255})
        CSResourceMgr.setLabelString(resName,{"frame","title"},"LtShop1","",{r=38,g=54,b=76,a=255},nil,120)   -- "迷失之塔"
        
        for var=1, LtRankingViewMgr.TAB_NUM do
            CSResourceMgr.getNodeByName(resName, "tab"..var):setLocalZOrder(0)
            CSResourceMgr.setLabelString(resName, "tabtext"..var, "LtRankT"..var, "", {r=255,g=255,b=255,a=255,w=1},nil,120)
            CSResourceMgr.setLabelColor(resName, "tabtext"..var, {r=82,g=82,b=82,a=255})
            CSResourceMgr.setButtonTexture(resName, "tab"..var, "Pet/Education/cwxx_yeqian_1.png", 
                "Pet/Education/cwxx_yeqian_2.png", "Pet/Education/cwxx_yeqian_2.png")
            CSResourceMgr.clickEventBinding(resName, "tab"..var, function()
                changeTab(var)
            end)
        end
        CSResourceMgr.getNodeByName(resName, "tab2"):setVisible(false)
    end

    local function loadB()
        CSResourceMgr.playAllFrameWithCallback(resName, 1, function()
            changeTab(curTab)
        end, "", 0.1)
    end
    --    loadA()
    --    loadB()
    local funcTable = {loadA, loadB}
    UnblockLoader.load(funcTable, tag)
end


function LtRankingViewMgr.hide()
    UIStack.pop("LtRankingViewMgr")

    UnblockLoader.cancel(tag)
    local list
    if list then
        list:removeAllItems()
    end
    for i=1,LtRankingViewMgr.TAB_NUM do
        CSResourceMgr.removeCSObjectByTag(resNameTab[i],"LtRankingTab"..i)
    end
    CSResourceMgr.removeCSObjectByTag(resName)
end


return LtRankingViewMgr