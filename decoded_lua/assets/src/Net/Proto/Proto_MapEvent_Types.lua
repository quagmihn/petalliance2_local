-- Net.Proto.Proto_MapEvent_Types

Proto.MET_NORMAL	= 0							-- [区域类型]普通区域
Proto.MET_NPC		= Proto.MET_NORMAL + 1		-- [区域类型]NPC区域
Proto.MET_MONSTER	= Proto.MET_NPC + 1			-- [区域类型]怪物区域
Proto.MET_RESOURCE	= Proto.MET_MONSTER + 1		-- [区域类型]资源区域
Proto.MET_FLAG		= Proto.MET_RESOURCE + 1	-- [区域类型]旗子区域
Proto.MET_UNKNOW	= Proto.MET_FLAG + 1		-- [区域类型]未知类型区域

function Proto.parseMapEventLocationData_PARAM_Npc(entry)
	local data={};
	data.npcid=Proto.parseDWORD(entry); -- NPC ID
	data.type=Proto.parseBYTE(entry); -- NPC格类型NPCCELLTYPE
	return data;
end

function Proto.writeMapEventLocationData_PARAM_Npc(msg,data)
	Proto.writeDWORD(msg,data.npcid); -- NPC ID
	Proto.writeBYTE(msg,data.type); -- NPC格类型NPCCELLTYPE
end

function Proto.parseMapEventLocationData_PARAM__Monster(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 怪物组ID
	data.isBoss=Proto.parseBYTE(entry); -- 是否boss
	return data;
end

function Proto.getMapEventLocationData_PARAM__MonsterIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeMapEventLocationData_PARAM__Monster(msg,data)
	Proto.writeDWORD(msg,data.id); -- 怪物组ID
	Proto.writeBYTE(msg,data.isBoss); -- 是否boss
end

function Proto.parseMapEventLocationData_PARAM_Resource(entry)
	local data={};
	data.itemid=Proto.parseDWORD(entry); -- 道具类型
	data.levelLimit=Proto.parseWORD(entry); -- 等级限制
	data.questLimit=Proto.parseWORD(entry); -- 任务限制
	return data;
end

function Proto.writeMapEventLocationData_PARAM_Resource(msg,data)
	Proto.writeDWORD(msg,data.itemid); -- 道具类型
	Proto.writeWORD(msg,data.levelLimit); -- 等级限制
	Proto.writeWORD(msg,data.questLimit); -- 任务限制
end

function Proto.parseMapEventLocationData_PARAM_Flag(entry)
	local data={};
	data.type=Proto.parseWORD(entry); -- 旗子类型
	return data;
end

function Proto.writeMapEventLocationData_PARAM_Flag(msg,data)
	Proto.writeWORD(msg,data.type); -- 旗子类型
end

function Proto.parseMapEventLocationData(entry)
	local data={};
	data.index=Proto.parseDWORD(entry); -- 索引
	data.type=Proto.parseBYTE(entry); -- 区域类型
	data.param={}; -- 
	if (data.type==Proto.MET_NPC) then
		data.param.npc=Proto.parseMapEventLocationData_PARAM_Npc(entry); -- NPC
	end
	if (data.type==Proto.MET_MONSTER) then
		data.param.monster=Proto.parseMapEventLocationData_PARAM__Monster(entry); -- 怪物
	end
	if (data.type==Proto.MET_RESOURCE) then
		data.param.resource=Proto.parseMapEventLocationData_PARAM_Resource(entry); -- 资源
	end
	if (data.type==Proto.MET_FLAG) then
		data.param.flag=Proto.parseMapEventLocationData_PARAM_Flag(entry); -- 资源
	end
	data.location=Proto.parsePOS2D(entry); -- 位置
	data.hasModel=Proto.parseBYTE(entry); -- 是否有自定义模型
	if (data.hasModel ~=0) then
		data.modelType=Proto.parseDWORD(entry); -- 模型类型
		data.modelDir=Proto.parseDirectType(entry); -- 模型方向
	end
	return data;
end

function Proto.writeMapEventLocationData(msg,data)
	Proto.writeDWORD(msg,data.index); -- 索引
	Proto.writeBYTE(msg,data.type); -- 区域类型
	if (data.type==Proto.MET_NPC) then
		Proto.writeMapEventLocationData_PARAM_Npc(msg,data.param.npc); -- NPC
	end
	if (data.type==Proto.MET_MONSTER) then
		Proto.writeMapEventLocationData_PARAM__Monster(msg,data.param.monster); -- 怪物
	end
	if (data.type==Proto.MET_RESOURCE) then
		Proto.writeMapEventLocationData_PARAM_Resource(msg,data.param.resource); -- 资源
	end
	if (data.type==Proto.MET_FLAG) then
		Proto.writeMapEventLocationData_PARAM_Flag(msg,data.param.flag); -- 资源
	end
	Proto.writePOS2D(msg,data.location); -- 位置
	Proto.writeBYTE(msg,data.hasModel); -- 是否有自定义模型
	if (data.hasModel ~=0) then
		Proto.writeDWORD(msg,data.modelType); -- 模型类型
		Proto.writeDirectType(msg,data.modelDir); -- 模型方向
	end
end

