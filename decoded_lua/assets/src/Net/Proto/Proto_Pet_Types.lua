-- Net.Proto.Proto_Pet_Types

Proto.ATTR_NONE		= 0						-- [宠物属性信息]无
Proto.ATTR_COMMON	= Proto.ATTR_NONE + 1	-- [宠物属性信息]一般
Proto.ATTR_FIGHT	= Proto.ATTR_COMMON + 1	-- [宠物属性信息]格斗
Proto.ATTR_WIND		= Proto.ATTR_FIGHT + 1	-- [宠物属性信息]风
Proto.ATTR_DRUG		= Proto.ATTR_WIND + 1	-- [宠物属性信息]毒
Proto.ATTR_LAND		= Proto.ATTR_DRUG + 1	-- [宠物属性信息]地
Proto.ATTR_ROCK		= Proto.ATTR_LAND + 1	-- [宠物属性信息]岩
Proto.ATTR_WORM		= Proto.ATTR_ROCK + 1	-- [宠物属性信息]虫
Proto.ATTR_GHOST	= Proto.ATTR_WORM + 1	-- [宠物属性信息]幽灵
Proto.ATTR_STEEL	= Proto.ATTR_GHOST + 1	-- [宠物属性信息]钢
Proto.ATTR_FIRE		= Proto.ATTR_STEEL + 1	-- [宠物属性信息]火
Proto.ATTR_WATER	= Proto.ATTR_FIRE + 1	-- [宠物属性信息]水
Proto.ATTR_GRASS	= Proto.ATTR_WATER + 1	-- [宠物属性信息]草
Proto.ATTR_ELEC		= Proto.ATTR_GRASS + 1	-- [宠物属性信息]电
Proto.ATTR_SUPER	= Proto.ATTR_ELEC + 1	-- [宠物属性信息]超能
Proto.ATTR_ICE		= Proto.ATTR_SUPER + 1	-- [宠物属性信息]冰
Proto.ATTR_DRAGON	= Proto.ATTR_ICE + 1	-- [宠物属性信息]龙
Proto.ATTR_EVIL		= Proto.ATTR_DRAGON + 1	-- [宠物属性信息]恶
Proto.ATTR_GOBLIN	= Proto.ATTR_EVIL + 1	-- [宠物属性信息]妖精
Proto.SKILLRARITY_C		= 0							-- []C级技能
Proto.SKILLRARITY_B		= Proto.SKILLRARITY_C + 1	-- []B级技能
Proto.SKILLRARITY_A		= Proto.SKILLRARITY_B + 1	-- []A级技能
Proto.SKILLRARITY_S		= Proto.SKILLRARITY_A + 1	-- []S级技能
Proto.SKILLRARITY_SR	= Proto.SKILLRARITY_S + 1	-- []SR级技能
Proto.SKILLRARITY_SSR	= Proto.SKILLRARITY_SR + 1	-- []SSR级技能
Proto.eST_Normal	= 0							-- []主动
Proto.eST_Profound	= Proto.eST_Normal + 1		-- []奥义
Proto.eST_Feature	= Proto.eST_Profound + 1	-- []特性
Proto.eST_Physics	= Proto.eST_Feature + 1		-- []物理
Proto.eST_Special	= Proto.eST_Physics + 1		-- []魔法
Proto.eST_Variety	= Proto.eST_Special + 1		-- []变化
Proto.eST_Passive	= Proto.eST_Variety + 1		-- []被动
Proto.eST_Assist	= Proto.eST_Passive + 1		-- []援助
Proto.eST_Genius	= Proto.eST_Assist + 1		-- []天赋
Proto.eST_ChangePet	= Proto.eST_Genius + 1		-- []换宠
Proto.eST_Num		= Proto.eST_ChangePet + 1	-- []数量(计算用)
Proto.eDT_None			= 0								-- []
Proto.eDT_PhysicsDamage	= Proto.eDT_None + 1			-- []物理伤害
Proto.eST_MagicDamage	= Proto.eDT_PhysicsDamage + 1	-- []魔法伤害
Proto.HELPER_PASSIVE_SKILL	= 0									-- []援助
Proto.B_PASSIVE_SKILL		= Proto.HELPER_PASSIVE_SKILL + 1	-- []B级
Proto.A_PASSIVE_SKILL		= Proto.B_PASSIVE_SKILL + 1			-- []A级
Proto.S_PASSIVE_SKILL		= Proto.A_PASSIVE_SKILL + 1			-- []S级
Proto.ePRT_D	= 0					-- []D级宠物
Proto.ePRT_C	= Proto.ePRT_D + 1	-- []C级宠物
Proto.ePRT_B	= Proto.ePRT_C + 1	-- []B级宠物
Proto.ePRT_A	= Proto.ePRT_B + 1	-- []A级宠物
Proto.ePRT_S	= Proto.ePRT_A + 1	-- []S级宠物
Proto.ePRT_SS	= Proto.ePRT_S + 1	-- []SS级宠物
Proto.ePRT_SSS	= Proto.ePRT_SS + 1	-- []SSS级宠物
Proto.ePUT_Fight	= 0						-- [宠物用途类型]出战
Proto.ePUT_Material	= Proto.ePUT_Fight + 1	-- [宠物用途类型]材料

function Proto.parseSkinInfo(entry)
	local data={};
	data.attribType=Proto.parseBYTE(entry); -- 影响的属性名枚举
	data.attribValue=Proto.parseDWORD(entry); -- 影响的属性值
	data.rate=Proto.parseDWORD(entry); -- 形态出现的概率
	return data;
end

function Proto.writeSkinInfo(msg,data)
	Proto.writeBYTE(msg,data.attribType); -- 影响的属性名枚举
	Proto.writeDWORD(msg,data.attribValue); -- 影响的属性值
	Proto.writeDWORD(msg,data.rate); -- 形态出现的概率
end

function Proto.parsePokemonInfo(entry)
	local data={};
	data.id=Proto.parsePetID(entry); -- 宠物ID
	data.name=Proto.parseLifeNick(entry); -- 宠物昵称
	data.useType=Proto.parseDWORD(entry); -- 宠物类型(用途)
	data.sexRate=Proto.parseDWORD(entry); -- 宠物性别率
	data.fightSkin=Proto.parseString(entry); -- 宠物战斗皮肤
	data.icon=Proto.parseString(entry); -- 宠物头像
	data.rarePoint=Proto.parseDWORD(entry); -- 宠物稀有度
	data.elementAtt1=Proto.parseDWORD(entry); -- 宠物元素属性1
	data.elementAtt2=Proto.parseDWORD(entry); -- 宠物元素属性2
	data.desc=Proto.parseString(entry); -- 宠物描述
	data.petWay=Proto.parseString(entry); -- 宠物足迹
	data.lifeRateValue=Proto.parseDWORD(entry); -- 生命种族值
	data.atkRateValue=Proto.parseDWORD(entry); -- 物攻种族值
	data.defRateValue=Proto.parseDWORD(entry); -- 物防种族值
	data.satkRateValue=Proto.parseDWORD(entry); -- 特攻种族值
	data.sdefRateValue=Proto.parseDWORD(entry); -- 特防种族值
	data.speedRateValue=Proto.parseDWORD(entry); -- 速度种族值
	data.yokeVec=Proto.parseVector(entry,Proto.parseWORD); -- 羁绊
	data.topLevel=Proto.parseWORD(entry); -- 最高等级
	data.skins=Proto.parseVector(entry,Proto.parseSkinInfo); -- 形态组
	data.gainParam=Proto.parseDWORD(entry); -- 获取参数
	data.eatCost=Proto.parseDWORD(entry); -- 吞噬消耗
	return data;
end

function Proto.getPokemonInfoIDLen()
	return Proto.getPetIDLen();
end

function Proto.writePokemonInfo(msg,data)
	Proto.writePetID(msg,data.id); -- 宠物ID
	Proto.writeLifeNick(msg,data.name); -- 宠物昵称
	Proto.writeDWORD(msg,data.useType); -- 宠物类型(用途)
	Proto.writeDWORD(msg,data.sexRate); -- 宠物性别率
	Proto.writeString(msg,data.fightSkin); -- 宠物战斗皮肤
	Proto.writeString(msg,data.icon); -- 宠物头像
	Proto.writeDWORD(msg,data.rarePoint); -- 宠物稀有度
	Proto.writeDWORD(msg,data.elementAtt1); -- 宠物元素属性1
	Proto.writeDWORD(msg,data.elementAtt2); -- 宠物元素属性2
	Proto.writeString(msg,data.desc); -- 宠物描述
	Proto.writeString(msg,data.petWay); -- 宠物足迹
	Proto.writeDWORD(msg,data.lifeRateValue); -- 生命种族值
	Proto.writeDWORD(msg,data.atkRateValue); -- 物攻种族值
	Proto.writeDWORD(msg,data.defRateValue); -- 物防种族值
	Proto.writeDWORD(msg,data.satkRateValue); -- 特攻种族值
	Proto.writeDWORD(msg,data.sdefRateValue); -- 特防种族值
	Proto.writeDWORD(msg,data.speedRateValue); -- 速度种族值
	Proto.writeVector(msg,data.yokeVec,Proto.writeWORD); -- 羁绊
	Proto.writeWORD(msg,data.topLevel); -- 最高等级
	Proto.writeVector(msg,data.skins,Proto.writeSkinInfo); -- 形态组
	Proto.writeDWORD(msg,data.gainParam); -- 获取参数
	Proto.writeDWORD(msg,data.eatCost); -- 吞噬消耗
