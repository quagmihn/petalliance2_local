-- Net.Proto.Proto_PVP

Proto.BattleUnReady	= 0							-- []
Proto.BattleReady	= Proto.BattleUnReady + 1	-- []
Proto.BattleReadyOK	= Proto.BattleReady + 1		-- []
Proto.BattleLoading	= Proto.BattleReadyOK + 1	-- []
Proto.BattleStart	= Proto.BattleLoading + 1	-- []
Proto.BattleWaitCommand			= 0										-- []
Proto.BattlePlayCommand			= Proto.BattleWaitCommand + 1			-- []
Proto.BattlePlayChallengerWin	= Proto.BattlePlayCommand + 1			-- []
Proto.BattlePlayBeChallengeWin	= Proto.BattlePlayChallengerWin + 1		-- []
Proto.BattlePlayNoneWin			= Proto.BattlePlayBeChallengeWin + 1	-- []
Proto.BattlePlayError			= Proto.BattlePlayNoneWin + 1			-- []

function Proto.writeP_CG_StartPVP_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_STARTPVP_REQ);
	Proto.writeDWORD(msg,data.bechallengeCharID); -- 对手角色ID
end

function Proto.parseP_GC_StartPVP_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_STARTPVP_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.battleID=Proto.parseQWORD(entry); -- 
		data.zoneID=Proto.parseDWORD(entry); -- 
		data.challengerID=Proto.parseDWORD(entry); -- 
		data.bechallengeCharID=Proto.parseDWORD(entry); -- 
		data.serverID=Proto.parseDWORD(entry); -- 
	end
	return data;
end

function Proto.parseP_GC_PVPInfo_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_PVPINFO_NTF;
	data.battleID=Proto.parseQWORD(entry); -- 
	data.zoneID=Proto.parseDWORD(entry); -- 
	data.challengerID=Proto.parseDWORD(entry); -- 
	data.bechallengeCharID=Proto.parseDWORD(entry); -- 
	data.battleStatus=Proto.parseDWORD(entry); -- 
	data.challengerPets=Proto.parseVector(entry,Proto.parseString); -- 战斗宠物列表
	data.bechallengePets=Proto.parseVector(entry,Proto.parseString); -- 战斗宠物列表
	data.name=Proto.parseString(entry); -- 挑战者昵称
	data.serverID=Proto.parseDWORD(entry); -- 服务器ID
	data.challengerHelperPets=Proto.parseVector(entry,Proto.parseString); -- 战斗宠物列表
	data.bechallengeHelperPets=Proto.parseVector(entry,Proto.parseString); -- 战斗宠物列表
	data.bossID=Proto.parseQWORD(entry); -- bossID
	data.bossHP=Proto.parseString(entry); -- bossID
	data.isPVPArenaBattle=Proto.parseWORD(entry); -- 是否为pvp竞技场战斗
	data.challengerGrade=Proto.parseDWORD(entry); -- 等阶
	data.challengerPoint=Proto.parseDWORD(entry); -- 积分
	data.bechallengeGrade=Proto.parseDWORD(entry); -- 等阶
	data.bechallengePoint=Proto.parseDWORD(entry); -- 积分
	data.challengerOtherParam=Proto.parseString(entry); -- 挑战者其他信息
	data.bechallengeOtherParam=Proto.parseString(entry); -- 被挑战者其他信息
	return data;
end

function Proto.writeP_CG_ReadyPVP_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_READYPVP_REQ);
	Proto.writeQWORD(msg,data.battleID); -- 战场id
	Proto.writeVector(msg,data.pets,Proto.writeString); -- 战斗宠物列表
	Proto.writeDWORD(msg,data.serverID); -- 服务器ID
	Proto.writeVector(msg,data.helperPets,Proto.writeString); -- 战斗宠物列表
end

function Proto.parseP_GC_ReadyPVP_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_READYPVP_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code==Proto.Error.ERROR_OK) then
		data.battleID=Proto.parseQWORD(entry); -- 
		data.zoneID=Proto.parseDWORD(entry); -- 
		data.challengerID=Proto.parseDWORD(entry); -- 
		data.bechallengeCharID=Proto.parseDWORD(entry); -- 
	end
	return data;
end

function Proto.writeP_CG_JoinPVP_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_JOINPVP_REQ);
	Proto.writeQWORD(msg,data.battleID); -- 
	Proto.writeDWORD(msg,data.serverID); -- 服务器ID
end

function Proto.parseP_GC_JoinPVP_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_JOINPVP_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	return data;
end

