-- Net.Proto.Proto_Daemon_Types

Proto.DEST_NONE			= 0							-- [守护服务器类型]没有启动
Proto.DEST_MANAGER		= Proto.DEST_NONE + 1		-- [守护服务器类型]manager
Proto.DEST_ZONE			= Proto.DEST_MANAGER + 1	-- [守护服务器类型]zone
Proto.DEST_ASSISTANT	= Proto.DEST_ZONE + 1		-- [守护服务器类型]assistant
Proto.DEST_MAP			= Proto.DEST_ASSISTANT + 1	-- [守护服务器类型]map
Proto.DEST_CHAT			= Proto.DEST_MAP + 1		-- [守护服务器类型]chat
Proto.DEST_AI			= Proto.DEST_CHAT + 1		-- [守护服务器类型]ai
Proto.DEST_GATE			= Proto.DEST_AI + 1			-- [守护服务器类型]gate
Proto.DEST_STAT			= Proto.DEST_GATE + 1		-- [守护服务器类型]stat

function Proto.parseDaemonServerInfo(entry)
	local data={};
	data.ip=Proto.parseDWORD(entry); -- ip
	data.port=Proto.parseWORD(entry); -- port
	return data;
end

function Proto.writeDaemonServerInfo(msg,data)
	Proto.writeDWORD(msg,data.ip); -- ip
	Proto.writeWORD(msg,data.port); -- port
end

function Proto.parseGameServerInfo(entry)
	local data={};
	data.type=Proto.parseBYTE(entry); -- 服务器类型
	return data;
end

function Proto.writeGameServerInfo(msg,data)
	Proto.writeBYTE(msg,data.type); -- 服务器类型
end

