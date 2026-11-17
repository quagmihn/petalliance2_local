-- Net.Proto.Proto_Plant_Types

Proto.PS_SEED				= 0							-- [植物种植状态（对服务器的概念来说PS_GROWING,PS_HARVEST,PS_RESTING，PS_SEED没有判定上的区别）]苗期
Proto.PS_GROWING			= Proto.PS_SEED + 1			-- [植物种植状态（对服务器的概念来说PS_GROWING,PS_HARVEST,PS_RESTING，PS_SEED没有判定上的区别）]生长中(生长期)
Proto.PS_HARVEST			= Proto.PS_GROWING + 1		-- [植物种植状态（对服务器的概念来说PS_GROWING,PS_HARVEST,PS_RESTING，PS_SEED没有判定上的区别）]收获期
Proto.PS_RESTING			= Proto.PS_HARVEST + 1		-- [植物种植状态（对服务器的概念来说PS_GROWING,PS_HARVEST,PS_RESTING，PS_SEED没有判定上的区别）]休眠期
Proto.PS_INGATHERED			= Proto.PS_RESTING + 1		-- [植物种植状态（对服务器的概念来说PS_GROWING,PS_HARVEST,PS_RESTING，PS_SEED没有判定上的区别）]已收获
Proto.PS_DEAD				= Proto.PS_INGATHERED + 1	-- [植物种植状态（对服务器的概念来说PS_GROWING,PS_HARVEST,PS_RESTING，PS_SEED没有判定上的区别）]死亡(将从数据库删除)
Proto.PS_DEAD_INGATHERED	= Proto.PS_DEAD + 1			-- [植物种植状态（对服务器的概念来说PS_GROWING,PS_HARVEST,PS_RESTING，PS_SEED没有判定上的区别）]收获后的死亡(应从数据库删除)
Proto.OT_IRRIGATE	= 0						-- [操作类型]浇水
Proto.OT_INGATHER	= Proto.OT_IRRIGATE + 1	-- [操作类型]采摘
Proto.OT_CLEAR		= Proto.OT_INGATHER + 1	-- [操作类型]清除
Proto.BS_WATER	= 0	-- [植物营养标志状态]缺水标志位
Proto.EET_GROWTHPERCENTUP		= 0									-- [环境效果类型]生长速度按百分比加快
Proto.EET_WATERPERCENTDOWN		= Proto.EET_GROWTHPERCENTUP + 1		-- [环境效果类型]水分消耗按百分比减少
Proto.EET_LONGEVITYUPBYSEASON	= Proto.EET_WATERPERCENTDOWN + 1	-- [环境效果类型]寿命增加季节数
Proto.EET_DEATHRATE				= Proto.EET_LONGEVITYUPBYSEASON + 1	-- [环境效果类型]死亡率(千万分之一)

function Proto.parsePlantOutput(entry)
	local data={};
	data.itemGenerateID=Proto.parseDWORD(entry); -- 植物类型ID
	data.outputRate=Proto.parseBYTE(entry); -- 产出率
	return data;
end

function Proto.writePlantOutput(msg,data)
	Proto.writeDWORD(msg,data.itemGenerateID); -- 植物类型ID
	Proto.writeBYTE(msg,data.outputRate); -- 产出率
end

function Proto.parsePlantInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 植物类型ID
	data.name=Proto.parsePlantNick(entry); -- 植物名称
	data.conversion=Proto.parseWORD(entry); -- 单位换算产量
	data.waterCost=Proto.parseBYTE(entry); -- 水分消耗速度
	data.longevitySeasons=Proto.parseBYTE(entry); -- 寿命（季节数）
	data.springCost=Proto.parseBYTE(entry); -- 春季的养分消耗率(%)
	data.summerCost=Proto.parseBYTE(entry); -- 夏季的养分消耗率(%)
	data.autumnCost=Proto.parseBYTE(entry); -- 秋季的养分消耗率(%)
	data.winterCost=Proto.parseBYTE(entry); -- 冬季的养分消耗率(%)
	data.plantingSeasonMask=Proto.parseBYTE(entry); -- 种植季节掩码(1<<SEASON_TYPE)
	data.seedSeasons=Proto.parseBYTE(entry); -- 幼苗季节数
	data.harvestSeasons=Proto.parseBYTE(entry); -- 收获季节数
	data.growSeasons=Proto.parseBYTE(entry); -- 无果(成长)期季节数
	data.restingSeasons=Proto.parseBYTE(entry); -- 休眠季节数
	data.groupType=Proto.parseBYTE(entry); -- 植物组类型
	data.speciesType=Proto.parseBYTE(entry); -- 生存类型
	data.size=Proto.parseBYTE(entry); -- 植物的占位大小
	data.mainProducts=Proto.parseVector(entry,Proto.parsePlantOutput); -- 主产物
	data.byproductGranduleLimit=Proto.parseDWORD(entry); -- 副产品的粒度上限
	data.byproducts=Proto.parseVector(entry,Proto.parsePlantOutput); -- 副产物
	data.matureGrowthRate=Proto.parseWORD(entry); -- 成熟生长率
	data.irrigateItems=Proto.parseVector(entry,Proto.parseDWORD); -- 可用于灌溉的消耗道具
	return data;
