local LtWarFogMgr = {}

LtWarFogMgr.ZORDER_WARFOG = 100

LtWarFogMgr.ZORDER_ADDED_1 = 1
LtWarFogMgr.ZORDER_ADDED_2 = 2

local exploredArea = {}
local lightenArea  = {}

local stencilNode
local clippingNode

local warfogNode
local blockNodeTable = {}

local darkEffTable   = {}

function LtWarFogMgr.getDarkNodes()
    return blockNodeTable
end

local function calcVisualField(center, radius)
    local col, row = center.col, center.row
    
    local ret = {}
    
    local dy = 0
    for i = radius, 0, -1 do
        for k = -i, i, 1 do
            if LtMapOption.isOnBoard(col + k, row + dy) then
                table.insert(ret, LtMapOption.convertToIndex(col + k, row + dy))
            end
            if dy ~= 0 then
                if LtMapOption.isOnBoard(col + k, row - dy) then
                    table.insert(ret, LtMapOption.convertToIndex(col + k, row - dy))
                end
            end
        end
        dy = dy + 1
    end
    
    return ret
end

local function calcExploredArea(movedCells)
    local data = {}
    
    for index, v in pairs(movedCells) do
        local col, row = LtMapOption.convertToCoord(index)
        local center = {col = col, row = row}
        
        local visualField = calcVisualField(center, 2)
        for k,v in pairs(visualField) do
            if not data[v] then data[v] = true end
        end
    end
    
    return data
end

local function calcLightenArea(movedCells)
    local data = {}
    
    for index, v in pairs(movedCells) do
        local col, row = LtMapOption.convertToCoord(index)
        local center = {col = col, row = row}

        local _lightenBlocks = LtMapOption.getAllNeighbour(index)
        for k,v in pairs(_lightenBlocks) do
            if not data[v] then data[v] = true end
        end
    end
    
    return data
end

local function getBlockNode(i)
    local char = AdvCharMgr.getTrainerByPos(i)
    if char then
        return char.info.node
    else
        return SearchingUIMgr.getBlockNode(i)
    end
end

local function setBlockNodeZOrder(i)
    local node = getBlockNode(i)
    node:setLocalZOrder(SearchingUIMgr.calcZOrderAt(i))
end

function LtWarFogMgr.Init()
    exploredArea = {}
    lightenArea  = {}
    blockNodeTable = {}
end

function LtWarFogMgr.clear()
    exploredArea = {}
    lightenArea  = {}

    for k, v in pairs(blockNodeTable) do
        if blockNodeTable[k] then blockNodeTable[k]:removeFromParent() end
        blockNodeTable[k] = nil
    end
    blockNodeTable = {}
    
    for k, eff in pairs(darkEffTable) do
        AnimationMgr.removeGafObjectByTag(eff.res,eff.tag)
        darkEffTable[k] = nil
    end
    
end

function LtWarFogMgr.initWarFog(movedCells)
    exploredArea = calcExploredArea(movedCells)
    lightenArea  = calcLightenArea(movedCells)
    
    warfogNode = CSResourceMgr.getNodeByName(LostTowerUIMgr.centerResName,{"ScrollView","fog"})
    local warFogBlockNode = CSResourceMgr.getNodeByName(LostTowerUIMgr.centerResName,{"ScrollView","warFog","warFogBlock"})
    
--    for k, v in pairs(blockNodeTable) do
--        if blockNodeTable[k] then blockNodeTable[k]:removeFromParent() end
--        blockNodeTable[k] = nil
--    end
    blockNodeTable = {}
    
    for i = 1, LtMapOption.getMapSize() do
        if not movedCells[i] then
            local x, y = SearchingUIMgr.getBlockNode(i):getPosition()

            local eff = AnimationMgr.createAni(warfogNode,"Spine/effects/Ui_miwu.png",x,y,"warfogAni"..i)
            AnimationMgr.playAni(eff.res,"animation",true,eff.tag)
            eff:setScale(0.95)
            
            darkEffTable[i] = eff
            
            if exploredArea[i] then
                eff:setOpacity(166)
                eff:setLocalZOrder(SearchingUIMgr.calcZOrderAt(i) + 5)
                
                if lightenArea[i] then 
                    AnimationMgr.removeGafObjectByTag(eff.res,eff.tag)
                    darkEffTable[i] = nil
                end
            else
                local node = warFogBlockNode:clone()
                blockNodeTable[i] = node
                warfogNode:addChild(node)
                node:setPosition(x, y)

                eff:setLocalZOrder(SearchingUIMgr.calcZOrderAt(i) + 5)
                
                getBlockNode(i):setVisible(false)
            end
        end
    end
    
