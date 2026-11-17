-- Net.Proto.Proto_Log_Types

Proto.LCT_USE_ITEM						= 0												-- [日志上下文类型]使用道具
Proto.LCT_SELL_ITEM						= Proto.LCT_USE_ITEM + 1						-- [日志上下文类型]卖出道具
Proto.LCT_DISCARD_ITEM					= Proto.LCT_SELL_ITEM + 1						-- [日志上下文类型]丢弃道具
Proto.LCT_SYNTHESIZE_ITEM				= Proto.LCT_DISCARD_ITEM + 1					-- [日志上下文类型]合成道具
Proto.LCT_RECEIVE_MAIL					= Proto.LCT_SYNTHESIZE_ITEM + 1					-- [日志上下文类型]接收邮件
Proto.LCT_BUY_COMMODITY					= Proto.LCT_RECEIVE_MAIL + 1					-- [日志上下文类型]购买商品
Proto.LCT_CHALLENGE_STAGE				= Proto.LCT_BUY_COMMODITY + 1					-- [日志上下文类型]挑战关卡
Proto.LCT_SIGNIN						= Proto.LCT_CHALLENGE_STAGE + 1					-- [日志上下文类型]每日签到
Proto.LCT_VIP_SIGNIN					= Proto.LCT_SIGNIN + 1							-- [日志上下文类型]VIP签到
Proto.LCT_ACTIVE_DRAWING				= Proto.LCT_VIP_SIGNIN + 1						-- [日志上下文类型]活跃度抽奖
Proto.LCT_RESET_HATCH					= Proto.LCT_ACTIVE_DRAWING + 1					-- [日志上下文类型]宠物移至孵化栏
Proto.LCT_FINISH_ACHIEVEMENT			= Proto.LCT_RESET_HATCH + 1						-- [日志上下文类型]完成成就
Proto.LCT_USE_TICKET					= Proto.LCT_FINISH_ACHIEVEMENT + 1				-- [日志上下文类型]使用积分券
Proto.LCT_ARENA_AWARD					= Proto.LCT_USE_TICKET + 1						-- [日志上下文类型]竞技场奖励
Proto.LCT_CHALLENGE_BOSS_REBORN			= Proto.LCT_ARENA_AWARD + 1						-- [日志上下文类型]boss战时间清空
Proto.LCT_GA_CHA						= Proto.LCT_CHALLENGE_BOSS_REBORN + 1			-- [日志上下文类型]扭蛋
Proto.LCT_HATCH_PET						= Proto.LCT_GA_CHA + 1							-- [日志上下文类型]孵蛋
Proto.LCT_CLEAR_HATCH					= Proto.LCT_HATCH_PET + 1						-- [日志上下文类型]清空孵化
Proto.LCT_TAKE_HATCH					= Proto.LCT_CLEAR_HATCH + 1						-- [日志上下文类型]领取孵化
Proto.LCT_INTENSIFY_EQUIP				= Proto.LCT_TAKE_HATCH + 1						-- [日志上下文类型]装备强化
Proto.LCT_EQUIP_MERGE					= Proto.LCT_INTENSIFY_EQUIP + 1					-- [日志上下文类型]装备融合
Proto.LCT_EQUIP_RESET					= Proto.LCT_EQUIP_MERGE + 1						-- [日志上下文类型]装备洗练
Proto.LCT_SKILL_LEARN					= Proto.LCT_EQUIP_RESET + 1						-- [日志上下文类型]技能学习
Proto.LCT_EQUIPMENT_WEAR				= Proto.LCT_SKILL_LEARN + 1						-- [日志上下文类型]装备穿戴
Proto.LCT_PACKET_EXTEND					= Proto.LCT_EQUIPMENT_WEAR + 1					-- [日志上下文类型]背包扩展
Proto.LCT_PET_CULL						= Proto.LCT_PACKET_EXTEND + 1					-- [日志上下文类型]新手宠物
Proto.LCT_SKILL_UP						= Proto.LCT_PET_CULL + 1						-- [日志上下文类型]技能升级
Proto.LCT_SUBSTITUE_PET					= Proto.LCT_SKILL_UP + 1						-- [日志上下文类型]拖油瓶
Proto.LCT_EGG_EAT						= Proto.LCT_SUBSTITUE_PET + 1					-- [日志上下文类型]吃蛋
Proto.LCT_GROUND_TRAINING				= Proto.LCT_EGG_EAT + 1							-- [日志上下文类型]训练场
Proto.LCT_PET_EVOLUTION					= Proto.LCT_GROUND_TRAINING + 1					-- [日志上下文类型]宠物进化
Proto.LCT_ARENA_SYSTEM_MAIL				= Proto.LCT_PET_EVOLUTION + 1					-- [日志上下文类型]竞技场系统邮件
Proto.LCT_BOSSBATTLE_SYSTEM_MAIL		= Proto.LCT_ARENA_SYSTEM_MAIL + 1				-- [日志上下文类型]boss战系统邮件
Proto.LCT_TRAINING_SYSTEM_MAIL			= Proto.LCT_BOSSBATTLE_SYSTEM_MAIL + 1			-- [日志上下文类型]训练场系统邮件
Proto.LCT_GM_SYSTEM_MAIL				= Proto.LCT_TRAINING_SYSTEM_MAIL + 1			-- [日志上下文类型]GM系统邮件
Proto.LCT_EXCHANGEREWARD_SYSTEM_MAIL	= Proto.LCT_GM_SYSTEM_MAIL + 1					-- [日志上下文类型]兑换奖励邮件
Proto.LCT_RESET_PET						= Proto.LCT_EXCHANGEREWARD_SYSTEM_MAIL + 1		-- [日志上下文类型]重置宠物个体
Proto.LCT_PET_EAT						= Proto.LCT_RESET_PET + 1						-- [日志上下文类型]宠物融合
Proto.LCT_PET_BREED						= Proto.LCT_PET_EAT + 1							-- [日志上下文类型]宠物潜力点培育
Proto.LCT_PET_CLEAR						= Proto.LCT_PET_BREED + 1						-- [日志上下文类型]宠物潜力点重置
Proto.LCT_SINGLE_STAGE_BATTLE			= Proto.LCT_PET_CLEAR + 1						-- [日志上下文类型]宠物闯关
Proto.LCT_REMOVE_AUCTION_ITEM			= Proto.LCT_SINGLE_STAGE_BATTLE + 1				-- [日志上下文类型]移除拍卖物品
Proto.LCT_PAY_AUCTION					= Proto.LCT_REMOVE_AUCTION_ITEM + 1				-- [日志上下文类型]获得拍卖物品
Proto.LCT_BUYITEM_AUCTION				= Proto.LCT_PAY_AUCTION + 1						-- [日志上下文类型]拍卖行买物品
Proto.LCT_UNION_CREATE					= Proto.LCT_BUYITEM_AUCTION + 1					-- [日志上下文类型]创建工会
Proto.LCT_RECHARGE						= Proto.LCT_UNION_CREATE + 1					-- [日志上下文类型]充值
Proto.LCT_AUCTION_EXCEED				= Proto.LCT_RECHARGE + 1						-- [日志上下文类型]拍卖行物品过期邮件
Proto.LCT_HEROSTAGE_RESET				= Proto.LCT_AUCTION_EXCEED + 1					-- [日志上下文类型]重置英雄关卡
Proto.LCT_SINGLEBOSS_REWARD				= Proto.LCT_HEROSTAGE_RESET + 1					-- [日志上下文类型]boss战单次奖励
Proto.LCT_MCASH_DRAWING					= Proto.LCT_SINGLEBOSS_REWARD + 1				-- [日志上下文类型]M币抽奖
Proto.LCT_MCASH_ACTIVITY				= Proto.LCT_MCASH_DRAWING + 1					-- [日志上下文类型]活动送M币
Proto.LCT_BUY_PET_EXP					= Proto.LCT_MCASH_ACTIVITY + 1					-- [日志上下文类型]购买宠物经验
Proto.LCT_BUY_UNION_ITEM				= Proto.LCT_BUY_PET_EXP + 1						-- [日志上下文类型]购买工会道具
Proto.LCT_UNION_SAC						= Proto.LCT_BUY_UNION_ITEM + 1					-- [日志上下文类型]工会献祭
Proto.LCT_CONFRATERNITY_DRAWING			= Proto.LCT_UNION_SAC + 1						-- [日志上下文类型]工会抽奖
Proto.LCT_FIGHTACTIVITY					= Proto.LCT_CONFRATERNITY_DRAWING + 1			-- [日志上下文类型]万人斩活动
Proto.LCT_SYN_GENECOVER					= Proto.LCT_FIGHTACTIVITY + 1					-- [日志上下文类型]技能书合成
Proto.LCT_GM_CHARGE_MCASH				= Proto.LCT_SYN_GENECOVER + 1					-- [日志上下文类型]GM充值
Proto.LCT_EXTEND_PET_DEPOTS_COUNT		= Proto.LCT_GM_CHARGE_MCASH + 1					-- [日志上下文类型]扩展宠物仓库上限
Proto.LCT_ARENA_BATTLE					= Proto.LCT_EXTEND_PET_DEPOTS_COUNT + 1			-- [日志上下文类型]竞技场扣费
Proto.LCT_DAILYTASK_AWARD				= Proto.LCT_ARENA_BATTLE + 1					-- [日志上下文类型]每日任务收益
Proto.LCT_MONOPOLY_AWARD				= Proto.LCT_DAILYTASK_AWARD + 1					-- [日志上下文类型]暴走收益
Proto.LCT_MONEY_TREE					= Proto.LCT_MONOPOLY_AWARD + 1					-- [日志上下文类型]摇钱树
Proto.LCT_SEND_ARENA_CHARM				= Proto.LCT_MONEY_TREE + 1						-- [日志上下文类型]竞技场赠送魅力
Proto.LCT_PET_RACE_ARENA_BATTLE			= Proto.LCT_SEND_ARENA_CHARM + 1				-- [日志上下文类型]宠物单挑竞技场扣费
Proto.LCT_PET_AIDE_NATURE_LEVELUP		= Proto.LCT_PET_RACE_ARENA_BATTLE + 1			-- [日志上下文类型]伴灵技能强化
Proto.LCT_PET_AIDE_EVOLUTION			= Proto.LCT_PET_AIDE_NATURE_LEVELUP + 1			-- [日志上下文类型]伴灵技能进化
Proto.LCT_PET_AIDE_RESET_FEED_PROGRESS	= Proto.LCT_PET_AIDE_EVOLUTION + 1				-- [日志上下文类型]伴灵清空饱食度
Proto.LCT_PET_AIDE_FEED					= Proto.LCT_PET_AIDE_RESET_FEED_PROGRESS + 1	-- [日志上下文类型]伴灵喂养
Proto.LCT_EQUIP_GENE					= Proto.LCT_PET_AIDE_FEED + 1					-- [日志上下文类型]装备技能
Proto.LCT_CROSSWORLD_SYSTEM_MAIL		= Proto.LCT_EQUIP_GENE + 1						-- [日志上下文类型]跨服赛系统邮件
Proto.LCT_CROSSWORLD_AWARD				= Proto.LCT_CROSSWORLD_SYSTEM_MAIL + 1			-- [日志上下文类型]跨服赛膜拜奖励
Proto.LCT_DIFFINDUSTRY_AWARD			= Proto.LCT_CROSSWORLD_AWARD + 1				-- [日志上下文类型]异业合作券
Proto.LCT_WEB_ACTIVITY					= Proto.LCT_DIFFINDUSTRY_AWARD + 1				-- [日志上下文类型]网页活动
Proto.LCT_CHANGE_PET_ASSIGNPOINTS		= Proto.LCT_WEB_ACTIVITY + 1					-- [日志上下文类型]修改宠物分配点
Proto.LCT_GM_MAIL						= Proto.LCT_CHANGE_PET_ASSIGNPOINTS + 1			-- [日志上下文类型]gm工具发送邮件
Proto.LCT_GALLANTS_SYSTEM_MAIL			= Proto.LCT_GM_MAIL + 1							-- [日志上下文类型]擂台赛系统邮件
Proto.LCT_PET_REDUCE_STRUGGLES			= Proto.LCT_GALLANTS_SYSTEM_MAIL + 1			-- [日志上下文类型]减少宠物努力值
Proto.LCT_GA_CHA_BURST					= Proto.LCT_PET_REDUCE_STRUGGLES + 1			-- [日志上下文类型]扭蛋爆发
Proto.LCT_IMMOLATE_PET					= Proto.LCT_GA_CHA_BURST + 1					-- [日志上下文类型]宠物献祭
Proto.LCT_PET_INJECT_SOUL				= Proto.LCT_IMMOLATE_PET + 1					-- [日志上下文类型]宠物注入灵魂
Proto.LCT_EXPAND_SOUL_POOL				= Proto.LCT_PET_INJECT_SOUL + 1					-- [日志上下文类型]扩充魂池
Proto.LCT_PET_TURN						= Proto.LCT_EXPAND_SOUL_POOL + 1				-- [日志上下文类型]宠物转生
Proto.LCT_CROSSWORLD_GAMBLE				= Proto.LCT_PET_TURN + 1						-- [日志上下文类型]跨服战下注
Proto.LCT_CHALLENGE_BOSS_PAYMEDICINE	= Proto.LCT_CROSSWORLD_GAMBLE + 1				-- [日志上下文类型]boss战付费药水
Proto.LCT_SEND_GIFT						= Proto.LCT_CHALLENGE_BOSS_PAYMEDICINE + 1		-- [日志上下文类型]商场赠送
Proto.LCT_PET_REFRESH_SIXD_POINTS		= Proto.LCT_SEND_GIFT + 1						-- [日志上下文类型]宠物刷新六维
Proto.LCT_RECHARGE_CONSUME_POINTS		= Proto.LCT_PET_REFRESH_SIXD_POINTS + 1			-- [日志上下文类型]充值消费积分变化
Proto.LCT_FETCH_SIGN_DAILY_REWARD		= Proto.LCT_RECHARGE_CONSUME_POINTS + 1			-- [日志上下文类型]领取每日签到奖励
Proto.LCT_RECHARGE_CONSUME_AWARD		= Proto.LCT_FETCH_SIGN_DAILY_REWARD + 1			-- [日志上下文类型]充值消费积分奖励
Proto.LCT_GET_DIG_AWARD					= Proto.LCT_RECHARGE_CONSUME_AWARD + 1			-- [日志上下文类型]挖宝奖励
Proto.LCT_GET_WEALTH_GOD_AWARD			= Proto.LCT_GET_DIG_AWARD + 1					-- [日志上下文类型]操神驾到奖励
Proto.LCT_BUY_MONTH_CARD				= Proto.LCT_GET_WEALTH_GOD_AWARD + 1			-- [日志上下文类型]购买月卡
Proto.LCT_TAKE_MONTH_CARD				= Proto.LCT_BUY_MONTH_CARD + 1					-- [日志上下文类型]领取月卡
Proto.LCT_BUY_ADVENTURE_RESET_TIMES		= Proto.LCT_TAKE_MONTH_CARD + 1					-- [日志上下文类型]副本购买重置次数
Proto.LCT_BUY_ADVENTURE_REBORN_TIMES	= Proto.LCT_BUY_ADVENTURE_RESET_TIMES + 1		-- [日志上下文类型]副本购买复活次数
Proto.LCT_GET_STAR_SOUL_REWARD			= Proto.LCT_BUY_ADVENTURE_REBORN_TIMES + 1		-- [日志上下文类型]领取星魂殿奖励
Proto.LCT_ADVENTURE_REWARD				= Proto.LCT_GET_STAR_SOUL_REWARD + 1			-- [日志上下文类型]副本奖励
Proto.LCT_COUNT							= Proto.LCT_ADVENTURE_REWARD + 1				-- [日志上下文类型]类型总数
Proto.LT_ITEM_CHANGE					= 0											-- [日志类型]道具变化
Proto.LT_MONEY_CHANGE					= Proto.LT_ITEM_CHANGE + 1					-- [日志类型]金钱变化
Proto.LT_CHAR_EXP_CHANGE				= Proto.LT_MONEY_CHANGE + 1					-- [日志类型]玩家经验变化
Proto.LT_PET_EXP_CHANGE					= Proto.LT_CHAR_EXP_CHANGE + 1				-- [日志类型]宠物经验变化
Proto.LT_CHAR_MAIL_CHANGE				= Proto.LT_PET_EXP_CHANGE + 1				-- [日志类型]人物邮件变化
Proto.LT_PET_POT_CHANGE					= Proto.LT_CHAR_MAIL_CHANGE + 1				-- [日志类型]宠物潜力点变化
Proto.LT_PET_ATT_CHANGE					= Proto.LT_PET_POT_CHANGE + 1				-- [日志类型]宠物属性变化
Proto.LT_PET_NATPOT_CHANGE				= Proto.LT_PET_ATT_CHANGE + 1				-- [日志类型]宠物初始潜力点变化
Proto.LT_SYSTEM_MAIL_CHANGE				= Proto.LT_PET_NATPOT_CHANGE + 1			-- [日志类型]系统邮件(替代原来的人物邮件)
Proto.LT_EQUIP_GENE_CHANGE				= Proto.LT_SYSTEM_MAIL_CHANGE + 1			-- [日志类型]装备技能信息变化
Proto.LT_EQUIP_PUMP_SOUL				= Proto.LT_EQUIP_GENE_CHANGE + 1			-- [日志类型]装备技能抽魂变异信息
Proto.LT_PET_ASSIGN_POINT_CHANGE		= Proto.LT_EQUIP_PUMP_SOUL + 1				-- [日志类型]宠物分配点变化
Proto.LT_GM_SEND_MAIL					= Proto.LT_PET_ASSIGN_POINT_CHANGE + 1		-- [日志类型]admintool发送邮件
Proto.LT_PET_REDUCE_STRUGGLES			= Proto.LT_GM_SEND_MAIL + 1					-- [日志类型]宠物减少努力值
Proto.LT_IMMOLATE_PET					= Proto.LT_PET_REDUCE_STRUGGLES + 1			-- [日志类型]宠物献祭
Proto.LT_PET_CHANGE_AFFIX_SIXD_POINTS	= Proto.LT_IMMOLATE_PET + 1					-- [日志类型]宠物修改附加六维
Proto.LT_RECHARGE_CONSUME_POINTS		= Proto.LT_PET_CHANGE_AFFIX_SIXD_POINTS + 1	-- [日志类型]充值消费积分变化
Proto.LT_COUNT							= Proto.LT_RECHARGE_CONSUME_POINTS + 1		-- [日志类型]类型总数

