-- Net.Proto.Proto_Quest_Types

Proto.QOT_CONTROLEPETBAG			= 0											-- [任务目标类型]收放宠物(客户端驱动) 
Proto.QOT_USEITEM					= Proto.QOT_CONTROLEPETBAG + 1				-- [任务目标类型]使用道具
Proto.QOT_ENDOWITEM					= Proto.QOT_USEITEM + 1						-- [任务目标类型]上交物品
Proto.QOT_KILLMONSTER				= Proto.QOT_ENDOWITEM + 1					-- [任务目标类型]打倒怪物
Proto.QOT_ERRAND					= Proto.QOT_KILLMONSTER + 1					-- [任务目标类型]跑腿(客户端驱动) 
Proto.QOT_EQUIPAVATAR				= Proto.QOT_ERRAND + 1						-- [任务目标类型]装备(服装)
Proto.QOT_EDITCARDGROUP				= Proto.QOT_EQUIPAVATAR + 1					-- [任务目标类型]配置卡片组(客户端驱动) 
Proto.QOT_DOCOMMANDMOVE				= Proto.QOT_EDITCARDGROUP + 1				-- [任务目标类型]根据指令进行移动(客户端驱动) 
Proto.QOT_RENAMEPET					= Proto.QOT_DOCOMMANDMOVE + 1				-- [任务目标类型]变更宠物名字(客户端驱动) 
Proto.QOT_ENTERREPETITION			= Proto.QOT_RENAMEPET + 1					-- [任务目标类型]进入副本
Proto.QOT_REPTITIONMOVE				= Proto.QOT_ENTERREPETITION + 1				-- [任务目标类型]在副本中移动(客户端驱动) 
Proto.QOT_COMPETITION_DEFENCE		= Proto.QOT_REPTITIONMOVE + 1				-- [任务目标类型]在竞技中防御(客户端驱动) 
Proto.QOT_COMPETITION_ATTACK		= Proto.QOT_COMPETITION_DEFENCE + 1			-- [任务目标类型]在竞技中普通攻击(客户端驱动) 
Proto.QOT_COLLECTITEM				= Proto.QOT_COMPETITION_ATTACK + 1			-- [任务目标类型]采集指定道具(客户端驱动) 
Proto.QOT_QUESTITEM					= Proto.QOT_COLLECTITEM + 1					-- [任务目标类型]上交任务道具
Proto.QOT_LEVELUPPET				= Proto.QOT_QUESTITEM + 1					-- [任务目标类型]升级宠物
Proto.QOT_USEITEMBYCATEGORY			= Proto.QOT_LEVELUPPET + 1					-- [任务目标类型]按类别使用道具
Proto.QOT_FINISHQUEST				= Proto.QOT_USEITEMBYCATEGORY + 1			-- [任务目标类型]完成任务
Proto.QOT_SETUPGARDEN				= Proto.QOT_FINISHQUEST + 1					-- [任务目标类型]落成庄园
Proto.QOT_PRODUCEFOOD				= Proto.QOT_SETUPGARDEN + 1					-- [任务目标类型]生产食物
Proto.QOT_TALKWITHNPC				= Proto.QOT_PRODUCEFOOD + 1					-- [任务目标类型]与NPC对话
Proto.QOT_ENTERTOWN					= Proto.QOT_TALKWITHNPC + 1					-- [任务目标类型]进入小镇(客户端驱动)
Proto.QOT_PLANTIRRIGATE				= Proto.QOT_ENTERTOWN + 1					-- [任务目标类型]植物灌溉(客户端驱动)
Proto.QOT_PLANTINGATHER				= Proto.QOT_PLANTIRRIGATE + 1				-- [任务目标类型]植物收获(客户端驱动)
Proto.QOT_OPENENTERPRISE			= Proto.QOT_PLANTINGATHER + 1				-- [任务目标类型]开始营业(客户端驱动)
Proto.QOT_FINISHACHIEVEMENT			= Proto.QOT_OPENENTERPRISE + 1				-- [任务目标类型]完成成就
Proto.QOT_PKWIN						= Proto.QOT_FINISHACHIEVEMENT + 1			-- [任务目标类型]决斗胜利(客户端驱动)
Proto.QOT_PRODUCEITEM				= Proto.QOT_PKWIN + 1						-- [任务目标类型]生产道具(客户端驱动)
Proto.QOT_COMBINECARD				= Proto.QOT_PRODUCEITEM + 1					-- [任务目标类型]合成卡片(客户端驱动)
Proto.QOT_UPGRADECARD				= Proto.QOT_COMBINECARD + 1					-- [任务目标类型]升级卡片(客户端驱动)
Proto.QOT_USEANYITEM				= Proto.QOT_UPGRADECARD + 1					-- [任务目标类型]使用任一道具
Proto.QOT_NINKIPOINT				= Proto.QOT_USEANYITEM + 1					-- [任务目标类型]达到指定人气(客户端驱动)
Proto.QOT_CATCHANYMONSTER			= Proto.QOT_NINKIPOINT + 1					-- [任务目标类型]捕捉任意怪物
Proto.QOT_HARVESTITEM				= Proto.QOT_CATCHANYMONSTER + 1				-- [任务目标类型]收获指定物品达到一定数量
Proto.QOT_SYNTHESIZEANYITEM			= Proto.QOT_HARVESTITEM + 1					-- [任务目标类型]合成任意材料(客户端驱动)
Proto.QOT_COMBATMONSTER				= Proto.QOT_SYNTHESIZEANYITEM + 1			-- [任务目标类型]和指定类型的怪物开始战斗
Proto.QOT_HAVEITEM					= Proto.QOT_COMBATMONSTER + 1				-- [任务目标类型]持有指定道具
Proto.QOT_ENDOWGCASH				= Proto.QOT_HAVEITEM + 1					-- [任务目标类型]上交G币
Proto.QOT_ENDOWNATIONCREDITMONEY	= Proto.QOT_ENDOWGCASH + 1					-- [任务目标类型]上交阵营信用卡金额
Proto.QOT_LEVELUPCHAR				= Proto.QOT_ENDOWNATIONCREDITMONEY + 1		-- [任务目标类型]人物升级
Proto.QOT_HATCHPET					= Proto.QOT_LEVELUPCHAR + 1					-- [任务目标类型]孵化宠物
Proto.QOT_LEVELUPPETWITHCOUNT		= Proto.QOT_HATCHPET + 1					-- [任务目标类型]升级宠物(多个)
Proto.QOT_HAVEPET					= Proto.QOT_LEVELUPPETWITHCOUNT + 1			-- [任务目标类型]拥有宠物
Proto.QOT_SEEPET					= Proto.QOT_HAVEPET + 1						-- [任务目标类型]认识宠物(客户端驱动) 
Proto.QOT_COLLECTPET				= Proto.QOT_SEEPET + 1						-- [任务目标类型]收集宠物(客户端驱动)
Proto.QOT_LEVELUPTRAININGGROUND		= Proto.QOT_COLLECTPET + 1					-- [任务目标类型]升级训练场(客户端驱动) 
Proto.QOT_TRAINPETSTREAK			= Proto.QOT_LEVELUPTRAININGGROUND + 1		-- [任务目标类型]训练宠物(客户端驱动) 
Proto.QOT_CHALLENGESTAGE			= Proto.QOT_TRAINPETSTREAK + 1				-- [任务目标类型]挑战关卡
Proto.QOT_HAVEMCASH					= Proto.QOT_CHALLENGESTAGE + 1				-- [任务目标类型]拥有金钱(客户端驱动) 
Proto.QOT_ARENARANK					= Proto.QOT_HAVEMCASH + 1					-- [任务目标类型]竞技场排名(客户端驱动)
Proto.QOT_ARENACOUNT				= Proto.QOT_ARENARANK + 1					-- [任务目标类型]竞技场挑战次数(客户端驱动)
Proto.QOT_ARENAWINSTREAK			= Proto.QOT_ARENACOUNT + 1					-- [任务目标类型]竞技场连胜(客户端驱动)
Proto.QOT_ARENASTREAK				= Proto.QOT_ARENAWINSTREAK + 1				-- [任务目标类型]竞技场持续天数(客户端驱动)
Proto.QOT_ADDFRIEND					= Proto.QOT_ARENASTREAK + 1					-- [任务目标类型]好友数量(客户端驱动)
Proto.QOT_CHANLLENAGEFRIEND			= Proto.QOT_ADDFRIEND + 1					-- [任务目标类型]挑战好友次数
Proto.QOT_TGRENTTIMES				= Proto.QOT_CHANLLENAGEFRIEND + 1			-- [任务目标类型]训练场被租用
Proto.QOT_BEATPET					= Proto.QOT_TGRENTTIMES + 1					-- [任务目标类型]击败宠物(客户端驱动)
Proto.QOT_PETSSTRENTHEN				= Proto.QOT_BEATPET + 1						-- [任务目标类型]强化宠物次数(客户端驱动)
Proto.QOT_QUALIFICATIONCOUNT		= Proto.QOT_PETSSTRENTHEN + 1				-- [任务目标类型]宠物资质数量(客户端驱动)
Proto.QOT_EVOLUTIONTIMES			= Proto.QOT_QUALIFICATIONCOUNT + 1			-- [任务目标类型]宠物进化次数(客户端驱动)
Proto.QOT_CHANLLENAGEFRIENDDAYCOUNT	= Proto.QOT_EVOLUTIONTIMES + 1				-- [任务目标类型]连续挑战好友天数(客户端驱动)
Proto.QOT_ADDFRIENDDISCONTIUOUS		= Proto.QOT_CHANLLENAGEFRIENDDAYCOUNT + 1	-- [任务目标类型]好友数量重新计数(客户端驱动)
Proto.QOT_HANGUPCOUNT				= Proto.QOT_ADDFRIENDDISCONTIUOUS + 1		-- [任务目标类型]挂机计数(客户端驱动)
Proto.QOT_EATEGGCOUNT				= Proto.QOT_HANGUPCOUNT + 1					-- [任务目标类型]吃蛋次数(客户端驱动)
Proto.QOT_EATPETCOUNT				= Proto.QOT_EATEGGCOUNT + 1					-- [任务目标类型]宠物融合次数(客户端驱动)
Proto.QOT_CHANLLENGEBOSSCOUNT		= Proto.QOT_EATPETCOUNT + 1					-- [任务目标类型]挑战Boss次数(客户端驱动)
Proto.QOT_GACHACOUNT				= Proto.QOT_CHANLLENGEBOSSCOUNT + 1			-- [任务目标类型]扭蛋次数
Proto.QOT_SYNITEMCOUNT				= Proto.QOT_GACHACOUNT + 1					-- [任务目标类型]道具合成次数
Proto.QOT_ALLELEPOWERUPCOUNT		= Proto.QOT_SYNITEMCOUNT + 1				-- [任务目标类型]宠物技能升级计数
Proto.QOT_VIP						= Proto.QOT_ALLELEPOWERUPCOUNT + 1			-- [任务目标类型]VIP等级
Proto.QOT_EQUIPMENTINTENSIFYCOUNT	= Proto.QOT_VIP + 1							-- [任务目标类型]装备强化次数(客户端驱动)
Proto.QOT_EQUIPMENTMERGECOUNT		= Proto.QOT_EQUIPMENTINTENSIFYCOUNT + 1		-- [任务目标类型]装备熔炼次数(客户端驱动)
Proto.QOT_EQUIPMENTRESETCOUNT		= Proto.QOT_EQUIPMENTMERGECOUNT + 1			-- [任务目标类型]装备洗练次数(客户端驱动)
Proto.QOT_PETIMMOLATECOUNT			= Proto.QOT_EQUIPMENTRESETCOUNT + 1			-- [任务目标类型]宠物献祭次数(客户端驱动)
Proto.QOT_COUNT						= Proto.QOT_PETIMMOLATECOUNT + 1			-- [任务目标类型]任务目标计数
Proto.QMB_CHARACTER	= 0							-- [任务主体]玩家
Proto.QMB_PET		= Proto.QMB_CHARACTER + 1	-- [任务主体]宠物
Proto.QVT_INVALID			= 0								-- [任务验证类型]无效的(无法接或还未经过验证)
Proto.QVT_COOLDOWN			= Proto.QVT_INVALID + 1			-- [任务验证类型]冷却中
Proto.QVT_LEVELBEYOND		= Proto.QVT_COOLDOWN + 1		-- [任务验证类型]等级差距超过一定值(但是能够接该任务)
Proto.QVT_LEVELNOTENOUGH	= Proto.QVT_LEVELBEYOND + 1		-- [任务验证类型]等级不够
Proto.QVT_NOTCOMPLETE		= Proto.QVT_LEVELNOTENOUGH + 1	-- [任务验证类型]接了该任务且未完成
Proto.QVT_CANACCEPT			= Proto.QVT_NOTCOMPLETE + 1		-- [任务验证类型]能够接该任务
Proto.QVT_COMPLETE			= Proto.QVT_CANACCEPT + 1		-- [任务验证类型]接了该任务且已完成
Proto.QVT_DURATIVE			= Proto.QVT_COMPLETE + 1		-- [任务验证类型]交付了并且是反复的任务
Proto.QRT_ONEOFF		= 0							-- [任务验证类型]一次性的
Proto.QRT_REPEATABLE	= Proto.QRT_ONEOFF + 1		-- [任务验证类型]可重复接的
Proto.QRT_DURATIVE		= Proto.QRT_REPEATABLE + 1	-- [任务验证类型]反复的
Proto.CQT_INFORMATION	= 0								-- [任务验证类型]帮会信息
Proto.CQT_ADDMEMBER		= Proto.CQT_INFORMATION + 1		-- [任务验证类型]添加成员
Proto.CQT_REMOVEMEMBER	= Proto.CQT_ADDMEMBER + 1		-- [任务验证类型]开除成员
Proto.CQT_NOTIFY		= Proto.CQT_REMOVEMEMBER + 1	-- [任务验证类型]帮会通告
Proto.CQT_PROMOTION		= Proto.CQT_NOTIFY + 1			-- [任务验证类型]升职
Proto.CQT_DEMOTION		= Proto.CQT_PROMOTION + 1		-- [任务验证类型]降职
Proto.CQT_ENERGY		= Proto.CQT_DEMOTION + 1		-- [任务验证类型]能源供应
Proto.CQT_CARBON		= Proto.CQT_ENERGY + 1			-- [任务验证类型]碳排量维持
Proto.CQT_TECHNOLOGY	= Proto.CQT_CARBON + 1			-- [任务验证类型]科技发展
Proto.CQT_ARMAMENT		= Proto.CQT_TECHNOLOGY + 1		-- [任务验证类型]军备供应
Proto.CQT_SABER			= Proto.CQT_ARMAMENT + 1		-- [任务验证类型]骑兵营
Proto.CQT_FOOTMAN		= Proto.CQT_SABER + 1			-- [任务验证类型]步兵营
Proto.CQT_ARTILLERYMAN	= Proto.CQT_FOOTMAN + 1			-- [任务验证类型]炮兵营
Proto.QMT_ALL			= 0							-- [任务地图类型]所有地图
Proto.QMT_REPETITION	= Proto.QMT_ALL + 1			-- [任务地图类型]副本
Proto.QMT_FARM			= Proto.QMT_REPETITION + 1	-- [任务地图类型]踩地雷