end

function Proto.getPlantInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writePlantInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 植物类型ID
	Proto.writePlantNick(msg,data.name); -- 植物名称
	Proto.writeWORD(msg,data.conversion); -- 单位换算产量
	Proto.writeBYTE(msg,data.waterCost); -- 水分消耗速度
	Proto.writeBYTE(msg,data.longevitySeasons); -- 寿命（季节数）
	Proto.writeBYTE(msg,data.springCost); -- 春季的养分消耗率(%)
	Proto.writeBYTE(msg,data.summerCost); -- 夏季的养分消耗率(%)
	Proto.writeBYTE(msg,data.autumnCost); -- 秋季的养分消耗率(%)
	Proto.writeBYTE(msg,data.winterCost); -- 冬季的养分消耗率(%)
	Proto.writeBYTE(msg,data.plantingSeasonMask); -- 种植季节掩码(1<<SEASON_TYPE)
	Proto.writeBYTE(msg,data.seedSeasons); -- 幼苗季节数
	Proto.writeBYTE(msg,data.harvestSeasons); -- 收获季节数
	Proto.writeBYTE(msg,data.growSeasons); -- 无果(成长)期季节数
	Proto.writeBYTE(msg,data.restingSeasons); -- 休眠季节数
	Proto.writeBYTE(msg,data.groupType); -- 植物组类型
	Proto.writeBYTE(msg,data.speciesType); -- 生存类型
	Proto.writeBYTE(msg,data.size); -- 植物的占位大小
	Proto.writeVector(msg,data.mainProducts,Proto.writePlantOutput); -- 主产物
	Proto.writeDWORD(msg,data.byproductGranduleLimit); -- 副产品的粒度上限
	Proto.writeVector(msg,data.byproducts,Proto.writePlantOutput); -- 副产物
	Proto.writeWORD(msg,data.matureGrowthRate); -- 成熟生长率
	Proto.writeVector(msg,data.irrigateItems,Proto.writeDWORD); -- 可用于灌溉的消耗道具
end

function Proto.parsePlant(entry)
	local data={};
	data.pos=Proto.parsePOS2D(entry); -- 植物单元格坐标
	data.type_id=Proto.parseDWORD(entry); -- 植物类型
	data.water=Proto.parseWORD(entry); -- 水分
	data.granule=Proto.parseDWORD(entry); -- 主产品累积粒度
	data.byproductGrandule=Proto.parseDWORD(entry); -- 副产品粒度
	data.state=Proto.parseBYTE(entry); -- 生长阶段,GrowthState
	data.plantingTime=Proto.parseDWORD(entry); -- 种植时间
	data.direction=Proto.parseBYTE(entry); -- 方向
	return data;
end

function Proto.writePlant(msg,data)
	Proto.writePOS2D(msg,data.pos); -- 植物单元格坐标
	Proto.writeDWORD(msg,data.type_id); -- 植物类型
	Proto.writeWORD(msg,data.water); -- 水分
	Proto.writeDWORD(msg,data.granule); -- 主产品累积粒度
	Proto.writeDWORD(msg,data.byproductGrandule); -- 副产品粒度
	Proto.writeBYTE(msg,data.state); -- 生长阶段,GrowthState
	Proto.writeDWORD(msg,data.plantingTime); -- 种植时间
	Proto.writeBYTE(msg,data.direction); -- 方向
end

function Proto.parsePlantOperateInfo(entry)
	local data={};
	data.id=Proto.parseBYTE(entry); -- 植物组类
	data.maskSeed=Proto.parseWORD(entry); -- 种苗期掩码
	data.maskGrowing=Proto.parseWORD(entry); -- 生长期掩码
	data.maskHarvest=Proto.parseWORD(entry); -- 收获期掩码
	data.maskResting=Proto.parseWORD(entry); -- 休眠期掩码
	return data;
