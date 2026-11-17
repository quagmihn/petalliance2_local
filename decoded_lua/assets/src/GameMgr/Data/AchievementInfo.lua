local AchievementInfo = {}

local AchievementInfoConfig = nil
local AchievementClientInfo = nil
local PokemonAchievementInfoConfig = nil
local PotentialInfoConfig = nil

function AchievementInfo.Init()
    if AchievementInfoConfig==nil then
        AchievementInfoConfig = require("src.DatReader.AchievementInfoConfig")
        AchievementInfoConfig.init()
    end
    
    if PokemonAchievementInfoConfig==nil then
        PokemonAchievementInfoConfig = require("src.DatReader.PokemonAchievementInfoConfig")
        PokemonAchievementInfoConfig.init()
    end
    
    if PotentialInfoConfig==nil then
        PotentialInfoConfig = require("src.DatReader.PotentialInfoConfig")
        PotentialInfoConfig.init()
    end

    if AchievementClientInfo==nil then
    	AchievementClientInfo = {}
        local AchievementClientInfoReader = TxtReader.new("Config/AchievementC.txt")
        local AchievementClientInfoData = AchievementClientInfoReader.init({"lid", "achIDs"}, 1)
        for key, var in pairs(AchievementClientInfoData) do
            local id = tonumber(var.lid)
            if id then
                local achIDs = var.achIDs
                local vec = lua_string_split(achIDs, ",")
                for k, v in pairs(vec) do
                    vec[k] = tonumber(v)
                end
                AchievementClientInfo[id] = vec
            end
        end
    end
end

--[[
data.id=Proto.parseWORD(entry); -- 成就ID
data.name=Proto.parseString(entry); -- 成就名称
data.desc=Proto.parseString(entry); -- 成就描述
data.achievementType=Proto.parseDWORD(entry); -- 成就类型
data.params=Proto.parseVector(entry,Proto.parseDWORD); -- 成就目标参数(table)
data.awardElementID=Proto.parseDWORD(entry); -- 奖励元素ID
data.awardElementNum=Proto.parseDWORD(entry); -- 奖励元素数量
data.countFieldName=Proto.parseString(entry); -- 计数名
data.isClient=Proto.parseDWORD(entry); -- 客户端控制
data.num=Proto.parseDWORD(entry); -- 数量
data.point=Proto.parseDWORD(entry); -- 成就点
data.gcash=Proto.parseDWORD(entry); -- 金币
data.mcash=Proto.parseDWORD(entry); -- M币
]]
function AchievementInfo.getAchievementInfoById(id)
    return AchievementInfoConfig.readEntryByID(id)
end

function AchievementInfo.getClientAchievementListInfo()
    local tmpVec = AchievementClientInfo
    return tmpVec
end

-- data.id=Proto.parseWORD(entry); -- 
-- data.name=Proto.parseString(entry); -- 
-- data.desc=Proto.parseString(entry); -- 
-- data.icon=Proto.parseString(entry); -- 
-- data.effect=Proto.parseString(entry); -- 效果
-- data.petIDs=Proto.parseVector(entry,Proto.parseDWORD); -- 宠物ID
-- data.point=Proto.parseDWORD(entry); -- 成就点
-- data.gcash=Proto.parseDWORD(entry); -- 金币
-- data.mcash=Proto.parseDWORD(entry); -- M币
function AchievementInfo.getPokemonAchievementInfoById(id)
    return PokemonAchievementInfoConfig.readEntryByID(id)
end

function AchievementInfo.getPokemonAchievementInfoCount()
    return PokemonAchievementInfoConfig.getEntryCount()
end

-- data.id=Proto.parseWORD(entry); -- 
-- data.potentialType=Proto.parseDWORD(entry); -- 
-- data.point=Proto.parseDWORD(entry); -- 点数
-- data.name=Proto.parseString(entry); -- 
-- data.desc=Proto.parseString(entry); -- 
-- data.icon=Proto.parseString(entry); -- 
-- data.effect=Proto.parseString(entry); -- 效果
-- data.params=Proto.parseVector(entry,Proto.parseDWORD); -- 参数
-- data.parents=Proto.parseVector(entry,Proto.parseDWORD); -- 上级ID
function AchievementInfo.getPotentialInfoById(id)
    return PotentialInfoConfig.readEntryByID(id)
end

function AchievementInfo.getPotentialInfoCount()
    return PotentialInfoConfig.getEntryCount()
end

return AchievementInfo