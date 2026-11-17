-- Net.Proto.Proto_Adventure_Types

Proto.ACT_START		= 0							-- [副本格子类型]起点
Proto.ACT_TERMINAL	= Proto.ACT_START + 1		-- [副本格子类型]终点
Proto.ACT_EMPTY		= Proto.ACT_TERMINAL + 1	-- [副本格子类型]空格子
Proto.ACT_CHEST		= Proto.ACT_EMPTY + 1		-- [副本格子类型]宝箱格
Proto.ACT_MONSTER	= Proto.ACT_CHEST + 1		-- [副本格子类型]怪物格
Proto.ACS_UNINIT	= 0						-- [副本格子状态]未初始化
Proto.ACS_INITED	= Proto.ACS_UNINIT + 1	-- [副本格子状态]已初始化
Proto.ACS_PASSED	= Proto.ACS_INITED + 1	-- [副本格子状态]已通过
Proto.eMET_MonsterMan	= 0								-- [地图事件类型]野怪训练师
Proto.eMET_Monster		= Proto.eMET_MonsterMan + 1		-- [地图事件类型]野怪
Proto.eMET_PresentBox	= Proto.eMET_Monster + 1		-- [地图事件类型]礼盒
Proto.eMET_CollectPoint	= Proto.eMET_PresentBox + 1		-- [地图事件类型]采集点
Proto.eMET_NULL			= Proto.eMET_CollectPoint + 1	-- [地图事件类型]无

function Proto.parseADSkillInfo(entry)
	local data={};
	data.skillid=Proto.parseDWORD(entry); -- 技能ID
	data.skilllevel=Proto.parseBYTE(entry); -- 技能等级
	return data;
end

function Proto.writeADSkillInfo(msg,data)
	Proto.writeDWORD(msg,data.skillid); -- 技能ID
	Proto.writeBYTE(msg,data.skilllevel); -- 技能等级
end

function Proto.parseMonsterGroupManInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.groupCode=Proto.parseString(entry); -- 训练师代号
	data.name=Proto.parseString(entry); -- 训练师名字
	data.pokemons=Proto.parseVector(entry,Proto.parseDWORD); -- 携带宠物
	data.helperPokemons=Proto.parseVector(entry,Proto.parseDWORD); -- 携带宠物
	data.seniorFigure=Proto.parseString(entry); -- 立绘形象
	data.figure=Proto.parseString(entry); -- 形象
	data.dir=Proto.parseDWORD(entry); -- 朝向
	data.autoAttack=Proto.parseDWORD(entry); -- 主动出击
	data.patrol=Proto.parseVector(entry,Proto.parseDWORD); -- 巡逻路径
	data.commingTalk=Proto.parseString(entry); -- 巡逻路径
	data.deadTalk=Proto.parseString(entry); -- 巡逻路径
	data.exp=Proto.parseDWORD(entry); -- 经验
	data.levelClass=Proto.parseDWORD(entry); -- 等阶
	data.disappear=Proto.parseDWORD(entry); -- 消失
	return data;
end

function Proto.getMonsterGroupManInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeMonsterGroupManInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeString(msg,data.groupCode); -- 训练师代号
	Proto.writeString(msg,data.name); -- 训练师名字
	Proto.writeVector(msg,data.pokemons,Proto.writeDWORD); -- 携带宠物
	Proto.writeVector(msg,data.helperPokemons,Proto.writeDWORD); -- 携带宠物
	Proto.writeString(msg,data.seniorFigure); -- 立绘形象
	Proto.writeString(msg,data.figure); -- 形象
	Proto.writeDWORD(msg,data.dir); -- 朝向
	Proto.writeDWORD(msg,data.autoAttack); -- 主动出击
	Proto.writeVector(msg,data.patrol,Proto.writeDWORD); -- 巡逻路径
	Proto.writeString(msg,data.commingTalk); -- 巡逻路径
	Proto.writeString(msg,data.deadTalk); -- 巡逻路径
	Proto.writeDWORD(msg,data.exp); -- 经验
	Proto.writeDWORD(msg,data.levelClass); -- 等阶
	Proto.writeDWORD(msg,data.disappear); -- 消失
end

function Proto.parseFloorsize(entry)
	local data={};
	data.item=Proto.parseVector(entry,Proto.parseDWORD); -- 每层格数
	return data;
end

function Proto.writeFloorsize(msg,data)
	Proto.writeVector(msg,data.item,Proto.writeDWORD); -- 每层格数
end

