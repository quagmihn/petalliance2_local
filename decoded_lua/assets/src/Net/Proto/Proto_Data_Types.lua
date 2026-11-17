-- Net.Proto.Proto_Data_Types

Proto.COST_GCASH	= 0						-- [道具等级类型类型]金币
Proto.COST_MCASH	= Proto.COST_GCASH + 1	-- [道具等级类型类型]M币
Proto.COST_ITEM		= Proto.COST_MCASH + 1	-- [道具等级类型类型]道具
Proto.RIT_GCASH	= 0						-- [奖励信息类型]金币
Proto.RIT_MCASH	= Proto.RIT_GCASH + 1	-- [奖励信息类型]M币
Proto.RIT_ITEM	= Proto.RIT_MCASH + 1	-- [奖励信息类型]道具

function Proto.parseStaticNpcInfo(entry)
	local data={};
	data.id=Proto.parseNpcID(entry); -- NpcID
	data.name=Proto.parseLifeNick(entry); -- Npc名称
	data.metier=Proto.parseWORD(entry); -- 职业
	data.publishedQuests=Proto.parseVarArray(entry,Proto.parseWORD,Proto.parseWORD); -- 发布的任务
	data.managedQuests=Proto.parseVarArray(entry,Proto.parseWORD,Proto.parseWORD); -- 管理的任务
	data.dialogContent=Proto.parseString(entry); -- 对话内容
	data.dialogLeave=Proto.parseString(entry); -- 离开对话
	return data;
end

function Proto.getStaticNpcInfoIDLen()
	return Proto.getNpcIDLen();
end

function Proto.writeStaticNpcInfo(msg,data)
	Proto.writeNpcID(msg,data.id); -- NpcID
	Proto.writeLifeNick(msg,data.name); -- Npc名称
	Proto.writeWORD(msg,data.metier); -- 职业
	Proto.writeVarArray(msg,data.publishedQuests,Proto.writeWORD,Proto.writeWORD); -- 发布的任务
	Proto.writeVarArray(msg,data.managedQuests,Proto.writeWORD,Proto.writeWORD); -- 管理的任务
	Proto.writeString(msg,data.dialogContent); -- 对话内容
	Proto.writeString(msg,data.dialogLeave); -- 离开对话
end

function Proto.parseMapPosInfo(entry)
	local data={};
	data.id=Proto.parseBYTE(entry); -- 地图ID
	data.direct=Proto.parseDirectType(entry); -- 方向
	data.pos=Proto.parsePOS2D(entry); -- 位置
	return data;
end

function Proto.getMapPosInfoIDLen()
	return Proto.getBYTELen();
end

function Proto.writeMapPosInfo(msg,data)
	Proto.writeBYTE(msg,data.id); -- 地图ID
	Proto.writeDirectType(msg,data.direct); -- 方向
	Proto.writePOS2D(msg,data.pos); -- 位置
end

function Proto.parseChannelNpcInfo(entry)
	local data={};
	data.id=Proto.parseNpcID(entry); -- NpcID
	data.maps=Proto.parseVector(entry,Proto.parseMapPosInfo); -- 地图位置信息
	return data;
end

function Proto.getChannelNpcInfoIDLen()
	return Proto.getNpcIDLen();
end

function Proto.writeChannelNpcInfo(msg,data)
	Proto.writeNpcID(msg,data.id); -- NpcID
	Proto.writeVector(msg,data.maps,Proto.writeMapPosInfo); -- 地图位置信息
end

function Proto.parseNationPrestige(entry)
	local data={};
	data.id=Proto.parseBYTE(entry); -- ID
	data.prestige=Proto.parseDWORD(entry); -- 增加声望
	data.prestigeVL=Proto.parseBYTE(entry); -- 声望等级阀值
	return data;
end

function Proto.getNationPrestigeIDLen()
	return Proto.getBYTELen();
end

