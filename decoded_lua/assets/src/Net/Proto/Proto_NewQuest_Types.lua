-- Net.Proto.Proto_NewQuest_Types

Proto.QUEST_TAGET_TYPE_KILL					= 0													-- [任务类型详细信息]打怪
Proto.QUEST_TAGET_TYPE_GANITEM				= Proto.QUEST_TAGET_TYPE_KILL + 1					-- [任务类型详细信息]收集道具
Proto.QUEST_TAGET_TYPE_CLIENT				= Proto.QUEST_TAGET_TYPE_GANITEM + 1				-- [任务类型详细信息]客户端控制
Proto.QUEST_TAGET_TYPE_FIN_NORMAL_ADV		= Proto.QUEST_TAGET_TYPE_CLIENT + 1					-- [任务类型详细信息]通关普通副本
Proto.QUEST_TAGET_TYPE_FIN_HARD_ADV			= Proto.QUEST_TAGET_TYPE_FIN_NORMAL_ADV + 1			-- [任务类型详细信息]通关困难副本
Proto.QUEST_TAGET_TYPE_FIN_HERO_ADV			= Proto.QUEST_TAGET_TYPE_FIN_HARD_ADV + 1			-- [任务类型详细信息]通关英雄副本
Proto.QUEST_TAGET_TYPE_FEED_PET				= Proto.QUEST_TAGET_TYPE_FIN_HERO_ADV + 1			-- [任务类型详细信息]喂养宠物经验
Proto.QUEST_TAGET_TYPE_GOLD_GACHA			= Proto.QUEST_TAGET_TYPE_FEED_PET + 1				-- [任务类型详细信息]金币抽奖
Proto.QUEST_TAGET_TYPE_CATCH_PET			= Proto.QUEST_TAGET_TYPE_GOLD_GACHA + 1				-- [任务类型详细信息]捕捉宠物
Proto.QUEST_TAGET_TYPE_ARENA				= Proto.QUEST_TAGET_TYPE_CATCH_PET + 1				-- [任务类型详细信息]竞技场挑战
Proto.QUEST_TAGET_TYPE_ACTION_VALUE_GIFT	= Proto.QUEST_TAGET_TYPE_ARENA + 1					-- [任务类型详细信息]赠送体力
Proto.QUEST_TAGET_TYPE_BUY_GOLD				= Proto.QUEST_TAGET_TYPE_ACTION_VALUE_GIFT + 1		-- [任务类型详细信息]购买金币
Proto.QUEST_TAGET_TYPE_PET_STAR_UP			= Proto.QUEST_TAGET_TYPE_BUY_GOLD + 1				-- [任务类型详细信息]宠物升星
Proto.QUEST_TAGET_TYPE_PET_STAGE_UP			= Proto.QUEST_TAGET_TYPE_PET_STAR_UP + 1			-- [任务类型详细信息]宠物强化
Proto.QUEST_TAGET_TYPE_PET_STRENG			= Proto.QUEST_TAGET_TYPE_PET_STAGE_UP + 1			-- [任务类型详细信息]宠物训练
Proto.QUEST_TAGET_TYPE_PET_EVO				= Proto.QUEST_TAGET_TYPE_PET_STRENG + 1				-- [任务类型详细信息]宠物进化
Proto.QUEST_TAGET_TYPE_WORLD_BOSS			= Proto.QUEST_TAGET_TYPE_PET_EVO + 1				-- [任务类型详细信息]世界boss活动
Proto.QUEST_TAGET_TYPE_BUY_ACTION_VALUE		= Proto.QUEST_TAGET_TYPE_WORLD_BOSS + 1				-- [任务类型详细信息]购买体力
Proto.QUEST_TAGET_TYPE_FINISH_MAP_POINT		= Proto.QUEST_TAGET_TYPE_BUY_ACTION_VALUE + 1		-- [任务类型详细信息]通关节点
Proto.QUEST_TAGET_TYPE_FINISH_ADV			= Proto.QUEST_TAGET_TYPE_FINISH_MAP_POINT + 1		-- [任务类型详细信息]通关副本
Proto.QUEST_TAGET_TYPE_CHARACTER_LEV		= Proto.QUEST_TAGET_TYPE_FINISH_ADV + 1				-- [任务类型详细信息]人物等级
Proto.QUEST_TAGET_TYPE_KILL_PETS			= Proto.QUEST_TAGET_TYPE_CHARACTER_LEV + 1			-- [任务类型详细信息]击败宠物
Proto.QUEST_TAGET_TYPE_KILL_PET				= Proto.QUEST_TAGET_TYPE_KILL_PETS + 1				-- [任务类型详细信息]击败指定宠物
Proto.QUEST_TAGET_TYPE_MONTH_CARD			= Proto.QUEST_TAGET_TYPE_KILL_PET + 1				-- [任务类型详细信息]领取月卡
Proto.QUEST_TAGET_TYPE_YEAR_CARD			= Proto.QUEST_TAGET_TYPE_MONTH_CARD + 1				-- [任务类型详细信息]领取年卡
Proto.QUEST_TAGET_TYPE_LIFE_CARD			= Proto.QUEST_TAGET_TYPE_YEAR_CARD + 1				-- [任务类型详细信息]领取终身卡
Proto.QUEST_TAGET_TYPE_LOSTTOWER			= Proto.QUEST_TAGET_TYPE_LIFE_CARD + 1				-- [任务类型详细信息]挑战千层塔
Proto.QUEST_TAGET_TYPE_TERRITORY			= Proto.QUEST_TAGET_TYPE_LOSTTOWER + 1				-- [任务类型详细信息]领主争夺
Proto.QUEST_TAGET_TYPE_PET_SKILL			= Proto.QUEST_TAGET_TYPE_TERRITORY + 1				-- [任务类型详细信息]技能合成
Proto.QUEST_TAGET_TYPE_APPOINT_PET_STRENG	= Proto.QUEST_TAGET_TYPE_PET_SKILL + 1				-- [任务类型详细信息]指定宠物强化
Proto.QUEST_TAGET_TYPE_APPOINT_PET_LEVEL_UP	= Proto.QUEST_TAGET_TYPE_APPOINT_PET_STRENG + 1		-- [任务类型详细信息]指定宠物升级
Proto.QUEST_TAGET_TYPE_ANY_PET_LEVEL_UP		= Proto.QUEST_TAGET_TYPE_APPOINT_PET_LEVEL_UP + 1	-- [任务类型详细信息]任意宠物升级
Proto.QUEST_TAGET_TYPE_APPOINT_PET_STAR_UP	= Proto.QUEST_TAGET_TYPE_ANY_PET_LEVEL_UP + 1		-- [任务类型详细信息]指定宠物升星
Proto.QUEST_TAGET_TYPE_APPOINT_PET_EVO		= Proto.QUEST_TAGET_TYPE_APPOINT_PET_STAR_UP + 1	-- [任务类型详细信息]指定宠物进化
Proto.QUEST_TAGET_TYPE_EXPLORE				= Proto.QUEST_TAGET_TYPE_APPOINT_PET_EVO + 1		-- [任务类型详细信息]探索
Proto.QUEST_TAGET_TYPE_COLLECT_PET			= Proto.QUEST_TAGET_TYPE_EXPLORE + 1				-- [任务类型详细信息]收集宠物
Proto.QUEST_TAGET_TYPE_REDHEART				= Proto.QUEST_TAGET_TYPE_COLLECT_PET + 1			-- [任务类型详细信息]点赞
Proto.QUEST_TAGET_TYPE_FIRSTPET_STRENG		= Proto.QUEST_TAGET_TYPE_REDHEART + 1				-- [任务类型详细信息]特殊需求宠物强化
Proto.QUEST_TAGET_TYPE_FIRSTPET_LEVEL_UP	= Proto.QUEST_TAGET_TYPE_FIRSTPET_STRENG + 1		-- [任务类型详细信息]特殊需求宠物升级
Proto.QUEST_TAGET_TYPE_LIFE_SKILL			= Proto.QUEST_TAGET_TYPE_FIRSTPET_LEVEL_UP + 1		-- [任务类型详细信息]生活制作
Proto.QUEST_TAGET_TYPE_USE_ITEM				= Proto.QUEST_TAGET_TYPE_LIFE_SKILL + 1				-- [任务类型详细信息]使用道具
Proto.QUEST_TAGET_TYPE_ADV_STAR				= Proto.QUEST_TAGET_TYPE_USE_ITEM + 1				-- [任务类型详细信息]关卡星数
Proto.QUEST_TAGET_TYPE_ADV_TEAM				= Proto.QUEST_TAGET_TYPE_ADV_STAR + 1				-- [任务类型详细信息]组队副本
Proto.QUEST_TAGET_TYPE_ADV_COMMENT			= Proto.QUEST_TAGET_TYPE_ADV_TEAM + 1				-- [任务类型详细信息]苹果评论
Proto.QUEST_TAGET_SCIENCE_CONSUME			= Proto.QUEST_TAGET_TYPE_ADV_COMMENT + 1			-- [任务类型详细信息]交任意科技材料
Proto.QUEST_RESET_TYPE_NEVER	= 0									-- [任务重置类型]永远不重置
Proto.QUEST_RESET_TYPE_DAY		= Proto.QUEST_RESET_TYPE_NEVER + 1	-- [任务重置类型]按天重置
Proto.QUEST_RESET_TYPE_WEEK		= Proto.QUEST_RESET_TYPE_DAY + 1	-- [任务重置类型]按周重置
Proto.QUEST_STATUS_NORMAL		= 0									-- [任务状态]任务进行中
Proto.QUEST_STATUS_DONE			= Proto.QUEST_STATUS_NORMAL + 1		-- [任务状态]任务已完成(已领奖励)
Proto.QUEST_STATUS_STANDBY		= Proto.QUEST_STATUS_DONE + 1		-- [任务状态]任务等待中
Proto.QUEST_STATUS_GROUP_DONE	= Proto.QUEST_STATUS_STANDBY + 1	-- [任务状态]任务已完成(已领奖励)(包括每日任务的奖励组)
Proto.QUEST_TYPE_MAIN		= 0							-- [任务类型]主线任务
Proto.QUEST_TYPE_SUB		= Proto.QUEST_TYPE_MAIN + 1	-- [任务类型]支线任务
Proto.QUEST_TYPE_EVERYDAY	= Proto.QUEST_TYPE_SUB + 1	-- [任务类型]每日任务

