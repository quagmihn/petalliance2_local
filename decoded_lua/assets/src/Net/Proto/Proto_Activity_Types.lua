-- Net.Proto.Proto_Activity_Types

Proto.ACT_UPGRADE						= 0											-- [活动类型]升级
Proto.ACT_CLIENT						= Proto.ACT_UPGRADE + 1						-- [活动类型]客户端自定义
Proto.ACT_SIGN							= Proto.ACT_CLIENT + 1						-- [活动类型]签到
Proto.ACT_LOGIN							= Proto.ACT_SIGN + 1						-- [活动类型]登录
Proto.ACT_DAILY_CONSUME					= Proto.ACT_LOGIN + 1						-- [活动类型]每日消费
Proto.ACT_GROUP_PURCHASE				= Proto.ACT_DAILY_CONSUME + 1				-- [活动类型]团购
Proto.ACT_GROWTH_FUND					= Proto.ACT_GROUP_PURCHASE + 1				-- [活动类型]成长基金
Proto.ACT_LUCKY_DRAW					= Proto.ACT_GROWTH_FUND + 1					-- [活动类型]幸运抽奖
Proto.ACT_DOUBLE_EXP_INSTANCE			= Proto.ACT_LUCKY_DRAW + 1					-- [活动类型]副本经验双倍
Proto.ACT_DAILY_GIFT					= Proto.ACT_DOUBLE_EXP_INSTANCE + 1			-- [活动类型]每日礼包
Proto.ACT_FIRST_LOGIN					= Proto.ACT_DAILY_GIFT + 1					-- [活动类型]首次登陆
Proto.ACT_DAILY_ACTION_VALUE			= Proto.ACT_FIRST_LOGIN + 1					-- [活动类型]每天领体力
Proto.ACT_RECHARGE						= Proto.ACT_DAILY_ACTION_VALUE + 1			-- [活动类型]充值
Proto.ACT_CONSUME						= Proto.ACT_RECHARGE + 1					-- [活动类型]消费
Proto.ACT_PAY_RETURN					= Proto.ACT_CONSUME + 1						-- [活动类型]封测返利
Proto.ACT_LEVEL_RETURN					= Proto.ACT_PAY_RETURN + 1					-- [活动类型]封测发奖
Proto.ACT_SPOKESMANGUESS				= Proto.ACT_LEVEL_RETURN + 1				-- [活动类型]代言人猜想
Proto.ACT_LUOTIANYI						= Proto.ACT_SPOKESMANGUESS + 1				-- [活动类型]洛天依积分
Proto.ACT_TL_CAPSULEEGG					= Proto.ACT_LUOTIANYI + 1					-- [活动类型]限时扭蛋
Proto.ACT_LOSTTOWER						= Proto.ACT_TL_CAPSULEEGG + 1				-- [活动类型]千层塔
Proto.ACT_PVPARENAGRADEPOINT			= Proto.ACT_LOSTTOWER + 1					-- [活动类型]大联盟赛
Proto.ACT_TEAMDUNGEON					= Proto.ACT_PVPARENAGRADEPOINT + 1			-- [活动类型]组队副本
Proto.ACT_POKEMONACHIEVEMENTACTIVITY	= Proto.ACT_TEAMDUNGEON + 1					-- [活动类型]宠物成就
Proto.ACT_WORLDBOSS						= Proto.ACT_POKEMONACHIEVEMENTACTIVITY + 1	-- [活动类型]世界BOSS
Proto.ACT_CONTINUELOGIN					= Proto.ACT_WORLDBOSS + 1					-- [活动类型]连续登陆
Proto.ACT_BOSSCOMBO						= Proto.ACT_CONTINUELOGIN + 1				-- [活动类型]连击Boss
Proto.ACT_BOSSATTACKCOUNT				= Proto.ACT_BOSSCOMBO + 1					-- [活动类型]攻击Boss次数
Proto.ACT_BOSSKILLTIME					= Proto.ACT_BOSSATTACKCOUNT + 1				-- [活动类型]击杀Boss时间
Proto.ACT_LIFESKILL						= Proto.ACT_BOSSKILLTIME + 1				-- [活动类型]生活技能活动
Proto.ACT_BUYACTIONVALUEADDCATCHRATE	= Proto.ACT_LIFESKILL + 1					-- [活动类型]买体力送捉宠加成活动
Proto.ACT_SURVIVALBATTLE				= Proto.ACT_BUYACTIONVALUEADDCATCHRATE + 1	-- [活动类型]生存战
Proto.ACT_ACTIVITYSHOP					= Proto.ACT_SURVIVALBATTLE + 1				-- [活动类型]活动商店
Proto.ACT_SURVIVALBATTLEFLOOR			= Proto.ACT_ACTIVITYSHOP + 1				-- [活动类型]生存战层数
Proto.ACT_PVPARENA						= Proto.ACT_SURVIVALBATTLEFLOOR + 1			-- [活动类型]大联盟赛参与
Proto.ACT_EXPEDITIONCLEAR				= Proto.ACT_PVPARENA + 1					-- [活动类型]远征通关
Proto.ACT_EXPEDITIONJOIN				= Proto.ACT_EXPEDITIONCLEAR + 1				-- [活动类型]远征参与
Proto.ACT_EXPEDITIONWIN					= Proto.ACT_EXPEDITIONJOIN + 1				-- [活动类型]远征过关
Proto.ACT_LOSTTOWERDOUBLES				= Proto.ACT_EXPEDITIONWIN + 1				-- [活动类型]千层塔双S

function Proto.parseActivityAward(entry)
	local data={};
	data.type=Proto.parseDWORD(entry); -- 奖励元素类型
	data.num=Proto.parseDWORD(entry); -- 奖励元素数量
	return data;
end

function Proto.writeActivityAward(msg,data)
	Proto.writeDWORD(msg,data.type); -- 奖励元素类型
	Proto.writeDWORD(msg,data.num); -- 奖励元素数量
end

function Proto.parseDailyActionValueItem(entry)
	local data={};
	data.startTime=Proto.parseDWORD(entry); -- 起始时间（秒）
	data.endTime=Proto.parseDWORD(entry); -- 结束时间（秒）
	data.num=Proto.parseWORD(entry); -- 可以领取的体力值
	return data;
end

function Proto.writeDailyActionValueItem(msg,data)
	Proto.writeDWORD(msg,data.startTime); -- 起始时间（秒）
	Proto.writeDWORD(msg,data.endTime); -- 结束时间（秒）
	Proto.writeWORD(msg,data.num); -- 可以领取的体力值
end

function Proto.parseLosTowerActionValueItem(entry)
	local data={};
	data.day=Proto.parseDWORD(entry); -- 星期几
	data.startTime=Proto.parseDWORD(entry); -- 起始时间（秒）
	data.endTime=Proto.parseDWORD(entry); -- 结束时间（秒）
	return data;
