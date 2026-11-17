function Proto.parseNormalRechargeInfoIos(entry)
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

function Proto.getNormalRechargeInfoIosIDLen()
	return Proto.getintLen();
end

local NormalRechargeInfoConfig = require("src.Utils.XDatReader").new("NormalRechargeInfo")
return NormalRechargeInfoConfig
