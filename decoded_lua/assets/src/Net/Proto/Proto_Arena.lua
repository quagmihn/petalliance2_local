-- Net.Proto.Proto_Arena

function Proto.writeP_CG_QueryArenaData_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_QUERYARENADATA_REQ);
end

function Proto.parseP_GC_QueryArenaData_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_QUERYARENADATA_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code==Proto.Error.ERROR_OK) then
		data.rank=Proto.parseDWORD(entry); -- 排名
		data.petObjIDs=Proto.parseVector(entry,Proto.parseDWORD); -- 防守宠物objIDs
		data.teamID=Proto.parseDWORD(entry); -- 防守队伍ID
	end
	return data;
end

function Proto.parseP_GC_ArenaRankChange_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_ARENARANKCHANGE_NTF;
	data.rank=Proto.parseDWORD(entry); -- 排名
	return data;
end

function Proto.parseP_GC_ArenaPetsChange_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_ARENAPETSCHANGE_NTF;
	data.petObjIDs=Proto.parseVector(entry,Proto.parseDWORD); -- 防守宠物objIDs
	data.teamID=Proto.parseDWORD(entry); -- 防守队伍ID
	return data;
end

function Proto.writeP_CG_RandomArenaEnemys_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_RANDOMARENAENEMYS_REQ);
	Proto.writeDWORD(msg,data.nowRank); -- 自己当前的排名
end

function Proto.parseP_GC_RandomArenaEnemys_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_RANDOMARENAENEMYS_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code==Proto.Error.ERROR_OK) then
		data.enemys=Proto.parseVector(entry,Proto.parseString); -- 对手
	end
	return data;
end

function Proto.writeP_CG_ChangeArenaPetObjIDs_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_CHANGEARENAPETOBJIDS_REQ);
	Proto.writeDWORD(msg,data.teamID); -- 防守队伍ID
	Proto.writeVector(msg,data.petObjIDs,Proto.writeDWORD); -- 防守宠物objIDs
end

function Proto.parseP_GC_ChangeArenaPetObjIDs_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_CHANGEARENAPETOBJIDS_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	return data;
end

function Proto.writeP_CG_JoinArena_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_JOINARENA_REQ);
	Proto.writeDWORD(msg,data.teamID); -- 防守队伍ID
	Proto.writeVector(msg,data.petObjIDs,Proto.writeDWORD); -- 防守宠物objIDs
end

function Proto.parseP_GC_JoinArena_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_JOINARENA_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code==Proto.Error.ERROR_OK) then
		data.rank=Proto.parseDWORD(entry); -- 排名
		data.teamID=Proto.parseDWORD(entry); -- 防守队伍ID
		data.petObjIDs=Proto.parseVector(entry,Proto.parseDWORD); -- 防守宠物objIDs
	end
	return data;
end

function Proto.writeP_CG_ArenaRankFight_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_ARENARANKFIGHT_REQ);
	Proto.writeDWORD(msg,data.rank); -- 挑战的排名
	Proto.writeDWORD(msg,data.teamID); -- 防守队伍ID
	Proto.writeVector(msg,data.petObjIDs,Proto.writeDWORD); -- 防守宠物objIDs
end

function Proto.parseP_GC_ArenaRankFight_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_ARENARANKFIGHT_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.arenaBattleID=Proto.parseString(entry); -- 
		data.self=Proto.parseVector(entry,Proto.parseString); -- 
		data.enemys=Proto.parseVector(entry,Proto.parseString); -- 
		data.battleID=Proto.parseString(entry); -- 
		data.serverID=Proto.parseDWORD(entry); -- 
		data.selfHelper=Proto.parseVector(entry,Proto.parseString); -- 
		data.enemysHelper=Proto.parseVector(entry,Proto.parseString); -- 
		data.selfOtherParams=Proto.parseString(entry); -- 
		data.enemyOtherParams=Proto.parseString(entry); -- 
	end
	return data;
end