end

function Proto.writeLosTowerActionValueItem(msg,data)
	Proto.writeDWORD(msg,data.day); -- 星期几
	Proto.writeDWORD(msg,data.startTime); -- 起始时间（秒）
	Proto.writeDWORD(msg,data.endTime); -- 结束时间（秒）
end

function Proto.parseUpgradeActivityInfo(entry)
	local data={};
	data.seconds=Proto.parseint(entry); -- 时间
	data.mLevel=Proto.parseint(entry); -- 境界
	data.awards=Proto.parseVarArray(entry,Proto.parseActivityAward,Proto.parseWORD); -- 奖励
	return data;
end

function Proto.writeUpgradeActivityInfo(msg,data)
	Proto.writeint(msg,data.seconds); -- 时间
	Proto.writeint(msg,data.mLevel); -- 境界
	Proto.writeVarArray(msg,data.awards,Proto.writeActivityAward,Proto.writeWORD); -- 奖励
end

function Proto.parseDailyConsumeActivityInfo(entry)
	local data={};
	data.mCash=Proto.parseint(entry); -- 累计M币
	data.awards=Proto.parseVarArray(entry,Proto.parseActivityAward,Proto.parseWORD); -- 奖励
	return data;
end

function Proto.writeDailyConsumeActivityInfo(msg,data)
	Proto.writeint(msg,data.mCash); -- 累计M币
	Proto.writeVarArray(msg,data.awards,Proto.writeActivityAward,Proto.writeWORD); -- 奖励
end

function Proto.parseRechargeActivityInfo(entry)
	local data={};
	data.mCash=Proto.parseint(entry); -- M币
	data.awards=Proto.parseVarArray(entry,Proto.parseActivityAward,Proto.parseWORD); -- 奖励
	data.days=Proto.parseDWORD(entry); -- 限时（天）
	return data;
end

function Proto.writeRechargeActivityInfo(msg,data)
	Proto.writeint(msg,data.mCash); -- M币
	Proto.writeVarArray(msg,data.awards,Proto.writeActivityAward,Proto.writeWORD); -- 奖励
	Proto.writeDWORD(msg,data.days); -- 限时（天）
end

function Proto.parseConsumeActivityInfo(entry)
	local data={};
	data.mCash=Proto.parseint(entry); -- M币
	data.awards=Proto.parseVarArray(entry,Proto.parseActivityAward,Proto.parseWORD); -- 奖励
	data.days=Proto.parseDWORD(entry); -- 限时（天）
	return data;
end

function Proto.writeConsumeActivityInfo(msg,data)
	Proto.writeint(msg,data.mCash); -- M币
	Proto.writeVarArray(msg,data.awards,Proto.writeActivityAward,Proto.writeWORD); -- 奖励
	Proto.writeDWORD(msg,data.days); -- 限时（天）
end

function Proto.parseSignActivityInfo(entry)
	local data={};
	data.awards=Proto.parseVarArray(entry,Proto.parseActivityAward,Proto.parseWORD); -- 奖励
	data.days=Proto.parseDWORD(entry); -- 累计天数
	return data;
end

function Proto.writeSignActivityInfo(msg,data)
	Proto.writeVarArray(msg,data.awards,Proto.writeActivityAward,Proto.writeWORD); -- 奖励
	Proto.writeDWORD(msg,data.days); -- 累计天数
end

function Proto.parseLoginActivityInfo(entry)
	local data={};
	data.awards=Proto.parseVarArray(entry,Proto.parseActivityAward,Proto.parseWORD); -- 奖励
	data.days=Proto.parseDWORD(entry); -- 累计天数
	return data;
end

function Proto.writeLoginActivityInfo(msg,data)
	Proto.writeVarArray(msg,data.awards,Proto.writeActivityAward,Proto.writeWORD); -- 奖励
	Proto.writeDWORD(msg,data.days); -- 累计天数
end

function Proto.parseDoubleExpInstanceActivityInfo(entry)
	local data={};
	data.hourStart=Proto.parseint(entry); -- 开始小时数
	data.hourEnd=Proto.parseint(entry); -- 结束小时数
	return data;
end

function Proto.writeDoubleExpInstanceActivityInfo(msg,data)
	Proto.writeint(msg,data.hourStart); -- 开始小时数
	Proto.writeint(msg,data.hourEnd); -- 结束小时数
end

function Proto.parseGroupPurchaseActivityInfo(entry)
	local data={};
	data.count=Proto.parseint(entry); -- 数量
	data.awards=Proto.parseVarArray(entry,Proto.parseActivityAward,Proto.parseWORD); -- 奖励
	return data;
end

function Proto.writeGroupPurchaseActivityInfo(msg,data)
	Proto.writeint(msg,data.count); -- 数量
	Proto.writeVarArray(msg,data.awards,Proto.writeActivityAward,Proto.writeWORD); -- 奖励
end

function Proto.parseCountActivityAwardInfo(entry)
	local data={};
	data.count=Proto.parseint(entry); -- 数量
	data.awards=Proto.parseVarArray(entry,Proto.parseActivityAward,Proto.parseWORD); -- 奖励
	return data;
end

function Proto.writeCountActivityAwardInfo(msg,data)
	Proto.writeint(msg,data.count); -- 数量
	Proto.writeVarArray(msg,data.awards,Proto.writeActivityAward,Proto.writeWORD); -- 奖励
end

function Proto.parseTypeCountActivityAwardInfo(entry)
	local data={};
	data.countType=Proto.parseint(entry); -- 计数类型
	data.count=Proto.parseint(entry); -- 数量
	data.awards=Proto.parseVarArray(entry,Proto.parseActivityAward,Proto.parseWORD); -- 奖励
	return data;
end

function Proto.writeTypeCountActivityAwardInfo(msg,data)
	Proto.writeint(msg,data.countType); -- 计数类型
	Proto.writeint(msg,data.count); -- 数量
	Proto.writeVarArray(msg,data.awards,Proto.writeActivityAward,Proto.writeWORD); -- 奖励
end

function Proto.parseGrowthFundActivityInfo(entry)
	local data={};
	data.mLevel=Proto.parseint(entry); -- 等级
	data.awards=Proto.parseVarArray(entry,Proto.parseActivityAward,Proto.parseWORD); -- 奖励
	return data;
end

function Proto.writeGrowthFundActivityInfo(msg,data)
	Proto.writeint(msg,data.mLevel); -- 等级
	Proto.writeVarArray(msg,data.awards,Proto.writeActivityAward,Proto.writeWORD); -- 奖励
end

function Proto.parseLuckyDrawActivityInfo(entry)
	local data={};
	data.mCash=Proto.parseint(entry); -- M币
	data.awards=Proto.parseVarArray(entry,Proto.parseint,Proto.parseWORD); -- 奖励
	return data;
