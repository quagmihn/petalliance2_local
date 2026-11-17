local LtPropMgr = {}

LtPropMgr.isChecking = true  -- 等待选择

local MAX_PROP_NUM = 4

local shadowNode = nil

local propTable = {}

local currentItemIndex = 0 --当前使用道具所在位置

function LtPropMgr.Init()
    propTable = {}
end

function LtPropMgr.test()
    print("currentItemIndex", currentItemIndex)
end

local function handleWhileFull(pickCallback, passCallback)
    local _shadow = CSResourceMgr.getNodeByName(LostTowerUIMgr.centerResName,{"ScrollView","fog","groundSample"}):clone()
    local _label  = CSResourceMgr.getNodeByName(LostTowerUIMgr.bottomResName,"hp_eff_l"):clone()
    
    _shadow:setVisible(true)

    local img = "UI/CommonFiles/misc_base_01.png"
    CSResourceMgr.setButtonTextureByNode(_shadow,img,img,img)
    _shadow:setOpacity(160)
    _shadow:setPosition(320, 0)
    _shadow:setAnchorPoint(0.5,0.0)
    _shadow:setContentSize(720,1136)
    _shadow:setColor({r=0,g=0,b=0,a=255})
    _shadow:setLocalZOrder( CocosModuleMgr.ZORDER_FLOAT )
    SceneMgr.getRunningScene:addChild(_shadow)

    local parent = CSResourceMgr.getNodeByName(LostTowerUIMgr.bottomResName,"prop")
    local posx, posy, ccp
    for i = 1, MAX_PROP_NUM do
        local prop = propTable[i]

        local srcNode = CSResourceMgr.getNodeByName(LostTowerUIMgr.bottomResName,{"prop","prop"..i})
        local node = srcNode:clone()
        posx, posy = srcNode:getPosition()
        ccp = parent:convertToWorldSpace(cc.p(posx,posy))

        _shadow:addChild(node)
        node:setPosition(ccp.x + 40, ccp.y)

        CSResourceMgr.clickEventBindingByNode(node,function()
            if pickCallback then pickCallback(i) end
            _shadow:removeAllChildren()
            _shadow:removeFromParent()
        end)
    end

    _label:ignoreContentAdaptWithSize(true)
    CSResourceMgr.setLabelStringByNode(_label,"LtTips17",nil,nil,390)
    _shadow:addChild(_label)
    _label:setPosition(320 + 40, ccp.y + 80)

    CSResourceMgr.clickEventBindingByNode(_shadow,function()
        DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene,2,"LtTips18",function()    -- 确认放弃道具
            if passCallback then passCallback() end
            _shadow:removeAllChildren()
            _shadow:removeFromParent()
        end, function()
            _shadow:removeAllChildren()
            _shadow:removeFromParent()
        end)
    end)

end 

function LtPropMgr.getPropTable()
    return propTable
end

function LtPropMgr.isPropFull()
    return #propTable >= MAX_PROP_NUM
end

function LtPropMgr.isPropBlock(block)
    if SearchingMgr.eventInfoTable[block] ~= LtEventOption.EVENT_PICKING then
        return false
    end
    if tonumber(SearchingMgr.itemTypeTable[block].type) ~= 1 then
        return false
    end
    
    return true
end

function LtPropMgr.checkPicking(block)
    if not LtPropMgr.isPropFull() then return end

    local propID = SearchingMgr.itemTypeTable[block].id
    
    handleWhileFull(function(index)
        LtPropMgr.isChecking = false
        SearchingMgr.moveWithCallback(block)
        SceneMgr.getRunningScene:performWithDelay(function()
            LtPropMgr.isChecking = true
            LtPropMgr.dropProp(index,function()
                -- LtPropMgr.addPropTo(index, propID)
                LtPropMgr.resetAllProps()
            end)
        end, 0.25)
    end,function()
        LtPropMgr.isChecking = false
        SearchingMgr.moveWithCallback(block)
        SceneMgr.getRunningScene:performWithDelay(function()
            LtPropMgr.isChecking = true
            local LostTowerSend = require("src.Net.Send.LostTowerSend")
            NetInterface.sendWithBlock("GC_USELOSTTOWERITEM_ACK",function()
                LostTowerSend.sendCG_UseLostTowerItem_Req({itemID = propID})
            end,function()
            end)
        end, 0.25)
    end)
