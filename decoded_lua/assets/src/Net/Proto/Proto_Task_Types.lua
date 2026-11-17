-- Net.Proto.Proto_Task_Types

Proto.TT_MOVE			= 0							-- []宠物移动,可以在未执行完本作业的条件下被其它作业替换
Proto.TT_FIXMOVE		= Proto.TT_MOVE + 1			-- []宠物固定路线移动
Proto.TT_ROAM			= Proto.TT_FIXMOVE + 1		-- []宠物或NPC闲狂
Proto.TT_DINING			= Proto.TT_ROAM + 1			-- []吃饭
Proto.TT_COOKING		= Proto.TT_DINING + 1		-- []烹饪
Proto.TT_USEITEM		= Proto.TT_COOKING + 1		-- []使用道具
Proto.TT_IRRIGATE		= Proto.TT_USEITEM + 1		-- []宠物浇水
Proto.TT_HARVEST		= Proto.TT_IRRIGATE + 1		-- []宠物收获(收割)
Proto.TT_REMOVEPLANT	= Proto.TT_HARVEST + 1		-- []移除植物
Proto.TT_SHIFTMODE		= Proto.TT_REMOVEPLANT + 1	-- []切换AI模式
Proto.TT_FEEDONMASTER	= Proto.TT_SHIFTMODE + 1	-- []到主人旁进食
Proto.TT_FEEDONPLANT	= Proto.TT_FEEDONMASTER + 1	-- []到植物上进食

function Proto.parseTaskData_BODY_Move(entry)
	local data={};
	data.target=Proto.parsePOS2D(entry); -- 移动目标
	return data;
end

function Proto.writeTaskData_BODY_Move(msg,data)
	Proto.writePOS2D(msg,data.target); -- 移动目标
end

function Proto.parseTaskData_BODY_FixMove(entry)
	local data={};
	data.target=Proto.parsePOS2D(entry); -- 移动目标
	return data;
end

function Proto.writeTaskData_BODY_FixMove(msg,data)
	Proto.writePOS2D(msg,data.target); -- 移动目标
end

function Proto.parseTaskData_BODY_Roam(entry)
	local data={};
	data.targets=Proto.parseVarArray(entry,Proto.parsePOS2D,Proto.parseWORD); -- 闲逛目标
	return data;
end

function Proto.writeTaskData_BODY_Roam(msg,data)
	Proto.writeVarArray(msg,data.targets,Proto.writePOS2D,Proto.writeWORD); -- 闲逛目标
end

function Proto.parseTaskData_BODY_UseItem(entry)
	local data={};
	data.pos=Proto.parseWORD(entry); -- 行囊位置
	data.type_id=Proto.parseDWORD(entry); -- 类型ID
	data.deadline=Proto.parseTIME_SEC(entry); -- 使用期限
	data.data=Proto.parseItemData(entry); -- 道具数据
	data.param=Proto.parseItemUsageParam(entry); -- 道具使用参数
	data.needMove=Proto.parseBYTE(entry); -- 使用前是否需要移动
	if (data.needMove ~=0) then
		data.moveTarget=Proto.parsePOS2D(entry); -- 预先移动的目标
	end
	return data;
end

function Proto.writeTaskData_BODY_UseItem(msg,data)
	Proto.writeWORD(msg,data.pos); -- 行囊位置
	Proto.writeDWORD(msg,data.type_id); -- 类型ID
	Proto.writeTIME_SEC(msg,data.deadline); -- 使用期限
	Proto.writeItemData(msg,data.data); -- 道具数据
	Proto.writeItemUsageParam(msg,data.param); -- 道具使用参数
	Proto.writeBYTE(msg,data.needMove); -- 使用前是否需要移动
	if (data.needMove ~=0) then
		Proto.writePOS2D(msg,data.moveTarget); -- 预先移动的目标
	end
end

function Proto.parseTaskData_BODY_Irrigate(entry)
	local data={};
	data.target=Proto.parsePOS2D(entry); -- 灌溉地点
	return data;
