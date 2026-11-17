-- Net.Proto.Proto_CreditCard_Types

function Proto.parseCreditCard(entry)
	local data={};
	data.cardID=Proto.parseCreditCardID(entry); -- 类型ID
	data.upperLimit=Proto.parseDWORD(entry); -- 货币上限
	data.money=Proto.parseDWORD(entry); -- 金钱
	return data;
end

function Proto.writeCreditCard(msg,data)
	Proto.writeCreditCardID(msg,data.cardID); -- 类型ID
	Proto.writeDWORD(msg,data.upperLimit); -- 货币上限
	Proto.writeDWORD(msg,data.money); -- 金钱
end

function Proto.parseNationCreditCardInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 阵营信用卡道具ID
	data.nation_id=Proto.parseBYTE(entry); -- 阵营ID
	data.upperBound=Proto.parseDWORD(entry); -- 金额上限
	data.money=Proto.parseDWORD(entry); -- 金钱
	return data;
end

function Proto.getNationCreditCardInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeNationCreditCardInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 阵营信用卡道具ID
	Proto.writeBYTE(msg,data.nation_id); -- 阵营ID
	Proto.writeDWORD(msg,data.upperBound); -- 金额上限
	Proto.writeDWORD(msg,data.money); -- 金钱
end

