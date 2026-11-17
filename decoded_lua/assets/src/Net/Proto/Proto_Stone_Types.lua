-- Net.Proto.Proto_Stone_Types

function Proto.parseHCSynthetiseInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 序号
	data.itemID=Proto.parseDWORD(entry); -- 材料ID
	data.num=Proto.parseDWORD(entry); -- 需求数量
	data.cost=Proto.parseDWORD(entry); -- 费用
	data.prob=Proto.parseDWORD(entry); -- 成功率
	data.newID=Proto.parseDWORD(entry); -- 目标ID
	return data;
end

function Proto.getHCSynthetiseInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeHCSynthetiseInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 序号
	Proto.writeDWORD(msg,data.itemID); -- 材料ID
	Proto.writeDWORD(msg,data.num); -- 需求数量
	Proto.writeDWORD(msg,data.cost); -- 费用
	Proto.writeDWORD(msg,data.prob); -- 成功率
	Proto.writeDWORD(msg,data.newID); -- 目标ID
end

function Proto.parseRJSynthetiseInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 等阶
	data.material=Proto.parseVector(entry,Proto.parseDWORD); -- 材料
	data.weight=Proto.parseVector(entry,Proto.parseDWORD); -- 权重值
	data.prob=Proto.parseDWORD(entry); -- 成功率
	data.cost=Proto.parseDWORD(entry); -- 费用
	return data;
end

function Proto.getRJSynthetiseInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeRJSynthetiseInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 等阶
	Proto.writeVector(msg,data.material,Proto.writeDWORD); -- 材料
	Proto.writeVector(msg,data.weight,Proto.writeDWORD); -- 权重值
	Proto.writeDWORD(msg,data.prob); -- 成功率
	Proto.writeDWORD(msg,data.cost); -- 费用
end

