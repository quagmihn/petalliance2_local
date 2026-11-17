-- Net.Proto.Proto_Facility_Types

Proto.FC_NORMAL			= 0								-- [设备种类]常用类别
Proto.FC_COOKER			= Proto.FC_NORMAL + 1			-- [设备种类]炉灶
Proto.FC_FOODCABINET	= Proto.FC_COOKER + 1			-- [设备种类]食品柜
Proto.FC_DININGTABLE	= Proto.FC_FOODCABINET + 1		-- [设备种类]餐桌
Proto.FC_WIRING			= Proto.FC_DININGTABLE + 1		-- [设备种类]电器设备,只能放在电器台上
Proto.FC_WORKTABLE		= Proto.FC_WIRING + 1			-- [设备种类]操作台
Proto.FC_WIRINGTABLE	= Proto.FC_WORKTABLE + 1		-- [设备种类]电器台
Proto.FC_BOILER			= Proto.FC_WIRINGTABLE + 1		-- [设备种类]炊具
Proto.FC_MACHINE		= Proto.FC_BOILER + 1			-- [设备种类]机械
Proto.FC_RESTAURANT		= Proto.FC_MACHINE + 1			-- [设备种类]饭店
Proto.FC_ORNAMENT		= Proto.FC_RESTAURANT + 1		-- [设备种类]装饰物
Proto.FC_SPA			= Proto.FC_ORNAMENT + 1			-- [设备种类]温泉
Proto.FC_PETDORM		= Proto.FC_SPA + 1				-- [设备种类]宠物宿舍
Proto.FC_BARRIER		= Proto.FC_PETDORM + 1			-- [设备种类]栅栏
Proto.FC_COUNTER		= Proto.FC_BARRIER + 1			-- [设备种类]柜台
Proto.FC_GARDENMACHINE	= Proto.FC_COUNTER + 1			-- [设备种类]园丁机器人
Proto.FC_STOREHOUSE		= Proto.FC_GARDENMACHINE + 1	-- [设备种类]储物柜
Proto.WS_OVEN				= 0								-- [电器系列]烤箱
Proto.WS_STIRRER			= Proto.WS_OVEN + 1				-- [电器系列]搅拌器
Proto.WS_JUICE_EXTRACTOR	= Proto.WS_STIRRER + 1			-- [电器系列]榨汁机
Proto.WS_SAUSAGE_MACHINE	= Proto.WS_JUICE_EXTRACTOR + 1	-- [电器系列]香肠机
Proto.WS_COOFEEPOT			= Proto.WS_SAUSAGE_MACHINE + 1	-- [电器系列]咖啡壶
Proto.BS_SAUTE		= 0						-- [锅类系列]炒锅
Proto.BS_SOUP		= Proto.BS_SAUTE + 1	-- [锅类系列]汤锅
Proto.BS_STEAMER	= Proto.BS_SOUP + 1		-- [锅类系列]蒸笼
Proto.BS_AUTOCLAVE	= Proto.BS_STEAMER + 1	-- [锅类系列]高压锅
Proto.GS_REMOVE 	= 0							-- [园丁机器人功能]移除
Proto.GS_IRRIGATE1	= Proto.GS_REMOVE  + 1		-- [园丁机器人功能]用1号材料灌溉
Proto.GS_INGATHER	= Proto.GS_IRRIGATE1 + 1	-- [园丁机器人功能]收获
Proto.GS_BYPRODUCT	= Proto.GS_INGATHER + 1		-- [园丁机器人功能]收获副产品
Proto.GS_IRRIGATE2	= Proto.GS_BYPRODUCT + 1	-- [园丁机器人功能]用2号材料灌溉
Proto.GS_COUNT		= Proto.GS_IRRIGATE2 + 1	-- [园丁机器人功能]功能总数
Proto.GS_ATTACH		= Proto.GS_COUNT + 1		-- [园丁机器人功能]获得状态
Proto.PDF_INSERT 	= 0						-- [宠物宿舍功能]加入
Proto.PDF_CLEAR		= Proto.PDF_INSERT  + 1	-- [宠物宿舍功能]清空
Proto.PDF_ADDFOOD	= Proto.PDF_CLEAR + 1	-- [宠物宿舍功能]增加食物
Proto.PDF_SETFOOD	= Proto.PDF_ADDFOOD + 1	-- [宠物宿舍功能]设置食物优先度
Proto.MPF_PROCESS	= 0						-- [机械加工功能]加工
Proto.MPF_INSERT	= Proto.MPF_PROCESS + 1	-- [机械加工功能]增加
Proto.MPF_MOVE		= Proto.MPF_INSERT + 1	-- [机械加工功能]移动
Proto.MPF_DELETE	= Proto.MPF_MOVE + 1	-- [机械加工功能]删除

