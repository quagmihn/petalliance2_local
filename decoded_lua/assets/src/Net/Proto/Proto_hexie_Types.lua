-- Net.Proto.Proto_hexie_Types

function Proto.parseHexieInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 编号
	data.hexie=Proto.parseString(entry); -- 屏蔽字词
	data.read=Proto.parseString(entry); -- 方便阅读
	return data;
end

function Proto.getHexieInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeHexieInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 编号
	Proto.writeString(msg,data.hexie); -- 屏蔽字词
	Proto.writeString(msg,data.read); -- 方便阅读
end

