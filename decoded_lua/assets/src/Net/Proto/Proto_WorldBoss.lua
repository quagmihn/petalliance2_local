-- Net.Proto.Proto_WorldBoss

function Proto.writeP_CG_GetWorldBoss_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETWORLDBOSS_REQ);
end

function Proto.parseP_GC_GetWorldBoss_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETWORLDBOSS_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if ( data.code ==Proto.Error.ERROR_OK) then
		data.bossID=Proto.parseDWORD(entry); -- bossID
		data.mapID=Proto.parseDWORD(entry); -- 地图ID
		data.duration=Proto.parseDWORD(entry); -- 持续时间
		data.isLive=Proto.parseDWORD(entry); -- 是否存活
		data.createTime=Proto.parseDWORD(entry); -- 创建时间
	end
	return data;
end

function Proto.writeP_CG_GetSelfWorldBossData_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETSELFWORLDBOSSDATA_REQ);
end

function Proto.parseP_GC_GetSelfWorldBossData_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETSELFWORLDBOSSDATA_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if ( data.code ==Proto.Error.ERROR_OK) then
		data.usedPets=Proto.parseVector(entry,Proto.parseDWORD); -- 使用过的宠物objID
		data.damage=Proto.parseDWORD(entry); -- 伤害
		data.state=Proto.parseDWORD(entry); -- 状态
		data.actionTime=Proto.parseDWORD(entry); -- 上次攻击时间
	end
	return data;
end

function Proto.writeP_CG_AttackBoss_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_ATTACKBOSS_REQ);
	Proto.writeDWORD(msg,data.petObjID); -- 宠物ObjID
	Proto.writeDWORD(msg,data.pos); -- 位置
end

function Proto.parseP_GC_AttackBoss_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_ATTACKBOSS_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if ( data.code ==Proto.Error.ERROR_OK) then
		data.damage=Proto.parseDWORD(entry); -- 伤害
	end
	return data;
end

function Proto.writeP_CG_TakeAward_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_TAKEAWARD_REQ);
end

function Proto.parseP_GC_TakeAward_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_TAKEAWARD_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	return data;
end

function Proto.writeP_CG_DiamondRecoverPet_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_DIAMONDRECOVERPET_REQ);
end

function Proto.parseP_GC_DiamondRecoverPet_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_DIAMONDRECOVERPET_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	return data;
end

function Proto.writeP_CG_DiamondRecoverAll_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_DIAMONDRECOVERALL_REQ);
end

function Proto.parseP_GC_DiamondRecoverAll_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_DIAMONDRECOVERALL_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	return data;
end

function Proto.writeP_CG_NormalRecover_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_NORMALRECOVER_REQ);
end

function Proto.parseP_GC_NormalRecover_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_NORMALRECOVER_ACK;
	data.code=Proto.parseWORD(entry); --  错误码
	return data;
end

function Proto.writeP_CG_BossAttack_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_BOSSATTACK_REQ);
	Proto.writeDWORD(msg,data.damage); -- 伤害
end

function Proto.parseP_GC_BossAttack_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_BOSSATTACK_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	return data;
end

function Proto.parseP_GC_CharStateChange_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_CHARSTATECHANGE_NTF;
	data.state=Proto.parseDWORD(entry); -- 状态
	return data;
end

function Proto.writeP_CG_GetDamageRank_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETDAMAGERANK_REQ);
end

function Proto.parseP_GC_GetDamageRank_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETDAMAGERANK_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if ( data.code==Proto.Error.ERROR_OK) then
		data.damageRank=Proto.parseVector(entry,Proto.parseDamageRank); -- 伤害排行
	end
	return data;
end

function Proto.writeP_CG_TakeWeekAward_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_TAKEWEEKAWARD_REQ);
	Proto.writeDWORD(msg,data.type); -- 类型
end

function Proto.parseP_GC_TakeWeekAward_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_TAKEWEEKAWARD_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code==Proto.Error.ERROR_OK) then
		data.award=Proto.parseVector(entry,Proto.parseString); -- 奖励物品信息
	end
	return data;
end

function Proto.writeP_CG_GetWeekChampionData_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETWEEKCHAMPIONDATA_REQ);
end

function Proto.parseP_GC_GetWeekChampionData_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETWEEKCHAMPIONDATA_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code==Proto.Error.ERROR_OK) then
		data.charID=Proto.parseDWORD(entry); -- 玩家姓名
		data.nickName=Proto.parseString(entry); -- 昵称
		data.familyName=Proto.parseString(entry); -- 家族名称
		data.fashions=Proto.parseVector(entry,Proto.parseDWORD); -- 时装信息
		data.message=Proto.parseString(entry); -- 留言
	end
	return data;
end

function Proto.writeP_CG_UpdateMessage_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_UPDATEMESSAGE_REQ);
	Proto.writeString(msg,data.content); -- 留言内容
end

function Proto.parseP_GC_UpdateMessage_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_UPDATEMESSAGE_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	return data;
end

function Proto.writeP_CG_GetWeekDamageRank_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETWEEKDAMAGERANK_REQ);
	Proto.writeDWORD(msg,data.rankMin); -- 
	Proto.writeDWORD(msg,data.rankMax); -- 
end

function Proto.parseP_GC_GetWeekDamageRank_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETWEEKDAMAGERANK_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if ( data.code==Proto.Error.ERROR_OK) then
		data.rankMin=Proto.parseDWORD(entry); -- 
		data.rankMax=Proto.parseDWORD(entry); -- 
	end
	if (data.code==Proto.Error.ERROR_OK) then
		data.soldiers=Proto.parseVector(entry,Proto.parseString); -- 
	end
	return data;
end

function Proto.writeP_CG_GetMyWeekDamageRank_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETMYWEEKDAMAGERANK_REQ);
end

function Proto.parseP_GC_GetMyWeekDamageRank_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETMYWEEKDAMAGERANK_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if ( data.code==Proto.Error.ERROR_OK) then
		data.rank=Proto.parseDWORD(entry); -- 
	end
	return data;
end

