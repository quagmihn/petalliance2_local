-- Net.Proto.Proto_FashionShow_Types

function Proto.parseAwardItem(entry)
	local data={};
	data.itemID=Proto.parseDWORD(entry); -- 道具ID
	data.itemCount=Proto.parseDWORD(entry); -- 道具数量
	return data;
end

function Proto.writeAwardItem(msg,data)
	Proto.writeDWORD(msg,data.itemID); -- 道具ID
	Proto.writeDWORD(msg,data.itemCount); -- 道具数量
end

function Proto.parseFashionShowAwardInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.mailID=Proto.parseDWORD(entry); -- 邮件ID
	data.awardList=Proto.parseVector(entry,Proto.parseAwardItem); -- 奖励列表
	return data;
end

function Proto.getFashionShowAwardInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeFashionShowAwardInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeDWORD(msg,data.mailID); -- 邮件ID
	Proto.writeVector(msg,data.awardList,Proto.writeAwardItem); -- 奖励列表
end

function Proto.parseFashionShowInfo(entry)
	local data={};
	data.charID=Proto.parseDWORD(entry); -- 人物ID
	data.fashions=Proto.parseVector(entry,Proto.parseDWORD); -- 时装信息
	data.petObjID=Proto.parseDWORD(entry); -- 宠物ObjID
	data.point=Proto.parseDWORD(entry); -- 点赞数
	data.petID=Proto.parseDWORD(entry); -- 宠物ID
	data.nickName=Proto.parseString(entry); -- 昵称
	data.sceneID=Proto.parseDWORD(entry); -- 场景ID
	data.skin=Proto.parseDWORD(entry); -- 皮肤
	return data;
end

function Proto.writeFashionShowInfo(msg,data)
	Proto.writeDWORD(msg,data.charID); -- 人物ID
	Proto.writeVector(msg,data.fashions,Proto.writeDWORD); -- 时装信息
	Proto.writeDWORD(msg,data.petObjID); -- 宠物ObjID
	Proto.writeDWORD(msg,data.point); -- 点赞数
	Proto.writeDWORD(msg,data.petID); -- 宠物ID
	Proto.writeString(msg,data.nickName); -- 昵称
	Proto.writeDWORD(msg,data.sceneID); -- 场景ID
	Proto.writeDWORD(msg,data.skin); -- 皮肤
end

function Proto.parseFashionShowRuleInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.sencePath=Proto.parseString(entry); -- 场景
	data.petType=Proto.parseDWORD(entry); -- 限定宠物系别
	data.fashionID=Proto.parseDWORD(entry); -- 限定时装
	return data;
end

function Proto.getFashionShowRuleInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeFashionShowRuleInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeString(msg,data.sencePath); -- 场景
	Proto.writeDWORD(msg,data.petType); -- 限定宠物系别
	Proto.writeDWORD(msg,data.fashionID); -- 限定时装
end

