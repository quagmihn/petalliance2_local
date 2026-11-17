-- Net.Proto.Proto_Chat

function Proto.writeP_CG_ChangeChannel_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_CHANGECHANNEL_REQ);
	Proto.writeString(msg,data.channel); -- 
	Proto.writeString(msg,data.data); -- 
end

function Proto.parseP_GC_ChangeChannel_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_CHANGECHANNEL_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code==Proto.Error.ERROR_OK) then
		data.channel=Proto.parseString(entry); -- 
	end
	return data;
end

function Proto.writeP_CZ_ScreenChat_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CZ_SCREENCHAT_REQ);
	Proto.writeChatContent(msg,data.content); -- 聊天内容
end

function Proto.parseP_ZC_ScreenChat_Brd(entry)
	local data={};
	data.msgID=Proto.Command.ZC_SCREENCHAT_BRD;
	data.handle=Proto.parseRoleHandle(entry); -- 说话者句柄
	data.content=Proto.parseChatContent(entry); -- 聊天内容
	return data;
end

function Proto.writeP_CM_PrivateChat_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CM_PRIVATECHAT_REQ);
	Proto.writeUserID(msg,data.id); -- 玩家ID
	Proto.writeChatContent(msg,data.content); -- 聊天内容
end

function Proto.parseP_MC_PrivateChat_Req(entry)
	local data={};
	data.msgID=Proto.Command.MC_PRIVATECHAT_REQ;
	data.code=Proto.parseWORD(entry); -- 返回码
	return data;
end

function Proto.parseP_MC_PrivateChat_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.MC_PRIVATECHAT_NTF;
	data.id=Proto.parseUserID(entry); -- 玩家ID
	data.content=Proto.parseChatContent(entry); -- 聊天内容
	return data;
end

function Proto.writeP_CZ_ScreenDraw_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CZ_SCREENDRAW_REQ);
	Proto.writeWORD(msg,data.colorID); -- 颜色编号
	Proto.writeBYTE(msg,data.width); -- 宽度
	Proto.writeVector(msg,data.drawContent,Proto.writePOS2D); -- 画图内容
end

function Proto.parseP_ZC_ScreenDraw_Ack(entry)
	local data={};
	data.msgID=Proto.Command.ZC_SCREENDRAW_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	return data;
end

function Proto.parseP_ZC_ScreenDraw_Brd(entry)
	local data={};
	data.msgID=Proto.Command.ZC_SCREENDRAW_BRD;
	data.handle=Proto.parseRoleHandle(entry); -- 角色Handle
	data.colorID=Proto.parseWORD(entry); -- 颜色编号
	data.width=Proto.parseBYTE(entry); -- 宽度
	data.drawContent=Proto.parseVector(entry,Proto.parsePOS2D); -- 画图内容
	return data;
end

function Proto.parseP_MC_SystemChat_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.MC_SYSTEMCHAT_NTF;
	data.content=Proto.parseChatContent(entry); -- 聊天内容
	return data;
end

function Proto.parseP_ZC_SystemChat_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.ZC_SYSTEMCHAT_NTF;
	data.content=Proto.parseChatContent(entry); -- 聊天内容
	return data;
end

function Proto.writeP_CZ_UseSpaceBugle_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CZ_USESPACEBUGLE_REQ);
	Proto.writeChatContent(msg,data.content); -- 聊天内容
	Proto.writeBYTE(msg,data.color); -- 颜色
	Proto.writeBYTE(msg,data.useItem); -- 是否使用道具
	if (data.useItem~=0) then
		Proto.writeWORD(msg,data.pos); -- 道具位置
	end
end

function Proto.parseP_GC_UseSpaceBugle_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_USESPACEBUGLE_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code==Proto.Error.ERROR_OK) then
		data.index=Proto.parseWORD(entry); -- 聊天位置
	end
	return data;
end

function Proto.writeP_CZ_UseBigBugle_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CZ_USEBIGBUGLE_REQ);
	Proto.writeChatContent(msg,data.content); -- 聊天内容
	Proto.writeBYTE(msg,data.color); -- 颜色
	Proto.writeBYTE(msg,data.useItem); -- 是否使用道具
	if (data.useItem~=0) then
		Proto.writeWORD(msg,data.pos); -- 道具位置
	end
end

function Proto.parseP_GC_UseBigBugle_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_USEBIGBUGLE_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code==Proto.Error.ERROR_OK) then
		data.index=Proto.parseWORD(entry); -- 聊天位置
	end
	return data;
end

function Proto.writeP_CZ_UseSmallBugle_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CZ_USESMALLBUGLE_REQ);
	Proto.writeChatContent(msg,data.content); -- 聊天内容
	Proto.writeBYTE(msg,data.color); -- 颜色
	Proto.writeBYTE(msg,data.useItem); -- 是否使用道具
	if (data.useItem~=0) then
		Proto.writeWORD(msg,data.pos); -- 道具位置
	end
