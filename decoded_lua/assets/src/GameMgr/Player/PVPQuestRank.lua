local PVPQuestRank = {}

local resName = ""
local resNameBG = ""

local PVPArenaRankAwardConfig = nil

function PVPQuestRank.Init()
    resName = "Player/ArenaPK/PPVQuestRank.csb"
    resNameBG = "Pet/Formation/FormationBGNew.csb"

    if PVPArenaRankAwardConfig == nil then
        PVPArenaRankAwardConfig = require("src.DatReader.PVPArenaRankAwardConfig")
        PVPArenaRankAwardConfig.init()
    end
end

function PVPQuestRank.initUIData()

    CSResourceMgr.setLabelString(resName, "title", "arenapk1", nil, {r=26,g=37,b=48,a=255,w=1})
    local title = CSResourceMgr.getNodeByName(resName,"title")
    CSResourceMgr.setLabelColorByNode(title,  {r=144,g=238,b=255,a=255})

    local awards = CSResourceMgr.getNodeByName(resName, "btn_rewardInfo")
    CSResourceMgr.setButtonStringByNode(awards, LuaSqlite.getLanguageByKey("arena52"), nil, {r=0,g=0,b=0,a=255,w=1})

    local labelTitle = CSResourceMgr.getNodeByName(resName, "title1")
    CSResourceMgr.setLabelStringByNode(labelTitle, "arena28", {r=221,g=82,b=26,a=255,w=2}, nil, 240)

    local des2 = CSResourceMgr.getNodeByName(resName, "des2")
    CSResourceMgr.setLabelStringByNode(des2, "pvptasktips15")

    local des3 = CSResourceMgr.getNodeByName(resName, "des3")
    CSResourceMgr.setLabelStringByNode(des3, CocosModuleMgr.createStringWithFormat({"arenapk3", CharInfo.get().pvparenapoint}))
    
    local des201 = CSResourceMgr.getNodeByName(resName, "des201")
    des201:setVisible(false)
    CSResourceMgr.setLabelStringByNode(des201, "pvptasktips17")

    local diff = CocosModuleMgr.getScreenSizeDiff()
    if diff < 0 then
        local list = CSResourceMgr.getNodeByName(resName,"list")
        local lsize = list:getContentSize()
        list:setContentSize(lsize.width, lsize.height+diff*2.66)
    end

end