end

-- #######################   Logic action   #########################

--- 初始道具数据
function LtPropMgr.setPropTable(data)
    local cjson = require("cjson")

    propTable = {}
    for k, v in pairs(data) do
        local vv = cjson.decode(v)
        table.insert(propTable, {propID = vv.itemID, num = 1})
    end
end

--- 刷新方格index上的道具
function LtPropMgr.resetPropAt(index)
end

--- 添加道具到方格index上
function LtPropMgr.addPropTo(index, propID)
    propTable[index] = {
        propID = propID,
        num    = 1,
    }
    
    local propInfo = LostTowerInfo.getPickUpItemInfoById(propID)
    
    local propNode = CSResourceMgr.getNodeByName(LostTowerUIMgr.bottomResName,{"prop","prop"..index})
    local icon = (propInfo ~= nil) and propInfo.path or ""
    CSResourceMgr.setButtonTextureByNode(propNode,icon,icon,icon)
    
    CSResourceMgr.clickEventBindingByNode(propNode,function()
        if currentItemIndex ~= 0 then return end
        
        currentItemIndex = index
        local targetID = propInfo.effectObj or 0
        LtPropMgr.addTargets({target=targetID})
    end,1)
    
--    local px, py
--    local beginX, beginY
--    local pxOffset, pyOffset
--    local scale_0 = 1.0
--    local scale_1 = 1.1
--    local scale_2 = 1.2
--    local moved = false
--    
--    local function touchFunc(sender)
--        moved = false
--        sender:setScale(scale_1)
--
--        px, py = sender:getPosition()
--        beginX = sender:getTouchBeganPosition().x
--        beginY = sender:getTouchBeganPosition().y
--        pxOffset = px - beginX
--        pyOffset = py - beginY
--    end
--    
--    local function clickFunc(sender)
--        if moved then return end
--        currentItemIndex = index
--        local board = SearchingUIMgr.getBlockContainer()
--        local targetID = propInfo.effectObj or 0
--        LtPropMgr.addTargets({target=targetID})
--        propNode:setScale(scale_0)
--    end
--    
--    local function dragFunc(sender)
--        moved = true
--        local pos = propNode:getTouchMovePosition()
--        propNode:setPosition(px, pos.y + pyOffset)
--        local d = 100 + math.sqrt((beginX - pos.x)*(beginX - pos.x) + (beginY - pos.y)*(beginY - pos.y))
--        propNode:setScale(100*scale_1/d)
--    end
--    
--    local function cancelFunc(sender)
--        if moved then return end
--        propNode:setScale(scale_0)
--    end
--    
--    CSResourceMgr.buttonEventBindingByNode(propNode,touchFunc,clickFunc,dragFunc,cancelFunc)
end

--- 删除方格index上的道具
function LtPropMgr.delPropAt(index)
    -- propTable[index] = {}
    table.remove(propTable,index)
    local propNode = CSResourceMgr.getNodeByName(LostTowerUIMgr.bottomResName,{"prop","prop"..index})
    local icon = "empty.png"
    CSResourceMgr.setButtonTextureByNode(propNode,icon,icon,icon)
    CSResourceMgr.clickEventBindingByNode(propNode,function()
        print("clear button click event")
    end)
end

--- init picked props and current item index
function LtPropMgr.setPickedProps()
    for i = 1, #propTable do
        LtPropMgr.addPropTo(i, propTable[i].propID)
    end
    currentItemIndex = 0
end

-- ###########################   User action    ############################

