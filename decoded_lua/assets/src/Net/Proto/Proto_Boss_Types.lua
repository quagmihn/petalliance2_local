-- Net.Proto.Proto_Boss_Types

Proto.BAT_RANK			= 0							-- [boss战奖励类型]名次奖励
Proto.BAT_SUNNY			= Proto.BAT_RANK + 1		-- [boss战奖励类型]阳光奖励
Proto.BAT_GROUP_RANK	= Proto.BAT_SUNNY + 1		-- [boss战奖励类型]boss组名次
Proto.BAT_KILL_BOSS		= Proto.BAT_GROUP_RANK + 1	-- [boss战奖励类型]boss击杀
Proto.BAT_GROUP_SUNNY	= Proto.BAT_KILL_BOSS + 1	-- [boss战奖励类型]boss组阳光奖励

function Proto.parseBossInfo(entry)
	local data={};
	data.id=Proto.parseBYTE(entry); -- bossID
	data.bossName=Proto.parseUnitName(entry); -- boss名称
	data.monsterID=Proto.parseDWORD(entry); -- 怪物ID
	data.maxHP=Proto.parseDWORD(entry); -- 最大血量
	data.refreshTime=Proto.parseDWORD(entry); -- 刷新时间(秒数)
	data.endTime=Proto.parseDWORD(entry); -- 结束时间(秒数)
	data.initLevel=Proto.parseWORD(entry); -- 初始等级
	data.hp=Proto.parseWORD(entry); -- hp比率
	data.sp=Proto.parseWORD(entry); -- sp比率
	data.pp=Proto.parseWORD(entry); -- PP比率
	data.lightAttack=Proto.parseWORD(entry); -- 光攻比率
	data.lightDefence=Proto.parseWORD(entry); -- 光防比率
	data.darkAttack=Proto.parseWORD(entry); -- 暗攻比率
	data.darkDefence=Proto.parseWORD(entry); -- 暗防比率
	data.achievePoint=Proto.parseWORD(entry); -- 参加成就点数
	data.sunnyAward=Proto.parseWORD(entry); -- 阳光普照奖
	data.sunnyAwardCount=Proto.parseWORD(entry); -- 阳光普照奖个数
	data.rebornTime=Proto.parseWORD(entry); -- 复活时间
	data.goldPrize=Proto.parseDWORD(entry); -- 金币奖励
	data.awards=Proto.parseVector(entry,Proto.parseDWORD); -- 奖励表
	data.awardsName=Proto.parseVector(entry,Proto.parseItemName); -- 奖励道具名称
	data.natureSettings=Proto.parseVector(entry,Proto.parseNatureSetting); -- 天性表
	return data;
end

function Proto.getBossInfoIDLen()
	return Proto.getBYTELen();
end

function Proto.writeBossInfo(msg,data)
	Proto.writeBYTE(msg,data.id); -- bossID
	Proto.writeUnitName(msg,data.bossName); -- boss名称
	Proto.writeDWORD(msg,data.monsterID); -- 怪物ID
	Proto.writeDWORD(msg,data.maxHP); -- 最大血量
	Proto.writeDWORD(msg,data.refreshTime); -- 刷新时间(秒数)
	Proto.writeDWORD(msg,data.endTime); -- 结束时间(秒数)
	Proto.writeWORD(msg,data.initLevel); -- 初始等级
	Proto.writeWORD(msg,data.hp); -- hp比率
	Proto.writeWORD(msg,data.sp); -- sp比率
	Proto.writeWORD(msg,data.pp); -- PP比率
	Proto.writeWORD(msg,data.lightAttack); -- 光攻比率
	Proto.writeWORD(msg,data.lightDefence); -- 光防比率
	Proto.writeWORD(msg,data.darkAttack); -- 暗攻比率
	Proto.writeWORD(msg,data.darkDefence); -- 暗防比率
	Proto.writeWORD(msg,data.achievePoint); -- 参加成就点数
	Proto.writeWORD(msg,data.sunnyAward); -- 阳光普照奖
	Proto.writeWORD(msg,data.sunnyAwardCount); -- 阳光普照奖个数
	Proto.writeWORD(msg,data.rebornTime); -- 复活时间
	Proto.writeDWORD(msg,data.goldPrize); -- 金币奖励
	Proto.writeVector(msg,data.awards,Proto.writeDWORD); -- 奖励表
	Proto.writeVector(msg,data.awardsName,Proto.writeItemName); -- 奖励道具名称
	Proto.writeVector(msg,data.natureSettings,Proto.writeNatureSetting); -- 天性表