function Proto.parseQuestObjectParam_PARAM_UseItem(entry)
	local data={};
	data.type=Proto.parseDWORD(entry); -- 道具类型
	data.count=Proto.parseWORD(entry); -- 道具数量
	return data;
end

function Proto.writeQuestObjectParam_PARAM_UseItem(msg,data)
	Proto.writeDWORD(msg,data.type); -- 道具类型
	Proto.writeWORD(msg,data.count); -- 道具数量
end

function Proto.parseQuestObjectParam_PARAM_UseItemByCategory(entry)
	local data={};
	data.category=Proto.parseBYTE(entry); -- 道具类别
	data.count=Proto.parseWORD(entry); -- 道具数量
	return data;
end

function Proto.writeQuestObjectParam_PARAM_UseItemByCategory(msg,data)
	Proto.writeBYTE(msg,data.category); -- 道具类别
	Proto.writeWORD(msg,data.count); -- 道具数量
end

function Proto.parseQuestObjectParam_PARAM_EndowItem(entry)
	local data={};
	data.type=Proto.parseDWORD(entry); -- 道具类型
	data.count=Proto.parseWORD(entry); -- 道具数量
	return data;
end

function Proto.writeQuestObjectParam_PARAM_EndowItem(msg,data)
	Proto.writeDWORD(msg,data.type); -- 道具类型
	Proto.writeWORD(msg,data.count); -- 道具数量
end

function Proto.parseQuestObjectParam_PARAM_KillMonster(entry)
	local data={};
	data.monsterID=Proto.parseDWORD(entry); -- 怪ID
	data.count=Proto.parseWORD(entry); -- 怪物数量
	return data;
end

function Proto.writeQuestObjectParam_PARAM_KillMonster(msg,data)
	Proto.writeDWORD(msg,data.monsterID); -- 怪ID
	Proto.writeWORD(msg,data.count); -- 怪物数量
end

function Proto.parseQuestObjectParam_PARAM_EquipAvatar(entry)
	local data={};
	data.type=Proto.parseDWORD(entry); -- 道具类型
	return data;
end

function Proto.writeQuestObjectParam_PARAM_EquipAvatar(msg,data)
	Proto.writeDWORD(msg,data.type); -- 道具类型
end

function Proto.parseQuestObjectParam_PARAM_EnterRepetition(entry)
	local data={};
	data.repStyle=Proto.parseRepStyle(entry); -- 副本类型
	return data;
end

function Proto.writeQuestObjectParam_PARAM_EnterRepetition(msg,data)
	Proto.writeRepStyle(msg,data.repStyle); -- 副本类型
end

function Proto.parseQuestObjectParam_PARAM_EnterTown(entry)
	local data={};
	data.townID=Proto.parseBYTE(entry); -- 小镇ID
	return data;
end

function Proto.writeQuestObjectParam_PARAM_EnterTown(msg,data)
	Proto.writeBYTE(msg,data.townID); -- 小镇ID
end

function Proto.parseQuestObjectParam_PARAM_RepetitionMove(entry)
	local data={};
	data.repStyle=Proto.parseRepStyle(entry); -- 副本类型
	return data;
end

function Proto.writeQuestObjectParam_PARAM_RepetitionMove(msg,data)
	Proto.writeRepStyle(msg,data.repStyle); -- 副本类型
end

function Proto.parseQuestObjectParam_PARAM_CollectItem(entry)
	local data={};
	data.type_id=Proto.parseDWORD(entry); -- 道具类型
	return data;
end

function Proto.writeQuestObjectParam_PARAM_CollectItem(msg,data)
	Proto.writeDWORD(msg,data.type_id); -- 道具类型
end

function Proto.parseQuestObjectParam_PARAM_QuestItem_PARAM_Repetition(entry)
	local data={};
	data.style=Proto.parseRepStyle(entry); -- 掉落道具副本类型(0的时候表示任意副本)
	return data;
end

function Proto.writeQuestObjectParam_PARAM_QuestItem_PARAM_Repetition(msg,data)
	Proto.writeRepStyle(msg,data.style); -- 掉落道具副本类型(0的时候表示任意副本)
end

function Proto.parseQuestObjectParam_PARAM_QuestItem_PARAM_Farm(entry)
	local data={};
	data.town=Proto.parseTownID(entry); -- 掉落道具小镇类型(0的时候表示任意小镇)
	return data;
end

function Proto.writeQuestObjectParam_PARAM_QuestItem_PARAM_Farm(msg,data)
	Proto.writeTownID(msg,data.town); -- 掉落道具小镇类型(0的时候表示任意小镇)
end

function Proto.parseQuestObjectParam_PARAM_QuestItem(entry)
	local data={};
	data.mapType=Proto.parseBYTE(entry); -- 任务地图类型
	data.param={}; -- 
	if (data.mapType==Proto.QMT_REPETITION) then
		data.param.repetition=Proto.parseQuestObjectParam_PARAM_QuestItem_PARAM_Repetition(entry); -- 副本
	end
	if (data.mapType==Proto.QMT_FARM) then
		data.param.farm=Proto.parseQuestObjectParam_PARAM_QuestItem_PARAM_Farm(entry); -- 踩地雷
	end
	data.monsterID=Proto.parseDWORD(entry); -- 掉落道具怪物ID(0的时候表示任意怪物)
	data.rate=Proto.parseDWORD(entry); -- 掉落概率(千万分之一)
	data.type=Proto.parseDWORD(entry); -- 道具类型
	data.count=Proto.parseWORD(entry); -- 道具数量
	data.forceBinded=Proto.parseBYTE(entry); -- 是否强制绑定
	return data;
end

function Proto.writeQuestObjectParam_PARAM_QuestItem(msg,data)
	Proto.writeBYTE(msg,data.mapType); -- 任务地图类型
	if (data.mapType==Proto.QMT_REPETITION) then
		Proto.writeQuestObjectParam_PARAM_QuestItem_PARAM_Repetition(msg,data.param.repetition); -- 副本
	end
	if (data.mapType==Proto.QMT_FARM) then
		Proto.writeQuestObjectParam_PARAM_QuestItem_PARAM_Farm(msg,data.param.farm); -- 踩地雷
	end
	Proto.writeDWORD(msg,data.monsterID); -- 掉落道具怪物ID(0的时候表示任意怪物)
	Proto.writeDWORD(msg,data.rate); -- 掉落概率(千万分之一)
	Proto.writeDWORD(msg,data.type); -- 道具类型
	Proto.writeWORD(msg,data.count); -- 道具数量
	Proto.writeBYTE(msg,data.forceBinded); -- 是否强制绑定
end

function Proto.parseQuestObjectParam_PARAM_LevelUpPet(entry)
	local data={};
	data.level=Proto.parseWORD(entry); -- 要升级到的等级
	return data;
end

function Proto.writeQuestObjectParam_PARAM_LevelUpPet(msg,data)
	Proto.writeWORD(msg,data.level); -- 要升级到的等级
end

function Proto.parseQuestObjectParam_PARAM_FinishQuest(entry)
	local data={};
	data.questID=Proto.parseWORD(entry); -- 任务ID
	return data;
end

function Proto.writeQuestObjectParam_PARAM_FinishQuest(msg,data)
	Proto.writeWORD(msg,data.questID); -- 任务ID
end

function Proto.parseQuestObjectParam_PARAM_ProduceFood(entry)
	local data={};
	data.foodCardID=Proto.parseDWORD(entry); -- 食物卡ID
	data.count=Proto.parseWORD(entry); -- 生产份数
	return data;
end

function Proto.writeQuestObjectParam_PARAM_ProduceFood(msg,data)
	Proto.writeDWORD(msg,data.foodCardID); -- 食物卡ID
	Proto.writeWORD(msg,data.count); -- 生产份数
end

function Proto.parseQuestObjectParam_PARAM_TalkWithNpc(entry)
	local data={};
	data.npcID=Proto.parseDWORD(entry); -- Npc ID
	return data;
end

function Proto.writeQuestObjectParam_PARAM_TalkWithNpc(msg,data)
	Proto.writeDWORD(msg,data.npcID); -- Npc ID
end

function Proto.parseQuestObjectParam_PARAM_FinishAchievement(entry)
	local data={};
	data.achievementID=Proto.parseWORD(entry); -- 成就ID
	return data;
end

function Proto.writeQuestObjectParam_PARAM_FinishAchievement(msg,data)
	Proto.writeWORD(msg,data.achievementID); -- 成就ID
end

function Proto.parseQuestObjectParam_PARAM_ProduceItem(entry)
	local data={};
	data.type=Proto.parseDWORD(entry); -- 道具类型
	return data;
end

function Proto.writeQuestObjectParam_PARAM_ProduceItem(msg,data)
	Proto.writeDWORD(msg,data.type); -- 道具类型
end

function Proto.parseQuestObjectParam_PARAM_UseAnyItem(entry)
	local data={};
	data.items=Proto.parseVarArray(entry,Proto.parseDWORD,Proto.parseWORD); -- 道具类型
	return data;
end

function Proto.writeQuestObjectParam_PARAM_UseAnyItem(msg,data)
	Proto.writeVarArray(msg,data.items,Proto.writeDWORD,Proto.writeWORD); -- 道具类型
end

function Proto.parseQuestObjectParam_PARAM_NinkiPoint(entry)
	local data={};
	data.nation=Proto.parseBYTE(entry); -- NPC阵营
	data.ninki=Proto.parseDWORD(entry); -- 点数
	return data;
end

function Proto.writeQuestObjectParam_PARAM_NinkiPoint(msg,data)
	Proto.writeBYTE(msg,data.nation); -- NPC阵营
	Proto.writeDWORD(msg,data.ninki); -- 点数
end

function Proto.parseQuestObjectParam_PARAM_HarvestItem(entry)
	local data={};
	data.type_id=Proto.parseDWORD(entry); -- 道具类型
	data.count=Proto.parseDWORD(entry); -- 数量
	return data;
end

function Proto.writeQuestObjectParam_PARAM_HarvestItem(msg,data)
	Proto.writeDWORD(msg,data.type_id); -- 道具类型
	Proto.writeDWORD(msg,data.count); -- 数量
end

function Proto.parseQuestObjectParam_PARAM_CombatMonster(entry)
	local data={};
	data.monsterID=Proto.parseDWORD(entry); -- 怪ID
	data.count=Proto.parseWORD(entry); -- 怪物数量
	return data;
end

function Proto.writeQuestObjectParam_PARAM_CombatMonster(msg,data)
	Proto.writeDWORD(msg,data.monsterID); -- 怪ID
	Proto.writeWORD(msg,data.count); -- 怪物数量
end

function Proto.parseQuestObjectParam_PARAM_HaveItem(entry)
	local data={};
	data.type=Proto.parseDWORD(entry); -- 道具类型
	data.count=Proto.parseWORD(entry); -- 道具数量
	return data;
end

