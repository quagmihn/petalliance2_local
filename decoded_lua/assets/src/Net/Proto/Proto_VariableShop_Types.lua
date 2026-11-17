-- Net.Proto.Proto_VariableShop_Types

function Proto.parseVariableSellItemInfo_MONEY_BODY__CreditCard(entry)
	local data={};
	data.type=Proto.parseBYTE(entry); -- 信用卡类型
	if (data.type ==Proto.CCT_NATION) then
		data.sub_type=Proto.parseBYTE(entry); -- 信用卡子类型
	end
	return data;
end

function Proto.writeVariableSellItemInfo_MONEY_BODY__CreditCard(msg,data)
	Proto.writeBYTE(msg,data.type); -- 信用卡类型
	if (data.type ==Proto.CCT_NATION) then
		Proto.writeBYTE(msg,data.sub_type); -- 信用卡子类型
	end
end

function Proto.parseVariableSellItemInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.itemGenerateID=Proto.parseDWORD(entry); -- 道具生成规则ID
	data.price=Proto.parseDWORD(entry); -- 出售价格
	data.money_type=Proto.parseBYTE(entry); -- 货币类型
	data.sub_type={}; -- 货币子类型
	if (data.money_type ==Proto.MT_CREDITCARD  and  (data.money_type ==Proto.MT_CREDITCARD)) then
		data.sub_type.creditCard=Proto.parseVariableSellItemInfo_MONEY_BODY__CreditCard(entry); -- 信用卡
	end
	data.days=Proto.parseshort(entry); -- 使用天数
	data.min_price=Proto.parseDWORD(entry); -- 最低出售价格
	data.max_price=Proto.parseDWORD(entry); -- 最高出售价格
	data.level=Proto.parseBYTE(entry); -- 道具等级
	data.isBound=Proto.parseBYTE(entry); -- 是否绑定
	return data;
end

function Proto.getVariableSellItemInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeVariableSellItemInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeDWORD(msg,data.itemGenerateID); -- 道具生成规则ID
	Proto.writeDWORD(msg,data.price); -- 出售价格
	Proto.writeBYTE(msg,data.money_type); -- 货币类型
	if (data.money_type ==Proto.MT_CREDITCARD  and  (data.money_type ==Proto.MT_CREDITCARD)) then
		Proto.writeVariableSellItemInfo_MONEY_BODY__CreditCard(msg,data.sub_type.creditCard); -- 信用卡
	end
	Proto.writeshort(msg,data.days); -- 使用天数
	Proto.writeDWORD(msg,data.min_price); -- 最低出售价格
	Proto.writeDWORD(msg,data.max_price); -- 最高出售价格
	Proto.writeBYTE(msg,data.level); -- 道具等级
	Proto.writeBYTE(msg,data.isBound); -- 是否绑定
end

function Proto.parseVariableBuyItemInfo_MONEY_BODY__CreditCard(entry)
	local data={};
	data.type=Proto.parseBYTE(entry); -- 信用卡类型
	if (data.type ==Proto.CCT_NATION) then
		data.sub_type=Proto.parseBYTE(entry); -- 信用卡子类型
	end
	return data;
end

function Proto.writeVariableBuyItemInfo_MONEY_BODY__CreditCard(msg,data)
	Proto.writeBYTE(msg,data.type); -- 信用卡类型
	if (data.type ==Proto.CCT_NATION) then
		Proto.writeBYTE(msg,data.sub_type); -- 信用卡子类型
	end
end

function Proto.parseVariableBuyItemInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.itemID=Proto.parseDWORD(entry); -- 道具ID
	data.price=Proto.parseDWORD(entry); -- 收购价格
	data.money_type=Proto.parseBYTE(entry); -- 货币类型
	data.sub_type={}; -- 货币子类型
	if (data.money_type ==Proto.MT_CREDITCARD  and  (data.money_type ==Proto.MT_CREDITCARD)) then
		data.sub_type.creditCard=Proto.parseVariableBuyItemInfo_MONEY_BODY__CreditCard(entry); -- 信用卡
	end
	data.min_price=Proto.parseDWORD(entry); -- 最低收购价格
	data.max_price=Proto.parseDWORD(entry); -- 最低收购价格
	data.level=Proto.parseBYTE(entry); -- 道具等级
	return data;
end

function Proto.getVariableBuyItemInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeVariableBuyItemInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeDWORD(msg,data.itemID); -- 道具ID
	Proto.writeDWORD(msg,data.price); -- 收购价格
	Proto.writeBYTE(msg,data.money_type); -- 货币类型
	if (data.money_type ==Proto.MT_CREDITCARD  and  (data.money_type ==Proto.MT_CREDITCARD)) then
		Proto.writeVariableBuyItemInfo_MONEY_BODY__CreditCard(msg,data.sub_type.creditCard); -- 信用卡
	end
	Proto.writeDWORD(msg,data.min_price); -- 最低收购价格
	Proto.writeDWORD(msg,data.max_price); -- 最低收购价格
	Proto.writeBYTE(msg,data.level); -- 道具等级
