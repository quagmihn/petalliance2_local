-- Net.Proto.Proto_PetStreng

function Proto.writeP_CG_PetStreng_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_PETSTRENG_REQ);
	Proto.writeDWORD(msg,data.petObjID); -- 宠物ObjID
	Proto.writeString(msg,data.addPoints); -- 增加的值的json （例：{"hpx":1,"atk":1,...}）
end

function Proto.parseP_GC_PetStreng_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_PETSTRENG_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.updatePet=Proto.parseString(entry); -- 
	end
	return data;
end

function Proto.writeP_CG_ResetPetStreng_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_RESETPETSTRENG_REQ);
	Proto.writeDWORD(msg,data.petObjID); -- 宠物ObjID
end

function Proto.parseP_GC_ResetPetStreng_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_RESETPETSTRENG_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.updatePet=Proto.parseString(entry); -- 
	end
	return data;
end

function Proto.writeP_CG_PetStrengOverflow_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_PETSTRENGOVERFLOW_REQ);
	Proto.writeDWORD(msg,data.petObjID); -- 宠物ObjID
	Proto.writeString(msg,data.oName); -- 增加的值类型名 ohp,oatk,ospeed,osatk,odef,osdef,oall
end

function Proto.parseP_GC_PetStrengOverflow_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_PETSTRENGOVERFLOW_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.updatePet=Proto.parseString(entry); -- 
	end
	return data;
end

