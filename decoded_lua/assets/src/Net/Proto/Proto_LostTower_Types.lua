-- Net.Proto.Proto_LostTower_Types

Proto.LTET_NONE				= 0									-- [迷失之塔事件类型]空事件
Proto.LTET_PICKITEM			= Proto.LTET_NONE + 1				-- [迷失之塔事件类型]拾取道具
Proto.LTET_PVE				= Proto.LTET_PICKITEM + 1			-- [迷失之塔事件类型]PVE战斗
Proto.LTET_OBSTACLE			= Proto.LTET_PVE + 1				-- [迷失之塔事件类型]障碍物
Proto.LTET_EXIT				= Proto.LTET_OBSTACLE + 1			-- [迷失之塔事件类型]出口
Proto.LTET_START			= Proto.LTET_EXIT + 1				-- [迷失之塔事件类型]起点
Proto.LTET_MECHANISM		= Proto.LTET_START + 1				-- [迷失之塔事件类型]机关
Proto.LTET_TRANS			= Proto.LTET_MECHANISM + 1			-- [迷失之塔事件类型]传送
Proto.LTET_TRAINER			= Proto.LTET_TRANS + 1				-- [迷失之塔事件类型]训练师
Proto.LTET_ATTRIBUTECHANGE	= Proto.LTET_TRAINER + 1			-- [迷失之塔事件类型]属性变化
Proto.LTET_RANDOMCHEST		= Proto.LTET_ATTRIBUTECHANGE + 1	-- [迷失之塔事件类型]随机宝箱
Proto.LTET_RECOVER			= Proto.LTET_RANDOMCHEST + 1		-- [迷失之塔事件类型]恢复
Proto.LTET_SPECIALEFFECT	= Proto.LTET_RECOVER + 1			-- [迷失之塔事件类型]特殊效果
Proto.LTET_NPC				= Proto.LTET_SPECIALEFFECT + 1		-- [迷失之塔事件类型]稀有NPC
Proto.LTET_RANDOMEVENT		= Proto.LTET_NPC + 1				-- [迷失之塔事件类型]随机事件
Proto.LTET_STATIONARYAWARD	= Proto.LTET_RANDOMEVENT + 1		-- [迷失之塔事件类型]固定奖励
Proto.LTET_PVPBATTLE		= Proto.LTET_STATIONARYAWARD + 1	-- [迷失之塔事件类型]PVP战斗
Proto.LTET_BOSS				= Proto.LTET_PVPBATTLE + 1			-- [迷失之塔事件类型]BOSS事件
Proto.LTET_TRIP				= Proto.LTET_BOSS + 1				-- [迷失之塔事件类型]陷阱
Proto.LTET_COLLECTION		= Proto.LTET_TRIP + 1				-- [迷失之塔事件类型]采集
Proto.ET_NONE		= 0						-- []无
Proto.ET_BOSS		= Proto.ET_NONE + 1		-- []守关BOSS
Proto.ET_AWARD		= Proto.ET_BOSS + 1		-- []奖励
Proto.ET_MONSTER	= Proto.ET_AWARD + 1	-- []野生怪物
Proto.ET_TRAINER	= Proto.ET_MONSTER + 1	-- []训练师
Proto.ET_CHEST		= Proto.ET_TRAINER + 1	-- []随机宝箱
Proto.ET_COLLECTION	= Proto.ET_CHEST + 1	-- []采集
Proto.DT_NONE	= 0						-- []无
Proto.DT_NORMAL	= Proto.DT_NONE + 1		-- []普通掉落
Proto.DT_ELITE	= Proto.DT_NORMAL + 1	-- []精英掉落
Proto.DT_BOSS	= Proto.DT_ELITE + 1	-- []BOSS掉落

function Proto.parseLostTowerList(entry)
	local data={};
	data.x=Proto.parseWORD(entry); -- X坐标
	data.y=Proto.parseWORD(entry); -- Y坐标
	data.type=Proto.parseDWORD(entry); -- 事件类型
	data.eventListID=Proto.parseDWORD(entry); -- 事件列表ID
	data.terrRes=Proto.parseDWORD(entry); -- 地形资源
	return data;
end

function Proto.writeLostTowerList(msg,data)
	Proto.writeWORD(msg,data.x); -- X坐标
	Proto.writeWORD(msg,data.y); -- Y坐标
	Proto.writeDWORD(msg,data.type); -- 事件类型
	Proto.writeDWORD(msg,data.eventListID); -- 事件列表ID
	Proto.writeDWORD(msg,data.terrRes); -- 地形资源
end

function Proto.parseLostTowerInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.lostTowerList=Proto.parseVector(entry,Proto.parseLostTowerList); -- 
	return data;
end

function Proto.getLostTowerInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeLostTowerInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeVector(msg,data.lostTowerList,Proto.writeLostTowerList); -- 
end

