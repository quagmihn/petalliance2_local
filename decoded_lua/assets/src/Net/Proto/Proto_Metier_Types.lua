-- Net.Proto.Proto_Metier_Types

function Proto.parseMetierInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 职业类型
	data.name=Proto.parseString(entry); -- 职业名称
	return data;
end

function Proto.getMetierInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeMetierInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 职业类型
	Proto.writeString(msg,data.name); -- 职业名称
end