function Proto.parseP_GC_PVPBattleCommand_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_PVPBATTLECOMMAND_NTF;
	data.battleID=Proto.parseQWORD(entry); -- 
	data.zoneID=Proto.parseDWORD(entry); -- 
	data.roundIndex=Proto.parseDWORD(entry); -- 
	data.battleCommandStatus=Proto.parseDWORD(entry); -- 
	data.battleCommands=Proto.parseVector(entry,Proto.parseString); -- 战斗指令
	return data;
end

function Proto.writeP_CG_PVPBattleCommand_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_PVPBATTLECOMMAND_REQ);
	Proto.writeQWORD(msg,data.battleID); -- 
	Proto.writeDWORD(msg,data.roundIndex); -- 
	Proto.writeDWORD(msg,data.skillIndex); -- 技能索引
	Proto.writeDWORD(msg,data.petID); -- 更换宠物ID 不换填0
	Proto.writeDWORD(msg,data.serverID); -- 服务器ID
end

function Proto.parseP_GC_PVPBattleCommand_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_PVPBATTLECOMMAND_ACK;
	data.code=Proto.parseWORD(entry); -- 
	return data;
end

function Proto.writeP_CG_PVPBattleStart_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_PVPBATTLESTART_REQ);
	Proto.writeQWORD(msg,data.battleID); -- 
	Proto.writeDWORD(msg,data.serverID); -- 服务器ID
end

function Proto.parseP_GC_PVPBattleStart_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_PVPBATTLESTART_ACK;
	data.code=Proto.parseWORD(entry); -- 
	return data;
end

function Proto.writeP_CG_LeavePVP_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_LEAVEPVP_REQ);
	Proto.writeQWORD(msg,data.battleID); -- 
	Proto.writeDWORD(msg,data.serverID); -- 服务器ID
end

function Proto.parseP_GC_LeavePVP_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_LEAVEPVP_ACK;
	data.code=Proto.parseWORD(entry); -- 
	return data;
end

function Proto.writeP_CG_GetPVPRecords_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETPVPRECORDS_REQ);
	Proto.writeQWORD(msg,data.battleID); -- 
	Proto.writeDWORD(msg,data.serverID); -- 服务器ID
	Proto.writeDWORD(msg,data.startIndex); -- 开始索引
end

function Proto.parseP_GC_GetPVPRecords_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETPVPRECORDS_ACK;
	data.code=Proto.parseWORD(entry); -- 
	return data;
end

function Proto.writeP_CG_JumpPVPTurn_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_JUMPPVPTURN_REQ);
	Proto.writeQWORD(msg,data.battleID); -- 
	Proto.writeDWORD(msg,data.serverID); -- 服务器ID
	Proto.writeDWORD(msg,data.startIndex); -- 开始索引
end

function Proto.parseP_GC_JumpPVPTurn_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_JUMPPVPTURN_ACK;
	data.code=Proto.parseWORD(entry); -- 
	return data;
end

function Proto.writeP_CG_GetPVPOneRecode_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETPVPONERECODE_REQ);
	Proto.writeQWORD(msg,data.battleID); -- 
	Proto.writeDWORD(msg,data.serverID); -- 服务器ID
	Proto.writeDWORD(msg,data.turnIndex); -- turnIndex
end

function Proto.parseP_GC_GetPVPOneRecode_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETPVPONERECODE_ACK;
	data.code=Proto.parseWORD(entry); -- 
	if (data.code ==Proto.Error.ERROR_OK) then
		data.battleID=Proto.parseQWORD(entry); -- 
		data.serverID=Proto.parseDWORD(entry); -- 服务器ID
		data.turnIndex=Proto.parseDWORD(entry); -- turnIndex
		data.report=Proto.parseString(entry); -- 
	end
	return data;
end

function Proto.writeP_CG_GetPVPCurrentBattleInfo_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETPVPCURRENTBATTLEINFO_REQ);
	Proto.writeQWORD(msg,data.battleID); -- 
	Proto.writeDWORD(msg,data.serverID); -- 服务器ID
end

function Proto.parseP_GC_GetPVPCurrentBattleInfo_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETPVPCURRENTBATTLEINFO_ACK;
	data.code=Proto.parseWORD(entry); -- 
	if (data.code ==Proto.Error.ERROR_OK) then
		data.battleID=Proto.parseQWORD(entry); -- 
		data.serverID=Proto.parseDWORD(entry); -- 服务器ID
		data.turnIndex=Proto.parseDWORD(entry); -- turnIndex
		data.battleInfo=Proto.parseString(entry); -- 
	end
	return data;
end

function Proto.writeP_CG_RefusePVPRequest_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_REFUSEPVPREQUEST_REQ);
	Proto.writeQWORD(msg,data.battleID); -- 
	Proto.writeDWORD(msg,data.serverID); -- 服务器ID
	Proto.writeDWORD(msg,data.charID); -- 角色ID