function Proto.writeQuestObjectParam_PARAM_HaveItem(msg,data)
	Proto.writeDWORD(msg,data.type); -- 道具类型
	Proto.writeWORD(msg,data.count); -- 道具数量
end

function Proto.parseQuestObjectParam_PARAM_EndowGCash(entry)
	local data={};
	data.money=Proto.parseDWORD(entry); -- 金额
	return data;
end

function Proto.writeQuestObjectParam_PARAM_EndowGCash(msg,data)
	Proto.writeDWORD(msg,data.money); -- 金额
end

function Proto.parseQuestObjectParam_PARAM_EndowNationCreditMoney(entry)
	local data={};
	data.nation=Proto.parseBYTE(entry); -- 阵营
	data.money=Proto.parseDWORD(entry); -- 信用卡金额
	return data;
end

function Proto.writeQuestObjectParam_PARAM_EndowNationCreditMoney(msg,data)
	Proto.writeBYTE(msg,data.nation); -- 阵营
	Proto.writeDWORD(msg,data.money); -- 信用卡金额
end

function Proto.parseQuestObjectParam_PARAM_LevelUpChar(entry)
	local data={};
	data.level=Proto.parseWORD(entry); -- 要升级到的等级
	return data;
end

function Proto.writeQuestObjectParam_PARAM_LevelUpChar(msg,data)
	Proto.writeWORD(msg,data.level); -- 要升级到的等级
end

function Proto.parseQuestObjectParam_PARAM_HatchPet(entry)
	local data={};
	data.petRace=Proto.parseDWORD(entry); -- 宠物种族
	data.count=Proto.parseWORD(entry); -- 数量
	return data;
end

function Proto.writeQuestObjectParam_PARAM_HatchPet(msg,data)
	Proto.writeDWORD(msg,data.petRace); -- 宠物种族
	Proto.writeWORD(msg,data.count); -- 数量
end

function Proto.parseQuestObjectParam_PARAM_LevelUpPetWithCount(entry)
	local data={};
	data.petRace=Proto.parseDWORD(entry); -- 宠物种族
	data.count=Proto.parseWORD(entry); -- 数量
	return data;
end

function Proto.writeQuestObjectParam_PARAM_LevelUpPetWithCount(msg,data)
	Proto.writeDWORD(msg,data.petRace); -- 宠物种族
	Proto.writeWORD(msg,data.count); -- 数量
end

function Proto.parseQuestObjectParam_PARAM_HavePet(entry)
	local data={};
	data.count=Proto.parseWORD(entry); -- 数量
	return data;
end

function Proto.writeQuestObjectParam_PARAM_HavePet(msg,data)
	Proto.writeWORD(msg,data.count); -- 数量
end

function Proto.parseQuestObjectParam_PARAM_SeePet(entry)
	local data={};
	data.elementType=Proto.parseBYTE(entry); -- 元素类型
	data.count=Proto.parseWORD(entry); -- 数量
	return data;
end

function Proto.writeQuestObjectParam_PARAM_SeePet(msg,data)
	Proto.writeBYTE(msg,data.elementType); -- 元素类型
	Proto.writeWORD(msg,data.count); -- 数量
end

function Proto.parseQuestObjectParam_PARAM_CollectPet(entry)
	local data={};
	data.elementType=Proto.parseBYTE(entry); -- 元素类型
	data.count=Proto.parseWORD(entry); -- 数量
	return data;
end

function Proto.writeQuestObjectParam_PARAM_CollectPet(msg,data)
	Proto.writeBYTE(msg,data.elementType); -- 元素类型
	Proto.writeWORD(msg,data.count); -- 数量
end

function Proto.parseQuestObjectParam_PARAM_LevelUpTrainingGround(entry)
	local data={};
	data.level=Proto.parseWORD(entry); -- 等级
	return data;
end

function Proto.writeQuestObjectParam_PARAM_LevelUpTrainingGround(msg,data)
	Proto.writeWORD(msg,data.level); -- 等级
end

function Proto.parseQuestObjectParam_PARAM_TrainPetStreak(entry)
	local data={};
	data.count=Proto.parseWORD(entry); -- 数量
	return data;
end

function Proto.writeQuestObjectParam_PARAM_TrainPetStreak(msg,data)
	Proto.writeWORD(msg,data.count); -- 数量
end

function Proto.parseQuestObjectParam_PARAM_ChallengeStage(entry)
	local data={};
	data.stage=Proto.parseDWORD(entry); -- 挑战点ID
	data.checkPoint=Proto.parseWORD(entry); -- 关卡
	return data;
end

function Proto.writeQuestObjectParam_PARAM_ChallengeStage(msg,data)
	Proto.writeDWORD(msg,data.stage); -- 挑战点ID
	Proto.writeWORD(msg,data.checkPoint); -- 关卡
end

function Proto.parseQuestObjectParam_PARAM_HaveMCash(entry)
	local data={};
	data.count=Proto.parseDWORD(entry); -- 数量
	return data;
end

function Proto.writeQuestObjectParam_PARAM_HaveMCash(msg,data)
	Proto.writeDWORD(msg,data.count); -- 数量
end

function Proto.parseQuestObjectParam_PARAM_ArenaRank(entry)
	local data={};
	data.rank=Proto.parseDWORD(entry); -- 排名
	return data;
end

function Proto.writeQuestObjectParam_PARAM_ArenaRank(msg,data)
	Proto.writeDWORD(msg,data.rank); -- 排名
end

function Proto.parseQuestObjectParam_PARAM_ArenaCount(entry)
	local data={};
	data.count=Proto.parseDWORD(entry); -- 数量
	return data;
end

function Proto.writeQuestObjectParam_PARAM_ArenaCount(msg,data)
	Proto.writeDWORD(msg,data.count); -- 数量
end

function Proto.parseQuestObjectParam_PARAM_ArenaWinStreak(entry)
	local data={};
	data.count=Proto.parseDWORD(entry); -- 数量
	return data;
end

function Proto.writeQuestObjectParam_PARAM_ArenaWinStreak(msg,data)
	Proto.writeDWORD(msg,data.count); -- 数量
end

function Proto.parseQuestObjectParam_PARAM_ArenaStreak(entry)
	local data={};
	data.count=Proto.parseDWORD(entry); -- 数量
	return data;
end

function Proto.writeQuestObjectParam_PARAM_ArenaStreak(msg,data)
	Proto.writeDWORD(msg,data.count); -- 数量
end

function Proto.parseQuestObjectParam_PARAM_AddFriend(entry)
	local data={};
	data.count=Proto.parseDWORD(entry); -- 数量
	return data;
end

function Proto.writeQuestObjectParam_PARAM_AddFriend(msg,data)
	Proto.writeDWORD(msg,data.count); -- 数量
end

function Proto.parseQuestObjectParam_PARAM_ChanllenageFriend(entry)
	local data={};
	data.count=Proto.parseDWORD(entry); -- 数量
	return data;
end

function Proto.writeQuestObjectParam_PARAM_ChanllenageFriend(msg,data)
	Proto.writeDWORD(msg,data.count); -- 数量
end

function Proto.parseQuestObjectParam_PARAM_TGRentTimes(entry)
	local data={};
	data.count=Proto.parseDWORD(entry); -- 数量
	return data;
end

function Proto.writeQuestObjectParam_PARAM_TGRentTimes(msg,data)
	Proto.writeDWORD(msg,data.count); -- 数量
end

function Proto.parseQuestObjectParam_PARAM_BeatPet(entry)
	local data={};
	data.petRace=Proto.parseDWORD(entry); -- 宠物种族
	data.count=Proto.parseWORD(entry); -- 数量
	return data;
end

function Proto.writeQuestObjectParam_PARAM_BeatPet(msg,data)
	Proto.writeDWORD(msg,data.petRace); -- 宠物种族
	Proto.writeWORD(msg,data.count); -- 数量
end

function Proto.parseQuestObjectParam_PARAM_PetsStrenthen(entry)
	local data={};
	data.struggletype=Proto.parseWORD(entry); -- 资质类型
	data.count=Proto.parseWORD(entry); -- 数量
	return data;
end

function Proto.writeQuestObjectParam_PARAM_PetsStrenthen(msg,data)
	Proto.writeWORD(msg,data.struggletype); -- 资质类型
	Proto.writeWORD(msg,data.count); -- 数量
end

function Proto.parseQuestObjectParam_PARAM_QualificationCount(entry)
	local data={};
	data.struggletype=Proto.parseWORD(entry); -- 资质类型
	data.count=Proto.parseWORD(entry); -- 数量
	return data;
end

function Proto.writeQuestObjectParam_PARAM_QualificationCount(msg,data)
	Proto.writeWORD(msg,data.struggletype); -- 资质类型
	Proto.writeWORD(msg,data.count); -- 数量
end

function Proto.parseQuestObjectParam_PARAM_EvolutionTimes(entry)
	local data={};
	data.count=Proto.parseWORD(entry); -- 数量
	return data;
end

function Proto.writeQuestObjectParam_PARAM_EvolutionTimes(msg,data)
	Proto.writeWORD(msg,data.count); -- 数量
end

function Proto.parseQuestObjectParam_PARAM_ChanllenageFriendDayCount(entry)
	local data={};
	data.count=Proto.parseDWORD(entry); -- 数量
	return data;
end

function Proto.writeQuestObjectParam_PARAM_ChanllenageFriendDayCount(msg,data)
	Proto.writeDWORD(msg,data.count); -- 数量
end

function Proto.parseQuestObjectParam_PARAM_AddFriendDiscountiuous(entry)
	local data={};
	data.count=Proto.parseDWORD(entry); -- 数量
	return data;
end

function Proto.writeQuestObjectParam_PARAM_AddFriendDiscountiuous(msg,data)
	Proto.writeDWORD(msg,data.count); -- 数量
end

function Proto.parseQuestObjectParam_PARAM_HangUp(entry)
	local data={};
	data.count=Proto.parseWORD(entry); -- 数量
	return data;
end

function Proto.writeQuestObjectParam_PARAM_HangUp(msg,data)
	Proto.writeWORD(msg,data.count); -- 数量
end

function Proto.parseQuestObjectParam_PARAM_EatEgg(entry)
	local data={};
	data.count=Proto.parseWORD(entry); -- 数量
	return data;
end

function Proto.writeQuestObjectParam_PARAM_EatEgg(msg,data)
	Proto.writeWORD(msg,data.count); -- 数量
end

function Proto.parseQuestObjectParam_PARAM_EatPet(entry)
	local data={};
	data.count=Proto.parseWORD(entry); -- 数量
	return data;
end

function Proto.writeQuestObjectParam_PARAM_EatPet(msg,data)
	Proto.writeWORD(msg,data.count); -- 数量
end

function Proto.parseQuestObjectParam_PARAM_ChanllengeBoss(entry)
	local data={};
	data.count=Proto.parseWORD(entry); -- 数量
	return data;
end

function Proto.writeQuestObjectParam_PARAM_ChanllengeBoss(msg,data)
	Proto.writeWORD(msg,data.count); -- 数量
end

function Proto.parseQuestObjectParam_PARAM_GaCha(entry)
	local data={};
	data.count=Proto.parseWORD(entry); -- 数量
	return data;
end

function Proto.writeQuestObjectParam_PARAM_GaCha(msg,data)
	Proto.writeWORD(msg,data.count); -- 数量
end

function Proto.parseQuestObjectParam_PARAM_SynItem(entry)
	local data={};
	data.count=Proto.parseWORD(entry); -- 数量
	return data;
end

function Proto.writeQuestObjectParam_PARAM_SynItem(msg,data)
	Proto.writeWORD(msg,data.count); -- 数量
end

function Proto.parseQuestObjectParam_PARAM_AllelePowerUp(entry)
	local data={};
	data.count=Proto.parseWORD(entry); -- 数量
	return data;
end

function Proto.writeQuestObjectParam_PARAM_AllelePowerUp(msg,data)
	Proto.writeWORD(msg,data.count); -- 数量
end

function Proto.parseQuestObjectParam_PARAM_Vip(entry)
	local data={};
	data.count=Proto.parseWORD(entry); -- 数量
	return data;
end

function Proto.writeQuestObjectParam_PARAM_Vip(msg,data)
	Proto.writeWORD(msg,data.count); -- 数量
end

function Proto.parseQuestObjectParam_PARAM_EquipmentIntensify(entry)
	local data={};
	data.count=Proto.parseWORD(entry); -- 数量
	return data;
end

function Proto.writeQuestObjectParam_PARAM_EquipmentIntensify(msg,data)
	Proto.writeWORD(msg,data.count); -- 数量
end

function Proto.parseQuestObjectParam_PARAM_EquipmentMerge(entry)
	local data={};
	data.count=Proto.parseWORD(entry); -- 数量
	return data;
end

function Proto.writeQuestObjectParam_PARAM_EquipmentMerge(msg,data)
	Proto.writeWORD(msg,data.count); -- 数量
end

function Proto.parseQuestObjectParam_PARAM_EquipmentReset(entry)
	local data={};
	data.count=Proto.parseWORD(entry); -- 数量
	return data;
end

function Proto.writeQuestObjectParam_PARAM_EquipmentReset(msg,data)
	Proto.writeWORD(msg,data.count); -- 数量
