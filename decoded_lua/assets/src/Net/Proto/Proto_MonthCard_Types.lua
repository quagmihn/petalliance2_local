-- Net.Proto.Proto_MonthCard_Types

function Proto.parseMonthCard(entry)
	local data={};
	data.id=Proto.parseint(entry); -- 月卡ID
	data.endTime=Proto.parseTIME_SEC(entry); -- 结束时间
	data.lastAwardTime=Proto.parseTIME_SEC(entry); -- 上次领取时间
	return data;
end

function Proto.getMonthCardIDLen()
	return Proto.getintLen();
end

function Proto.writeMonthCard(msg,data)
	Proto.writeint(msg,data.id); -- 月卡ID
	Proto.writeTIME_SEC(msg,data.endTime); -- 结束时间
	Proto.writeTIME_SEC(msg,data.lastAwardTime); -- 上次领取时间
end