function Proto.writeP_CG_ArenaRankFightEnd_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_ARENARANKFIGHTEND_REQ);
	Proto.writeString(msg,data.arenaBattleID); -- 
	Proto.writeDWORD(msg,data.isWin); -- 是否胜利 0负 1胜 2平
	Proto.writeVector(msg,data.report,Proto.writeString); -- 
end

function Proto.parseP_GC_ArenaRankFightEnd_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_ARENARANKFIGHTEND_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	return data;
end

function Proto.writeP_CG_QueryArenaRank_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_QUERYARENARANK_REQ);
	Proto.writeDWORD(msg,data.rankMin); -- 
	Proto.writeDWORD(msg,data.rankMax); -- 
end

function Proto.parseP_GC_QueryArenaRank_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_QUERYARENARANK_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code==Proto.Error.ERROR_OK) then
		data.soldiers=Proto.parseVector(entry,Proto.parseString); -- 
	end
	return data;
end

function Proto.writeP_CG_QueryArenaSoldierDetail_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_QUERYARENASOLDIERDETAIL_REQ);
	Proto.writeDWORD(msg,data.charID); -- 
	Proto.writeDWORD(msg,data.teamID); -- 
end

function Proto.parseP_GC_QueryArenaSoldierDetail_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_QUERYARENASOLDIERDETAIL_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code==Proto.Error.ERROR_OK) then
		data.charID=Proto.parseDWORD(entry); -- 
		data.teamID=Proto.parseDWORD(entry); -- 
		data.pets=Proto.parseVector(entry,Proto.parseString); -- 
		data.helperPets=Proto.parseVector(entry,Proto.parseString); -- 
	end
	return data;
end

function Proto.writeP_CG_ClearArenaCD_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_CLEARARENACD_REQ);
end

function Proto.parseP_GC_ClearArenaCD_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_CLEARARENACD_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	return data;
end

function Proto.writeP_CG_BuyArenaFightTimes_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_BUYARENAFIGHTTIMES_REQ);
end

function Proto.parseP_GC_BuyArenaFightTimes_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_BUYARENAFIGHTTIMES_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	return data;
end

function Proto.writeP_CG_GetArenaAward_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETARENAAWARD_REQ);
end

function Proto.parseP_GC_GetArenaAward_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETARENAAWARD_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	return data;
end

function Proto.writeP_CG_GetArenaRecode_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETARENARECODE_REQ);
	Proto.writeDWORD(msg,data.startIndex); -- 
	Proto.writeDWORD(msg,data.endIndex); -- 
end

function Proto.parseP_GC_GetArenaRecode_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETARENARECODE_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code==Proto.Error.ERROR_OK) then
		data.isNew=Proto.parseDWORD(entry); -- 
		data.recodes=Proto.parseVector(entry,Proto.parseString); -- 
	end
	return data;
end

function Proto.writeP_CG_PlayArenaRecode_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_PLAYARENARECODE_REQ);
	Proto.writeString(msg,data.t); -- 
end

function Proto.parseP_GC_PlayArenaRecode_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_PLAYARENARECODE_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code==Proto.Error.ERROR_OK) then
		data.recodeNum=Proto.parseDWORD(entry); -- 
		data.recodeInfo=Proto.parseString(entry); -- 
	end
	return data;
end

function Proto.parseP_GC_PlayArenaRecode_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_PLAYARENARECODE_NTF;
	data.turnIndex=Proto.parseDWORD(entry); -- 
	data.recode=Proto.parseString(entry); -- 
	return data;
end

function Proto.parseP_GC_PlayArenaRecode2_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_PLAYARENARECODE2_NTF;
	data.recodeInfo=Proto.parseString(entry); -- 
	return data;
end

function Proto.parseP_GC_PlayArenaRecode3_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_PLAYARENARECODE3_NTF;
	data.recodeInfo=Proto.parseString(entry); -- 
	return data;
end

function Proto.parseP_GC_PlayArenaRecode4_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_PLAYARENARECODE4_NTF;
	data.recodeInfo=Proto.parseString(entry); -- 
	return data;