function Proto.parseWiringPosition(entry)
	local data={};
	data.pos=Proto.parsePOS2D(entry); -- 坐上角位置
	data.dir=Proto.parseBYTE(entry); -- 十二点钟方向
	return data;
end

function Proto.writeWiringPosition(msg,data)
	Proto.writePOS2D(msg,data.pos); -- 坐上角位置
	Proto.writeBYTE(msg,data.dir); -- 十二点钟方向
end

function Proto.parseCookerHole(entry)
	local data={};
	data.hole=Proto.parsePOS2D(entry); -- 灶孔位置
	data.work=Proto.parsePOS2D_S(entry); -- 工作位置
	return data;
end

function Proto.writeCookerHole(msg,data)
	Proto.writePOS2D(msg,data.hole); -- 灶孔位置
	Proto.writePOS2D_S(msg,data.work); -- 工作位置
end

function Proto.parseRestaurantLevelInfo(entry)
	local data={};
	data.level=Proto.parseBYTE(entry); -- 等级
	data.prestigeLevel=Proto.parseBYTE(entry); -- 需要声望等级
	data.headDirection=Proto.parseDirectType(entry); -- 队首方向
	data.queue=Proto.parseVarArray(entry,Proto.parsePOS2D_S,Proto.parseWORD); -- 排队点
	return data;
end

function Proto.writeRestaurantLevelInfo(msg,data)
	Proto.writeBYTE(msg,data.level); -- 等级
	Proto.writeBYTE(msg,data.prestigeLevel); -- 需要声望等级
	Proto.writeDirectType(msg,data.headDirection); -- 队首方向
	Proto.writeVarArray(msg,data.queue,Proto.writePOS2D_S,Proto.writeWORD); -- 排队点
end

function Proto.parseFacilityInfo_BODY_Cooker(entry)
	local data={};
	data.holes=Proto.parseVarArray(entry,Proto.parseCookerHole,Proto.parseWORD); -- 灶孔
	return data;
end

function Proto.writeFacilityInfo_BODY_Cooker(msg,data)
	Proto.writeVarArray(msg,data.holes,Proto.writeCookerHole,Proto.writeWORD); -- 灶孔
end

function Proto.parseFacilityInfo_BODY_FoodCabinet(entry)
	local data={};
	data.gate=Proto.parsePOS2D(entry); -- 门位置
	data.open=Proto.parsePOS2D_S(entry); -- 开门位置
	return data;
end

function Proto.writeFacilityInfo_BODY_FoodCabinet(msg,data)
	Proto.writePOS2D(msg,data.gate); -- 门位置
	Proto.writePOS2D_S(msg,data.open); -- 开门位置
end

function Proto.parseFacilityInfo_BODY_DiningTable(entry)
	local data={};
	data.center=Proto.parsePOS2D(entry); -- 中心点坐标
	data.seats=Proto.parseVarArray(entry,Proto.parsePOS2D,Proto.parseWORD); -- 座位
	return data;
end

function Proto.writeFacilityInfo_BODY_DiningTable(msg,data)
	Proto.writePOS2D(msg,data.center); -- 中心点坐标
	Proto.writeVarArray(msg,data.seats,Proto.writePOS2D,Proto.writeWORD); -- 座位
end

function Proto.parseFacilityInfo_BODY_Wiring(entry)
	local data={};
	data.series=Proto.parseBYTE(entry); -- 系列
	data.touch=Proto.parsePOS2D(entry); -- 接触点
	data.stand=Proto.parsePOS2D_S(entry); -- 站位点
	return data;
end

function Proto.writeFacilityInfo_BODY_Wiring(msg,data)
	Proto.writeBYTE(msg,data.series); -- 系列
	Proto.writePOS2D(msg,data.touch); -- 接触点
	Proto.writePOS2D_S(msg,data.stand); -- 站位点
end

function Proto.parseFacilityInfo_BODY_WorkTable(entry)
	local data={};
	data.touch=Proto.parsePOS2D(entry); -- 接触点
	data.stand=Proto.parsePOS2D_S(entry); -- 站位点
	return data;