function Proto.parseAdventureInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.name=Proto.parseString(entry); -- 副本名称
	data.prompt_1=Proto.parseString(entry); -- 副本提示1
	data.prompt_2=Proto.parseString(entry); -- 每层名称
	data.prompt_3=Proto.parseString(entry); -- 副本提示3
	data.floor=Proto.parseDWORD(entry); -- 副本层数
	data.scene=Proto.parseVector(entry,Proto.parseDWORD); -- 副本场景
	data.weather=Proto.parseVector(entry,Proto.parseDWORD); -- 副本天气
	data.Exp_rewards=Proto.parseDWORD(entry); -- 主角经验奖励
	data.prepose=Proto.parseDWORD(entry); -- 前置副本
	data.power=Proto.parseDWORD(entry); -- 体力消耗
	data.level=Proto.parseDWORD(entry); -- 主角等级要求
	data.type=Proto.parseDWORD(entry); -- 副本类型
	data.prop=Proto.parseString(entry); -- 进入道具需求
	data.prop_amount=Proto.parseDWORD(entry); -- 进入道具需求数
	data.resurgence=Proto.parseBYTE(entry); -- 是否可复活
	data.resurgence_cost=Proto.parseDWORD(entry); -- 复活代价
	data.target=Proto.parseVector(entry,Proto.parseDWORD); -- 副本目标
	data.target_parameter=Proto.parseString(entry); -- 副本目标参数
	data.rewards=Proto.parseDWORD(entry); -- 副本奖励
	data.rewards_Icon=Proto.parseString(entry); -- 副本通关奖励Icon
	data.diffcultType=Proto.parseDWORD(entry); -- 难度种类
	data.fightWarning=Proto.parseString(entry); -- 遇敌提醒
	data.floorsizes=Proto.parseVector(entry,Proto.parseFloorsize); -- 每层格数
	data.mapInfo=Proto.parseString(entry); -- 地图
	data.resetConsumeID=Proto.parseDWORD(entry); -- 重置消耗元素ID
	return data;
end

function Proto.getAdventureInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeAdventureInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeString(msg,data.name); -- 副本名称
	Proto.writeString(msg,data.prompt_1); -- 副本提示1
	Proto.writeString(msg,data.prompt_2); -- 每层名称
	Proto.writeString(msg,data.prompt_3); -- 副本提示3
	Proto.writeDWORD(msg,data.floor); -- 副本层数
	Proto.writeVector(msg,data.scene,Proto.writeDWORD); -- 副本场景
	Proto.writeVector(msg,data.weather,Proto.writeDWORD); -- 副本天气
	Proto.writeDWORD(msg,data.Exp_rewards); -- 主角经验奖励
	Proto.writeDWORD(msg,data.prepose); -- 前置副本
	Proto.writeDWORD(msg,data.power); -- 体力消耗
	Proto.writeDWORD(msg,data.level); -- 主角等级要求
	Proto.writeDWORD(msg,data.type); -- 副本类型
	Proto.writeString(msg,data.prop); -- 进入道具需求
	Proto.writeDWORD(msg,data.prop_amount); -- 进入道具需求数
	Proto.writeBYTE(msg,data.resurgence); -- 是否可复活
	Proto.writeDWORD(msg,data.resurgence_cost); -- 复活代价
	Proto.writeVector(msg,data.target,Proto.writeDWORD); -- 副本目标
	Proto.writeString(msg,data.target_parameter); -- 副本目标参数
	Proto.writeDWORD(msg,data.rewards); -- 副本奖励
	Proto.writeString(msg,data.rewards_Icon); -- 副本通关奖励Icon
	Proto.writeDWORD(msg,data.diffcultType); -- 难度种类
	Proto.writeString(msg,data.fightWarning); -- 遇敌提醒
	Proto.writeVector(msg,data.floorsizes,Proto.writeFloorsize); -- 每层格数
	Proto.writeString(msg,data.mapInfo); -- 地图
	Proto.writeDWORD(msg,data.resetConsumeID); -- 重置消耗元素ID
end

function Proto.parseSceneInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.number=Proto.parseDWORD(entry); -- 副本编号
	data.name=Proto.parseString(entry); -- 场景名称
	data.event=Proto.parseDWORD(entry); -- 事件表现
	data.eventType=Proto.parseDWORD(entry); -- 事件类型
	data.eventX=Proto.parseDWORD(entry); -- 事件X坐标
	data.eventY=Proto.parseDWORD(entry); -- 事件Y坐标
	data.floor=Proto.parseDWORD(entry); -- 层数
	data.fogRes=Proto.parseDWORD(entry); -- 迷雾资源
	data.terrRes=Proto.parseDWORD(entry); -- 地形资源
	data.isInitOpen=Proto.parseDWORD(entry); -- 初始通过
	data.award=Proto.parseDWORD(entry); -- 奖励
	data.target=Proto.parseString(entry); -- 目标方格
	data.probability=Proto.parseWORD(entry); -- 出现概率
	return data;