function PVPQuestRank.refreshMyInfo()

    local rank = 0

    local awardValue = PVPArenaRankAwardConfig.readEntryByID(PVPArenaRankAwardConfig.getEntryCount())
    if ArenaInfo.getMyPVPArenaRank() <= awardValue.rankRange[2] and CharInfo.get().pvparenapoint >= SystemInfo.getGlobalConfigAddInfoByID(62002).values[1] then
        rank = ArenaInfo.getMyPVPArenaRank()
    end

    local panel1     = CSResourceMgr.getNodeByName(resName, "panel_1", tag)
    local labelName  = CSResourceMgr.seekNodeByName(panel1, "char_name")
    local labelVip   = CSResourceMgr.seekNodeByName(panel1, "vip_level")
    local labelLv    = CSResourceMgr.seekNodeByName(panel1, "char_level")
    local labelTitle = CSResourceMgr.seekNodeByName(panel1, "rank_title")
    local labelRank  = CSResourceMgr.seekNodeByName(panel1, "rank_num")
    local spriteIcon = CSResourceMgr.seekNodeByName(panel1, "char_icon")
    
    local viplevel = CharInfo.getVipInfoByID(CharInfo.getVIPLevel()).viplevel
    CSResourceMgr.seekNodeByName(panel1,"vip_title"):setVisible(viplevel > 0)
    labelVip:setVisible(viplevel > 0)

    CSResourceMgr.setLabelStringByNode(labelName, CharInfo.getNickName(), {r=0,g=0,b=0,a=255,w=1,s=2}, nil, 161)
    CSResourceMgr.setLabelStringByNode(labelVip, viplevel, {r=0,g=0,b=0,a=255,w=1,s=2})
    CSResourceMgr.setLabelStringByNode(labelLv, "Lv."..CharInfo.getLevel(), {r=0,g=0,b=0,a=255,w=1,s=2})
    CSResourceMgr.setLabelStringByNode(labelTitle, "arena7", {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 160)
    CSResourceMgr.setLabelStringByNode(labelRank, rank, {r=0,g=0,b=0,a=255}, nil, 138)

    CSResourceMgr.setLabelColorByNode(labelName,  {r=255,g=252,b=0,a=255})
    CSResourceMgr.setLabelColorByNode(labelVip,   {r=255,g=252,b=0,a=255})
    CSResourceMgr.setLabelColorByNode(labelTitle, {r=166,g=243,b=255,a=255})

    CSResourceMgr.setSpriteTextureByNode(spriteIcon, CharInfo.getHeadIcon(CharInfo.getCurfashion()))
    spriteIcon:setScale(1.5)
    spriteIcon:setPositionY(70)

    if rank == 0 then
        CSResourceMgr.setLabelStringByNode(labelRank, "LtText21", nil, nil, 136)
    end
end

function PVPQuestRank.hideUI()
    UnblockLoader.cancel("PVPQuestRank")
    CSResourceMgr.removeCSObjectByTag(resName)
    CSResourceMgr.removeCSObjectByTag(resNameBG, "PVPQuestRank")
    UIStack.pop("PVPQuestRank")
end

function PVPQuestRank.show(scene)
    if CSResourceMgr.getCsbObj(resName) then
        return  
    end
    UIStack.push("PVPQuestRank",PVPQuestRank.hideUI,true)
    local function loadBG()
        local bgLayer = CSResourceMgr.createRes(scene, resNameBG, "PVPQuestRank")
        bgLayer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resNameBG, 320, 480, "PVPQuestRank")
    end
    
    local function loadCSB()

        local curLayer = CSResourceMgr.createRes(scene, resName)
        curLayer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setFullScreen(resName)
        
        CSResourceMgr.clickEventBinding(resName, "close", function()
            PVPQuestRank.hideUI()
        end)

        CSResourceMgr.clickEventBinding(resName, "btn_rewardInfo", function()
            local t = {}
            local totalRank = 0
            for i=1, PVPArenaRankAwardConfig.getEntryCount() do
                local value = PVPArenaRankAwardConfig.readEntryByID(i)
                t[i] = {id = value.rankRange[1], awardItems = {}}
                totalRank = value.rankRange[2]
                for j=1,#value.rewardElement/2 do
                    t[i].awardItems[j] = {
                        elementID = value.rewardElement[j*2-1],
                        count     = value.rewardElement[j*2],
                    }
                end
            end
            LtRankAwardList.show(SceneMgr.getRunningScene, t, 1, totalRank)
        end)
        
        PVPQuestRank.initUIData()

    end
    
    loadBG()
    loadCSB()

    PVPQuestRank.getMyRankInfo()
    
    PVPQuestRank.getRankInfo()

end

function PVPQuestRank.getMyRankInfo()

    NetInterface.sendWithBlock("GC_GETMYPVPARENARANK_ACK", function()
        local PVPSend = require("src.Net.Send.PVPSend")
        PVPSend.sendCG_GetMyPVPArenaRank_Req()
    end, function()
        PVPQuestRank.refreshMyInfo()
    end, function(code)
        TipsMgr.showError(scene, code)
    end)
    
end

function PVPQuestRank.getRankInfo()

    NetInterface.sendWithBlock("GC_GETPVPARENARANK_ACK", function()
        local PVPSend = require("src.Net.Send.PVPSend")
        PVPSend.sendCG_GetPVPArenaRank_Req(1,11)
    end, function()
        PVPQuestRank.createList()
    end, function(code)
        TipsMgr.showError(scene, code)
    end)
    
end

