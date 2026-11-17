-- Net.Proto.Proto_Intensify_Types

function Proto.parseEquipLevelAttributesSixDInfo(entry)
	local data={};
	data.hp=Proto.parseDWORD(entry); -- 血量
	data.spd=Proto.parseDWORD(entry); -- 速度
	data.atk=Proto.parseDWORD(entry); -- 物理攻击
	data.defence=Proto.parseDWORD(entry); -- 物理防御
	data.matk=Proto.parseDWORD(entry); -- 魔法攻击
	data.mdefence=Proto.parseDWORD(entry); -- 魔法防御
	return data;
end

function Proto.writeEquipLevelAttributesSixDInfo(msg,data)
	Proto.writeDWORD(msg,data.hp); -- 血量
	Proto.writeDWORD(msg,data.spd); -- 速度
	Proto.writeDWORD(msg,data.atk); -- 物理攻击
	Proto.writeDWORD(msg,data.defence); -- 物理防御
	Proto.writeDWORD(msg,data.matk); -- 魔法攻击
	Proto.writeDWORD(msg,data.mdefence); -- 魔法防御
end

function Proto.parseEquipLevelAttributesInfo(entry)
	local data={};
	data.id=Proto.parseWORD(entry); -- 强化等级
	data.attributes=Proto.parseEquipLevelAttributesSixDInfo(entry); -- 六维加成
	return data;
end

function Proto.getEquipLevelAttributesInfoIDLen()
	return Proto.getWORDLen();
end

function Proto.writeEquipLevelAttributesInfo(msg,data)
	Proto.writeWORD(msg,data.id); -- 强化等级
	Proto.writeEquipLevelAttributesSixDInfo(msg,data.attributes); -- 六维加成
end

function Proto.parseEquipUpgradeProbInfo(entry)
	local data={};
	data.useMCash=Proto.parseWORD(entry); -- M币成功率
	data.useGCash=Proto.parseWORD(entry); -- G币成功率
	return data;
end

function Proto.writeEquipUpgradeProbInfo(msg,data)
	Proto.writeWORD(msg,data.useMCash); -- M币成功率
	Proto.writeWORD(msg,data.useGCash); -- G币成功率
end

function Proto.parseEquipUpgradeCostInfo(entry)
	local data={};
	data.rank=Proto.parseWORD(entry); -- 装备品阶
	data.useMCash=Proto.parseDWORD(entry); -- M币
	data.useGCash=Proto.parseDWORD(entry); -- G币
	return data;
end

function Proto.writeEquipUpgradeCostInfo(msg,data)
	Proto.writeWORD(msg,data.rank); -- 装备品阶
	Proto.writeDWORD(msg,data.useMCash); -- M币
	Proto.writeDWORD(msg,data.useGCash); -- G币
end

function Proto.parseEquipUpgradeInfo(entry)
	local data={};
	data.id=Proto.parseWORD(entry); -- 当前等级
	data.chance=Proto.parseEquipUpgradeProbInfo(entry); -- 成功率
	data.cost=Proto.parseVector(entry,Proto.parseEquipUpgradeCostInfo); -- 花费
	return data;
end

function Proto.getEquipUpgradeInfoIDLen()
	return Proto.getWORDLen();
end

function Proto.writeEquipUpgradeInfo(msg,data)
	Proto.writeWORD(msg,data.id); -- 当前等级
	Proto.writeEquipUpgradeProbInfo(msg,data.chance); -- 成功率
	Proto.writeVector(msg,data.cost,Proto.writeEquipUpgradeCostInfo); -- 花费
end

function Proto.parseEquipLimitInfo(entry)
	local data={};
	data.id=Proto.parseWORD(entry); -- 装备品阶
	data.levelLimit=Proto.parseWORD(entry); -- 上限
	return data;
end

function Proto.getEquipLimitInfoIDLen()
	return Proto.getWORDLen();
end

function Proto.writeEquipLimitInfo(msg,data)
	Proto.writeWORD(msg,data.id); -- 装备品阶
	Proto.writeWORD(msg,data.levelLimit); -- 上限
end