function Proto.parseEventList(entry)
	local data={};
	data.eventType=Proto.parseDWORD(entry); -- 事件类型
	data.event=Proto.parseDWORD(entry); -- 事件表现
	data.rate=Proto.parseDWORD(entry); -- 概率
	return data;
end

function Proto.writeEventList(msg,data)
	Proto.writeDWORD(msg,data.eventType); -- 事件类型
	Proto.writeDWORD(msg,data.event); -- 事件表现
	Proto.writeDWORD(msg,data.rate); -- 概率
end

function Proto.parseEventListInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.eventList=Proto.parseVector(entry,Proto.parseEventList); -- 
	return data;
end

function Proto.getEventListInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeEventListInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeVector(msg,data.eventList,Proto.writeEventList); -- 
end

function Proto.parseRecoverEffectInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.type=Proto.parseDWORD(entry); -- 类型1表示百分比，2表示数值
	data.value=Proto.parseDWORD(entry); -- 具体值
	data.expressionRes=Proto.parseString(entry); -- 副本表现资源
	data.expressionEffect=Proto.parseString(entry); -- 人物表现特效
	return data;
end

function Proto.getRecoverEffectInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeRecoverEffectInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeDWORD(msg,data.type); -- 类型1表示百分比，2表示数值
	Proto.writeDWORD(msg,data.value); -- 具体值
	Proto.writeString(msg,data.expressionRes); -- 副本表现资源
	Proto.writeString(msg,data.expressionEffect); -- 人物表现特效
end

function Proto.parseRandomChestInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.stateName=Proto.parseString(entry); -- 状态名称
	data.openCondition=Proto.parseDWORD(entry); -- 打开宝箱需要道具，0表示不需要
	data.openMoney=Proto.parseDWORD(entry); -- 钻石打开
	data.typeRes=Proto.parseString(entry); -- 属性标示
	data.randomAwardIDFirst=Proto.parseVector(entry,Proto.parseDWORD); -- 随机奖励1
	data.randomAwardIDSecond=Proto.parseVector(entry,Proto.parseDWORD); -- 随机奖励2
	data.randomAwardIDThird=Proto.parseVector(entry,Proto.parseDWORD); -- 随机奖励3
	data.randomAwardIDFourth=Proto.parseVector(entry,Proto.parseDWORD); -- 随机奖励4
	data.openBeforPath=Proto.parseString(entry); -- 宝箱打开前路径
	data.openAfterPath=Proto.parseString(entry); -- 宝箱打开后路径
	return data;
end

function Proto.getRandomChestInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeRandomChestInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeString(msg,data.stateName); -- 状态名称
	Proto.writeDWORD(msg,data.openCondition); -- 打开宝箱需要道具，0表示不需要
	Proto.writeDWORD(msg,data.openMoney); -- 钻石打开
	Proto.writeString(msg,data.typeRes); -- 属性标示
	Proto.writeVector(msg,data.randomAwardIDFirst,Proto.writeDWORD); -- 随机奖励1
	Proto.writeVector(msg,data.randomAwardIDSecond,Proto.writeDWORD); -- 随机奖励2
	Proto.writeVector(msg,data.randomAwardIDThird,Proto.writeDWORD); -- 随机奖励3
	Proto.writeVector(msg,data.randomAwardIDFourth,Proto.writeDWORD); -- 随机奖励4
	Proto.writeString(msg,data.openBeforPath); -- 宝箱打开前路径
	Proto.writeString(msg,data.openAfterPath); -- 宝箱打开后路径
end

function Proto.parseLostTowerAwardInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.rate=Proto.parseDWORD(entry); -- 概率
	data.itemID=Proto.parseDWORD(entry); -- 道具ID
	data.count=Proto.parseDWORD(entry); -- 奖励次数
	return data;
end

function Proto.getLostTowerAwardInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeLostTowerAwardInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeDWORD(msg,data.rate); -- 概率
	Proto.writeDWORD(msg,data.itemID); -- 道具ID
	Proto.writeDWORD(msg,data.count); -- 奖励次数
end

function Proto.parseAttributeChangeInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.name=Proto.parseString(entry); -- 状态名称
	data.type=Proto.parseDWORD(entry); -- 增加类型1表示百分比，2表示数值
	data.subType=Proto.parseDWORD(entry); -- 影响属性
	data.value=Proto.parseint(entry); -- 具体数值
	data.stepNumber=Proto.parseDWORD(entry); -- 持续步数
	data.res=Proto.parseString(entry); -- 副本表现资源
	data.specialEffects=Proto.parseString(entry); -- 特效
	return data;
end

