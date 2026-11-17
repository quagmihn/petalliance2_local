-- Net.Proto.Proto_SetInfo

function Proto.writeP_CG_PetFreedomLock_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_PETFREEDOMLOCK_REQ);
	Proto.writeDWORD(msg,data.setType); -- 设置类型:1,设置。2，解锁
	Proto.writeString(msg,data.password); -- 密码
end

function Proto.parseP_GC_PetFreedomLock_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_PETFREEDOMLOCK_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	return data;
end