end

function Proto.parseQuestObjectParam_PARAM_PetImmolateCount(entry)
	local data={};
	data.count=Proto.parseWORD(entry); -- 次数
	return data;
end

function Proto.writeQuestObjectParam_PARAM_PetImmolateCount(msg,data)
	Proto.writeWORD(msg,data.count); -- 次数
end

function Proto.parseQuestObjectParam(entry)
	local data={};
	data.type=Proto.parseWORD(entry); -- 目标类型
	data.param={}; -- 
	if (data.type==Proto.QOT_USEITEM) then
		data.param.useItem=Proto.parseQuestObjectParam_PARAM_UseItem(entry); -- 使用道具
	end
	if (data.type==Proto.QOT_USEITEMBYCATEGORY) then
		data.param.useItemByCategory=Proto.parseQuestObjectParam_PARAM_UseItemByCategory(entry); -- 按类别使用道具
	end
	if (data.type==Proto.QOT_ENDOWITEM) then
		data.param.endowItem=Proto.parseQuestObjectParam_PARAM_EndowItem(entry); -- 上交物品
	end
	if (data.type==Proto.QOT_KILLMONSTER) then
		data.param.killMonster=Proto.parseQuestObjectParam_PARAM_KillMonster(entry); -- 杀死怪物
	end
	if (data.type==Proto.QOT_EQUIPAVATAR) then
		data.param.equipAvatar=Proto.parseQuestObjectParam_PARAM_EquipAvatar(entry); -- 装备道具
	end
	if (data.type==Proto.QOT_ENTERREPETITION) then
		data.param.enterRepetition=Proto.parseQuestObjectParam_PARAM_EnterRepetition(entry); -- 进入副本
	end
	if (data.type==Proto.QOT_ENTERTOWN) then
		data.param.enterTown=Proto.parseQuestObjectParam_PARAM_EnterTown(entry); -- 进入副本
	end
	if (data.type==Proto.QOT_REPTITIONMOVE) then
		data.param.repetitionMove=Proto.parseQuestObjectParam_PARAM_RepetitionMove(entry); -- 副本移动
	end
	if (data.type==Proto.QOT_COLLECTITEM) then
		data.param.collectItem=Proto.parseQuestObjectParam_PARAM_CollectItem(entry); -- 采集道具
	end
	if (data.type==Proto.QOT_QUESTITEM) then
		data.param.questItem=Proto.parseQuestObjectParam_PARAM_QuestItem(entry); -- 上交任务道具
	end
	if (data.type==Proto.QOT_LEVELUPPET) then
		data.param.levelUpPet=Proto.parseQuestObjectParam_PARAM_LevelUpPet(entry); -- 升级宠物
	end
	if (data.type==Proto.QOT_FINISHQUEST) then
		data.param.finishQuest=Proto.parseQuestObjectParam_PARAM_FinishQuest(entry); -- 完成任务
	end
	if (data.type==Proto.QOT_PRODUCEFOOD) then
		data.param.produceFood=Proto.parseQuestObjectParam_PARAM_ProduceFood(entry); -- 生产食物
	end
	if (data.type==Proto.QOT_TALKWITHNPC) then
		data.param.talkWithNpc=Proto.parseQuestObjectParam_PARAM_TalkWithNpc(entry); -- 与NPC对话
	end
	if (data.type==Proto.QOT_FINISHACHIEVEMENT) then
		data.param.finishAchievement=Proto.parseQuestObjectParam_PARAM_FinishAchievement(entry); -- 完成成就
	end
	if (data.type==Proto.QOT_PRODUCEITEM) then
		data.param.produceItem=Proto.parseQuestObjectParam_PARAM_ProduceItem(entry); -- 生产道具
	end
	if (data.type==Proto.QOT_USEANYITEM) then
		data.param.useAnyItem=Proto.parseQuestObjectParam_PARAM_UseAnyItem(entry); -- 使用任一道具
	end
	if (data.type==Proto.QOT_NINKIPOINT) then
		data.param.ninkiPoint=Proto.parseQuestObjectParam_PARAM_NinkiPoint(entry); -- 人气点数
	end
	if (data.type==Proto.QOT_HARVESTITEM) then
		data.param.harvestItem=Proto.parseQuestObjectParam_PARAM_HarvestItem(entry); -- 收获指定物品达到一定数量
	end
	if (data.type==Proto.QOT_COMBATMONSTER) then
		data.param.combatMonster=Proto.parseQuestObjectParam_PARAM_CombatMonster(entry); -- 和指定类型怪物战斗
	end
	if (data.type==Proto.QOT_HAVEITEM) then
		data.param.haveItem=Proto.parseQuestObjectParam_PARAM_HaveItem(entry); -- 持有道具
	end
	if (data.type==Proto.QOT_ENDOWGCASH) then
		data.param.endowGCash=Proto.parseQuestObjectParam_PARAM_EndowGCash(entry); -- 上交G币
	end
	if (data.type==Proto.QOT_ENDOWNATIONCREDITMONEY) then
		data.param.endowNationCreditMoney=Proto.parseQuestObjectParam_PARAM_EndowNationCreditMoney(entry); -- 上交阵营信用卡货币
	end
	if (data.type==Proto.QOT_LEVELUPCHAR) then
		data.param.levelUpChar=Proto.parseQuestObjectParam_PARAM_LevelUpChar(entry); -- 人物升级
	end
	if (data.type==Proto.QOT_HATCHPET) then
		data.param.hatchPet=Proto.parseQuestObjectParam_PARAM_HatchPet(entry); -- 孵化宠物
	end
	if (data.type==Proto.QOT_LEVELUPPETWITHCOUNT) then
		data.param.levelUpPetWithCount=Proto.parseQuestObjectParam_PARAM_LevelUpPetWithCount(entry); -- 升级宠物(多个)
	end
	if (data.type==Proto.QOT_HAVEPET) then
		data.param.havePet=Proto.parseQuestObjectParam_PARAM_HavePet(entry); -- 拥有宠物
	end
	if (data.type==Proto.QOT_SEEPET) then
		data.param.seePet=Proto.parseQuestObjectParam_PARAM_SeePet(entry); -- 认识宠物
	end
	if (data.type==Proto.QOT_COLLECTPET) then
		data.param.collectPet=Proto.parseQuestObjectParam_PARAM_CollectPet(entry); -- 收集宠物
	end
	if (data.type==Proto.QOT_LEVELUPTRAININGGROUND) then
		data.param.levelUpTrainingGround=Proto.parseQuestObjectParam_PARAM_LevelUpTrainingGround(entry); -- 升级训练场
	end
	if (data.type==Proto.QOT_TRAINPETSTREAK) then
		data.param.trainPetStreak=Proto.parseQuestObjectParam_PARAM_TrainPetStreak(entry); -- 持续训练宠物
	end
	if (data.type==Proto.QOT_CHALLENGESTAGE) then
		data.param.challengeStage=Proto.parseQuestObjectParam_PARAM_ChallengeStage(entry); -- 挑战关卡
	end
	if (data.type==Proto.QOT_HAVEMCASH) then
		data.param.haveMCash=Proto.parseQuestObjectParam_PARAM_HaveMCash(entry); -- 拥有金钱
	end
	if (data.type==Proto.QOT_ARENARANK) then
		data.param.arenaRank=Proto.parseQuestObjectParam_PARAM_ArenaRank(entry); -- 竞技场排名
	end
	if (data.type==Proto.QOT_ARENACOUNT) then
		data.param.arenaCount=Proto.parseQuestObjectParam_PARAM_ArenaCount(entry); -- 竞技场挑战次数
	end
	if (data.type==Proto.QOT_ARENAWINSTREAK) then
		data.param.arenaWinStreak=Proto.parseQuestObjectParam_PARAM_ArenaWinStreak(entry); -- 竞技场连胜
	end
	if (data.type==Proto.QOT_ARENASTREAK) then
		data.param.arenaStreak=Proto.parseQuestObjectParam_PARAM_ArenaStreak(entry); -- 竞技场持续挑战
	end
	if (data.type==Proto.QOT_ADDFRIEND) then
		data.param.addFriend=Proto.parseQuestObjectParam_PARAM_AddFriend(entry); -- 添加好友
	end
	if (data.type==Proto.QOT_CHANLLENAGEFRIEND) then
		data.param.chanllenageFriend=Proto.parseQuestObjectParam_PARAM_ChanllenageFriend(entry); -- 挑战好友次数
	end
	if (data.type==Proto.QOT_TGRENTTIMES) then
		data.param.tgRentTimes=Proto.parseQuestObjectParam_PARAM_TGRentTimes(entry); -- 训练场被租用次数
	end
	if (data.type==Proto.QOT_BEATPET) then
		data.param.beatPet=Proto.parseQuestObjectParam_PARAM_BeatPet(entry); -- 击败怪物
	end
	if (data.type==Proto.QOT_PETSSTRENTHEN) then
		data.param.petsStrenthen=Proto.parseQuestObjectParam_PARAM_PetsStrenthen(entry); -- 强化宠物次数
	end
	if (data.type==Proto.QOT_QUALIFICATIONCOUNT) then
		data.param.qualificationCount=Proto.parseQuestObjectParam_PARAM_QualificationCount(entry); -- 宠物资质数量
	end
	if (data.type==Proto.QOT_EVOLUTIONTIMES) then
		data.param.evolutionTimes=Proto.parseQuestObjectParam_PARAM_EvolutionTimes(entry); -- 宠物进化次数
	end
	if (data.type==Proto.QOT_CHANLLENAGEFRIENDDAYCOUNT) then
		data.param.chanllenageFriendDayCount=Proto.parseQuestObjectParam_PARAM_ChanllenageFriendDayCount(entry); -- 连续挑战好友天数
	end
	if (data.type==Proto.QOT_ADDFRIENDDISCONTIUOUS) then
		data.param.addFriendDiscountiuous=Proto.parseQuestObjectParam_PARAM_AddFriendDiscountiuous(entry); -- 添加好友
	end
	if (data.type==Proto.QOT_HANGUPCOUNT) then
		data.param.hangup=Proto.parseQuestObjectParam_PARAM_HangUp(entry); -- 挂机次数
	end
	if (data.type==Proto.QOT_EATEGGCOUNT) then
		data.param.eatEgg=Proto.parseQuestObjectParam_PARAM_EatEgg(entry); -- 吃蛋次数
	end
	if (data.type==Proto.QOT_EATPETCOUNT) then
		data.param.eatPet=Proto.parseQuestObjectParam_PARAM_EatPet(entry); -- 宠物融合次数
	end
	if (data.type==Proto.QOT_CHANLLENGEBOSSCOUNT) then
		data.param.chanllengeBoss=Proto.parseQuestObjectParam_PARAM_ChanllengeBoss(entry); -- 挑战Boss次数
	end
	if (data.type==Proto.QOT_GACHACOUNT) then
		data.param.gacha=Proto.parseQuestObjectParam_PARAM_GaCha(entry); -- 扭蛋次数
	end
	if (data.type==Proto.QOT_SYNITEMCOUNT) then
		data.param.synItem=Proto.parseQuestObjectParam_PARAM_SynItem(entry); -- 道具合成次数
	end
	if (data.type==Proto.QOT_ALLELEPOWERUPCOUNT) then
		data.param.allelePowerUp=Proto.parseQuestObjectParam_PARAM_AllelePowerUp(entry); -- 宠物技能升级次数
	end
	if (data.type==Proto.QOT_VIP) then
		data.param.vip=Proto.parseQuestObjectParam_PARAM_Vip(entry); -- VIP等级
	end
	if (data.type==Proto.QOT_EQUIPMENTINTENSIFYCOUNT) then
		data.param.equipmentIntensify=Proto.parseQuestObjectParam_PARAM_EquipmentIntensify(entry); -- 装备强化次数
	end
	if (data.type==Proto.QOT_EQUIPMENTMERGECOUNT) then
		data.param.equipmentMerge=Proto.parseQuestObjectParam_PARAM_EquipmentMerge(entry); -- 装备熔炼次数
	end
	if (data.type==Proto.QOT_EQUIPMENTRESETCOUNT) then
		data.param.equipmentReset=Proto.parseQuestObjectParam_PARAM_EquipmentReset(entry); -- 装备洗练次数
	end
	if (data.type==Proto.QOT_PETIMMOLATECOUNT) then
		data.param.petImmolateCount=Proto.parseQuestObjectParam_PARAM_PetImmolateCount(entry); -- 宠物献祭次数
	end
	return data;
end

