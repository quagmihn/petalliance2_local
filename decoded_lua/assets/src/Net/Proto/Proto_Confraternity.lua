-- Net.Proto.Proto_Confraternity

function Proto.writeP_CG_Family_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_FAMILY_REQ);
	Proto.writeString(msg,data.cmd); -- 命令
	Proto.writeString(msg,data.concent); -- 内容
end

function Proto.parseP_GC_Family_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_FAMILY_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code==Proto.Error.ERROR_OK) then
		data.cmd=Proto.parseString(entry); -- 命令
		data.ackConcent=Proto.parseString(entry); -- 内容
	end
	return data;
end

function Proto.parseP_GC_Family_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_FAMILY_NTF;
	data.cmd=Proto.parseString(entry); -- 命令
	data.ackConcent=Proto.parseString(entry); -- 内容
	return data;
end

function Proto.writeP_CG_GetDungeon_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETDUNGEON_REQ);
	Proto.writeWORD(msg,data.type); -- 类型1家族副本,2组队副本
end

function Proto.parseP_GC_GetDungeon_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETDUNGEON_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.cellNum=Proto.parseDWORD(entry); -- 副本格子数
		data.membersNum=Proto.parseDWORD(entry); -- 成员个数
		data.buffNum=Proto.parseDWORD(entry); -- buff个数
		data.battleNum=Proto.parseDWORD(entry); -- 战斗个数
		data.advID=Proto.parseDWORD(entry); -- 副本ID
		data.maxKilled=Proto.parseDWORD(entry); -- 最大击杀怪物个数
	end
	return data;
end

function Proto.parseP_GC_CurrentFloorAllMebers_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_CURRENTFLOORALLMEBERS_NTF;
	data.membersList=Proto.parseVector(entry,Proto.parseString); -- 
	return data;
end

function Proto.parseP_GC_AllBuff_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_ALLBUFF_NTF;
	data.buffList=Proto.parseVector(entry,Proto.parseString); -- 
	return data;
end

function Proto.parseP_GC_AllBattle_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_ALLBATTLE_NTF;
	data.battleList=Proto.parseVector(entry,Proto.parseString); -- 
	return data;
end

function Proto.parseP_GC_DungeonCells_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_DUNGEONCELLS_NTF;
	data.cells=Proto.parseVector(entry,Proto.parseString); -- 格子信息
	return data;
end

function Proto.writeP_CG_DungeonMoveCell_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_DUNGEONMOVECELL_REQ);
	Proto.writeDWORD(msg,data.x); -- x
	Proto.writeDWORD(msg,data.y); -- y
	Proto.writeString(msg,data.path); -- 路径
	Proto.writeWORD(msg,data.type); -- 副本类型1家族副本,2组队副本
end

function Proto.parseP_GC_DungeonMoveCell_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_DUNGEONMOVECELL_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	return data;
end

function Proto.writeP_CG_FireDungeonCell_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_FIREDUNGEONCELL_REQ);
	Proto.writeDWORD(msg,data.x); -- x
	Proto.writeDWORD(msg,data.y); -- y
	Proto.writeWORD(msg,data.type); -- 副本类型1家族副本,2组队副本
end

function Proto.parseP_GC_FireDungeonCell_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_FIREDUNGEONCELL_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	return data;
end

function Proto.writeP_CG_DungeonChangeFloor_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_DUNGEONCHANGEFLOOR_REQ);
	Proto.writeDWORD(msg,data.type); -- 0回到上一层,1去下一层
	Proto.writeWORD(msg,data.mapType); -- 副本类型1家族副本,2组队副本
end

function Proto.parseP_GC_DungeonChangeFloor_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_DUNGEONCHANGEFLOOR_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	return data;
end

function Proto.writeP_CG_FamilyDisplayCell_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_FAMILYDISPLAYCELL_REQ);
	Proto.writeDWORD(msg,data.x); -- x
	Proto.writeDWORD(msg,data.y); -- y
end

function Proto.parseP_GC_FamilyDisplayCell_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_FAMILYDISPLAYCELL_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	return data;
end

function Proto.parseP_GC_FamilyRandomChestAward_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_FAMILYRANDOMCHESTAWARD_NTF;
	data.contribute=Proto.parseDWORD(entry); -- 贡献度
	data.awardContent=Proto.parseString(entry); -- 奖励内容
	return data;
end

function Proto.parseP_GC_FamilyBattleInfo_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_FAMILYBATTLEINFO_NTF;
	data.monsters=Proto.parseVector(entry,Proto.parseString); -- 怪物信息列表
	return data;
end

function Proto.writeP_CG_DungeonBattleEnd_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_DUNGEONBATTLEEND_REQ);
	Proto.writeWORD(msg,data.isWin); -- 0 败 1 胜 2平
	Proto.writeDWORD(msg,data.battleID); -- 战斗ID
	Proto.writeDWORD(msg,data.monsterHp); -- 怪物剩余血量
	Proto.writeDWORD(msg,data.dps); -- 伤害统计
	Proto.writeDWORD(msg,data.x); -- x
	Proto.writeDWORD(msg,data.y); -- y
	Proto.writeWORD(msg,data.type); -- 副本类型1家族副本,2组队副本
end

function Proto.parseP_GC_DungeonBattleEnd_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_DUNGEONBATTLEEND_ACK;
	data.code=Proto.parseWORD(entry); -- code
	return data;
end

