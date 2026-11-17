-- Net.Proto.Proto_ChatUser_Types

Proto.US_ONLINE		= 0						-- [玩家状态的枚举]在线
Proto.US_BUSY		= Proto.US_ONLINE + 1	-- [玩家状态的枚举]忙
Proto.US_AWAY		= Proto.US_BUSY + 1		-- [玩家状态的枚举]离开
Proto.US_HIDDEN		= Proto.US_AWAY + 1		-- [玩家状态的枚举]隐身
Proto.US_OFFLINE	= Proto.US_HIDDEN + 1	-- [玩家状态的枚举]离线
Proto.PM_ANYBODY	= 0							-- [个人消息的选项枚举]任何人
Proto.PM_NOANYBODY	= Proto.PM_ANYBODY + 1		-- [个人消息的选项枚举]不接受他人信息
Proto.PM_ONLYFRIEND	= Proto.PM_NOANYBODY + 1	-- [个人消息的选项枚举]仅仅接受好友信息
Proto.PM_ONLYTEAM	= Proto.PM_ONLYFRIEND + 1	-- [个人消息的选项枚举]只接受同队或同帮会或好友的信息
Proto.POSOP_ALL		= 0							-- [是否公开个人当前位置的枚举]所有人
Proto.POSOP_FRIEND	= Proto.POSOP_ALL + 1		-- [是否公开个人当前位置的枚举]好友
Proto.POSOP_NOBODY	= Proto.POSOP_FRIEND + 1	-- [是否公开个人当前位置的枚举]不公开

