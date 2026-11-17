-- Net.Proto.Proto_Farm_Types

Proto.FT_NORMAL		= 0						-- [Farm区域类型]普通区域
Proto.FT_NPC		= Proto.FT_NORMAL + 1	-- [Farm区域类型]NPC区域
Proto.FT_MONSTER	= Proto.FT_NPC + 1		-- [Farm区域类型]怪物区域
Proto.FT_RESOURCE	= Proto.FT_MONSTER + 1	-- [Farm区域类型]资源区域
Proto.FT_UNKNOW		= Proto.FT_RESOURCE + 1	-- [Farm区域类型]未知类型区域
Proto.FNT_SHOP		= 0						-- [FarmNpc类型]商店格
Proto.FNT_TASK		= Proto.FNT_SHOP + 1	-- [FarmNpc类型]任务格
Proto.FNT_DIALOG	= Proto.FNT_TASK + 1	-- [FarmNpc类型]对话格
Proto.FIT_MAP	= 0						-- [FARM对话框]地图信息
Proto.FIT_LIMIT	= Proto.FIT_MAP + 1		-- [FARM对话框]倒计信息
Proto.FIT_NPC	= Proto.FIT_LIMIT + 1	-- [FARM对话框]NPC对话信息
Proto.FIT_TIME	= Proto.FIT_NPC + 1		-- [FARM对话框]时间倒记

function Proto.parseFarmNpcBriefInfo(entry)
	local data={};
	data.npcid=Proto.parseDWORD(entry); -- NPC ID
	data.name=Proto.parseLifeNick(entry); -- npc名字
	return data;
end

function Proto.writeFarmNpcBriefInfo(msg,data)
	Proto.writeDWORD(msg,data.npcid); -- NPC ID
	Proto.writeLifeNick(msg,data.name); -- npc名字
end

function Proto.parseFarmEventLocationData_PARAM_Npc(entry)
	local data={};
	data.npcid=Proto.parseDWORD(entry); -- NPC ID
	data.type=Proto.parseBYTE(entry); -- NPC格类型NPCCELLTYPE
	return data;
end

function Proto.writeFarmEventLocationData_PARAM_Npc(msg,data)
	Proto.writeDWORD(msg,data.npcid); -- NPC ID
	Proto.writeBYTE(msg,data.type); -- NPC格类型NPCCELLTYPE
end

function Proto.parseFarmEventLocationData_PARAM__Monster(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 怪物组ID
	data.isBoss=Proto.parseBYTE(entry); -- 是否boss
	return data;
end

function Proto.getFarmEventLocationData_PARAM__MonsterIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeFarmEventLocationData_PARAM__Monster(msg,data)
	Proto.writeDWORD(msg,data.id); -- 怪物组ID
	Proto.writeBYTE(msg,data.isBoss); -- 是否boss
end

function Proto.parseFarmEventLocationData_PARAM_Resource(entry)
	local data={};
	data.itemid=Proto.parseDWORD(entry); -- 道具类型
	data.levelLimit=Proto.parseWORD(entry); -- 等级限制
	data.questLimit=Proto.parseWORD(entry); -- 任务限制
	return data;
end

function Proto.writeFarmEventLocationData_PARAM_Resource(msg,data)
	Proto.writeDWORD(msg,data.itemid); -- 道具类型
	Proto.writeWORD(msg,data.levelLimit); -- 等级限制
	Proto.writeWORD(msg,data.questLimit); -- 任务限制
end

function Proto.parseFarmEventLocationData(entry)
	local data={};
	data.index=Proto.parseDWORD(entry); -- 索引
	data.type=Proto.parseBYTE(entry); -- 区域类型
	data.param={}; -- 
	if (data.type==Proto.FT_NPC) then
		data.param.npc=Proto.parseFarmEventLocationData_PARAM_Npc(entry); -- NPC
	end
	if (data.type==Proto.FT_MONSTER) then
		data.param.monster=Proto.parseFarmEventLocationData_PARAM__Monster(entry); -- 怪物
	end
	if (data.type==Proto.FT_RESOURCE) then
		data.param.resource=Proto.parseFarmEventLocationData_PARAM_Resource(entry); -- 资源
	end
	data.location=Proto.parsePOS2D(entry); -- 位置
	data.hasModel=Proto.parseBYTE(entry); -- 是否有自定义模型
	if (data.hasModel ~=0) then
		data.modelType=Proto.parseDWORD(entry); -- 模型类型
		data.modelDir=Proto.parseDirectType(entry); -- 模型方向
	end
	return data;
end

function Proto.writeFarmEventLocationData(msg,data)
	Proto.writeDWORD(msg,data.index); -- 索引
	Proto.writeBYTE(msg,data.type); -- 区域类型
	if (data.type==Proto.FT_NPC) then
		Proto.writeFarmEventLocationData_PARAM_Npc(msg,data.param.npc); -- NPC
	end
	if (data.type==Proto.FT_MONSTER) then
		Proto.writeFarmEventLocationData_PARAM__Monster(msg,data.param.monster); -- 怪物
	end
	if (data.type==Proto.FT_RESOURCE) then
		Proto.writeFarmEventLocationData_PARAM_Resource(msg,data.param.resource); -- 资源
	end
	Proto.writePOS2D(msg,data.location); -- 位置
	Proto.writeBYTE(msg,data.hasModel); -- 是否有自定义模型
	if (data.hasModel ~=0) then
		Proto.writeDWORD(msg,data.modelType); -- 模型类型
		Proto.writeDirectType(msg,data.modelDir); -- 模型方向
	end
end

