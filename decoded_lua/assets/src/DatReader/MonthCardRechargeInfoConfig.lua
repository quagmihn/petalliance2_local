function Proto.parseMonthCardRechargeInfoIos(entry)
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
function Proto.getMonthCardRechargeInfoIosIDLen()
	return Proto.getintLen();
end


local MonthCardRechargeInfoConfig = require("src.Utils.XDatReader").new("MonthCardRechargeInfo")
return MonthCardRechargeInfoConfig