end

function Proto.parseBossAwardInfo(entry)
	local data={};
	data.rank=Proto.parseWORD(entry); -- 排名
	data.rankType=Proto.parseBYTE(entry); -- 奖励类型
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.awardTable=Proto.parseDWORD(entry); -- 奖励表
	data.count=Proto.parseDWORD(entry); -- 个数
	data.sendTime=Proto.parseDWORD(entry); -- 发奖时间
	return data;
end

function Proto.writeBossAwardInfo(msg,data)
	Proto.writeWORD(msg,data.rank); -- 排名
	Proto.writeBYTE(msg,data.rankType); -- 奖励类型
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writeDWORD(msg,data.awardTable); -- 奖励表
	Proto.writeDWORD(msg,data.count); -- 个数
	Proto.writeDWORD(msg,data.sendTime); -- 发奖时间
end

function Proto.parseBossRank(entry)
	local data={};
	data.userID=Proto.parseCharacterID(entry); -- charID
	data.userNick=Proto.parseNickName(entry); -- 玩家昵称
	data.damage=Proto.parseDWORD(entry); -- 造成boss伤害
	return data;
end

function Proto.writeBossRank(msg,data)
	Proto.writeCharacterID(msg,data.userID); -- charID
	Proto.writeNickName(msg,data.userNick); -- 玩家昵称
	Proto.writeDWORD(msg,data.damage); -- 造成boss伤害
end

function Proto.parseBossMedicineInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- id
	data.freeTimes=Proto.parseDWORD(entry); -- 免费使用次数
	data.totalTimes=Proto.parseDWORD(entry); -- 总次数
	data.firstPay=Proto.parseDWORD(entry); -- 首次超额花费
	data.increasePay=Proto.parseDWORD(entry); -- 增加花费
	return data;
end

function Proto.getBossMedicineInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeBossMedicineInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- id
	Proto.writeDWORD(msg,data.freeTimes); -- 免费使用次数
	Proto.writeDWORD(msg,data.totalTimes); -- 总次数
	Proto.writeDWORD(msg,data.firstPay); -- 首次超额花费
	Proto.writeDWORD(msg,data.increasePay); -- 增加花费
end

function Proto.parseBossGroupInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- id
	data.startTime=Proto.parseString(entry); -- 开始时间
	data.endTime=Proto.parseString(entry); -- 结束时间
	data.awards=Proto.parseVector(entry,Proto.parseDWORD); -- 排行奖励
	data.sunnyAward=Proto.parseDWORD(entry); -- 阳光普照
	return data;
end

function Proto.getBossGroupInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeBossGroupInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- id
	Proto.writeString(msg,data.startTime); -- 开始时间
	Proto.writeString(msg,data.endTime); -- 结束时间
	Proto.writeVector(msg,data.awards,Proto.writeDWORD); -- 排行奖励
	Proto.writeDWORD(msg,data.sunnyAward); -- 阳光普照
end

function Proto.parseBossDetailInfo(entry)
	local data={};
	data.appearID=Proto.parseDWORD(entry); -- 出场id
	data.bossGroupName=Proto.parseUnitName(entry); -- bossGroup名称
	data.rebornTime=Proto.parseDWORD(entry); -- 复活时间
	data.rebornCost=Proto.parseCostInfo(entry); -- 复活花费
	data.limitTime=Proto.parseDWORD(entry); -- 限度时间
	data.killAward=Proto.parseDWORD(entry); -- 击杀奖励
	data.awards=Proto.parseVector(entry,Proto.parseDWORD); -- 排行奖励
	data.sunnyAward=Proto.parseDWORD(entry); -- 阳光普照
	data.challengeAward=Proto.parseDWORD(entry); -- 挑战奖励
	data.monsterGroup=Proto.parseDWORD(entry); -- 怪物组id
	return data;