end

function Proto.writeTaskData_BODY_Irrigate(msg,data)
	Proto.writePOS2D(msg,data.target); -- 灌溉地点
end

function Proto.parseTaskData_BODY_Harvest(entry)
	local data={};
	data.target=Proto.parsePOS2D(entry); -- 收获地点
	return data;
end

function Proto.writeTaskData_BODY_Harvest(msg,data)
	Proto.writePOS2D(msg,data.target); -- 收获地点
end

function Proto.parseTaskData_BODY_RemovePlant(entry)
	local data={};
	data.target=Proto.parsePOS2D(entry); -- 移除地点
	return data;
end

function Proto.writeTaskData_BODY_RemovePlant(msg,data)
	Proto.writePOS2D(msg,data.target); -- 移除地点
end

function Proto.parseTaskData_BODY_ShiftMode(entry)
	local data={};
	data.mode=Proto.parseBYTE(entry); -- 要切换的模式(AIMode)
	return data;
end

function Proto.writeTaskData_BODY_ShiftMode(msg,data)
	Proto.writeBYTE(msg,data.mode); -- 要切换的模式(AIMode)
end

function Proto.parseTaskData_BODY_FeedOnMaster(entry)
	local data={};
	data.masterPos=Proto.parsePOS2D(entry); -- 主人位置
	data.foodID=Proto.parseDWORD(entry); -- 食物类型
	return data;
end

function Proto.writeTaskData_BODY_FeedOnMaster(msg,data)
	Proto.writePOS2D(msg,data.masterPos); -- 主人位置
	Proto.writeDWORD(msg,data.foodID); -- 食物类型
end

function Proto.parseTaskData_BODY_FeedOnPlant(entry)
	local data={};
	data.plantPos=Proto.parsePOS2D(entry); -- 植物位置
	data.foodID=Proto.parseDWORD(entry); -- 食物类型
	return data;
end

function Proto.writeTaskData_BODY_FeedOnPlant(msg,data)
	Proto.writePOS2D(msg,data.plantPos); -- 植物位置
	Proto.writeDWORD(msg,data.foodID); -- 食物类型
end

function Proto.parseTaskData(entry)
	local data={};
	data.type=Proto.parseWORD(entry); -- 作业类型,TaskType
	data.body={}; -- 
	if (data.type==Proto.TT_MOVE) then
		data.body.move=Proto.parseTaskData_BODY_Move(entry); -- 移动作业
	end
	if (data.type==Proto.TT_FIXMOVE) then
		data.body.fixMove=Proto.parseTaskData_BODY_FixMove(entry); -- 因定移动作业
	end
	if (data.type==Proto.TT_ROAM) then
		data.body.roam=Proto.parseTaskData_BODY_Roam(entry); -- 闲逛作业
	end
	if (data.type==Proto.TT_USEITEM) then
		data.body.useItem=Proto.parseTaskData_BODY_UseItem(entry); -- 使用道具
	end
	if (data.type==Proto.TT_IRRIGATE) then
		data.body.irrigate=Proto.parseTaskData_BODY_Irrigate(entry); -- 灌溉
	end
	if (data.type==Proto.TT_HARVEST) then
		data.body.harvest=Proto.parseTaskData_BODY_Harvest(entry); -- 收获
	end
	if (data.type==Proto.TT_REMOVEPLANT) then
		data.body.removeplant=Proto.parseTaskData_BODY_RemovePlant(entry); -- 移除植物
	end
	if (data.type==Proto.TT_SHIFTMODE) then
		data.body.shiftMode=Proto.parseTaskData_BODY_ShiftMode(entry); -- 切换模式
	end
	if (data.type==Proto.TT_FEEDONMASTER) then
		data.body.feedOnMaster=Proto.parseTaskData_BODY_FeedOnMaster(entry); -- 到主人旁进食
	end
	if (data.type==Proto.TT_FEEDONPLANT) then
		data.body.feedOnPlant=Proto.parseTaskData_BODY_FeedOnPlant(entry); -- 到植物上进食
	end
	return data;
