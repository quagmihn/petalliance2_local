-- Net.Proto.Proto_SurvivalBattle

function Proto.writeP_CG_GetSurvivalBattleData_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETSURVIVALBATTLEDATA_REQ);
end

function Proto.parseP_GC_GetSurvivalBattleData_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETSURVIVALBATTLEDATA_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if ( data.code ==Proto.Error.ERROR_OK) then
		data.currentFloor=Proto.parseDWORD(entry); -- 当前层数
		data.boss=Proto.parseString(entry); -- 当前boss
		data.vecUsedPets=Proto.parseVector(entry,Proto.parseDWORD); -- 使用过的宠物
	end
	return data;
end

function Proto.writeP_CG_SurvivalBattleEnd_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_SURVIVALBATTLEEND_REQ);
	Proto.writeDWORD(msg,data.damage); -- 伤害
	Proto.writeDWORD(msg,data.usePetID); -- 使用宠物objID
end

function Proto.parseP_GC_SurvivalBattleEnd_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_SURVIVALBATTLEEND_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	return data;
end

