-- Net.Proto.Proto_CrossWorld_Types

function Proto.parseCrossWorldRoundInfo(entry)
	local data={};
	data.winCount=Proto.parseWORD(entry); -- 胜出人数
	data.round=Proto.parseBYTE(entry); -- 第几轮,从0开始
	data.battleTime=Proto.parseTIME_SEC(entry); -- 比赛时间
	return data;
end

function Proto.writeCrossWorldRoundInfo(msg,data)
	Proto.writeWORD(msg,data.winCount); -- 胜出人数
	Proto.writeBYTE(msg,data.round); -- 第几轮,从0开始
	Proto.writeTIME_SEC(msg,data.battleTime); -- 比赛时间
end

function Proto.parseCrossWorldGambleDateInfo(entry)
	local data={};
	data.gambleWinCount=Proto.parseWORD(entry); -- 结算胜出人数
	data.money=Proto.parseDWORD(entry); -- 赌注
	data.awardTableID=Proto.parseDWORD(entry); -- 奖励组ID
	return data;
end

function Proto.writeCrossWorldGambleDateInfo(msg,data)
	Proto.writeWORD(msg,data.gambleWinCount); -- 结算胜出人数
	Proto.writeDWORD(msg,data.money); -- 赌注
	Proto.writeDWORD(msg,data.awardTableID); -- 奖励组ID
end

function Proto.parseCrossWorldAwardInfo(entry)
	local data={};
	data.winCount=Proto.parseWORD(entry); -- 胜出人数
	data.awardTableID=Proto.parseDWORD(entry); -- 奖励组ID
	data.gambleInfos=Proto.parseVector(entry,Proto.parseCrossWorldGambleDateInfo); -- 赌博配置信息
	return data;
end

function Proto.writeCrossWorldAwardInfo(msg,data)
	Proto.writeWORD(msg,data.winCount); -- 胜出人数
	Proto.writeDWORD(msg,data.awardTableID); -- 奖励组ID
	Proto.writeVector(msg,data.gambleInfos,Proto.writeCrossWorldGambleDateInfo); -- 赌博配置信息
end

function Proto.parseCrossWorldNoticeInfo(entry)
	local data={};
	data.winCount=Proto.parseWORD(entry); -- 胜出人数
	data.content=Proto.parseString(entry); -- 公告内容
	return data;
end

function Proto.writeCrossWorldNoticeInfo(msg,data)
	Proto.writeWORD(msg,data.winCount); -- 胜出人数
	Proto.writeString(msg,data.content); -- 公告内容
end

function Proto.parseCrossWorldNoticeRoundInfo(entry)
	local data={};
	data.winCount=Proto.parseWORD(entry); -- 胜出人数
	data.round=Proto.parseBYTE(entry); -- 第几轮,从0开始
	data.content=Proto.parseString(entry); -- 公告内容
	return data;
end

function Proto.writeCrossWorldNoticeRoundInfo(msg,data)
	Proto.writeWORD(msg,data.winCount); -- 胜出人数
	Proto.writeBYTE(msg,data.round); -- 第几轮,从0开始
	Proto.writeString(msg,data.content); -- 公告内容
end

function Proto.parseCrossWorldLoseMailInfo(entry)
	local data={};
	data.winCount=Proto.parseWORD(entry); -- 胜出人数
	data.content=Proto.parseString(entry); -- 邮件内容
	return data;
end

function Proto.writeCrossWorldLoseMailInfo(msg,data)
	Proto.writeWORD(msg,data.winCount); -- 胜出人数
	Proto.writeString(msg,data.content); -- 邮件内容
end

