--[[
性能分析器
@author leon lee
]]

local PerFormaceAnalyzer = {}
local bTurnOnPerFormace = false --是否开启性能分析统计

local performanceRootNode = {
    name = "root", --节点名称
    hitcounts = 0, --命中调用次数
    starttime = 0, --开始统计时间
    endtime = 0, --结束统计时间
    next = nil,--下一个节点数组,树形结构
}

local performNodeTable = {}

function PerFormaceAnalyzer.Init()
    if not bTurnOnPerFormace then return end
    performNodeTable["root"] = performanceRootNode
end

---性能监测开始
--@param parentnodename str 监测的节点的父节点名称
--@param nodename str 监测节点的名称
function PerFormaceAnalyzer.Start(parentnodename,nodename)
    if not bTurnOnPerFormace then return end
    local node  = performNodeTable[nodename]
    if node ~=nil then --already have
        node.starttime = os.clock()
        return
    end
    
    if performNodeTable[parentnodename] ==nil then
        print("Assert PerFormaceAnalyzer parentnode:"..nodename.." is not exists"..nil)
        return
    end
    
    local newPerFormaceNode = {
        name = nodename,
        hitcounts = 0,
        starttime = os.clock(),
        endtime = 0,
        next = nil,
    }
    
    performNodeTable[nodename] = newPerFormaceNode
    
    local parentNode = performNodeTable[parentnodename]
    if parentNode.next == nil then
        local children = {}
        table.insert(children,newPerFormaceNode)
        parentNode.next = children
        
    else
        table.insert(parentNode.next,newPerFormaceNode)
    end
    newPerFormaceNode.starttime = os.clock()
    
end

---性能监测结束节点
--@param nodename str 结束的节点名称,千万不要写错了。否则统计就不准了
function PerFormaceAnalyzer.End(nodename)
    if not bTurnOnPerFormace then return end
    local node = performNodeTable[nodename]
    if node == nil then
        print("Assert PerFormaceAnalyzer end:"..nodename.." is not exists"..nil)        
        return
    end
    
    node.hitcounts = node.hitcounts+1
    node.endtime = os.clock()
end


---输出性能测试报告
function PerFormaceAnalyzer.OutPutPerformaceReport()
    local currentNode = performanceRootNode.next
    local function printNodePerformInfo(currentNodeTable)
        if currentNodeTable~=nil then
            for i = 1,#currentNodeTable do
                print("node name:"..currentNodeTable[i].name.." hit counts:"..currentNodeTable[i].hitcounts.." takes time per count:"..(currentNodeTable[i].endtime-currentNodeTable[i].starttime))
                printNodePerformInfo(currentNodeTable[i].next)        
            end      
        end
    end
    
    --print("currentNode cnt:"..#currentNode)
    
    printNodePerformInfo(currentNode)
end

return PerFormaceAnalyzer