end

function Proto.writeTaskData(msg,data)
	Proto.writeWORD(msg,data.type); -- 作业类型,TaskType
	if (data.type==Proto.TT_MOVE) then
		Proto.writeTaskData_BODY_Move(msg,data.body.move); -- 移动作业
	end
	if (data.type==Proto.TT_FIXMOVE) then
		Proto.writeTaskData_BODY_FixMove(msg,data.body.fixMove); -- 因定移动作业
	end
	if (data.type==Proto.TT_ROAM) then
		Proto.writeTaskData_BODY_Roam(msg,data.body.roam); -- 闲逛作业
	end
	if (data.type==Proto.TT_USEITEM) then
		Proto.writeTaskData_BODY_UseItem(msg,data.body.useItem); -- 使用道具
	end
	if (data.type==Proto.TT_IRRIGATE) then
		Proto.writeTaskData_BODY_Irrigate(msg,data.body.irrigate); -- 灌溉
	end
	if (data.type==Proto.TT_HARVEST) then
		Proto.writeTaskData_BODY_Harvest(msg,data.body.harvest); -- 收获
	end
	if (data.type==Proto.TT_REMOVEPLANT) then
		Proto.writeTaskData_BODY_RemovePlant(msg,data.body.removeplant); -- 移除植物
	end
	if (data.type==Proto.TT_SHIFTMODE) then
		Proto.writeTaskData_BODY_ShiftMode(msg,data.body.shiftMode); -- 切换模式
	end
	if (data.type==Proto.TT_FEEDONMASTER) then
		Proto.writeTaskData_BODY_FeedOnMaster(msg,data.body.feedOnMaster); -- 到主人旁进食
	end
	if (data.type==Proto.TT_FEEDONPLANT) then
		Proto.writeTaskData_BODY_FeedOnPlant(msg,data.body.feedOnPlant); -- 到植物上进食
	end
end

function Proto.parseTaskItem(entry)
	local data={};
	data.index=Proto.parseDWORD(entry); -- 作业索引
	data.mapid=Proto.parseMapID(entry); -- 地图ID
	data.data=Proto.parseTaskData(entry); -- 作业数据
	return data;
end

function Proto.writeTaskItem(msg,data)
	Proto.writeDWORD(msg,data.index); -- 作业索引
	Proto.writeMapID(msg,data.mapid); -- 地图ID
	Proto.writeTaskData(msg,data.data); -- 作业数据
end

function Proto.parsePetTaskItem(entry)
	local data={};
	data.mapid=Proto.parseMapID(entry); -- 地图ID
	data.data=Proto.parseTaskData(entry); -- 作业数据
	data.replace=Proto.parseBYTE(entry); -- 是否替换(0:叠加;非0:替换)
	return data;
end

function Proto.writePetTaskItem(msg,data)
	Proto.writeMapID(msg,data.mapid); -- 地图ID
	Proto.writeTaskData(msg,data.data); -- 作业数据
	Proto.writeBYTE(msg,data.replace); -- 是否替换(0:叠加;非0:替换)
end

function Proto.parseActiveTaskData_BODY_Move(entry)
	local data={};
	data.target=Proto.parsePOS2D(entry); -- 移动目标
	return data;
end

function Proto.writeActiveTaskData_BODY_Move(msg,data)
	Proto.writePOS2D(msg,data.target); -- 移动目标
end

function Proto.parseActiveTaskData_BODY_FixMove(entry)
	local data={};
	data.target=Proto.parsePOS2D(entry); -- 移动目标
	return data;
end

function Proto.writeActiveTaskData_BODY_FixMove(msg,data)
	Proto.writePOS2D(msg,data.target); -- 移动目标
end

function Proto.parseActiveTaskData_BODY_UseItem(entry)
	local data={};
	data.pos=Proto.parseWORD(entry); -- 行囊位置
	data.param=Proto.parseItemUsageParam(entry); -- 道具使用参数
	return data;