end

function Proto.writeFacilityInfo_BODY_WorkTable(msg,data)
	Proto.writePOS2D(msg,data.touch); -- 接触点
	Proto.writePOS2D_S(msg,data.stand); -- 站位点
end

function Proto.parseFacilityInfo_BODY_WiringTable(entry)
	local data={};
	data.positions=Proto.parseVarArray(entry,Proto.parseWiringPosition,Proto.parseWORD); -- 电器位置
	return data;
end

function Proto.writeFacilityInfo_BODY_WiringTable(msg,data)
	Proto.writeVarArray(msg,data.positions,Proto.writeWiringPosition,Proto.writeWORD); -- 电器位置
end

function Proto.parseFacilityInfo_BODY_Boiler(entry)
	local data={};
	data.series=Proto.parseBYTE(entry); -- 系列
	return data;
end

function Proto.writeFacilityInfo_BODY_Boiler(msg,data)
	Proto.writeBYTE(msg,data.series); -- 系列
end

function Proto.parseFacilityInfo_BODY_Machine(entry)
	local data={};
	data.maxDuration=Proto.parseWORD(entry); -- 最大耐久度
	data.damageProb=Proto.parseWORD(entry); -- 损坏概率(万分之一)
	data.fittings=Proto.parseDWORD(entry); -- 配件
	return data;
end

function Proto.writeFacilityInfo_BODY_Machine(msg,data)
	Proto.writeWORD(msg,data.maxDuration); -- 最大耐久度
	Proto.writeWORD(msg,data.damageProb); -- 损坏概率(万分之一)
	Proto.writeDWORD(msg,data.fittings); -- 配件
end

function Proto.parseFacilityInfo_BODY_Restaurant(entry)
	local data={};
	data.initMenu=Proto.parseVarArray(entry,Proto.parseDWORD,Proto.parseWORD); -- 初始菜单
	data.menu=Proto.parseVarArray(entry,Proto.parseDWORD,Proto.parseWORD); -- 可用菜单
	data.levels=Proto.parseVarArray(entry,Proto.parseRestaurantLevelInfo,Proto.parseWORD); -- 等级信息
	return data;
end

function Proto.writeFacilityInfo_BODY_Restaurant(msg,data)
	Proto.writeVarArray(msg,data.initMenu,Proto.writeDWORD,Proto.writeWORD); -- 初始菜单
	Proto.writeVarArray(msg,data.menu,Proto.writeDWORD,Proto.writeWORD); -- 可用菜单
	Proto.writeVarArray(msg,data.levels,Proto.writeRestaurantLevelInfo,Proto.writeWORD); -- 等级信息
end

function Proto.parseFacilityInfo_BODY_Spa(entry)
	local data={};
	data.wells=Proto.parseVarArray(entry,Proto.parsePOS2D_S,Proto.parseWORD); -- 泉井
	data.leave=Proto.parsePOS2D_S(entry); -- 离开点
	data.headDirection=Proto.parseDirectType(entry); -- 队首方向
	data.queue=Proto.parseVarArray(entry,Proto.parsePOS2D_S,Proto.parseWORD); -- 排队点
	data.maxWaterStorage=Proto.parseWORD(entry); -- 最大水量
	data.power=Proto.parseDWORD(entry); -- 加热功率
	data.maxDuration=Proto.parseWORD(entry); -- 最大耐久度
	return data;
end

function Proto.writeFacilityInfo_BODY_Spa(msg,data)
	Proto.writeVarArray(msg,data.wells,Proto.writePOS2D_S,Proto.writeWORD); -- 泉井
	Proto.writePOS2D_S(msg,data.leave); -- 离开点
	Proto.writeDirectType(msg,data.headDirection); -- 队首方向
	Proto.writeVarArray(msg,data.queue,Proto.writePOS2D_S,Proto.writeWORD); -- 排队点
	Proto.writeWORD(msg,data.maxWaterStorage); -- 最大水量
	Proto.writeDWORD(msg,data.power); -- 加热功率
	Proto.writeWORD(msg,data.maxDuration); -- 最大耐久度
end

function Proto.parseFacilityInfo_BODY_PetDorm(entry)
	local data={};
	data.room=Proto.parsePOS2D(entry); -- 房间位置
	return data;
end

function Proto.writeFacilityInfo_BODY_PetDorm(msg,data)
	Proto.writePOS2D(msg,data.room); -- 房间位置
end

