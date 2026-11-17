-- Net.Proto.Proto_Define_PetFeedingInfo_Types

Proto.PFW_DORM	= 0						-- [宠物进食方式]在宿舍中
Proto.PFW_OWNER	= Proto.PFW_DORM + 1	-- [宠物进食方式]从主人那
Proto.PFW_PLANT	= Proto.PFW_OWNER + 1	-- [宠物进食方式]在树上

function Proto.parsePetFeedingInfo(entry)
	local data={};
	data.foodID=Proto.parseDWORD(entry); -- 食物ID
	data.feedWay=Proto.parseBYTE(entry); -- 进食方式
	return data;
end

function Proto.writePetFeedingInfo(msg,data)
	Proto.writeDWORD(msg,data.foodID); -- 食物ID
	Proto.writeBYTE(msg,data.feedWay); -- 进食方式
end

