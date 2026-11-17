-- Net.Proto.Proto_MonthCard

function Proto.writeP_CZ_LoadMonthCard_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CZ_LOADMONTHCARD_REQ);
end

function Proto.parseP_ZC_LoadMonthCard_Ack(entry)
	local data={};
	data.msgID=Proto.Command.ZC_LOADMONTHCARD_ACK;
	data.code=Proto.parseCode(entry); -- 返回码
	if (data.code.value==Proto.Error.ERROR_OK) then
		data.infos=Proto.parseVector(entry,Proto.parseMonthCard); -- 月卡数据
		data.isNeverBuy=Proto.parseDWORD(entry); -- 是否从没买过
	end
	return data;
end

function Proto.writeP_CZ_TakeMonthCardAward_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CZ_TAKEMONTHCARDAWARD_REQ);
	Proto.writeint(msg,data.id); -- 月卡ID
end

function Proto.parseP_ZC_TakeMonthCardAward_Ack(entry)
	local data={};
	data.msgID=Proto.Command.ZC_TAKEMONTHCARDAWARD_ACK;
	data.code=Proto.parseCode(entry); -- 返回码
	return data;
end

