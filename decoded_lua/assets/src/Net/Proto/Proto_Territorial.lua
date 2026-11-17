-- Net.Proto.Proto_Territorial

function Proto.writeP_CG_TerritoryInfo_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_TERRITORYINFO_REQ);
	Proto.writeVector(msg,data.adventureIDs,Proto.writeDWORD); -- 副本ID
end

function Proto.parseP_GC_TerritoryInfo_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_TERRITORYINFO_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.terrInfo=Proto.parseVector(entry,Proto.parseString); -- 领地信息
	end
	return data;
end

function Proto.writeP_CG_TerritoryInfoNoPets_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_TERRITORYINFONOPETS_REQ);
	Proto.writeVector(msg,data.adventureIDs,Proto.writeDWORD); -- 副本ID
end

function Proto.parseP_GC_TerritoryInfoNoPets_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_TERRITORYINFONOPETS_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.terrInfo=Proto.parseDWORD(entry); -- 领地信息条数
	end
	return data;
end

function Proto.writeP_CG_TerritoryFight_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_TERRITORYFIGHT_REQ);
	Proto.writeDWORD(msg,data.adventureID); -- 副本ID
	Proto.writeVector(msg,data.petsID,Proto.writeDWORD); -- 宠物ID
	Proto.writeVector(msg,data.helpPetsID,Proto.writeDWORD); -- 援助宠物ID
end

function Proto.parseP_GC_TerritoryFight_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_TERRITORYFIGHT_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.territoryBattleID=Proto.parseString(entry); --   
		data.self=Proto.parseVector(entry,Proto.parseString); -- 自己宠物
		data.enemy=Proto.parseVector(entry,Proto.parseString); -- 敌方宠物
		data.selfHelp=Proto.parseVector(entry,Proto.parseString); -- 自己援助宠物
		data.enemyHelp=Proto.parseVector(entry,Proto.parseString); -- 敌方援助宠物
		data.battleID=Proto.parseString(entry); -- 
		data.serverID=Proto.parseDWORD(entry); -- 
	end
	return data;
end

function Proto.writeP_CG_FightEnd_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_FIGHTEND_REQ);
	Proto.writeDWORD(msg,data.isWin); -- 是否胜利
	Proto.writeDWORD(msg,data.adventureID); -- 副本ID
	Proto.writeString(msg,data.territoryBattleID); --   
end

function Proto.parseP_GC_FightEnd_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_FIGHTEND_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	return data;
end

function Proto.writeP_CG_TerritoryRankInfo_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_TERRITORYRANKINFO_REQ);
end

function Proto.parseP_GC_TerritoryRankInfo_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_TERRITORYRANKINFO_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.rank=Proto.parseVector(entry,Proto.parseString); -- 排行榜
	end
	return data;
end

function Proto.writeP_CG_TerritorialResetInfo_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_TERRITORIALRESETINFO_REQ);
end

function Proto.parseP_GC_TerritorialResetInfo_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_TERRITORIALRESETINFO_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	return data;
end

function Proto.writeP_CG_SelfTerritoryInfo_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_SELFTERRITORYINFO_REQ);
end

function Proto.parseP_GC_SelfTerritoryInfo_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_SELFTERRITORYINFO_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.rank=Proto.parseString(entry); -- 排行榜
	end
	return data;
end

function Proto.writeP_CG_TerritoryCountInfo_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_TERRITORYCOUNTINFO_REQ);
end

function Proto.parseP_GC_TerritoryCountInfo_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_TERRITORYCOUNTINFO_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.Tcount=Proto.parseDWORD(entry); -- 挑战总次数
		data.buyCount=Proto.parseDWORD(entry); -- 购买次数
		data.maxCount=Proto.parseDWORD(entry); -- 最大挑战次数
	end
	return data;
end

function Proto.writeP_CG_QuerySelfTerritoryIDInfo_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_QUERYSELFTERRITORYIDINFO_REQ);
end

function Proto.parseP_GC_QuerySelfTerritoryIDInfo_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_QUERYSELFTERRITORYIDINFO_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.adventureID=Proto.parseDWORD(entry); -- 领地ID
		data.familyID=Proto.parseVector(entry,Proto.parseDWORD); -- 家族ID
	end
	return data;
end

function Proto.parseP_GC_TerritoryChange_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_TERRITORYCHANGE_NTF;
	data.charID=Proto.parseDWORD(entry); -- 擂主ID
	data.oldcharID=Proto.parseDWORD(entry); -- 原擂主ID
	data.adventureID=Proto.parseDWORD(entry); -- 领地ID
	return data;
end

function Proto.parseP_GC_TerritoryCountChange_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_TERRITORYCOUNTCHANGE_NTF;
	data.count=Proto.parseString(entry); -- 次数变化
	return data;
end

function Proto.parseP_GC_TerritoryInfoWiki_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_TERRITORYINFOWIKI_NTF;
	data.territoryInfo=Proto.parseVector(entry,Proto.parseString); -- 领主信息
	return data;
end