function Proto.getAttributeChangeInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeAttributeChangeInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeString(msg,data.name); -- 状态名称
	Proto.writeDWORD(msg,data.type); -- 增加类型1表示百分比，2表示数值
	Proto.writeDWORD(msg,data.subType); -- 影响属性
	Proto.writeint(msg,data.value); -- 具体数值
	Proto.writeDWORD(msg,data.stepNumber); -- 持续步数
	Proto.writeString(msg,data.res); -- 副本表现资源
	Proto.writeString(msg,data.specialEffects); -- 特效
end

function Proto.parseRandomEventInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.randomList=Proto.parseVector(entry,Proto.parseEventList); -- 随机列表
	return data;
end

function Proto.getRandomEventInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeRandomEventInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeVector(msg,data.randomList,Proto.writeEventList); -- 随机列表
end

function Proto.parseStationaryAwardInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.awardID=Proto.parseDWORD(entry); -- 奖励ID
	return data;
end

function Proto.getStationaryAwardInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeStationaryAwardInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeDWORD(msg,data.awardID); -- 奖励ID
end

function Proto.parsePointLostTowerInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID层数
	data.monster=Proto.parseDWORD(entry); -- 小怪掉落积分
	data.boss=Proto.parseDWORD(entry); -- BOSS掉落积分
	data.monsterMan=Proto.parseDWORD(entry); -- 训练师掉落积分
	data.pvp=Proto.parseDWORD(entry); -- PVP掉落积分
	data.pvpArena=Proto.parseDWORD(entry); -- PVP掉落竞技场点
	data.pvpStepNumber=Proto.parseDWORD(entry); -- pvp掉落步数
	return data;
end

function Proto.getPointLostTowerInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writePointLostTowerInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID层数
	Proto.writeDWORD(msg,data.monster); -- 小怪掉落积分
	Proto.writeDWORD(msg,data.boss); -- BOSS掉落积分
	Proto.writeDWORD(msg,data.monsterMan); -- 训练师掉落积分
	Proto.writeDWORD(msg,data.pvp); -- PVP掉落积分
	Proto.writeDWORD(msg,data.pvpArena); -- PVP掉落竞技场点
	Proto.writeDWORD(msg,data.pvpStepNumber); -- pvp掉落步数
end

function Proto.parseTransferInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 层数ID
	data.consume=Proto.parseDWORD(entry); -- 消耗ID
	return data;
end

function Proto.getTransferInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeTransferInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 层数ID
	Proto.writeDWORD(msg,data.consume); -- 消耗ID
end

function Proto.parseRecoverStateInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 次数
	data.consume=Proto.parseDWORD(entry); -- 消耗
	return data;
end

function Proto.getRecoverStateInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeRecoverStateInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 次数
	Proto.writeDWORD(msg,data.consume); -- 消耗
end

function Proto.parseRandomMapRuleInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 层数
	data.mapList=Proto.parseVector(entry,Proto.parseDWORD); -- 地图列表
	return data;
end

function Proto.getRandomMapRuleInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeRandomMapRuleInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 层数
	Proto.writeVector(msg,data.mapList,Proto.writeDWORD); -- 地图列表
end

function Proto.parseLostTowerBossInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.groupCode=Proto.parseString(entry); -- 训练师代号
	data.name=Proto.parseString(entry); -- 训练师名字
	data.fightPokemons=Proto.parseVector(entry,Proto.parseDWORD); -- 战斗宠物
	data.aidPokemons=Proto.parseVector(entry,Proto.parseDWORD); -- 援助宠物
	data.seniorFigure=Proto.parseString(entry); -- 立绘形象
	data.figure=Proto.parseString(entry); -- 形象
	data.dir=Proto.parseDWORD(entry); -- 朝向
	data.autoAttack=Proto.parseDWORD(entry); -- 主动出击
	data.patrol=Proto.parseVector(entry,Proto.parseDWORD); -- 巡逻路径
	data.disappear=Proto.parseDWORD(entry); -- 消失
	data.dropType=Proto.parseDWORD(entry); -- 掉落类型
	data.levelClass=Proto.parseDWORD(entry); -- 等阶
	return data;
end

function Proto.getLostTowerBossInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeLostTowerBossInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeString(msg,data.groupCode); -- 训练师代号
	Proto.writeString(msg,data.name); -- 训练师名字
	Proto.writeVector(msg,data.fightPokemons,Proto.writeDWORD); -- 战斗宠物
	Proto.writeVector(msg,data.aidPokemons,Proto.writeDWORD); -- 援助宠物
	Proto.writeString(msg,data.seniorFigure); -- 立绘形象
	Proto.writeString(msg,data.figure); -- 形象
	Proto.writeDWORD(msg,data.dir); -- 朝向
	Proto.writeDWORD(msg,data.autoAttack); -- 主动出击
	Proto.writeVector(msg,data.patrol,Proto.writeDWORD); -- 巡逻路径
	Proto.writeDWORD(msg,data.disappear); -- 消失
	Proto.writeDWORD(msg,data.dropType); -- 掉落类型
	Proto.writeDWORD(msg,data.levelClass); -- 等阶
