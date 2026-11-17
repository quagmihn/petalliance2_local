-- Net.Proto.Proto_Define_MapID_Types

Proto.MapID_T_NONE				= 0										-- [主类型]不在地图
Proto.MapID_T_CHANNEL			= Proto.MapID_T_NONE + 1				-- [主类型]频道地图
Proto.MapID_T_PLAYER			= Proto.MapID_T_CHANNEL + 1				-- [主类型]玩家地图
Proto.MapID_T_REPETITION		= Proto.MapID_T_PLAYER + 1				-- [主类型]副本地图
Proto.MapID_T_CAMP				= Proto.MapID_T_REPETITION + 1			-- [主类型]阵地地图
Proto.MapID_T_WARCONFRATERNITY	= Proto.MapID_T_CAMP + 1				-- [主类型]公会战地图
Proto.MapID_T_CONFRATERNITY		= Proto.MapID_T_WARCONFRATERNITY + 1	-- [主类型]公会地图
Proto.MapID_BODY_Player_ST_GARDEN	= 0	-- [子类型]庄园地图

function Proto.parseMapID_BODY_Channel(entry)
	local data={};
	data.subtype=Proto.parseBYTE(entry); -- ChannelMapType
	data.id=Proto.parseChannelID(entry); -- 频道ID
	return data;
end

function Proto.getMapID_BODY_ChannelIDLen()
	return Proto.getChannelIDLen();
end

function Proto.writeMapID_BODY_Channel(msg,data)
	Proto.writeBYTE(msg,data.subtype); -- ChannelMapType
	Proto.writeChannelID(msg,data.id); -- 频道ID
end

function Proto.parseMapID_BODY_Player(entry)
	local data={};
	data.subtype=Proto.parseBYTE(entry); -- SUBTYPE
	data.gardenID=Proto.parseGardenID(entry); -- 庄园ID
	return data;
end

function Proto.writeMapID_BODY_Player(msg,data)
	Proto.writeBYTE(msg,data.subtype); -- SUBTYPE
	Proto.writeGardenID(msg,data.gardenID); -- 庄园ID
end

function Proto.parseMapID_BODY_Repetition(entry)
	local data={};
	data.repID=Proto.parseDWORD(entry); -- 副本ID
	return data;
end

function Proto.writeMapID_BODY_Repetition(msg,data)
	Proto.writeDWORD(msg,data.repID); -- 副本ID
end

function Proto.parseMapID_BODY_Camp(entry)
	local data={};
	data.campID=Proto.parseDWORD(entry); -- 阵地ID
	return data;
end

function Proto.writeMapID_BODY_Camp(msg,data)
	Proto.writeDWORD(msg,data.campID); -- 阵地ID
end

function Proto.parseMapID_BODY_Confraternity(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 公会场景场景id
	return data;
end

function Proto.getMapID_BODY_ConfraternityIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeMapID_BODY_Confraternity(msg,data)
	Proto.writeDWORD(msg,data.id); -- 公会场景场景id
end

function Proto.parseMapID_BODY_ConfraternityWar(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 公会战场景id
	return data;
end

function Proto.getMapID_BODY_ConfraternityWarIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeMapID_BODY_ConfraternityWar(msg,data)
	Proto.writeDWORD(msg,data.id); -- 公会战场景id
end

function Proto.parseMapID(entry)
	local data={};
	data.type=Proto.parseBYTE(entry); -- TYPE
	data.body={}; -- 
	if (data.type==Proto.MapID_T_CHANNEL) then
		data.body.channel=Proto.parseMapID_BODY_Channel(entry); -- 
	end
	if (data.type==Proto.MapID_T_PLAYER) then
		data.body.player=Proto.parseMapID_BODY_Player(entry); -- 
	end
	if (data.type==Proto.MapID_T_REPETITION) then
		data.body.repetition=Proto.parseMapID_BODY_Repetition(entry); -- 
	end
	if (data.type==Proto.MapID_T_CAMP) then
		data.body.camp=Proto.parseMapID_BODY_Camp(entry); -- 
	end
	if (data.type==Proto.MapID_T_CONFRATERNITY) then
		data.body.confraternity=Proto.parseMapID_BODY_Confraternity(entry); -- 
	end
	if (data.type==Proto.MapID_T_WARCONFRATERNITY) then
		data.body.confraternityWar=Proto.parseMapID_BODY_ConfraternityWar(entry); -- 
	end
	return data;
end

function Proto.writeMapID(msg,data)
	Proto.writeBYTE(msg,data.type); -- TYPE
	if (data.type==Proto.MapID_T_CHANNEL) then
		Proto.writeMapID_BODY_Channel(msg,data.body.channel); -- 
	end
	if (data.type==Proto.MapID_T_PLAYER) then
		Proto.writeMapID_BODY_Player(msg,data.body.player); -- 
	end
	if (data.type==Proto.MapID_T_REPETITION) then
		Proto.writeMapID_BODY_Repetition(msg,data.body.repetition); -- 
	end
	if (data.type==Proto.MapID_T_CAMP) then
		Proto.writeMapID_BODY_Camp(msg,data.body.camp); -- 
	end
	if (data.type==Proto.MapID_T_CONFRATERNITY) then
		Proto.writeMapID_BODY_Confraternity(msg,data.body.confraternity); -- 
	end
	if (data.type==Proto.MapID_T_WARCONFRATERNITY) then
		Proto.writeMapID_BODY_ConfraternityWar(msg,data.body.confraternityWar); -- 
	end
end

