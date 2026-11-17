local LtExchangeViewMgr = {}

local useUnblockLoader = true

local resName = "LostTower/Menu/LtExchange.csb"
local itemNodes = {}

local myPoints = 0

LtExchangeViewMgr.shopItems = {}
LtExchangeViewMgr.shopResetTime = nil
LtExchangeViewMgr.systemReflashTime = nil

LtExchangeViewMgr.refreshTimeMax = 20
LtExchangeViewMgr.refreshCount = 0
local refreshInfo = {}

function LtExchangeViewMgr.Init()
    myPoints = 0

    itemNodes = {}
    LtExchangeViewMgr.shopItems = {}
    LtExchangeViewMgr.shopResetTime = nil
    LtExchangeViewMgr.systemReflashTime = nil
    LtExchangeViewMgr.refreshTimeMax = 20
    LtExchangeViewMgr.refreshCount = 0
    refreshInfo = {}
end

function LtExchangeViewMgr.updateAfterRefresh()
end

--- 计算刷新间隔
local function getCountDownTime(_t, _i)
    local countDownTime = 0
    local carry = 0

    local nexti = _i + 1 
    if nexti > #_t then 
        carry = 1 
        nexti = nexti % #_t
        if #_t == 1 then nexti = 1 end
    end

    local serverTime = CharInfo.getServerTime()

    local date = os.date("*t",serverTime)
    date.day = date.day + carry
    date.hour = _t[nexti]
    date.min  = 0
    date.sec  = 0

    return os.time(date) - serverTime
end

