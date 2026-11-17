-- Net.Proto.Proto_Code_Types

function Proto.parseCode(entry)
	local data={};
	data.value=Proto.parseint(entry); -- 值
	data.file=Proto.parsestring(entry); -- 文件名
	data.line=Proto.parseint(entry); -- 行号
	return data;
end

function Proto.writeCode(msg,data)
	Proto.writeint(msg,data.value); -- 值
	Proto.writestring(msg,data.file); -- 文件名
	Proto.writeint(msg,data.line); -- 行号
end

