-- Net.Proto.Proto_Downtime_Types

function Proto.parsePlayerIP(entry)
	local data={};
	data.playerID=Proto.parseDWORD(entry); -- 玩家id
	data.ip=Proto.parseDWORD(entry); -- 登陆ip
	data.nickName=Proto.parseNickName(entry); -- 昵称
	data.username=Proto.parseUserName(entry); -- 用户名
	data.indulgeFlag=Proto.parseBYTE(entry); -- 沉迷状态标志
	return data;
end

function Proto.writePlayerIP(msg,data)
	Proto.writeDWORD(msg,data.playerID); -- 玩家id
	Proto.writeDWORD(msg,data.ip); -- 登陆ip
	Proto.writeNickName(msg,data.nickName); -- 昵称
	Proto.writeUserName(msg,data.username); -- 用户名
	Proto.writeBYTE(msg,data.indulgeFlag); -- 沉迷状态标志
end

function Proto.parseIPAreaInfo(entry)
	local data={};
	data.userID=Proto.parseDWORD(entry); -- 网吧
	data.index=Proto.parseDWORD(entry); -- index
	data.ip=Proto.parseDWORD(entry); -- ip
	return data;
end

function Proto.writeIPAreaInfo(msg,data)
	Proto.writeDWORD(msg,data.userID); -- 网吧
	Proto.writeDWORD(msg,data.index); -- index
	Proto.writeDWORD(msg,data.ip); -- ip
end

function Proto.parseOntimeNotice(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 公告id
	data.space=Proto.parseTIME_SEC(entry); -- 间隔
	data.count=Proto.parseDWORD(entry); -- 循环次数
	data.first=Proto.parseTIME_SEC(entry); -- 第一次播放时间
	data.content=Proto.parseString(entry); -- 是否立即发送
	return data;
end

function Proto.getOntimeNoticeIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeOntimeNotice(msg,data)
	Proto.writeDWORD(msg,data.id); -- 公告id
	Proto.writeTIME_SEC(msg,data.space); -- 间隔
	Proto.writeDWORD(msg,data.count); -- 循环次数
	Proto.writeTIME_SEC(msg,data.first); -- 第一次播放时间
	Proto.writeString(msg,data.content); -- 是否立即发送
end

function Proto.parseAreaPresentInfo(entry)
	local data={};
	data.presentID=Proto.parseDWORD(entry); -- 礼物id
	data.generateID=Proto.parseDWORD(entry); -- 道具生成规则id
	data.isBind=Proto.parseBYTE(entry); -- 是否绑定
	return data;
end

function Proto.writeAreaPresentInfo(msg,data)
	Proto.writeDWORD(msg,data.presentID); -- 礼物id
	Proto.writeDWORD(msg,data.generateID); -- 道具生成规则id
	Proto.writeBYTE(msg,data.isBind); -- 是否绑定
end

function Proto.parseAreaOnlinePresentInfo(entry)
	local data={};
	data.timeCost=Proto.parseDWORD(entry); -- 花费时间
	data.generateID=Proto.parseDWORD(entry); -- 道具生成规则id
	data.count=Proto.parseWORD(entry); -- 数量
	data.isBind=Proto.parseBYTE(entry); -- 是否绑定
	return data;
end

function Proto.writeAreaOnlinePresentInfo(msg,data)
	Proto.writeDWORD(msg,data.timeCost); -- 花费时间
	Proto.writeDWORD(msg,data.generateID); -- 道具生成规则id
	Proto.writeWORD(msg,data.count); -- 数量
	Proto.writeBYTE(msg,data.isBind); -- 是否绑定
end

function Proto.parseAreaOnlinePresentRule(entry)
	local data={};
	data.ruleID=Proto.parseDWORD(entry); -- 规则id
	data.isLoop=Proto.parseBYTE(entry); -- 是否重复
	data.isUse=Proto.parseBYTE(entry); -- 是否使用
	data.infos=Proto.parseVector(entry,Proto.parseAreaOnlinePresentInfo); -- 礼物信息
	return data;
end

function Proto.writeAreaOnlinePresentRule(msg,data)
	Proto.writeDWORD(msg,data.ruleID); -- 规则id
	Proto.writeBYTE(msg,data.isLoop); -- 是否重复
	Proto.writeBYTE(msg,data.isUse); -- 是否使用
	Proto.writeVector(msg,data.infos,Proto.writeAreaOnlinePresentInfo); -- 礼物信息
end

function Proto.parseResumeIndulge(entry)
	local data={};
	data.playerID=Proto.parseDWORD(entry); -- 礼物id
	data.indulgeFlag=Proto.parseBYTE(entry); -- 是否绑定
	return data;
end

function Proto.writeResumeIndulge(msg,data)
	Proto.writeDWORD(msg,data.playerID); -- 礼物id
	Proto.writeBYTE(msg,data.indulgeFlag); -- 是否绑定
end