function PVPQuestRank.createRankingItemNew(playerInfo, type)
    local sample = CSResourceMgr.createRes(nil,"LostTower/Menu/RankingItemA1.csb")
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
    fc:setPositionX(fc:getPositionX()-14)
    fc:setAnchorPoint(0.5, 0.5)
    local familyNode = CSResourceMgr.seekNodeByName(node, "family")
    
    CSResourceMgr.seekNodeByName(node,"bg13"):setVisible(playerInfo.vipLevel > 1)
    vip:setVisible(playerInfo.vipLevel > 1)

    playerIcon:setScale(1.0)
    CSResourceMgr.setSpriteTextureByNode(playerIcon, playerInfo.charIcon)

    local icon = CSResourceMgr.seekNodeByName(node, "bg15")
    icon:setVisible(false)

    if rankNum <= 3 then
        rankLab:setVisible(false)
        CSResourceMgr.setSpriteTextureByNode(rankTex, ArenaViewMgr.PlayerRankNumTex[rankNum])
    else
        rankTex:setVisible(false)
        CSResourceMgr.setLabelStringByNode(rankLab, rankNum, {r=0,g=0,b=0,a=255,w=1,s=2})
        CSResourceMgr.setLabelColorByNode(rankLab, {r=166,g=243,b=255,a=255})
    end

    if rankNum > 3 then rankNum = 4 end
    CSResourceMgr.setSpriteTextureByNode(diban, ArenaViewMgr.PlayerRankBackgroudTex[rankNum])
    bg11:setColor(ArenaViewMgr.BGTexColor1[rankNum])
    bg21:setColor(ArenaViewMgr.BGTexColor2[rankNum])
    bg14:setColor(ArenaViewMgr.BGTexColor3[rankNum])
    fmbg:setColor(ArenaViewMgr.BGTexColor2[rankNum])
    
    local vipLv = CharInfo.getVipInfoByID(playerInfo.vipLevel).viplevel
    CSResourceMgr.setLabelStringByNode(vip, vipLv, {r=0,g=0,b=0,a=255,w=1,s=1})
    CSResourceMgr.setLabelStringByNode(playerLv, "Lv."..playerInfo.level)
    CSResourceMgr.setLabelStringByNode(playerName, playerInfo.name, {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 198)
    CSResourceMgr.setLabelStringByNode(fc, playerInfo.fightPoint, {r=0,g=0,b=0,a=255,w=1,s=1}, nil, 112)

    CSResourceMgr.setLabelColorByNode(vip, {r=255,g=252,b=0,a=255})
    CSResourceMgr.setLabelColorByNode(playerLv, ArenaViewMgr.PlayerLvColor[rankNum])

    if faimly then

    else
        familyNode:setVisible(false)
    end
    
    return node
end

function PVPQuestRank.createList()

    if CSResourceMgr.getCsbObj(resName) then
        local list = CSResourceMgr.getNodeByName(resName,"list")
        list:removeAllItems()
        
        local funcTable = {}
        UnblockLoader.cancel("PVPQuestRank")

        local rankList = ArenaInfo.getPVPArenaRank()
        for i=1, #rankList do
            local info = rankList[i]
            table.insert(funcTable,function()
                local component = PVPQuestRank.createRankingItemNew({
                    name = info.nickname,
                    level = info.Level,
                    vipLevel = info.vipLevel,
                    fightPoint = info.pvpArenaPoint,
                    rank = i,
                    charIcon = ItemInfo.getFashionItemInfoById(info.fashion.curFashion[1]).filePath,
                }, 1)
                component:setVisible(true)
                component:setScaleY(0)
                list:pushBackCustomItem(component)
                transition.scaleTo(component,{scale=1.0,time = 0.1})
            end)
        end
        if #rankList == 0 then
            local des201 = CSResourceMgr.getNodeByName(resName, "des201")
            des201:setVisible(true)
        end
        UnblockLoader.load(funcTable,"PVPQuestRank")
    end

end

return PVPQuestRank