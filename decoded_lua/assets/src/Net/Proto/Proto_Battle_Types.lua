-- Net.Proto.Proto_Battle_Types

Proto.BTT_USER							= 0											-- [战斗目标类型]玩家
Proto.BTT_MONSTER						= Proto.BTT_USER + 1						-- [战斗目标类型]野怪
Proto.BTT_ADVENTURE_MONSTER				= Proto.BTT_MONSTER + 1						-- [战斗目标类型]副本怪物
Proto.BTT_ADVENTURE_MONSTER_MAN_GROUP	= Proto.BTT_ADVENTURE_MONSTER + 1			-- [战斗目标类型]副本训练师
Proto.BTT_ADVENTURE_MONSTER_GROUP		= Proto.BTT_ADVENTURE_MONSTER_MAN_GROUP + 1	-- [战斗目标类型]副本怪物组
Proto.BTT_MONSTER_MAN_GROUP				= Proto.BTT_ADVENTURE_MONSTER_GROUP + 1		-- [战斗目标类型]野怪训练师
Proto.BTT_MONSTER_GROUP					= Proto.BTT_MONSTER_MAN_GROUP + 1			-- [战斗目标类型]野怪组
Proto.BTT_EXPLORE_DIFFCULT_UNLOCK		= Proto.BTT_MONSTER_GROUP + 1				-- [战斗目标类型]挂机难度解锁战斗
Proto.BTT_EXPLORE_BOSS					= Proto.BTT_EXPLORE_DIFFCULT_UNLOCK + 1		-- [战斗目标类型]挂机BOSS战斗
Proto.BTT_ARENA							= Proto.BTT_EXPLORE_BOSS + 1				-- [战斗目标类型]竞技场
Proto.BTT_LOSTTOWER_MONSTER				= Proto.BTT_ARENA + 1						-- [战斗目标类型]迷失之塔野怪
Proto.BTT_LOSTTOWER_MONSTER_MAN_GROUP	= Proto.BTT_LOSTTOWER_MONSTER + 1			-- [战斗目标类型]迷失之塔野怪训练师
Proto.BTT_LOSTTOWER_BOSS				= Proto.BTT_LOSTTOWER_MONSTER_MAN_GROUP + 1	-- [战斗目标类型]迷失之塔boss
Proto.BTT_FAMILYQUEST_ARREST			= Proto.BTT_LOSTTOWER_BOSS + 1				-- [战斗目标类型]家族任务缉拿
Proto.BTT_FAMILYQUEST_PATROL			= Proto.BTT_FAMILYQUEST_ARREST + 1			-- [战斗目标类型]家族任务巡逻
Proto.BTT_FAMILYQUEST_MONSTER			= Proto.BTT_FAMILYQUEST_PATROL + 1			-- [战斗目标类型]家族任务珍兽
Proto.BTT_FAMILYDUNGEON_MONSTER			= Proto.BTT_FAMILYQUEST_MONSTER + 1			-- [战斗目标类型]家族副本怪物
Proto.BTT_TEAMDUNGEON_MONSTER			= Proto.BTT_FAMILYDUNGEON_MONSTER + 1		-- [战斗目标类型]组队副本怪物
Proto.BTT_LOSTTOWER_JUMP_BOSS			= Proto.BTT_TEAMDUNGEON_MONSTER + 1			-- [战斗目标类型]迷失之塔传送boss
Proto.BCT_PET		= 0					-- [战斗单元类型]宠物
Proto.BCT_MONSTER	= Proto.BCT_PET + 1	-- [战斗单元类型]怪物
Proto.BF_A	= 0					-- [战斗阵营]A方
Proto.BF_B	= Proto.BF_A + 1	-- [战斗阵营]B方
Proto.BATTLE_TYPE_NONE				= 0										-- [战斗触发类型]默认战斗类型
Proto.BATTLE_TYPE_ARENA				= Proto.BATTLE_TYPE_NONE + 1			-- [战斗触发类型]竞技场挑战
Proto.BATTLE_TYPE_STAGE				= Proto.BATTLE_TYPE_ARENA + 1			-- [战斗触发类型]挑战关卡
Proto.BATTLE_TYPE_FRIEND			= Proto.BATTLE_TYPE_STAGE + 1			-- [战斗触发类型]挑战好友
Proto.BATTLE_TYPE_BOSS				= Proto.BATTLE_TYPE_FRIEND + 1			-- [战斗触发类型]挑战BOSS
Proto.BATTLE_TYPE_POINT				= Proto.BATTLE_TYPE_BOSS + 1			-- [战斗触发类型]积分战
Proto.BATTLE_TYPE_CHAT				= Proto.BATTLE_TYPE_POINT + 1			-- [战斗触发类型]聊天战
Proto.BATTLE_TYPE_EVOLUTION			= Proto.BATTLE_TYPE_CHAT + 1			-- [战斗触发类型]进化战
Proto.BATTLE_TYPE_SINGLESTAGE		= Proto.BATTLE_TYPE_EVOLUTION + 1		-- [战斗触发类型]千里走单骑战
Proto.BATTLE_TYPE_STAGEARENA		= Proto.BATTLE_TYPE_SINGLESTAGE + 1		-- [战斗触发类型]擂台战
Proto.BATTLE_TYPE_ACTIVITY			= Proto.BATTLE_TYPE_STAGEARENA + 1		-- [战斗触发类型]活动万人斩战
Proto.BATTLE_TYPE_PET_RACE_ARENA	= Proto.BATTLE_TYPE_ACTIVITY + 1		-- [战斗触发类型]宠物单挑竞技场
Proto.BATTLE_TYPE_CROSSWORLD		= Proto.BATTLE_TYPE_PET_RACE_ARENA + 1	-- [战斗触发类型]跨服竞技场
Proto.BATTLE_TYPE_GALLANTS			= Proto.BATTLE_TYPE_CROSSWORLD + 1		-- [战斗触发类型]新擂台赛竞技场
Proto.BATTLE_TYPE_ADVENTURE			= Proto.BATTLE_TYPE_GALLANTS + 1		-- [战斗触发类型]新副本战斗
Proto.BATTLE_TYPE_STARSOUL			= Proto.BATTLE_TYPE_ADVENTURE + 1		-- [战斗触发类型]星魂殿战斗
Proto.CHANLLENAGE_USER_WIN		= 0									-- [挑战玩家日志结果]挑战玩家胜利
Proto.CHANLLENAGE_USER_LOST		= Proto.CHANLLENAGE_USER_WIN + 1	-- [挑战玩家日志结果]挑战玩家失败
Proto.CHANLLENAGE_USER_FAILED	= Proto.CHANLLENAGE_USER_LOST + 1	-- [挑战玩家日志结果]被玩家挑战成功
Proto.CHANLLENAGE_USER_MCASH	= 0									-- [挑战玩家每日奖励]M币
Proto.CHANLLENAGE_USER_GCASH	= Proto.CHANLLENAGE_USER_MCASH + 1	-- [挑战玩家每日奖励]G币
Proto.CHANLLENAGE_USER_EXP		= Proto.CHANLLENAGE_USER_GCASH + 1	-- [挑战玩家每日奖励]经验
Proto.BRT_STAGE_ARENA	= 0							-- [战斗记录类型]关卡擂台挑战
Proto.BRT_ARENA			= Proto.BRT_STAGE_ARENA + 1	-- [战斗记录类型]竞技场
Proto.PST_PASSIVE	= 0						-- [潜力技能触发类型]被动
Proto.PST_APPEAR	= Proto.PST_PASSIVE + 1	-- [潜力技能触发类型]登场

