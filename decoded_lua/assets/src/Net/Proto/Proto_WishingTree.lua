-- Net.Proto.Proto_WishingTree

function Proto.writeP_CG_GetWishingTreesData_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETWISHINGTREESDATA_REQ);
end

function Proto.parseP_GC_GetWishingTreesData_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETWISHINGTREESDATA_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code==Proto.Error.ERROR_OK) then
		data.treesData=Proto.parseVector(entry,Proto.parseWishingTreeIDObj); -- 许愿树数据
	end
	return data;
end

function Proto.parseP_GC_PlantTreeNTF_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_PLANTTREENTF_NTF;
	data.code=Proto.parseWORD(entry); -- 错误码
	return data;
end

function Proto.writeP_CG_PrayToTree_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_PRAYTOTREE_REQ);
	Proto.writeDWORD(msg,data.treeID); -- 树ID
end

function Proto.parseP_GC_PrayToTree_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_PRAYTOTREE_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code==Proto.Error.ERROR_OK) then
		data.awards=Proto.parseVector(entry,Proto.parseString); -- 祈愿奖励
	end
	return data;
end