end

function Proto.parsePOS(entry)
	local data={};
	data.x=Proto.parseDWORD(entry); -- x坐标
	data.y=Proto.parseDWORD(entry); -- y坐标
	return data;
end

function Proto.writePOS(msg,data)
	Proto.writeDWORD(msg,data.x); -- x坐标
	Proto.writeDWORD(msg,data.y); -- y坐标
end

function Proto.parseTrapInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.type=Proto.parseDWORD(entry); -- 类型
	data.value=Proto.parseDWORD(entry); -- 具体值
	return data;
end

function Proto.getTrapInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeTrapInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeDWORD(msg,data.type); -- 类型
	Proto.writeDWORD(msg,data.value); -- 具体值
end

function Proto.parseLostTowerPet(entry)
	local data={};
	data.objID=Proto.parseDWORD(entry); -- 宠物ID
	data.hp=Proto.parseDWORD(entry); -- 宠物血量
	return data;
end

function Proto.writeLostTowerPet(msg,data)
	Proto.writeDWORD(msg,data.objID); -- 宠物ID
	Proto.writeDWORD(msg,data.hp); -- 宠物血量
end

function Proto.parseRank(entry)
	local data={};
	data.charID=Proto.parseDWORD(entry); -- 用户ID
	data.value=Proto.parseDWORD(entry); -- 层数
	data.nickname=Proto.parseString(entry); -- 昵称
	data.level=Proto.parseDWORD(entry); -- 等级
	data.vipLevel=Proto.parseDWORD(entry); -- vip等级
	data.icon=Proto.parseDWORD(entry); -- icon
	data.updateTime=Proto.parseDWORD(entry); -- 更新时间
	return data;
end

function Proto.writeRank(msg,data)
	Proto.writeDWORD(msg,data.charID); -- 用户ID
	Proto.writeDWORD(msg,data.value); -- 层数
	Proto.writeString(msg,data.nickname); -- 昵称
	Proto.writeDWORD(msg,data.level); -- 等级
	Proto.writeDWORD(msg,data.vipLevel); -- vip等级
	Proto.writeDWORD(msg,data.icon); -- icon
	Proto.writeDWORD(msg,data.updateTime); -- 更新时间
end

function Proto.parseRankAwardList(entry)
	local data={};
	data.rank=Proto.parseDWORD(entry); -- 排名
	data.mailID=Proto.parseDWORD(entry); -- 邮件ID
	data.awardItems=Proto.parseVector(entry,Proto.parseDWORD); -- 奖励元素信息
	return data;
end

function Proto.writeRankAwardList(msg,data)
	Proto.writeDWORD(msg,data.rank); -- 排名
	Proto.writeDWORD(msg,data.mailID); -- 邮件ID
	Proto.writeVector(msg,data.awardItems,Proto.writeDWORD); -- 奖励元素信息
end

function Proto.parseLostTowerRankAwardInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.awardList=Proto.parseVector(entry,Proto.parseRankAwardList); -- 排行奖励详细列表
	return data;
end

function Proto.getLostTowerRankAwardInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeLostTowerRankAwardInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeVector(msg,data.awardList,Proto.writeRankAwardList); -- 排行奖励详细列表
end

function Proto.parseawardInfo(entry)
	local data={};
	data.awardID=Proto.parseDWORD(entry); -- 奖励ID
	data.rate=Proto.parseDWORD(entry); -- 概率
	return data;
end

function Proto.writeawardInfo(msg,data)
	Proto.writeDWORD(msg,data.awardID); -- 奖励ID
	Proto.writeDWORD(msg,data.rate); -- 概率
end

function Proto.parseDropList(entry)
	local data={};
	data.awardList=Proto.parseVector(entry,Proto.parseawardInfo); -- 
	return data;
end

function Proto.writeDropList(msg,data)
	Proto.writeVector(msg,data.awardList,Proto.writeawardInfo); -- 
end

function Proto.parseCollectionInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.needLevel=Proto.parseDWORD(entry); -- 需要生活职业等级
	data.beforeRes=Proto.parseString(entry); -- 采集前资源
	data.afterRes=Proto.parseString(entry); -- 采集后资源
	data.dropList=Proto.parseVector(entry,Proto.parseDropList); -- 掉落列表
	return data;
end

function Proto.getCollectionInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeCollectionInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeDWORD(msg,data.needLevel); -- 需要生活职业等级
	Proto.writeString(msg,data.beforeRes); -- 采集前资源
	Proto.writeString(msg,data.afterRes); -- 采集后资源
	Proto.writeVector(msg,data.dropList,Proto.writeDropList); -- 掉落列表
end

function Proto.parseTransferDoorInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.x=Proto.parseDWORD(entry); -- x坐标
	data.y=Proto.parseDWORD(entry); -- y坐标
	data.path=Proto.parseString(entry); -- 资源路径
	return data;
