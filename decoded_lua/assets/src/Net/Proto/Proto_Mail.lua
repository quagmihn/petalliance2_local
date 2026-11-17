-- Net.Proto.Proto_Mail

function Proto.writeP_CG_CheckUnReadMail_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_CHECKUNREADMAIL_REQ);
end

function Proto.parseP_GC_CheckUnReadMail_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_CHECKUNREADMAIL_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.hasUnReadGroupMail=Proto.parseWORD(entry); -- 有未读群邮件吗
		data.hasUnReadPersonMail=Proto.parseWORD(entry); -- 有未读个人邮件吗
	end
	return data;
end

function Proto.writeP_CG_GetMail_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETMAIL_REQ);
	Proto.writeString(msg,data.mailIndex); -- 邮件索引
	Proto.writeWORD(msg,data.mailType); -- 邮件类型
end

function Proto.parseP_GC_GetMail_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETMAIL_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.mailInfo=Proto.parseString(entry); -- 邮件内容
	end
	return data;
end

function Proto.writeP_CG_GetMailAttach_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETMAILATTACH_REQ);
	Proto.writeString(msg,data.mailIndex); -- 邮件索引
	Proto.writeWORD(msg,data.mailType); -- 邮件类型
end

function Proto.parseP_GC_GetMailAttach_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETMAILATTACH_ACK;
	data.code=Proto.parseWORD(entry); -- 
	return data;
end

function Proto.writeP_CG_GetSomeMails_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETSOMEMAILS_REQ);
	Proto.writeString(msg,data.GruopTimeTip); -- 时间线索，查询晚于这个时间的邮件。0代表最新
	Proto.writeDWORD(msg,data.personCount); -- 时间线索，查询晚于这个时间的邮件。0代表最新
	Proto.writeWORD(msg,data.mailCount); -- 邮件数量
end

function Proto.parseP_GC_GetSomeMails_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETSOMEMAILS_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.mails=Proto.parseString(entry); -- 多个邮件
	end
	return data;
end

function Proto.writeP_CG_DelMail_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_DELMAIL_REQ);
	Proto.writeString(msg,data.mailIndex); -- 邮件索引
	Proto.writeWORD(msg,data.mailType); -- 邮件类型
end

function Proto.parseP_GC_DelMail_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_DELMAIL_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	return data;
end

function Proto.parseP_GC_NewMailNotify_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_NEWMAILNOTIFY_NTF;
	return data;
end

function Proto.parseP_GC_CleanPersonMailNTF_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_CLEANPERSONMAILNTF_NTF;
	return data;
end

