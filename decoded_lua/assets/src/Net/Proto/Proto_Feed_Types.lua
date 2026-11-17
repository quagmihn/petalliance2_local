-- Net.Proto.Proto_Feed_Types

function Proto.parsePetDormInfo_ID(entry)
	local data={};
	data.raceID=Proto.parseDWORD(entry); -- 宠物种族ID
	data.dormID=Proto.parseDWORD(entry); -- 宠物宿舍ID
	return data;
end

function Proto.writePetDormInfo_ID(msg,data)
	Proto.writeDWORD(msg,data.raceID); -- 宠物种族ID
	Proto.writeDWORD(msg,data.dormID); -- 宠物宿舍ID
end

function Proto.parsePetDormInfo(entry)
	local data={};
	data.id=Proto.parsePetDormInfo_ID(entry); -- 宠物宿舍信息ID
	return data;
end

function Proto.getPetDormInfoIDLen()
	return Proto.getPetDormInfo_IDLen();
end

function Proto.writePetDormInfo(msg,data)
	Proto.writePetDormInfo_ID(msg,data.id); -- 宠物宿舍信息ID
end

function Proto.parsePetFoodInfo_ID(entry)
	local data={};
	data.raceID=Proto.parseDWORD(entry); -- 宠物种族ID
	data.foodID=Proto.parseDWORD(entry); -- 道具ID
	return data;
end

function Proto.writePetFoodInfo_ID(msg,data)
	Proto.writeDWORD(msg,data.raceID); -- 宠物种族ID
	Proto.writeDWORD(msg,data.foodID); -- 道具ID
end

function Proto.parsePetFoodInfo(entry)
	local data={};
	data.id=Proto.parsePetFoodInfo_ID(entry); -- 宠物食物信息ID
	data.eatCount=Proto.parseWORD(entry); -- 每次吃的数量
	data.duration=Proto.parseDWORD(entry); -- 吃这些食物的持续时间(毫秒)
	return data;
end

function Proto.getPetFoodInfoIDLen()
	return Proto.getPetFoodInfo_IDLen();
end

function Proto.writePetFoodInfo(msg,data)
	Proto.writePetFoodInfo_ID(msg,data.id); -- 宠物食物信息ID
	Proto.writeWORD(msg,data.eatCount); -- 每次吃的数量
	Proto.writeDWORD(msg,data.duration); -- 吃这些食物的持续时间(毫秒)
end