end

function Proto.parsePetSkillInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.name=Proto.parseString(entry); -- 技能名称
	data.skillAtt=Proto.parseDWORD(entry); -- 技能属性
	data.skill_A_Type=Proto.parseDWORD(entry); -- 技能类型
	data.skill_B_Type=Proto.parseDWORD(entry); -- 技能分类
	data.skillPresupposed=Proto.parseDWORD(entry); -- 技能预设
	data.skillAllTime=Proto.parseDWORD(entry); -- 技能总时间
	data.power=Proto.parseDWORD(entry); -- 技能威力
	data.airpower=Proto.parseDWORD(entry); -- 技能威力
	data.groundpower=Proto.parseDWORD(entry); -- 技能威力
	data.hitRate=Proto.parseDWORD(entry); -- 技能命中率
	data.pp=Proto.parseDWORD(entry); -- PP
	data.energy=Proto.parseDWORD(entry); -- 奥义能量
	data.speed=Proto.parseDWORD(entry); -- 指令速度
	data.icon=Proto.parseString(entry); -- 技能图标
	data.preinstall=Proto.parseString(entry); -- 技能预设
	data.effect=Proto.parseString(entry); -- 技能效果
	data.parameterA=Proto.parseDWORD(entry); -- 技能参数A
	data.parameterB=Proto.parseDWORD(entry); -- 技能参数B
	data.parameterC=Proto.parseDWORD(entry); -- 技能参数C
	data.parameterD=Proto.parseDWORD(entry); -- 技能参数D
	data.parameterE=Proto.parseDWORD(entry); -- 技能参数E
	data.desc=Proto.parseString(entry); -- 技能描述
	data.upItemType=Proto.parseDWORD(entry); -- 升级道具
	data.triggerTypes=Proto.parseString(entry); -- 触发时机
	return data;
end

function Proto.getPetSkillInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writePetSkillInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeString(msg,data.name); -- 技能名称
	Proto.writeDWORD(msg,data.skillAtt); -- 技能属性
	Proto.writeDWORD(msg,data.skill_A_Type); -- 技能类型
	Proto.writeDWORD(msg,data.skill_B_Type); -- 技能分类
	Proto.writeDWORD(msg,data.skillPresupposed); -- 技能预设
	Proto.writeDWORD(msg,data.skillAllTime); -- 技能总时间
	Proto.writeDWORD(msg,data.power); -- 技能威力
	Proto.writeDWORD(msg,data.airpower); -- 技能威力
	Proto.writeDWORD(msg,data.groundpower); -- 技能威力
	Proto.writeDWORD(msg,data.hitRate); -- 技能命中率
	Proto.writeDWORD(msg,data.pp); -- PP
	Proto.writeDWORD(msg,data.energy); -- 奥义能量
	Proto.writeDWORD(msg,data.speed); -- 指令速度
	Proto.writeString(msg,data.icon); -- 技能图标
	Proto.writeString(msg,data.preinstall); -- 技能预设
	Proto.writeString(msg,data.effect); -- 技能效果
	Proto.writeDWORD(msg,data.parameterA); -- 技能参数A
	Proto.writeDWORD(msg,data.parameterB); -- 技能参数B
	Proto.writeDWORD(msg,data.parameterC); -- 技能参数C
	Proto.writeDWORD(msg,data.parameterD); -- 技能参数D
	Proto.writeDWORD(msg,data.parameterE); -- 技能参数E
	Proto.writeString(msg,data.desc); -- 技能描述
	Proto.writeDWORD(msg,data.upItemType); -- 升级道具
	Proto.writeString(msg,data.triggerTypes); -- 触发时机
end

function Proto.parsePetBufferInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.name=Proto.parseString(entry); -- 名称
	data.desc=Proto.parseString(entry); -- 效果描述
	data.icon=Proto.parseString(entry); -- 状态图标
	data.animation=Proto.parseString(entry); -- 状态动画
	data.onlyType=Proto.parseDWORD(entry); -- 唯一性
	data.changePetClear=Proto.parseDWORD(entry); -- 换宠解除
	data.canMultiply=Proto.parseDWORD(entry); -- 是否叠加
	data.effect=Proto.parseString(entry); -- 具体效果
	data.endEffect=Proto.parseString(entry); -- 结束效果
	data.triggerType=Proto.parseString(entry); -- 触发时机
	return data;
end

function Proto.getPetBufferInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writePetBufferInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeString(msg,data.name); -- 名称
	Proto.writeString(msg,data.desc); -- 效果描述
	Proto.writeString(msg,data.icon); -- 状态图标
	Proto.writeString(msg,data.animation); -- 状态动画
	Proto.writeDWORD(msg,data.onlyType); -- 唯一性
	Proto.writeDWORD(msg,data.changePetClear); -- 换宠解除
	Proto.writeDWORD(msg,data.canMultiply); -- 是否叠加
	Proto.writeString(msg,data.effect); -- 具体效果
	Proto.writeString(msg,data.endEffect); -- 结束效果
	Proto.writeString(msg,data.triggerType); -- 触发时机
end

function Proto.parseWeatherInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.name=Proto.parseString(entry); -- ID
	data.desc=Proto.parseString(entry); -- ID
	data.params=Proto.parseVector(entry,Proto.parseDWORD); -- 参数
	return data;
end

function Proto.getWeatherInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeWeatherInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeString(msg,data.name); -- ID
	Proto.writeString(msg,data.desc); -- ID
	Proto.writeVector(msg,data.params,Proto.writeDWORD); -- 参数
end

function Proto.parsePetDescription(entry)
	local data={};
	data.id=Proto.parsePetID(entry); -- 宠物ID
	data.name=Proto.parseLifeNick(entry); -- 宠物昵称
	data.gender=Proto.parseBYTE(entry); -- 性别
	data.natureGene=Proto.parseUnitNatureGene(entry); -- 遗传天性
	data.level=Proto.parseWORD(entry); -- 等级
	data.experience=Proto.parseDWORD(entry); -- 经验值
	data.remainingAttribute=Proto.parseWORD(entry); -- 可分配属性
	data.raceType=Proto.parseDWORD(entry); -- 动物类型
	data.selfAttrib=Proto.parseBYTE(entry); -- 个体值
	data.struggles=Proto.parseStruggles(entry); -- 努力值
	data.assignPoints=Proto.parseAssignPoints(entry); -- 分配值
	data.turnTimes=Proto.parseBYTE(entry); -- 转生值
	data.preRace=Proto.parseDWORD(entry); -- 转生前种族
	data.turnLevel=Proto.parseDWORD(entry); -- 转生累计等级
	data.turnExp=Proto.parseDWORD(entry); -- 转生累计经验
	data.growth=Proto.parseDWORD(entry); -- 发育度
	data.fatigue=Proto.parseWORD(entry); -- 饥饿度
	data.fatigueUpdateTime=Proto.parseTIME_SEC(entry); -- 饥饿度更新时间
	data.hp=Proto.parseDWORD(entry); -- HP值
	data.sp=Proto.parseDWORD(entry); -- SP值
	data.hasFoodState=Proto.parseBYTE(entry); -- 是否有食物临时增益状态
	if (data.hasFoodState ~=0) then
		data.foodID=Proto.parseDWORD(entry); -- 临时增益食物ID
	end
	data.residualGrowth=Proto.parseDWORD(entry); -- 可转换成长度
	data.lastGrowthExchangeTime=Proto.parseTIME_SEC(entry); -- 上次转换成长度时间
	data.health=Proto.parseDWORD(entry); -- 健康度
	data.power=Proto.parseDWORD(entry); -- 战斗力
	return data;
end

function Proto.getPetDescriptionIDLen()
	return Proto.getPetIDLen();
end

