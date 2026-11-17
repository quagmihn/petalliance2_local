-- Net.Proto.Proto_Bugle_Types

function Proto.parseBugleConfig(entry)
	local data={};
	data.id=Proto.parseBYTE(entry); -- 配置编号
	data.spaceBugle=Proto.parseDWORD(entry); -- 宇宙喇叭道具类型
	data.bigBugle=Proto.parseDWORD(entry); -- 大喇叭道具类型
	data.smallBugle=Proto.parseDWORD(entry); -- 小喇叭道具类型
	data.spaceBugleLasts=Proto.parseDWORD(entry); -- 宇宙喇叭持续时间(秒)
	data.bigBugleLasts=Proto.parseDWORD(entry); -- 大喇叭持续时间(秒)
	data.smallBugleLasts=Proto.parseDWORD(entry); -- 小喇叭持续时间(秒)
	data.spaceBuglePrice=Proto.parseDWORD(entry); -- 宇宙喇叭价格
	data.bigBuglePrice=Proto.parseDWORD(entry); -- 大喇叭价格
	data.smallBuglePrice=Proto.parseDWORD(entry); -- 小喇叭价格
	return data;
end

function Proto.getBugleConfigIDLen()
	return Proto.getBYTELen();
end

function Proto.writeBugleConfig(msg,data)
	Proto.writeBYTE(msg,data.id); -- 配置编号
	Proto.writeDWORD(msg,data.spaceBugle); -- 宇宙喇叭道具类型
	Proto.writeDWORD(msg,data.bigBugle); -- 大喇叭道具类型
	Proto.writeDWORD(msg,data.smallBugle); -- 小喇叭道具类型
	Proto.writeDWORD(msg,data.spaceBugleLasts); -- 宇宙喇叭持续时间(秒)
	Proto.writeDWORD(msg,data.bigBugleLasts); -- 大喇叭持续时间(秒)
	Proto.writeDWORD(msg,data.smallBugleLasts); -- 小喇叭持续时间(秒)
	Proto.writeDWORD(msg,data.spaceBuglePrice); -- 宇宙喇叭价格
	Proto.writeDWORD(msg,data.bigBuglePrice); -- 大喇叭价格
	Proto.writeDWORD(msg,data.smallBuglePrice); -- 小喇叭价格
end