function Proto.parseCrossWorldDataInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 必须为0,与程序代码兼容
	data.startDate=Proto.parseString(entry); -- 初始日期
	data.periodDays=Proto.parseBYTE(entry); -- 持续天数
	data.enrollTime=Proto.parseDWORD(entry); -- 报名时间
	data.freezeSecs=Proto.parseDWORD(entry); -- 赛前冻结秒数
	data.champoinAwards=Proto.parseString(entry); -- 冠军奖励描述
	data.championZoneAwardTableID=Proto.parseDWORD(entry); -- 冠军区每日领取励
	data.normalZoneAwardTableID=Proto.parseDWORD(entry); -- 非冠军区每日领取励
	data.rounds=Proto.parseVector(entry,Proto.parseCrossWorldRoundInfo); -- 赛程信息
	data.notices=Proto.parseVector(entry,Proto.parseCrossWorldNoticeInfo); -- 公告信息
	data.roundNotices=Proto.parseVector(entry,Proto.parseCrossWorldNoticeRoundInfo); -- 轮次公告信息
	data.loseMails=Proto.parseVector(entry,Proto.parseCrossWorldLoseMailInfo); -- 比赛失利邮件信息
	data.awards=Proto.parseVector(entry,Proto.parseCrossWorldAwardInfo); -- 奖励信息
	return data;
end

function Proto.getCrossWorldDataInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeCrossWorldDataInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 必须为0,与程序代码兼容
	Proto.writeString(msg,data.startDate); -- 初始日期
	Proto.writeBYTE(msg,data.periodDays); -- 持续天数
	Proto.writeDWORD(msg,data.enrollTime); -- 报名时间
	Proto.writeDWORD(msg,data.freezeSecs); -- 赛前冻结秒数
	Proto.writeString(msg,data.champoinAwards); -- 冠军奖励描述
	Proto.writeDWORD(msg,data.championZoneAwardTableID); -- 冠军区每日领取励
	Proto.writeDWORD(msg,data.normalZoneAwardTableID); -- 非冠军区每日领取励
	Proto.writeVector(msg,data.rounds,Proto.writeCrossWorldRoundInfo); -- 赛程信息
	Proto.writeVector(msg,data.notices,Proto.writeCrossWorldNoticeInfo); -- 公告信息
	Proto.writeVector(msg,data.roundNotices,Proto.writeCrossWorldNoticeRoundInfo); -- 轮次公告信息
	Proto.writeVector(msg,data.loseMails,Proto.writeCrossWorldLoseMailInfo); -- 比赛失利邮件信息
	Proto.writeVector(msg,data.awards,Proto.writeCrossWorldAwardInfo); -- 奖励信息
end

function Proto.parseCrossWorldPlayerInfo(entry)
	local data={};
	data.icon=Proto.parseBYTE(entry); -- 头像
	data.zoneID=Proto.parseDWORD(entry); -- 大区ID
	data.zoneName=Proto.parseString(entry); -- 大区名称
	data.charID=Proto.parseDWORD(entry); -- 角色ID
	data.nickName=Proto.parseNickName(entry); -- 昵称
	return data;
end

function Proto.writeCrossWorldPlayerInfo(msg,data)
	Proto.writeBYTE(msg,data.icon); -- 头像
	Proto.writeDWORD(msg,data.zoneID); -- 大区ID
	Proto.writeString(msg,data.zoneName); -- 大区名称
	Proto.writeDWORD(msg,data.charID); -- 角色ID
	Proto.writeNickName(msg,data.nickName); -- 昵称
end

function Proto.parseCrossWorldBattleUnit(entry)
	local data={};
	data.pets=Proto.parseVector(entry,Proto.parseBattleUnitInfo); -- 宠物
	data.equips=Proto.parseVector(entry,Proto.parseItemUnit); -- 装备
	data.hasAidePet=Proto.parseBYTE(entry); -- 是否有伴灵
	if (data.hasAidePet~=0) then
		data.aidePet=Proto.parsePetAideDetailInfo(entry); -- 伴灵详细信息
	end
	return data;
end

function Proto.writeCrossWorldBattleUnit(msg,data)
	Proto.writeVector(msg,data.pets,Proto.writeBattleUnitInfo); -- 宠物
	Proto.writeVector(msg,data.equips,Proto.writeItemUnit); -- 装备
	Proto.writeBYTE(msg,data.hasAidePet); -- 是否有伴灵
	if (data.hasAidePet~=0) then
		Proto.writePetAideDetailInfo(msg,data.aidePet); -- 伴灵详细信息
	end
end

function Proto.parseCrossWorldRankPlayerInfo(entry)
	local data={};
	data.player=Proto.parseCrossWorldPlayerInfo(entry); -- 玩家
	data.unit=Proto.parseCrossWorldBattleUnit(entry); -- 战斗单元
	return data;