end

function Proto.writeActiveTaskData_BODY_UseItem(msg,data)
	Proto.writeWORD(msg,data.pos); -- 行囊位置
	Proto.writeItemUsageParam(msg,data.param); -- 道具使用参数
end

function Proto.parseActiveTaskData_BODY_Irrigate(entry)
	local data={};
	return data;
end

function Proto.writeActiveTaskData_BODY_Irrigate(msg,data)
end

function Proto.parseActiveTaskData_BODY_Harvest(entry)
	local data={};
	return data;
end

function Proto.writeActiveTaskData_BODY_Harvest(msg,data)
end

function Proto.parseActiveTaskData_BODY_PHASE_Irrigate_1(entry)
	local data={};
	data.target=Proto.parsePOS2D(entry); -- 灌溉地点
	return data;
end

function Proto.writeActiveTaskData_BODY_PHASE_Irrigate_1(msg,data)
	Proto.writePOS2D(msg,data.target); -- 灌溉地点
end

function Proto.parseActiveTaskData_BODY_PHASE_Irrigate_2(entry)
	local data={};
	data.timeCost=Proto.parseDWORD(entry); -- 灌溉耗时
	return data;
end

function Proto.writeActiveTaskData_BODY_PHASE_Irrigate_2(msg,data)
	Proto.writeDWORD(msg,data.timeCost); -- 灌溉耗时
end

function Proto.parseActiveTaskData_BODY_PHASE_Harvest_1(entry)
	local data={};
	data.target=Proto.parsePOS2D(entry); -- 收获地点
	return data;
end

function Proto.writeActiveTaskData_BODY_PHASE_Harvest_1(msg,data)
	Proto.writePOS2D(msg,data.target); -- 收获地点
end

function Proto.parseActiveTaskData_BODY_PHASE_Harvest_2(entry)
	local data={};
	data.timeCost=Proto.parseDWORD(entry); -- 收获耗时
	return data;
end

function Proto.writeActiveTaskData_BODY_PHASE_Harvest_2(msg,data)
	Proto.writeDWORD(msg,data.timeCost); -- 收获耗时
end

function Proto.parseActiveTaskData_BODY_PHASE_RemovePlant_1(entry)
	local data={};
	data.target=Proto.parsePOS2D(entry); -- 移除地点
	return data;
end

function Proto.writeActiveTaskData_BODY_PHASE_RemovePlant_1(msg,data)
	Proto.writePOS2D(msg,data.target); -- 移除地点
end

function Proto.parseActiveTaskData_BODY_PHASE_RemovePlant_2(entry)
	local data={};
	data.timeCost=Proto.parseDWORD(entry); -- 移除耗时
	return data;
end

function Proto.writeActiveTaskData_BODY_PHASE_RemovePlant_2(msg,data)
	Proto.writeDWORD(msg,data.timeCost); -- 移除耗时
end