end

function Proto.writeLuckyDrawActivityInfo(msg,data)
	Proto.writeint(msg,data.mCash); -- M币
	Proto.writeVarArray(msg,data.awards,Proto.writeint,Proto.writeWORD); -- 奖励
end

function Proto.parseDailyGiftActivityInfo(entry)
	local data={};
	data.mCash=Proto.parseint(entry); -- M币
	data.time=Proto.parseZoic_StringForUnion_50_(entry); -- 礼包日期
	data.awards=Proto.parseVarArray(entry,Proto.parseActivityAward,Proto.parseWORD); -- 奖励
	return data;
end

function Proto.writeDailyGiftActivityInfo(msg,data)
	Proto.writeint(msg,data.mCash); -- M币
	Proto.writeZoic_StringForUnion_50_(msg,data.time); -- 礼包日期
	Proto.writeVarArray(msg,data.awards,Proto.writeActivityAward,Proto.writeWORD); -- 奖励
end

function Proto.parseRefiningPiecesActivityInfo(entry)
	local data={};
	data.awards=Proto.parseVarArray(entry,Proto.parseActivityAward,Proto.parseWORD); -- 奖励
	data.count=Proto.parseint(entry); -- 次数
	return data;
end

function Proto.writeRefiningPiecesActivityInfo(msg,data)
	Proto.writeVarArray(msg,data.awards,Proto.writeActivityAward,Proto.writeWORD); -- 奖励
	Proto.writeint(msg,data.count); -- 次数
end

function Proto.parseFirstLoginActivityInfo(entry)
	local data={};
	data.awards=Proto.parseVarArray(entry,Proto.parseActivityAward,Proto.parseWORD); -- 奖励
	return data;
end

function Proto.writeFirstLoginActivityInfo(msg,data)
	Proto.writeVarArray(msg,data.awards,Proto.writeActivityAward,Proto.writeWORD); -- 奖励
end

function Proto.parseSpokesmanGuessActivityInfo(entry)
	local data={};
	data.progress=Proto.parseDWORD(entry); -- 进度
	data.awards=Proto.parseVarArray(entry,Proto.parseActivityAward,Proto.parseWORD); -- 奖励
	return data;
end

function Proto.writeSpokesmanGuessActivityInfo(msg,data)
	Proto.writeDWORD(msg,data.progress); -- 进度
	Proto.writeVarArray(msg,data.awards,Proto.writeActivityAward,Proto.writeWORD); -- 奖励
end

function Proto.parseLuoTianyiActivityInfo(entry)
	local data={};
	data.rank=Proto.parseDWORD(entry); -- 排名
	data.awards=Proto.parseVarArray(entry,Proto.parseActivityAward,Proto.parseWORD); -- 奖励
	return data;
end

function Proto.writeLuoTianyiActivityInfo(msg,data)
	Proto.writeDWORD(msg,data.rank); -- 排名
	Proto.writeVarArray(msg,data.awards,Proto.writeActivityAward,Proto.writeWORD); -- 奖励
end

function Proto.parseTimeLimitCapsuleEggActivityInfo(entry)
	local data={};
	data.type=Proto.parseBYTE(entry); -- 扭蛋类型
	data.costType=Proto.parseBYTE(entry); -- 消耗类型,1钻石，2金币
	data.cost=Proto.parseDWORD(entry); -- 消耗值
	data.awardNormal=Proto.parseDWORD(entry); -- 普通奖池
	data.awardSepcial=Proto.parseDWORD(entry); -- 保底奖池
	return data;
end

function Proto.writeTimeLimitCapsuleEggActivityInfo(msg,data)
	Proto.writeBYTE(msg,data.type); -- 扭蛋类型
	Proto.writeBYTE(msg,data.costType); -- 消耗类型,1钻石，2金币
	Proto.writeDWORD(msg,data.cost); -- 消耗值
	Proto.writeDWORD(msg,data.awardNormal); -- 普通奖池
	Proto.writeDWORD(msg,data.awardSepcial); -- 保底奖池
end

function Proto.parseLostTowerDoubleS(entry)
	local data={};
	data.day=Proto.parseDWORD(entry); -- 星期几
	data.startTime=Proto.parseDWORD(entry); -- 开始时间
	data.endTime=Proto.parseDWORD(entry); -- 结束时间
	return data;
end

function Proto.writeLostTowerDoubleS(msg,data)
	Proto.writeDWORD(msg,data.day); -- 星期几
	Proto.writeDWORD(msg,data.startTime); -- 开始时间
	Proto.writeDWORD(msg,data.endTime); -- 结束时间
end

function Proto.parseActivityInfo_BODY_Upgrade(entry)
	local data={};
	data.infos=Proto.parseVarArray(entry,Proto.parseUpgradeActivityInfo,Proto.parseWORD); -- 升级表
	return data;
end

function Proto.writeActivityInfo_BODY_Upgrade(msg,data)
	Proto.writeVarArray(msg,data.infos,Proto.writeUpgradeActivityInfo,Proto.writeWORD); -- 升级表
end

function Proto.parseActivityInfo_BODY_Sign(entry)
	local data={};
	data.infos=Proto.parseVarArray(entry,Proto.parseSignActivityInfo,Proto.parseWORD); -- 签到表
	return data;
end

function Proto.writeActivityInfo_BODY_Sign(msg,data)
	Proto.writeVarArray(msg,data.infos,Proto.writeSignActivityInfo,Proto.writeWORD); -- 签到表
end

function Proto.parseActivityInfo_BODY_Login(entry)
	local data={};
	data.infos=Proto.parseVarArray(entry,Proto.parseLoginActivityInfo,Proto.parseWORD); -- 登录表
	return data;
end

function Proto.writeActivityInfo_BODY_Login(msg,data)
	Proto.writeVarArray(msg,data.infos,Proto.writeLoginActivityInfo,Proto.writeWORD); -- 登录表
end

function Proto.parseActivityInfo_BODY_DailyConsume(entry)
	local data={};
	data.infos=Proto.parseVarArray(entry,Proto.parseDailyConsumeActivityInfo,Proto.parseWORD); -- 每日消费表
	return data;
end

function Proto.writeActivityInfo_BODY_DailyConsume(msg,data)
	Proto.writeVarArray(msg,data.infos,Proto.writeDailyConsumeActivityInfo,Proto.writeWORD); -- 每日消费表
end

function Proto.parseActivityInfo_BODY_BossCombo(entry)
	local data={};
	data.infos=Proto.parseVarArray(entry,Proto.parseCountActivityAwardInfo,Proto.parseWORD); -- 
	return data;
end

function Proto.writeActivityInfo_BODY_BossCombo(msg,data)
	Proto.writeVarArray(msg,data.infos,Proto.writeCountActivityAwardInfo,Proto.writeWORD); -- 