function Proto.writeNationPrestige(msg,data)
	Proto.writeBYTE(msg,data.id); -- ID
	Proto.writeDWORD(msg,data.prestige); -- 增加声望
	Proto.writeBYTE(msg,data.prestigeVL); -- 声望等级阀值
end

function Proto.parseTownChunnelPrice(entry)
	local data={};
	data.id=Proto.parseBYTE(entry); -- 目的地小镇
	data.price=Proto.parseDWORD(entry); -- 价格
	data.pos=Proto.parsePOS2D(entry); -- 位置
	data.direct=Proto.parseDirectType(entry); -- 方向
	data.dialogSelect=Proto.parseString(entry); -- 对话内容
	return data;
end

function Proto.getTownChunnelPriceIDLen()
	return Proto.getBYTELen();
end

function Proto.writeTownChunnelPrice(msg,data)
	Proto.writeBYTE(msg,data.id); -- 目的地小镇
	Proto.writeDWORD(msg,data.price); -- 价格
	Proto.writePOS2D(msg,data.pos); -- 位置
	Proto.writeDirectType(msg,data.direct); -- 方向
	Proto.writeString(msg,data.dialogSelect); -- 对话内容
end

function Proto.parseTownChunnelInfo(entry)
	local data={};
	data.id=Proto.parseTownID(entry); -- 小镇
	data.goals=Proto.parseVector(entry,Proto.parseTownChunnelPrice); -- 目的地
	return data;
end

function Proto.getTownChunnelInfoIDLen()
	return Proto.getTownIDLen();
end

function Proto.writeTownChunnelInfo(msg,data)
	Proto.writeTownID(msg,data.id); -- 小镇
	Proto.writeVector(msg,data.goals,Proto.writeTownChunnelPrice); -- 目的地
end

function Proto.parseInternChunnelPrice(entry)
	local data={};
	data.countryid=Proto.parseCountryID(entry); -- 目的国家
	data.townid=Proto.parseTownID(entry); -- 目的地小镇
	data.price=Proto.parseDWORD(entry); -- 价格
	data.pos=Proto.parsePOS2D(entry); -- 位置
	data.direct=Proto.parseDirectType(entry); -- 方向
	data.dialogSelect=Proto.parseString(entry); -- 对话内容
	return data;
end

function Proto.writeInternChunnelPrice(msg,data)
	Proto.writeCountryID(msg,data.countryid); -- 目的国家
	Proto.writeTownID(msg,data.townid); -- 目的地小镇
	Proto.writeDWORD(msg,data.price); -- 价格
	Proto.writePOS2D(msg,data.pos); -- 位置
	Proto.writeDirectType(msg,data.direct); -- 方向
	Proto.writeString(msg,data.dialogSelect); -- 对话内容
end

function Proto.parseInternChunnelTown(entry)
	local data={};
	data.townid=Proto.parseTownID(entry); -- 出发小镇
	data.goals=Proto.parseVector(entry,Proto.parseInternChunnelPrice); -- 目的地
	return data;
end

function Proto.writeInternChunnelTown(msg,data)
	Proto.writeTownID(msg,data.townid); -- 出发小镇
	Proto.writeVector(msg,data.goals,Proto.writeInternChunnelPrice); -- 目的地
end

function Proto.parseInternChunnelInfo(entry)
	local data={};
	data.id=Proto.parseCountryID(entry); -- 出发国家
	data.townlist=Proto.parseVector(entry,Proto.parseInternChunnelTown); -- 出发小镇列表
	return data;
end

function Proto.getInternChunnelInfoIDLen()
	return Proto.getCountryIDLen();
end

function Proto.writeInternChunnelInfo(msg,data)
	Proto.writeCountryID(msg,data.id); -- 出发国家
	Proto.writeVector(msg,data.townlist,Proto.writeInternChunnelTown); -- 出发小镇列表
end

function Proto.parseReturnChunnelPrice(entry)
	local data={};
	data.id=Proto.parseBYTE(entry); -- 目的地小镇
	data.price=Proto.parseDWORD(entry); -- 价格
	data.pos=Proto.parsePOS2D(entry); -- 位置
	data.direct=Proto.parseDirectType(entry); -- 方向
	data.dialogSelect=Proto.parseString(entry); -- 对话内容
	return data;
