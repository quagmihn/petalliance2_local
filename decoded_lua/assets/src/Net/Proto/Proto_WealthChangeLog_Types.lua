-- Net.Proto.Proto_WealthChangeLog_Types

Proto.WCT_NONE						= 0											-- [资产变更类型(原因)]未确定
Proto.WCT_SKILLCARDLEVEL			= Proto.WCT_NONE + 1						-- [资产变更类型(原因)]卡片等级变化
Proto.WCT_MAILSEND					= Proto.WCT_SKILLCARDLEVEL + 1				-- [资产变更类型(原因)]邮件发送
Proto.WCT_DISCARD					= Proto.WCT_MAILSEND + 1					-- [资产变更类型(原因)]丢弃道具
Proto.WCT_COMMODITY					= Proto.WCT_DISCARD + 1						-- [资产变更类型(原因)]商品买卖
Proto.WCT_PUZZLE					= Proto.WCT_COMMODITY + 1					-- [资产变更类型(原因)]宝箱拼图
Proto.WCT_STOCKCOUNT				= Proto.WCT_PUZZLE + 1						-- [资产变更类型(原因)]股票帐户
Proto.WCT_STOCKTRADE				= Proto.WCT_STOCKCOUNT + 1					-- [资产变更类型(原因)]股票交易
Proto.WCT_SPACEBUGGLE				= Proto.WCT_STOCKTRADE + 1					-- [资产变更类型(原因)]宇宙喇叭
Proto.WCT_BIGBUGGLE					= Proto.WCT_SPACEBUGGLE + 1					-- [资产变更类型(原因)]大喇叭
Proto.WCT_SMALLBUGGLE				= Proto.WCT_BIGBUGGLE + 1					-- [资产变更类型(原因)]小喇叭
Proto.WCT_MAILRECEIVE				= Proto.WCT_SMALLBUGGLE + 1					-- [资产变更类型(原因)]邮件收取
Proto.WCT_GROWTHTOEXP				= Proto.WCT_MAILRECEIVE + 1					-- [资产变更类型(原因)]成长度转换exp
Proto.WCT_FINISHQUEST				= Proto.WCT_GROWTHTOEXP + 1					-- [资产变更类型(原因)]完成任务
Proto.WCT_REPETITIONMONSTER			= Proto.WCT_FINISHQUEST + 1					-- [资产变更类型(原因)]副本怪物
Proto.WCT_REPETITIONAWARD			= Proto.WCT_REPETITIONMONSTER + 1			-- [资产变更类型(原因)]副本奖励
Proto.WCT_SYNTHESIZESKILLCARD		= Proto.WCT_REPETITIONAWARD + 1				-- [资产变更类型(原因)]合成技能卡
Proto.WCT_SYNTHESIZEITEM			= Proto.WCT_SYNTHESIZESKILLCARD + 1			-- [资产变更类型(原因)]合成道具
Proto.WCT_TREASURE					= Proto.WCT_SYNTHESIZEITEM + 1				-- [资产变更类型(原因)]使用宝箱
Proto.WCT_TRADE						= Proto.WCT_TREASURE + 1					-- [资产变更类型(原因)]玩家交易
Proto.WCT_INSURANCE					= Proto.WCT_TRADE + 1						-- [资产变更类型(原因)]投保
Proto.WCT_LABORAGE					= Proto.WCT_INSURANCE + 1					-- [资产变更类型(原因)]工资
Proto.WCT_ACTIVITYKEY				= Proto.WCT_LABORAGE + 1					-- [资产变更类型(原因)]激活输入码
Proto.WCT_ACTIVITYITEM				= Proto.WCT_ACTIVITYKEY + 1					-- [资产变更类型(原因)]活动增送道具
Proto.WCT_SKILLCARDINTENSIFY		= Proto.WCT_ACTIVITYITEM + 1				-- [资产变更类型(原因)]卡片升级
Proto.WCT_ACTIVITYMONEY				= Proto.WCT_SKILLCARDINTENSIFY + 1			-- [资产变更类型(原因)]活动赠送资金
Proto.WCT_CONFRATERNITYFUND			= Proto.WCT_ACTIVITYMONEY + 1				-- [资产变更类型(原因)]公会资金
Proto.WCT_CONFRATERNITYCONTRIBUTE	= Proto.WCT_CONFRATERNITYFUND + 1			-- [资产变更类型(原因)]公会贡献点购买
Proto.WCT_CONFRATERNITYSTOCK		= Proto.WCT_CONFRATERNITYCONTRIBUTE + 1		-- [资产变更类型(原因)]公会采购
Proto.WCT_USESKILL					= Proto.WCT_CONFRATERNITYSTOCK + 1			-- [资产变更类型(原因)]技能消耗道具
Proto.WCT_MINING					= Proto.WCT_USESKILL + 1					-- [资产变更类型(原因)]挖矿
Proto.WCT_SNATCH					= Proto.WCT_MINING + 1						-- [资产变更类型(原因)]抢夺
Proto.WCT_INSERTCARD				= Proto.WCT_SNATCH + 1						-- [资产变更类型(原因)]插入技能卡
Proto.WCT_PLAYERSHOP				= Proto.WCT_INSERTCARD + 1					-- [资产变更类型(原因)]挂店交易
Proto.WCT_MARRIAGE					= Proto.WCT_PLAYERSHOP + 1					-- [资产变更类型(原因)]结婚
Proto.WCT_DIVORCE					= Proto.WCT_MARRIAGE + 1					-- [资产变更类型(原因)]离婚
Proto.WCT_FARMMONSTER				= Proto.WCT_DIVORCE + 1						-- [资产变更类型(原因)]野外怪物掉落
Proto.WCT_FARMCOLLECT				= Proto.WCT_FARMMONSTER + 1					-- [资产变更类型(原因)]野外采集
Proto.WCT_PRODUCT					= Proto.WCT_FARMCOLLECT + 1					-- [资产变更类型(原因)]生产线
Proto.WCT_CONFRATERNITYWARATTACK	= Proto.WCT_PRODUCT + 1						-- [资产变更类型(原因)]公会战宣战
Proto.WCT_CONFRATERNITYWAROVER		= Proto.WCT_CONFRATERNITYWARATTACK + 1		-- [资产变更类型(原因)]公会战结束
Proto.WCT_PRE_CONFRATERNITYWAROVER	= Proto.WCT_CONFRATERNITYWAROVER + 1		-- [资产变更类型(原因)]公会战结束预处理
Proto.WCT_CONFRATERNITYWARAWARD		= Proto.WCT_PRE_CONFRATERNITYWAROVER + 1	-- [资产变更类型(原因)]公会战奖励
Proto.WCT_TRADECONTESTAWARD			= Proto.WCT_CONFRATERNITYWARAWARD + 1		-- [资产变更类型(原因)]贸易战奖励
Proto.WCT_ACTIVEALLELE				= Proto.WCT_TRADECONTESTAWARD + 1			-- [资产变更类型(原因)]重修天性
Proto.WCT_FETCHINSURANCE			= Proto.WCT_ACTIVEALLELE + 1				-- [资产变更类型(原因)]领取保险
Proto.WCT_ONLINEPRESENT				= Proto.WCT_FETCHINSURANCE + 1				-- [资产变更类型(原因)]在线礼包
Proto.WCT_ITEMUSE					= Proto.WCT_ONLINEPRESENT + 1				-- [资产变更类型(原因)]道具使用
Proto.WCT_MAPPRESENT				= Proto.WCT_ITEMUSE + 1						-- [资产变更类型(原因)]地图礼物
Proto.WCT_ACCEPTQUEST				= Proto.WCT_MAPPRESENT + 1					-- [资产变更类型(原因)]接受任务
Proto.WCT_CANCELQUEST				= Proto.WCT_ACCEPTQUEST + 1					-- [资产变更类型(原因)]放弃任务
Proto.WCT_EQUIPINTENSIFY			= Proto.WCT_CANCELQUEST + 1					-- [资产变更类型(原因)]装备强化
Proto.WCT_CHARLOGIN					= Proto.WCT_EQUIPINTENSIFY + 1				-- [资产变更类型(原因)]玩家登入
Proto.WCT_PETDORMFEED				= Proto.WCT_CHARLOGIN + 1					-- [资产变更类型(原因)]宠物宿舍喂食
Proto.WCT_PETDORMEAT				= Proto.WCT_PETDORMFEED + 1					-- [资产变更类型(原因)]宠物宿舍进食
Proto.WCT_PACKETEXTEND				= Proto.WCT_PETDORMEAT + 1					-- [资产变更类型(原因)]背包扩充
Proto.WCT_ITEMEXCHANGE				= Proto.WCT_PACKETEXTEND + 1				-- [资产变更类型(原因)]道具交换
Proto.WCT_CONFRATERNITYMONEY		= Proto.WCT_ITEMEXCHANGE + 1				-- [资产变更类型(原因)]帮派抽头
Proto.WCT_LORDERMONEY				= Proto.WCT_CONFRATERNITYMONEY + 1			-- [资产变更类型(原因)]领主抽头
Proto.WCT_SLOTSTART					= Proto.WCT_LORDERMONEY + 1					-- [资产变更类型(原因)]开始投币摇奖
Proto.WCT_SLOTPRESENT				= Proto.WCT_SLOTSTART + 1					-- [资产变更类型(原因)]领取摇奖奖励
Proto.WCT_AUCTION_SELL				= Proto.WCT_SLOTPRESENT + 1					-- [资产变更类型(原因)]拍卖行卖出
Proto.WCT_AUCTION_BUY				= Proto.WCT_AUCTION_SELL + 1				-- [资产变更类型(原因)]拍卖行买入
Proto.WT_NONE		= 0							-- [资产类型]未确定
Proto.WT_ITEM		= Proto.WT_NONE + 1			-- [资产类型]道具
Proto.WT_GCASH		= Proto.WT_ITEM + 1			-- [资产类型]贝壳币
Proto.WT_CREDITCARD	= Proto.WT_GCASH + 1		-- [资产类型]点券
Proto.WT_GROWTH		= Proto.WT_CREDITCARD + 1	-- [资产类型]成长度
Proto.WT_EXP		= Proto.WT_GROWTH + 1		-- [资产类型]经验
Proto.WT_TOTAL		= Proto.WT_EXP + 1			-- [资产类型]类别总数
Proto.LL_NOTLOG		= 0						-- [记录级别]不记录
Proto.LL_CERTAIN	= Proto.LL_NOTLOG + 1	-- [记录级别]有确定原因的
Proto.LL_ALL		= Proto.LL_CERTAIN + 1	-- [记录级别]全部记录
Proto.SCT_NONE		= 0						-- [抽样类型]不记录
Proto.SCT_WAIT		= Proto.SCT_NONE + 1	-- [抽样类型]只记录一次前等待
Proto.SCT_ONCE		= Proto.SCT_WAIT + 1	-- [抽样类型]只记录一次
Proto.SCT_ALWAYS	= Proto.SCT_ONCE + 1	-- [抽样类型]循环记录
Proto.CONT_NONE			= 0							-- [上下文类型]无上下文
Proto.CONT_SINGLE		= Proto.CONT_NONE + 1		-- [上下文类型]简单操作
Proto.CONT_REPETITION	= Proto.CONT_SINGLE + 1		-- [上下文类型]副本操作
Proto.CONT_SNATCH		= Proto.CONT_REPETITION + 1	-- [上下文类型]枪夺操作
Proto.CONT_CONWAR		= Proto.CONT_SNATCH + 1		-- [上下文类型]公会战操作
Proto.CONT_FARM			= Proto.CONT_CONWAR + 1		-- [上下文类型]野外地图
Proto.WCLT_NONE						= 0											-- [资产变化类型]无
Proto.WCLT_ITEMDELETE				= Proto.WCLT_NONE + 1						-- [资产变化类型]道具删除
Proto.WCLT_ITEMEXCHANGE				= Proto.WCLT_ITEMDELETE + 1					-- [资产变化类型]道具交换
Proto.WCLT_ITEMINSERT				= Proto.WCLT_ITEMEXCHANGE + 1				-- [资产变化类型]道具插入
Proto.WCLT_ITEMMODIFY				= Proto.WCLT_ITEMINSERT + 1					-- [资产变化类型]道具改变
Proto.WCLT_ITEMMOVE					= Proto.WCLT_ITEMMODIFY + 1					-- [资产变化类型]道具移动
Proto.WCLT_GROWTHMODIFY				= Proto.WCLT_ITEMMOVE + 1					-- [资产变化类型]成长度变化
Proto.WCLT_EXPMODIFY				= Proto.WCLT_GROWTHMODIFY + 1				-- [资产变化类型]经验变化
Proto.WCLT_GCASHMODIFY				= Proto.WCLT_EXPMODIFY + 1					-- [资产变化类型]贝壳币变化
Proto.WCLT_CREDITCARDMODIFY			= Proto.WCLT_GCASHMODIFY + 1				-- [资产变化类型]信用卡变化
Proto.WCLT_CONFRATERNITYFUNDMODIFY	= Proto.WCLT_CREDITCARDMODIFY + 1			-- [资产变化类型]公会资金变化
Proto.WCLT_CONFRATERNITYEXPMODIFY	= Proto.WCLT_CONFRATERNITYFUNDMODIFY + 1	-- [资产变化类型]公会经验变化
Proto.WCLT_PRESENTINSERT			= Proto.WCLT_CONFRATERNITYEXPMODIFY + 1		-- [资产变化类型]礼物插入
Proto.WCLT_PRESENTREMOVE			= Proto.WCLT_PRESENTINSERT + 1				-- [资产变化类型]礼物移除
Proto.WCLT_QUESTINSERT				= Proto.WCLT_PRESENTREMOVE + 1				-- [资产变化类型]任务插入
Proto.WCLT_QUESTREMOVE				= Proto.WCLT_QUESTINSERT + 1				-- [资产变化类型]任务移除
Proto.WCLT_GLOBALRECORDUPDATE		= Proto.WCLT_QUESTREMOVE + 1				-- [资产变化类型]全局记录更新
Proto.WCLT_GLOBALRECORDREMOVE		= Proto.WCLT_GLOBALRECORDUPDATE + 1			-- [资产变化类型]全局记录移除
Proto.WCLT_FACILITYINSERT			= Proto.WCLT_GLOBALRECORDREMOVE + 1			-- [资产变化类型]庄园设备新增
Proto.WCLT_FACILITYREMOVE			= Proto.WCLT_FACILITYINSERT + 1				-- [资产变化类型]庄园设备移除
Proto.WCLT_FACILITYMODIFY			= Proto.WCLT_FACILITYREMOVE + 1				-- [资产变化类型]庄园设备改变

