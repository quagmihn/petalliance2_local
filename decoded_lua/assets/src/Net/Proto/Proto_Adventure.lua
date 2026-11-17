-- Net.Proto.Proto_Adventure

function Proto.writeP_CG_CreateAdventure_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_CREATEADVENTURE_REQ);
	Proto.writeDWORD(msg,data.adventureID); -- 
end

function Proto.parseP_GC_CreateAdventure_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_CREATEADVENTURE_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.adventureID=Proto.parseDWORD(entry); -- 
		data.adventureInfo=Proto.parseString(entry); -- 
	end
	return data;
end

function Proto.writeP_CG_GetCurrentAdventrue_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETCURRENTADVENTRUE_REQ);
end

function Proto.parseP_GC_GetCurrentAdventrue_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETCURRENTADVENTRUE_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.adventureID=Proto.parseDWORD(entry); -- 
		data.adventureInfo=Proto.parseString(entry); -- 
	end
	return data;
end

function Proto.writeP_CG_GetFinishedAdventures_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETFINISHEDADVENTURES_REQ);
end

function Proto.parseP_GC_GetFinishedAdventures_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETFINISHEDADVENTURES_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	data.num=Proto.parseDWORD(entry); -- 副本数量（等待notify发送）
	return data;
end

function Proto.parseP_GC_GetFinishedAdventures_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETFINISHEDADVENTURES_NTF;
	data.finished=Proto.parseVector(entry,Proto.parseString); -- 
	return data;
end

function Proto.writeP_CG_GetAdventureAward_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETADVENTUREAWARD_REQ);
	Proto.writeDWORD(msg,data.floor); -- 层数 (1 开始)
	Proto.writeDWORD(msg,data.field); -- 列数 (1 开始)
	Proto.writeDWORD(msg,data.row); -- 行数 (1 开始)
end

function Proto.parseP_GC_GetAdventureAward_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETADVENTUREAWARD_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.awards=Proto.parseVector(entry,Proto.parseString); -- 
	end
	return data;
end

function Proto.writeP_CG_FinishAdventure_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_FINISHADVENTURE_REQ);
	Proto.writeWORD(msg,data.star); -- 
end

function Proto.parseP_GC_FinishAdventure_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_FINISHADVENTURE_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.awards=Proto.parseVector(entry,Proto.parseString); -- 
	end
	return data;
end

function Proto.writeP_CG_SetBillboard_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_SETBILLBOARD_REQ);
	Proto.writeString(msg,data.billboardKey); -- 
	Proto.writeString(msg,data.billboardConcent); -- 
end

function Proto.parseP_GC_SetBillboard_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_SETBILLBOARD_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.billboardKey=Proto.parseString(entry); -- 
		data.billboardConcent=Proto.parseVector(entry,Proto.parseString); -- 
	end
	return data;
end

function Proto.writeP_CG_GetBillboard_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETBILLBOARD_REQ);
	Proto.writeString(msg,data.billboardKey); -- 
end

function Proto.parseP_GC_GetBillboard_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETBILLBOARD_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.billboardKey=Proto.parseString(entry); -- 
		data.billboardConcent=Proto.parseVector(entry,Proto.parseString); -- 
	end
	return data;
end

function Proto.writeP_CG_AdventureUseSkill_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_ADVENTUREUSESKILL_REQ);
	Proto.writeDWORD(msg,data.objID); -- 
	Proto.writeDWORD(msg,data.skillID); -- 
end

function Proto.parseP_GC_AdventureUseSkill_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_ADVENTUREUSESKILL_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	return data;
end

function Proto.writeP_CG_CreatRandomAdventrue_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_CREATRANDOMADVENTRUE_REQ);
end

function Proto.parseP_GC_CreatRandomAdventrue_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_CREATRANDOMADVENTRUE_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	return data;
end

function Proto.writeP_CG_FinishRandomAdventrue_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_FINISHRANDOMADVENTRUE_REQ);
end

function Proto.parseP_GC_FinishRandomAdventrue_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_FINISHRANDOMADVENTRUE_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	return data;
end

function Proto.writeP_CG_GetRandomAdventrueAward_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETRANDOMADVENTRUEAWARD_REQ);
end

function Proto.parseP_GC_GetRandomAdventrueAward_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETRANDOMADVENTRUEAWARD_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	return data;
end

function Proto.writeP_CG_AdventureDamage_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_ADVENTUREDAMAGE_REQ);
	Proto.writeVector(msg,data.petObjIDs,Proto.writeDWORD); -- 
	Proto.writeVector(msg,data.damageTypes,Proto.writeDWORD); -- 
	Proto.writeVector(msg,data.damages,Proto.writeDWORD); -- 
end

