-- Net.Proto.Proto_WealthGod_Types

function Proto.parseWealthGodInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 索引
	data.investNum=Proto.parseDWORD(entry); -- 投资金额
	data.awardID=Proto.parseDWORD(entry); -- 奖励ID
	data.day=Proto.parseDWORD(entry); -- 返还天数
	return data;
end

function Proto.getWealthGodInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeWealthGodInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 索引
	Proto.writeDWORD(msg,data.investNum); -- 投资金额
	Proto.writeDWORD(msg,data.awardID); -- 奖励ID
	Proto.writeDWORD(msg,data.day); -- 返还天数
end