end

function Proto.parseP_GC_UseSmallBugle_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_USESMALLBUGLE_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code==Proto.Error.ERROR_OK) then
		data.index=Proto.parseWORD(entry); -- 聊天位置
	end
	return data;
end

function Proto.parseP_GC_SpaceBugle_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_SPACEBUGLE_NTF;
	data.characterID=Proto.parseDWORD(entry); -- 玩家ID
	data.name=Proto.parseNickName(entry); -- 玩家昵称
	data.content=Proto.parseChatContent(entry); -- 聊天内容
	data.color=Proto.parseBYTE(entry); -- 颜色
	return data;
end

function Proto.parseP_GC_BigBugle_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_BIGBUGLE_NTF;
	data.name=Proto.parseNickName(entry); -- 玩家昵称
	data.content=Proto.parseChatContent(entry); -- 聊天内容
	data.color=Proto.parseBYTE(entry); -- 颜色
	return data;
end

function Proto.parseP_GC_SmallBugle_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_SMALLBUGLE_NTF;
	data.name=Proto.parseNickName(entry); -- 玩家昵称
	data.content=Proto.parseChatContent(entry); -- 聊天内容
	data.color=Proto.parseBYTE(entry); -- 颜色
	return data;
end

function Proto.parseP_GC_IngameBulletin_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_INGAMEBULLETIN_NTF;
	data.type=Proto.parseBYTE(entry); -- 公告类型
	data.content=Proto.parseChatContent(entry); -- 公告内容
	return data;
end

function Proto.parseP_HC_SystemNotice_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.HC_SYSTEMNOTICE_NTF;
	data.sbid=Proto.parseDWORD(entry); -- 广播内容编号
	data.sbParam=Proto.parseString(entry); -- 广播参数信息
	return data;
end

function Proto.writeP_CJ_QueryCharacterInfo_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CJ_QUERYCHARACTERINFO_REQ);
	Proto.writeDWORD(msg,data.pointWarID); -- 积分战ID
	Proto.writeDWORD(msg,data.charid); -- 角色ID
end

function Proto.parseP_JC_QueryCharacterInfo_Ack(entry)
	local data={};
	data.msgID=Proto.Command.JC_QUERYCHARACTERINFO_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code==Proto.Error.ERROR_OK) then
		data.petUnits=Proto.parseVarArray(entry,Proto.parseBattleUnitInfo,Proto.parseWORD); -- 宠物信息
		data.equipUnits=Proto.parseVector(entry,Proto.parseItemUnit); -- 装备信息
	end
	return data;
end

function Proto.writeP_CM_QueryStageArenaCharacterInfo_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CM_QUERYSTAGEARENACHARACTERINFO_REQ);
	Proto.writeDWORD(msg,data.stageid); -- 关卡ID
end

function Proto.parseP_MC_QueryStageArenaCharacterInfo_Ack(entry)
	local data={};
	data.msgID=Proto.Command.MC_QUERYSTAGEARENACHARACTERINFO_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code==Proto.Error.ERROR_OK) then
		data.petUnits=Proto.parseVarArray(entry,Proto.parseBattleUnitInfo,Proto.parseWORD); -- 宠物信息
		data.equipUnits=Proto.parseVector(entry,Proto.parseItemUnit); -- 装备信息
	end
	return data;
end

function Proto.writeP_CZ_QueryChatCharacterInfo_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CZ_QUERYCHATCHARACTERINFO_REQ);
	Proto.writeRoleHandle(msg,data.roleHandle); -- 角色handle
end

function Proto.parseP_ZC_QueryChatCharacterInfo_Ack(entry)
	local data={};
	data.msgID=Proto.Command.ZC_QUERYCHATCHARACTERINFO_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code==Proto.Error.ERROR_OK) then
		data.petUnits=Proto.parseVarArray(entry,Proto.parseBattleUnitInfo,Proto.parseWORD); -- 宠物信息
		data.equipUnits=Proto.parseVector(entry,Proto.parseItemUnit); -- 装备信息
	end
	return data;
end

function Proto.writeP_CG_Chat_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_CHAT_REQ);
	Proto.writeString(msg,data.charID); -- 私聊用 角色id
	Proto.writeString(msg,data.channel); -- 频道
	Proto.writeString(msg,data.concent); -- 内容
end

function Proto.parseP_GC_Chat_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_CHAT_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	return data;
end

function Proto.parseP_GC_Chat_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_CHAT_NTF;
	data.charIDFrom=Proto.parseString(entry); -- 来源角色id 0表示系统
	data.charIDFromName=Proto.parseString(entry); -- 来源角色id 0表示系统
	data.charIDTo=Proto.parseString(entry); -- 私聊用 角色id
	data.channel=Proto.parseString(entry); -- 频道
	data.concent=Proto.parseString(entry); -- 内容
	return data;
end

