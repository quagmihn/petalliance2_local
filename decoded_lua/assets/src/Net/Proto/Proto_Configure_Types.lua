-- Net.Proto.Proto_Configure_Types

function Proto.parseProtoInfo(entry)
	local data={};
	data.id=Proto.parseWORD(entry); -- 天性ID
	data.proto=Proto.parseString(entry); -- 协议
	return data;
end

function Proto.getProtoInfoIDLen()
	return Proto.getWORDLen();
end

function Proto.writeProtoInfo(msg,data)
	Proto.writeWORD(msg,data.id); -- 天性ID
	Proto.writeString(msg,data.proto); -- 协议
end

