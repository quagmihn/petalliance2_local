local propMgr = {}

local aniTable = {}

local shadowNode = nil
local shadowExists = false
local shadowRes = "Searching/ShadowLayer.csb"

local currentItemIndex = 0 --当前使用道具所在位置

local PROP_NUM_MAX = 4

local function addToUseRecord(record, info)
    table.insert(record, info)
end

---清空道具slot
local function clearPropSlot(slot)
    addToUseRecord(SearchingMapMgr.propUseRecord[SearchingMapMgr.currFloor],{index = slot, info = SearchingMapMgr.allItems[slot]})

    --道具取事件清空
    CSResourceMgr.setButtonTexture(SearchingUIMgr.bottomResName,"prop"..slot,"empty.png","empty.png","empty.png")
    CSResourceMgr.clickEventBinding(SearchingUIMgr.bottomResName,"prop"..slot, function(sender, state)
        print("事件清空了")
    end)
end

function propMgr.removeShadow()
    shadowExists = false
    
    if shadowNode then
        pcall(function()
            shadowNode:removeFromParent()
        end)
        shadowNode = nil
    end
end

---移除阴影层以及作用对象
local function removeAll()
    for k, ani in pairs(aniTable) do
        if AnimationMgr.getGafObj(ani.res,ani.tag) then
            AnimationMgr.removeGafObjectByTag(ani.res, ani.tag)
        end
    end
    aniTable = {}

    for k=1, LtMapOption.getMapSize() do
        CSResourceMgr.removeCSObjectByTag("Searching/Node.csb", k)
    end
    
    propMgr.removeShadow()
end

---覆盖阴影屏蔽层
--@return #node 阴影层节点
local function addShadow()
    if shadowExists then return end
    
    shadowExists = true

    --覆蓋屏蔽層
    local board = SearchingUIMgr.getBlockContainer()
    
    shadowNode = CSResourceMgr.getNodeByName(SearchingUIMgr.centerResName,{"fog","groundSample"}):clone()
    shadowNode:setVisible(true)
    
    local x, y = board:getInnerContainer():getPosition()
    local w, h = board:getInnerContainerSize().width, board:getInnerContainerSize().height
    
    local img = "UI/CommonFiles/misc_base_01.png"
    CSResourceMgr.setButtonTextureByNode(shadowNode,img,img,img)
    shadowNode:setOpacity(160)
    shadowNode:setPosition(w / 2, h / 2)
    shadowNode:setAnchorPoint(0.5,0.5)
    shadowNode:setContentSize(w + 2*104,h + 4*104)
    shadowNode:setColor({r=0,g=0,b=0,a=255})
    shadowNode:setLocalZOrder( SearchingUIMgr.ZORDER_COVER_SHADOW )
    
    board:addChild(shadowNode)
    
    --阴影层
    CSResourceMgr.clickEventBindingByNode(shadowNode, function(sender, state)
        removeAll()
        currentItemIndex = 0
    end)
    
    return shadowNode
end

---添加作用对象UI
local function addTargetUI(board,block)
    local node = CSResourceMgr.createRes(board,"Searching/Node.csb",block)
    local btn = CSResourceMgr.getNodeByName("Searching/Node.csb","stone",block)
    local img = "Searching/empty.png"
    CSResourceMgr.setButtonTexture("Searching/Node.csb", "stone",  img,  img,  img, block)
    btn:setContentSize(SearchingUIMgr.BLOCK_WIDTH, SearchingUIMgr.BLOCK_HEIGHT)

    local _x = SearchingUIMgr.BLOCK_WIDTH/2
    local _y = SearchingUIMgr.BLOCK_HEIGHT/2 - 30
    
    local aniRes = SearchingMgr.itemTypeTable[block].aniRes
    if not aniRes or aniRes == "" then
        local sp = display.newSprite(SearchingMgr.itemTypeTable[block].resName[1])
        btn:addChild(sp)
        sp:setPosition(52, 52)
    else
        local resName =  aniRes  -- "Spine/searching/"..aniRes..".png"
        local kbsAni = AnimationMgr.createAni(btn, resName, _x, _y, "4prop"..block)
        AnimationMgr.playAni(resName, "animation", true, "4prop"..block)
        
        table.insert(aniTable, kbsAni)
    end

    local x, y = SearchingUIMgr.getBlockNode(block):getPosition()
    node:setPosition(x, y)
    node:setLocalZOrder( SearchingUIMgr.ZORDER_COVER_SHADOW+1 )
