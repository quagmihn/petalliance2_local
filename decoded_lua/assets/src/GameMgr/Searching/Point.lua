Point = {}

local weightTbl = {    
    [SearchingMapMgr.EVENT_VOID]        = 0,
    [SearchingMapMgr.EVENT_PICKING]     = 0,
    [SearchingMapMgr.EVENT_ENTERANCE]   = 0,
    [SearchingMapMgr.EVENT_SWITCH]      = 0,
    [SearchingMapMgr.EVENT_PORTAL]      = 20,
    [SearchingMapMgr.EVENT_EXIT]        = 0,
}

--计算F值
function Point.CalcF( point, endPoint)

    --啓發函式啓用
    point.H = math.abs(endPoint.X-point.X) + math.abs(endPoint.Y-point.Y)
    
    --方格有事件时启发值增加权重 
    local block = LtMapOption.convertToIndex(point.X, point.Y)
    local etype = SearchingMgr.eventInfoTable[block]
    local weight = weightTbl[etype] or 0
    
    if etype == LtEventOption.EVENT_SWITCH 
    and SearchingMgr.itemTypeTable[block].name == "liusha"
    and SearchingMgr.eventStateInfoTable[block] == 3 
    then
        weight = 20
    end
    
    point.H = weight+point.H
    --if SearchingMgr.eventInfoTable[block] ~= SearchingMapMgr.EVENT_VOID then point.H = weight*point.H end
    
    point.F = point.G + point.H
    
end

function Point.create( posId )
    local point = {}
    point.parentPoint = nil
    point.step = 1 --用于计算h值
    local x,y = LtMapOption.convertToCoord(posId)
    point.F = 0
    point.G = 0
    point.H = 0
    point.X = x            --point.X范围[1,5]
    point.Y = y            --point.Y范围[1,6]
    point.posId = posId
    point.CalcF = 0 + 0 + 0
    
    return point
end

return Point