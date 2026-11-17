-- Net.Proto.Proto_NewShop

function Proto.writeP_CG_getShop_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETSHOP_REQ);
	Proto.writeDWORD(msg,data.type); -- 类型
end

function Proto.parseP_GC_getShop_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETSHOP_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.shop=Proto.parseShop(entry); -- 商品信息
	end
	return data;
end

function Proto.writeP_CG_RefreshGoods_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_REFRESHGOODS_REQ);
	Proto.writeDWORD(msg,data.type); -- 商品类型
end

function Proto.parseP_GC_RefreshGoods_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_REFRESHGOODS_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.shopList=Proto.parseVector(entry,Proto.parseShopList); -- 商品信息列表
	end
	return data;
end

function Proto.writeP_CG_BuyGoods_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_BUYGOODS_REQ);
	Proto.writeDWORD(msg,data.type); -- 商店类型
	Proto.writeDWORD(msg,data.index); -- 商品索引
	Proto.writeDWORD(msg,data.buyCount); -- 购买次数
end

function Proto.parseP_GC_BuyGoods_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_BUYGOODS_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	return data;
end

function Proto.writeP_CG_SystemRefreshGoods_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_SYSTEMREFRESHGOODS_REQ);
	Proto.writeDWORD(msg,data.type); -- 商品类型
end

function Proto.parseP_GC_SystemRefreshGoods_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_SYSTEMREFRESHGOODS_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.shopList=Proto.parseVector(entry,Proto.parseShopList); -- 商品信息列表
	end
	return data;
end

function Proto.writeP_CG_ResetShop_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_RESETSHOP_REQ);
	Proto.writeDWORD(msg,data.type); -- 商店类型
end

function Proto.parseP_GC_ResetShop_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_RESETSHOP_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	return data;
end

function Proto.writeP_CG_GetRedHeartShopInfo_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETREDHEARTSHOPINFO_REQ);
end

function Proto.parseP_GC_GetRedHeartShopInfo_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETREDHEARTSHOPINFO_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.goodsList=Proto.parseVector(entry,Proto.parseRedHeartGoods); -- 商品信息列表
	end
	return data;
end

function Proto.writeP_CG_BuyRedHeartGoods_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_BUYREDHEARTGOODS_REQ);
	Proto.writeWORD(msg,data.pos); -- 商品位置
end

function Proto.parseP_GC_BuyRedHeartGoods_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_BUYREDHEARTGOODS_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	return data;
end

function Proto.writeP_CG_GetMyRedHeartShopInfo_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETMYREDHEARTSHOPINFO_REQ);
end

function Proto.parseP_GC_GetMyRedHeartShopInfo_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETMYREDHEARTSHOPINFO_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	data.data=Proto.parseString(entry); -- 友情商店记录
	return data;
end

function Proto.parseP_GC_RedHeartShopRefreshNTF_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_REDHEARTSHOPREFRESHNTF_NTF;
	return data;
end

function Proto.parseP_GC_MyRedHeartShopInfoNTF_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_MYREDHEARTSHOPINFONTF_NTF;
	data.data=Proto.parseString(entry); -- 友情商店记录
	return data;
end

function Proto.writeP_CG_GetOneMCashShop_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETONEMCASHSHOP_REQ);
end

function Proto.parseP_GC_GetOneMCashShop_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETONEMCASHSHOP_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.itemNum=Proto.parseDWORD(entry); -- 商店道具数量
	end
	return data;
end

function Proto.parseP_GC_GetOneMCashShop_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETONEMCASHSHOP_NTF;
	data.itemInfos=Proto.parseVector(entry,Proto.parseString); -- 商店道具
	return data;
end

function Proto.writeP_CG_BuyOneMCashShop_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_BUYONEMCASHSHOP_REQ);
	Proto.writeDWORD(msg,data.itemID); -- 
	Proto.writeDWORD(msg,data.buyNum); -- 
end

function Proto.parseP_GC_BuyOneMCashShop_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_BUYONEMCASHSHOP_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.itemInfo=Proto.parseString(entry); -- 道具
	end
	return data;
end

function Proto.writeP_CG_GetOneMCashShopDetail_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETONEMCASHSHOPDETAIL_REQ);
	Proto.writeDWORD(msg,data.itemID); -- 
end

function Proto.parseP_GC_GetOneMCashShopDetail_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETONEMCASHSHOPDETAIL_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.itemInfo=Proto.parseString(entry); -- 道具
	end
	return data;
end

function Proto.writeP_CG_GetOneMCashShopLog_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETONEMCASHSHOPLOG_REQ);
	Proto.writeDWORD(msg,data.startIndex); -- 
	Proto.writeDWORD(msg,data.endIndex); -- 
end

function Proto.parseP_GC_GetOneMCashShopLog_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETONEMCASHSHOPLOG_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.startIndex=Proto.parseDWORD(entry); -- 
		data.endIndex=Proto.parseDWORD(entry); -- 
		data.wins=Proto.parseVector(entry,Proto.parseString); -- 获胜玩家
	end
	return data;
end

function Proto.writeP_CG_GetSelfActivityShopData_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETSELFACTIVITYSHOPDATA_REQ);
end

function Proto.parseP_GC_GetSelfActivityShopData_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETSELFACTIVITYSHOPDATA_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code==Proto.Error.ERROR_OK) then
		data.lastBuyTime=Proto.parseDWORD(entry); -- 购买时间
		data.vecData=Proto.parseVector(entry,Proto.parseActivityShopData); -- 商品信息列表
	end
	return data;
end

function Proto.writeP_CG_BuyActivityShopItem_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_BUYACTIVITYSHOPITEM_REQ);
	Proto.writeDWORD(msg,data.itemID); -- 商品ID
	Proto.writeDWORD(msg,data.count); -- 购买次数
end

function Proto.parseP_GC_BuyActivityShopItem_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_BUYACTIVITYSHOPITEM_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	return data;
end

