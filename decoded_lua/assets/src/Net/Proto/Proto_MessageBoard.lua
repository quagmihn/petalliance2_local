-- Net.Proto.Proto_MessageBoard

function Proto.writeP_CG_PostMessagePet_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_POSTMESSAGEPET_REQ);
	Proto.writeString(msg,data.sContent); -- 评论信息
	Proto.writeDWORD(msg,data.pokeID); -- 宠物pokeID
end

function Proto.parseP_GC_PostMessagePet_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_POSTMESSAGEPET_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	return data;
end

function Proto.writeP_CG_PostMessageFB_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_POSTMESSAGEFB_REQ);
	Proto.writeString(msg,data.sContent); -- 评论信息
	Proto.writeWORD(msg,data.mapID); -- 
	Proto.writeWORD(msg,data.nodeID); -- 
	Proto.writeBYTE(msg,data.diffi); -- 难度：1,2,3
end

function Proto.parseP_GC_PostMessageFB_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_POSTMESSAGEFB_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	return data;
end

function Proto.writeP_CG_PostApprovePet_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_POSTAPPROVEPET_REQ);
	Proto.writeString(msg,data.sCommentID); -- 评论ID
	Proto.writeBYTE(msg,data.bApprove); -- 1赞0踩
end

function Proto.parseP_GC_PostApprovePet_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_POSTAPPROVEPET_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	return data;
end

function Proto.writeP_CG_PostApproveFB_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_POSTAPPROVEFB_REQ);
	Proto.writeString(msg,data.sCommentID); -- 评论ID
	Proto.writeBYTE(msg,data.bApprove); -- 1赞0踩
end

function Proto.parseP_GC_PostApproveFB_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_POSTAPPROVEFB_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	return data;
end

function Proto.writeP_CG_GetMessagesPetByTime_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETMESSAGESPETBYTIME_REQ);
	Proto.writeDWORD(msg,data.pokeID); -- 宠物pokeID
	Proto.writeString(msg,data.startIndex); -- 起始评论ID
	Proto.writeDWORD(msg,data.num); -- 要获取的评论数量
end

function Proto.parseP_GC_GetMessagesPetByTime_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETMESSAGESPETBYTIME_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.comments=Proto.parseString(entry); -- 评论组
	end
	return data;
end

function Proto.writeP_CG_GetMessagesPetByApprove_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETMESSAGESPETBYAPPROVE_REQ);
	Proto.writeDWORD(msg,data.pokeID); -- 宠物pokeID
	Proto.writeDWORD(msg,data.tipNum); -- 提示点赞量
	Proto.writeDWORD(msg,data.skipNum); -- 跳过多少个评论
	Proto.writeDWORD(msg,data.num); -- 要获取的评论数量
end

function Proto.parseP_GC_GetMessagesPetByApprove_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETMESSAGESPETBYAPPROVE_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.comments=Proto.parseString(entry); -- 评论组
	end
	return data;
end

function Proto.writeP_CG_GetMessagesFBByTime_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETMESSAGESFBBYTIME_REQ);
	Proto.writeWORD(msg,data.mapID); -- 
	Proto.writeWORD(msg,data.nodeID); -- 
	Proto.writeBYTE(msg,data.diffi); -- 难度：1,2,3
	Proto.writeString(msg,data.startIndex); -- 起始评论ID
	Proto.writeDWORD(msg,data.num); -- 要获取的评论数量
end

function Proto.parseP_GC_GetMessagesFBByTime_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETMESSAGESFBBYTIME_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.comments=Proto.parseString(entry); -- 评论组
	end
	return data;
end

function Proto.writeP_CG_GetMessagesFBByApprove_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETMESSAGESFBBYAPPROVE_REQ);
	Proto.writeWORD(msg,data.mapID); -- 
	Proto.writeWORD(msg,data.nodeID); -- 
	Proto.writeBYTE(msg,data.diffi); -- 难度：1,2,3
	Proto.writeDWORD(msg,data.tipNum); -- 提示点赞量
	Proto.writeDWORD(msg,data.skipNum); -- 跳过多少个评论
	Proto.writeDWORD(msg,data.num); -- 要获取的评论数量
end

function Proto.parseP_GC_GetMessagesFBByApprove_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETMESSAGESFBBYAPPROVE_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.comments=Proto.parseString(entry); -- 评论组
	end
	return data;
end

