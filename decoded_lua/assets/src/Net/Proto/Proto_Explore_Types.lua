-- Net.Proto.Proto_Explore_Types

Proto.EXPLORE_COMMON	= 0							-- [探索事件类型]普通
Proto.EXPLORE_MONEY		= Proto.EXPLORE_COMMON + 1	-- [探索事件类型]金币
Proto.EXPLORE_BOSS		= Proto.EXPLORE_MONEY + 1	-- [探索事件类型]BOSS
Proto.EXPLORE_REWARD	= Proto.EXPLORE_BOSS + 1	-- [探索事件类型]特殊奖励
Proto.EXPLORE_UNUSUAL	= Proto.EXPLORE_REWARD + 1	-- [探索事件类型]稀有事件
Proto.EXPLORE_MCASH		= Proto.EXPLORE_UNUSUAL + 1	-- [探索事件类型]M币事件

function Proto.parseExploreEventSInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.eventType=Proto.parseDWORD(entry); --  探索类型,ExploreTypes
	data.eventLevel=Proto.parseDWORD(entry); -- 探索等级
	data.name=Proto.parseString(entry); -- 名称
	data.describe=Proto.parseString(entry); -- 描述
	data.quality=Proto.parseDWORD(entry); -- 品质
	data.recover=Proto.parseDWORD(entry); -- 回复体力
	data.rewardElement=Proto.parseVector(entry,Proto.parseDWORD); -- 奖励元素
	data.rewardNum=Proto.parseVector(entry,Proto.parseDWORD); -- 奖励数量
	data.parameter=Proto.parseString(entry); -- 参数
	return data;
end

function Proto.getExploreEventSInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeExploreEventSInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeDWORD(msg,data.eventType); --  探索类型,ExploreTypes
	Proto.writeDWORD(msg,data.eventLevel); -- 探索等级
	Proto.writeString(msg,data.name); -- 名称
	Proto.writeString(msg,data.describe); -- 描述
	Proto.writeDWORD(msg,data.quality); -- 品质
	Proto.writeDWORD(msg,data.recover); -- 回复体力
	Proto.writeVector(msg,data.rewardElement,Proto.writeDWORD); -- 奖励元素
	Proto.writeVector(msg,data.rewardNum,Proto.writeDWORD); -- 奖励数量
	Proto.writeString(msg,data.parameter); -- 参数
end

function Proto.parseExploreInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 探索ID
	data.name=Proto.parseString(entry); -- 名称
	data.needStar=Proto.parseDWORD(entry); -- 解锁星级
	data.normalMoney=Proto.parseDWORD(entry); -- 探索总时间
	data.normalPetExp=Proto.parseDWORD(entry); -- 探索领队类型
	data.normalAwardTime=Proto.parseDWORD(entry); -- 固定收益时间间隔
	data.randomAwardIDs=Proto.parseVector(entry,Proto.parseDWORD); -- 随机物品掉落ID
	data.randomAwardTime=Proto.parseDWORD(entry); -- 随机收益时间间隔
	data.territorialTime=Proto.parseDWORD(entry); -- 领主随机收益时间
	data.familyTime=Proto.parseDWORD(entry); -- 家族成员随机收益
	data.worldID=Proto.parseDWORD(entry); -- 地图ID
	return data;
end

function Proto.getExploreInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeExploreInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 探索ID
	Proto.writeString(msg,data.name); -- 名称
	Proto.writeDWORD(msg,data.needStar); -- 解锁星级
	Proto.writeDWORD(msg,data.normalMoney); -- 探索总时间
	Proto.writeDWORD(msg,data.normalPetExp); -- 探索领队类型
	Proto.writeDWORD(msg,data.normalAwardTime); -- 固定收益时间间隔
	Proto.writeVector(msg,data.randomAwardIDs,Proto.writeDWORD); -- 随机物品掉落ID
	Proto.writeDWORD(msg,data.randomAwardTime); -- 随机收益时间间隔
	Proto.writeDWORD(msg,data.territorialTime); -- 领主随机收益时间
	Proto.writeDWORD(msg,data.familyTime); -- 家族成员随机收益
	Proto.writeDWORD(msg,data.worldID); -- 地图ID
end

function Proto.parseExploreRandomAwardInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 
	data.rate=Proto.parseDWORD(entry); -- 概率
	data.itemID=Proto.parseDWORD(entry); -- 道具ID
	data.count=Proto.parseDWORD(entry); -- 数量
	data.eventLevel=Proto.parseDWORD(entry); -- 事件等级
	return data;
end

function Proto.getExploreRandomAwardInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeExploreRandomAwardInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 
	Proto.writeDWORD(msg,data.rate); -- 概率
	Proto.writeDWORD(msg,data.itemID); -- 道具ID
	Proto.writeDWORD(msg,data.count); -- 数量
	Proto.writeDWORD(msg,data.eventLevel); -- 事件等级
end

function Proto.parseExplorePacketBuyInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 
	data.gcash=Proto.parseDWORD(entry); -- G币
	data.mcash=Proto.parseDWORD(entry); -- M币
	return data;
end

function Proto.getExplorePacketBuyInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeExplorePacketBuyInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 
	Proto.writeDWORD(msg,data.gcash); -- G币
	Proto.writeDWORD(msg,data.mcash); -- M币
end

