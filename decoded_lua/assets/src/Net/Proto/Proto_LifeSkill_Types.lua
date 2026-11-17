-- Net.Proto.Proto_LifeSkill_Types

Proto.LST_COLLECT	= 0							-- [生活技能枚举]采集
Proto.LST_FASHION	= Proto.LST_COLLECT + 1		-- [生活技能枚举]时装师
Proto.LST_FURNITURE	= Proto.LST_FASHION + 1		-- [生活技能枚举]家具师
Proto.LST_DECORATE	= Proto.LST_FURNITURE + 1	-- [生活技能枚举]装潢师
Proto.LST_NUM		= Proto.LST_DECORATE + 1	-- [生活技能枚举]num
Proto.DT_FASHION_HEAD			= 0										-- [图纸类型]时装头饰
Proto.DT_FASHION_CLOTH			= Proto.DT_FASHION_HEAD + 1				-- [图纸类型]时装上衣
Proto.DT_FASHION_TROUSERS		= Proto.DT_FASHION_CLOTH + 1			-- [图纸类型]时装裤子
Proto.DT_FASHION_BACK			= Proto.DT_FASHION_TROUSERS + 1			-- [图纸类型]时装背饰
Proto.DT_FASHION_WEAPON			= Proto.DT_FASHION_BACK + 1				-- [图纸类型]时装武器
Proto.DT_FURNITURE_BED			= Proto.DT_FASHION_WEAPON + 1			-- [图纸类型]家具床
Proto.DT_FURNITURE_WARDROBE		= Proto.DT_FURNITURE_BED + 1			-- [图纸类型]家具衣柜
Proto.DT_FURNITURE_SOFA			= Proto.DT_FURNITURE_WARDROBE + 1		-- [图纸类型]家具沙发
Proto.DT_FURNITURE_TABLE		= Proto.DT_FURNITURE_SOFA + 1			-- [图纸类型]家具桌子
Proto.DT_FURNITURE_TV			= Proto.DT_FURNITURE_TABLE + 1			-- [图纸类型]家具电视
Proto.DT_FURNITURE_TREADMILL	= Proto.DT_FURNITURE_TV + 1				-- [图纸类型]家具跑步机
Proto.DT_FURNITURE_COMPUTER		= Proto.DT_FURNITURE_TREADMILL + 1		-- [图纸类型]家具电脑
Proto.DT_DECORATE_DOORPLATE		= Proto.DT_FURNITURE_COMPUTER + 1		-- [图纸类型]装潢门牌
Proto.DT_DECORATE_DOOR			= Proto.DT_DECORATE_DOORPLATE + 1		-- [图纸类型]装潢门
Proto.DT_DECORATE_SUITCASE		= Proto.DT_DECORATE_DOOR + 1			-- [图纸类型]装潢旅行箱
Proto.DT_DECORATE_WALLPAPER		= Proto.DT_DECORATE_SUITCASE + 1		-- [图纸类型]装潢墙纸
Proto.DT_DECORATE_FLOOR			= Proto.DT_DECORATE_WALLPAPER + 1		-- [图纸类型]装潢地板
Proto.DT_DECORATE_POTTING		= Proto.DT_DECORATE_FLOOR + 1			-- [图纸类型]装潢盆栽
Proto.DT_DECORATE_WALLDECORATE	= Proto.DT_DECORATE_POTTING + 1			-- [图纸类型]装潢墙饰
Proto.DT_DECORATE_PENDANT		= Proto.DT_DECORATE_WALLDECORATE + 1	-- [图纸类型]装潢吊灯

function Proto.parseDrawingInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 图纸ID
	data.name=Proto.parseString(entry); -- 名称
	data.itemID=Proto.parseDWORD(entry); -- 物品表图纸ID
	data.currencyType=Proto.parseBYTE(entry); -- 货币类型
	data.price=Proto.parseDWORD(entry); -- 售价
	data.description=Proto.parseString(entry); -- 说明
	data.drawingType=Proto.parseString(entry); -- 分类
	data.career=Proto.parseBYTE(entry); -- 需求职业
	data.level=Proto.parseBYTE(entry); -- 需求等级
	data.exp=Proto.parseDWORD(entry); -- 获得经验
	data.costs=Proto.parseVector(entry,Proto.parseDWORD); -- 消耗材料
	data.awards=Proto.parseVector(entry,Proto.parseDWORD); -- 获取奖励
	return data;
end

function Proto.getDrawingInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeDrawingInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 图纸ID
	Proto.writeString(msg,data.name); -- 名称
	Proto.writeDWORD(msg,data.itemID); -- 物品表图纸ID
	Proto.writeBYTE(msg,data.currencyType); -- 货币类型
	Proto.writeDWORD(msg,data.price); -- 售价
	Proto.writeString(msg,data.description); -- 说明
	Proto.writeString(msg,data.drawingType); -- 分类
	Proto.writeBYTE(msg,data.career); -- 需求职业
	Proto.writeBYTE(msg,data.level); -- 需求等级
	Proto.writeDWORD(msg,data.exp); -- 获得经验
	Proto.writeVector(msg,data.costs,Proto.writeDWORD); -- 消耗材料
	Proto.writeVector(msg,data.awards,Proto.writeDWORD); -- 获取奖励
end

function Proto.parseLifeSkillExp(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 等级
	data.exp=Proto.parseDWORD(entry); -- 需求经验
	return data;
end

function Proto.getLifeSkillExpIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeLifeSkillExp(msg,data)
	Proto.writeDWORD(msg,data.id); -- 等级
	Proto.writeDWORD(msg,data.exp); -- 需求经验
end

function Proto.parseLifeSkillCareerChange(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 等级
	data.elemID=Proto.parseDWORD(entry); -- 消费元素ID
	return data;
end

function Proto.getLifeSkillCareerChangeIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeLifeSkillCareerChange(msg,data)
	Proto.writeDWORD(msg,data.id); -- 等级
	Proto.writeDWORD(msg,data.elemID); -- 消费元素ID
end