end

function Proto.parseActivityInfo_BODY_PvpArena(entry)
	local data={};
	data.infos=Proto.parseVarArray(entry,Proto.parseCountActivityAwardInfo,Proto.parseWORD); -- 
	return data;
end

function Proto.writeActivityInfo_BODY_PvpArena(msg,data)
	Proto.writeVarArray(msg,data.infos,Proto.writeCountActivityAwardInfo,Proto.writeWORD); -- 
end

function Proto.parseActivityInfo_BODY_SurvivalBattleFloor(entry)
	local data={};
	data.infos=Proto.parseVarArray(entry,Proto.parseCountActivityAwardInfo,Proto.parseWORD); -- 
	return data;
end

function Proto.writeActivityInfo_BODY_SurvivalBattleFloor(msg,data)
	Proto.writeVarArray(msg,data.infos,Proto.writeCountActivityAwardInfo,Proto.writeWORD); -- 
end

function Proto.parseActivityInfo_BODY_ExpeditionClear(entry)
	local data={};
	data.infos=Proto.parseVarArray(entry,Proto.parseCountActivityAwardInfo,Proto.parseWORD); -- 
	return data;
end

function Proto.writeActivityInfo_BODY_ExpeditionClear(msg,data)
	Proto.writeVarArray(msg,data.infos,Proto.writeCountActivityAwardInfo,Proto.writeWORD); -- 
end

function Proto.parseActivityInfo_BODY_ExpeditionJoin(entry)
	local data={};
	data.infos=Proto.parseVarArray(entry,Proto.parseCountActivityAwardInfo,Proto.parseWORD); -- 
	return data;
end

function Proto.writeActivityInfo_BODY_ExpeditionJoin(msg,data)
	Proto.writeVarArray(msg,data.infos,Proto.writeCountActivityAwardInfo,Proto.writeWORD); -- 
end

function Proto.parseActivityInfo_BODY_ExpeditionWin(entry)
	local data={};
	data.infos=Proto.parseVarArray(entry,Proto.parseCountActivityAwardInfo,Proto.parseWORD); -- 
	return data;
end

function Proto.writeActivityInfo_BODY_ExpeditionWin(msg,data)
	Proto.writeVarArray(msg,data.infos,Proto.writeCountActivityAwardInfo,Proto.writeWORD); -- 
end

function Proto.parseActivityInfo_BODY_BossAttackCount(entry)
	local data={};
	data.infos=Proto.parseVarArray(entry,Proto.parseCountActivityAwardInfo,Proto.parseWORD); -- 
	return data;
end

function Proto.writeActivityInfo_BODY_BossAttackCount(msg,data)
	Proto.writeVarArray(msg,data.infos,Proto.writeCountActivityAwardInfo,Proto.writeWORD); -- 
end

function Proto.parseActivityInfo_BODY_BossKillTime(entry)
	local data={};
	data.infos=Proto.parseVarArray(entry,Proto.parseCountActivityAwardInfo,Proto.parseWORD); -- 
	return data;
end

function Proto.writeActivityInfo_BODY_BossKillTime(msg,data)
	Proto.writeVarArray(msg,data.infos,Proto.writeCountActivityAwardInfo,Proto.writeWORD); -- 
end

function Proto.parseActivityInfo_BODY_LifeSkill(entry)
	local data={};
	data.infos=Proto.parseVarArray(entry,Proto.parseTypeCountActivityAwardInfo,Proto.parseWORD); -- 
	return data;
end

function Proto.writeActivityInfo_BODY_LifeSkill(msg,data)
	Proto.writeVarArray(msg,data.infos,Proto.writeTypeCountActivityAwardInfo,Proto.writeWORD); -- 
end

function Proto.parseActivityInfo_BODY_GroupPurchase(entry)
	local data={};
	data.vipLevel=Proto.parseint(entry); -- VIP等级
	data.mCash=Proto.parseint(entry); -- M币
	data.awards=Proto.parseVarArray(entry,Proto.parseActivityAward,Proto.parseWORD); -- 奖励
	data.infos=Proto.parseVarArray(entry,Proto.parseGroupPurchaseActivityInfo,Proto.parseWORD); -- 团购表
	return data;
end

function Proto.writeActivityInfo_BODY_GroupPurchase(msg,data)
	Proto.writeint(msg,data.vipLevel); -- VIP等级
	Proto.writeint(msg,data.mCash); -- M币
	Proto.writeVarArray(msg,data.awards,Proto.writeActivityAward,Proto.writeWORD); -- 奖励
	Proto.writeVarArray(msg,data.infos,Proto.writeGroupPurchaseActivityInfo,Proto.writeWORD); -- 团购表
end

function Proto.parseActivityInfo_BODY_GrowthFund(entry)
	local data={};
	data.vipLevel=Proto.parseint(entry); -- VIP等级
	data.mCash=Proto.parseint(entry); -- M币
	data.awards=Proto.parseVarArray(entry,Proto.parseActivityAward,Proto.parseWORD); -- 奖励
	data.infos=Proto.parseVarArray(entry,Proto.parseGrowthFundActivityInfo,Proto.parseWORD); -- 成长基金
	return data;
end

function Proto.writeActivityInfo_BODY_GrowthFund(msg,data)
	Proto.writeint(msg,data.vipLevel); -- VIP等级
	Proto.writeint(msg,data.mCash); -- M币
	Proto.writeVarArray(msg,data.awards,Proto.writeActivityAward,Proto.writeWORD); -- 奖励
	Proto.writeVarArray(msg,data.infos,Proto.writeGrowthFundActivityInfo,Proto.writeWORD); -- 成长基金
end

function Proto.parseActivityInfo_BODY_LuckyDraw(entry)
	local data={};
	data.infos=Proto.parseVarArray(entry,Proto.parseLuckyDrawActivityInfo,Proto.parseWORD); -- 幸运抽奖表
	return data;
end

function Proto.writeActivityInfo_BODY_LuckyDraw(msg,data)
	Proto.writeVarArray(msg,data.infos,Proto.writeLuckyDrawActivityInfo,Proto.writeWORD); -- 幸运抽奖表
end

function Proto.parseActivityInfo_BODY_DoubleExpInstance(entry)
	local data={};
	data.infos=Proto.parseVarArray(entry,Proto.parseDoubleExpInstanceActivityInfo,Proto.parseWORD); -- 双倍副本经验表
	return data;
end

function Proto.writeActivityInfo_BODY_DoubleExpInstance(msg,data)
	Proto.writeVarArray(msg,data.infos,Proto.writeDoubleExpInstanceActivityInfo,Proto.writeWORD); -- 双倍副本经验表
end

function Proto.parseActivityInfo_BODY_DailyGift(entry)
	local data={};
	data.infos=Proto.parseVarArray(entry,Proto.parseDailyGiftActivityInfo,Proto.parseWORD); -- 每日礼包表
	return data;
