-- Net.Proto.Proto_Shop_Types

Proto.SM_CYCLE			= 0							-- [进货方式]按周期
Proto.SM_NUM			= Proto.SM_CYCLE + 1		-- [进货方式]按数量
Proto.SM_CYCLEANDNUM	= Proto.SM_NUM + 1			-- [进货方式]周期数量交集
Proto.SM_CYCLEORNUM		= Proto.SM_CYCLEANDNUM + 1	-- [进货方式]周期数量并集
Proto.SM_NONE			= Proto.SM_CYCLEORNUM + 1	-- [进货方式]不进货
Proto.PT_CHARACTER		= 0							-- [AI模式]玩家背包
Proto.PT_CONFRATERNITY	= Proto.PT_CHARACTER + 1	-- [AI模式]公会背包
Proto.SGT_COMMODITY	= 0							-- [赠送礼物类型]商场道具
Proto.SGT_GACHA		= Proto.SGT_COMMODITY + 1	-- [赠送礼物类型]扭蛋

function Proto.parseCollectInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 道具类型ID
	data.money_type=Proto.parseBYTE(entry); -- 货币类型
	data.price=Proto.parseDWORD(entry); -- 收购价格
	data.num=Proto.parseWORD(entry); -- 收购数量
	data.mode=Proto.parseBYTE(entry); -- 变化触发方式
	data.cycle=Proto.parseDWORD(entry); -- 变化周期
	data.trigger_num=Proto.parseWORD(entry); -- 变化触发数量
	data.change_num=Proto.parseWORD(entry); -- 一次增加数量
	return data;
end

function Proto.getCollectInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeCollectInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 道具类型ID
	Proto.writeBYTE(msg,data.money_type); -- 货币类型
	Proto.writeDWORD(msg,data.price); -- 收购价格
	Proto.writeWORD(msg,data.num); -- 收购数量
	Proto.writeBYTE(msg,data.mode); -- 变化触发方式
	Proto.writeDWORD(msg,data.cycle); -- 变化周期
	Proto.writeWORD(msg,data.trigger_num); -- 变化触发数量
	Proto.writeWORD(msg,data.change_num); -- 一次增加数量
end

function Proto.parseCollectNpcInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- NpcID
	data.collects=Proto.parseVarArray(entry,Proto.parseDWORD,Proto.parseWORD); -- 收购物品道具类型ID列表
	return data;
end

function Proto.getCollectNpcInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeCollectNpcInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- NpcID
	Proto.writeVarArray(msg,data.collects,Proto.writeDWORD,Proto.writeWORD); -- 收购物品道具类型ID列表
end

function Proto.parseCommodityInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 商品ID
	data.name=Proto.parseString(entry); -- 商品名称
	data.itemGenerateID=Proto.parseDWORD(entry); -- 道具生成规则ID
	data.days=Proto.parseshort(entry); -- 使用天数
	data.moneyType=Proto.parseMoneyType(entry); -- 货币类型
	data.price=Proto.parseDWORD(entry); -- 价格
	data.max_stock=Proto.parseWORD(entry); -- 最大库存
	data.stock_mode=Proto.parseBYTE(entry); -- 进货触发方式
	data.stock_cycle=Proto.parseDWORD(entry); -- 进货周期
	data.trigger_num=Proto.parseWORD(entry); -- 进货触发数量
	data.stock_num=Proto.parseWORD(entry); -- 一次进货数量
	data.is_bound=Proto.parseBYTE(entry); -- 是否绑定
	data.honorPoint=Proto.parseDWORD(entry); -- 荣誉点
	data.vipLevel=Proto.parseDWORD(entry); -- vip等级
	data.maxNum=Proto.parseDWORD(entry); -- 最大购买次数
	return data;
end