end

function Proto.getTransferDoorInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeTransferDoorInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeDWORD(msg,data.x); -- x坐标
	Proto.writeDWORD(msg,data.y); -- y坐标
	Proto.writeString(msg,data.path); -- 资源路径
end

function Proto.parseLostTowerResetInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 次数ID
	data.consume=Proto.parseDWORD(entry); -- 消耗ID
	return data;
end

function Proto.getLostTowerResetInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeLostTowerResetInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 次数ID
	Proto.writeDWORD(msg,data.consume); -- 消耗ID
end

function Proto.parseConditionList(entry)
	local data={};
	data.condition=Proto.parseDWORD(entry); -- 条件ID
	data.conditionType=Proto.parseDWORD(entry); -- 条件类型
	return data;
end

function Proto.writeConditionList(msg,data)
	Proto.writeDWORD(msg,data.condition); -- 条件ID
	Proto.writeDWORD(msg,data.conditionType); -- 条件类型
end

function Proto.parseObstacleInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.type=Proto.parseDWORD(entry); -- 类型
	data.conditionList=Proto.parseVector(entry,Proto.parseConditionList); -- 条件列表
	data.terrainRes=Proto.parseDWORD(entry); -- 地形资源
	data.clickReaction=Proto.parseString(entry); -- 点击反应
	data.path=Proto.parseString(entry); -- 图片资源
	data.flashEffect=Proto.parseString(entry); -- 动画效果
	data.desc=Proto.parseString(entry); -- 障碍物信息
	data.isGround=Proto.parseDWORD(entry); -- 是否地面
	return data;
end

function Proto.getObstacleInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeObstacleInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeDWORD(msg,data.type); -- 类型
	Proto.writeVector(msg,data.conditionList,Proto.writeConditionList); -- 条件列表
	Proto.writeDWORD(msg,data.terrainRes); -- 地形资源
	Proto.writeString(msg,data.clickReaction); -- 点击反应
	Proto.writeString(msg,data.path); -- 图片资源
	Proto.writeString(msg,data.flashEffect); -- 动画效果
	Proto.writeString(msg,data.desc); -- 障碍物信息
	Proto.writeDWORD(msg,data.isGround); -- 是否地面
end

function Proto.parsePickUpItemInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.desc=Proto.parseString(entry); -- 描述
	data.path=Proto.parseString(entry); -- 资源路径
	data.effectObj=Proto.parseDWORD(entry); -- 作用对象
	data.expressionRes=Proto.parseString(entry); -- 人物表情资源
	return data;
end

function Proto.getPickUpItemInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writePickUpItemInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeString(msg,data.desc); -- 描述
	Proto.writeString(msg,data.path); -- 资源路径
	Proto.writeDWORD(msg,data.effectObj); -- 作用对象
	Proto.writeString(msg,data.expressionRes); -- 人物表情资源
end

function Proto.parseFloorRelationInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.boss=Proto.parseDWORD(entry); -- 守关BOSS
	data.award=Proto.parseDWORD(entry); -- 奖励
	data.monster=Proto.parseDWORD(entry); -- 野生怪物
	data.activityMonster=Proto.parseDWORD(entry); -- 活动野生怪物
	data.trainer=Proto.parseDWORD(entry); -- 训练师
	data.chestList=Proto.parseVector(entry,Proto.parseDWORD); -- 随机宝箱
	data.chestRate=Proto.parseVector(entry,Proto.parseDWORD); -- 随机宝箱权重
	data.collection=Proto.parseDWORD(entry); -- 采集
	data.petLevel=Proto.parseDWORD(entry); -- 宠物等级
	data.petStage=Proto.parseDWORD(entry); -- 宠物强化等级
	data.petStar=Proto.parseDWORD(entry); -- 宠物星数
	data.normalDrop=Proto.parseVector(entry,Proto.parseDWORD); -- 普通掉落
	data.eliteDrop=Proto.parseVector(entry,Proto.parseDWORD); -- 精英掉落
	data.bossDrop=Proto.parseVector(entry,Proto.parseDWORD); -- BOSS掉落
	data.activityDrop=Proto.parseDWORD(entry); -- 活动奖励
	data.monsterExp=Proto.parseDWORD(entry); -- 怪物经验
	data.trainerExp=Proto.parseDWORD(entry); -- 训练师经验
	data.bossExp=Proto.parseDWORD(entry); -- BOSS经验
	return data;
end

