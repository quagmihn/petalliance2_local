-- Net.Proto.Proto_Mail_Types

function Proto.parseMailContentInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 邮件编号
	data.senderName=Proto.parseString(entry); -- 发件人姓名
	data.title=Proto.parseString(entry); -- 标题
	data.content=Proto.parseString(entry); -- 文本内容
	data.deadTime=Proto.parseQWORD(entry); -- 过期时间点
	data.timeLast=Proto.parseQWORD(entry); -- 持续时间
	return data;
end

function Proto.getMailContentInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeMailContentInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 邮件编号
	Proto.writeString(msg,data.senderName); -- 发件人姓名
	Proto.writeString(msg,data.title); -- 标题
	Proto.writeString(msg,data.content); -- 文本内容
	Proto.writeQWORD(msg,data.deadTime); -- 过期时间点
	Proto.writeQWORD(msg,data.timeLast); -- 持续时间
end