end

--*****************************  道具事件func定义    ********************************
---笛子作用于卡比兽
local function dizi_kbs_func(k)
    if SearchingMgr.mapInfoTable[k] == 0 then
        SearchingUIMgr.TurnToBlock(k)
        
        local pickItemInfo = SearchingMapMgr.allItems[currentItemIndex].info
        
        local emoji = tonumber(pickItemInfo.openAni) or 0
        local smood = CocosModuleMgr.showMood(SearchingMgr.player, emoji, -20, 80, true)
        if smood then
            smood:setScale(0.6, 0.6)
            smood:setLocalZOrder(101)
        end

        SceneMgr.getRunningScene:performWithDelay(function()

            --检查副本目标
            SearchingMgr.eventStateInfoTable[k] = 3
            SearchingMgr.checkGoals(k)

            local aniRes = SearchingMgr.itemTypeTable[k].aniRes
            if aniRes and aniRes ~= "" then
                local resName = aniRes  -- "Spine/searching/"..aniRes..".png"
                AnimationMgr.removeGafObjectByTag(resName, "4prop"..k)
                AnimationMgr.removeGafObjectByTag(resName, k)
            end

            --更新方格
            SearchingMgr.eventInfoTable[k] = SearchingMapMgr.EVENT_VOID
            SearchingMgr.itemTypeTable[k] = {}
            SearchingUIMgr.hideBlock(k)
            SearchingMgr.unlockTonari(k)

            --道具取事件清空
            clearPropSlot(currentItemIndex)
            table.remove(SearchingMapMgr.allItems, currentItemIndex)
            propMgr.refreshProps()
            currentItemIndex = 0
            
            SearchingUIMgr.blockClickEvent(k, function()
                SearchingMgr.blockClickedEvent(k)
            end)

            --  刷新训练师视野
            for _, char in pairs(AdvCharMgr.getTrainers()) do
                AdvCharMgr.setTrainerVision(char)
            end

        end, 0.5)

        SceneMgr.getRunningScene:performWithDelay(function()
            SearchingMgr.checkGoals(k)
        end, 0.7)
    end
    
    removeAll()
    
end


-- 命名规则
-- %prop%_%target%
local propFuncDef = {
    dizi_kbs   = dizi_kbs_func,
    
}

--********************************************************************************

---添加作用对象点击事件
local function addTargetEvent(k,callback)
    CSResourceMgr.clickEventBinding("Searching/Node.csb", "stone", function(sender, state)
        if callback then
            callback(k)
        end
        
        local x, y = SearchingUIMgr.getBlockNode(k):getPosition()
        local parent = SearchingUIMgr.getBlockContainer()
        local effAni = AnimationMgr.createAni(parent, "Spine/effects/UI_daojudianji.png",x,y,k)
        effAni:setLocalZOrder(SearchingUIMgr.ZORDER_COVER_SHADOW)
        AnimationMgr.playAniWithCallback(effAni.res, "animation", nil, k, true)
    end,k)
end

---添加道具有效作用对象
--@param info table 道具信息
local function addTargets(info)
    local targetType = info.targetType or LtEventOption.EVENT_OBSTRUCTION
    local board = SearchingUIMgr.getBlockContainer()
    for k=1,LtMapOption.getMapSize() do
        if SearchingMgr.itemTypeTable[k].id == tonumber(info.target) then
            if SearchingMgr.mapInfoTable[k] == 0 then
                if SearchingMgr.eventInfoTable[k] == targetType then
                    local func = "dizi_kbs"
                    addTargetUI(board,k)
                    addTargetEvent(k,propFuncDef[func])
                end
            end
        end
    end
end