function Proto.parseMessageInfo(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 接收玩家的ID
	data.senderid=Proto.parseCharacterID(entry); -- 发送者ID
	data.nickname=Proto.parseNickName(entry); -- 发送人的名字
	data.time=Proto.parseSendTime(entry); -- 发送时间
	data.msg=Proto.parseUserMsg(entry); -- 消息内容
	data.msgid=Proto.parseMsgID(entry); -- 消息ID
	return data;
end

function Proto.writeMessageInfo(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 接收玩家的ID
	Proto.writeCharacterID(msg,data.senderid); -- 发送者ID
	Proto.writeNickName(msg,data.nickname); -- 发送人的名字
	Proto.writeSendTime(msg,data.time); -- 发送时间
	Proto.writeUserMsg(msg,data.msg); -- 消息内容
	Proto.writeMsgID(msg,data.msgid); -- 消息ID
end

function Proto.parseUserBaseInfo(entry)
	local data={};
	data.id=Proto.parseCharacterID(entry); -- 玩家的ID
	data.name=Proto.parseNickName(entry); -- 玩家名字
	data.nationality=Proto.parseCountryID(entry); -- 玩家国籍
	data.faceid=Proto.parseFaceIconID(entry); -- 头像ID
	data.gender=Proto.parseBYTE(entry); -- 玩家性别
	data.state=Proto.parseBYTE(entry); -- 玩家状态
	data.hasActiveGarden=Proto.parseBYTE(entry); -- 是否有活动庄园
	if (data.hasActiveGarden~=0) then
		data.activeGardenTown=Proto.parseTownID(entry); -- 活动庄园所在小镇
		data.activeGardenID=Proto.parseGardenID(entry); -- 活动庄园ID
	end
	return data;
end

function Proto.getUserBaseInfoIDLen()
	return Proto.getCharacterIDLen();
end

function Proto.writeUserBaseInfo(msg,data)
	Proto.writeCharacterID(msg,data.id); -- 玩家的ID
	Proto.writeNickName(msg,data.name); -- 玩家名字
	Proto.writeCountryID(msg,data.nationality); -- 玩家国籍
	Proto.writeFaceIconID(msg,data.faceid); -- 头像ID
	Proto.writeBYTE(msg,data.gender); -- 玩家性别
	Proto.writeBYTE(msg,data.state); -- 玩家状态
	Proto.writeBYTE(msg,data.hasActiveGarden); -- 是否有活动庄园
	if (data.hasActiveGarden~=0) then
		Proto.writeTownID(msg,data.activeGardenTown); -- 活动庄园所在小镇
		Proto.writeGardenID(msg,data.activeGardenID); -- 活动庄园ID
	end
end

function Proto.parseUserRunInfo(entry)
	local data={};
	data.id=Proto.parseCharacterID(entry); -- 玩家的ID
	data.state=Proto.parseBYTE(entry); -- 玩家状态
	data.leaveword=Proto.parseLeaveWord(entry); -- 个性留言
	data.mapID=Proto.parseMapID(entry); -- 所在地图
	data.level=Proto.parseWORD(entry); -- 玩家等级
	return data;
end

function Proto.getUserRunInfoIDLen()
	return Proto.getCharacterIDLen();
end

function Proto.writeUserRunInfo(msg,data)
	Proto.writeCharacterID(msg,data.id); -- 玩家的ID
	Proto.writeBYTE(msg,data.state); -- 玩家状态
	Proto.writeLeaveWord(msg,data.leaveword); -- 个性留言
	Proto.writeMapID(msg,data.mapID); -- 所在地图
	Proto.writeWORD(msg,data.level); -- 玩家等级
end

function Proto.parseGroupInfo(entry)
	local data={};
	data.id=Proto.parseGroupID(entry); -- 组的ID
	data.name=Proto.parseGroupName(entry); -- 组的名字
	data.userinfos=Proto.parseVector(entry,Proto.parseUserBaseInfo); -- 组的好友的信息
	return data;
end

function Proto.getGroupInfoIDLen()
	return Proto.getGroupIDLen();
end

function Proto.writeGroupInfo(msg,data)
	Proto.writeGroupID(msg,data.id); -- 组的ID
	Proto.writeGroupName(msg,data.name); -- 组的名字
	Proto.writeVector(msg,data.userinfos,Proto.writeUserBaseInfo); -- 组的好友的信息
end

function Proto.parseUserInfo(entry)
	local data={};
	data.userbaseinfo=Proto.parseUserBaseInfo(entry); -- 用户的基本信息
	data.userruninfo=Proto.parseUserRunInfo(entry); -- 用户的动态信息
	return data;
end

function Proto.writeUserInfo(msg,data)
	Proto.writeUserBaseInfo(msg,data.userbaseinfo); -- 用户的基本信息
	Proto.writeUserRunInfo(msg,data.userruninfo); -- 用户的动态信息
end

function Proto.parseFriendGroup(entry)
	local data={};
	data.id=Proto.parseGroupID(entry); -- 组的ID
	data.name=Proto.parseGroupName(entry); -- 组的名字
	data.userinfos=Proto.parseVector(entry,Proto.parseCharacterID); -- 组的用户
	return data;
end

function Proto.getFriendGroupIDLen()
	return Proto.getGroupIDLen();
end

function Proto.writeFriendGroup(msg,data)
	Proto.writeGroupID(msg,data.id); -- 组的ID
	Proto.writeGroupName(msg,data.name); -- 组的名字
	Proto.writeVector(msg,data.userinfos,Proto.writeCharacterID); -- 组的用户
end

function Proto.parseFacebookInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 
	data.value=Proto.parseDWORD(entry); -- 值
	data.name=Proto.parseString(entry); -- 属性
	data.desc=Proto.parseString(entry); -- 描述
	return data;
end

function Proto.getFacebookInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeFacebookInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 
	Proto.writeDWORD(msg,data.value); -- 值
	Proto.writeString(msg,data.name); -- 属性
	Proto.writeString(msg,data.desc); -- 描述
end

function Proto.parseFacebookFriendInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 
	data.num=Proto.parseDWORD(entry); -- 人数
	data.award=Proto.parseDWORD(entry); -- 奖励表
	return data;
end

function Proto.getFacebookFriendInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeFacebookFriendInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 
	Proto.writeDWORD(msg,data.num); -- 人数
	Proto.writeDWORD(msg,data.award); -- 奖励表
end