end

function Proto.writeActivityInfo_BODY_DailyGift(msg,data)
	Proto.writeVarArray(msg,data.infos,Proto.writeDailyGiftActivityInfo,Proto.writeWORD); -- 每日礼包表
end

function Proto.parseActivityInfo_BODY_DailyActionValue(entry)
	local data={};
	data.infos=Proto.parseVarArray(entry,Proto.parseDailyActionValueItem,Proto.parseWORD); -- 领体力结构
	return data;
end

function Proto.writeActivityInfo_BODY_DailyActionValue(msg,data)
	Proto.writeVarArray(msg,data.infos,Proto.writeDailyActionValueItem,Proto.writeWORD); -- 领体力结构
end

function Proto.parseActivityInfo_BODY_BuyActionValueAddCatchRate(entry)
	local data={};
	data.count=Proto.parseDWORD(entry); -- 增加数量
	data.rate=Proto.parseDWORD(entry); -- 增加比例
	return data;
end

function Proto.writeActivityInfo_BODY_BuyActionValueAddCatchRate(msg,data)
	Proto.writeDWORD(msg,data.count); -- 增加数量
	Proto.writeDWORD(msg,data.rate); -- 增加比例
end

function Proto.parseActivityInfo_BODY_Rechare(entry)
	local data={};
	data.infos=Proto.parseVarArray(entry,Proto.parseRechargeActivityInfo,Proto.parseWORD); -- 充值
	data.type=Proto.parseBYTE(entry); -- 每天刷新吗
	return data;
end

function Proto.writeActivityInfo_BODY_Rechare(msg,data)
	Proto.writeVarArray(msg,data.infos,Proto.writeRechargeActivityInfo,Proto.writeWORD); -- 充值
	Proto.writeBYTE(msg,data.type); -- 每天刷新吗
end

function Proto.parseActivityInfo_BODY_Consume(entry)
	local data={};
	data.infos=Proto.parseVarArray(entry,Proto.parseConsumeActivityInfo,Proto.parseWORD); -- 消费
	data.isDaily=Proto.parseBYTE(entry); -- 每天刷新吗
	return data;
end

function Proto.writeActivityInfo_BODY_Consume(msg,data)
	Proto.writeVarArray(msg,data.infos,Proto.writeConsumeActivityInfo,Proto.writeWORD); -- 消费
	Proto.writeBYTE(msg,data.isDaily); -- 每天刷新吗
end

function Proto.parseActivityInfo_BODY_PayReturn(entry)
	local data={};
	data.mailID=Proto.parseDWORD(entry); -- 邮件ID
	data.money=Proto.parseDWORD(entry); -- 金额
	data.rateLte=Proto.parseDWORD(entry); -- 小于等于的返利比例
	data.rateGt=Proto.parseDWORD(entry); -- 大于的返利比例
	return data;
end

function Proto.writeActivityInfo_BODY_PayReturn(msg,data)
	Proto.writeDWORD(msg,data.mailID); -- 邮件ID
	Proto.writeDWORD(msg,data.money); -- 金额
	Proto.writeDWORD(msg,data.rateLte); -- 小于等于的返利比例
	Proto.writeDWORD(msg,data.rateGt); -- 大于的返利比例
end

function Proto.parseActivityInfo_BODY_LevelReturn(entry)
	local data={};
	data.mailID=Proto.parseDWORD(entry); -- 邮件ID
	data.awards=Proto.parseVarArray(entry,Proto.parseActivityAward,Proto.parseWORD); -- 奖励
	return data;
end

function Proto.writeActivityInfo_BODY_LevelReturn(msg,data)
	Proto.writeDWORD(msg,data.mailID); -- 邮件ID
	Proto.writeVarArray(msg,data.awards,Proto.writeActivityAward,Proto.writeWORD); -- 奖励
end

function Proto.parseActivityInfo_BODY_SpokesmanGuess(entry)
	local data={};
	data.infos=Proto.parseVarArray(entry,Proto.parseSpokesmanGuessActivityInfo,Proto.parseWORD); -- 进度奖励
	return data;
end

function Proto.writeActivityInfo_BODY_SpokesmanGuess(msg,data)
	Proto.writeVarArray(msg,data.infos,Proto.writeSpokesmanGuessActivityInfo,Proto.writeWORD); -- 进度奖励
end

function Proto.parseActivityInfo_BODY_LuoTianyi(entry)
	local data={};
	data.infos=Proto.parseVarArray(entry,Proto.parseLuoTianyiActivityInfo,Proto.parseWORD); -- 洛天依积分表
	return data;
end

function Proto.writeActivityInfo_BODY_LuoTianyi(msg,data)
	Proto.writeVarArray(msg,data.infos,Proto.writeLuoTianyiActivityInfo,Proto.writeWORD); -- 洛天依积分表
end

function Proto.parseActivityInfo_BODY_TimeLimitCapsuleEgg(entry)
	local data={};
	data.infos=Proto.parseVarArray(entry,Proto.parseTimeLimitCapsuleEggActivityInfo,Proto.parseWORD); -- 洛天依积分表
	return data;
end

function Proto.writeActivityInfo_BODY_TimeLimitCapsuleEgg(msg,data)
	Proto.writeVarArray(msg,data.infos,Proto.writeTimeLimitCapsuleEggActivityInfo,Proto.writeWORD); -- 洛天依积分表
end

function Proto.parseActivityInfo_BODY_LosTowerActionValue(entry)
	local data={};
	data.infos=Proto.parseVarArray(entry,Proto.parseLosTowerActionValueItem,Proto.parseWORD); -- 千层塔
	return data;
end

function Proto.writeActivityInfo_BODY_LosTowerActionValue(msg,data)
	Proto.writeVarArray(msg,data.infos,Proto.writeLosTowerActionValueItem,Proto.writeWORD); -- 千层塔
end

function Proto.parseActivityInfo_BODY_PVPArenaGradePoint(entry)
	local data={};
	data.awards=Proto.parseVarArray(entry,Proto.parseActivityAward,Proto.parseWORD); -- 奖励
	data.times=Proto.parseDWORD(entry); -- 需要完成多少次
	return data;
end

function Proto.writeActivityInfo_BODY_PVPArenaGradePoint(msg,data)
	Proto.writeVarArray(msg,data.awards,Proto.writeActivityAward,Proto.writeWORD); -- 奖励
	Proto.writeDWORD(msg,data.times); -- 需要完成多少次
end

function Proto.parseActivityInfo_BODY_TeamDungeon(entry)
	local data={};
	data.awards=Proto.parseVarArray(entry,Proto.parseActivityAward,Proto.parseWORD); -- 奖励
	data.times=Proto.parseDWORD(entry); -- 需要完成多少次
	return data;