function Proto.getFloorRelationInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeFloorRelationInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeDWORD(msg,data.boss); -- 守关BOSS
	Proto.writeDWORD(msg,data.award); -- 奖励
	Proto.writeDWORD(msg,data.monster); -- 野生怪物
	Proto.writeDWORD(msg,data.activityMonster); -- 活动野生怪物
	Proto.writeDWORD(msg,data.trainer); -- 训练师
	Proto.writeVector(msg,data.chestList,Proto.writeDWORD); -- 随机宝箱
	Proto.writeVector(msg,data.chestRate,Proto.writeDWORD); -- 随机宝箱权重
	Proto.writeDWORD(msg,data.collection); -- 采集
	Proto.writeDWORD(msg,data.petLevel); -- 宠物等级
	Proto.writeDWORD(msg,data.petStage); -- 宠物强化等级
	Proto.writeDWORD(msg,data.petStar); -- 宠物星数
	Proto.writeVector(msg,data.normalDrop,Proto.writeDWORD); -- 普通掉落
	Proto.writeVector(msg,data.eliteDrop,Proto.writeDWORD); -- 精英掉落
	Proto.writeVector(msg,data.bossDrop,Proto.writeDWORD); -- BOSS掉落
	Proto.writeDWORD(msg,data.activityDrop); -- 活动奖励
	Proto.writeDWORD(msg,data.monsterExp); -- 怪物经验
	Proto.writeDWORD(msg,data.trainerExp); -- 训练师经验
	Proto.writeDWORD(msg,data.bossExp); -- BOSS经验
end

function Proto.parseLostTowerMonsterManGroupInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.groupCode=Proto.parseString(entry); -- 训练师代号
	data.name=Proto.parseString(entry); -- 训练师名字
	data.fightPokemons=Proto.parseVector(entry,Proto.parseDWORD); -- 战斗宠物
	data.aidPokemons=Proto.parseVector(entry,Proto.parseDWORD); -- 援助宠物
	data.seniorFigure=Proto.parseString(entry); -- 立绘形象
	data.figure=Proto.parseString(entry); -- 形象
	data.dir=Proto.parseDWORD(entry); -- 朝向
	data.autoAttack=Proto.parseDWORD(entry); -- 主动出击
	data.patrol=Proto.parseVector(entry,Proto.parseDWORD); -- 巡逻路径
	data.commingTalk=Proto.parseString(entry); -- 训练师登场对话
	data.deadTalk=Proto.parseString(entry); -- 训练师失败对话
	data.disappear=Proto.parseDWORD(entry); -- 消失
	data.additionalDrop=Proto.parseVector(entry,Proto.parseDWORD); -- 掉落类型
	data.dropID=Proto.parseDWORD(entry); -- 掉落ID
	data.levelClass=Proto.parseDWORD(entry); -- 等阶
	return data;
end

function Proto.getLostTowerMonsterManGroupInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeLostTowerMonsterManGroupInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeString(msg,data.groupCode); -- 训练师代号
	Proto.writeString(msg,data.name); -- 训练师名字
	Proto.writeVector(msg,data.fightPokemons,Proto.writeDWORD); -- 战斗宠物
	Proto.writeVector(msg,data.aidPokemons,Proto.writeDWORD); -- 援助宠物
	Proto.writeString(msg,data.seniorFigure); -- 立绘形象
	Proto.writeString(msg,data.figure); -- 形象
	Proto.writeDWORD(msg,data.dir); -- 朝向
	Proto.writeDWORD(msg,data.autoAttack); -- 主动出击
	Proto.writeVector(msg,data.patrol,Proto.writeDWORD); -- 巡逻路径
	Proto.writeString(msg,data.commingTalk); -- 训练师登场对话
	Proto.writeString(msg,data.deadTalk); -- 训练师失败对话
	Proto.writeDWORD(msg,data.disappear); -- 消失
	Proto.writeVector(msg,data.additionalDrop,Proto.writeDWORD); -- 掉落类型
	Proto.writeDWORD(msg,data.dropID); -- 掉落ID
	Proto.writeDWORD(msg,data.levelClass); -- 等阶
end

function Proto.parseLostTowerMonsterInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.number=Proto.parseString(entry); -- 怪物编号
	data.petnumber=Proto.parseDWORD(entry); -- 宠物编号
	data.amendmentHP=Proto.parseDWORD(entry); -- HP修正比例
	data.amendmentSPD=Proto.parseDWORD(entry); -- SPD修正比例
	data.amendmentATK=Proto.parseDWORD(entry); -- ATK修正比例
	data.amendmentDEF=Proto.parseDWORD(entry); -- DEF修正比例
	data.amendmentSATK=Proto.parseDWORD(entry); -- SATK修正比例
	data.amendmentSDEF=Proto.parseDWORD(entry); -- SDEF修正比例
	data.dropnumber=Proto.parseDWORD(entry); -- 掉落编号
	data.skill1=Proto.parseVector(entry,Proto.parseDWORD); -- 怪物技能1
	data.skill2=Proto.parseVector(entry,Proto.parseDWORD); -- 怪物技能2
	data.skill3=Proto.parseVector(entry,Proto.parseDWORD); -- 怪物技能3
	data.skill4=Proto.parseDWORD(entry); -- 怪物技能4
	data.skill1_pro=Proto.parseDWORD(entry); -- 怪物技能1发动概率
	data.skill2_pro=Proto.parseDWORD(entry); -- 怪物技能2发动概率
	data.skill3_pro=Proto.parseDWORD(entry); -- 怪物技能3发动概率
	data.skill4_pro=Proto.parseDWORD(entry); -- 怪物技能4发动概率
	data.catchRate=Proto.parseDWORD(entry); -- 捕获率
	data.away=Proto.parseDWORD(entry); -- 逃跑率
	data.capture=Proto.parseDWORD(entry); -- 最大捕获机会
	data.paSkills=Proto.parseVector(entry,Proto.parseDWORD); -- 被动技能
	data.petGeneID=Proto.parseDWORD(entry); -- 宠物生成ID
	data.specialState=Proto.parseDWORD(entry); -- 特殊形态
	return data;
