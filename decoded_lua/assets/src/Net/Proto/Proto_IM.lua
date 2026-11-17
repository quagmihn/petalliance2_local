-- Net.Proto.Proto_IM

function Proto.parseP_GC_Message_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_MESSAGE_NTF;
	data.command=Proto.parsestring(entry); -- 消息命令
	data.param=Proto.parsestring(entry); -- 消息参数
	return data;
end

