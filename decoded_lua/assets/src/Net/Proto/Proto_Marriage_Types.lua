-- Net.Proto.Proto_Marriage_Types

Proto.MT_NORMAL	= 0						-- [结婚类型]普通
Proto.MT_LUXURY	= Proto.MT_NORMAL + 1	-- [结婚类型]豪华
Proto.DT_SINGLE	= 0						-- [离婚类型]单方面
Proto.DT_DOUBLE	= Proto.DT_SINGLE + 1	-- [离婚类型]双方面
Proto.CGAT_MACHINE	= 0							-- [夫妻庄园权限类型]机械
Proto.CGAT_DORM		= Proto.CGAT_MACHINE + 1	-- [夫妻庄园权限类型]宠物宿舍
Proto.CGAT_ROBOT	= Proto.CGAT_DORM + 1		-- [夫妻庄园权限类型]机器人
Proto.CGAT_PLANT	= Proto.CGAT_ROBOT + 1		-- [夫妻庄园权限类型]植物
Proto.CGA_MACHINEPRODUCE	= 0								-- [机械权限]机械加工
Proto.CGA_MACHINEMOVE		= Proto.CGA_MACHINEPRODUCE + 1	-- [机械权限]移动机械
Proto.CGA_MACHINEREMOVE		= Proto.CGA_MACHINEMOVE + 1		-- [机械权限]删除机械
Proto.CGA_MACHINEADD		= Proto.CGA_MACHINEREMOVE + 1	-- [机械权限]增加机械
Proto.CGA_DORMADDPET		= 0								-- [宠物宿舍权限]加入宠物
Proto.CGA_DORMREMOVEPET		= Proto.CGA_DORMADDPET + 1		-- [宠物宿舍权限]移出宠物
Proto.CGA_DORMADDFEED		= Proto.CGA_DORMREMOVEPET + 1	-- [宠物宿舍权限]添加饲料
Proto.CGA_DORMADJUSTFEED	= Proto.CGA_DORMADDFEED + 1		-- [宠物宿舍权限]添加饲料
Proto.CGA_ROBOTREMOVEPLANT	= 0									-- [庄园机器人权限]机器人移除植物
Proto.CGA_ROBOTIRRIGATE		= Proto.CGA_ROBOTREMOVEPLANT + 1	-- [庄园机器人权限]机器人灌溉植物
Proto.CGA_ROBOTINGATHER		= Proto.CGA_ROBOTIRRIGATE + 1		-- [庄园机器人权限]机器人收获植物
Proto.CGA_ROBOTBYPRODUCT	= Proto.CGA_ROBOTINGATHER + 1		-- [庄园机器人权限]机器人收获副产品
Proto.CGA_ROBOTATTACH		= Proto.CGA_ROBOTBYPRODUCT + 1		-- [庄园机器人权限]机器人获取状态
Proto.CGA_PLANTADD			= 0								-- [植物权限]植物种植
Proto.CGA_PLANTREMOVE		= Proto.CGA_PLANTADD + 1		-- [植物权限]移除植物
Proto.CGA_PLANTIRRIGATE		= Proto.CGA_PLANTREMOVE + 1		-- [植物权限]灌溉植物
Proto.CGA_PLANTINGATHER		= Proto.CGA_PLANTIRRIGATE + 1	-- [植物权限]收获植物
Proto.CGA_PLANTBYPRODUCT	= Proto.CGA_PLANTINGATHER + 1	-- [植物权限]收获副产品

function Proto.parseMarriageConfigInfo(entry)
	local data={};
	data.id=Proto.parseBYTE(entry); -- 婚礼类型
	data.maleMarrigePresent=Proto.parseVector(entry,Proto.parseItemGenerateConfig); -- 男方结婚礼物
	data.femaleMarrigePresent=Proto.parseVector(entry,Proto.parseItemGenerateConfig); -- 女方结婚礼物
	data.moneyCash=Proto.parseMoneyType(entry); -- 货币类型
	data.marrigeCost=Proto.parseDWORD(entry); -- 结婚费用
	data.weddingTime=Proto.parseDWORD(entry); -- 婚礼时间
	return data;
end

function Proto.getMarriageConfigInfoIDLen()
	return Proto.getBYTELen();
end

