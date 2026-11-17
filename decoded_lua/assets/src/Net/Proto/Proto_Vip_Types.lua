-- Net.Proto.Proto_Vip_Types

function Proto.parseVipInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.viplevel=Proto.parseDWORD(entry); -- vip等级
	data.explain=Proto.parseString(entry); -- 特权说明
	data.awardsID=Proto.parseVector(entry,Proto.parseDWORD); -- 等级奖励
	data.recharge=Proto.parseDWORD(entry); -- 充值费用
	data.goldTimes=Proto.parseDWORD(entry); -- 点金次数
	data.buyPower=Proto.parseDWORD(entry); -- 购买体力
	data.reActivity=Proto.parseDWORD(entry); -- 重置活动本次数
	data.reCost=Proto.parseDWORD(entry); -- 重置费用
	data.reCommon=Proto.parseDWORD(entry); -- 重置一般本次数
	data.exploreAwardTimeReduceRate=Proto.parseDWORD(entry); -- 缩短挂机结算时间(百分比)
	data.ltSetpNumber=Proto.parseDWORD(entry); -- 迷失之塔移动步数
	data.ltShopRefresh=Proto.parseDWORD(entry); -- 迷失之塔商店刷新次数
	data.arenaShopRefresh=Proto.parseDWORD(entry); -- 竞技场商店刷新次数
	data.terrBuyNum=Proto.parseDWORD(entry); -- 领主额外挑战次数
	data.repairTimes=Proto.parseBYTE(entry); -- 签到补签次数
	data.lostTowerRecoverTime=Proto.parseDWORD(entry); -- 迷失之塔步数恢复时间
	data.dreamCoinAdd=Proto.parseDWORD(entry); -- 扭蛋额外梦想币
	data.effect=Proto.parseString(entry); -- 特效
	return data;
end

function Proto.getVipInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeVipInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeDWORD(msg,data.viplevel); -- vip等级
	Proto.writeString(msg,data.explain); -- 特权说明
	Proto.writeVector(msg,data.awardsID,Proto.writeDWORD); -- 等级奖励
	Proto.writeDWORD(msg,data.recharge); -- 充值费用
	Proto.writeDWORD(msg,data.goldTimes); -- 点金次数
	Proto.writeDWORD(msg,data.buyPower); -- 购买体力
	Proto.writeDWORD(msg,data.reActivity); -- 重置活动本次数
	Proto.writeDWORD(msg,data.reCost); -- 重置费用
	Proto.writeDWORD(msg,data.reCommon); -- 重置一般本次数
	Proto.writeDWORD(msg,data.exploreAwardTimeReduceRate); -- 缩短挂机结算时间(百分比)
	Proto.writeDWORD(msg,data.ltSetpNumber); -- 迷失之塔移动步数
	Proto.writeDWORD(msg,data.ltShopRefresh); -- 迷失之塔商店刷新次数
	Proto.writeDWORD(msg,data.arenaShopRefresh); -- 竞技场商店刷新次数
	Proto.writeDWORD(msg,data.terrBuyNum); -- 领主额外挑战次数
	Proto.writeBYTE(msg,data.repairTimes); -- 签到补签次数
	Proto.writeDWORD(msg,data.lostTowerRecoverTime); -- 迷失之塔步数恢复时间
	Proto.writeDWORD(msg,data.dreamCoinAdd); -- 扭蛋额外梦想币
	Proto.writeString(msg,data.effect); -- 特效
end

function Proto.parseGoldPointInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 次数
	data.gold=Proto.parseDWORD(entry); -- 产出金币
	data.jewel=Proto.parseDWORD(entry); -- 花费钻石
	return data;
end

function Proto.getGoldPointInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeGoldPointInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 次数
	Proto.writeDWORD(msg,data.gold); -- 产出金币
	Proto.writeDWORD(msg,data.jewel); -- 花费钻石
end

function Proto.parseGoldPointMultiInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 倍率
	data.weight=Proto.parseDWORD(entry); -- 权重
	return data;
end

function Proto.getGoldPointMultiInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeGoldPointMultiInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 倍率
	Proto.writeDWORD(msg,data.weight); -- 权重
end

function Proto.parseBuyPowerInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 次数
	data.cost=Proto.parseDWORD(entry); -- 花费钻石
	data.power=Proto.parseDWORD(entry); -- 体力恢复
	return data;
end

function Proto.getBuyPowerInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeBuyPowerInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 次数
	Proto.writeDWORD(msg,data.cost); -- 花费钻石
	Proto.writeDWORD(msg,data.power); -- 体力恢复
end

function Proto.parseResetInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 重置次数
	data.cost=Proto.parseDWORD(entry); -- 花费钻石
	return data;
end

function Proto.getResetInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeResetInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 重置次数
	Proto.writeDWORD(msg,data.cost); -- 花费钻石
end