function Proto.writeQuestObjectParam(msg,data)
	Proto.writeWORD(msg,data.type); -- 目标类型
	if (data.type==Proto.QOT_USEITEM) then
		Proto.writeQuestObjectParam_PARAM_UseItem(msg,data.param.useItem); -- 使用道具
	end
	if (data.type==Proto.QOT_USEITEMBYCATEGORY) then
		Proto.writeQuestObjectParam_PARAM_UseItemByCategory(msg,data.param.useItemByCategory); -- 按类别使用道具
	end
	if (data.type==Proto.QOT_ENDOWITEM) then
		Proto.writeQuestObjectParam_PARAM_EndowItem(msg,data.param.endowItem); -- 上交物品
	end
	if (data.type==Proto.QOT_KILLMONSTER) then
		Proto.writeQuestObjectParam_PARAM_KillMonster(msg,data.param.killMonster); -- 杀死怪物
	end
	if (data.type==Proto.QOT_EQUIPAVATAR) then
		Proto.writeQuestObjectParam_PARAM_EquipAvatar(msg,data.param.equipAvatar); -- 装备道具
	end
	if (data.type==Proto.QOT_ENTERREPETITION) then
		Proto.writeQuestObjectParam_PARAM_EnterRepetition(msg,data.param.enterRepetition); -- 进入副本
	end
	if (data.type==Proto.QOT_ENTERTOWN) then
		Proto.writeQuestObjectParam_PARAM_EnterTown(msg,data.param.enterTown); -- 进入副本
	end
	if (data.type==Proto.QOT_REPTITIONMOVE) then
		Proto.writeQuestObjectParam_PARAM_RepetitionMove(msg,data.param.repetitionMove); -- 副本移动
	end
	if (data.type==Proto.QOT_COLLECTITEM) then
		Proto.writeQuestObjectParam_PARAM_CollectItem(msg,data.param.collectItem); -- 采集道具
	end
	if (data.type==Proto.QOT_QUESTITEM) then
		Proto.writeQuestObjectParam_PARAM_QuestItem(msg,data.param.questItem); -- 上交任务道具
	end
	if (data.type==Proto.QOT_LEVELUPPET) then
		Proto.writeQuestObjectParam_PARAM_LevelUpPet(msg,data.param.levelUpPet); -- 升级宠物
	end
	if (data.type==Proto.QOT_FINISHQUEST) then
		Proto.writeQuestObjectParam_PARAM_FinishQuest(msg,data.param.finishQuest); -- 完成任务
	end
	if (data.type==Proto.QOT_PRODUCEFOOD) then
		Proto.writeQuestObjectParam_PARAM_ProduceFood(msg,data.param.produceFood); -- 生产食物
	end
	if (data.type==Proto.QOT_TALKWITHNPC) then
		Proto.writeQuestObjectParam_PARAM_TalkWithNpc(msg,data.param.talkWithNpc); -- 与NPC对话
	end
	if (data.type==Proto.QOT_FINISHACHIEVEMENT) then
		Proto.writeQuestObjectParam_PARAM_FinishAchievement(msg,data.param.finishAchievement); -- 完成成就
	end
	if (data.type==Proto.QOT_PRODUCEITEM) then
		Proto.writeQuestObjectParam_PARAM_ProduceItem(msg,data.param.produceItem); -- 生产道具
	end
	if (data.type==Proto.QOT_USEANYITEM) then
		Proto.writeQuestObjectParam_PARAM_UseAnyItem(msg,data.param.useAnyItem); -- 使用任一道具
	end
	if (data.type==Proto.QOT_NINKIPOINT) then
		Proto.writeQuestObjectParam_PARAM_NinkiPoint(msg,data.param.ninkiPoint); -- 人气点数
	end
	if (data.type==Proto.QOT_HARVESTITEM) then
		Proto.writeQuestObjectParam_PARAM_HarvestItem(msg,data.param.harvestItem); -- 收获指定物品达到一定数量
	end
	if (data.type==Proto.QOT_COMBATMONSTER) then
		Proto.writeQuestObjectParam_PARAM_CombatMonster(msg,data.param.combatMonster); -- 和指定类型怪物战斗
	end
	if (data.type==Proto.QOT_HAVEITEM) then
		Proto.writeQuestObjectParam_PARAM_HaveItem(msg,data.param.haveItem); -- 持有道具
	end
	if (data.type==Proto.QOT_ENDOWGCASH) then
		Proto.writeQuestObjectParam_PARAM_EndowGCash(msg,data.param.endowGCash); -- 上交G币
	end
	if (data.type==Proto.QOT_ENDOWNATIONCREDITMONEY) then
		Proto.writeQuestObjectParam_PARAM_EndowNationCreditMoney(msg,data.param.endowNationCreditMoney); -- 上交阵营信用卡货币
	end
	if (data.type==Proto.QOT_LEVELUPCHAR) then
		Proto.writeQuestObjectParam_PARAM_LevelUpChar(msg,data.param.levelUpChar); -- 人物升级
	end
	if (data.type==Proto.QOT_HATCHPET) then
		Proto.writeQuestObjectParam_PARAM_HatchPet(msg,data.param.hatchPet); -- 孵化宠物
	end
	if (data.type==Proto.QOT_LEVELUPPETWITHCOUNT) then
		Proto.writeQuestObjectParam_PARAM_LevelUpPetWithCount(msg,data.param.levelUpPetWithCount); -- 升级宠物(多个)
	end
	if (data.type==Proto.QOT_HAVEPET) then
		Proto.writeQuestObjectParam_PARAM_HavePet(msg,data.param.havePet); -- 拥有宠物
	end
	if (data.type==Proto.QOT_SEEPET) then
		Proto.writeQuestObjectParam_PARAM_SeePet(msg,data.param.seePet); -- 认识宠物
	end
	if (data.type==Proto.QOT_COLLECTPET) then
		Proto.writeQuestObjectParam_PARAM_CollectPet(msg,data.param.collectPet); -- 收集宠物
	end
	if (data.type==Proto.QOT_LEVELUPTRAININGGROUND) then
		Proto.writeQuestObjectParam_PARAM_LevelUpTrainingGround(msg,data.param.levelUpTrainingGround); -- 升级训练场
	end
	if (data.type==Proto.QOT_TRAINPETSTREAK) then
		Proto.writeQuestObjectParam_PARAM_TrainPetStreak(msg,data.param.trainPetStreak); -- 持续训练宠物
	end
	if (data.type==Proto.QOT_CHALLENGESTAGE) then
		Proto.writeQuestObjectParam_PARAM_ChallengeStage(msg,data.param.challengeStage); -- 挑战关卡
	end
	if (data.type==Proto.QOT_HAVEMCASH) then
		Proto.writeQuestObjectParam_PARAM_HaveMCash(msg,data.param.haveMCash); -- 拥有金钱
	end
	if (data.type==Proto.QOT_ARENARANK) then
		Proto.writeQuestObjectParam_PARAM_ArenaRank(msg,data.param.arenaRank); -- 竞技场排名
	end
	if (data.type==Proto.QOT_ARENACOUNT) then
		Proto.writeQuestObjectParam_PARAM_ArenaCount(msg,data.param.arenaCount); -- 竞技场挑战次数
	end
	if (data.type==Proto.QOT_ARENAWINSTREAK) then
		Proto.writeQuestObjectParam_PARAM_ArenaWinStreak(msg,data.param.arenaWinStreak); -- 竞技场连胜
	end
	if (data.type==Proto.QOT_ARENASTREAK) then
		Proto.writeQuestObjectParam_PARAM_ArenaStreak(msg,data.param.arenaStreak); -- 竞技场持续挑战
	end
	if (data.type==Proto.QOT_ADDFRIEND) then
		Proto.writeQuestObjectParam_PARAM_AddFriend(msg,data.param.addFriend); -- 添加好友
	end
	if (data.type==Proto.QOT_CHANLLENAGEFRIEND) then
		Proto.writeQuestObjectParam_PARAM_ChanllenageFriend(msg,data.param.chanllenageFriend); -- 挑战好友次数
	end
	if (data.type==Proto.QOT_TGRENTTIMES) then
		Proto.writeQuestObjectParam_PARAM_TGRentTimes(msg,data.param.tgRentTimes); -- 训练场被租用次数
	end
	if (data.type==Proto.QOT_BEATPET) then
		Proto.writeQuestObjectParam_PARAM_BeatPet(msg,data.param.beatPet); -- 击败怪物
	end
	if (data.type==Proto.QOT_PETSSTRENTHEN) then
		Proto.writeQuestObjectParam_PARAM_PetsStrenthen(msg,data.param.petsStrenthen); -- 强化宠物次数
	end
	if (data.type==Proto.QOT_QUALIFICATIONCOUNT) then
		Proto.writeQuestObjectParam_PARAM_QualificationCount(msg,data.param.qualificationCount); -- 宠物资质数量
	end
	if (data.type==Proto.QOT_EVOLUTIONTIMES) then
		Proto.writeQuestObjectParam_PARAM_EvolutionTimes(msg,data.param.evolutionTimes); -- 宠物进化次数
	end
	if (data.type==Proto.QOT_CHANLLENAGEFRIENDDAYCOUNT) then
		Proto.writeQuestObjectParam_PARAM_ChanllenageFriendDayCount(msg,data.param.chanllenageFriendDayCount); -- 连续挑战好友天数
	end
	if (data.type==Proto.QOT_ADDFRIENDDISCONTIUOUS) then
		Proto.writeQuestObjectParam_PARAM_AddFriendDiscountiuous(msg,data.param.addFriendDiscountiuous); -- 添加好友
	end
	if (data.type==Proto.QOT_HANGUPCOUNT) then
		Proto.writeQuestObjectParam_PARAM_HangUp(msg,data.param.hangup); -- 挂机次数
	end
	if (data.type==Proto.QOT_EATEGGCOUNT) then
		Proto.writeQuestObjectParam_PARAM_EatEgg(msg,data.param.eatEgg); -- 吃蛋次数
	end
	if (data.type==Proto.QOT_EATPETCOUNT) then
		Proto.writeQuestObjectParam_PARAM_EatPet(msg,data.param.eatPet); -- 宠物融合次数
	end
	if (data.type==Proto.QOT_CHANLLENGEBOSSCOUNT) then
		Proto.writeQuestObjectParam_PARAM_ChanllengeBoss(msg,data.param.chanllengeBoss); -- 挑战Boss次数
	end
	if (data.type==Proto.QOT_GACHACOUNT) then
		Proto.writeQuestObjectParam_PARAM_GaCha(msg,data.param.gacha); -- 扭蛋次数
	end
	if (data.type==Proto.QOT_SYNITEMCOUNT) then
		Proto.writeQuestObjectParam_PARAM_SynItem(msg,data.param.synItem); -- 道具合成次数
	end
	if (data.type==Proto.QOT_ALLELEPOWERUPCOUNT) then
		Proto.writeQuestObjectParam_PARAM_AllelePowerUp(msg,data.param.allelePowerUp); -- 宠物技能升级次数
	end
	if (data.type==Proto.QOT_VIP) then
		Proto.writeQuestObjectParam_PARAM_Vip(msg,data.param.vip); -- VIP等级
	end
	if (data.type==Proto.QOT_EQUIPMENTINTENSIFYCOUNT) then
		Proto.writeQuestObjectParam_PARAM_EquipmentIntensify(msg,data.param.equipmentIntensify); -- 装备强化次数
	end
	if (data.type==Proto.QOT_EQUIPMENTMERGECOUNT) then
		Proto.writeQuestObjectParam_PARAM_EquipmentMerge(msg,data.param.equipmentMerge); -- 装备熔炼次数
	end
	if (data.type==Proto.QOT_EQUIPMENTRESETCOUNT) then
		Proto.writeQuestObjectParam_PARAM_EquipmentReset(msg,data.param.equipmentReset); -- 装备洗练次数
	end
	if (data.type==Proto.QOT_PETIMMOLATECOUNT) then
		Proto.writeQuestObjectParam_PARAM_PetImmolateCount(msg,data.param.petImmolateCount); -- 宠物献祭次数
	end
end

function Proto.parseQuestObjectData_DATA_KillMonster(entry)
	local data={};
	data.count=Proto.parseWORD(entry); -- 怪物数量
	return data;
end

function Proto.writeQuestObjectData_DATA_KillMonster(msg,data)
	Proto.writeWORD(msg,data.count); -- 怪物数量
end

function Proto.parseQuestObjectData_DATA_UseItem(entry)
	local data={};
	data.count=Proto.parseWORD(entry); -- 道具数量
	return data;
end

function Proto.writeQuestObjectData_DATA_UseItem(msg,data)
	Proto.writeWORD(msg,data.count); -- 道具数量
end

function Proto.parseQuestObjectData_DATA_UseItemByCategory(entry)
	local data={};
	data.count=Proto.parseWORD(entry); -- 道具数量
	return data;
end

function Proto.writeQuestObjectData_DATA_UseItemByCategory(msg,data)
	Proto.writeWORD(msg,data.count); -- 道具数量
end

function Proto.parseQuestObjectData_DATA_ProduceFood(entry)
	local data={};
	data.count=Proto.parseWORD(entry); -- 已生产份数
	return data;
end

function Proto.writeQuestObjectData_DATA_ProduceFood(msg,data)
	Proto.writeWORD(msg,data.count); -- 已生产份数
end

function Proto.parseQuestObjectData_DATA_HarvestItem(entry)
	local data={};
	data.count=Proto.parseDWORD(entry); -- 已收获数量
	return data;
end

function Proto.writeQuestObjectData_DATA_HarvestItem(msg,data)
	Proto.writeDWORD(msg,data.count); -- 已收获数量
end

