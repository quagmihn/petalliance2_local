-- Net.Proto.Proto_Objective_Types

Proto.OBJECTIVE_NUM_TYPE_ADD	= 0									-- [目标数量类型]目标数量累加
Proto.OBJECTIVE_NUM_TYPE_EVAL	= Proto.OBJECTIVE_NUM_TYPE_ADD + 1	-- [目标数量类型]目标数量赋值
Proto.OBJECTIVE_EVENT_TYPE_KILL		= 0											-- [目标数量类型]打怪
Proto.OBJECTIVE_EVENT_TYPE_GANITEM	= Proto.OBJECTIVE_EVENT_TYPE_KILL + 1		-- [目标数量类型]收集道具
Proto.OBJECTIVE_EVENT_TYPE_CLIENT	= Proto.OBJECTIVE_EVENT_TYPE_GANITEM + 1	-- [目标数量类型]客户端控制

function Proto.parseObjectiveInfo(entry)
	local data={};
	data.eventType=Proto.parseWORD(entry); -- 目标事件类型
	data.mainID=Proto.parseDWORD(entry); -- 目标主要ID
	data.subID=Proto.parseDWORD(entry); -- 目标次要ID
	data.finalID=Proto.parseDWORD(entry); -- 目标末位ID
	data.numType=Proto.parseBYTE(entry); -- 目标数量类型
	data.amount=Proto.parseDWORD(entry); -- 目标需要的数量
	data.queryType=Proto.parseBYTE(entry); -- 状态查询类型
	return data;
end

function Proto.writeObjectiveInfo(msg,data)
	Proto.writeWORD(msg,data.eventType); -- 目标事件类型
	Proto.writeDWORD(msg,data.mainID); -- 目标主要ID
	Proto.writeDWORD(msg,data.subID); -- 目标次要ID
	Proto.writeDWORD(msg,data.finalID); -- 目标末位ID
	Proto.writeBYTE(msg,data.numType); -- 目标数量类型
	Proto.writeDWORD(msg,data.amount); -- 目标需要的数量
	Proto.writeBYTE(msg,data.queryType); -- 状态查询类型
end

