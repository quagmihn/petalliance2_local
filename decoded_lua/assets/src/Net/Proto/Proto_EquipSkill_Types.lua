-- Net.Proto.Proto_EquipSkill_Types

Proto.EGOPT_ACTIVATE			= 0									-- []激活
Proto.EGOPT_PUMPSOUL			= Proto.EGOPT_ACTIVATE + 1			-- []抽魂
Proto.EGOPT_PUMPSOUL_RESERVER	= Proto.EGOPT_PUMPSOUL + 1			-- []抽魂保留
Proto.EGOPT_SELGENE				= Proto.EGOPT_PUMPSOUL_RESERVER + 1	-- []选取技能
Proto.EGOPT_USEBOOK				= Proto.EGOPT_SELGENE + 1			-- []使用技能书

function Proto.parseEquipPumpSoulPartCondition(entry)
	local data={};
	data.geneActivateLevel=Proto.parseWORD(entry); -- 激活等级
	data.activateCost=Proto.parseCostInfo(entry); -- 激活消耗
	data.reserveCost=Proto.parseCostInfo(entry); -- 保留消耗
	return data;
end

function Proto.writeEquipPumpSoulPartCondition(msg,data)
	Proto.writeWORD(msg,data.geneActivateLevel); -- 激活等级
	Proto.writeCostInfo(msg,data.activateCost); -- 激活消耗
	Proto.writeCostInfo(msg,data.reserveCost); -- 保留消耗
end

function Proto.parseEquipPartPumpSoulInfo(entry)
	local data={};
	data.id=Proto.parseWORD(entry); -- 部件
	data.pumpSoulLimit=Proto.parseDWORD(entry); -- 抽魂上限
	data.pumpSoulPartConditionInfo=Proto.parseVector(entry,Proto.parseEquipPumpSoulPartCondition); -- 抽魂条件信息
	data.pumpSoulPartPosInfo=Proto.parseVector(entry,Proto.parseWORD); -- 被抽魂装备位
	return data;
end

function Proto.getEquipPartPumpSoulInfoIDLen()
	return Proto.getWORDLen();
end

function Proto.writeEquipPartPumpSoulInfo(msg,data)
	Proto.writeWORD(msg,data.id); -- 部件
	Proto.writeDWORD(msg,data.pumpSoulLimit); -- 抽魂上限
	Proto.writeVector(msg,data.pumpSoulPartConditionInfo,Proto.writeEquipPumpSoulPartCondition); -- 抽魂条件信息
	Proto.writeVector(msg,data.pumpSoulPartPosInfo,Proto.writeWORD); -- 被抽魂装备位
end

function Proto.parseEquipLevelPumpSoulInfo(entry)
	local data={};
	data.id=Proto.parseWORD(entry); -- 等阶
	data.geneCount=Proto.parseBYTE(entry); -- 可装备技能数
	data.genePumpSoulPoint=Proto.parseDWORD(entry); -- 抽魂点数
	data.geneInitPumpSoulPoint1=Proto.parseDWORD(entry); -- 初始抽魂值1
	data.geneInitPumpSoulPoint2=Proto.parseDWORD(entry); -- 初始抽魂值2
	return data;
end

function Proto.getEquipLevelPumpSoulInfoIDLen()
	return Proto.getWORDLen();
end

function Proto.writeEquipLevelPumpSoulInfo(msg,data)
	Proto.writeWORD(msg,data.id); -- 等阶
	Proto.writeBYTE(msg,data.geneCount); -- 可装备技能数
	Proto.writeDWORD(msg,data.genePumpSoulPoint); -- 抽魂点数
	Proto.writeDWORD(msg,data.geneInitPumpSoulPoint1); -- 初始抽魂值1
	Proto.writeDWORD(msg,data.geneInitPumpSoulPoint2); -- 初始抽魂值2
end

function Proto.parseEquipGeneGenerateProb(entry)
	local data={};
	data.geneID=Proto.parseWORD(entry); -- 基因id
	data.geneLevel=Proto.parseWORD(entry); -- 基因等级
	data.prob=Proto.parseDWORD(entry); -- 概率
	return data;
end

function Proto.writeEquipGeneGenerateProb(msg,data)
	Proto.writeWORD(msg,data.geneID); -- 基因id
	Proto.writeWORD(msg,data.geneLevel); -- 基因等级
	Proto.writeDWORD(msg,data.prob); -- 概率
end

function Proto.parseEquipGeneGenerateInfo(entry)
	local data={};
	data.id=Proto.parseWORD(entry); -- 经验
	data.generateProbInfo=Proto.parseVector(entry,Proto.parseEquipGeneGenerateProb); -- 基因概率
	return data;
end

function Proto.getEquipGeneGenerateInfoIDLen()
	return Proto.getWORDLen();
end

function Proto.writeEquipGeneGenerateInfo(msg,data)
	Proto.writeWORD(msg,data.id); -- 经验
	Proto.writeVector(msg,data.generateProbInfo,Proto.writeEquipGeneGenerateProb); -- 基因概率
end

function Proto.parseEquipPartGeneGenerateInfo(entry)
	local data={};
	data.id=Proto.parseWORD(entry); -- 部位
	data.generateInfoList=Proto.parseVector(entry,Proto.parseEquipGeneGenerateInfo); -- 基因生成信息列表
	return data;
end

function Proto.getEquipPartGeneGenerateInfoIDLen()
	return Proto.getWORDLen();
end

function Proto.writeEquipPartGeneGenerateInfo(msg,data)
	Proto.writeWORD(msg,data.id); -- 部位
	Proto.writeVector(msg,data.generateInfoList,Proto.writeEquipGeneGenerateInfo); -- 基因生成信息列表
end

function Proto.parseEquipGeneChangeProb(entry)
	local data={};
	data.pumpSoulPoint=Proto.parseDWORD(entry); -- 经验
	data.prob=Proto.parseDWORD(entry); -- 可变异概率
	return data;
end

function Proto.writeEquipGeneChangeProb(msg,data)
	Proto.writeDWORD(msg,data.pumpSoulPoint); -- 经验
	Proto.writeDWORD(msg,data.prob); -- 可变异概率
end

function Proto.parseEquipGeneChangeProbGroupInfo(entry)
	local data={};
	data.id=Proto.parseWORD(entry); -- 部件
	data.changeProbInfoGroup=Proto.parseVector(entry,Proto.parseEquipGeneChangeProb); -- 变异概率组
	return data;
end

function Proto.getEquipGeneChangeProbGroupInfoIDLen()
	return Proto.getWORDLen();
end

function Proto.writeEquipGeneChangeProbGroupInfo(msg,data)
	Proto.writeWORD(msg,data.id); -- 部件
	Proto.writeVector(msg,data.changeProbInfoGroup,Proto.writeEquipGeneChangeProb); -- 变异概率组
end

function Proto.parseEquipGeneBookUseInfo(entry)
	local data={};
	data.id=Proto.parseWORD(entry); -- 技能id
	data.needPumpSoulPoint=Proto.parseVector(entry,Proto.parseDWORD); -- 需要达到的装备魂值
	data.costInfo=Proto.parseCostInfo(entry); -- 消耗
	return data;
end

function Proto.getEquipGeneBookUseInfoIDLen()
	return Proto.getWORDLen();
end

function Proto.writeEquipGeneBookUseInfo(msg,data)
	Proto.writeWORD(msg,data.id); -- 技能id
	Proto.writeVector(msg,data.needPumpSoulPoint,Proto.writeDWORD); -- 需要达到的装备魂值
	Proto.writeCostInfo(msg,data.costInfo); -- 消耗
end