end

function Proto.getSceneInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeSceneInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeDWORD(msg,data.number); -- 副本编号
	Proto.writeString(msg,data.name); -- 场景名称
	Proto.writeDWORD(msg,data.event); -- 事件表现
	Proto.writeDWORD(msg,data.eventType); -- 事件类型
	Proto.writeDWORD(msg,data.eventX); -- 事件X坐标
	Proto.writeDWORD(msg,data.eventY); -- 事件Y坐标
	Proto.writeDWORD(msg,data.floor); -- 层数
	Proto.writeDWORD(msg,data.fogRes); -- 迷雾资源
	Proto.writeDWORD(msg,data.terrRes); -- 地形资源
	Proto.writeDWORD(msg,data.isInitOpen); -- 初始通过
	Proto.writeDWORD(msg,data.award); -- 奖励
	Proto.writeString(msg,data.target); -- 目标方格
	Proto.writeWORD(msg,data.probability); -- 出现概率
end

function Proto.parseMonstrosityInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.number=Proto.parseString(entry); -- 怪物编号
	data.level=Proto.parseVector(entry,Proto.parseDWORD); -- 怪物等级
	data.petnumber=Proto.parseDWORD(entry); -- 宠物编号
	data.petStage=Proto.parseDWORD(entry); -- 宠物阶数
	data.petStar=Proto.parseDWORD(entry); -- 宠物星数
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
	data.exp=Proto.parseDWORD(entry); -- 经验
	data.specialState=Proto.parseDWORD(entry); -- 皮肤
	return data;
end

function Proto.getMonstrosityInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeMonstrosityInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeString(msg,data.number); -- 怪物编号
	Proto.writeVector(msg,data.level,Proto.writeDWORD); -- 怪物等级
	Proto.writeDWORD(msg,data.petnumber); -- 宠物编号
	Proto.writeDWORD(msg,data.petStage); -- 宠物阶数
	Proto.writeDWORD(msg,data.petStar); -- 宠物星数
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
	Proto.writeDWORD(msg,data.exp); -- 经验
	Proto.writeDWORD(msg,data.specialState); -- 皮肤
end

function Proto.parseDBossInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.number=Proto.parseDWORD(entry); -- BOSS编号
	data.name=Proto.parseString(entry); -- BOSS名称
	data.skin=Proto.parseDWORD(entry); -- BOSS皮肤
	data.serial=Proto.parseDWORD(entry); -- BOSS宠物序号
	data.petNumber=Proto.parseDWORD(entry); -- BOSS宠物编号
	data.petLevel=Proto.parseDWORD(entry); -- BOSS宠物等级
	data.petSkill1=Proto.parseDWORD(entry); -- BOSS宠物技能1
	data.petSkill2=Proto.parseDWORD(entry); -- BOSS宠物技能2
	data.petSkill3=Proto.parseDWORD(entry); -- BOSS宠物技能3
	data.skill1_pro=Proto.parseDWORD(entry); -- BOSS宠物技能1发动概率
	data.skill2_pro=Proto.parseDWORD(entry); -- BOSS宠物技能2发动概率
	data.skill3_pro=Proto.parseDWORD(entry); -- BOSS宠物技能3发动概率
	data.prologue=Proto.parseString(entry); -- BOSS开场白
	data.closing=Proto.parseString(entry); -- BOSS结束语
	data.dropnumber=Proto.parseDWORD(entry); -- 掉落编号
	return data;
end

function Proto.getDBossInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeDBossInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeDWORD(msg,data.number); -- BOSS编号
	Proto.writeString(msg,data.name); -- BOSS名称
	Proto.writeDWORD(msg,data.skin); -- BOSS皮肤
	Proto.writeDWORD(msg,data.serial); -- BOSS宠物序号
	Proto.writeDWORD(msg,data.petNumber); -- BOSS宠物编号
	Proto.writeDWORD(msg,data.petLevel); -- BOSS宠物等级
	Proto.writeDWORD(msg,data.petSkill1); -- BOSS宠物技能1
	Proto.writeDWORD(msg,data.petSkill2); -- BOSS宠物技能2
	Proto.writeDWORD(msg,data.petSkill3); -- BOSS宠物技能3
	Proto.writeDWORD(msg,data.skill1_pro); -- BOSS宠物技能1发动概率
	Proto.writeDWORD(msg,data.skill2_pro); -- BOSS宠物技能2发动概率
	Proto.writeDWORD(msg,data.skill3_pro); -- BOSS宠物技能3发动概率
	Proto.writeString(msg,data.prologue); -- BOSS开场白
	Proto.writeString(msg,data.closing); -- BOSS结束语
	Proto.writeDWORD(msg,data.dropnumber); -- 掉落编号
