-- Net.Proto.Proto_PetAide_Types

Proto.PACT_S		= 0					-- []S阶
Proto.PACT_A		= Proto.PACT_S + 1	-- []A阶
Proto.PACT_B		= Proto.PACT_A + 1	-- []B阶
Proto.PACT_C		= Proto.PACT_B + 1	-- []C阶
Proto.PACT_D		= Proto.PACT_C + 1	-- []D阶
Proto.PACT_E		= Proto.PACT_D + 1	-- []E阶
Proto.PACT_COUNT	= Proto.PACT_E + 1	-- []总数
Proto.PETAIDE_CREATE_CHANGE			= 0											-- []伴灵出生
Proto.PETAIDE_EXP_CHANGE			= Proto.PETAIDE_CREATE_CHANGE + 1			-- []伴灵经验变化
Proto.PETAIDE_LEVEL_CHANGE			= Proto.PETAIDE_EXP_CHANGE + 1				-- []伴灵等级变化
Proto.PETAIDE_CLASS_CHANGE			= Proto.PETAIDE_LEVEL_CHANGE + 1			-- []伴灵等阶变化
Proto.PETAIDE_FEED_PROGRESS_CHANGE	= Proto.PETAIDE_CLASS_CHANGE + 1			-- []伴灵饱食度变化
Proto.PETAIDE_NATURE_CHANGE			= Proto.PETAIDE_FEED_PROGRESS_CHANGE + 1	-- []伴灵天性发生变化
Proto.PETAIDE_EFFECT_CHANGE			= Proto.PETAIDE_NATURE_CHANGE + 1			-- []伴灵出战位置变化
Proto.PETAIDE_UNEFFECTED	= 0								-- []伴灵未携带
Proto.PETAIDE_EFFECTED		= Proto.PETAIDE_UNEFFECTED + 1	-- []伴灵携带
Proto.PETAIDE_NATURE_UNEFFECTED	= 0										-- []伴灵未携带
Proto.PETAIDE_NATURE_EFFECTED	= Proto.PETAIDE_NATURE_UNEFFECTED + 1	-- []伴灵携带

function Proto.parsePetAideGlobeInfo(entry)
	local data={};
	data.id=Proto.parseBYTE(entry); -- 配置编号
	data.feedCDTime=Proto.parseDWORD(entry); -- 喂养冷却时间(秒)
	data.aideMaxCount=Proto.parseBYTE(entry); -- 伴灵携带最大个数
	data.aideNaturesCountEffected=Proto.parseBYTE(entry); -- 伴灵有效天性个数
	data.aideNaturesCount=Proto.parseBYTE(entry); -- 伴灵天生携带天性个数
	data.clearFeedCostType=Proto.parseCostInfo(entry); -- 每日清空喂食价格类型
	data.reserveNatureLevelCost=Proto.parseCostInfo(entry); -- 伴灵技能等级保留消耗
	data.luckyNatureLevelCost=Proto.parseCostInfo(entry); -- 伴灵技能升级幸运消耗
	return data;
end

function Proto.getPetAideGlobeInfoIDLen()
	return Proto.getBYTELen();
end

function Proto.writePetAideGlobeInfo(msg,data)
	Proto.writeBYTE(msg,data.id); -- 配置编号
	Proto.writeDWORD(msg,data.feedCDTime); -- 喂养冷却时间(秒)
	Proto.writeBYTE(msg,data.aideMaxCount); -- 伴灵携带最大个数
	Proto.writeBYTE(msg,data.aideNaturesCountEffected); -- 伴灵有效天性个数
	Proto.writeBYTE(msg,data.aideNaturesCount); -- 伴灵天生携带天性个数
	Proto.writeCostInfo(msg,data.clearFeedCostType); -- 每日清空喂食价格类型
	Proto.writeCostInfo(msg,data.reserveNatureLevelCost); -- 伴灵技能等级保留消耗
	Proto.writeCostInfo(msg,data.luckyNatureLevelCost); -- 伴灵技能升级幸运消耗
end

function Proto.parsePetAideInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 伴灵类型ID
	data.nickName=Proto.parseString(entry); -- 名称
	data.aideClass=Proto.parseBYTE(entry); -- 等阶
	data.struggles=Proto.parseVarArray(entry,Proto.parseWORD,Proto.parseWORD); -- 六维增幅比例
	data.maxFeedProgress=Proto.parseDWORD(entry); -- 饱食度上限
	data.maxNatureLevel=Proto.parseDWORD(entry); -- 天性等级上限
	data.maxLevel=Proto.parseDWORD(entry); -- 等级上限
	return data;
end

function Proto.getPetAideInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writePetAideInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 伴灵类型ID
	Proto.writeString(msg,data.nickName); -- 名称
	Proto.writeBYTE(msg,data.aideClass); -- 等阶
	Proto.writeVarArray(msg,data.struggles,Proto.writeWORD,Proto.writeWORD); -- 六维增幅比例
	Proto.writeDWORD(msg,data.maxFeedProgress); -- 饱食度上限
	Proto.writeDWORD(msg,data.maxNatureLevel); -- 天性等级上限
	Proto.writeDWORD(msg,data.maxLevel); -- 等级上限
end

function Proto.parsePetAideNatureInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 伴灵类型ID
	data.geneProbabilityGroups=Proto.parseVector(entry,Proto.parseDWORD); -- 基因概率组
	return data;
end

function Proto.getPetAideNatureInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writePetAideNatureInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 伴灵类型ID
	Proto.writeVector(msg,data.geneProbabilityGroups,Proto.writeDWORD); -- 基因概率组
end

