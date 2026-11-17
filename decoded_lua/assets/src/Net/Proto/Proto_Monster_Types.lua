-- Net.Proto.Proto_Monster_Types

function Proto.parseNationInfo(entry)
	local data={};
	data.id=Proto.parseBYTE(entry); -- ID
	data.name=Proto.parseUnitName(entry); -- 名称
	data.initPrestigeLevel=Proto.parseBYTE(entry); -- 初始声望等级
	return data;
end

function Proto.getNationInfoIDLen()
	return Proto.getBYTELen();
end

function Proto.writeNationInfo(msg,data)
	Proto.writeBYTE(msg,data.id); -- ID
	Proto.writeUnitName(msg,data.name); -- 名称
	Proto.writeBYTE(msg,data.initPrestigeLevel); -- 初始声望等级
end

function Proto.parseMonsterAttributeRate(entry)
	local data={};
	data.hp=Proto.parseWORD(entry); -- HP
	data.sp=Proto.parseWORD(entry); -- SP
	data.pp=Proto.parseWORD(entry); -- PP
	data.lightAttack=Proto.parseWORD(entry); -- 光攻
	data.lightDefence=Proto.parseWORD(entry); -- 光防
	data.darkAttack=Proto.parseWORD(entry); -- 暗攻
	data.darkDefence=Proto.parseWORD(entry); -- 暗防
	return data;
end

function Proto.writeMonsterAttributeRate(msg,data)
	Proto.writeWORD(msg,data.hp); -- HP
	Proto.writeWORD(msg,data.sp); -- SP
	Proto.writeWORD(msg,data.pp); -- PP
	Proto.writeWORD(msg,data.lightAttack); -- 光攻
	Proto.writeWORD(msg,data.lightDefence); -- 光防
	Proto.writeWORD(msg,data.darkAttack); -- 暗攻
	Proto.writeWORD(msg,data.darkDefence); -- 暗防
end

function Proto.parseSkillAIGroupInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 编号
	data.name=Proto.parseString(entry); -- 名称
	data.skillGeneraters=Proto.parseVector(entry,Proto.parseDWORD); -- 技能生成规则
	data.aiRuleInfos=Proto.parseVector(entry,Proto.parseDWORD); -- AI规则表
	return data;
end

function Proto.getSkillAIGroupInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeSkillAIGroupInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 编号
	Proto.writeString(msg,data.name); -- 名称
	Proto.writeVector(msg,data.skillGeneraters,Proto.writeDWORD); -- 技能生成规则
	Proto.writeVector(msg,data.aiRuleInfos,Proto.writeDWORD); -- AI规则表
end

function Proto.parseSkillSetting(entry)
	local data={};
	data.prop=Proto.parseDWORD(entry); -- 概率
	data.skillAIGroupID=Proto.parseDWORD(entry); -- 技能AI配置编号
	return data;
end

function Proto.writeSkillSetting(msg,data)
	Proto.writeDWORD(msg,data.prop); -- 概率
	Proto.writeDWORD(msg,data.skillAIGroupID); -- 技能AI配置编号
end

function Proto.parseNatureSetting(entry)
	local data={};
	data.id=Proto.parseWORD(entry); -- 天性编号
	data.level=Proto.parseWORD(entry); -- 等级
	return data;
end

function Proto.getNatureSettingIDLen()
	return Proto.getWORDLen();
end

function Proto.writeNatureSetting(msg,data)
	Proto.writeWORD(msg,data.id); -- 天性编号
	Proto.writeWORD(msg,data.level); -- 等级
end

