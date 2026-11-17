-- Net.Proto.Proto_Spa_Types

function Proto.parseSpaCardInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 卡片ID
	data.capsule=Proto.parseDWORD(entry); -- 维护胶囊ID
	data.routine=Proto.parseSpaCardFormula(entry); -- 泡的效果
	data.final=Proto.parseSpaCardFormula(entry); -- 整体效果
	return data;
end

function Proto.getSpaCardInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeSpaCardInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 卡片ID
	Proto.writeDWORD(msg,data.capsule); -- 维护胶囊ID
	Proto.writeSpaCardFormula(msg,data.routine); -- 泡的效果
	Proto.writeSpaCardFormula(msg,data.final); -- 整体效果
end