function Proto.parseFacilityInfo_BODY_Counter(entry)
	local data={};
	data.itemCount=Proto.parseBYTE(entry); -- 商品数量
	return data;
end

function Proto.writeFacilityInfo_BODY_Counter(msg,data)
	Proto.writeBYTE(msg,data.itemCount); -- 商品数量
end

function Proto.parseFacilityInfo_BODY_GardenMachine(entry)
	local data={};
	data.maxDuration=Proto.parseWORD(entry); -- 最大耐久度
	data.functionMask=Proto.parseBYTE(entry); -- 功能
	return data;
end

function Proto.writeFacilityInfo_BODY_GardenMachine(msg,data)
	Proto.writeWORD(msg,data.maxDuration); -- 最大耐久度
	Proto.writeBYTE(msg,data.functionMask); -- 功能
end

function Proto.parseFacilityInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 设备类型ID
	data.category=Proto.parseBYTE(entry); -- 设施种类
	data.code=Proto.parseFacilityCode(entry); -- 编码(英文符号)
	data.name=Proto.parseFacilityName(entry); -- 名称(本地符号)
	data.length=Proto.parseBYTE(entry); -- 长
	data.width=Proto.parseBYTE(entry); -- 宽
	data.level=Proto.parseBYTE(entry); -- 等级
	data.reclaim=Proto.parseBYTE(entry); -- 回收标志
	data.shapeMasks=Proto.parseVarArray(entry,Proto.parsePOS2D,Proto.parseWORD); -- 形状掩码
	data.body={}; -- 
	if (data.category==Proto.FC_COOKER) then
		data.body.cooker=Proto.parseFacilityInfo_BODY_Cooker(entry); -- 灶
	end
	if (data.category==Proto.FC_FOODCABINET) then
		data.body.foodCabinet=Proto.parseFacilityInfo_BODY_FoodCabinet(entry); -- 食品柜
	end
	if (data.category==Proto.FC_DININGTABLE) then
		data.body.diningTable=Proto.parseFacilityInfo_BODY_DiningTable(entry); -- 餐桌
	end
	if (data.category==Proto.FC_WIRING) then
		data.body.wiring=Proto.parseFacilityInfo_BODY_Wiring(entry); -- 电器设备
	end
	if (data.category==Proto.FC_WORKTABLE) then
		data.body.workTable=Proto.parseFacilityInfo_BODY_WorkTable(entry); -- 操作台
	end
	if (data.category==Proto.FC_WIRINGTABLE) then
		data.body.wiringTable=Proto.parseFacilityInfo_BODY_WiringTable(entry); -- 电器台
	end
	if (data.category==Proto.FC_BOILER) then
		data.body.boiler=Proto.parseFacilityInfo_BODY_Boiler(entry); -- 锅类炊具
	end
	if (data.category==Proto.FC_MACHINE) then
		data.body.machine=Proto.parseFacilityInfo_BODY_Machine(entry); -- 机械
	end
	if (data.category==Proto.FC_RESTAURANT) then
		data.body.restaurant=Proto.parseFacilityInfo_BODY_Restaurant(entry); -- 饭店
	end
	if (data.category==Proto.FC_SPA) then
		data.body.spa=Proto.parseFacilityInfo_BODY_Spa(entry); -- 温泉
	end
	if (data.category==Proto.FC_PETDORM) then
		data.body.petDorm=Proto.parseFacilityInfo_BODY_PetDorm(entry); -- 宠物宿舍
	end
	if (data.category==Proto.FC_COUNTER) then
		data.body.counter=Proto.parseFacilityInfo_BODY_Counter(entry); -- 柜台
	end
	if (data.category==Proto.FC_GARDENMACHINE) then
		data.body.gardenMachine=Proto.parseFacilityInfo_BODY_GardenMachine(entry); -- 园丁机器人
	end
	return data;
end

