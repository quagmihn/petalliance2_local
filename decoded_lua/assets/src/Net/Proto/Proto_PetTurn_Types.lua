-- Net.Proto.Proto_PetTurn_Types

function Proto.parsePetTurnCreditCardInfo(entry)
	local data={};
	data.creditCartType=Proto.parseBYTE(entry); -- 信用卡类型
	data.creditCartValue=Proto.parseDWORD(entry); -- 值
	return data;
end

function Proto.writePetTurnCreditCardInfo(msg,data)
	Proto.writeBYTE(msg,data.creditCartType); -- 信用卡类型
	Proto.writeDWORD(msg,data.creditCartValue); -- 值
end

function Proto.parsePetTurnInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 种族
	data.raceHP=Proto.parseWORD(entry); -- 种族HP值
	data.raceSP=Proto.parseWORD(entry); -- 种族SP值
	data.lightAttack=Proto.parseWORD(entry); -- 物攻
	data.lightDefence=Proto.parseWORD(entry); -- 物防
	data.darkAttack=Proto.parseWORD(entry); -- 魔攻
	data.darkDefence=Proto.parseWORD(entry); -- 魔防
	return data;
end

function Proto.getPetTurnInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writePetTurnInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 种族
	Proto.writeWORD(msg,data.raceHP); -- 种族HP值
	Proto.writeWORD(msg,data.raceSP); -- 种族SP值
	Proto.writeWORD(msg,data.lightAttack); -- 物攻
	Proto.writeWORD(msg,data.lightDefence); -- 物防
	Proto.writeWORD(msg,data.darkAttack); -- 魔攻
	Proto.writeWORD(msg,data.darkDefence); -- 魔防
end

function Proto.parsePetTurnRuleInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 转生前种族
	data.needLevel=Proto.parseWORD(entry); -- 需要等级
	data.targetRace=Proto.parseDWORD(entry); -- 转生后种族
	data.needCreditCardInfo=Proto.parseVector(entry,Proto.parsePetTurnCreditCardInfo); -- 花费信用卡信息
	return data;
end

function Proto.getPetTurnRuleInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writePetTurnRuleInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 转生前种族
	Proto.writeWORD(msg,data.needLevel); -- 需要等级
	Proto.writeDWORD(msg,data.targetRace); -- 转生后种族
	Proto.writeVector(msg,data.needCreditCardInfo,Proto.writePetTurnCreditCardInfo); -- 花费信用卡信息
end

function Proto.parsePetImmolateInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 献祭种族
	data.getCreditCardInfo=Proto.parseVector(entry,Proto.parsePetTurnCreditCardInfo); -- 收获信用卡信息
	return data;
end

function Proto.getPetImmolateInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writePetImmolateInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 献祭种族
	Proto.writeVector(msg,data.getCreditCardInfo,Proto.writePetTurnCreditCardInfo); -- 收获信用卡信息
end

function Proto.parsePetAwakeInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 转生前种族
	data.costCreditCardInfo=Proto.parseVector(entry,Proto.parsePetTurnCreditCardInfo); -- 花费信用卡信息
	data.geneGroup=Proto.parseDWORD(entry); -- 觉醒技能组
	return data;
end

function Proto.getPetAwakeInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writePetAwakeInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 转生前种族
	Proto.writeVector(msg,data.costCreditCardInfo,Proto.writePetTurnCreditCardInfo); -- 花费信用卡信息
	Proto.writeDWORD(msg,data.geneGroup); -- 觉醒技能组
end

function Proto.parsePetSoulPoolInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 编号
	data.expandCostInfo=Proto.parseCostInfo(entry); -- 花费
	data.creditCardLimitInfo=Proto.parseVector(entry,Proto.parsePetTurnCreditCardInfo); -- 信用卡最大限制信息
	return data;
end

function Proto.getPetSoulPoolInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writePetSoulPoolInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 编号
	Proto.writeCostInfo(msg,data.expandCostInfo); -- 花费
	Proto.writeVector(msg,data.creditCardLimitInfo,Proto.writePetTurnCreditCardInfo); -- 信用卡最大限制信息
end