end

function Proto.getReturnChunnelPriceIDLen()
	return Proto.getBYTELen();
end

function Proto.writeReturnChunnelPrice(msg,data)
	Proto.writeBYTE(msg,data.id); -- 目的地小镇
	Proto.writeDWORD(msg,data.price); -- 价格
	Proto.writePOS2D(msg,data.pos); -- 位置
	Proto.writeDirectType(msg,data.direct); -- 方向
	Proto.writeString(msg,data.dialogSelect); -- 对话内容
end

function Proto.parseReturnChunnelInfo(entry)
	local data={};
	data.id=Proto.parseTownID(entry); -- 小镇
	data.goals=Proto.parseVector(entry,Proto.parseReturnChunnelPrice); -- 目的地
	return data;
end

function Proto.getReturnChunnelInfoIDLen()
	return Proto.getTownIDLen();
end

function Proto.writeReturnChunnelInfo(msg,data)
	Proto.writeTownID(msg,data.id); -- 小镇
	Proto.writeVector(msg,data.goals,Proto.writeReturnChunnelPrice); -- 目的地
end

function Proto.parseFarmMapInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 小镇ID
	data.code=Proto.parseFarmMapCode(entry); -- 小镇编码
	return data;
end

function Proto.getFarmMapInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeFarmMapInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 小镇ID
	Proto.writeFarmMapCode(msg,data.code); -- 小镇编码
end

function Proto.parseMonsterFightInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 怪物id
	data.x=Proto.parseBYTE(entry); -- X坐标
	data.y=Proto.parseBYTE(entry); -- Y坐标
	return data;
end

function Proto.getMonsterFightInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeMonsterFightInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 怪物id
	Proto.writeBYTE(msg,data.x); -- X坐标
	Proto.writeBYTE(msg,data.y); -- Y坐标
end

function Proto.parseFightMonsterInfo(entry)
	local data={};
	data.monsterID=Proto.parseDWORD(entry); -- 怪物ID
	data.level=Proto.parseBYTE(entry); -- 等级系数
	data.extraHP=Proto.parseVector(entry,Proto.parseDWORD); -- 额外HP
	data.extraSP=Proto.parseVector(entry,Proto.parseDWORD); -- 额外SP
	data.extraATK=Proto.parseVector(entry,Proto.parseDWORD); -- 额外ATK
	data.extraDEF=Proto.parseVector(entry,Proto.parseDWORD); -- 额外EEF
	data.extraMATK=Proto.parseVector(entry,Proto.parseDWORD); -- 额外MATK
	data.extraMDEF=Proto.parseVector(entry,Proto.parseDWORD); -- 额外MDEF
	return data;
end

function Proto.writeFightMonsterInfo(msg,data)
	Proto.writeDWORD(msg,data.monsterID); -- 怪物ID
	Proto.writeBYTE(msg,data.level); -- 等级系数
	Proto.writeVector(msg,data.extraHP,Proto.writeDWORD); -- 额外HP
	Proto.writeVector(msg,data.extraSP,Proto.writeDWORD); -- 额外SP
	Proto.writeVector(msg,data.extraATK,Proto.writeDWORD); -- 额外ATK
	Proto.writeVector(msg,data.extraDEF,Proto.writeDWORD); -- 额外EEF
	Proto.writeVector(msg,data.extraMATK,Proto.writeDWORD); -- 额外MATK
	Proto.writeVector(msg,data.extraMDEF,Proto.writeDWORD); -- 额外MDEF
end

function Proto.parseFightInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 组ID
	data.awardTable=Proto.parseDWORD(entry); -- 奖励表
	data.monsters=Proto.parseVector(entry,Proto.parseFightMonsterInfo); -- 怪物组
	return data;
end

