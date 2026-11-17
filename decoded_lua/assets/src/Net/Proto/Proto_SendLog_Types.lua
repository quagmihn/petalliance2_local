-- Net.Proto.Proto_SendLog_Types

Proto.OP_TYPE_NULL			= 0								-- [交易所操作类型]无操作
Proto.OP_TYPE_SHANGJIA		= Proto.OP_TYPE_NULL + 1		-- [交易所操作类型]上架
Proto.OP_TYPE_XIAJIA		= Proto.OP_TYPE_SHANGJIA + 1	-- [交易所操作类型]下架
Proto.OP_TYPE_GOUMAI		= Proto.OP_TYPE_XIAJIA + 1		-- [交易所操作类型]购买
Proto.OP_TYPE_CHUSHOU		= Proto.OP_TYPE_GOUMAI + 1		-- [交易所操作类型]出售
Proto.OP_TYPE_SHANGHUI		= Proto.OP_TYPE_CHUSHOU + 1		-- [交易所操作类型]商会
Proto.OP_TYPE_SHANGCHENG	= Proto.OP_TYPE_SHANGHUI + 1	-- [交易所操作类型]商城
Proto.CHANGE_TYPE_NULL		= 0									-- [交易所物品类型]无
Proto.CHANGE_TYPE_COST		= Proto.CHANGE_TYPE_NULL + 1		-- [交易所物品类型]消耗品
Proto.CHANGE_TYPE_MATERIAL	= Proto.CHANGE_TYPE_COST + 1		-- [交易所物品类型]材料
Proto.CHANGE_TYPE_LIFE		= Proto.CHANGE_TYPE_MATERIAL + 1	-- [交易所物品类型]生活道具
Proto.CHANGE_TYPE_PIECE		= Proto.CHANGE_TYPE_LIFE + 1		-- [交易所物品类型]碎片
Proto.CHANGE_TYPE_PET		= Proto.CHANGE_TYPE_PIECE + 1		-- [交易所物品类型]宠物

function Proto.parseSendLogExchangeInfo(entry)
	local data={};
	data.Exchange_id=Proto.parseDWORD(entry); -- 交易唯一ID
	data.op=Proto.parseWORD(entry); -- 操作类型
	data.change_type=Proto.parseWORD(entry); -- 交易的物品类型
	data.type_id=Proto.parseDWORD(entry); -- 交易物品类型编号
	data.item_id=Proto.parseDWORD(entry); -- 交易物品唯一编号
	data.num=Proto.parseDWORD(entry); -- 交易物品数量
	data.shangjia_end_time=Proto.parseQWORD(entry); -- 上架道具到期时间
	data.shangjia_money=Proto.parseDWORD(entry); -- 上架银币金额
	data.chengjiao_money=Proto.parseDWORD(entry); -- 成交银币金额
	data.cost_zuanshi=Proto.parseDWORD(entry); -- 商城购买消耗钻石
	return data;
end

function Proto.writeSendLogExchangeInfo(msg,data)
	Proto.writeDWORD(msg,data.Exchange_id); -- 交易唯一ID
	Proto.writeWORD(msg,data.op); -- 操作类型
	Proto.writeWORD(msg,data.change_type); -- 交易的物品类型
	Proto.writeDWORD(msg,data.type_id); -- 交易物品类型编号
	Proto.writeDWORD(msg,data.item_id); -- 交易物品唯一编号
	Proto.writeDWORD(msg,data.num); -- 交易物品数量
	Proto.writeQWORD(msg,data.shangjia_end_time); -- 上架道具到期时间
	Proto.writeDWORD(msg,data.shangjia_money); -- 上架银币金额
	Proto.writeDWORD(msg,data.chengjiao_money); -- 成交银币金额
	Proto.writeDWORD(msg,data.cost_zuanshi); -- 商城购买消耗钻石
end

