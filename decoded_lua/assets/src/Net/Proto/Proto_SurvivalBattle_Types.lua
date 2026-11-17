-- Net.Proto.Proto_SurvivalBattle_Types

function Proto.parseAwardList(entry)
	local data={};
	data.itemID=Proto.parseDWORD(entry); -- 物品ID
	data.count=Proto.parseDWORD(entry); -- 个数
	return data;
end

function Proto.writeAwardList(msg,data)
	Proto.writeDWORD(msg,data.itemID); -- 物品ID
	Proto.writeDWORD(msg,data.count); -- 个数
end

function Proto.parseSurvivalBattleAwardInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.awardList=Proto.parseVector(entry,Proto.parseAwardList); -- 奖励列表
	return data;
end

function Proto.getSurvivalBattleAwardInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeSurvivalBattleAwardInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeVector(msg,data.awardList,Proto.writeAwardList); -- 奖励列表
end

