-- Net.Proto.Proto_Achievement

function Proto.writeP_CG_GetAchievements_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETACHIEVEMENTS_REQ);
end

function Proto.parseP_GC_GetAchievements_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETACHIEVEMENTS_ACK;
	data.code=Proto.parseWORD(entry); -- 
	if (data.code ==Proto.Error.ERROR_OK) then
		data.achievementIDs=Proto.parseVector(entry,Proto.parseWORD); -- 
	end
	return data;
end

function Proto.writeP_CG_FinishAchievement_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_FINISHACHIEVEMENT_REQ);
	Proto.writeWORD(msg,data.achievementID); -- 成就ID
end

function Proto.parseP_GC_FinishAchievement_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_FINISHACHIEVEMENT_ACK;
	data.code=Proto.parseWORD(entry); -- 
	if (data.code ==Proto.Error.ERROR_OK) then
		data.achievementID=Proto.parseWORD(entry); -- 成就ID
	end
	return data;
end

function Proto.writeP_CG_FinishPokemonAchievement_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_FINISHPOKEMONACHIEVEMENT_REQ);
	Proto.writeWORD(msg,data.pokeAchievementID); -- 成就ID
end

function Proto.parseP_GC_FinishPokemonAchievement_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_FINISHPOKEMONACHIEVEMENT_ACK;
	data.code=Proto.parseWORD(entry); -- 
	if (data.code ==Proto.Error.ERROR_OK) then
		data.pokeAchievementID=Proto.parseWORD(entry); -- 成就ID
	end
	return data;
end

function Proto.writeP_CG_GetPokemonAchievements_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETPOKEMONACHIEVEMENTS_REQ);
end

function Proto.parseP_GC_GetPokemonAchievements_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETPOKEMONACHIEVEMENTS_ACK;
	data.code=Proto.parseWORD(entry); -- 
	if (data.code ==Proto.Error.ERROR_OK) then
		data.pokeAchievementIDs=Proto.parseVector(entry,Proto.parseWORD); -- 
	end
	return data;
end

function Proto.writeP_CG_GetPotentials_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETPOTENTIALS_REQ);
end

function Proto.parseP_GC_GetPotentials_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETPOTENTIALS_ACK;
	data.code=Proto.parseWORD(entry); -- 
	if (data.code ==Proto.Error.ERROR_OK) then
		data.potentials=Proto.parseVector(entry,Proto.parseWORD); -- 
	end
	return data;
end

function Proto.writeP_CG_BuyPotential_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_BUYPOTENTIAL_REQ);
	Proto.writeWORD(msg,data.potentialID); -- 潜力ID
end

function Proto.parseP_GC_BuyPotential_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_BUYPOTENTIAL_ACK;
	data.code=Proto.parseWORD(entry); -- 
	return data;
end

function Proto.writeP_CG_ResetAchievement_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_RESETACHIEVEMENT_REQ);
end

function Proto.parseP_GC_ResetAchievement_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_RESETACHIEVEMENT_ACK;
	data.code=Proto.parseWORD(entry); -- 
	return data;
end

function Proto.writeP_CG_FinishPokemonAchievementActivity_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_FINISHPOKEMONACHIEVEMENTACTIVITY_REQ);
	Proto.writeWORD(msg,data.pokeAchievementID); -- 成就ID
end

function Proto.parseP_GC_FinishPokemonAchievementActivity_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_FINISHPOKEMONACHIEVEMENTACTIVITY_ACK;
	data.code=Proto.parseWORD(entry); -- 
	if (data.code ==Proto.Error.ERROR_OK) then
		data.pokeAchievementID=Proto.parseWORD(entry); -- 成就ID
	end
	return data;
end

function Proto.writeP_CG_GetPokemonAchievementsAct_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETPOKEMONACHIEVEMENTSACT_REQ);
end

function Proto.parseP_GC_GetPokemonAchievementsAct_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETPOKEMONACHIEVEMENTSACT_ACK;
	data.code=Proto.parseWORD(entry); -- 
	if (data.code ==Proto.Error.ERROR_OK) then
		data.pokeAchievementIDs=Proto.parseVector(entry,Proto.parseWORD); -- 
	end
	return data;
end