--    local rows = LtMapOption.getMapRows()
--    for i = 1, LtMapOption.getMapCols() do
--        local _block = LtMapOption.convertToIndex(i, rows)
--        local x0, y0 = SearchingUIMgr.getBlockNode(_block):getPosition()
--        local _x, _y = x0, y0 - 104
--        
--        local eff = AnimationMgr.createAni(warfogNode,"Spine/effects/Ui_miwu.png",_x,_y,"warfogAniAdded"..i)
--        AnimationMgr.playAni(eff.res,"animation",true,eff.tag)
--        eff:setScale(0.95)
--    end
    
    for i = 1, LtMapOption.getMapSize() do
        if lightenArea[i] then
            setBlockNodeZOrder(i)
        else
            if exploredArea[i] then setBlockNodeZOrder(i) end
        end
    end
    
    SearchingMgr.player:setLocalZOrder(SearchingUIMgr.calcZOrderAt(SearchingMgr.playerCurrPosition,true))
    
end

function LtWarFogMgr.refreshWarFog(movedcells, newCell)
    for k, v in pairs(movedcells) do
        if k == newCell then return end
    end
    movedcells[newCell] = true

    local col, row = LtMapOption.convertToCoord(newCell)
    local center = {col = col, row = row}

    local visualField = calcVisualField(center, 2)
    
    local eff = AnimationMgr.getGafObj("Spine/effects/Ui_miwu.png","warfogAni"..newCell)
    if eff then
        if blockNodeTable[newCell] then blockNodeTable[newCell]:removeFromParent() end
        blockNodeTable[newCell] = nil
        AnimationMgr.removeGafObjectByTag(eff.res,eff.tag)
        darkEffTable[newCell]   = nil
    end
    
    local neighbours = LtMapOption.getAllNeighbour(newCell)
    local _lightenField = {}
    for k, v in pairs(neighbours) do _lightenField[v] = true end
    
    for k, v in pairs(visualField) do
        if _lightenField[v] then
            if not lightenArea[v] then
                lightenArea[v] = true
                local _eff = AnimationMgr.getGafObj("Spine/effects/Ui_miwu.png","warfogAni"..v)
                if _eff then
                    transition.fadeTo(_eff,{opacity=0, time=0.25})
                    _eff:performWithDelay(function()
                        AnimationMgr.removeGafObjectByTag(_eff.res,_eff.tag)
                        darkEffTable[v] = nil
                    end,0.25)
                end
    
                setBlockNodeZOrder(v)
            end
        else
            if not exploredArea[v] then
                exploredArea[v] = true
                local _eff = AnimationMgr.getGafObj("Spine/effects/Ui_miwu.png","warfogAni"..v)
                if _eff then
                    transition.fadeTo(_eff,{opacity=166, time=0.25})
                    _eff:performWithDelay(function()
                        if blockNodeTable[v] then blockNodeTable[v]:removeFromParent() end
                        blockNodeTable[v] = nil
                    end,0.25)
                    
                    _eff:setLocalZOrder(SearchingUIMgr.calcZOrderAt(v) + 5)
                    
                    setBlockNodeZOrder(v)
                end
            end
        end
        
        local _node = getBlockNode(v)
        if _node then
            _node:setVisible(true)
        end
    end
end

function LtWarFogMgr.setPosition(i, x, y)
    local eff = AnimationMgr.getGafObj("Spine/effects/Ui_miwu.png","warfogAni"..i)
    if eff then
        eff:setPosition(x, y)
    end
    if blockNodeTable[i] then
        blockNodeTable[i]:setPosition(x, y)
    end
end

function LtWarFogMgr.scrollBy(moveX, moveY, moveTime)
    for i = 1, LtMapOption.getMapSize() do
        local eff = AnimationMgr.getGafObj("Spine/effects/Ui_miwu.png","warfogAni"..i)
        if eff then 
            transition.moveBy(eff, {x=moveX, y=moveY, time=moveTime})
        end
        if blockNodeTable[i] then
            transition.moveBy(blockNodeTable[i], {x=moveX, y=moveY, time=moveTime})
        end
    end
end

function LtWarFogMgr.scrollTo(i, moveX, moveY, moveTime)
    local eff = AnimationMgr.getGafObj("Spine/effects/Ui_miwu.png","warfogAni"..i)
    if eff then 
        transition.moveTo(eff, {x=moveX, y=moveY, time=moveTime})
    end
    if blockNodeTable[i] then
        transition.moveTo(blockNodeTable[i], {x=moveX, y=moveY, time=moveTime})
    end
end

function LtWarFogMgr.getAdditionalZOrder(block)
    local ret = 0

    if lightenArea[block] then 
        ret = LtWarFogMgr.ZORDER_ADDED_2 
    end
    
    return ret
end

function LtWarFogMgr.isExplored(block)
    return exploredArea[block]
end

return LtWarFogMgr