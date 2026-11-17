-- Net.Proto.Proto_Synthesize_Types

Proto.SCT_S		= 0					-- []S阶
Proto.SCT_A		= Proto.SCT_S + 1	-- []A阶
Proto.SCT_B		= Proto.SCT_A + 1	-- []B阶
Proto.SCT_C		= Proto.SCT_B + 1	-- []C阶
Proto.SCT_D		= Proto.SCT_C + 1	-- []D阶
Proto.SCT_E		= Proto.SCT_D + 1	-- []E阶
Proto.SCT_COUNT	= Proto.SCT_E + 1	-- []总数

function Proto.parseSynthesizationInput(entry)
	local data={};
	data.item_type=Proto.parseDWORD(entry); -- 道具类型
	data.count=Proto.parseWORD(entry); -- 道具数量
	return data;
end

function Proto.writeSynthesizationInput(msg,data)
	Proto.writeDWORD(msg,data.item_type); -- 道具类型
	Proto.writeWORD(msg,data.count); -- 道具数量
end

function Proto.parseSynthesizationProbability(entry)
	local data={};
	data.prob=Proto.parseDWORD(entry); -- 概率(千万分之一概率)
	data.item_generateID=Proto.parseDWORD(entry); -- 道具生成规则
	return data;
end

function Proto.writeSynthesizationProbability(msg,data)
	Proto.writeDWORD(msg,data.prob); -- 概率(千万分之一概率)
	Proto.writeDWORD(msg,data.item_generateID); -- 道具生成规则
end

function Proto.parseSynthesizationOutputGroup(entry)
	local data={};
	data.product=Proto.parseVector(entry,Proto.parseSynthesizationProbability); -- 输出组
	return data;
end

function Proto.writeSynthesizationOutputGroup(msg,data)
	Proto.writeVector(msg,data.product,Proto.writeSynthesizationProbability); -- 输出组
end

function Proto.parseSkillCardSynthesizationInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 合成编号
	data.name=Proto.parseString(entry); -- 合成名
	data.baseInputs=Proto.parseVector(entry,Proto.parseSynthesizationInput); -- 最少输入
	data.output=Proto.parseVector(entry,Proto.parseSynthesizationOutputGroup); -- 输出
	return data;
end

function Proto.getSkillCardSynthesizationInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeSkillCardSynthesizationInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 合成编号
	Proto.writeString(msg,data.name); -- 合成名
	Proto.writeVector(msg,data.baseInputs,Proto.writeSynthesizationInput); -- 最少输入
	Proto.writeVector(msg,data.output,Proto.writeSynthesizationOutputGroup); -- 输出
end

function Proto.parseSkillCardSynthesizationNpcInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- NPC ID
	data.synthesizations=Proto.parseVector(entry,Proto.parseDWORD); -- 合成规则表
	return data;
end

function Proto.getSkillCardSynthesizationNpcInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeSkillCardSynthesizationNpcInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- NPC ID
	Proto.writeVector(msg,data.synthesizations,Proto.writeDWORD); -- 合成规则表
end

function Proto.parseSynthesizationItemInput(entry)
	local data={};
	data.item_type=Proto.parseDWORD(entry); -- 道具类型
	data.min_count=Proto.parseWORD(entry); -- 最小道具数量
	data.max_count=Proto.parseWORD(entry); -- 最大道具数量
	return data;
end

function Proto.writeSynthesizationItemInput(msg,data)
	Proto.writeDWORD(msg,data.item_type); -- 道具类型
	Proto.writeWORD(msg,data.min_count); -- 最小道具数量
	Proto.writeWORD(msg,data.max_count); -- 最大道具数量
end

function Proto.parseNatureSynthesizationScore(entry)
	local data={};
	data.id=Proto.parseBYTE(entry); -- 技能书等阶
	data.score=Proto.parseBYTE(entry); -- 得分
	return data;
end

function Proto.getNatureSynthesizationScoreIDLen()
	return Proto.getBYTELen();
end

