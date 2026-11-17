-- Net.Proto.Proto_WArena

function Proto.writeP_CG_QueryWArenaData_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_QUERYWARENADATA_REQ);
end

function Proto.parseP_GC_QueryWArenaData_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_QUERYWARENADATA_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code==Proto.Error.ERROR_OK) then
		data.pets=Proto.parseVector(entry,Proto.parseString); -- 防守宠物
		data.helperPets=Proto.parseVector(entry,Proto.parseString); -- 援助防守宠物
	end
	return data;
end

function Proto.writeP_CG_QueryMyWArenaRank_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_QUERYMYWARENARANK_REQ);
end

function Proto.parseP_GC_QueryMyWArenaRank_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_QUERYMYWARENARANK_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code==Proto.Error.ERROR_OK) then
		data.rank=Proto.parseDWORD(entry); -- 排名
	end
	return data;
end

function Proto.parseP_GC_WArenaRankChange_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_WARENARANKCHANGE_NTF;
	data.rank=Proto.parseDWORD(entry); -- 排名
	return data;
end

function Proto.writeP_CG_RandomWArenaEnemys_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_RANDOMWARENAENEMYS_REQ);
	Proto.writeDWORD(msg,data.nowRank); -- 自己当前的排名
end

function Proto.parseP_GC_RandomWArenaEnemys_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_RANDOMWARENAENEMYS_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code==Proto.Error.ERROR_OK) then
		data.enemys=Proto.parseVector(entry,Proto.parseString); -- 对手
	end
	return data;
end

function Proto.writeP_CG_ChangeWArenaPetObjIDs_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_CHANGEWARENAPETOBJIDS_REQ);
	Proto.writeVector(msg,data.petObjIDs,Proto.writeDWORD); -- 防守宠物objIDs
	Proto.writeVector(msg,data.helperPetObjIDs,Proto.writeDWORD); -- 援助防守宠物objIDs
end

function Proto.parseP_GC_ChangeWArenaPetObjIDs_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_CHANGEWARENAPETOBJIDS_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	return data;
end

function Proto.writeP_CG_JoinWArena_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_JOINWARENA_REQ);
end

function Proto.parseP_GC_JoinWArena_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_JOINWARENA_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code==Proto.Error.ERROR_OK) then
		data.rank=Proto.parseDWORD(entry); -- 排名
		data.pets=Proto.parseVector(entry,Proto.parseString); -- 
		data.helperPets=Proto.parseVector(entry,Proto.parseString); -- 
	end
	return data;
end

function Proto.writeP_CG_WArenaRankFight_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_WARENARANKFIGHT_REQ);
	Proto.writeDWORD(msg,data.rank); -- 挑战的排名
end

function Proto.parseP_GC_WArenaRankFight_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_WARENARANKFIGHT_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.arenaBattleID=Proto.parseString(entry); -- 
		data.self=Proto.parseVector(entry,Proto.parseString); -- 
		data.enemys=Proto.parseVector(entry,Proto.parseString); -- 
		data.battleID=Proto.parseString(entry); -- 
		data.serverID=Proto.parseDWORD(entry); -- 
		data.selfHelper=Proto.parseVector(entry,Proto.parseString); -- 
		data.enemysHelper=Proto.parseVector(entry,Proto.parseString); -- 
	end
	return data;
end

function Proto.writeP_CG_QueryWArenaRank_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_QUERYWARENARANK_REQ);
	Proto.writeDWORD(msg,data.rankMin); -- 
	Proto.writeDWORD(msg,data.rankMax); -- 
end

function Proto.parseP_GC_QueryWArenaRank_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_QUERYWARENARANK_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code==Proto.Error.ERROR_OK) then
		data.soldiers=Proto.parseVector(entry,Proto.parseString); -- 
	end
	return data;
end

function Proto.writeP_CG_QueryWArenaSoldierDetail_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_QUERYWARENASOLDIERDETAIL_REQ);
	Proto.writeDWORD(msg,data.charID); -- 
end

function Proto.parseP_GC_QueryWArenaSoldierDetail_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_QUERYWARENASOLDIERDETAIL_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code==Proto.Error.ERROR_OK) then
		data.charID=Proto.parseDWORD(entry); -- 
		data.pets=Proto.parseVector(entry,Proto.parseString); -- 
		data.helperPets=Proto.parseVector(entry,Proto.parseString); -- 
	end
	return data;
end

function Proto.writeP_CG_ClearWArenaCD_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_CLEARWARENACD_REQ);
end

function Proto.parseP_GC_ClearWArenaCD_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_CLEARWARENACD_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	return data;
end

function Proto.writeP_CG_BuyWArenaFightTimes_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_BUYWARENAFIGHTTIMES_REQ);
end

function Proto.parseP_GC_BuyWArenaFightTimes_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_BUYWARENAFIGHTTIMES_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	return data;
end

function Proto.writeP_CG_GetWArenaAward_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETWARENAAWARD_REQ);
end

function Proto.parseP_GC_GetWArenaAward_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETWARENAAWARD_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	return data;
end

function Proto.writeP_CG_GetWArenaRecode_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETWARENARECODE_REQ);
	Proto.writeDWORD(msg,data.startIndex); -- 
	Proto.writeDWORD(msg,data.endIndex); -- 
end

function Proto.parseP_GC_GetWArenaRecode_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETWARENARECODE_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code==Proto.Error.ERROR_OK) then
		data.isNew=Proto.parseDWORD(entry); -- 
		data.recodes=Proto.parseVector(entry,Proto.parseString); -- 
	end
	return data;
end

function Proto.writeP_CG_PlayWArenaRecode_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_PLAYWARENARECODE_REQ);
	Proto.writeString(msg,data.t); -- 
end

function Proto.parseP_GC_PlayWArenaRecode_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_PLAYWARENARECODE_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code==Proto.Error.ERROR_OK) then
		data.recodeNum=Proto.parseDWORD(entry); -- 
		data.recodeInfo=Proto.parseString(entry); -- 
	end
	return data;
end

function Proto.parseP_GC_PlayWArenaRecode_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_PLAYWARENARECODE_NTF;
	data.turnIndex=Proto.parseDWORD(entry); -- 
	data.recode=Proto.parseString(entry); -- 
	return data;
end

function Proto.parseP_GC_GetWArenaRecode_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETWARENARECODE_NTF;
	data.isNew=Proto.parseDWORD(entry); -- 
	data.recodes=Proto.parseVector(entry,Proto.parseString); -- 
	return data;
end

function Proto.parseP_GC_PlayWArenaRecode2_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_PLAYWARENARECODE2_NTF;
	data.recodeInfo=Proto.parseString(entry); -- 
	return data;
end

function Proto.parseP_GC_PlayWArenaRecode3_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_PLAYWARENARECODE3_NTF;
	data.recodeInfo=Proto.parseString(entry); -- 
	return data;
end

function Proto.parseP_GC_PlayWArenaRecode4_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_PLAYWARENARECODE4_NTF;
	data.recodeInfo=Proto.parseString(entry); -- 
	return data;
end

