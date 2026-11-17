local LtOpenBoxView = {}

local resName = "LostTower/Others/OpenBoxView.csb"
local tag = "LtOpenBoxView"

local consume_mcash = 0

function LtOpenBoxView.Init()
end

function LtOpenBoxView.show(scene, keyID, boxID, callback, useMCash)
    GameAudio.playUISound("popup")
    UIStack.push("LtOpenBoxView",LtOpenBoxView.hide)

    scene = scene or SceneMgr.getRunningScene
    keyID = keyID or 167
    boxID = boxID or 1001
    
    local Layer
    local board
    
    local randomChestInfo = LostTowerInfo.getRandomChestInfoById(boxID)
    
    consume_mcash = randomChestInfo.openMoney
    
    local function loadCSB()
        Layer = CSResourceMgr.createRes(scene,resName,tag)
        CSResourceMgr.setRelativePosition(resName, 320, 480, tag)
        Layer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        
        board = CSResourceMgr.getNodeByName(resName,"board",tag)
        board:setVisible(false)
        CSResourceMgr.getNodeByName(resName, "block", tag):setOpacity(100)
        
        local keyNode = CSResourceMgr.getNodeByName(resName, {"board","db1","slot"}, tag)
        local icon = CSResourceMgr.seekNodeByName(keyNode, "icon")
        local numLabel = CSResourceMgr.seekNodeByName(keyNode, "num")
        
        local itemNum = 1
        local keyNum  = ItemInfo.getCharItemNum(keyID)
        if useMCash then
            CSResourceMgr.setLabelColorByNode(numLabel,{r=255,g=0,b=0,a=255})
        end
        
        local dbTexture = ItemInfo.getItemRareBGImage(keyID)
        CSResourceMgr.setButtonTextureByNode(keyNode,dbTexture,dbTexture,dbTexture)
        local iconTexture = ItemInfo.getItemInfoById(keyID).icon
        icon:loadTexture(iconTexture)
        CSResourceMgr.setLabelStringByNode(numLabel,keyNum.."/"..itemNum)
        
        CSResourceMgr.buttonEventBinding(resName,{"board","db1","slot"},function()
            local info = {id = keyID, sum = itemNum, type = 2}
            ItemInfoViewMgr.show(info, false)
        end,function()
            ItemInfoViewMgr.hide()
        end,function()
        end,function()
            ItemInfoViewMgr.hide()
        end,tag)
        
        local awardID = {}
        for _,v in pairs(randomChestInfo.randomAwardIDFirst) do
            table.insert(awardID, v)
        end
        for _,v in pairs(randomChestInfo.randomAwardIDSecond) do
            table.insert(awardID, v)
        end
        for _,v in pairs(randomChestInfo.randomAwardIDThird) do
            table.insert(awardID, v)
        end
        for _,v in pairs(randomChestInfo.randomAwardIDFourth) do
            table.insert(awardID, v)
        end
        
        local itemNumber = (#awardID > 4) and 4 or #awardID
        
        local db2 = CSResourceMgr.getNodeByName(resName, {"board", "db2"}, tag)
        local _sample = CSResourceMgr.getNodeByName(resName, {"board", "db2", "slot"}, tag)
        _sample:hide()
        local x, y = _sample:getPosition()
        local _x = x - 50 * (itemNumber - 1)
        for i = 1, itemNumber do
            --[[
            local node = _sample
            if i ~= 1 then 
                node = _sample:clone()
                db2:addChild(node)
            end
            
            node:setPosition(_x + 100 * (i - 1), y) 
            
            local itemID = LostTowerInfo.getLostTowerAwardInfoById(awardID[i]).itemID

            local dbTexture = ItemInfo.getItemRareBGImage(itemID)
            CSResourceMgr.setButtonTextureByNode(node,dbTexture,dbTexture,dbTexture)
            local icon = CSResourceMgr.seekNodeByName(node, "icon")
            local iconTexture = ItemInfo.getItemInfoById(itemID).icon
            icon:loadTexture(iconTexture)
            ]]
            local itemID = LostTowerInfo.getLostTowerAwardInfoById(awardID[i]).itemID
            local node = ItemInfo.getItemIconById(itemID, nil, nil, true)
            node:addTo(db2)
            node:setPosition(_x + 100 * (i - 1), y)
            node:scale(0.6)
            CSResourceMgr.buttonEventBindingByNode(node,function()
                local info = {id = itemID, sum = 1, type = 2}
                ItemInfoViewMgr.show(info, false)
            end,function()
                ItemInfoViewMgr.hide()
            end,function()
            end,function()
                ItemInfoViewMgr.hide()
            end)
        end
    end
    
    local function init()
        local titleLabel1 = CSResourceMgr.getNodeByName(resName,{"board", "banner", "title1"}, tag)
        CSResourceMgr.setLabelColorByNode(titleLabel1, {r=255,g=255,b=83,a=255})
        CSResourceMgr.setLabelStringByNode(titleLabel1, "LtText51") -- "新发现！"
        titleLabel1:enableOutline({r=146,g=49,b=29,a=255}, 1)

        local tipsText = "LtText52"
        -- if useMCash then tipsText = "LtText56" end
        
        local tipLabel = CSResourceMgr.getNodeByName(resName,{"board", "db1", "tip"}, tag)
        CSResourceMgr.setLabelColorByNode(tipLabel, {r=144,g=238,b=255,a=255})
        CSResourceMgr.setLabelStringByNode(tipLabel, CocosModuleMgr.createStringWithFormat({tipsText, randomChestInfo.stateName})) -- "发现一个黄金宝箱，打开需要以下道具"
        tipLabel:enableOutline({r=38,g=54,b=76,a=255}, 1)
        CSResourceMgr.setLabelMaxWidth(resName,{"board", "db1", "tip"},400,tag)
        tipLabel:setAnchorPoint(0.5, 0.5)

        local titleLabel2 = CSResourceMgr.getNodeByName(resName,{"board", "banner2", "title2"}, tag)
        CSResourceMgr.setLabelStringByNode(titleLabel2, "LtText53") -- "机率获得"
        titleLabel2:enableOutline({r=209,g=138,b=0,a=255}, 1)
        
        CSResourceMgr.setButtonString(resName, {"board", "cancel"}, "LtText54",tag) -- "放弃"
        
        if useMCash then
            CSResourceMgr.setButtonString(resName, {"board", "open"}, "",tag) -- ""
            local button = CSResourceMgr.getNodeByName(resName,{"board", "open"},tag)
            CSResourceMgr.seekNodeByName(button,"diamond"):setVisible(true)
            CSResourceMgr.seekNodeByName(button,"d_num_l"):setVisible(true)
            
            local label = CSResourceMgr.seekNodeByName(button,"d_num_l")
            CSResourceMgr.setLabelStringByNode(label,consume_mcash)
            
            if consume_mcash > CharInfo.getMCash() then
                CSResourceMgr.setLabelColorByNode(label,{r=255,g=0,b=0,a=255})
            else
                CSResourceMgr.setLabelColorByNode(label,{r=255,g=255,b=255,a=255})
            end
        else
            CSResourceMgr.setButtonString(resName, {"board", "open"}, "LtText55",tag) -- "打开"
            local button = CSResourceMgr.getNodeByName(resName,{"board", "open"},tag)
            CSResourceMgr.seekNodeByName(button,"diamond"):setVisible(false)
            CSResourceMgr.seekNodeByName(button,"d_num_l"):setVisible(false)
        end
        
    end
    
    local function playAction()
        board:setVisible(true)
        CocosModuleMgr.showUIAnimation(board, "down")
        
        local fade = cc.FadeTo:create(0.2, 180)  -- 70%
        CSResourceMgr.getNodeByName(resName, "block", tag):runAction(fade)
    end
    
    local function bindEvent()
--        CSResourceMgr.clickEventBinding(resName,"block",function()
--            LtOpenBoxView.hide()
--        end,tag)
        CSResourceMgr.clickEventBinding(resName,{"board", "cancel"},function()
            GameAudio.playUISound("retract")
            LtOpenBoxView.hide()
        end,tag)
        CSResourceMgr.clickEventBinding(resName,{"board", "open"},function()
            LtOpenBoxView.hide()
            
            if useMCash then
                if consume_mcash > CharInfo.getMCash() then
                    StandardTipsMgr.show(1,"tips14")   -- 钻石不足
                else
                    if callback then callback() end
                end
            else
                if callback then callback() end
            end
        end,tag)
    end
    
    local funcTable = { loadCSB, init, playAction, bindEvent, }
    
    UnblockLoader.load(funcTable,tag)
    
--    for i=1, #funcTable do funcTable[i]() end
    
end

function LtOpenBoxView.hide()
    UIStack.pop("LtOpenBoxView")
    CSResourceMgr.removeCSObjectByTag(resName,tag)
end

return LtOpenBoxView