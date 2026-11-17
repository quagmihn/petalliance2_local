-- Net.Proto.Proto_TrainingGround_Types

function Proto.parseTrainingGroundID(entry)
	local data={};
	data.OwnerID=Proto.parseUserID(entry); -- 主人ID
	data.index=Proto.parseBYTE(entry); -- 训练场编号
	return data;
end

function Proto.writeTrainingGroundID(msg,data)
	Proto.writeUserID(msg,data.OwnerID); -- 主人ID
	Proto.writeBYTE(msg,data.index); -- 训练场编号
end

function Proto.parseTGVipTimeReq(entry)
	local data={};
	data.tgid=Proto.parseTrainingGroundID(entry); -- 编号
	data.petid=Proto.parsePetID(entry); -- 宠物编号
	return data;
end

function Proto.writeTGVipTimeReq(msg,data)
	Proto.writeTrainingGroundID(msg,data.tgid); -- 编号
	Proto.writePetID(msg,data.petid); -- 宠物编号
end

function Proto.parseTGVipTimeAck(entry)
	local data={};
	data.tgid=Proto.parseTrainingGroundID(entry); -- 编号
	data.tgTime=Proto.parseTIME_SEC(entry); -- 训练场时间
	return data;
end

function Proto.writeTGVipTimeAck(msg,data)
	Proto.writeTrainingGroundID(msg,data.tgid); -- 编号
	Proto.writeTIME_SEC(msg,data.tgTime); -- 训练场时间
end

function Proto.parseTrainingGroundInfo(entry)
	local data={};
	data.id=Proto.parseTrainingGroundID(entry); -- 编号
	data.level=Proto.parseWORD(entry); -- 训练场等级
	data.occupation=Proto.parseBYTE(entry); -- 是否被占用
	if (data.occupation==1) then
		data.petID=Proto.parseDWORD(entry); -- 训练宠物ID
		data.BeginTime=Proto.parseTIME_SEC(entry); -- 开始使用时间
		data.TGTime=Proto.parseTIME_SEC(entry); -- 训练场时间
		data.petLevel=Proto.parseWORD(entry); -- 训练宠物等级
	end
	return data;
end

function Proto.getTrainingGroundInfoIDLen()
	return Proto.getTrainingGroundIDLen();
end

function Proto.writeTrainingGroundInfo(msg,data)
	Proto.writeTrainingGroundID(msg,data.id); -- 编号
	Proto.writeWORD(msg,data.level); -- 训练场等级
	Proto.writeBYTE(msg,data.occupation); -- 是否被占用
	if (data.occupation==1) then
		Proto.writeDWORD(msg,data.petID); -- 训练宠物ID
		Proto.writeTIME_SEC(msg,data.BeginTime); -- 开始使用时间
		Proto.writeTIME_SEC(msg,data.TGTime); -- 训练场时间
		Proto.writeWORD(msg,data.petLevel); -- 训练宠物等级
	end
end

function Proto.parseTGLog(entry)
	local data={};
	data.logIndex=Proto.parseDWORD(entry); -- 日志编号
	data.id=Proto.parseTrainingGroundID(entry); -- 编号
	data.ownerName=Proto.parseNickName(entry); -- 训练场主人
	data.petName=Proto.parseLifeNick(entry); -- 宠物名称
	data.level=Proto.parseWORD(entry); -- 训练场等级
	data.petID=Proto.parseDWORD(entry); -- 训练宠物ID
	data.petLevel=Proto.parseWORD(entry); -- 训练宠物等级
	data.logTime=Proto.parseTIME_SEC(entry); -- 时间
	data.logType=Proto.parseWORD(entry); -- 日志类型
	data.value=Proto.parseDWORD(entry); -- 日志内容值
	data.TGTime=Proto.parseTIME_SEC(entry); -- 训练场时间
	return data;
end

function Proto.getTGLogIDLen()
	return Proto.getTrainingGroundIDLen();
end

function Proto.writeTGLog(msg,data)
	Proto.writeDWORD(msg,data.logIndex); -- 日志编号
	Proto.writeTrainingGroundID(msg,data.id); -- 编号
	Proto.writeNickName(msg,data.ownerName); -- 训练场主人
	Proto.writeLifeNick(msg,data.petName); -- 宠物名称
	Proto.writeWORD(msg,data.level); -- 训练场等级
	Proto.writeDWORD(msg,data.petID); -- 训练宠物ID
	Proto.writeWORD(msg,data.petLevel); -- 训练宠物等级
	Proto.writeTIME_SEC(msg,data.logTime); -- 时间
	Proto.writeWORD(msg,data.logType); -- 日志类型
	Proto.writeDWORD(msg,data.value); -- 日志内容值
	Proto.writeTIME_SEC(msg,data.TGTime); -- 训练场时间
end