function Proto.getFacilityInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeFacilityInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 设备类型ID
	Proto.writeBYTE(msg,data.category); -- 设施种类
	Proto.writeFacilityCode(msg,data.code); -- 编码(英文符号)
	Proto.writeFacilityName(msg,data.name); -- 名称(本地符号)
	Proto.writeBYTE(msg,data.length); -- 长
	Proto.writeBYTE(msg,data.width); -- 宽
	Proto.writeBYTE(msg,data.level); -- 等级
	Proto.writeBYTE(msg,data.reclaim); -- 回收标志
	Proto.writeVarArray(msg,data.shapeMasks,Proto.writePOS2D,Proto.writeWORD); -- 形状掩码
	if (data.category==Proto.FC_COOKER) then
		Proto.writeFacilityInfo_BODY_Cooker(msg,data.body.cooker); -- 灶
	end
	if (data.category==Proto.FC_FOODCABINET) then
		Proto.writeFacilityInfo_BODY_FoodCabinet(msg,data.body.foodCabinet); -- 食品柜
	end
	if (data.category==Proto.FC_DININGTABLE) then
		Proto.writeFacilityInfo_BODY_DiningTable(msg,data.body.diningTable); -- 餐桌
	end
	if (data.category==Proto.FC_WIRING) then
		Proto.writeFacilityInfo_BODY_Wiring(msg,data.body.wiring); -- 电器设备
	end
	if (data.category==Proto.FC_WORKTABLE) then
		Proto.writeFacilityInfo_BODY_WorkTable(msg,data.body.workTable); -- 操作台
	end
	if (data.category==Proto.FC_WIRINGTABLE) then
		Proto.writeFacilityInfo_BODY_WiringTable(msg,data.body.wiringTable); -- 电器台
	end
	if (data.category==Proto.FC_BOILER) then
		Proto.writeFacilityInfo_BODY_Boiler(msg,data.body.boiler); -- 锅类炊具
	end
	if (data.category==Proto.FC_MACHINE) then
		Proto.writeFacilityInfo_BODY_Machine(msg,data.body.machine); -- 机械
	end
	if (data.category==Proto.FC_RESTAURANT) then
		Proto.writeFacilityInfo_BODY_Restaurant(msg,data.body.restaurant); -- 饭店
	end
	if (data.category==Proto.FC_SPA) then
		Proto.writeFacilityInfo_BODY_Spa(msg,data.body.spa); -- 温泉
	end
	if (data.category==Proto.FC_PETDORM) then
		Proto.writeFacilityInfo_BODY_PetDorm(msg,data.body.petDorm); -- 宠物宿舍
	end
	if (data.category==Proto.FC_COUNTER) then
		Proto.writeFacilityInfo_BODY_Counter(msg,data.body.counter); -- 柜台
	end
	if (data.category==Proto.FC_GARDENMACHINE) then
		Proto.writeFacilityInfo_BODY_GardenMachine(msg,data.body.gardenMachine); -- 园丁机器人
	end
end

function Proto.parseFacilityFavorGroup(entry)
	local data={};
	data.id=Proto.parseWORD(entry); -- 人气组编号
	data.name=Proto.parseString(entry); -- 人气上限
	data.ninkiLimit=Proto.parseDWORD(entry); -- 人气上限
	return data;
end

function Proto.getFacilityFavorGroupIDLen()
	return Proto.getWORDLen();
end

function Proto.writeFacilityFavorGroup(msg,data)
	Proto.writeWORD(msg,data.id); -- 人气组编号
	Proto.writeString(msg,data.name); -- 人气上限
	Proto.writeDWORD(msg,data.ninkiLimit); -- 人气上限
end

function Proto.parseNationNinki(entry)
	local data={};
	data.nationID=Proto.parseBYTE(entry); -- 阵营ID
	data.ninki=Proto.parseDWORD(entry); -- 人气
	return data;
end

function Proto.writeNationNinki(msg,data)
	Proto.writeBYTE(msg,data.nationID); -- 阵营ID
	Proto.writeDWORD(msg,data.ninki); -- 人气
end

function Proto.parseFacilityFavorInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 设备类型ID
	data.favorGroupID=Proto.parseWORD(entry); -- 人气组编号
	data.nationNinki=Proto.parseVector(entry,Proto.parseNationNinki); -- 阵营人气
	return data;
end

function Proto.getFacilityFavorInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeFacilityFavorInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 设备类型ID
	Proto.writeWORD(msg,data.favorGroupID); -- 人气组编号
	Proto.writeVector(msg,data.nationNinki,Proto.writeNationNinki); -- 阵营人气
end

function Proto.parseFacilityData_BODY_Machine(entry)
	local data={};
	data.curDuration=Proto.parseWORD(entry); -- 当前耐久度
	data.maxDuration=Proto.parseWORD(entry); -- 最大耐久度
	data.fare=Proto.parseint(entry); -- 使用费(G币)
	return data;
end