end

function Proto.getPlantOperateInfoIDLen()
	return Proto.getBYTELen();
end

function Proto.writePlantOperateInfo(msg,data)
	Proto.writeBYTE(msg,data.id); -- 植物组类
	Proto.writeWORD(msg,data.maskSeed); -- 种苗期掩码
	Proto.writeWORD(msg,data.maskGrowing); -- 生长期掩码
	Proto.writeWORD(msg,data.maskHarvest); -- 收获期掩码
	Proto.writeWORD(msg,data.maskResting); -- 休眠期掩码
end

function Proto.parsePlantDetail(entry)
	local data={};
	data.plant=Proto.parsePlant(entry); -- 植物属性
	data.updateTime=Proto.parseDWORD(entry); -- 更新时间
	return data;
end

function Proto.writePlantDetail(msg,data)
	Proto.writePlant(msg,data.plant); -- 植物属性
	Proto.writeDWORD(msg,data.updateTime); -- 更新时间
end

function Proto.parsePlantState(entry)
	local data={};
	data.plant=Proto.parsePlant(entry); -- 植物属性
	return data;
end

function Proto.writePlantState(msg,data)
	Proto.writePlant(msg,data.plant); -- 植物属性
end

function Proto.parseSeedPlant(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 种子道具类型ID
	data.plant_type=Proto.parseDWORD(entry); -- 植物类型ID
	return data;
end

function Proto.getSeedPlantIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeSeedPlant(msg,data)
	Proto.writeDWORD(msg,data.id); -- 种子道具类型ID
	Proto.writeDWORD(msg,data.plant_type); -- 植物类型ID
end

function Proto.parseToolOperate(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 工具道具类型ID
	data.operateType=Proto.parseBYTE(entry); -- 操作类型(OperateType)
	data.timeCost=Proto.parseDWORD(entry); -- 花费时间
	return data;
end

function Proto.getToolOperateIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeToolOperate(msg,data)
	Proto.writeDWORD(msg,data.id); -- 工具道具类型ID
	Proto.writeBYTE(msg,data.operateType); -- 操作类型(OperateType)
	Proto.writeDWORD(msg,data.timeCost); -- 花费时间
end

function Proto.parseEnvironalEffect(entry)
	local data={};
	data.effectType=Proto.parseBYTE(entry); -- 环境效果类型
	data.value=Proto.parseint(entry); -- 对应值
	return data;
end

function Proto.writeEnvironalEffect(msg,data)
	Proto.writeBYTE(msg,data.effectType); -- 环境效果类型
	Proto.writeint(msg,data.value); -- 对应值
end

function Proto.parseEnvironalEffectInfo(entry)
	local data={};
	data.id=Proto.parseWORD(entry); -- 环境效果类型
	data.name=Proto.parseString(entry); -- 环境效果类型名称
	data.effects=Proto.parseVector(entry,Proto.parseEnvironalEffect); -- 效果内容
	return data;
end

function Proto.getEnvironalEffectInfoIDLen()
	return Proto.getWORDLen();
end

function Proto.writeEnvironalEffectInfo(msg,data)
	Proto.writeWORD(msg,data.id); -- 环境效果类型
	Proto.writeString(msg,data.name); -- 环境效果类型名称
	Proto.writeVector(msg,data.effects,Proto.writeEnvironalEffect); -- 效果内容
end

function Proto.parsePlantPeciesEnvironal(entry)
	local data={};
	data.species=Proto.parseBYTE(entry); -- 种类
	data.eEffectInfos=Proto.parseVector(entry,Proto.parseWORD); -- 环境效果信息表
	return data;
end

function Proto.writePlantPeciesEnvironal(msg,data)
	Proto.writeBYTE(msg,data.species); -- 种类
	Proto.writeVector(msg,data.eEffectInfos,Proto.writeWORD); -- 环境效果信息表
end

function Proto.parseIrrigateItemInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 相应的道具类型ID
	data.waterRecover=Proto.parseWORD(entry); -- 恢复水分
	data.waterLimit=Proto.parseWORD(entry); -- 水分上限
	return data;
end

function Proto.getIrrigateItemInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeIrrigateItemInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 相应的道具类型ID
	Proto.writeWORD(msg,data.waterRecover); -- 恢复水分
	Proto.writeWORD(msg,data.waterLimit); -- 水分上限
end

