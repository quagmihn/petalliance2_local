-- Net.Proto.Proto_Vip

function Proto.writeP_CG_GetVipAward_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETVIPAWARD_REQ);
	Proto.writeDWORD(msg,data.vipID); -- vipID
	Proto.writeVector(msg,data.awardID,Proto.writeDWORD); -- awardID
end

function Proto.parseP_GC_GetVipAward_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETVIPAWARD_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	return data;
end

function Proto.writeP_CG_VipAwardInfo_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_VIPAWARDINFO_REQ);
end

function Proto.parseP_GC_VipAwardInfo_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_VIPAWARDINFO_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	data.vipAwardsInfo=Proto.parseVector(entry,Proto.parseDWORD); -- VIP已领取奖励
	return data;
end

function Proto.writeP_CG_RechargeTestCmd_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_RECHARGETESTCMD_REQ);
	Proto.writeDWORD(msg,data.payID); -- 充值ID
	Proto.writeString(msg,data.appID); -- appID
end

function Proto.parseP_GC_RechargeTestCmd_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_RECHARGETESTCMD_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	return data;
end