function Proto.parseLogContextData_BODY_UseItem(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.type_id=Proto.parseDWORD(entry); -- 道具ID
	return data;
end

function Proto.writeLogContextData_BODY_UseItem(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writeDWORD(msg,data.type_id); -- 道具ID
end

function Proto.parseLogContextData_BODY_SellItem(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.type_id=Proto.parseDWORD(entry); -- 道具ID
	data.count=Proto.parseWORD(entry); -- 数量
	return data;
end

function Proto.writeLogContextData_BODY_SellItem(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writeDWORD(msg,data.type_id); -- 道具ID
	Proto.writeWORD(msg,data.count); -- 数量
end

function Proto.parseLogContextData_BODY_DisCardItem(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.type_id=Proto.parseDWORD(entry); -- 道具ID
	data.count=Proto.parseWORD(entry); -- 数量
	return data;
end

function Proto.writeLogContextData_BODY_DisCardItem(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writeDWORD(msg,data.type_id); -- 道具ID
	Proto.writeWORD(msg,data.count); -- 数量
end

function Proto.parseLogContextData_BODY_SynthesizeItem(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.synthesizeID=Proto.parseQWORD(entry); -- 道具合成ID
	return data;
end

function Proto.writeLogContextData_BODY_SynthesizeItem(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writeQWORD(msg,data.synthesizeID); -- 道具合成ID
end

function Proto.parseLogContextData_BODY_ReceiveMail(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.mailID=Proto.parseQWORD(entry); -- 邮件ID
	return data;
end

function Proto.writeLogContextData_BODY_ReceiveMail(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writeQWORD(msg,data.mailID); -- 邮件ID
end

function Proto.parseLogContextData_BODY_BuyCommodity(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.commodityID=Proto.parseDWORD(entry); -- 商品ID
	data.count=Proto.parseDWORD(entry); -- 商品数量
	return data;
end

function Proto.writeLogContextData_BODY_BuyCommodity(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writeDWORD(msg,data.commodityID); -- 商品ID
	Proto.writeDWORD(msg,data.count); -- 商品数量
end

function Proto.parseLogContextData_BODY_ChallengeStage(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.stage=Proto.parseDWORD(entry); -- 关卡
	data.checkPoint=Proto.parseBYTE(entry); -- 挑战点
	return data;
end

function Proto.writeLogContextData_BODY_ChallengeStage(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writeDWORD(msg,data.stage); -- 关卡
	Proto.writeBYTE(msg,data.checkPoint); -- 挑战点
end

function Proto.parseLogContextData_BODY_SignIn(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	return data;
end

function Proto.writeLogContextData_BODY_SignIn(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
end

function Proto.parseLogContextData_BODY_VipSignIn(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.level=Proto.parseWORD(entry); -- VIP等级
	return data;
end

function Proto.writeLogContextData_BODY_VipSignIn(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writeWORD(msg,data.level); -- VIP等级
end

function Proto.parseLogContextData_BODY_ActiveDrawing(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	return data;
end

function Proto.writeLogContextData_BODY_ActiveDrawing(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
end

function Proto.parseLogContextData_BODY_ResetHatch(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.fromPos=Proto.parseWORD(entry); -- 开始位置
	data.toPos=Proto.parseWORD(entry); -- 移至位置
	return data;
end

function Proto.writeLogContextData_BODY_ResetHatch(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writeWORD(msg,data.fromPos); -- 开始位置
	Proto.writeWORD(msg,data.toPos); -- 移至位置
end

function Proto.parseLogContextData_BODY_FinishAchievement(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.achievementID=Proto.parseWORD(entry); -- 成就ID
	data.achievementPoints=Proto.parseBYTE(entry); -- 成就点
	data.achievementSequence=Proto.parseDWORD(entry); -- 成就次序
	return data;
end

function Proto.writeLogContextData_BODY_FinishAchievement(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writeWORD(msg,data.achievementID); -- 成就ID
	Proto.writeBYTE(msg,data.achievementPoints); -- 成就点
	Proto.writeDWORD(msg,data.achievementSequence); -- 成就次序
end

function Proto.parseLogContextData_BODY_UseTicket(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.pointwarid=Proto.parseBYTE(entry); -- 积分战ID
	data.itemID=Proto.parseDWORD(entry); -- 挑战券类型
	data.itemCount=Proto.parseDWORD(entry); -- 挑战券数量
	return data;
end

function Proto.writeLogContextData_BODY_UseTicket(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writeBYTE(msg,data.pointwarid); -- 积分战ID
	Proto.writeDWORD(msg,data.itemID); -- 挑战券类型
	Proto.writeDWORD(msg,data.itemCount); -- 挑战券数量
end

function Proto.parseLogContextData_BODY_ArenaAward(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	return data;
end

function Proto.writeLogContextData_BODY_ArenaAward(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
end

function Proto.parseLogContextData_BODY_ChallengeBossReborn(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	return data;
end

function Proto.writeLogContextData_BODY_ChallengeBossReborn(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
end

function Proto.parseLogContextData_BODY_GaCha(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.gaChaID=Proto.parseDWORD(entry); -- 扭蛋ID
	return data;
end

function Proto.writeLogContextData_BODY_GaCha(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writeDWORD(msg,data.gaChaID); -- 扭蛋ID
end

function Proto.parseLogContextData_BODY_HatchPet(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.position=Proto.parseWORD(entry); -- 孵化位置
	return data;
end

function Proto.writeLogContextData_BODY_HatchPet(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writeWORD(msg,data.position); -- 孵化位置
end

function Proto.parseLogContextData_BODY_ClearHatch(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.position=Proto.parseWORD(entry); -- 孵化位置
	return data;
end

function Proto.writeLogContextData_BODY_ClearHatch(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writeWORD(msg,data.position); -- 孵化位置
end

function Proto.parseLogContextData_BODY_ClearPotential(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.petID=Proto.parsePetID(entry); -- 宠物ID
	return data;
end

function Proto.writeLogContextData_BODY_ClearPotential(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writePetID(msg,data.petID); -- 宠物ID
end

function Proto.parseLogContextData_BODY_BreedPotential(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.petID=Proto.parsePetID(entry); -- 宠物ID
	return data;
end

function Proto.writeLogContextData_BODY_BreedPotential(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writePetID(msg,data.petID); -- 宠物ID
end

function Proto.parseLogContextData_BODY_TakeHatch(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.position=Proto.parseWORD(entry); -- 孵化位置
	return data;
end

function Proto.writeLogContextData_BODY_TakeHatch(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writeWORD(msg,data.position); -- 孵化位置
end

function Proto.parseLogContextData_BODY_IntensifyEquip(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.itemPacketID=Proto.parseItemPacketID(entry); -- 行囊ID
	data.equipPos=Proto.parseWORD(entry); -- 装备位置
	data.moneyType=Proto.parseMoneyType(entry); -- 货币种类
	data.itemTypeID=Proto.parseDWORD(entry); -- 强化装备
	data.itemCount=Proto.parseWORD(entry); -- 强化道具数量
	return data;
end

function Proto.writeLogContextData_BODY_IntensifyEquip(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writeItemPacketID(msg,data.itemPacketID); -- 行囊ID
	Proto.writeWORD(msg,data.equipPos); -- 装备位置
	Proto.writeMoneyType(msg,data.moneyType); -- 货币种类
	Proto.writeDWORD(msg,data.itemTypeID); -- 强化装备
	Proto.writeWORD(msg,data.itemCount); -- 强化道具数量
end

function Proto.parseLogContextData_BODY_MergeEquip(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.itemPacketID=Proto.parseItemPacketID(entry); -- 行囊ID
	data.equipPos=Proto.parseWORD(entry); -- 装备位置
	data.mergePos=Proto.parseWORD(entry); -- 被融合装备位置
	data.moneyType=Proto.parseMoneyType(entry); -- 货币种类
	data.elementType=Proto.parseBYTE(entry); -- 抽取属性
	return data;
end

function Proto.writeLogContextData_BODY_MergeEquip(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writeItemPacketID(msg,data.itemPacketID); -- 行囊ID
	Proto.writeWORD(msg,data.equipPos); -- 装备位置
	Proto.writeWORD(msg,data.mergePos); -- 被融合装备位置
	Proto.writeMoneyType(msg,data.moneyType); -- 货币种类
	Proto.writeBYTE(msg,data.elementType); -- 抽取属性
end

function Proto.parseLogContextData_BODY_ResetEquip(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.itemPacketID=Proto.parseItemPacketID(entry); -- 行囊ID
	data.equipPos=Proto.parseWORD(entry); -- 装备位置
	data.moneyType=Proto.parseMoneyType(entry); -- 货币种类
	return data;
end

function Proto.writeLogContextData_BODY_ResetEquip(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writeItemPacketID(msg,data.itemPacketID); -- 行囊ID
	Proto.writeWORD(msg,data.equipPos); -- 装备位置
	Proto.writeMoneyType(msg,data.moneyType); -- 货币种类
end

function Proto.parseLogContextData_BODY_LearnSkill(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.petID=Proto.parseDWORD(entry); -- 宠物ID
	data.itemPos=Proto.parseWORD(entry); -- 装备位置
	data.genePos=Proto.parseWORD(entry); -- 基因位置
	return data;
end

function Proto.writeLogContextData_BODY_LearnSkill(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writeDWORD(msg,data.petID); -- 宠物ID
	Proto.writeWORD(msg,data.itemPos); -- 装备位置
	Proto.writeWORD(msg,data.genePos); -- 基因位置
end

function Proto.parseLogContextData_BODY_WearEquipment(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.part=Proto.parseWORD(entry); -- 身体部位
	data.version=Proto.parseDWORD(entry); -- 版本
	data.pos=Proto.parseWORD(entry); -- 装备位置
	return data;
end

function Proto.writeLogContextData_BODY_WearEquipment(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writeWORD(msg,data.part); -- 身体部位
	Proto.writeDWORD(msg,data.version); -- 版本
	Proto.writeWORD(msg,data.pos); -- 装备位置
end

function Proto.parseLogContextData_BODY_ExtendPacket(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	return data;
end

function Proto.writeLogContextData_BODY_ExtendPacket(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
end

function Proto.parseLogContextData_BODY_CullPet(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.generateID=Proto.parseDWORD(entry); -- 道具生成ID
	return data;
end

function Proto.writeLogContextData_BODY_CullPet(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writeDWORD(msg,data.generateID); -- 道具生成ID
end

function Proto.parseLogContextData_BODY_SkillUp(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.petID=Proto.parsePetID(entry); -- 宠物ID
	data.bag=Proto.parseItemPacketID(entry); -- 行囊ID
	data.allelePos=Proto.parseWORD(entry); -- 基因位置
	data.itemPos=Proto.parseWORD(entry); -- 道具位置
	return data;
end

function Proto.writeLogContextData_BODY_SkillUp(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writePetID(msg,data.petID); -- 宠物ID
	Proto.writeItemPacketID(msg,data.bag); -- 行囊ID
	Proto.writeWORD(msg,data.allelePos); -- 基因位置
	Proto.writeWORD(msg,data.itemPos); -- 道具位置
end

function Proto.parseLogContextData_BODY_SubstitutePet(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.substitutePos=Proto.parseBYTE(entry); -- 替补位置
	return data;
end

function Proto.writeLogContextData_BODY_SubstitutePet(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writeBYTE(msg,data.substitutePos); -- 替补位置
end

function Proto.parseLogContextData_BODY_EatEgg(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.petID=Proto.parsePetID(entry); -- 替补位置
	return data;
end

function Proto.writeLogContextData_BODY_EatEgg(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writePetID(msg,data.petID); -- 替补位置
end

function Proto.parseLogContextData_BODY_EatPet(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.petID=Proto.parsePetID(entry); -- 宠物ID
	data.eatPetID=Proto.parsePetID(entry); -- 被吃宠物ID
	return data;
end

function Proto.writeLogContextData_BODY_EatPet(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writePetID(msg,data.petID); -- 宠物ID
	Proto.writePetID(msg,data.eatPetID); -- 被吃宠物ID
end

function Proto.parseLogContextData_BODY_TrainingGround(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.ownerID=Proto.parseUserID(entry); -- 训练场所有者
	data.petID=Proto.parsePetID(entry); -- 宠物ID
	data.money=Proto.parseMoney(entry); -- 金钱
	return data;
end

function Proto.writeLogContextData_BODY_TrainingGround(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writeUserID(msg,data.ownerID); -- 训练场所有者
	Proto.writePetID(msg,data.petID); -- 宠物ID
	Proto.writeMoney(msg,data.money); -- 金钱
end

function Proto.parseLogContextData_BODY_PetEvolution(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.petID=Proto.parsePetID(entry); -- 宠物ID
	return data;
end

function Proto.writeLogContextData_BODY_PetEvolution(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writePetID(msg,data.petID); -- 宠物ID
end

function Proto.parseLogContextData_BODY_ArenaMail(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	return data;
end

function Proto.writeLogContextData_BODY_ArenaMail(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
end

function Proto.parseLogContextData_BODY_BossBattleMail(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	return data;
end

function Proto.writeLogContextData_BODY_BossBattleMail(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
end

function Proto.parseLogContextData_BODY_TrainingMail(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	return data;
end

function Proto.writeLogContextData_BODY_TrainingMail(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
end

function Proto.parseLogContextData_BODY_GMMail(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	return data;
end

function Proto.writeLogContextData_BODY_GMMail(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
end

function Proto.parseLogContextData_BODY_ExchangeRewardMail(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	return data;
end

function Proto.writeLogContextData_BODY_ExchangeRewardMail(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
end

function Proto.parseLogContextData_BODY_SingleStageBattle(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.petID=Proto.parsePetID(entry); -- 宠物ID
	return data;
end

function Proto.writeLogContextData_BODY_SingleStageBattle(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writePetID(msg,data.petID); -- 宠物ID
end

function Proto.parseLogContextData_BODY_RemoveAuctionItem(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.itemID=Proto.parseDWORD(entry); -- 道具ID
	data.itemCount=Proto.parseDWORD(entry); -- 道具数量
	return data;
end

function Proto.writeLogContextData_BODY_RemoveAuctionItem(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writeDWORD(msg,data.itemID); -- 道具ID
	Proto.writeDWORD(msg,data.itemCount); -- 道具数量
end

function Proto.parseLogContextData_BODY_PayAuction(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	return data;
end

function Proto.writeLogContextData_BODY_PayAuction(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
end

function Proto.parseLogContextData_BODY_BuyItemAuction(entry)
	local data={};
	data.buyerID=Proto.parseCharacterID(entry); -- 买家ID
	data.solderID=Proto.parseCharacterID(entry); -- 卖家ID
	data.itemType=Proto.parseDWORD(entry); -- 道具类型id
	return data;
end

function Proto.writeLogContextData_BODY_BuyItemAuction(msg,data)
	Proto.writeCharacterID(msg,data.buyerID); -- 买家ID
	Proto.writeCharacterID(msg,data.solderID); -- 卖家ID
	Proto.writeDWORD(msg,data.itemType); -- 道具类型id
end

function Proto.parseLogContextData_BODY_CreateUnion(entry)
	local data={};
	data.creater=Proto.parseCharacterID(entry); -- 创建者ID
	data.unionID=Proto.parseDWORD(entry); -- 工会ID
	return data;
end

function Proto.writeLogContextData_BODY_CreateUnion(msg,data)
	Proto.writeCharacterID(msg,data.creater); -- 创建者ID
	Proto.writeDWORD(msg,data.unionID); -- 工会ID
end

function Proto.parseLogContextData_BODY_Recharge(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.value=Proto.parseDWORD(entry); -- 充值数
	data.platformID=Proto.parseshort(entry); -- 平台ID
	data.orderID=Proto.parseZoic_StringForUnion_200_(entry); -- 订单ID
	return data;
end

function Proto.writeLogContextData_BODY_Recharge(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writeDWORD(msg,data.value); -- 充值数
	Proto.writeshort(msg,data.platformID); -- 平台ID
	Proto.writeZoic_StringForUnion_200_(msg,data.orderID); -- 订单ID
end

function Proto.parseLogContextData_BODY_AuctionExceed(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	return data;
end

function Proto.writeLogContextData_BODY_AuctionExceed(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
end

function Proto.parseLogContextData_BODY_ResetHeroStage(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.challengeID=Proto.parseDWORD(entry); -- 充值数
	return data;
end

function Proto.writeLogContextData_BODY_ResetHeroStage(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writeDWORD(msg,data.challengeID); -- 充值数
end

function Proto.parseLogContextData_BODY_SingleBossReward(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	return data;
end

function Proto.writeLogContextData_BODY_SingleBossReward(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
end

function Proto.parseLogContextData_BODY_McashDrawing(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.doubleTimes=Proto.parseWORD(entry); -- 翻倍值
	return data;
end

function Proto.writeLogContextData_BODY_McashDrawing(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writeWORD(msg,data.doubleTimes); -- 翻倍值
end

function Proto.parseLogContextData_BODY_McashActivity(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	return data;
end

function Proto.writeLogContextData_BODY_McashActivity(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
end

function Proto.parseLogContextData_BODY_BuyPetExp(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.petID=Proto.parseDWORD(entry); -- 宠物ID
	data.exp=Proto.parseDWORD(entry); -- 购买数量
	return data;
end

function Proto.writeLogContextData_BODY_BuyPetExp(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writeDWORD(msg,data.petID); -- 宠物ID
	Proto.writeDWORD(msg,data.exp); -- 购买数量
end

function Proto.parseLogContextData_BODY_BuyUnionItem(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.commodityID=Proto.parseDWORD(entry); -- 商品ID
	data.count=Proto.parseDWORD(entry); -- 购买数量
	return data;
end

function Proto.writeLogContextData_BODY_BuyUnionItem(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writeDWORD(msg,data.commodityID); -- 商品ID
	Proto.writeDWORD(msg,data.count); -- 购买数量
end

function Proto.parseLogContextData_BODY_UnionSacrifice(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.commodityID=Proto.parseDWORD(entry); -- 商品ID
	data.count=Proto.parseDWORD(entry); -- 购买数量
	return data;
end

function Proto.writeLogContextData_BODY_UnionSacrifice(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writeDWORD(msg,data.commodityID); -- 商品ID
	Proto.writeDWORD(msg,data.count); -- 购买数量
end

function Proto.parseLogContextData_BODY_FightActivity(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.fightID=Proto.parseDWORD(entry); -- 关卡ID
	return data;
end

function Proto.writeLogContextData_BODY_FightActivity(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writeDWORD(msg,data.fightID); -- 关卡ID
end

function Proto.parseLogContextData_BODY_ConfraternityDrawing(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	return data;
end

function Proto.writeLogContextData_BODY_ConfraternityDrawing(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
end

function Proto.parseLogContextData_BODY_SynGeneCover(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	return data;
end

function Proto.writeLogContextData_BODY_SynGeneCover(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
end

function Proto.parseLogContextData_BODY_GMChargeMCash(entry)
	local data={};
	data.adminID=Proto.parseCharacterID(entry); -- AdminID
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.value=Proto.parseDWORD(entry); -- 充值数
	return data;
end

function Proto.writeLogContextData_BODY_GMChargeMCash(msg,data)
	Proto.writeCharacterID(msg,data.adminID); -- AdminID
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writeDWORD(msg,data.value); -- 充值数
end

function Proto.parseLogContextData_BODY_ExtendPetDepotsCount(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- CharID
	data.ID=Proto.parseDWORD(entry); -- 仓库扩展方案ID
	data.depotCount=Proto.parseDWORD(entry); -- 仓库格数
	data.extendDepotCount=Proto.parseDWORD(entry); -- 仓库扩展格数
	return data;
end

function Proto.writeLogContextData_BODY_ExtendPetDepotsCount(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- CharID
	Proto.writeDWORD(msg,data.ID); -- 仓库扩展方案ID
	Proto.writeDWORD(msg,data.depotCount); -- 仓库格数
	Proto.writeDWORD(msg,data.extendDepotCount); -- 仓库扩展格数
end

function Proto.parseLogContextData_BODY_ArenaBattleCost(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.cost=Proto.parseDWORD(entry); -- 花费
	return data;
end

function Proto.writeLogContextData_BODY_ArenaBattleCost(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writeDWORD(msg,data.cost); -- 花费
end

function Proto.parseLogContextData_BODY_DailyTaskAward(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.awardGCash=Proto.parseDWORD(entry); -- G币收益
	return data;
end

function Proto.writeLogContextData_BODY_DailyTaskAward(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writeDWORD(msg,data.awardGCash); -- G币收益
end

function Proto.parseLogContextData_BODY_MonopolyAward(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	return data;
end

function Proto.writeLogContextData_BODY_MonopolyAward(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
end

function Proto.parseLogContextData_BODY_MoneyTree(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.money=Proto.parseDWORD(entry); -- 花费
	data.times=Proto.parseDWORD(entry); -- 次数
	return data;
end

function Proto.writeLogContextData_BODY_MoneyTree(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writeDWORD(msg,data.money); -- 花费
	Proto.writeDWORD(msg,data.times); -- 次数
end

function Proto.parseLogContextData_BODY_ArenaSendCharm(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.money=Proto.parseDWORD(entry); -- 花费
	return data;
end

function Proto.writeLogContextData_BODY_ArenaSendCharm(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writeDWORD(msg,data.money); -- 花费
end

function Proto.parseLogContextData_BODY_PetRaceArenaBattleCost(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.cost=Proto.parseDWORD(entry); -- 花费
	data.type=Proto.parseint(entry); -- 花费类型
	return data;
end

function Proto.writeLogContextData_BODY_PetRaceArenaBattleCost(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writeDWORD(msg,data.cost); -- 花费
	Proto.writeint(msg,data.type); -- 花费类型
end

function Proto.parseLogContextData_BODY_PetaideNatureLevelUp(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.costType=Proto.parseBYTE(entry); -- 费用类型
	data.itemid=Proto.parseDWORD(entry); -- 消耗道具类型
	data.count=Proto.parseDWORD(entry); -- 花费
	return data;
end

function Proto.writeLogContextData_BODY_PetaideNatureLevelUp(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writeBYTE(msg,data.costType); -- 费用类型
	Proto.writeDWORD(msg,data.itemid); -- 消耗道具类型
	Proto.writeDWORD(msg,data.count); -- 花费
end

function Proto.parseLogContextData_BODY_PetaideEvolution(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.costType=Proto.parseBYTE(entry); -- 费用类型
	data.itemid=Proto.parseDWORD(entry); -- 消耗道具类型
	data.count=Proto.parseDWORD(entry); -- 花费
	return data;
end

function Proto.writeLogContextData_BODY_PetaideEvolution(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writeBYTE(msg,data.costType); -- 费用类型
	Proto.writeDWORD(msg,data.itemid); -- 消耗道具类型
	Proto.writeDWORD(msg,data.count); -- 花费
end

function Proto.parseLogContextData_BODY_PetaideResetFeedProgress(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.costType=Proto.parseBYTE(entry); -- 费用类型
	data.itemid=Proto.parseDWORD(entry); -- 消耗道具类型
	data.count=Proto.parseDWORD(entry); -- 花费
	return data;
end

function Proto.writeLogContextData_BODY_PetaideResetFeedProgress(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writeBYTE(msg,data.costType); -- 费用类型
	Proto.writeDWORD(msg,data.itemid); -- 消耗道具类型
	Proto.writeDWORD(msg,data.count); -- 花费
end

function Proto.parseLogContextData_BODY_PetaideFeed(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.itemid=Proto.parseDWORD(entry); -- 消耗道具类型
	data.count=Proto.parseDWORD(entry); -- 花费
	return data;
end

function Proto.writeLogContextData_BODY_PetaideFeed(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writeDWORD(msg,data.itemid); -- 消耗道具类型
	Proto.writeDWORD(msg,data.count); -- 花费
end

function Proto.parseLogContextData_BODY_EquipGeneCost(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.type=Proto.parseint(entry); -- 花费类型
	data.costType=Proto.parseBYTE(entry); -- 费用类型
	data.itemid=Proto.parseDWORD(entry); -- 消耗道具类型
	data.count=Proto.parseDWORD(entry); -- 花费
	return data;
end

function Proto.writeLogContextData_BODY_EquipGeneCost(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writeint(msg,data.type); -- 花费类型
	Proto.writeBYTE(msg,data.costType); -- 费用类型
	Proto.writeDWORD(msg,data.itemid); -- 消耗道具类型
	Proto.writeDWORD(msg,data.count); -- 花费
end

function Proto.parseLogContextData_BODY_CrossWorldMail(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	return data;
end

function Proto.writeLogContextData_BODY_CrossWorldMail(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
end

function Proto.parseLogContextData_BODY_CrossWorldAward(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.awardTableID=Proto.parseDWORD(entry); -- 奖励组ID
	return data;
end

function Proto.writeLogContextData_BODY_CrossWorldAward(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writeDWORD(msg,data.awardTableID); -- 奖励组ID
end

function Proto.parseLogContextData_BODY_DiffIndustryAward(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.successAward=Proto.parseBYTE(entry); -- 成功获得
	return data;
end

function Proto.writeLogContextData_BODY_DiffIndustryAward(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writeBYTE(msg,data.successAward); -- 成功获得
end

function Proto.parseLogContextData_BODY_WebActivityCost(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.type=Proto.parseDWORD(entry); -- 网页活动类型
	data.costType=Proto.parseDWORD(entry); -- 花费类型
	data.cost=Proto.parseDWORD(entry); -- 花费
	return data;
end

function Proto.writeLogContextData_BODY_WebActivityCost(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writeDWORD(msg,data.type); -- 网页活动类型
	Proto.writeDWORD(msg,data.costType); -- 花费类型
	Proto.writeDWORD(msg,data.cost); -- 花费
end

function Proto.parseLogContextData_BODY_ChangePetAssignPoints(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.petID=Proto.parseDWORD(entry); -- 宠物ID
	return data;
end

function Proto.writeLogContextData_BODY_ChangePetAssignPoints(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writeDWORD(msg,data.petID); -- 宠物ID
end

function Proto.parseLogContextData_BODY_GMSendMail(entry)
	local data={};
	data.adminID=Proto.parseCharacterID(entry); -- AdminID
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	return data;
end

function Proto.writeLogContextData_BODY_GMSendMail(msg,data)
	Proto.writeCharacterID(msg,data.adminID); -- AdminID
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
end

function Proto.parseLogContextData_BODY_GallantsMail(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	return data;
end

function Proto.writeLogContextData_BODY_GallantsMail(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
end

function Proto.parseLogContextData_BODY_PetReduceStruggles(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.petID=Proto.parsePetID(entry); -- 宠物ID
	data.reducePoint1=Proto.parseWORD(entry); -- 减少努力值1
	data.reducePoint2=Proto.parseWORD(entry); -- 减少努力值2
	data.reducePoint3=Proto.parseWORD(entry); -- 减少努力值3
	data.reducePoint4=Proto.parseWORD(entry); -- 减少努力值4
	data.reducePoint5=Proto.parseWORD(entry); -- 减少努力值5
	data.reducePoint6=Proto.parseWORD(entry); -- 减少努力值6
	data.petStruggle1=Proto.parseWORD(entry); -- 宠物努力值1
	data.petStruggle2=Proto.parseWORD(entry); -- 宠物努力值2
	data.petStruggle3=Proto.parseWORD(entry); -- 宠物努力值3
	data.petStruggle4=Proto.parseWORD(entry); -- 宠物努力值4
	data.petStruggle5=Proto.parseWORD(entry); -- 宠物努力值5
	data.petStruggle6=Proto.parseWORD(entry); -- 宠物努力值6
	data.petIntensifyCount=Proto.parseWORD(entry); -- 宠物潜力点
	return data;
end

function Proto.writeLogContextData_BODY_PetReduceStruggles(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writePetID(msg,data.petID); -- 宠物ID
	Proto.writeWORD(msg,data.reducePoint1); -- 减少努力值1
	Proto.writeWORD(msg,data.reducePoint2); -- 减少努力值2
	Proto.writeWORD(msg,data.reducePoint3); -- 减少努力值3
	Proto.writeWORD(msg,data.reducePoint4); -- 减少努力值4
	Proto.writeWORD(msg,data.reducePoint5); -- 减少努力值5
	Proto.writeWORD(msg,data.reducePoint6); -- 减少努力值6
	Proto.writeWORD(msg,data.petStruggle1); -- 宠物努力值1
	Proto.writeWORD(msg,data.petStruggle2); -- 宠物努力值2
	Proto.writeWORD(msg,data.petStruggle3); -- 宠物努力值3
	Proto.writeWORD(msg,data.petStruggle4); -- 宠物努力值4
	Proto.writeWORD(msg,data.petStruggle5); -- 宠物努力值5
	Proto.writeWORD(msg,data.petStruggle6); -- 宠物努力值6
	Proto.writeWORD(msg,data.petIntensifyCount); -- 宠物潜力点
end

function Proto.parseLogContextData_BODY_GachaBurst(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.gachaID=Proto.parseDWORD(entry); -- 扭蛋机ID
	data.gachaEggGenerateID=Proto.parseDWORD(entry); -- 扭蛋ID
	return data;
end

function Proto.writeLogContextData_BODY_GachaBurst(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writeDWORD(msg,data.gachaID); -- 扭蛋机ID
	Proto.writeDWORD(msg,data.gachaEggGenerateID); -- 扭蛋ID
end

function Proto.parseLogContextData_BODY_ImmolatePet(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.petID=Proto.parsePetID(entry); -- 宠物ID
	data.race=Proto.parseDWORD(entry); -- 宠物种族
	return data;
end

function Proto.writeLogContextData_BODY_ImmolatePet(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writePetID(msg,data.petID); -- 宠物ID
	Proto.writeDWORD(msg,data.race); -- 宠物种族
end

function Proto.parseLogContextData_BODY_PetInjectSoul(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.petID=Proto.parsePetID(entry); -- 宠物ID
	data.soulPoints=Proto.parseDWORD(entry); -- 需要转换的点数
	return data;
end

function Proto.writeLogContextData_BODY_PetInjectSoul(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writePetID(msg,data.petID); -- 宠物ID
	Proto.writeDWORD(msg,data.soulPoints); -- 需要转换的点数
end

function Proto.parseLogContextData_BODY_ExpandSoulPool(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	return data;
end

function Proto.writeLogContextData_BODY_ExpandSoulPool(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
end

function Proto.parseLogContextData_BODY_PetTurn(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.petID=Proto.parsePetID(entry); -- 宠物ID
	return data;
end

function Proto.writeLogContextData_BODY_PetTurn(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writePetID(msg,data.petID); -- 宠物ID
end

function Proto.parseLogContextData_BODY_CrossWorldGamble(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.winCount=Proto.parseWORD(entry); -- 胜出人数
	data.winnerID=Proto.parseCharacterID(entry); -- 获胜玩家ID
	data.money=Proto.parseDWORD(entry); -- 赌注
	return data;
end

function Proto.writeLogContextData_BODY_CrossWorldGamble(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writeWORD(msg,data.winCount); -- 胜出人数
	Proto.writeCharacterID(msg,data.winnerID); -- 获胜玩家ID
	Proto.writeDWORD(msg,data.money); -- 赌注
end

function Proto.parseLogContextData_BODY_ChallengeBossRebornPayMedicine(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	return data;
end

function Proto.writeLogContextData_BODY_ChallengeBossRebornPayMedicine(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
end

function Proto.parseLogContextData_BODY_SendGift(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.receiverCharID=Proto.parseCharacterID(entry); -- 获赠者ID
	data.giftType=Proto.parseBYTE(entry); -- 赠送道具类型
	data.param1=Proto.parseDWORD(entry); -- 参数1
	data.param2=Proto.parseDWORD(entry); -- 参数2
	return data;
end

function Proto.writeLogContextData_BODY_SendGift(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writeCharacterID(msg,data.receiverCharID); -- 获赠者ID
	Proto.writeBYTE(msg,data.giftType); -- 赠送道具类型
	Proto.writeDWORD(msg,data.param1); -- 参数1
	Proto.writeDWORD(msg,data.param2); -- 参数2
end

function Proto.parseLogContextData_BODY_PetRefreshSixDPoints(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.petID=Proto.parsePetID(entry); -- 宠物ID
	return data;
end

function Proto.writeLogContextData_BODY_PetRefreshSixDPoints(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writePetID(msg,data.petID); -- 宠物ID
end

function Proto.parseLogContextData_BODY_SignDailyReward(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.awardID=Proto.parseDWORD(entry); -- 奖励组ID
	return data;
end

function Proto.writeLogContextData_BODY_SignDailyReward(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writeDWORD(msg,data.awardID); -- 奖励组ID
end

function Proto.parseLogContextData_BODY_DigTreasureAward(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.awardID=Proto.parseDWORD(entry); -- 奖励组ID
	return data;
end

function Proto.writeLogContextData_BODY_DigTreasureAward(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writeDWORD(msg,data.awardID); -- 奖励组ID
end

function Proto.parseLogContextData_BODY_WealthGodAward(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.awardID=Proto.parseDWORD(entry); -- 奖励组ID
	return data;
end

function Proto.writeLogContextData_BODY_WealthGodAward(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writeDWORD(msg,data.awardID); -- 奖励组ID
end

function Proto.parseLogContextData_BODY_RechargeConsumePoints(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.activityID=Proto.parseDWORD(entry); -- 活动ID
	data.type=Proto.parseBYTE(entry); -- 充值或消费
	data.oldValue=Proto.parseDWORD(entry); -- 原始数值
	data.addValue=Proto.parseint(entry); -- 添加数值
	return data;
end

function Proto.writeLogContextData_BODY_RechargeConsumePoints(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writeDWORD(msg,data.activityID); -- 活动ID
	Proto.writeBYTE(msg,data.type); -- 充值或消费
	Proto.writeDWORD(msg,data.oldValue); -- 原始数值
	Proto.writeint(msg,data.addValue); -- 添加数值
end

function Proto.parseLogContextData_BODY_RechargeConsumeAward(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.type=Proto.parseBYTE(entry); -- 充值或消费
	data.awardTableID=Proto.parseDWORD(entry); -- 奖励
	return data;
end

function Proto.writeLogContextData_BODY_RechargeConsumeAward(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writeBYTE(msg,data.type); -- 充值或消费
	Proto.writeDWORD(msg,data.awardTableID); -- 奖励
end

function Proto.parseLogContextData_BODY_BuyMonthCard(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.cardID=Proto.parseBYTE(entry); -- 月卡ID
	return data;
end

function Proto.writeLogContextData_BODY_BuyMonthCard(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writeBYTE(msg,data.cardID); -- 月卡ID
end

function Proto.parseLogContextData_BODY_TakeMonthCard(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.cardID=Proto.parseBYTE(entry); -- 月卡ID
	return data;
end

function Proto.writeLogContextData_BODY_TakeMonthCard(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writeBYTE(msg,data.cardID); -- 月卡ID
end

function Proto.parseLogContextData_BODY_BuyAdventureResetTimes(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	return data;
end

function Proto.writeLogContextData_BODY_BuyAdventureResetTimes(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
end

function Proto.parseLogContextData_BODY_BuyAdventureRebornTimes(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	return data;
end

function Proto.writeLogContextData_BODY_BuyAdventureRebornTimes(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
end

function Proto.parseLogContextData_BODY_GetStarSoulReward(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.awardID=Proto.parseDWORD(entry); -- 奖励ID
	return data;
end

function Proto.writeLogContextData_BODY_GetStarSoulReward(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writeDWORD(msg,data.awardID); -- 奖励ID
end

function Proto.parseLogContextData_BODY_AdventureReward(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.level=Proto.parseDWORD(entry); -- 副本层数
	data.cellType=Proto.parseBYTE(entry); -- 格子类型
	data.awardTable=Proto.parseDWORD(entry); -- 奖励表
	return data;
end

function Proto.writeLogContextData_BODY_AdventureReward(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writeDWORD(msg,data.level); -- 副本层数
	Proto.writeBYTE(msg,data.cellType); -- 格子类型
	Proto.writeDWORD(msg,data.awardTable); -- 奖励表
end

function Proto.parseLogContextData(entry)
	local data={};
	data.type=Proto.parseBYTE(entry); -- 上下文类型,
	data.body={}; -- 
	if (data.type==Proto.LCT_USE_ITEM) then
		data.body.useItem=Proto.parseLogContextData_BODY_UseItem(entry); -- 使用道具
	end
	if (data.type==Proto.LCT_SELL_ITEM) then
		data.body.sellItem=Proto.parseLogContextData_BODY_SellItem(entry); -- 出售道具
	end
	if (data.type==Proto.LCT_DISCARD_ITEM) then
		data.body.discardItem=Proto.parseLogContextData_BODY_DisCardItem(entry); -- 丢弃道具
	end
	if (data.type==Proto.LCT_SYNTHESIZE_ITEM) then
		data.body.synthesizeItem=Proto.parseLogContextData_BODY_SynthesizeItem(entry); -- 合成道具
	end
	if (data.type==Proto.LCT_RECEIVE_MAIL) then
		data.body.receiveMail=Proto.parseLogContextData_BODY_ReceiveMail(entry); -- 收邮件
	end
	if (data.type==Proto.LCT_BUY_COMMODITY) then
		data.body.buyCommodity=Proto.parseLogContextData_BODY_BuyCommodity(entry); -- 随身商店购买
	end
	if (data.type==Proto.LCT_CHALLENGE_STAGE) then
		data.body.challengeStage=Proto.parseLogContextData_BODY_ChallengeStage(entry); -- 挑战关卡
	end
	if (data.type==Proto.LCT_SIGNIN) then
		data.body.signIn=Proto.parseLogContextData_BODY_SignIn(entry); -- 每日签到
	end
	if (data.type==Proto.LCT_VIP_SIGNIN) then
		data.body.vipSignIn=Proto.parseLogContextData_BODY_VipSignIn(entry); -- VIP签到
	end
	if (data.type==Proto.LCT_ACTIVE_DRAWING) then
		data.body.activeDrawing=Proto.parseLogContextData_BODY_ActiveDrawing(entry); -- 活跃度抽奖
	end
	if (data.type==Proto.LCT_RESET_HATCH) then
		data.body.resetHatch=Proto.parseLogContextData_BODY_ResetHatch(entry); -- 宠物移动至孵化栏
	end
	if (data.type==Proto.LCT_FINISH_ACHIEVEMENT) then
		data.body.finishAchievement=Proto.parseLogContextData_BODY_FinishAchievement(entry); -- 完成成就
	end
	if (data.type==Proto.LCT_USE_TICKET) then
		data.body.useTicket=Proto.parseLogContextData_BODY_UseTicket(entry); -- 使用积分券
	end
	if (data.type==Proto.LCT_ARENA_AWARD) then
		data.body.arenaAward=Proto.parseLogContextData_BODY_ArenaAward(entry); -- 竞技场奖励
	end
	if (data.type==Proto.LCT_CHALLENGE_BOSS_REBORN) then
		data.body.challengeBossReborn=Proto.parseLogContextData_BODY_ChallengeBossReborn(entry); -- 挑战boss复活时间清空
	end
	if (data.type==Proto.LCT_GA_CHA) then
		data.body.gaCha=Proto.parseLogContextData_BODY_GaCha(entry); -- 扭蛋
	end
	if (data.type==Proto.LCT_HATCH_PET) then
		data.body.hatchPet=Proto.parseLogContextData_BODY_HatchPet(entry); -- 孵蛋
	end
	if (data.type==Proto.LCT_CLEAR_HATCH) then
		data.body.clearHatch=Proto.parseLogContextData_BODY_ClearHatch(entry); -- 清空孵化
	end
	if (data.type==Proto.LCT_PET_CLEAR) then
		data.body.clearPotential=Proto.parseLogContextData_BODY_ClearPotential(entry); -- 宠物潜力点重置
	end
	if (data.type==Proto.LCT_PET_BREED) then
		data.body.breedPotential=Proto.parseLogContextData_BODY_BreedPotential(entry); -- 宠物潜力点培育
	end
	if (data.type==Proto.LCT_TAKE_HATCH) then
		data.body.takeHatch=Proto.parseLogContextData_BODY_TakeHatch(entry); -- 领取孵化
	end
	if (data.type==Proto.LCT_INTENSIFY_EQUIP) then
		data.body.intensifyEquip=Proto.parseLogContextData_BODY_IntensifyEquip(entry); -- 强化装备
	end
	if (data.type==Proto.LCT_EQUIP_MERGE) then
		data.body.mergeEquip=Proto.parseLogContextData_BODY_MergeEquip(entry); -- 融合装备
	end
	if (data.type==Proto.LCT_EQUIP_RESET) then
		data.body.resetEquip=Proto.parseLogContextData_BODY_ResetEquip(entry); -- 洗练装备
	end
	if (data.type==Proto.LCT_SKILL_LEARN) then
		data.body.learnSkill=Proto.parseLogContextData_BODY_LearnSkill(entry); -- 学习技能
	end
	if (data.type==Proto.LCT_EQUIPMENT_WEAR) then
		data.body.wearEquipment=Proto.parseLogContextData_BODY_WearEquipment(entry); -- 穿戴装备
	end
	if (data.type==Proto.LCT_PACKET_EXTEND) then
		data.body.extendPacket=Proto.parseLogContextData_BODY_ExtendPacket(entry); -- 扩展背包
	end
	if (data.type==Proto.LCT_PET_CULL) then
		data.body.cullPet=Proto.parseLogContextData_BODY_CullPet(entry); -- 新手宠物蛋
	end
	if (data.type==Proto.LCT_SKILL_UP) then
		data.body.skillUp=Proto.parseLogContextData_BODY_SkillUp(entry); -- 技能升级
	end
	if (data.type==Proto.LCT_SUBSTITUE_PET) then
		data.body.substitutePet=Proto.parseLogContextData_BODY_SubstitutePet(entry); -- 拖油瓶请求
	end
	if (data.type==Proto.LCT_EGG_EAT) then
		data.body.eatEgg=Proto.parseLogContextData_BODY_EatEgg(entry); -- 吃蛋
	end
	if (data.type==Proto.LCT_PET_EAT) then
		data.body.eatPet=Proto.parseLogContextData_BODY_EatPet(entry); -- 吃宠
	end
	if (data.type==Proto.LCT_GROUND_TRAINING) then
		data.body.trainingGround=Proto.parseLogContextData_BODY_TrainingGround(entry); -- 训练场
	end
	if (data.type==Proto.LCT_PET_EVOLUTION) then
		data.body.petEvolution=Proto.parseLogContextData_BODY_PetEvolution(entry); -- 宠物进化
	end
	if (data.type==Proto.LCT_ARENA_SYSTEM_MAIL) then
		data.body.arenaMail=Proto.parseLogContextData_BODY_ArenaMail(entry); -- 竞技场系统邮件
	end
	if (data.type==Proto.LCT_BOSSBATTLE_SYSTEM_MAIL) then
		data.body.bossBattleMail=Proto.parseLogContextData_BODY_BossBattleMail(entry); -- boss战系统邮件
	end
	if (data.type==Proto.LCT_TRAINING_SYSTEM_MAIL) then
		data.body.trainingMail=Proto.parseLogContextData_BODY_TrainingMail(entry); -- 训练场系统邮件
	end
	if (data.type==Proto.LCT_GM_SYSTEM_MAIL) then
		data.body.gmMail=Proto.parseLogContextData_BODY_GMMail(entry); -- GM系统邮件
	end
	if (data.type==Proto.LCT_EXCHANGEREWARD_SYSTEM_MAIL) then
		data.body.exchangeRewardMail=Proto.parseLogContextData_BODY_ExchangeRewardMail(entry); -- 兑换奖励
	end
	if (data.type==Proto.LCT_SINGLE_STAGE_BATTLE) then
		data.body.singleStageBattle=Proto.parseLogContextData_BODY_SingleStageBattle(entry); -- 宠物闯关
	end
	if (data.type==Proto.LCT_REMOVE_AUCTION_ITEM) then
		data.body.removeAuctionItem=Proto.parseLogContextData_BODY_RemoveAuctionItem(entry); -- 移除拍卖道具
	end
	if (data.type==Proto.LCT_PAY_AUCTION) then
		data.body.payAuction=Proto.parseLogContextData_BODY_PayAuction(entry); -- 支付拍卖道具
	end
	if (data.type==Proto.LCT_BUYITEM_AUCTION) then
		data.body.buyItemAuction=Proto.parseLogContextData_BODY_BuyItemAuction(entry); -- 购买拍卖道具
	end
	if (data.type==Proto.LCT_UNION_CREATE) then
		data.body.createUnion=Proto.parseLogContextData_BODY_CreateUnion(entry); -- 创建工会
	end
	if (data.type==Proto.LCT_RECHARGE) then
		data.body.recharge=Proto.parseLogContextData_BODY_Recharge(entry); -- 充值
	end
	if (data.type==Proto.LCT_AUCTION_EXCEED) then
		data.body.auctionExceed=Proto.parseLogContextData_BODY_AuctionExceed(entry); -- 拍卖行物品过期邮件
	end
	if (data.type==Proto.LCT_HEROSTAGE_RESET) then
		data.body.resetHeroStage=Proto.parseLogContextData_BODY_ResetHeroStage(entry); -- 重置英雄关卡
	end
	if (data.type==Proto.LCT_SINGLEBOSS_REWARD) then
		data.body.singleBossReward=Proto.parseLogContextData_BODY_SingleBossReward(entry); -- boss战单次奖励
	end
	if (data.type==Proto.LCT_MCASH_DRAWING) then
		data.body.mcashDrawing=Proto.parseLogContextData_BODY_McashDrawing(entry); -- M币抽奖
	end
	if (data.type==Proto.LCT_MCASH_ACTIVITY) then
		data.body.mcashActivity=Proto.parseLogContextData_BODY_McashActivity(entry); -- 活动奖励M币
	end
	if (data.type==Proto.LCT_BUY_PET_EXP) then
		data.body.buyPetExp=Proto.parseLogContextData_BODY_BuyPetExp(entry); -- 购买宠物经验
	end
	if (data.type==Proto.LCT_BUY_UNION_ITEM) then
		data.body.buyUnionItem=Proto.parseLogContextData_BODY_BuyUnionItem(entry); -- 购买工会道具
	end
	if (data.type==Proto.LCT_UNION_SAC) then
		data.body.unionSacrifice=Proto.parseLogContextData_BODY_UnionSacrifice(entry); -- 工会献祭
	end
	if (data.type==Proto.LCT_FIGHTACTIVITY) then
		data.body.fightActivity=Proto.parseLogContextData_BODY_FightActivity(entry); -- 万人斩活动
	end
	if (data.type==Proto.LCT_CONFRATERNITY_DRAWING) then
		data.body.confraternityDrawing=Proto.parseLogContextData_BODY_ConfraternityDrawing(entry); -- 工会抽奖
	end
	if (data.type==Proto.LCT_SYN_GENECOVER) then
		data.body.synGeneCover=Proto.parseLogContextData_BODY_SynGeneCover(entry); -- 技能书合成
	end
	if (data.type==Proto.LCT_GM_CHARGE_MCASH) then
		data.body.gmChargeMCash=Proto.parseLogContextData_BODY_GMChargeMCash(entry); -- GM充值
	end
	if (data.type==Proto.LCT_EXTEND_PET_DEPOTS_COUNT) then
		data.body.extendPetDepotsCount=Proto.parseLogContextData_BODY_ExtendPetDepotsCount(entry); -- 扩展宠物仓库
	end
	if (data.type==Proto.LCT_ARENA_BATTLE) then
		data.body.arenaBattleCost=Proto.parseLogContextData_BODY_ArenaBattleCost(entry); -- 竞技场挑战花费
	end
	if (data.type==Proto.LCT_DAILYTASK_AWARD) then
		data.body.dailyTaskAward=Proto.parseLogContextData_BODY_DailyTaskAward(entry); -- 竞技场挑战花费
	end
	if (data.type==Proto.LCT_MONOPOLY_AWARD) then
		data.body.monopolyAward=Proto.parseLogContextData_BODY_MonopolyAward(entry); -- 暴走收益
	end
	if (data.type==Proto.LCT_MONEY_TREE) then
		data.body.moneyTree=Proto.parseLogContextData_BODY_MoneyTree(entry); -- 摇钱树
	end
	if (data.type==Proto.LCT_SEND_ARENA_CHARM) then
		data.body.arenaSendCharm=Proto.parseLogContextData_BODY_ArenaSendCharm(entry); -- 竞技场赠送魅力
	end
	if (data.type==Proto.LCT_PET_RACE_ARENA_BATTLE) then
		data.body.petRaceArenaBattleCost=Proto.parseLogContextData_BODY_PetRaceArenaBattleCost(entry); -- 宠物单挑竞技场挑战花费
	end
	if (data.type==Proto.LCT_PET_AIDE_NATURE_LEVELUP) then
		data.body.petaideNatureLevelUp=Proto.parseLogContextData_BODY_PetaideNatureLevelUp(entry); -- 伴灵技能强化
	end
	if (data.type==Proto.LCT_PET_AIDE_EVOLUTION) then
		data.body.petaideEvolution=Proto.parseLogContextData_BODY_PetaideEvolution(entry); -- 伴灵进化
	end
	if (data.type==Proto.LCT_PET_AIDE_RESET_FEED_PROGRESS) then
		data.body.petaideResetFeedProgress=Proto.parseLogContextData_BODY_PetaideResetFeedProgress(entry); -- 伴灵清空饱食度
	end
	if (data.type==Proto.LCT_PET_AIDE_FEED) then
		data.body.petaideFeed=Proto.parseLogContextData_BODY_PetaideFeed(entry); -- 伴灵喂养
	end
	if (data.type==Proto.LCT_EQUIP_GENE) then
		data.body.equipGeneCost=Proto.parseLogContextData_BODY_EquipGeneCost(entry); -- 装备技能花费
	end
	if (data.type==Proto.LCT_CROSSWORLD_SYSTEM_MAIL) then
		data.body.crossWorldMail=Proto.parseLogContextData_BODY_CrossWorldMail(entry); -- 跨服战邮件奖励
	end
	if (data.type==Proto.LCT_CROSSWORLD_AWARD) then
		data.body.crossWorldAward=Proto.parseLogContextData_BODY_CrossWorldAward(entry); -- 跨服战膜拜奖励
	end
	if (data.type==Proto.LCT_DIFFINDUSTRY_AWARD) then
		data.body.diffIndustryAward=Proto.parseLogContextData_BODY_DiffIndustryAward(entry); -- 异业合作券
	end
	if (data.type==Proto.LCT_WEB_ACTIVITY) then
		data.body.webActivityCost=Proto.parseLogContextData_BODY_WebActivityCost(entry); -- 网页活动花费
	end
	if (data.type==Proto.LCT_CHANGE_PET_ASSIGNPOINTS) then
		data.body.changePetAssignPoints=Proto.parseLogContextData_BODY_ChangePetAssignPoints(entry); -- 修改宠物分配点
	end
	if (data.type==Proto.LCT_GM_MAIL) then
		data.body.gmSendMail=Proto.parseLogContextData_BODY_GMSendMail(entry); -- admintool发送邮件
	end
	if (data.type==Proto.LCT_GALLANTS_SYSTEM_MAIL) then
		data.body.gallantsMail=Proto.parseLogContextData_BODY_GallantsMail(entry); -- 擂台赛邮件件
	end
	if (data.type==Proto.LCT_PET_REDUCE_STRUGGLES) then
		data.body.petReduceStruggles=Proto.parseLogContextData_BODY_PetReduceStruggles(entry); -- 宠物减少努力值
	end
	if (data.type==Proto.LCT_GA_CHA_BURST) then
		data.body.gachaBurst=Proto.parseLogContextData_BODY_GachaBurst(entry); -- 扭蛋爆发
	end
	if (data.type==Proto.LCT_IMMOLATE_PET) then
		data.body.immolatePet=Proto.parseLogContextData_BODY_ImmolatePet(entry); -- 献祭
	end
	if (data.type==Proto.LCT_PET_INJECT_SOUL) then
		data.body.petInjectSoul=Proto.parseLogContextData_BODY_PetInjectSoul(entry); -- 宠物注入灵魂
	end
	if (data.type==Proto.LCT_EXPAND_SOUL_POOL) then
		data.body.expandSoulPool=Proto.parseLogContextData_BODY_ExpandSoulPool(entry); -- 扩充魂池
	end
	if (data.type==Proto.LCT_PET_TURN) then
		data.body.petTurn=Proto.parseLogContextData_BODY_PetTurn(entry); -- 宠物转生
	end
	if (data.type==Proto.LCT_CROSSWORLD_GAMBLE) then
		data.body.crossWorldGamble=Proto.parseLogContextData_BODY_CrossWorldGamble(entry); -- 跨服战赌博
	end
	if (data.type==Proto.LCT_CHALLENGE_BOSS_PAYMEDICINE) then
		data.body.challengeBossPayMedicine=Proto.parseLogContextData_BODY_ChallengeBossRebornPayMedicine(entry); -- 挑战boss付费药水
	end
	if (data.type==Proto.LCT_SEND_GIFT) then
		data.body.sendGift=Proto.parseLogContextData_BODY_SendGift(entry); -- 商场赠送道具
	end
	if (data.type==Proto.LCT_PET_REFRESH_SIXD_POINTS) then
		data.body.petRefreshSixDPoints=Proto.parseLogContextData_BODY_PetRefreshSixDPoints(entry); -- 刷新六维
	end
	if (data.type==Proto.LCT_FETCH_SIGN_DAILY_REWARD) then
		data.body.signDailyAward=Proto.parseLogContextData_BODY_SignDailyReward(entry); -- 每日签到领取奖励
	end
	if (data.type==Proto.LCT_GET_DIG_AWARD) then
		data.body.digTreasureAward=Proto.parseLogContextData_BODY_DigTreasureAward(entry); -- 挖宝获得奖励
	end
	if (data.type==Proto.LCT_GET_WEALTH_GOD_AWARD) then
		data.body.wealthGodAward=Proto.parseLogContextData_BODY_WealthGodAward(entry); -- 财神驾到获得奖励
	end
	if (data.type==Proto.LCT_RECHARGE_CONSUME_POINTS) then
		data.body.rechargeConsumePoints=Proto.parseLogContextData_BODY_RechargeConsumePoints(entry); -- 充值消费积分变化
	end
	if (data.type==Proto.LCT_RECHARGE_CONSUME_AWARD) then
		data.body.rechargeConsumeAward=Proto.parseLogContextData_BODY_RechargeConsumeAward(entry); -- 充值消费积分奖励
	end
	if (data.type==Proto.LCT_BUY_MONTH_CARD) then
		data.body.buyMonthCard=Proto.parseLogContextData_BODY_BuyMonthCard(entry); -- 购买月卡
	end
	if (data.type==Proto.LCT_TAKE_MONTH_CARD) then
		data.body.takeMonthCard=Proto.parseLogContextData_BODY_TakeMonthCard(entry); -- 领取月卡
	end
	if (data.type==Proto.LCT_BUY_ADVENTURE_RESET_TIMES) then
		data.body.buyAdventureResetTimes=Proto.parseLogContextData_BODY_BuyAdventureResetTimes(entry); -- 副本购买重置次数
	end
	if (data.type==Proto.LCT_BUY_ADVENTURE_REBORN_TIMES) then
		data.body.buyAdventureRebornTimes=Proto.parseLogContextData_BODY_BuyAdventureRebornTimes(entry); -- 副本购买重置次数
	end
	if (data.type==Proto.LCT_GET_STAR_SOUL_REWARD) then
		data.body.getStarSoulReward=Proto.parseLogContextData_BODY_GetStarSoulReward(entry); -- 领取星魂殿奖励
	end
	if (data.type==Proto.LCT_ADVENTURE_REWARD) then
		data.body.adventureReward=Proto.parseLogContextData_BODY_AdventureReward(entry); -- 副本奖励
	end
	return data;
end

function Proto.writeLogContextData(msg,data)
	Proto.writeBYTE(msg,data.type); -- 上下文类型,
	if (data.type==Proto.LCT_USE_ITEM) then
		Proto.writeLogContextData_BODY_UseItem(msg,data.body.useItem); -- 使用道具
	end
	if (data.type==Proto.LCT_SELL_ITEM) then
		Proto.writeLogContextData_BODY_SellItem(msg,data.body.sellItem); -- 出售道具
	end
	if (data.type==Proto.LCT_DISCARD_ITEM) then
		Proto.writeLogContextData_BODY_DisCardItem(msg,data.body.discardItem); -- 丢弃道具
	end
	if (data.type==Proto.LCT_SYNTHESIZE_ITEM) then
		Proto.writeLogContextData_BODY_SynthesizeItem(msg,data.body.synthesizeItem); -- 合成道具
	end
	if (data.type==Proto.LCT_RECEIVE_MAIL) then
		Proto.writeLogContextData_BODY_ReceiveMail(msg,data.body.receiveMail); -- 收邮件
	end
	if (data.type==Proto.LCT_BUY_COMMODITY) then
		Proto.writeLogContextData_BODY_BuyCommodity(msg,data.body.buyCommodity); -- 随身商店购买
	end
	if (data.type==Proto.LCT_CHALLENGE_STAGE) then
		Proto.writeLogContextData_BODY_ChallengeStage(msg,data.body.challengeStage); -- 挑战关卡
	end
	if (data.type==Proto.LCT_SIGNIN) then
		Proto.writeLogContextData_BODY_SignIn(msg,data.body.signIn); -- 每日签到
	end
	if (data.type==Proto.LCT_VIP_SIGNIN) then
		Proto.writeLogContextData_BODY_VipSignIn(msg,data.body.vipSignIn); -- VIP签到
	end
	if (data.type==Proto.LCT_ACTIVE_DRAWING) then
		Proto.writeLogContextData_BODY_ActiveDrawing(msg,data.body.activeDrawing); -- 活跃度抽奖
	end
	if (data.type==Proto.LCT_RESET_HATCH) then
		Proto.writeLogContextData_BODY_ResetHatch(msg,data.body.resetHatch); -- 宠物移动至孵化栏
	end
	if (data.type==Proto.LCT_FINISH_ACHIEVEMENT) then
		Proto.writeLogContextData_BODY_FinishAchievement(msg,data.body.finishAchievement); -- 完成成就
	end
	if (data.type==Proto.LCT_USE_TICKET) then
		Proto.writeLogContextData_BODY_UseTicket(msg,data.body.useTicket); -- 使用积分券
	end
	if (data.type==Proto.LCT_ARENA_AWARD) then
		Proto.writeLogContextData_BODY_ArenaAward(msg,data.body.arenaAward); -- 竞技场奖励
	end
	if (data.type==Proto.LCT_CHALLENGE_BOSS_REBORN) then
		Proto.writeLogContextData_BODY_ChallengeBossReborn(msg,data.body.challengeBossReborn); -- 挑战boss复活时间清空
	end
	if (data.type==Proto.LCT_GA_CHA) then
		Proto.writeLogContextData_BODY_GaCha(msg,data.body.gaCha); -- 扭蛋
	end
	if (data.type==Proto.LCT_HATCH_PET) then
		Proto.writeLogContextData_BODY_HatchPet(msg,data.body.hatchPet); -- 孵蛋
	end
	if (data.type==Proto.LCT_CLEAR_HATCH) then
		Proto.writeLogContextData_BODY_ClearHatch(msg,data.body.clearHatch); -- 清空孵化
	end
	if (data.type==Proto.LCT_PET_CLEAR) then
		Proto.writeLogContextData_BODY_ClearPotential(msg,data.body.clearPotential); -- 宠物潜力点重置
	end
	if (data.type==Proto.LCT_PET_BREED) then
		Proto.writeLogContextData_BODY_BreedPotential(msg,data.body.breedPotential); -- 宠物潜力点培育
	end
	if (data.type==Proto.LCT_TAKE_HATCH) then
		Proto.writeLogContextData_BODY_TakeHatch(msg,data.body.takeHatch); -- 领取孵化
	end
	if (data.type==Proto.LCT_INTENSIFY_EQUIP) then
		Proto.writeLogContextData_BODY_IntensifyEquip(msg,data.body.intensifyEquip); -- 强化装备
	end
	if (data.type==Proto.LCT_EQUIP_MERGE) then
		Proto.writeLogContextData_BODY_MergeEquip(msg,data.body.mergeEquip); -- 融合装备
	end
	if (data.type==Proto.LCT_EQUIP_RESET) then
		Proto.writeLogContextData_BODY_ResetEquip(msg,data.body.resetEquip); -- 洗练装备
	end
	if (data.type==Proto.LCT_SKILL_LEARN) then
		Proto.writeLogContextData_BODY_LearnSkill(msg,data.body.learnSkill); -- 学习技能
	end
	if (data.type==Proto.LCT_EQUIPMENT_WEAR) then
		Proto.writeLogContextData_BODY_WearEquipment(msg,data.body.wearEquipment); -- 穿戴装备
	end
	if (data.type==Proto.LCT_PACKET_EXTEND) then
		Proto.writeLogContextData_BODY_ExtendPacket(msg,data.body.extendPacket); -- 扩展背包
	end
	if (data.type==Proto.LCT_PET_CULL) then
		Proto.writeLogContextData_BODY_CullPet(msg,data.body.cullPet); -- 新手宠物蛋
	end
	if (data.type==Proto.LCT_SKILL_UP) then
		Proto.writeLogContextData_BODY_SkillUp(msg,data.body.skillUp); -- 技能升级
	end
	if (data.type==Proto.LCT_SUBSTITUE_PET) then
		Proto.writeLogContextData_BODY_SubstitutePet(msg,data.body.substitutePet); -- 拖油瓶请求
	end
	if (data.type==Proto.LCT_EGG_EAT) then
		Proto.writeLogContextData_BODY_EatEgg(msg,data.body.eatEgg); -- 吃蛋
	end
	if (data.type==Proto.LCT_PET_EAT) then
		Proto.writeLogContextData_BODY_EatPet(msg,data.body.eatPet); -- 吃宠
	end
	if (data.type==Proto.LCT_GROUND_TRAINING) then
		Proto.writeLogContextData_BODY_TrainingGround(msg,data.body.trainingGround); -- 训练场
	end
	if (data.type==Proto.LCT_PET_EVOLUTION) then
		Proto.writeLogContextData_BODY_PetEvolution(msg,data.body.petEvolution); -- 宠物进化
	end
	if (data.type==Proto.LCT_ARENA_SYSTEM_MAIL) then
		Proto.writeLogContextData_BODY_ArenaMail(msg,data.body.arenaMail); -- 竞技场系统邮件
	end
	if (data.type==Proto.LCT_BOSSBATTLE_SYSTEM_MAIL) then
		Proto.writeLogContextData_BODY_BossBattleMail(msg,data.body.bossBattleMail); -- boss战系统邮件
	end
	if (data.type==Proto.LCT_TRAINING_SYSTEM_MAIL) then
		Proto.writeLogContextData_BODY_TrainingMail(msg,data.body.trainingMail); -- 训练场系统邮件
	end
	if (data.type==Proto.LCT_GM_SYSTEM_MAIL) then
		Proto.writeLogContextData_BODY_GMMail(msg,data.body.gmMail); -- GM系统邮件
	end
	if (data.type==Proto.LCT_EXCHANGEREWARD_SYSTEM_MAIL) then
		Proto.writeLogContextData_BODY_ExchangeRewardMail(msg,data.body.exchangeRewardMail); -- 兑换奖励
	end
	if (data.type==Proto.LCT_SINGLE_STAGE_BATTLE) then
		Proto.writeLogContextData_BODY_SingleStageBattle(msg,data.body.singleStageBattle); -- 宠物闯关
	end
	if (data.type==Proto.LCT_REMOVE_AUCTION_ITEM) then
		Proto.writeLogContextData_BODY_RemoveAuctionItem(msg,data.body.removeAuctionItem); -- 移除拍卖道具
	end
	if (data.type==Proto.LCT_PAY_AUCTION) then
		Proto.writeLogContextData_BODY_PayAuction(msg,data.body.payAuction); -- 支付拍卖道具
	end
	if (data.type==Proto.LCT_BUYITEM_AUCTION) then
		Proto.writeLogContextData_BODY_BuyItemAuction(msg,data.body.buyItemAuction); -- 购买拍卖道具
	end
	if (data.type==Proto.LCT_UNION_CREATE) then
		Proto.writeLogContextData_BODY_CreateUnion(msg,data.body.createUnion); -- 创建工会
	end
	if (data.type==Proto.LCT_RECHARGE) then
		Proto.writeLogContextData_BODY_Recharge(msg,data.body.recharge); -- 充值
	end
	if (data.type==Proto.LCT_AUCTION_EXCEED) then
		Proto.writeLogContextData_BODY_AuctionExceed(msg,data.body.auctionExceed); -- 拍卖行物品过期邮件
	end
	if (data.type==Proto.LCT_HEROSTAGE_RESET) then
		Proto.writeLogContextData_BODY_ResetHeroStage(msg,data.body.resetHeroStage); -- 重置英雄关卡
	end
	if (data.type==Proto.LCT_SINGLEBOSS_REWARD) then
		Proto.writeLogContextData_BODY_SingleBossReward(msg,data.body.singleBossReward); -- boss战单次奖励
	end
	if (data.type==Proto.LCT_MCASH_DRAWING) then
		Proto.writeLogContextData_BODY_McashDrawing(msg,data.body.mcashDrawing); -- M币抽奖
	end
	if (data.type==Proto.LCT_MCASH_ACTIVITY) then
		Proto.writeLogContextData_BODY_McashActivity(msg,data.body.mcashActivity); -- 活动奖励M币
	end
	if (data.type==Proto.LCT_BUY_PET_EXP) then
		Proto.writeLogContextData_BODY_BuyPetExp(msg,data.body.buyPetExp); -- 购买宠物经验
	end
	if (data.type==Proto.LCT_BUY_UNION_ITEM) then
		Proto.writeLogContextData_BODY_BuyUnionItem(msg,data.body.buyUnionItem); -- 购买工会道具
	end
	if (data.type==Proto.LCT_UNION_SAC) then
		Proto.writeLogContextData_BODY_UnionSacrifice(msg,data.body.unionSacrifice); -- 工会献祭
	end
	if (data.type==Proto.LCT_FIGHTACTIVITY) then
		Proto.writeLogContextData_BODY_FightActivity(msg,data.body.fightActivity); -- 万人斩活动
	end
	if (data.type==Proto.LCT_CONFRATERNITY_DRAWING) then
		Proto.writeLogContextData_BODY_ConfraternityDrawing(msg,data.body.confraternityDrawing); -- 工会抽奖
	end
	if (data.type==Proto.LCT_SYN_GENECOVER) then
		Proto.writeLogContextData_BODY_SynGeneCover(msg,data.body.synGeneCover); -- 技能书合成
	end
	if (data.type==Proto.LCT_GM_CHARGE_MCASH) then
		Proto.writeLogContextData_BODY_GMChargeMCash(msg,data.body.gmChargeMCash); -- GM充值
	end
	if (data.type==Proto.LCT_EXTEND_PET_DEPOTS_COUNT) then
		Proto.writeLogContextData_BODY_ExtendPetDepotsCount(msg,data.body.extendPetDepotsCount); -- 扩展宠物仓库
	end
	if (data.type==Proto.LCT_ARENA_BATTLE) then
		Proto.writeLogContextData_BODY_ArenaBattleCost(msg,data.body.arenaBattleCost); -- 竞技场挑战花费
	end
	if (data.type==Proto.LCT_DAILYTASK_AWARD) then
		Proto.writeLogContextData_BODY_DailyTaskAward(msg,data.body.dailyTaskAward); -- 竞技场挑战花费
	end
	if (data.type==Proto.LCT_MONOPOLY_AWARD) then
		Proto.writeLogContextData_BODY_MonopolyAward(msg,data.body.monopolyAward); -- 暴走收益
	end
	if (data.type==Proto.LCT_MONEY_TREE) then
		Proto.writeLogContextData_BODY_MoneyTree(msg,data.body.moneyTree); -- 摇钱树
	end
	if (data.type==Proto.LCT_SEND_ARENA_CHARM) then
		Proto.writeLogContextData_BODY_ArenaSendCharm(msg,data.body.arenaSendCharm); -- 竞技场赠送魅力
	end
	if (data.type==Proto.LCT_PET_RACE_ARENA_BATTLE) then
		Proto.writeLogContextData_BODY_PetRaceArenaBattleCost(msg,data.body.petRaceArenaBattleCost); -- 宠物单挑竞技场挑战花费
	end
	if (data.type==Proto.LCT_PET_AIDE_NATURE_LEVELUP) then
		Proto.writeLogContextData_BODY_PetaideNatureLevelUp(msg,data.body.petaideNatureLevelUp); -- 伴灵技能强化
	end
	if (data.type==Proto.LCT_PET_AIDE_EVOLUTION) then
		Proto.writeLogContextData_BODY_PetaideEvolution(msg,data.body.petaideEvolution); -- 伴灵进化
	end
	if (data.type==Proto.LCT_PET_AIDE_RESET_FEED_PROGRESS) then
		Proto.writeLogContextData_BODY_PetaideResetFeedProgress(msg,data.body.petaideResetFeedProgress); -- 伴灵清空饱食度
	end
	if (data.type==Proto.LCT_PET_AIDE_FEED) then
		Proto.writeLogContextData_BODY_PetaideFeed(msg,data.body.petaideFeed); -- 伴灵喂养
	end
	if (data.type==Proto.LCT_EQUIP_GENE) then
		Proto.writeLogContextData_BODY_EquipGeneCost(msg,data.body.equipGeneCost); -- 装备技能花费
	end
	if (data.type==Proto.LCT_CROSSWORLD_SYSTEM_MAIL) then
		Proto.writeLogContextData_BODY_CrossWorldMail(msg,data.body.crossWorldMail); -- 跨服战邮件奖励
	end
	if (data.type==Proto.LCT_CROSSWORLD_AWARD) then
		Proto.writeLogContextData_BODY_CrossWorldAward(msg,data.body.crossWorldAward); -- 跨服战膜拜奖励
	end
	if (data.type==Proto.LCT_DIFFINDUSTRY_AWARD) then
		Proto.writeLogContextData_BODY_DiffIndustryAward(msg,data.body.diffIndustryAward); -- 异业合作券
	end
	if (data.type==Proto.LCT_WEB_ACTIVITY) then
		Proto.writeLogContextData_BODY_WebActivityCost(msg,data.body.webActivityCost); -- 网页活动花费
	end
	if (data.type==Proto.LCT_CHANGE_PET_ASSIGNPOINTS) then
		Proto.writeLogContextData_BODY_ChangePetAssignPoints(msg,data.body.changePetAssignPoints); -- 修改宠物分配点
	end
	if (data.type==Proto.LCT_GM_MAIL) then
		Proto.writeLogContextData_BODY_GMSendMail(msg,data.body.gmSendMail); -- admintool发送邮件
	end
	if (data.type==Proto.LCT_GALLANTS_SYSTEM_MAIL) then
		Proto.writeLogContextData_BODY_GallantsMail(msg,data.body.gallantsMail); -- 擂台赛邮件件
	end
	if (data.type==Proto.LCT_PET_REDUCE_STRUGGLES) then
		Proto.writeLogContextData_BODY_PetReduceStruggles(msg,data.body.petReduceStruggles); -- 宠物减少努力值
	end
	if (data.type==Proto.LCT_GA_CHA_BURST) then
		Proto.writeLogContextData_BODY_GachaBurst(msg,data.body.gachaBurst); -- 扭蛋爆发
	end
	if (data.type==Proto.LCT_IMMOLATE_PET) then
		Proto.writeLogContextData_BODY_ImmolatePet(msg,data.body.immolatePet); -- 献祭
	end
	if (data.type==Proto.LCT_PET_INJECT_SOUL) then
		Proto.writeLogContextData_BODY_PetInjectSoul(msg,data.body.petInjectSoul); -- 宠物注入灵魂
	end
	if (data.type==Proto.LCT_EXPAND_SOUL_POOL) then
		Proto.writeLogContextData_BODY_ExpandSoulPool(msg,data.body.expandSoulPool); -- 扩充魂池
	end
	if (data.type==Proto.LCT_PET_TURN) then
		Proto.writeLogContextData_BODY_PetTurn(msg,data.body.petTurn); -- 宠物转生
	end
	if (data.type==Proto.LCT_CROSSWORLD_GAMBLE) then
		Proto.writeLogContextData_BODY_CrossWorldGamble(msg,data.body.crossWorldGamble); -- 跨服战赌博
	end
	if (data.type==Proto.LCT_CHALLENGE_BOSS_PAYMEDICINE) then
		Proto.writeLogContextData_BODY_ChallengeBossRebornPayMedicine(msg,data.body.challengeBossPayMedicine); -- 挑战boss付费药水
	end
	if (data.type==Proto.LCT_SEND_GIFT) then
		Proto.writeLogContextData_BODY_SendGift(msg,data.body.sendGift); -- 商场赠送道具
	end
	if (data.type==Proto.LCT_PET_REFRESH_SIXD_POINTS) then
		Proto.writeLogContextData_BODY_PetRefreshSixDPoints(msg,data.body.petRefreshSixDPoints); -- 刷新六维
	end
	if (data.type==Proto.LCT_FETCH_SIGN_DAILY_REWARD) then
		Proto.writeLogContextData_BODY_SignDailyReward(msg,data.body.signDailyAward); -- 每日签到领取奖励
	end
	if (data.type==Proto.LCT_GET_DIG_AWARD) then
		Proto.writeLogContextData_BODY_DigTreasureAward(msg,data.body.digTreasureAward); -- 挖宝获得奖励
	end
	if (data.type==Proto.LCT_GET_WEALTH_GOD_AWARD) then
		Proto.writeLogContextData_BODY_WealthGodAward(msg,data.body.wealthGodAward); -- 财神驾到获得奖励
	end
	if (data.type==Proto.LCT_RECHARGE_CONSUME_POINTS) then
		Proto.writeLogContextData_BODY_RechargeConsumePoints(msg,data.body.rechargeConsumePoints); -- 充值消费积分变化
	end
	if (data.type==Proto.LCT_RECHARGE_CONSUME_AWARD) then
		Proto.writeLogContextData_BODY_RechargeConsumeAward(msg,data.body.rechargeConsumeAward); -- 充值消费积分奖励
	end
	if (data.type==Proto.LCT_BUY_MONTH_CARD) then
		Proto.writeLogContextData_BODY_BuyMonthCard(msg,data.body.buyMonthCard); -- 购买月卡
	end
	if (data.type==Proto.LCT_TAKE_MONTH_CARD) then
		Proto.writeLogContextData_BODY_TakeMonthCard(msg,data.body.takeMonthCard); -- 领取月卡
	end
	if (data.type==Proto.LCT_BUY_ADVENTURE_RESET_TIMES) then
		Proto.writeLogContextData_BODY_BuyAdventureResetTimes(msg,data.body.buyAdventureResetTimes); -- 副本购买重置次数
	end
	if (data.type==Proto.LCT_BUY_ADVENTURE_REBORN_TIMES) then
		Proto.writeLogContextData_BODY_BuyAdventureRebornTimes(msg,data.body.buyAdventureRebornTimes); -- 副本购买重置次数
	end
	if (data.type==Proto.LCT_GET_STAR_SOUL_REWARD) then
		Proto.writeLogContextData_BODY_GetStarSoulReward(msg,data.body.getStarSoulReward); -- 领取星魂殿奖励
	end
	if (data.type==Proto.LCT_ADVENTURE_REWARD) then
		Proto.writeLogContextData_BODY_AdventureReward(msg,data.body.adventureReward); -- 副本奖励
	end
end

function Proto.parseLogData_BODY_ItemChange(entry)
	local data={};
	data.packetID=Proto.parseItemPacketID(entry); -- 背包ID
	data.item=Proto.parseItem(entry); -- 变化的道具
	data.changeNumber=Proto.parseint(entry); -- 改变数量
	return data;
end

function Proto.writeLogData_BODY_ItemChange(msg,data)
	Proto.writeItemPacketID(msg,data.packetID); -- 背包ID
	Proto.writeItem(msg,data.item); -- 变化的道具
	Proto.writeint(msg,data.changeNumber); -- 改变数量
end

function Proto.parseLogData_BODY_MoneyChange(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.moneyType=Proto.parseBYTE(entry); -- 金钱类型
	data.oldValue=Proto.parseDWORD(entry); -- 变化前数量
	data.newValue=Proto.parseDWORD(entry); -- 变化后数量
	return data;
end

function Proto.writeLogData_BODY_MoneyChange(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writeBYTE(msg,data.moneyType); -- 金钱类型
	Proto.writeDWORD(msg,data.oldValue); -- 变化前数量
	Proto.writeDWORD(msg,data.newValue); -- 变化后数量
end

function Proto.parseLogData_BODY_CharExpChange(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.oldValue=Proto.parseDWORD(entry); -- 变化前数量
	data.newValue=Proto.parseDWORD(entry); -- 变化后数量
	return data;
end

function Proto.writeLogData_BODY_CharExpChange(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writeDWORD(msg,data.oldValue); -- 变化前数量
	Proto.writeDWORD(msg,data.newValue); -- 变化后数量
end

function Proto.parseLogData_BODY_PetExpChange(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.petID=Proto.parsePetID(entry); -- 宠物ID
	data.oldValue=Proto.parseDWORD(entry); -- 变化前数量
	data.newValue=Proto.parseDWORD(entry); -- 变化后数量
	return data;
end

function Proto.writeLogData_BODY_PetExpChange(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writePetID(msg,data.petID); -- 宠物ID
	Proto.writeDWORD(msg,data.oldValue); -- 变化前数量
	Proto.writeDWORD(msg,data.newValue); -- 变化后数量
end

function Proto.parseLogData_BODY_CharMailChange(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.mailID=Proto.parseQWORD(entry); -- 邮件ID
	return data;
end

function Proto.writeLogData_BODY_CharMailChange(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writeQWORD(msg,data.mailID); -- 邮件ID
end

function Proto.parseLogData_BODY_PetPotentialChange(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.petID=Proto.parsePetID(entry); -- 宠物ID
	data.oldValue=Proto.parseBYTE(entry); -- 变化前值
	data.newValue=Proto.parseBYTE(entry); -- 变化后值
	return data;
end

function Proto.writeLogData_BODY_PetPotentialChange(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writePetID(msg,data.petID); -- 宠物ID
	Proto.writeBYTE(msg,data.oldValue); -- 变化前值
	Proto.writeBYTE(msg,data.newValue); -- 变化后值
end

function Proto.parseLogData_BODY_PetAttributeChange(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.petID=Proto.parsePetID(entry); -- 宠物ID
	data.attType=Proto.parseBYTE(entry); -- 属性类型
	data.oldValue=Proto.parseWORD(entry); -- 变化前数量
	data.newValue=Proto.parseWORD(entry); -- 变化后数量
	return data;
end

function Proto.writeLogData_BODY_PetAttributeChange(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writePetID(msg,data.petID); -- 宠物ID
	Proto.writeBYTE(msg,data.attType); -- 属性类型
	Proto.writeWORD(msg,data.oldValue); -- 变化前数量
	Proto.writeWORD(msg,data.newValue); -- 变化后数量
end

function Proto.parseLogData_BODY_PetNaturePotChange(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.petID=Proto.parsePetID(entry); -- 宠物ID
	data.oldValue=Proto.parseBYTE(entry); -- 变化前值
	data.newValue=Proto.parseBYTE(entry); -- 变化后值
	return data;
end

function Proto.writeLogData_BODY_PetNaturePotChange(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writePetID(msg,data.petID); -- 宠物ID
	Proto.writeBYTE(msg,data.oldValue); -- 变化前值
	Proto.writeBYTE(msg,data.newValue); -- 变化后值
end

function Proto.parseLogData_BODY_SystemMailChange(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.mailID=Proto.parseQWORD(entry); -- 邮件ID
	data.gCash=Proto.parseDWORD(entry); -- G币
	data.mCash=Proto.parseDWORD(entry); -- M币
	data.itemID=Proto.parseDWORD(entry); -- 道具ID
	data.count=Proto.parseWORD(entry); -- 数量
	return data;
end

function Proto.writeLogData_BODY_SystemMailChange(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writeQWORD(msg,data.mailID); -- 邮件ID
	Proto.writeDWORD(msg,data.gCash); -- G币
	Proto.writeDWORD(msg,data.mCash); -- M币
	Proto.writeDWORD(msg,data.itemID); -- 道具ID
	Proto.writeWORD(msg,data.count); -- 数量
end

function Proto.parseLogData_BODY_EquipGeneChange(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.itemType=Proto.parseDWORD(entry); -- 道具类型
	data.pumpSoulPoint=Proto.parseDWORD(entry); -- 魂值
	data.geneID=Proto.parseWORD(entry); -- 技能id
	data.geneLevel=Proto.parseWORD(entry); -- 技能等级
	return data;
end

function Proto.writeLogData_BODY_EquipGeneChange(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writeDWORD(msg,data.itemType); -- 道具类型
	Proto.writeDWORD(msg,data.pumpSoulPoint); -- 魂值
	Proto.writeWORD(msg,data.geneID); -- 技能id
	Proto.writeWORD(msg,data.geneLevel); -- 技能等级
end

function Proto.parseLogData_BODY_EquipGenePumpSoul(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.itemType=Proto.parseDWORD(entry); -- 道具类型
	data.geneID1=Proto.parseWORD(entry); -- 技能保留
	data.geneLevel1=Proto.parseWORD(entry); -- 技能等级1
	data.geneID2=Proto.parseWORD(entry); -- 技能替换
	data.geneLevel2=Proto.parseWORD(entry); -- 技能等级2
	data.geneID3=Proto.parseWORD(entry); -- 技能变异
	data.geneLevel3=Proto.parseWORD(entry); -- 技能等级3
	return data;
end

function Proto.writeLogData_BODY_EquipGenePumpSoul(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writeDWORD(msg,data.itemType); -- 道具类型
	Proto.writeWORD(msg,data.geneID1); -- 技能保留
	Proto.writeWORD(msg,data.geneLevel1); -- 技能等级1
	Proto.writeWORD(msg,data.geneID2); -- 技能替换
	Proto.writeWORD(msg,data.geneLevel2); -- 技能等级2
	Proto.writeWORD(msg,data.geneID3); -- 技能变异
	Proto.writeWORD(msg,data.geneLevel3); -- 技能等级3
end

function Proto.parseLogData_BODY_PetAssignPointChange(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.petID=Proto.parsePetID(entry); -- 宠物ID
	data.attType=Proto.parseBYTE(entry); -- 属性类型
	data.oldValue=Proto.parseint(entry); -- 变化前数量
	data.newValue=Proto.parseint(entry); -- 变化后数量
	return data;
end

function Proto.writeLogData_BODY_PetAssignPointChange(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writePetID(msg,data.petID); -- 宠物ID
	Proto.writeBYTE(msg,data.attType); -- 属性类型
	Proto.writeint(msg,data.oldValue); -- 变化前数量
	Proto.writeint(msg,data.newValue); -- 变化后数量
end

function Proto.parseLogData_BODY_GMSendMail(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.gCash=Proto.parseDWORD(entry); -- G币
	data.mCash=Proto.parseDWORD(entry); -- M币
	data.itemType=Proto.parseDWORD(entry); -- 道具类型
	data.count=Proto.parseDWORD(entry); -- 道具数量
	return data;
end

function Proto.writeLogData_BODY_GMSendMail(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writeDWORD(msg,data.gCash); -- G币
	Proto.writeDWORD(msg,data.mCash); -- M币
	Proto.writeDWORD(msg,data.itemType); -- 道具类型
	Proto.writeDWORD(msg,data.count); -- 道具数量
end

function Proto.parseLogData_BODY_PetReduceStruggles(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.petID=Proto.parsePetID(entry); -- 宠物ID
	data.petStruggle1=Proto.parseWORD(entry); -- 宠物努力值1
	data.petStruggle2=Proto.parseWORD(entry); -- 宠物努力值2
	data.petStruggle3=Proto.parseWORD(entry); -- 宠物努力值3
	data.petStruggle4=Proto.parseWORD(entry); -- 宠物努力值4
	data.petStruggle5=Proto.parseWORD(entry); -- 宠物努力值5
	data.petStruggle6=Proto.parseWORD(entry); -- 宠物努力值6
	data.petIntensifyCount=Proto.parseWORD(entry); -- 宠物潜力点
	return data;
end

function Proto.writeLogData_BODY_PetReduceStruggles(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writePetID(msg,data.petID); -- 宠物ID
	Proto.writeWORD(msg,data.petStruggle1); -- 宠物努力值1
	Proto.writeWORD(msg,data.petStruggle2); -- 宠物努力值2
	Proto.writeWORD(msg,data.petStruggle3); -- 宠物努力值3
	Proto.writeWORD(msg,data.petStruggle4); -- 宠物努力值4
	Proto.writeWORD(msg,data.petStruggle5); -- 宠物努力值5
	Proto.writeWORD(msg,data.petStruggle6); -- 宠物努力值6
	Proto.writeWORD(msg,data.petIntensifyCount); -- 宠物潜力点
end

function Proto.parseLogData_BODY_ImmolatePet(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.petID=Proto.parsePetID(entry); -- 宠物ID
	data.addPoint=Proto.parseDWORD(entry); -- 增加的点数
	return data;
end

function Proto.writeLogData_BODY_ImmolatePet(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writePetID(msg,data.petID); -- 宠物ID
	Proto.writeDWORD(msg,data.addPoint); -- 增加的点数
end

function Proto.parseLogData_BODY_PetChangeAffixSixDPoints(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.petID=Proto.parsePetID(entry); -- 宠物ID
	data.pointsType=Proto.parseBYTE(entry); -- 六维类型
	data.oldPoint1=Proto.parseint(entry); -- 原始值1
	data.oldPoint2=Proto.parseint(entry); -- 原始值2
	data.oldPoint3=Proto.parseint(entry); -- 原始值3
	data.oldPoint4=Proto.parseint(entry); -- 原始值4
	data.oldPoint5=Proto.parseint(entry); -- 原始值5
	data.oldPoint6=Proto.parseint(entry); -- 原始值6
	data.newPoint1=Proto.parseint(entry); -- 新值1
	data.newPoint2=Proto.parseint(entry); -- 新值2
	data.newPoint3=Proto.parseint(entry); -- 新值3
	data.newPoint4=Proto.parseint(entry); -- 新值4
	data.newPoint5=Proto.parseint(entry); -- 新值5
	data.newPoint6=Proto.parseint(entry); -- 新值6
	return data;
end

function Proto.writeLogData_BODY_PetChangeAffixSixDPoints(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writePetID(msg,data.petID); -- 宠物ID
	Proto.writeBYTE(msg,data.pointsType); -- 六维类型
	Proto.writeint(msg,data.oldPoint1); -- 原始值1
	Proto.writeint(msg,data.oldPoint2); -- 原始值2
	Proto.writeint(msg,data.oldPoint3); -- 原始值3
	Proto.writeint(msg,data.oldPoint4); -- 原始值4
	Proto.writeint(msg,data.oldPoint5); -- 原始值5
	Proto.writeint(msg,data.oldPoint6); -- 原始值6
	Proto.writeint(msg,data.newPoint1); -- 新值1
	Proto.writeint(msg,data.newPoint2); -- 新值2
	Proto.writeint(msg,data.newPoint3); -- 新值3
	Proto.writeint(msg,data.newPoint4); -- 新值4
	Proto.writeint(msg,data.newPoint5); -- 新值5
	Proto.writeint(msg,data.newPoint6); -- 新值6
end

function Proto.parseLogData_BODY_RechargeConsumePoints(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.activityID=Proto.parseDWORD(entry); -- 活动ID
	data.type=Proto.parseBYTE(entry); -- 充值或消费
	data.newValue=Proto.parseDWORD(entry); -- 最新数值
	return data;
end

function Proto.writeLogData_BODY_RechargeConsumePoints(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writeDWORD(msg,data.activityID); -- 活动ID
	Proto.writeBYTE(msg,data.type); -- 充值或消费
	Proto.writeDWORD(msg,data.newValue); -- 最新数值
end

function Proto.parseLogData(entry)
	local data={};
	data.type=Proto.parseBYTE(entry); -- 日志类型,
	data.body={}; -- 
	if (data.type==Proto.LT_ITEM_CHANGE) then
		data.body.itemChange=Proto.parseLogData_BODY_ItemChange(entry); -- 道具变化
	end
	if (data.type==Proto.LT_MONEY_CHANGE) then
		data.body.moneyChange=Proto.parseLogData_BODY_MoneyChange(entry); -- 金钱变化
	end
	if (data.type==Proto.LT_CHAR_EXP_CHANGE) then
		data.body.charExpChange=Proto.parseLogData_BODY_CharExpChange(entry); -- 人物经验变化
	end
	if (data.type==Proto.LT_PET_EXP_CHANGE) then
		data.body.petExpChange=Proto.parseLogData_BODY_PetExpChange(entry); -- 宠物经验变化
	end
	if (data.type==Proto.LT_CHAR_MAIL_CHANGE) then
		data.body.charMailChange=Proto.parseLogData_BODY_CharMailChange(entry); -- 人物邮件变化
	end
	if (data.type==Proto.LT_PET_POT_CHANGE) then
		data.body.petPotentialChange=Proto.parseLogData_BODY_PetPotentialChange(entry); -- 宠物潜力点变化
	end
	if (data.type==Proto.LT_PET_ATT_CHANGE) then
		data.body.petAttributeChange=Proto.parseLogData_BODY_PetAttributeChange(entry); -- 宠物属性变化
	end
	if (data.type==Proto.LT_PET_NATPOT_CHANGE) then
		data.body.petNaturePotChange=Proto.parseLogData_BODY_PetNaturePotChange(entry); -- 宠物初始潜力点变化
	end
	if (data.type==Proto.LT_SYSTEM_MAIL_CHANGE) then
		data.body.systemMailChange=Proto.parseLogData_BODY_SystemMailChange(entry); -- 系统邮件变化
	end
	if (data.type==Proto.LT_EQUIP_GENE_CHANGE) then
		data.body.equipGeneChange=Proto.parseLogData_BODY_EquipGeneChange(entry); -- 装备技能变化
	end
	if (data.type==Proto.LT_EQUIP_PUMP_SOUL) then
		data.body.equipGenePumpSoul=Proto.parseLogData_BODY_EquipGenePumpSoul(entry); -- 装备技能抽魂变化
	end
	if (data.type==Proto.LT_PET_ASSIGN_POINT_CHANGE) then
		data.body.petAssignPointChange=Proto.parseLogData_BODY_PetAssignPointChange(entry); -- 宠物分配点变化
	end
	if (data.type==Proto.LT_GM_SEND_MAIL) then
		data.body.gmSendMail=Proto.parseLogData_BODY_GMSendMail(entry); -- gm发送邮件
	end
	if (data.type==Proto.LT_PET_REDUCE_STRUGGLES) then
		data.body.petReduceStruggles=Proto.parseLogData_BODY_PetReduceStruggles(entry); -- 宠物减少努力值
	end
	if (data.type==Proto.LT_IMMOLATE_PET) then
		data.body.immolatePet=Proto.parseLogData_BODY_ImmolatePet(entry); -- 献祭
	end
	if (data.type==Proto.LT_PET_CHANGE_AFFIX_SIXD_POINTS) then
		data.body.petChangeAffixSixDPoints=Proto.parseLogData_BODY_PetChangeAffixSixDPoints(entry); -- 更新宠物附加六维
	end
	if (data.type==Proto.LT_RECHARGE_CONSUME_POINTS) then
		data.body.rechargeConsumePoints=Proto.parseLogData_BODY_RechargeConsumePoints(entry); -- 充值消费积分变化
	end
	return data;
end

function Proto.writeLogData(msg,data)
	Proto.writeBYTE(msg,data.type); -- 日志类型,
	if (data.type==Proto.LT_ITEM_CHANGE) then
		Proto.writeLogData_BODY_ItemChange(msg,data.body.itemChange); -- 道具变化
	end
	if (data.type==Proto.LT_MONEY_CHANGE) then
		Proto.writeLogData_BODY_MoneyChange(msg,data.body.moneyChange); -- 金钱变化
	end
	if (data.type==Proto.LT_CHAR_EXP_CHANGE) then
		Proto.writeLogData_BODY_CharExpChange(msg,data.body.charExpChange); -- 人物经验变化
	end
	if (data.type==Proto.LT_PET_EXP_CHANGE) then
		Proto.writeLogData_BODY_PetExpChange(msg,data.body.petExpChange); -- 宠物经验变化
	end
	if (data.type==Proto.LT_CHAR_MAIL_CHANGE) then
		Proto.writeLogData_BODY_CharMailChange(msg,data.body.charMailChange); -- 人物邮件变化
	end
	if (data.type==Proto.LT_PET_POT_CHANGE) then
		Proto.writeLogData_BODY_PetPotentialChange(msg,data.body.petPotentialChange); -- 宠物潜力点变化
	end
	if (data.type==Proto.LT_PET_ATT_CHANGE) then
		Proto.writeLogData_BODY_PetAttributeChange(msg,data.body.petAttributeChange); -- 宠物属性变化
	end
	if (data.type==Proto.LT_PET_NATPOT_CHANGE) then
		Proto.writeLogData_BODY_PetNaturePotChange(msg,data.body.petNaturePotChange); -- 宠物初始潜力点变化
	end
	if (data.type==Proto.LT_SYSTEM_MAIL_CHANGE) then
		Proto.writeLogData_BODY_SystemMailChange(msg,data.body.systemMailChange); -- 系统邮件变化
	end
	if (data.type==Proto.LT_EQUIP_GENE_CHANGE) then
		Proto.writeLogData_BODY_EquipGeneChange(msg,data.body.equipGeneChange); -- 装备技能变化
	end
	if (data.type==Proto.LT_EQUIP_PUMP_SOUL) then
		Proto.writeLogData_BODY_EquipGenePumpSoul(msg,data.body.equipGenePumpSoul); -- 装备技能抽魂变化
	end
	if (data.type==Proto.LT_PET_ASSIGN_POINT_CHANGE) then
		Proto.writeLogData_BODY_PetAssignPointChange(msg,data.body.petAssignPointChange); -- 宠物分配点变化
	end
	if (data.type==Proto.LT_GM_SEND_MAIL) then
		Proto.writeLogData_BODY_GMSendMail(msg,data.body.gmSendMail); -- gm发送邮件
	end
	if (data.type==Proto.LT_PET_REDUCE_STRUGGLES) then
		Proto.writeLogData_BODY_PetReduceStruggles(msg,data.body.petReduceStruggles); -- 宠物减少努力值
	end
	if (data.type==Proto.LT_IMMOLATE_PET) then
		Proto.writeLogData_BODY_ImmolatePet(msg,data.body.immolatePet); -- 献祭
	end
	if (data.type==Proto.LT_PET_CHANGE_AFFIX_SIXD_POINTS) then
		Proto.writeLogData_BODY_PetChangeAffixSixDPoints(msg,data.body.petChangeAffixSixDPoints); -- 更新宠物附加六维
	end
	if (data.type==Proto.LT_RECHARGE_CONSUME_POINTS) then
		Proto.writeLogData_BODY_RechargeConsumePoints(msg,data.body.rechargeConsumePoints); -- 充值消费积分变化
	end
end

