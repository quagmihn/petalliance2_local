-- Net.Proto.Proto_Hatch_Types

function Proto.parseHatchInfo(entry)
	local data={};
	data.lastHatchTime=Proto.parseTIME_SEC(entry); -- 上次喂养时间
	data.progress=Proto.parseBYTE(entry); -- 已喂养天数
	data.position=Proto.parseWORD(entry); -- 孵化位置
	return data;
end

function Proto.writeHatchInfo(msg,data)
	Proto.writeTIME_SEC(msg,data.lastHatchTime); -- 上次喂养时间
	Proto.writeBYTE(msg,data.progress); -- 已喂养天数
	Proto.writeWORD(msg,data.position); -- 孵化位置
end