function Proto.writeNatureSynthesizationScore(msg,data)
	Proto.writeBYTE(msg,data.id); -- 技能书等阶
	Proto.writeBYTE(msg,data.score); -- 得分
end

function Proto.parseAwardProbability(entry)
	local data={};
	data.prob=Proto.parseDWORD(entry); -- 概率(千万分之一概率)
	data.awardID=Proto.parseDWORD(entry); -- 奖励表ID
	return data;
end

function Proto.writeAwardProbability(msg,data)
	Proto.writeDWORD(msg,data.prob); -- 概率(千万分之一概率)
	Proto.writeDWORD(msg,data.awardID); -- 奖励表ID
end

function Proto.parseNatureSynthesizationResult(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.beginScore=Proto.parseBYTE(entry); -- 起始分数
	data.endScore=Proto.parseBYTE(entry); -- 结束分数
	data.conditions=Proto.parseVector(entry,Proto.parseBYTE); -- 条件
	data.awardIDs=Proto.parseVector(entry,Proto.parseAwardProbability); -- 奖励表ID
	data.cost=Proto.parseCostInfo(entry); -- 花费
	data.pro=Proto.parseWORD(entry); -- 暴击率
	return data;
end

function Proto.getNatureSynthesizationResultIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeNatureSynthesizationResult(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeBYTE(msg,data.beginScore); -- 起始分数
	Proto.writeBYTE(msg,data.endScore); -- 结束分数
	Proto.writeVector(msg,data.conditions,Proto.writeBYTE); -- 条件
	Proto.writeVector(msg,data.awardIDs,Proto.writeAwardProbability); -- 奖励表ID
	Proto.writeCostInfo(msg,data.cost); -- 花费
	Proto.writeWORD(msg,data.pro); -- 暴击率
end

function Proto.parseSynthesizationItemProbability(entry)
	local data={};
	data.item_type=Proto.parseDWORD(entry); -- 道具生成规则
	return data;
end

function Proto.writeSynthesizationItemProbability(msg,data)
	Proto.writeDWORD(msg,data.item_type); -- 道具生成规则
end

function Proto.parseItemSynthesizationInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 合成编号
	data.name=Proto.parseString(entry); -- 合成名
	data.inputs=Proto.parseVector(entry,Proto.parseSynthesizationItemInput); -- 道具输入
	data.outputs=Proto.parseVector(entry,Proto.parseSynthesizationItemProbability); -- 道具输出
	data.prob=Proto.parseDWORD(entry); -- 概率(千万分之一概率)
	data.moneyType=Proto.parseBYTE(entry); -- 费用币种
	data.moneyCount=Proto.parseWORD(entry); -- 费用
	data.needShow=Proto.parseBYTE(entry); -- 兑换商店是否显示
	data.shopID=Proto.parseWORD(entry); -- 兑换商店号
	return data;
end

function Proto.getItemSynthesizationInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeItemSynthesizationInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 合成编号
	Proto.writeString(msg,data.name); -- 合成名
	Proto.writeVector(msg,data.inputs,Proto.writeSynthesizationItemInput); -- 道具输入
	Proto.writeVector(msg,data.outputs,Proto.writeSynthesizationItemProbability); -- 道具输出
	Proto.writeDWORD(msg,data.prob); -- 概率(千万分之一概率)
	Proto.writeBYTE(msg,data.moneyType); -- 费用币种
	Proto.writeWORD(msg,data.moneyCount); -- 费用
	Proto.writeBYTE(msg,data.needShow); -- 兑换商店是否显示
	Proto.writeWORD(msg,data.shopID); -- 兑换商店号
end

function Proto.parseItemReuseInput(entry)
	local data={};
	data.itemType=Proto.parseDWORD(entry); -- 道具类型
	data.count=Proto.parseWORD(entry); -- 道具数量
	return data;
end

function Proto.writeItemReuseInput(msg,data)
	Proto.writeDWORD(msg,data.itemType); -- 道具类型
	Proto.writeWORD(msg,data.count); -- 道具数量
end