end

function Proto.parseDropInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.dropnumber=Proto.parseString(entry); -- 掉落编号
	data.reNumber=Proto.parseVector(entry,Proto.parseDWORD); -- 奖池编号
	data.count=Proto.parseVector(entry,Proto.parseDWORD); -- 抽取次数
	data.ticket=Proto.parseDWORD(entry); -- 奖券支付
	data.nTicket=Proto.parseDWORD(entry); -- 奖券支付数
	return data;
end

function Proto.getDropInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeDropInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeString(msg,data.dropnumber); -- 掉落编号
	Proto.writeVector(msg,data.reNumber,Proto.writeDWORD); -- 奖池编号
	Proto.writeVector(msg,data.count,Proto.writeDWORD); -- 抽取次数
	Proto.writeDWORD(msg,data.ticket); -- 奖券支付
	Proto.writeDWORD(msg,data.nTicket); -- 奖券支付数
end

function Proto.parseRewardInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.number=Proto.parseString(entry); -- 奖池编号
	data.element=Proto.parseVector(entry,Proto.parseDWORD); -- 奖励元素
	data.nReward=Proto.parseVector(entry,Proto.parseDWORD); -- 奖励数
	data.probability=Proto.parseVector(entry,Proto.parseDWORD); -- 获得概率
	return data;
end

function Proto.getRewardInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeRewardInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeString(msg,data.number); -- 奖池编号
	Proto.writeVector(msg,data.element,Proto.writeDWORD); -- 奖励元素
	Proto.writeVector(msg,data.nReward,Proto.writeDWORD); -- 奖励数
	Proto.writeVector(msg,data.probability,Proto.writeDWORD); -- 获得概率
end

function Proto.parseEventInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.number=Proto.parseString(entry); -- 事件编号
	data.type=Proto.parseDWORD(entry); -- 事件类型
	data.eventA=Proto.parseString(entry); -- 事件参数A
	data.eventB=Proto.parseString(entry); -- 事件参数B
	data.eventC=Proto.parseString(entry); -- 事件参数C
	data.eventD=Proto.parseString(entry); -- 事件参数D
	data.eventE=Proto.parseString(entry); -- 事件参数E
	return data;
end

function Proto.getEventInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeEventInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeString(msg,data.number); -- 事件编号
	Proto.writeDWORD(msg,data.type); -- 事件类型
	Proto.writeString(msg,data.eventA); -- 事件参数A
	Proto.writeString(msg,data.eventB); -- 事件参数B
	Proto.writeString(msg,data.eventC); -- 事件参数C
	Proto.writeString(msg,data.eventD); -- 事件参数D
	Proto.writeString(msg,data.eventE); -- 事件参数E
end

function Proto.parseADMonsterInfo(entry)
	local data={};
	data.index=Proto.parseBYTE(entry); -- 出场顺序
	data.monsterName=Proto.parseZoic_StringForUnion_24_(entry); -- 怪物名称
	data.level=Proto.parseDWORD(entry); -- 怪物等级
	data.race=Proto.parseDWORD(entry); -- 怪物种族
	data.currentHp=Proto.parseDWORD(entry); -- 当前HP
	data.maxHp=Proto.parseDWORD(entry); -- 最大HP
	data.speed=Proto.parseDWORD(entry); -- 速度
	data.lightAttack=Proto.parseDWORD(entry); -- 光攻
	data.lightDefence=Proto.parseDWORD(entry); -- 光防
	data.darkAttack=Proto.parseDWORD(entry); -- 暗攻
	data.darkDefence=Proto.parseDWORD(entry); -- 暗攻
	data.skillList=Proto.parseVarArray(entry,Proto.parseADSkillInfo,Proto.parseWORD); -- 技能表
	return data;
end

function Proto.writeADMonsterInfo(msg,data)
	Proto.writeBYTE(msg,data.index); -- 出场顺序
	Proto.writeZoic_StringForUnion_24_(msg,data.monsterName); -- 怪物名称
	Proto.writeDWORD(msg,data.level); -- 怪物等级
	Proto.writeDWORD(msg,data.race); -- 怪物种族
	Proto.writeDWORD(msg,data.currentHp); -- 当前HP
	Proto.writeDWORD(msg,data.maxHp); -- 最大HP
	Proto.writeDWORD(msg,data.speed); -- 速度
	Proto.writeDWORD(msg,data.lightAttack); -- 光攻
	Proto.writeDWORD(msg,data.lightDefence); -- 光防
	Proto.writeDWORD(msg,data.darkAttack); -- 暗攻
	Proto.writeDWORD(msg,data.darkDefence); -- 暗攻
	Proto.writeVarArray(msg,data.skillList,Proto.writeADSkillInfo,Proto.writeWORD); -- 技能表