function Proto.parsePetAideLevelInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 等级
	data.exp=Proto.parseDWORD(entry); -- 经验
	data.addedRatio=Proto.parseDWORD(entry); -- 附加比例
	return data;
end

function Proto.getPetAideLevelInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writePetAideLevelInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 等级
	Proto.writeDWORD(msg,data.exp); -- 经验
	Proto.writeDWORD(msg,data.addedRatio); -- 附加比例
end

function Proto.parsePetAideNatureSynthesizationInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 道具类型编号
	data.probs=Proto.parseVector(entry,Proto.parseDWORD); -- 技能强化概率
	return data;
end

function Proto.getPetAideNatureSynthesizationInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writePetAideNatureSynthesizationInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 道具类型编号
	Proto.writeVector(msg,data.probs,Proto.writeDWORD); -- 技能强化概率
end

function Proto.parsePetAideEvolutionInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 进化编号
	data.sourceID=Proto.parseDWORD(entry); -- 进化前类型ID
	data.targetID=Proto.parseDWORD(entry); -- 进化后类型ID
	data.level=Proto.parseDWORD(entry); -- 进化等级
	data.costInfos=Proto.parseVector(entry,Proto.parseCostInfo); -- 进化道具类型
	return data;
end

function Proto.getPetAideEvolutionInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writePetAideEvolutionInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 进化编号
	Proto.writeDWORD(msg,data.sourceID); -- 进化前类型ID
	Proto.writeDWORD(msg,data.targetID); -- 进化后类型ID
	Proto.writeDWORD(msg,data.level); -- 进化等级
	Proto.writeVector(msg,data.costInfos,Proto.writeCostInfo); -- 进化道具类型
end

function Proto.parsePetAideFeedInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 道具编号
	data.exp=Proto.parseDWORD(entry); -- 增加经验
	data.feedProgress=Proto.parseDWORD(entry); -- 饱食度
	return data;
end

function Proto.getPetAideFeedInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writePetAideFeedInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 道具编号
	Proto.writeDWORD(msg,data.exp); -- 增加经验
	Proto.writeDWORD(msg,data.feedProgress); -- 饱食度
end

function Proto.parsePetAideDetailInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 伴灵ID
	data.typeID=Proto.parseDWORD(entry); -- 伴灵类型ID
	data.nickName=Proto.parseString(entry); -- 名称
	data.pos=Proto.parseBYTE(entry); -- 位置
	data.eff=Proto.parseBYTE(entry); -- 当前携带
	data.exp=Proto.parseDWORD(entry); -- 经验
	data.level=Proto.parseWORD(entry); -- 等级
	data.lastFeedProgressTime=Proto.parseTIME_SEC(entry); -- 上次喂食时间
	data.feedProgress=Proto.parseDWORD(entry); -- 饱食度
	data.struggles=Proto.parseVarArray(entry,Proto.parseWORD,Proto.parseWORD); -- 六维增幅比例
	data.natures=Proto.parseVector(entry,Proto.parseUnitNatureAllele); -- 技能库
	data.natureOnEffected=Proto.parseVector(entry,Proto.parseBYTE); -- 生效技能位置
	return data;
end

function Proto.getPetAideDetailInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writePetAideDetailInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 伴灵ID
	Proto.writeDWORD(msg,data.typeID); -- 伴灵类型ID
	Proto.writeString(msg,data.nickName); -- 名称
	Proto.writeBYTE(msg,data.pos); -- 位置
	Proto.writeBYTE(msg,data.eff); -- 当前携带
	Proto.writeDWORD(msg,data.exp); -- 经验
	Proto.writeWORD(msg,data.level); -- 等级
	Proto.writeTIME_SEC(msg,data.lastFeedProgressTime); -- 上次喂食时间
	Proto.writeDWORD(msg,data.feedProgress); -- 饱食度
	Proto.writeVarArray(msg,data.struggles,Proto.writeWORD,Proto.writeWORD); -- 六维增幅比例
	Proto.writeVector(msg,data.natures,Proto.writeUnitNatureAllele); -- 技能库
	Proto.writeVector(msg,data.natureOnEffected,Proto.writeBYTE); -- 生效技能位置
end

function Proto.parsePetAideNatureLevelInfo(entry)
	local data={};
	data.geneID=Proto.parseWORD(entry); -- 技能ID
	data.geneLevel=Proto.parseint(entry); -- 技能等级
	data.geneFakeName=Proto.parseString(entry); -- 技能假名称
	data.geneFakeLevel=Proto.parseint(entry); -- 技能假等级
	return data;
end

function Proto.writePetAideNatureLevelInfo(msg,data)
	Proto.writeWORD(msg,data.geneID); -- 技能ID
	Proto.writeint(msg,data.geneLevel); -- 技能等级
	Proto.writeString(msg,data.geneFakeName); -- 技能假名称
	Proto.writeint(msg,data.geneFakeLevel); -- 技能假等级
end

function Proto.parsePetAideNatureLevelInfoGroup(entry)
	local data={};
	data.id=Proto.parseint(entry); -- id
	data.natureLevelInfoGroup=Proto.parseVector(entry,Proto.parsePetAideNatureLevelInfo); -- 伴灵天性等级信息
	return data;
end

function Proto.getPetAideNatureLevelInfoGroupIDLen()
	return Proto.getintLen();
end

function Proto.writePetAideNatureLevelInfoGroup(msg,data)
	Proto.writeint(msg,data.id); -- id
	Proto.writeVector(msg,data.natureLevelInfoGroup,Proto.writePetAideNatureLevelInfo); -- 伴灵天性等级信息
end

