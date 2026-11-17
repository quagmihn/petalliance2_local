-- Net.Proto.Proto_DigTreasure_Types

function Proto.parseDigTreasureAwards(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 索引
	data.pos=Proto.parseDWORD(entry); -- 位置
	data.type=Proto.parseBYTE(entry); -- 类型 0奖励组 1字
	data.awardID=Proto.parseDWORD(entry); -- 奖励组ID
	data.wordID=Proto.parseBYTE(entry); -- 字ID
	data.need=Proto.parseDWORD(entry); -- 兑换需要
	return data;
end

function Proto.getDigTreasureAwardsIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeDigTreasureAwards(msg,data)
	Proto.writeDWORD(msg,data.id); -- 索引
	Proto.writeDWORD(msg,data.pos); -- 位置
	Proto.writeBYTE(msg,data.type); -- 类型 0奖励组 1字
	Proto.writeDWORD(msg,data.awardID); -- 奖励组ID
	Proto.writeBYTE(msg,data.wordID); -- 字ID
	Proto.writeDWORD(msg,data.need); -- 兑换需要
end

function Proto.parseDigTreasureCost(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 索引
	data.firstCost=Proto.parseDWORD(entry); -- 第一个消耗
	data.continueCost=Proto.parseDWORD(entry); -- 持续消耗
	data.refreshCount=Proto.parseDWORD(entry); -- 每日刷新次数
	return data;
end

function Proto.getDigTreasureCostIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeDigTreasureCost(msg,data)
	Proto.writeDWORD(msg,data.id); -- 索引
	Proto.writeDWORD(msg,data.firstCost); -- 第一个消耗
	Proto.writeDWORD(msg,data.continueCost); -- 持续消耗
	Proto.writeDWORD(msg,data.refreshCount); -- 每日刷新次数
end

function Proto.parseDigTreasureExchange(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 索引
	data.awardID=Proto.parseDWORD(entry); -- 奖励组ID
	data.shou=Proto.parseDWORD(entry); -- 兽字
	data.shen=Proto.parseDWORD(entry); -- 神字
	data.chuan=Proto.parseDWORD(entry); -- 传字
	data.shuo=Proto.parseDWORD(entry); -- 说字
	return data;
end

function Proto.getDigTreasureExchangeIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeDigTreasureExchange(msg,data)
	Proto.writeDWORD(msg,data.id); -- 索引
	Proto.writeDWORD(msg,data.awardID); -- 奖励组ID
	Proto.writeDWORD(msg,data.shou); -- 兽字
	Proto.writeDWORD(msg,data.shen); -- 神字
	Proto.writeDWORD(msg,data.chuan); -- 传字
	Proto.writeDWORD(msg,data.shuo); -- 说字
end