function Proto.parseBattleNatureInfo(entry)
	local data={};
	data.id=Proto.parseWORD(entry); -- 天性ID
	data.level=Proto.parseWORD(entry); -- 天性等级
	data.pos=Proto.parseWORD(entry); -- 天性位置
	return data;
end

function Proto.getBattleNatureInfoIDLen()
	return Proto.getWORDLen();
end

function Proto.writeBattleNatureInfo(msg,data)
	Proto.writeWORD(msg,data.id); -- 天性ID
	Proto.writeWORD(msg,data.level); -- 天性等级
	Proto.writeWORD(msg,data.pos); -- 天性位置
end

function Proto.parseBattleNature(entry)
	local data={};
	data.id=Proto.parseWORD(entry); -- 天性ID
	data.level=Proto.parseWORD(entry); -- 天性等级
	return data;
end

function Proto.getBattleNatureIDLen()
	return Proto.getWORDLen();
end

function Proto.writeBattleNature(msg,data)
	Proto.writeWORD(msg,data.id); -- 天性ID
	Proto.writeWORD(msg,data.level); -- 天性等级
end

function Proto.parseBattleTargetInfo(entry)
	local data={};
	data.type=Proto.parseBYTE(entry); -- 战斗目标类型BattleTargetType
	data.id=Proto.parseDWORD(entry); -- 战斗目标ID
	return data;
end

function Proto.getBattleTargetInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeBattleTargetInfo(msg,data)
	Proto.writeBYTE(msg,data.type); -- 战斗目标类型BattleTargetType
	Proto.writeDWORD(msg,data.id); -- 战斗目标ID
end