function Proto.parseNewQuestInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 任务ID
	data.name=Proto.parseString(entry); -- 任务名字
	data.type=Proto.parseBYTE(entry); -- 任务类型
	data.parentID=Proto.parseDWORD(entry); -- 上一级任务ID
	data.childIDs=Proto.parseVector(entry,Proto.parseDWORD); -- 下一级任务ID
	data.startTime=Proto.parseString(entry); -- 开始时间
	data.endTime=Proto.parseString(entry); -- 结束时间
	data.resetType=Proto.parseBYTE(entry); -- 重置类型
	data.resetPeriod=Proto.parseWORD(entry); -- 重置周期
	data.awardID=Proto.parseDWORD(entry); -- 奖励ID
	data.icon=Proto.parseString(entry); -- 图标
	data.desc=Proto.parseString(entry); -- 描述
	data.objectiveDesc=Proto.parseString(entry); -- 目标描述
	data.objectiveList=Proto.parseVector(entry,Proto.parseObjectiveInfo); -- 任务目标列表
	data.strongType=Proto.parseString(entry); -- 强制类型
	data.buttonName=Proto.parseString(entry); -- 按钮名称
	data.targetMapName=Proto.parseString(entry); -- 目标地图名称
	data.mcash=Proto.parseDWORD(entry); -- 目标地图名称
	data.dailyQuestPower=Proto.parseDWORD(entry); -- 活跃度
	data.awardIcon=Proto.parseString(entry); -- 奖励图标
	data.unlockMapID=Proto.parseString(entry); -- 解锁地图id
	data.needVisable=Proto.parseDWORD(entry); -- 显示
	data.firstPokemonID=Proto.parseDWORD(entry); -- 需要初始宠物id
	return data;
