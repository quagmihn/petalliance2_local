-- Net.Proto.Proto_Achievement_Types

function Proto.parseAchievementInfo(entry)
	local data={};
	data.id=Proto.parseWORD(entry); -- 成就ID
	data.name=Proto.parseString(entry); -- 成就名称
	data.desc=Proto.parseString(entry); -- 成就描述
	data.achievementType=Proto.parseDWORD(entry); -- 成就类型
	data.params=Proto.parseVector(entry,Proto.parseDWORD); -- 成就目标参数
	data.awardElementID=Proto.parseDWORD(entry); -- 奖励元素ID
	data.awardElementNum=Proto.parseDWORD(entry); -- 奖励元素数量
	data.countFieldName=Proto.parseString(entry); -- 计数名
	data.isClient=Proto.parseDWORD(entry); -- 客户端控制
	data.num=Proto.parseDWORD(entry); -- 数量
	data.point=Proto.parseDWORD(entry); -- 成就点
	data.gcash=Proto.parseDWORD(entry); -- 金币
	data.mcash=Proto.parseDWORD(entry); -- M币
	data.isVisable=Proto.parseDWORD(entry); -- 是否显示
	return data;
end

function Proto.getAchievementInfoIDLen()
	return Proto.getWORDLen();
end

function Proto.writeAchievementInfo(msg,data)
	Proto.writeWORD(msg,data.id); -- 成就ID
	Proto.writeString(msg,data.name); -- 成就名称
	Proto.writeString(msg,data.desc); -- 成就描述
	Proto.writeDWORD(msg,data.achievementType); -- 成就类型
	Proto.writeVector(msg,data.params,Proto.writeDWORD); -- 成就目标参数
	Proto.writeDWORD(msg,data.awardElementID); -- 奖励元素ID
	Proto.writeDWORD(msg,data.awardElementNum); -- 奖励元素数量
	Proto.writeString(msg,data.countFieldName); -- 计数名
	Proto.writeDWORD(msg,data.isClient); -- 客户端控制
	Proto.writeDWORD(msg,data.num); -- 数量
	Proto.writeDWORD(msg,data.point); -- 成就点
	Proto.writeDWORD(msg,data.gcash); -- 金币
	Proto.writeDWORD(msg,data.mcash); -- M币
	Proto.writeDWORD(msg,data.isVisable); -- 是否显示
end

function Proto.parsePotentialInfo(entry)
	local data={};
	data.id=Proto.parseWORD(entry); -- 
	data.potentialType=Proto.parseDWORD(entry); -- 
	data.point=Proto.parseDWORD(entry); -- 点数
	data.name=Proto.parseString(entry); -- 
	data.desc=Proto.parseString(entry); -- 
	data.icon=Proto.parseString(entry); -- 
	data.effect=Proto.parseString(entry); -- 效果
	data.params=Proto.parseVector(entry,Proto.parseDWORD); -- 参数
	data.parents=Proto.parseVector(entry,Proto.parseDWORD); -- 上级ID
	return data;
end

function Proto.getPotentialInfoIDLen()
	return Proto.getWORDLen();
end

function Proto.writePotentialInfo(msg,data)
	Proto.writeWORD(msg,data.id); -- 
	Proto.writeDWORD(msg,data.potentialType); -- 
	Proto.writeDWORD(msg,data.point); -- 点数
	Proto.writeString(msg,data.name); -- 
	Proto.writeString(msg,data.desc); -- 
	Proto.writeString(msg,data.icon); -- 
	Proto.writeString(msg,data.effect); -- 效果
	Proto.writeVector(msg,data.params,Proto.writeDWORD); -- 参数
	Proto.writeVector(msg,data.parents,Proto.writeDWORD); -- 上级ID
end

function Proto.parsePokemonAchievementInfo(entry)
	local data={};
	data.id=Proto.parseWORD(entry); -- 
	data.name=Proto.parseString(entry); -- 
	data.desc=Proto.parseString(entry); -- 
	data.icon=Proto.parseString(entry); -- 
	data.effect=Proto.parseString(entry); -- 效果
	data.petIDs=Proto.parseVector(entry,Proto.parseDWORD); -- 宠物ID
	data.point=Proto.parseDWORD(entry); -- 成就点
	data.gcash=Proto.parseDWORD(entry); -- 金币
	data.mcash=Proto.parseDWORD(entry); -- M币
	return data;
end

function Proto.getPokemonAchievementInfoIDLen()
	return Proto.getWORDLen();
end

function Proto.writePokemonAchievementInfo(msg,data)
	Proto.writeWORD(msg,data.id); -- 
	Proto.writeString(msg,data.name); -- 
	Proto.writeString(msg,data.desc); -- 
	Proto.writeString(msg,data.icon); -- 
	Proto.writeString(msg,data.effect); -- 效果
	Proto.writeVector(msg,data.petIDs,Proto.writeDWORD); -- 宠物ID
	Proto.writeDWORD(msg,data.point); -- 成就点
	Proto.writeDWORD(msg,data.gcash); -- 金币
	Proto.writeDWORD(msg,data.mcash); -- M币
end

function Proto.parseResetAchievementInfo(entry)
	local data={};
	data.id=Proto.parseWORD(entry); -- 次数
	data.cost=Proto.parseDWORD(entry); -- 钻石消耗
	return data;
end

function Proto.getResetAchievementInfoIDLen()
	return Proto.getWORDLen();
end

function Proto.writeResetAchievementInfo(msg,data)
	Proto.writeWORD(msg,data.id); -- 次数
	Proto.writeDWORD(msg,data.cost); -- 钻石消耗
end

function Proto.parseActivityPokemonAchievementInfo(entry)
	local data={};
	data.id=Proto.parseWORD(entry); -- 
	data.name=Proto.parseString(entry); -- 
	data.desc=Proto.parseString(entry); -- 
	data.icon=Proto.parseString(entry); -- 
	data.effect=Proto.parseString(entry); -- 效果
	data.petIDs=Proto.parseVector(entry,Proto.parseDWORD); -- 宠物ID
	data.awardIDs=Proto.parseVector(entry,Proto.parseDWORD); -- 奖励元素ID
	data.count=Proto.parseVector(entry,Proto.parseDWORD); -- 奖励数量
	return data;
end

function Proto.getActivityPokemonAchievementInfoIDLen()
	return Proto.getWORDLen();
end

function Proto.writeActivityPokemonAchievementInfo(msg,data)
	Proto.writeWORD(msg,data.id); -- 
	Proto.writeString(msg,data.name); -- 
	Proto.writeString(msg,data.desc); -- 
	Proto.writeString(msg,data.icon); -- 
	Proto.writeString(msg,data.effect); -- 效果
	Proto.writeVector(msg,data.petIDs,Proto.writeDWORD); -- 宠物ID
	Proto.writeVector(msg,data.awardIDs,Proto.writeDWORD); -- 奖励元素ID
	Proto.writeVector(msg,data.count,Proto.writeDWORD); -- 奖励数量
end