end

function Proto.parseP_GC_GetArenaRecode_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETARENARECODE_NTF;
	data.isNew=Proto.parseDWORD(entry); -- 
	data.recodes=Proto.parseVector(entry,Proto.parseString); -- 
	return data;
end

function Proto.writeP_CG_QueryMArenaData_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_QUERYMARENADATA_REQ);
end

function Proto.parseP_GC_QueryMArenaData_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_QUERYMARENADATA_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code==Proto.Error.ERROR_OK) then
		data.rank=Proto.parseDWORD(entry); -- 排名
		data.petObjIDs=Proto.parseVector(entry,Proto.parseDWORD); -- 防守宠物objIDs
		data.teamID=Proto.parseDWORD(entry); -- 防守队伍ID
	end
	return data;
end

function Proto.parseP_GC_MArenaRankChange_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_MARENARANKCHANGE_NTF;
	data.rank=Proto.parseDWORD(entry); -- 排名
	return data;
end

function Proto.parseP_GC_MArenaPetsChange_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_MARENAPETSCHANGE_NTF;
	data.petObjIDs=Proto.parseVector(entry,Proto.parseDWORD); -- 防守宠物objIDs
	data.teamID=Proto.parseDWORD(entry); -- 防守队伍ID
	return data;
end

function Proto.writeP_CG_RandomMArenaEnemys_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_RANDOMMARENAENEMYS_REQ);
	Proto.writeDWORD(msg,data.nowRank); -- 自己当前的排名
end

function Proto.parseP_GC_RandomMArenaEnemys_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_RANDOMMARENAENEMYS_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code==Proto.Error.ERROR_OK) then
		data.enemys=Proto.parseVector(entry,Proto.parseString); -- 对手
	end
	return data;
end

function Proto.writeP_CG_ChangeMArenaPetObjIDs_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_CHANGEMARENAPETOBJIDS_REQ);
	Proto.writeDWORD(msg,data.teamID); -- 防守队伍ID
	Proto.writeVector(msg,data.petObjIDs,Proto.writeDWORD); -- 防守宠物objIDs
end

function Proto.parseP_GC_ChangeMArenaPetObjIDs_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_CHANGEMARENAPETOBJIDS_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	return data;
end

function Proto.writeP_CG_JoinMArena_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_JOINMARENA_REQ);
	Proto.writeDWORD(msg,data.teamID); -- 防守队伍ID
	Proto.writeVector(msg,data.petObjIDs,Proto.writeDWORD); -- 防守宠物objIDs
end

function Proto.parseP_GC_JoinMArena_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_JOINMARENA_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code==Proto.Error.ERROR_OK) then
		data.rank=Proto.parseDWORD(entry); -- 排名
		data.teamID=Proto.parseDWORD(entry); -- 防守队伍ID
		data.petObjIDs=Proto.parseVector(entry,Proto.parseDWORD); -- 防守宠物objIDs
	end
	return data;
end

function Proto.writeP_CG_MArenaRankFight_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_MARENARANKFIGHT_REQ);
	Proto.writeDWORD(msg,data.rank); -- 挑战的排名
	Proto.writeDWORD(msg,data.teamID); -- 防守队伍ID
	Proto.writeVector(msg,data.petObjIDs,Proto.writeDWORD); -- 防守宠物objIDs
end

function Proto.parseP_GC_MArenaRankFight_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_MARENARANKFIGHT_ACK;
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

function Proto.writeP_CG_MArenaRankFightEnd_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_MARENARANKFIGHTEND_REQ);
	Proto.writeString(msg,data.arenaBattleID); -- 
	Proto.writeDWORD(msg,data.isWin); -- 是否胜利 0负 1胜 2平
	Proto.writeVector(msg,data.report,Proto.writeString); -- 
end

function Proto.parseP_GC_MArenaRankFightEnd_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_MARENARANKFIGHTEND_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	return data;
end

