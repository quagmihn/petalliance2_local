-- Net.Proto.Proto_Define_GardenVisitorInfo_Types

function Proto.parseGardenVisitorInfo_ID(entry)
	local data={};
	data.gardenType=Proto.parseWORD(entry); -- 庄园类型
	data.nationID=Proto.parseBYTE(entry); -- 阵营ID
	return data;
end

function Proto.writeGardenVisitorInfo_ID(msg,data)
	Proto.writeWORD(msg,data.gardenType); -- 庄园类型
	Proto.writeBYTE(msg,data.nationID); -- 阵营ID
end

function Proto.parseGardenVisitorInfo(entry)
	local data={};
	data.id=Proto.parseGardenVisitorInfo_ID(entry); -- 庄园阵营信息ID
	return data;
end

function Proto.getGardenVisitorInfoIDLen()
	return Proto.getGardenVisitorInfo_IDLen();
end

function Proto.writeGardenVisitorInfo(msg,data)
	Proto.writeGardenVisitorInfo_ID(msg,data.id); -- 庄园阵营信息ID
end

