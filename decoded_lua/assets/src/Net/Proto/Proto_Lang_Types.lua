-- Net.Proto.Proto_Lang_Types

function Proto.parseLangInfo(entry)
	local data={};
	data.id=Proto.parsestring(entry); -- ID
	data.lang=Proto.parsestring(entry); -- 语言相关值
	return data;
end

function Proto.getLangInfoIDLen()
	return Proto.getstringLen();
end

function Proto.writeLangInfo(msg,data)
	Proto.writestring(msg,data.id); -- ID
	Proto.writestring(msg,data.lang); -- 语言相关值
end

