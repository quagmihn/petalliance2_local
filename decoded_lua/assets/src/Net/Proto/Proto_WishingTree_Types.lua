-- Net.Proto.Proto_WishingTree_Types

function Proto.parseWishingTreeAward(entry)
	local data={};
	data.type=Proto.parseDWORD(entry); -- 奖励元素类型
	data.num=Proto.parseDWORD(entry); -- 奖励元素数量
	return data;
end

function Proto.writeWishingTreeAward(msg,data)
	Proto.writeDWORD(msg,data.type); -- 奖励元素类型
	Proto.writeDWORD(msg,data.num); -- 奖励元素数量
end

function Proto.parseWishingTreeLevelInfo(entry)
	local data={};
	data.treeModel=Proto.parsestring(entry); -- 树表现
	data.wishCount=Proto.parseBYTE(entry); -- 许愿次数
	data.ripeAward=Proto.parseVector(entry,Proto.parseWishingTreeAward); -- 成熟奖励
	return data;
end

function Proto.writeWishingTreeLevelInfo(msg,data)
	Proto.writestring(msg,data.treeModel); -- 树表现
	Proto.writeBYTE(msg,data.wishCount); -- 许愿次数
	Proto.writeVector(msg,data.ripeAward,Proto.writeWishingTreeAward); -- 成熟奖励
end

function Proto.parseWishingTreeInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 序号
	data.name=Proto.parsestring(entry); -- 名称
	data.ripeTime=Proto.parseDWORD(entry); -- 成熟时间（秒）
	data.starLevel=Proto.parseWORD(entry); -- 星级
	data.wishAward=Proto.parseVector(entry,Proto.parseDWORD); -- 祈愿奖励
	data.levelInfos=Proto.parseVector(entry,Proto.parseWishingTreeLevelInfo); -- 等级信息组
	return data;
end

function Proto.getWishingTreeInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeWishingTreeInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 序号
	Proto.writestring(msg,data.name); -- 名称
	Proto.writeDWORD(msg,data.ripeTime); -- 成熟时间（秒）
	Proto.writeWORD(msg,data.starLevel); -- 星级
	Proto.writeVector(msg,data.wishAward,Proto.writeDWORD); -- 祈愿奖励
	Proto.writeVector(msg,data.levelInfos,Proto.writeWishingTreeLevelInfo); -- 等级信息组
end

function Proto.parseWishingTreeObj(entry)
	local data={};
	data.plantTime=Proto.parseDWORD(entry); -- 种植时间
	data.treeIndex=Proto.parseWORD(entry); -- 树索引
	data.level=Proto.parseWORD(entry); -- 等级
	data.exp=Proto.parseWORD(entry); -- 经验
	data.ownerName=Proto.parsestring(entry); -- 拥有者
	data.targetStr=Proto.parsestring(entry); -- 附加信息
	return data;
end

function Proto.writeWishingTreeObj(msg,data)
	Proto.writeDWORD(msg,data.plantTime); -- 种植时间
	Proto.writeWORD(msg,data.treeIndex); -- 树索引
	Proto.writeWORD(msg,data.level); -- 等级
	Proto.writeWORD(msg,data.exp); -- 经验
	Proto.writestring(msg,data.ownerName); -- 拥有者
	Proto.writestring(msg,data.targetStr); -- 附加信息
end

function Proto.parseWishingTreeIDObj(entry)
	local data={};
	data.treeID=Proto.parseDWORD(entry); -- 树ID
	data.treeIndex=Proto.parseWORD(entry); -- 树索引
	data.plantTime=Proto.parseDWORD(entry); -- 种植时间
	data.level=Proto.parseWORD(entry); -- 等级
	data.exp=Proto.parseWORD(entry); -- 经验
	data.ownerName=Proto.parsestring(entry); -- 拥有者
	data.targetStr=Proto.parsestring(entry); -- 附加信息
	data.isPrayed=Proto.parseBYTE(entry); -- 已许愿？
	return data;
end

function Proto.writeWishingTreeIDObj(msg,data)
	Proto.writeDWORD(msg,data.treeID); -- 树ID
	Proto.writeWORD(msg,data.treeIndex); -- 树索引
	Proto.writeDWORD(msg,data.plantTime); -- 种植时间
	Proto.writeWORD(msg,data.level); -- 等级
	Proto.writeWORD(msg,data.exp); -- 经验
	Proto.writestring(msg,data.ownerName); -- 拥有者
	Proto.writestring(msg,data.targetStr); -- 附加信息
	Proto.writeBYTE(msg,data.isPrayed); -- 已许愿？
end