function Proto.getCommodityInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeCommodityInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 商品ID
	Proto.writeString(msg,data.name); -- 商品名称
	Proto.writeDWORD(msg,data.itemGenerateID); -- 道具生成规则ID
	Proto.writeshort(msg,data.days); -- 使用天数
	Proto.writeMoneyType(msg,data.moneyType); -- 货币类型
	Proto.writeDWORD(msg,data.price); -- 价格
	Proto.writeWORD(msg,data.max_stock); -- 最大库存
	Proto.writeBYTE(msg,data.stock_mode); -- 进货触发方式
	Proto.writeDWORD(msg,data.stock_cycle); -- 进货周期
	Proto.writeWORD(msg,data.trigger_num); -- 进货触发数量
	Proto.writeWORD(msg,data.stock_num); -- 一次进货数量
	Proto.writeBYTE(msg,data.is_bound); -- 是否绑定
	Proto.writeDWORD(msg,data.honorPoint); -- 荣誉点
	Proto.writeDWORD(msg,data.vipLevel); -- vip等级
	Proto.writeDWORD(msg,data.maxNum); -- 最大购买次数
end

function Proto.parsePocketCommodityInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 商品ID
	data.name=Proto.parseItemName(entry); -- 商品名称
	data.itemGenerateID=Proto.parseDWORD(entry); -- 道具生成规则ID
	data.days=Proto.parseshort(entry); -- 使用天数
	data.moneyType=Proto.parseMoneyType(entry); -- 货币类型
	data.price=Proto.parseDWORD(entry); -- 价格
	data.is_bound=Proto.parseBYTE(entry); -- 是否绑定
	return data;
end

function Proto.getPocketCommodityInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writePocketCommodityInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 商品ID
	Proto.writeItemName(msg,data.name); -- 商品名称
	Proto.writeDWORD(msg,data.itemGenerateID); -- 道具生成规则ID
	Proto.writeshort(msg,data.days); -- 使用天数
	Proto.writeMoneyType(msg,data.moneyType); -- 货币类型
	Proto.writeDWORD(msg,data.price); -- 价格
	Proto.writeBYTE(msg,data.is_bound); -- 是否绑定
end

function Proto.parseBoundInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 经营范围ID
	data.name=Proto.parseItemName(entry); -- 经营范围名称
	data.mobility=Proto.parseBYTE(entry); -- 固定标志(0:固定范围;1:不固定)
	data.commodityids=Proto.parseVarArray(entry,Proto.parseDWORD,Proto.parseWORD); -- 商品ID列表
	return data;
end

function Proto.getBoundInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeBoundInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 经营范围ID
	Proto.writeItemName(msg,data.name); -- 经营范围名称
	Proto.writeBYTE(msg,data.mobility); -- 固定标志(0:固定范围;1:不固定)
	Proto.writeVarArray(msg,data.commodityids,Proto.writeDWORD,Proto.writeWORD); -- 商品ID列表
end

function Proto.parsePocketBoundInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 经营范围ID
	data.name=Proto.parseItemName(entry); -- 经营范围名称
	data.mobility=Proto.parseBYTE(entry); -- 固定标志(0:固定范围;1:不固定)
	data.pocketCommodityids=Proto.parseVarArray(entry,Proto.parseDWORD,Proto.parseWORD); -- 随身商品ID列表
	return data;
end

function Proto.getPocketBoundInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writePocketBoundInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 经营范围ID
	Proto.writeItemName(msg,data.name); -- 经营范围名称
	Proto.writeBYTE(msg,data.mobility); -- 固定标志(0:固定范围;1:不固定)
	Proto.writeVarArray(msg,data.pocketCommodityids,Proto.writeDWORD,Proto.writeWORD); -- 随身商品ID列表
end

function Proto.parseShopNpcInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 仓库信息ID
	data.max_count=Proto.parseWORD(entry); -- 最大商品数
	data.boundids=Proto.parseVarArray(entry,Proto.parseDWORD,Proto.parseWORD); -- 经营范围ID列表
	return data;
end

function Proto.getShopNpcInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeShopNpcInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 仓库信息ID
	Proto.writeWORD(msg,data.max_count); -- 最大商品数
	Proto.writeVarArray(msg,data.boundids,Proto.writeDWORD,Proto.writeWORD); -- 经营范围ID列表
