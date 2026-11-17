-- Net.Proto.Proto_Match_Types

Proto.ML_FINAL			= 0							-- [比赛级别]决赛
Proto.ML_SEMIFINAL		= Proto.ML_FINAL + 1		-- [比赛级别]半决赛
Proto.ML_QUARTERFINAL	= Proto.ML_SEMIFINAL + 1	-- [比赛级别]四分之一决赛
Proto.ML_PREVIEW		= Proto.ML_QUARTERFINAL + 1	-- [比赛级别]预选

function Proto.parseMatchInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 锦标赛id
	data.preItem=Proto.parseDWORD(entry); -- 预选赛道具ID
	data.quarterItem=Proto.parseDWORD(entry); -- 四强赛道具ID
	data.semiItem=Proto.parseDWORD(entry); -- 半决赛道具ID
	data.finalItem=Proto.parseDWORD(entry); -- 决赛道具ID
	data.goldenMedal=Proto.parseDWORD(entry); -- 金牌道具ID
	return data;
end

function Proto.getMatchInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeMatchInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 锦标赛id
	Proto.writeDWORD(msg,data.preItem); -- 预选赛道具ID
	Proto.writeDWORD(msg,data.quarterItem); -- 四强赛道具ID
	Proto.writeDWORD(msg,data.semiItem); -- 半决赛道具ID
	Proto.writeDWORD(msg,data.finalItem); -- 决赛道具ID
	Proto.writeDWORD(msg,data.goldenMedal); -- 金牌道具ID
end

function Proto.parseMatchWinInfo(entry)
	local data={};
	data.type=Proto.parseBYTE(entry); -- 锦标赛类型
	data.id=Proto.parseWORD(entry); -- 届数
	data.endTime=Proto.parseTIME_SEC(entry); -- 结束时间
	data.winners=Proto.parseVector(entry,Proto.parseUserID); -- 胜利者
	return data;
end

function Proto.getMatchWinInfoIDLen()
	return Proto.getWORDLen();
end

function Proto.writeMatchWinInfo(msg,data)
	Proto.writeBYTE(msg,data.type); -- 锦标赛类型
	Proto.writeWORD(msg,data.id); -- 届数
	Proto.writeTIME_SEC(msg,data.endTime); -- 结束时间
	Proto.writeVector(msg,data.winners,Proto.writeUserID); -- 胜利者
end

function Proto.parseMatchWinDetailInfo(entry)
	local data={};
	data.type=Proto.parseBYTE(entry); -- 锦标赛类型
	data.id=Proto.parseWORD(entry); -- 届数
	data.endTime=Proto.parseTIME_SEC(entry); -- 结束时间
	data.winnersID=Proto.parseVector(entry,Proto.parseUserID); -- 胜利者ID
	data.winnersNick=Proto.parseVector(entry,Proto.parseNickName); -- 胜利者昵称
	return data;
end

function Proto.getMatchWinDetailInfoIDLen()
	return Proto.getWORDLen();
end

function Proto.writeMatchWinDetailInfo(msg,data)
	Proto.writeBYTE(msg,data.type); -- 锦标赛类型
	Proto.writeWORD(msg,data.id); -- 届数
	Proto.writeTIME_SEC(msg,data.endTime); -- 结束时间
	Proto.writeVector(msg,data.winnersID,Proto.writeUserID); -- 胜利者ID
	Proto.writeVector(msg,data.winnersNick,Proto.writeNickName); -- 胜利者昵称
end

