-- Net.Proto.Proto_SupervisorTool_Types

function Proto.parseActiveServerInfo(entry)
	local data={};
	data.ip=Proto.parseDWORD(entry); -- IP
	data.port=Proto.parseWORD(entry); -- 端口
	return data;
end

function Proto.writeActiveServerInfo(msg,data)
	Proto.writeDWORD(msg,data.ip); -- IP
	Proto.writeWORD(msg,data.port); -- 端口
end

function Proto.parseChannelState(entry)
	local data={};
	data.zone=Proto.parseTownID(entry); -- ZONE id
	data.channel=Proto.parseBYTE(entry); -- Channel id
	data.currentPlayer=Proto.parseWORD(entry); -- 玩家的当前数量
	data.maxPlayer=Proto.parseWORD(entry); -- 玩家的最大数量
	return data;
end

function Proto.writeChannelState(msg,data)
	Proto.writeTownID(msg,data.zone); -- ZONE id
	Proto.writeBYTE(msg,data.channel); -- Channel id
	Proto.writeWORD(msg,data.currentPlayer); -- 玩家的当前数量
	Proto.writeWORD(msg,data.maxPlayer); -- 玩家的最大数量
end

function Proto.parseServerInformation(entry)
	local data={};
	data.serverName=Proto.parseString(entry); -- 服务器名
	data.ip=Proto.parseString(entry); -- 服务器IP
	data.port=Proto.parseWORD(entry); -- 服务器端口号
	return data;
end

function Proto.writeServerInformation(msg,data)
	Proto.writeString(msg,data.serverName); -- 服务器名
	Proto.writeString(msg,data.ip); -- 服务器IP
	Proto.writeWORD(msg,data.port); -- 服务器端口号
end

function Proto.parseServerState(entry)
	local data={};
	data.info=Proto.parseServerInformation(entry); -- 服务器信息
	data.isActive=Proto.parseBYTE(entry); -- 服务器是否活动
	return data;
end

function Proto.writeServerState(msg,data)
	Proto.writeServerInformation(msg,data.info); -- 服务器信息
	Proto.writeBYTE(msg,data.isActive); -- 服务器是否活动
end

