local ScienceInfo = {}

ScienceInfo.ITEM_ID = 9988

local ScienceInfoConfig = nil
local ScienceConsumeInfoConfig = nil
local ResetRule = nil
local typesDef = {}
local MainSkillInfo = {}
local SubSkillInfo = {}
local SkillAttrsInfo = {}
local maxStarNum = 10
local maxLevelNum = 5
local purchaseOrder = nil
local purchaseOrderTime = 0
local lockLevel = 0

local function setSkillInfo()
    MainSkillInfo = {}
    SubSkillInfo = {}
    SkillAttrsInfo = {}
    typesDef = {
        [1] = Proto.AT_HP, 
        [2] = Proto.AT_ATK, 
        [3] = Proto.AT_SATK, 
        [4] = Proto.AT_DEF, 
        [5] = Proto.AT_SDEF, 
        [6] = Proto.AT_SPEED,
        [7] = Proto.AT_RATE, 
        [8] = Proto.AT_CRT, 
        [9] = Proto.AT_CRTHURT, 
        [10] = Proto.AT_DAMAGEREDUCE, 
        [11] = Proto.AT_ANTIHURT, 
        [12] = Proto.AT_EVD,
        [13] = Proto.AT_PENETRATION,
        [14] = Proto.AT_SPENETRATION,
        [15] = Proto.AT_ANTICRT,
        [16] = Proto.AT_HEALRATE,
    }
    for var=1, ScienceInfoConfig.getEntryCount() do
        local id = ScienceInfoConfig.getEntryID(var)
        local data = ScienceInfoConfig.readEntryByID(id)
        local level = 1
        local star = 0
        if data.scienceType==1 then
            table.insert(MainSkillInfo, {id=data.id, name=data.desc, desc=data.desc2, lock=data.openLevel, level=level, 
                exp=0, type=1, star=star, icon=data.icon})
        elseif data.scienceType==2 then
            table.insert(SubSkillInfo, {id=data.id, name=data.desc, desc=data.desc2, lock=data.openLevel, level=level,
                exp=0, type=2, star=star, icon=data.icon})
        end
    end
    for key, var in pairs(typesDef) do
        SkillAttrsInfo[var] = 0
    end
end

function ScienceInfo.Init()
    if ScienceInfoConfig==nil then
        ScienceInfoConfig = require("src.DatReader.ScienceInfoConfig")
        ScienceInfoConfig.init()
    end
    
    if ScienceConsumeInfoConfig==nil then
        ScienceConsumeInfoConfig = require("src.DatReader.ScienceConsumeInfoConfig")
        ScienceConsumeInfoConfig.init()
    end
    local val1 = SystemInfo.getGlobalConfigAddInfoByID(92)
    if val1 then
        maxLevelNum = val1.values[1]
    end
    local val2 = SystemInfo.getGlobalConfigAddInfoByID(93)
    if val2 then
        maxStarNum = val2.values[1]
    end
    purchaseOrder = nil
    purchaseOrderTime = 0
    if ResetRule==nil then
        local val3 = SystemInfo.getGlobalConfigAddInfoByID(61004)
        if val3 then
            ResetRule = val3.values
        end
    end
    local val4 = SystemInfo.getGlobalConfigAddInfoByID(61005)
    if val4 then
        lockLevel = val4.values[1]
    end
    
    setSkillInfo()
end

--[[
data.id=Proto.parseDWORD(entry); -- 
data.openLevel=Proto.parseDWORD(entry); -- 
data.scienceType=Proto.parseDWORD(entry); -- 
data.icon=Proto.parseString(entry); -- 
data.desc=Proto.parseString(entry); -- 
data.desc2=Proto.parseString(entry); -- 
data.values=Proto.parseVector(entry,Proto.parseDWORD); -- 数值
data.levelUpSciencePoints=Proto.parseVector(entry,Proto.parseDWORD); -- 升级科技点
data.starUpConsumes=Proto.parseVector(entry,Proto.parseDWORD); -- 突破材料
data.starUpSciencePoints=Proto.parseVector(entry,Proto.parseDWORD); -- 突破科技点
]]
function ScienceInfo.getScienceInfoByID(id)
    return ScienceInfoConfig.readEntryByID(id)
