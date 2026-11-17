-- Net.Proto.Proto_Freight_Types

Proto.FCT_SYSTEM		= 0						-- [货运航运公司类型]系统
Proto.FCT_CONFRATERNITY	= Proto.FCT_SYSTEM + 1	-- [货运航运公司类型]帮派

function Proto.parseFreightBaseInfo(entry)
	local data={};
	data.name=Proto.parseScheduleName(entry); -- 班次名
	data.startTownID=Proto.parseTownID(entry); -- 出发小镇
	data.destinationTownID=Proto.parseTownID(entry); -- 目标小镇
	data.costTime=Proto.parseTIME_SEC(entry); -- 运输耗时
	data.baseCharge=Proto.parseDWORD(entry); -- 每舱位的基本运费
	data.bunkCount=Proto.parseWORD(entry); -- 舱位数量
	data.typeName=Proto.parseFreightName(entry); -- 型号名称
	data.corpName=Proto.parseString(entry); -- 公司名称
	return data;
end

function Proto.writeFreightBaseInfo(msg,data)
	Proto.writeScheduleName(msg,data.name); -- 班次名
	Proto.writeTownID(msg,data.startTownID); -- 出发小镇
	Proto.writeTownID(msg,data.destinationTownID); -- 目标小镇
	Proto.writeTIME_SEC(msg,data.costTime); -- 运输耗时
	Proto.writeDWORD(msg,data.baseCharge); -- 每舱位的基本运费
	Proto.writeWORD(msg,data.bunkCount); -- 舱位数量
	Proto.writeFreightName(msg,data.typeName); -- 型号名称
	Proto.writeString(msg,data.corpName); -- 公司名称
end

function Proto.parseFreightScheduleInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 班次ID
	data.baseInfo=Proto.parseFreightBaseInfo(entry); -- 班次基本信息
	data.startTime=Proto.parseTIME_SEC(entry); -- 起航时间(相当于当日0:00:00时刻的偏移)
	return data;
end

function Proto.getFreightScheduleInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeFreightScheduleInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 班次ID
	Proto.writeFreightBaseInfo(msg,data.baseInfo); -- 班次基本信息
	Proto.writeTIME_SEC(msg,data.startTime); -- 起航时间(相当于当日0:00:00时刻的偏移)
end

function Proto.parseStowingFreight(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 航班ID
	data.leftStowTime=Proto.parseTIME_SEC(entry); -- 剩余起航时刻
	data.baseInfo=Proto.parseFreightBaseInfo(entry); -- 基本信息
	return data;
end

function Proto.getStowingFreightIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeStowingFreight(msg,data)
	Proto.writeDWORD(msg,data.id); -- 航班ID
	Proto.writeTIME_SEC(msg,data.leftStowTime); -- 剩余起航时刻
	Proto.writeFreightBaseInfo(msg,data.baseInfo); -- 基本信息
end

function Proto.parseFreightDetail(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 航班ID
	data.stowLimitTime=Proto.parseTIME_SEC(entry); -- 起航时刻
	data.baseInfo=Proto.parseFreightBaseInfo(entry); -- 基本信息
	data.usedBunk=Proto.parseWORD(entry); -- 已经占用的舱位数
	return data;
end

function Proto.getFreightDetailIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeFreightDetail(msg,data)
	Proto.writeDWORD(msg,data.id); -- 航班ID
	Proto.writeTIME_SEC(msg,data.stowLimitTime); -- 起航时刻
	Proto.writeFreightBaseInfo(msg,data.baseInfo); -- 基本信息
	Proto.writeWORD(msg,data.usedBunk); -- 已经占用的舱位数
end

function Proto.parseFreightCode(entry)
	local data={};
	data.type=Proto.parseBYTE(entry); -- 货运航运公司类型
	data.corpID=Proto.parseDWORD(entry); -- 公司ID
	data.id=Proto.parseDWORD(entry); -- 内部航班编号
	return data;
end

function Proto.getFreightCodeIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeFreightCode(msg,data)
	Proto.writeBYTE(msg,data.type); -- 货运航运公司类型
	Proto.writeDWORD(msg,data.corpID); -- 公司ID
	Proto.writeDWORD(msg,data.id); -- 内部航班编号
end

function Proto.parseBunkDetail(entry)
	local data={};
	data.bunkID=Proto.parseWORD(entry); -- 舱位编号
	data.roleID=Proto.parseUserID(entry); -- 委托人角色ID
	data.itemDesc=Proto.parseItemDesc(entry); -- 道具描述
	return data;
end

function Proto.writeBunkDetail(msg,data)
	Proto.writeWORD(msg,data.bunkID); -- 舱位编号
	Proto.writeUserID(msg,data.roleID); -- 委托人角色ID
	Proto.writeItemDesc(msg,data.itemDesc); -- 道具描述
end

function Proto.parseSendFreight(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 出发编号
	data.sendTime=Proto.parseTIME_SEC(entry); -- 起航时刻
	data.arriveTime=Proto.parseTIME_SEC(entry); -- 到达时刻
	data.baseInfo=Proto.parseFreightBaseInfo(entry); -- 基本信息
	return data;
end

function Proto.getSendFreightIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeSendFreight(msg,data)
	Proto.writeDWORD(msg,data.id); -- 出发编号
	Proto.writeTIME_SEC(msg,data.sendTime); -- 起航时刻
	Proto.writeTIME_SEC(msg,data.arriveTime); -- 到达时刻
	Proto.writeFreightBaseInfo(msg,data.baseInfo); -- 基本信息
end