function Proto.parseP_GC_AdventureDamage_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_ADVENTUREDAMAGE_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.petObjIDs=Proto.parseVector(entry,Proto.parseDWORD); -- 
		data.damageTypes=Proto.parseVector(entry,Proto.parseDWORD); -- 
		data.hp=Proto.parseVector(entry,Proto.parseDWORD); -- 
	end
	return data;
end

function Proto.writeP_CG_QuickClearAdventure_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_QUICKCLEARADVENTURE_REQ);
	Proto.writeDWORD(msg,data.adventureID); -- 副本ID
	Proto.writeDWORD(msg,data.clearType); -- 扫荡类型 0:扫荡券
	Proto.writeDWORD(msg,data.isManyTimes); -- 是否连续扫荡 1 是 0 否
end

function Proto.parseP_GC_QuickClearAdventure_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_QUICKCLEARADVENTURE_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.awards=Proto.parseVector(entry,Proto.parseString); -- 
	end
	return data;
end

function Proto.writeP_CG_TriggerNodeEvent_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_TRIGGERNODEEVENT_REQ);
	Proto.writeWORD(msg,data.mapIndex); -- 大地图编号
	Proto.writeDWORD(msg,data.nodeIndex); -- 节点编号
end

function Proto.parseP_GC_TriggerNodeEvent_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_TRIGGERNODEEVENT_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.awards=Proto.parseVector(entry,Proto.parseString); -- 事件奖品
	end
	return data;
end

function Proto.writeP_CG_GetMyMapNodeEventInfo_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETMYMAPNODEEVENTINFO_REQ);
end

function Proto.parseP_GC_GetMyMapNodeEventInfo_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETMYMAPNODEEVENTINFO_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.nodeEventInfo=Proto.parseString(entry); -- 节点事件信息
	end
	return data;
end

function Proto.writeP_CG_FireAdventureEvent_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_FIREADVENTUREEVENT_REQ);
	Proto.writeDWORD(msg,data.adventureID); -- 副本ID
	Proto.writeVector(msg,data.events,Proto.writeDWORD); -- 事件列表
end

function Proto.parseP_GC_FireAdventureEvent_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_FIREADVENTUREEVENT_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	return data;
end

function Proto.writeP_CG_RefreshMapNodeEvent_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_REFRESHMAPNODEEVENT_REQ);
end

function Proto.parseP_GC_RefreshMapNodeEvent_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_REFRESHMAPNODEEVENT_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.nodeEventInfo=Proto.parseString(entry); -- 节点事件信息
	end
	return data;
end

function Proto.writeP_CG_BuyNpcShopGoods_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_BUYNPCSHOPGOODS_REQ);
	Proto.writeDWORD(msg,data.index); -- 商品序号
end

function Proto.parseP_GC_BuyNpcShopGoods_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_BUYNPCSHOPGOODS_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	return data;
end

function Proto.writeP_CG_ResetAdventureTimes_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_RESETADVENTURETIMES_REQ);
	Proto.writeDWORD(msg,data.adventureID); -- 
end

function Proto.parseP_GC_ResetAdventureTimes_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_RESETADVENTURETIMES_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.finAdv=Proto.parseString(entry); -- 
	end
	return data;
end

function Proto.writeP_CG_ResetAdventure_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_RESETADVENTURE_REQ);
end

function Proto.parseP_GC_ResetAdventure_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_RESETADVENTURE_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	return data;
end

function Proto.writeP_CG_GetMapStarAward_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETMAPSTARAWARD_REQ);
	Proto.writeDWORD(msg,data.tID); -- 
end

function Proto.parseP_GC_GetMapStarAward_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETMAPSTARAWARD_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.awards=Proto.parseVector(entry,Proto.parseString); -- 
	end
	return data;
end

function Proto.writeP_CG_GetMapStarAwardData_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETMAPSTARAWARDDATA_REQ);
end

function Proto.parseP_GC_GetMapStarAwardData_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETMAPSTARAWARDDATA_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.datas=Proto.parseVector(entry,Proto.parseDWORD); -- 
	end
	return data;
end

function Proto.writeP_CG_GetAdvAward_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETADVAWARD_REQ);
	Proto.writeDWORD(msg,data.advID); -- 
end

function Proto.parseP_GC_GetAdvAward_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETADVAWARD_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.awards=Proto.parseVector(entry,Proto.parseString); -- 
	end
	return data;
end

function Proto.writeP_CG_GetAdvAwardData_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETADVAWARDDATA_REQ);
end

function Proto.parseP_GC_GetAdvAwardData_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETADVAWARDDATA_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.datas=Proto.parseVector(entry,Proto.parseDWORD); -- 
	end
	return data;
end

