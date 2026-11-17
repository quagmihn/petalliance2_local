-- Net.Proto.Proto_Garden

function Proto.writeP_CG_GetHome_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETHOME_REQ);
	Proto.writeDWORD(msg,data.charID); -- 
end

function Proto.parseP_GC_GetHome_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETHOME_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code==Proto.Error.ERROR_OK) then
		data.home=Proto.parseString(entry); -- 
		data.charID=Proto.parseDWORD(entry); -- 
	end
	return data;
end

function Proto.writeP_CG_SetHome_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_SETHOME_REQ);
	Proto.writeString(msg,data.homeName); -- 
	Proto.writeVector(msg,data.addFurnitures,Proto.writeString); -- {objID:xxx,otherParam:{...}}
	Proto.writeDWORD(msg,data.delFurnitureObjID); -- 不删填0
	Proto.writeVector(msg,data.moveFurnitures,Proto.writeString); -- {objID:xxx,otherParam:{...}}
end

function Proto.parseP_GC_SetHome_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_SETHOME_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code==Proto.Error.ERROR_OK) then
		data.home=Proto.parseString(entry); -- 
	end
	return data;
end

function Proto.writeP_CG_BuyHome_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_BUYHOME_REQ);
end

function Proto.parseP_GC_BuyHome_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_BUYHOME_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code==Proto.Error.ERROR_OK) then
		data.home=Proto.parseString(entry); -- 
	end
	return data;
end

