-- Net.Proto.Proto_Item

function Proto.writeP_CG_GetItemPacket_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETITEMPACKET_REQ);
end

function Proto.parseP_GC_GetItemPacket_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETITEMPACKET_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code==Proto.Error.ERROR_OK) then
		data.itemNum=Proto.parseDWORD(entry); -- 道具总数
		data.equipNum=Proto.parseDWORD(entry); -- 装备总数
		data.furnitureNum=Proto.parseDWORD(entry); -- 家具总数
		data.skillItemNum=Proto.parseDWORD(entry); -- 技能书总数
		data.petPieceItemNum=Proto.parseDWORD(entry); -- 宠物碎片总数
	end
	return data;
end

function Proto.parseP_GC_GetItemPacket_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETITEMPACKET_NTF;
	data.items=Proto.parseVector(entry,Proto.parseString); -- 道具
	return data;
end

function Proto.parseP_GC_GetEquipPacket_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETEQUIPPACKET_NTF;
	data.equips=Proto.parseVector(entry,Proto.parseString); -- 装备
	return data;
end

function Proto.parseP_GC_GetFurniturePacket_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETFURNITUREPACKET_NTF;
	data.furnitures=Proto.parseVector(entry,Proto.parseString); -- 家具
	return data;
end

function Proto.parseP_GC_GetSkillItemPacket_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETSKILLITEMPACKET_NTF;
	data.skillItems=Proto.parseVector(entry,Proto.parseString); -- 家具
	return data;
end

function Proto.parseP_GC_GetPetPieceItemPacket_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETPETPIECEITEMPACKET_NTF;
	data.petPieceItems=Proto.parseVector(entry,Proto.parseString); -- 宠物碎片
	return data;
end

function Proto.parseP_GC_UpdateItems_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_UPDATEITEMS_NTF;
	data.items=Proto.parseVector(entry,Proto.parseString); -- 道具
	return data;
end

function Proto.parseP_GC_UpdateEquips_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_UPDATEEQUIPS_NTF;
	data.equips=Proto.parseVector(entry,Proto.parseString); -- 装备
	return data;
end

function Proto.parseP_GC_UpdateFurnitures_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_UPDATEFURNITURES_NTF;
	data.furnitures=Proto.parseVector(entry,Proto.parseString); -- 家具
	return data;
end

function Proto.parseP_GC_UpdateSkillItems_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_UPDATESKILLITEMS_NTF;
	data.skillItems=Proto.parseVector(entry,Proto.parseString); -- 技能道具
	return data;
end

function Proto.writeP_CG_UseItem_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_USEITEM_REQ);
	Proto.writeDWORD(msg,data.itemID); -- 道具ID
	Proto.writeDWORD(msg,data.targetNum); -- 使用目标
	Proto.writeString(msg,data.targetStr); -- 使用目标
	Proto.writeDWORD(msg,data.useNum); -- 使用目标
end

function Proto.parseP_GC_UseItem_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_USEITEM_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code==Proto.Error.ERROR_OK) then
		data.itemID=Proto.parseDWORD(entry); -- 道具总数
		data.itemNum=Proto.parseDWORD(entry); -- 道具总数
	end
	if (data.code ==Proto.Error.ERROR_OK) then
		data.awards=Proto.parseVector(entry,Proto.parseString); -- 
	end
	return data;
end

function Proto.writeP_CG_StrengthenEquip_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_STRENGTHENEQUIP_REQ);
	Proto.writeDWORD(msg,data.petObjID); -- 宠物objID
	Proto.writeDWORD(msg,data.equipObjID); -- 装备objID
end

function Proto.parseP_GC_StrengthenEquip_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_STRENGTHENEQUIP_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code==Proto.Error.ERROR_OK) then
		data.petObjID=Proto.parseDWORD(entry); -- 宠物objID
		data.equipObjID=Proto.parseDWORD(entry); -- 装备objID
		data.js=Proto.parseString(entry); -- 
		data.strengthenAddNum=Proto.parseDWORD(entry); -- 增加的强化值
	end
	return data;
end

function Proto.writeP_CG_EvoEquip_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_EVOEQUIP_REQ);
	Proto.writeDWORD(msg,data.petObjID); -- 宠物objID
	Proto.writeDWORD(msg,data.equipObjID); -- 装备objID
end

function Proto.parseP_GC_EvoEquip_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_EVOEQUIP_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code==Proto.Error.ERROR_OK) then
		data.petObjID=Proto.parseDWORD(entry); -- 宠物objID
		data.equipObjID=Proto.parseDWORD(entry); -- 装备objID
		data.js=Proto.parseString(entry); -- 
	end
	return data;
