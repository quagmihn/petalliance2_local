-- Net.Proto.Proto_HangUp_Types

Proto.PH_ADD	= 0					-- [概率修正方向]增加概率
Proto.PH_SUB	= Proto.PH_ADD + 1	-- [概率修正方向]减少概率
Proto.PHUPDATE_USE			= 0							-- [挂机点信息更新]使用挂机点
Proto.PHUPDATE_ABANDONED	= Proto.PHUPDATE_USE + 1	-- [挂机点信息更新]弃用挂机点
Proto.USE_GCASH_HANGUP	= 0								-- [挂机类型]使用金币
Proto.USE_MCASH_HANGUP	= Proto.USE_GCASH_HANGUP + 1	-- [挂机类型]使用RMB
Proto.USE_ITEM_HANGUP	= Proto.USE_MCASH_HANGUP + 1	-- [挂机类型]使用道具

function Proto.parsePetProbChange(entry)
	local data={};
	data.opType=Proto.parseBYTE(entry); -- 修正方向PetHangProbOP
	data.phProb=Proto.parseDWORD(entry); -- 修正概率值
	return data;
end

function Proto.writePetProbChange(msg,data)
	Proto.writeBYTE(msg,data.opType); -- 修正方向PetHangProbOP
	Proto.writeDWORD(msg,data.phProb); -- 修正概率值
end

function Proto.parsePetHangUpAwardInfo(entry)
	local data={};
	data.id=Proto.parseWORD(entry); -- 挂机点ID
	data.itemCode=Proto.parseDWORD(entry); -- 奖励道具编号
	data.prob=Proto.parseDWORD(entry); -- 基础概率
	data.petRaceProbChange=Proto.parseVector(entry,Proto.parsePetProbChange); -- 宠物种族概率修正
	return data;
end

function Proto.getPetHangUpAwardInfoIDLen()
	return Proto.getWORDLen();
end

function Proto.writePetHangUpAwardInfo(msg,data)
	Proto.writeWORD(msg,data.id); -- 挂机点ID
	Proto.writeDWORD(msg,data.itemCode); -- 奖励道具编号
	Proto.writeDWORD(msg,data.prob); -- 基础概率
	Proto.writeVector(msg,data.petRaceProbChange,Proto.writePetProbChange); -- 宠物种族概率修正
end

function Proto.parsePetHangUpInfo(entry)
	local data={};
	data.id=Proto.parseWORD(entry); -- 挂机点ID
	data.hangUpName=Proto.parseString(entry); -- 挂机点名称
	data.hangUpTime=Proto.parseDWORD(entry); -- 挂机时间(秒)
	data.hangUpMoney=Proto.parseDWORD(entry); -- 挂机费用(g币)
	data.hangUpRMB=Proto.parseDWORD(entry); -- 挂机费用(M币)
	data.hangUpItemType=Proto.parseDWORD(entry); -- 使用道具
	data.hangUpItemCount=Proto.parseDWORD(entry); -- 使用道具数量
	data.hangUpAwards=Proto.parseVector(entry,Proto.parsePetHangUpAwardInfo); -- 挂机奖励信息
	return data;
end

function Proto.getPetHangUpInfoIDLen()
	return Proto.getWORDLen();
end

function Proto.writePetHangUpInfo(msg,data)
	Proto.writeWORD(msg,data.id); -- 挂机点ID
	Proto.writeString(msg,data.hangUpName); -- 挂机点名称
	Proto.writeDWORD(msg,data.hangUpTime); -- 挂机时间(秒)
	Proto.writeDWORD(msg,data.hangUpMoney); -- 挂机费用(g币)
	Proto.writeDWORD(msg,data.hangUpRMB); -- 挂机费用(M币)
	Proto.writeDWORD(msg,data.hangUpItemType); -- 使用道具
	Proto.writeDWORD(msg,data.hangUpItemCount); -- 使用道具数量
	Proto.writeVector(msg,data.hangUpAwards,Proto.writePetHangUpAwardInfo); -- 挂机奖励信息
end

function Proto.parsePetHangUpLevelProbChange(entry)
	local data={};
	data.id=Proto.parseWORD(entry); -- ID
	data.petLevel=Proto.parseWORD(entry); -- 宠物等级
	data.petProbChange=Proto.parsePetProbChange(entry); -- 修正方向PetHangProbOP
	return data;
end

function Proto.getPetHangUpLevelProbChangeIDLen()
	return Proto.getWORDLen();
end

function Proto.writePetHangUpLevelProbChange(msg,data)
	Proto.writeWORD(msg,data.id); -- ID
	Proto.writeWORD(msg,data.petLevel); -- 宠物等级
	Proto.writePetProbChange(msg,data.petProbChange); -- 修正方向PetHangProbOP
end

function Proto.parsePetHangUpPointInfo(entry)
	local data={};
	data.hangupid=Proto.parseWORD(entry); -- 挂机点id
	data.petid=Proto.parsePetID(entry); -- 宠物ID
	data.beginTime=Proto.parseTIME_SEC(entry); -- 开始时间
	data.award=Proto.parseDWORD(entry); -- 奖励道具
	data.hangupTime=Proto.parseTIME_SEC(entry); -- 挂机时间
	return data;
end

function Proto.writePetHangUpPointInfo(msg,data)
	Proto.writeWORD(msg,data.hangupid); -- 挂机点id
	Proto.writePetID(msg,data.petid); -- 宠物ID
	Proto.writeTIME_SEC(msg,data.beginTime); -- 开始时间
	Proto.writeDWORD(msg,data.award); -- 奖励道具
	Proto.writeTIME_SEC(msg,data.hangupTime); -- 挂机时间
end