function Proto.parseRepetitionLogContext(entry)
	local data={};
	data.rep_id=Proto.parseDWORD(entry); -- 副本id
	data.dice_time=Proto.parseDWORD(entry); -- 步数
	data.type=Proto.parseBYTE(entry); -- 变化原因
	data.rep_type=Proto.parseRepStyle(entry); -- 副本类型
	data.cell=Proto.parseDWORD(entry); -- 格子
	return data;
end

function Proto.writeRepetitionLogContext(msg,data)
	Proto.writeDWORD(msg,data.rep_id); -- 副本id
	Proto.writeDWORD(msg,data.dice_time); -- 步数
	Proto.writeBYTE(msg,data.type); -- 变化原因
	Proto.writeRepStyle(msg,data.rep_type); -- 副本类型
	Proto.writeDWORD(msg,data.cell); -- 格子
end

function Proto.parseSingleLogContext(entry)
	local data={};
	data.type=Proto.parseBYTE(entry); -- 变化原因
	data.owner_type=Proto.parseBYTE(entry); -- 变化所有者类型
	data.owner_id=Proto.parseDWORD(entry); -- 变化所有者ID
	data.change_from=Proto.parseDWORD(entry); -- 变化来源
	return data;
end

function Proto.writeSingleLogContext(msg,data)
	Proto.writeBYTE(msg,data.type); -- 变化原因
	Proto.writeBYTE(msg,data.owner_type); -- 变化所有者类型
	Proto.writeDWORD(msg,data.owner_id); -- 变化所有者ID
	Proto.writeDWORD(msg,data.change_from); -- 变化来源
