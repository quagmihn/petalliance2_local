-- Net.Proto.Proto_PlatformStateCode_Types

function Proto.parsePlatformStateCodeInfo(entry)
	local data={};
	data.id=Proto.parseWORD(entry); -- ID
	data.code=Proto.parseDWORD(entry); -- 响应码
	data.text=Proto.parseString(entry); -- 原因
	return data;
end

function Proto.getPlatformStateCodeInfoIDLen()
	return Proto.getWORDLen();
end

function Proto.writePlatformStateCodeInfo(msg,data)
	Proto.writeWORD(msg,data.id); -- ID
	Proto.writeDWORD(msg,data.code); -- 响应码
	Proto.writeString(msg,data.text); -- 原因
end

