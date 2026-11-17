-- Net.Proto.Proto_Battle

function Proto.writeP_CG_CreatePVEBattle_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_CREATEPVEBATTLE_REQ);
	Proto.writeDWORD(msg,data.battleType); -- 
	Proto.writeDWORD(msg,data.battleTypeID); -- 
	Proto.writeDWORD(msg,data.battleTypeSubID); -- 
end

function Proto.parseP_GC_CreatePVEBattle_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_CREATEPVEBATTLE_ACK;
	data.code=Proto.parseWORD(entry); -- 
	if (data.code ==Proto.Error.ERROR_OK) then
		data.monsters=Proto.parseVector(entry,Proto.parseString); -- 
		data.exp=Proto.parseDWORD(entry); -- 
		data.helpMonsters=Proto.parseVector(entry,Proto.parseString); -- 
	end
	return data;
end

function Proto.writeP_CG_PVEBattleEnd_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_PVEBATTLEEND_REQ);
	Proto.writeWORD(msg,data.isWin); -- 0 败 1 胜 2平
	Proto.writeVector(msg,data.battleDetails,Proto.writeString); -- 战斗信息
end

function Proto.parseP_GC_PVEBattleEnd_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_PVEBATTLEEND_ACK;
	data.code=Proto.parseWORD(entry); -- 
	if (data.code ==Proto.Error.ERROR_OK) then
		data.exp=Proto.parseDWORD(entry); -- 
	end
	return data;
end

function Proto.writeP_CG_PVEPokemonCatch_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_PVEPOKEMONCATCH_REQ);
	Proto.writeDWORD(msg,data.pokemonID); -- 
	Proto.writeDWORD(msg,data.itemID); -- 
end

function Proto.parseP_GC_PVEPokemonCatch_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_PVEPOKEMONCATCH_ACK;
	data.code=Proto.parseWORD(entry); -- 
	if (data.code ==Proto.Error.ERROR_OK) then
		data.isCatched=Proto.parseWORD(entry); -- 0 捉失败 1 捉成功
		data.petData=Proto.parseString(entry); -- 
		data.pb=Proto.parseDWORD(entry); -- 
	end
	return data;
end

