-- Net.Proto.Proto_Global_Types

function Proto.parseGlobalInfo(entry)
	local data={};
	data.id=Proto.parseint(entry); -- id
	data.countResetHour=Proto.parseint(entry); -- 计数重置时刻
	data.rechargeMoneyToMCashRate=Proto.parsefloat(entry); -- 充值成MCash比率
	data.payBannedMailID=Proto.parseint(entry); -- 充值禁止邮件ID
	return data;
end

function Proto.getGlobalInfoIDLen()
	return Proto.getintLen();
end

function Proto.writeGlobalInfo(msg,data)
	Proto.writeint(msg,data.id); -- id
	Proto.writeint(msg,data.countResetHour); -- 计数重置时刻
	Proto.writefloat(msg,data.rechargeMoneyToMCashRate); -- 充值成MCash比率
	Proto.writeint(msg,data.payBannedMailID); -- 充值禁止邮件ID
end