end

function Proto.getNewQuestInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeNewQuestInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 任务ID
	Proto.writeString(msg,data.name); -- 任务名字
	Proto.writeBYTE(msg,data.type); -- 任务类型
	Proto.writeDWORD(msg,data.parentID); -- 上一级任务ID
	Proto.writeVector(msg,data.childIDs,Proto.writeDWORD); -- 下一级任务ID
	Proto.writeString(msg,data.startTime); -- 开始时间
	Proto.writeString(msg,data.endTime); -- 结束时间
	Proto.writeBYTE(msg,data.resetType); -- 重置类型
	Proto.writeWORD(msg,data.resetPeriod); -- 重置周期
	Proto.writeDWORD(msg,data.awardID); -- 奖励ID
	Proto.writeString(msg,data.icon); -- 图标
	Proto.writeString(msg,data.desc); -- 描述
	Proto.writeString(msg,data.objectiveDesc); -- 目标描述
	Proto.writeVector(msg,data.objectiveList,Proto.writeObjectiveInfo); -- 任务目标列表
	Proto.writeString(msg,data.strongType); -- 强制类型
	Proto.writeString(msg,data.buttonName); -- 按钮名称
	Proto.writeString(msg,data.targetMapName); -- 目标地图名称
	Proto.writeDWORD(msg,data.mcash); -- 目标地图名称
	Proto.writeDWORD(msg,data.dailyQuestPower); -- 活跃度
	Proto.writeString(msg,data.awardIcon); -- 奖励图标
	Proto.writeString(msg,data.unlockMapID); -- 解锁地图id
	Proto.writeDWORD(msg,data.needVisable); -- 显示
	Proto.writeDWORD(msg,data.firstPokemonID); -- 需要初始宠物id
