-- Net.Proto.Proto_PetEquip

function Proto.writeP_CG_PetEquipOn_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_PETEQUIPON_REQ);
	Proto.writeDWORD(msg,data.petObjID); -- 
	Proto.writeDWORD(msg,data.equipObjID); -- 
end

function Proto.parseP_GC_PetEquipOn_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_PETEQUIPON_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	return data;
end

function Proto.writeP_CG_PetEquipOff_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_PETEQUIPOFF_REQ);
	Proto.writeDWORD(msg,data.petObjID); -- 
	Proto.writeWORD(msg,data.pos); -- 装备位置
end

function Proto.parseP_GC_PetEquipOff_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_PETEQUIPOFF_ACK;
	data.code=Proto.parseWORD(entry); -- 
	return data;
end

function Proto.writeP_CG_PetEquipCompose_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_PETEQUIPCOMPOSE_REQ);
	Proto.writeDWORD(msg,data.itemID); -- 
end

function Proto.parseP_GC_PetEquipCompose_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_PETEQUIPCOMPOSE_ACK;
	data.code=Proto.parseWORD(entry); -- 
	return data;
end

function Proto.writeP_CG_PetEquipStrengthen_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_PETEQUIPSTRENGTHEN_REQ);
	Proto.writeDWORD(msg,data.ObjID); -- pet/equip
	Proto.writeBYTE(msg,data.pos); -- 部位,0代表没有装备在宠物上
	Proto.writeDWORD(msg,data.luckStoneID); -- 幸运石
end

function Proto.parseP_GC_PetEquipStrengthen_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_PETEQUIPSTRENGTHEN_ACK;
	data.code=Proto.parseWORD(entry); -- 
	return data;
end

function Proto.writeP_CG_PetEquipBaptism_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_PETEQUIPBAPTISM_REQ);
	Proto.writeDWORD(msg,data.ObjID); -- pet/equip
	Proto.writeBYTE(msg,data.pos); -- 部位,0代表没有装备在宠物上
	Proto.writeString(msg,data.strengthenLevel); -- 哪个强化等级的词条
end

function Proto.parseP_GC_PetEquipBaptism_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_PETEQUIPBAPTISM_ACK;
	data.code=Proto.parseWORD(entry); -- 
	if (data.code==Proto.Error.ERROR_OK) then
		data.effect=Proto.parseDWORD(entry); -- 新属性内容
	end
	return data;
end

function Proto.writeP_CG_PetEquipPurify_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_PETEQUIPPURIFY_REQ);
	Proto.writeDWORD(msg,data.ObjID); -- pet/equip
	Proto.writeBYTE(msg,data.pos); -- 部位,0代表没有装备在宠物上
	Proto.writeDWORD(msg,data.purifyStoneNum); -- 淬炼石数量
	Proto.writeVector(msg,data.equips,Proto.writeString); -- 淬炼消耗用装备
end

function Proto.parseP_GC_PetEquipPurify_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_PETEQUIPPURIFY_ACK;
	data.code=Proto.parseWORD(entry); -- 
	return data;
end

function Proto.writeP_CG_PetEquipRestore_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_PETEQUIPRESTORE_REQ);
	Proto.writeDWORD(msg,data.objID); -- pet/equip
	Proto.writeBYTE(msg,data.pos); -- 部位,0代表没有装备在宠物上
end

function Proto.parseP_GC_PetEquipRestore_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_PETEQUIPRESTORE_ACK;
	data.code=Proto.parseWORD(entry); -- 
	return data;
end

function Proto.parseP_GC_UpdatePetEquip_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_UPDATEPETEQUIP_NTF;
	data.bDelete=Proto.parseBYTE(entry); -- 删除还是更新，添加
	data.equipInfo=Proto.parseString(entry); -- 宠物装备信息, 删除时不发
	return data;
end

function Proto.writeP_CG_PetEquipAppraise_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_PETEQUIPAPPRAISE_REQ);
	Proto.writeDWORD(msg,data.itemID); -- 未鉴定装备的道具ID
end

function Proto.parseP_GC_PetEquipAppraise_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_PETEQUIPAPPRAISE_ACK;
	data.code=Proto.parseWORD(entry); -- 
	data.equipInfo=Proto.parseString(entry); -- 装备信息
	return data;
end

