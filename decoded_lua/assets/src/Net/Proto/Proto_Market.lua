-- Net.Proto.Proto_Market

function Proto.parseMarketInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 
	data.itemID=Proto.parseDWORD(entry); -- 
	data.marketType=Proto.parseDWORD(entry); -- 
	data.subType=Proto.parseDWORD(entry); -- 
	data.subTypeName=Proto.parseString(entry); -- 
	data.smallType=Proto.parseDWORD(entry); -- 
	data.smallTypeName=Proto.parseString(entry); -- 
	data.coinType=Proto.parseDWORD(entry); -- 
	data.num=Proto.parseDWORD(entry); -- 
	data.buyMax=Proto.parseDWORD(entry); -- 
	data.vip=Proto.parseDWORD(entry); -- 
	data.oldNum=Proto.parseDWORD(entry); -- 
	data.tag=Proto.parseString(entry); -- 
	return data;
end

function Proto.getMarketInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeMarketInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 
	Proto.writeDWORD(msg,data.itemID); -- 
	Proto.writeDWORD(msg,data.marketType); -- 
	Proto.writeDWORD(msg,data.subType); -- 
	Proto.writeString(msg,data.subTypeName); -- 
	Proto.writeDWORD(msg,data.smallType); -- 
	Proto.writeString(msg,data.smallTypeName); -- 
	Proto.writeDWORD(msg,data.coinType); -- 
	Proto.writeDWORD(msg,data.num); -- 
	Proto.writeDWORD(msg,data.buyMax); -- 
	Proto.writeDWORD(msg,data.vip); -- 
	Proto.writeDWORD(msg,data.oldNum); -- 
	Proto.writeString(msg,data.tag); -- 
end

function Proto.writeP_CG_GetMyMarket_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETMYMARKET_REQ);
end

function Proto.parseP_GC_GetMyMarket_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETMYMARKET_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code==Proto.Error.ERROR_OK) then
		data.products=Proto.parseVector(entry,Proto.parseString); -- 
	end
	return data;
end

function Proto.writeP_CG_SellOnMarket_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_SELLONMARKET_REQ);
	Proto.writeDWORD(msg,data.itemID); -- 
	Proto.writeDWORD(msg,data.objID); -- 非家具填0
	Proto.writeDWORD(msg,data.sellNum); -- 数量
	Proto.writeDWORD(msg,data.unitPrice); -- 单价
end

function Proto.parseP_GC_SellOnMarket_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_SELLONMARKET_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code==Proto.Error.ERROR_OK) then
		data.product=Proto.parseString(entry); -- 
	end
	return data;
end

function Proto.writeP_CG_SearchProducts_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_SEARCHPRODUCTS_REQ);
	Proto.writeDWORD(msg,data.itemType); -- 道具类型
	Proto.writeDWORD(msg,data.itemSubType); -- 道具子类型
	Proto.writeDWORD(msg,data.itemID); -- 搜索道具id
	Proto.writeDWORD(msg,data.sortType); -- 排序规则
	Proto.writeDWORD(msg,data.startIndex); -- 开始
	Proto.writeDWORD(msg,data.searchNum); -- 数量
	Proto.writeString(msg,data.selectID); -- 特定标签
end

function Proto.parseP_GC_SearchProducts_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_SEARCHPRODUCTS_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code==Proto.Error.ERROR_OK) then
		data.products=Proto.parseVector(entry,Proto.parseString); -- 
	end
	return data;
end

function Proto.writeP_CG_BuyProduct_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_BUYPRODUCT_REQ);
	Proto.writeString(msg,data.productID); -- 商品ID
	Proto.writeDWORD(msg,data.num); -- 购买数量
end

function Proto.parseP_GC_BuyProduct_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_BUYPRODUCT_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	return data;
end

function Proto.writeP_CG_DelMyProduct_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_DELMYPRODUCT_REQ);
	Proto.writeString(msg,data.productID); -- 商品ID
end

function Proto.parseP_GC_DelMyProduct_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_DELMYPRODUCT_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	return data;
end

function Proto.writeP_CG_BuyMarketItem_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_BUYMARKETITEM_REQ);
	Proto.writeDWORD(msg,data.marketInfoID); -- 商品ID
	Proto.writeDWORD(msg,data.num); -- 数量
end

function Proto.parseP_GC_BuyMarketItem_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_BUYMARKETITEM_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	return data;
end

