-- Net.Proto.Proto_Activities

function Proto.writeP_CG_GetActivitiesData_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETACTIVITIESDATA_REQ);
end

function Proto.parseP_GC_GetActivitiesData_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETACTIVITIESDATA_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code==Proto.Error.ERROR_OK) then
		data.data=Proto.parseString(entry); -- json数据
	end
	return data;
end

function Proto.writeP_CG_FetchLoginAwards_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_FETCHLOGINAWARDS_REQ);
	Proto.writeint(msg,data.day); -- 登录第几天的
end

function Proto.parseP_GC_FetchLoginAwards_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_FETCHLOGINAWARDS_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	return data;
end

function Proto.writeP_CG_FetchFirstLoginAwards_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_FETCHFIRSTLOGINAWARDS_REQ);
end

function Proto.parseP_GC_FetchFirstLoginAwards_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_FETCHFIRSTLOGINAWARDS_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	return data;
end

function Proto.writeP_CG_FetchUpgradeAwards_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_FETCHUPGRADEAWARDS_REQ);
	Proto.writeBYTE(msg,data.level); -- 玩家等级
end

function Proto.parseP_GC_FetchUpgradeAwards_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_FETCHUPGRADEAWARDS_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	return data;
end

function Proto.writeP_CG_FetchDailyActionValue_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_FETCHDAILYACTIONVALUE_REQ);
end

function Proto.parseP_GC_FetchDailyActionValue_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_FETCHDAILYACTIONVALUE_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	return data;
end

function Proto.writeP_CG_FetchRechargeAwards_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_FETCHRECHARGEAWARDS_REQ);
	Proto.writeDWORD(msg,data.aID); -- 活动ID
	Proto.writeDWORD(msg,data.mCash); -- 充值额度
end

function Proto.parseP_GC_FetchRechargeAwards_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_FETCHRECHARGEAWARDS_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	return data;
end

function Proto.writeP_CG_FetchConsumeAwards_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_FETCHCONSUMEAWARDS_REQ);
	Proto.writeDWORD(msg,data.aID); -- 活动ID
	Proto.writeDWORD(msg,data.mCash); -- 消费额度
end

function Proto.parseP_GC_FetchConsumeAwards_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_FETCHCONSUMEAWARDS_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	return data;
end

function Proto.writeP_CG_BuyGrowthFund_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_BUYGROWTHFUND_REQ);
	Proto.writeDWORD(msg,data.aID); -- 活动ID
end

function Proto.parseP_GC_BuyGrowthFund_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_BUYGROWTHFUND_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	return data;
end

function Proto.writeP_CG_FetchGrowthFundAwards_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_FETCHGROWTHFUNDAWARDS_REQ);
	Proto.writeBYTE(msg,data.level); -- 玩家等级
end

function Proto.parseP_GC_FetchGrowthFundAwards_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_FETCHGROWTHFUNDAWARDS_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	return data;
end

function Proto.writeP_CG_FetchSpokesmanGuessAwards_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_FETCHSPOKESMANGUESSAWARDS_REQ);
	Proto.writeDWORD(msg,data.aID); -- 活动ID
	Proto.writeBYTE(msg,data.awardIndex); -- 第几个奖项(0~N)
end

function Proto.parseP_GC_FetchSpokesmanGuessAwards_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_FETCHSPOKESMANGUESSAWARDS_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	return data;
end

function Proto.writeP_CG_TimeLimitCapsuleEgg_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_TIMELIMITCAPSULEEGG_REQ);
	Proto.writeDWORD(msg,data.aID); -- 活动ID
	Proto.writeint(msg,data.atype); -- 宠物1，技能2
end

function Proto.parseP_GC_TimeLimitCapsuleEgg_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_TIMELIMITCAPSULEEGG_ACK;
	data.code=Proto.parseWORD(entry); -- 
	if (data.code==Proto.Error.ERROR_OK) then
		data.awardVecStr=Proto.parseVector(entry,Proto.parseString); -- 奖励元素表
	end
	return data;
end

function Proto.writeP_CG_GetWorldOpenTime_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETWORLDOPENTIME_REQ);
end

function Proto.parseP_GC_GetWorldOpenTime_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETWORLDOPENTIME_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code==Proto.Error.ERROR_OK) then
		data.openTime=Proto.parseQWORD(entry); -- 开服时间
	end
	return data;
end

function Proto.writeP_CG_FetchPVPArenaGradePointAwards_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_FETCHPVPARENAGRADEPOINTAWARDS_REQ);
	Proto.writeDWORD(msg,data.aID); -- 活动ID
end

function Proto.parseP_GC_FetchPVPArenaGradePointAwards_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_FETCHPVPARENAGRADEPOINTAWARDS_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	return data;
end

function Proto.writeP_CG_FetchTeamDungeonAwards_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_FETCHTEAMDUNGEONAWARDS_REQ);
	Proto.writeDWORD(msg,data.aID); -- 活动ID
end

function Proto.parseP_GC_FetchTeamDungeonAwards_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_FETCHTEAMDUNGEONAWARDS_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	return data;
end

function Proto.writeP_CG_FetchWorldBossAwards_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_FETCHWORLDBOSSAWARDS_REQ);
	Proto.writeDWORD(msg,data.aID); -- 活动ID
end

function Proto.parseP_GC_FetchWorldBossAwards_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_FETCHWORLDBOSSAWARDS_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	return data;
end

function Proto.writeP_CG_GetGMActivities_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETGMACTIVITIES_REQ);
	Proto.writeDWORD(msg,data.aID); -- 活动ID
end

function Proto.parseP_GC_GetGMActivities_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETGMACTIVITIES_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	data.count=Proto.parseDWORD(entry); -- 活动数量
	return data;
end

function Proto.parseP_GC_GMActivitiesInfo_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_GMACTIVITIESINFO_NTF;
	data.activities=Proto.parseVector(entry,Proto.parseString); -- 活动
	return data;
end

function Proto.writeP_CG_FetchContinueLoginAwards_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_FETCHCONTINUELOGINAWARDS_REQ);
	Proto.writeDWORD(msg,data.aID); -- 登录第几天的
end

function Proto.parseP_GC_FetchContinueLoginAwards_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_FETCHCONTINUELOGINAWARDS_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	return data;
end

function Proto.writeP_CG_FetchDailyCountActivityAward_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_FETCHDAILYCOUNTACTIVITYAWARD_REQ);
	Proto.writeDWORD(msg,data.aID); -- 活动ID
	Proto.writeDWORD(msg,data.count); -- 计数
end

function Proto.parseP_GC_FetchDailyCountActivityAward_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_FETCHDAILYCOUNTACTIVITYAWARD_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	return data;
end

function Proto.writeP_CG_GetPosterBoardInfo_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETPOSTERBOARDINFO_REQ);
end

function Proto.parseP_GC_GetPosterBoardInfo_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETPOSTERBOARDINFO_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if (data.code==Proto.Error.ERROR_OK) then
		data.width=Proto.parseDWORD(entry); -- 整体宽度
		data.length=Proto.parseDWORD(entry); -- 整体长度
		data.params=Proto.parseString(entry); -- 参数
	end
	return data;
end