function Proto.parseQuestObjectData_DATA_CombatMonster(entry)
	local data={};
	data.count=Proto.parseWORD(entry); -- 怪物数量
	return data;
end

function Proto.writeQuestObjectData_DATA_CombatMonster(msg,data)
	Proto.writeWORD(msg,data.count); -- 怪物数量
end

function Proto.parseQuestObjectData_DATA_HatchPet(entry)
	local data={};
	data.count=Proto.parseWORD(entry); -- 数量
	return data;
end

function Proto.writeQuestObjectData_DATA_HatchPet(msg,data)
	Proto.writeWORD(msg,data.count); -- 数量
end

function Proto.parseQuestObjectData_DATA_LevelUpPetWithCount(entry)
	local data={};
	data.count=Proto.parseWORD(entry); -- 数量
	return data;
end

function Proto.writeQuestObjectData_DATA_LevelUpPetWithCount(msg,data)
	Proto.writeWORD(msg,data.count); -- 数量
end

function Proto.parseQuestObjectData_DATA_HavePet(entry)
	local data={};
	data.count=Proto.parseWORD(entry); -- 数量
	return data;
end

function Proto.writeQuestObjectData_DATA_HavePet(msg,data)
	Proto.writeWORD(msg,data.count); -- 数量
end

function Proto.parseQuestObjectData_DATA_SeePet(entry)
	local data={};
	data.count=Proto.parseWORD(entry); -- 数量
	return data;
end

function Proto.writeQuestObjectData_DATA_SeePet(msg,data)
	Proto.writeWORD(msg,data.count); -- 数量
end

function Proto.parseQuestObjectData_DATA_CollectPet(entry)
	local data={};
	data.count=Proto.parseWORD(entry); -- 数量
	return data;
end

function Proto.writeQuestObjectData_DATA_CollectPet(msg,data)
	Proto.writeWORD(msg,data.count); -- 数量
end

function Proto.parseQuestObjectData_DATA_TrainPetStreak(entry)
	local data={};
	data.count=Proto.parseWORD(entry); -- 数量
	data.lastTime=Proto.parseTIME_SEC(entry); -- 上次记录时间
	return data;
end

function Proto.writeQuestObjectData_DATA_TrainPetStreak(msg,data)
	Proto.writeWORD(msg,data.count); -- 数量
	Proto.writeTIME_SEC(msg,data.lastTime); -- 上次记录时间
end

function Proto.parseQuestObjectData_DATA_ArenaCount(entry)
	local data={};
	data.lastTime=Proto.parseTIME_SEC(entry); -- 上次记录时间
	data.count=Proto.parseDWORD(entry); -- 数量
	return data;
end

function Proto.writeQuestObjectData_DATA_ArenaCount(msg,data)
	Proto.writeTIME_SEC(msg,data.lastTime); -- 上次记录时间
	Proto.writeDWORD(msg,data.count); -- 数量
end

function Proto.parseQuestObjectData_DATA_ArenaWinStreak(entry)
	local data={};
	data.count=Proto.parseDWORD(entry); -- 数量
	return data;
end

function Proto.writeQuestObjectData_DATA_ArenaWinStreak(msg,data)
	Proto.writeDWORD(msg,data.count); -- 数量
end

function Proto.parseQuestObjectData_DATA_ArenaStreak(entry)
	local data={};
	data.count=Proto.parseDWORD(entry); -- 数量
	data.lastTime=Proto.parseTIME_SEC(entry); -- 上次记录时间
	return data;
end

function Proto.writeQuestObjectData_DATA_ArenaStreak(msg,data)
	Proto.writeDWORD(msg,data.count); -- 数量
	Proto.writeTIME_SEC(msg,data.lastTime); -- 上次记录时间
end

function Proto.parseQuestObjectData_DATA_ADDFriend(entry)
	local data={};
	data.count=Proto.parseDWORD(entry); -- 数量
	return data;
end

function Proto.writeQuestObjectData_DATA_ADDFriend(msg,data)
	Proto.writeDWORD(msg,data.count); -- 数量
end

function Proto.parseQuestObjectData_DATA_ChanllenageFriend(entry)
	local data={};
	data.count=Proto.parseDWORD(entry); -- 数量
	return data;
end

function Proto.writeQuestObjectData_DATA_ChanllenageFriend(msg,data)
	Proto.writeDWORD(msg,data.count); -- 数量
end

function Proto.parseQuestObjectData_DATA_TGRentTimes(entry)
	local data={};
	data.count=Proto.parseDWORD(entry); -- 数量
	data.lastTime=Proto.parseTIME_SEC(entry); -- 上次记录时间
	return data;
end

function Proto.writeQuestObjectData_DATA_TGRentTimes(msg,data)
	Proto.writeDWORD(msg,data.count); -- 数量
	Proto.writeTIME_SEC(msg,data.lastTime); -- 上次记录时间
end

function Proto.parseQuestObjectData_DATA_BeatPet(entry)
	local data={};
	data.count=Proto.parseWORD(entry); -- 怪物数量
	return data;
end

function Proto.writeQuestObjectData_DATA_BeatPet(msg,data)
	Proto.writeWORD(msg,data.count); -- 怪物数量
end

function Proto.parseQuestObjectData_DATA_PetsStrenthen(entry)
	local data={};
	data.count=Proto.parseWORD(entry); -- 次数
	return data;
end

function Proto.writeQuestObjectData_DATA_PetsStrenthen(msg,data)
	Proto.writeWORD(msg,data.count); -- 次数
end

function Proto.parseQuestObjectData_DATA_QualificationCount(entry)
	local data={};
	data.count=Proto.parseWORD(entry); -- 次数
	return data;
end

function Proto.writeQuestObjectData_DATA_QualificationCount(msg,data)
	Proto.writeWORD(msg,data.count); -- 次数
end

function Proto.parseQuestObjectData_DATA_EvolutionTimes(entry)
	local data={};
	data.count=Proto.parseWORD(entry); -- 次数
	return data;
end

function Proto.writeQuestObjectData_DATA_EvolutionTimes(msg,data)
	Proto.writeWORD(msg,data.count); -- 次数
end

function Proto.parseQuestObjectData_DATA_ChanllenageFriendDayCount(entry)
	local data={};
	data.count=Proto.parseDWORD(entry); -- 数量
	data.lastTime=Proto.parseTIME_SEC(entry); -- 上次记录时间
	return data;
end

function Proto.writeQuestObjectData_DATA_ChanllenageFriendDayCount(msg,data)
	Proto.writeDWORD(msg,data.count); -- 数量
	Proto.writeTIME_SEC(msg,data.lastTime); -- 上次记录时间
end

function Proto.parseQuestObjectData_DATA_ADDFriendDiscountiuous(entry)
	local data={};
	data.count=Proto.parseDWORD(entry); -- 数量
	return data;
end

function Proto.writeQuestObjectData_DATA_ADDFriendDiscountiuous(msg,data)
	Proto.writeDWORD(msg,data.count); -- 数量
end

function Proto.parseQuestObjectData_DATA_HangUp(entry)
	local data={};
	data.count=Proto.parseWORD(entry); -- 数量
	return data;
end

function Proto.writeQuestObjectData_DATA_HangUp(msg,data)
	Proto.writeWORD(msg,data.count); -- 数量
end

function Proto.parseQuestObjectData_DATA_EatEgg(entry)
	local data={};
	data.count=Proto.parseWORD(entry); -- 数量
	return data;
end

function Proto.writeQuestObjectData_DATA_EatEgg(msg,data)
	Proto.writeWORD(msg,data.count); -- 数量
end

function Proto.parseQuestObjectData_DATA_EatPet(entry)
	local data={};
	data.count=Proto.parseWORD(entry); -- 数量
	return data;
end

function Proto.writeQuestObjectData_DATA_EatPet(msg,data)
	Proto.writeWORD(msg,data.count); -- 数量
end

function Proto.parseQuestObjectData_DATA_ChanllengeBoss(entry)
	local data={};
	data.count=Proto.parseWORD(entry); -- 数量
	return data;
end

function Proto.writeQuestObjectData_DATA_ChanllengeBoss(msg,data)
	Proto.writeWORD(msg,data.count); -- 数量
end

function Proto.parseQuestObjectData_DATA_GaCha(entry)
	local data={};
	data.count=Proto.parseWORD(entry); -- 数量
	return data;
end

function Proto.writeQuestObjectData_DATA_GaCha(msg,data)
	Proto.writeWORD(msg,data.count); -- 数量
end

function Proto.parseQuestObjectData_DATA_SynItem(entry)
	local data={};
	data.count=Proto.parseWORD(entry); -- 数量
	return data;
end

function Proto.writeQuestObjectData_DATA_SynItem(msg,data)
	Proto.writeWORD(msg,data.count); -- 数量
end

function Proto.parseQuestObjectData_DATA_AllelePowerUp(entry)
	local data={};
	data.count=Proto.parseWORD(entry); -- 数量
	return data;
end

function Proto.writeQuestObjectData_DATA_AllelePowerUp(msg,data)
	Proto.writeWORD(msg,data.count); -- 数量
end

function Proto.parseQuestObjectData_DATA_Vip(entry)
	local data={};
	data.count=Proto.parseWORD(entry); -- 数量
	return data;
end

function Proto.writeQuestObjectData_DATA_Vip(msg,data)
	Proto.writeWORD(msg,data.count); -- 数量
end

function Proto.parseQuestObjectData_DATA_EquipmentIntensify(entry)
	local data={};
	data.count=Proto.parseWORD(entry); -- 数量
	return data;
end

function Proto.writeQuestObjectData_DATA_EquipmentIntensify(msg,data)
	Proto.writeWORD(msg,data.count); -- 数量
end

function Proto.parseQuestObjectData_DATA_EquipmentMerge(entry)
	local data={};
	data.count=Proto.parseWORD(entry); -- 数量
	return data;
end

function Proto.writeQuestObjectData_DATA_EquipmentMerge(msg,data)
	Proto.writeWORD(msg,data.count); -- 数量
end

function Proto.parseQuestObjectData_DATA_EquipmentReset(entry)
	local data={};
	data.count=Proto.parseWORD(entry); -- 数量
	return data;
end

function Proto.writeQuestObjectData_DATA_EquipmentReset(msg,data)
	Proto.writeWORD(msg,data.count); -- 数量
end

function Proto.parseQuestObjectData_DATA_PetImmolateCount(entry)
	local data={};
	data.count=Proto.parseWORD(entry); -- 次数
	return data;
end

function Proto.writeQuestObjectData_DATA_PetImmolateCount(msg,data)
	Proto.writeWORD(msg,data.count); -- 次数
end

