-- Net.Proto.Proto_Explore

function Proto.writeP_CG_GetExploreData_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETEXPLOREDATA_REQ);
end

function Proto.parseP_GC_GetExploreData_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETEXPLOREDATA_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.exploreDatas=Proto.parseVector(entry,Proto.parseString); -- 
		data.exploreDiffcultDatas=Proto.parseString(entry); -- 
	end
	return data;
end

function Proto.writeP_CG_Explore_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_EXPLORE_REQ);
	Proto.writeDWORD(msg,data.exploreIndex); -- 探索编号
	Proto.writeDWORD(msg,data.difficulty); -- 
	Proto.writeDWORD(msg,data.option); -- 0,1
	Proto.writeVector(msg,data.petObjIDs,Proto.writeDWORD); -- 探索宠物列表 第一个为队长
end

function Proto.parseP_GC_Explore_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_EXPLORE_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.exploreIndex=Proto.parseDWORD(entry); -- 
		data.exploreData=Proto.parseString(entry); -- 
	end
	return data;
end

function Proto.writeP_CG_EndExplore_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_ENDEXPLORE_REQ);
	Proto.writeDWORD(msg,data.exploreIndex); -- 探索编号
end

function Proto.parseP_GC_EndExplore_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_ENDEXPLORE_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.exploreIndex=Proto.parseDWORD(entry); -- 
		data.exploreData=Proto.parseString(entry); -- 
		data.awards=Proto.parseVector(entry,Proto.parseString); -- 
		data.exploreDiffcultDatas=Proto.parseString(entry); -- 
	end
	return data;
end

function Proto.parseP_GC_UpdateExploreDiffcultDatas_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_UPDATEEXPLOREDIFFCULTDATAS_NTF;
	data.exploreDiffcultDatas=Proto.parseString(entry); -- 
	return data;
end

function Proto.parseP_GC_UpdateExploreData_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_UPDATEEXPLOREDATA_NTF;
	data.exploreData=Proto.parseString(entry); -- 
	return data;
end

function Proto.writeP_CG_BuyExplorePacket_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_BUYEXPLOREPACKET_REQ);
end

function Proto.parseP_GC_BuyExplorePacket_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_BUYEXPLOREPACKET_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.explorePacketNum=Proto.parseDWORD(entry); -- 
		data.exploreData=Proto.parseString(entry); -- 
	end
	return data;
end

