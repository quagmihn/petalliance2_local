-- Net.Proto.Proto_HotKey_Types

function Proto.parseHotKeyPageInfo(entry)
	local data={};
	data.type=Proto.parseBYTE(entry); -- 角色类型
	data.characterID=Proto.parseDWORD(entry); -- 人物ID
	data.petID=Proto.parseDWORD(entry); -- 宠物ID:type=T_PET
	data.page=Proto.parseBYTE(entry); -- 页码
	data.data=Proto.parseHotKeyData(entry); -- HotKey内容
	return data;
end

function Proto.writeHotKeyPageInfo(msg,data)
	Proto.writeBYTE(msg,data.type); -- 角色类型
	Proto.writeDWORD(msg,data.characterID); -- 人物ID
	Proto.writeDWORD(msg,data.petID); -- 宠物ID:type=T_PET
	Proto.writeBYTE(msg,data.page); -- 页码
	Proto.writeHotKeyData(msg,data.data); -- HotKey内容
end