--- 拾取道具
function LtPropMgr.pickProp(propID)
    if #propTable >= MAX_PROP_NUM then
--        handleWhileFull(function(index)
--            LtPropMgr.dropProp(index,function()
--                LtPropMgr.addPropTo(index, propID)
--            end)
--        end, function()
--            local LostTowerSend = require("src.Net.Send.LostTowerSend")
--            NetInterface.sendWithBlock("GC_USELOSTTOWERITEM_ACK",function()
--                LostTowerSend.sendCG_UseLostTowerItem_Req({itemID = propID})
--            end,function()
--            end)
--        end)
    else
        LtPropMgr.addPropTo(#propTable + 1, propID)
    end
end

--- 丢弃道具
function LtPropMgr.dropProp(index, callback)
    local LostTowerSend = require("src.Net.Send.LostTowerSend")
    NetInterface.sendWithBlock("GC_USELOSTTOWERITEM_ACK",function()
        LostTowerSend.sendCG_UseLostTowerItem_Req({itemID = propTable[index].propID})
    end,function()
        LtPropMgr.delPropAt(index)
        if callback then callback() end
    end)
end

--- 使用道具
function LtPropMgr.useProp(index)
    local info = propTable[index]
    
    info.num = info.num or 1
    if info.num > 1 then
        info.num = info.num - 1
        LtPropMgr.resetPropAt(index)
    elseif info.num == 1 then
        LtPropMgr.delPropAt(index)
    else
        print("ERROR")
    end
end

function LtPropMgr.sendUseItemReq(index,callback)
    local LostTowerSend = require("src.Net.Send.LostTowerSend")
    NetInterface.sendWithBlock("GC_USELOSTTOWERITEM_ACK",function()
        LostTowerSend.sendCG_UseLostTowerItem_Req({itemID = propTable[index].propID})
    end,function()
        LtPropMgr.useProp(index)
        LtPropMgr.resetAllProps()
        if callback then callback() end
    end)
end

--- 刷新所有道具
function LtPropMgr.resetAllProps()
    local emptyTex = "empty.png"
    
    for i = 1, MAX_PROP_NUM do
        local propNode = CSResourceMgr.getNodeByName(LostTowerUIMgr.bottomResName,{"prop","prop"..i})
        CSResourceMgr.setButtonTextureByNode(propNode,emptyTex,emptyTex,emptyTex)
        CSResourceMgr.clickEventBindingByNode(propNode,function() end)
    end
    
    for i = 1, #propTable do
        LtPropMgr.addPropTo(i, propTable[i].propID)
    end
end

--- 删除所有道具
function LtPropMgr.clearAllProps()
    for i=1, #propTable do
        LtPropMgr.delPropAt(i)
    end
    propTable = {}
end

--*****************************  道具事件func定义    ********************************
---笛子作用于卡比兽
local function dizi_kbs_func(k)
    if SearchingMgr.mapInfoTable[k] == 0 then
        SearchingUIMgr.TurnToBlock(k)
        
        local pid = propTable[currentItemIndex].propID
        local pickItemInfo = LostTowerInfo.getPickUpItemInfoById(pid) or {}
        
        local emoji = tonumber(pickItemInfo.expressionRes) or 0
        local smood = CocosModuleMgr.showMood(SearchingMgr.player, emoji, -20, 110, true)
        if smood then
            smood:setScale(0.6, 0.6)
            smood:setLocalZOrder(101)
        end

        SceneMgr.getRunningScene:performWithDelay(function()
            LtPropMgr.sendUseItemReq(currentItemIndex,function()
                LtFuncMgr.sendFireReq({
                    fireCell = k,
                    successCallback = function()
                        local aniRes = SearchingMgr.itemTypeTable[k].aniRes
                        if aniRes and aniRes ~= "" then
                            local resName = aniRes  -- "Spine/searching/"..aniRes..".png"
                            AnimationMgr.removeGafObjectByTag(resName, "4prop"..k)
                            AnimationMgr.removeGafObjectByTag(resName, k)
                        end
                        
                        currentItemIndex = 0
                        
                        SearchingMgr.eventStateInfoTable[k] = 3
                        SearchingUIMgr.clearBlock(k)
                        SearchingMgr.unlockTonari(k)
                    end
                })
            end)
        end, 0.5)
        
        LtPropMgr.removeAllTargets()
    end
end


-- 命名规则
-- %prop%_%target%
local propFuncDef = {
    dizi_kbs = dizi_kbs_func,

}

function LtPropMgr.addShadow(parent)
    if shadowNode then return end

    local board = SearchingUIMgr.getBlockContainer()

    shadowNode = CSResourceMgr.getNodeByName(LostTowerUIMgr.centerResName, "blockSample"):clone()
    
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
    
    CSResourceMgr.clickEventBindingByNode(shadowNode,function()
        LtPropMgr.removeAllTargets()
        currentItemIndex = 0
    end)
end

---添加作用对象UI
local function addTargetUI(board,block)
    local tag = "PropTargetAt"..block
    local node = CSResourceMgr.createRes(board,"Searching/Node.csb",tag)
    local btn = CSResourceMgr.getNodeByName("Searching/Node.csb","stone",tag)
    local img = "Searching/empty.png"
    CSResourceMgr.setButtonTexture("Searching/Node.csb", "stone",  img,  img,  img, tag)
    btn:setContentSize(SearchingUIMgr.BLOCK_WIDTH, SearchingUIMgr.BLOCK_HEIGHT)
    
    local aniRes = SearchingMgr.itemTypeTable[block].aniRes
    if not aniRes or aniRes == "" then
        local sp = display.newSprite(SearchingMgr.itemTypeTable[block].resName[1])
        btn:addChild(sp)
        sp:setPosition(52, 52)
    else
        if cc.FileUtils:getInstance():isFileExist(aniRes) then
            local _x = SearchingUIMgr.BLOCK_WIDTH/2
            local _y = SearchingUIMgr.BLOCK_HEIGHT/2 - 30
            local kbsAni = AnimationMgr.createAni(btn, aniRes, _x, _y, "4prop"..block)
            AnimationMgr.playAni(aniRes, "animation", true, "4prop"..block)
        end
    end

    local x, y = SearchingUIMgr.getBlockNode(block):getPosition()
    node:setPosition(x, y)
    node:setLocalZOrder( SearchingUIMgr.ZORDER_COVER_SHADOW+1 )
end

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
    end,"PropTargetAt"..k)