end

function Proto.writeBossDetailInfo(msg,data)
	Proto.writeDWORD(msg,data.appearID); -- 出场id
	Proto.writeUnitName(msg,data.bossGroupName); -- bossGroup名称
	Proto.writeDWORD(msg,data.rebornTime); -- 复活时间
	Proto.writeCostInfo(msg,data.rebornCost); -- 复活花费
	Proto.writeDWORD(msg,data.limitTime); -- 限度时间
	Proto.writeDWORD(msg,data.killAward); -- 击杀奖励
	Proto.writeVector(msg,data.awards,Proto.writeDWORD); -- 排行奖励
	Proto.writeDWORD(msg,data.sunnyAward); -- 阳光普照
	Proto.writeDWORD(msg,data.challengeAward); -- 挑战奖励
	Proto.writeDWORD(msg,data.monsterGroup); -- 怪物组id
end

function Proto.parseBossDetailInfos(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- boss组id
	data.detailInfos=Proto.parseVector(entry,Proto.parseBossDetailInfo); -- 详细信息列表
	return data;
end

function Proto.getBossDetailInfosIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeBossDetailInfos(msg,data)
	Proto.writeDWORD(msg,data.id); -- boss组id
	Proto.writeVector(msg,data.detailInfos,Proto.writeBossDetailInfo); -- 详细信息列表
end

function Proto.parseBossMonsterInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- id
	data.bossName=Proto.parseUnitName(entry); -- boss名称
	data.prob=Proto.parseDWORD(entry); -- 概率
	data.initLevel=Proto.parseDWORD(entry); -- 初始等级
	data.maxHP=Proto.parseDWORD(entry); -- 最大血量
	data.hp=Proto.parseWORD(entry); -- hp比率
	data.sp=Proto.parseWORD(entry); -- sp比率
	data.pp=Proto.parseWORD(entry); -- PP比率
	data.lightAttack=Proto.parseWORD(entry); -- 光攻比率
	data.lightDefence=Proto.parseWORD(entry); -- 光防比率
	data.darkAttack=Proto.parseWORD(entry); -- 暗攻比率
	data.darkDefence=Proto.parseWORD(entry); -- 暗防比率
	data.natureSettings=Proto.parseVector(entry,Proto.parseNatureSetting); -- 天性表
	return data;
end

function Proto.getBossMonsterInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeBossMonsterInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- id
	Proto.writeUnitName(msg,data.bossName); -- boss名称
	Proto.writeDWORD(msg,data.prob); -- 概率
	Proto.writeDWORD(msg,data.initLevel); -- 初始等级
	Proto.writeDWORD(msg,data.maxHP); -- 最大血量
	Proto.writeWORD(msg,data.hp); -- hp比率
	Proto.writeWORD(msg,data.sp); -- sp比率
	Proto.writeWORD(msg,data.pp); -- PP比率
	Proto.writeWORD(msg,data.lightAttack); -- 光攻比率
	Proto.writeWORD(msg,data.lightDefence); -- 光防比率
	Proto.writeWORD(msg,data.darkAttack); -- 暗攻比率
	Proto.writeWORD(msg,data.darkDefence); -- 暗防比率
	Proto.writeVector(msg,data.natureSettings,Proto.writeNatureSetting); -- 天性表
end

function Proto.parseBossMonsterInfos(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- boss组id
	data.monsterInfos=Proto.parseVector(entry,Proto.parseBossMonsterInfo); -- 怪物信息列表
	return data;
end

function Proto.getBossMonsterInfosIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeBossMonsterInfos(msg,data)
	Proto.writeDWORD(msg,data.id); -- boss组id
	Proto.writeVector(msg,data.monsterInfos,Proto.writeBossMonsterInfo); -- 怪物信息列表
end

