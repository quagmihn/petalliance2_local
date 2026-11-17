-- Net.Proto.Proto_Arena_Types

Proto.AT_PRIMARY	= 0						-- [竞技场类型]初级
Proto.AT_JUNIOR		= Proto.AT_PRIMARY + 1	-- [竞技场类型]中级
Proto.AT_SENIOR		= Proto.AT_JUNIOR + 1	-- [竞技场类型]高级
Proto.PWS_OPEN	= 0						-- [积分战状态]积分战开始
Proto.PWS_CLOSE	= Proto.PWS_OPEN + 1	-- [积分战状态]积分战结束
Proto.PW_RANK_SS	= 0						-- [积分战玩家排名分类]SS级
Proto.PW_RANK_S		= Proto.PW_RANK_SS + 1	-- [积分战玩家排名分类]S级
Proto.PW_RANK_A		= Proto.PW_RANK_S + 1	-- [积分战玩家排名分类]A级
Proto.PW_RANK_B		= Proto.PW_RANK_A + 1	-- [积分战玩家排名分类]B级
Proto.PW_RANK_C		= Proto.PW_RANK_B + 1	-- [积分战玩家排名分类]C级
Proto.PW_RANK_D		= Proto.PW_RANK_C + 1	-- [积分战玩家排名分类]D级
Proto.PW_RANK_E		= Proto.PW_RANK_D + 1	-- [积分战玩家排名分类]E级
Proto.PW_RANK_F		= Proto.PW_RANK_E + 1	-- [积分战玩家排名分类]F级
Proto.PW_OP_STAUS_NORMAL	= 0								-- [积分战对手状态]没干过
Proto.PW_OP_STAUS_WIN		= Proto.PW_OP_STAUS_NORMAL + 1	-- [积分战对手状态]击败
Proto.PW_OP_STAUS_LOST		= Proto.PW_OP_STAUS_WIN + 1		-- [积分战对手状态]没击败
Proto.AJP_UNPAY	= 0						-- [竞技场查看跃迁列表支付类型]未支付
Proto.AJP_PAY	= Proto.AJP_UNPAY + 1	-- [竞技场查看跃迁列表支付类型]支付
Proto.ASCT_UNPAY	= 0						-- [竞技场赠送魅力方式]普通
Proto.ASCT_PAY		= Proto.ASCT_UNPAY + 1	-- [竞技场赠送魅力方式]支付

function Proto.parseSelfArenaBriefInfo(entry)
	local data={};
	data.bestRank=Proto.parseDWORD(entry); -- 最高排名
	data.currentRank=Proto.parseDWORD(entry); -- 当前排名
	return data;
end

function Proto.writeSelfArenaBriefInfo(msg,data)
	Proto.writeDWORD(msg,data.bestRank); -- 最高排名
	Proto.writeDWORD(msg,data.currentRank); -- 当前排名
end

function Proto.parseArenaAwardInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 
	data.arenaPoint=Proto.parseDWORD(entry); -- 
	data.gcash=Proto.parseDWORD(entry); -- 
	data.awardItems=Proto.parseVector(entry,Proto.parseDWORD); -- 
	return data;
end

function Proto.getArenaAwardInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeArenaAwardInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 
	Proto.writeDWORD(msg,data.arenaPoint); -- 
	Proto.writeDWORD(msg,data.gcash); -- 
	Proto.writeVector(msg,data.awardItems,Proto.writeDWORD); -- 
end