end

function Proto.parseVariableSellItemCount(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 出售物品信息ID
	data.count=Proto.parseWORD(entry); -- 数量
	return data;
end

function Proto.getVariableSellItemCountIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeVariableSellItemCount(msg,data)
	Proto.writeDWORD(msg,data.id); -- 出售物品信息ID
	Proto.writeWORD(msg,data.count); -- 数量
end

function Proto.parseVariableBuyItemCount(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 收购物品信息ID
	data.count=Proto.parseWORD(entry); -- 数量
	return data;
end

function Proto.getVariableBuyItemCountIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeVariableBuyItemCount(msg,data)
	Proto.writeDWORD(msg,data.id); -- 收购物品信息ID
	Proto.writeWORD(msg,data.count); -- 数量
end

function Proto.parseVariableSellNPCInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- id
	data.NPCID=Proto.parseDWORD(entry); -- NpcID
	data.startTime=Proto.parseDWORD(entry); -- 开始时间
	data.duration=Proto.parseDWORD(entry); -- 持续时间
	data.sells=Proto.parseVarArray(entry,Proto.parseVariableSellItemCount,Proto.parseWORD); -- 出售物品道具类型ID列表
	return data;
end

function Proto.getVariableSellNPCInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeVariableSellNPCInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- id
	Proto.writeDWORD(msg,data.NPCID); -- NpcID
	Proto.writeDWORD(msg,data.startTime); -- 开始时间
	Proto.writeDWORD(msg,data.duration); -- 持续时间
	Proto.writeVarArray(msg,data.sells,Proto.writeVariableSellItemCount,Proto.writeWORD); -- 出售物品道具类型ID列表
end

function Proto.parseVariableBuyNPCInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- id
	data.NPCID=Proto.parseDWORD(entry); -- NpcID
	data.startTime=Proto.parseDWORD(entry); -- 开始时间
	data.duration=Proto.parseDWORD(entry); -- 持续时间
	data.sells=Proto.parseVarArray(entry,Proto.parseVariableBuyItemCount,Proto.parseWORD); -- 收购物品道具类型ID列表
	return data;
end

function Proto.getVariableBuyNPCInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeVariableBuyNPCInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- id
	Proto.writeDWORD(msg,data.NPCID); -- NpcID
	Proto.writeDWORD(msg,data.startTime); -- 开始时间
	Proto.writeDWORD(msg,data.duration); -- 持续时间
	Proto.writeVarArray(msg,data.sells,Proto.writeVariableBuyItemCount,Proto.writeWORD); -- 收购物品道具类型ID列表
end

function Proto.parseVariableSellItemDetail(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 出售物品信息ID
	data.count=Proto.parseWORD(entry); -- 数量
	data.price=Proto.parseDWORD(entry); -- 出售价格
	return data;
end

function Proto.getVariableSellItemDetailIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeVariableSellItemDetail(msg,data)
	Proto.writeDWORD(msg,data.id); -- 出售物品信息ID
	Proto.writeWORD(msg,data.count); -- 数量
	Proto.writeDWORD(msg,data.price); -- 出售价格
end

function Proto.parseVariableBuyItemDetail(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 收购物品信息ID
	data.count=Proto.parseWORD(entry); -- 数量
	data.price=Proto.parseDWORD(entry); -- 收购价格
	return data;
end

function Proto.getVariableBuyItemDetailIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeVariableBuyItemDetail(msg,data)
	Proto.writeDWORD(msg,data.id); -- 收购物品信息ID
	Proto.writeWORD(msg,data.count); -- 数量
	Proto.writeDWORD(msg,data.price); -- 收购价格
end

function Proto.parseVariableSellItemPrice(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 出售物品信息ID
	data.price=Proto.parseDWORD(entry); -- 出售价格
	return data;
end

function Proto.getVariableSellItemPriceIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeVariableSellItemPrice(msg,data)
	Proto.writeDWORD(msg,data.id); -- 出售物品信息ID
	Proto.writeDWORD(msg,data.price); -- 出售价格
end

function Proto.parseVariableBuyItemPrice(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 收购物品信息ID
	data.price=Proto.parseDWORD(entry); -- 收购价格
	return data;
end

function Proto.getVariableBuyItemPriceIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeVariableBuyItemPrice(msg,data)
	Proto.writeDWORD(msg,data.id); -- 收购物品信息ID
	Proto.writeDWORD(msg,data.price); -- 收购价格
end