end

function Proto.writeP_CG_WashEquip_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_WASHEQUIP_REQ);
	Proto.writeDWORD(msg,data.petObjID); -- 宠物objID
	Proto.writeDWORD(msg,data.equipObjID); -- 装备objID
end

function Proto.parseP_GC_WashEquip_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_WASHEQUIP_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code==Proto.Error.ERROR_OK) then
		data.petObjID=Proto.parseDWORD(entry); -- 宠物objID
		data.equipObjID=Proto.parseDWORD(entry); -- 装备objID
		data.js=Proto.parseString(entry); -- 
	end
	return data;
end

function Proto.writeP_CG_MoveEquip_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_MOVEEQUIP_REQ);
	Proto.writeDWORD(msg,data.petObjID); -- 宠物objID
	Proto.writeDWORD(msg,data.equipObjID); -- 装备objID
	Proto.writeDWORD(msg,data.onoff); -- 0 卸下 1 装备到第一格 2 装备到第二格
end

function Proto.parseP_GC_MoveEquip_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_MOVEEQUIP_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code==Proto.Error.ERROR_OK) then
		data.petObjID=Proto.parseDWORD(entry); -- 宠物objID
		data.equipObjID=Proto.parseDWORD(entry); -- 装备objID
		data.onoff=Proto.parseDWORD(entry); -- 0 卸下 1 装备到第一格 2 装备到第二格
		data.equips=Proto.parseVector(entry,Proto.parseString); -- 
		data.pet=Proto.parseString(entry); -- 
	end
	return data;
end

function Proto.writeP_CG_UseWashEquip_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_USEWASHEQUIP_REQ);
	Proto.writeDWORD(msg,data.petObjID); -- 宠物objID
	Proto.writeDWORD(msg,data.equipObjID); -- 装备objID
end

function Proto.parseP_GC_UseWashEquip_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_USEWASHEQUIP_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code==Proto.Error.ERROR_OK) then
		data.petObjID=Proto.parseDWORD(entry); -- 宠物objID
		data.equipObjID=Proto.parseDWORD(entry); -- 装备objID
		data.js=Proto.parseString(entry); -- 
	end
	return data;
end

function Proto.writeP_CG_BuyPacket_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_BUYPACKET_REQ);
	Proto.writeDWORD(msg,data.packetType); -- 1 道具 2 宠物
end

function Proto.parseP_GC_BuyPacket_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_BUYPACKET_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code==Proto.Error.ERROR_OK) then
		data.packetType=Proto.parseDWORD(entry); -- 1 道具 2 宠物
		data.num=Proto.parseDWORD(entry); -- 当前数量
	end
	return data;
end

function Proto.writeP_CG_SellItem_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_SELLITEM_REQ);
	Proto.writeDWORD(msg,data.itemID); -- 物品ID
	Proto.writeDWORD(msg,data.objID); -- objID
	Proto.writeDWORD(msg,data.num); -- 数量
end

function Proto.parseP_GC_SellItem_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_SELLITEM_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code==Proto.Error.ERROR_OK) then
		data.goldNum=Proto.parseDWORD(entry); -- 金币数量
	end
	return data;
end

function Proto.writeP_CG_QuerySomeItems_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_QUERYSOMEITEMS_REQ);
	Proto.writeVector(msg,data.itemIDs,Proto.writeDWORD); -- 物品ID
end

function Proto.parseP_GC_QuerySomeItems_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_QUERYSOMEITEMS_ACK;
	data.code=Proto.parseWORD(entry); -- 
	if (data.code==Proto.Error.ERROR_OK) then
		data.itemIDs=Proto.parseVector(entry,Proto.parseDWORD); -- 物品ID
		data.nums=Proto.parseVector(entry,Proto.parseDWORD); -- 数量
	end
	return data;
end

function Proto.writeP_CG_GetSevenDayAward_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETSEVENDAYAWARD_REQ);
	Proto.writeDWORD(msg,data.sevenDayID); -- 
	Proto.writeDWORD(msg,data.selectIndex); -- 
end

function Proto.parseP_GC_GetSevenDayAward_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETSEVENDAYAWARD_ACK;
	data.code=Proto.parseWORD(entry); -- 
	if (data.code==Proto.Error.ERROR_OK) then
		data.awards=Proto.parseVector(entry,Proto.parseString); -- 物品ID
	end
	return data;
end

function Proto.writeP_CG_ChangeName_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_CHANGENAME_REQ);
	Proto.writeString(msg,data.nickname); -- 
end

function Proto.parseP_GC_ChangeName_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_CHANGENAME_ACK;
	data.code=Proto.parseWORD(entry); -- 
	return data;
end