end

function Proto.getLostTowerMonsterInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeLostTowerMonsterInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeString(msg,data.number); -- 怪物编号
	Proto.writeDWORD(msg,data.petnumber); -- 宠物编号
	Proto.writeDWORD(msg,data.amendmentHP); -- HP修正比例
	Proto.writeDWORD(msg,data.amendmentSPD); -- SPD修正比例
	Proto.writeDWORD(msg,data.amendmentATK); -- ATK修正比例
	Proto.writeDWORD(msg,data.amendmentDEF); -- DEF修正比例
	Proto.writeDWORD(msg,data.amendmentSATK); -- SATK修正比例
	Proto.writeDWORD(msg,data.amendmentSDEF); -- SDEF修正比例
	Proto.writeDWORD(msg,data.dropnumber); -- 掉落编号
	Proto.writeVector(msg,data.skill1,Proto.writeDWORD); -- 怪物技能1
	Proto.writeVector(msg,data.skill2,Proto.writeDWORD); -- 怪物技能2
	Proto.writeVector(msg,data.skill3,Proto.writeDWORD); -- 怪物技能3
	Proto.writeDWORD(msg,data.skill4); -- 怪物技能4
	Proto.writeDWORD(msg,data.skill1_pro); -- 怪物技能1发动概率
	Proto.writeDWORD(msg,data.skill2_pro); -- 怪物技能2发动概率
	Proto.writeDWORD(msg,data.skill3_pro); -- 怪物技能3发动概率
	Proto.writeDWORD(msg,data.skill4_pro); -- 怪物技能4发动概率
	Proto.writeDWORD(msg,data.catchRate); -- 捕获率
	Proto.writeDWORD(msg,data.away); -- 逃跑率
	Proto.writeDWORD(msg,data.capture); -- 最大捕获机会
	Proto.writeVector(msg,data.paSkills,Proto.writeDWORD); -- 被动技能
	Proto.writeDWORD(msg,data.petGeneID); -- 宠物生成ID
	Proto.writeDWORD(msg,data.specialState); -- 特殊形态
end

function Proto.parseMonsterList(entry)
	local data={};
	data.monsterID=Proto.parseDWORD(entry); -- 怪物ID
	data.rate=Proto.parseDWORD(entry); -- 概率
	return data;
end

function Proto.writeMonsterList(msg,data)
	Proto.writeDWORD(msg,data.monsterID); -- 怪物ID
	Proto.writeDWORD(msg,data.rate); -- 概率
end

function Proto.parseLostTowerMonsterRandomInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.monsterList=Proto.parseVector(entry,Proto.parseMonsterList); -- 怪物随机列表
	return data;
end

function Proto.getLostTowerMonsterRandomInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeLostTowerMonsterRandomInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeVector(msg,data.monsterList,Proto.writeMonsterList); -- 怪物随机列表
end

function Proto.parseDropDetail(entry)
	local data={};
	data.itemID=Proto.parseDWORD(entry); -- 道具ID
	data.count=Proto.parseDWORD(entry); -- 道具个数
	data.rate=Proto.parseDWORD(entry); -- 概率
	return data;
end

function Proto.writeDropDetail(msg,data)
	Proto.writeDWORD(msg,data.itemID); -- 道具ID
	Proto.writeDWORD(msg,data.count); -- 道具个数
	Proto.writeDWORD(msg,data.rate); -- 概率
end

function Proto.parseLostTowerDropInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.dropList=Proto.parseVector(entry,Proto.parseDropDetail); -- 掉落列表
	return data;
end

function Proto.getLostTowerDropInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeLostTowerDropInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeVector(msg,data.dropList,Proto.writeDropDetail); -- 掉落列表
end