function Proto.parseBattleCell(entry)
	local data={};
	data.type=Proto.parseBYTE(entry); -- 战斗单元类型BattleCellType
	data.id=Proto.parseDWORD(entry); -- 战斗单元ID
	data.name=Proto.parseNickName(entry); -- 名称
	data.HP=Proto.parseDWORD(entry); -- 血量
	data.maxHP=Proto.parseDWORD(entry); -- 最大血量
	data.attack=Proto.parseDWORD(entry); -- 物理攻击
	data.defence=Proto.parseDWORD(entry); -- 物理防御
	data.mattack=Proto.parseDWORD(entry); -- 魔法攻击
	data.mdefence=Proto.parseDWORD(entry); -- 魔法防御
	data.critical=Proto.parseDWORD(entry); -- 暴击
	data.dodge=Proto.parseDWORD(entry); -- 闪避
	data.pos=Proto.parseBattlePos(entry); -- 战斗单元位置
	data.level=Proto.parseWORD(entry); -- 等级
	data.speed=Proto.parseDWORD(entry); -- 速度
	data.natures=Proto.parseVarArray(entry,Proto.parseBattleNatureInfo,Proto.parseWORD); -- 天性
	return data;
end

function Proto.getBattleCellIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeBattleCell(msg,data)
	Proto.writeBYTE(msg,data.type); -- 战斗单元类型BattleCellType
	Proto.writeDWORD(msg,data.id); -- 战斗单元ID
	Proto.writeNickName(msg,data.name); -- 名称
	Proto.writeDWORD(msg,data.HP); -- 血量
	Proto.writeDWORD(msg,data.maxHP); -- 最大血量
	Proto.writeDWORD(msg,data.attack); -- 物理攻击
	Proto.writeDWORD(msg,data.defence); -- 物理防御
	Proto.writeDWORD(msg,data.mattack); -- 魔法攻击
	Proto.writeDWORD(msg,data.mdefence); -- 魔法防御
	Proto.writeDWORD(msg,data.critical); -- 暴击
	Proto.writeDWORD(msg,data.dodge); -- 闪避
	Proto.writeBattlePos(msg,data.pos); -- 战斗单元位置
	Proto.writeWORD(msg,data.level); -- 等级
	Proto.writeDWORD(msg,data.speed); -- 速度
	Proto.writeVarArray(msg,data.natures,Proto.writeBattleNatureInfo,Proto.writeWORD); -- 天性
end

function Proto.parseBattleFactionInfo(entry)
	local data={};
	data.targetInfo=Proto.parseBattleTargetInfo(entry); -- 战斗目标信息
	data.equipInfo=Proto.parseVector(entry,Proto.parseItemUnit); -- 装备信息
	data.petAideInfo=Proto.parseVector(entry,Proto.parsePetAideDetailInfo_); -- 伴灵信息
	data.cells=Proto.parseVector(entry,Proto.parseBattleCell); -- 战斗单元信息
	return data;
end

function Proto.writeBattleFactionInfo(msg,data)
	Proto.writeBattleTargetInfo(msg,data.targetInfo); -- 战斗目标信息
	Proto.writeVector(msg,data.equipInfo,Proto.writeItemUnit); -- 装备信息
	Proto.writeVector(msg,data.petAideInfo,Proto.writePetAideDetailInfo_); -- 伴灵信息
	Proto.writeVector(msg,data.cells,Proto.writeBattleCell); -- 战斗单元信息
end

function Proto.parseBattleAttribute(entry)
	local data={};
	data.type=Proto.parseBYTE(entry); -- 类型NatureAttribType
	data.value=Proto.parseDWORD(entry); -- 值
	return data;
end

function Proto.writeBattleAttribute(msg,data)
	Proto.writeBYTE(msg,data.type); -- 类型NatureAttribType
	Proto.writeDWORD(msg,data.value); -- 值
end

function Proto.parseBattleRoundAttacker(entry)
	local data={};
	data.faction=Proto.parseBYTE(entry); -- 阵营
	data.pos=Proto.parseBattlePos(entry); -- 位置
	data.HP=Proto.parseint(entry); -- 血量
	data.natures=Proto.parseVector(entry,Proto.parseBattleNature); -- 天性
	data.changeValues=Proto.parseVector(entry,Proto.parseBattleAttribute); -- 变更的属性
	data.isCritical=Proto.parseBYTE(entry); -- 是否暴击
	return data;
end