function Proto.parseMonsterInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.typeName=Proto.parseUnitName(entry); -- 名称
	data.raceType=Proto.parseWORD(entry); -- 动物类型
	data.hasGender=Proto.parseBYTE(entry); -- 是否具有性别
	if (data.hasGender ~=0) then
		data.femaleProb=Proto.parseBYTE(entry); -- 雌性概率(百分比)
	end
	data.heredityGeneID=Proto.parseDWORD(entry); -- 遗传基因表ID
	data.extraHp=Proto.parseDWORD(entry); -- 额外HP
	data.attribRate=Proto.parseMonsterAttributeRate(entry); -- 属性率
	data.exp=Proto.parseDWORD(entry); -- 经验值
	data.enemyNations=Proto.parseVector(entry,Proto.parseNationPrestige); -- 敌对阵营
	data.skillSettings=Proto.parseVector(entry,Proto.parseSkillSetting); -- 技能配置
	data.natureSettings=Proto.parseVector(entry,Proto.parseNatureSetting); -- 天性配置
	data.equips=Proto.parseVector(entry,Proto.parseItem); -- 装备
	return data;
end

function Proto.getMonsterInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeMonsterInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeUnitName(msg,data.typeName); -- 名称
	Proto.writeWORD(msg,data.raceType); -- 动物类型
	Proto.writeBYTE(msg,data.hasGender); -- 是否具有性别
	if (data.hasGender ~=0) then
		Proto.writeBYTE(msg,data.femaleProb); -- 雌性概率(百分比)
	end
	Proto.writeDWORD(msg,data.heredityGeneID); -- 遗传基因表ID
	Proto.writeDWORD(msg,data.extraHp); -- 额外HP
	Proto.writeMonsterAttributeRate(msg,data.attribRate); -- 属性率
	Proto.writeDWORD(msg,data.exp); -- 经验值
	Proto.writeVector(msg,data.enemyNations,Proto.writeNationPrestige); -- 敌对阵营
	Proto.writeVector(msg,data.skillSettings,Proto.writeSkillSetting); -- 技能配置
	Proto.writeVector(msg,data.natureSettings,Proto.writeNatureSetting); -- 天性配置
	Proto.writeVector(msg,data.equips,Proto.writeItem); -- 装备
end

function Proto.parseDummyInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.name=Proto.parseUnitName(entry); -- 名称
	data.raceType=Proto.parseWORD(entry); -- 动物类型
	data.hasGender=Proto.parseBYTE(entry); -- 是否具有性别
	if (data.hasGender ~=0) then
		data.femaleProb=Proto.parseBYTE(entry); -- 雌性概率(百分比)
	end
	data.heredityGeneID=Proto.parseDWORD(entry); -- 遗传基因表ID
	data.skillAIGroupID=Proto.parseDWORD(entry); -- 技能AI配置编号
	return data;
end

function Proto.getDummyInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeDummyInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeUnitName(msg,data.name); -- 名称
	Proto.writeWORD(msg,data.raceType); -- 动物类型
	Proto.writeBYTE(msg,data.hasGender); -- 是否具有性别
	if (data.hasGender ~=0) then
		Proto.writeBYTE(msg,data.femaleProb); -- 雌性概率(百分比)
	end
	Proto.writeDWORD(msg,data.heredityGeneID); -- 遗传基因表ID
	Proto.writeDWORD(msg,data.skillAIGroupID); -- 技能AI配置编号
end

function Proto.parseLevelExp(entry)
	local data={};
	data.id=Proto.parseint(entry); -- 等级差值
	data.expRate=Proto.parseBYTE(entry); -- 经验比例
	return data;
end

function Proto.getLevelExpIDLen()
	return Proto.getintLen();
end

function Proto.writeLevelExp(msg,data)
	Proto.writeint(msg,data.id); -- 等级差值
	Proto.writeBYTE(msg,data.expRate); -- 经验比例
end

function Proto.parseMonsterEggInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 怪物ID
	data.catchQuotiety=Proto.parseDWORD(entry); -- 捕获率
	data.itemGenerateID=Proto.parseDWORD(entry); -- 对应道具生成类型
	return data;
end

function Proto.getMonsterEggInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeMonsterEggInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 怪物ID
	Proto.writeDWORD(msg,data.catchQuotiety); -- 捕获率
	Proto.writeDWORD(msg,data.itemGenerateID); -- 对应道具生成类型
end

