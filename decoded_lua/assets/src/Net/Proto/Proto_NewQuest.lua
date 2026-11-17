-- Net.Proto.Proto_NewQuest

function Proto.writeP_CZ_QuestList_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CZ_QUESTLIST_REQ);
end

function Proto.parseP_ZC_QuestList_Ack(entry)
	local data={};
	data.msgID=Proto.Command.ZC_QUESTLIST_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code==Proto.Error.ERROR_OK) then
		data.questNum=Proto.parseDWORD(entry); -- 任务数量
	end
	return data;
end

function Proto.writeP_CZ_CommitQuest_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CZ_COMMITQUEST_REQ);
	Proto.writeDWORD(msg,data.questID); -- 任务ID
end

function Proto.parseP_ZC_CommitQuest_Ack(entry)
	local data={};
	data.msgID=Proto.Command.ZC_COMMITQUEST_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code==Proto.Error.ERROR_OK) then
		data.questID=Proto.parseDWORD(entry); -- 任务ID
		data.awards=Proto.parseVector(entry,Proto.parseString); -- 奖励元素表
	end
	return data;
end

function Proto.parseP_ZC_NewQuest_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.ZC_NEWQUEST_NTF;
	data.questList=Proto.parseVector(entry,Proto.parseQuestData); -- 新任务列表
	return data;
end

function Proto.parseP_ZC_UpdateQuest_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.ZC_UPDATEQUEST_NTF;
	data.quest=Proto.parseQuestData(entry); -- 新任务列表
	return data;
end

function Proto.parseP_ZC_NewDeleteQuest_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.ZC_NEWDELETEQUEST_NTF;
	data.questID=Proto.parseDWORD(entry); -- 任务ID
	return data;
end

function Proto.writeP_CZ_UpdateQuest_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CZ_UPDATEQUEST_REQ);
	Proto.writeQuestData(msg,data.quest); -- 任务
end

function Proto.parseP_ZC_UpdateQuest_Ack(entry)
	local data={};
	data.msgID=Proto.Command.ZC_UPDATEQUEST_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	return data;
end

function Proto.writeP_CG_StepLog_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_STEPLOG_REQ);
	Proto.writeString(msg,data.key); -- 
	Proto.writeString(msg,data.value); -- 
end

function Proto.parseP_GC_StepLog_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_STEPLOG_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	return data;
end

function Proto.writeP_CG_GetDailyQuestStepAward_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETDAILYQUESTSTEPAWARD_REQ);
	Proto.writeDWORD(msg,data.stepIndex); -- 
end

function Proto.parseP_GC_GetDailyQuestStepAward_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETDAILYQUESTSTEPAWARD_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code==Proto.Error.ERROR_OK) then
		data.stepIndex=Proto.parseDWORD(entry); -- 
		data.awards=Proto.parseVector(entry,Proto.parseString); -- 
	end
	return data;
end