function Proto.writeBattleRoundAttacker(msg,data)
	Proto.writeBYTE(msg,data.faction); -- 阵营
	Proto.writeBattlePos(msg,data.pos); -- 位置
	Proto.writeint(msg,data.HP); -- 血量
	Proto.writeVector(msg,data.natures,Proto.writeBattleNature); -- 天性
	Proto.writeVector(msg,data.changeValues,Proto.writeBattleAttribute); -- 变更的属性
	Proto.writeBYTE(msg,data.isCritical); -- 是否暴击
end

function Proto.parseBattleRoundDefender(entry)
	local data={};
	data.faction=Proto.parseBYTE(entry); -- 阵营
	data.pos=Proto.parseBattlePos(entry); -- 位置
	data.HP=Proto.parseint(entry); -- 血量
	data.natures=Proto.parseVector(entry,Proto.parseBattleNature); -- 天性
	data.changeValues=Proto.parseVector(entry,Proto.parseBattleAttribute); -- 变更的属性
	data.isDodge=Proto.parseBYTE(entry); -- 是否闪避
	return data;
end

function Proto.writeBattleRoundDefender(msg,data)
	Proto.writeBYTE(msg,data.faction); -- 阵营
	Proto.writeBattlePos(msg,data.pos); -- 位置
	Proto.writeint(msg,data.HP); -- 血量
	Proto.writeVector(msg,data.natures,Proto.writeBattleNature); -- 天性
	Proto.writeVector(msg,data.changeValues,Proto.writeBattleAttribute); -- 变更的属性
	Proto.writeBYTE(msg,data.isDodge); -- 是否闪避
end

function Proto.parseBattleRoundBuffer(entry)
	local data={};
	data.faction=Proto.parseBYTE(entry); -- 阵营
	data.pos=Proto.parseBattlePos(entry); -- 位置
	data.dmg=Proto.parseDWORD(entry); -- 伤害
	data.buffID=Proto.parseint(entry); -- BUFF
	return data;
end

function Proto.writeBattleRoundBuffer(msg,data)
	Proto.writeBYTE(msg,data.faction); -- 阵营
	Proto.writeBattlePos(msg,data.pos); -- 位置
	Proto.writeDWORD(msg,data.dmg); -- 伤害
	Proto.writeint(msg,data.buffID); -- BUFF
end

function Proto.parseBattleRound(entry)
	local data={};
	data.sn=Proto.parseWORD(entry); -- 回合号
	data.attacker=Proto.parseBattleRoundAttacker(entry); -- 攻击者
	data.defender=Proto.parseBattleRoundDefender(entry); -- 防御者
	return data;
end

function Proto.writeBattleRound(msg,data)
	Proto.writeWORD(msg,data.sn); -- 回合号
	Proto.writeBattleRoundAttacker(msg,data.attacker); -- 攻击者
	Proto.writeBattleRoundDefender(msg,data.defender); -- 防御者
end

function Proto.parseBattleResult(entry)
	local data={};
	data.winner=Proto.parseBYTE(entry); -- 赢家阵营
	return data;
end

function Proto.writeBattleResult(msg,data)
	Proto.writeBYTE(msg,data.winner); -- 赢家阵营
end

function Proto.parseChanllenageUserLog(entry)
	local data={};
	data.row_id=Proto.parseDWORD(entry); -- 日志编号
	data.opid=Proto.parseCharacterID(entry); -- 对手ID
	data.logTime=Proto.parseTIME_SEC(entry); -- 时间
	data.result=Proto.parseBYTE(entry); -- 结果ChanllenageUserLogResult
	return data;
end

function Proto.writeChanllenageUserLog(msg,data)
	Proto.writeDWORD(msg,data.row_id); -- 日志编号
	Proto.writeCharacterID(msg,data.opid); -- 对手ID
	Proto.writeTIME_SEC(msg,data.logTime); -- 时间
	Proto.writeBYTE(msg,data.result); -- 结果ChanllenageUserLogResult
end

function Proto.parseBattleUnitInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 单位ID(宠物ID/怪物ID)
	data.raceType=Proto.parseDWORD(entry); -- 种族
	data.name=Proto.parseNickName(entry); -- 名称
	data.selfAttrib=Proto.parseBYTE(entry); -- 个体值
	data.maxHP=Proto.parseDWORD(entry); -- 最大血量
	data.speed=Proto.parseDWORD(entry); -- 速度
	data.attack=Proto.parseDWORD(entry); -- 物理攻击
	data.defence=Proto.parseDWORD(entry); -- 物理防御
	data.mattack=Proto.parseDWORD(entry); -- 魔法攻击
	data.mdefence=Proto.parseDWORD(entry); -- 魔法防御
	data.baseElementType=Proto.parseBYTE(entry); -- 基本属性
	data.auxiliaryElementType=Proto.parseBYTE(entry); -- 辅助属性
	data.level=Proto.parseWORD(entry); -- 等级
	data.natures=Proto.parseVarArray(entry,Proto.parseBattleNatureInfo,Proto.parseWORD); -- 天性
	data.affixNatures=Proto.parseVarArray(entry,Proto.parseBattleNatureInfo,Proto.parseWORD); -- 附属天性
	data.curHp=Proto.parseDWORD(entry); -- 当前血量
	return data;