local function getTimePoint(timePoints)
    local dateTime = os.date("*t",CharInfo.getServerTime())
    local index
    for i = 1, #timePoints - 1 do
        if dateTime.hour >= timePoints[i] and dateTime.hour < timePoints[i+1] then
            index = i
        end
    end
    if dateTime.hour < timePoints[1] then index = 0 end
    if dateTime.hour >= timePoints[#timePoints] then index = #timePoints end
    
    return index
end

local function isTimeToSysRefresh(lastTime, now)
    if not lastTime then return false end
    
    local timePoints = SystemInfo.getGlobalConfigAddInfoByID(33).values
    local _index = getTimePoint(timePoints)
    for i = 1, #timePoints, 1 do
        local offsetTime = 3600*timePoints[i]
        local dayTimeDiff = CocosModuleMgr.getDayTimeDiff(lastTime,now,offsetTime)
        if dayTimeDiff ~= 0 and i >= _index then
            return true, getCountDownTime(timePoints, i)
        end
    end
    
    return false
end

function LtExchangeViewMgr.show(scene)
    UIStack.push("LtExchangeViewMgr", LtExchangeViewMgr.hide)

    -- vip表刷新次数上限
    LtExchangeViewMgr.refreshTimeMax = CharInfo.getVipInfoByID(CharInfo.getVIPLevel()).ltShopRefresh

    local function getConsumeInfo()
        -- init shop refresh info
        refreshInfo = {}
        local shopType = 3   -- 千层塔
        local info = ItemInfo.getShopReFlashInfoById(shopType)
        if info then
            for key, value in pairs(info.reflashDetail) do
                refreshInfo[value.count] = value.consume
            end
        end
    end
    getConsumeInfo()

    local systemRefreshDidDone = false

    local function loadCSB()

        local layer = CSResourceMgr.createRes(scene,resName)
        CSResourceMgr.setFullScreen(resName)
        CSResourceMgr.setRelativePosition(resName, 320, 480)
        layer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        
        --title
        CSResourceMgr.setLabelColor(resName,{"frame","title"},{r=144,g=238,b=255,a=255})
        CSResourceMgr.setLabelString(resName,{"frame","title"},"LtShop1","",{r=38,g=54,b=76,a=255},nil,120)   -- "迷失之塔"

        --title2
        CSResourceMgr.setLabelString(resName,{"frame","db","titleIcon","title"},"LtShop2","",{r=194,g=114,b=71,a=255})   -- "兑换商店"
        CSResourceMgr.getNodeByName(resName,"help"):setVisible(false)  -- 隐藏帮助按钮
        
        -- my points
        CSResourceMgr.setLabelColor(resName,{"frame","db","bottom","score","score_name"},{r=166,g=243,b=255,a=255})
        CSResourceMgr.setLabelString(resName,{"frame","db","bottom","score","score_name"},"LtShop3","",{r=38,g=54,b=76,a=255},nil,100)   -- "当前积分"
        CSResourceMgr.setLabelString(resName,{"frame","db","bottom","score","label_score"},myPoints,"")
        
        -- refresh consume
        local consumeNumber
        local count = LtExchangeViewMgr.refreshCount+1
        if count < LtExchangeViewMgr.refreshTimeMax then
            if refreshInfo[count] then
                consumeNumber = ItemInfo.getConsumeElementInfoById(refreshInfo[count]).num
            else
                consumeNumber = "noData"
            end
        else
            if refreshInfo[LtExchangeViewMgr.refreshTimeMax] then
                consumeNumber = ItemInfo.getConsumeElementInfoById(refreshInfo[LtExchangeViewMgr.refreshTimeMax]).num
            else
                consumeNumber = "noData"
            end
        end
        CSResourceMgr.setLabelColor(resName,{"frame","db","bottom","refresh","mcash_n"},{r=227,g=233,b=255,a=255})
        CSResourceMgr.setLabelString(resName,{"frame","db","bottom","refresh","mcash_n"},consumeNumber,"",nil,nil,44)
        
        local times = LtExchangeViewMgr.refreshTimeMax-LtExchangeViewMgr.refreshCount
        if times < 0 then times = 0 end
        CSResourceMgr.setLabelColor(resName,{"frame","db","bottom","score","refreshTimes_t"},{r=249,g=225,b=20,a=255})
        CSResourceMgr.setLabelString(resName,{"frame","db","bottom","score","refreshTimes_t"},"LtText41","",nil,nil,149)  -- "今日剩余刷新次数:"
        CSResourceMgr.getNodeByName(resName,{"frame","db","bottom","score","refreshTimes_t"}):enableOutline({r=0,g=0,b=0,a=255}, 1)
        CSResourceMgr.setLabelString(resName,{"frame","db","bottom","score","refreshTimes_n"},times,"",nil,nil,44)
        
        CSResourceMgr.setLabelColor(resName,{"frame","db","bottom","refresh","refresh_time_t"},{r=166,g=243,b=255,a=255})
        CSResourceMgr.setLabelString(resName,{"frame","db","bottom","refresh","refresh_time_t"},"LtText42","",nil,nil,90)
        CSResourceMgr.getNodeByName(resName,{"frame","db","bottom","refresh","refresh_time_t"}):enableOutline({r=38,g=54,b=76,a=255}, 1)  --"刷新倒计时："
        
        CSResourceMgr.clickEventBinding(resName,{"frame", "close"},function()
            LtExchangeViewMgr.hide()
        end)   
        
        CSResourceMgr.clickEventBinding(resName,{"frame","db","bottom","refresh","refresh_btn"},function()
            local count = LtExchangeViewMgr.refreshCount
            if not refreshInfo[count+1] or times == 0 then
                print("current refresh count:",count)
                StandardTipsMgr.show(1,"LtTips11")  -- "本日刷新次数达上限"
                return
            end
            local consume = ItemInfo.getConsumeElementInfoById(refreshInfo[count+1])
            if CharInfo.getMCash() < consume.num then
                StandardTipsMgr.show(1,"tips14")   -- 钻石不足
                return
            end
            
            LtExchangeViewMgr.refreshCount = LtExchangeViewMgr.refreshCount + 1
            
            --DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 2, "LtTips2", function()   -- "是否刷新所有商品？"
            NetInterface.sendWithBlock("GC_REFRESHGOODS_ACK",function()
                local CommonShopSend = require("src.Net.Send.CommonShopSend")
                CommonShopSend.sendCG_RefreshGoods_Req({type = 3,})
            end,function()
                LtExchangeViewMgr.refresh()
            end,function(code)
                TipsMgr.showError(nil,code)
            end)
        end)
        
--        if LtExchangeViewMgr.systemReflashTime then
--            local timePoints = SystemInfo.getGlobalConfigAddInfoByID(33).values
--            local timeLabel = CSResourceMgr.getNodeByName(resName,{"frame","db","bottom","refresh","refresh_time"})
--            
--            local flag = false
--            local _index = getTimePoint(timePoints)
--            for i = 1, #timePoints, 1 do
--                local t1 = LtExchangeViewMgr.systemReflashTime
--                local t2 = CharInfo.getServerTime()
--                local offsetTime = 3600*timePoints[i]
--                local dayTimeDiff = CocosModuleMgr.getDayTimeDiff(t1,t2,offsetTime)
--                
--                if dayTimeDiff ~= 0 and i >= _index then
--                    flag = true
--                    LtExchangeViewMgr.autoRefresh(getCountDownTime(timePoints, i), true)
--                    break
--                end
--            end
--        end
            
--        if not systemRefreshDidDone then
            local timePoints = SystemInfo.getGlobalConfigAddInfoByID(33).values
            local timeLabel = CSResourceMgr.getNodeByName(resName,{"frame","db","bottom","refresh","refresh_time"})
            local dateTime = os.date("*t",CharInfo.getServerTime())
            local index
            for i = 1, #timePoints - 1 do
                if dateTime.hour >= timePoints[i] and dateTime.hour < timePoints[i+1] then
                    index = i
                end
            end
            if dateTime.hour < timePoints[1] then index = 0 end
            if dateTime.hour >= timePoints[#timePoints] then index = #timePoints end
            CocosModuleMgr.setTimeLabelCountDown(timeLabel, getCountDownTime(timePoints, index), function()
                LtExchangeViewMgr.autoRefresh()
            end)
--        end
        
    end

    local function playCSB()
        CSResourceMgr.playAction(resName,0,5)
    end

    local function init()
        local ExItems = LtExchangeViewMgr.getItems()
        LtExchangeViewMgr.resetExItems(ExItems)
    end

    local function buttonBinding()
    end

    local funcTable = {loadCSB, playCSB, init, buttonBinding}
    
    local flag, countDown = isTimeToSysRefresh(LtExchangeViewMgr.systemReflashTime, CharInfo.getServerTime())
    if flag and countDown then
--        LtExchangeViewMgr.autoRefresh(countDown, true, function()
--            systemRefreshDidDone = true
--            UnblockLoader.load(funcTable,"LtExchangeViewMgr")
--        end)
        NetInterface.sendWithBlock("GC_SYSTEMREFRESHGOODS_ACK",function()
            local CommonShopSend = require("src.Net.Send.CommonShopSend")
            CommonShopSend.sendCG_SystemRefreshGoods_Req({type = 3,})
        end,function()
            systemRefreshDidDone = true
            UnblockLoader.load(funcTable,"LtExchangeViewMgr")
        end,function(code)
            TipsMgr.showError(nil,code)
        end)
    else
        UnblockLoader.load(funcTable,"LtExchangeViewMgr")
    end

end

function LtExchangeViewMgr.hide()
    UIStack.pop("LtExchangeViewMgr")

    LtExchangeViewMgr.shopItems = {}
    LtExchangeViewMgr.refreshCount = nil
    LtExchangeViewMgr.shopResetTime = nil
    LtExchangeViewMgr.systemReflashTime = nil
    UnblockLoader.cancel("LtExchangeViewMgr")
    UnblockLoader.cancel("LtExchangeViewMgr-resetExItems")
    CSResourceMgr.getNodeByName(resName,{"frame", "db", "list"}):removeAllItems()
    CSResourceMgr.removeCSObjectByTag(resName)
end

--- 从服务器获取兑换商品
function LtExchangeViewMgr.getItems()
    for k,v in pairs(LtExchangeViewMgr.shopItems) do
        print("~~~~~~~~~~ shopItems ~~~~~~~~~~~~",k)
        for kk,vv in pairs(v) do
            print(kk,vv)
        end
    end
    local items = LtExchangeViewMgr.shopItems
    
    return items
end

--- 系统自动刷新
-- @param flag number [ true:点开时系统刷新; false:界面中系统刷新 ]
function LtExchangeViewMgr.autoRefresh(refreshTime, flag, callback)
    local timePoints = SystemInfo.getGlobalConfigAddInfoByID(33).values
    local dateTime = os.date("*t",CharInfo.getServerTime())
    local index
    for i = 1, #timePoints - 1 do
        if dateTime.hour >= timePoints[i] and dateTime.hour < timePoints[i+1] then
            index = i
        end
    end
    if dateTime.hour < timePoints[1] then index = 0 end
    if dateTime.hour >= timePoints[#timePoints] then index = #timePoints end
    
    refreshTime = refreshTime or getCountDownTime(timePoints, index)

    NetInterface.sendWithBlock("GC_SYSTEMREFRESHGOODS_ACK",function()
        local CommonShopSend = require("src.Net.Send.CommonShopSend")
        CommonShopSend.sendCG_SystemRefreshGoods_Req({type = 3,})
    end,function()
        -- refresh list
        if not flag then -- 停留再界面中系统刷新时，reset商品
            LtExchangeViewMgr.resetExItems(LtExchangeViewMgr.getItems(), nil)
        end

        -- refresh time
        local timeLabel = CSResourceMgr.getNodeByName(resName,{"frame","db","bottom","refresh","refresh_time"})
        CocosModuleMgr.setTimeLabelCountDown(timeLabel, refreshTime, function()
            LtExchangeViewMgr.autoRefresh()
        end)
        
        if callback then callback() end
    end,function(code)
        TipsMgr.showError(nil,code)
    end)
end

--- 手动刷新商品
function LtExchangeViewMgr.refresh()
    -- refresh list
    LtExchangeViewMgr.resetExItems(LtExchangeViewMgr.getItems(), nil)
    
    local times = LtExchangeViewMgr.refreshTimeMax-LtExchangeViewMgr.refreshCount
    if times < 0 then times = 0 end
    CSResourceMgr.setLabelString(resName,{"frame","db","bottom","score","refreshTimes_n"},times)

    local consumeNumber
    local count = LtExchangeViewMgr.refreshCount+1
    if count < LtExchangeViewMgr.refreshTimeMax then
        consumeNumber = ItemInfo.getConsumeElementInfoById(refreshInfo[count]).num
    else
        consumeNumber = ItemInfo.getConsumeElementInfoById(refreshInfo[LtExchangeViewMgr.refreshTimeMax]).num
    end
    CSResourceMgr.setLabelString(resName,{"frame","db","bottom","refresh","mcash_n"},consumeNumber)
    if consumeNumber > CharInfo.getMCash() then
        CSResourceMgr.setLabelColor(resName,{"frame","db","bottom","refresh","mcash_n"},{r=255,g=0,b=0,a=255})
    else
        CSResourceMgr.setLabelColor(resName,{"frame","db","bottom","refresh","mcash_n"},{r=227,g=233,b=255,a=255})
    end
end

--- reset list
function LtExchangeViewMgr.resetExItems(items, sortFunc)
    local funcTable = {}
    local list = CSResourceMgr.getNodeByName(resName,{"frame", "db", "list"})
    local sample = CSResourceMgr.getNodeByName(resName,"item")
    
    local RANK_NUM = 3
    local xOrigin = 94
    local xStep = 188
    
    local panelTable = {}
    local itemTable = {}
    
    if sortFunc then
        sortFunc(items)
    end
    
    -- 移除已添加items
    list:removeAllItems()
    itemNodes = {}
    
    for i=1, #items do
        local row = math.ceil(i/RANK_NUM)
        local rank = i%RANK_NUM
        if rank==0 then
            rank = RANK_NUM
        end
        if rank==1 then
            local panel = CSResourceMgr.getNodeByName(resName, "panel"):clone()
            table.insert(panelTable, panel)
            list:pushBackCustomItem(panel)
        end
        local function itemFunc()
            local parent = CSResourceMgr.seekNodeByName(panelTable[row],"item"):clone()
            parent:addTo(panelTable[row])
            parent:setPositionX(xStep*(rank-1)+xOrigin)
            
            if rank == 3 then
                CSResourceMgr.seekNodeByName(panelTable[row],"item"):setVisible(false)
            end
            
            CSResourceMgr.seekNodeByName(parent,"item_background_1"):setColor({r=128,g=161,b=172,a=255})
            CSResourceMgr.seekNodeByName(parent,"item_background_3"):setColor({r=2,g=16,b=28,a=255})
            
            local info = {
                icon = "",
                name = "",
                num  = 0,
            }
            
            local _info = ItemInfo.getAwardElementInfoById(items[i].itemID)
            if _info.elementType == Proto.AET_ITEM then     -- 道具
                info = clone(ItemInfo.getItemInfoById(_info.elementID))

                local _itype = ItemInfo.getItemType(_info.elementID)
                if _itype == 4 then
                    local petPieceInfo = ItemInfo.getPetPieceInfoById(_info.elementID)
                    info.icon = PokemonInfo.getPokemonIconByID(PokemonInfo.getGeneInfoByID(petPieceInfo.pokeID).petID)
                    CSResourceMgr.seekNodeByName(parent, "piece_mask"):setVisible(true)
                    CSResourceMgr.seekNodeByName(parent,"item_icon"):setScale(0.7)
                else
                    CSResourceMgr.seekNodeByName(parent, "piece_mask"):setVisible(false)
                    CSResourceMgr.seekNodeByName(parent,"item_icon"):setScale(1.0)
                end
                
                CSResourceMgr.seekNodeByName(parent,"item_icon"):loadTexture(info.icon)
                
                local label = CSResourceMgr.seekNodeByName(parent,"item_name")
                CSResourceMgr.setLabelStringByNode(label,info.name,{r=0,g=0,b=0,a=255,w=1},nil,108)
                CSResourceMgr.setLabelColorByNode(label,ItemInfo.COLOR[info.itemRare+1])
                
                local dbTexture = ItemInfo.getItemRareBGImage(info.id)
                CSResourceMgr.seekNodeByName(parent,"item_background_2"):loadTexture(dbTexture)
            elseif _info.elementType == Proto.AET_PET then -- 宠物
                local geneInfo = PokemonInfo.getGeneInfoByID(_info.elementID)
                info = clone(PokemonInfo.getPokemonInfoByID(geneInfo.petID))
                
                local _icon = PokemonInfo.getPokemonIconByID(info.id)
                CSResourceMgr.seekNodeByName(parent,"item_icon"):loadTexture(_icon)
                CSResourceMgr.seekNodeByName(parent,"item_icon"):setScale(0.75)
                
                local label = CSResourceMgr.seekNodeByName(parent,"item_name")
                CSResourceMgr.setLabelStringByNode(label,info.name,{r=0,g=0,b=0,a=255,w=1},nil,108)
                CSResourceMgr.setLabelColorByNode(label,PokemonInfo.COLOR[info.rarePoint])
                
                local rareRes = PokemonInfo.getStagePics(nil,info.elementAtt1, info.rarePoint)
                CSResourceMgr.seekNodeByName(parent,"item_background_2"):loadTexture(rareRes.p1)
            else
                print("QQQQQQQQQQQQQQQQQQQ")
            end

            local cost_label = CSResourceMgr.seekNodeByName(parent,"item_cost")
            CSResourceMgr.setLabelStringByNode(CSResourceMgr.seekNodeByName(parent,"item_num"),items[i].num,CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
            CSResourceMgr.setLabelStringByNode(cost_label,items[i].price)
            
            -- check to see if there're enough points to buy items
            if myPoints < items[i].price then
                CSResourceMgr.setLabelColorByNode(cost_label,{r=255,g=0,b=0,a=255})
            else
                CSResourceMgr.setLabelColorByNode(cost_label,{r=255,g=255,b=255,a=255})
            end
            
            if items[i].count > 0 then
                CSResourceMgr.seekNodeByName(parent,"gray"):setVisible(false)
            else
                CSResourceMgr.seekNodeByName(parent,"gray"):setVisible(true)
            end
            
            CSResourceMgr.longtouchEventBindingByNode(parent, function ()
                ItemInfoViewMgr.show({id = _info.elementID}, false)
            end, function ()
                if myPoints < items[i].price then
                    StandardTipsMgr.show(1,"LtTips3")  -- "积分不足，无法购买"
                    return
                end
                
                if items[i].count < 1 then
                    StandardTipsMgr.show(1,"LtTips4")  -- "卖光了"
                    return
                end
                
                DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 2, "LtTips5", function()   -- "是否购买？"
                    NetInterface.sendWithBlock("GC_BUYGOODS_ACK",function()
                        local CommonShopSend = require("src.Net.Send.CommonShopSend")
                        CommonShopSend.sendCG_BuyGoods_Req({type = 3, index = i - 1,buyCount = 1})
                    end,function()
                        StandardTipsMgr.show(0,"LtTips6")   -- "购买成功"
                        LtExchangeViewMgr.refreshAfterExchange(i)
                    end,function(code)
                    end)
                end, function()
                end)
            end)
            
            itemNodes[i] = parent

            parent:setScale(0)
            transition.scaleTo(parent, {scale = 1, time = 0.1})
        end
        table.insert(funcTable, itemFunc)
    end
    
    if useUnblockLoader then
        UnblockLoader.load(funcTable,"LtExchangeViewMgr")
    else
        for i=1,#funcTable do
            funcTable[i]()
        end
    end
    
end

-- 购买后刷新
function LtExchangeViewMgr.refreshAfterExchange(index)

    local cost = LtExchangeViewMgr.shopItems[index].price
    myPoints = myPoints - cost
    CSResourceMgr.setLabelString(resName,{"frame","db","bottom","score","label_score"},myPoints,"")
    LostTowerUIMgr.updatePoints(myPoints)
    
    LtExchangeViewMgr.shopItems[index].count = LtExchangeViewMgr.shopItems[index].count - 1
    
    CSResourceMgr.setLabelStringByNode(CSResourceMgr.seekNodeByName(itemNodes[index],"item_num"),LtExchangeViewMgr.shopItems[index].num)
    
    local parent = itemNodes[index]
    if LtExchangeViewMgr.shopItems[index].count > 0 then
        CSResourceMgr.seekNodeByName(parent,"gray"):setVisible(false)
    else
        CSResourceMgr.seekNodeByName(parent,"gray"):setVisible(true)
    end
    
    for i=1, #LtExchangeViewMgr.shopItems do
        -- check to see if there're enough points to buy items
        local label = CSResourceMgr.seekNodeByName(itemNodes[i],"item_cost")
        if myPoints < LtExchangeViewMgr.shopItems[i].price then
            CSResourceMgr.setLabelColorByNode(label,{r=255,g=0,b=0,a=255})
        else
            CSResourceMgr.setLabelColorByNode(label,{r=255,g=255,b=255,a=255})
        end
    end
    
end

function LtExchangeViewMgr.callLTShop()
    if not NetInterface.isConnect then return end
    
    local function getPoints(_callback)
        NetInterface.send("GC_GetCharacterValues_Ack", function()
            local LoginSend = require("src.Net.Send.LoginSend")
            LoginSend.sendCG_GetCharacterValues_Req({"lostTowerPoint"})
        end, function()
            myPoints = CharInfo.get().losttowerpoint or 0
            
            if myPoints == 0 then
            end
            
            if _callback then _callback() end
        end)
    end
    
    local function getShop()
        NetInterface.sendWithBlock("GC_GETSHOP_ACK",function()
            local CommonShopSend = require("src.Net.Send.CommonShopSend")
            CommonShopSend.sendCG_getShop_Req({type = 3,})
        end,function()
            local p = SystemInfo.getGlobalConfigAddInfoByID(35).values[1]
            local offsetTime = 3600 * p
            local dayDiff = CocosModuleMgr.getDayTimeDiff(LtExchangeViewMgr.shopResetTime, CharInfo.getServerTime(), offsetTime)
            if dayDiff ~= 0 then
                NetInterface.sendWithBlock("GC_RESETSHOP_ACK",function()
                    local CommonShopSend = require("src.Net.Send.CommonShopSend")
                    CommonShopSend.sendCG_ResetShop_Req({type = 3,})
                end,function()
                    LtExchangeViewMgr.refreshCount = 0
                    LtExchangeViewMgr.shopResetTime = CharInfo.getServerTime()
                    LtExchangeViewMgr.show(SceneMgr.getRunningScene)
                end)
            elseif dayDiff == 0 then
                LtExchangeViewMgr.show(SceneMgr.getRunningScene)
            end
        end,function()
        end)
    end
    
    getPoints(function()
        getShop()
    end)
end

return LtExchangeViewMgr