function Proto.parseActiveTaskData(entry)
	local data={};
	data.type=Proto.parseWORD(entry); -- 作业类型,TaskType
	data.phase=Proto.parseBYTE(entry); -- 阶段,每种子类型的阶段都不一样
	data.body={}; -- 作业的数据
	if (data.type==Proto.TT_MOVE) then
		data.body.move=Proto.parseActiveTaskData_BODY_Move(entry); -- 移动作业
	end
	if (data.type==Proto.TT_FIXMOVE) then
		data.body.fixMove=Proto.parseActiveTaskData_BODY_FixMove(entry); -- 因定移动作业
	end
	if (data.type==Proto.TT_USEITEM) then
		data.body.useItem=Proto.parseActiveTaskData_BODY_UseItem(entry); -- 使用道具
	end
	if (data.type==Proto.TT_IRRIGATE) then
		data.body.irrigate=Proto.parseActiveTaskData_BODY_Irrigate(entry); -- 灌溉
	end
	if (data.type==Proto.TT_HARVEST) then
		data.body.harvest=Proto.parseActiveTaskData_BODY_Harvest(entry); -- 收获
	end
	data.bodyPhase={}; -- 作业的阶段数据
	if (data.type==1) then
		data.bodyPhase.irrigate_1=Proto.parseActiveTaskData_BODY_PHASE_Irrigate_1(entry); -- 灌溉阶段1
	end
	if (data.type==2) then
		data.bodyPhase.irrigate_2=Proto.parseActiveTaskData_BODY_PHASE_Irrigate_2(entry); -- 灌溉阶段2
	end
	if (data.type==1) then
		data.bodyPhase.harvest_1=Proto.parseActiveTaskData_BODY_PHASE_Harvest_1(entry); -- 收获阶段1
	end
	if (data.type==2) then
		data.bodyPhase.harvest_2=Proto.parseActiveTaskData_BODY_PHASE_Harvest_2(entry); -- 收获阶段2
	end
	if (data.type==1) then
		data.bodyPhase.removeplant_1=Proto.parseActiveTaskData_BODY_PHASE_RemovePlant_1(entry); -- 移除植物阶段1
	end
	if (data.type==2) then
		data.bodyPhase.removeplant_2=Proto.parseActiveTaskData_BODY_PHASE_RemovePlant_2(entry); -- 移除植物阶段2
	end
	return data;
end

function Proto.writeActiveTaskData(msg,data)
	Proto.writeWORD(msg,data.type); -- 作业类型,TaskType
	Proto.writeBYTE(msg,data.phase); -- 阶段,每种子类型的阶段都不一样
	if (data.type==Proto.TT_MOVE) then
		Proto.writeActiveTaskData_BODY_Move(msg,data.body.move); -- 移动作业
	end
	if (data.type==Proto.TT_FIXMOVE) then
		Proto.writeActiveTaskData_BODY_FixMove(msg,data.body.fixMove); -- 因定移动作业
	end
	if (data.type==Proto.TT_USEITEM) then
		Proto.writeActiveTaskData_BODY_UseItem(msg,data.body.useItem); -- 使用道具
	end
	if (data.type==Proto.TT_IRRIGATE) then
		Proto.writeActiveTaskData_BODY_Irrigate(msg,data.body.irrigate); -- 灌溉
	end
	if (data.type==Proto.TT_HARVEST) then
		Proto.writeActiveTaskData_BODY_Harvest(msg,data.body.harvest); -- 收获
	end
	if (data.type==1) then
		Proto.writeActiveTaskData_BODY_PHASE_Irrigate_1(msg,data.bodyPhase.irrigate_1); -- 灌溉阶段1
	end
	if (data.type==2) then
		Proto.writeActiveTaskData_BODY_PHASE_Irrigate_2(msg,data.bodyPhase.irrigate_2); -- 灌溉阶段2
	end
	if (data.type==1) then
		Proto.writeActiveTaskData_BODY_PHASE_Harvest_1(msg,data.bodyPhase.harvest_1); -- 收获阶段1
	end
	if (data.type==2) then
		Proto.writeActiveTaskData_BODY_PHASE_Harvest_2(msg,data.bodyPhase.harvest_2); -- 收获阶段2
	end
	if (data.type==1) then
		Proto.writeActiveTaskData_BODY_PHASE_RemovePlant_1(msg,data.bodyPhase.removeplant_1); -- 移除植物阶段1
	end
	if (data.type==2) then
		Proto.writeActiveTaskData_BODY_PHASE_RemovePlant_2(msg,data.bodyPhase.removeplant_2); -- 移除植物阶段2
	end
end

function Proto.parseActiveTaskItem(entry)
	local data={};
	data.index=Proto.parseDWORD(entry); -- 作业索引
	data.data=Proto.parseActiveTaskData(entry); -- 作业数据
	return data;
end

function Proto.writeActiveTaskItem(msg,data)
	Proto.writeDWORD(msg,data.index); -- 作业索引
	Proto.writeActiveTaskData(msg,data.data); -- 作业数据
end

