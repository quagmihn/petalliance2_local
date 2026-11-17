-- Net.Proto.Proto_Bulletin

function Proto.parseBulletinBriefInfo(entry)
	local data={};
	data.id=Proto.parseint(entry); -- 布告ID
	data.update=Proto.parseint(entry); -- 更新时间
	return data;
end

function Proto.getBulletinBriefInfoIDLen()
	return Proto.getintLen();
end

function Proto.writeBulletinBriefInfo(msg,data)
	Proto.writeint(msg,data.id); -- 布告ID
	Proto.writeint(msg,data.update); -- 更新时间
end

function Proto.parseBulletinDetailInfo(entry)
	local data={};
	data.id=Proto.parseint(entry); -- 布告ID
	data.world=Proto.parseint(entry); -- 世界
	data.picture=Proto.parsestring(entry); -- 图片
	data.content=Proto.parsestring(entry); -- 内容
	data.update=Proto.parseint(entry); -- 更新时间
	return data;
end

function Proto.getBulletinDetailInfoIDLen()
	return Proto.getintLen();
end

function Proto.writeBulletinDetailInfo(msg,data)
	Proto.writeint(msg,data.id); -- 布告ID
	Proto.writeint(msg,data.world); -- 世界
	Proto.writestring(msg,data.picture); -- 图片
	Proto.writestring(msg,data.content); -- 内容
	Proto.writeint(msg,data.update); -- 更新时间
end

function Proto.writeP_CG_ListBulletin_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_LISTBULLETIN_REQ);
end

function Proto.parseP_GC_ListBulletin_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_LISTBULLETIN_ACK;
	data.code=Proto.parseCode(entry); -- 返回码
	if (data.code.value==Proto.Error.ERROR_OK) then
		data.bulletins=Proto.parseVector(entry,Proto.parseBulletinBriefInfo); -- 布告列表
	end
	return data;
end

function Proto.writeP_CG_GetBulletin_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETBULLETIN_REQ);
	Proto.writeint(msg,data.id); -- 布告ID
end

function Proto.parseP_GC_GetBulletin_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETBULLETIN_ACK;
	data.code=Proto.parseCode(entry); -- 返回码
	if (data.code.value==Proto.Error.ERROR_OK) then
		data.info=Proto.parseBulletinDetailInfo(entry); -- 布告信息
	end
	return data;
end