end

function Proto.writeActivityInfo_BODY_TeamDungeon(msg,data)
	Proto.writeVarArray(msg,data.awards,Proto.writeActivityAward,Proto.writeWORD); -- 奖励
	Proto.writeDWORD(msg,data.times); -- 需要完成多少次
end

function Proto.parseActivityInfo_BODY_WorldBoss(entry)
	local data={};
	data.awards=Proto.parseVarArray(entry,Proto.parseActivityAward,Proto.parseWORD); -- 奖励
	data.times=Proto.parseDWORD(entry); -- 需要完成多少次
	return data;
end

function Proto.writeActivityInfo_BODY_WorldBoss(msg,data)
	Proto.writeVarArray(msg,data.awards,Proto.writeActivityAward,Proto.writeWORD); -- 奖励
	Proto.writeDWORD(msg,data.times); -- 需要完成多少次
end

function Proto.parseActivityInfo_BODY_ContinueLogin(entry)
	local data={};
	data.awards=Proto.parseVarArray(entry,Proto.parseActivityAward,Proto.parseWORD); -- 奖励
	data.times=Proto.parseDWORD(entry); -- 连续登陆
	return data;
end

function Proto.writeActivityInfo_BODY_ContinueLogin(msg,data)
	Proto.writeVarArray(msg,data.awards,Proto.writeActivityAward,Proto.writeWORD); -- 奖励
	Proto.writeDWORD(msg,data.times); -- 连续登陆
end

function Proto.parseActivityInfo_BODY_SurvivalBattle(entry)
	local data={};
	return data;
end

function Proto.writeActivityInfo_BODY_SurvivalBattle(msg,data)
end

function Proto.parseActivityInfo_BODY_ActivityShop(entry)
	local data={};
	return data;
end

function Proto.writeActivityInfo_BODY_ActivityShop(msg,data)
end

function Proto.parseActivityInfo_BODY_Client(entry)
	local data={};
	data.params=Proto.parseZoic_StringForUnion_512_(entry); -- 奖励
	return data;
end

function Proto.writeActivityInfo_BODY_Client(msg,data)
	Proto.writeZoic_StringForUnion_512_(msg,data.params); -- 奖励
end

function Proto.parseActivityInfo_BODY_LostTowerDoubleSValue(entry)
	local data={};
	data.infos=Proto.parseVarArray(entry,Proto.parseLostTowerDoubleS,Proto.parseWORD); -- 千层塔双S
	return data;
end

function Proto.writeActivityInfo_BODY_LostTowerDoubleSValue(msg,data)
	Proto.writeVarArray(msg,data.infos,Proto.writeLostTowerDoubleS,Proto.writeWORD); -- 千层塔双S
end

function Proto.parseActivityInfo(entry)
	local data={};
	data.id=Proto.parseint(entry); -- 活动ID
	data.beginTime=Proto.parsestring(entry); -- 开始时间
	data.openServerDays=Proto.parseint(entry); -- 开服天数
	data.lastTime=Proto.parseint(entry); -- 持续时间
	data.isPeriod=Proto.parseint(entry); -- 是否循环
	data.type=Proto.parseint(entry); -- 类型
	data.body={}; -- 数据
	if (data.type==Proto.ACT_UPGRADE) then
		data.body.upgrade=Proto.parseActivityInfo_BODY_Upgrade(entry); -- 
	end
	if (data.type==Proto.ACT_SIGN) then
		data.body.sign=Proto.parseActivityInfo_BODY_Sign(entry); -- 
	end
	if (data.type==Proto.ACT_LOGIN) then
		data.body.login=Proto.parseActivityInfo_BODY_Login(entry); -- 
	end
	if (data.type==Proto.ACT_FIRST_LOGIN) then
		data.body.firstLogin=Proto.parseFirstLoginActivityInfo(entry); -- 首次登陆
	end
	if (data.type==Proto.ACT_DAILY_CONSUME) then
		data.body.dailyConsume=Proto.parseActivityInfo_BODY_DailyConsume(entry); -- 
	end
	if (data.type==Proto.ACT_BOSSCOMBO) then
		data.body.bossCombo=Proto.parseActivityInfo_BODY_BossCombo(entry); -- 
	end
	if (data.type==Proto.ACT_PVPARENA) then
		data.body.pvpArena=Proto.parseActivityInfo_BODY_PvpArena(entry); -- 
	end
	if (data.type==Proto.ACT_SURVIVALBATTLEFLOOR) then
		data.body.survivalBattleFloor=Proto.parseActivityInfo_BODY_SurvivalBattleFloor(entry); -- 
	end
	if (data.type==Proto.ACT_EXPEDITIONCLEAR) then
		data.body.expeditionClear=Proto.parseActivityInfo_BODY_ExpeditionClear(entry); -- 
	end
	if (data.type==Proto.ACT_EXPEDITIONJOIN) then
		data.body.expeditionJoin=Proto.parseActivityInfo_BODY_ExpeditionJoin(entry); -- 
	end
	if (data.type==Proto.ACT_EXPEDITIONWIN) then
		data.body.expeditionWin=Proto.parseActivityInfo_BODY_ExpeditionWin(entry); -- 
	end
	if (data.type==Proto.ACT_BOSSATTACKCOUNT) then
		data.body.bossAttackCount=Proto.parseActivityInfo_BODY_BossAttackCount(entry); -- 
	end
	if (data.type==Proto.ACT_BOSSKILLTIME) then
		data.body.bossKillTime=Proto.parseActivityInfo_BODY_BossKillTime(entry); -- 
	end
	if (data.type==Proto.ACT_LIFESKILL) then
		data.body.lifeSkill=Proto.parseActivityInfo_BODY_LifeSkill(entry); -- 
	end
	if (data.type==Proto.ACT_GROUP_PURCHASE) then
		data.body.groupPurchase=Proto.parseActivityInfo_BODY_GroupPurchase(entry); -- 
	end
	if (data.type==Proto.ACT_GROWTH_FUND) then
		data.body.growthFund=Proto.parseActivityInfo_BODY_GrowthFund(entry); -- 
	end
	if (data.type==Proto.ACT_LUCKY_DRAW) then
		data.body.luckyDraw=Proto.parseActivityInfo_BODY_LuckyDraw(entry); -- 
	end
	if (data.type==Proto.ACT_DOUBLE_EXP_INSTANCE) then
		data.body.doubleExpInstance=Proto.parseActivityInfo_BODY_DoubleExpInstance(entry); -- 
	end
	if (data.type==Proto.ACT_DAILY_GIFT) then
		data.body.dailyGift=Proto.parseActivityInfo_BODY_DailyGift(entry); -- 
	end
	if (data.type==Proto.ACT_DAILY_ACTION_VALUE) then
		data.body.dailyActionValue=Proto.parseActivityInfo_BODY_DailyActionValue(entry); -- 
	end
	if (data.type==Proto.ACT_BUYACTIONVALUEADDCATCHRATE) then
		data.body.buyActionValueAddCatchRate=Proto.parseActivityInfo_BODY_BuyActionValueAddCatchRate(entry); -- 
	end
	if (data.type==Proto.ACT_RECHARGE) then
		data.body.recharge=Proto.parseActivityInfo_BODY_Rechare(entry); -- 
	end
	if (data.type==Proto.ACT_CONSUME) then
		data.body.consume=Proto.parseActivityInfo_BODY_Consume(entry); -- 
	end
	if (data.type==Proto.ACT_PAY_RETURN) then
		data.body.payReturn=Proto.parseActivityInfo_BODY_PayReturn(entry); -- 
	end
	if (data.type==Proto.ACT_LEVEL_RETURN) then
		data.body.levelReturn=Proto.parseActivityInfo_BODY_LevelReturn(entry); -- 
	end
	if (data.type==Proto.ACT_SPOKESMANGUESS) then
		data.body.spokesmanGuess=Proto.parseActivityInfo_BODY_SpokesmanGuess(entry); -- 
	end
	if (data.type==Proto.ACT_LUOTIANYI) then
		data.body.luotianyi=Proto.parseActivityInfo_BODY_LuoTianyi(entry); -- 
	end
	if (data.type==Proto.ACT_TL_CAPSULEEGG) then
		data.body.timeLimitCapsuleEgg=Proto.parseActivityInfo_BODY_TimeLimitCapsuleEgg(entry); -- 
	end
	if (data.type==Proto.ACT_LOSTTOWER) then
		data.body.losTowerActionValue=Proto.parseActivityInfo_BODY_LosTowerActionValue(entry); -- 
	end
	if (data.type==Proto.ACT_PVPARENAGRADEPOINT) then
		data.body.pvpArenaGradePoint=Proto.parseActivityInfo_BODY_PVPArenaGradePoint(entry); -- 
	end
	if (data.type==Proto.ACT_TEAMDUNGEON) then
		data.body.teamDungeon=Proto.parseActivityInfo_BODY_TeamDungeon(entry); -- 
	end
	if (data.type==Proto.ACT_WORLDBOSS) then
		data.body.worldBoss=Proto.parseActivityInfo_BODY_WorldBoss(entry); -- 
	end
	if (data.type==Proto.ACT_CONTINUELOGIN) then
		data.body.continueLogin=Proto.parseActivityInfo_BODY_ContinueLogin(entry); -- 
	end
	if (data.type==Proto.ACT_SURVIVALBATTLE) then
		data.body.survivalBattle=Proto.parseActivityInfo_BODY_SurvivalBattle(entry); -- 
	end
	if (data.type==Proto.ACT_ACTIVITYSHOP) then
		data.body.activityShop=Proto.parseActivityInfo_BODY_ActivityShop(entry); -- 
	end
	if (data.type==Proto.ACT_CLIENT) then
		data.body.client=Proto.parseActivityInfo_BODY_Client(entry); -- 
	end
	if (data.type==Proto.ACT_LOSTTOWERDOUBLES) then
		data.body.lostTowerDoubleSValue=Proto.parseActivityInfo_BODY_LostTowerDoubleSValue(entry); -- 
	end
	return data;
