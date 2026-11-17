-- Net.Proto.Proto_Signin_Types

function Proto.parseSigninVipRate(entry)
	local data={};
	data.vipLevel=Proto.parseBYTE(entry); -- vip等级
	data.rate=Proto.parseBYTE(entry); -- 倍数
	return data;
end

function Proto.writeSigninVipRate(msg,data)
	Proto.writeBYTE(msg,data.vipLevel); -- vip等级
	Proto.writeBYTE(msg,data.rate); -- 倍数
end

function Proto.parseSigninDayAward(entry)
	local data={};
	data.type=Proto.parseDWORD(entry); -- 奖励元素类型
	data.num=Proto.parseDWORD(entry); -- 奖励元素数量
	return data;
end

function Proto.writeSigninDayAward(msg,data)
	Proto.writeDWORD(msg,data.type); -- 奖励元素类型
	Proto.writeDWORD(msg,data.num); -- 奖励元素数量
end

function Proto.parseSigninInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 日期的天
	data.vipRate=Proto.parseSigninVipRate(entry); -- VIP翻倍
	data.awards=Proto.parseVector(entry,Proto.parseSigninDayAward); -- 奖励组，一月到十二月
	return data;
end

function Proto.getSigninInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeSigninInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 日期的天
	Proto.writeSigninVipRate(msg,data.vipRate); -- VIP翻倍
	Proto.writeVector(msg,data.awards,Proto.writeSigninDayAward); -- 奖励组，一月到十二月
end

function Proto.parseSigninRepairCostInfo(entry)
	local data={};
	data.id=Proto.parseBYTE(entry); -- 次数
	data.cost=Proto.parseDWORD(entry); -- 费用
	return data;
end

function Proto.getSigninRepairCostInfoIDLen()
	return Proto.getBYTELen();
end

function Proto.writeSigninRepairCostInfo(msg,data)
	Proto.writeBYTE(msg,data.id); -- 次数
	Proto.writeDWORD(msg,data.cost); -- 费用
end

