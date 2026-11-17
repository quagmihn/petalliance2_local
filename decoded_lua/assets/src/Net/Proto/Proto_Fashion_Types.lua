-- Net.Proto.Proto_Fashion_Types

Proto.FT_HEAD		= 0						-- [时装装备部位]头部
Proto.FT_CLOTH		= Proto.FT_HEAD + 1		-- [时装装备部位]上身
Proto.FT_TROUSERS	= Proto.FT_CLOTH + 1	-- [时装装备部位]下身
Proto.FT_BACK		= Proto.FT_TROUSERS + 1	-- [时装装备部位]背部
Proto.FT_WEAPON		= Proto.FT_BACK + 1		-- [时装装备部位]武器
Proto.FT_EYE		= Proto.FT_WEAPON + 1	-- [时装装备部位]眼睛
Proto.FT_COUNT		= Proto.FT_EYE + 1		-- [时装装备部位]计数
Proto.FS_MALE	= 0						-- [时装性别]男
Proto.FS_FEMALE	= Proto.FS_MALE + 1		-- [时装性别]女
Proto.FS_BOTH	= Proto.FS_FEMALE + 1	-- [时装性别]通用

function Proto.parseFashionItemInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 道具类型
	data.sex=Proto.parseBYTE(entry); -- 时装性别
	data.name=Proto.parseString(entry); -- 时装名称
	data.filePath=Proto.parseString(entry); -- 时装文件路径
	data.order=Proto.parseDWORD(entry); -- 排序
	data.isHide=Proto.parseBYTE(entry); -- 是否隐藏
	data.petAttributeType=Proto.parseDWORD(entry); -- 宠物增加属性类型
	data.petAttributeValue=Proto.parseDWORD(entry); -- 宠物增加属性值
	data.skillID=Proto.parseDWORD(entry); -- 技能ID
	data.suitEffect=Proto.parseDWORD(entry); -- 套装
	return data;
end

function Proto.getFashionItemInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeFashionItemInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 道具类型
	Proto.writeBYTE(msg,data.sex); -- 时装性别
	Proto.writeString(msg,data.name); -- 时装名称
	Proto.writeString(msg,data.filePath); -- 时装文件路径
	Proto.writeDWORD(msg,data.order); -- 排序
	Proto.writeBYTE(msg,data.isHide); -- 是否隐藏
	Proto.writeDWORD(msg,data.petAttributeType); -- 宠物增加属性类型
	Proto.writeDWORD(msg,data.petAttributeValue); -- 宠物增加属性值
	Proto.writeDWORD(msg,data.skillID); -- 技能ID
	Proto.writeDWORD(msg,data.suitEffect); -- 套装
end

function Proto.parseFashionSuitEffectInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 
	data.name=Proto.parseString(entry); -- 
	data.summary=Proto.parseString(entry); -- 
	data.des=Proto.parseString(entry); -- 
	data.oneEffect=Proto.parseDWORD(entry); -- 
	data.twoEffect=Proto.parseDWORD(entry); -- 
	data.threeEffect=Proto.parseDWORD(entry); -- 
	data.effectValues=Proto.parseVector(entry,Proto.parseDWORD); -- 
	return data;
end

function Proto.getFashionSuitEffectInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeFashionSuitEffectInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 
	Proto.writeString(msg,data.name); -- 
	Proto.writeString(msg,data.summary); -- 
	Proto.writeString(msg,data.des); -- 
	Proto.writeDWORD(msg,data.oneEffect); -- 
	Proto.writeDWORD(msg,data.twoEffect); -- 
	Proto.writeDWORD(msg,data.threeEffect); -- 
	Proto.writeVector(msg,data.effectValues,Proto.writeDWORD); -- 
end