function Proto.getFightInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeFightInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 组ID
	Proto.writeDWORD(msg,data.awardTable); -- 奖励表
	Proto.writeVector(msg,data.monsters,Proto.writeFightMonsterInfo); -- 怪物组
end

function Proto.parseFightProbability(entry)
	local data={};
	data.prob=Proto.parseDWORD(entry); -- 概率(千万分之一概率)
	data.fightID=Proto.parseDWORD(entry); -- 战斗组ID
	return data;
end

function Proto.writeFightProbability(msg,data)
	Proto.writeDWORD(msg,data.prob); -- 概率(千万分之一概率)
	Proto.writeDWORD(msg,data.fightID); -- 战斗组ID
end

function Proto.parseCheckPointInfo(entry)
	local data={};
	data.fights=Proto.parseVector(entry,Proto.parseFightProbability); -- 战斗组
	return data;
end

function Proto.writeCheckPointInfo(msg,data)
	Proto.writeVector(msg,data.fights,Proto.writeFightProbability); -- 战斗组
end

function Proto.parseStageRecord(entry)
	local data={};
	data.stage=Proto.parseDWORD(entry); -- 挑战点
	data.checkPoint=Proto.parseBYTE(entry); -- 关卡
	data.lastChanllenageTime=Proto.parseTIME_SEC(entry); -- 最后挑战时间
	data.lastResetTime=Proto.parseTIME_SEC(entry); -- 上次重置时间
	data.resetCount=Proto.parseBYTE(entry); -- 重置次数
	return data;
end

function Proto.writeStageRecord(msg,data)
	Proto.writeDWORD(msg,data.stage); -- 挑战点
	Proto.writeBYTE(msg,data.checkPoint); -- 关卡
	Proto.writeTIME_SEC(msg,data.lastChanllenageTime); -- 最后挑战时间
	Proto.writeTIME_SEC(msg,data.lastResetTime); -- 上次重置时间
	Proto.writeBYTE(msg,data.resetCount); -- 重置次数
end

function Proto.parseCostInfo_PARAM_GCash(entry)
	local data={};
	data.value=Proto.parseWORD(entry); -- 值
	return data;
end

function Proto.writeCostInfo_PARAM_GCash(msg,data)
	Proto.writeWORD(msg,data.value); -- 值
end

function Proto.parseCostInfo_PARAM_MCash(entry)
	local data={};
	data.value=Proto.parseWORD(entry); -- 值
	return data;
end

function Proto.writeCostInfo_PARAM_MCash(msg,data)
	Proto.writeWORD(msg,data.value); -- 值
end

function Proto.parseCostInfo_PARAM_Item(entry)
	local data={};
	data.itemID=Proto.parseDWORD(entry); -- 道具ID
	data.count=Proto.parseWORD(entry); -- 道具数量
	return data;
end

function Proto.writeCostInfo_PARAM_Item(msg,data)
	Proto.writeDWORD(msg,data.itemID); -- 道具ID
	Proto.writeWORD(msg,data.count); -- 道具数量
end

function Proto.parseCostInfo(entry)
	local data={};
	data.type=Proto.parseBYTE(entry); -- 消耗道具类型
	data.param={}; -- 
	if (data.type==Proto.COST_GCASH) then
		data.param.gCash=Proto.parseCostInfo_PARAM_GCash(entry); -- G币
	end
	if (data.type==Proto.COST_MCASH) then
		data.param.mCash=Proto.parseCostInfo_PARAM_MCash(entry); -- M币
	end
	if (data.type==Proto.COST_ITEM) then
		data.param.item=Proto.parseCostInfo_PARAM_Item(entry); -- 道具
	end
	return data;
end

function Proto.writeCostInfo(msg,data)
	Proto.writeBYTE(msg,data.type); -- 消耗道具类型
	if (data.type==Proto.COST_GCASH) then
		Proto.writeCostInfo_PARAM_GCash(msg,data.param.gCash); -- G币
	end
	if (data.type==Proto.COST_MCASH) then
		Proto.writeCostInfo_PARAM_MCash(msg,data.param.mCash); -- M币
	end
	if (data.type==Proto.COST_ITEM) then
		Proto.writeCostInfo_PARAM_Item(msg,data.param.item); -- 道具
	end
