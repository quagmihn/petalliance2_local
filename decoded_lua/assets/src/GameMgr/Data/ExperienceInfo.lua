local ExperienceInfo = {}

local ExperienceInfoConfig = nil
local LifeSkillExpConfig = nil          --生活技能经验表
local LifeSkillCareerChangeconfig = nil --生活技能切换消耗表
local LevelLockData = nil
local LevelLockInfo = nil

function ExperienceInfo.Init()
    if ExperienceInfoConfig==nil then
        ExperienceInfoConfig = require("src.DatReader.ExperienceInfoConfig")
        ExperienceInfoConfig.init()
        for var=1, ExperienceInfoConfig.getEntryCount() do
            local id = ExperienceInfoConfig.getEntryID(var)
            local data = ExperienceInfoConfig.readEntryByID(id)
            --print(data.id,data.roleExp,data.petExp,data.limitPower)
        end
    end
    
    if LifeSkillExpConfig==nil then
        LifeSkillExpConfig = require("src.DatReader.LifeSkillExpConfig")
        LifeSkillExpConfig.init()
    end
    
    if LifeSkillCareerChangeconfig==nil then
        LifeSkillCareerChangeconfig = require("src.DatReader.LifeSkillCareerChangeConfig")
        LifeSkillCareerChangeconfig.init()
    end
    
    if LevelLockData==nil then
        local LevelLockDataReader = TxtReader.new("Config/ExpOpenLock.txt")
        LevelLockData = LevelLockDataReader.init({"level", "curIDs", "nextIDs"}, 1)
        for key, var in pairs(LevelLockData) do
            if var.curIDs then
                local tmpVec = lua_string_split(var.curIDs, ",")
                for k, v in pairs(tmpVec) do
                    tmpVec[k] = tonumber(v)
                end
                var.curIDs = tmpVec
            else
                var.curIDs = {}
            end
            if var.nextIDs then
                local tmpVec = lua_string_split(var.nextIDs, ",")
                for k, v in pairs(tmpVec) do
                    tmpVec[k] = tonumber(v)
                end
                var.nextIDs = tmpVec
            else
                var.nextIDs = {}
            end
        end
    end
    
    if LevelLockInfo==nil then
        LevelLockInfo = TxtReader.new("Config/ExpOpenLockInfo.txt")
        LevelLockInfo.init({"id", "level", "name", "desc", "icon", "ismap"}, 1)
    end
end

--[[
data.id=Proto.parseDWORD(entry); -- 等级
data.roleExp=Proto.parseDWORD(entry); -- 人物总经验
data.petExpVec=Proto.parseVector(entry,Proto.parseDWORD); -- 宠物总经验组
data.limitPower=Proto.parseDWORD(entry); -- 体力上限
data.levelUpAddPower=Proto.parseDWORD(entry); -- 升级回复体力值
data.petSingleAttrStrengthenMax=Proto.parseDWORD(entry); -- 单属性强化上限
--]]
function ExperienceInfo.getExperienceInfoByID(id)
    if id==0 then
        return {id=0, roleExp=0, petExpVec={0,0,0,0,0,0}, limitPower=0,levelUpAddPower=0,petSingleAttrStrengthenMax=0}
    end
    return ExperienceInfoConfig.readEntryByID(id)
end

--[[
data.id=Proto.parseDWORD(entry); -- 等级
data.exp=Proto.parseDWORD(entry); -- 需求经验
--]]
function ExperienceInfo.getLifeSkillExpInfoByID(id)
    return LifeSkillExpConfig.readEntryByID(id)   
end

--[[
data.id=Proto.parseDWORD(entry); -- 等级
data.elemID=Proto.parseDWORD(entry); -- 消费元素ID
--]]
function ExperienceInfo.getLifeSkillCareerChangeByID(id)
    return LifeSkillCareerChangeconfig.readEntryByID(id)
end

--level, curIDs, nextIDs
function ExperienceInfo.getLevelLockDataByLevel(level)
    return LevelLockData[level]
end

--id, level, name, desc, icon
function ExperienceInfo.getLevelLockInfoByID(id)
	return LevelLockInfo.get(id)
end

return ExperienceInfo