function Proto.writeP_CG_QueryMArenaRank_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_QUERYMARENARANK_REQ);
	Proto.writeDWORD(msg,data.rankMin); -- 
	Proto.writeDWORD(msg,data.rankMax); -- 
end

function Proto.parseP_GC_QueryMArenaRank_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_QUERYMARENARANK_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code==Proto.Error.ERROR_OK) then
		data.soldiers=Proto.parseVector(entry,Proto.parseString); -- 
	end
	return data;
end

function Proto.writeP_CG_QueryMArenaSoldierDetail_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_QUERYMARENASOLDIERDETAIL_REQ);
	Proto.writeDWORD(msg,data.charID); -- 
	Proto.writeDWORD(msg,data.teamID); -- 
end

function Proto.parseP_GC_QueryMArenaSoldierDetail_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_QUERYMARENASOLDIERDETAIL_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code==Proto.Error.ERROR_OK) then
		data.charID=Proto.parseDWORD(entry); -- 
		data.teamID=Proto.parseDWORD(entry); -- 
		data.pets=Proto.parseVector(entry,Proto.parseString); -- 
		data.helperPets=Proto.parseVector(entry,Proto.parseString); -- 
	end
	return data;
end

function Proto.writeP_CG_ClearMArenaCD_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_CLEARMARENACD_REQ);
end

function Proto.parseP_GC_ClearMArenaCD_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_CLEARMARENACD_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	return data;
end

function Proto.writeP_CG_BuyMArenaFightTimes_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_BUYMARENAFIGHTTIMES_REQ);
end

function Proto.parseP_GC_BuyMArenaFightTimes_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_BUYMARENAFIGHTTIMES_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	return data;
end

function Proto.writeP_CG_GetMArenaAward_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETMARENAAWARD_REQ);
end

function Proto.parseP_GC_GetMArenaAward_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETMARENAAWARD_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	return data;
end

function Proto.writeP_CG_GetMArenaRecode_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETMARENARECODE_REQ);
	Proto.writeDWORD(msg,data.startIndex); -- 
	Proto.writeDWORD(msg,data.endIndex); -- 
end

function Proto.parseP_GC_GetMArenaRecode_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETMARENARECODE_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code==Proto.Error.ERROR_OK) then
		data.isNew=Proto.parseDWORD(entry); -- 
		data.recodes=Proto.parseVector(entry,Proto.parseString); -- 
	end
	return data;
end

function Proto.writeP_CG_PlayMArenaRecode_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_PLAYMARENARECODE_REQ);
	Proto.writeString(msg,data.t); -- 
end

function Proto.parseP_GC_PlayMArenaRecode_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_PLAYMARENARECODE_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code==Proto.Error.ERROR_OK) then
		data.recodeNum=Proto.parseDWORD(entry); -- 
		data.recodeInfo=Proto.parseString(entry); -- 
	end
	return data;
end

function Proto.parseP_GC_PlayMArenaRecode_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_PLAYMARENARECODE_NTF;
	data.turnIndex=Proto.parseDWORD(entry); -- 
	data.recode=Proto.parseString(entry); -- 
	return data;
end

function Proto.parseP_GC_GetMArenaRecode_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETMARENARECODE_NTF;
	data.isNew=Proto.parseDWORD(entry); -- 
	data.recodes=Proto.parseVector(entry,Proto.parseString); -- 
	return data;
end

function Proto.parseP_GC_PlayMArenaRecode2_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_PLAYMARENARECODE2_NTF;
	data.recodeInfo=Proto.parseString(entry); -- 
	return data;
end

function Proto.parseP_GC_PlayMArenaRecode3_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_PLAYMARENARECODE3_NTF;
	data.recodeInfo=Proto.parseString(entry); -- 
	return data;
end

function Proto.parseP_GC_PlayMArenaRecode4_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_PLAYMARENARECODE4_NTF;
	data.recodeInfo=Proto.parseString(entry); -- 
	return data;
end