end

function Proto.parseStageInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.name=Proto.parseString(entry); -- 挑战点名称
	data.condition=Proto.parseStageRecord(entry); -- 开启条件
	data.checkPoints=Proto.parseVector(entry,Proto.parseCheckPointInfo); -- 关卡组
	data.cost=Proto.parseCostInfo(entry); -- 重置代价
	data.desc=Proto.parseString(entry); -- 描述
	return data;
end

function Proto.getStageInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeStageInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeString(msg,data.name); -- 挑战点名称
	Proto.writeStageRecord(msg,data.condition); -- 开启条件
	Proto.writeVector(msg,data.checkPoints,Proto.writeCheckPointInfo); -- 关卡组
	Proto.writeCostInfo(msg,data.cost); -- 重置代价
	Proto.writeString(msg,data.desc); -- 描述
end

function Proto.parseRandomInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 单元ID
	data.prob=Proto.parseDWORD(entry); -- 测试几率(千万分之一)
	return data;
end

function Proto.getRandomInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeRandomInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 单元ID
	Proto.writeDWORD(msg,data.prob); -- 测试几率(千万分之一)
end

function Proto.parseRandomTableInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 随机表的ID
	data.infos=Proto.parseVarArray(entry,Proto.parseRandomInfo,Proto.parseWORD); -- 随机表向量
	return data;
end

function Proto.getRandomTableInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeRandomTableInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 随机表的ID
	Proto.writeVarArray(msg,data.infos,Proto.writeRandomInfo,Proto.writeWORD); -- 随机表向量
end