function Proto.writeFacilityData_BODY_Machine(msg,data)
	Proto.writeWORD(msg,data.curDuration); -- 当前耐久度
	Proto.writeWORD(msg,data.maxDuration); -- 最大耐久度
	Proto.writeint(msg,data.fare); -- 使用费(G币)
end

function Proto.parseFacilityData_BODY_Counter(entry)
	local data={};
	data.items=Proto.parseVarArray(entry,Proto.parseDWORD,Proto.parseWORD); -- 商品
	return data;
end

function Proto.writeFacilityData_BODY_Counter(msg,data)
	Proto.writeVarArray(msg,data.items,Proto.writeDWORD,Proto.writeWORD); -- 商品
end

function Proto.parseFacilityData_BODY_PetDorm_FeedItem(entry)
	local data={};
	data.foodID=Proto.parseDWORD(entry); -- 食物ID
	data.count=Proto.parseDWORD(entry); -- 数量
	return data;
end

function Proto.writeFacilityData_BODY_PetDorm_FeedItem(msg,data)
	Proto.writeDWORD(msg,data.foodID); -- 食物ID
	Proto.writeDWORD(msg,data.count); -- 数量
end

function Proto.parseFacilityData_BODY_PetDorm(entry)
	local data={};
	data.feeds=Proto.parseVarArray(entry,Proto.parseFacilityData_BODY_PetDorm_FeedItem,Proto.parseWORD); -- 饲料
	return data;
end

function Proto.writeFacilityData_BODY_PetDorm(msg,data)
	Proto.writeVarArray(msg,data.feeds,Proto.writeFacilityData_BODY_PetDorm_FeedItem,Proto.writeWORD); -- 饲料
end

function Proto.parseFacilityData_BODY_GardenMachine(entry)
	local data={};
	data.curDuration=Proto.parseWORD(entry); -- 当前耐久度
	data.maxDuration=Proto.parseWORD(entry); -- 最大耐久度
	return data;
end

function Proto.writeFacilityData_BODY_GardenMachine(msg,data)
	Proto.writeWORD(msg,data.curDuration); -- 当前耐久度
	Proto.writeWORD(msg,data.maxDuration); -- 最大耐久度
end

function Proto.parseFacilityData(entry)
	local data={};
	data.category=Proto.parseBYTE(entry); -- 设施种类
	data.body={}; -- 
	if (data.category==Proto.FC_MACHINE) then
		data.body.machine=Proto.parseFacilityData_BODY_Machine(entry); -- 机械
	end
	if (data.category==Proto.FC_COUNTER) then
		data.body.counter=Proto.parseFacilityData_BODY_Counter(entry); -- 柜台
	end
	if (data.category==Proto.FC_PETDORM) then
		data.body.petDorm=Proto.parseFacilityData_BODY_PetDorm(entry); -- 宠物宿舍
	end
	if (data.category==Proto.FC_GARDENMACHINE) then
		data.body.gardenMachine=Proto.parseFacilityData_BODY_GardenMachine(entry); -- 园丁机器人
	end
	return data;
end

function Proto.writeFacilityData(msg,data)
	Proto.writeBYTE(msg,data.category); -- 设施种类
	if (data.category==Proto.FC_MACHINE) then
		Proto.writeFacilityData_BODY_Machine(msg,data.body.machine); -- 机械
	end
	if (data.category==Proto.FC_COUNTER) then
		Proto.writeFacilityData_BODY_Counter(msg,data.body.counter); -- 柜台
	end
	if (data.category==Proto.FC_PETDORM) then
		Proto.writeFacilityData_BODY_PetDorm(msg,data.body.petDorm); -- 宠物宿舍
	end
	if (data.category==Proto.FC_GARDENMACHINE) then
		Proto.writeFacilityData_BODY_GardenMachine(msg,data.body.gardenMachine); -- 园丁机器人
	end
end

function Proto.parseFacilityDesc(entry)
	local data={};
	data.type=Proto.parseDWORD(entry); -- 设备类型
	data.pos=Proto.parsePOS2D(entry); -- 设备相对位置
	data.direction=Proto.parseBYTE(entry); -- 设备相对方向
	data.pid=Proto.parseQWORD(entry); -- 父设施ID
	if (data.pid~=0) then
		data.part=Proto.parseBYTE(entry); -- 部位
	end
	data.data=Proto.parseFacilityData(entry); -- 设备数据
	return data;
end

