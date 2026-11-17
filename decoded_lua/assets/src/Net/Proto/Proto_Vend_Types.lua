-- Net.Proto.Proto_Vend_Types

function Proto.parseMerchandise(entry)
	local data={};
	data.itemdesc=Proto.parseItemDesc(entry); -- 商品信息
	data.price=Proto.parseDWORD(entry); -- 商品单价
	data.pos=Proto.parseWORD(entry); -- 商品包裹位置
	data.shoppos=Proto.parseWORD(entry); -- 商品在摊位上的位置
	return data;
end

function Proto.writeMerchandise(msg,data)
	Proto.writeItemDesc(msg,data.itemdesc); -- 商品信息
	Proto.writeDWORD(msg,data.price); -- 商品单价
	Proto.writeWORD(msg,data.pos); -- 商品包裹位置
	Proto.writeWORD(msg,data.shoppos); -- 商品在摊位上的位置
end