end

function Proto.writeCrossWorldRankPlayerInfo(msg,data)
	Proto.writeCrossWorldPlayerInfo(msg,data.player); -- 玩家
	Proto.writeCrossWorldBattleUnit(msg,data.unit); -- 战斗单元
end

function Proto.parseCrossWorldSelfZonePlayerInfo(entry)
	local data={};
	data.zoneID=Proto.parseDWORD(entry); -- 大区ID
	data.charID=Proto.parseDWORD(entry); -- 角色ID
	data.nickName=Proto.parseNickName(entry); -- 昵称
	data.icon=Proto.parseBYTE(entry); -- 头像
	data.winCount=Proto.parseWORD(entry); -- 胜出人数
	data.alive=Proto.parseBYTE(entry); -- 是否活着,0:不活;非0:活着
	return data;
end

function Proto.writeCrossWorldSelfZonePlayerInfo(msg,data)
	Proto.writeDWORD(msg,data.zoneID); -- 大区ID
	Proto.writeDWORD(msg,data.charID); -- 角色ID
	Proto.writeNickName(msg,data.nickName); -- 昵称
	Proto.writeBYTE(msg,data.icon); -- 头像
	Proto.writeWORD(msg,data.winCount); -- 胜出人数
	Proto.writeBYTE(msg,data.alive); -- 是否活着,0:不活;非0:活着
end

function Proto.parseCrossWorldBattleInfo(entry)
	local data={};
	data.winCount=Proto.parseWORD(entry); -- 胜出人数
	data.round=Proto.parseDWORD(entry); -- 比赛场次
	data.playerA=Proto.parseCrossWorldPlayerInfo(entry); -- 玩家A
	data.playerB=Proto.parseCrossWorldPlayerInfo(entry); -- 玩家B，如果玩家B的昵称为空表示不存在
	data.winner=Proto.parseBYTE(entry); -- 0代表 playerA胜利
	data.recordID=Proto.parseDWORD(entry); -- 战斗记录ID
	return data;
end

function Proto.writeCrossWorldBattleInfo(msg,data)
	Proto.writeWORD(msg,data.winCount); -- 胜出人数
	Proto.writeDWORD(msg,data.round); -- 比赛场次
	Proto.writeCrossWorldPlayerInfo(msg,data.playerA); -- 玩家A
	Proto.writeCrossWorldPlayerInfo(msg,data.playerB); -- 玩家B，如果玩家B的昵称为空表示不存在
	Proto.writeBYTE(msg,data.winner); -- 0代表 playerA胜利
	Proto.writeDWORD(msg,data.recordID); -- 战斗记录ID
end

function Proto.parseCrossWorldGambleInfo(entry)
	local data={};
	data.charID=Proto.parseDWORD(entry); -- 下注玩家id
	data.winCount=Proto.parseWORD(entry); -- 胜出人数
	data.gambleWinCount=Proto.parseWORD(entry); -- 结算胜出人数
	data.winnerID=Proto.parseDWORD(entry); -- 获胜玩家ID
	data.money=Proto.parseDWORD(entry); -- 赌注
	return data;
end

function Proto.writeCrossWorldGambleInfo(msg,data)
	Proto.writeDWORD(msg,data.charID); -- 下注玩家id
	Proto.writeWORD(msg,data.winCount); -- 胜出人数
	Proto.writeWORD(msg,data.gambleWinCount); -- 结算胜出人数
	Proto.writeDWORD(msg,data.winnerID); -- 获胜玩家ID
	Proto.writeDWORD(msg,data.money); -- 赌注
end

function Proto.parseCrossWorldGambleAwardInfo(entry)
	local data={};
	data.index=Proto.parseDWORD(entry); -- 第几届
	data.gambleInfo=Proto.parseCrossWorldGambleInfo(entry); -- 下注信息
	return data;
end

function Proto.writeCrossWorldGambleAwardInfo(msg,data)
	Proto.writeDWORD(msg,data.index); -- 第几届
	Proto.writeCrossWorldGambleInfo(msg,data.gambleInfo); -- 下注信息
end

