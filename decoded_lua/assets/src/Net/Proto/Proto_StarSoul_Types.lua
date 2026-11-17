-- Net.Proto.Proto_StarSoul_Types

function Proto.parseStarPetInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 宠物ID
	data.hp=Proto.parseDWORD(entry); -- 剩余血量
	data.maxhp=Proto.parseDWORD(entry); -- 最大血量
	data.index=Proto.parseDWORD(entry); -- 宠物位置索引 0-2
	return data;
end

function Proto.getStarPetInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeStarPetInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 宠物ID
	Proto.writeDWORD(msg,data.hp); -- 剩余血量
	Proto.writeDWORD(msg,data.maxhp); -- 最大血量
	Proto.writeDWORD(msg,data.index); -- 宠物位置索引 0-2
end

function Proto.parseStarMonsterInfo(entry)
	local data={};
	data.index=Proto.parseBYTE(entry); -- 位置索引 0-2
	data.id=Proto.parseDWORD(entry); -- 怪物ID
	data.hp=Proto.parseDWORD(entry); -- 剩余血量
	data.level=Proto.parseDWORD(entry); -- 怪物等级
	data.maxhp=Proto.parseDWORD(entry); -- 最大血量
	return data;
end

function Proto.getStarMonsterInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeStarMonsterInfo(msg,data)
	Proto.writeBYTE(msg,data.index); -- 位置索引 0-2
	Proto.writeDWORD(msg,data.id); -- 怪物ID
	Proto.writeDWORD(msg,data.hp); -- 剩余血量
	Proto.writeDWORD(msg,data.level); -- 怪物等级
	Proto.writeDWORD(msg,data.maxhp); -- 最大血量
end

function Proto.parseStarSoul(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 关卡ID
	data.fightID=Proto.parseDWORD(entry); -- 战斗组ID
	data.last_fight_time=Proto.parseTIME_SEC(entry); -- 上次殴打时间
	data.petInfo=Proto.parseVector(entry,Proto.parseStarPetInfo); -- 打星魂殿的宠物数据
	data.monsterInfo=Proto.parseVector(entry,Proto.parseStarMonsterInfo); -- 当前关卡的怪物数据
	return data;
end

function Proto.getStarSoulIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeStarSoul(msg,data)
	Proto.writeDWORD(msg,data.id); -- 关卡ID
	Proto.writeDWORD(msg,data.fightID); -- 战斗组ID
	Proto.writeTIME_SEC(msg,data.last_fight_time); -- 上次殴打时间
	Proto.writeVector(msg,data.petInfo,Proto.writeStarPetInfo); -- 打星魂殿的宠物数据
	Proto.writeVector(msg,data.monsterInfo,Proto.writeStarMonsterInfo); -- 当前关卡的怪物数据
end

