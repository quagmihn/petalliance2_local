-- Net.Proto.Proto_FashionShow

function Proto.writeP_CG_GetFashionShowRank_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETFASHIONSHOWRANK_REQ);
end

function Proto.parseP_GC_GetFashionShowRank_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETFASHIONSHOWRANK_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.rankInfo=Proto.parseString(entry); -- 排行信息
	end
	return data;
end

function Proto.writeP_CG_SaveFashionShow_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_SAVEFASHIONSHOW_REQ);
	Proto.writeVector(msg,data.fashions,Proto.writeDWORD); -- 时装信息
	Proto.writeDWORD(msg,data.petObjID); -- 宠物ID
	Proto.writeDWORD(msg,data.sceneID); -- 场景ID
end

function Proto.parseP_GC_SaveFashionShow_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_SAVEFASHIONSHOW_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	return data;
end

function Proto.writeP_CG_GetSingleFashionShow_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETSINGLEFASHIONSHOW_REQ);
	Proto.writeDWORD(msg,data.charID); -- 玩家ID
end

function Proto.parseP_GC_GetSingleFashionShow_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETSINGLEFASHIONSHOW_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.fashions=Proto.parseVector(entry,Proto.parseDWORD); -- 时装信息
		data.petObjID=Proto.parseDWORD(entry); -- 宠物ObjID
		data.point=Proto.parseDWORD(entry); -- 点赞分数
		data.rank=Proto.parseDWORD(entry); -- 排名
		data.petID=Proto.parseDWORD(entry); -- 宠物ID
		data.vipLevel=Proto.parseDWORD(entry); -- vip等级
		data.familyName=Proto.parseString(entry); -- 家族名称
		data.sceneID=Proto.parseDWORD(entry); -- 场景ID
		data.skin=Proto.parseDWORD(entry); -- 皮肤
	end
	return data;
end

function Proto.writeP_CG_TakeFashionShowRankAward_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_TAKEFASHIONSHOWRANKAWARD_REQ);
end

function Proto.parseP_GC_TakeFashionShowRankAward_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_TAKEFASHIONSHOWRANKAWARD_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	return data;
end

function Proto.writeP_CG_GetFashionShowPeopers_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETFASHIONSHOWPEOPERS_REQ);
end

function Proto.parseP_GC_GetFashionShowPeopers_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETFASHIONSHOWPEOPERS_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.fashionShow=Proto.parseVector(entry,Proto.parseFashionShowInfo); -- 时装大赛人物列表
	end
	return data;
end

function Proto.writeP_CG_LikeFashionShow_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_LIKEFASHIONSHOW_REQ);
	Proto.writeDWORD(msg,data.charID); -- 玩家ID
end

function Proto.parseP_GC_LikeFashionShow_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_LIKEFASHIONSHOW_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	return data;
end

function Proto.writeP_CG_GetLikeList_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETLIKELIST_REQ);
end

function Proto.parseP_GC_GetLikeList_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETLIKELIST_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.likeList=Proto.parseString(entry); -- 点赞列表
	end
	return data;
end

