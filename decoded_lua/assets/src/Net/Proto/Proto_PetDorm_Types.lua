-- Net.Proto.Proto_PetDorm_Types

function Proto.parseDormPetState(entry)
	local data={};
	data.dormID=Proto.parseQWORD(entry); -- 宿舍ID
	data.petID=Proto.parseDWORD(entry); -- 宠物ID
	data.raceType=Proto.parseDWORD(entry); -- 动物类型
	data.fatigue=Proto.parseWORD(entry); -- 饥饿度
	data.growth=Proto.parseDWORD(entry); -- 成长度
	data.health=Proto.parseDWORD(entry); -- 健康度
	return data;
end

function Proto.writeDormPetState(msg,data)
	Proto.writeQWORD(msg,data.dormID); -- 宿舍ID
	Proto.writeDWORD(msg,data.petID); -- 宠物ID
	Proto.writeDWORD(msg,data.raceType); -- 动物类型
	Proto.writeWORD(msg,data.fatigue); -- 饥饿度
	Proto.writeDWORD(msg,data.growth); -- 成长度
	Proto.writeDWORD(msg,data.health); -- 健康度
end

function Proto.parseDormPetDetail(entry)
	local data={};
	data.state=Proto.parseDormPetState(entry); -- 宿舍宠物状态
	data.ownerID=Proto.parseDWORD(entry); -- 主人ID
	data.updateTime=Proto.parseTIME_SEC(entry); -- 更新时间
	return data;
end

function Proto.writeDormPetDetail(msg,data)
	Proto.writeDormPetState(msg,data.state); -- 宿舍宠物状态
	Proto.writeDWORD(msg,data.ownerID); -- 主人ID
	Proto.writeTIME_SEC(msg,data.updateTime); -- 更新时间
end

