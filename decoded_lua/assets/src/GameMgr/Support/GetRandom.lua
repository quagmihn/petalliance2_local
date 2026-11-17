local GetRandom = {}

local currSeed = 0

function GetRandom.Init()
    print("GetRandom初始化")
    
    -- 初始游戏时设置种子
    math.randomseed(tostring(os.time()):reverse():sub(1, 6))
    math.random(1,10000)
    
    currSeed = 0
end

---获取随机数
--@param min int 区间最小值
--@param max int 区间最大值
function GetRandom.random(min, max)
    if min>max then
    	return 0
    end
--    local _currSeed = tostring(os.time()):reverse():sub(1, 6)
--    if _currSeed ~= currSeed then 
--        local seed = _currSeed
--        math.randomseed(seed)
--    end
--    currSeed = _currSeed
    
    local rNumber = math.random(min, max)
    
    return rNumber
end

---根据比率获取随机数
--@param rateTbl table 比率表，例如{20,30,50}表示有20%概率得到1，30%概率得到2，50%概率得到3
function GetRandom.randomWithProbability(rateTbl)
    local sum = 0
    local tbl = {0}
    for key, var in pairs(rateTbl) do
        sum = var+sum
        tbl[key+1] = sum
    end
    if sum~=100 then
        print("BattleMgr.randomWithProbability() 警告，比率填写错误！ sum="..sum)
    end

--    local seed = tostring(os.time()):reverse():sub(1, 6)+randomSeed*10000+randomSeed*1000+randomSeed*100+randomSeed*10+randomSeed
--    math.randomseed(seed)
--    GetRandom.checkRandomSeed()
    
--    local _currSeed = tostring(os.time()):reverse():sub(1, 6)
--    if _currSeed ~= currSeed then 
--        local seed = _currSeed 
--        math.randomseed(seed)
--    end
--    currSeed = _currSeed
    
    local rNumber = math.random(1,100)
    --print("----------------------------------------------------"..seed..","..rNumber)
    for key, var in pairs(tbl) do
        if key+1 == table.getn(tbl) then
            return key
        end
        if tbl[key]<=rNumber and rNumber<=tbl[key+1] then
            return key
        end
    end
end

function GetRandom.randomTable(tbl)
    local tableNew = {}
    local indexTable = {}
    for k,v in pairs(tbl) do
        table.insert(indexTable,k)
    end
    local indexNum = #indexTable
    for i=1,#indexTable do
        local ran = GetRandom.random(1, indexNum)
        table.insert(tableNew,tbl[indexTable[ran]])
        table.remove(indexTable,ran)
        indexNum = indexNum - 1
    end
    return tableNew
end

return GetRandom