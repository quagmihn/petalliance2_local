-- Net.Proto.Proto_Stock_Types

function Proto.parseStockRecord(entry)
	local data={};
	data.recordseq=Proto.parseStockRecSeq(entry); -- 交易记录序列号
	data.isBuy=Proto.parseBYTE(entry); -- 1-买入;0-卖出
	data.sockettid=Proto.parseStockTID(entry); -- 股票类型ID(对应阵营ID)
	data.price=Proto.parseDWORD(entry); -- 单价（每100股）
	data.stack=Proto.parseWORD(entry); -- 笔数（每100股为1笔）
	data.datetime=Proto.parseTIME_SEC(entry); -- 日期时间
	return data;
end

function Proto.writeStockRecord(msg,data)
	Proto.writeStockRecSeq(msg,data.recordseq); -- 交易记录序列号
	Proto.writeBYTE(msg,data.isBuy); -- 1-买入;0-卖出
	Proto.writeStockTID(msg,data.sockettid); -- 股票类型ID(对应阵营ID)
	Proto.writeDWORD(msg,data.price); -- 单价（每100股）
	Proto.writeWORD(msg,data.stack); -- 笔数（每100股为1笔）
	Proto.writeTIME_SEC(msg,data.datetime); -- 日期时间
end

function Proto.parseStockAmount(entry)
	local data={};
	data.tid=Proto.parseStockTID(entry); -- 股票类型ID(对应阵营ID)
	data.amount=Proto.parseDWORD(entry); -- 股票数量
	return data;
end

function Proto.writeStockAmount(msg,data)
	Proto.writeStockTID(msg,data.tid); -- 股票类型ID(对应阵营ID)
	Proto.writeDWORD(msg,data.amount); -- 股票数量
end

function Proto.parseStockAccount(entry)
	local data={};
	data.g_cash=Proto.parseDWORD(entry); -- 贝壳币
	data.stockamount=Proto.parseVector(entry,Proto.parseStockAmount); -- 股票数量
	return data;
end

function Proto.writeStockAccount(msg,data)
	Proto.writeDWORD(msg,data.g_cash); -- 贝壳币
	Proto.writeVector(msg,data.stockamount,Proto.writeStockAmount); -- 股票数量
end

function Proto.parseStockInfo(entry)
	local data={};
	data.id=Proto.parseStockTID(entry); -- 股票类型ID（对应阵营ID）
	data.name=Proto.parseUnitName(entry); -- 股票名称
	data.open=Proto.parseBYTE(entry); -- 开通状态1-开通;0-未开通
	data.tax=Proto.parseWORD(entry); -- 手续费率（1/1000）
	return data;
end

function Proto.getStockInfoIDLen()
	return Proto.getStockTIDLen();
end

function Proto.writeStockInfo(msg,data)
	Proto.writeStockTID(msg,data.id); -- 股票类型ID（对应阵营ID）
	Proto.writeUnitName(msg,data.name); -- 股票名称
	Proto.writeBYTE(msg,data.open); -- 开通状态1-开通;0-未开通
	Proto.writeWORD(msg,data.tax); -- 手续费率（1/1000）
end

function Proto.parseStockConfig(entry)
	local data={};
	data.id=Proto.parseBYTE(entry); -- 配置编号
	data.accountGCashMax=Proto.parseDWORD(entry); -- 交易账户贝壳币上限
	data.accountStockMax=Proto.parseDWORD(entry); -- 交易帐户股票数量上限
	data.buyCountMax=Proto.parseDWORD(entry); -- 买入委托次数上限
	data.sellCountMax=Proto.parseDWORD(entry); -- 卖出委托次数上限
	data.stockAmountPerMax=Proto.parseDWORD(entry); -- 每次委托买卖股票数量上限
	data.stockPriceMax=Proto.parseDWORD(entry); -- 股票单价（每100股价格）上限
	return data;
end

function Proto.getStockConfigIDLen()
	return Proto.getBYTELen();
end

function Proto.writeStockConfig(msg,data)
	Proto.writeBYTE(msg,data.id); -- 配置编号
	Proto.writeDWORD(msg,data.accountGCashMax); -- 交易账户贝壳币上限
	Proto.writeDWORD(msg,data.accountStockMax); -- 交易帐户股票数量上限
	Proto.writeDWORD(msg,data.buyCountMax); -- 买入委托次数上限
	Proto.writeDWORD(msg,data.sellCountMax); -- 卖出委托次数上限
	Proto.writeDWORD(msg,data.stockAmountPerMax); -- 每次委托买卖股票数量上限
	Proto.writeDWORD(msg,data.stockPriceMax); -- 股票单价（每100股价格）上限
end

