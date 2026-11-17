-- Net.Proto.Proto_ConfraternityTradeContest_Types

function Proto.parseConfraternityTradeInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 公会id
	data.tradeCount=Proto.parseDWORD(entry); -- 贸易量
	return data;
end

function Proto.getConfraternityTradeInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeConfraternityTradeInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 公会id
	Proto.writeDWORD(msg,data.tradeCount); -- 贸易量
end

function Proto.parseConfraternityTradeCountInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 公会id
	data.updateTime=Proto.parseTIME_SEC(entry); -- 更新时间
	data.tradeTotalCount=Proto.parseDWORD(entry); -- 总贸易量
	return data;
end

function Proto.getConfraternityTradeCountInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeConfraternityTradeCountInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 公会id
	Proto.writeTIME_SEC(msg,data.updateTime); -- 更新时间
	Proto.writeDWORD(msg,data.tradeTotalCount); -- 总贸易量
end

function Proto.parseConfraternityTradeContestAward(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 公会id
	data.deadline=Proto.parseTIME_SEC(entry); -- 过期时间
	data.awardType=Proto.parseWORD(entry); -- 奖励类型
	return data;
end

function Proto.getConfraternityTradeContestAwardIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeConfraternityTradeContestAward(msg,data)
	Proto.writeDWORD(msg,data.id); -- 公会id
	Proto.writeTIME_SEC(msg,data.deadline); -- 过期时间
	Proto.writeWORD(msg,data.awardType); -- 奖励类型
end

function Proto.parseAwardConfig(entry)
	local data={};
	data.generateID=Proto.parseDWORD(entry); -- 道具规则id
	data.count=Proto.parseWORD(entry); -- 数量
	return data;
end

function Proto.writeAwardConfig(msg,data)
	Proto.writeDWORD(msg,data.generateID); -- 道具规则id
	Proto.writeWORD(msg,data.count); -- 数量
end

function Proto.parseConfraternityTradeContestAwardInfo(entry)
	local data={};
	data.id=Proto.parseWORD(entry); -- 排名
	data.awardTime=Proto.parseDWORD(entry); -- 奖励持续时间
	data.awards=Proto.parseVector(entry,Proto.parseAwardConfig); -- 奖励
	return data;
end

function Proto.getConfraternityTradeContestAwardInfoIDLen()
	return Proto.getWORDLen();
end

function Proto.writeConfraternityTradeContestAwardInfo(msg,data)
	Proto.writeWORD(msg,data.id); -- 排名
	Proto.writeDWORD(msg,data.awardTime); -- 奖励持续时间
	Proto.writeVector(msg,data.awards,Proto.writeAwardConfig); -- 奖励
end