end

function Proto.getActivityInfoIDLen()
	return Proto.getintLen();
end

function Proto.writeActivityInfo(msg,data)
	Proto.writeint(msg,data.id); -- 活动ID
	Proto.writestring(msg,data.beginTime); -- 开始时间
	Proto.writeint(msg,data.openServerDays); -- 开服天数
	Proto.writeint(msg,data.lastTime); -- 持续时间
	Proto.writeint(msg,data.isPeriod); -- 是否循环
	Proto.writeint(msg,data.type); -- 类型
	if (data.type==Proto.ACT_UPGRADE) then
		Proto.writeActivityInfo_BODY_Upgrade(msg,data.body.upgrade); -- 
	end
	if (data.type==Proto.ACT_SIGN) then
		Proto.writeActivityInfo_BODY_Sign(msg,data.body.sign); -- 
	end
	if (data.type==Proto.ACT_LOGIN) then
		Proto.writeActivityInfo_BODY_Login(msg,data.body.login); -- 
	end
	if (data.type==Proto.ACT_FIRST_LOGIN) then
		Proto.writeFirstLoginActivityInfo(msg,data.body.firstLogin); -- 首次登陆
	end
	if (data.type==Proto.ACT_DAILY_CONSUME) then
		Proto.writeActivityInfo_BODY_DailyConsume(msg,data.body.dailyConsume); -- 
	end
	if (data.type==Proto.ACT_BOSSCOMBO) then
		Proto.writeActivityInfo_BODY_BossCombo(msg,data.body.bossCombo); -- 
	end
	if (data.type==Proto.ACT_PVPARENA) then
		Proto.writeActivityInfo_BODY_PvpArena(msg,data.body.pvpArena); -- 
	end
	if (data.type==Proto.ACT_SURVIVALBATTLEFLOOR) then
		Proto.writeActivityInfo_BODY_SurvivalBattleFloor(msg,data.body.survivalBattleFloor); -- 
	end
	if (data.type==Proto.ACT_EXPEDITIONCLEAR) then
		Proto.writeActivityInfo_BODY_ExpeditionClear(msg,data.body.expeditionClear); -- 
	end
	if (data.type==Proto.ACT_EXPEDITIONJOIN) then
		Proto.writeActivityInfo_BODY_ExpeditionJoin(msg,data.body.expeditionJoin); -- 
	end
	if (data.type==Proto.ACT_EXPEDITIONWIN) then
		Proto.writeActivityInfo_BODY_ExpeditionWin(msg,data.body.expeditionWin); -- 
	end
	if (data.type==Proto.ACT_BOSSATTACKCOUNT) then
		Proto.writeActivityInfo_BODY_BossAttackCount(msg,data.body.bossAttackCount); -- 
	end
	if (data.type==Proto.ACT_BOSSKILLTIME) then
		Proto.writeActivityInfo_BODY_BossKillTime(msg,data.body.bossKillTime); -- 
	end
	if (data.type==Proto.ACT_LIFESKILL) then
		Proto.writeActivityInfo_BODY_LifeSkill(msg,data.body.lifeSkill); -- 
	end
	if (data.type==Proto.ACT_GROUP_PURCHASE) then
		Proto.writeActivityInfo_BODY_GroupPurchase(msg,data.body.groupPurchase); -- 
	end
	if (data.type==Proto.ACT_GROWTH_FUND) then
		Proto.writeActivityInfo_BODY_GrowthFund(msg,data.body.growthFund); -- 
	end
	if (data.type==Proto.ACT_LUCKY_DRAW) then
		Proto.writeActivityInfo_BODY_LuckyDraw(msg,data.body.luckyDraw); -- 
	end
	if (data.type==Proto.ACT_DOUBLE_EXP_INSTANCE) then
		Proto.writeActivityInfo_BODY_DoubleExpInstance(msg,data.body.doubleExpInstance); -- 
	end
	if (data.type==Proto.ACT_DAILY_GIFT) then
		Proto.writeActivityInfo_BODY_DailyGift(msg,data.body.dailyGift); -- 
	end
	if (data.type==Proto.ACT_DAILY_ACTION_VALUE) then
		Proto.writeActivityInfo_BODY_DailyActionValue(msg,data.body.dailyActionValue); -- 
	end
	if (data.type==Proto.ACT_BUYACTIONVALUEADDCATCHRATE) then
		Proto.writeActivityInfo_BODY_BuyActionValueAddCatchRate(msg,data.body.buyActionValueAddCatchRate); -- 
	end
	if (data.type==Proto.ACT_RECHARGE) then
		Proto.writeActivityInfo_BODY_Rechare(msg,data.body.recharge); -- 
	end
	if (data.type==Proto.ACT_CONSUME) then
		Proto.writeActivityInfo_BODY_Consume(msg,data.body.consume); -- 
	end
	if (data.type==Proto.ACT_PAY_RETURN) then
		Proto.writeActivityInfo_BODY_PayReturn(msg,data.body.payReturn); -- 
	end
	if (data.type==Proto.ACT_LEVEL_RETURN) then
		Proto.writeActivityInfo_BODY_LevelReturn(msg,data.body.levelReturn); -- 
	end
	if (data.type==Proto.ACT_SPOKESMANGUESS) then
		Proto.writeActivityInfo_BODY_SpokesmanGuess(msg,data.body.spokesmanGuess); -- 
	end
	if (data.type==Proto.ACT_LUOTIANYI) then
		Proto.writeActivityInfo_BODY_LuoTianyi(msg,data.body.luotianyi); -- 
	end
	if (data.type==Proto.ACT_TL_CAPSULEEGG) then
		Proto.writeActivityInfo_BODY_TimeLimitCapsuleEgg(msg,data.body.timeLimitCapsuleEgg); -- 
	end
	if (data.type==Proto.ACT_LOSTTOWER) then
		Proto.writeActivityInfo_BODY_LosTowerActionValue(msg,data.body.losTowerActionValue); -- 
	end
	if (data.type==Proto.ACT_PVPARENAGRADEPOINT) then
		Proto.writeActivityInfo_BODY_PVPArenaGradePoint(msg,data.body.pvpArenaGradePoint); -- 
	end
	if (data.type==Proto.ACT_TEAMDUNGEON) then
		Proto.writeActivityInfo_BODY_TeamDungeon(msg,data.body.teamDungeon); -- 
	end
	if (data.type==Proto.ACT_WORLDBOSS) then
		Proto.writeActivityInfo_BODY_WorldBoss(msg,data.body.worldBoss); -- 
	end
	if (data.type==Proto.ACT_CONTINUELOGIN) then
		Proto.writeActivityInfo_BODY_ContinueLogin(msg,data.body.continueLogin); -- 
	end
	if (data.type==Proto.ACT_SURVIVALBATTLE) then
		Proto.writeActivityInfo_BODY_SurvivalBattle(msg,data.body.survivalBattle); -- 
	end
	if (data.type==Proto.ACT_ACTIVITYSHOP) then
		Proto.writeActivityInfo_BODY_ActivityShop(msg,data.body.activityShop); -- 
	end
	if (data.type==Proto.ACT_CLIENT) then
		Proto.writeActivityInfo_BODY_Client(msg,data.body.client); -- 
	end
	if (data.type==Proto.ACT_LOSTTOWERDOUBLES) then
		Proto.writeActivityInfo_BODY_LostTowerDoubleSValue(msg,data.body.lostTowerDoubleSValue); -- 
	end
