local FriendsViewMgr = {}

local resName = {}
local resNameA = {}
local resNameB = {}
local resNameC = {}
local resNameBG = {}
local allFriendTable = {}
local applyPlayerTable = {}
local editbox = nil
local searchPlayerId = ""
local todayZanCount = 0
local friendMaxNum = 0
local friendPointMaxNum = 0
local mChatFriendTable = {}
local curTab = 1
local tabALoad = false
local tabBLoad = false
local tabCLoad = false
local friendPoint = 0
local redHeartShopInfo = {}
local addTableIndex = {}
local friendObjTable = {}
local curFriendInfo = {}
local isRefresh = false
local searchPlayer = {}
local isGetingInfo = false
local getinfoCallback = nil
local allFriendNum = 0

function FriendsViewMgr.Init()
    resName = "Player/Friends/FriendsListView.csb"
    resNameA = "Player/Friends/FriendsApplyListView.csb"
    resNameB = "Player/Friends/lookFriendInfoWindow.csb"
    resNameC = "Player/Friends/SearchFriendView.csb"
    resNameBG = "Pet/Formation/FormationBGNew.csb"
    allFriendTable = {}
    applyPlayerTable = {}
    editbox = nil
    searchPlayerId = ""
    todayZanCount = 0
    friendMaxNum = 0
    friendPointMaxNum = 0
    mChatFriendTable = {}
    curTab = 1
    tabALoad = false
    tabBLoad = false
    tabCLoad = false
    friendPoint = 0
    redHeartShopInfo = {}
    friendObjTable = {}
    curFriendInfo = {}
    isRefresh = false
    searchPlayer = {}
    allFriendNum = 0
end


