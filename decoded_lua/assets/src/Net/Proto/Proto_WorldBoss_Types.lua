-- Net.Proto.Proto_WorldBoss_Types

function Proto.parseWorldBossRank(entry)
	local data={};
	data.charID=Proto.parseDWORD(entry); -- 玩家ID
	data.damage=Proto.parseDWORD(entry); -- 伤害
	return data;
end

function Proto.writeWorldBossRank(msg,data)
	Proto.writeDWORD(msg,data.charID); -- 玩家ID
	Proto.writeDWORD(msg,data.damage); -- 伤害
end

function Proto.parseDamageRank(entry)
	local data={};
	data.charID=Proto.parseDWORD(entry); -- 玩家ID
	data.damage=Proto.parseDWORD(entry); -- 伤害
	data.nickname=Proto.parseString(entry); -- 昵称
	return data;
end

function Proto.writeDamageRank(msg,data)
	Proto.writeDWORD(msg,data.charID); -- 玩家ID
	Proto.writeDWORD(msg,data.damage); -- 伤害
	Proto.writeString(msg,data.nickname); -- 昵称
end

function Proto.parseWorldBossInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- bossID
	data.bossName=Proto.parseString(entry); -- boss名称
	data.property=Proto.parseDWORD(entry); -- boss属性
	data.model=Proto.parseString(entry); -- BOSS模型
	data.mapList=Proto.parseVector(entry,Proto.parseDWORD); -- 所在地图
	data.skill=Proto.parseString(entry); -- BOSS技能
	data.awardID=Proto.parseDWORD(entry); -- 结算奖励
	data.cutIn=Proto.parseString(entry); -- 
	return data;
end

function Proto.getWorldBossInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeWorldBossInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- bossID
	Proto.writeString(msg,data.bossName); -- boss名称
	Proto.writeDWORD(msg,data.property); -- boss属性
	Proto.writeString(msg,data.model); -- BOSS模型
	Proto.writeVector(msg,data.mapList,Proto.writeDWORD); -- 所在地图
	Proto.writeString(msg,data.skill); -- BOSS技能
	Proto.writeDWORD(msg,data.awardID); -- 结算奖励
	Proto.writeString(msg,data.cutIn); -- 
end

function Proto.parseWorldBossAwardItem(entry)
	local data={};
	data.itemID=Proto.parseDWORD(entry); -- 物品ID
	data.count=Proto.parseDWORD(entry); -- 数量
	return data;
end

function Proto.writeWorldBossAwardItem(msg,data)
	Proto.writeDWORD(msg,data.itemID); -- 物品ID
	Proto.writeDWORD(msg,data.count); -- 数量
end

function Proto.parseWorldBossAwardList(entry)
	local data={};
	data.rank=Proto.parseDWORD(entry); -- 排名
	data.awardItems=Proto.parseVector(entry,Proto.parseWorldBossAwardItem); -- 奖励列表
	return data;
end

function Proto.writeWorldBossAwardList(msg,data)
	Proto.writeDWORD(msg,data.rank); -- 排名
	Proto.writeVector(msg,data.awardItems,Proto.writeWorldBossAwardItem); -- 奖励列表
end

function Proto.parseBossKillAwardInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.mailID=Proto.parseDWORD(entry); -- 邮件ID
	data.awardList=Proto.parseVector(entry,Proto.parseWorldBossAwardList); -- 奖励列表
	return data;
end

function Proto.getBossKillAwardInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeBossKillAwardInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeDWORD(msg,data.mailID); -- 邮件ID
	Proto.writeVector(msg,data.awardList,Proto.writeWorldBossAwardList); -- 奖励列表
end

function Proto.parseWeekChampionData(entry)
	local data={};
	data.charID=Proto.parseDWORD(entry); -- 玩家ID
	data.damage=Proto.parseDWORD(entry); -- 伤害
	data.familyName=Proto.parseString(entry); -- 公会名称
	data.nickname=Proto.parseString(entry); -- 玩家名称
	data.fashions=Proto.parseVector(entry,Proto.parseDWORD); -- 时装
	data.message=Proto.parseString(entry); -- 留言
	return data;
end

function Proto.writeWeekChampionData(msg,data)
	Proto.writeDWORD(msg,data.charID); -- 玩家ID
	Proto.writeDWORD(msg,data.damage); -- 伤害
	Proto.writeString(msg,data.familyName); -- 公会名称
	Proto.writeString(msg,data.nickname); -- 玩家名称
	Proto.writeVector(msg,data.fashions,Proto.writeDWORD); -- 时装
	Proto.writeString(msg,data.message); -- 留言
end

function Proto.parseWeekAwardList(entry)
	local data={};
	data.itemID=Proto.parseDWORD(entry); -- 物品ID
	data.count=Proto.parseDWORD(entry); -- 个数
	return data;
end

function Proto.writeWeekAwardList(msg,data)
	Proto.writeDWORD(msg,data.itemID); -- 物品ID
	Proto.writeDWORD(msg,data.count); -- 个数
end

function Proto.parseWorldBossWeekAwardInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.damageCondition=Proto.parseDWORD(entry); -- 伤害条件
	data.awardList=Proto.parseVector(entry,Proto.parseWeekAwardList); -- 奖励列表
	return data;
end

function Proto.getWorldBossWeekAwardInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeWorldBossWeekAwardInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeDWORD(msg,data.damageCondition); -- 伤害条件
	Proto.writeVector(msg,data.awardList,Proto.writeWeekAwardList); -- 奖励列表
end