function Proto.parseQuestObjectData(entry)
	local data={};
	data.type=Proto.parseWORD(entry); -- 目标类型
	data.data={}; -- 
	if (data.type==Proto.QOT_KILLMONSTER) then
		data.data.killMonster=Proto.parseQuestObjectData_DATA_KillMonster(entry); -- 杀死怪物
	end
	if (data.type==Proto.QOT_USEITEM) then
		data.data.useItem=Proto.parseQuestObjectData_DATA_UseItem(entry); -- 使用道具
	end
	if (data.type==Proto.QOT_USEITEMBYCATEGORY) then
		data.data.useItemByCategory=Proto.parseQuestObjectData_DATA_UseItemByCategory(entry); -- 按类别使用道具
	end
	if (data.type==Proto.QOT_PRODUCEFOOD) then
		data.data.produceFood=Proto.parseQuestObjectData_DATA_ProduceFood(entry); -- 生产食物
	end
	if (data.type==Proto.QOT_HARVESTITEM) then
		data.data.harvestItem=Proto.parseQuestObjectData_DATA_HarvestItem(entry); -- 收获指定物品达到一定数量
	end
	if (data.type==Proto.QOT_COMBATMONSTER) then
		data.data.combatMonster=Proto.parseQuestObjectData_DATA_CombatMonster(entry); -- 和指定类型的怪物开始战斗
	end
	if (data.type==Proto.QOT_HATCHPET) then
		data.data.hatchPet=Proto.parseQuestObjectData_DATA_HatchPet(entry); -- 孵化宠物
	end
	if (data.type==Proto.QOT_LEVELUPPETWITHCOUNT) then
		data.data.levelUpPetWithCount=Proto.parseQuestObjectData_DATA_LevelUpPetWithCount(entry); -- 升级宠物
	end
	if (data.type==Proto.QOT_HAVEPET) then
		data.data.havePet=Proto.parseQuestObjectData_DATA_HavePet(entry); -- 拥有宠物
	end
	if (data.type==Proto.QOT_SEEPET) then
		data.data.seePet=Proto.parseQuestObjectData_DATA_SeePet(entry); -- 认识宠物
	end
	if (data.type==Proto.QOT_COLLECTPET) then
		data.data.collectPet=Proto.parseQuestObjectData_DATA_CollectPet(entry); -- 收集宠物
	end
	if (data.type==Proto.QOT_TRAINPETSTREAK) then
		data.data.trainPetStreak=Proto.parseQuestObjectData_DATA_TrainPetStreak(entry); -- 持续训练宠物
	end
	if (data.type==Proto.QOT_ARENACOUNT) then
		data.data.arenaCount=Proto.parseQuestObjectData_DATA_ArenaCount(entry); -- 竞技场挑战次数
	end
	if (data.type==Proto.QOT_ARENAWINSTREAK) then
		data.data.arenaWinStreak=Proto.parseQuestObjectData_DATA_ArenaWinStreak(entry); -- 竞技场连胜
	end
	if (data.type==Proto.QOT_ARENASTREAK) then
		data.data.arenaStreak=Proto.parseQuestObjectData_DATA_ArenaStreak(entry); -- 竞技场持续挑战
	end
	if (data.type==Proto.QOT_ADDFRIEND) then
		data.data.addFriend=Proto.parseQuestObjectData_DATA_ADDFriend(entry); -- 添加好友
	end
	if (data.type==Proto.QOT_CHANLLENAGEFRIEND) then
		data.data.chanllenageFriend=Proto.parseQuestObjectData_DATA_ChanllenageFriend(entry); -- 挑战好友次数
	end
	if (data.type==Proto.QOT_TGRENTTIMES) then
		data.data.tgRentTimes=Proto.parseQuestObjectData_DATA_TGRentTimes(entry); -- 训练场被租用次数
	end
	if (data.type==Proto.QOT_BEATPET) then
		data.data.beatPet=Proto.parseQuestObjectData_DATA_BeatPet(entry); -- 击败怪物
	end
	if (data.type==Proto.QOT_PETSSTRENTHEN) then
		data.data.petsStrenthen=Proto.parseQuestObjectData_DATA_PetsStrenthen(entry); -- 强化宠物次数
	end
	if (data.type==Proto.QOT_QUALIFICATIONCOUNT) then
		data.data.qualificationCount=Proto.parseQuestObjectData_DATA_QualificationCount(entry); -- 宠物资质数量
	end
	if (data.type==Proto.QOT_EVOLUTIONTIMES) then
		data.data.evolutionTimes=Proto.parseQuestObjectData_DATA_EvolutionTimes(entry); -- 宠物进化次数
	end
	if (data.type==Proto.QOT_CHANLLENAGEFRIENDDAYCOUNT) then
		data.data.chanllenageFriendDayCount=Proto.parseQuestObjectData_DATA_ChanllenageFriendDayCount(entry); -- 连续挑战好友天数
	end
	if (data.type==Proto.QOT_ADDFRIENDDISCONTIUOUS) then
		data.data.addFriendDiscountiuous=Proto.parseQuestObjectData_DATA_ADDFriendDiscountiuous(entry); -- 添加好友
	end
	if (data.type==Proto.QOT_HANGUPCOUNT) then
		data.data.hangup=Proto.parseQuestObjectData_DATA_HangUp(entry); -- 挂机次数
	end
	if (data.type==Proto.QOT_EATEGGCOUNT) then
		data.data.eatEgg=Proto.parseQuestObjectData_DATA_EatEgg(entry); -- 吃蛋次数
	end
	if (data.type==Proto.QOT_EATPETCOUNT) then
		data.data.eatPet=Proto.parseQuestObjectData_DATA_EatPet(entry); -- 宠物融合次数
	end
	if (data.type==Proto.QOT_CHANLLENGEBOSSCOUNT) then
		data.data.chanllengeBoss=Proto.parseQuestObjectData_DATA_ChanllengeBoss(entry); -- 挑战Boss次数
	end
	if (data.type==Proto.QOT_GACHACOUNT) then
		data.data.gacha=Proto.parseQuestObjectData_DATA_GaCha(entry); -- 扭蛋次数
	end
	if (data.type==Proto.QOT_SYNITEMCOUNT) then
		data.data.synItem=Proto.parseQuestObjectData_DATA_SynItem(entry); -- 道具合成次数
	end
	if (data.type==Proto.QOT_ALLELEPOWERUPCOUNT) then
		data.data.allelePowerUp=Proto.parseQuestObjectData_DATA_AllelePowerUp(entry); -- 宠物技能升级次数
	end
	if (data.type==Proto.QOT_VIP) then
		data.data.vip=Proto.parseQuestObjectData_DATA_Vip(entry); -- VIP等级
	end
	if (data.type==Proto.QOT_EQUIPMENTINTENSIFYCOUNT) then
		data.data.equipmentIntensify=Proto.parseQuestObjectData_DATA_EquipmentIntensify(entry); -- 装备强化次数
	end
	if (data.type==Proto.QOT_EQUIPMENTMERGECOUNT) then
		data.data.equipmentMerge=Proto.parseQuestObjectData_DATA_EquipmentMerge(entry); -- 装备熔炼次数
	end
	if (data.type==Proto.QOT_EQUIPMENTRESETCOUNT) then
		data.data.equipmentReset=Proto.parseQuestObjectData_DATA_EquipmentReset(entry); -- 装备洗练次数
	end
	if (data.type==Proto.QOT_PETIMMOLATECOUNT) then
		data.data.petImmolateCount=Proto.parseQuestObjectData_DATA_PetImmolateCount(entry); -- 宠物献祭次数
	end
	return data;
end

function Proto.writeQuestObjectData(msg,data)
	Proto.writeWORD(msg,data.type); -- 目标类型
	if (data.type==Proto.QOT_KILLMONSTER) then
		Proto.writeQuestObjectData_DATA_KillMonster(msg,data.data.killMonster); -- 杀死怪物
	end
	if (data.type==Proto.QOT_USEITEM) then
		Proto.writeQuestObjectData_DATA_UseItem(msg,data.data.useItem); -- 使用道具
	end
	if (data.type==Proto.QOT_USEITEMBYCATEGORY) then
		Proto.writeQuestObjectData_DATA_UseItemByCategory(msg,data.data.useItemByCategory); -- 按类别使用道具
	end
	if (data.type==Proto.QOT_PRODUCEFOOD) then
		Proto.writeQuestObjectData_DATA_ProduceFood(msg,data.data.produceFood); -- 生产食物
	end
	if (data.type==Proto.QOT_HARVESTITEM) then
		Proto.writeQuestObjectData_DATA_HarvestItem(msg,data.data.harvestItem); -- 收获指定物品达到一定数量
	end
	if (data.type==Proto.QOT_COMBATMONSTER) then
		Proto.writeQuestObjectData_DATA_CombatMonster(msg,data.data.combatMonster); -- 和指定类型的怪物开始战斗
	end
	if (data.type==Proto.QOT_HATCHPET) then
		Proto.writeQuestObjectData_DATA_HatchPet(msg,data.data.hatchPet); -- 孵化宠物
	end
	if (data.type==Proto.QOT_LEVELUPPETWITHCOUNT) then
		Proto.writeQuestObjectData_DATA_LevelUpPetWithCount(msg,data.data.levelUpPetWithCount); -- 升级宠物
	end
	if (data.type==Proto.QOT_HAVEPET) then
		Proto.writeQuestObjectData_DATA_HavePet(msg,data.data.havePet); -- 拥有宠物
	end
	if (data.type==Proto.QOT_SEEPET) then
		Proto.writeQuestObjectData_DATA_SeePet(msg,data.data.seePet); -- 认识宠物
	end
	if (data.type==Proto.QOT_COLLECTPET) then
		Proto.writeQuestObjectData_DATA_CollectPet(msg,data.data.collectPet); -- 收集宠物
	end
	if (data.type==Proto.QOT_TRAINPETSTREAK) then
		Proto.writeQuestObjectData_DATA_TrainPetStreak(msg,data.data.trainPetStreak); -- 持续训练宠物
	end
	if (data.type==Proto.QOT_ARENACOUNT) then
		Proto.writeQuestObjectData_DATA_ArenaCount(msg,data.data.arenaCount); -- 竞技场挑战次数
	end
	if (data.type==Proto.QOT_ARENAWINSTREAK) then
		Proto.writeQuestObjectData_DATA_ArenaWinStreak(msg,data.data.arenaWinStreak); -- 竞技场连胜
	end
	if (data.type==Proto.QOT_ARENASTREAK) then
		Proto.writeQuestObjectData_DATA_ArenaStreak(msg,data.data.arenaStreak); -- 竞技场持续挑战
	end
	if (data.type==Proto.QOT_ADDFRIEND) then
		Proto.writeQuestObjectData_DATA_ADDFriend(msg,data.data.addFriend); -- 添加好友
	end
	if (data.type==Proto.QOT_CHANLLENAGEFRIEND) then
		Proto.writeQuestObjectData_DATA_ChanllenageFriend(msg,data.data.chanllenageFriend); -- 挑战好友次数
	end
	if (data.type==Proto.QOT_TGRENTTIMES) then
		Proto.writeQuestObjectData_DATA_TGRentTimes(msg,data.data.tgRentTimes); -- 训练场被租用次数
	end
	if (data.type==Proto.QOT_BEATPET) then
		Proto.writeQuestObjectData_DATA_BeatPet(msg,data.data.beatPet); -- 击败怪物
	end
	if (data.type==Proto.QOT_PETSSTRENTHEN) then
		Proto.writeQuestObjectData_DATA_PetsStrenthen(msg,data.data.petsStrenthen); -- 强化宠物次数
	end
	if (data.type==Proto.QOT_QUALIFICATIONCOUNT) then
		Proto.writeQuestObjectData_DATA_QualificationCount(msg,data.data.qualificationCount); -- 宠物资质数量
	end
	if (data.type==Proto.QOT_EVOLUTIONTIMES) then
		Proto.writeQuestObjectData_DATA_EvolutionTimes(msg,data.data.evolutionTimes); -- 宠物进化次数
	end
	if (data.type==Proto.QOT_CHANLLENAGEFRIENDDAYCOUNT) then
		Proto.writeQuestObjectData_DATA_ChanllenageFriendDayCount(msg,data.data.chanllenageFriendDayCount); -- 连续挑战好友天数
	end
	if (data.type==Proto.QOT_ADDFRIENDDISCONTIUOUS) then
		Proto.writeQuestObjectData_DATA_ADDFriendDiscountiuous(msg,data.data.addFriendDiscountiuous); -- 添加好友
	end
	if (data.type==Proto.QOT_HANGUPCOUNT) then
		Proto.writeQuestObjectData_DATA_HangUp(msg,data.data.hangup); -- 挂机次数
	end
	if (data.type==Proto.QOT_EATEGGCOUNT) then
		Proto.writeQuestObjectData_DATA_EatEgg(msg,data.data.eatEgg); -- 吃蛋次数
	end
	if (data.type==Proto.QOT_EATPETCOUNT) then
		Proto.writeQuestObjectData_DATA_EatPet(msg,data.data.eatPet); -- 宠物融合次数
	end
	if (data.type==Proto.QOT_CHANLLENGEBOSSCOUNT) then
		Proto.writeQuestObjectData_DATA_ChanllengeBoss(msg,data.data.chanllengeBoss); -- 挑战Boss次数
	end
	if (data.type==Proto.QOT_GACHACOUNT) then
		Proto.writeQuestObjectData_DATA_GaCha(msg,data.data.gacha); -- 扭蛋次数
	end
	if (data.type==Proto.QOT_SYNITEMCOUNT) then
		Proto.writeQuestObjectData_DATA_SynItem(msg,data.data.synItem); -- 道具合成次数
	end
	if (data.type==Proto.QOT_ALLELEPOWERUPCOUNT) then
		Proto.writeQuestObjectData_DATA_AllelePowerUp(msg,data.data.allelePowerUp); -- 宠物技能升级次数
	end
	if (data.type==Proto.QOT_VIP) then
		Proto.writeQuestObjectData_DATA_Vip(msg,data.data.vip); -- VIP等级
	end
	if (data.type==Proto.QOT_EQUIPMENTINTENSIFYCOUNT) then
		Proto.writeQuestObjectData_DATA_EquipmentIntensify(msg,data.data.equipmentIntensify); -- 装备强化次数
	end
	if (data.type==Proto.QOT_EQUIPMENTMERGECOUNT) then
		Proto.writeQuestObjectData_DATA_EquipmentMerge(msg,data.data.equipmentMerge); -- 装备熔炼次数
	end
	if (data.type==Proto.QOT_EQUIPMENTRESETCOUNT) then
		Proto.writeQuestObjectData_DATA_EquipmentReset(msg,data.data.equipmentReset); -- 装备洗练次数
	end
	if (data.type==Proto.QOT_PETIMMOLATECOUNT) then
		Proto.writeQuestObjectData_DATA_PetImmolateCount(msg,data.data.petImmolateCount); -- 宠物献祭次数
	end
end

function Proto.parseQuestObject(entry)
	local data={};
	data.index=Proto.parseBYTE(entry); -- 索引
	data.finished=Proto.parseBYTE(entry); -- 是否完成
	data.param=Proto.parseQuestObjectParam(entry); -- 参数
	data.data=Proto.parseQuestObjectData(entry); -- 数据
	return data;
end

function Proto.writeQuestObject(msg,data)
	Proto.writeBYTE(msg,data.index); -- 索引
	Proto.writeBYTE(msg,data.finished); -- 是否完成
	Proto.writeQuestObjectParam(msg,data.param); -- 参数
	Proto.writeQuestObjectData(msg,data.data); -- 数据
