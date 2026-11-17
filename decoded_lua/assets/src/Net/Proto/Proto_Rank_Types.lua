-- Net.Proto.Proto_Rank_Types

Proto.CLT_USE_GCASH			= 0									-- [玩家日志类型]使用G币
Proto.CLT_USE_MCASH			= Proto.CLT_USE_GCASH + 1			-- [玩家日志类型]使用M币
Proto.CLT_BOSS_DAMAGE		= Proto.CLT_USE_MCASH + 1			-- [玩家日志类型]boss最高伤害
Proto.CLT_CHANLLENAGE_USER	= Proto.CLT_BOSS_DAMAGE + 1			-- [玩家日志类型]挑战好友胜次
Proto.CLT_PET_ALBUM_POINTS	= Proto.CLT_CHANLLENAGE_USER + 1	-- [玩家日志类型]宠物图鉴点数
Proto.CLT_COUNT				= Proto.CLT_PET_ALBUM_POINTS + 1	-- [玩家日志类型]总数
Proto.RT_PET_POWER			= 0								-- [排行榜类型]宠物战斗力
Proto.RT_ACHIEVEMENT		= Proto.RT_PET_POWER + 1		-- [排行榜类型]成就
Proto.RT_USE_GCASH			= Proto.RT_ACHIEVEMENT + 1		-- [排行榜类型]使用G币
Proto.RT_BOSS_DAMAGE		= Proto.RT_USE_GCASH + 1		-- [排行榜类型]boss最高伤害
Proto.RT_CHANLLENAGE_UER	= Proto.RT_BOSS_DAMAGE + 1		-- [排行榜类型]挑战好友胜次
Proto.RT_PET_ALBUM_POINTS	= Proto.RT_CHANLLENAGE_UER + 1	-- [排行榜类型]宠物图鉴积分
Proto.RT_COUNT				= Proto.RT_PET_ALBUM_POINTS + 1	-- [排行榜类型]总数

function Proto.parseCharacterLogRecord(entry)
	local data={};
	data.type=Proto.parseBYTE(entry); -- 日志类型
	data.value=Proto.parseDWORD(entry); -- 数值
	return data;
end

function Proto.writeCharacterLogRecord(msg,data)
	Proto.writeBYTE(msg,data.type); -- 日志类型
	Proto.writeDWORD(msg,data.value); -- 数值
end

function Proto.parsePetPowerRankInfo(entry)
	local data={};
	data.rank=Proto.parseDWORD(entry); -- 排行
	data.id=Proto.parseDWORD(entry); -- 宠物ID
	data.petRace=Proto.parseDWORD(entry); -- 种族
	data.ownerID=Proto.parseDWORD(entry); -- 主人ID
	data.power=Proto.parseDWORD(entry); -- 战斗力
	return data;
end

function Proto.getPetPowerRankInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writePetPowerRankInfo(msg,data)
	Proto.writeDWORD(msg,data.rank); -- 排行
	Proto.writeDWORD(msg,data.id); -- 宠物ID
	Proto.writeDWORD(msg,data.petRace); -- 种族
	Proto.writeDWORD(msg,data.ownerID); -- 主人ID
	Proto.writeDWORD(msg,data.power); -- 战斗力
end

function Proto.parseAchievementRankInfo(entry)
	local data={};
	data.rank=Proto.parseDWORD(entry); -- 排行
	data.id=Proto.parseDWORD(entry); -- 玩家ID
	data.power=Proto.parseDWORD(entry); -- 战斗力
	return data;
end

function Proto.getAchievementRankInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeAchievementRankInfo(msg,data)
	Proto.writeDWORD(msg,data.rank); -- 排行
	Proto.writeDWORD(msg,data.id); -- 玩家ID
	Proto.writeDWORD(msg,data.power); -- 战斗力
end

function Proto.parseUseGCashRankInfo(entry)
	local data={};
	data.rank=Proto.parseDWORD(entry); -- 排行
	data.id=Proto.parseDWORD(entry); -- 玩家ID
	data.power=Proto.parseDWORD(entry); -- 战斗力
	return data;
end

function Proto.getUseGCashRankInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeUseGCashRankInfo(msg,data)
	Proto.writeDWORD(msg,data.rank); -- 排行
	Proto.writeDWORD(msg,data.id); -- 玩家ID
	Proto.writeDWORD(msg,data.power); -- 战斗力
end

function Proto.parseBossDamageRankInfo(entry)
	local data={};
	data.rank=Proto.parseDWORD(entry); -- 排行
	data.id=Proto.parseDWORD(entry); -- 玩家ID
	data.chanllenageTimes=Proto.parseDWORD(entry); -- 挑战次数
	data.power=Proto.parseDWORD(entry); -- boss最高伤害
	return data;
end

function Proto.getBossDamageRankInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeBossDamageRankInfo(msg,data)
	Proto.writeDWORD(msg,data.rank); -- 排行
	Proto.writeDWORD(msg,data.id); -- 玩家ID
	Proto.writeDWORD(msg,data.chanllenageTimes); -- 挑战次数
	Proto.writeDWORD(msg,data.power); -- boss最高伤害
end

function Proto.parseChanllenageUserRankInfo(entry)
	local data={};
	data.rank=Proto.parseDWORD(entry); -- 排行
	data.id=Proto.parseDWORD(entry); -- 玩家ID
	data.rate=Proto.parseDWORD(entry); -- 胜率
	data.power=Proto.parseDWORD(entry); -- 挑战好友胜次
	return data;
end

function Proto.getChanllenageUserRankInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeChanllenageUserRankInfo(msg,data)
	Proto.writeDWORD(msg,data.rank); -- 排行
	Proto.writeDWORD(msg,data.id); -- 玩家ID
	Proto.writeDWORD(msg,data.rate); -- 胜率
	Proto.writeDWORD(msg,data.power); -- 挑战好友胜次
end

function Proto.parsePetAlbumPointsRankInfo(entry)
	local data={};
	data.rank=Proto.parseDWORD(entry); -- 排行
	data.id=Proto.parseDWORD(entry); -- 玩家ID
	data.power=Proto.parseDWORD(entry); -- 积分
	return data;
end

function Proto.getPetAlbumPointsRankInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writePetAlbumPointsRankInfo(msg,data)
	Proto.writeDWORD(msg,data.rank); -- 排行
	Proto.writeDWORD(msg,data.id); -- 玩家ID
	Proto.writeDWORD(msg,data.power); -- 积分
end

