-- Net.Proto.Proto_Recharge

function Proto.parseRechargeCDInfo(entry)
	local data={};
	data.cdType=Proto.parsestring(entry); -- CD类型
	data.lastTime=Proto.parseTIME_SEC(entry); -- 上一次充值时间
	return data;
end

function Proto.writeRechargeCDInfo(msg,data)
	Proto.writestring(msg,data.cdType); -- CD类型
	Proto.writeTIME_SEC(msg,data.lastTime); -- 上一次充值时间
end

function Proto.writeP_CG_RechargeCD_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_RECHARGECD_REQ);
end

function Proto.parseP_GC_RechargeCD_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_RECHARGECD_ACK;
	data.code=Proto.parseCode(entry); -- 返回码
	if (data.code.value==Proto.Error.ERROR_OK) then
		data.jsCD=Proto.parseString(entry); -- CD数据
	end
	return data;
end

