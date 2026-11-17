-- Net.Proto.Proto_Chat_Types

Proto.SBT_ALL		= 0						-- [玩家广播范围]全服
Proto.SBT_FRIEND	= Proto.SBT_ALL + 1		-- [玩家广播范围]好友
Proto.SBT_PERSONAL	= Proto.SBT_FRIEND + 1	-- [玩家广播范围]个人
Proto.SBC_CHANLLENAGE_SUCCESS			= 0												-- [玩家广播类型]被挑战成功
Proto.SBC_CHANLLENAGE_DEFENCE_SUCCESS	= Proto.SBC_CHANLLENAGE_SUCCESS + 1				-- [玩家广播类型]保持排名到获得奖励
Proto.SBC_CHANLLENAGEFRIEND_FAILED		= Proto.SBC_CHANLLENAGE_DEFENCE_SUCCESS + 1		-- [玩家广播类型]被加为好友并击败
Proto.SBC_CHANLLENAGEFRIEND_WIN			= Proto.SBC_CHANLLENAGEFRIEND_FAILED + 1		-- [玩家广播类型]被加为好友，对手挑战失败
Proto.SBC_SPETa_SUCCESS					= Proto.SBC_CHANLLENAGEFRIEND_WIN + 1			-- [玩家广播类型]S级宠物孵化成功
Proto.SBC_SPETb_SUCCESS					= Proto.SBC_SPETa_SUCCESS + 1					-- [玩家广播类型]S级宠物进化成功
Proto.SBC_FRIEND_APETa_SUCCESS			= Proto.SBC_SPETb_SUCCESS + 1					-- [玩家广播类型]A级宠物孵化成功
Proto.SBC_FRIEND_APETb_SUCCESS			= Proto.SBC_FRIEND_APETa_SUCCESS + 1			-- [玩家广播类型]A级宠物孵化进化
Proto.SBC_FRIEND_PETtrain				= Proto.SBC_FRIEND_APETb_SUCCESS + 1			-- [玩家广播类型]其他玩家租用自己训练场
Proto.SBC_PETtrain_FAILED				= Proto.SBC_FRIEND_PETtrain + 1					-- [玩家广播类型]租用的训练场栏位被抢占
Proto.SBC_SALE							= Proto.SBC_PETtrain_FAILED + 1					-- [玩家广播类型]物品售出
Proto.SBC_EGGAWARD						= Proto.SBC_SALE + 1							-- [玩家广播类型]收到稀有扭蛋
Proto.SBC_BOSS_HURT						= Proto.SBC_EGGAWARD + 1						-- [玩家广播类型]给予BOSS伤害
Proto.SBC_BOSS_KO						= Proto.SBC_BOSS_HURT + 1						-- [玩家广播类型]击败BOSS
Proto.SBC_FRIENDVIP_VIP1				= Proto.SBC_BOSS_KO + 1							-- [玩家广播类型]好友成为VIP
Proto.SBC_FRIENDVIP_VIPUP				= Proto.SBC_FRIENDVIP_VIP1 + 1					-- [玩家广播类型]好友VIP升级
Proto.SBC_VIP_VIPTOP					= Proto.SBC_FRIENDVIP_VIPUP + 1					-- [玩家广播类型]用户成为7级VIP用户
Proto.SBC_FRIEND_AWARD					= Proto.SBC_VIP_VIPTOP + 1						-- [玩家广播类型]完成成就获得奖励
Proto.SBC_AWARD							= Proto.SBC_FRIEND_AWARD + 1					-- [玩家广播类型]完成成就获得奖励
Proto.SBC_BOSS_LEAVE					= Proto.SBC_AWARD + 1							-- [玩家广播类型]Boss离开
Proto.SBC_BOSS_5MIN_START				= Proto.SBC_BOSS_LEAVE + 1						-- [玩家广播类型]Boss战开始前5分钟
Proto.SBC_BOSS_3MIN_START				= Proto.SBC_BOSS_5MIN_START + 1					-- [玩家广播类型]Boss战开始前3分钟
Proto.SBC_BOSS_START					= Proto.SBC_BOSS_3MIN_START + 1					-- [玩家广播类型]Boss战开始
Proto.SBC_BOSS_DEAD						= Proto.SBC_BOSS_START + 1						-- [玩家广播类型]Boss战通关
Proto.SBC_MCASH_DRAWING					= Proto.SBC_BOSS_DEAD + 1						-- [玩家广播类型]M币大奖
Proto.SBC_STAGE_ARENA_OCC				= Proto.SBC_MCASH_DRAWING + 1					-- [玩家广播类型]挑战擂台成功
Proto.SBC_STAGE_ARENA_SUCC				= Proto.SBC_STAGE_ARENA_OCC + 1					-- [玩家广播类型]守擂六小时成功
Proto.SBC_ACTIVITY_AWARD				= Proto.SBC_STAGE_ARENA_SUCC + 1				-- [玩家广播类型]万人斩抢楼
Proto.SBC_ACTIVITY_NOTICE				= Proto.SBC_ACTIVITY_AWARD + 1					-- [玩家广播类型]万人斩
Proto.SBC_ACTIVITY_START				= Proto.SBC_ACTIVITY_NOTICE + 1					-- [玩家广播类型]万人斩开始
Proto.SBC_ACTIVITY_END					= Proto.SBC_ACTIVITY_START + 1					-- [玩家广播类型]万人斩结束
Proto.SBC_ACTIVITY_CLOSE				= Proto.SBC_ACTIVITY_END + 1					-- [玩家广播类型]万人斩关闭
Proto.SBC_ARENA_BE_ATTACK				= Proto.SBC_ACTIVITY_CLOSE + 1					-- [玩家广播类型]竞技场被打
Proto.SBC_ARENA_RANK_CHANGE				= Proto.SBC_ARENA_BE_ATTACK + 1					-- [玩家广播类型]竞技场排名变化
Proto.SBC_ARENA_RANK_RESULT				= Proto.SBC_ARENA_RANK_CHANGE + 1				-- [玩家广播类型]竞技场结算结果
Proto.SBC_PET_RACE_ARENA_RANK_RESULT	= Proto.SBC_ARENA_RANK_RESULT + 1				-- [玩家广播类型]单挑战竞技场结算结果
Proto.SBC_PET_RACE_ARENA_RANK_CHANGE	= Proto.SBC_PET_RACE_ARENA_RANK_RESULT + 1		-- [玩家广播类型]单挑战竞技场排名变化
Proto.SBC_PET_AIDE_GENE_LEVEL_TO_TWENTY	= Proto.SBC_PET_RACE_ARENA_RANK_CHANGE + 1		-- [玩家广播类型]伴灵技能强化至20级
Proto.SBC_PET_AIDE_GENE_LEVEL_TO_MAX	= Proto.SBC_PET_AIDE_GENE_LEVEL_TO_TWENTY + 1	-- [玩家广播类型]伴灵技能强化最高级
Proto.SBC_CROSSWORLD_END				= Proto.SBC_PET_AIDE_GENE_LEVEL_TO_MAX + 1		-- [玩家广播类型]跨服战结束通知
Proto.SBC_CROSSWORLD_ROUND_END			= Proto.SBC_CROSSWORLD_END + 1					-- [玩家广播类型]跨服战轮次结束通知
Proto.SBC_CROSSWORLD_ENROLL_REMINDER	= Proto.SBC_CROSSWORLD_ROUND_END + 1			-- [玩家广播类型]跨服战报名提醒
Proto.SBC_GALLANTS_REMINDER				= Proto.SBC_CROSSWORLD_ENROLL_REMINDER + 1		-- [玩家广播类型]擂台赛赛前提醒
Proto.SBC_GALLANTS_BEGIN				= Proto.SBC_GALLANTS_REMINDER + 1				-- [玩家广播类型]擂台赛开启
Proto.SBC_GALLANTS_END					= Proto.SBC_GALLANTS_BEGIN + 1					-- [玩家广播类型]擂台赛关闭
Proto.SBC_AUCTION_REMINDER				= Proto.SBC_GALLANTS_END + 1					-- [玩家广播类型]拍卖行开启前提醒
Proto.SBC_AUCTION_START					= Proto.SBC_AUCTION_REMINDER + 1				-- [玩家广播类型]拍卖行开启
Proto.SBC_AUCTION_END					= Proto.SBC_AUCTION_START + 1					-- [玩家广播类型]拍卖行关闭
Proto.SBC_MONOPOLY						= Proto.SBC_AUCTION_END + 1						-- [玩家广播类型]暴走公告
Proto.SBC_BOSS_APPEAR					= Proto.SBC_MONOPOLY + 1						-- [玩家广播类型]Boss出现
Proto.SBC_Count							= Proto.SBC_BOSS_APPEAR + 1						-- [玩家广播类型]数量
Proto.MAIL_BOSS_AWARD							= 0													-- [玩家邮件类型]Boss战奖励
Proto.MAIL_BOSS_SUNNY_AWARD						= Proto.MAIL_BOSS_AWARD + 1							-- [玩家邮件类型]Boss战阳光普照
Proto.MAIL_ARENA_AWARD							= Proto.MAIL_BOSS_SUNNY_AWARD + 1					-- [玩家邮件类型]竞技场物品奖励
Proto.MAIL_HANGUP_AWARD							= Proto.MAIL_ARENA_AWARD + 1						-- [玩家邮件类型]挂机奖励
Proto.MAIL_TRAININGGROUND						= Proto.MAIL_HANGUP_AWARD + 1						-- [玩家邮件类型]训练场租金
Proto.MAIL_ARENA_AWARD_BYRANK					= Proto.MAIL_TRAININGGROUND + 1						-- [玩家邮件类型]竞技场物品奖励
Proto.MAIL_ARENA_AWARD_BYPOS					= Proto.MAIL_ARENA_AWARD_BYRANK + 1					-- [玩家邮件类型]竞技场物品奖励
Proto.MAIL_AUCTION_SENDBACK						= Proto.MAIL_ARENA_AWARD_BYPOS + 1					-- [玩家邮件类型]拍卖行道具退回
Proto.MAIL_AUCTION_GETITEM						= Proto.MAIL_AUCTION_SENDBACK + 1					-- [玩家邮件类型]拍卖行购买道具
Proto.MAIL_AUCTION_GETMONEY						= Proto.MAIL_AUCTION_GETITEM + 1					-- [玩家邮件类型]拍卖行拍卖款
Proto.MAIL_CON_DISMISS							= Proto.MAIL_AUCTION_GETMONEY + 1					-- [玩家邮件类型]逐出工会
Proto.MAIL_CONSUME								= Proto.MAIL_CON_DISMISS + 1						-- [玩家邮件类型]消费奖励
Proto.MAIL_RECHARGE								= Proto.MAIL_CONSUME + 1							-- [玩家邮件类型]充值奖励
Proto.MAIL_CON_JOIN								= Proto.MAIL_RECHARGE + 1							-- [玩家邮件类型]加入工会
Proto.MAIL_CON_LOGIN							= Proto.MAIL_CON_JOIN + 1							-- [玩家邮件类型]连续登陆奖励
Proto.MAIL_STAGEARENA_AWARD						= Proto.MAIL_CON_LOGIN + 1							-- [玩家邮件类型]擂台赛奖励
Proto.MAIL_ACTIVITY_POINTAWARD					= Proto.MAIL_STAGEARENA_AWARD + 1					-- [玩家邮件类型]万人斩抢楼奖励
Proto.MAIL_ACTIVITY_AWARD						= Proto.MAIL_ACTIVITY_POINTAWARD + 1				-- [玩家邮件类型]万人斩通关奖励
Proto.MAIL_CON_DISBAND							= Proto.MAIL_ACTIVITY_AWARD + 1						-- [玩家邮件类型]工会解散
Proto.MAIL_ACTIVITY_PETLEVEL					= Proto.MAIL_CON_DISBAND + 1						-- [玩家邮件类型]宠物等级
Proto.MAIL_ARENA_BATTLE_WIN						= Proto.MAIL_ACTIVITY_PETLEVEL + 1					-- [玩家邮件类型]竞技场战斗获胜奖励
Proto.MAIL_ARENA_BATTLE_LOSE					= Proto.MAIL_ARENA_BATTLE_WIN + 1					-- [玩家邮件类型]竞技场战斗失败奖励
Proto.MAIL_ARENA_RANK_AWARD						= Proto.MAIL_ARENA_BATTLE_LOSE + 1					-- [玩家邮件类型]竞技场结算奖励
Proto.MAIL_PET_RACE_ARENA_RANK_AWARD			= Proto.MAIL_ARENA_RANK_AWARD + 1					-- [玩家邮件类型]宠物单挑竞技场结算奖励
Proto.MAIL_PET_RACE_ARENA_BATTLE				= Proto.MAIL_PET_RACE_ARENA_RANK_AWARD + 1			-- [玩家邮件类型]参加宠物单挑战奖励
Proto.MAIL_CROSSWORLD_INVITE					= Proto.MAIL_PET_RACE_ARENA_BATTLE + 1				-- [玩家邮件类型]跨服战邀请
Proto.MAIL_CROSSWORLD_RANK_AWARD				= Proto.MAIL_CROSSWORLD_INVITE + 1					-- [玩家邮件类型]跨服战结算奖励
Proto.MAIL_CROSSWORLD_CHAMPION_ZONE_AWARD		= Proto.MAIL_CROSSWORLD_RANK_AWARD + 1				-- [玩家邮件类型]跨服战冠军区每日奖励
Proto.MAIL_DIFF_INDUSTRY_SUCCESS				= Proto.MAIL_CROSSWORLD_CHAMPION_ZONE_AWARD + 1		-- [玩家邮件类型]异业券兑换成功
Proto.MAIL_DIFF_INDUSTRY_FAIL					= Proto.MAIL_DIFF_INDUSTRY_SUCCESS + 1				-- [玩家邮件类型]异业券兑换失败
Proto.MAIL_CROSSWORLD_LOSE						= Proto.MAIL_DIFF_INDUSTRY_FAIL + 1					-- [玩家邮件类型]跨服战比赛失利邮件
Proto.MAIL_GALLANTS_CHAMPION_AWARD				= Proto.MAIL_CROSSWORLD_LOSE + 1					-- [玩家邮件类型]擂台赛冠军奖励
Proto.MAIL_GALLANTS_OCCUPY_TIME_AWARD			= Proto.MAIL_GALLANTS_CHAMPION_AWARD + 1			-- [玩家邮件类型]擂台赛占领时间奖励
Proto.MAIL_CROSSWORLD_GAMBLE					= Proto.MAIL_GALLANTS_OCCUPY_TIME_AWARD + 1			-- [玩家邮件类型]跨服战赌博奖励
Proto.MAIL_BOSS_CHALLENGE_AWARD					= Proto.MAIL_CROSSWORLD_GAMBLE + 1					-- [玩家邮件类型]Boss战挑战奖励
Proto.MAIL_BOSS_GROUP_AWARD						= Proto.MAIL_BOSS_CHALLENGE_AWARD + 1				-- [玩家邮件类型]Boss战boss组奖励
Proto.MAIL_BOSS_KILL_AWARD						= Proto.MAIL_BOSS_GROUP_AWARD + 1					-- [玩家邮件类型]Boss战boss击杀奖励
Proto.MAIL_SEND_GIFT							= Proto.MAIL_BOSS_KILL_AWARD + 1					-- [玩家邮件类型]玩家赠送
Proto.MAIL_CONFRATERNITYRANK_LEADER_ASSIGN		= Proto.MAIL_SEND_GIFT + 1							-- [玩家邮件类型]家族积分族长分配奖励
Proto.MAIL_CONFRATERNITYRANK_ASSIGN_AWARDS		= Proto.MAIL_CONFRATERNITYRANK_LEADER_ASSIGN + 1	-- [玩家邮件类型]家族积分结算分配奖励
Proto.MAIL_CONFRATERNITYRANK_SUNSHINE_AWARDS	= Proto.MAIL_CONFRATERNITYRANK_ASSIGN_AWARDS + 1	-- [玩家邮件类型]家族积分结算福利奖
Proto.MAIL_NEW_PET_ALBUM_AWARDS					= Proto.MAIL_CONFRATERNITYRANK_SUNSHINE_AWARDS + 1	-- [玩家邮件类型]宠物图鉴领取奖励
Proto.MAIL_WEALTH_GOD_AWARDS					= Proto.MAIL_NEW_PET_ALBUM_AWARDS + 1				-- [玩家邮件类型]财神驾到领取奖励
Proto.MAIL_CHALLENGE_FAIL_NTF					= Proto.MAIL_WEALTH_GOD_AWARDS + 1					-- [玩家邮件类型]被挑战者打败好友战
Proto.MAIL_CHALLENGE_WIN_NTF					= Proto.MAIL_CHALLENGE_FAIL_NTF + 1					-- [玩家邮件类型]把挑战者打败好友战
Proto.MAIL_CHALLENGE_CHAT_FAIL_NTF				= Proto.MAIL_CHALLENGE_WIN_NTF + 1					-- [玩家邮件类型]把挑战者打败聊天战
Proto.MAIL_CHALLENGE_CHAT_WIN_NTF				= Proto.MAIL_CHALLENGE_CHAT_FAIL_NTF + 1			-- [玩家邮件类型]把挑战者打败聊天战
Proto.MAIL_CHALLENGE_RANK_FAIL_NTF				= Proto.MAIL_CHALLENGE_CHAT_WIN_NTF + 1				-- [玩家邮件类型]把挑战者打败排名战
Proto.MAIL_CHALLENGE_RANK_WIN_NTF				= Proto.MAIL_CHALLENGE_RANK_FAIL_NTF + 1			-- [玩家邮件类型]把挑战者打败排名战
Proto.MAIL_CHALLENGE_SINGLE_FAIL_NTF			= Proto.MAIL_CHALLENGE_RANK_WIN_NTF + 1				-- [玩家邮件类型]把挑战者打败单挑战
Proto.MAIL_CHALLENGE_SINGLE_WIN_NTF				= Proto.MAIL_CHALLENGE_SINGLE_FAIL_NTF + 1			-- [玩家邮件类型]把挑战者打败单挑战
Proto.MAIL_CHALLENGE_POINT_FAIL_NTF				= Proto.MAIL_CHALLENGE_SINGLE_WIN_NTF + 1			-- [玩家邮件类型]把挑战者打败积分战
Proto.MAIL_CHALLENGE_POINT_WIN_NTF				= Proto.MAIL_CHALLENGE_POINT_FAIL_NTF + 1			-- [玩家邮件类型]把挑战者打败积分战
Proto.MAIL_CHALLENGE_STAGE_FAIL_NTF				= Proto.MAIL_CHALLENGE_POINT_WIN_NTF + 1			-- [玩家邮件类型]把挑战者打败积分战
Proto.MAIL_CHALLENGE_STAGE_WIN_NTF				= Proto.MAIL_CHALLENGE_STAGE_FAIL_NTF + 1			-- [玩家邮件类型]把挑战者打败积分战
Proto.SBTC_XITONG	= 0							-- [玩家广播类型(客户端)]系统
Proto.SBTC_GONGGAO	= Proto.SBTC_XITONG + 1		-- [玩家广播类型(客户端)]公告
Proto.SBT_HAOYOU	= Proto.SBTC_GONGGAO + 1	-- [玩家广播类型(客户端)]好友
Proto.SBT_BOSS		= Proto.SBT_HAOYOU + 1		-- [玩家广播类型(客户端)]BOSS
Proto.CDIT_ITEM				= 0								-- []道具
Proto.CDIT_PLAYER			= Proto.CDIT_ITEM + 1			-- []玩家
Proto.CDIT_PUZZLEPROCESS	= Proto.CDIT_PLAYER + 1			-- []拼图进度
Proto.CDIT_NPC				= Proto.CDIT_PUZZLEPROCESS + 1	-- []NPC
Proto.CDIT_LOCATION			= Proto.CDIT_NPC + 1			-- []位置
Proto.CDIT_REPETITION		= Proto.CDIT_LOCATION + 1		-- []副本
Proto.CDIT_PET				= Proto.CDIT_REPETITION + 1		-- []宠物
Proto.CDIT_CONFRATERNITY	= Proto.CDIT_PET + 1			-- []公会
Proto.IGBT_ITEM		= 0						-- []拼图宝箱
Proto.IGBT_PK		= Proto.IGBT_ITEM + 1	-- []国际PK
Proto.IGBT_WEDDING	= Proto.IGBT_PK + 1		-- []婚礼
Proto.BLT_NONE	= 0						-- []未知
Proto.BLT_SPACE	= Proto.BLT_NONE + 1	-- []宇宙喇叭
Proto.BLT_BIG	= Proto.BLT_SPACE + 1	-- []大喇叭
Proto.BLT_SMALL	= Proto.BLT_BIG + 1		-- []小喇叭
Proto.SP_FREE			= 0							-- [发言权限码]自由发言
Proto.SP_BAN_ALL		= Proto.SP_FREE + 1			-- [发言权限码]禁所有发言
Proto.SP_BAN_SCREEN		= Proto.SP_BAN_ALL + 1		-- [发言权限码]禁屏幕发言
Proto.SP_BAN_PRIVATE	= Proto.SP_BAN_SCREEN + 1	-- [发言权限码]禁私密发言
Proto.SP_BAN_UNION		= Proto.SP_BAN_PRIVATE + 1	-- [发言权限码]禁工会发言
Proto.SP_CUSTOM			= Proto.SP_BAN_UNION + 1	-- [发言权限码]自定义

