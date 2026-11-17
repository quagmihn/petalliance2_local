-- Net.Proto.Proto_BroadcastMsg_Types

function Proto.parseBroadcastMsgInfo(entry)
	local data={};
	data.id=Proto.parseWORD(entry); -- ID
	data.event=Proto.parseString(entry); -- 事件
	data.CD=Proto.parseWORD(entry); -- 播放间隔
	data.times=Proto.parseWORD(entry); -- 播放次数
	data.content=Proto.parseString(entry); -- 文本
	return data;
end

function Proto.getBroadcastMsgInfoIDLen()
	return Proto.getWORDLen();
end

function Proto.writeBroadcastMsgInfo(msg,data)
	Proto.writeWORD(msg,data.id); -- ID
	Proto.writeString(msg,data.event); -- 事件
	Proto.writeWORD(msg,data.CD); -- 播放间隔
	Proto.writeWORD(msg,data.times); -- 播放次数
	Proto.writeString(msg,data.content); -- 文本
end

