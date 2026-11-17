-- Net.Proto.Proto_ChatUser

function Proto.writeP_CG_GetMyFriends_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETMYFRIENDS_REQ);
end

function Proto.parseP_GC_GetMyFriends_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETMYFRIENDS_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code==Proto.Error.ERROR_OK) then
		data.friendNum=Proto.parseDWORD(entry); -- 好友数量
	end
	return data;
end

function Proto.parseP_GC_GetMyFriends_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETMYFRIENDS_NTF;
	data.friends=Proto.parseVector(entry,Proto.parseString); -- 好友
	return data;
end

function Proto.writeP_CG_GetMyRedHearts_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETMYREDHEARTS_REQ);
end

function Proto.parseP_GC_GetMyRedHearts_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETMYREDHEARTS_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code==Proto.Error.ERROR_OK) then
		data.redHearts=Proto.parseDWORD(entry); -- 好友点赞数量
	end
	return data;
end

function Proto.parseP_GC_GetMyRedHearts_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETMYREDHEARTS_NTF;
	data.redHearts=Proto.parseVector(entry,Proto.parseString); -- 好友
	return data;
end

function Proto.writeP_CG_AddFriend_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_ADDFRIEND_REQ);
	Proto.writeString(msg,data.friendID); -- 好友ID
end

function Proto.parseP_GC_AddFriend_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_ADDFRIEND_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code==Proto.Error.ERROR_OK) then
		data.newfriend=Proto.parseString(entry); -- 
	end
	return data;
end

function Proto.parseP_GC_AddFriend_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_ADDFRIEND_NTF;
	data.needConfirm=Proto.parseDWORD(entry); -- 是否需要确认
	data.newfriend=Proto.parseString(entry); -- 
	return data;
end

function Proto.writeP_CG_ConfirmAddFriend_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_CONFIRMADDFRIEND_REQ);
	Proto.writeString(msg,data.friendID); -- 好友ID
	Proto.writeDWORD(msg,data.isConfirm); -- 是否确认
end

function Proto.parseP_GC_ConfirmAddFriend_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_CONFIRMADDFRIEND_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	return data;
end

function Proto.writeP_CG_GetFriendDetail_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETFRIENDDETAIL_REQ);
	Proto.writeString(msg,data.friendID); -- 好友ID
end

function Proto.parseP_GC_GetFriendDetail_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETFRIENDDETAIL_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code==Proto.Error.ERROR_OK) then
		data.detail=Proto.parseString(entry); -- 
	end
	return data;
end

function Proto.writeP_CG_UpdateFriendDetail_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_UPDATEFRIENDDETAIL_REQ);
	Proto.writeString(msg,data.friendID); -- 好友ID
	Proto.writeString(msg,data.detail); -- 
end

function Proto.parseP_GC_UpdateFriendDetail_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_UPDATEFRIENDDETAIL_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	return data;
end

function Proto.writeP_CG_RedHeart_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_REDHEART_REQ);
	Proto.writeString(msg,data.friendID); -- 好友ID
end

function Proto.parseP_GC_RedHeart_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_REDHEART_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code==Proto.Error.ERROR_OK) then
		data.friendID=Proto.parseString(entry); -- 
		data.lastRedHeartTime=Proto.parseString(entry); -- 
	end
	return data;
end

function Proto.writeP_CG_DelFriend_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_DELFRIEND_REQ);
	Proto.writeString(msg,data.friendID); -- 好友ID
end

function Proto.parseP_GC_DelFriend_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_DELFRIEND_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	return data;
end

function Proto.writeP_CG_GetRecommendFriend_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETRECOMMENDFRIEND_REQ);
end

function Proto.parseP_GC_GetRecommendFriend_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETRECOMMENDFRIEND_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code==Proto.Error.ERROR_OK) then
		data.recommends=Proto.parseVector(entry,Proto.parseString); -- 
	end
	return data;
end

function Proto.writeP_CG_DisbandAllFriendApply_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_DISBANDALLFRIENDAPPLY_REQ);
end

function Proto.parseP_GC_DisbandAllFriendApply_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_DISBANDALLFRIENDAPPLY_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	return data;
end

function Proto.parseP_GC_FriendFull_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_FRIENDFULL_NTF;
	return data;
end

function Proto.writeP_CG_FBSharePower_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_FBSHAREPOWER_REQ);
	Proto.writeString(msg,data.shareUser); -- 
end

function Proto.parseP_GC_FBSharePower_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_FBSHAREPOWER_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	return data;
end

function Proto.writeP_CG_FBFriendAward_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_FBFRIENDAWARD_REQ);
	Proto.writeDWORD(msg,data.fbFriendID); -- 
end

function Proto.parseP_GC_FBFriendAward_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_FBFRIENDAWARD_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	return data;
end