end

function Proto.parseDungeonGeneInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 索引
	data.geneId=Proto.parseDWORD(entry); -- 天性ID
	data.level=Proto.parseDWORD(entry); -- 天性等级
	data.elementType=Proto.parseDWORD(entry); -- 天性类型
	data.leastDifficult=Proto.parseDWORD(entry); -- 最低难度
	return data;
end

function Proto.getDungeonGeneInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeDungeonGeneInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 索引
	Proto.writeDWORD(msg,data.geneId); -- 天性ID
	Proto.writeDWORD(msg,data.level); -- 天性等级
	Proto.writeDWORD(msg,data.elementType); -- 天性类型
	Proto.writeDWORD(msg,data.leastDifficult); -- 最低难度
end

function Proto.parsePetSkillDetailInfo(entry)
	local data={};
	data.level=Proto.parseDWORD(entry); -- 等级
	data.geneSkillId=Proto.parseDWORD(entry); -- 技能ID
	data.geneSkillLevel=Proto.parseDWORD(entry); -- 技能等级
	return data;
end

function Proto.writePetSkillDetailInfo(msg,data)
	Proto.writeDWORD(msg,data.level); -- 等级
	Proto.writeDWORD(msg,data.geneSkillId); -- 技能ID
	Proto.writeDWORD(msg,data.geneSkillLevel); -- 技能等级
end

