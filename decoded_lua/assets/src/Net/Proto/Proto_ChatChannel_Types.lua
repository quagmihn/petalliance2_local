-- Net.Proto.Proto_ChatChannel_Types

Proto.CHOP_NONE			= 0							-- [频道选项]谁都可以加入
Proto.CHOP_CHINVITE		= Proto.CHOP_NONE + 1		-- [频道选项]类型是邀请,只能由频道内玩家邀请进入频道
Proto.CHOP_CHPRIVATE	= Proto.CHOP_CHINVITE + 1	-- [频道选项]私有,不能再加入玩家
Proto.CHOP_CHENCRYPT	= Proto.CHOP_CHPRIVATE + 1	-- [频道选项]加密,必须输入密码后才能进入频道
Proto.CHTYPE_FIXEDCHANNEL			= 0								-- [频道的类型]固定频道
Proto.CHTYPE_TEMPCHANNEL			= Proto.CHTYPE_FIXEDCHANNEL + 1	-- [频道的类型]临时频道
Proto.CHTYPE_GROUPCHANNEL			= Proto.CHTYPE_TEMPCHANNEL + 1	-- [频道的类型]组队频道
Proto.CHTYPE_TOWNCHANNEL			= Proto.CHTYPE_GROUPCHANNEL + 1	-- [频道的类型]小镇频道
Proto.CHTYPE_CONFRATERNITYCHANNEL	= Proto.CHTYPE_TOWNCHANNEL + 1	-- [频道的类型]公会频道

function Proto.parseChannelCategory(entry)
	local data={};
	data.pid=Proto.parseCategoryID(entry); -- 分类的父ID
	data.id=Proto.parseCategoryID(entry); -- 分类的ID
	data.name=Proto.parseCategoryName(entry); -- 分类的名字
	return data;
end

function Proto.getChannelCategoryIDLen()
	return Proto.getCategoryIDLen();
end

function Proto.writeChannelCategory(msg,data)
	Proto.writeCategoryID(msg,data.pid); -- 分类的父ID
	Proto.writeCategoryID(msg,data.id); -- 分类的ID
	Proto.writeCategoryName(msg,data.name); -- 分类的名字
end

function Proto.parseCategoryInfo(entry)
	local data={};
	data.id=Proto.parseCategoryID(entry); -- 分类的ID
	data.name=Proto.parseCategoryName(entry); -- 分类的名字
	return data;
end

function Proto.getCategoryInfoIDLen()
	return Proto.getCategoryIDLen();
end

function Proto.writeCategoryInfo(msg,data)
	Proto.writeCategoryID(msg,data.id); -- 分类的ID
	Proto.writeCategoryName(msg,data.name); -- 分类的名字
end

function Proto.parseChatUserInfo(entry)
	local data={};
	data.charID=Proto.parseCharacterID(entry); -- 用户的ID
	data.nickname=Proto.parseNickName(entry); -- 玩家昵称
	return data;
end

function Proto.writeChatUserInfo(msg,data)
	Proto.writeCharacterID(msg,data.charID); -- 用户的ID
	Proto.writeNickName(msg,data.nickname); -- 玩家昵称
end

function Proto.parseChatChannelID(entry)
	local data={};
	data.channelid=Proto.parseDWORD(entry); -- 频道ID
	data.type=Proto.parseBYTE(entry); -- 频道的类型,用的是enum CHANNELTYPE
	return data;
end

function Proto.writeChatChannelID(msg,data)
	Proto.writeDWORD(msg,data.channelid); -- 频道ID
	Proto.writeBYTE(msg,data.type); -- 频道的类型,用的是enum CHANNELTYPE
end

function Proto.parseChannelShortInfo(entry)
	local data={};
	data.id=Proto.parseChatChannelID(entry); -- 频道ID
	data.name=Proto.parseChatChannelName(entry); -- 频道名称
	data.count=Proto.parseWORD(entry); -- 频道人数
	data.description=Proto.parseChatChannelDesc(entry); -- 频道描述
	data.option=Proto.parseBYTE(entry); -- 频道选项,用的是enum 
	return data;
end

function Proto.getChannelShortInfoIDLen()
	return Proto.getChatChannelIDLen();
end

function Proto.writeChannelShortInfo(msg,data)
	Proto.writeChatChannelID(msg,data.id); -- 频道ID
	Proto.writeChatChannelName(msg,data.name); -- 频道名称
	Proto.writeWORD(msg,data.count); -- 频道人数
	Proto.writeChatChannelDesc(msg,data.description); -- 频道描述
	Proto.writeBYTE(msg,data.option); -- 频道选项,用的是enum 
end

function Proto.parseChannelFullInfo(entry)
	local data={};
	data.option=Proto.parseBYTE(entry); -- 频道选项,用的是enum 
	data.createDate=Proto.parseTIME_SEC(entry); -- 频道创建时间
	data.owner=Proto.parseCharacterID(entry); -- 频道的创建人
	data.category=Proto.parseWORD(entry); -- 频道分类
	data.name=Proto.parseChatChannelName(entry); -- 频道名称
	data.description=Proto.parseChatChannelDesc(entry); -- 频道描述
	data.count=Proto.parseWORD(entry); -- 频道人数
	data.hide=Proto.parseBYTE(entry); -- 频道是否隐藏
	data.maxcount=Proto.parseWORD(entry); -- 频道最大人数
	return data;
end

function Proto.writeChannelFullInfo(msg,data)
	Proto.writeBYTE(msg,data.option); -- 频道选项,用的是enum 
	Proto.writeTIME_SEC(msg,data.createDate); -- 频道创建时间
	Proto.writeCharacterID(msg,data.owner); -- 频道的创建人
	Proto.writeWORD(msg,data.category); -- 频道分类
	Proto.writeChatChannelName(msg,data.name); -- 频道名称
	Proto.writeChatChannelDesc(msg,data.description); -- 频道描述
	Proto.writeWORD(msg,data.count); -- 频道人数
	Proto.writeBYTE(msg,data.hide); -- 频道是否隐藏
	Proto.writeWORD(msg,data.maxcount); -- 频道最大人数
end

