-- Net.Proto.Proto_LostTower

function Proto.writeP_CG_GetLostTowerData_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETLOSTTOWERDATA_REQ);
end

function Proto.parseP_GC_GetLostTowerData_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETLOSTTOWERDATA_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code==Proto.Error.ERROR_OK) then
		data.lostTowerData=Proto.parseCharacterLostTowerData(entry); -- 玩家迷失之塔数据
	end
	return data;
end

function Proto.writeP_CG_resetData_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_RESETDATA_REQ);
end

function Proto.parseP_GC_resetData_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_RESETDATA_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	return data;
end

function Proto.writeP_CG_moveNewCell_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_MOVENEWCELL_REQ);
	Proto.writeDWORD(msg,data.x); -- x坐标
	Proto.writeDWORD(msg,data.y); -- y坐标
end

function Proto.parseP_GC_moveNewCell_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_MOVENEWCELL_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	return data;
end

function Proto.writeP_CG_ChangeFloor_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_CHANGEFLOOR_REQ);
	Proto.writeDWORD(msg,data.floor); -- 0表示上一层，1表示下一次层
end

function Proto.parseP_GC_ChangeFloor_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_CHANGEFLOOR_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	return data;
end

function Proto.writeP_CG_fireEventCell_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_FIREEVENTCELL_REQ);
	Proto.writeDWORD(msg,data.x); -- 坐标x
	Proto.writeDWORD(msg,data.y); -- 坐标y
end

function Proto.writeP_CG_MoneyOpenChest_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_MONEYOPENCHEST_REQ);
	Proto.writeDWORD(msg,data.x); -- 坐标x
	Proto.writeDWORD(msg,data.y); -- 坐标y
end

function Proto.parseP_GC_MoneyOpenChest_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_MONEYOPENCHEST_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	return data;
end

function Proto.parseP_GC_fireEventCell_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_FIREEVENTCELL_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	return data;
end

function Proto.writeP_CG_changeReadyPet_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_CHANGEREADYPET_REQ);
	Proto.writeVector(msg,data.activityArmysList,Proto.writeDWORD); -- 上阵宠物列表
	Proto.writeVector(msg,data.activityHelpArmysList,Proto.writeDWORD); -- 援助
end

function Proto.parseP_GC_changeReadyPet_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_CHANGEREADYPET_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	return data;
end

function Proto.parseP_GC_EventAward_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_EVENTAWARD_NTF;
	data.awards=Proto.parseVector(entry,Proto.parseString); -- 奖励信息
	return data;
end

function Proto.parseP_GC_RandomEvent_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_RANDOMEVENT_NTF;
	data.type=Proto.parseDWORD(entry); -- 事件类型
	data.eventID=Proto.parseDWORD(entry); -- 表现ID
	return data;
end

function Proto.parseP_GC_LostTowerPointChange_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_LOSTTOWERPOINTCHANGE_NTF;
	data.points=Proto.parseDWORD(entry); -- 变化后总数
	return data;
end

function Proto.parseP_GC_LostTowerWeekPointChange_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_LOSTTOWERWEEKPOINTCHANGE_NTF;
	data.points=Proto.parseDWORD(entry); -- 变化后总数
	return data;
end

function Proto.writeP_CG_TransferFloor_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_TRANSFERFLOOR_REQ);
	Proto.writeDWORD(msg,data.floor); -- 层数
end

function Proto.parseP_GC_TransferFloor_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_TRANSFERFLOOR_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	return data;
end

function Proto.writeP_CG_RecoverState_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_RECOVERSTATE_REQ);
end

function Proto.parseP_GC_RecoverState_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_RECOVERSTATE_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	return data;
end

function Proto.parseP_GC_enemyPets_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_ENEMYPETS_NTF;
	data.enemys=Proto.parseVector(entry,Proto.parseString); -- 地方宠物信息
	return data;
end