function Proto.parseBossHp(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.hp=Proto.parseDWORD(entry); -- 剩余hp
	return data;
end

function Proto.getBossHpIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeBossHp(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeDWORD(msg,data.hp); -- 剩余hp
end

function Proto.parseDungeonPetSkillInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 技能组ID
	data.detailInfos=Proto.parseVector(entry,Proto.parsePetSkillDetailInfo); -- 技能具体信息
	return data;
end

function Proto.getDungeonPetSkillInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeDungeonPetSkillInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 技能组ID
	Proto.writeVector(msg,data.detailInfos,Proto.writePetSkillDetailInfo); -- 技能具体信息
end

function Proto.parseEquipSkillInfo(entry)
	local data={};
	data.skillId=Proto.parseDWORD(entry); -- 装备技能ID
	data.skillLevel=Proto.parseDWORD(entry); -- 装备技能等级
	return data;
end

function Proto.writeEquipSkillInfo(msg,data)
	Proto.writeDWORD(msg,data.skillId); -- 装备技能ID
	Proto.writeDWORD(msg,data.skillLevel); -- 装备技能等级
end

function Proto.parseDungeonEquipSkillInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 索引
	data.equipGroupName=Proto.parseUnitName(entry); -- 技能组名
	data.equipSkillType=Proto.parseDWORD(entry); -- 技能类型
	data.leastFloor=Proto.parseDWORD(entry); -- 最小层数
	data.skillListInfo=Proto.parseVector(entry,Proto.parseEquipSkillInfo); -- 技能具体信息
	return data;
end

function Proto.getDungeonEquipSkillInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeDungeonEquipSkillInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 索引
	Proto.writeUnitName(msg,data.equipGroupName); -- 技能组名
	Proto.writeDWORD(msg,data.equipSkillType); -- 技能类型
	Proto.writeDWORD(msg,data.leastFloor); -- 最小层数
	Proto.writeVector(msg,data.skillListInfo,Proto.writeEquipSkillInfo); -- 技能具体信息
end

function Proto.parseDungeonAwardsInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 索引
	data.awardsType=Proto.parseDWORD(entry); -- 奖励类别，1:宝箱,2:怪物,3:BOSS
	data.floor=Proto.parseDWORD(entry); -- 层数
	data.awardsLevel=Proto.parseDWORD(entry); -- 奖励等级
	data.awardsId=Proto.parseDWORD(entry); -- 对应的奖励组ID
	return data;
end

function Proto.getDungeonAwardsInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeDungeonAwardsInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 索引
	Proto.writeDWORD(msg,data.awardsType); -- 奖励类别，1:宝箱,2:怪物,3:BOSS
	Proto.writeDWORD(msg,data.floor); -- 层数
	Proto.writeDWORD(msg,data.awardsLevel); -- 奖励等级
	Proto.writeDWORD(msg,data.awardsId); -- 对应的奖励组ID
end

function Proto.parseCharacterAdventureInfo(entry)
	local data={};
	data.highestLevel=Proto.parseDWORD(entry); -- 最高层数
	data.totalLevel=Proto.parseDWORD(entry); -- 总层数
	data.currentLevel=Proto.parseDWORD(entry); -- 当前层数
	data.resetTimes=Proto.parseDWORD(entry); -- 已经重置次数
	data.rebornTimes=Proto.parseDWORD(entry); -- 已经复活次数(用int为了防止错误)
	data.rebornBuyTimes=Proto.parseDWORD(entry); -- 已经复活购买次数
	data.resetBuyTimes=Proto.parseDWORD(entry); -- 已经重置购买次数
	data.currentGird=Proto.parseDWORD(entry); -- 当前所处格子
	data.isDead=Proto.parseBYTE(entry); -- 是否活着
	data.startGird=Proto.parseWORD(entry); -- 起点索引
	data.finalGird=Proto.parseWORD(entry); -- 终点索引
	data.deadline=Proto.parseTIME_SEC(entry); -- 过期时间
	data.passGird=Proto.parseVector(entry,Proto.parseWORD); -- 已经走过的格子
	data.girdState=Proto.parseVector(entry,Proto.parseBYTE); -- 格子状态 1为走过了 0未走过
	return data;
end

function Proto.writeCharacterAdventureInfo(msg,data)
	Proto.writeDWORD(msg,data.highestLevel); -- 最高层数
	Proto.writeDWORD(msg,data.totalLevel); -- 总层数
	Proto.writeDWORD(msg,data.currentLevel); -- 当前层数
	Proto.writeDWORD(msg,data.resetTimes); -- 已经重置次数
	Proto.writeDWORD(msg,data.rebornTimes); -- 已经复活次数(用int为了防止错误)
	Proto.writeDWORD(msg,data.rebornBuyTimes); -- 已经复活购买次数
	Proto.writeDWORD(msg,data.resetBuyTimes); -- 已经重置购买次数
	Proto.writeDWORD(msg,data.currentGird); -- 当前所处格子
	Proto.writeBYTE(msg,data.isDead); -- 是否活着
	Proto.writeWORD(msg,data.startGird); -- 起点索引
	Proto.writeWORD(msg,data.finalGird); -- 终点索引
	Proto.writeTIME_SEC(msg,data.deadline); -- 过期时间
	Proto.writeVector(msg,data.passGird,Proto.writeWORD); -- 已经走过的格子
	Proto.writeVector(msg,data.girdState,Proto.writeBYTE); -- 格子状态 1为走过了 0未走过
end

function Proto.parseAdventrueCell_Data_Start(entry)
	local data={};
	return data;
end

function Proto.writeAdventrueCell_Data_Start(msg,data)
end

function Proto.parseAdventrueCell_Data_Terminal(entry)
	local data={};
	data.difficult=Proto.parseVarArray(entry,Proto.parseBYTE,Proto.parseWORD); -- 难度数据
	data.bossInfo=Proto.parseVarArray(entry,Proto.parseADMonsterInfo,Proto.parseWORD); -- Boss信息
	return data;
end

function Proto.writeAdventrueCell_Data_Terminal(msg,data)
	Proto.writeVarArray(msg,data.difficult,Proto.writeBYTE,Proto.writeWORD); -- 难度数据
	Proto.writeVarArray(msg,data.bossInfo,Proto.writeADMonsterInfo,Proto.writeWORD); -- Boss信息
end

function Proto.parseAdventrueCell_Data_Empty(entry)
	local data={};
	return data;
end

function Proto.writeAdventrueCell_Data_Empty(msg,data)
end

function Proto.parseAdventrueCell_Data_Chest(entry)
	local data={};
	data.difficult=Proto.parseBYTE(entry); -- 难度数据
	return data;
end

function Proto.writeAdventrueCell_Data_Chest(msg,data)
	Proto.writeBYTE(msg,data.difficult); -- 难度数据
end

function Proto.parseAdventrueCell_Data_Monster(entry)
	local data={};
	data.difficult=Proto.parseVarArray(entry,Proto.parseBYTE,Proto.parseWORD); -- 难度数据
	data.monsterInfo=Proto.parseVarArray(entry,Proto.parseADMonsterInfo,Proto.parseWORD); -- 怪物信息
	return data;
end

function Proto.writeAdventrueCell_Data_Monster(msg,data)
	Proto.writeVarArray(msg,data.difficult,Proto.writeBYTE,Proto.writeWORD); -- 难度数据
	Proto.writeVarArray(msg,data.monsterInfo,Proto.writeADMonsterInfo,Proto.writeWORD); -- 怪物信息
end

function Proto.parseAdventrueCell(entry)
	local data={};
	data.index=Proto.parseWORD(entry); -- 格子索引
	data.type=Proto.parseBYTE(entry); -- 格子类型,AdventureCellType
	data.state=Proto.parseBYTE(entry); -- 格子状态,AdventureCellState
	data.data={}; -- 格子数据
	if (data.type==Proto.ACT_START) then
		data.data.start=Proto.parseAdventrueCell_Data_Start(entry); -- 起点
	end
	if (data.type==Proto.ACT_TERMINAL) then
		data.data.terminal=Proto.parseAdventrueCell_Data_Terminal(entry); -- 终点
	end
	if (data.type==Proto.ACT_EMPTY) then
		data.data.empty=Proto.parseAdventrueCell_Data_Empty(entry); -- 空格子
	end
	if (data.type==Proto.ACT_CHEST) then
		data.data.chest=Proto.parseAdventrueCell_Data_Chest(entry); -- 宝箱格
	end
	if (data.type==Proto.ACT_MONSTER) then
		data.data.monster=Proto.parseAdventrueCell_Data_Monster(entry); -- 怪物格
	end
	return data;
end

function Proto.writeAdventrueCell(msg,data)
	Proto.writeWORD(msg,data.index); -- 格子索引
	Proto.writeBYTE(msg,data.type); -- 格子类型,AdventureCellType
	Proto.writeBYTE(msg,data.state); -- 格子状态,AdventureCellState
	if (data.type==Proto.ACT_START) then
		Proto.writeAdventrueCell_Data_Start(msg,data.data.start); -- 起点
	end
	if (data.type==Proto.ACT_TERMINAL) then
		Proto.writeAdventrueCell_Data_Terminal(msg,data.data.terminal); -- 终点
	end
	if (data.type==Proto.ACT_EMPTY) then
		Proto.writeAdventrueCell_Data_Empty(msg,data.data.empty); -- 空格子
	end
	if (data.type==Proto.ACT_CHEST) then
		Proto.writeAdventrueCell_Data_Chest(msg,data.data.chest); -- 宝箱格
	end
	if (data.type==Proto.ACT_MONSTER) then
		Proto.writeAdventrueCell_Data_Monster(msg,data.data.monster); -- 怪物格
	end
end

function Proto.parseEventNode(entry)
	local data={};
	data.nodeIndex=Proto.parseDWORD(entry); -- 地图点的编号
	data.eventVec=Proto.parseVector(entry,Proto.parseDWORD); -- 事件
	data.collectEventVec=Proto.parseVector(entry,Proto.parseDWORD); -- 采集事件
	data.mapLock=Proto.parseDWORD(entry); -- 解锁条件
	return data;
end

function Proto.writeEventNode(msg,data)
	Proto.writeDWORD(msg,data.nodeIndex); -- 地图点的编号
	Proto.writeVector(msg,data.eventVec,Proto.writeDWORD); -- 事件
	Proto.writeVector(msg,data.collectEventVec,Proto.writeDWORD); -- 采集事件
	Proto.writeDWORD(msg,data.mapLock); -- 解锁条件
end

function Proto.parseMapNodeInfo(entry)
	local data={};
	data.id=Proto.parseWORD(entry); -- 大地图编号
	data.EventNodeVec=Proto.parseVector(entry,Proto.parseEventNode); -- 事件小节点集合
	return data;
end

function Proto.getMapNodeInfoIDLen()
	return Proto.getWORDLen();
end

function Proto.writeMapNodeInfo(msg,data)
	Proto.writeWORD(msg,data.id); -- 大地图编号
	Proto.writeVector(msg,data.EventNodeVec,Proto.writeEventNode); -- 事件小节点集合
end

function Proto.parseMapEventInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.eventType=Proto.parseWORD(entry); -- 事件类型
	data.eventObjID=Proto.parseDWORD(entry); -- 事件对象
	data.eventAward=Proto.parseDWORD(entry); -- 奖励
	data.eventRate=Proto.parseWORD(entry); -- 权重
	return data;
end

function Proto.getMapEventInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeMapEventInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeWORD(msg,data.eventType); -- 事件类型
	Proto.writeDWORD(msg,data.eventObjID); -- 事件对象
	Proto.writeDWORD(msg,data.eventAward); -- 奖励
	Proto.writeWORD(msg,data.eventRate); -- 权重
end

function Proto.parseNodeRandEvent(entry)
	local data={};
	data.mapIndex=Proto.parseWORD(entry); -- 大地图索引
	data.nodeIndex=Proto.parseDWORD(entry); -- 小节点索引
	data.eventIndex=Proto.parseDWORD(entry); -- 事件索引
	return data;
end

function Proto.writeNodeRandEvent(msg,data)
	Proto.writeWORD(msg,data.mapIndex); -- 大地图索引
	Proto.writeDWORD(msg,data.nodeIndex); -- 小节点索引
	Proto.writeDWORD(msg,data.eventIndex); -- 事件索引
end

function Proto.parseDisposableInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.eventType=Proto.parseDWORD(entry); -- 事件类型
	data.eventRandomID=Proto.parseDWORD(entry); -- 事件表现
	data.finishEvent=Proto.parseDWORD(entry); -- 结束后事件类型
	data.finishEventType=Proto.parseDWORD(entry); -- 结束后事件表现
	data.conditionID=Proto.parseDWORD(entry); -- 触发条件ID
	return data;
end

function Proto.getDisposableInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeDisposableInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeDWORD(msg,data.eventType); -- 事件类型
	Proto.writeDWORD(msg,data.eventRandomID); -- 事件表现
	Proto.writeDWORD(msg,data.finishEvent); -- 结束后事件类型
	Proto.writeDWORD(msg,data.finishEventType); -- 结束后事件表现
	Proto.writeDWORD(msg,data.conditionID); -- 触发条件ID
end

function Proto.parseEventNpcInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.type=Proto.parseDWORD(entry); -- NPC类型
	data.param1=Proto.parseDWORD(entry); -- 参数1
	data.param2=Proto.parseDWORD(entry); -- 参数2
	return data;
end

function Proto.getEventNpcInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeEventNpcInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeDWORD(msg,data.type); -- NPC类型
	Proto.writeDWORD(msg,data.param1); -- 参数1
	Proto.writeDWORD(msg,data.param2); -- 参数2
end

function Proto.parseNpcShopList(entry)
	local data={};
	data.itemID=Proto.parseDWORD(entry); -- 商品奖励元素ID
	data.type=Proto.parseDWORD(entry); -- 消费类型
	data.price=Proto.parseDWORD(entry); -- 价格
	data.number=Proto.parseDWORD(entry); -- 购买数量
	data.count=Proto.parseDWORD(entry); -- 购买次数
	data.weigth=Proto.parseDWORD(entry); -- 权重
	return data;
end

function Proto.writeNpcShopList(msg,data)
	Proto.writeDWORD(msg,data.itemID); -- 商品奖励元素ID
	Proto.writeDWORD(msg,data.type); -- 消费类型
	Proto.writeDWORD(msg,data.price); -- 价格
	Proto.writeDWORD(msg,data.number); -- 购买数量
	Proto.writeDWORD(msg,data.count); -- 购买次数
	Proto.writeDWORD(msg,data.weigth); -- 权重
end

function Proto.parseNpcBusinessmanInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.npcShop=Proto.parseVector(entry,Proto.parseNpcShopList); -- 商品列表
	return data;
end

function Proto.getNpcBusinessmanInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeNpcBusinessmanInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeVector(msg,data.npcShop,Proto.writeNpcShopList); -- 商品列表
end

function Proto.parseRandomDetail(entry)
	local data={};
	data.event=Proto.parseDWORD(entry); -- 事件表现
	data.rate=Proto.parseDWORD(entry); -- 概率
	return data;
end

function Proto.writeRandomDetail(msg,data)
	Proto.writeDWORD(msg,data.event); -- 事件表现
	Proto.writeDWORD(msg,data.rate); -- 概率
end

function Proto.parseEventShowRandomInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.randomList=Proto.parseVector(entry,Proto.parseRandomDetail); -- 随机信息列表
	return data;
end

function Proto.getEventShowRandomInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeEventShowRandomInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeVector(msg,data.randomList,Proto.writeRandomDetail); -- 随机信息列表
end

function Proto.parseMapStarAward(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.bMapID=Proto.parseDWORD(entry); -- 
	data.level=Proto.parseDWORD(entry); -- 
	data.needStar=Proto.parseDWORD(entry); -- 
	data.awardElements=Proto.parseVector(entry,Proto.parseDWORD); -- 
	data.awardElementNums=Proto.parseVector(entry,Proto.parseDWORD); -- 
	return data;
end

function Proto.getMapStarAwardIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeMapStarAward(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeDWORD(msg,data.bMapID); -- 
	Proto.writeDWORD(msg,data.level); -- 
	Proto.writeDWORD(msg,data.needStar); -- 
	Proto.writeVector(msg,data.awardElements,Proto.writeDWORD); -- 
	Proto.writeVector(msg,data.awardElementNums,Proto.writeDWORD); -- 
end

function Proto.parseAdvAward(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.petGeneID=Proto.parseDWORD(entry); -- 
	return data;
end

function Proto.getAdvAwardIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeAdvAward(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeDWORD(msg,data.petGeneID); -- 
end

