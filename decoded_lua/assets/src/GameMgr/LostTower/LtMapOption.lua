local LtMapOption = {}

local MAP_ROW = 6
local MAP_COL = 5

LtMapOption.SCREEN_RANK = 5 -- 屏幕最大列数

LtMapOption.DIR_PARAMS = {
    {c = 0,  r = -1}, -- 上
    {c = 0,  r = 1},  -- 下
    {c = -1, r = 0},  -- 左
    {c = 1,  r = 0},  -- 右
}

local MAP_TYPE = "ADVENTURE"   --/ "LOSTTOWER"

local cellID = {}

local function initCellID(rows, cols)
    cellID = {}
    
    for r = 1, rows do
        cellID[r] = {}
        for c = 1, cols do
            cellID[r][c] = LtMapOption.convertToIndex(c, r)
        end
    end
end

function LtMapOption.Init()
    cellID = {}
end

function LtMapOption.getCellID(r, c)
    return cellID[r][c]
end

function LtMapOption.setMapType(type)
    MAP_TYPE = type
end

function LtMapOption.getMapType()
    return MAP_TYPE
end

function LtMapOption.setMapSize(rows,cols)
    MAP_ROW = rows
    MAP_COL = cols
    
    initCellID(rows, cols)
end

function LtMapOption.getMapSize()
    return MAP_ROW*MAP_COL
end

function LtMapOption.getMapRows()
    return MAP_ROW
end

function LtMapOption.getMapCols()
    return MAP_COL
end

function LtMapOption.isValid(block)
    if block < 0 or block > LtMapOption.getMapSize() then
        print("ADV_DEBUG_ERROR: Invalid block id...")
        return false
    end
    return true
end

---方格id转换为座标
--@param i int block_id
--@return #int column
--@return #int row
function LtMapOption.convertToCoord(i)
    local col = (i%MAP_COL == 0) and MAP_COL or i%MAP_COL
    local row = math.ceil(i/MAP_COL)   --向上取整 
    return col, row
end

---座标转换为方格编号，左上为原点，横向x轴，纵向y轴
--@param col int column
--@param row int row
function LtMapOption.convertToIndex(col, row)
    if col>0 and col<=MAP_COL and row>0 and row<=MAP_ROW then
        return MAP_COL*(row-1)+col
    else
        return nil
    end
end

---检查越界
--@param col int column
--@param row int row
function LtMapOption.isOnBoard(col, row)
    if col<=0 or col>MAP_COL or row<=0 or row>MAP_ROW then
        return false
    end
    return true
end

---座标是否可达
function LtMapOption.isReachable(col, row)

    -- check to is if the pos is offboard
    if col <= 0 or col > LtMapOption.getMapCols() or row <= 0 or row > LtMapOption.getMapRows() then
        return false
    end

    local block = LtMapOption.convertToIndex(col, row)
    local etype = SearchingMgr.eventInfoTable[block]
    
    if SearchingMgr.mapInfoTable[block] ~= 0 then return false end
    
    if LtEventOption.reachable[etype] then
        local canpass = SearchingMgr.itemTypeTable[block].canpass
        canpass = canpass or "1"
        if canpass == "0" and SearchingMgr.eventInfoTable[block] ~= LtEventOption.EVENT_VOID then
            return false
        end
    else
        return false
    end
    
--    if etype == LtEventOption.EVENT_OBSTRUCTION
--    and SearchingMgr.eventStateInfoTable[block] ~= 3 
--    then
--        return false
--    end
--    
--    if etype == LtEventOption.EVENT_EXIT then
--        return false
--    end
    
    --有训练师将要步入方格，限制为不可达
--    for _,var in pairs( AdvCharMgr.getTrainers() ) do
--        if var.info.floor == SearchingMapMgr.currFloor then
--            if var.info.pos == block then
--                return false
--            end
--            if var.info.nextStep == block then
--                return false
--            end
--        end
--    end

    return true
    
end

function LtMapOption.getDirection(source, target)
    local offset = target - source
    
    if offset == -LtMapOption.getMapCols() then
        return 1   -- 上
    elseif offset == LtMapOption.getMapCols() then
        return 2   -- 下
    elseif offset == -1 then
        return 3   -- 左
    elseif offset == 1  then
        return 4   -- 右
    end
end

---获取指定方向的相邻格子
--
function LtMapOption.getNeighbour(block, dir)
    local col, row = LtMapOption.convertToCoord(block)
    local c = LtMapOption.DIR_PARAMS[dir].c
    local r = LtMapOption.DIR_PARAMS[dir].r
    
    return LtMapOption.convertToIndex(col+c,row+r)
end

function LtMapOption.getAllNeighbour(block)
    local col, row = LtMapOption.convertToCoord(block)
    local params = {
        {0,-1},{0,1},{-1,0},{1,0}
    }
    
    local ret = {}
    for i = 1, #params do
        local _block = LtMapOption.convertToIndex(col+params[i][1],row+params[i][2])
        if _block then table.insert(ret,_block) end
    end

    return ret
end

return LtMapOption