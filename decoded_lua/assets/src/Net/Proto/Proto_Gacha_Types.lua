-- Net.Proto.Proto_Gacha_Types

Proto.GCT_GCASH	= 0						-- [扭蛋消耗类型]G币
Proto.GCT_MCASH	= Proto.GCT_GCASH + 1	-- [扭蛋消耗类型]M币
Proto.GCT_ITEM	= Proto.GCT_MCASH + 1	-- [扭蛋消耗类型]道具

function Proto.parseGachaCost_PARAM_GCash(entry)
	local data={};
	data.value=Proto.parseWORD(entry); -- 值
	return data;
end

function Proto.writeGachaCost_PARAM_GCash(msg,data)
	Proto.writeWORD(msg,data.value); -- 值
end

function Proto.parseGachaCost_PARAM_MCash(entry)
	local data={};
	data.value=Proto.parseWORD(entry); -- 值
	return data;
end

function Proto.writeGachaCost_PARAM_MCash(msg,data)
	Proto.writeWORD(msg,data.value); -- 值
end

function Proto.parseGachaCost_PARAM_Item(entry)
	local data={};
	data.itemID=Proto.parseDWORD(entry); -- 道具生成ID
	data.count=Proto.parseWORD(entry); -- 道具数量
	return data;
end

function Proto.writeGachaCost_PARAM_Item(msg,data)
	Proto.writeDWORD(msg,data.itemID); -- 道具生成ID
	Proto.writeWORD(msg,data.count); -- 道具数量
end

function Proto.parseGachaCost(entry)
	local data={};
	data.type=Proto.parseWORD(entry); -- 扭蛋消耗类型
	data.param={}; -- 
	if (data.type==Proto.GCT_GCASH) then
		data.param.gCash=Proto.parseGachaCost_PARAM_GCash(entry); -- G币
	end
	if (data.type==Proto.GCT_MCASH) then
		data.param.mCash=Proto.parseGachaCost_PARAM_MCash(entry); -- M币
	end
	if (data.type==Proto.GCT_ITEM) then
		data.param.item=Proto.parseGachaCost_PARAM_Item(entry); -- 道具
	end
	return data;
end

function Proto.writeGachaCost(msg,data)
	Proto.writeWORD(msg,data.type); -- 扭蛋消耗类型
	if (data.type==Proto.GCT_GCASH) then
		Proto.writeGachaCost_PARAM_GCash(msg,data.param.gCash); -- G币
	end
	if (data.type==Proto.GCT_MCASH) then
		Proto.writeGachaCost_PARAM_MCash(msg,data.param.mCash); -- M币
	end
	if (data.type==Proto.GCT_ITEM) then
		Proto.writeGachaCost_PARAM_Item(msg,data.param.item); -- 道具
	end
end

function Proto.parseGachaInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 编号
	data.name=Proto.parseString(entry); -- 扭蛋名称
	data.cost=Proto.parseGachaCost(entry); -- 消耗
	data.awardTable=Proto.parseDWORD(entry); -- 奖励表
	data.progressTotal=Proto.parseDWORD(entry); -- 总进度
	data.sundryAwardTable=Proto.parseDWORD(entry); -- 杂项奖励表
	return data;
end

function Proto.getGachaInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeGachaInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 编号
	Proto.writeString(msg,data.name); -- 扭蛋名称
	Proto.writeGachaCost(msg,data.cost); -- 消耗
	Proto.writeDWORD(msg,data.awardTable); -- 奖励表
	Proto.writeDWORD(msg,data.progressTotal); -- 总进度
	Proto.writeDWORD(msg,data.sundryAwardTable); -- 杂项奖励表
end

function Proto.parseGachaProgressInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 编号
	data.progress=Proto.parseDWORD(entry); -- 进度
	return data;
end

function Proto.getGachaProgressInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeGachaProgressInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 编号
	Proto.writeDWORD(msg,data.progress); -- 进度
end

