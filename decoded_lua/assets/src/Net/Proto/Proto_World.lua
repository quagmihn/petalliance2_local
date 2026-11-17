-- Net.Proto.Proto_World

Proto.WS_MAINTAIN	= 0							-- [世界状态]维护
Proto.WS_FREE		= Proto.WS_MAINTAIN + 1		-- [世界状态]空闲
Proto.WS_RECOMMEND	= Proto.WS_FREE + 1			-- [世界状态]推荐
Proto.WS_CROWDED	= Proto.WS_RECOMMEND + 1	-- [世界状态]拥挤
Proto.WS_FULL		= Proto.WS_CROWDED + 1		-- [世界状态]爆满

function Proto.parseWorldInfo(entry)
	local data={};
	data.id=Proto.parseint(entry); -- ID
	data.name=Proto.parsestring(entry); -- 名称
	data.channel=Proto.parsestring(entry); -- 渠道
	data.zone=Proto.parseint(entry); -- 区号
	data.state=Proto.parseint(entry); -- 状态
	data.openTime=Proto.parseint(entry); -- 开服时间
	return data;
end

function Proto.getWorldInfoIDLen()
	return Proto.getintLen();
end

function Proto.writeWorldInfo(msg,data)
	Proto.writeint(msg,data.id); -- ID
	Proto.writestring(msg,data.name); -- 名称
	Proto.writestring(msg,data.channel); -- 渠道
	Proto.writeint(msg,data.zone); -- 区号
	Proto.writeint(msg,data.state); -- 状态
	Proto.writeint(msg,data.openTime); -- 开服时间
end

function Proto.parseP_ZC_Season_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.ZC_SEASON_NTF;
	data.season=Proto.parseBYTE(entry); -- 季节
	data.offset=Proto.parseDWORD(entry); -- 度过时间
	return data;
end

function Proto.parseP_ZC_LocalTime_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.ZC_LOCALTIME_NTF;
	data.time=Proto.parseDWORD(entry); -- 时间
	return data;
end

function Proto.writeP_CZ_ExecuteCommand_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CZ_EXECUTECOMMAND_REQ);
	Proto.writeRanaCommand(msg,data.command); -- 命令脚本
end

function Proto.parseP_ZC_ExecuteCommand_Ack(entry)
	local data={};
	data.msgID=Proto.Command.ZC_EXECUTECOMMAND_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	return data;
end

function Proto.parseP_MC_Bulletin_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.MC_BULLETIN_NTF;
	data.text=Proto.parseBulletinText(entry); -- 公告
	return data;
end

function Proto.writeP_CZ_GetComingFestaPeriod_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CZ_GETCOMINGFESTAPERIOD_REQ);
end

function Proto.parseP_ZC_GetComingFestaPeriod_Ack(entry)
	local data={};
	data.msgID=Proto.Command.ZC_GETCOMINGFESTAPERIOD_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.festas=Proto.parseVector(entry,Proto.parseFestaPeriod); -- 节日表
	end
	return data;
end

function Proto.writeP_CZ_ListOnlineBulletinCaption_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CZ_LISTONLINEBULLETINCAPTION_REQ);
end

function Proto.parseP_ZC_ListOnlineBulletinCaption_Ack(entry)
	local data={};
	data.msgID=Proto.Command.ZC_LISTONLINEBULLETINCAPTION_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.captions=Proto.parseVector(entry,Proto.parseOnlineBulletinCaption); -- 在线公告标识
	end
	return data;
end

function Proto.writeP_CZ_GetOnlineBulletin_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CZ_GETONLINEBULLETIN_REQ);
	Proto.writeBulletinCode(msg,data.key_code); -- 关键词
end

function Proto.parseP_ZC_GetOnlineBulletin_Ack(entry)
	local data={};
	data.msgID=Proto.Command.ZC_GETONLINEBULLETIN_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.onlineBulletin=Proto.parseOnlineBulletin(entry); -- 公告内容
	end
	return data;
end

function Proto.writeP_CG_WorldList_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_WORLDLIST_REQ);
	Proto.writestring(msg,data.channel); -- 世界频道
end

function Proto.parseP_GC_WorldList_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_WORLDLIST_ACK;
	data.timeZone=Proto.parsestring(entry); -- 时区
	data.worlds=Proto.parseVector(entry,Proto.parseWorldInfo); -- 世界列表
	return data;
end