end

function Proto.parseShopCommodityInfo(entry)
	local data={};
	data.info=Proto.parseCommodityInfo(entry); -- 商品信息
	data.price=Proto.parseDWORD(entry); -- 价格
	data.stocks=Proto.parseWORD(entry); -- 当前库存
	return data;
end

function Proto.writeShopCommodityInfo(msg,data)
	Proto.writeCommodityInfo(msg,data.info); -- 商品信息
	Proto.writeDWORD(msg,data.price); -- 价格
	Proto.writeWORD(msg,data.stocks); -- 当前库存
end

function Proto.parseShopCollectInfo(entry)
	local data={};
	data.info=Proto.parseCollectInfo(entry); -- 收购物品信息
	data.id=Proto.parseDWORD(entry); -- 收购物品ID
	data.price=Proto.parseDWORD(entry); -- 价格
	data.num=Proto.parseWORD(entry); -- 收购数量
	return data;
end

function Proto.getShopCollectInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeShopCollectInfo(msg,data)
	Proto.writeCollectInfo(msg,data.info); -- 收购物品信息
	Proto.writeDWORD(msg,data.id); -- 收购物品ID
	Proto.writeDWORD(msg,data.price); -- 价格
	Proto.writeWORD(msg,data.num); -- 收购数量
end

function Proto.parseLuxuryShopInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 编号
	data.npcID=Proto.parseDWORD(entry); -- NpcID
	data.nickName=Proto.parseNickName(entry); -- 庄园主人名
	data.initLocation=Proto.parsePOS2D(entry); -- 初始位置
	data.initDirect=Proto.parseDirectType(entry); -- 初始方向
	return data;
end

function Proto.getLuxuryShopInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeLuxuryShopInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 编号
	Proto.writeDWORD(msg,data.npcID); -- NpcID
	Proto.writeNickName(msg,data.nickName); -- 庄园主人名
	Proto.writePOS2D(msg,data.initLocation); -- 初始位置
	Proto.writeDirectType(msg,data.initDirect); -- 初始方向
end

function Proto.parseConfraternityCommodityInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 商品ID
	data.itemGenerateID=Proto.parseDWORD(entry); -- 道具生成规则编号
	data.prize=Proto.parseDWORD(entry); -- 价格
	data.level=Proto.parseBYTE(entry); -- 开放等级
	data.is_bound=Proto.parseBYTE(entry); -- 是否绑定
	return data;
end

function Proto.getConfraternityCommodityInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeConfraternityCommodityInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 商品ID
	Proto.writeDWORD(msg,data.itemGenerateID); -- 道具生成规则编号
	Proto.writeDWORD(msg,data.prize); -- 价格
	Proto.writeBYTE(msg,data.level); -- 开放等级
	Proto.writeBYTE(msg,data.is_bound); -- 是否绑定
end

function Proto.parseContributeCommodityInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 物品类型
	data.isBound=Proto.parseBYTE(entry); -- 是否绑定换取
	data.contribute=Proto.parseDWORD(entry); -- 所需贡献点
	return data;
end

function Proto.getContributeCommodityInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeContributeCommodityInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 物品类型
	Proto.writeBYTE(msg,data.isBound); -- 是否绑定换取
	Proto.writeDWORD(msg,data.contribute); -- 所需贡献点
end

function Proto.parseContributeCommodityDetail(entry)
	local data={};
	data.typeID=Proto.parseDWORD(entry); -- 物品类型
	data.isBound=Proto.parseBYTE(entry); -- 是否绑定换取
	data.contribute=Proto.parseDWORD(entry); -- 所需贡献点
	data.level=Proto.parseBYTE(entry); -- 所需公会等级
	return data;
end

