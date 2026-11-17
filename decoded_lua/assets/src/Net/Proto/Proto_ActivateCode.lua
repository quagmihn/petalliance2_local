-- Net.Proto.Proto_ActivateCode

function Proto.writeP_CG_UseActivateCode_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_USEACTIVATECODE_REQ);
	Proto.writeString(msg,data.strCode); -- 激活码
end

function Proto.parseP_GC_UseActivateCode_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_USEACTIVATECODE_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	return data;
end

