-- Net.Proto.Proto_TreasureBox

function Proto.writeP_CG_GetTreasureBoxData_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETTREASUREBOXDATA_REQ);
end

function Proto.parseP_GC_GetTreasureBoxData_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETTREASUREBOXDATA_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code==Proto.Error.ERROR_OK) then
		data.boxes=Proto.parseString(entry); -- 宝箱数据
	end
	return data;
end

function Proto.writeP_CG_OpenTreasureBox_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_OPENTREASUREBOX_REQ);
	Proto.writeBYTE(msg,data.boxID); -- 宝箱编号0~3
	Proto.writeBYTE(msg,data.bFree); -- 0：收费。 1：免费
end

function Proto.parseP_GC_OpenTreasureBox_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_OPENTREASUREBOX_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code==Proto.Error.ERROR_OK) then
		data.awards=Proto.parseVector(entry,Proto.parseString); -- 奖励
	end
	return data;
end

function Proto.parseP_GC_TreasureBoxNTF_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_TREASUREBOXNTF_NTF;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code==Proto.Error.ERROR_OK) then
		data.boxes=Proto.parseString(entry); -- 宝箱数据
	end
	return data;
end

function Proto.writeP_CG_UnlockTreasureBox_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_UNLOCKTREASUREBOX_REQ);
	Proto.writeBYTE(msg,data.boxID); -- 宝箱编号0~3
end

function Proto.parseP_GC_UnlockTreasureBox_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_UNLOCKTREASUREBOX_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	return data;
end

function Proto.parseP_GC_NewTreasureBox_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_NEWTREASUREBOX_NTF;
	data.boxes=Proto.parseString(entry); -- 
	return data;
end

function Proto.writeP_CG_SelectTreasureBox_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_SELECTTREASUREBOX_REQ);
	Proto.writeBYTE(msg,data.boxID); -- 宝箱编号 0~N
end

function Proto.parseP_GC_SelectTreasureBox_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_SELECTTREASUREBOX_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	return data;
end