end

function Proto.getBattleUnitInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeBattleUnitInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 单位ID(宠物ID/怪物ID)
	Proto.writeDWORD(msg,data.raceType); -- 种族
	Proto.writeNickName(msg,data.name); -- 名称
	Proto.writeBYTE(msg,data.selfAttrib); -- 个体值
	Proto.writeDWORD(msg,data.maxHP); -- 最大血量
	Proto.writeDWORD(msg,data.speed); -- 速度
	Proto.writeDWORD(msg,data.attack); -- 物理攻击
	Proto.writeDWORD(msg,data.defence); -- 物理防御
	Proto.writeDWORD(msg,data.mattack); -- 魔法攻击
	Proto.writeDWORD(msg,data.mdefence); -- 魔法防御
	Proto.writeBYTE(msg,data.baseElementType); -- 基本属性
	Proto.writeBYTE(msg,data.auxiliaryElementType); -- 辅助属性
	Proto.writeWORD(msg,data.level); -- 等级
	Proto.writeVarArray(msg,data.natures,Proto.writeBattleNatureInfo,Proto.writeWORD); -- 天性
	Proto.writeVarArray(msg,data.affixNatures,Proto.writeBattleNatureInfo,Proto.writeWORD); -- 附属天性
	Proto.writeDWORD(msg,data.curHp); -- 当前血量
end

function Proto.parseBattleInitInfo(entry)
	local data={};
	data.target=Proto.parseBattleTargetInfo(entry); -- 战斗目标信息
	data.hasDetailInfo=Proto.parseBYTE(entry); -- 是否指定详细信息
	data.detailInfo=Proto.parseVarArray(entry,Proto.parseBattleUnitInfo,Proto.parseWORD); -- 详细信息
	return data;
end

function Proto.writeBattleInitInfo(msg,data)
	Proto.writeBattleTargetInfo(msg,data.target); -- 战斗目标信息
	Proto.writeBYTE(msg,data.hasDetailInfo); -- 是否指定详细信息
	Proto.writeVarArray(msg,data.detailInfo,Proto.writeBattleUnitInfo,Proto.writeWORD); -- 详细信息
end

function Proto.parseBattleInitInfoEx(entry)
	local data={};
	data.target=Proto.parseBattleTargetInfo(entry); -- 战斗目标信息
	data.hasDetailInfo=Proto.parseBYTE(entry); -- 是否指定详细信息
	data.detailInfo=Proto.parseVarArray(entry,Proto.parseBattleUnitInfo,Proto.parseWORD); -- 详细信息
	return data;
end

function Proto.writeBattleInitInfoEx(msg,data)
	Proto.writeBattleTargetInfo(msg,data.target); -- 战斗目标信息
	Proto.writeBYTE(msg,data.hasDetailInfo); -- 是否指定详细信息
	Proto.writeVarArray(msg,data.detailInfo,Proto.writeBattleUnitInfo,Proto.writeWORD); -- 详细信息
end

function Proto.parseSkillTemplateParamDefine(entry)
	local data={};
	data.desc=Proto.parseString(entry); -- 参数描述
	data.type=Proto.parseString(entry); -- 参数类型
	data.defaultValue=Proto.parseVector(entry,Proto.parseString); -- 默认值
	data.isForceValue=Proto.parseBYTE(entry); -- 是否强制
	return data;
end

function Proto.writeSkillTemplateParamDefine(msg,data)
	Proto.writeString(msg,data.desc); -- 参数描述
	Proto.writeString(msg,data.type); -- 参数类型
	Proto.writeVector(msg,data.defaultValue,Proto.writeString); -- 默认值
	Proto.writeBYTE(msg,data.isForceValue); -- 是否强制
end

function Proto.parseSkillTemplateInfo(entry)
	local data={};
	data.id=Proto.parseWORD(entry); -- 模板编号
	data.name=Proto.parseString(entry); -- 名称
	data.code=Proto.parseString(entry); -- 编码
	return data;
end

function Proto.getSkillTemplateInfoIDLen()
	return Proto.getWORDLen();
end

function Proto.writeSkillTemplateInfo(msg,data)
	Proto.writeWORD(msg,data.id); -- 模板编号
	Proto.writeString(msg,data.name); -- 名称
	Proto.writeString(msg,data.code); -- 编码
