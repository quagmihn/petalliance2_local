-- Net.Proto.Proto_Attribute_Types

Proto.AET_NORMAL	= 0							-- [元素类型]普通
Proto.AET_FIRE		= Proto.AET_NORMAL + 1		-- [元素类型]火系
Proto.AET_WATER		= Proto.AET_FIRE + 1		-- [元素类型]水系
Proto.AET_GRASS		= Proto.AET_WATER + 1		-- [元素类型]草系
Proto.AET_ELECTRIC	= Proto.AET_GRASS + 1		-- [元素类型]电系
Proto.AET_COMBAT	= Proto.AET_ELECTRIC + 1	-- [元素类型]格斗系
Proto.AET_EARTH		= Proto.AET_COMBAT + 1		-- [元素类型]地系
Proto.AET_FLY		= Proto.AET_EARTH + 1		-- [元素类型]飞行系
Proto.AET_SUPER		= Proto.AET_FLY + 1			-- [元素类型]超能系
Proto.AET_GHOST		= Proto.AET_SUPER + 1		-- [元素类型]鬼系
Proto.AET_DRAGON	= Proto.AET_GHOST + 1		-- [元素类型]龙系
Proto.AET_COUNT		= Proto.AET_DRAGON + 1		-- [元素类型]元素属性计数
Proto.AEFT_LIGHT	= 0						-- [(元素)领域类型]光
Proto.AEFT_DARK		= Proto.AEFT_LIGHT + 1	-- [(元素)领域类型]暗
Proto.AEFT_COUNT	= Proto.AEFT_DARK + 1	-- [(元素)领域类型]元素领域计数
Proto.STGT_MAXHP			= 0									-- [努力值类型]最大HP
Proto.STGT_SPEED			= Proto.STGT_MAXHP + 1				-- [努力值类型]速度
Proto.STGT_PHYSICS_ATTACK	= Proto.STGT_SPEED + 1				-- [努力值类型]物攻
Proto.STGT_PHYSICS_DEFENCE	= Proto.STGT_PHYSICS_ATTACK + 1		-- [努力值类型]物防
Proto.STGT_MAGIC_ATTACK		= Proto.STGT_PHYSICS_DEFENCE + 1	-- [努力值类型]魔攻
Proto.STGT_MAGIC_DEFENCE	= Proto.STGT_MAGIC_ATTACK + 1		-- [努力值类型]魔防
Proto.STGT_COUNT			= Proto.STGT_MAGIC_DEFENCE + 1		-- [努力值类型]努力值计数
Proto.SG_ARMORY		= 0						-- [携带限制]纹章
Proto.SG_ELITE		= Proto.SG_ARMORY + 1	-- [携带限制]精英技奥义绝招
Proto.SG_EXCLUSIVE	= Proto.SG_ELITE + 1	-- [携带限制]必杀无敌杀手锏
Proto.SCC_SS	= 0					-- [卡片阶位]SS
Proto.SCC_S		= Proto.SCC_SS + 1	-- [卡片阶位]S
Proto.SCC_A		= Proto.SCC_S + 1	-- [卡片阶位]A
Proto.SCC_B		= Proto.SCC_A + 1	-- [卡片阶位]B
Proto.SCC_C		= Proto.SCC_B + 1	-- [卡片阶位]C
Proto.SCC_D		= Proto.SCC_C + 1	-- [卡片阶位]D
Proto.SCC_E		= Proto.SCC_D + 1	-- [卡片阶位]E
Proto.ATT_NONE	= 0						-- [地形类型]无地形
Proto.ATT_GRASS	= Proto.ATT_NONE + 1	-- [地形类型]草地
Proto.ATT_MUD	= Proto.ATT_GRASS + 1	-- [地形类型]泥土
Proto.ATT_ROCK	= Proto.ATT_MUD + 1		-- [地形类型]岩石
Proto.ATT_METAL	= Proto.ATT_ROCK + 1	-- [地形类型]金属
Proto.ATT_SAND	= Proto.ATT_METAL + 1	-- [地形类型]沙
Proto.ATT_WATER	= Proto.ATT_SAND + 1	-- [地形类型]水
Proto.ATT_SKY	= Proto.ATT_WATER + 1	-- [地形类型]空中
Proto.ATT_MAGMA	= Proto.ATT_SKY + 1		-- [地形类型]熔岩
Proto.ATT_COUNT	= Proto.ATT_MAGMA + 1	-- [地形类型]总数
Proto.UG_FEMALE	= 0						-- [宠物性别]雌性
Proto.UG_MALE	= Proto.UG_FEMALE + 1	-- [宠物性别]雄性
Proto.UG_NONE	= Proto.UG_MALE + 1		-- [宠物性别]无性别
Proto.CCT_NONE				= 0									-- [施展类型]无
Proto.CCT_PHYSICAL_MELEE	= Proto.CCT_NONE + 1				-- [施展类型]近战物理攻击
Proto.CCT_PHYSICAL_MISSILE	= Proto.CCT_PHYSICAL_MELEE + 1		-- [施展类型]远程物理攻击
Proto.CCT_MAGIC				= Proto.CCT_PHYSICAL_MISSILE + 1	-- [施展类型]法术
Proto.AWT_NONE		= 0						-- [天气类型]无天气
Proto.AWT_HOT		= Proto.AWT_NONE + 1	-- [天气类型]炎热
Proto.AWT_RAIN		= Proto.AWT_HOT + 1		-- [天气类型]下雨
Proto.AWT_WIND		= Proto.AWT_RAIN + 1	-- [天气类型]下雨
Proto.AWT_HOLE		= Proto.AWT_WIND + 1	-- [天气类型]洞穴
Proto.AWT_TUNDER	= Proto.AWT_HOLE + 1	-- [天气类型]打雷
Proto.AWT_SWAMP		= Proto.AWT_TUNDER + 1	-- [天气类型]沼泽
Proto.AWT_SUN		= Proto.AWT_SWAMP + 1	-- [天气类型]晴天
Proto.PCT_FIRST		= 0						-- [宠物进化阶级类型]一阶
Proto.PCT_SECOND	= Proto.PCT_FIRST + 1	-- [宠物进化阶级类型]二阶
Proto.PCT_THIRD		= Proto.PCT_SECOND + 1	-- [宠物进化阶级类型]三阶
Proto.PCT_TOP		= Proto.PCT_THIRD + 1	-- [宠物进化阶级类型]完全体
Proto.AT_NONE			= 0							-- [属性类型]
Proto.AT_HP				= Proto.AT_NONE + 1			-- [属性类型]生命
Proto.AT_ATK			= Proto.AT_HP + 1			-- [属性类型]物攻
Proto.AT_DEF			= Proto.AT_ATK + 1			-- [属性类型]物防
Proto.AT_SATK			= Proto.AT_DEF + 1			-- [属性类型]魔攻
Proto.AT_SDEF			= Proto.AT_SATK + 1			-- [属性类型]魔防
Proto.AT_SPEED			= Proto.AT_SDEF + 1			-- [属性类型]速度
Proto.AT_RATE			= Proto.AT_SPEED + 1		-- [属性类型]命中
Proto.AT_EVD			= Proto.AT_RATE + 1			-- [属性类型]闪避
Proto.AT_DAMAGEREDUCE	= Proto.AT_EVD + 1			-- [属性类型]减伤
Proto.AT_CRT			= Proto.AT_DAMAGEREDUCE + 1	-- [属性类型]暴击
Proto.AT_SPECIAL		= Proto.AT_CRT + 1			-- [属性类型]特殊
Proto.AT_HP_Per			= Proto.AT_SPECIAL + 1		-- [属性类型]生命百分比
Proto.AT_ATK_Per		= Proto.AT_HP_Per + 1		-- [属性类型]物攻百分比
Proto.AT_DEF_Per		= Proto.AT_ATK_Per + 1		-- [属性类型]物防百分比
Proto.AT_SATK_Per		= Proto.AT_DEF_Per + 1		-- [属性类型]魔攻百分比
Proto.AT_SDEF_Per		= Proto.AT_SATK_Per + 1		-- [属性类型]魔防百分比
Proto.AT_SPEED_Per		= Proto.AT_SDEF_Per + 1		-- [属性类型]速度百分比
Proto.AT_CRTHURT		= Proto.AT_SPEED_Per + 1	-- [属性类型]爆伤
Proto.AT_RAGE			= Proto.AT_CRTHURT + 1		-- [属性类型]怒气
Proto.AT_ENERGY			= Proto.AT_RAGE + 1			-- [属性类型]能量
Proto.AT_HEALRATE		= Proto.AT_ENERGY + 1		-- [属性类型]治疗修正
Proto.AT_ANTICRT		= Proto.AT_HEALRATE + 1		-- [属性类型]暴击抵抗
Proto.AT_ANTIHURT		= Proto.AT_ANTICRT + 1		-- [属性类型]减伤
Proto.AT_SDEFFIX		= Proto.AT_ANTIHURT + 1		-- [属性类型]魔防修正
Proto.AT_DEFFIX			= Proto.AT_SDEFFIX + 1		-- [属性类型]物防修正
Proto.AT_PENETRATION	= Proto.AT_DEFFIX + 1		-- [属性类型]物理穿透
Proto.AT_SPENETRATION	= Proto.AT_PENETRATION + 1	-- [属性类型]魔法穿透
Proto.NTT_SELF			= 0								-- [天性目标类型]自己
Proto.NTT_ENEMY			= Proto.NTT_SELF + 1			-- [天性目标类型]敌人
Proto.NTT_BOTH			= Proto.NTT_ENEMY + 1			-- [天性目标类型]对敌利已
Proto.NTT_ENEMY_BYSELF	= Proto.NTT_BOTH + 1			-- [天性目标类型]以己制敌
Proto.NTT_ENEMY_BYSELF2	= Proto.NTT_ENEMY_BYSELF + 1	-- [天性目标类型]以己制敌2
Proto.NTT_BOTH_HURT		= Proto.NTT_ENEMY_BYSELF2 + 1	-- [天性目标类型]两败俱伤
Proto.NTT_MC			= Proto.NTT_BOTH_HURT + 1		-- [天性目标类型]特殊
Proto.NCW_ADD		= 0						-- [天性改变属性方式]增加
Proto.NCW_SUB		= Proto.NCW_ADD + 1		-- [天性改变属性方式]减少
Proto.NCW_IMMUNE	= Proto.NCW_SUB + 1		-- [天性改变属性方式]免疫
Proto.NCW_MC		= Proto.NCW_IMMUNE + 1	-- [天性改变属性方式]特殊
Proto.NCT_PERCENT	= 0						-- [天性改变属性类型]百分比
Proto.NCT_NUM		= Proto.NCT_PERCENT + 1	-- [天性改变属性类型]整数
Proto.NCT_MC		= Proto.NCT_NUM + 1		-- [天性改变属性类型]特殊
Proto.NDT_ATK	= 0						-- [天性触发时机]攻击时
Proto.NDT_DEF	= Proto.NDT_ATK + 1		-- [天性触发时机]防御时
Proto.NDT_ANY	= Proto.NDT_DEF + 1		-- [天性触发时机]不限
Proto.NDT_START	= Proto.NDT_ANY + 1		-- [天性触发时机]战斗开始时
Proto.NDT_DIE	= Proto.NDT_START + 1	-- [天性触发时机]死亡时
Proto.NDT_SHPLS	= Proto.NDT_DIE + 1		-- [天性触发时机]自生HP小于
Proto.NDT_EHPLS	= Proto.NDT_SHPLS + 1	-- [天性触发时机]敌人HP小于
Proto.NDT_SHPGT	= Proto.NDT_EHPLS + 1	-- [天性触发时机]自己HP大于等于
Proto.NDT_EHPGT	= Proto.NDT_SHPGT + 1	-- [天性触发时机]敌人HP大于等于
Proto.PC_NONECLASS	= 0							-- [宠物等阶]
Proto.PC_C			= Proto.PC_NONECLASS + 1	-- [宠物等阶]c级
Proto.PC_B			= Proto.PC_C + 1			-- [宠物等阶]b级
Proto.PC_A			= Proto.PC_B + 1			-- [宠物等阶]a级
Proto.PC_S			= Proto.PC_A + 1			-- [宠物等阶]s级
Proto.PC_SS			= Proto.PC_S + 1			-- [宠物等阶]ss级
Proto.PC_SSS		= Proto.PC_SS + 1			-- [宠物等阶]sss级
Proto.NOWNER_PET		= 0							-- [天性永远者]宠物
Proto.NOWNER_PETAIDE	= Proto.NOWNER_PET + 1		-- [天性永远者]伴灵
Proto.NOWNER_EQUIP		= Proto.NOWNER_PETAIDE + 1	-- [天性永远者]装备
Proto.NOWNER_AWAKE		= Proto.NOWNER_EQUIP + 1	-- [天性永远者]觉醒
Proto.AFFIX_SIXD_REFRESH	= 0	-- [宠物附加六维类型]刷新六维

