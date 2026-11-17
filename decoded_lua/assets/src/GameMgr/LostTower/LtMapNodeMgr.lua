local LtMapNodeMgr = {}

LtMapNodeMgr.BLOCK_WIDTH  = 104
LtMapNodeMgr.BLOCK_HEIGHT = 104

local LostTowerMgr = require("src.GameMgr.LostTower.LostTowerMgr")
local LtMapOption = require("src.GameMgr.LostTower.LtMapOption")

local _blocks  = {}   --block节点table
local _grounds = {}   --ground节点table

function LtMapNodeMgr.Init()
end

---獲取block節點
function LtMapNodeMgr.getBlockNode(i)
    return _blocks[i]
end

---获取ground节点
function LtMapNodeMgr.getGroundNode(i)
    return _grounds[i]
end

---清除clone节点
function LtMapNodeMgr.clear()
    SearchingUIMgr.getBlockContainer():removeAllChildren()
    SearchingUIMgr.getGroundContainer():removeAllChildren()
    _blocks  = {}
    _grounds = {}
end

---绑定block点击事件
function LtMapNodeMgr.blockClickEvent(block, callback)
    local b_node = SearchingUIMgr.getBlockNode(block)
    CSResourceMgr.clickEventBindingByNode(b_node,function(sender, state)
        callback()
    end)
end

function LtMapNodeMgr.CreateMapWithSize(scene,resName)
    local currLayer = CSResourceMgr.getCsbObj(resName)

    if not currLayer then
        currLayer = CSResourceMgr.createRes(scene, resName)
        CSResourceMgr.setFullScreen(resName)
        CocosModuleMgr.setRelativePosition(currLayer, 320, 480)
        currLayer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)

        LostTowerUIMgr.eventNodePool.init(
            CSResourceMgr.getNodeByName(resName, "fog"),
            CSResourceMgr.getNodeByName(resName, "blockSample")
        )
        LostTowerUIMgr.tileNodePool.init(
            CSResourceMgr.getNodeByName(resName, "fog"),
            CSResourceMgr.getNodeByName(resName, "groundSample")
        )
    end
    
    local function set()
        _blocks  = {}
        _grounds = {}

        local f = CSResourceMgr.seekNodeByName(currLayer,"fog")
        local f_sample = CSResourceMgr.seekNodeByName(f,"blockSample")
        local g_sample = CSResourceMgr.seekNodeByName(f,"groundSample")

        --迷雾/地砖位置调整
        f:setPosition(0, 40+624)
        
        local GRID_WIDTH = 104
        local mapWidth  = LtMapOption.getMapCols()
        local mapHeight = LtMapOption.getMapRows()
        f:setInnerContainerSize({width = mapWidth*GRID_WIDTH, height = mapHeight*GRID_WIDTH})
        
        DungeonMapMgr.setBackground(f, (3-1)*mapWidth+3)
        DungeonMapMgr.setFrame(f, (3-1)*mapWidth+3)
        
        local cols = LtMapOption.getMapCols()
        local rows = LtMapOption.getMapRows()
        for i=1, LtMapOption.getMapSize() do

            local g_ = LostTowerUIMgr.tileNodePool.pop()  -- g_sample:clone()
            -- g_:addTo(f)
            g_:removeAllChildren()
            g_:setLocalZOrder(math.ceil(i/cols)-rows-1)
            g_:setContentSize(114, 145)
            g_:setPosition(LtMapNodeMgr.BLOCK_WIDTH/2+LtMapNodeMgr.BLOCK_WIDTH*((i-1)%cols), (mapHeight*GRID_WIDTH+52-LtMapNodeMgr.BLOCK_HEIGHT*math.ceil(i/cols)))
            _grounds[i] = g_

            local f_ = LostTowerUIMgr.eventNodePool.pop()  -- f_sample:clone()
            -- f_:addTo(f)
            f_:setContentSize(104, 138)
            f_:setPosition(LtMapNodeMgr.BLOCK_WIDTH/2+LtMapNodeMgr.BLOCK_WIDTH*((i-1)%cols), mapHeight*GRID_WIDTH+15+52-(LtMapNodeMgr.BLOCK_HEIGHT*math.ceil(i/cols)))
            _blocks[i] = f_
            
            local icon = CSResourceMgr.seekNodeByName(f_,"b_icon")
            icon:removeAllChildren()
            transition.stopTarget(icon)
            icon:setPosition(52, 52)
            
            LtMapNodeMgr.blockClickEvent(i, function()
                SearchingMgr.blockClickedEvent(i)
            end)
            
        end
    end
    set()
    return currLayer    
end

return LtMapNodeMgr