function Proto.parseChatContent(entry)
	local data={};
	data.text=Proto.parseString(entry); -- 正文
	return data;
end

function Proto.writeChatContent(msg,data)
	Proto.writeString(msg,data.text); -- 正文
end

function Proto.parseSystemBroadcastMessageInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 编号
	data.bcContentType=Proto.parseWORD(entry); -- 广播类型
	data.bcType=Proto.parseBYTE(entry); -- 广播范围
	data.bcContentTypeClient=Proto.parseWORD(entry); -- 广播类型
	data.content=Proto.parseNoticeContent(entry); -- 内容
	data.paramCount=Proto.parseBYTE(entry); -- 参数数量
	return data;
end

function Proto.getSystemBroadcastMessageInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeSystemBroadcastMessageInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 编号
	Proto.writeWORD(msg,data.bcContentType); -- 广播类型
	Proto.writeBYTE(msg,data.bcType); -- 广播范围
	Proto.writeWORD(msg,data.bcContentTypeClient); -- 广播类型
	Proto.writeNoticeContent(msg,data.content); -- 内容
	Proto.writeBYTE(msg,data.paramCount); -- 参数数量
end

function Proto.parseSystemBroadcastMessageInfoEx(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 编号
	data.contentEx=Proto.parseNoticeContent(entry); -- 内容
	return data;
end

function Proto.getSystemBroadcastMessageInfoExIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeSystemBroadcastMessageInfoEx(msg,data)
	Proto.writeDWORD(msg,data.id); -- 编号
	Proto.writeNoticeContent(msg,data.contentEx); -- 内容
end

function Proto.parseMailMessageInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 编号
	data.mailContentType=Proto.parseWORD(entry); -- 邮件类型
	data.content=Proto.parseMailContent(entry); -- 内容
	data.mailName=Proto.parseMailTitle(entry); -- 邮件名称
	data.paramCount=Proto.parseBYTE(entry); -- 参数数量
	return data;
end

function Proto.getMailMessageInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeMailMessageInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 编号
	Proto.writeWORD(msg,data.mailContentType); -- 邮件类型
	Proto.writeMailContent(msg,data.content); -- 内容
	Proto.writeMailTitle(msg,data.mailName); -- 邮件名称
	Proto.writeBYTE(msg,data.paramCount); -- 参数数量
end

function Proto.parseMailMessageInfoEx(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 编号
	data.contentEx=Proto.parseMailContent(entry); -- 内容
	return data;
end

function Proto.getMailMessageInfoExIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeMailMessageInfoEx(msg,data)
	Proto.writeDWORD(msg,data.id); -- 编号
	Proto.writeMailContent(msg,data.contentEx); -- 内容
end