function Proto.writeContributeCommodityDetail(msg,data)
	Proto.writeDWORD(msg,data.typeID); -- 物品类型
	Proto.writeBYTE(msg,data.isBound); -- 是否绑定换取
	Proto.writeDWORD(msg,data.contribute); -- 所需贡献点
	Proto.writeBYTE(msg,data.level); -- 所需公会等级
end

function Proto.parseContributeCommodity(entry)
	local data={};
	data.typeID=Proto.parseDWORD(entry); -- 物品类型
	data.isBound=Proto.parseBYTE(entry); -- 是否绑定换取
	data.contribute=Proto.parseDWORD(entry); -- 所需贡献点
	data.count=Proto.parseDWORD(entry); -- 物品数量
	data.pos=Proto.parseWORD(entry); -- 公会背包中的位置
	return data;
end

function Proto.writeContributeCommodity(msg,data)
	Proto.writeDWORD(msg,data.typeID); -- 物品类型
	Proto.writeBYTE(msg,data.isBound); -- 是否绑定换取
	Proto.writeDWORD(msg,data.contribute); -- 所需贡献点
	Proto.writeDWORD(msg,data.count); -- 物品数量
	Proto.writeWORD(msg,data.pos); -- 公会背包中的位置
end

function Proto.parseExchangeItemTradeInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 交换项id
	data.originalItem=Proto.parseDWORD(entry); -- 原始的道具
	data.needCount=Proto.parseDWORD(entry); -- 需要的数量
	data.generateID=Proto.parseDWORD(entry); -- 生成规则id
	data.count=Proto.parseWORD(entry); -- 数量
	data.isBind=Proto.parseBYTE(entry); -- 是否绑定
	data.isOpen=Proto.parseBYTE(entry); -- 是否销售
	return data;
end

function Proto.getExchangeItemTradeInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeExchangeItemTradeInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 交换项id
	Proto.writeDWORD(msg,data.originalItem); -- 原始的道具
	Proto.writeDWORD(msg,data.needCount); -- 需要的数量
	Proto.writeDWORD(msg,data.generateID); -- 生成规则id
	Proto.writeWORD(msg,data.count); -- 数量
	Proto.writeBYTE(msg,data.isBind); -- 是否绑定
	Proto.writeBYTE(msg,data.isOpen); -- 是否销售
end

function Proto.parseSendGiftItem_BODY__Commodity(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 商品id
	data.count=Proto.parseDWORD(entry); -- 数量
	return data;
end

function Proto.getSendGiftItem_BODY__CommodityIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeSendGiftItem_BODY__Commodity(msg,data)
	Proto.writeDWORD(msg,data.id); -- 商品id
	Proto.writeDWORD(msg,data.count); -- 数量
end

function Proto.parseSendGiftItem_BODY__Gacha(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 扭蛋机ID
	data.count=Proto.parseDWORD(entry); -- 数量
	return data;
end

function Proto.getSendGiftItem_BODY__GachaIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeSendGiftItem_BODY__Gacha(msg,data)
	Proto.writeDWORD(msg,data.id); -- 扭蛋机ID
	Proto.writeDWORD(msg,data.count); -- 数量
end

function Proto.parseSendGiftItem(entry)
	local data={};
	data.type=Proto.parseBYTE(entry); -- 数据类型
	data.body={}; -- 数据
	if (data.type==Proto.SGT_COMMODITY) then
		data.body.commodity=Proto.parseSendGiftItem_BODY__Commodity(entry); -- 商品
	end
	if (data.type==Proto.SGT_GACHA) then
		data.body.gacha=Proto.parseSendGiftItem_BODY__Gacha(entry); -- 扭蛋机
	end
	return data;
end

function Proto.writeSendGiftItem(msg,data)
	Proto.writeBYTE(msg,data.type); -- 数据类型
	if (data.type==Proto.SGT_COMMODITY) then
		Proto.writeSendGiftItem_BODY__Commodity(msg,data.body.commodity); -- 商品
	end
	if (data.type==Proto.SGT_GACHA) then
		Proto.writeSendGiftItem_BODY__Gacha(msg,data.body.gacha); -- 扭蛋机
	end
end