function Proto.writeFacilityDesc(msg,data)
	Proto.writeDWORD(msg,data.type); -- 设备类型
	Proto.writePOS2D(msg,data.pos); -- 设备相对位置
	Proto.writeBYTE(msg,data.direction); -- 设备相对方向
	Proto.writeQWORD(msg,data.pid); -- 父设施ID
	if (data.pid~=0) then
		Proto.writeBYTE(msg,data.part); -- 部位
	end
	Proto.writeFacilityData(msg,data.data); -- 设备数据
end

function Proto.parseFacility(entry)
	local data={};
	data.id=Proto.parseQWORD(entry); -- 设备ID
	data.facilityDesc=Proto.parseFacilityDesc(entry); -- 设备描述
	return data;
end

function Proto.getFacilityIDLen()
	return Proto.getQWORDLen();
end

function Proto.writeFacility(msg,data)
	Proto.writeQWORD(msg,data.id); -- 设备ID
	Proto.writeFacilityDesc(msg,data.facilityDesc); -- 设备描述
end

function Proto.parseMachineInput(entry)
	local data={};
	data.item_type=Proto.parseDWORD(entry); -- 道具类型
	data.count=Proto.parseWORD(entry); -- 道具数量
	return data;
end

function Proto.writeMachineInput(msg,data)
	Proto.writeDWORD(msg,data.item_type); -- 道具类型
	Proto.writeWORD(msg,data.count); -- 道具数量
end

function Proto.parseMachineOutputItem(entry)
	local data={};
	data.item_generateID=Proto.parseDWORD(entry); -- 道具类型
	data.minCount=Proto.parseWORD(entry); -- 最小数量
	data.maxCount=Proto.parseWORD(entry); -- 最大数量
	return data;
end

function Proto.writeMachineOutputItem(msg,data)
	Proto.writeDWORD(msg,data.item_generateID); -- 道具类型
	Proto.writeWORD(msg,data.minCount); -- 最小数量
	Proto.writeWORD(msg,data.maxCount); -- 最大数量
end

function Proto.parseMachineOutput(entry)
	local data={};
	data.prob=Proto.parseDWORD(entry); -- 概率(千万分之一概率)
	data.products=Proto.parseVarArray(entry,Proto.parseMachineOutputItem,Proto.parseWORD); -- 生成产品
	return data;
end

function Proto.writeMachineOutput(msg,data)
	Proto.writeDWORD(msg,data.prob); -- 概率(千万分之一概率)
	Proto.writeVarArray(msg,data.products,Proto.writeMachineOutputItem,Proto.writeWORD); -- 生成产品
end

function Proto.parseMachineOutputGroup(entry)
	local data={};
	data.products=Proto.parseVarArray(entry,Proto.parseMachineOutput,Proto.parseWORD); -- 生成产品
	return data;
end

function Proto.writeMachineOutputGroup(msg,data)
	Proto.writeVarArray(msg,data.products,Proto.writeMachineOutput,Proto.writeWORD); -- 生成产品
end

function Proto.parseProductLineInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 生产线id
	data.inputs=Proto.parseVarArray(entry,Proto.parseMachineInput,Proto.parseWORD); -- 输入
	data.ms=Proto.parseDWORD(entry); -- 时间
	data.groups=Proto.parseVarArray(entry,Proto.parseMachineOutputGroup,Proto.parseWORD); -- 输出组
	return data;
end

function Proto.getProductLineInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeProductLineInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 生产线id
	Proto.writeVarArray(msg,data.inputs,Proto.writeMachineInput,Proto.writeWORD); -- 输入
	Proto.writeDWORD(msg,data.ms); -- 时间
	Proto.writeVarArray(msg,data.groups,Proto.writeMachineOutputGroup,Proto.writeWORD); -- 输出组
end

function Proto.parseMachineProductLineInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 设备类型
	data.lines=Proto.parseVector(entry,Proto.parseDWORD); -- 生产线ID
	return data;
end

function Proto.getMachineProductLineInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeMachineProductLineInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 设备类型
	Proto.writeVector(msg,data.lines,Proto.writeDWORD); -- 生产线ID
end

function Proto.parseNpcProductInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- npcID
	data.productLines=Proto.parseVector(entry,Proto.parseDWORD); -- 生产线集合
	return data;
end

function Proto.getNpcProductInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeNpcProductInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- npcID
	Proto.writeVector(msg,data.productLines,Proto.writeDWORD); -- 生产线集合
end

