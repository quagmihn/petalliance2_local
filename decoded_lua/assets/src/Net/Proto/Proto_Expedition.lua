-- Net.Proto.Proto_Expedition

function Proto.writeP_CG_GetExpeditionData_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETEXPEDITIONDATA_REQ);
	Proto.writeDWORD(msg,data.type); -- 类型,0当前,1普通难度,2困难难度,3噩梦难度
	Proto.writeVector(msg,data.petList,Proto.writeDWORD); -- 宠物列表
end

function Proto.parseP_GC_GetExpeditionData_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETEXPEDITIONDATA_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.expeditionData=Proto.parseExpeditionData(entry); -- 远征数据
	end
	return data;
end

function Proto.writeP_CG_ExpeditionBattleEnd_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_EXPEDITIONBATTLEEND_REQ);
	Proto.writeDWORD(msg,data.petObjID); -- 战斗宠物ID
	Proto.writeDWORD(msg,data.petHP); -- 战斗宠物血量
	Proto.writeDWORD(msg,data.damage); -- 伤害
	Proto.writeVector(msg,data.quests,Proto.writeDWORD); -- 任务ID
end

function Proto.parseP_GC_ExpeditionBattleEnd_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_EXPEDITIONBATTLEEND_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	return data;
end

function Proto.writeP_CG_GetPointLotteryData_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETPOINTLOTTERYDATA_REQ);
end

function Proto.parseP_GC_GetPointLotteryData_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETPOINTLOTTERYDATA_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.maxCount=Proto.parseDWORD(entry); -- 最大次数
		data.usedCount=Proto.parseDWORD(entry); -- 使用过次数
		data.buyCount=Proto.parseDWORD(entry); -- 已购买次数
		data.maxBuyCount=Proto.parseDWORD(entry); -- 最大购买次数
		data.currentPos=Proto.parseDWORD(entry); -- 当前位置
	end
	return data;
end

function Proto.writeP_CG_RollDice_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_ROLLDICE_REQ);
end

function Proto.parseP_GC_RollDice_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_ROLLDICE_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.stepNumber=Proto.parseDWORD(entry); -- 步数
	end
	return data;
end

function Proto.writeP_CG_BuyRollCount_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_BUYROLLCOUNT_REQ);
end

function Proto.parseP_GC_BuyRollCount_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_BUYROLLCOUNT_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	return data;
end

function Proto.parseP_GC_ExpeditionAward_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_EXPEDITIONAWARD_NTF;
	data.awards=Proto.parseVector(entry,Proto.parseString); -- 奖励信息
	return data;
end

function Proto.parseP_GC_PetDetail_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_PETDETAIL_NTF;
	data.pets=Proto.parseVector(entry,Proto.parseString); -- 宠物列表
	return data;
end