function Proto.writePetDescription(msg,data)
	Proto.writePetID(msg,data.id); -- 宠物ID
	Proto.writeLifeNick(msg,data.name); -- 宠物昵称
	Proto.writeBYTE(msg,data.gender); -- 性别
	Proto.writeUnitNatureGene(msg,data.natureGene); -- 遗传天性
	Proto.writeWORD(msg,data.level); -- 等级
	Proto.writeDWORD(msg,data.experience); -- 经验值
	Proto.writeWORD(msg,data.remainingAttribute); -- 可分配属性
	Proto.writeDWORD(msg,data.raceType); -- 动物类型
	Proto.writeBYTE(msg,data.selfAttrib); -- 个体值
	Proto.writeStruggles(msg,data.struggles); -- 努力值
	Proto.writeAssignPoints(msg,data.assignPoints); -- 分配值
	Proto.writeBYTE(msg,data.turnTimes); -- 转生值
	Proto.writeDWORD(msg,data.preRace); -- 转生前种族
	Proto.writeDWORD(msg,data.turnLevel); -- 转生累计等级
	Proto.writeDWORD(msg,data.turnExp); -- 转生累计经验
	Proto.writeDWORD(msg,data.growth); -- 发育度
	Proto.writeWORD(msg,data.fatigue); -- 饥饿度
	Proto.writeTIME_SEC(msg,data.fatigueUpdateTime); -- 饥饿度更新时间
	Proto.writeDWORD(msg,data.hp); -- HP值
	Proto.writeDWORD(msg,data.sp); -- SP值
	Proto.writeBYTE(msg,data.hasFoodState); -- 是否有食物临时增益状态
	if (data.hasFoodState ~=0) then
		Proto.writeDWORD(msg,data.foodID); -- 临时增益食物ID
	end
	Proto.writeDWORD(msg,data.residualGrowth); -- 可转换成长度
	Proto.writeTIME_SEC(msg,data.lastGrowthExchangeTime); -- 上次转换成长度时间
	Proto.writeDWORD(msg,data.health); -- 健康度
	Proto.writeDWORD(msg,data.power); -- 战斗力
end

function Proto.parsePetBagDescription(entry)
	local data={};
	data.canRename=Proto.parseBYTE(entry); -- 能否更名
	data.procreateCount=Proto.parseBYTE(entry); -- 已生育次数
	data.forbidProcreate=Proto.parseBYTE(entry); -- 是否杂交
	data.father=Proto.parseDWORD(entry); -- 老爸
	data.mother=Proto.parseDWORD(entry); -- 老妈
	return data;
end

function Proto.writePetBagDescription(msg,data)
	Proto.writeBYTE(msg,data.canRename); -- 能否更名
	Proto.writeBYTE(msg,data.procreateCount); -- 已生育次数
	Proto.writeBYTE(msg,data.forbidProcreate); -- 是否杂交
	Proto.writeDWORD(msg,data.father); -- 老爸
	Proto.writeDWORD(msg,data.mother); -- 老妈
end

function Proto.parseAllelePosProbability(entry)
	local data={};
	data.pos=Proto.parseWORD(entry); -- 基因位置
	data.probID_a=Proto.parseDWORD(entry); -- 基因概率组编号
	data.probID_b=Proto.parseDWORD(entry); -- 基因概率组编号
	return data;
end

function Proto.writeAllelePosProbability(msg,data)
	Proto.writeWORD(msg,data.pos); -- 基因位置
	Proto.writeDWORD(msg,data.probID_a); -- 基因概率组编号
	Proto.writeDWORD(msg,data.probID_b); -- 基因概率组编号
end

function Proto.parseAllelePosInfo(entry)
	local data={};
	data.pos=Proto.parseWORD(entry); -- 基因位置
	data.probID_a=Proto.parseDWORD(entry); -- 基因概率组编号
	data.probID_b=Proto.parseDWORD(entry); -- 基因概率组编号
	data.itemID=Proto.parseDWORD(entry); -- 激活使用道具
	return data;
end

function Proto.writeAllelePosInfo(msg,data)
	Proto.writeWORD(msg,data.pos); -- 基因位置
	Proto.writeDWORD(msg,data.probID_a); -- 基因概率组编号
	Proto.writeDWORD(msg,data.probID_b); -- 基因概率组编号
	Proto.writeDWORD(msg,data.itemID); -- 激活使用道具
end

function Proto.parseEvolveRace(entry)
	local data={};
	data.race=Proto.parseDWORD(entry); -- 宠物种族
	data.growth=Proto.parseDWORD(entry); -- 所需发育度
	data.level=Proto.parseWORD(entry); -- 所需等级
	data.genders=Proto.parseVector(entry,Proto.parseBYTE); -- 有效性别
	data.genePos=Proto.parseVector(entry,Proto.parseWORD); -- 保留的天性位置
	data.keepGender=Proto.parseBYTE(entry); -- 是否保留性别
	return data;
end

function Proto.writeEvolveRace(msg,data)
	Proto.writeDWORD(msg,data.race); -- 宠物种族
	Proto.writeDWORD(msg,data.growth); -- 所需发育度
	Proto.writeWORD(msg,data.level); -- 所需等级
	Proto.writeVector(msg,data.genders,Proto.writeBYTE); -- 有效性别
	Proto.writeVector(msg,data.genePos,Proto.writeWORD); -- 保留的天性位置
	Proto.writeBYTE(msg,data.keepGender); -- 是否保留性别
end

function Proto.parseRaceProbability(entry)
	local data={};
	data.raceID=Proto.parseDWORD(entry); -- 种族编号
	data.prob=Proto.parseDWORD(entry); -- 概率(千万分之一)
	return data;
end

function Proto.writeRaceProbability(msg,data)
	Proto.writeDWORD(msg,data.raceID); -- 种族编号
	Proto.writeDWORD(msg,data.prob); -- 概率(千万分之一)
end

function Proto.parsePetRaceEvolutionInfo(entry)
	local data={};
	data.prob=Proto.parseDWORD(entry); -- 概率(千万分之一)
	data.race=Proto.parseDWORD(entry); -- 目标宠物种族
	data.fightID=Proto.parseDWORD(entry); -- 进化战对手组ID
	data.isForceLevel=Proto.parseBYTE(entry); -- 是否强制等级
	if (data.isForceLevel ~=0) then
		data.level=Proto.parseWORD(entry); -- 强制等级
	end
	data.addSelfAttr=Proto.parseBYTE(entry); -- 进化增加潜能点
	data.generateGenes=Proto.parseVector(entry,Proto.parseAllelePosProbability); -- 特别生成的基因
	return data;
end

function Proto.writePetRaceEvolutionInfo(msg,data)
	Proto.writeDWORD(msg,data.prob); -- 概率(千万分之一)
	Proto.writeDWORD(msg,data.race); -- 目标宠物种族
	Proto.writeDWORD(msg,data.fightID); -- 进化战对手组ID
	Proto.writeBYTE(msg,data.isForceLevel); -- 是否强制等级
	if (data.isForceLevel ~=0) then
		Proto.writeWORD(msg,data.level); -- 强制等级
	end
	Proto.writeBYTE(msg,data.addSelfAttr); -- 进化增加潜能点
	Proto.writeVector(msg,data.generateGenes,Proto.writeAllelePosProbability); -- 特别生成的基因
end

