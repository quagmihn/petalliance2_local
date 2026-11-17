local TeamMapInfo = {}

local teamFloorInfoConfig = nil
local teamItemInfoConfig = nil
local teamMonsterInfoConfig = nil
local teamObstacleInfoConfig = nil
local teamPickUpItemInfoConfig = nil
local teamTransferInfoConfig = nil

function TeamMapInfo.Init()
    if teamFloorInfoConfig==nil then
        teamFloorInfoConfig = require("src.DatReader.TeamFloorInfoConfig")
        teamFloorInfoConfig.init()
    end
    
    if teamItemInfoConfig==nil then
        teamItemInfoConfig = require("src.DatReader.TeamItemInfoConfig")
        teamItemInfoConfig.init()
    end
    
    if teamMonsterInfoConfig==nil then
        teamMonsterInfoConfig = require("src.DatReader.TeamMonsterInfoConfig")
        teamMonsterInfoConfig.init()
    end
    
    if teamObstacleInfoConfig==nil then
        teamObstacleInfoConfig = require("src.DatReader.TeamObstacleInfoConfig")
        teamObstacleInfoConfig.init()
    end
    
    if teamPickUpItemInfoConfig==nil then
        teamPickUpItemInfoConfig = require("src.DatReader.TeamPickUpItemInfoConfig")
        teamPickUpItemInfoConfig.init()
    end
    
    if teamTransferInfoConfig==nil then
        teamTransferInfoConfig = require("src.DatReader.TeamTransferInfoConfig")
        teamTransferInfoConfig.init()
    end
end

--[[
data.id=Proto.parseDWORD(entry); -- 副本ID
data.maxFloor=Proto.parseDWORD(entry); -- 最大楼层
data.maxKill=Proto.parseDWORD(entry); -- 击杀个数显示BOSS
data.name=Proto.parseString(entry); -- 副本名称
data.enterMinLevel=Proto.parseDWORD(entry); -- 最小进入等级
data.enterMaxLevel=Proto.parseDWORD(entry); -- 最大进入等级
data.animationRes=Proto.parseString(entry); -- 副本动画资源
data.awardChestIDs=Proto.parseVector(entry,Proto.parseDWORD); -- 奖励池1宝箱ID
data.awardRates=Proto.parseVector(entry,Proto.parseDWORD); -- 奖励池1宝箱概率
data.awardChestCount=Proto.parseDWORD(entry); -- 奖励池1宝箱个数
data.awardChestIDsTwo=Proto.parseVector(entry,Proto.parseDWORD); -- 奖励池2宝箱ID
data.awardRates2=Proto.parseVector(entry,Proto.parseDWORD); -- 奖励池2宝箱概率
data.awardChestCount2=Proto.parseDWORD(entry); -- 奖励池2宝箱个数
data.sence=Proto.parseDWORD(entry); -- 场景
]]
function TeamMapInfo.getTeamFloorInfoById(id)
    return teamFloorInfoConfig.readEntryByID(id)
end

--[[
data.id=Proto.parseDWORD(entry); -- ID
data.name=Proto.parseString(entry); -- 名称
data.picRes=Proto.parseString(entry); -- 图片资源
]]
function TeamMapInfo.getTeamItemInfoById(id)
    return teamItemInfoConfig.readEntryByID(id)
end

--[[
data.id=Proto.parseDWORD(entry); -- ID
data.number=Proto.parseString(entry); -- 怪物编号
data.petnumber=Proto.parseDWORD(entry); -- 宠物编号
data.maxHP=Proto.parseDWORD(entry); -- 最大血量
data.level=Proto.parseDWORD(entry); -- 宠物等级
data.petStage=Proto.parseDWORD(entry); -- 宠物强化等级
data.petStar=Proto.parseDWORD(entry); -- 宠物星数
data.amendmentHP=Proto.parseDWORD(entry); -- HP修正比例
data.amendmentSPD=Proto.parseDWORD(entry); -- SPD修正比例
data.amendmentATK=Proto.parseDWORD(entry); -- ATK修正比例
data.amendmentDEF=Proto.parseDWORD(entry); -- DEF修正比例
data.amendmentSATK=Proto.parseDWORD(entry); -- SATK修正比例
data.amendmentSDEF=Proto.parseDWORD(entry); -- SDEF修正比例
data.awardItems=Proto.parseVector(entry,Proto.parseDWORD); -- 奖励道具
data.awardCounts=Proto.parseVector(entry,Proto.parseDWORD); -- 奖励数量
data.skill1=Proto.parseVector(entry,Proto.parseDWORD); -- 怪物技能1
data.skill2=Proto.parseVector(entry,Proto.parseDWORD); -- 怪物技能2
data.skill3=Proto.parseVector(entry,Proto.parseDWORD); -- 怪物技能3
data.skill4=Proto.parseDWORD(entry); -- 怪物技能4
data.skill1_pro=Proto.parseDWORD(entry); -- 怪物技能1发动概率
data.skill2_pro=Proto.parseDWORD(entry); -- 怪物技能2发动概率
data.skill3_pro=Proto.parseDWORD(entry); -- 怪物技能3发动概率
data.skill4_pro=Proto.parseDWORD(entry); -- 怪物技能4发动概率
data.catchRate=Proto.parseDWORD(entry); -- 捕获率
data.away=Proto.parseDWORD(entry); -- 逃跑率
data.capture=Proto.parseDWORD(entry); -- 最大捕获机会
data.paSkills=Proto.parseVector(entry,Proto.parseDWORD); -- 被动技能
data.petGeneID=Proto.parseDWORD(entry); -- 宠物生成ID
data.mailID=Proto.parseDWORD(entry); -- 奖励邮件ID
data.contribute=Proto.parseDWORD(entry); -- 贡献度
data.badge=Proto.parseDWORD(entry); -- 徽章
]]
function TeamMapInfo.getTeamMonsterInfoById(id)
    return teamMonsterInfoConfig.readEntryByID(id)
end

--[[
data.id=Proto.parseDWORD(entry); -- ID
data.type=Proto.parseDWORD(entry); -- 类型
data.iconRes=Proto.parseString(entry); -- 图标资源
]]
function TeamMapInfo.getTeamObstacleInfoById(id)
    return teamObstacleInfoConfig.readEntryByID(id)
end

--[[
data.id=Proto.parseDWORD(entry); -- ID
data.itemID=Proto.parseDWORD(entry); -- 物品ID
data.count=Proto.parseDWORD(entry); -- 个数
]]
function TeamMapInfo.getTeamPickUpItemInfoById(id)
    return teamPickUpItemInfoConfig.readEntryByID(id)
end

--[[
data.id=Proto.parseDWORD(entry); -- ID
data.type=Proto.parseDWORD(entry); -- 类型
data.picRes=Proto.parseString(entry); -- 图标资源
]]
function TeamMapInfo.getTeamTransferInfoById(id)
    return teamTransferInfoConfig.readEntryByID(id)
end

return TeamMapInfo