end

function Proto.parseSkillTemplateParamData(entry)
	local data={};
	data.name=Proto.parseString(entry); -- 参数描述
	data.datas=Proto.parseVector(entry,Proto.parseString); -- 值
	return data;
end

function Proto.writeSkillTemplateParamData(msg,data)
	Proto.writeString(msg,data.name); -- 参数描述
	Proto.writeVector(msg,data.datas,Proto.writeString); -- 值
end

function Proto.parseSkillTemplateData(entry)
	local data={};
	data.index=Proto.parseWORD(entry); -- index
	data.id=Proto.parseWORD(entry); -- 模板编号
	data.params=Proto.parseVector(entry,Proto.parseSkillTemplateParamData); -- 模板参数数据
	return data;
end

function Proto.getSkillTemplateDataIDLen()
	return Proto.getWORDLen();
end

function Proto.writeSkillTemplateData(msg,data)
	Proto.writeWORD(msg,data.index); -- index
	Proto.writeWORD(msg,data.id); -- 模板编号
	Proto.writeVector(msg,data.params,Proto.writeSkillTemplateParamData); -- 模板参数数据
end

function Proto.parseSkillTag(entry)
	local data={};
	data.index=Proto.parseBYTE(entry); -- index
	data.id=Proto.parseWORD(entry); -- 标签编号
	data.powers=Proto.parseVector(entry,Proto.parseBYTE); -- 技能等级对应强度
	return data;
end

function Proto.getSkillTagIDLen()
	return Proto.getWORDLen();
end

function Proto.writeSkillTag(msg,data)
	Proto.writeBYTE(msg,data.index); -- index
	Proto.writeWORD(msg,data.id); -- 标签编号
	Proto.writeVector(msg,data.powers,Proto.writeBYTE); -- 技能等级对应强度
end

function Proto.parseSkillInfo(entry)
	local data={};
	data.id=Proto.parseWORD(entry); -- 技能编号
	data.name=Proto.parseString(entry); -- 名称
	data.skillAtt=Proto.parseDWORD(entry); -- 技能属性
	data.skill_A_Type=Proto.parseDWORD(entry); -- 技能类型
	data.skill_B_Type=Proto.parseDWORD(entry); -- 技能分类
	data.skillTags=Proto.parseVector(entry,Proto.parseSkillTag); -- 技能标签
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
	data.triggerEvent=Proto.parseString(entry); -- 触发事件
	data.triggerRates=Proto.parseVector(entry,Proto.parseBYTE); -- 触发概率
	data.adjustRate=Proto.parseBYTE(entry); -- 总强度修正
	data.triggerCondition=Proto.parseString(entry); -- lang表触发时机描述
	data.triggerCondition2=Proto.parseString(entry); -- lang表触发时机描述2
	data.changeValue=Proto.parseString(entry); -- 变化值
	data.conditions=Proto.parseVector(entry,Proto.parseSkillTemplateData); -- 触发条件
	return data;
end

function Proto.getSkillInfoIDLen()
	return Proto.getWORDLen();
end

function Proto.writeSkillInfo(msg,data)
	Proto.writeWORD(msg,data.id); -- 技能编号
	Proto.writeString(msg,data.name); -- 名称
	Proto.writeDWORD(msg,data.skillAtt); -- 技能属性
	Proto.writeDWORD(msg,data.skill_A_Type); -- 技能类型
	Proto.writeDWORD(msg,data.skill_B_Type); -- 技能分类
	Proto.writeVector(msg,data.skillTags,Proto.writeSkillTag); -- 技能标签
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
	Proto.writeString(msg,data.triggerEvent); -- 触发事件
	Proto.writeVector(msg,data.triggerRates,Proto.writeBYTE); -- 触发概率
	Proto.writeBYTE(msg,data.adjustRate); -- 总强度修正
	Proto.writeString(msg,data.triggerCondition); -- lang表触发时机描述
	Proto.writeString(msg,data.triggerCondition2); -- lang表触发时机描述2
	Proto.writeString(msg,data.changeValue); -- 变化值
	Proto.writeVector(msg,data.conditions,Proto.writeSkillTemplateData); -- 触发条件
end

function Proto.parseBuffInfo(entry)
	local data={};
	data.id=Proto.parseWORD(entry); -- Buff编号
	data.name=Proto.parseString(entry); -- 名称
	data.desc=Proto.parseString(entry); -- 描述
	data.templates=Proto.parseVector(entry,Proto.parseSkillTemplateData); -- 技能模板
	data.tags=Proto.parseVector(entry,Proto.parseString); -- 技能标签
	return data;