function Proto.parseEggRace(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 宠物蛋道具类型ID
	data.race_id=Proto.parseDWORD(entry); -- 种族类型ID
	data.days=Proto.parseBYTE(entry); -- 孵化需要天数
	if (data.days~=0) then
		data.eat_item=Proto.parseDWORD(entry); -- 灌注道具
		data.eat_count=Proto.parseWORD(entry); -- 灌注数量
	end
	data.eat_experience=Proto.parseDWORD(entry); -- 吃蛋经验
	data.eat_cost=Proto.parseDWORD(entry); -- 吃蛋消耗G币
	data.hatch_cost=Proto.parseDWORD(entry); -- 孵化消耗M币
	return data;
end

function Proto.getEggRaceIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeEggRace(msg,data)
	Proto.writeDWORD(msg,data.id); -- 宠物蛋道具类型ID
	Proto.writeDWORD(msg,data.race_id); -- 种族类型ID
	Proto.writeBYTE(msg,data.days); -- 孵化需要天数
	if (data.days~=0) then
		Proto.writeDWORD(msg,data.eat_item); -- 灌注道具
		Proto.writeWORD(msg,data.eat_count); -- 灌注数量
	end
	Proto.writeDWORD(msg,data.eat_experience); -- 吃蛋经验
	Proto.writeDWORD(msg,data.eat_cost); -- 吃蛋消耗G币
	Proto.writeDWORD(msg,data.hatch_cost); -- 孵化消耗M币
end

function Proto.parseStatePowerInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 状态ID
	data.power=Proto.parseBYTE(entry); -- 强度
	return data;
end

function Proto.getStatePowerInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeStatePowerInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 状态ID
	Proto.writeBYTE(msg,data.power); -- 强度
end

function Proto.parseFoodStateInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 食物道具类型ID
	data.baseCalorie=Proto.parseWORD(entry); -- 基础卡路里
	data.fat=Proto.parseWORD(entry); -- 脂肪指数
	data.states=Proto.parseVector(entry,Proto.parseStatePowerInfo); -- 临时增益状态
	return data;
end

function Proto.getFoodStateInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeFoodStateInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 食物道具类型ID
	Proto.writeWORD(msg,data.baseCalorie); -- 基础卡路里
	Proto.writeWORD(msg,data.fat); -- 脂肪指数
	Proto.writeVector(msg,data.states,Proto.writeStatePowerInfo); -- 临时增益状态
end

function Proto.parseFestaInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 节日ID
	data.name=Proto.parseString(entry); -- 节日名
	return data;
end

function Proto.getFestaInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeFestaInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 节日ID
	Proto.writeString(msg,data.name); -- 节日名
end

function Proto.parseFestaPeriod(entry)
	local data={};
	data.start=Proto.parseTIME_SEC(entry); -- 开始时间
	data.over=Proto.parseTIME_SEC(entry); -- 结束时间
	data.festaID=Proto.parseDWORD(entry); -- 节日分类ID
	data.property=Proto.parseFestaProperty(entry); -- 特别属性
	return data;
end

function Proto.writeFestaPeriod(msg,data)
	Proto.writeTIME_SEC(msg,data.start); -- 开始时间
	Proto.writeTIME_SEC(msg,data.over); -- 结束时间
	Proto.writeDWORD(msg,data.festaID); -- 节日分类ID
	Proto.writeFestaProperty(msg,data.property); -- 特别属性
end

function Proto.parseConfraternityNpcInfo(entry)
	local data={};
	data.id=Proto.parseNpcID(entry); -- NpcID
	data.states=Proto.parseVector(entry,Proto.parseStatePowerInfo); -- 增益状态
	return data;
end

function Proto.getConfraternityNpcInfoIDLen()
	return Proto.getNpcIDLen();
end

function Proto.writeConfraternityNpcInfo(msg,data)
	Proto.writeNpcID(msg,data.id); -- NpcID
	Proto.writeVector(msg,data.states,Proto.writeStatePowerInfo); -- 增益状态
end

function Proto.parseCountryInfo(entry)
	local data={};
	data.id=Proto.parseCountryID(entry); -- 国家ID
	data.name=Proto.parseString(entry); -- 国家名称
	data.neutral=Proto.parseBYTE(entry); -- 是否中立
	return data;
end

function Proto.getCountryInfoIDLen()
	return Proto.getCountryIDLen();
end

function Proto.writeCountryInfo(msg,data)
	Proto.writeCountryID(msg,data.id); -- 国家ID
	Proto.writeString(msg,data.name); -- 国家名称
	Proto.writeBYTE(msg,data.neutral); -- 是否中立
end

function Proto.parseBattleServerInfo(entry)
	local data={};
	data.ip=Proto.parseDWORD(entry); -- ip地址
	data.port=Proto.parseWORD(entry); -- 端口
	return data;
end

function Proto.writeBattleServerInfo(msg,data)
	Proto.writeDWORD(msg,data.ip); -- ip地址
	Proto.writeWORD(msg,data.port); -- 端口
end

function Proto.parsePetSubstituteInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 编号
	data.pos=Proto.parseBYTE(entry); -- 位置
	data.mcash=Proto.parseDWORD(entry); -- m币价格
	data.gcash=Proto.parseDWORD(entry); -- g币价格
	return data;
end

function Proto.getPetSubstituteInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writePetSubstituteInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 编号
	Proto.writeBYTE(msg,data.pos); -- 位置
	Proto.writeDWORD(msg,data.mcash); -- m币价格
	Proto.writeDWORD(msg,data.gcash); -- g币价格
end

function Proto.parsePetBattleBriefInfo(entry)
	local data={};
	data.name=Proto.parseLifeNick(entry); -- 宠物名称
	data.raceType=Proto.parseDWORD(entry); -- 动物类型
	data.level=Proto.parseWORD(entry); -- 等级
	return data;
end

function Proto.writePetBattleBriefInfo(msg,data)
	Proto.writeLifeNick(msg,data.name); -- 宠物名称
	Proto.writeDWORD(msg,data.raceType); -- 动物类型
	Proto.writeWORD(msg,data.level); -- 等级
end