end

function Proto.parseP_GC_RefusePVPRequest_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_REFUSEPVPREQUEST_ACK;
	data.code=Proto.parseWORD(entry); -- 
	if (data.code ==Proto.Error.ERROR_OK) then
		data.battleID=Proto.parseQWORD(entry); -- 
		data.serverID=Proto.parseDWORD(entry); -- 服务器ID
	end
	return data;
end

function Proto.writeP_CG_JoinPVPArena_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_JOINPVPARENA_REQ);
	Proto.writeVector(msg,data.petObjIDs,Proto.writeDWORD); -- 
	Proto.writeVector(msg,data.helperPetObjIDs,Proto.writeDWORD); -- 
	Proto.writeDWORD(msg,data.level); -- 
end

function Proto.parseP_GC_JoinPVPArena_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_JOINPVPARENA_ACK;
	data.code=Proto.parseWORD(entry); -- 
	return data;
end

function Proto.writeP_CG_CancelJoinPVPArena_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_CANCELJOINPVPARENA_REQ);
end

function Proto.parseP_GC_CancelJoinPVPArena_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_CANCELJOINPVPARENA_ACK;
	data.code=Proto.parseWORD(entry); -- 
	return data;
end

function Proto.writeP_CG_GetPVPArenaAward_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETPVPARENAAWARD_REQ);
end

function Proto.parseP_GC_GetPVPArenaAward_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETPVPARENAAWARD_ACK;
	data.code=Proto.parseWORD(entry); -- 
	return data;
end

function Proto.writeP_CG_GetPVPArenaRank_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETPVPARENARANK_REQ);
	Proto.writeDWORD(msg,data.rankMin); -- 
	Proto.writeDWORD(msg,data.rankMax); -- 
end

function Proto.parseP_GC_GetPVPArenaRank_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETPVPARENARANK_ACK;
	data.code=Proto.parseWORD(entry); -- 
	if (data.code==Proto.Error.ERROR_OK) then
		data.soldiers=Proto.parseVector(entry,Proto.parseString); -- 
	end
	return data;
end

function Proto.writeP_CG_GetMYPVPArenaRank_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETMYPVPARENARANK_REQ);
end

function Proto.parseP_GC_GetMYPVPArenaRank_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETMYPVPARENARANK_ACK;
	data.code=Proto.parseWORD(entry); -- 
	if (data.code==Proto.Error.ERROR_OK) then
		data.rank=Proto.parseDWORD(entry); -- 
	end
	return data;
end

function Proto.writeP_CG_GetMYPVPArenaQuests_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETMYPVPARENAQUESTS_REQ);
end

function Proto.parseP_GC_GetMYPVPArenaQuests_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETMYPVPARENAQUESTS_ACK;
	data.code=Proto.parseWORD(entry); -- 
	if (data.code==Proto.Error.ERROR_OK) then
		data.pvpArenaQuestData=Proto.parseString(entry); -- 
	end
	return data;
end

function Proto.writeP_CG_CommitPVPArenaQuest_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_COMMITPVPARENAQUEST_REQ);
	Proto.writeDWORD(msg,data.questID); -- 
end

function Proto.parseP_GC_CommitPVPArenaQuest_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_COMMITPVPARENAQUEST_ACK;
	data.code=Proto.parseWORD(entry); -- 
	if (data.code==Proto.Error.ERROR_OK) then
		data.pvpArenaQuestData=Proto.parseString(entry); -- 
	end
	return data;
end

function Proto.writeP_CG_ResetPVPArenaQuest_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_RESETPVPARENAQUEST_REQ);
	Proto.writeDWORD(msg,data.questID); -- 
end

function Proto.parseP_GC_ResetPVPArenaQuest_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_RESETPVPARENAQUEST_ACK;
	data.code=Proto.parseWORD(entry); -- 
	if (data.code==Proto.Error.ERROR_OK) then
		data.pvpArenaQuestData=Proto.parseString(entry); -- 
	end
	return data;
end

function Proto.writeP_CG_GetPVPArenaQuestPowerAward_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETPVPARENAQUESTPOWERAWARD_REQ);
end

function Proto.parseP_GC_GetPVPArenaQuestPowerAward_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETPVPARENAQUESTPOWERAWARD_ACK;
	data.code=Proto.parseWORD(entry); -- 
	if (data.code==Proto.Error.ERROR_OK) then
		data.pvpArenaQuestData=Proto.parseString(entry); -- 
	end
	return data;
end