function FriendsViewMgr.show(scene)
    UIStack.push("FriendsViewMgr",FriendsViewMgr.hide,true)
    allFriendTable = {}
    applyPlayerTable = {}
    tabALoad = false
    tabBLoad = false
    tabCLoad = false
    curTab = 1
    local function loadBG()
        local bgLayer = CSResourceMgr.createRes(scene, resNameBG)
        bgLayer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resNameBG, 320, 480)
        bgLayer:setOpacity(0)
        transition.fadeIn(bgLayer, {time=0.3})
    end
    local function loadCSB()
        local curLayer = CSResourceMgr.createRes(scene, resName)
        curLayer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resName, 320, 480)
        curLayer:setVisible(false)

        --...
        local diff = CocosModuleMgr.getScreenSizeDiff()
        local frame = CSResourceMgr.getNodeByName(resName, "frame")
        local fsize = frame:getContentSize()
        frame:setContentSize(fsize.width, fsize.height+diff)
        local title = CSResourceMgr.getNodeByName(resName, "title")
        local tposy = title:getPositionY()
        title:setPositionY(tposy+diff)     
        local playerMax = CSResourceMgr.getNodeByName(resName, "playerMax")
        local pposy = playerMax:getPositionY()
        playerMax:setPositionY(pposy+diff)   
        local list = CSResourceMgr.getNodeByName(resName,"friendList")
        local lsize = list:getContentSize()
        list:setContentSize(lsize.width, lsize.height+diff)
        local list2 = CSResourceMgr.getNodeByName(resName,"shopList")
        local l2size = list2:getContentSize()
        list2:setContentSize(l2size.width, l2size.height+diff)
        local list3 = CSResourceMgr.getNodeByName(resName,"hytjList")
        local l3size = list3:getContentSize()
        list3:setContentSize(l3size.width, l3size.height+diff)
        local back2 = CSResourceMgr.getNodeByName(resName,"back2")
        local b2size = back2:getContentSize()
        back2:setContentSize(b2size.width, b2size.height+diff)
        local node = CSResourceMgr.getNodeByName(resName,"node")
        local nposy = node:getPositionY()
        node:setPositionY(nposy+(diff/2<0 and 0 or diff/2)) 
        local tab1 = CSResourceMgr.getNodeByName(resName,"tab1")
        local t1posy = tab1:getPositionY()
        tab1:setPositionY(t1posy+diff) 
        local tab2 = CSResourceMgr.getNodeByName(resName,"tab2")
        local t2posy = tab2:getPositionY()
        tab2:setPositionY(t2posy+diff) 
        local friendValueMax = CSResourceMgr.getNodeByName(resName,"friendValueMax")
        local frposy = friendValueMax:getPositionY()
        friendValueMax:setPositionY(frposy+diff) 
        local line1 = CSResourceMgr.getNodeByName(resName,"line1")
        local lineposy = line1:getPositionY()
        line1:setPositionY(lineposy+diff) 
        local back1 = CSResourceMgr.getNodeByName(resName,"back1")
        local bposy = back1:getPositionY()
        back1:setPositionY(bposy+diff) 

        friendMaxNum = SystemInfo.getGlobalConfigAddInfoByID(42).values[1]
        friendPointMaxNum = SystemInfo.getGlobalConfigAddInfoByID(54).values[1]
        friendPoint = CharInfo.get()["friendpoints"] or 0

        local title = CSResourceMgr.getNodeByName(resName,"title")
        CSResourceMgr.setLabelColorByNode(title, {r=160,g=235,b=250,a=255})
        CSResourceMgr.setLabelStringByNode(title, "friendList0", {r=37,g=54,b=75,a=255})
        local applyBtn = CSResourceMgr.getNodeByName(resName,"applyBtn")
        CSResourceMgr.setButtonStringByNode(applyBtn, "friendList1", {r=0,g=0,b=0,a=255})
        CSResourceMgr.setButtonStringColorByNode(applyBtn, {r=227,g=233,b=255,a=255})
        local searchBtn = CSResourceMgr.getNodeByName(resName,"searchBtn")
        CSResourceMgr.setButtonStringByNode(searchBtn, "friendList2", {r=0,g=0,b=0,a=255} )
        CSResourceMgr.setButtonStringColorByNode(searchBtn, {r=227,g=233,b=255,a=255})
        local maxLabel = CSResourceMgr.getNodeByName(resName,"maxLabel")
        CSResourceMgr.setLabelColorByNode(maxLabel, {r=144,g=238,b=255,a=255})
        CSResourceMgr.setLabelStringByNode(maxLabel, "friendList3", {r=12,g=27,b=38,a=255})
        maxLabel:enableOutline({r=12,g=27,b=38,a=255}, 1)
        local curNum = CSResourceMgr.getNodeByName(resName,"curNum")
        CSResourceMgr.setLabelColorByNode(curNum, {r=255,g=255,b=255,a=255})
        CSResourceMgr.setLabelStringByNode(curNum, #allFriendTable.."/"..friendMaxNum, {r=0,g=0,b=0,a=255})
        curNum:enableOutline({r=0,g=0,b=0,a=255}, 1)
        friendValueMax:setVisible(true)
        local friendValue = CSResourceMgr.getNodeByName(resName,"friendValue")
        CSResourceMgr.setLabelColorByNode(friendValue, {r=255,g=255,b=255,a=255})
        CSResourceMgr.setLabelStringByNode(friendValue, friendPoint.."/"..friendPointMaxNum, {r=0,g=0,b=0,a=255,w=1})

        CSResourceMgr.clickEventBinding(resName, "applyBtn", function()
            FriendsViewMgr.setApplyRedPoint(false)
            FriendsViewMgr.showApplyView()
        end)
        
        CSResourceMgr.clickEventBinding(resName, "searchBtn", function()
            FriendsViewMgr.showSearchView()
        end)

        NetInterface.sendWithBlock("GC_GetCharacterValues_Ack", function()
            local LoginSend = require("src.Net.Send.LoginSend")
            LoginSend.sendCG_GetCharacterValues_Req({"lastRedHeartTime","todayRedHeartCount"})
            end,function()
                local lastRedHeartTime = CharInfo.get()["lastredhearttime"] or 0
                local todayRedHeartCount = CharInfo.get()["todayredheartcount"] or 0
                todayZanCount = FriendsViewMgr.isToday(lastRedHeartTime) and todayRedHeartCount or 0
            end)
        
        local selColor = {r=255,g=255,b=255,a=255}
        local selOutColor = {r=209,g=138,b=0,a=255}
        local unselColor = {r=82,g=82,b=82,a=255}
        local unselOutColor = {r=236,g=236,b=236,a=0}
        local listNameList = {"friendList","shopList","hytjList"}
        local tabName = {"friendList19", "friendList20","friendList23"}
        for var=1, 3 do
            CSResourceMgr.clickEventBinding(resName, "tab"..var, function()
                GameAudio.playUISound("sheetClick")
                CSResourceMgr.setButtonEnabled(resName, "tab"..curTab, true)
                CSResourceMgr.getNodeByName(resName, listNameList[curTab]):setVisible(false)
                CSResourceMgr.setButtonStringColor(resName, "tab"..curTab, unselColor)
                CSResourceMgr.setButtonString(resName, "tab"..curTab, tabName[curTab],"",unselOutColor)
                local tabbtn = CSResourceMgr.getNodeByName(resName, "tab"..curTab)
                tabbtn:setPositionY(821+diff)
                tabbtn:setScale(1, 1)
                tabbtn:setLocalZOrder(1)
                curTab = var
                CSResourceMgr.setButtonEnabled(resName, "tab"..curTab, false)
                CSResourceMgr.getNodeByName(resName, listNameList[curTab]):setVisible(true)
                CSResourceMgr.setButtonStringColor(resName, "tab"..curTab, selColor)
                CSResourceMgr.setButtonString(resName, "tab"..curTab, tabName[curTab],"",selOutColor)
                local curtabbtn = CSResourceMgr.getNodeByName(resName, "tab"..curTab)
                curtabbtn:setPositionY(826+diff)
                curtabbtn:setScale(1.1, 1.1)
                curtabbtn:setLocalZOrder(2)
                if var == 1 and not tabALoad then
                    NetInterface.sendWithBlock("GC_GetMyFriends_Ack", function()
                        local ChatUserSend = require("src.Net.Send.ChatUserSend")
                        ChatUserSend.sendCG_GetMyFriends_Req()
                        end)
                    tabALoad = true
                end
                if var == 2 and not tabBLoad then
                    NetInterface.sendWithBlock("GC_GetMyRedHeartShopInfo_Ack", function()
                        local NewShopSend = require("src.Net.Send.NewShopSend")
                        NewShopSend.sendCG_GetMyRedHeartShopInfo_Req()
                        end)
                    NetInterface.sendWithBlock("GC_GetRedHeartShopInfo_Ack", function()
                        local NewShopSend = require("src.Net.Send.NewShopSend")
                        NewShopSend.sendCG_GetRedHeartShopInfo_Req()
                        end)
                end
                if var == 3 and not tabCLoad then
                    NetInterface.sendWithBlock("GC_GetRecommendFriend_Ack", function()
                        local ChatUserSend = require("src.Net.Send.ChatUserSend")
                        ChatUserSend.sendCG_GetRecommendFriend_Req()
                        end,function()
                            isRefresh = true
                        end)
                    tabCLoad = true
                end
                CSResourceMgr.getNodeByName(resName,"applyBtn"):setVisible(var == 1)
                CSResourceMgr.getNodeByName(resName,"searchBtn"):setVisible(var == 1)
                CSResourceMgr.getNodeByName(resName,"refreshBtn"):setVisible(var == 3)
                CSResourceMgr.getNodeByName(resName,"addAllBtn"):setVisible(var == 3)
            end)
            CSResourceMgr.setButtonStringColor(resName, "tab"..var, unselColor)
            CSResourceMgr.setButtonString(resName, "tab"..var, tabName[var],"",unselOutColor)
            local tabbtn = CSResourceMgr.getNodeByName(resName, "tab"..var)
            tabbtn:setPositionY(821+diff)
            tabbtn:setScale(1, 1)
            tabbtn:setLocalZOrder(1)
        end
        CSResourceMgr.setButtonStringColor(resName, "tab"..curTab, selColor)
        CSResourceMgr.setButtonString(resName, "tab"..curTab, tabName[curTab],"",selOutColor)
        CSResourceMgr.setButtonEnabled(resName, "tab"..curTab, false)
        CSResourceMgr.getNodeByName(resName, listNameList[curTab]):setVisible(true)
        local curtabbtn = CSResourceMgr.getNodeByName(resName, "tab"..curTab)
        curtabbtn:setPositionY(826+diff)
        curtabbtn:setScale(1.1, 1.1)
        curtabbtn:setLocalZOrder(2)  
        if curTab == 1 and not tabALoad then
            NetInterface.sendWithBlock("GC_GetMyFriends_Ack", function()
                local ChatUserSend = require("src.Net.Send.ChatUserSend")
                ChatUserSend.sendCG_GetMyFriends_Req()
                end)
            tabALoad = true
        end        
        if curTab == 2 and not tabBLoad then
            NetInterface.sendWithBlock("GC_GetMyRedHeartShopInfo_Ack", function()
                local NewShopSend = require("src.Net.Send.NewShopSend")
                NewShopSend.sendCG_GetMyRedHeartShopInfo_Req()
                end)
            NetInterface.sendWithBlock("GC_GetRedHeartShopInfo_Ack", function()
                local NewShopSend = require("src.Net.Send.NewShopSend")
                NewShopSend.sendCG_GetRedHeartShopInfo_Req()
                end)
        end   
        if curTab == 3 and not tabCLoad then
            NetInterface.sendWithBlock("GC_GetRecommendFriend_Ack", function()
                local ChatUserSend = require("src.Net.Send.ChatUserSend")
                ChatUserSend.sendCG_GetRecommendFriend_Req()
                end,function()
                    isRefresh = true
                end)
            tabCLoad = true
        end
        CSResourceMgr.getNodeByName(resName,"applyBtn"):setVisible(curTab == 1)
        CSResourceMgr.getNodeByName(resName,"searchBtn"):setVisible(curTab == 1)
        CSResourceMgr.getNodeByName(resName,"refreshBtn"):setVisible(curTab == 3)
        CSResourceMgr.getNodeByName(resName,"addAllBtn"):setVisible(curTab == 3)
    end
    
    local function playCSB()
        CSResourceMgr.getCsbObj(resName):setVisible(true)
        local node = CSResourceMgr.getNodeByName(resName,"frame")
        CocosModuleMgr.showUIAnimation(node,"up")
        StatusBarMgr.showTopInfoBar(function()
            FriendsViewMgr.hide()
        end)
    end

    local funcTable = {loadBG, loadCSB, playCSB}

    UnblockLoader.load(funcTable, "FriendsViewMgr.show")
end

function FriendsViewMgr.SetShop(goodsList)
    local funcTable = {}
    local curNum = CSResourceMgr.getNodeByName(resName,"curNum")
    CSResourceMgr.setLabelColorByNode(curNum, {r=255,g=255,b=255,a=255})
    CSResourceMgr.setLabelStringByNode(curNum, #allFriendTable.."/"..friendMaxNum, {r=0,g=0,b=0,a=255,w=1})
    local list = CSResourceMgr.getNodeByName(resName, "shopList")
    local panel = CSResourceMgr.getNodeByName(resName, "panel")
    local panelNodes = {}
    if list then
        list:removeAllItems()
    end
    local goodsNum = #goodsList
    for i=1,math.ceil(goodsNum / 3) do
        table.insert(funcTable,function()
            panelNodes[i] = panel:clone()
            panelNodes[i]:setVisible(true)
            local back = CSResourceMgr.seekNodeByName(panelNodes[i], "back")
            back:setColor(i%2==0 and  {r=3,g=23,b=49} or {r=43,g=65,b=98})
            list:pushBackCustomItem(panelNodes[i]) 
        end)
    end
    for index=1,#goodsList do
        table.insert(funcTable,function()
            local line = math.ceil(index / 3)
            local row = index % 3 == 0 and 3 or index % 3
            local petNode = CSResourceMgr.seekNodeByName(panelNodes[line],"b"..(index-3*(line-1)))
            local goods = goodsList[index]
            local itemInfo = ItemInfo.getItemInfoById(goods.id)
            local itemType = ItemInfo.getItemType(itemInfo.id)
            if itemType == 4 then
                local mask = CSResourceMgr.seekNodeByName(petNode, "mask")
                mask:setVisible(true)
                local petPieceInfo = ItemInfo.getPetPieceInfoById(itemInfo.id)
                local pokemonInfo = PokemonInfo.getPokemonInfoByID(PokemonInfo.getGeneInfoByID(petPieceInfo.pokeID).petID)
                local name = CSResourceMgr.seekNodeByName(petNode, "name")
                CSResourceMgr.setLabelColorByNode(name, {r=255,g=255,b=255,a=255})
                CSResourceMgr.setLabelStringByNode(name,pokemonInfo.name, {r=0,g=0,b=0,a=255,w=1})
                local itemIcon = CSResourceMgr.seekNodeByName(petNode, "itemIcon")
                CSResourceMgr.setSpriteTextureByNode(itemIcon, "Pet/PetIcon/"..pokemonInfo.icon..".png")
                itemIcon:setScale(0.85)
            else
                local name = CSResourceMgr.seekNodeByName(petNode, "name")
                CSResourceMgr.setLabelColorByNode(name, {r=255,g=255,b=255,a=255})
                CSResourceMgr.setLabelStringByNode(name,itemInfo.name, {r=0,g=0,b=0,a=255,w=1})
                local itemIcon = CSResourceMgr.seekNodeByName(petNode, "itemIcon")
                CSResourceMgr.setSpriteTextureByNode(itemIcon, itemInfo.icon)
            end
            local itemIconBack = CSResourceMgr.seekNodeByName(petNode, "itemIconBack")
            CSResourceMgr.setSpriteTextureByNode(itemIconBack, ItemInfo.getItemRareBGImage(goods.id))
            local itemNum = CSResourceMgr.seekNodeByName(petNode, "itemNum")
            CSResourceMgr.setLabelColorByNode(itemNum, {r=255,g=255,b=255,a=255})
            CSResourceMgr.setLabelStringByNode(itemNum,goods.num, {r=0,g=0,b=0,a=255,w=1})
            local haveEnoughRes = friendPoint >= goods.price
            local numColor = haveEnoughRes and {r=255,g=255,b=255,a=255} or  {r=255,g=0,b=0,a=255}
            local num = CSResourceMgr.seekNodeByName(petNode, "num")
            CSResourceMgr.setLabelColorByNode(num, numColor)
            CSResourceMgr.setLabelStringByNode(num,goods.price, {r=0,g=0,b=0,a=255})
            CSResourceMgr.seekNodeByName(petNode, "bb"):setColor({r=128,g=161,b=172,a=255})
            CSResourceMgr.seekNodeByName(petNode, "numBack"):setColor(line%2==0 and {r=35,g=56,b=87,a=255} or {r=2,g=16,b=28,a=255})

            CSResourceMgr.longtouchEventBindingByNode(petNode, function()
                ItemInfoViewMgr.show({id = goods.id, sum = goods.num,type = 1,objID = 0},false)
            end,function()
                if haveEnoughRes then
                    DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 2, "LtTips5", function()
                    NetInterface.sendWithBlock("GC_BuyRedHeartGoods_Ack",function()
                        local NewShopSend = require("src.Net.Send.NewShopSend")
                        NewShopSend.sendCG_BuyRedHeartGoods_Req({pos = index-1})
                    end, function()
                        GameAudio.playUISound("shopexchange")
                        StandardTipsMgr.show(0, "LtTips6")   -- "购买成功"
                        table.insert(redHeartShopInfo,index-1)
                        friendPoint = friendPoint - goods.price
                        CSResourceMgr.setLabelString(resName, "friendValue", friendPoint.."/"..friendPointMaxNum, "", {r=0,g=0,b=0,a=255,w=1})
                        FriendsViewMgr.SetShop(goodsList)
                    end, function(code)
                        print("failed to buy",code)
                    end)
                        end, function()--取消
                    end)
                else
                    StandardTipsMgr.show(1, "FriendShopTips1")
                end
            end)

            for k,v in pairs(redHeartShopInfo) do
                if v == index-1 then
                    CSResourceMgr.setButtonEnabledByNode(petNode, false)
                    local gray = CSResourceMgr.seekNodeByName(petNode,"gray")
                    gray:setVisible(true)
                    gray:setColor({r=0,g=0,b=0,a=255})
                    gray:setOpacity(153)
                end
            end
            petNode:setVisible(true)
            petNode:setScale(0, 0)
            transition.scaleTo(petNode, {scale=0.93, time=0.2})
        end)
    end
    UnblockLoader.load(funcTable,"FriendsViewMgr.SetShop")
end

function FriendsViewMgr.showFriendsList()
    UnblockLoader.cancel("FriendsViewMgr.showFriendsList")
    local funcTable = {}
    local list = CSResourceMgr.getNodeByName(resName,"friendList")
    CSResourceMgr.removeListByNode(list)
    local curNum = CSResourceMgr.getNodeByName(resName,"curNum")
    CSResourceMgr.setLabelColorByNode(curNum, {r=255,g=255,b=255,a=255})
    CSResourceMgr.setLabelStringByNode(curNum, #allFriendTable.."/"..friendMaxNum, {r=0,g=0,b=0,a=255,w=1})
    friendObjTable = {}
    curFriendInfo = {}

    local function setFriend(playerInfo)
        local friend = CSResourceMgr.getNodeByName(resName, "friend"):clone()
        friend:setVisible(true)
        friendObjTable[#friendObjTable+1] = friend 
        local playerName = CSResourceMgr.seekNodeByName(friend, "playerName")
        CSResourceMgr.setLabelColorByNode(playerName, {r=255,g=255,b=255,a=255})
        CSResourceMgr.setLabelStringByNode(playerName,playerInfo.name, {r=5,g=48,b=84,a=255})
        local level = CSResourceMgr.seekNodeByName(friend, "Lv")
        CSResourceMgr.setLabelColorByNode(level, {r=255,g=252,b=0,a=255})
        CSResourceMgr.setLabelStringByNode(level,"Lv"..playerInfo.level, {r=0,g=0,b=0,a=255})
        local likeNum = CSResourceMgr.seekNodeByName(friend, "likeNum")
        CSResourceMgr.setLabelColorByNode(likeNum, {r=255,g=255,b=255,a=255})
        CSResourceMgr.setLabelStringByNode(likeNum,playerInfo.friendPoint)
        local attackNum = CSResourceMgr.seekNodeByName(friend, "attackNum")
        CSResourceMgr.setLabelColorByNode(attackNum, {r=255,g=255,b=255,a=255})
        CSResourceMgr.setLabelStringByNode(attackNum,playerInfo.fightPoint)
        local lastTimeLabel = CSResourceMgr.seekNodeByName(friend, "lastTimeLabel")
        CSResourceMgr.setLabelColorByNode(lastTimeLabel, {r=71,g=96,b=103,a=255})
        CSResourceMgr.setLabelStringByNode(lastTimeLabel,LuaSqlite.getLanguageByKey("friendList4")..CocosModuleMgr.createStringWithFormat({"ArenaRecord6", 1}))
        lastTimeLabel:setVisible(false)
        local vipLevel = CSResourceMgr.seekNodeByName(friend, "vipLevel")
        CSResourceMgr.setLabelColorByNode(vipLevel, {r=255,g=252,b=0,a=255})
        CSResourceMgr.setLabelStringByNode(vipLevel,playerInfo.vipLevel-1,{r=0,g=0,b=0,a=255,w=1,s=1})
        if playerInfo.vipLevel-1 == 0 then
            CSResourceMgr.seekNodeByName(friend, "vipInfo"):setVisible(false)
        end
        local likeLabel = CSResourceMgr.seekNodeByName(friend, "likeLabel")
        CSResourceMgr.setLabelColorByNode(likeLabel, {r=255,g=255,b=255,a=255})
        CSResourceMgr.setLabelStringByNode(likeLabel,"friendList21",{r=0,g=0,b=0,a=255,w=1,s=1})
        if playerInfo.familyName and playerInfo.familyName~="" then
            local familyName = CSResourceMgr.seekNodeByName(friend, "familyName")
            CSResourceMgr.setLabelColorByNode(familyName, {r=255,g=255,b=255,a=255})
            CSResourceMgr.setLabelStringByNode(familyName,playerInfo.familyName,{r=0,g=0,b=0,a=255,w=1,s=1})
            CSResourceMgr.seekNodeByName(friend, "familyIcon"):loadTexture("Confraternity/icon_qizhi1_hz.png")
        else
            CSResourceMgr.seekNodeByName(friend, "familyBack"):setVisible(false)
        end
        if playerInfo.fashion then
            local headIcon = CSResourceMgr.seekNodeByName(friend, "headIcon")
            headIcon:loadTexture(CharInfo.getHeadIcon(playerInfo.fashion.curFashion))
            headIcon:setScale(1.7)
        end

        CSResourceMgr.clickEventBindingByNode(friend,function()
            FriendsViewMgr.setVisible(false)
            FriendsViewMgr.showFriendInfoWindow(playerInfo)
        end)

        local likeBtn = CSResourceMgr.seekNodeByName(friend, "likeBtn")
        local likeIcon = CSResourceMgr.seekNodeByName(friend, "likeIcon")
        local playerLastRedHeartTime = playerInfo.lastRedHeartTime or 0
        if FriendsViewMgr.isToday(playerLastRedHeartTime) then
            CSResourceMgr.setButtonEnabledByNode(likeBtn, false)
            CSResourceMgr.setSpriteTextureByNode(likeIcon, "UI/CommonFiles/icon_youhaodu_gray.png")
        else
            CSResourceMgr.setButtonEnabledByNode(likeBtn, true)
            CSResourceMgr.setSpriteTextureByNode(likeIcon, "UI/CommonFiles/icon_youhaodu.png")
            CSResourceMgr.clickEventBindingByNode(likeBtn,function()
                if todayZanCount < 10 then
                    NetInterface.sendWithBlock("GC_RedHeart_Ack", function()
                        local ChatUserSend = require("src.Net.Send.ChatUserSend")
                        ChatUserSend.sendCG_RedHeart_Req({friendID = playerInfo.friendID})
                        end,function()
                            StandardTipsMgr.show(0, "chat13")
                            todayZanCount = todayZanCount + 1
                            friendPoint = friendPoint + 10
                            CSResourceMgr.setLabelString(resName, "friendValue", friendPoint.."/"..friendPointMaxNum, "", {r=0,g=0,b=0,a=255,w=1})
                            CSResourceMgr.setLabelStringByNode(likeNum,tonumber(playerInfo.friendPoint)+10)
                            CSResourceMgr.setButtonEnabledByNode(likeBtn, false)
                            CSResourceMgr.setSpriteTextureByNode(likeIcon, "UI/CommonFiles/icon_youhaodu_gray.png")

                            local likeValue = CSResourceMgr.seekNodeByName(friend, "likeValue")
                            transition.scaleTo(likeValue, {scale=1, time=0.2})
                            likeValue:performWithDelay(function()
                                transition.scaleTo(likeValue, {scale=0.5, time=0.2})
                            end, 0.2)
                            playerInfo.lastRedHeartTime = CharInfo.getServerTime()
                        end,function(code)
                                if code == Proto.Error.ERROR_NOT_FRIEND then
                                    DialogBoxMgr.showSmallDialogBox(scene, 1, "friendList14")
                                elseif code == Proto.Error.ERROR_NOT_FRIEND_REDHEARTMAX then
                                    DialogBoxMgr.showSmallDialogBox(scene, 1, "friendList16")
                                end
                        end)
                else
                    DialogBoxMgr.showSmallDialogBox(scene, 1, "friendList15")
                end
            end)
        end
 
        CSResourceMgr.seekNodeByName(friend, "back"):setColor({r=67,g=85,b=100})
        CSResourceMgr.seekNodeByName(friend, "headBack"):setColor({r=128,g=161,b=172})
        CSResourceMgr.seekNodeByName(friend, "zanBack"):setColor({r=128,g=161,b=172})
        CSResourceMgr.seekNodeByName(friend, "likeBack"):setColor({r=71,g=96,b=103})
        CSResourceMgr.seekNodeByName(friend, "attackBack"):setColor({r=71,g=96,b=103})
        CSResourceMgr.seekNodeByName(friend, "familyBack"):setColor({r=185,g=200,b=205})
        list:pushBackCustomItem(friend)

        friend:setScaleY(0)
        transition.scaleTo(friend, {scale=1, time=0.2})
    end

    if #applyPlayerTable > 0 and not CSResourceMgr.getCsbObj(resNameA) then
        FriendsViewMgr.setApplyRedPoint(true)
    end

    for k,v in pairs(allFriendTable) do
        table.insert(funcTable,function()
            setFriend(v)
        end)
    end
    table.insert(funcTable,function()
        FriendsViewMgr.getFriendInfo(1)
        isGetingInfo = true
    end)

    UnblockLoader.load(funcTable, "FriendsViewMgr.showFriendsList")
end

function FriendsViewMgr.getFriendInfo(index)
    if not allFriendTable[index] or not friendObjTable[index] then
        return
    end
    NetInterface.send("GC_GetFriendDetail_Ack", function()
        local ChatUserSend = require("src.Net.Send.ChatUserSend")
        ChatUserSend.sendCG_GetFriendDetail_Req({friendID = allFriendTable[index].friendID})
        end,function()
            FriendsViewMgr.refreshFriendInfo(index,allFriendTable[index],friendObjTable[index])
        end)
end

function FriendsViewMgr.setFriendInfo(playerInfo)
    curFriendInfo = playerInfo
    curFriendInfo.friendID = curFriendInfo.charID
end

function FriendsViewMgr.refreshFriendInfo(index,playerInfo,friend)
    if not CSResourceMgr.getCsbObj(resName) then
        return
    end
    if not friend then
        return
    end
    for k,v in pairs(curFriendInfo) do
        print(k,v)
    end
    local userInfo = curFriendInfo
    local playerName = CSResourceMgr.seekNodeByName(friend, "playerName")
    CSResourceMgr.setLabelColorByNode(playerName, {r=255,g=255,b=255,a=255})
    CSResourceMgr.setLabelStringByNode(playerName,userInfo.nickname, {r=5,g=48,b=84,a=255})
    local level = CSResourceMgr.seekNodeByName(friend, "Lv")
    CSResourceMgr.setLabelColorByNode(level, {r=255,g=252,b=0,a=255})
    CSResourceMgr.setLabelStringByNode(level,"Lv"..userInfo.level, {r=0,g=0,b=0,a=255})
    local likeNum = CSResourceMgr.seekNodeByName(friend, "likeNum")
    CSResourceMgr.setLabelColorByNode(likeNum, {r=255,g=255,b=255,a=255})
    CSResourceMgr.setLabelStringByNode(likeNum,playerInfo.friendPoint)
    local attackNum = CSResourceMgr.seekNodeByName(friend, "attackNum")
    CSResourceMgr.setLabelColorByNode(attackNum, {r=255,g=255,b=255,a=255})
    CSResourceMgr.setLabelStringByNode(attackNum,userInfo.fightPoint)
    local lastTimeLabel = CSResourceMgr.seekNodeByName(friend, "lastTimeLabel")
    CSResourceMgr.setLabelColorByNode(lastTimeLabel, {r=71,g=96,b=103,a=255})
    CSResourceMgr.setLabelStringByNode(lastTimeLabel,LuaSqlite.getLanguageByKey("friendList4")..CocosModuleMgr.createStringWithFormat({"ArenaRecord6", 1}))
    local vipLevel = CSResourceMgr.seekNodeByName(friend, "vipLevel")
    CSResourceMgr.setLabelColorByNode(vipLevel, {r=255,g=252,b=0,a=255})
    CSResourceMgr.setLabelStringByNode(vipLevel,userInfo.vipLevel-1,{r=0,g=0,b=0,a=255,w=1,s=1})
    if userInfo.vipLevel-1 == 0 then
        CSResourceMgr.seekNodeByName(friend, "vipInfo"):setVisible(false)
    end
    local likeLabel = CSResourceMgr.seekNodeByName(friend, "likeLabel")
    CSResourceMgr.setLabelColorByNode(likeLabel, {r=255,g=255,b=255,a=255})
    CSResourceMgr.setLabelStringByNode(likeLabel,"friendList21",{r=0,g=0,b=0,a=255,w=1,s=1})
    if userInfo.familyName and userInfo.familyName~="" then
        local familyName = CSResourceMgr.seekNodeByName(friend, "familyName")
        CSResourceMgr.setLabelColorByNode(familyName, {r=255,g=255,b=255,a=255})
        CSResourceMgr.setLabelStringByNode(familyName,userInfo.familyName,{r=0,g=0,b=0,a=255,w=1,s=1})
        CSResourceMgr.seekNodeByName(friend, "familyIcon"):loadTexture("Confraternity/icon_qizhi1_hz.png")
    else
        CSResourceMgr.seekNodeByName(friend, "familyBack"):setVisible(false)
    end
    if userInfo.fashion then
        local headIcon = CSResourceMgr.seekNodeByName(friend, "headIcon")
        headIcon:loadTexture(CharInfo.getHeadIcon(userInfo.fashion.curFashion))
        headIcon:setScale(1.7)
    end

    CSResourceMgr.clickEventBindingByNode(friend,function()
        FriendsViewMgr.setVisible(false)
        FriendsViewMgr.showFriendInfoWindow(userInfo)
    end)

    local likeBtn = CSResourceMgr.seekNodeByName(friend, "likeBtn")
    local likeIcon = CSResourceMgr.seekNodeByName(friend, "likeIcon")
    local playerLastRedHeartTime = playerInfo.lastRedHeartTime or 0
    if FriendsViewMgr.isToday(playerLastRedHeartTime) then
        CSResourceMgr.setButtonEnabledByNode(likeBtn, false)
        CSResourceMgr.setSpriteTextureByNode(likeIcon, "UI/CommonFiles/icon_youhaodu_gray.png")
    else
        CSResourceMgr.setButtonEnabledByNode(likeBtn, true)
        CSResourceMgr.setSpriteTextureByNode(likeIcon, "UI/CommonFiles/icon_youhaodu.png")
        CSResourceMgr.clickEventBindingByNode(likeBtn,function()
            if todayZanCount < 10 then
                NetInterface.sendWithBlock("GC_RedHeart_Ack", function()
                    local ChatUserSend = require("src.Net.Send.ChatUserSend")
                    ChatUserSend.sendCG_RedHeart_Req({friendID = userInfo.friendID})
                    end,function()
                        StandardTipsMgr.show(0, "chat13")
                        todayZanCount = todayZanCount + 1
                        friendPoint = friendPoint + 10
                        CSResourceMgr.setLabelString(resName, "friendValue", friendPoint.."/"..friendPointMaxNum, "", {r=0,g=0,b=0,a=255,w=1})
                        CSResourceMgr.setLabelStringByNode(likeNum,tonumber(playerInfo.friendPoint)+10)
                        CSResourceMgr.setButtonEnabledByNode(likeBtn, false)
                        CSResourceMgr.setSpriteTextureByNode(likeIcon, "UI/CommonFiles/icon_youhaodu_gray.png")

                        local likeValue = CSResourceMgr.seekNodeByName(friend, "likeValue")
                        transition.scaleTo(likeValue, {scale=1, time=0.2})
                        likeValue:performWithDelay(function()
                            transition.scaleTo(likeValue, {scale=0.5, time=0.2})
                        end, 0.2)
                        playerInfo.lastRedHeartTime = CharInfo.getServerTime()
                    end,function(code)
                            if code == Proto.Error.ERROR_NOT_FRIEND then
                                DialogBoxMgr.showSmallDialogBox(scene, 1, "friendList14")
                            elseif code == Proto.Error.ERROR_NOT_FRIEND_REDHEARTMAX then
                                DialogBoxMgr.showSmallDialogBox(scene, 1, "friendList16")
                            end
                    end)
            else
                DialogBoxMgr.showSmallDialogBox(scene, 1, "friendList15")
            end
        end)
    end

    local detailTbl = {level=userInfo.level,vipLevel=userInfo.vipLevel,fightPoint=userInfo.fightPoint,fashion=userInfo.fashion,
                        familyID=(userInfo.familyID or 0),familyName=(userInfo.familyName or "")}
    local cjson = require("cjson")
    local detail = json.encode(detailTbl)
    NetInterface.send("GC_UpdateFriendDetail_Ack", function()
        local ChatUserSend = require("src.Net.Send.ChatUserSend")
        ChatUserSend.sendCG_UpdateFriendDetail_Req({friendID = userInfo.friendID,detail = detail})
        end,function()
            if allFriendTable[index + 1] then
                FriendsViewMgr.getFriendInfo(index+1)
            else
                isGetingInfo = false
                if getinfoCallback then
                    getinfoCallback()
                    getinfoCallback = nil
                end
            end
        end)
end

function FriendsViewMgr.showApplyView()
    local function loadCSB()
        local node = CSResourceMgr.getNodeByName(resName,"node")
        local curLayer = CSResourceMgr.createRes(node, resNameA)
        curLayer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        --...
        local function close()
            FriendsViewMgr.refreshFriendsList()
            local list = CSResourceMgr.getNodeByName(resNameA, "applyList")
            if list then
                list:removeAllItems()
            end
            UnblockLoader.cancel("FriendsViewMgr.showApplyView")
            UnblockLoader.cancel("FriendsViewMgr.setAllApplyPlayer")
            CSResourceMgr.removeCSObjectByTag(resNameA)
        end
        CSResourceMgr.clickEventBinding(resNameA, "close", function()
            close()
        end)
        local title = CSResourceMgr.getNodeByName(resNameA,"title")
        CSResourceMgr.setLabelColorByNode(title, {r=160,g=235,b=250,a=255})
        CSResourceMgr.setLabelStringByNode(title, "friendList1", {r=37,g=54,b=75,a=255})

        local rejectBtn = CSResourceMgr.getNodeByName(resNameA,"rejectBtn")
        CSResourceMgr.setButtonStringColorByNode(rejectBtn, {r=227,g=233,b=255,a=255})
        CSResourceMgr.setButtonStringByNode(rejectBtn, "friendList7", {r=0,g=0,b=0,a=255})

        CSResourceMgr.clickEventBindingByNode(rejectBtn, function()
            NetInterface.sendWithBlock("GC_DisbandAllFriendApply_Ack", function()
                local ChatUserSend = require("src.Net.Send.ChatUserSend")
                ChatUserSend.sendCG_DisbandAllFriendApply_Req()
                end,function()
                    close()
                    applyPlayerTable = {}
                    StandardTipsMgr.show(0, "friendList29")
                end)
        end)
    end
    
    local function playCSB()
        CSResourceMgr.playAction(resNameA, 0, 5, false)
        FriendsViewMgr.setAllApplyPlayer()
    end

    local funcTable = {loadCSB, playCSB}

    UnblockLoader.load(funcTable, "FriendsViewMgr.showApplyView")
end

function FriendsViewMgr.showFriendInfoWindow(playerInfo)
    local function loadCSB()
        local node = CSResourceMgr.getNodeByName(resName,"node")
        local infoWindow = CSResourceMgr.createRes(node, resNameB)
        node:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        local diff = CocosModuleMgr.getScreenSizeDiff()
        CSResourceMgr.setRelativePosition(resNameB, 0, 0)

        local title = CSResourceMgr.getNodeByName(resNameB,"title")
        CSResourceMgr.setLabelColorByNode(title, {r=160,g=235,b=250,a=255})
        CSResourceMgr.setLabelStringByNode(title,"friendList0" , {r=37,g=54,b=75,a=255})

        CSResourceMgr.clickEventBinding(resNameB,"close",function()
            FriendsViewMgr.setVisible(true)
            UnblockLoader.cancel("FriendsViewMgr.showFriendInfoWindow")
            CSResourceMgr.removeCSObjectByTag(resNameB)
        end)

        local buttonList = {}
        for i=1,6 do
            buttonList[i] = CSResourceMgr.getNodeByName(resNameB,"Button"..i)
            CSResourceMgr.setButtonStringColorByNode(buttonList[i], {r=227,g=233,b=255,a=255})
            CSResourceMgr.setButtonStringByNode(buttonList[i], "FriendInfo"..i, {r=0,g=0,b=0,a=255})
        end

        --查看好友按钮
        CSResourceMgr.clickEventBindingByNode(buttonList[1],function()
            if isGetingInfo then
                getinfoCallback = function()
                    PersonalCenterMgr.show(SceneMgr.getRunningScene,playerInfo.friendID)
                end
            else
                PersonalCenterMgr.show(SceneMgr.getRunningScene,playerInfo.friendID)
            end
        end)

        --好友切磋按钮
        CSResourceMgr.clickEventBindingByNode(buttonList[2],function()
            BattlePVPMgr.sendCG_StartPVP_Req(playerInfo.friendID)
            StandardTipsMgr.show(0, "chat12")
            FriendsViewMgr.setVisible(true)
            UnblockLoader.cancel("FriendsViewMgr.showFriendInfoWindow")
            CSResourceMgr.removeCSObjectByTag(resNameB)
        end)
        
        --邀请家园按钮
        CSResourceMgr.clickEventBindingByNode(buttonList[3],function()
            if HomeInfo.IsCurrentHomeGuestNumReachMax() then
                DialogBoxMgr.showSmallDialogBox(self, 1, "home005")
            else
                NetInterface.sendWithBlock("GC_Chat_Ack", function()
                    --HomeInfo.SetCurrentHomeCharID(CharInfo.getCharID())
                    HomeInfo.SendInviteEnterHome(playerInfo.friendID)
                    --print("---------playerInfo.friendID="..tostring(playerInfo.friendID))
                end,function()
                    StandardTipsMgr.show(0, "chat12")
                end)
            end
            FriendsViewMgr.setVisible(true)
            UnblockLoader.cancel("FriendsViewMgr.showFriendInfoWindow")
            CSResourceMgr.removeCSObjectByTag(resNameB)
        end)

        --邀请家族按钮
        if CharInfo.getFamilyID() then
            CSResourceMgr.clickEventBindingByNode(buttonList[4],function()
                if CharInfo.getFamilyID() == nil or FamilyInfo.GetLocalFamilyInfo() == nil then
                    StandardTipsMgr.show(1, "family10")
                elseif playerInfo.level < SystemInfo.getGlobalConfigAddInfoByID(24005).values[1] then
                    StandardTipsMgr.show(1, "family12")
                else
                    NetInterface.sendWithBlock("GC_Chat_Ack", function()
                        --HomeInfo.SetCurrentHomeCharID(CharInfo.getCharID())
                        FamilyInfo.SendInviteEnterFamily(playerInfo.friendID)
                        --print("---------playerInfo.friendID="..tostring(playerInfo.friendID))
                    end,function()
                        StandardTipsMgr.show(0, "chat12")
                    end)
                end
                FriendsViewMgr.setVisible(true)
                UnblockLoader.cancel("FriendsViewMgr.showFriendInfoWindow")
                CSResourceMgr.removeCSObjectByTag(resNameB)
            end)
        else
            CSResourceMgr.setButtonEnabledByNode(buttonList[4], false)
        end

        --私聊好友按钮
        CSResourceMgr.clickEventBindingByNode(buttonList[5],function()
            UnblockLoader.cancel("FriendsViewMgr.showFriendInfoWindow")
            CSResourceMgr.removeCSObjectByTag(resNameB)
            FriendsViewMgr.hide()
            if SceneMgr.currentScene~="TownScene" then
                if not CSResourceMgr.getCsbObj("UI/Chat/TownChatLayer.csb") then
                    TownChatMgr.addUIInMain()
                    TownChatMgr.changeStatus(1)
                    BasicMenuMgr.setChatBtnEnable(false)
                else
                    TownChatMgr.showChatView(true)
                end
            end
            TownChatMgr.setOneChat({name = playerInfo.nickname,id = playerInfo.friendID})
        end)

        --删除好友按钮
        CSResourceMgr.clickEventBindingByNode(buttonList[6],function()
            NetInterface.sendWithBlock("GC_DelFriend_Ack", function()
                local ChatUserSend = require("src.Net.Send.ChatUserSend")
                ChatUserSend.sendCG_DelFriend_Req({friendID = playerInfo.friendID})
                end,function()
                    GameAudio.playUISound("friendDelete")
                    for k,v in pairs(allFriendTable) do
                        if v.friendID == playerInfo.friendID then
                            table.remove(allFriendTable,k)
                        end
                    end
                    FriendsViewMgr.refreshFriendsList()
                end)
            FriendsViewMgr.setVisible(true)
            UnblockLoader.cancel("FriendsViewMgr.showFriendInfoWindow")
            CSResourceMgr.removeCSObjectByTag(resNameB)
        end)
    end
    local function playCSB()
        CSResourceMgr.playAction(resNameB, 0, 5, false)
    end
    
    local funcTable = {loadCSB, playCSB}
    UnblockLoader.load(funcTable, "FriendsViewMgr.showFriendInfoWindow")
end

function FriendsViewMgr.setAllApplyPlayer()
    local funcTable = {}
    local list = CSResourceMgr.getNodeByName(resNameA, "applyList")
    local function setApplyPlayer(playerInfo)
        local player = CSResourceMgr.getNodeByName(resNameA, "applyPlayer"):clone()
        player:setVisible(true)
        local playerName = CSResourceMgr.seekNodeByName(player, "playerName")
        CSResourceMgr.setLabelColorByNode(playerName, {r=255,g=255,b=255,a=255})
        CSResourceMgr.setLabelStringByNode(playerName,playerInfo.name, {r=5,g=48,b=84,a=255})
        playerName:enableOutline({r=5,g=48,b=84,a=255}, 1)
        local back = CSResourceMgr.seekNodeByName(player, "back")
        back:setColor({r=148,g=169,b=175})
        local back2 = CSResourceMgr.seekNodeByName(player, "back2")
        back2:setColor({r=88,g=105,b=110})
        local level = CSResourceMgr.seekNodeByName(player, "level")
        CSResourceMgr.setLabelColorByNode(level, {r=255,g=252,b=0,a=255})
        CSResourceMgr.setLabelStringByNode(level,"lv"..playerInfo.level, {r=5,g=48,b=84,a=255})
        local falseBtn = CSResourceMgr.seekNodeByName(player,"falseBtn")
        CSResourceMgr.setButtonStringByNode(falseBtn, "friendList5", {r=62,g=77,b=27,a=255})
        CSResourceMgr.setButtonStringColorByNode(falseBtn, {r=255,g=255,b=255,a=255})
        falseBtn:getTitleRenderer():enableOutline({r=62,g=77,b=27,a=255}, 1)
        local trueBtn = CSResourceMgr.seekNodeByName(player,"trueBtn")
        CSResourceMgr.setButtonStringByNode(trueBtn, "friendList6", {r=77,g=35,b=27,a=255})
        CSResourceMgr.setButtonStringColorByNode(trueBtn, {r=255,g=255,b=255,a=255})
        trueBtn:getTitleRenderer():enableOutline({r=77,g=35,b=27,a=255}, 1)
        if playerInfo.fashion then
            local headIcon = CSResourceMgr.seekNodeByName(player, "headIcon")
            headIcon:loadTexture(CharInfo.getHeadIcon(playerInfo.fashion.curFashion))
            headIcon:setScale(1.2)
        end

        CSResourceMgr.clickEventBindingByNode(trueBtn, function()
            if FriendsViewMgr.getFriendNum()>=friendMaxNum then
                StandardTipsMgr.show(1, "friendList27")
            else
                NetInterface.sendWithBlock("GC_ConfirmAddFriend_Ack", function()
                    local ChatUserSend = require("src.Net.Send.ChatUserSend")
                    ChatUserSend.sendCG_ConfirmAddFriend_Req({friendID = playerInfo.friendID,isConfirm = 1})
                    end,function()
                        GameAudio.playUISound("friendAccecpt")
                        for k,v in pairs(applyPlayerTable) do
                            if v.friendID == playerInfo.friendID then
                                table.remove(applyPlayerTable,k)
                                break
                            end
                        end
                        if not FriendsViewMgr.isHaveFriend(playerInfo) then
                            table.insert(allFriendTable,playerInfo)
                            local curNum = CSResourceMgr.getNodeByName(resName,"curNum")
                            CSResourceMgr.setLabelStringByNode(curNum, #allFriendTable.."/"..friendMaxNum, {r=0,g=0,b=0,a=255,w=1})
                        end
                        FriendsViewMgr.refreshAllApplyPlayer()
                    end,function(code)
                        if (Proto.Error.ERROR_FRIENDOVER == code) then
                            StandardTipsMgr.show(1, "friendList28")
                            for k,v in pairs(applyPlayerTable) do
                                if v.friendID == playerInfo.friendID then
                                    table.remove(applyPlayerTable,k)
                                    break
                                end
                            end
                            FriendsViewMgr.refreshAllApplyPlayer()
                        end
                    end)
            end
        end)

        CSResourceMgr.clickEventBindingByNode(falseBtn, function()
            NetInterface.sendWithBlock("GC_ConfirmAddFriend_Ack", function()
                local ChatUserSend = require("src.Net.Send.ChatUserSend")
                ChatUserSend.sendCG_ConfirmAddFriend_Req({friendID = playerInfo.friendID,isConfirm = 0})
                end,function()
                    for k,v in pairs(applyPlayerTable) do
                        if v.friendID == playerInfo.friendID then
                            table.remove(applyPlayerTable,k)
                            break
                        end
                    end
                    FriendsViewMgr.refreshAllApplyPlayer()
                end)
        end)
        list:pushBackCustomItem(player)
        player:setScaleY(0)
        transition.scaleTo(player, {scale=1, time=0.2})
    end

    for k,v in pairs(applyPlayerTable) do
        table.insert(funcTable,function()
            setApplyPlayer(v)
        end)
    end

    UnblockLoader.load(funcTable, "FriendsViewMgr.setAllApplyPlayer")
end

function FriendsViewMgr.refreshAllApplyPlayer()
    local list = CSResourceMgr.getNodeByName(resNameA, "applyList")
    if list then
        list:removeAllItems()
    end
    FriendsViewMgr.setAllApplyPlayer()
end

function FriendsViewMgr.refreshFriendsList()
    local list = CSResourceMgr.getNodeByName(resName, "friendList")
    if list then
        list:removeAllItems()
    end
    FriendsViewMgr.showFriendsList()
end

function FriendsViewMgr.hide()
    UIStack.pop("FriendsViewMgr")
    StatusBarMgr.hideTopInfoBar()
    UnblockLoader.cancel("FriendsViewMgr.show")
    UnblockLoader.cancel("FriendsViewMgr.showFriendsList")
    UnblockLoader.cancel("FriendsViewMgr.SetShop")
    UnblockLoader.cancel("FriendsViewMgr.setRecommendFriend")

    local list = CSResourceMgr.getNodeByName(resName,"friendList")
    if list then
        list:removeAllItems()
    end
    mChatFriendTable = allFriendTable
    TownChatMgr.setAllFriendTable(mChatFriendTable)
    applyPlayerTable = {}
    redHeartShopInfo = {}
    friendObjTable = {}
    searchPlayer = {}
    tabALoad = false
    tabBLoad = false
    tabCLoad = false
    curTab = 1
    isRefresh = false
    isGetingInfo = false
    getinfoCallback = nil
    allFriendNum = 0
    
    GameGuideMgr.checkProcess()
    
    CSResourceMgr.removeCSObjectByTag(resName)
    CSResourceMgr.removeCSObjectByTag(resNameBG)
    GameAudio.playUISound("retract")
end

function FriendsViewMgr.getAllFriend(friendTable)
    if CSResourceMgr.getCsbObj(resName) then
        for k,v in pairs(friendTable) do
            local cjson = require("cjson")
            local friendInfo = cjson.decode(v)
            if friendInfo.needConfirm == 1 then
                table.insert(applyPlayerTable,friendInfo)
            else
                table.insert(allFriendTable,friendInfo)
            end
        end
        if allFriendNum == #applyPlayerTable + #allFriendTable then
            FriendsViewMgr.showFriendsList()
        end
        mChatFriendTable = allFriendTable
    else
        for k,v in pairs(friendTable) do
            local cjson = require("cjson")
            local friendInfo = cjson.decode(v)
            if friendInfo.needConfirm ~= 1 then
                table.insert(allFriendTable,friendInfo)
            end
            mChatFriendTable = allFriendTable
        end
        TownChatMgr.setAllFriendTable(mChatFriendTable)
    end
end

function FriendsViewMgr.showNewFriendRedPoint(newfriend,needConfirm)
    local cjson = require("cjson")
    local friendInfo = cjson.decode(newfriend)
    if CSResourceMgr.getCsbObj(resName) then
        if needConfirm == 1 then
            FriendsViewMgr.setApplyRedPoint(true)
            if not FriendsViewMgr.isAlreadyApply(friendInfo) then
                table.insert(applyPlayerTable,friendInfo)
            end
        end
    else
        if needConfirm == 1 then
            StatusBarMgr.addRedPoint(4)
        end
    end
end

function FriendsViewMgr.addFriendToList(playerInfo)
    if FriendsViewMgr.isHaveFriend(playerInfo) then
        return
    end
    table.insert(allFriendTable,playerInfo)
    if CSResourceMgr.getCsbObj(resName) then
        FriendsViewMgr.refreshFriendsList()
    end
end

function FriendsViewMgr.setApplyRedPoint(enabled)
    local redPoint = CSResourceMgr.getNodeByName(resName,"redPoint")
    redPoint:setVisible(enabled)
end

function FriendsViewMgr.isHaveFriend(friendInfo)
    for k,v in pairs(allFriendTable) do
        if v.friendID == friendInfo.friendID then
            return true
        end
    end
    return false
end

function FriendsViewMgr.isAlreadyApply(friendInfo)
    for k,v in pairs(applyPlayerTable) do
        if v.friendID == friendInfo.friendID then
            return true
        end
    end
    return false
end

function FriendsViewMgr.showSearchView()
    local function loadCSB()
        local node = CSResourceMgr.getNodeByName(resName,"node")
        local curLayer = CSResourceMgr.createRes(node, resNameC)
        curLayer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        --...

        editbox = CocosModuleMgr.newTextEditor(CSResourceMgr.getNodeByName(resNameC, "frame"), "empty", 
        350, 24, 241, 337, 24, TownChatMgr.MAX_NAME_SIZE, "friendList9",nil,function()
            if not tonumber(editbox:getText()) and editbox:getText()~="" then
                editbox:setText("")
                StandardTipsMgr.show(1,"friendList26")
            end
            if tonumber(editbox:getText()) and tonumber(editbox:getText())<0 then
                editbox:setText("")
                StandardTipsMgr.show(1,"friendList26")
            end
        end,false)

        CSResourceMgr.clickEventBinding(resNameC, "close", function()
            UnblockLoader.cancel("FriendsViewMgr.showSearchView")
            CSResourceMgr.removeCSObjectByTag(resNameC)
        end)
        local title = CSResourceMgr.getNodeByName(resNameC,"title")
        CSResourceMgr.setLabelColorByNode(title, {r=160,g=235,b=250,a=255})
        CSResourceMgr.setLabelStringByNode(title, "friendList8", {r=37,g=54,b=75,a=255})

        local noSearchLabel = CSResourceMgr.getNodeByName(resNameC,"noSearchLabel")
        CSResourceMgr.setLabelColorByNode(noSearchLabel, {r=255,g=0,b=0,a=255})
        CSResourceMgr.setLabelStringByNode(noSearchLabel, "friendList12")

        CSResourceMgr.clickEventBinding(resNameC, "searchBtn", function()
                local text = editbox:getText()
                if text~="" then
                    if isGetingInfo then
                        getinfoCallback = function()
                        NetInterface.sendWithBlock("GC_GetFriendDetail_Ack", function()
                            local ChatUserSend = require("src.Net.Send.ChatUserSend")
                            ChatUserSend.sendCG_GetFriendDetail_Req({friendID = text})
                            searchPlayerId = text
                            end,function()
                                FriendsViewMgr.showSearchPlayerInfo(searchPlayer)
                                GameAudio.playUISound("success")
                            end,function()
                                StandardTipsMgr.show(1,"friendList13")
                            end)
                        end
                    else
                        NetInterface.sendWithBlock("GC_GetFriendDetail_Ack", function()
                            local ChatUserSend = require("src.Net.Send.ChatUserSend")
                            ChatUserSend.sendCG_GetFriendDetail_Req({friendID = text})
                            searchPlayerId = text
                            end,function()
                                FriendsViewMgr.showSearchPlayerInfo(searchPlayer)
                                GameAudio.playUISound("success")
                            end,function()
                                StandardTipsMgr.show(1,"friendList13")
                            end)
                    end
                end
            end)
    end
    
    local function playCSB()
        CSResourceMgr.playAction(resNameC, 0, 5, false)
    end

    local funcTable = {loadCSB, playCSB}
    UnblockLoader.load(funcTable, "FriendsViewMgr.showSearchView")
end

function FriendsViewMgr.setSearchPlayer(playerInfo)
    searchPlayer = playerInfo
end

function FriendsViewMgr.showSearchPlayerInfo(playerInfo)
    if CSResourceMgr.getCsbObj(resNameC) then
        local searchPlayer = CSResourceMgr.getNodeByName(resNameC,"searchPlayer")
        searchPlayer:setVisible(true)
        local playerName = CSResourceMgr.getNodeByName(resNameC,"playerName")
        CSResourceMgr.setLabelColorByNode(playerName, {r=196,g=230,b=252,a=255})
        CSResourceMgr.setLabelStringByNode(playerName, playerInfo.nickname, {r=0,g=0,b=0,a=255})
        playerName:enableOutline({r=0,g=0,b=0,a=255},1)
        local level = CSResourceMgr.getNodeByName(resNameC,"level")
        CSResourceMgr.setLabelColorByNode(level, {r=255,g=252,b=0,a=255})
        CSResourceMgr.setLabelStringByNode(level, "Lv"..playerInfo.level, {r=0,g=0,b=0,a=255})
        level:enableOutline({r=0,g=0,b=0,a=255},1)
        local playerInfoLabel = CSResourceMgr.getNodeByName(resNameC,"playerInfoLabel")
        CSResourceMgr.setLabelColorByNode(playerInfoLabel, {r=196,g=230,b=252,a=255})
        CSResourceMgr.setLabelStringByNode(playerInfoLabel, "friendList10", {r=0,g=0,b=0,a=255})
        playerInfoLabel:enableOutline({r=0,g=0,b=0,a=255},1)
        local attackNum = CSResourceMgr.getNodeByName(resNameC,"attackNum")
        CSResourceMgr.setLabelColorByNode(attackNum, {r=144,g=238,b=255,a=255})
        CSResourceMgr.setLabelStringByNode(attackNum, playerInfo.fightPoint, {r=12,g=27,b=38,a=255})
        attackNum:enableOutline({r=12,g=27,b=38,a=255},1)
        local addBtn = CSResourceMgr.getNodeByName(resNameC,"addBtn")
        CSResourceMgr.setButtonStringByNode(addBtn, "friendList11", {r=0,g=0,b=0,a=255})
        CSResourceMgr.setButtonStringColorByNode(addBtn, {r=227,g=233,b=255,a=255})
        CSResourceMgr.clickEventBindingByNode(addBtn, function()
            if searchPlayerId == tostring(CharInfo.getCharID()) then
                DialogBoxMgr.showSmallDialogBox(scene, 1, "friendList17")
            else
                FriendsViewMgr.AddFriend(searchPlayerId)
                UnblockLoader.cancel("FriendsViewMgr.showSearchView")
                CSResourceMgr.removeCSObjectByTag(resNameC)
            end
        end)
    end
end

function FriendsViewMgr.isToday(lastTime)
    if lastTime~=0 then
        local dayNow = math.floor((CharInfo.getServerTime()+CharInfo.getServerTimeZone())/86400)
        local dayLastBuy = math.floor((lastTime+CharInfo.getServerTimeZone())/86400)
        if dayNow == dayLastBuy then
            if (lastTime+CharInfo.getServerTimeZone())%86400 >= 21600 then
                return true
            end
        elseif (dayNow-dayLastBuy) == 1 then
            if (CharInfo.getServerTime()+CharInfo.getServerTimeZone())%86400 < 21600 and (lastTime+CharInfo.getServerTimeZone())%86400 >= 21600 then
                return true
            end
        end
    end
    return false
end

function FriendsViewMgr.getAllFriendToChat()
    if #mChatFriendTable == 0 then
        NetInterface.sendWithBlock("GC_GetMyFriends_Ack", function()
            local ChatUserSend = require("src.Net.Send.ChatUserSend")
            ChatUserSend.sendCG_GetMyFriends_Req()
            end)
    else
        TownChatMgr.setAllFriendTable(mChatFriendTable)
    end
end

function FriendsViewMgr.setRedHeartShopInfo(info)
    redHeartShopInfo = info.myGoods or {}
end

function FriendsViewMgr.AddFriend(friendID)
    friendMaxNum = SystemInfo.getGlobalConfigAddInfoByID(42).values[1]
    if FriendsViewMgr.getFriendNum()>=friendMaxNum then
        StandardTipsMgr.show(1, "friendList27")
        return
    end
    NetInterface.sendWithBlock("GC_AddFriend_Ack", function()
        local ChatUserSend = require("src.Net.Send.ChatUserSend")
        ChatUserSend.sendCG_AddFriend_Req({friendID = friendID})
        end,function()
            StandardTipsMgr.show(0, "chat12")
        end)
end

function FriendsViewMgr.setRecommendFriend(recommends)
    local funcTable = {}
    local curNum = CSResourceMgr.getNodeByName(resName,"curNum")
    CSResourceMgr.setLabelColorByNode(curNum, {r=255,g=255,b=255,a=255})
    CSResourceMgr.setLabelStringByNode(curNum, #allFriendTable.."/"..friendMaxNum, {r=0,g=0,b=0,a=255,w=1})
    local list = CSResourceMgr.getNodeByName(resName,"hytjList")
    CSResourceMgr.removeListByNode(list)
    local friendTabel = {}
    local playerInfoTable = {}

    local function setFriend(k,playerInfo)
        local friend = CSResourceMgr.getNodeByName(resName, "friend"):clone()
        friend:setVisible(true)
        friendTabel[k] = friend
        local playerName = CSResourceMgr.seekNodeByName(friend, "playerName")
        CSResourceMgr.setLabelColorByNode(playerName, {r=255,g=255,b=255,a=255})
        CSResourceMgr.setLabelStringByNode(playerName,playerInfo.nickname, {r=5,g=48,b=84,a=255})
        local level = CSResourceMgr.seekNodeByName(friend, "Lv")
        CSResourceMgr.setLabelColorByNode(level, {r=255,g=252,b=0,a=255})
        CSResourceMgr.setLabelStringByNode(level,"Lv"..playerInfo.Level, {r=0,g=0,b=0,a=255})
        CSResourceMgr.seekNodeByName(friend, "likeNum"):setVisible(false)
        CSResourceMgr.seekNodeByName(friend, "likeValue"):setVisible(false)
        CSResourceMgr.seekNodeByName(friend, "likeBack"):setVisible(false)
        CSResourceMgr.seekNodeByName(friend, "lastTimeLabel"):setVisible(false)
        CSResourceMgr.seekNodeByName(friend, "likeNum"):setVisible(false)
        CSResourceMgr.seekNodeByName(friend, "likeValue"):setVisible(false)
        CSResourceMgr.seekNodeByName(friend, "likeBack"):setVisible(false)
        CSResourceMgr.seekNodeByName(friend, "likeBtn"):setVisible(false)

        CSResourceMgr.seekNodeByName(friend, "attackBack"):setPosition(200,66)
        CSResourceMgr.seekNodeByName(friend, "attackValue"):setPosition(137,66)
        CSResourceMgr.seekNodeByName(friend, "attackNum"):setPosition(200,66)

        local attackNum = CSResourceMgr.seekNodeByName(friend, "attackNum")
        CSResourceMgr.setLabelColorByNode(attackNum, {r=255,g=255,b=255,a=255})
        CSResourceMgr.setLabelStringByNode(attackNum,playerInfo.fightPoint)
        local vipLevel = CSResourceMgr.seekNodeByName(friend, "vipLevel")
        CSResourceMgr.setLabelColorByNode(vipLevel, {r=255,g=252,b=0,a=255})
        CSResourceMgr.setLabelStringByNode(vipLevel,playerInfo.vipLevel-1,{r=0,g=0,b=0,a=255,w=1,s=1})
        if playerInfo.vipLevel-1 == 0 then
            CSResourceMgr.seekNodeByName(friend, "vipInfo"):setVisible(false)
        end
        local likeLabel = CSResourceMgr.seekNodeByName(friend, "likeLabel")
        CSResourceMgr.setLabelColorByNode(likeLabel, {r=255,g=255,b=255,a=255})
        CSResourceMgr.setLabelStringByNode(likeLabel,"friendList21",{r=0,g=0,b=0,a=255,w=1,s=1})
        if playerInfo.familyName and playerInfo.familyName~="" then
            local familyName = CSResourceMgr.seekNodeByName(friend, "familyName")
            CSResourceMgr.setLabelColorByNode(familyName, {r=255,g=255,b=255,a=255})
            CSResourceMgr.setLabelStringByNode(familyName,playerInfo.familyName,{r=0,g=0,b=0,a=255,w=1,s=1})
            CSResourceMgr.seekNodeByName(friend, "familyIcon"):loadTexture("Confraternity/icon_qizhi1_hz.png")
        else
            CSResourceMgr.seekNodeByName(friend, "familyBack"):setVisible(false)
        end
        local headIcon = CSResourceMgr.seekNodeByName(friend, "headIcon")
        headIcon:loadTexture(CharInfo.getHeadIcon(playerInfo.fashion.curFashion))
        headIcon:setScale(1.7)

        local addtjBtn = CSResourceMgr.seekNodeByName(friend, "addtjBtn")
        addtjBtn:setVisible(true)
        local addtjLabel = CSResourceMgr.seekNodeByName(friend, "addtjLabel")
        CSResourceMgr.setLabelColorByNode(addtjLabel, {r=248,g=255,b=238,a=255})
        CSResourceMgr.setLabelStringByNode(addtjLabel,"friendList22", {r=36,g=98,b=5,a=255,w=1,s=1})
        CSResourceMgr.clickEventBindingByNode(addtjBtn, function()
            NetInterface.sendWithBlock("GC_AddFriend_Ack", function()
                local ChatUserSend = require("src.Net.Send.ChatUserSend")
                ChatUserSend.sendCG_AddFriend_Req({friendID = playerInfo.friendID})
                end,function()
                    friendTabel[k] = nil
                    StandardTipsMgr.show(0, "chat12")
                    CSResourceMgr.setButtonEnabledByNode(addtjBtn, false)
                    CSResourceMgr.setLabelColorByNode(addtjLabel, {r=255,g=255,b=255,a=255})
                    CSResourceMgr.setLabelStringByNode(addtjLabel,"friendList22", {r=0,g=0,b=0,a=255,w=1,s=1})
                    CSResourceMgr.seekNodeByName(friend, "addtjIcon"):loadTexture("UI/CommonFiles/add_2.png")
                end)
        end)

 
        CSResourceMgr.seekNodeByName(friend, "back"):setColor({r=67,g=85,b=100})
        CSResourceMgr.seekNodeByName(friend, "headBack"):setColor({r=128,g=161,b=172})
        CSResourceMgr.seekNodeByName(friend, "zanBack"):setColor({r=128,g=161,b=172})
        CSResourceMgr.seekNodeByName(friend, "likeBack"):setColor({r=71,g=96,b=103})
        CSResourceMgr.seekNodeByName(friend, "attackBack"):setColor({r=71,g=96,b=103})
        CSResourceMgr.seekNodeByName(friend, "familyBack"):setColor({r=185,g=200,b=205})
        list:pushBackCustomItem(friend)

        friend:setScaleY(0)
        transition.scaleTo(friend, {scale=1, time=0.2})
    end

    local addAllBtn = CSResourceMgr.getNodeByName(resName, "addAllBtn")
    CSResourceMgr.setButtonStringByNode(addAllBtn, "friendList24", {r=0,g=0,b=0,a=255})
    CSResourceMgr.setButtonStringColorByNode(addAllBtn, {r=227,g=233,b=255,a=255})
    local refreshBtn = CSResourceMgr.getNodeByName(resName, "refreshBtn")
    CSResourceMgr.setButtonStringByNode(refreshBtn, "friendList25", {r=0,g=0,b=0,a=255})
    CSResourceMgr.setButtonStringColorByNode(refreshBtn, {r=227,g=233,b=255,a=255})
    CSResourceMgr.clickEventBindingByNode(refreshBtn, function()
        if not isRefresh then
            NetInterface.sendWithBlock("GC_GetRecommendFriend_Ack", function()
                local ChatUserSend = require("src.Net.Send.ChatUserSend")
                ChatUserSend.sendCG_GetRecommendFriend_Req()
                end,function()
                    isRefresh = true
                end)
        end
    end)

    local function addRecommends(friendBtn,playerInfo,index)
        NetInterface.sendWithBlock("GC_AddFriend_Ack", function()
            local ChatUserSend = require("src.Net.Send.ChatUserSend")
            ChatUserSend.sendCG_AddFriend_Req({friendID = playerInfo.friendID})
            end,function()
                if addTableIndex[index + 1] then
                    addRecommends(friendTabel[addTableIndex[index+1]],playerInfoTable[addTableIndex[index+1]],index+1)
                end
                StandardTipsMgr.show(0, "chat12")
                CSResourceMgr.setButtonEnabledByNode(CSResourceMgr.seekNodeByName(friendTabel[addTableIndex[index]],"addtjBtn"), false)
                CSResourceMgr.setLabelColorByNode(CSResourceMgr.seekNodeByName(friendTabel[addTableIndex[index]],"addtjLabel"), {r=255,g=255,b=255,a=255})
                CSResourceMgr.setLabelStringByNode(CSResourceMgr.seekNodeByName(friendTabel[addTableIndex[index]],"addtjLabel"),"friendList22", {r=0,g=0,b=0,a=255,w=1,s=1})
                CSResourceMgr.seekNodeByName(friendTabel[addTableIndex[index]], "addtjIcon"):loadTexture("UI/CommonFiles/add_2.png")
                friendTabel[addTableIndex[index]] = nil
            end)
    end

    CSResourceMgr.clickEventBindingByNode(addAllBtn, function()
        addTableIndex = {}
        for k,v in pairs(friendTabel) do
            table.insert(addTableIndex,k)
        end
        if friendTabel[addTableIndex[1]] then
            addRecommends(friendTabel[addTableIndex[1]],playerInfoTable[addTableIndex[1]],1)
        end
    end)

    for k,v in pairs(recommends) do
        local cjson = require("cjson")
        local playerInfo = cjson.decode(v)
        playerInfo.friendID =  playerInfo["_id"]
        if playerInfo.friendID ~= CharInfo.getCharID() and not FriendsViewMgr.isHaveFriend(playerInfo) then
            table.insert(funcTable,function()
                playerInfoTable[k] = playerInfo
                setFriend(k,playerInfo)
            end)
        end
    end
    table.insert(funcTable,function()
        isRefresh = false
    end)
    UnblockLoader.load(funcTable, "FriendsViewMgr.setRecommendFriend")
end

function FriendsViewMgr.getFriendNum()
    return #allFriendTable
end

function FriendsViewMgr.getMyFriends()
    return allFriendTable
end

function FriendsViewMgr.setVisible(visible)
    if not CSResourceMgr.getCsbObj(resName) then
        return
    end
    if visible == false then
        StatusBarMgr.hideTopInfoBar()
    else
        StatusBarMgr.showTopInfoBar(function()
            FriendsViewMgr.hide()
        end)
    end
end

function FriendsViewMgr.setAllFriendNum(num)
    allFriendNum = num
end

return FriendsViewMgr