function Proto.writeMarriageConfigInfo(msg,data)
	Proto.writeBYTE(msg,data.id); -- 婚礼类型
	Proto.writeVector(msg,data.maleMarrigePresent,Proto.writeItemGenerateConfig); -- 男方结婚礼物
	Proto.writeVector(msg,data.femaleMarrigePresent,Proto.writeItemGenerateConfig); -- 女方结婚礼物
	Proto.writeMoneyType(msg,data.moneyCash); -- 货币类型
	Proto.writeDWORD(msg,data.marrigeCost); -- 结婚费用
	Proto.writeDWORD(msg,data.weddingTime); -- 婚礼时间
end

function Proto.parseDivorceConfigInfo(entry)
	local data={};
	data.id=Proto.parseBYTE(entry); -- 离婚类型
	data.maleDestroyItem=Proto.parseVector(entry,Proto.parseItemConfig); -- 男方销毁道具
	data.femaleDestroyItem=Proto.parseVector(entry,Proto.parseItemConfig); -- 女方销毁道具
	data.divorceCost=Proto.parseDWORD(entry); -- 离婚费用
	return data;
end

function Proto.getDivorceConfigInfoIDLen()
	return Proto.getBYTELen();
end

function Proto.writeDivorceConfigInfo(msg,data)
	Proto.writeBYTE(msg,data.id); -- 离婚类型
	Proto.writeVector(msg,data.maleDestroyItem,Proto.writeItemConfig); -- 男方销毁道具
	Proto.writeVector(msg,data.femaleDestroyItem,Proto.writeItemConfig); -- 女方销毁道具
	Proto.writeDWORD(msg,data.divorceCost); -- 离婚费用
end

function Proto.parseWeddingPresentInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 道具类型
	data.presents=Proto.parseVector(entry,Proto.parseItemGenerateConfig); -- 礼品
	return data;
end

function Proto.getWeddingPresentInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeWeddingPresentInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 道具类型
	Proto.writeVector(msg,data.presents,Proto.writeItemGenerateConfig); -- 礼品
end

function Proto.parseWeddingInfo(entry)
	local data={};
	data.type=Proto.parseBYTE(entry); -- 婚礼类型
	data.mapID=Proto.parseMapID(entry); -- 地图ID
	data.male=Proto.parseRoleHandle(entry); -- 男方
	data.female=Proto.parseRoleHandle(entry); -- 女方
	data.maleID=Proto.parseDWORD(entry); -- 男方ID
	data.femaleID=Proto.parseDWORD(entry); -- 女方ID
	data.weddingBeginTime=Proto.parseTIME_SEC(entry); -- 婚礼开始时间
	data.weddingTime=Proto.parseDWORD(entry); -- 婚礼持续时间
	return data;
end

function Proto.writeWeddingInfo(msg,data)
	Proto.writeBYTE(msg,data.type); -- 婚礼类型
	Proto.writeMapID(msg,data.mapID); -- 地图ID
	Proto.writeRoleHandle(msg,data.male); -- 男方
	Proto.writeRoleHandle(msg,data.female); -- 女方
	Proto.writeDWORD(msg,data.maleID); -- 男方ID
	Proto.writeDWORD(msg,data.femaleID); -- 女方ID
	Proto.writeTIME_SEC(msg,data.weddingBeginTime); -- 婚礼开始时间
	Proto.writeDWORD(msg,data.weddingTime); -- 婚礼持续时间
end

function Proto.parseUseAccess(entry)
	local data={};
	data.action=Proto.parseBYTE(entry); -- 相关操作
	data.open=Proto.parseBYTE(entry); -- 是否开启
	return data;
end

function Proto.writeUseAccess(msg,data)
	Proto.writeBYTE(msg,data.action); -- 相关操作
	Proto.writeBYTE(msg,data.open); -- 是否开启
end

function Proto.parseCoupleGardenUseInfo(entry)
	local data={};
	data.id=Proto.parseBYTE(entry); -- 设备类型
	data.access=Proto.parseVector(entry,Proto.parseUseAccess); -- 相关操作
	return data;
end

function Proto.getCoupleGardenUseInfoIDLen()
	return Proto.getBYTELen();
end

function Proto.writeCoupleGardenUseInfo(msg,data)
	Proto.writeBYTE(msg,data.id); -- 设备类型
	Proto.writeVector(msg,data.access,Proto.writeUseAccess); -- 相关操作
end

