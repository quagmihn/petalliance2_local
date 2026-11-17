-- Net.Proto.Proto_Team

function Proto.writeP_CG_AutoJoinTeam_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_AUTOJOINTEAM_REQ);
	Proto.writeDWORD(msg,data.adventureID); -- 
	Proto.writeDWORD(msg,data.leaderID); -- 
end

function Proto.parseP_GC_AutoJoinTeam_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_AUTOJOINTEAM_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	return data;
end

function Proto.parseP_GC_AutoJoinTeam_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_AUTOJOINTEAM_NTF;
	data.teamData=Proto.parseTeamData(entry); -- 
	return data;
end

function Proto.writeP_CG_CancelAutoJoinTeam_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_CANCELAUTOJOINTEAM_REQ);
	Proto.writeDWORD(msg,data.adventureID); -- 
end

function Proto.parseP_GC_CancelAutoJoinTeam_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_CANCELAUTOJOINTEAM_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	return data;
end

function Proto.writeP_CG_CreateTeam_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_CREATETEAM_REQ);
	Proto.writeDWORD(msg,data.adventureID); -- 
	Proto.writeDWORD(msg,data.canAutoJoin); -- 0不能 1能
end

function Proto.parseP_GC_CreateTeam_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_CREATETEAM_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code==Proto.Error.ERROR_OK) then
		data.teamData=Proto.parseTeamData(entry); -- 
	end
	return data;
end

function Proto.writeP_CG_GetTeamMembers_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETTEAMMEMBERS_REQ);
	Proto.writeVector(msg,data.memberIndexs,Proto.writeDWORD); -- [0,1,2]
end

function Proto.parseP_GC_GetTeamMembers_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETTEAMMEMBERS_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code==Proto.Error.ERROR_OK) then
		data.memberIndexs=Proto.parseVector(entry,Proto.parseDWORD); -- [0,1,2]
		data.teamMemberDatas=Proto.parseVector(entry,Proto.parseTeamMemberData); -- 
	end
	return data;
end

function Proto.writeP_CG_SetTeamReady_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_SETTEAMREADY_REQ);
	Proto.writeDWORD(msg,data.isReady); -- 0:notReady 1:ready
end

function Proto.parseP_GC_SetTeamReady_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_SETTEAMREADY_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code==Proto.Error.ERROR_OK) then
		data.isReady=Proto.parseDWORD(entry); -- 0:notReady 1:ready
	end
	return data;
end

function Proto.writeP_CG_SetTeamPets_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_SETTEAMPETS_REQ);
	Proto.writeVector(msg,data.petObjIDs,Proto.writeDWORD); -- 
	Proto.writeVector(msg,data.helperPetObjIDs,Proto.writeDWORD); -- 
end

function Proto.parseP_GC_SetTeamPets_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_SETTEAMPETS_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code==Proto.Error.ERROR_OK) then
		data.teamMemberData=Proto.parseTeamMemberData(entry); -- 
	end
	return data;
end

function Proto.writeP_CG_KickTeamMember_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_KICKTEAMMEMBER_REQ);
	Proto.writeDWORD(msg,data.charID); -- 
end

function Proto.parseP_GC_KickTeamMember_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_KICKTEAMMEMBER_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code==Proto.Error.ERROR_OK) then
		data.charID=Proto.parseDWORD(entry); -- 
	end
	return data;
end

function Proto.parseP_GC_KickTeamMember_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_KICKTEAMMEMBER_NTF;
	data.charID=Proto.parseDWORD(entry); -- 
	return data;
end

function Proto.writeP_CG_InviteTeamMember_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_INVITETEAMMEMBER_REQ);
	Proto.writeDWORD(msg,data.charID); -- 
end

function Proto.parseP_GC_InviteTeamMember_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_INVITETEAMMEMBER_ACK;
	data.code=Proto.parseWORD(entry); -- 
	return data;
end

function Proto.writeP_CG_RefuseJoinTeam_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_REFUSEJOINTEAM_REQ);
	Proto.writeDWORD(msg,data.teamID); -- 
end

function Proto.parseP_GC_RefuseJoinTeam_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_REFUSEJOINTEAM_ACK;
	data.code=Proto.parseWORD(entry); -- 
	return data;
end

function Proto.writeP_CG_GetMyTeam_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETMYTEAM_REQ);
end

function Proto.parseP_GC_GetMyTeam_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETMYTEAM_ACK;
	data.code=Proto.parseWORD(entry); -- 
	if (data.code==Proto.Error.ERROR_OK) then
		data.teamData=Proto.parseTeamData(entry); -- 
	end
	return data;
