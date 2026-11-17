-- Net.Proto.Proto_Monopoly_Types

function Proto.parseMonopolyCellInfo(entry)
	local data={};
	data.id=Proto.parseBYTE(entry); -- 格子ID
	data.nextAwardTimes=Proto.parseBYTE(entry); -- 下一次的奖励倍数
	data.weight=Proto.parseBYTE(entry); -- 权重
	data.awardTableID=Proto.parseDWORD(entry); -- 奖励表ID
	data.broadcast=Proto.parseBYTE(entry); -- 广播标志
	data.awardName=Proto.parseString(entry); -- 奖励标题
	return data;
end

function Proto.getMonopolyCellInfoIDLen()
	return Proto.getBYTELen();
end

function Proto.writeMonopolyCellInfo(msg,data)
	Proto.writeBYTE(msg,data.id); -- 格子ID
	Proto.writeBYTE(msg,data.nextAwardTimes); -- 下一次的奖励倍数
	Proto.writeBYTE(msg,data.weight); -- 权重
	Proto.writeDWORD(msg,data.awardTableID); -- 奖励表ID
	Proto.writeBYTE(msg,data.broadcast); -- 广播标志
	Proto.writeString(msg,data.awardName); -- 奖励标题
end

function Proto.parseMonopolyDataInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 必须为0,与程序代码兼容
	data.MCash=Proto.parseDWORD(entry); -- 扣的M币
	data.itemID=Proto.parseDWORD(entry); -- 扣的道具
	data.cells=Proto.parseVector(entry,Proto.parseMonopolyCellInfo); -- 格子信息
	return data;
end

function Proto.getMonopolyDataInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeMonopolyDataInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 必须为0,与程序代码兼容
	Proto.writeDWORD(msg,data.MCash); -- 扣的M币
	Proto.writeDWORD(msg,data.itemID); -- 扣的道具
	Proto.writeVector(msg,data.cells,Proto.writeMonopolyCellInfo); -- 格子信息
end

function Proto.parseMonopolyRankInfo(entry)
	local data={};
	data.rank=Proto.parseWORD(entry); -- 名次
	data.nickname=Proto.parseNickName(entry); -- 昵称
	data.steps=Proto.parseDWORD(entry); -- 总步数
	return data;
end

function Proto.writeMonopolyRankInfo(msg,data)
	Proto.writeWORD(msg,data.rank); -- 名次
	Proto.writeNickName(msg,data.nickname); -- 昵称
	Proto.writeDWORD(msg,data.steps); -- 总步数
end