end

function Proto.parseSnatchLogContext(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 抢夺id
	data.type=Proto.parseBYTE(entry); -- 变化类型
	data.defense=Proto.parseDWORD(entry); -- 目标玩家id
	data.attack=Proto.parseDWORD(entry); -- 发起玩家id
	return data;
end

function Proto.getSnatchLogContextIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeSnatchLogContext(msg,data)
	Proto.writeDWORD(msg,data.id); -- 抢夺id
	Proto.writeBYTE(msg,data.type); -- 变化类型
	Proto.writeDWORD(msg,data.defense); -- 目标玩家id
	Proto.writeDWORD(msg,data.attack); -- 发起玩家id
end

function Proto.parseConWarLogContext(entry)
	local data={};
	data.warID=Proto.parseDWORD(entry); -- 公会战id
	data.changeType=Proto.parseBYTE(entry); -- 变更类型
	data.defense=Proto.parseDWORD(entry); -- 防守公会id
	data.attack=Proto.parseDWORD(entry); -- 挑战公会id
	return data;
end

function Proto.writeConWarLogContext(msg,data)
	Proto.writeDWORD(msg,data.warID); -- 公会战id
	Proto.writeBYTE(msg,data.changeType); -- 变更类型
	Proto.writeDWORD(msg,data.defense); -- 防守公会id
	Proto.writeDWORD(msg,data.attack); -- 挑战公会id
end

function Proto.parseFarmLogContext(entry)
	local data={};
	data.farmType=Proto.parseDWORD(entry); -- 野外地图类型
	data.type=Proto.parseBYTE(entry); -- 变更类型
	return data;
end

function Proto.writeFarmLogContext(msg,data)
	Proto.writeDWORD(msg,data.farmType); -- 野外地图类型
	Proto.writeBYTE(msg,data.type); -- 变更类型
end

function Proto.parseSkillUseTime(entry)
	local data={};
	data.skillID=Proto.parseDWORD(entry); -- 技能id
	data.useTime=Proto.parseDWORD(entry); -- 使用次数
	return data;
end

function Proto.writeSkillUseTime(msg,data)
	Proto.writeDWORD(msg,data.skillID); -- 技能id
	Proto.writeDWORD(msg,data.useTime); -- 使用次数
end

function Proto.parseMonsterDeadTime(entry)
	local data={};
	data.monsterType=Proto.parseDWORD(entry); -- 怪物类型
	data.times=Proto.parseDWORD(entry); -- 死亡次数
	return data;
end

function Proto.writeMonsterDeadTime(msg,data)
	Proto.writeDWORD(msg,data.monsterType); -- 怪物类型
	Proto.writeDWORD(msg,data.times); -- 死亡次数
end

function Proto.parseSkillUseLogContext(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 上下文id
	data.type=Proto.parseBYTE(entry); -- 抽样类型
	data.spotCheckNum=Proto.parseBYTE(entry); -- 抽样模数
	data.logTime=Proto.parseTIME_SEC(entry); -- 记录时间
	data.startTime=Proto.parseTIME_SEC(entry); -- 开始时间
	data.endTime=Proto.parseTIME_SEC(entry); -- 结束时间
	return data;
end

function Proto.getSkillUseLogContextIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeSkillUseLogContext(msg,data)
	Proto.writeDWORD(msg,data.id); -- 上下文id
	Proto.writeBYTE(msg,data.type); -- 抽样类型
	Proto.writeBYTE(msg,data.spotCheckNum); -- 抽样模数
	Proto.writeTIME_SEC(msg,data.logTime); -- 记录时间
	Proto.writeTIME_SEC(msg,data.startTime); -- 开始时间
	Proto.writeTIME_SEC(msg,data.endTime); -- 结束时间
end

function Proto.parseWealthChangeFlow(entry)
	local data={};
	data.wealthType=Proto.parseBYTE(entry); -- 资产类型
	data.changeFrom=Proto.parseDWORD(entry); -- 资产变更引发者
	data.changeTo=Proto.parseDWORD(entry); -- 资产变更影响者
	data.changeNum=Proto.parseint(entry); -- 资产变更数量
	return data;
end

function Proto.writeWealthChangeFlow(msg,data)
	Proto.writeBYTE(msg,data.wealthType); -- 资产类型
	Proto.writeDWORD(msg,data.changeFrom); -- 资产变更引发者
	Proto.writeDWORD(msg,data.changeTo); -- 资产变更影响者
	Proto.writeint(msg,data.changeNum); -- 资产变更数量
end

