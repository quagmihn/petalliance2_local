-- Net.Proto.Proto_Validate_Types

function Proto.parseValidatePresentInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 
	data.itemGenerateID=Proto.parseDWORD(entry); -- 道具生成规则ID
	data.count=Proto.parseWORD(entry); -- 数量
	return data;
end

function Proto.getValidatePresentInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeValidatePresentInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 
	Proto.writeDWORD(msg,data.itemGenerateID); -- 道具生成规则ID
	Proto.writeWORD(msg,data.count); -- 数量
end

