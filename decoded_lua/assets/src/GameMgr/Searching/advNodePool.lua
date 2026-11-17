local advNodePool = {}

function advNodePool.Init()
end

function advNodePool.create()
    local pool = {}
    
    pool.parent = nil
    
    pool.unusedTable = {}
    pool.usedTable = {}
    pool.currentKey = 1
    
    pool.init = function(parent, sample)
        pool.unusedTable = {}
        pool.usedTable = {}
        pool.currentKey = 1
        
        pool.parent = parent
        pool.sample = sample
    end
    
    pool.createNode = function()
        local parent = pool.parent
        local node = pool.sample:clone()
        parent:addChild(node)
        
        node.key = pool.currentKey
        pool.currentKey = pool.currentKey + 1
        
        return node
    end
    
    pool.push = function(node)
        node:setVisible(false)
        node.isUsed = false
        
        pool.usedTable[node.key] = nil
        table.insert(pool.unusedTable, node)
    end
    
    pool.pushAll = function()
        for _, node in pairs(pool.usedTable) do
            pool.push(node)
        end
    end
    
    pool.pop = function()
        local node
        if #pool.unusedTable > 0 then
            node = table.remove(pool.unusedTable)
        else
            node = pool.createNode()
        end
        
        pool.usedTable[node.key] = node

        node:setVisible(true)
        node.isUsed = true
        node.parent = pool.parent

        return node
    end
    
    pool.release = function()
        for k, v in pairs(pool.usedTable) do
            v:removeFromParent()
        end
        for k, v in pairs(pool.unusedTable) do
            v:removeFromParent()
        end
        
        pool.usedTable = nil
        pool.unusedTable = nil
        pool = nil
    end
    
    return pool
end

return advNodePool