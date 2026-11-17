-- Net.Proto.Proto_Territorial_Types

function Proto.parseTerritorialListInfo(entry)
	local data={};
	data.name=Proto.parseString(entry); -- 名称
	data.level=Proto.parseDWORD(entry); -- 玩家等级
	data.lock=Proto.parseDWORD(entry); -- 解锁难度
	data.limit=Proto.parseDWORD(entry); -- 解锁要求
	data.beginTime=Proto.parseString(entry); -- 开启时间
	data.lastTime=Proto.parseDWORD(entry); -- 持续时间(秒)
	data.award=Proto.parseVector(entry,Proto.parseDWORD); -- 奖励ID
	data.rate=Proto.parseDWORD(entry); -- 挂机收益
	data.mailID=Proto.parseDWORD(entry); -- 邮件ID
	data.failmailID=Proto.parseDWORD(entry); -- 失败通报
	data.winPoint=Proto.parseDWORD(entry); -- 占点分数
	return data;
end

function Proto.writeTerritorialListInfo(msg,data)
	Proto.writeString(msg,data.name); -- 名称
	Proto.writeDWORD(msg,data.level); -- 玩家等级
	Proto.writeDWORD(msg,data.lock); -- 解锁难度
	Proto.writeDWORD(msg,data.limit); -- 解锁要求
	Proto.writeString(msg,data.beginTime); -- 开启时间
	Proto.writeDWORD(msg,data.lastTime); -- 持续时间(秒)
	Proto.writeVector(msg,data.award,Proto.writeDWORD); -- 奖励ID
	Proto.writeDWORD(msg,data.rate); -- 挂机收益
	Proto.writeDWORD(msg,data.mailID); -- 邮件ID
	Proto.writeDWORD(msg,data.failmailID); -- 失败通报
	Proto.writeDWORD(msg,data.winPoint); -- 占点分数
end

function Proto.parseTerritorialInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 副本ID
	data.territorialList=Proto.parseVector(entry,Proto.parseTerritorialListInfo); -- 信息列表
	return data;
end

function Proto.getTerritorialInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeTerritorialInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 副本ID
	Proto.writeVector(msg,data.territorialList,Proto.writeTerritorialListInfo); -- 信息列表
end

function Proto.parseTerritorialRankInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 副本ID
	data.award=Proto.parseVector(entry,Proto.parseDWORD); -- 奖励ID
	data.mailID=Proto.parseDWORD(entry); -- 邮件ID
	return data;
end

function Proto.getTerritorialRankInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeTerritorialRankInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 副本ID
	Proto.writeVector(msg,data.award,Proto.writeDWORD); -- 奖励ID
	Proto.writeDWORD(msg,data.mailID); -- 邮件ID
end

function Proto.parseTerritorialAwardInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 副本ID
	data.itemID=Proto.parseDWORD(entry); -- 道具ID
	data.count=Proto.parseDWORD(entry); -- 数量
	return data;
end

function Proto.getTerritorialAwardInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeTerritorialAwardInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 副本ID
	Proto.writeDWORD(msg,data.itemID); -- 道具ID
	Proto.writeDWORD(msg,data.count); -- 数量
end

function Proto.parseTerritorialResetInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 重置次数
	data.timeCost=Proto.parseDWORD(entry); -- 时间消耗(M币)
	data.count=Proto.parseDWORD(entry); -- 次数消耗(M币)
	return data;
end

function Proto.getTerritorialResetInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeTerritorialResetInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 重置次数
	Proto.writeDWORD(msg,data.timeCost); -- 时间消耗(M币)
	Proto.writeDWORD(msg,data.count); -- 次数消耗(M币)
end

