local advNpcShopMgr = {}

local useUnblockLoader = true

local resName = "Searching/Other/NpcExchange.csb"
local tag = "advNpcShop"

local CASH_TYPE = {
    mcash = 0,
    gcash = 1,
}

local itemNodes = {}

local function updateCash(type)
    if type == CASH_TYPE["mcash"] then     -- Mcash
        local label = CSResourceMgr.getNodeByName(resName,{"frame","db","bottom","mnum_l"},tag)
        CSResourceMgr.setLabelStringByNode(label, CharInfo.getMCash())
    elseif type == CASH_TYPE["gcash"] then -- Gcash
        local label = CSResourceMgr.getNodeByName(resName,{"frame","db","bottom","gnum_l"},tag)
        CSResourceMgr.setLabelStringByNode(label, CharInfo.getGCash())
    end
end

local function updateAfterPurch(_items, i)
    updateCash(_items[i].type)
    
    _items[i].count = _items[i].count - 1
    
    local parent = itemNodes[i]
    local _label = CSResourceMgr.seekNodeByName(parent,"item_cost")
    if _items[i].count > 0 then
        CSResourceMgr.seekNodeByName(parent,"gray"):setVisible(false)
    else
        CSResourceMgr.seekNodeByName(parent,"gray"):setVisible(true)
    end
    
    local cash_num = 0
    
    for i=1, #_items do
        -- check to see if there're enough points to buy items
        local label = CSResourceMgr.seekNodeByName(itemNodes[i],"item_cost")

        if _items[i].type == CASH_TYPE["mcash"] then     -- Mcash
            cash_num = CharInfo.getMCash()
        elseif _items[i].type == CASH_TYPE["gcash"] then -- Gcash
            cash_num = CharInfo.getGCash()
        end
        
        
        if _items[i].count < 1 then
            CSResourceMgr.setLabelColorByNode(_label, {r=180,g=180,b=180,a=128})
        else
            if cash_num < _items[i].price then
                CSResourceMgr.setLabelColorByNode(label,{r=255,g=0,b=0,a=255})
            else
                CSResourceMgr.setLabelColorByNode(label,{r=255,g=255,b=255,a=255})
            end
        end
    end
end

--- reset list
local function resetExItems(items, sortFunc)
    local funcTable = {}
    local list = CSResourceMgr.getNodeByName(resName,{"frame", "db", "list"},tag)
    local sample = CSResourceMgr.getNodeByName(resName,"item",tag)

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
            local panel = CSResourceMgr.getNodeByName(resName, "panel",tag):clone()
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
            end
            
            local cost_icon = CSResourceMgr.seekNodeByName(parent,"item_cost_icon")
            if items[i].type == CASH_TYPE["mcash"] then -- Mcash
                cost_icon:loadTexture("UI/CommonFiles/ico_lanzuan.png")
                cost_icon:setScale(0.5)
            end
            if items[i].type == CASH_TYPE["gcash"] then -- Gcash
                cost_icon:loadTexture("UI/CommonFiles/icon_jinbi.png")
                cost_icon:setScale(0.5)
            end

            local cost_label = CSResourceMgr.seekNodeByName(parent,"item_cost")
            CSResourceMgr.setLabelStringByNode(CSResourceMgr.seekNodeByName(parent,"item_num"),items[i].number,CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
            CSResourceMgr.setLabelStringByNode(cost_label,items[i].price)

            if items[i].count > 0 then
                CSResourceMgr.setLabelColorByNode(cost_label, {r=255,g=255,b=255,a=255})
                CSResourceMgr.seekNodeByName(parent,"gray"):setVisible(false)
            else
                CSResourceMgr.setLabelColorByNode(cost_label, {r=180,g=180,b=180,a=128})
                CSResourceMgr.seekNodeByName(parent,"gray"):setVisible(true)
            end
            
            -- item 点击事件
            CSResourceMgr.longtouchEventBindingByNode(parent, function ()
                ItemInfoViewMgr.show({id = _info.elementID}, false)
            end, function ()
                if items[i].type == CASH_TYPE["mcash"] then
                    if CharInfo.getMCash() < items[i].price then
                        TipsMgr.show(SceneMgr.getRunningScene, "tips14")
                        return
                    end
                elseif items[i].type == CASH_TYPE["gcash"] then
                    if CharInfo.getGCash() < items[i].price then
                        TipsMgr.show(SceneMgr.getRunningScene, "tips13")
                        return
                    end
                end
                
                if items[i].count < 1 then
                    StandardTipsMgr.show(1,"LtTips4")
                    return
                end
                
                DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene, 2, "LtTips5", function()   -- "是否购买？"
                    NetInterface.sendWithBlock("GC_BUYNPCSHOPGOODS_ACK",function()
                        local AdventureSend = require("src.Net.Send.AdventureSend")
                        AdventureSend.sendCG_BuyNpcShopGoods_Req({index = i - 1,})
                    end,function()
                        StandardTipsMgr.show(0,"LtTips6")   -- "购买成功"
                        updateAfterPurch(items, i)
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
        UnblockLoader.load(funcTable,"advNpcShopMgr-resetExItems")
    else
        for i=1,#funcTable do
            funcTable[i]()
        end
    end

end

function advNpcShopMgr.show(scene, shopItems, closeCallback)
    scene = scene or SceneMgr.getRunningScene
    
    if not shopItems or #shopItems == 0 then return end
    
    local layer
    local board

    local gcashLabel
    local mcashLabel
    
    local function loadCSB()

        layer = CSResourceMgr.createRes(scene,resName,tag)
        CSResourceMgr.setRelativePosition(resName, 320, 480, tag)
        layer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        
        board = CSResourceMgr.getNodeByName(resName,"frame",tag)
        board:setVisible(false)
        CSResourceMgr.getNodeByName(resName, "block", tag):setOpacity(100)
        
        local title = CSResourceMgr.getNodeByName(resName,{"frame","db","titleIcon","title"},tag)
        CSResourceMgr.setLabelStringByNode(title, "advtext17",{r=0,g=0,b=0,a=128,w=1})  -- "npc商店"

        mcashLabel = CSResourceMgr.getNodeByName(resName,{"frame","db","bottom","mnum_l"},tag)
        gcashLabel = CSResourceMgr.getNodeByName(resName,{"frame","db","bottom","gnum_l"},tag)
        CSResourceMgr.setLabelStringByNode(mcashLabel,CharInfo.getMCash(),{r=0,g=0,b=0,a=128,w=1},nil,88)
        CSResourceMgr.setLabelStringByNode(gcashLabel,CharInfo.getGCash(),{r=0,g=0,b=0,a=128,w=1},nil,88)

    end

    local function playCSB()
        board:setVisible(true)
        CocosModuleMgr.showUIAnimation(board, "down")

        local fade = cc.FadeTo:create(0.2, 180)  -- 70%
        CSResourceMgr.getNodeByName(resName, "block", tag):runAction(fade)
    end

    local function init()
        resetExItems(shopItems)
    end

    local function buttonBinding()
        -- close window
        CSResourceMgr.clickEventBinding(resName,{"frame", "close"},function()
            advNpcShopMgr.hide()
            
            if closeCallback then closeCallback() end
        end, tag)
    end

    local funcTable = {loadCSB, playCSB, init, buttonBinding}

    if useUnblockLoader then
        UnblockLoader.load(funcTable,"advNpcShopMgr")
    else
        for i=1,#funcTable do
            funcTable[i]()
        end
    end

end

function advNpcShopMgr.hide()
    itemNodes = {}
    CSResourceMgr.removeCSObjectByTag(resName,tag)
end

return advNpcShopMgr