end

--[[
data.id=Proto.parseDWORD(entry); -- 
data.consumeType=Proto.parseDWORD(entry); -- 消耗类型
data.sciencePoint=Proto.parseDWORD(entry); -- 科技点
data.rate=Proto.parseDWORD(entry); -- 权重
data.sciencePointRate=Proto.parseString(entry); -- 倍率
data.consumeItems=Proto.parseVector(entry,Proto.parseDWORD); -- 材料
]]
function ScienceInfo.getScienceConsumeInfoByID(id)
    return ScienceConsumeInfoConfig.readEntryByID(id)
end

function ScienceInfo.getMaxLevel()
    return maxLevelNum
end

function ScienceInfo.getMaxStar()
    return maxStarNum
end

function ScienceInfo.changeSciencePoint()
    ScienceViewMgr.refreshPoint()
end

function ScienceInfo.getSciencePoint()
    return CharInfo.get().sciencepoint or 0
end

function ScienceInfo.refreshSkillInfo(data)
    local info = {}
    --print("ScienceInfo.refreshSkillInfo", sz_T2S(data))
    for var=1, #data do
        local exp = 0
        if data[var].level>=maxLevelNum then
            data[var].level = maxLevelNum
            exp = ScienceInfo.getExpMax(data[var].id, data[var].star, data[var].level)
        end
        info[data[var].id] = {level=data[var].level, star=data[var].star, exp=exp}
    end
    local function setAttrs(vec)
        for var=1, #vec do
            local data = info[vec[var].id]
            if data then
                local val = vec[var]
                val.star = data.star
                val.level = data.level
                val.exp = data.exp
                --print(val.id, val.star, val.level)
                if CharInfo.getLevel()>=val.lock then
                    local eff = ScienceInfo.getSkillEffect(val.id, val.star, val.level)
                    SkillAttrsInfo[typesDef[val.id]] = eff
                end
            end
        end
    end
    setAttrs(MainSkillInfo)
    setAttrs(SubSkillInfo)
    PokemonInfo.refreshSciencePower()
end

function ScienceInfo.refreshLevel()
    local boolChanged = false
    local function checkLevel(vec)
        for var=1, #vec do
            local val = vec[var]
            if CharInfo.getLevel()>=val.lock then
                local eff = ScienceInfo.getSkillEffect(val.id, val.star, val.level)
                if eff~=SkillAttrsInfo[typesDef[val.id]] then
                	boolChanged = true
                end
                SkillAttrsInfo[typesDef[val.id]] = eff
            end
        end
    end
    checkLevel(MainSkillInfo)
    checkLevel(SubSkillInfo)
    if boolChanged then
        PokemonInfo.refreshSciencePower()
    end
end

function ScienceInfo.getMainSkillInfo()
    return MainSkillInfo
end

function ScienceInfo.getSubSkillInfo()
    return SubSkillInfo
end

function ScienceInfo.getIconFrameRes(type)
    local vec = {"Player/Science/kj_zhu.png", "Player/Science/kj_fu.png"}
	return vec[type] or vec[1]
end

function ScienceInfo.getExpMax(id, star, level)
    if level>=maxLevelNum then
        level = maxLevelNum-1
    end
    local exp = ScienceInfo.getScienceInfoByID(id).levelUpSciencePoints[star*(maxLevelNum-1)+level] or 0
    return exp
end

function ScienceInfo.getSkillEffect(id, star, level, boolNext)
    if boolNext then
        level = level+1
        if level>maxLevelNum then
            star = star+1
            level = 1
    	end
        if star>maxStarNum then
            star = maxStarNum
    	end
    end
    local data = ScienceInfo.getScienceInfoByID(id)
    if data then
        local sum = data.values[star*maxLevelNum+level] or 0
        if data.scienceType==2 then
        	sum = sum/100
        end
        return sum
    end
    return 0