end

---添加道具有效作用对象
--@param info table 道具信息
function LtPropMgr.addTargets(info)
    if shadowNode then return end

    local targetType = SearchingMapMgr.EVENT_OBSTRUCTION
    local board = SearchingUIMgr.getBlockContainer()
    
    local function check(_k)
        if SearchingMgr.mapInfoTable[_k] ~= 0 then return false end
        if not LtWarFogMgr.isExplored(_k) then return false end
        if tonumber(SearchingMgr.itemTypeTable[_k].id) ~= info.target then return false end
        if SearchingMgr.eventInfoTable[_k] ~= targetType then return false end
        
        return true
    end

    LtPropMgr.addShadow(board)
    for k=1,LtMapOption.getMapSize() do
        if check(k) then 
            local func = "dizi_kbs"
            addTargetUI(board,k)
            addTargetEvent(k,propFuncDef[func])
        end
    end
    
end

function LtPropMgr.removeShadowNode()
    if shadowNode then
        pcall(function()
            shadowNode:removeFromParent()
        end)
        shadowNode = nil
    end
end

---移除阴影层以及作用对象
function LtPropMgr.removeAllTargets()
    --删除所有道具作用对象
    for k=1, LtMapOption.getMapSize() do
        CSResourceMgr.removeCSObjectByTag("Searching/Node.csb", "PropTargetAt"..k)
    end
    
    LtPropMgr.removeShadowNode()
end


return LtPropMgr