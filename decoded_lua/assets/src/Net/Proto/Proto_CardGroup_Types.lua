-- Net.Proto.Proto_CardGroup_Types

function Proto.parseCardGroup(entry)
	local data={};
	data.index=Proto.parseBYTE(entry); -- 条目索引
	data.name=Proto.parseCardGroupName(entry); -- 卡片组名称
	data.poses=Proto.parseVector(entry,Proto.parseWORD); -- 卡片位置
	return data;
end

function Proto.writeCardGroup(msg,data)
	Proto.writeBYTE(msg,data.index); -- 条目索引
	Proto.writeCardGroupName(msg,data.name); -- 卡片组名称
	Proto.writeVector(msg,data.poses,Proto.writeWORD); -- 卡片位置
end