end

function Proto.writeP_CG_SetTeamSort_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_SETTEAMSORT_REQ);
	Proto.writeVector(msg,data.teamSort,Proto.writeDWORD); -- 组队位置排列，空数组代表正常排列位置，[0,1,2]正常顺序排列
end

function Proto.parseP_GC_SetTeamSort_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_SETTEAMSORT_ACK;
	data.code=Proto.parseWORD(entry); -- 
	data.teamSort=Proto.parseVector(entry,Proto.parseDWORD); -- 组队位置排列，空数组代表正常排列位置，[0,1,2]正常顺序排列
	return data;
end

function Proto.writeP_CG_SetTeamAutoJoin_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_SETTEAMAUTOJOIN_REQ);
	Proto.writeDWORD(msg,data.canAutoJoin); -- 
end

function Proto.parseP_GC_SetTeamAutoJoin_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_SETTEAMAUTOJOIN_ACK;
	data.code=Proto.parseWORD(entry); -- 
	data.canAutoJoin=Proto.parseDWORD(entry); -- 
	return data;
end

function Proto.parseP_GC_TeamDungeonEnd_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_TEAMDUNGEONEND_NTF;
	data.chestID=Proto.parseDWORD(entry); -- 宝箱ID
	return data;
end

function Proto.writeP_CG_EnterTeamDungeon_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_ENTERTEAMDUNGEON_REQ);
	Proto.writeDWORD(msg,data.mapID); -- 地图ID
end

function Proto.parseP_GC_EnterTeamDungeon_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_ENTERTEAMDUNGEON_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	return data;
end

function Proto.writeP_CG_TeamBattleEnd_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_TEAMBATTLEEND_REQ);
	Proto.writeWORD(msg,data.isWin); -- 0 败 1 胜 2平
	Proto.writeVector(msg,data.battleDetails,Proto.writeString); -- 战斗信息
	Proto.writeDWORD(msg,data.monsterHP); -- 怪物血量
	Proto.writeDWORD(msg,data.battleID); -- 战斗ID
	Proto.writeDWORD(msg,data.x); -- x坐标
	Proto.writeDWORD(msg,data.y); -- y坐标
end

function Proto.parseP_GC_TeamBattleEnd_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_TEAMBATTLEEND_ACK;
	data.code=Proto.parseWORD(entry); -- 
	if (data.code ==Proto.Error.ERROR_OK) then
		data.exp=Proto.parseDWORD(entry); -- 
	end
	return data;
end

function Proto.writeP_CG_LeaveTeamDungeon_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_LEAVETEAMDUNGEON_REQ);
end

function Proto.parseP_GC_LeaveTeamDungeon_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_LEAVETEAMDUNGEON_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	return data;
end

function Proto.parseP_GC_CharacterLeaveDungeon_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_CHARACTERLEAVEDUNGEON_NTF;
	data.charID=Proto.parseDWORD(entry); -- 玩家ID
	return data;
end

function Proto.writeP_CG_ChangeArmyPet_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_CHANGEARMYPET_REQ);
	Proto.writeVector(msg,data.pets,Proto.writeDWORD); -- 出站宠物列表
	Proto.writeVector(msg,data.helperPets,Proto.writeDWORD); -- 援助宠物列表
end

function Proto.parseP_GC_ChangeArmyPet_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_CHANGEARMYPET_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	return data;
end

function Proto.writeP_CG_ReviveCharacter_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_REVIVECHARACTER_REQ);
	Proto.writeDWORD(msg,data.charID); -- 玩家ID
end

function Proto.parseP_GC_ReviveCharacter_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_REVIVECHARACTER_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	return data;
end

function Proto.writeP_CG_TeamDungeonBattleStart_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_TEAMDUNGEONBATTLESTART_REQ);
	Proto.writeDWORD(msg,data.monsterID); -- 怪物ID
end

function Proto.parseP_GC_TeamDungeonBattleStart_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_TEAMDUNGEONBATTLESTART_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	return data;
end

function Proto.writeP_CG_QueryTeamDungeonMonsterHp_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_QUERYTEAMDUNGEONMONSTERHP_REQ);
end

function Proto.parseP_GC_QueryTeamDungeonMonsterHp_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_QUERYTEAMDUNGEONMONSTERHP_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.vecMonsterHp=Proto.parseVector(entry,Proto.parseTeamMonsterHp); -- 组队副本怪物血量列表
	end
	return data;
end