function Proto.parseElementResistance(entry)
	local data={};
	data.element=Proto.parseVarArray(entry,Proto.parseshort,Proto.parseWORD); -- 元素抗性表
	return data;
end

function Proto.writeElementResistance(msg,data)
	Proto.writeVarArray(msg,data.element,Proto.writeshort,Proto.writeWORD); -- 元素抗性表
end

function Proto.parseConsumeItem(entry)
	local data={};
	data.type_id=Proto.parseDWORD(entry); -- 道具
	data.count=Proto.parseWORD(entry); -- 数量
	return data;
end

function Proto.writeConsumeItem(msg,data)
	Proto.writeDWORD(msg,data.type_id); -- 道具
	Proto.writeWORD(msg,data.count); -- 数量
end

function Proto.parseSkillParam(entry)
	local data={};
	data.index=Proto.parseBYTE(entry); -- 索引
	data.script=Proto.parseSkillParamScript(entry); -- 脚本
	return data;
end

function Proto.writeSkillParam(msg,data)
	Proto.writeBYTE(msg,data.index); -- 索引
	Proto.writeSkillParamScript(msg,data.script); -- 脚本
end

function Proto.parseCardSkill(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 卡片的道具类型ID
	data.skill_id=Proto.parseDWORD(entry); -- 技能ID
	data.minLevel=Proto.parseBYTE(entry); -- 最低等级
	data.sp=Proto.parseWORD(entry); -- 消耗SP
	data.pp=Proto.parseWORD(entry); -- 优先度
	data.skillLimit_mask=Proto.parseWORD(entry); -- 携带限制(MASK:SkillLimit)
	data.sideEffect=Proto.parseElementResistance(entry); -- 副作用
	data.warmUp=Proto.parseBYTE(entry); -- 预热回合数
	data.coolDown=Proto.parseBYTE(entry); -- 冷却回合数
	data.cost=Proto.parseBYTE(entry); -- 花费
	data.cardClass=Proto.parseBYTE(entry); -- 卡片阶位
	data.costItems=Proto.parseVector(entry,Proto.parseConsumeItem); -- 消耗道具类型
	data.paramScripts=Proto.parseVector(entry,Proto.parseSkillParam); -- 卡片技能参数
	return data;
end

function Proto.getCardSkillIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeCardSkill(msg,data)
	Proto.writeDWORD(msg,data.id); -- 卡片的道具类型ID
	Proto.writeDWORD(msg,data.skill_id); -- 技能ID
	Proto.writeBYTE(msg,data.minLevel); -- 最低等级
	Proto.writeWORD(msg,data.sp); -- 消耗SP
	Proto.writeWORD(msg,data.pp); -- 优先度
	Proto.writeWORD(msg,data.skillLimit_mask); -- 携带限制(MASK:SkillLimit)
	Proto.writeElementResistance(msg,data.sideEffect); -- 副作用
	Proto.writeBYTE(msg,data.warmUp); -- 预热回合数
	Proto.writeBYTE(msg,data.coolDown); -- 冷却回合数
	Proto.writeBYTE(msg,data.cost); -- 花费
	Proto.writeBYTE(msg,data.cardClass); -- 卡片阶位
	Proto.writeVector(msg,data.costItems,Proto.writeConsumeItem); -- 消耗道具类型
	Proto.writeVector(msg,data.paramScripts,Proto.writeSkillParam); -- 卡片技能参数
end

function Proto.parseCardDeck(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 套卡ID
	data.name=Proto.parseString(entry); -- 套卡名称
	data.cards=Proto.parseVarArray(entry,Proto.parseDWORD,Proto.parseWORD); -- 套卡卡片
	return data;
end

function Proto.getCardDeckIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeCardDeck(msg,data)
	Proto.writeDWORD(msg,data.id); -- 套卡ID
	Proto.writeString(msg,data.name); -- 套卡名称
	Proto.writeVarArray(msg,data.cards,Proto.writeDWORD,Proto.writeWORD); -- 套卡卡片
end

function Proto.parseLevelInfo(entry)
	local data={};
	data.id=Proto.parseWORD(entry); -- 等级
	data.totalExtraPoints=Proto.parseWORD(entry); -- 额外可加总点数
	data.experience=Proto.parseDWORD(entry); -- 所需经验值
	data.turnExtraExp=Proto.parseDWORD(entry); -- 转生附加经验
	return data;
end

function Proto.getLevelInfoIDLen()
	return Proto.getWORDLen();
end

function Proto.writeLevelInfo(msg,data)
	Proto.writeWORD(msg,data.id); -- 等级
	Proto.writeWORD(msg,data.totalExtraPoints); -- 额外可加总点数
	Proto.writeDWORD(msg,data.experience); -- 所需经验值
	Proto.writeDWORD(msg,data.turnExtraExp); -- 转生附加经验
end

function Proto.parseUnitRaceInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 编号
	data.name=Proto.parseUnitName(entry); -- 本名(种族名)
	data.petClass=Proto.parseBYTE(entry); -- 等阶
	data.heredity=Proto.parseBYTE(entry); -- 遗传类型
	data.raceHP=Proto.parseWORD(entry); -- 种族HP值
	data.raceSP=Proto.parseWORD(entry); -- 种族SP值
	data.racePP=Proto.parseWORD(entry); -- 种族PP值
	data.lightAttack=Proto.parseWORD(entry); -- 光攻
	data.lightDefence=Proto.parseWORD(entry); -- 光防
	data.darkAttack=Proto.parseWORD(entry); -- 暗攻
	data.darkDefence=Proto.parseWORD(entry); -- 暗防
	data.baseElementType=Proto.parseBYTE(entry); -- 基础属性
	data.auxiliaryElementType=Proto.parseBYTE(entry); -- 辅助属性
	data.baseAttackCastType=Proto.parseBYTE(entry); -- 普通攻击方式
	data.attackFloat=Proto.parseBYTE(entry); -- 攻击浮动率
	data.criticalRate=Proto.parseBYTE(entry); -- 致命率
	data.learnableSkillCards=Proto.parseVector(entry,Proto.parseDWORD); -- 可习得的技能卡
	data.albumAwardTabelID=Proto.parseDWORD(entry); -- 图鉴奖励
	data.usableGeneCoverItems=Proto.parseVector(entry,Proto.parseDWORD); -- 可使用的天性覆盖道具
	data.calorieToSaturation=Proto.parseRanaScript(entry); -- 卡路里到饷和度算法
	data.saturationToGrowth=Proto.parseRanaScript(entry); -- 饷和度到成长度算法
	data.onHungry=Proto.parseRanaScript(entry); -- 饥饿时寻找食物算法
	data.onSatiate=Proto.parseRanaScript(entry); -- 吃饱时后续行为算法
	return data;
end

function Proto.getUnitRaceInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeUnitRaceInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 编号
	Proto.writeUnitName(msg,data.name); -- 本名(种族名)
	Proto.writeBYTE(msg,data.petClass); -- 等阶
	Proto.writeBYTE(msg,data.heredity); -- 遗传类型
	Proto.writeWORD(msg,data.raceHP); -- 种族HP值
	Proto.writeWORD(msg,data.raceSP); -- 种族SP值
	Proto.writeWORD(msg,data.racePP); -- 种族PP值
	Proto.writeWORD(msg,data.lightAttack); -- 光攻
	Proto.writeWORD(msg,data.lightDefence); -- 光防
	Proto.writeWORD(msg,data.darkAttack); -- 暗攻
	Proto.writeWORD(msg,data.darkDefence); -- 暗防
	Proto.writeBYTE(msg,data.baseElementType); -- 基础属性
	Proto.writeBYTE(msg,data.auxiliaryElementType); -- 辅助属性
	Proto.writeBYTE(msg,data.baseAttackCastType); -- 普通攻击方式
	Proto.writeBYTE(msg,data.attackFloat); -- 攻击浮动率
	Proto.writeBYTE(msg,data.criticalRate); -- 致命率
	Proto.writeVector(msg,data.learnableSkillCards,Proto.writeDWORD); -- 可习得的技能卡
	Proto.writeDWORD(msg,data.albumAwardTabelID); -- 图鉴奖励
	Proto.writeVector(msg,data.usableGeneCoverItems,Proto.writeDWORD); -- 可使用的天性覆盖道具
	Proto.writeRanaScript(msg,data.calorieToSaturation); -- 卡路里到饷和度算法
	Proto.writeRanaScript(msg,data.saturationToGrowth); -- 饷和度到成长度算法
	Proto.writeRanaScript(msg,data.onHungry); -- 饥饿时寻找食物算法
	Proto.writeRanaScript(msg,data.onSatiate); -- 吃饱时后续行为算法
end

function Proto.parseEquipmentAttr(entry)
	local data={};
	data.attr=Proto.parseBYTE(entry); -- 属性
	data.beginValue=Proto.parseFloatString(entry); -- 初始值
	data.growValue=Proto.parseFloatString(entry); -- 成长值
	data.maxValue=Proto.parseFloatString(entry); -- 最大值
	return data;
end

function Proto.writeEquipmentAttr(msg,data)
	Proto.writeBYTE(msg,data.attr); -- 属性
	Proto.writeFloatString(msg,data.beginValue); -- 初始值
	Proto.writeFloatString(msg,data.growValue); -- 成长值
	Proto.writeFloatString(msg,data.maxValue); -- 最大值
end

function Proto.parseEquipmentInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 装备的道具类型ID
	data.part=Proto.parseBYTE(entry); -- 部位
	data.grade=Proto.parseWORD(entry); -- 品阶
	data.gradeUpID=Proto.parseDWORD(entry); -- 进阶后ID
	data.equipAttrs=Proto.parseVector(entry,Proto.parseEquipmentAttr); -- 装备属性
	data.beginStrengthen=Proto.parseDWORD(entry); -- 初始强化等级
	data.maxStrengthen=Proto.parseDWORD(entry); -- 最大强化等级
	data.gradeUpResource=Proto.parseVector(entry,Proto.parseDWORD); -- 强化材料
	return data;
end

function Proto.getEquipmentInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeEquipmentInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 装备的道具类型ID
	Proto.writeBYTE(msg,data.part); -- 部位
	Proto.writeWORD(msg,data.grade); -- 品阶
	Proto.writeDWORD(msg,data.gradeUpID); -- 进阶后ID
	Proto.writeVector(msg,data.equipAttrs,Proto.writeEquipmentAttr); -- 装备属性
	Proto.writeDWORD(msg,data.beginStrengthen); -- 初始强化等级
	Proto.writeDWORD(msg,data.maxStrengthen); -- 最大强化等级
	Proto.writeVector(msg,data.gradeUpResource,Proto.writeDWORD); -- 强化材料
end

function Proto.parseEquipmentStrInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 强化等级
	data.strMoneys=Proto.parseVector(entry,Proto.parseDWORD); -- 强化所需金币(绿蓝紫橙对应数组)
	return data;
end

function Proto.getEquipmentStrInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeEquipmentStrInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 强化等级
	Proto.writeVector(msg,data.strMoneys,Proto.writeDWORD); -- 强化所需金币(绿蓝紫橙对应数组)
end

function Proto.parseAttribAffixInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.rate=Proto.parseDWORD(entry); -- 类型权重
	data.affixType=Proto.parseDWORD(entry); -- 类型
	data.valueRanges=Proto.parseVector(entry,Proto.parseFloatString); -- 取值范围
	data.valueRates=Proto.parseVector(entry,Proto.parseDWORD); -- 取值权重
	return data;
end

function Proto.getAttribAffixInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeAttribAffixInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeDWORD(msg,data.rate); -- 类型权重
	Proto.writeDWORD(msg,data.affixType); -- 类型
	Proto.writeVector(msg,data.valueRanges,Proto.writeFloatString); -- 取值范围
	Proto.writeVector(msg,data.valueRates,Proto.writeDWORD); -- 取值权重
end

function Proto.parseEquipmentWashInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 洗练次数
	data.washStone=Proto.parseDWORD(entry); -- 消耗洗练石
	data.washMoney=Proto.parseDWORD(entry); -- 消耗金币
	data.returnRate=Proto.parseDWORD(entry); -- 返还比例
	data.hpRange=Proto.parseVector(entry,Proto.parseFloatString); -- 生命
	data.atkRange=Proto.parseVector(entry,Proto.parseFloatString); -- 物攻
	data.satkRange=Proto.parseVector(entry,Proto.parseFloatString); -- 魔攻
	data.defRange=Proto.parseVector(entry,Proto.parseFloatString); -- 物防
	data.sdefRange=Proto.parseVector(entry,Proto.parseFloatString); -- 魔防
	return data;
end

function Proto.getEquipmentWashInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeEquipmentWashInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 洗练次数
	Proto.writeDWORD(msg,data.washStone); -- 消耗洗练石
	Proto.writeDWORD(msg,data.washMoney); -- 消耗金币
	Proto.writeDWORD(msg,data.returnRate); -- 返还比例
	Proto.writeVector(msg,data.hpRange,Proto.writeFloatString); -- 生命
	Proto.writeVector(msg,data.atkRange,Proto.writeFloatString); -- 物攻
	Proto.writeVector(msg,data.satkRange,Proto.writeFloatString); -- 魔攻
	Proto.writeVector(msg,data.defRange,Proto.writeFloatString); -- 物防
	Proto.writeVector(msg,data.sdefRange,Proto.writeFloatString); -- 魔防
end

function Proto.parseAffixRandomGroup(entry)
	local data={};
	data.prob=Proto.parseDWORD(entry); -- 概率(千万分之一概率)
	data.affixID=Proto.parseAtrribAffixID(entry); -- 词缀编号
	return data;
end

function Proto.writeAffixRandomGroup(msg,data)
	Proto.writeDWORD(msg,data.prob); -- 概率(千万分之一概率)
	Proto.writeAtrribAffixID(msg,data.affixID); -- 词缀编号
end

function Proto.parseAffixGroupInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 词缀组编号
	data.name=Proto.parseString(entry); -- 词缀组名称
	data.groups=Proto.parseVector(entry,Proto.parseAffixRandomGroup); -- 词缀组
	return data;
end

function Proto.getAffixGroupInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeAffixGroupInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 词缀组编号
	Proto.writeString(msg,data.name); -- 词缀组名称
	Proto.writeVector(msg,data.groups,Proto.writeAffixRandomGroup); -- 词缀组
end

function Proto.parseNatureGeneState(entry)
	local data={};
	data.stateID=Proto.parseDWORD(entry); -- 天性状态ID
	data.powerScript=Proto.parseString(entry); -- 天性状态强度脚本
	return data;
end

function Proto.writeNatureGeneState(msg,data)
	Proto.writeDWORD(msg,data.stateID); -- 天性状态ID
	Proto.writeString(msg,data.powerScript); -- 天性状态强度脚本
end

function Proto.parseNatureGeneInfo(entry)
	local data={};
	data.id=Proto.parseWORD(entry); -- 编号
	data.name=Proto.parseString(entry); -- 天性名
	data.heredity=Proto.parseBYTE(entry); -- 遗传强度
	data.expression=Proto.parseBYTE(entry); -- 表达强度
	data.globalStates=Proto.parseVector(entry,Proto.parseNatureGeneState); -- 对应状态
	data.limitLevel=Proto.parseBYTE(entry); -- 限制等级
	data.isShow=Proto.parseBYTE(entry); -- 是否外观天性
	data.intercrossGeneID=Proto.parseWORD(entry); -- 杂交时的强制变更
	data.activeMinLevel=Proto.parseWORD(entry); -- 限制最低等级
	data.activeMaxLevel=Proto.parseWORD(entry); -- 限制最高等级
	return data;
end

function Proto.getNatureGeneInfoIDLen()
	return Proto.getWORDLen();
end

function Proto.writeNatureGeneInfo(msg,data)
	Proto.writeWORD(msg,data.id); -- 编号
	Proto.writeString(msg,data.name); -- 天性名
	Proto.writeBYTE(msg,data.heredity); -- 遗传强度
	Proto.writeBYTE(msg,data.expression); -- 表达强度
	Proto.writeVector(msg,data.globalStates,Proto.writeNatureGeneState); -- 对应状态
	Proto.writeBYTE(msg,data.limitLevel); -- 限制等级
	Proto.writeBYTE(msg,data.isShow); -- 是否外观天性
	Proto.writeWORD(msg,data.intercrossGeneID); -- 杂交时的强制变更
	Proto.writeWORD(msg,data.activeMinLevel); -- 限制最低等级
	Proto.writeWORD(msg,data.activeMaxLevel); -- 限制最高等级
end

function Proto.parseUnitNatureAllele(entry)
	local data={};
	data.geneID_a=Proto.parseWORD(entry); -- 基因编号a
	data.geneID_b=Proto.parseWORD(entry); -- 基因编号b
	data.level=Proto.parseBYTE(entry); -- 等级
	data.pos=Proto.parseBYTE(entry); -- 位置
	return data;
end

function Proto.writeUnitNatureAllele(msg,data)
	Proto.writeWORD(msg,data.geneID_a); -- 基因编号a
	Proto.writeWORD(msg,data.geneID_b); -- 基因编号b
	Proto.writeBYTE(msg,data.level); -- 等级
	Proto.writeBYTE(msg,data.pos); -- 位置
end

function Proto.parseUnitNatureGene(entry)
	local data={};
	data.alleles=Proto.parseVarArray(entry,Proto.parseUnitNatureAllele,Proto.parseWORD); -- 基因对
	return data;
end

function Proto.writeUnitNatureGene(msg,data)
	Proto.writeVarArray(msg,data.alleles,Proto.writeUnitNatureAllele,Proto.writeWORD); -- 基因对
end

function Proto.parseNatureInfo(entry)
	local data={};
	data.id=Proto.parseWORD(entry); -- 天性ID
	data.name=Proto.parseString(entry); -- 天性名称
	data.timing=Proto.parseBYTE(entry); -- 触发时机(NatureDispatchTiming)
	data.condition=Proto.parseString(entry); -- 触发条件
	data.ratio=Proto.parseWORD(entry); -- 触发几率
	data.target=Proto.parseBYTE(entry); -- 目标类型
	data.changeWay=Proto.parseBYTE(entry); -- 改变属性方式
	data.attrib=Proto.parseBYTE(entry); -- 属性类型
	data.changeType=Proto.parseBYTE(entry); -- 改变属性类型
	data.elementType=Proto.parseBYTE(entry); -- 元素类型
	data.value1=Proto.parseVector(entry,Proto.parseWORD); -- 属性值1
	data.value2=Proto.parseVector(entry,Proto.parseWORD); -- 属性值2
	data.value3=Proto.parseVector(entry,Proto.parseWORD); -- 属性值3
	data.value4=Proto.parseVector(entry,Proto.parseWORD); -- 属性值4
	data.value5=Proto.parseVector(entry,Proto.parseWORD); -- 属性值5
	data.rounds=Proto.parseWORD(entry); -- 持续回合数
	data.priority=Proto.parseint(entry); -- 优先级
	data.natureOwner=Proto.parseBYTE(entry); -- 拥有者
	data.script=Proto.parseString(entry); -- 脚本
	data.lonely=Proto.parseint(entry); -- 唯一
	return data;
end

function Proto.getNatureInfoIDLen()
	return Proto.getWORDLen();
end

function Proto.writeNatureInfo(msg,data)
	Proto.writeWORD(msg,data.id); -- 天性ID
	Proto.writeString(msg,data.name); -- 天性名称
	Proto.writeBYTE(msg,data.timing); -- 触发时机(NatureDispatchTiming)
	Proto.writeString(msg,data.condition); -- 触发条件
	Proto.writeWORD(msg,data.ratio); -- 触发几率
	Proto.writeBYTE(msg,data.target); -- 目标类型
	Proto.writeBYTE(msg,data.changeWay); -- 改变属性方式
	Proto.writeBYTE(msg,data.attrib); -- 属性类型
	Proto.writeBYTE(msg,data.changeType); -- 改变属性类型
	Proto.writeBYTE(msg,data.elementType); -- 元素类型
	Proto.writeVector(msg,data.value1,Proto.writeWORD); -- 属性值1
	Proto.writeVector(msg,data.value2,Proto.writeWORD); -- 属性值2
	Proto.writeVector(msg,data.value3,Proto.writeWORD); -- 属性值3
	Proto.writeVector(msg,data.value4,Proto.writeWORD); -- 属性值4
	Proto.writeVector(msg,data.value5,Proto.writeWORD); -- 属性值5
	Proto.writeWORD(msg,data.rounds); -- 持续回合数
	Proto.writeint(msg,data.priority); -- 优先级
	Proto.writeBYTE(msg,data.natureOwner); -- 拥有者
	Proto.writeString(msg,data.script); -- 脚本
	Proto.writeint(msg,data.lonely); -- 唯一
end

function Proto.parseImmunedObjectInfo(entry)
	local data={};
	data.effectID=Proto.parseWORD(entry); -- 被免天性ID
	data.target=Proto.parseBYTE(entry); -- 目标类型
	return data;
end

function Proto.writeImmunedObjectInfo(msg,data)
	Proto.writeWORD(msg,data.effectID); -- 被免天性ID
	Proto.writeBYTE(msg,data.target); -- 目标类型
end

function Proto.parseImmunedNatureExtraInfo(entry)
	local data={};
	data.id=Proto.parseWORD(entry); -- 免疫天性ID
	data.immunedObject=Proto.parseVector(entry,Proto.parseImmunedObjectInfo); -- 免疫对象
	return data;
end

function Proto.getImmunedNatureExtraInfoIDLen()
	return Proto.getWORDLen();
end

function Proto.writeImmunedNatureExtraInfo(msg,data)
	Proto.writeWORD(msg,data.id); -- 免疫天性ID
	Proto.writeVector(msg,data.immunedObject,Proto.writeImmunedObjectInfo); -- 免疫对象
end

function Proto.parseGeneProbability(entry)
	local data={};
	data.prob=Proto.parseDWORD(entry); -- 概率(千万分之一概率)
	data.natureGeneID=Proto.parseWORD(entry); -- 天性遗传信息编号
	return data;
end

function Proto.writeGeneProbability(msg,data)
	Proto.writeDWORD(msg,data.prob); -- 概率(千万分之一概率)
	Proto.writeWORD(msg,data.natureGeneID); -- 天性遗传信息编号
end

function Proto.parseGeneProbabilityGroupInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 词缀组编号
	data.geneGroup=Proto.parseVector(entry,Proto.parseGeneProbability); -- 基因概率
	return data;
end

function Proto.getGeneProbabilityGroupInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeGeneProbabilityGroupInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 词缀组编号
	Proto.writeVector(msg,data.geneGroup,Proto.writeGeneProbability); -- 基因概率
end

function Proto.parseGeneProbabilityPair(entry)
	local data={};
	data.probID_a=Proto.parseDWORD(entry); -- 基因概率组编号
	data.probID_b=Proto.parseDWORD(entry); -- 基因概率组编号
	return data;
end

function Proto.writeGeneProbabilityPair(msg,data)
	Proto.writeDWORD(msg,data.probID_a); -- 基因概率组编号
	Proto.writeDWORD(msg,data.probID_b); -- 基因概率组编号
end

function Proto.parseHeredityGeneInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 词缀组编号
	data.geneProbs=Proto.parseVarArray(entry,Proto.parseGeneProbabilityPair,Proto.parseWORD); -- 基因分布概率
	return data;
end

function Proto.getHeredityGeneInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeHeredityGeneInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 词缀组编号
	Proto.writeVarArray(msg,data.geneProbs,Proto.writeGeneProbabilityPair,Proto.writeWORD); -- 基因分布概率
end

function Proto.parseActiveAlleleItemInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 道具id
	data.type_id=Proto.parseDWORD(entry); -- 道具类型
	return data;
end

function Proto.getActiveAlleleItemInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeActiveAlleleItemInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 道具id
	Proto.writeDWORD(msg,data.type_id); -- 道具类型
end

function Proto.parseWarSkill(entry)
	local data={};
	data.id=Proto.parseWORD(entry); -- 战争技能id
	data.level=Proto.parseBYTE(entry); -- 等级
	data.exp=Proto.parseDWORD(entry); -- 技能经验
	return data;
end

function Proto.getWarSkillIDLen()
	return Proto.getWORDLen();
end

function Proto.writeWarSkill(msg,data)
	Proto.writeWORD(msg,data.id); -- 战争技能id
	Proto.writeBYTE(msg,data.level); -- 等级
	Proto.writeDWORD(msg,data.exp); -- 技能经验
end

function Proto.parsePetWarSkillInfo(entry)
	local data={};
	data.id=Proto.parseWORD(entry); -- 战争技能id
	data.maxLevel=Proto.parseBYTE(entry); -- 等级
	data.levelExp=Proto.parseVector(entry,Proto.parseDWORD); -- 技能经验表
	return data;
end

function Proto.getPetWarSkillInfoIDLen()
	return Proto.getWORDLen();
end

function Proto.writePetWarSkillInfo(msg,data)
	Proto.writeWORD(msg,data.id); -- 战争技能id
	Proto.writeBYTE(msg,data.maxLevel); -- 等级
	Proto.writeVector(msg,data.levelExp,Proto.writeDWORD); -- 技能经验表
end

function Proto.parseCharWarSkillInfo(entry)
	local data={};
	data.id=Proto.parseWORD(entry); -- 战争技能id
	data.maxLevel=Proto.parseBYTE(entry); -- 等级
	data.levelExp=Proto.parseVector(entry,Proto.parseDWORD); -- 技能经验表
	return data;
end

function Proto.getCharWarSkillInfoIDLen()
	return Proto.getWORDLen();
end

function Proto.writeCharWarSkillInfo(msg,data)
	Proto.writeWORD(msg,data.id); -- 战争技能id
	Proto.writeBYTE(msg,data.maxLevel); -- 等级
	Proto.writeVector(msg,data.levelExp,Proto.writeDWORD); -- 技能经验表
end

function Proto.parseCharWarInfo(entry)
	local data={};
	data.warSkills=Proto.parseVector(entry,Proto.parseWarSkill); -- 战争技能
	return data;
end

function Proto.writeCharWarInfo(msg,data)
	Proto.writeVector(msg,data.warSkills,Proto.writeWarSkill); -- 战争技能
end

function Proto.parsePetStrugglePillInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 道具id
	data.effect=Proto.parseBYTE(entry); -- 效果
	data.point=Proto.parseBYTE(entry); -- 努力点
	data.raceClass=Proto.parseVector(entry,Proto.parseBYTE); -- 进化阶级类型
	return data;
end

function Proto.getPetStrugglePillInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writePetStrugglePillInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 道具id
	Proto.writeBYTE(msg,data.effect); -- 效果
	Proto.writeBYTE(msg,data.point); -- 努力点
	Proto.writeVector(msg,data.raceClass,Proto.writeBYTE); -- 进化阶级类型
end

function Proto.parseMaxPill(entry)
	local data={};
	data.level=Proto.parseWORD(entry); -- 宠物等级
	data.maxPill=Proto.parseWORD(entry); -- 最大食用量
	return data;
end

function Proto.writeMaxPill(msg,data)
	Proto.writeWORD(msg,data.level); -- 宠物等级
	Proto.writeWORD(msg,data.maxPill); -- 最大食用量
end

function Proto.parsePetStruggleUseInfo(entry)
	local data={};
	data.id=Proto.parseBYTE(entry); -- 宠物进化阶级
	data.limit=Proto.parseVector(entry,Proto.parseMaxPill); -- 食用量限制
	return data;
end

function Proto.getPetStruggleUseInfoIDLen()
	return Proto.getBYTELen();
end

function Proto.writePetStruggleUseInfo(msg,data)
	Proto.writeBYTE(msg,data.id); -- 宠物进化阶级
	Proto.writeVector(msg,data.limit,Proto.writeMaxPill); -- 食用量限制
end

function Proto.parseMapBuff(entry)
	local data={};
	data.type=Proto.parseWORD(entry); -- 状态类型
	return data;
end

function Proto.writeMapBuff(msg,data)
	Proto.writeWORD(msg,data.type); -- 状态类型
end

function Proto.parseMapBuffInfo(entry)
	local data={};
	data.handle=Proto.parseRoleHandle(entry); -- 人物handle
	data.buffs=Proto.parseVector(entry,Proto.parseMapBuff); -- 状态
	return data;
end

function Proto.writeMapBuffInfo(msg,data)
	Proto.writeRoleHandle(msg,data.handle); -- 人物handle
	Proto.writeVector(msg,data.buffs,Proto.writeMapBuff); -- 状态
end

function Proto.parseCharEquipmentInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 装备的道具类型ID
	data.parts=Proto.parseVarArray(entry,Proto.parseBYTE,Proto.parseWORD); -- 可装备该道具的位置
	data.effects=Proto.parseVarArray(entry,Proto.parseBYTE,Proto.parseWORD); -- 影响属性(StruggleType)
	data.powerItems=Proto.parseVarArray(entry,Proto.parseDWORD,Proto.parseWORD); -- 可用强化道具
	data.achievement=Proto.parseWORD(entry); -- 要求成就点数
	return data;
end

function Proto.getCharEquipmentInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeCharEquipmentInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 装备的道具类型ID
	Proto.writeVarArray(msg,data.parts,Proto.writeBYTE,Proto.writeWORD); -- 可装备该道具的位置
	Proto.writeVarArray(msg,data.effects,Proto.writeBYTE,Proto.writeWORD); -- 影响属性(StruggleType)
	Proto.writeVarArray(msg,data.powerItems,Proto.writeDWORD,Proto.writeWORD); -- 可用强化道具
	Proto.writeWORD(msg,data.achievement); -- 要求成就点数
end

function Proto.parseEquipAffixComposeInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 装备的道具类型ID
	data.items=Proto.parseVector(entry,Proto.parseDWORD); -- 可使用强化道具
	return data;
end

function Proto.getEquipAffixComposeInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeEquipAffixComposeInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 装备的道具类型ID
	Proto.writeVector(msg,data.items,Proto.writeDWORD); -- 可使用强化道具
end

function Proto.parseEquipAffixComposeItemInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 道具类型ID
	data.affixGroups=Proto.parseVector(entry,Proto.parseDWORD); -- 可增加词缀组
	return data;
end

function Proto.getEquipAffixComposeItemInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeEquipAffixComposeItemInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 道具类型ID
	Proto.writeVector(msg,data.affixGroups,Proto.writeDWORD); -- 可增加词缀组
end

function Proto.parseCharLevelInfo(entry)
	local data={};
	data.id=Proto.parseWORD(entry); -- 等级
	data.exp=Proto.parseDWORD(entry); -- 累计经验
	return data;
end

function Proto.getCharLevelInfoIDLen()
	return Proto.getWORDLen();
end

function Proto.writeCharLevelInfo(msg,data)
	Proto.writeWORD(msg,data.id); -- 等级
	Proto.writeDWORD(msg,data.exp); -- 累计经验
end

function Proto.parseVIPLevelInfo(entry)
	local data={};
	data.id=Proto.parseWORD(entry); -- 等级
	data.exp=Proto.parseDWORD(entry); -- 累计充值数量
	data.arenaChallengeExtraTimes=Proto.parseBYTE(entry); -- 每日额外的竞技场挑战次数
	data.buyExpLimit=Proto.parseDWORD(entry); -- 每日购买经验限制
	data.clearFeedDailyLimit=Proto.parseDWORD(entry); -- 每日晴空伴灵饱食度上限
	data.petExperienceSoulExtra=Proto.parseDWORD(entry); -- 经验魂容量上限增加
	data.petTurnSoulExtra=Proto.parseDWORD(entry); -- 转生魂容量上限增加
	data.injectSoulExtra=Proto.parseDWORD(entry); -- 每日灵魂注入次数增加
	data.adventureResetTimes=Proto.parseDWORD(entry); -- 副本额外重置次数
	data.adventureResetBuyTimes=Proto.parseDWORD(entry); -- 副本额外重置购买次数
	data.adventureRebornBuyTimes=Proto.parseDWORD(entry); -- 副本额外复活购买次数
	return data;
end

function Proto.getVIPLevelInfoIDLen()
	return Proto.getWORDLen();
end

function Proto.writeVIPLevelInfo(msg,data)
	Proto.writeWORD(msg,data.id); -- 等级
	Proto.writeDWORD(msg,data.exp); -- 累计充值数量
	Proto.writeBYTE(msg,data.arenaChallengeExtraTimes); -- 每日额外的竞技场挑战次数
	Proto.writeDWORD(msg,data.buyExpLimit); -- 每日购买经验限制
	Proto.writeDWORD(msg,data.clearFeedDailyLimit); -- 每日晴空伴灵饱食度上限
	Proto.writeDWORD(msg,data.petExperienceSoulExtra); -- 经验魂容量上限增加
	Proto.writeDWORD(msg,data.petTurnSoulExtra); -- 转生魂容量上限增加
	Proto.writeDWORD(msg,data.injectSoulExtra); -- 每日灵魂注入次数增加
	Proto.writeDWORD(msg,data.adventureResetTimes); -- 副本额外重置次数
	Proto.writeDWORD(msg,data.adventureResetBuyTimes); -- 副本额外重置购买次数
	Proto.writeDWORD(msg,data.adventureRebornBuyTimes); -- 副本额外复活购买次数
end

function Proto.parseAffixSixDimensionalPoints(entry)
	local data={};
	data.id=Proto.parseWORD(entry); -- 类型
	data.points=Proto.parseVector(entry,Proto.parseint); -- 点数
	return data;
end

function Proto.getAffixSixDimensionalPointsIDLen()
	return Proto.getWORDLen();
end

function Proto.writeAffixSixDimensionalPoints(msg,data)
	Proto.writeWORD(msg,data.id); -- 类型
	Proto.writeVector(msg,data.points,Proto.writeint); -- 点数
end

function Proto.parseAttributeStarImproveItem(entry)
	local data={};
	data.value=Proto.parseDWORD(entry); -- 值
	data.proportion=Proto.parseDWORD(entry); -- 百分比
	return data;
end

function Proto.writeAttributeStarImproveItem(msg,data)
	Proto.writeDWORD(msg,data.value); -- 值
	Proto.writeDWORD(msg,data.proportion); -- 百分比
end

function Proto.parseAttributeStarImproveInfo(entry)
	local data={};
	data.id=Proto.parseWORD(entry); -- 属性类型
	data.starList=Proto.parseVector(entry,Proto.parseAttributeStarImproveItem); -- 星级列表
	return data;
end

function Proto.getAttributeStarImproveInfoIDLen()
	return Proto.getWORDLen();
end

function Proto.writeAttributeStarImproveInfo(msg,data)
	Proto.writeWORD(msg,data.id); -- 属性类型
	Proto.writeVector(msg,data.starList,Proto.writeAttributeStarImproveItem); -- 星级列表
end