end

function Proto.getBuffInfoIDLen()
	return Proto.getWORDLen();
end

function Proto.writeBuffInfo(msg,data)
	Proto.writeWORD(msg,data.id); -- Buff编号
	Proto.writeString(msg,data.name); -- 名称
	Proto.writeString(msg,data.desc); -- 描述
	Proto.writeVector(msg,data.templates,Proto.writeSkillTemplateData); -- 技能模板
	Proto.writeVector(msg,data.tags,Proto.writeString); -- 技能标签
end

function Proto.parseSkillTagTemplateInfo(entry)
	local data={};
	data.event=Proto.parseString(entry); -- 触发时机
	data.conditions=Proto.parseVector(entry,Proto.parseSkillTemplateData); -- 条件模板
	data.actions=Proto.parseVector(entry,Proto.parseSkillTemplateData); -- 功能模板
	return data;
end

function Proto.writeSkillTagTemplateInfo(msg,data)
	Proto.writeString(msg,data.event); -- 触发时机
	Proto.writeVector(msg,data.conditions,Proto.writeSkillTemplateData); -- 条件模板
	Proto.writeVector(msg,data.actions,Proto.writeSkillTemplateData); -- 功能模板
end

function Proto.parseSkillTagInfo(entry)
	local data={};
	data.id=Proto.parseWORD(entry); -- 标签编号
	data.name=Proto.parseString(entry); -- 名称
	data.effect=Proto.parseDWORD(entry); -- 效果表现
	data.descs=Proto.parseVector(entry,Proto.parseString); -- 描述
	data.icon=Proto.parseString(entry); -- 技能标签图标
	data.selfBuff=Proto.parseBYTE(entry); -- 是否加到自己身上
	data.hideBuff=Proto.parseBYTE(entry); -- 是否隐藏
	data.templates=Proto.parseVector(entry,Proto.parseSkillTagTemplateInfo); -- 模板
	data.tags=Proto.parseVector(entry,Proto.parseString); -- 技能标签
	data.groups=Proto.parseVector(entry,Proto.parseString); -- 技能分类
	return data;
end

function Proto.getSkillTagInfoIDLen()
	return Proto.getWORDLen();
end

function Proto.writeSkillTagInfo(msg,data)
	Proto.writeWORD(msg,data.id); -- 标签编号
	Proto.writeString(msg,data.name); -- 名称
	Proto.writeDWORD(msg,data.effect); -- 效果表现
	Proto.writeVector(msg,data.descs,Proto.writeString); -- 描述
	Proto.writeString(msg,data.icon); -- 技能标签图标
	Proto.writeBYTE(msg,data.selfBuff); -- 是否加到自己身上
	Proto.writeBYTE(msg,data.hideBuff); -- 是否隐藏
	Proto.writeVector(msg,data.templates,Proto.writeSkillTagTemplateInfo); -- 模板
	Proto.writeVector(msg,data.tags,Proto.writeString); -- 技能标签
	Proto.writeVector(msg,data.groups,Proto.writeString); -- 技能分类
end

function Proto.parsePotentialSkillInfo(entry)
	local data={};
	data.id=Proto.parseWORD(entry); -- 潜力ID
	data.skillID=Proto.parseWORD(entry); -- 技能ID
	data.type=Proto.parseBYTE(entry); -- 触发类型PotentialSkillTriggerType
	data.prob=Proto.parseDWORD(entry); -- 触发概率
	return data;
end

function Proto.getPotentialSkillInfoIDLen()
	return Proto.getWORDLen();
end

function Proto.writePotentialSkillInfo(msg,data)
	Proto.writeWORD(msg,data.id); -- 潜力ID
	Proto.writeWORD(msg,data.skillID); -- 技能ID
	Proto.writeBYTE(msg,data.type); -- 触发类型PotentialSkillTriggerType
	Proto.writeDWORD(msg,data.prob); -- 触发概率
end

function Proto.parseElementSkillInfo(entry)
	local data={};
	data.id=Proto.parseWORD(entry); -- 编号
	data.elementType=Proto.parseBYTE(entry); -- 基本属性PetAttriType
	data.skills=Proto.parseVector(entry,Proto.parseWORD); -- 技能列表
	return data;
end

function Proto.getElementSkillInfoIDLen()
	return Proto.getWORDLen();
end

function Proto.writeElementSkillInfo(msg,data)
	Proto.writeWORD(msg,data.id); -- 编号
	Proto.writeBYTE(msg,data.elementType); -- 基本属性PetAttriType
	Proto.writeVector(msg,data.skills,Proto.writeWORD); -- 技能列表
end