function Proto.writeP_CG_MoveObstacle_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_MOVEOBSTACLE_REQ);
	Proto.writePOS(msg,data.fromPos); -- 移动障碍物坐标
	Proto.writePOS(msg,data.toPos); -- 目标坐标
end

function Proto.parseP_GC_MoveObstacle_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_MOVEOBSTACLE_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	return data;
end

function Proto.writeP_CG_onTrap_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_ONTRAP_REQ);
	Proto.writePOS(msg,data.position); -- 位置
end

function Proto.parseP_GC_onTrap_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_ONTRAP_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.pets=Proto.parseVector(entry,Proto.parseLostTowerPet); -- 宠物列表
	end
	return data;
end

function Proto.writeP_CG_LostTowerPVPBattleEnd_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_LOSTTOWERPVPBATTLEEND_REQ);
	Proto.writeWORD(msg,data.isWin); -- 0 败 1 胜 2平
	Proto.writeVector(msg,data.battleDetails,Proto.writeString); -- 战斗信息
end

function Proto.parseP_GC_LostTowerPVPBattleEnd_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_LOSTTOWERPVPBATTLEEND_ACK;
	data.code=Proto.parseWORD(entry); -- 
	return data;
end

function Proto.writeP_CG_QueryFloorRank_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_QUERYFLOORRANK_REQ);
end

function Proto.parseP_GC_QueryFloorRank_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_QUERYFLOORRANK_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.rankInfo=Proto.parseString(entry); -- 排行信息
	end
	return data;
end

function Proto.writeP_CG_QueryPointRank_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_QUERYPOINTRANK_REQ);
end

function Proto.parseP_GC_QueryPointRank_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_QUERYPOINTRANK_ACK;
	data.code=Proto.parseWORD(entry); --  返回码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.rankInfo=Proto.parseString(entry); -- 排行信息
	end
	return data;
end

function Proto.writeP_CG_EnterTransferDoor_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_ENTERTRANSFERDOOR_REQ);
	Proto.writeDWORD(msg,data.x); -- x坐标
	Proto.writeDWORD(msg,data.y); -- y坐标
end

function Proto.parseP_GC_EnterTransferDoor_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_ENTERTRANSFERDOOR_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	return data;
end

function Proto.parseP_GC_TransferCell_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_TRANSFERCELL_NTF;
	data.x=Proto.parseDWORD(entry); -- x坐标
	data.y=Proto.parseDWORD(entry); -- y坐标
	return data;
end

function Proto.writeP_CG_UseLostTowerItem_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_USELOSTTOWERITEM_REQ);
	Proto.writeDWORD(msg,data.itemID); -- 道具ID
end

function Proto.parseP_GC_UseLostTowerItem_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_USELOSTTOWERITEM_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	return data;
end

function Proto.parseP_GC_LostTowerItemUpdate_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_LOSTTOWERITEMUPDATE_NTF;
	data.items=Proto.parseVector(entry,Proto.parseDWORD); -- 道具列表
	return data;
end

function Proto.parseP_GC_LostTowerStepNumberUpdate_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_LOSTTOWERSTEPNUMBERUPDATE_NTF;
	data.setpNumber=Proto.parseDWORD(entry); -- 步数
	data.lastUpdateTime=Proto.parseDWORD(entry); -- 最后恢复时间
	return data;
end

function Proto.writeP_CG_RecoverStepNumber_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_RECOVERSTEPNUMBER_REQ);
end

function Proto.parseP_GC_RecoverStepNumber_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_RECOVERSTEPNUMBER_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	return data;
end

function Proto.parseP_GC_AddLostTowerPets_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_ADDLOSTTOWERPETS_NTF;
	data.objID=Proto.parseDWORD(entry); -- 宠物objID
	data.hp=Proto.parseDWORD(entry); -- 血量
	return data;
end

function Proto.parseP_GC_LostTowerEvents_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_LOSTTOWEREVENTS_NTF;
	data.events=Proto.parseVector(entry,Proto.parseString); -- 事件
	return data;
end