end

function Proto.parseQuestData(entry)
	local data={};
	data.questID=Proto.parseDWORD(entry); -- 任务ID
	data.status=Proto.parseBYTE(entry); -- 任务状态
	data.updateTime=Proto.parseQWORD(entry); -- 任务更新时间
	data.progressList=Proto.parseVector(entry,Proto.parseDWORD); -- 任务目标进度
	return data;
end

function Proto.writeQuestData(msg,data)
	Proto.writeDWORD(msg,data.questID); -- 任务ID
	Proto.writeBYTE(msg,data.status); -- 任务状态
	Proto.writeQWORD(msg,data.updateTime); -- 任务更新时间
	Proto.writeVector(msg,data.progressList,Proto.writeDWORD); -- 任务目标进度
end

function Proto.parseQuestDetail(entry)
	local data={};
	data.questID=Proto.parseDWORD(entry); -- 任务ID
	data.status=Proto.parseBYTE(entry); -- 任务状态
	data.updateTime=Proto.parseQWORD(entry); -- 任务更新时间
	data.progressList=Proto.parseVector(entry,Proto.parseDWORD); -- 任务目标进度
	data.awardsList=Proto.parseVector(entry,Proto.parseDWORD); -- 任务奖励列表
	return data;
end

function Proto.writeQuestDetail(msg,data)
	Proto.writeDWORD(msg,data.questID); -- 任务ID
	Proto.writeBYTE(msg,data.status); -- 任务状态
	Proto.writeQWORD(msg,data.updateTime); -- 任务更新时间
	Proto.writeVector(msg,data.progressList,Proto.writeDWORD); -- 任务目标进度
	Proto.writeVector(msg,data.awardsList,Proto.writeDWORD); -- 任务奖励列表
end

