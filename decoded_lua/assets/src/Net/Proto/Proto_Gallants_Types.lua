-- Net.Proto.Proto_Gallants_Types

Proto.GRULES_RACE		= 0							-- []宠物种族
Proto.GRULES_CLASS		= Proto.GRULES_RACE + 1		-- []宠物品阶
Proto.GRULES_PETAIDE	= Proto.GRULES_CLASS + 1	-- []伴灵失效
Proto.GRULES_EQUIP		= Proto.GRULES_PETAIDE + 1	-- []装备失效
Proto.GRULES_PETID		= Proto.GRULES_EQUIP + 1	-- []宠物类型

function Proto.parseGallantsTimeInfo(entry)
	local data={};
	data.startTime=Proto.parseString(entry); -- 开始时间
	data.periodTime=Proto.parseDWORD(entry); -- 持续时间
	return data;
end

function Proto.writeGallantsTimeInfo(msg,data)
	Proto.writeString(msg,data.startTime); -- 开始时间
	Proto.writeDWORD(msg,data.periodTime); -- 持续时间
end

function Proto.parseGallantsRuleInfo(entry)
	local data={};
	data.ruleID=Proto.parseBYTE(entry); -- 规则ID
	data.ruleType=Proto.parseBYTE(entry); -- 规则
	data.ruleProb=Proto.parseDWORD(entry); -- 规则使用概率
	data.paramList=Proto.parseVector(entry,Proto.parseDWORD); -- 参数列表
	return data;
end

function Proto.writeGallantsRuleInfo(msg,data)
	Proto.writeBYTE(msg,data.ruleID); -- 规则ID
	Proto.writeBYTE(msg,data.ruleType); -- 规则
	Proto.writeDWORD(msg,data.ruleProb); -- 规则使用概率
	Proto.writeVector(msg,data.paramList,Proto.writeDWORD); -- 参数列表
end

function Proto.parseGallantsInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 必须为0,与程序代码兼容
	data.timeList=Proto.parseVector(entry,Proto.parseGallantsTimeInfo); -- 擂台赛时间
	data.rules=Proto.parseVector(entry,Proto.parseGallantsRuleInfo); -- 擂台赛规则
	data.gallantsChampionAwardTableID=Proto.parseDWORD(entry); -- 擂台赛冠军奖励
	data.gallantsTimesAwardTableID=Proto.parseDWORD(entry); -- 擂台赛占领时间奖励
	data.gallantsCost=Proto.parseDWORD(entry); -- 消耗 暂时只扣除行动力
	return data;
end

function Proto.getGallantsInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeGallantsInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 必须为0,与程序代码兼容
	Proto.writeVector(msg,data.timeList,Proto.writeGallantsTimeInfo); -- 擂台赛时间
	Proto.writeVector(msg,data.rules,Proto.writeGallantsRuleInfo); -- 擂台赛规则
	Proto.writeDWORD(msg,data.gallantsChampionAwardTableID); -- 擂台赛冠军奖励
	Proto.writeDWORD(msg,data.gallantsTimesAwardTableID); -- 擂台赛占领时间奖励
	Proto.writeDWORD(msg,data.gallantsCost); -- 消耗 暂时只扣除行动力
end

function Proto.parseGallantsBattleUnit(entry)
	local data={};
	data.pets=Proto.parseVector(entry,Proto.parseBattleUnitInfo); -- 宠物
	data.equips=Proto.parseVector(entry,Proto.parseItemUnit); -- 装备
	data.hasAidePet=Proto.parseBYTE(entry); -- 是否有伴灵
	if (data.hasAidePet~=0) then
		data.aidePet=Proto.parsePetAideDetailInfo(entry); -- 伴灵详细信息
	end
	return data;
end

function Proto.writeGallantsBattleUnit(msg,data)
	Proto.writeVector(msg,data.pets,Proto.writeBattleUnitInfo); -- 宠物
	Proto.writeVector(msg,data.equips,Proto.writeItemUnit); -- 装备
	Proto.writeBYTE(msg,data.hasAidePet); -- 是否有伴灵
	if (data.hasAidePet~=0) then
		Proto.writePetAideDetailInfo(msg,data.aidePet); -- 伴灵详细信息
	end
end

function Proto.parseGallantsOccupyTimeAward(entry)
	local data={};
	data.rewardTime=Proto.parseTIME_SEC(entry); -- 奖励时间
	data.charID=Proto.parseDWORD(entry); -- 玩家ID
	data.occpySeconds=Proto.parseDWORD(entry); -- 占领秒数
	data.occpyTotalSeconds=Proto.parseDWORD(entry); -- 占领总秒数
	return data;
end

function Proto.writeGallantsOccupyTimeAward(msg,data)
	Proto.writeTIME_SEC(msg,data.rewardTime); -- 奖励时间
	Proto.writeDWORD(msg,data.charID); -- 玩家ID
	Proto.writeDWORD(msg,data.occpySeconds); -- 占领秒数
	Proto.writeDWORD(msg,data.occpyTotalSeconds); -- 占领总秒数
end

function Proto.parseGallantsCharInfo(entry)
	local data={};
	data.charID=Proto.parseDWORD(entry); -- 玩家ID
	data.nickName=Proto.parseNickName(entry); -- 昵称
	data.occupyTimePercent=Proto.parseDWORD(entry); -- 占领时间百分百
	return data;
end

function Proto.writeGallantsCharInfo(msg,data)
	Proto.writeDWORD(msg,data.charID); -- 玩家ID
	Proto.writeNickName(msg,data.nickName); -- 昵称
	Proto.writeDWORD(msg,data.occupyTimePercent); -- 占领时间百分百
end

