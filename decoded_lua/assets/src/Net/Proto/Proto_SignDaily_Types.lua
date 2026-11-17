-- Net.Proto.Proto_SignDaily_Types

function Proto.parseSignDailyItem(entry)
	local data={};
	data.signInfo=Proto.parseVector(entry,Proto.parseBYTE); -- 每月签到数据
	data.lastTime=Proto.parseTIME_SEC(entry); -- 上一次签到时间
	data.fetchList=Proto.parseVector(entry,Proto.parseBYTE); -- 已经领取过的物品
	return data;
end

function Proto.writeSignDailyItem(msg,data)
	Proto.writeVector(msg,data.signInfo,Proto.writeBYTE); -- 每月签到数据
	Proto.writeTIME_SEC(msg,data.lastTime); -- 上一次签到时间
	Proto.writeVector(msg,data.fetchList,Proto.writeBYTE); -- 已经领取过的物品
end

function Proto.parseSignRewardInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 索引
	data.count=Proto.parseDWORD(entry); -- 签到次数
	data.awardID=Proto.parseDWORD(entry); -- 奖励组ID
	return data;
end

function Proto.getSignRewardInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeSignRewardInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 索引
	Proto.writeDWORD(msg,data.count); -- 签到次数
	Proto.writeDWORD(msg,data.awardID); -- 奖励组ID
end

