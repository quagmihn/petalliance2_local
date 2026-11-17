-- Net.Proto.Proto_Advertisement_Types

function Proto.parseAdvertisementInfo(entry)
	local data={};
	data.garden_id=Proto.parseDWORD(entry); -- 所在庄园ID
	data.location=Proto.parseWORD(entry); -- 广告位置
	data.ad_garden_id=Proto.parseDWORD(entry); -- 广告庄园ID
	data.ad_garden_name=Proto.parseGardenName(entry); -- 广告庄园名
	data.ad_master_name=Proto.parseNickName(entry); -- 广告主名
	data.main_work=Proto.parseBYTE(entry); -- 主营业务
	data.del_time=Proto.parseTIME_SEC(entry); -- 过期时间
	return data;
end

function Proto.writeAdvertisementInfo(msg,data)
	Proto.writeDWORD(msg,data.garden_id); -- 所在庄园ID
	Proto.writeWORD(msg,data.location); -- 广告位置
	Proto.writeDWORD(msg,data.ad_garden_id); -- 广告庄园ID
	Proto.writeGardenName(msg,data.ad_garden_name); -- 广告庄园名
	Proto.writeNickName(msg,data.ad_master_name); -- 广告主名
	Proto.writeBYTE(msg,data.main_work); -- 主营业务
	Proto.writeTIME_SEC(msg,data.del_time); -- 过期时间
end

