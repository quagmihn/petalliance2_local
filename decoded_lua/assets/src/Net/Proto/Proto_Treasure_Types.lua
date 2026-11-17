-- Net.Proto.Proto_Treasure_Types

Proto.TBT_BRONZE	= 0						-- [宝箱类型]青铜
Proto.TBT_SILVER	= Proto.TBT_BRONZE + 1	-- [宝箱类型]银质
Proto.TBT_GOLD		= Proto.TBT_SILVER + 1	-- [宝箱类型]金质
Proto.TBT_NUM		= Proto.TBT_GOLD + 1	-- [宝箱类型]数量

function Proto.parseTreasureBoxInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 宝箱ID
	data.name=Proto.parseString(entry); -- 名称
	data.imagePath=Proto.parseString(entry); -- 图片路径
	data.CD=Proto.parseDWORD(entry); -- 开启时间
	data.speedSeconds=Proto.parseVector(entry,Proto.parseWORD); -- 加速
	data.awards=Proto.parseVector(entry,Proto.parseDWORD); -- 随机奖励
	return data;
end

function Proto.getTreasureBoxInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeTreasureBoxInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 宝箱ID
	Proto.writeString(msg,data.name); -- 名称
	Proto.writeString(msg,data.imagePath); -- 图片路径
	Proto.writeDWORD(msg,data.CD); -- 开启时间
	Proto.writeVector(msg,data.speedSeconds,Proto.writeWORD); -- 加速
	Proto.writeVector(msg,data.awards,Proto.writeDWORD); -- 随机奖励
end