function Proto.parsePetRaceEvolution(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 进化规则ID
	data.sourcePet=Proto.parseEvolveRace(entry); -- 来源宠物种族
	data.hasConsumeItem=Proto.parseBYTE(entry); -- 是否消耗道具
	if (data.hasConsumeItem ~=0) then
		data.item_type=Proto.parseDWORD(entry); -- 所需道具类型
		data.item_count=Proto.parseDWORD(entry); -- 所需道具数量
	end
	data.sacrificePets=Proto.parseVector(entry,Proto.parseEvolveRace); -- 牺牲宠物
	data.races=Proto.parseVector(entry,Proto.parsePetRaceEvolutionInfo); -- 进化目标
	return data;
end

function Proto.getPetRaceEvolutionIDLen()
	return Proto.getDWORDLen();
end

function Proto.writePetRaceEvolution(msg,data)
	Proto.writeDWORD(msg,data.id); -- 进化规则ID
	Proto.writeEvolveRace(msg,data.sourcePet); -- 来源宠物种族
	Proto.writeBYTE(msg,data.hasConsumeItem); -- 是否消耗道具
	if (data.hasConsumeItem ~=0) then
		Proto.writeDWORD(msg,data.item_type); -- 所需道具类型
		Proto.writeDWORD(msg,data.item_count); -- 所需道具数量
	end
	Proto.writeVector(msg,data.sacrificePets,Proto.writeEvolveRace); -- 牺牲宠物
	Proto.writeVector(msg,data.races,Proto.writePetRaceEvolutionInfo); -- 进化目标
end

function Proto.parsePetRaceSuperEvolution(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 进化规则ID
	data.sourcePet=Proto.parseEvolveRace(entry); -- 来源宠物种族
	data.hasConsumeItem=Proto.parseBYTE(entry); -- 是否消耗道具
	if (data.hasConsumeItem ~=0) then
		data.item_type=Proto.parseDWORD(entry); -- 所需道具类型
		data.item_count=Proto.parseDWORD(entry); -- 所需道具数量
	end
	data.sacrificePets=Proto.parseVector(entry,Proto.parseEvolveRace); -- 牺牲宠物
	data.races=Proto.parseVector(entry,Proto.parsePetRaceEvolutionInfo); -- 进化目标
	return data;
end

function Proto.getPetRaceSuperEvolutionIDLen()
	return Proto.getDWORDLen();
end

function Proto.writePetRaceSuperEvolution(msg,data)
	Proto.writeDWORD(msg,data.id); -- 进化规则ID
	Proto.writeEvolveRace(msg,data.sourcePet); -- 来源宠物种族
	Proto.writeBYTE(msg,data.hasConsumeItem); -- 是否消耗道具
	if (data.hasConsumeItem ~=0) then
		Proto.writeDWORD(msg,data.item_type); -- 所需道具类型
		Proto.writeDWORD(msg,data.item_count); -- 所需道具数量
	end
	Proto.writeVector(msg,data.sacrificePets,Proto.writeEvolveRace); -- 牺牲宠物
	Proto.writeVector(msg,data.races,Proto.writePetRaceEvolutionInfo); -- 进化目标
end

function Proto.parseRaceProcreationInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 种族编号
	data.intercross_id=Proto.parseWORD(entry); -- 杂交组ID
	data.level=Proto.parseWORD(entry); -- 需要等级
	data.growth=Proto.parseDWORD(entry); -- 需要等级
	data.gameteItemType=Proto.parseDWORD(entry); -- 配子道具类型
	data.costItems=Proto.parseVector(entry,Proto.parseConsumeItem); -- 消耗道具类型
	data.procreateCount=Proto.parseBYTE(entry); -- 最大生育次数
	data.petEggItemType=Proto.parseDWORD(entry); -- 后代宠物蛋道具类型(未必是先代的种族)
	data.femaleProb=Proto.parseBYTE(entry); -- 雌性率(百分之一单位)
	data.heritableAllelePos=Proto.parseVector(entry,Proto.parseWORD); -- 可遗传的基因位置
	data.defaultGeneID=Proto.parseWORD(entry); -- 基因概率组编号
	return data;
end

function Proto.getRaceProcreationInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeRaceProcreationInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 种族编号
	Proto.writeWORD(msg,data.intercross_id); -- 杂交组ID
	Proto.writeWORD(msg,data.level); -- 需要等级
	Proto.writeDWORD(msg,data.growth); -- 需要等级
	Proto.writeDWORD(msg,data.gameteItemType); -- 配子道具类型
	Proto.writeVector(msg,data.costItems,Proto.writeConsumeItem); -- 消耗道具类型
	Proto.writeBYTE(msg,data.procreateCount); -- 最大生育次数
	Proto.writeDWORD(msg,data.petEggItemType); -- 后代宠物蛋道具类型(未必是先代的种族)
	Proto.writeBYTE(msg,data.femaleProb); -- 雌性率(百分之一单位)
	Proto.writeVector(msg,data.heritableAllelePos,Proto.writeWORD); -- 可遗传的基因位置
	Proto.writeWORD(msg,data.defaultGeneID); -- 基因概率组编号
end

function Proto.parseRaceIntercrossInfo(entry)
	local data={};
	data.id=Proto.parseWORD(entry); -- 杂交组编号
	data.name=Proto.parseString(entry); -- 名称
	data.intercrossGroup=Proto.parseVector(entry,Proto.parseRaceProbability); -- 基因概率
	return data;
end

function Proto.getRaceIntercrossInfoIDLen()
	return Proto.getWORDLen();
end

function Proto.writeRaceIntercrossInfo(msg,data)
	Proto.writeWORD(msg,data.id); -- 杂交组编号
	Proto.writeString(msg,data.name); -- 名称
	Proto.writeVector(msg,data.intercrossGroup,Proto.writeRaceProbability); -- 基因概率
end

function Proto.parseGeneIntensifyItemInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 道具id
	data.type_id=Proto.parseDWORD(entry); -- 道具类型
	return data;
end

function Proto.getGeneIntensifyItemInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeGeneIntensifyItemInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 道具id
	Proto.writeDWORD(msg,data.type_id); -- 道具类型
end

function Proto.parsePetAlleleActive(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 目标宠物种族
	data.generateGenes=Proto.parseVector(entry,Proto.parseAllelePosInfo); -- 特别生成的基因
	return data;
end

function Proto.getPetAlleleActiveIDLen()
	return Proto.getDWORDLen();
end

function Proto.writePetAlleleActive(msg,data)
	Proto.writeDWORD(msg,data.id); -- 目标宠物种族
	Proto.writeVector(msg,data.generateGenes,Proto.writeAllelePosInfo); -- 特别生成的基因
end

function Proto.parseSacredPetInfo(entry)
	local data={};
	data.pet=Proto.parseDWORD(entry); -- 宠物类型
	data.level=Proto.parseBYTE(entry); -- 被祭祀宠物所需等级
	data.growth=Proto.parseDWORD(entry); -- 被祭祀宠物所需成长度
	data.itemID=Proto.parseDWORD(entry); -- 祭祀所需道具
	data.genePos=Proto.parseVector(entry,Proto.parseWORD); -- 祭祀天性位置
	return data;
end

function Proto.writeSacredPetInfo(msg,data)
	Proto.writeDWORD(msg,data.pet); -- 宠物类型
	Proto.writeBYTE(msg,data.level); -- 被祭祀宠物所需等级
	Proto.writeDWORD(msg,data.growth); -- 被祭祀宠物所需成长度
	Proto.writeDWORD(msg,data.itemID); -- 祭祀所需道具
	Proto.writeVector(msg,data.genePos,Proto.writeWORD); -- 祭祀天性位置
end

function Proto.parsePetSacredInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 祭祀组号
	data.targetPet=Proto.parseDWORD(entry); -- 目标宠物类型
	data.sacredInfo=Proto.parseSacredPetInfo(entry); -- 祭祀宠物信息
	return data;
end

function Proto.getPetSacredInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writePetSacredInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 祭祀组号
	Proto.writeDWORD(msg,data.targetPet); -- 目标宠物类型
	Proto.writeSacredPetInfo(msg,data.sacredInfo); -- 祭祀宠物信息
end

function Proto.parseItemGeneCoverInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 道具编号
	data.geneID_a=Proto.parseWORD(entry); -- 基因编号a
	data.geneID_b=Proto.parseWORD(entry); -- 基因编号b
	data.pos=Proto.parseVector(entry,Proto.parseWORD); -- 可选择位置
	data.raceList=Proto.parseVector(entry,Proto.parseDWORD); -- 可适用种族
	return data;
end

function Proto.getItemGeneCoverInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeItemGeneCoverInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 道具编号
	Proto.writeWORD(msg,data.geneID_a); -- 基因编号a
	Proto.writeWORD(msg,data.geneID_b); -- 基因编号b
	Proto.writeVector(msg,data.pos,Proto.writeWORD); -- 可选择位置
	Proto.writeVector(msg,data.raceList,Proto.writeDWORD); -- 可适用种族
end

function Proto.parseInBagPetOrder(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 宠物ID
	data.order=Proto.parseBYTE(entry); -- 宠物袋顺序(0表示首发)
	return data;
end

function Proto.getInBagPetOrderIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeInBagPetOrder(msg,data)
	Proto.writeDWORD(msg,data.id); -- 宠物ID
	Proto.writeBYTE(msg,data.order); -- 宠物袋顺序(0表示首发)
end

function Proto.parseAppointedAlleleInfo(entry)
	local data={};
	data.pos=Proto.parseWORD(entry); -- 基因位置
	data.itemType=Proto.parseDWORD(entry); -- 激活使用道具
	data.level=Proto.parseBYTE(entry); -- 激活后等级
	data.genes=Proto.parseVector(entry,Proto.parseWORD); -- 可选择天性
	return data;
end

function Proto.writeAppointedAlleleInfo(msg,data)
	Proto.writeWORD(msg,data.pos); -- 基因位置
	Proto.writeDWORD(msg,data.itemType); -- 激活使用道具
	Proto.writeBYTE(msg,data.level); -- 激活后等级
	Proto.writeVector(msg,data.genes,Proto.writeWORD); -- 可选择天性
end

function Proto.parseAppointedAlleleActiveInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 宠物ID
	data.appointedAlleles=Proto.parseVector(entry,Proto.parseAppointedAlleleInfo); -- 可选择天性
	return data;
end

function Proto.getAppointedAlleleActiveInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeAppointedAlleleActiveInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 宠物ID
	Proto.writeVector(msg,data.appointedAlleles,Proto.writeAppointedAlleleInfo); -- 可选择天性
end

function Proto.parseHealthPillInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 健康度恢复药丸类型ID
	data.value=Proto.parseDWORD(entry); -- 恢复量
	return data;
end

function Proto.getHealthPillInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeHealthPillInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 健康度恢复药丸类型ID
	Proto.writeDWORD(msg,data.value); -- 恢复量
end

function Proto.parseInWarhousePetDesc(entry)
	local data={};
	data.id=Proto.parsePetID(entry); -- 宠物ID
	data.name=Proto.parseLifeNick(entry); -- 宠物昵称
	data.raceType=Proto.parseDWORD(entry); -- 种族
	data.level=Proto.parseWORD(entry); -- 等级
	data.status=Proto.parseBYTE(entry); -- 状态
	return data;
end

function Proto.getInWarhousePetDescIDLen()
	return Proto.getPetIDLen();
end

function Proto.writeInWarhousePetDesc(msg,data)
	Proto.writePetID(msg,data.id); -- 宠物ID
	Proto.writeLifeNick(msg,data.name); -- 宠物昵称
	Proto.writeDWORD(msg,data.raceType); -- 种族
	Proto.writeWORD(msg,data.level); -- 等级
	Proto.writeBYTE(msg,data.status); -- 状态
end

function Proto.parsePetAttribute(entry)
	local data={};
	data.maxHP=Proto.parseDWORD(entry); -- 最大生命值
	data.maxSP=Proto.parseDWORD(entry); -- 最大能量
	data.maxPP=Proto.parseDWORD(entry); -- 最大优先度
	data.lightAttack=Proto.parseDWORD(entry); -- 光攻
	data.lightDefence=Proto.parseDWORD(entry); -- 光防
	data.darkAttack=Proto.parseDWORD(entry); -- 暗攻
	data.darkDefence=Proto.parseDWORD(entry); -- 暗防
	return data;
end

function Proto.writePetAttribute(msg,data)
	Proto.writeDWORD(msg,data.maxHP); -- 最大生命值
	Proto.writeDWORD(msg,data.maxSP); -- 最大能量
	Proto.writeDWORD(msg,data.maxPP); -- 最大优先度
	Proto.writeDWORD(msg,data.lightAttack); -- 光攻
	Proto.writeDWORD(msg,data.lightDefence); -- 光防
	Proto.writeDWORD(msg,data.darkAttack); -- 暗攻
	Proto.writeDWORD(msg,data.darkDefence); -- 暗防
end

function Proto.parsePetInfo(entry)
	local data={};
	data.desc=Proto.parsePetDescription(entry); -- 宠物描述
	data.activeStatus=Proto.parseBYTE(entry); -- 宠物活动状态
	data.noStruggleAtrrib=Proto.parsePetAttribute(entry); -- 不计算努力值的基本属性
	data.baseAtrrib=Proto.parsePetAttribute(entry); -- 基本属性(不计算装备)
	data.activeMode=Proto.parseBYTE(entry); -- AI模式
	data.hasDorm=Proto.parseBYTE(entry); -- 有无宿舍
	if (data.hasDorm~=0) then
		data.dormGardenID=Proto.parseDWORD(entry); -- 宿舍所在庄园ID
		data.dormID=Proto.parseQWORD(entry); -- 所在宿舍ID
	end
	data.vipPet=Proto.parseBYTE(entry); -- 是否付费宠物
	data.forbidProcreate=Proto.parseBYTE(entry); -- 是否杂交
	return data;
end

function Proto.writePetInfo(msg,data)
	Proto.writePetDescription(msg,data.desc); -- 宠物描述
	Proto.writeBYTE(msg,data.activeStatus); -- 宠物活动状态
	Proto.writePetAttribute(msg,data.noStruggleAtrrib); -- 不计算努力值的基本属性
	Proto.writePetAttribute(msg,data.baseAtrrib); -- 基本属性(不计算装备)
	Proto.writeBYTE(msg,data.activeMode); -- AI模式
	Proto.writeBYTE(msg,data.hasDorm); -- 有无宿舍
	if (data.hasDorm~=0) then
		Proto.writeDWORD(msg,data.dormGardenID); -- 宿舍所在庄园ID
		Proto.writeQWORD(msg,data.dormID); -- 所在宿舍ID
	end
	Proto.writeBYTE(msg,data.vipPet); -- 是否付费宠物
	Proto.writeBYTE(msg,data.forbidProcreate); -- 是否杂交
end

function Proto.parsePetPotentialLevelInfo(entry)
	local data={};
	data.id=Proto.parseBYTE(entry); -- 等级
	data.experience=Proto.parseDWORD(entry); -- 经验
	return data;
end

function Proto.getPetPotentialLevelInfoIDLen()
	return Proto.getBYTELen();
end

function Proto.writePetPotentialLevelInfo(msg,data)
	Proto.writeBYTE(msg,data.id); -- 等级
	Proto.writeDWORD(msg,data.experience); -- 经验
end

function Proto.parsePetPotentialInfo(entry)
	local data={};
	data.id=Proto.parsePetID(entry); -- 宠物ID
	data.level=Proto.parseBYTE(entry); -- 等级
	data.experience=Proto.parseDWORD(entry); -- 经验
	data.intensifyCount=Proto.parseWORD(entry); -- 强化次数
	data.intensifyMaxCount=Proto.parseWORD(entry); -- 强化上限
	return data;
end

function Proto.getPetPotentialInfoIDLen()
	return Proto.getPetIDLen();
end

function Proto.writePetPotentialInfo(msg,data)
	Proto.writePetID(msg,data.id); -- 宠物ID
	Proto.writeBYTE(msg,data.level); -- 等级
	Proto.writeDWORD(msg,data.experience); -- 经验
	Proto.writeWORD(msg,data.intensifyCount); -- 强化次数
	Proto.writeWORD(msg,data.intensifyMaxCount); -- 强化上限
end

function Proto.parseDepotExtendInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 仓库扩展方案ID
	data.depotCount=Proto.parseDWORD(entry); -- 仓库格数
	data.extendDepotCount=Proto.parseDWORD(entry); -- 仓库扩展格数
	data.expends=Proto.parseVector(entry,Proto.parseCostInfo); -- 仓库扩展代价
	return data;
end

function Proto.getDepotExtendInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeDepotExtendInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 仓库扩展方案ID
	Proto.writeDWORD(msg,data.depotCount); -- 仓库格数
	Proto.writeDWORD(msg,data.extendDepotCount); -- 仓库扩展格数
	Proto.writeVector(msg,data.expends,Proto.writeCostInfo); -- 仓库扩展代价
end

function Proto.parseSixDimensionalRefreshLimitInfo(entry)
	local data={};
	data.turnTimes=Proto.parseDWORD(entry); -- 转生次数
	data.limit=Proto.parseDWORD(entry); -- 上限
	return data;
end

function Proto.writeSixDimensionalRefreshLimitInfo(msg,data)
	Proto.writeDWORD(msg,data.turnTimes); -- 转生次数
	Proto.writeDWORD(msg,data.limit); -- 上限
end

function Proto.parseSixDimensionalRefreshRuleInfo(entry)
	local data={};
	data.prob=Proto.parseDWORD(entry); -- 概率
	data.value=Proto.parseint(entry); -- 值
	return data;
end

function Proto.writeSixDimensionalRefreshRuleInfo(msg,data)
	Proto.writeDWORD(msg,data.prob); -- 概率
	Proto.writeint(msg,data.value); -- 值
end

function Proto.parseSixDimensionalRefreshInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- id
	data.limitInfo=Proto.parseVector(entry,Proto.parseSixDimensionalRefreshLimitInfo); -- 上限信息
	data.ruleInfo=Proto.parseVector(entry,Proto.parseSixDimensionalRefreshRuleInfo); -- 规则信息
	data.costItemID=Proto.parseDWORD(entry); -- 需求道具
	data.costItemCount=Proto.parseDWORD(entry); -- 需求道具数量
	return data;
end

function Proto.getSixDimensionalRefreshInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeSixDimensionalRefreshInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- id
	Proto.writeVector(msg,data.limitInfo,Proto.writeSixDimensionalRefreshLimitInfo); -- 上限信息
	Proto.writeVector(msg,data.ruleInfo,Proto.writeSixDimensionalRefreshRuleInfo); -- 规则信息
	Proto.writeDWORD(msg,data.costItemID); -- 需求道具
	Proto.writeDWORD(msg,data.costItemCount); -- 需求道具数量
end

function Proto.parseExperienceInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 等级
	data.roleExp=Proto.parseDWORD(entry); -- 人物总经验
	data.petExpVec=Proto.parseVector(entry,Proto.parseDWORD); -- 宠物总经验组
	data.limitPower=Proto.parseDWORD(entry); -- 体力上限
	data.levelUpAddPower=Proto.parseDWORD(entry); -- 升级回复体力值
	data.petSingleAttrStrengthenMax=Proto.parseDWORD(entry); -- 单属性强化上限
	data.petLevelMax=Proto.parseDWORD(entry); -- 宠物等级上限
	return data;
end

function Proto.getExperienceInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeExperienceInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 等级
	Proto.writeDWORD(msg,data.roleExp); -- 人物总经验
	Proto.writeVector(msg,data.petExpVec,Proto.writeDWORD); -- 宠物总经验组
	Proto.writeDWORD(msg,data.limitPower); -- 体力上限
	Proto.writeDWORD(msg,data.levelUpAddPower); -- 升级回复体力值
	Proto.writeDWORD(msg,data.petSingleAttrStrengthenMax); -- 单属性强化上限
	Proto.writeDWORD(msg,data.petLevelMax); -- 宠物等级上限
end

function Proto.parsePetStrengthenInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 强化次数
	data.consumeType=Proto.parseVector(entry,Proto.parseDWORD); -- 材料
	data.consumeCount=Proto.parseDWORD(entry); -- 份数
	data.gcash=Proto.parseDWORD(entry); -- 消耗G币
	return data;
end

function Proto.getPetStrengthenInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writePetStrengthenInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 强化次数
	Proto.writeVector(msg,data.consumeType,Proto.writeDWORD); -- 材料
	Proto.writeDWORD(msg,data.consumeCount); -- 份数
	Proto.writeDWORD(msg,data.gcash); -- 消耗G币
end

function Proto.parsePetPrimarySkill(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 宠物ID
	data.skill1=Proto.parseDWORD(entry); -- 技能1
	data.skill2=Proto.parseDWORD(entry); -- 技能2
	data.skill3=Proto.parseDWORD(entry); -- 技能3
	data.skill4=Proto.parseDWORD(entry); -- 技能4
	return data;
end

function Proto.getPetPrimarySkillIDLen()
	return Proto.getDWORDLen();
end

function Proto.writePetPrimarySkill(msg,data)
	Proto.writeDWORD(msg,data.id); -- 宠物ID
	Proto.writeDWORD(msg,data.skill1); -- 技能1
	Proto.writeDWORD(msg,data.skill2); -- 技能2
	Proto.writeDWORD(msg,data.skill3); -- 技能3
	Proto.writeDWORD(msg,data.skill4); -- 技能4
end

function Proto.parseStageCons(entry)
	local data={};
	data.costs=Proto.parseVector(entry,Proto.parseDWORD); -- 消耗元素
	return data;
end

function Proto.writeStageCons(msg,data)
	Proto.writeVector(msg,data.costs,Proto.writeDWORD); -- 消耗元素
end

function Proto.parsePetAdvanceInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 次数
	data.stageCons=Proto.parseVector(entry,Proto.parseStageCons); -- 各种类消耗:C >> SSS
	return data;
end

function Proto.getPetAdvanceInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writePetAdvanceInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 次数
	Proto.writeVector(msg,data.stageCons,Proto.writeStageCons); -- 各种类消耗:C >> SSS
end

function Proto.parsePetStarUpInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 宠物ID
	data.costItem=Proto.parseVector(entry,Proto.parseDWORD); -- 消耗的道具ID
	data.num1=Proto.parseVector(entry,Proto.parseDWORD); -- 数量1
	data.costPet=Proto.parseVector(entry,Proto.parseDWORD); -- 消耗的宠物ID
	data.num2=Proto.parseVector(entry,Proto.parseDWORD); -- 数量2
	data.limit=Proto.parseVector(entry,Proto.parseDWORD); -- 强化次数限制
	data.maxStar=Proto.parseDWORD(entry); -- 最大星数
	data.costPetComm=Proto.parseVector(entry,Proto.parseDWORD); -- 通用升星材料
	return data;
end

function Proto.getPetStarUpInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writePetStarUpInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 宠物ID
	Proto.writeVector(msg,data.costItem,Proto.writeDWORD); -- 消耗的道具ID
	Proto.writeVector(msg,data.num1,Proto.writeDWORD); -- 数量1
	Proto.writeVector(msg,data.costPet,Proto.writeDWORD); -- 消耗的宠物ID
	Proto.writeVector(msg,data.num2,Proto.writeDWORD); -- 数量2
	Proto.writeVector(msg,data.limit,Proto.writeDWORD); -- 强化次数限制
	Proto.writeDWORD(msg,data.maxStar); -- 最大星数
	Proto.writeVector(msg,data.costPetComm,Proto.writeDWORD); -- 通用升星材料
end

function Proto.parseEvoSkillInfo(entry)
	local data={};
	data.skillType=Proto.parseDWORD(entry); -- 技能类型
	data.skillArrID=Proto.parseDWORD(entry); -- 技能组索引
	data.skillPosType=Proto.parseDWORD(entry); -- 技能位类型
	return data;
end

function Proto.writeEvoSkillInfo(msg,data)
	Proto.writeDWORD(msg,data.skillType); -- 技能类型
	Proto.writeDWORD(msg,data.skillArrID); -- 技能组索引
	Proto.writeDWORD(msg,data.skillPosType); -- 技能位类型
end

function Proto.parseEvoRateInfo(entry)
	local data={};
	data.rate=Proto.parseDWORD(entry); -- 进化概率
	data.newRace=Proto.parseDWORD(entry); -- 新种族
	data.EvoSkillVec=Proto.parseVector(entry,Proto.parseEvoSkillInfo); -- 可能学会的技能们。。
	return data;
end

function Proto.writeEvoRateInfo(msg,data)
	Proto.writeDWORD(msg,data.rate); -- 进化概率
	Proto.writeDWORD(msg,data.newRace); -- 新种族
	Proto.writeVector(msg,data.EvoSkillVec,Proto.writeEvoSkillInfo); -- 可能学会的技能们。。
end

function Proto.parsePetEvoLevelInfo(entry)
	local data={};
	data.level=Proto.parseWORD(entry); -- 进化需要的等级
	data.stageCons=Proto.parseVector(entry,Proto.parseDWORD); -- 宠物进化消费
	data.EvoRateInfoVec=Proto.parseVector(entry,Proto.parseEvoRateInfo); -- 宠物进化消费
	return data;
end

function Proto.writePetEvoLevelInfo(msg,data)
	Proto.writeWORD(msg,data.level); -- 进化需要的等级
	Proto.writeVector(msg,data.stageCons,Proto.writeDWORD); -- 宠物进化消费
	Proto.writeVector(msg,data.EvoRateInfoVec,Proto.writeEvoRateInfo); -- 宠物进化消费
end

function Proto.parsePetEvoInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 宠物种族
	data.PetEvoLevelInfoVec=Proto.parseVector(entry,Proto.parsePetEvoLevelInfo); -- 宠物进化时各种可能等级对应的信息
	return data;
end

function Proto.getPetEvoInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writePetEvoInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 宠物种族
	Proto.writeVector(msg,data.PetEvoLevelInfoVec,Proto.writePetEvoLevelInfo); -- 宠物进化时各种可能等级对应的信息
end

function Proto.parseCapsuleEggInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 扭蛋类型
	data.normalEggAwardIndex=Proto.parseWORD(entry); -- 每次扭蛋奖励组项
	data.OneEggCons=Proto.parseDWORD(entry); -- 扭一次消费
	data.tenEggCons=Proto.parseDWORD(entry); -- 扭十次消费
	data.expELem=Proto.parseDWORD(entry); -- 经验药水奖励元素经验药水奖励元素
	data.freeTimes=Proto.parseDWORD(entry); -- 每日免费次数
	data.CD=Proto.parseDWORD(entry); -- 免费扭蛋的冷却时间
	data.firstEggAwardIndex=Proto.parseWORD(entry); -- 首抽奖励组项
	data.firstTenEggAwardIndex=Proto.parseWORD(entry); -- 首次十连奖励组项
	data.normalTenEggAwardIndex=Proto.parseWORD(entry); -- 普通十连奖励组项
	data.tenTimesEggAwardIndex=Proto.parseWORD(entry); -- 十次内必出奖励组项
	data.vipLevel=Proto.parseWORD(entry); -- VIP等级限制
	data.wishName=Proto.parseString(entry); -- 心愿名称
	data.wishValuePer=Proto.parseDWORD(entry); -- 心愿单次附加值
	data.wishCost=Proto.parseDWORD(entry); -- 心愿附加值消耗
	data.wishAwards=Proto.parseDWORD(entry); -- 附加值可用时，奖池
	data.wishAwardsCount=Proto.parseDWORD(entry); -- 可选个数
	data.dreamName=Proto.parseString(entry); -- 梦想
	data.dreamValuePer=Proto.parseDWORD(entry); -- 梦想单次附加值
	data.dreamCost=Proto.parseDWORD(entry); -- 梦想消耗
	data.dreamAwards=Proto.parseDWORD(entry); -- 梦想奖池
	data.dreamAwardsCount=Proto.parseDWORD(entry); -- 可选个数
	return data;
end

function Proto.getCapsuleEggInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeCapsuleEggInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 扭蛋类型
	Proto.writeWORD(msg,data.normalEggAwardIndex); -- 每次扭蛋奖励组项
	Proto.writeDWORD(msg,data.OneEggCons); -- 扭一次消费
	Proto.writeDWORD(msg,data.tenEggCons); -- 扭十次消费
	Proto.writeDWORD(msg,data.expELem); -- 经验药水奖励元素经验药水奖励元素
	Proto.writeDWORD(msg,data.freeTimes); -- 每日免费次数
	Proto.writeDWORD(msg,data.CD); -- 免费扭蛋的冷却时间
	Proto.writeWORD(msg,data.firstEggAwardIndex); -- 首抽奖励组项
	Proto.writeWORD(msg,data.firstTenEggAwardIndex); -- 首次十连奖励组项
	Proto.writeWORD(msg,data.normalTenEggAwardIndex); -- 普通十连奖励组项
	Proto.writeWORD(msg,data.tenTimesEggAwardIndex); -- 十次内必出奖励组项
	Proto.writeWORD(msg,data.vipLevel); -- VIP等级限制
	Proto.writeString(msg,data.wishName); -- 心愿名称
	Proto.writeDWORD(msg,data.wishValuePer); -- 心愿单次附加值
	Proto.writeDWORD(msg,data.wishCost); -- 心愿附加值消耗
	Proto.writeDWORD(msg,data.wishAwards); -- 附加值可用时，奖池
	Proto.writeDWORD(msg,data.wishAwardsCount); -- 可选个数
	Proto.writeString(msg,data.dreamName); -- 梦想
	Proto.writeDWORD(msg,data.dreamValuePer); -- 梦想单次附加值
	Proto.writeDWORD(msg,data.dreamCost); -- 梦想消耗
	Proto.writeDWORD(msg,data.dreamAwards); -- 梦想奖池
	Proto.writeDWORD(msg,data.dreamAwardsCount); -- 可选个数
end

function Proto.parseCapsuleEggRateAward(entry)
	local data={};
	data.rate=Proto.parseWORD(entry); -- 概率
	data.awardItemIndex=Proto.parseDWORD(entry); -- 奖励元素ID
	data.awardItemNum=Proto.parseDWORD(entry); -- 奖励元素的数量
	return data;
end

function Proto.writeCapsuleEggRateAward(msg,data)
	Proto.writeWORD(msg,data.rate); -- 概率
	Proto.writeDWORD(msg,data.awardItemIndex); -- 奖励元素ID
	Proto.writeDWORD(msg,data.awardItemNum); -- 奖励元素的数量
end

function Proto.parseCapsuleEggAwardInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 奖励组的索引
	data.awardInfoVec=Proto.parseVector(entry,Proto.parseCapsuleEggRateAward); -- 奖励及概率的数组
	return data;
end

function Proto.getCapsuleEggAwardInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeCapsuleEggAwardInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 奖励组的索引
	Proto.writeVector(msg,data.awardInfoVec,Proto.writeCapsuleEggRateAward); -- 奖励及概率的数组
end

function Proto.parsePassiveSkillInfo(entry)
	local data={};
	data.passiveSkillType=Proto.parseDWORD(entry); -- 类型
	data.passiveSkillID=Proto.parseDWORD(entry); -- ID
	return data;
end

function Proto.writePassiveSkillInfo(msg,data)
	Proto.writeDWORD(msg,data.passiveSkillType); -- 类型
	Proto.writeDWORD(msg,data.passiveSkillID); -- ID
end

function Proto.parseGeneInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.petID=Proto.parseDWORD(entry); -- 宠物ID
	data.skill_1=Proto.parseDWORD(entry); -- 技能1
	data.skill_2=Proto.parseDWORD(entry); -- 技能2
	data.skill_3=Proto.parseDWORD(entry); -- 技能23
	data.profound=Proto.parseDWORD(entry); -- 奥义
	data.passiveSkills=Proto.parseVector(entry,Proto.parsePassiveSkillInfo); -- 被动技能
	return data;
end

function Proto.getGeneInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeGeneInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeDWORD(msg,data.petID); -- 宠物ID
	Proto.writeDWORD(msg,data.skill_1); -- 技能1
	Proto.writeDWORD(msg,data.skill_2); -- 技能2
	Proto.writeDWORD(msg,data.skill_3); -- 技能23
	Proto.writeDWORD(msg,data.profound); -- 奥义
	Proto.writeVector(msg,data.passiveSkills,Proto.writePassiveSkillInfo); -- 被动技能
end

function Proto.parsePetGeneGroupInfo(entry)
	local data={};
	data.prob=Proto.parseDWORD(entry); -- 概率
	data.prob_skillID=Proto.parseDWORD(entry); -- 技能ID
	return data;
end

function Proto.writePetGeneGroupInfo(msg,data)
	Proto.writeDWORD(msg,data.prob); -- 概率
	Proto.writeDWORD(msg,data.prob_skillID); -- 技能ID
end

function Proto.parseGeneProbabilityInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 宠物种族
	data.geneGroup=Proto.parseVector(entry,Proto.parsePetGeneGroupInfo); -- 技能组
	return data;
end

function Proto.getGeneProbabilityInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeGeneProbabilityInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 宠物种族
	Proto.writeVector(msg,data.geneGroup,Proto.writePetGeneGroupInfo); -- 技能组
end

function Proto.parsePetAwardGroupInfo(entry)
	local data={};
	data.probability=Proto.parseDWORD(entry); -- 概率
	data.awardID=Proto.parseDWORD(entry); -- 奖励ID
	data.num=Proto.parseDWORD(entry); -- 数量
	return data;
end

function Proto.writePetAwardGroupInfo(msg,data)
	Proto.writeDWORD(msg,data.probability); -- 概率
	Proto.writeDWORD(msg,data.awardID); -- 奖励ID
	Proto.writeDWORD(msg,data.num); -- 数量
end

function Proto.parsePetFreedomAwardGroupInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.name=Proto.parseVector(entry,Proto.parsePetAwardGroupInfo); -- 奖励组
	return data;
end

function Proto.getPetFreedomAwardGroupInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writePetFreedomAwardGroupInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeVector(msg,data.name,Proto.writePetAwardGroupInfo); -- 奖励组
end

function Proto.parsePetFreedomStarpointInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 星数
	data.Fvalue=Proto.parseVector(entry,Proto.parseDWORD); -- 附加值
	return data;
end

function Proto.getPetFreedomStarpointInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writePetFreedomStarpointInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 星数
	Proto.writeVector(msg,data.Fvalue,Proto.writeDWORD); -- 附加值
end

function Proto.parsePetFreedomAwardInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.rarity=Proto.parseDWORD(entry); -- 宠物稀有度
	data.skill_s=Proto.parseDWORD(entry); -- 技能碎片
	data.dreamCash=Proto.parseDWORD(entry); -- 梦想币
	data.wishCash=Proto.parseDWORD(entry); -- 心愿币
	data.scienceItem=Proto.parseDWORD(entry); -- 
	data.scienceItemNum=Proto.parseVector(entry,Proto.parseDWORD); -- 
	return data;
end

function Proto.getPetFreedomAwardInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writePetFreedomAwardInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeDWORD(msg,data.rarity); -- 宠物稀有度
	Proto.writeDWORD(msg,data.skill_s); -- 技能碎片
	Proto.writeDWORD(msg,data.dreamCash); -- 梦想币
	Proto.writeDWORD(msg,data.wishCash); -- 心愿币
	Proto.writeDWORD(msg,data.scienceItem); -- 
	Proto.writeVector(msg,data.scienceItemNum,Proto.writeDWORD); -- 
end

function Proto.parseYokeInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.yokeName=Proto.parseString(entry); -- 羁绊名称
	data.pets=Proto.parseVector(entry,Proto.parseDWORD); -- 需求宠物
	data.rarePoint=Proto.parseWORD(entry); -- 稀有度
	data.attribType=Proto.parseWORD(entry); -- 属性类型
	return data;
end

function Proto.getYokeInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeYokeInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeString(msg,data.yokeName); -- 羁绊名称
	Proto.writeVector(msg,data.pets,Proto.writeDWORD); -- 需求宠物
	Proto.writeWORD(msg,data.rarePoint); -- 稀有度
	Proto.writeWORD(msg,data.attribType); -- 属性类型
end

function Proto.parseYokeEffect(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 积分
	data.effectValues=Proto.parseVector(entry,Proto.parsefloat); -- 属性值组
	return data;
end

function Proto.getYokeEffectIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeYokeEffect(msg,data)
	Proto.writeDWORD(msg,data.id); -- 积分
	Proto.writeVector(msg,data.effectValues,Proto.writefloat); -- 属性值组
end

function Proto.parseYokeScore(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 积分
	data.scores=Proto.parseVector(entry,Proto.parseDWORD); -- 星级积分
	return data;
end

function Proto.getYokeScoreIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeYokeScore(msg,data)
	Proto.writeDWORD(msg,data.id); -- 积分
	Proto.writeVector(msg,data.scores,Proto.writeDWORD); -- 星级积分
end

function Proto.parseYokeEffectPos(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 属性名
	data.pos=Proto.parseDWORD(entry); -- 位置
	data.name=Proto.parseString(entry); -- lang名
	return data;
end

function Proto.getYokeEffectPosIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeYokeEffectPos(msg,data)
	Proto.writeDWORD(msg,data.id); -- 属性名
	Proto.writeDWORD(msg,data.pos); -- 位置
	Proto.writeString(msg,data.name); -- lang名
end

function Proto.parsePetPieceInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.name=Proto.parseString(entry); -- 名称
	data.grade=Proto.parseString(entry); -- 品阶
	data.icon=Proto.parseDWORD(entry); -- icon
	data.num=Proto.parseDWORD(entry); -- 合成数量
	data.pokeID=Proto.parseDWORD(entry); -- 目标ID
	data.describe=Proto.parseString(entry); -- 描述
	return data;
end

function Proto.getPetPieceInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writePetPieceInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeString(msg,data.name); -- 名称
	Proto.writeString(msg,data.grade); -- 品阶
	Proto.writeDWORD(msg,data.icon); -- icon
	Proto.writeDWORD(msg,data.num); -- 合成数量
	Proto.writeDWORD(msg,data.pokeID); -- 目标ID
	Proto.writeString(msg,data.describe); -- 描述
end

function Proto.parseSkillPlay(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.myAction=Proto.parseDWORD(entry); -- 己方动作
	data.hisAction=Proto.parseDWORD(entry); -- 对方反应
	data.readyAni=Proto.parseString(entry); -- 蓄力动画
	data.fireAniBg=Proto.parseString(entry); -- 释放动画底层
	data.fireAniTop=Proto.parseString(entry); -- 释放动画顶层
	data.beAttackedAni=Proto.parseString(entry); -- 击中动画
	data.sound=Proto.parseString(entry); -- 音效
	data.hitsound=Proto.parseString(entry); -- 打击音效
	data.aniPos=Proto.parsefloat(entry); -- 动画位置
	data.bgUD=Proto.parsefloat(entry); -- 背上下
	data.bgLR=Proto.parsefloat(entry); -- 背左右
	data.topUD=Proto.parsefloat(entry); -- 正上下
	data.topLR=Proto.parsefloat(entry); -- 正左右
	data.firePointUD=Proto.parsefloat(entry); -- 弹道打击点上下
	data.firePointLR=Proto.parsefloat(entry); -- 弹道打击点左右
	data.typeIcon=Proto.parseString(entry); -- 类型图标
	data.firePointPos=Proto.parsefloat(entry); -- 弹道打击点位置
	data.scale=Proto.parsefloat(entry); -- 尺寸大小
	return data;
end

function Proto.getSkillPlayIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeSkillPlay(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeDWORD(msg,data.myAction); -- 己方动作
	Proto.writeDWORD(msg,data.hisAction); -- 对方反应
	Proto.writeString(msg,data.readyAni); -- 蓄力动画
	Proto.writeString(msg,data.fireAniBg); -- 释放动画底层
	Proto.writeString(msg,data.fireAniTop); -- 释放动画顶层
	Proto.writeString(msg,data.beAttackedAni); -- 击中动画
	Proto.writeString(msg,data.sound); -- 音效
	Proto.writeString(msg,data.hitsound); -- 打击音效
	Proto.writefloat(msg,data.aniPos); -- 动画位置
	Proto.writefloat(msg,data.bgUD); -- 背上下
	Proto.writefloat(msg,data.bgLR); -- 背左右
	Proto.writefloat(msg,data.topUD); -- 正上下
	Proto.writefloat(msg,data.topLR); -- 正左右
	Proto.writefloat(msg,data.firePointUD); -- 弹道打击点上下
	Proto.writefloat(msg,data.firePointLR); -- 弹道打击点左右
	Proto.writeString(msg,data.typeIcon); -- 类型图标
	Proto.writefloat(msg,data.firePointPos); -- 弹道打击点位置
	Proto.writefloat(msg,data.scale); -- 尺寸大小
end

function Proto.parsePetResetStarInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 星数
	data.consume=Proto.parseDWORD(entry); -- 消耗星数
	return data;
end

function Proto.getPetResetStarInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writePetResetStarInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 星数
	Proto.writeDWORD(msg,data.consume); -- 消耗星数
end

function Proto.parseScienceConsumeInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 
	data.consumeType=Proto.parseDWORD(entry); -- 消耗类型
	data.sciencePoint=Proto.parseDWORD(entry); -- 科技点
	data.rate=Proto.parseDWORD(entry); -- 权重
	data.sciencePointRate=Proto.parseString(entry); -- 倍率
	data.consumeItems=Proto.parseVector(entry,Proto.parseDWORD); -- 材料
	return data;
end

function Proto.getScienceConsumeInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeScienceConsumeInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 
	Proto.writeDWORD(msg,data.consumeType); -- 消耗类型
	Proto.writeDWORD(msg,data.sciencePoint); -- 科技点
	Proto.writeDWORD(msg,data.rate); -- 权重
	Proto.writeString(msg,data.sciencePointRate); -- 倍率
	Proto.writeVector(msg,data.consumeItems,Proto.writeDWORD); -- 材料
end

function Proto.parseScienceInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 
	data.openLevel=Proto.parseDWORD(entry); -- 
	data.scienceType=Proto.parseDWORD(entry); -- 
	data.icon=Proto.parseString(entry); -- 
	data.desc=Proto.parseString(entry); -- 
	data.desc2=Proto.parseString(entry); -- 
	data.values=Proto.parseVector(entry,Proto.parseDWORD); -- 数值
	data.levelUpSciencePoints=Proto.parseVector(entry,Proto.parseDWORD); -- 升级科技点
	data.starUpConsumes=Proto.parseVector(entry,Proto.parseDWORD); -- 突破科技点
	data.starUpSciencePoints=Proto.parseVector(entry,Proto.parseDWORD); -- 突破材料
	return data;
end

function Proto.getScienceInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeScienceInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 
	Proto.writeDWORD(msg,data.openLevel); -- 
	Proto.writeDWORD(msg,data.scienceType); -- 
	Proto.writeString(msg,data.icon); -- 
	Proto.writeString(msg,data.desc); -- 
	Proto.writeString(msg,data.desc2); -- 
	Proto.writeVector(msg,data.values,Proto.writeDWORD); -- 数值
	Proto.writeVector(msg,data.levelUpSciencePoints,Proto.writeDWORD); -- 升级科技点
	Proto.writeVector(msg,data.starUpConsumes,Proto.writeDWORD); -- 突破科技点
	Proto.writeVector(msg,data.starUpSciencePoints,Proto.writeDWORD); -- 突破材料
end

function Proto.parseCustomSkillBookInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 
	data.petIDs=Proto.parseVector(entry,Proto.parseDWORD); -- 
	return data;
end

function Proto.getCustomSkillBookInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeCustomSkillBookInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 
	Proto.writeVector(msg,data.petIDs,Proto.writeDWORD); -- 
end

function Proto.parseScienceData(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 
	data.level=Proto.parseWORD(entry); -- 
	data.star=Proto.parseWORD(entry); -- 
	return data;
end

function Proto.getScienceDataIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeScienceData(msg,data)
	Proto.writeDWORD(msg,data.id); -- 
	Proto.writeWORD(msg,data.level); -- 
	Proto.writeWORD(msg,data.star); -- 
end

function Proto.parsePetChainInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 
	data.petGeneID=Proto.parseDWORD(entry); -- 
	return data;
end

function Proto.getPetChainInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writePetChainInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 
	Proto.writeDWORD(msg,data.petGeneID); -- 
end