end

function ScienceInfo.getScienceAttrsTable(data, level)
    if data then
        local vec = {}
        level = level or CharInfo.getLevel()
        for var=1, #data do
            local id = tonumber(data[var].id)
            if level>=ScienceInfo.getScienceInfoByID(id).openLevel then
                local eff = ScienceInfo.getSkillEffect(id, data[var].star, data[var].level)
                vec[typesDef[id]] = eff
            else
                vec[typesDef[id]] = 0
            end
        end
        return vec
    end
    return SkillAttrsInfo
end

function ScienceInfo.getScienceFightPower(level)
    level = level or 1
    if level<lockLevel then
    	return 0
    end
    return BattleBasicValueCalc.calcFC(level, SkillAttrsInfo[Proto.AT_HP], SkillAttrsInfo[Proto.AT_ATK],
        SkillAttrsInfo[Proto.AT_DEF], SkillAttrsInfo[Proto.AT_SATK], SkillAttrsInfo[Proto.AT_SDEF], SkillAttrsInfo[Proto.AT_SPEED])
end

function ScienceInfo.getUpgradeMaterial(id, star)
    local data = ScienceInfo.getScienceInfoByID(id)
    local itemVec = {}
    if data.starUpConsumes[star+1] then
        local info = ScienceInfo.getScienceConsumeInfoByID(data.starUpConsumes[star+1])
        for n=1, math.floor((#info.consumeItems)/2) do
            table.insert(itemVec, {info.consumeItems[n*2-1], info.consumeItems[n*2]})
        end
    end
    if data.starUpSciencePoints[star+1] then
        if data.starUpSciencePoints[star+1]>0 then
            table.insert(itemVec, {ScienceInfo.ITEM_ID, data.starUpSciencePoints[star+1]})
    	end
    end
    return itemVec
end

function ScienceInfo.setPurchaseOrder(vec, nvec, time)
    --[[
    local rVec = {}
    for var=1, ScienceConsumeInfoConfig.getEntryCount() do
        local id = ScienceConsumeInfoConfig.getEntryID(var)
        local data = ScienceConsumeInfoConfig.readEntryByID(id)
        if data.sciencePoint>0 then
            table.insert(rVec, id)
        end
    end]]
    print("ScienceInfo订单信息更新", #vec)
    if time then
        purchaseOrderTime = tonumber(time)
        if not purchaseOrderTime then
        	purchaseOrderTime = CharInfo.getServerTime()
        end
    end
    purchaseOrder = {}
    for var=1, #vec do
        local info = ScienceInfo.getScienceConsumeInfoByID(vec[var])
        for n=1, math.floor((#info.consumeItems)/2) do
            table.insert(purchaseOrder, {item=info.consumeItems[n*2-1], total=info.consumeItems[n*2], type=info.consumeType,
                num=nvec[var] or 0, price=info.sciencePoint, rate=info.sciencePointRate, id=vec[var]})
        end
    end
end

function ScienceInfo.getPurchaseOrder()
    return purchaseOrder or {}
end

function ScienceInfo.getPurchaseOrderTime()
    return purchaseOrderTime
end

function ScienceInfo.getPurchaseOrderRefreshTimes()
    local timesec = CharInfo.get().resetscienceconsumetime or 0
    local daydiff = CocosModuleMgr.getDayTimeDiff(timesec, CharInfo.getServerTime())
    if daydiff~=0 then
    	return 0
    end
    return CharInfo.get().resetscienceconsumenum or 0
end

function ScienceInfo.getResetPurchaseOrderConsume()
	return ResetRule or {}
end

function ScienceInfo.getMyScienceTotalLevel()
    return CharInfo.get().sciencelevel or 0
end

function ScienceInfo.getPetAttrLockLevel()
	return lockLevel
end

return ScienceInfo