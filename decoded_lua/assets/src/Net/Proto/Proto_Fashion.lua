-- Net.Proto.Proto_Fashion

function Proto.writeP_CG_GetFashions_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETFASHIONS_REQ);
end

function Proto.parseP_GC_GetFashions_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETFASHIONS_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code==Proto.Error.ERROR_OK) then
		data.FashionInfo=Proto.parseString(entry); -- 角色时装信息
	end
	return data;
end

function Proto.writeP_CG_SetFashions_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_SETFASHIONS_REQ);
	Proto.writeVector(msg,data.FashionInfo,Proto.writeDWORD); -- 角色时装信息
end

function Proto.parseP_GC_SetFashions_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_SETFASHIONS_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code==Proto.Error.ERROR_OK) then
		data.FashionInfo=Proto.parseString(entry); -- 角色时装信息
	end
	return data;
end

function Proto.writeP_CG_RestoreFashions_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_RESTOREFASHIONS_REQ);
end

function Proto.parseP_GC_RestoreFashions_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_RESTOREFASHIONS_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code==Proto.Error.ERROR_OK) then
		data.FashionInfo=Proto.parseString(entry); -- 角色时装信息
	end
	return data;
end

function Proto.parseP_GC_Fashions_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_FASHIONS_NTF;
	data.FashionInfo=Proto.parseString(entry); -- 角色时装信息
	return data;
end

