-- Net.Proto.Proto_Recharge_Types

Proto.FRAT_LIFE				= 0								-- [首充奖励类型]终生
Proto.FRAT_DAILY			= Proto.FRAT_LIFE + 1			-- [首充奖励类型]每日
Proto.FRAT_DAILY_ADVANCED	= Proto.FRAT_DAILY + 1			-- [首充奖励类型]每日升级版
Proto.FRAT_COUNT			= Proto.FRAT_DAILY_ADVANCED + 1	-- [首充奖励类型]总数量

function Proto.parseFirstRechargeAwardInfo(entry)
	local data={};
	data.id=Proto.parseint(entry); -- ID
	data.type=Proto.parseint(entry); -- FirstRechargeAwardType
	data.itemID=Proto.parseint(entry); -- 道具ID
	data.itemCount=Proto.parseint(entry); -- 道具数量
	data.mailID=Proto.parseint(entry); -- 邮件ID
	return data;
end

function Proto.getFirstRechargeAwardInfoIDLen()
	return Proto.getintLen();
end

function Proto.writeFirstRechargeAwardInfo(msg,data)
	Proto.writeint(msg,data.id); -- ID
	Proto.writeint(msg,data.type); -- FirstRechargeAwardType
	Proto.writeint(msg,data.itemID); -- 道具ID
	Proto.writeint(msg,data.itemCount); -- 道具数量
	Proto.writeint(msg,data.mailID); -- 邮件ID
end

function Proto.parseNormalRechargeInfo(entry)
	local data={};
	data.id=Proto.parseint(entry); -- ID
	data.name=Proto.parsestring(entry); -- ID
	data.money=Proto.parseint(entry); -- 充值金额
	data.mCash=Proto.parseint(entry); -- 元玉
	data.giftMCash=Proto.parseint(entry); -- 赠送元玉
	data.bonusRate=Proto.parseint(entry); -- 翻倍倍数
	data.bonusCD=Proto.parseint(entry); -- 翻倍CD(分)
	data.orderName=Proto.parseString(entry); -- 订单号
	data.image=Proto.parseString(entry); -- 图片路径
	data.tag=Proto.parseString(entry); -- 标签
	return data;
end

function Proto.getNormalRechargeInfoIDLen()
	return Proto.getintLen();
end

function Proto.writeNormalRechargeInfo(msg,data)
	Proto.writeint(msg,data.id); -- ID
	Proto.writestring(msg,data.name); -- ID
	Proto.writeint(msg,data.money); -- 充值金额
	Proto.writeint(msg,data.mCash); -- 元玉
	Proto.writeint(msg,data.giftMCash); -- 赠送元玉
	Proto.writeint(msg,data.bonusRate); -- 翻倍倍数
	Proto.writeint(msg,data.bonusCD); -- 翻倍CD(分)
	Proto.writeString(msg,data.orderName); -- 订单号
	Proto.writeString(msg,data.image); -- 图片路径
	Proto.writeString(msg,data.tag); -- 标签
end

function Proto.parseMonthCardRechargeInfo(entry)
	local data={};
	data.id=Proto.parseint(entry); -- ID
	data.name=Proto.parsestring(entry); -- 名称
	data.money=Proto.parseint(entry); -- 充值金额
	data.days=Proto.parseint(entry); -- 有效天数
	data.mCashPerDay=Proto.parseint(entry); -- 每天元玉数
	data.initMCash=Proto.parseint(entry); -- 初始元玉销
	data.orderName=Proto.parseString(entry); -- 订单号
	return data;
end

function Proto.getMonthCardRechargeInfoIDLen()
	return Proto.getintLen();
end

function Proto.writeMonthCardRechargeInfo(msg,data)
	Proto.writeint(msg,data.id); -- ID
	Proto.writestring(msg,data.name); -- 名称
	Proto.writeint(msg,data.money); -- 充值金额
	Proto.writeint(msg,data.days); -- 有效天数
	Proto.writeint(msg,data.mCashPerDay); -- 每天元玉数
	Proto.writeint(msg,data.initMCash); -- 初始元玉销
	Proto.writeString(msg,data.orderName); -- 订单号
end

