-- Net.Proto.Proto_Robot_Types

function Proto.parseRobotInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 
	data.level=Proto.parseWORD(entry); -- 等级
	data.monsters=Proto.parseVector(entry,Proto.parseDWORD); -- 
	data.gender=Proto.parseDWORD(entry); -- 
	data.name=Proto.parseString(entry); -- 
	data.fashions=Proto.parseVector(entry,Proto.parseDWORD); -- 
	data.petStreng=Proto.parseDWORD(entry); -- 宠物阶数
	data.petStar=Proto.parseDWORD(entry); -- 宠物星数
	return data;
end

function Proto.getRobotInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeRobotInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 
	Proto.writeWORD(msg,data.level); -- 等级
	Proto.writeVector(msg,data.monsters,Proto.writeDWORD); -- 
	Proto.writeDWORD(msg,data.gender); -- 
	Proto.writeString(msg,data.name); -- 
	Proto.writeVector(msg,data.fashions,Proto.writeDWORD); -- 
	Proto.writeDWORD(msg,data.petStreng); -- 宠物阶数
	Proto.writeDWORD(msg,data.petStar); -- 宠物星数
end