end

function Proto.parseQuestObjectInfo(entry)
	local data={};
	data.param=Proto.parseQuestObjectParam(entry); -- 目标参数
	data.desc=Proto.parseQuestObjectDesc(entry); -- 目标描述
	data.extraDialog=Proto.parseQuestDialogContent(entry); -- 附加对话
	return data;
end

function Proto.writeQuestObjectInfo(msg,data)
	Proto.writeQuestObjectParam(msg,data.param); -- 目标参数
	Proto.writeQuestObjectDesc(msg,data.desc); -- 目标描述
	Proto.writeQuestDialogContent(msg,data.extraDialog); -- 附加对话
end

function Proto.parseQuest(entry)
	local data={};
	data.id=Proto.parseWORD(entry); -- 任务ID
	data.index=Proto.parseBYTE(entry); -- 索引
	data.deadline=Proto.parseTIME_SEC(entry); -- 最后期限
	data.objects=Proto.parseVarArray(entry,Proto.parseQuestObject,Proto.parseWORD); -- 任务目标
	return data;
end

function Proto.getQuestIDLen()
	return Proto.getWORDLen();
end

function Proto.writeQuest(msg,data)
	Proto.writeWORD(msg,data.id); -- 任务ID
	Proto.writeBYTE(msg,data.index); -- 索引
	Proto.writeTIME_SEC(msg,data.deadline); -- 最后期限
	Proto.writeVarArray(msg,data.objects,Proto.writeQuestObject,Proto.writeWORD); -- 任务目标
end

function Proto.parseQuestItemInfo(entry)
	local data={};
	data.generateID=Proto.parseDWORD(entry); -- 道具生成规则
	data.count=Proto.parseWORD(entry); -- 数量
	return data;
end

function Proto.writeQuestItemInfo(msg,data)
	Proto.writeDWORD(msg,data.generateID); -- 道具生成规则
	Proto.writeWORD(msg,data.count); -- 数量
end

function Proto.parseQuestAcceptRule(entry)
	local data={};
	data.achievement=Proto.parseDWORD(entry); -- 需要成就
	data.acceptCondition=Proto.parseQuestAcceptCondition(entry); -- 接受条件
	return data;
end

function Proto.writeQuestAcceptRule(msg,data)
	Proto.writeDWORD(msg,data.achievement); -- 需要成就
	Proto.writeQuestAcceptCondition(msg,data.acceptCondition); -- 接受条件
end

function Proto.parseQuestFinishRule(entry)
	local data={};
	data.finishCondition=Proto.parseString(entry); -- 完成条件
	return data;
end

function Proto.writeQuestFinishRule(msg,data)
	Proto.writeString(msg,data.finishCondition); -- 完成条件
end

function Proto.parseQuestInfo(entry)
	local data={};
	data.id=Proto.parseWORD(entry); -- 任务ID
	data.name=Proto.parseQuestName(entry); -- 任务名称
	data.desc=Proto.parseQuestDesc(entry); -- 任务描述
	data.level=Proto.parseWORD(entry); -- 级别
	data.maxLevel=Proto.parseWORD(entry); -- 最大级别
	data.mainBody=Proto.parseBYTE(entry); -- 主体
	data.repeatType=Proto.parseBYTE(entry); -- 重复类型
	data.secs=Proto.parseDWORD(entry); -- 时间限制(秒)
	data.condition=Proto.parseQuestAcceptRule(entry); -- 接受条件
	data.finishCondition=Proto.parseQuestFinishRule(entry); -- 完成条件
	data.items=Proto.parseVarArray(entry,Proto.parseQuestItemInfo,Proto.parseWORD); -- 赠送道具
	data.objects=Proto.parseVarArray(entry,Proto.parseQuestObjectInfo,Proto.parseWORD); -- 任务目标
	data.baseExperience=Proto.parseDWORD(entry); -- 基本经验奖励(按照等级变动)
	data.baseAward=Proto.parseAwardGroup(entry); -- 基本奖励
	data.awardGroups=Proto.parseVarArray(entry,Proto.parseAwardGroup,Proto.parseWORD); -- 奖励物品组
	data.acceptDialog=Proto.parseQuestDialogContent(entry); -- 接受任务对话
	data.finishDialog=Proto.parseQuestDialogContent(entry); -- 完成任务对话
	data.unfinishDialog=Proto.parseQuestDialogContent(entry); -- 未完成任务对话
	data.previousQuest=Proto.parseWORD(entry); -- 前序任务
	return data;
end

function Proto.getQuestInfoIDLen()
	return Proto.getWORDLen();
end

function Proto.writeQuestInfo(msg,data)
	Proto.writeWORD(msg,data.id); -- 任务ID
	Proto.writeQuestName(msg,data.name); -- 任务名称
	Proto.writeQuestDesc(msg,data.desc); -- 任务描述
	Proto.writeWORD(msg,data.level); -- 级别
	Proto.writeWORD(msg,data.maxLevel); -- 最大级别
	Proto.writeBYTE(msg,data.mainBody); -- 主体
	Proto.writeBYTE(msg,data.repeatType); -- 重复类型
	Proto.writeDWORD(msg,data.secs); -- 时间限制(秒)
	Proto.writeQuestAcceptRule(msg,data.condition); -- 接受条件
	Proto.writeQuestFinishRule(msg,data.finishCondition); -- 完成条件
	Proto.writeVarArray(msg,data.items,Proto.writeQuestItemInfo,Proto.writeWORD); -- 赠送道具
	Proto.writeVarArray(msg,data.objects,Proto.writeQuestObjectInfo,Proto.writeWORD); -- 任务目标
	Proto.writeDWORD(msg,data.baseExperience); -- 基本经验奖励(按照等级变动)
	Proto.writeAwardGroup(msg,data.baseAward); -- 基本奖励
	Proto.writeVarArray(msg,data.awardGroups,Proto.writeAwardGroup,Proto.writeWORD); -- 奖励物品组
	Proto.writeQuestDialogContent(msg,data.acceptDialog); -- 接受任务对话
	Proto.writeQuestDialogContent(msg,data.finishDialog); -- 完成任务对话
	Proto.writeQuestDialogContent(msg,data.unfinishDialog); -- 未完成任务对话
	Proto.writeWORD(msg,data.previousQuest); -- 前序任务
end

function Proto.parseQuestTriggerInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 任务凭证道具ID
	data.questID=Proto.parseWORD(entry); -- 对应的任务ID
	return data;
end

function Proto.getQuestTriggerInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeQuestTriggerInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 任务凭证道具ID
	Proto.writeWORD(msg,data.questID); -- 对应的任务ID
end

function Proto.parseRaceQuestInfo(entry)
	local data={};
	data.id=Proto.parseWORD(entry); -- 任务ID
	data.races=Proto.parseVector(entry,Proto.parseBYTE); -- 种类
	return data;
end

function Proto.getRaceQuestInfoIDLen()
	return Proto.getWORDLen();
end

function Proto.writeRaceQuestInfo(msg,data)
	Proto.writeWORD(msg,data.id); -- 任务ID
	Proto.writeVector(msg,data.races,Proto.writeBYTE); -- 种类
end

function Proto.parseQuestCoolDownInfo(entry)
	local data={};
	data.id=Proto.parseWORD(entry); -- 冷却编号
	data.name=Proto.parseString(entry); -- 任务名称
	data.compeleteCoolDown=Proto.parseTIME_SEC(entry); -- 完成冷却
	data.cancelCoolDown=Proto.parseTIME_SEC(entry); -- 放弃冷却
	data.countLimit=Proto.parseWORD(entry); -- 累计次数限制
	if (data.countLimit ~=0) then
		data.countLimitClearScript=Proto.parseString(entry); -- 下回清空累计次数时刻脚本
	end
	data.groupedQuests=Proto.parseVector(entry,Proto.parseWORD); -- 属于本组的任务
	return data;
end

function Proto.getQuestCoolDownInfoIDLen()
	return Proto.getWORDLen();
end

function Proto.writeQuestCoolDownInfo(msg,data)
	Proto.writeWORD(msg,data.id); -- 冷却编号
	Proto.writeString(msg,data.name); -- 任务名称
	Proto.writeTIME_SEC(msg,data.compeleteCoolDown); -- 完成冷却
	Proto.writeTIME_SEC(msg,data.cancelCoolDown); -- 放弃冷却
	Proto.writeWORD(msg,data.countLimit); -- 累计次数限制
	if (data.countLimit ~=0) then
		Proto.writeString(msg,data.countLimitClearScript); -- 下回清空累计次数时刻脚本
	end
	Proto.writeVector(msg,data.groupedQuests,Proto.writeWORD); -- 属于本组的任务
end

function Proto.parseQuestCoolDownData(entry)
	local data={};
	data.infoID=Proto.parseWORD(entry); -- 冷却组ID
	data.coolDown=Proto.parseTIME_SEC(entry); -- 冷却
	data.count=Proto.parseWORD(entry); -- 累计次数
	data.countClearTime=Proto.parseTIME_SEC(entry); -- 次数清空时间
	return data;
end

function Proto.writeQuestCoolDownData(msg,data)
	Proto.writeWORD(msg,data.infoID); -- 冷却组ID
	Proto.writeTIME_SEC(msg,data.coolDown); -- 冷却
	Proto.writeWORD(msg,data.count); -- 累计次数
	Proto.writeTIME_SEC(msg,data.countClearTime); -- 次数清空时间
end

function Proto.parseRaceClassQuestInfo(entry)
	local data={};
	data.id=Proto.parseWORD(entry); -- 任务ID
	data.raceClass=Proto.parseVector(entry,Proto.parseBYTE); -- 阶数
	return data;
end

function Proto.getRaceClassQuestInfoIDLen()
	return Proto.getWORDLen();
end

function Proto.writeRaceClassQuestInfo(msg,data)
	Proto.writeWORD(msg,data.id); -- 任务ID
	Proto.writeVector(msg,data.raceClass,Proto.writeBYTE); -- 阶数
end

function Proto.parseTimeLimit(entry)
	local data={};
	data.id=Proto.parseBYTE(entry); -- 时间段id
	data.beginHour=Proto.parseBYTE(entry); -- 开始小时数
	data.beginMin=Proto.parseBYTE(entry); -- 开始分钟数
	data.endHour=Proto.parseBYTE(entry); -- 结束小时数
	data.endMin=Proto.parseBYTE(entry); -- 结束分钟数
	return data;
end

function Proto.getTimeLimitIDLen()
	return Proto.getBYTELen();
end

function Proto.writeTimeLimit(msg,data)
	Proto.writeBYTE(msg,data.id); -- 时间段id
	Proto.writeBYTE(msg,data.beginHour); -- 开始小时数
	Proto.writeBYTE(msg,data.beginMin); -- 开始分钟数
	Proto.writeBYTE(msg,data.endHour); -- 结束小时数
	Proto.writeBYTE(msg,data.endMin); -- 结束分钟数
end

function Proto.parseConfraternityQuestInfo(entry)
	local data={};
	data.id=Proto.parseWORD(entry); -- 任务ID
	data.num=Proto.parseWORD(entry); -- 任务数量限制
	data.type=Proto.parseBYTE(entry); -- 任务类型
	data.level=Proto.parseBYTE(entry); -- 所需公会等级
	data.limits=Proto.parseVector(entry,Proto.parseTimeLimit); -- 时间限制
	return data;
end

function Proto.getConfraternityQuestInfoIDLen()
	return Proto.getWORDLen();
end

function Proto.writeConfraternityQuestInfo(msg,data)
	Proto.writeWORD(msg,data.id); -- 任务ID
	Proto.writeWORD(msg,data.num); -- 任务数量限制
	Proto.writeBYTE(msg,data.type); -- 任务类型
	Proto.writeBYTE(msg,data.level); -- 所需公会等级
	Proto.writeVector(msg,data.limits,Proto.writeTimeLimit); -- 时间限制
end

function Proto.parseSingleRaceQuestInfo(entry)
	local data={};
	data.id=Proto.parseWORD(entry); -- 任务ID
	data.petRaces=Proto.parseVector(entry,Proto.parseDWORD); -- 宠物集
	return data;
end

function Proto.getSingleRaceQuestInfoIDLen()
	return Proto.getWORDLen();
end

function Proto.writeSingleRaceQuestInfo(msg,data)
	Proto.writeWORD(msg,data.id); -- 任务ID
	Proto.writeVector(msg,data.petRaces,Proto.writeDWORD); -- 宠物集
end

function Proto.parseGlobalRecordQuestInfo(entry)
	local data={};
	data.id=Proto.parseWORD(entry); -- 任务ID
	data.code=Proto.parseString(entry); -- 记录编码
	data.script=Proto.parseString(entry); -- 记录脚本
	return data;
end

function Proto.getGlobalRecordQuestInfoIDLen()
	return Proto.getWORDLen();
end

function Proto.writeGlobalRecordQuestInfo(msg,data)
	Proto.writeWORD(msg,data.id); -- 任务ID
	Proto.writeString(msg,data.code); -- 记录编码
	Proto.writeString(msg,data.script); -- 记录脚本
end

