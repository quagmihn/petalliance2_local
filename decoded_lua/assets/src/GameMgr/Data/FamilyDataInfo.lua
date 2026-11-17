local FamilyDataInfo = {}

local familyAttributeChangeInfoConfig = nil
local familyAwardInfoConfig = nil
local familyDevoteBufferInfoConfig = nil
local familyLevelInfoConfig = nil
local familyMonsterInfoConfig = nil
local familyObstacleInfoConfig = nil
local familyRandomChestInfoConfig = nil
local familyShopInfoConfig = nil
local familyTransferInfoConfig = nil

function FamilyDataInfo.Init()
    if familyAttributeChangeInfoConfig==nil then
        familyAttributeChangeInfoConfig = require("src.DatReader.FamilyAttributeChangeInfoConfig")
        familyAttributeChangeInfoConfig.init()
    end
    
    if familyAwardInfoConfig==nil then
        familyAwardInfoConfig = require("src.DatReader.FamilyAwardInfoConfig")
        familyAwardInfoConfig.init()
    end
    
    if familyDevoteBufferInfoConfig==nil then
        familyDevoteBufferInfoConfig = require("src.DatReader.FamilyDevoteBufferInfoConfig")
        familyDevoteBufferInfoConfig.init()
    end
    
    if familyLevelInfoConfig==nil then
        familyLevelInfoConfig = require("src.DatReader.FamilyLevelInfoConfig")
        familyLevelInfoConfig.init()
    end
    
    if familyMonsterInfoConfig==nil then
        familyMonsterInfoConfig = require("src.DatReader.FamilyMonsterInfoConfig")
        familyMonsterInfoConfig.init()
    end
    
    if familyObstacleInfoConfig==nil then
        familyObstacleInfoConfig = require("src.DatReader.FamilyObstacleInfoConfig")
        familyObstacleInfoConfig.init()
    end
    
    if familyRandomChestInfoConfig==nil then
        familyRandomChestInfoConfig = require("src.DatReader.FamilyRandomChestInfoConfig")
        familyRandomChestInfoConfig.init()
    end
    
    if familyShopInfoConfig==nil then
        familyShopInfoConfig = require("src.DatReader.FamilyShopInfoConfig")
        familyShopInfoConfig.init()
    end
    
    if familyTransferInfoConfig==nil then
        familyTransferInfoConfig = require("src.DatReader.FamilyTransferInfoConfig")
        familyTransferInfoConfig.init()
    end
end

--[[
data.id=Proto.parseDWORD(entry); -- ID
data.values=Proto.parseDWORD(entry); -- 数值
data.type=Proto.parseDWORD(entry); -- 类型
]]
function FamilyDataInfo.getFamilyAttributeChangeInfoById(id)
    return familyAttributeChangeInfoConfig.readEntryByID(id)
end

--[[
data.id=Proto.parseDWORD(entry); -- ID
data.awardElements=Proto.parseVector(entry,Proto.parseDWORD); -- 奖励道具
data.awardCounts=Proto.parseVector(entry,Proto.parseDWORD); -- 奖励数量
]]
function FamilyDataInfo.getFamilyAwardInfoById(id)
    return familyAwardInfoConfig.readEntryByID(id)
end

function FamilyDataInfo.getFamilyAwardInfoTotal()
    return familyAwardInfoConfig.getEntryCount()
end

--[[
data.id=Proto.parseDWORD(entry); -- id
data.bufferRate=Proto.parseDWORD(entry); -- 加成比例
]]
function FamilyDataInfo.getFamilyDevoteBufferInfoById(id)
    if id > familyDevoteBufferInfoConfig.getEntryCount() then
        id = familyDevoteBufferInfoConfig.getEntryCount()
    end
    return familyDevoteBufferInfoConfig.readEntryByID(id)
end

--[[
data.id=Proto.parseDWORD(entry); -- id
data.familyCoin=Proto.parseDWORD(entry); -- 公会徽章
data.donationLimit=Proto.parseDWORD(entry); -- 捐赠上限
data.resetFamilyQuestCost=Proto.parseDWORD(entry); -- 重置任务费用
]]
function FamilyDataInfo.getFamilyLevelInfoById(id)
    return familyLevelInfoConfig.readEntryByID(id)
end

function FamilyDataInfo.getFamilyLevelInfoTotal()
    return familyLevelInfoConfig.getEntryCount()
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
function FamilyDataInfo.getFamilyMonsterInfoById(id)
    return familyMonsterInfoConfig.readEntryByID(id)
end

--[[
data.id=Proto.parseDWORD(entry); -- ID
data.type=Proto.parseDWORD(entry); -- 类型
data.iconRes=Proto.parseString(entry); -- 图标资源
]]
function FamilyDataInfo.getFamilyObstacleInfoById(id)
    return familyObstacleInfoConfig.readEntryByID(id)
end

--[[
data.id=Proto.parseDWORD(entry); -- ID
data.openCount=Proto.parseDWORD(entry); -- 打开次数
data.awardElements=Proto.parseVector(entry,Proto.parseDWORD); -- 奖励元素
data.awardElementNums=Proto.parseVector(entry,Proto.parseDWORD); -- 奖励个数
data.contribute=Proto.parseDWORD(entry); -- 贡献度
data.picRes=Proto.parseString(entry); -- 
]]
function FamilyDataInfo.getFamilyRandomChestInfoById(id)
    return familyRandomChestInfoConfig.readEntryByID(id)
end

--[[
data.id=Proto.parseDWORD(entry); -- ID
data.awardElementID=Proto.parseDWORD(entry); -- 奖励元素ID
data.awardCount=Proto.parseDWORD(entry); -- 购买个数
data.price=Proto.parseDWORD(entry); -- 价格
data.needLevel=Proto.parseDWORD(entry); -- 需要家族等级
]]
function FamilyDataInfo.getFamilyShopInfoById(id)
    return familyShopInfoConfig.readEntryByID(id)
end

function FamilyDataInfo.getFamilyShopInfoTotal()
    return familyShopInfoConfig.getEntryCount()
end

--[[
data.id=Proto.parseDWORD(entry); -- ID
data.type=Proto.parseDWORD(entry); -- 类型
data.picRes=Proto.parseString(entry); -- 图标资源
]]
function FamilyDataInfo.getFamilyTransferInfoById(id)
    return familyTransferInfoConfig.readEntryByID(id)
end

return FamilyDataInfo