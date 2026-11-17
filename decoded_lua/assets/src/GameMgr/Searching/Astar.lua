Astar = {}

Astar.open = {}
Astar.closed = {}

local function initOpen(startBlock)
    table.insert(Astar.open, Point.create(startBlock))
end

local function getMinPoint(list)
    local minPoint = list[1]
    local k = 1
    for i=1, table.getn(list) do
        if minPoint.F > list[i].F then
            minPoint = list[i]
            k = i
        end
    end
    return minPoint, k
end

local function existsPoint(list, point)
    if table.getn(list)<=0 then return false end
    for i, p in pairs(list) do
        if p.X == point.X and p.Y == point.Y then
            return true
        end
    end
    return false
end

local function existsXY(list, x, y)
    if table.getn(list)<=0 then return false end
    for i, p in pairs(list) do
        if p.X == x and p.Y == y then
            return true
        end
    end
    return false
end

--获取相邻的点  
function Astar.getSurroundPoints( point )

    local function isreachable(col, row)
    
        -- 寻路时终点设为可达，实际移动时移除
        local block = LtMapOption.convertToIndex(col,row)
        if block == SearchingMgr.destination then
            return true
        end
    
        return LtMapOption.isReachable(col, row)
        
    end
    
    local surroundPoints = {}
    if isreachable(point.X+1,point.Y) then table.insert(surroundPoints, Point.create(LtMapOption.convertToIndex(point.X+1,point.Y))) end
    if isreachable(point.X-1,point.Y) then table.insert(surroundPoints, Point.create(LtMapOption.convertToIndex(point.X-1,point.Y))) end
    if isreachable(point.X,point.Y+1) then table.insert(surroundPoints, Point.create(LtMapOption.convertToIndex(point.X,point.Y+1))) end
    if isreachable(point.X,point.Y-1) then table.insert(surroundPoints, Point.create(LtMapOption.convertToIndex(point.X,point.Y-1))) end
    
    return surroundPoints   --返回point点的集合  
    
end 

--计算G值  
local function CalcG( point )  
    local G = point.G  
    local parentG = 0  
    if point.parentPoint then 
        parentG = point.parentPoint.G  
    end
    return G + parentG + 1   --另加一步步長
end

local function foundPoint( tempStart,point, endPoint)
    local G = CalcG(point)  
    if G < point.G then  
        point.parentPoint = tempStart  
        point.G = G  
        Point.CalcF(point, endPoint)  
    end  
end

local function notFoundPoint( tempStart,point, endPoint) 
    point.parentPoint = tempStart 
    point.G = CalcG(point)  
    Point.CalcF(point, endPoint)  
    table.insert(Astar.open, point)  
end 

local function getPoint( list,data )  
    for i,point in pairs(list) do  
        if point.posId == data.posId then  
            return point  
        end  
    end  
    return nil  
end 

function Astar.findpath(startPoint, tagPoint)
    Astar.open = {}
    Astar.closed = {}
    table.insert(Astar.open, startPoint)
    while table.getn(Astar.open) ~= 0 do
        --找出F的最小值  
        local tempStart, k = getMinPoint(Astar.open)
        table.remove(Astar.open,k)
        table.insert(Astar.closed, tempStart) 
        --找出它相邻的点  
        local surroundPoints = Astar.getSurroundPoints(tempStart)  
        for i,point in pairs(surroundPoints) do  
            if existsPoint(Astar.open,point) then  
                --计算G值,如果比原来大,就什么都不做,否则设置他的父节点为当前节点,并更新G和F  
                if not existsPoint(Astar.closed,point) then foundPoint(tempStart,point, tagPoint) end
            else  
                --如果他们不再开始列表里面(且不再關閉列表中),就加入,并设置父节点,并计算GHF 
                if not existsPoint(Astar.closed,point) then notFoundPoint(tempStart,point, tagPoint) end
            end
        end
        --如果目標節點在open表中则返回  
        if getPoint(Astar.open,tagPoint) then  
            return getPoint(Astar.open,tagPoint)  
        end 
        if SearchingMgr.ADV_DEBUG then
            print("******************open***********************")
            for i in pairs(Astar.open) do
                print("open："..Astar.open[i].posId.."  G:"..Astar.open[i].G.."    H:"..Astar.open[i].H)
            end
            print("*****************closed**********************")
            for i in pairs(Astar.closed) do
                print("closed："..Astar.closed[i].posId)
            end
            print("*********************************************")
        end
    end

    return getPoint(Astar.open,tagPoint)

end

return Astar