function Proto.parseP_GC_FamilyKillBoss_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_FAMILYKILLBOSS_NTF;
	data.x=Proto.parseDWORD(entry); -- x
	data.y=Proto.parseDWORD(entry); -- y
	return data;
end

function Proto.parseP_GC_CharacterMoveCell_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_CHARACTERMOVECELL_NTF;
	data.charID=Proto.parseDWORD(entry); -- 玩家ID 
	data.x=Proto.parseDWORD(entry); -- x
	data.y=Proto.parseDWORD(entry); -- y
	data.gender=Proto.parseDWORD(entry); -- 性别
	data.level=Proto.parseDWORD(entry); -- 等级
	data.name=Proto.parseString(entry); -- 姓名
	data.floor=Proto.parseDWORD(entry); -- 楼层
	data.fashions=Proto.parseVector(entry,Proto.parseDWORD); -- 时装
	data.path=Proto.parseString(entry); -- 路径
	data.state=Proto.parseDWORD(entry); -- 状态
	return data;
end

function Proto.parseP_GC_AddBuff_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_ADDBUFF_NTF;
	data.buffID=Proto.parseDWORD(entry); -- buffID
	return data;
end

function Proto.parseP_GC_OpenChest_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_OPENCHEST_NTF;
	data.lockedTime=Proto.parseDWORD(entry); -- 锁定时间
	data.x=Proto.parseDWORD(entry); -- x
	data.y=Proto.parseDWORD(entry); -- y
	return data;
end

function Proto.parseP_GC_CleanCell_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_CLEANCELL_NTF;
	data.x=Proto.parseDWORD(entry); -- x
	data.y=Proto.parseDWORD(entry); -- y
	return data;
end

function Proto.parseP_GC_BattleStartLocked_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_BATTLESTARTLOCKED_NTF;
	data.x=Proto.parseDWORD(entry); -- x
	data.y=Proto.parseDWORD(entry); -- y
	data.isLocked=Proto.parseDWORD(entry); -- 是否锁定
	data.lockedTime=Proto.parseDWORD(entry); -- 锁定时间
	return data;
end

function Proto.parseP_GC_LeaveFloor_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_LEAVEFLOOR_NTF;
	data.charID=Proto.parseDWORD(entry); -- 玩家ID
	data.floor=Proto.parseDWORD(entry); -- 楼层
	return data;
end

function Proto.parseP_GC_DisplayCell_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_DISPLAYCELL_NTF;
	data.x=Proto.parseDWORD(entry); -- x
	data.y=Proto.parseDWORD(entry); -- y
	return data;
end

function Proto.writeP_CG_GetDungeonCreateTime_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETDUNGEONCREATETIME_REQ);
end

function Proto.parseP_GC_GetDungeonCreateTime_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETDUNGEONCREATETIME_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.createTime=Proto.parseDWORD(entry); -- 创建时间
	end
	return data;
end

function Proto.writeP_CG_ResetDungeon_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_RESETDUNGEON_REQ);
end

function Proto.parseP_GC_ResetDungeon_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_RESETDUNGEON_ACK;
	data.code=Proto.parseWORD(entry); --  返回码
	return data;
end

function Proto.writeP_CG_GetDungeonAward_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETDUNGEONAWARD_REQ);
end

function Proto.parseP_GC_GetDungeonAward_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETDUNGEONAWARD_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.awardContent=Proto.parseString(entry); -- 奖励内容
	end
	return data;
end

function Proto.writeP_CG_GetDungeonAwardInfo_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETDUNGEONAWARDINFO_REQ);
end

function Proto.parseP_GC_GetDungeonAwardInfo_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETDUNGEONAWARDINFO_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	data.awardFloor=Proto.parseDWORD(entry); -- 奖励层数
	data.canTakeAward=Proto.parseDWORD(entry); -- 0不能领奖励，1能领奖励
	return data;
end

function Proto.writeP_CG_GetDungeonLog_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETDUNGEONLOG_REQ);
end

function Proto.parseP_GC_GetDungeonLog_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETDUNGEONLOG_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.logList=Proto.parseVector(entry,Proto.parseDungeonLogData); -- 日志列表
	end
	return data;
end

function Proto.writeP_CG_GetFamilyShopData_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETFAMILYSHOPDATA_REQ);
end

function Proto.parseP_GC_GetFamilyShopData_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETFAMILYSHOPDATA_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	if ( data.code ==Proto.Error.ERROR_OK) then
		data.reflashTime=Proto.parseDWORD(entry); -- 刷新时间
		data.purchased=Proto.parseVector(entry,Proto.parseDWORD); -- 已购买商品
		data.levelReflashTime=Proto.parseDWORD(entry); -- 等级刷新时间
	end
	return data;
end

function Proto.writeP_CG_BuyFamilyShopGoods_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_BUYFAMILYSHOPGOODS_REQ);
	Proto.writeDWORD(msg,data.goodsID); -- 商品ID
end

function Proto.parseP_GC_BuyFamilyShopGoods_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_BUYFAMILYSHOPGOODS_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	return data;
end

function Proto.writeP_CG_RefalshFamilyShop_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_REFALSHFAMILYSHOP_REQ);
end

function Proto.parseP_GC_RefalshFamilyShop_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_REFALSHFAMILYSHOP_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	return data;
end

function Proto.writeP_CG_LevelReflashFamilyShop_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_LEVELREFLASHFAMILYSHOP_REQ);
end

function Proto.parseP_GC_LevelReflashFamilyShop_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_LEVELREFLASHFAMILYSHOP_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	return data;
end