function Proto.parseArenaRewardLog(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 场次
	data.rewardTime=Proto.parseTIME_SEC(entry); -- 奖励时间
	data.rank1=Proto.parseCharacterID(entry); -- 第1名
	data.rank2=Proto.parseCharacterID(entry); -- 第2名
	data.rank3=Proto.parseCharacterID(entry); -- 第3名
	data.rank4=Proto.parseCharacterID(entry); -- 第4名
	data.rank5=Proto.parseCharacterID(entry); -- 第5名
	data.rank6=Proto.parseCharacterID(entry); -- 第6名
	data.rank7=Proto.parseCharacterID(entry); -- 第7名
	data.rank8=Proto.parseCharacterID(entry); -- 第8名
	data.rank9=Proto.parseCharacterID(entry); -- 第9名
	data.rank10=Proto.parseCharacterID(entry); -- 第10名
	data.keepCount=Proto.parseDWORD(entry); -- 连胜次数
	return data;
end

function Proto.getArenaRewardLogIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeArenaRewardLog(msg,data)
	Proto.writeDWORD(msg,data.id); -- 场次
	Proto.writeTIME_SEC(msg,data.rewardTime); -- 奖励时间
	Proto.writeCharacterID(msg,data.rank1); -- 第1名
	Proto.writeCharacterID(msg,data.rank2); -- 第2名
	Proto.writeCharacterID(msg,data.rank3); -- 第3名
	Proto.writeCharacterID(msg,data.rank4); -- 第4名
	Proto.writeCharacterID(msg,data.rank5); -- 第5名
	Proto.writeCharacterID(msg,data.rank6); -- 第6名
	Proto.writeCharacterID(msg,data.rank7); -- 第7名
	Proto.writeCharacterID(msg,data.rank8); -- 第8名
	Proto.writeCharacterID(msg,data.rank9); -- 第9名
	Proto.writeCharacterID(msg,data.rank10); -- 第10名
	Proto.writeDWORD(msg,data.keepCount); -- 连胜次数
end

function Proto.parseArenaStaticInfo(entry)
	local data={};
	data.nickname=Proto.parseNickName(entry); -- 玩家昵称
	data.icon=Proto.parseBYTE(entry); -- 玩家头像
	return data;
end

function Proto.writeArenaStaticInfo(msg,data)
	Proto.writeNickName(msg,data.nickname); -- 玩家昵称
	Proto.writeBYTE(msg,data.icon); -- 玩家头像
end

function Proto.parseArenaDynamicInfo(entry)
	local data={};
	data.rank=Proto.parseDWORD(entry); -- 排名
	data.power=Proto.parseDWORD(entry); -- 玩家战斗力
	return data;
end

function Proto.writeArenaDynamicInfo(msg,data)
	Proto.writeDWORD(msg,data.rank); -- 排名
	Proto.writeDWORD(msg,data.power); -- 玩家战斗力
end

function Proto.parseCharArenaDynamicInfo(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.dynamicInfo=Proto.parseArenaDynamicInfo(entry); -- 玩家动态信息
	return data;
end

function Proto.writeCharArenaDynamicInfo(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writeArenaDynamicInfo(msg,data.dynamicInfo); -- 玩家动态信息
end

function Proto.parseCharArenaInfo(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.staticInfo=Proto.parseArenaStaticInfo(entry); -- 玩家固定信息
	data.dynamicInfo=Proto.parseArenaDynamicInfo(entry); -- 玩家动态信息
	return data;
end

function Proto.writeCharArenaInfo(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writeArenaStaticInfo(msg,data.staticInfo); -- 玩家固定信息
	Proto.writeArenaDynamicInfo(msg,data.dynamicInfo); -- 玩家动态信息
end

function Proto.parseArenaEnemyInfo(entry)
	local data={};
	data.info=Proto.parseCharArenaInfo(entry); -- 玩家完整信息
	data.time=Proto.parseTIME_SEC(entry); -- 时间
	return data;
end

function Proto.writeArenaEnemyInfo(msg,data)
	Proto.writeCharArenaInfo(msg,data.info); -- 玩家完整信息
	Proto.writeTIME_SEC(msg,data.time); -- 时间
end

function Proto.parseCharArenaDetailInfo(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.charItemInfo=Proto.parseVector(entry,Proto.parseItemUnit); -- 玩家装备信息
	data.charPetInfo=Proto.parseVector(entry,Proto.parseBattleUnitInfo); -- 玩家宠物信息
	data.charArenaInfo=Proto.parseCharArenaInfo(entry); -- 玩家竞技场信息
	return data;
end

function Proto.writeCharArenaDetailInfo(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writeVector(msg,data.charItemInfo,Proto.writeItemUnit); -- 玩家装备信息
	Proto.writeVector(msg,data.charPetInfo,Proto.writeBattleUnitInfo); -- 玩家宠物信息
	Proto.writeCharArenaInfo(msg,data.charArenaInfo); -- 玩家竞技场信息
end

function Proto.parsePointWarRankInfo(entry)
	local data={};
	data.id=Proto.parseBYTE(entry); -- ID
	data.rank=Proto.parseBYTE(entry); -- 玩家分类
	data.percent=Proto.parseDWORD(entry); -- 排名比率
	return data;
end

function Proto.getPointWarRankInfoIDLen()
	return Proto.getBYTELen();
end

function Proto.writePointWarRankInfo(msg,data)
	Proto.writeBYTE(msg,data.id); -- ID
	Proto.writeBYTE(msg,data.rank); -- 玩家分类
	Proto.writeDWORD(msg,data.percent); -- 排名比率
end

function Proto.parsePointWarRankAwardInfo(entry)
	local data={};
	data.id=Proto.parseBYTE(entry); -- ID
	data.pointWarID=Proto.parseBYTE(entry); -- 积分战ID
	data.rank=Proto.parseBYTE(entry); -- 玩家分类
	data.award=Proto.parseDWORD(entry); -- 奖励
	return data;
end

function Proto.getPointWarRankAwardInfoIDLen()
	return Proto.getBYTELen();
end

function Proto.writePointWarRankAwardInfo(msg,data)
	Proto.writeBYTE(msg,data.id); -- ID
	Proto.writeBYTE(msg,data.pointWarID); -- 积分战ID
	Proto.writeBYTE(msg,data.rank); -- 玩家分类
	Proto.writeDWORD(msg,data.award); -- 奖励
end

function Proto.parsePointWarPointInfo(entry)
	local data={};
	data.id=Proto.parseBYTE(entry); -- ID
	data.win=Proto.parseBYTE(entry); -- 单券胜次
	data.point=Proto.parseBYTE(entry); -- 积分
	data.award=Proto.parseDWORD(entry); -- 奖励
	return data;
end

function Proto.getPointWarPointInfoIDLen()
	return Proto.getBYTELen();
end

function Proto.writePointWarPointInfo(msg,data)
	Proto.writeBYTE(msg,data.id); -- ID
	Proto.writeBYTE(msg,data.win); -- 单券胜次
	Proto.writeBYTE(msg,data.point); -- 积分
	Proto.writeDWORD(msg,data.award); -- 奖励
end

function Proto.parsePointWarTitleInfo(entry)
	local data={};
	data.id=Proto.parseBYTE(entry); -- ID
	data.petBassElement=Proto.parseVector(entry,Proto.parseDWORD); -- 宠物基本类型
	return data;
end

function Proto.getPointWarTitleInfoIDLen()
	return Proto.getBYTELen();
end

function Proto.writePointWarTitleInfo(msg,data)
	Proto.writeBYTE(msg,data.id); -- ID
	Proto.writeVector(msg,data.petBassElement,Proto.writeDWORD); -- 宠物基本类型
end

function Proto.parsePointWarInfo(entry)
	local data={};
	data.id=Proto.parseBYTE(entry); -- ID
	data.pointWarName=Proto.parseString(entry); -- 积分战名称
	data.beginTime=Proto.parseTIME_SEC(entry); -- 开始时间
	data.holdTimeLength=Proto.parseTIME_SEC(entry); -- 举行时间时长(秒)
	data.refreshTimeLength=Proto.parseTIME_SEC(entry); -- 更新周期时长(秒)
	data.isRandom=Proto.parseBYTE(entry); -- 是否随机主题
	data.titleType=Proto.parseBYTE(entry); -- 主题类型
	data.ticketID=Proto.parseDWORD(entry); -- 挑战券道具类型
	data.ticketCount=Proto.parseDWORD(entry); -- 挑战券数量
	data.awards=Proto.parseVector(entry,Proto.parseDWORD); -- 奖励
	return data;
end

function Proto.getPointWarInfoIDLen()
	return Proto.getBYTELen();
end

function Proto.writePointWarInfo(msg,data)
	Proto.writeBYTE(msg,data.id); -- ID
	Proto.writeString(msg,data.pointWarName); -- 积分战名称
	Proto.writeTIME_SEC(msg,data.beginTime); -- 开始时间
	Proto.writeTIME_SEC(msg,data.holdTimeLength); -- 举行时间时长(秒)
	Proto.writeTIME_SEC(msg,data.refreshTimeLength); -- 更新周期时长(秒)
	Proto.writeBYTE(msg,data.isRandom); -- 是否随机主题
	Proto.writeBYTE(msg,data.titleType); -- 主题类型
	Proto.writeDWORD(msg,data.ticketID); -- 挑战券道具类型
	Proto.writeDWORD(msg,data.ticketCount); -- 挑战券数量
	Proto.writeVector(msg,data.awards,Proto.writeDWORD); -- 奖励
end

function Proto.parsePointWarOpInfo(entry)
	local data={};
	data.pointWarId=Proto.parseBYTE(entry); -- 积分战ID
	data.opid=Proto.parseCharacterID(entry); -- 对手id
	data.pos=Proto.parseDWORD(entry); -- 顺位
	data.attack=Proto.parseDWORD(entry); -- 攻击力
	data.status=Proto.parseBYTE(entry); -- 状态
	return data;
end

function Proto.writePointWarOpInfo(msg,data)
	Proto.writeBYTE(msg,data.pointWarId); -- 积分战ID
	Proto.writeCharacterID(msg,data.opid); -- 对手id
	Proto.writeDWORD(msg,data.pos); -- 顺位
	Proto.writeDWORD(msg,data.attack); -- 攻击力
	Proto.writeBYTE(msg,data.status); -- 状态
end

function Proto.parsePointWarCharacter(entry)
	local data={};
	data.pwid=Proto.parseBYTE(entry); -- pwid
	data.charid=Proto.parseCharacterID(entry); -- charid
	data.nickname=Proto.parseNickName(entry); -- 昵称
	data.rank=Proto.parseBYTE(entry); -- 级别
	data.pos=Proto.parseDWORD(entry); -- 顺位
	data.points=Proto.parseDWORD(entry); -- 积分
	data.totalwin=Proto.parseDWORD(entry); -- 总胜场
	data.win=Proto.parseBYTE(entry); -- 本券胜场
	data.leftCount=Proto.parseBYTE(entry); -- 本券剩余场次
	data.comb=Proto.parseDWORD(entry); -- 连胜
	data.maxComb=Proto.parseDWORD(entry); -- 最长连胜
	data.lastwin=Proto.parseBYTE(entry); -- 上次是否胜利
	data.total=Proto.parseDWORD(entry); -- 总场次
	data.attack=Proto.parseDWORD(entry); -- 攻击力
	return data;
end

function Proto.writePointWarCharacter(msg,data)
	Proto.writeBYTE(msg,data.pwid); -- pwid
	Proto.writeCharacterID(msg,data.charid); -- charid
	Proto.writeNickName(msg,data.nickname); -- 昵称
	Proto.writeBYTE(msg,data.rank); -- 级别
	Proto.writeDWORD(msg,data.pos); -- 顺位
	Proto.writeDWORD(msg,data.points); -- 积分
	Proto.writeDWORD(msg,data.totalwin); -- 总胜场
	Proto.writeBYTE(msg,data.win); -- 本券胜场
	Proto.writeBYTE(msg,data.leftCount); -- 本券剩余场次
	Proto.writeDWORD(msg,data.comb); -- 连胜
	Proto.writeDWORD(msg,data.maxComb); -- 最长连胜
	Proto.writeBYTE(msg,data.lastwin); -- 上次是否胜利
	Proto.writeDWORD(msg,data.total); -- 总场次
	Proto.writeDWORD(msg,data.attack); -- 攻击力
end

function Proto.parsePointWarAwards(entry)
	local data={};
	data.charid=Proto.parseCharacterID(entry); -- 玩家id
	data.mailContentType=Proto.parseWORD(entry); -- 邮件类型
	data.param=Proto.parseVector(entry,Proto.parsestd_string); -- 奖励邮件参数
	data.award=Proto.parseDWORD(entry); -- 奖励编码
	return data;
end

function Proto.writePointWarAwards(msg,data)
	Proto.writeCharacterID(msg,data.charid); -- 玩家id
	Proto.writeWORD(msg,data.mailContentType); -- 邮件类型
	Proto.writeVector(msg,data.param,Proto.writestd_string); -- 奖励邮件参数
	Proto.writeDWORD(msg,data.award); -- 奖励编码
end

function Proto.parsePointWarInfoClient(entry)
	local data={};
	data.pointWarInfo=Proto.parsePointWarInfo(entry); -- 积分战信息
	data.holdTimes=Proto.parseDWORD(entry); -- 举行次数
	data.pointWarPointInfo=Proto.parseVector(entry,Proto.parsePointWarPointInfo); -- 积分战积分规则
	data.rankAwardInfo=Proto.parseVector(entry,Proto.parsePointWarRankAwardInfo); -- 积分战分级奖励
	data.hasPointWarCharInfo=Proto.parseBYTE(entry); -- 是否有玩家信息
	if (data.hasPointWarCharInfo ==1) then
		data.pointWarCharacterInfo=Proto.parsePointWarCharacter(entry); -- 玩家信息
		data.pointWarOpInfo=Proto.parseVector(entry,Proto.parsePointWarOpInfo); -- 玩家对手信息
	end
	return data;
end

function Proto.writePointWarInfoClient(msg,data)
	Proto.writePointWarInfo(msg,data.pointWarInfo); -- 积分战信息
	Proto.writeDWORD(msg,data.holdTimes); -- 举行次数
	Proto.writeVector(msg,data.pointWarPointInfo,Proto.writePointWarPointInfo); -- 积分战积分规则
	Proto.writeVector(msg,data.rankAwardInfo,Proto.writePointWarRankAwardInfo); -- 积分战分级奖励
	Proto.writeBYTE(msg,data.hasPointWarCharInfo); -- 是否有玩家信息
	if (data.hasPointWarCharInfo ==1) then
		Proto.writePointWarCharacter(msg,data.pointWarCharacterInfo); -- 玩家信息
		Proto.writeVector(msg,data.pointWarOpInfo,Proto.writePointWarOpInfo); -- 玩家对手信息
	end
end

function Proto.parseArenaEnemy(entry)
	local data={};
	data.enemyCharID=Proto.parseCharacterID(entry); -- 仇人id
	data.becomeTime=Proto.parseTIME_SEC(entry); -- 成为仇人的时间
	return data;
end

function Proto.writeArenaEnemy(msg,data)
	Proto.writeCharacterID(msg,data.enemyCharID); -- 仇人id
	Proto.writeTIME_SEC(msg,data.becomeTime); -- 成为仇人的时间
end

function Proto.parseCharArenaDetailInfoEx(entry)
	local data={};
	data.charDetailInfo=Proto.parseCharArenaDetailInfo(entry); -- 详细信息
	data.charConfraternityID=Proto.parseDWORD(entry); -- 公会ID
	return data;
end

function Proto.writeCharArenaDetailInfoEx(msg,data)
	Proto.writeCharArenaDetailInfo(msg,data.charDetailInfo); -- 详细信息
	Proto.writeDWORD(msg,data.charConfraternityID); -- 公会ID
end

function Proto.parseCharArenaCharmInfo(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 玩家ID
	data.staticInfo=Proto.parseArenaStaticInfo(entry); -- 固定信息
	data.charConfraternityID=Proto.parseDWORD(entry); -- 公会ID
	data.charmPoint=Proto.parseDWORD(entry); -- 魅力点
	return data;
end

function Proto.writeCharArenaCharmInfo(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 玩家ID
	Proto.writeArenaStaticInfo(msg,data.staticInfo); -- 固定信息
	Proto.writeDWORD(msg,data.charConfraternityID); -- 公会ID
	Proto.writeDWORD(msg,data.charmPoint); -- 魅力点
end

function Proto.parsePetRaceArenaInfo(entry)
	local data={};
	data.elementType=Proto.parseDWORD(entry); -- 宠物属性
	data.petClass=Proto.parseDWORD(entry); -- 宠物等阶
	return data;
end

function Proto.writePetRaceArenaInfo(msg,data)
	Proto.writeDWORD(msg,data.elementType); -- 宠物属性
	Proto.writeDWORD(msg,data.petClass); -- 宠物等阶
end

function Proto.parseCharPetRaceArenaInfo(entry)
	local data={};
	data.petRaceArenaInfo=Proto.parsePetRaceArenaInfo(entry); -- 宠物属性信息
	data.charArenaInfo=Proto.parseCharArenaInfo(entry); -- 玩家竞技场信息
	return data;
end

function Proto.writeCharPetRaceArenaInfo(msg,data)
	Proto.writePetRaceArenaInfo(msg,data.petRaceArenaInfo); -- 宠物属性信息
	Proto.writeCharArenaInfo(msg,data.charArenaInfo); -- 玩家竞技场信息
end

function Proto.parseCharPetRaceArenaDetailInfo(entry)
	local data={};
	data.petRaceArenaInfo=Proto.parsePetRaceArenaInfo(entry); -- 宠物属性信息
	data.charArenaDetailInfo=Proto.parseCharArenaDetailInfo(entry); -- 玩家竞技场详细信息
	return data;
end

function Proto.writeCharPetRaceArenaDetailInfo(msg,data)
	Proto.writePetRaceArenaInfo(msg,data.petRaceArenaInfo); -- 宠物属性信息
	Proto.writeCharArenaDetailInfo(msg,data.charArenaDetailInfo); -- 玩家竞技场详细信息
end

function Proto.parseWArenaRankAward(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 
	data.rankRange=Proto.parseVector(entry,Proto.parseDWORD); -- 
	data.mail=Proto.parseDWORD(entry); -- 
	data.rewardElement=Proto.parseVector(entry,Proto.parseDWORD); -- 品级
	return data;
end

function Proto.getWArenaRankAwardIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeWArenaRankAward(msg,data)
	Proto.writeDWORD(msg,data.id); -- 
	Proto.writeVector(msg,data.rankRange,Proto.writeDWORD); -- 
	Proto.writeDWORD(msg,data.mail); -- 
	Proto.writeVector(msg,data.rewardElement,Proto.writeDWORD); -- 品级
end

