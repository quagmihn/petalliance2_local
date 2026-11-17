-- Net.Proto.Proto_Auction_Types

function Proto.parseAuctionItem(entry)
	local data={};
	data.id=Proto.parseQWORD(entry); -- 编号
	data.item=Proto.parseItemDesc(entry); -- 道具描述
	data.price=Proto.parseMoney(entry); -- 价格
	data.seller=Proto.parseUserID(entry); -- 卖家ID
	return data;
end

function Proto.getAuctionItemIDLen()
	return Proto.getQWORDLen();
end

function Proto.writeAuctionItem(msg,data)
	Proto.writeQWORD(msg,data.id); -- 编号
	Proto.writeItemDesc(msg,data.item); -- 道具描述
	Proto.writeMoney(msg,data.price); -- 价格
	Proto.writeUserID(msg,data.seller); -- 卖家ID
end

