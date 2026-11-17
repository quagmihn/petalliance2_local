-- Net.Proto.Proto_DailyTask_Types

function Proto.parseDailyTaskAwardInfo(entry)
	local data={};
	data.id=Proto.parseWORD(entry); -- 每日任务ID
	data.awardTableID=Proto.parseDWORD(entry); -- 奖励表ID
	return data;
end

function Proto.getDailyTaskAwardInfoIDLen()
	return Proto.getWORDLen();
end

function Proto.writeDailyTaskAwardInfo(msg,data)
	Proto.writeWORD(msg,data.id); -- 每日任务ID
	Proto.writeDWORD(msg,data.awardTableID); -- 奖励表ID
end