end

function Proto.parseActivityInfoClient(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 活动ID
	data.name=Proto.parseString(entry); -- 活动名称
	data.beginTime=Proto.parseDWORD(entry); -- 开始时间
	data.openServerDays=Proto.parseint(entry); -- 开服天数
	data.lastTime=Proto.parseDWORD(entry); -- 持续时间
	data.isPeriod=Proto.parseDWORD(entry); -- 是否循环
	data.image=Proto.parseString(entry); -- 活动图片
	data.page=Proto.parseDWORD(entry); -- 活动分页
	data.type=Proto.parseDWORD(entry); -- 类型
	data.drawType=Proto.parseString(entry); -- 领取方式
	data.describe=Proto.parseString(entry); -- 活动详情
	data.androidDescribe=Proto.parseString(entry); -- 安卓活动详情
	data.params=Proto.parseVector(entry,Proto.parseString); -- 参数
	data.plat=Proto.parseString(entry); -- 平台显示
	return data;
end

function Proto.getActivityInfoClientIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeActivityInfoClient(msg,data)
	Proto.writeDWORD(msg,data.id); -- 活动ID
	Proto.writeString(msg,data.name); -- 活动名称
	Proto.writeDWORD(msg,data.beginTime); -- 开始时间
	Proto.writeint(msg,data.openServerDays); -- 开服天数
	Proto.writeDWORD(msg,data.lastTime); -- 持续时间
	Proto.writeDWORD(msg,data.isPeriod); -- 是否循环
	Proto.writeString(msg,data.image); -- 活动图片
	Proto.writeDWORD(msg,data.page); -- 活动分页
	Proto.writeDWORD(msg,data.type); -- 类型
	Proto.writeString(msg,data.drawType); -- 领取方式
	Proto.writeString(msg,data.describe); -- 活动详情
	Proto.writeString(msg,data.androidDescribe); -- 安卓活动详情
	Proto.writeVector(msg,data.params,Proto.writeString); -- 参数
	Proto.writeString(msg,data.plat); -- 平台显示
end

function Proto.parseGMActivityInfoClient(entry)
	local data={};
	data.acitivitBase=Proto.parseActivityInfo(entry); -- 基本活动信息
	data.beginTime=Proto.parseint(entry); -- 开始时间
	data.page=Proto.parseint(entry); -- 活动分页
	data.image=Proto.parseString(entry); -- 活动图片
	data.plat=Proto.parseString(entry); -- 平台显示
	return data;
end

function Proto.writeGMActivityInfoClient(msg,data)
	Proto.writeActivityInfo(msg,data.acitivitBase); -- 基本活动信息
	Proto.writeint(msg,data.beginTime); -- 开始时间
	Proto.writeint(msg,data.page); -- 活动分页
	Proto.writeString(msg,data.image); -- 活动图片
	Proto.writeString(msg,data.plat); -- 平台显示
end