function Proto.parseCharacterLostTowerData(entry)
	local data={};
	data.stepNumber=Proto.parseDWORD(entry); -- 步数
	data.maxFloor=Proto.parseDWORD(entry); -- 最高层数
	data.weekMaxFloor=Proto.parseDWORD(entry); -- 周最高层
	data.weekMaxPoint=Proto.parseDWORD(entry); -- 周最高积分
	data.currentFloor=Proto.parseDWORD(entry); -- 当前层数
	data.points=Proto.parseDWORD(entry); -- 积分
	data.recordingPoint=Proto.parseDWORD(entry); -- 记录点
	data.recoverCount=Proto.parseDWORD(entry); -- 恢复次数
	data.lastTransferTime=Proto.parseDWORD(entry); -- 最后传送时间
	data.resetCount=Proto.parseDWORD(entry); -- 重置次数
	data.resetTime=Proto.parseDWORD(entry); -- 重置时间
	data.lastUpdateStepNumberTime=Proto.parseDWORD(entry); -- 最后更新步数时间
	data.movedCell=Proto.parseVector(entry,Proto.parseString); -- 移动过的格子
	data.position=Proto.parseString(entry); -- 位置信息
	data.pets=Proto.parseVector(entry,Proto.parseString); -- 宠物列表
	data.activityArmys=Proto.parseVector(entry,Proto.parseDWORD); -- 战斗宠物
	data.activityHelpArmys=Proto.parseVector(entry,Proto.parseDWORD); -- 援助宠物
	data.firedEventCell=Proto.parseVector(entry,Proto.parseString); -- 已触发事件过的格子
	data.pickupItems=Proto.parseVector(entry,Proto.parseString); -- 千层塔道具
	data.buff=Proto.parseVector(entry,Proto.parseString); -- buff
	data.eventNum=Proto.parseDWORD(entry); -- 格子个数
	return data;
end

function Proto.writeCharacterLostTowerData(msg,data)
	Proto.writeDWORD(msg,data.stepNumber); -- 步数
	Proto.writeDWORD(msg,data.maxFloor); -- 最高层数
	Proto.writeDWORD(msg,data.weekMaxFloor); -- 周最高层
	Proto.writeDWORD(msg,data.weekMaxPoint); -- 周最高积分
	Proto.writeDWORD(msg,data.currentFloor); -- 当前层数
	Proto.writeDWORD(msg,data.points); -- 积分
	Proto.writeDWORD(msg,data.recordingPoint); -- 记录点
	Proto.writeDWORD(msg,data.recoverCount); -- 恢复次数
	Proto.writeDWORD(msg,data.lastTransferTime); -- 最后传送时间
	Proto.writeDWORD(msg,data.resetCount); -- 重置次数
	Proto.writeDWORD(msg,data.resetTime); -- 重置时间
	Proto.writeDWORD(msg,data.lastUpdateStepNumberTime); -- 最后更新步数时间
	Proto.writeVector(msg,data.movedCell,Proto.writeString); -- 移动过的格子
	Proto.writeString(msg,data.position); -- 位置信息
	Proto.writeVector(msg,data.pets,Proto.writeString); -- 宠物列表
	Proto.writeVector(msg,data.activityArmys,Proto.writeDWORD); -- 战斗宠物
	Proto.writeVector(msg,data.activityHelpArmys,Proto.writeDWORD); -- 援助宠物
	Proto.writeVector(msg,data.firedEventCell,Proto.writeString); -- 已触发事件过的格子
	Proto.writeVector(msg,data.pickupItems,Proto.writeString); -- 千层塔道具
	Proto.writeVector(msg,data.buff,Proto.writeString); -- buff
	Proto.writeDWORD(msg,data.eventNum); -- 格子个数
end

function Proto.parseLostTowerArenaData(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 玩家ID
	data.teamID=Proto.parseDWORD(entry); -- 队伍ID
	data.fightPoint=Proto.parseDWORD(entry); -- 战斗力
	return data;
end

function Proto.getLostTowerArenaDataIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeLostTowerArenaData(msg,data)
	Proto.writeDWORD(msg,data.id); -- 玩家ID
	Proto.writeDWORD(msg,data.teamID); -- 队伍ID
	Proto.writeDWORD(msg,data.fightPoint); -- 战斗力
end

function Proto.parseEmptyEventInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.type=Proto.parseDWORD(entry); -- 类型
	data.animationEffects=Proto.parseString(entry); -- 动画效果
	data.terrainRes=Proto.parseString(entry); -- 地形资源
	data.isGround=Proto.parseDWORD(entry); -- 代替地砖
	data.backup=Proto.parseString(entry); -- 补充
	return data;
end

function Proto.getEmptyEventInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeEmptyEventInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeDWORD(msg,data.type); -- 类型
	Proto.writeString(msg,data.animationEffects); -- 动画效果
	Proto.writeString(msg,data.terrainRes); -- 地形资源
	Proto.writeDWORD(msg,data.isGround); -- 代替地砖
	Proto.writeString(msg,data.backup); -- 补充
end