function Proto.parsePVPArenaGradeInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 编号
	data.gradeDown=Proto.parseDWORD(entry); -- 失败降杯
	data.gradeName=Proto.parseString(entry); -- 杯名
	data.startPoint=Proto.parseDWORD(entry); -- 下分段
	data.topPoint=Proto.parseDWORD(entry); -- 上分段
	data.watchPet=Proto.parseDWORD(entry); -- 杯显示宠物
	data.fixPointParam=Proto.parseDWORD(entry); -- 失败积分补偿系数
	data.rewardElement=Proto.parseVector(entry,Proto.parseDWORD); -- 奖励类型
	data.robotLevelRange=Proto.parseVector(entry,Proto.parseDWORD); -- 机器人等级区间
	data.robotInSecondRange=Proto.parseVector(entry,Proto.parseDWORD); -- 机器人插队秒数区间
	data.questPowerAwardNeed=Proto.parseDWORD(entry); -- 活跃度需求
	data.questPowerAwards=Proto.parseVector(entry,Proto.parseDWORD); -- 活跃度奖励
	data.questNum=Proto.parseDWORD(entry); -- 任务数量
	return data;
end

function Proto.getPVPArenaGradeInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writePVPArenaGradeInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 编号
	Proto.writeDWORD(msg,data.gradeDown); -- 失败降杯
	Proto.writeString(msg,data.gradeName); -- 杯名
	Proto.writeDWORD(msg,data.startPoint); -- 下分段
	Proto.writeDWORD(msg,data.topPoint); -- 上分段
	Proto.writeDWORD(msg,data.watchPet); -- 杯显示宠物
	Proto.writeDWORD(msg,data.fixPointParam); -- 失败积分补偿系数
	Proto.writeVector(msg,data.rewardElement,Proto.writeDWORD); -- 奖励类型
	Proto.writeVector(msg,data.robotLevelRange,Proto.writeDWORD); -- 机器人等级区间
	Proto.writeVector(msg,data.robotInSecondRange,Proto.writeDWORD); -- 机器人插队秒数区间
	Proto.writeDWORD(msg,data.questPowerAwardNeed); -- 活跃度需求
	Proto.writeVector(msg,data.questPowerAwards,Proto.writeDWORD); -- 活跃度奖励
	Proto.writeDWORD(msg,data.questNum); -- 任务数量
end

function Proto.parsePVPArenaQuestInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 任务ID
	data.grade=Proto.parseDWORD(entry); -- 大联盟段位ID
	data.cond=Proto.parseDWORD(entry); -- 条件
	data.questClass=Proto.parseDWORD(entry); -- 品级
	data.title=Proto.parseString(entry); -- 描述
	data.desc=Proto.parseString(entry); -- 描述
	data.questType=Proto.parseString(entry); -- 类型
	data.param1=Proto.parseDWORD(entry); -- 参数1
	data.param2=Proto.parseDWORD(entry); -- 参数2
	data.rewardElement=Proto.parseVector(entry,Proto.parseDWORD); -- 任务奖励
	data.rate=Proto.parseDWORD(entry); -- 权重
	return data;
end

function Proto.getPVPArenaQuestInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writePVPArenaQuestInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 任务ID
	Proto.writeDWORD(msg,data.grade); -- 大联盟段位ID
	Proto.writeDWORD(msg,data.cond); -- 条件
	Proto.writeDWORD(msg,data.questClass); -- 品级
	Proto.writeString(msg,data.title); -- 描述
	Proto.writeString(msg,data.desc); -- 描述
	Proto.writeString(msg,data.questType); -- 类型
	Proto.writeDWORD(msg,data.param1); -- 参数1
	Proto.writeDWORD(msg,data.param2); -- 参数2
	Proto.writeVector(msg,data.rewardElement,Proto.writeDWORD); -- 任务奖励
	Proto.writeDWORD(msg,data.rate); -- 权重
end

function Proto.parsePVPArenaRankAward(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 
	data.rankRange=Proto.parseVector(entry,Proto.parseDWORD); -- 
	data.mail=Proto.parseDWORD(entry); -- 
	data.rewardElement=Proto.parseVector(entry,Proto.parseDWORD); -- 品级
	return data;
end

function Proto.getPVPArenaRankAwardIDLen()
	return Proto.getDWORDLen();
end

function Proto.writePVPArenaRankAward(msg,data)
	Proto.writeDWORD(msg,data.id); -- 
	Proto.writeVector(msg,data.rankRange,Proto.writeDWORD); -- 
	Proto.writeDWORD(msg,data.mail); -- 
	Proto.writeVector(msg,data.rewardElement,Proto.writeDWORD); -- 品级
end