local function showPropDesc(slot,info)

    local scene = SceneMgr.getRunningScene
    local curLayer
    local resName = "Searching/Common/propDesc.csb"

    local function loadCSB()
        curLayer = CSResourceMgr.createRes(scene, resName,slot)
        curLayer:setLocalZOrder(25)
        CSResourceMgr.setRelativePosition(resName, 320, 480)

        local itemName = CSResourceMgr.getNodeByName(resName,"propname")
        local itemDesc = CSResourceMgr.getNodeByName(resName,"propdesc")
        CSResourceMgr.setLabelString(resName,info.name,"",{r=0,g=0,b=0,a=255})
        CSResourceMgr.setLabelString(resName,info.desc,"",{r=0,g=0,b=0,a=255})
    end

    local function playCSB()
    end

    local funcTable = {loadCSB, playCSB}

    UnblockLoader.load(funcTable)
end

local function hidePorpDesc(slot)
    local resName = "Searching/Common/propDesc.csb"
    CSResourceMgr.removeCSObjectByTag(resName,slot)
end

---添加道具
function propMgr.addProp(slot,img,info)
    if slot<0 and slot>4 then
        print("ADV_DEBUG_INFO:道具slot越界")
        return
    end

    SearchingMapMgr.allItems[slot] = {
        img = img,
        info = info,
        target = info.target,
        targetType = info.targetType,
    }
    
    --添加道具栏icon
    local daoju = CSResourceMgr.getNodeByName(SearchingUIMgr.bottomResName,"prop"..slot)
    CSResourceMgr.setButtonTexture(SearchingUIMgr.bottomResName,"prop"..slot,  img,  img,  img)
    
    --点击事件[CSResourceMgr.ButtonFuncTable中添加]
    CSResourceMgr.clickEventBinding(SearchingUIMgr.bottomResName,"prop"..slot, function(sender, state)
        if currentItemIndex ~= 0 then return end
    
        addShadow()
        currentItemIndex = slot
        addTargets(SearchingMapMgr.allItems[slot])
    end,"",true)
    
--    local itemDescViewMgr = require("src.GameMgr.Searching.itemDescViewMgr")
--    local scheduler = require("framework.scheduler")
--    local useFlag = true
--    local handle
--    local s, e  -- 按钮点击开始/结束时间
--    
--    local function touchFunc()
--        s = os.clock()
--        handle = scheduler.scheduleGlobal(function()  --长按监听
--            e = os.clock()
--            -- print(s,e,e-s)
--            if e-s > 0.5 then
--                useFlag = false
--                itemDescViewMgr.show(info)
--                scheduler.unscheduleGlobal(handle)
--            end
--        end, 0.01)
--    end
--    
--    local function clickFunc()
--        if handle ~= nil then scheduler.unscheduleGlobal(handle) end
--        if useFlag then
--            addShadow()
--            currentItemIndex = slot
--            addTargets(SearchingMapMgr.allItems[slot])
--        else
--            useFlag = true
--            itemDescViewMgr.hide()
--        end
--    end
--    
--    local function dragFunc()
--    end
--    
--    local function cancelFunc()
--        if handle ~= nil then scheduler.unscheduleGlobal(handle) end
--        if useFlag then
--        else
--            useFlag = true
--            itemDescViewMgr.hide()
--        end
--    end
--    
--    CSResourceMgr.buttonEventBindingByNode(daoju,touchFunc,clickFunc,dragFunc,cancelFunc)
end

---设置所有道具, 清空当前使用的道具
function propMgr.setAllProp()
    -- if #SearchingMapMgr.allItems == 0 then return end
    for slot=1,#SearchingMapMgr.allItems do
        if SearchingMapMgr.allItems[slot] and SearchingMapMgr.allItems[slot]["info"] then
            local img = SearchingMapMgr.allItems[slot]["img"]
            propMgr.addProp(slot,img,SearchingMapMgr.allItems[slot]["info"])
        end
    end
    currentItemIndex = 0
end

function propMgr.refreshProps()
    for i = 1, PROP_NUM_MAX do
        CSResourceMgr.setButtonTexture(SearchingUIMgr.bottomResName,"prop"..i,"empty.png","empty.png","empty.png")
        CSResourceMgr.clickEventBinding(SearchingUIMgr.bottomResName,"prop"..i, function() end)
    end
    
    propMgr.setAllProp()
end

return propMgr