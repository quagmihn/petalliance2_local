-- Net.Proto.Proto_Prentice_Types

Proto.PDR_MASTER	= 0							-- [断绝师徒关系原因]师傅主动断绝关系
Proto.PDR_PRENTICE	= Proto.PDR_MASTER + 1		-- [断绝师徒关系原因]徒弟主动断绝关系
Proto.PDR_LEVEL		= Proto.PDR_PRENTICE + 1	-- [断绝师徒关系原因]等级超过限制

function Proto.parsePrenticeBaseInfo(entry)
	local data={};
	data.charID=Proto.parseUserID(entry); -- 角色ID
	data.charName=Proto.parseNickName(entry); -- 角色昵称
	data.startTime=Proto.parseTIME_SEC(entry); -- 收徒时间(时间戳)
	data.startAchievement=Proto.parseWORD(entry); -- 收徒时最高成就等级
	return data;
end

function Proto.writePrenticeBaseInfo(msg,data)
	Proto.writeUserID(msg,data.charID); -- 角色ID
	Proto.writeNickName(msg,data.charName); -- 角色昵称
	Proto.writeTIME_SEC(msg,data.startTime); -- 收徒时间(时间戳)
	Proto.writeWORD(msg,data.startAchievement); -- 收徒时最高成就等级
end

function Proto.parsePrenticeExInfo(entry)
	local data={};
	data.isOnline=Proto.parseBYTE(entry); -- 是否在线(1:在线;0:不在线)
	data.isChannel=Proto.parseBYTE(entry); -- 是否在频道(1:在频道;0:不在频道)
	data.channelID=Proto.parseChannelID(entry); -- 频道ID
	data.achievementID=Proto.parseWORD(entry); -- 当前成就ID
	return data;
end

function Proto.writePrenticeExInfo(msg,data)
	Proto.writeBYTE(msg,data.isOnline); -- 是否在线(1:在线;0:不在线)
	Proto.writeBYTE(msg,data.isChannel); -- 是否在频道(1:在频道;0:不在频道)
	Proto.writeChannelID(msg,data.channelID); -- 频道ID
	Proto.writeWORD(msg,data.achievementID); -- 当前成就ID
end

function Proto.parsePrenticeAchievementInfo(entry)
	local data={};
	data.id=Proto.parseWORD(entry); -- 成就ID
	data.step=Proto.parseDWORD(entry); -- 步骤编号(0开始)
	return data;
end

function Proto.getPrenticeAchievementInfoIDLen()
	return Proto.getWORDLen();
end

function Proto.writePrenticeAchievementInfo(msg,data)
	Proto.writeWORD(msg,data.id); -- 成就ID
	Proto.writeDWORD(msg,data.step); -- 步骤编号(0开始)
end

