-- Net.Proto.Proto_NewShop_Types

Proto.SHOP_NONE			= 0							-- [商店类型]无
Proto.SHOP_ARENA		= Proto.SHOP_NONE + 1		-- [商店类型]竞技场商店
Proto.SHOP_COMMON		= Proto.SHOP_ARENA + 1		-- [商店类型]普通商店
Proto.SHOP_LOSTTOWER	= Proto.SHOP_COMMON + 1		-- [商店类型]迷失之塔商店
Proto.SHOP_PVPARENA		= Proto.SHOP_LOSTTOWER + 1	-- [商店类型]大联盟商店
Proto.SHOP_WISH			= Proto.SHOP_PVPARENA + 1	-- [商店类型]心愿商店
Proto.SHOP_DREAM		= Proto.SHOP_WISH + 1		-- [商店类型]梦想商店

function Proto.parseShopDetail(entry)
	local data={};
	data.itemID=Proto.parseDWORD(entry); -- 道具ID
	data.price=Proto.parseDWORD(entry); -- 价格
	data.number=Proto.parseDWORD(entry); -- 购买数量
	data.count=Proto.parseDWORD(entry); -- 购买次数
	data.weigth=Proto.parseDWORD(entry); -- 权重
	return data;
end

function Proto.writeShopDetail(msg,data)
	Proto.writeDWORD(msg,data.itemID); -- 道具ID
	Proto.writeDWORD(msg,data.price); -- 价格
	Proto.writeDWORD(msg,data.number); -- 购买数量
	Proto.writeDWORD(msg,data.count); -- 购买次数
	Proto.writeDWORD(msg,data.weigth); -- 权重
end

function Proto.parseShopInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.shopPool=Proto.parseVector(entry,Proto.parseDWORD); -- 商品池列表
	return data;
end

function Proto.getShopInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeShopInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeVector(msg,data.shopPool,Proto.writeDWORD); -- 商品池列表
end

function Proto.parseShopList(entry)
	local data={};
	data.itemID=Proto.parseDWORD(entry); -- 商品ID
	data.count=Proto.parseDWORD(entry); -- 商品数量
	data.num=Proto.parseDWORD(entry); -- 购买次数
	data.price=Proto.parseDWORD(entry); -- 价格
	data.conditionNum=Proto.parseDWORD(entry); -- 开启条件
	return data;
end

function Proto.writeShopList(msg,data)
	Proto.writeDWORD(msg,data.itemID); -- 商品ID
	Proto.writeDWORD(msg,data.count); -- 商品数量
	Proto.writeDWORD(msg,data.num); -- 购买次数
	Proto.writeDWORD(msg,data.price); -- 价格
	Proto.writeDWORD(msg,data.conditionNum); -- 开启条件
end

function Proto.parseReflashDetail(entry)
	local data={};
	data.count=Proto.parseDWORD(entry); -- 刷新次数
	data.consume=Proto.parseDWORD(entry); -- 消耗
	return data;
end

function Proto.writeReflashDetail(msg,data)
	Proto.writeDWORD(msg,data.count); -- 刷新次数
	Proto.writeDWORD(msg,data.consume); -- 消耗
end

function Proto.parseShopReflashInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 类型id
	data.reflashDetail=Proto.parseVector(entry,Proto.parseReflashDetail); -- 刷新详细信息列表
	return data;
end

function Proto.getShopReflashInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeShopReflashInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 类型id
	Proto.writeVector(msg,data.reflashDetail,Proto.writeReflashDetail); -- 刷新详细信息列表
end

function Proto.parseShop(entry)
	local data={};
	data.shopList=Proto.parseVector(entry,Proto.parseShopList); -- 商品列表
	data.resetTime=Proto.parseDWORD(entry); -- 重置时间
	data.reflashCount=Proto.parseDWORD(entry); -- 手动刷新次数
	data.systemReflashTime=Proto.parseDWORD(entry); -- 系统刷新时间
	return data;
end

function Proto.writeShop(msg,data)
	Proto.writeVector(msg,data.shopList,Proto.writeShopList); -- 商品列表
	Proto.writeDWORD(msg,data.resetTime); -- 重置时间
	Proto.writeDWORD(msg,data.reflashCount); -- 手动刷新次数
	Proto.writeDWORD(msg,data.systemReflashTime); -- 系统刷新时间
end

function Proto.parseShopPoolInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.shopDetail=Proto.parseVector(entry,Proto.parseShopDetail); -- 商店详细信息列表
	data.conditionNum=Proto.parseDWORD(entry); -- 开启条件
	return data;
end

function Proto.getShopPoolInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeShopPoolInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeVector(msg,data.shopDetail,Proto.writeShopDetail); -- 商店详细信息列表
	Proto.writeDWORD(msg,data.conditionNum); -- 开启条件
end

function Proto.parseRedHeartGoods(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.num=Proto.parseDWORD(entry); -- 
	data.price=Proto.parseDWORD(entry); -- 
	return data;
end

function Proto.getRedHeartGoodsIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeRedHeartGoods(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeDWORD(msg,data.num); -- 
	Proto.writeDWORD(msg,data.price); -- 
end

function Proto.parseActivityShopData(entry)
	local data={};
	data.itemID=Proto.parseDWORD(entry); -- 商品ID
	data.buyCount=Proto.parseDWORD(entry); -- 购买次数
	return data;
end

function Proto.writeActivityShopData(msg,data)
	Proto.writeDWORD(msg,data.itemID); -- 商品ID
	Proto.writeDWORD(msg,data.buyCount); -- 购买次数
end

function Proto.parseActivityShopInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.itemID=Proto.parseDWORD(entry); -- 奖励元素ID
	data.count=Proto.parseDWORD(entry); -- 购买个数
	data.buyCount=Proto.parseDWORD(entry); -- 购买次数
	data.price=Proto.parseDWORD(entry); -- 价格
	return data;
end

function Proto.getActivityShopInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeActivityShopInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeDWORD(msg,data.itemID); -- 奖励元素ID
	Proto.writeDWORD(msg,data.count); -- 购买个数
	Proto.writeDWORD(msg,data.buyCount); -- 购买次数
	Proto.writeDWORD(msg,data.price); -- 价格
end

