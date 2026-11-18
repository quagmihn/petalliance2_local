-- Net.Proto.Proto_Pet

Proto.PTT_MOVE		= 0						-- []宠物移动,可以在未执行完本任务的条件下被其它任务替换
Proto.PTT_FIXMOVE	= Proto.PTT_MOVE + 1	-- []宠物固定路线移动

function Proto.parsePetTask_BODY_Move(entry)
	local data={};
	data.target=Proto.parsePOS2D(entry); -- 移动目标
	return data;
end

function Proto.writePetTask_BODY_Move(msg,data)
	Proto.writePOS2D(msg,data.target); -- 移动目标
end

function Proto.parsePetTask_BODY_FixMove(entry)
	local data={};
	data.target=Proto.parsePOS2D(entry); -- 移动目标
	return data;
end

function Proto.writePetTask_BODY_FixMove(msg,data)
	Proto.writePOS2D(msg,data.target); -- 移动目标
end

function Proto.parsePetTask(entry)
	local data={};
	data.type=Proto.parseBYTE(entry); -- 任务类型,PetTaskType
	data.body={}; -- 
	if (data.type==Proto.PTT_MOVE) then
		data.body.move=Proto.parsePetTask_BODY_Move(entry); -- 移动任务
	end
	if (data.type==Proto.PTT_FIXMOVE) then
		data.body.fixMove=Proto.parsePetTask_BODY_FixMove(entry); -- 因定移动任务
	end
	return data;
end

function Proto.writePetTask(msg,data)
	Proto.writeBYTE(msg,data.type); -- 任务类型,PetTaskType
	if (data.type==Proto.PTT_MOVE) then
		Proto.writePetTask_BODY_Move(msg,data.body.move); -- 移动任务
	end
	if (data.type==Proto.PTT_FIXMOVE) then
		Proto.writePetTask_BODY_FixMove(msg,data.body.fixMove); -- 因定移动任务
	end
end

function Proto.parseResolveSkillInfo(entry)
	local data={};
	data.SkillBookID=Proto.parseDWORD(entry); -- 技能书ID
	data.number=Proto.parseDWORD(entry); -- 技能书数量
	return data;
end

function Proto.writeResolveSkillInfo(msg,data)
	Proto.writeDWORD(msg,data.SkillBookID); -- 技能书ID
	Proto.writeDWORD(msg,data.number); -- 技能书数量
end

function Proto.parseCapsuleEggTypeInfo(entry)
	local data={};
	data.timeLast=Proto.parseString(entry); -- 上次扭蛋时间
	data.times=Proto.parseWORD(entry); -- 已用免费次数
	data.addValue=Proto.parseDWORD(entry); -- 附加值(心愿之力)
	data.bFirstEgg=Proto.parseWORD(entry); -- 是否首抽
	data.bFirstTenEgg=Proto.parseWORD(entry); -- 是否首次十连
	data.tenTimesIndex=Proto.parseWORD(entry); -- 十次必出之第几次
	return data;
end

function Proto.writeCapsuleEggTypeInfo(msg,data)
	Proto.writeString(msg,data.timeLast); -- 上次扭蛋时间
	Proto.writeWORD(msg,data.times); -- 已用免费次数
	Proto.writeDWORD(msg,data.addValue); -- 附加值(心愿之力)
	Proto.writeWORD(msg,data.bFirstEgg); -- 是否首抽
	Proto.writeWORD(msg,data.bFirstTenEgg); -- 是否首次十连
	Proto.writeWORD(msg,data.tenTimesIndex); -- 十次必出之第几次
end

function Proto.parseCapsuleEggAllInfo(entry)
	local data={};
	data.CapsuleEggTypeInfoVec=Proto.parseVector(entry,Proto.parseCapsuleEggTypeInfo); -- 扭蛋类型结构信息的容器
	return data;
end

function Proto.writeCapsuleEggAllInfo(msg,data)
	Proto.writeVector(msg,data.CapsuleEggTypeInfoVec,Proto.writeCapsuleEggTypeInfo); -- 扭蛋类型结构信息的容器
end

function Proto.parseCapsuleEggTimesAndCD(entry)
	local data={};
	data.times=Proto.parseWORD(entry); -- 免费次数使用值
	data.timeLast=Proto.parseQWORD(entry); -- 上次使用时间
	return data;
end

function Proto.writeCapsuleEggTimesAndCD(msg,data)
	Proto.writeWORD(msg,data.times); -- 免费次数使用值
	Proto.writeQWORD(msg,data.timeLast); -- 上次使用时间
end

function Proto.parsePetArmyInfo(entry)
	local data={};
	data.armyIndex=Proto.parseDWORD(entry); -- 队伍索引
	data.armyMembers=Proto.parseVector(entry,Proto.parseDWORD); -- 队伍成员数组
	data.helpArmyMembers=Proto.parseVector(entry,Proto.parseDWORD); -- 队伍成员数组
	return data;
end

function Proto.writePetArmyInfo(msg,data)
	Proto.writeDWORD(msg,data.armyIndex); -- 队伍索引
	Proto.writeVector(msg,data.armyMembers,Proto.writeDWORD); -- 队伍成员数组
	Proto.writeVector(msg,data.helpArmyMembers,Proto.writeDWORD); -- 队伍成员数组
end

function Proto.writeP_CG_QueryPokemons_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_QUERYPOKEMONS_REQ);
	Proto.writeQWORD(msg,data.characterID); -- 角色ID
	Proto.writeDWORD(msg,data.startIndex); -- 开始索引
	Proto.writeDWORD(msg,data.endIndex); -- 结束索引
end

function Proto.parseP_GC_QueryPokemons_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_QUERYPOKEMONS_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.characterID=Proto.parseQWORD(entry); -- 角色ID
		data.startIndex=Proto.parseDWORD(entry); -- 开始索引
		data.endIndex=Proto.parseDWORD(entry); -- 结束索引
		data.activePets=Proto.parseVector(entry,Proto.parseString); -- 战斗宠物列表
		data.unactivePets=Proto.parseVector(entry,Proto.parseString); -- 未战斗宠物列表
		data.unactivePetNum=Proto.parseDWORD(entry); -- 未战斗宠物数量
		data.activeHelperPets=Proto.parseVector(entry,Proto.parseString); -- 战斗宠物列表
	end
	return data;
end

function Proto.parseP_GC_UpdatePokemon_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_UPDATEPOKEMON_NTF;
	data.objID=Proto.parseQWORD(entry); -- 
	data.pet=Proto.parseString(entry); -- 
	return data;
end

function Proto.parseP_GC_DelPokemon_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_DELPOKEMON_NTF;
	data.objID=Proto.parseQWORD(entry); -- 
	return data;
end

function Proto.parseP_GC_UpdateActivityPokemons_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_UPDATEACTIVITYPOKEMONS_NTF;
	data.activePets=Proto.parseVector(entry,Proto.parseString); -- 战斗宠物列表
	data.activeHelperPets=Proto.parseVector(entry,Proto.parseString); -- 战斗宠物列表
	return data;
end

function Proto.writeP_CM_LoadPet_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CM_LOADPET_REQ);
end

function Proto.parseP_MC_LoadPet_Ack(entry)
	local data={};
	data.msgID=Proto.Command.MC_LOADPET_ACK;
	data.pets=Proto.parseVector(entry,Proto.parsePetID); -- 宠物列表
	return data;
end

function Proto.writeP_CZ_PutPetInBag_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CZ_PUTPETINBAG_REQ);
	Proto.writePetID(msg,data.petid); -- 宠物ID
end

function Proto.parseP_ZC_PutPetInBag_Ack(entry)
	local data={};
	data.msgID=Proto.Command.ZC_PUTPETINBAG_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	return data;
end

function Proto.parseP_ZC_BeginEnclosePet_Brd(entry)
	local data={};
	data.msgID=Proto.Command.ZC_BEGINENCLOSEPET_BRD;
	data.master=Proto.parseRoleHandle(entry); -- 宠物主人句柄
	return data;
end

function Proto.parseP_ZC_EndEnclosePet_Brd(entry)
	local data={};
	data.msgID=Proto.Command.ZC_ENDENCLOSEPET_BRD;
	data.master=Proto.parseRoleHandle(entry); -- 宠物主人句柄
	return data;
end

function Proto.parseP_ZC_PetEnclosed_Brd(entry)
	local data={};
	data.msgID=Proto.Command.ZC_PETENCLOSED_BRD;
	data.pet=Proto.parseRoleHandle(entry); -- 被收宠物句柄
	return data;
end

function Proto.parseP_ZC_InBagPetOrder_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.ZC_INBAGPETORDER_NTF;
	data.petOrders=Proto.parseVector(entry,Proto.parseInBagPetOrder); -- 宠物袋顺序
	return data;
end

function Proto.writeP_CZ_LoadPetBag_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CZ_LOADPETBAG_REQ);
	Proto.writePetID(msg,data.petID); -- 宠物ID
end

function Proto.parseP_ZC_LoadPetBag_Ack(entry)
	local data={};
	data.msgID=Proto.Command.ZC_LOADPETBAG_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.petInfo=Proto.parsePetInfo(entry); -- 宠物描述
	end
	return data;
end

function Proto.parseP_ZC_LoadPetBag_Brd(entry)
	local data={};
	data.msgID=Proto.Command.ZC_LOADPETBAG_BRD;
	data.master=Proto.parseRoleHandle(entry); -- 宠物主人句柄
	data.info=Proto.parsePetBriefInfo(entry); -- 袋中宠物信息
	return data;
end

function Proto.writeP_CZ_FreePet_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CZ_FREEPET_REQ);
	Proto.writeDWORD(msg,data.petID); -- 宠物ID
end

function Proto.parseP_ZC_FreePet_Ack(entry)
	local data={};
	data.msgID=Proto.Command.ZC_FREEPET_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.petID=Proto.parseDWORD(entry); -- 宠物ID
	end
	return data;
end

function Proto.parseP_ZC_FreePet_Brd(entry)
	local data={};
	data.msgID=Proto.Command.ZC_FREEPET_BRD;
	data.master=Proto.parseRoleHandle(entry); -- 宠物主人句柄
	return data;
end

function Proto.writeP_CM_QueryPetInfo_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CM_QUERYPETINFO_REQ);
	Proto.writePetID(msg,data.petid); -- 宠物ID
end

function Proto.parseP_MC_QueryPetInfo_Ack(entry)
	local data={};
	data.msgID=Proto.Command.MC_QUERYPETINFO_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code==Proto.Error.ERROR_OK) then
		data.info=Proto.parsePetInfo	(entry); -- 宠物信息
	end
	return data;
end

function Proto.writeP_CM_QueryPetOwner_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CM_QUERYPETOWNER_REQ);
	Proto.writeVector(msg,data.petid,Proto.writePetID); -- 宠物ID
end

function Proto.parseP_MC_QueryPetOwner_Ack(entry)
	local data={};
	data.msgID=Proto.Command.MC_QUERYPETOWNER_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code==Proto.Error.ERROR_OK) then
		data.petids=Proto.parseVector(entry,Proto.parsePetID); -- 宠物id
		data.info=Proto.parseVector(entry,Proto.parseCharBriefInfo); -- 主人简要信息
	end
	return data;
end

function Proto.parseP_MC_ActiveModeShifted_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.MC_ACTIVEMODESHIFTED_NTF;
	data.petid=Proto.parsePetID(entry); -- 宠物ID
	data.mode=Proto.parseBYTE(entry); -- AI模式(AIMode)
	return data;
end

function Proto.parseP_ZC_CreatePet_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.ZC_CREATEPET_NTF;
	data.petID=Proto.parsePetID(entry); -- 宠物ID
	data.isInBag=Proto.parseBYTE(entry); -- 是否在宠物袋中
	return data;
end

function Proto.writeP_CZ_RenameBagPet_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CZ_RENAMEBAGPET_REQ);
	Proto.writeDWORD(msg,data.petID); -- 宠物ID
	Proto.writeLifeNick(msg,data.name); -- 宠物昵称
end

function Proto.parseP_ZC_RenameBagPet_Ack(entry)
	local data={};
	data.msgID=Proto.Command.ZC_RENAMEBAGPET_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.petID=Proto.parseDWORD(entry); -- 宠物ID
		data.name=Proto.parseLifeNick(entry); -- 宠物昵称
	end
	return data;
end

function Proto.parseP_ZC_RenameBagPet_Brd(entry)
	local data={};
	data.msgID=Proto.Command.ZC_RENAMEBAGPET_BRD;
	data.master=Proto.parseRoleHandle(entry); -- 宠物主人句柄
	data.name=Proto.parseLifeNick(entry); -- 宠物昵称
	return data;
end

function Proto.writeP_CM_LoadInWarehousePet_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CM_LOADINWAREHOUSEPET_REQ);
end

function Proto.parseP_MC_LoadInWarehousePet_Ack(entry)
	local data={};
	data.msgID=Proto.Command.MC_LOADINWAREHOUSEPET_ACK;
	data.count=Proto.parseWORD(entry); -- 宠物列表
	return data;
end

function Proto.parseP_MC_InWarehousePetData_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.MC_INWAREHOUSEPETDATA_NTF;
	data.pets=Proto.parseVector(entry,Proto.parseInWarhousePetDesc); -- 宠物列表
	return data;
end

function Proto.writeP_CZ_PutPetInWarehouse_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CZ_PUTPETINWAREHOUSE_REQ);
	Proto.writeDWORD(msg,data.petID); -- 宠物ID
end

function Proto.parseP_ZC_PutPetInWarehouse_Ack(entry)
	local data={};
	data.msgID=Proto.Command.ZC_PUTPETINWAREHOUSE_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.petID=Proto.parseDWORD(entry); -- 宠物ID
		data.status=Proto.parseBYTE(entry); -- 状态
	end
	return data;
end

function Proto.writeP_CZ_RetakeInWarehousePet_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CZ_RETAKEINWAREHOUSEPET_REQ);
	Proto.writePetID(msg,data.petid); -- 宠物ID
end

function Proto.parseP_ZC_RetakeInWarehousePet_Ack(entry)
	local data={};
	data.msgID=Proto.Command.ZC_RETAKEINWAREHOUSEPET_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	return data;
end

function Proto.writeP_CM_LoadDiscardPet_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CM_LOADDISCARDPET_REQ);
end

function Proto.parseP_MC_LoadDiscardPet_Ack(entry)
	local data={};
	data.msgID=Proto.Command.MC_LOADDISCARDPET_ACK;
	data.pets=Proto.parseVector(entry,Proto.parsePetID); -- 宠物列表
	return data;
end

function Proto.writeP_CZ_DiscardPet_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CZ_DISCARDPET_REQ);
	Proto.writeDWORD(msg,data.petID); -- 宠物ID
end

function Proto.parseP_ZC_DiscardPet_Ack(entry)
	local data={};
	data.msgID=Proto.Command.ZC_DISCARDPET_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	return data;
end

function Proto.writeP_CZ_RedeemPet_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CZ_REDEEMPET_REQ);
	Proto.writePetID(msg,data.petid); -- 宠物ID
end

function Proto.parseP_ZC_RedeemPet_Ack(entry)
	local data={};
	data.msgID=Proto.Command.ZC_REDEEMPET_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	return data;
end

function Proto.writeP_CZ_EvolutionQuery_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CZ_EVOLUTIONQUERY_REQ);
	Proto.writeDWORD(msg,data.raceType); -- 进化种族
end

function Proto.parseP_ZC_EvolutionQuery_Ack(entry)
	local data={};
	data.msgID=Proto.Command.ZC_EVOLUTIONQUERY_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.evolutions=Proto.parseVector(entry,Proto.parsePetRaceEvolution); -- 进化列表
	end
	return data;
end

function Proto.writeP_CG_EvolutionPet_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_EVOLUTIONPET_REQ);
	Proto.writeDWORD(msg,data.objID); -- 请求进化的宠物ID
	Proto.writeWORD(msg,data.choice); -- 进化的方向
	Proto.writeBYTE(msg,data.bProtectSkin); -- 保留形态对应的属性
end

function Proto.parseP_GC_EvolutionPet_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_EVOLUTIONPET_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code==Proto.Error.ERROR_OK) then
		data.objID=Proto.parseDWORD(entry); -- 请求进化的宠物ID
		data.newRace=Proto.parseDWORD(entry); -- 进化后的种族
		data.addSkills=Proto.parseVector(entry,Proto.parseEvoSkillInfo); -- 额外的可替换技能
	end
	return data;
end

function Proto.writeP_CG_SuperEvolutionPet_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_SUPEREVOLUTIONPET_REQ);
	Proto.writeDWORD(msg,data.objID); -- 请求超进化的宠物ID
	Proto.writeWORD(msg,data.choice); -- 超进化的方向
	Proto.writeBYTE(msg,data.bProtectSkin); -- 保留形态对应的属性
end

function Proto.parseP_GC_SuperEvolutionPet_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_SUPEREVOLUTIONPET_ACK;
	data.code=Proto.parseWORD(entry); -- 
	if (data.code==Proto.Error.ERROR_OK) then
		data.objID=Proto.parseDWORD(entry); -- 请求超进化的宠物ID
		data.newRace=Proto.parseDWORD(entry); -- 超进化后的种族
		data.addSkills=Proto.parseVector(entry,Proto.parseEvoSkillInfo); -- 额外的可替换技能
	end
	return data;
end

function Proto.parseP_ZC_EvolutionPet_Brd(entry)
	local data={};
	data.msgID=Proto.Command.ZC_EVOLUTIONPET_BRD;
	data.master=Proto.parseRoleHandle(entry); -- 宠物主人句柄
	data.raceType=Proto.parseDWORD_(entry); -- 宠物种族
	data.gender=Proto.parseBYTE(entry); -- 宠物性别
	data.geneApperLeft=Proto.parseWORD(entry); -- 外表天性
	data.geneApperRight=Proto.parseWORD(entry); -- 外表天性
	return data;
end

function Proto.parseP_ZC_InsertPetFoodState_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.ZC_INSERTPETFOODSTATE_NTF;
	data.petID=Proto.parseDWORD(entry); -- 宠物ID
	data.foodID=Proto.parseDWORD(entry); -- 食物ID
	return data;
end

function Proto.parseP_ZC_RemovePetFoodState_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.ZC_REMOVEPETFOODSTATE_NTF;
	data.petID=Proto.parseDWORD(entry); -- 宠物ID
	data.foodID=Proto.parseDWORD(entry); -- 食物ID
	return data;
end

function Proto.parseP_ZC_InsertPetConfraternityNpcState_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.ZC_INSERTPETCONFRATERNITYNPCSTATE_NTF;
	data.petID=Proto.parseDWORD(entry); -- 宠物ID
	data.confraternityNpcID=Proto.parseDWORD(entry); -- 帮派NPCID
	return data;
end

function Proto.parseP_ZC_RemovePetConfraternityNpcState_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.ZC_REMOVEPETCONFRATERNITYNPCSTATE_NTF;
	data.petID=Proto.parseDWORD(entry); -- 宠物ID
	data.confraternityNpcID=Proto.parseDWORD(entry); -- 帮派NPCID
	return data;
end

function Proto.writeP_CZ_BagPetSpawnGamete_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CZ_BAGPETSPAWNGAMETE_REQ);
	Proto.writeDWORD(msg,data.petID); -- 宠物ID
end

function Proto.parseP_ZC_BagPetSpawnGamete_Ack(entry)
	local data={};
	data.msgID=Proto.Command.ZC_BAGPETSPAWNGAMETE_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.petID=Proto.parseDWORD(entry); -- 宠物ID
	end
	return data;
end

function Proto.writeP_CZ_MateGamete_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CZ_MATEGAMETE_REQ);
	Proto.writeWORD(msg,data.pos1); -- 配子1
	Proto.writeWORD(msg,data.pos2); -- 配子2
end

function Proto.parseP_ZC_MateGamete_Ack(entry)
	local data={};
	data.msgID=Proto.Command.ZC_MATEGAMETE_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	return data;
end

function Proto.writeP_CZ_AllelePowerUp_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CZ_ALLELEPOWERUP_REQ);
	Proto.writePetID(msg,data.petID); -- 宠物ID
	Proto.writeItemPacketID(msg,data.bag); -- 行囊ID
	Proto.writeWORD(msg,data.allelePos); -- 基因位置
	Proto.writeWORD(msg,data.itemPos); -- 道具位置
end

function Proto.parseP_ZC_AllelePowerUp_Ack(entry)
	local data={};
	data.msgID=Proto.Command.ZC_ALLELEPOWERUP_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	return data;
end

function Proto.writeP_CZ_ActivatePet_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CZ_ACTIVATEPET_REQ);
	Proto.writePetID(msg,data.petID); -- 宠物ID
end

function Proto.parseP_ZC_ActivatePet_Ack(entry)
	local data={};
	data.msgID=Proto.Command.ZC_ACTIVATEPET_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	return data;
end

function Proto.writeP_CZ_QueryRaceClass_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CZ_QUERYRACECLASS_REQ);
	Proto.writeWORD(msg,data.raceType); -- 宠物类型
end

function Proto.parseP_ZC_QueryRaceClass_Ack(entry)
	local data={};
	data.msgID=Proto.Command.ZC_QUERYRACECLASS_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	data.classNum=Proto.parseBYTE(entry); -- 阶数
	return data;
end

function Proto.writeP_CZ_InBagPetWarInfo_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CZ_INBAGPETWARINFO_REQ);
	Proto.writeDWORD(msg,data.petID); -- 宠物ID
end

function Proto.parseP_ZC_InBagPetWarInfo_Ack(entry)
	local data={};
	data.msgID=Proto.Command.ZC_INBAGPETWARINFO_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.petID=Proto.parseDWORD(entry); -- 宠物ID
	end
	return data;
end

function Proto.writeP_CZ_QuerySacredInfo_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CZ_QUERYSACREDINFO_REQ);
	Proto.writeDWORD(msg,data.raceType); -- 宠物类型
end

function Proto.parseP_ZC_QuerySacredInfo_Ack(entry)
	local data={};
	data.msgID=Proto.Command.ZC_QUERYSACREDINFO_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.info=Proto.parseVector(entry,Proto.parseSacredPetInfo); -- 宠物祭祀信息
	end
	return data;
end

function Proto.writeP_CZ_SacredPet_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CZ_SACREDPET_REQ);
	Proto.writeDWORD(msg,data.petID); -- 目标宠物ID
	Proto.writeDWORD(msg,data.sacredID); -- 祭祀宠物id
end

function Proto.parseP_ZC_SacredPet_Ack(entry)
	local data={};
	data.msgID=Proto.Command.ZC_SACREDPET_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.petID=Proto.parseDWORD(entry); -- 目标宠物ID
	end
	return data;
end

function Proto.parseP_ZC_PetModelChanged_Brd(entry)
	local data={};
	data.msgID=Proto.Command.ZC_PETMODELCHANGED_BRD;
	data.master=Proto.parseRoleHandle(entry); -- 宠物主人句柄
	data.raceType=Proto.parseDWORD_(entry); -- 宠物种族
	data.gender=Proto.parseBYTE(entry); -- 宠物性别
	data.pos=Proto.parseWORD(entry); -- 天性位置
	data.geneLeft=Proto.parseWORD(entry); -- 天性左
	data.geneRight=Proto.parseWORD(entry); -- 天性右
	return data;
end

function Proto.writeP_CZ_SwapInBagPetOrder_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CZ_SWAPINBAGPETORDER_REQ);
	Proto.writePetID(msg,data.petID_a); -- 宠物ID
	Proto.writePetID(msg,data.petID_b); -- 宠物ID
end

function Proto.parseP_ZC_SwapInBagPetOrder_Ack(entry)
	local data={};
	data.msgID=Proto.Command.ZC_SWAPINBAGPETORDER_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	return data;
end

function Proto.parseP_ZC_UpdatePetPower_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.ZC_UPDATEPETPOWER_NTF;
	data.id=Proto.parsePetID(entry); -- 宠物ID
	data.power=Proto.parseDWORD(entry); -- 战斗力
	return data;
end

function Proto.writeP_CZ_QueryPetInBagInfo_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CZ_QUERYPETINBAGINFO_REQ);
	Proto.writeCharacterID(msg,data.charid); -- 玩家ID
end

function Proto.parseP_ZC_QueryPetInBagInfo_Ack(entry)
	local data={};
	data.msgID=Proto.Command.ZC_QUERYPETINBAGINFO_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code==Proto.Error.ERROR_OK) then
		data.infos=Proto.parseVector(entry,Proto.parsePetInfo); -- 宠物信息
	end
	return data;
end

function Proto.writeP_CZ_LoadPotential_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CZ_LOADPOTENTIAL_REQ);
	Proto.writeVector(msg,data.pets,Proto.writePetID); -- 宠物信息
end

function Proto.parseP_ZC_LoadPotential_Ack(entry)
	local data={};
	data.msgID=Proto.Command.ZC_LOADPOTENTIAL_ACK;
	data.infos=Proto.parseVector(entry,Proto.parsePetPotentialInfo); -- 宠物信息
	return data;
end

function Proto.parseP_ZC_UpdatePotential_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.ZC_UPDATEPOTENTIAL_NTF;
	data.info=Proto.parsePetPotentialInfo(entry); -- 潜力信息
	return data;
end

function Proto.writeP_CZ_EatEgg_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CZ_EATEGG_REQ);
	Proto.writePetID(msg,data.petID); -- 宠物ID
	Proto.writeVector(msg,data.itemPos,Proto.writeWORD); -- 道具位置
end

function Proto.parseP_ZC_EatEgg_Ack(entry)
	local data={};
	data.msgID=Proto.Command.ZC_EATEGG_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	return data;
end

function Proto.writeP_CZ_EatPet_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CZ_EATPET_REQ);
	Proto.writePetID(msg,data.petID); -- 宠物ID
	Proto.writePetID(msg,data.eatPetID); -- 被吃宠物ID
end

function Proto.parseP_ZC_EatPet_Ack(entry)
	local data={};
	data.msgID=Proto.Command.ZC_EATPET_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	return data;
end

function Proto.writeP_CM_CheckPetUpgradeInWarehouse_Ntf(msg,data)
	Proto.writeWORD(msg,Proto.Command.CM_CHECKPETUPGRADEINWAREHOUSE_NTF);
	Proto.writePetID(msg,data.petID); -- 宠物ID
end

function Proto.writeP_CZ_QuerySubstitute_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CZ_QUERYSUBSTITUTE_REQ);
end

function Proto.parseP_ZC_QuerySubstitute_Ack(entry)
	local data={};
	data.msgID=Proto.Command.ZC_QUERYSUBSTITUTE_ACK;
	data.substitutes=Proto.parseBYTE(entry); -- 已开启替补位置
	return data;
end

function Proto.writeP_CZ_GetSubstitute_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CZ_GETSUBSTITUTE_REQ);
	Proto.writeBYTE(msg,data.moneyType); -- 币种
	Proto.writeBYTE(msg,data.substitutePos); -- 替补位置
end

function Proto.parseP_ZC_GetSubstitute_Ack(entry)
	local data={};
	data.msgID=Proto.Command.ZC_GETSUBSTITUTE_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	return data;
end

function Proto.writeP_CZ_GetPetDepotsCount_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CZ_GETPETDEPOTSCOUNT_REQ);
end

function Proto.parseP_ZC_GetPetDepotsCount_Ack(entry)
	local data={};
	data.msgID=Proto.Command.ZC_GETPETDEPOTSCOUNT_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	data.count=Proto.parseWORD(entry); -- 数量
	return data;
end

function Proto.writeP_CG_PokemonEvo_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_POKEMONEVO_REQ);
	Proto.writeDWORD(msg,data.objID); -- 宠物objID
end

function Proto.parseP_GC_PokemonEvo_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_POKEMONEVO_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code==Proto.Error.ERROR_OK) then
		data.pet=Proto.parseString(entry); -- 
	end
	return data;
end

function Proto.writeP_CG_UpdateActivePetList_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_UPDATEACTIVEPETLIST_REQ);
	Proto.writeString(msg,data.petsIndexStr); -- 要激活的宠物的序列
end

function Proto.parseP_GC_UpdateActivePetList_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_UPDATEACTIVEPETLIST_ACK;
	data.code=Proto.parseWORD(entry); -- 
	return data;
end

function Proto.writeP_CG_PokemonAdvaStageLevel_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_POKEMONADVASTAGELEVEL_REQ);
	Proto.writeDWORD(msg,data.objID); -- 要进阶的宠物索引(非表格)
end

function Proto.parseP_GC_PokemonAdvaStageLevel_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_POKEMONADVASTAGELEVEL_ACK;
	data.code=Proto.parseWORD(entry); -- 
	if (data.code==Proto.Error.ERROR_OK) then
		data.objID=Proto.parseDWORD(entry); -- 
		data.stage=Proto.parseWORD(entry); -- 
	end
	return data;
end

function Proto.writeP_CG_PokemonSkillLevelUp_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_POKEMONSKILLLEVELUP_REQ);
	Proto.writeDWORD(msg,data.objID); -- 宠物objID
	Proto.writeDWORD(msg,data.skillIndex); -- 技能索引 0 1 2 3 4
end

function Proto.parseP_GC_PokemonSkillLevelUp_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_POKEMONSKILLLEVELUP_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code==Proto.Error.ERROR_OK) then
		data.objID=Proto.parseDWORD(entry); -- 
		data.skillIndex=Proto.parseDWORD(entry); -- 技能索引 0 1 2 3 4
		data.newSkillID=Proto.parseDWORD(entry); -- 技能ID
	end
	return data;
end

function Proto.writeP_CG_PokemonSkillChange_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_POKEMONSKILLCHANGE_REQ);
	Proto.writeDWORD(msg,data.objID); -- 宠物objID
	Proto.writeDWORD(msg,data.skillIndex); -- 技能索引 0 1 2 3 4
	Proto.writeDWORD(msg,data.itemID); -- 使用的道具ID
end

function Proto.parseP_GC_PokemonSkillChange_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_POKEMONSKILLCHANGE_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code==Proto.Error.ERROR_OK) then
		data.objID=Proto.parseDWORD(entry); -- 
		data.skillIndex=Proto.parseDWORD(entry); -- 
		data.newSkillID=Proto.parseDWORD(entry); -- 技能ID
	end
	return data;
end

function Proto.writeP_CG_SkillItemUpgrade_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_SKILLITEMUPGRADE_REQ);
	Proto.writeDWORD(msg,data.itemID); -- 使用的道具ID
end

function Proto.parseP_GC_SkillItemUpgrade_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_SKILLITEMUPGRADE_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code==Proto.Error.ERROR_OK) then
		data.newItemID=Proto.parseDWORD(entry); -- 新道具ID
	end
	return data;
end

function Proto.writeP_CG_CapsuleEgg_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_CAPSULEEGG_REQ);
	Proto.writeWORD(msg,data.optType); -- 扭蛋类型
	Proto.writeWORD(msg,data.choice); -- 选择1: 1次、2: 10次或者3: 附加值方式（心愿之力）
	Proto.writeWORD(msg,data.bFree); -- 是否免费抽取
	Proto.writeWORD(msg,data.choiceEx); -- 附加值方式（心愿之力）时选择的宠物索引
	if data.localRequestKey then
		Proto.writeString(msg,data.localRequestKey);
	end
end

function Proto.parseP_GC_CapsuleEgg_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_CAPSULEEGG_ACK;
	data.code=Proto.parseWORD(entry); -- 
	if (data.code==Proto.Error.ERROR_OK) then
		data.awardVecStr=Proto.parseVector(entry,Proto.parseString); -- 奖励元素表
	end
	return data;
end

function Proto.writeP_CG_CapsuleEggCDs_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_CAPSULEEGGCDS_REQ);
end

function Proto.parseP_GC_CapsuleEggCDs_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_CAPSULEEGGCDS_ACK;
	data.code=Proto.parseWORD(entry); -- 
	if (data.code==Proto.Error.ERROR_OK) then
		data.capsuleEggTimeAndCDsVec=Proto.parseVector(entry,Proto.parseCapsuleEggTimesAndCD); -- 免费次数使用值和冷却时间组
	end
	return data;
end

function Proto.writeP_CG_CapsuleEggAllInfoCmd_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_CAPSULEEGGALLINFOCMD_REQ);
end

function Proto.parseP_GC_CapsuleEggAllInfoCmd_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_CAPSULEEGGALLINFOCMD_ACK;
	data.code=Proto.parseWORD(entry); -- 
	if (data.code==Proto.Error.ERROR_OK) then
		data.capsuleEggAllInfo=Proto.parseString(entry); -- 扭蛋全部信息
	end
	return data;
end

function Proto.writeP_CG_PetFreedom_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_PETFREEDOM_REQ);
	Proto.writeVector(msg,data.petObjIDs,Proto.writeDWORD); -- 宠物ObjIDs
end

function Proto.parseP_GC_PetFreedom_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_PETFREEDOM_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	return data;
end

function Proto.writeP_CG_PetStarPour_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_PETSTARPOUR_REQ);
	Proto.writeDWORD(msg,data.petObjID); -- 宠物ObjID
	Proto.writeDWORD(msg,data.itemID); -- 物品ID
end

function Proto.parseP_GC_PetStarPour_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_PETSTARPOUR_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	data.pourExp=Proto.parseDWORD(entry); -- 灌注经验
	return data;
end

function Proto.writeP_CG_PetStarPourAuto_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_PETSTARPOURAUTO_REQ);
	Proto.writeDWORD(msg,data.petObjID); -- 宠物ObjID
end

function Proto.parseP_GC_PetStarPourAuto_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_PETSTARPOURAUTO_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	data.pourExp=Proto.parseDWORD(entry); -- 灌注经验
	return data;
end

function Proto.writeP_CG_PetStarUp_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_PETSTARUP_REQ);
	Proto.writeDWORD(msg,data.petObjID); -- 宠物ObjID
	Proto.writeVector(msg,data.costPetObjIDs,Proto.writeDWORD); -- 消耗宠物ObjIDs
end

function Proto.parseP_GC_PetStarUp_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_PETSTARUP_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	return data;
end

function Proto.writeP_CG_ChangePetEvoSkill_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_CHANGEPETEVOSKILL_REQ);
	Proto.writeDWORD(msg,data.petObjID); -- 宠物ObjID
	Proto.writeDWORD(msg,data.skillIndex); -- 要替换的技能格
	Proto.writeDWORD(msg,data.skillID); -- 新技能ID
end

function Proto.parseP_GC_ChangePetEvoSkill_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_CHANGEPETEVOSKILL_ACK;
	data.code=Proto.parseWORD(entry); -- 
	if (data.code==Proto.Error.ERROR_OK) then
		data.petObjID=Proto.parseDWORD(entry); -- 宠物ObjID
		data.skillIndex=Proto.parseDWORD(entry); -- 要替换的技能格
		data.skillID=Proto.parseDWORD(entry); -- 新技能ID
	end
	return data;
end

function Proto.writeP_CG_UpdatePetArmys_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_UPDATEPETARMYS_REQ);
	Proto.writeVector(msg,data.petArmys,Proto.writePetArmyInfo); -- 宠物队伍成员组
end

function Proto.parseP_GC_UpdatePetArmys_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_UPDATEPETARMYS_ACK;
	data.code=Proto.parseWORD(entry); -- 
	return data;
end

function Proto.writeP_CG_GetPetArmys_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETPETARMYS_REQ);
end

function Proto.parseP_GC_GetPetArmys_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETPETARMYS_ACK;
	data.code=Proto.parseWORD(entry); -- 
	data.petArmys=Proto.parseString(entry); -- 宠物队伍成员组
	return data;
end

function Proto.writeP_CG_ActivePetArmy_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_ACTIVEPETARMY_REQ);
	Proto.writeDWORD(msg,data.petArmyIndex); -- 宠物编队索引
end

function Proto.parseP_GC_ActivePetArmy_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_ACTIVEPETARMY_ACK;
	data.code=Proto.parseWORD(entry); -- 
	return data;
end

function Proto.writeP_CG_AddYokePet_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_ADDYOKEPET_REQ);
	Proto.writeDWORD(msg,data.objID); -- 主宠ID
	Proto.writeWORD(msg,data.yokeID); -- 羁绊编号
	Proto.writeWORD(msg,data.yokeCellID); -- 羁绊格子位置，从0开始
	Proto.writeDWORD(msg,data.assistObjID); -- 羁绊宠ID
end

function Proto.parseP_GC_AddYokePet_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_ADDYOKEPET_ACK;
	data.code=Proto.parseWORD(entry); -- 
	return data;
end

function Proto.writeP_CG_DelYokePet_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_DELYOKEPET_REQ);
	Proto.writeDWORD(msg,data.objID); -- 主宠ID
	Proto.writeWORD(msg,data.yokeID); -- 羁绊编号
	Proto.writeWORD(msg,data.yokeCellID); -- 羁绊格子位置，从0开始
end

function Proto.parseP_GC_DelYokePet_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_DELYOKEPET_ACK;
	data.code=Proto.parseWORD(entry); -- 
	return data;
end

function Proto.writeP_CG_ChangeYokePet_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_CHANGEYOKEPET_REQ);
	Proto.writeDWORD(msg,data.objID); -- 主宠ID
	Proto.writeWORD(msg,data.yokeID); -- 羁绊编号
	Proto.writeWORD(msg,data.yokeCellID); -- 羁绊格子位置，从0开始
	Proto.writeDWORD(msg,data.assistObjID); -- 替换宠ID
end

function Proto.parseP_GC_ChangeYokePet_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_CHANGEYOKEPET_ACK;
	data.code=Proto.parseWORD(entry); -- 
	return data;
end

function Proto.parseP_GC_UpdatePetYokeInfo_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_UPDATEPETYOKEINFO_NTF;
	data.petsYoke=Proto.parseString(entry); -- 羁绊
	return data;
end

function Proto.writeP_CG_GetCapsuleEggAddValuePets_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETCAPSULEEGGADDVALUEPETS_REQ);
	Proto.writeBYTE(msg,data.type); -- 扭蛋类型
end

function Proto.parseP_GC_GetCapsuleEggAddValuePets_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETCAPSULEEGGADDVALUEPETS_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code==Proto.Error.ERROR_OK) then
		data.addPets=Proto.parseString(entry); -- 宠物组
	end
	return data;
end

function Proto.writeP_CG_GetPetSkillWiki_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETPETSKILLWIKI_REQ);
end

function Proto.parseP_GC_GetPetSkillWiki_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETPETSKILLWIKI_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code==Proto.Error.ERROR_OK) then
		data.skillBookNum=Proto.parseDWORD(entry); -- 
	end
	return data;
end

function Proto.parseP_GC_GetPetSkillWiki_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETPETSKILLWIKI_NTF;
	data.skillBookIDs=Proto.parseVector(entry,Proto.parseDWORD); -- 
	return data;
end

function Proto.parseP_GC_UpdatePetSkillWiki_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_UPDATEPETSKILLWIKI_NTF;
	data.skillBookIDs=Proto.parseVector(entry,Proto.parseDWORD); -- 
	return data;
end

function Proto.writeP_CG_CompoundPetSkill_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_COMPOUNDPETSKILL_REQ);
	Proto.writeDWORD(msg,data.SkillBookID); -- 技能书ID
	Proto.writeDWORD(msg,data.num); -- 数量
end

function Proto.parseP_GC_CompoundPetSkill_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_COMPOUNDPETSKILL_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	return data;
end

function Proto.writeP_CG_ResolvePetSkill_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_RESOLVEPETSKILL_REQ);
	Proto.writeVector(msg,data.SkillBookInfo,Proto.writeResolveSkillInfo); -- 技能书信息
end

function Proto.parseP_GC_ResolvePetSkill_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_RESOLVEPETSKILL_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	return data;
end

function Proto.writeP_CG_GetPetWiki_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETPETWIKI_REQ);
end

function Proto.parseP_GC_GetPetWiki_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETPETWIKI_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code==Proto.Error.ERROR_OK) then
		data.num=Proto.parseDWORD(entry); -- 
	end
	return data;
end

function Proto.writeP_CG_GetPetWikiActivity_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETPETWIKIACTIVITY_REQ);
end

function Proto.parseP_GC_GetPetWikiActivity_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETPETWIKIACTIVITY_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code==Proto.Error.ERROR_OK) then
		data.num=Proto.parseDWORD(entry); -- 
	end
	return data;
end

function Proto.parseP_GC_GetPetWiki_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETPETWIKI_NTF;
	data.petWiki=Proto.parseVector(entry,Proto.parseDWORD); -- 
	return data;
end

function Proto.parseP_GC_GetPetWikiActivity_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETPETWIKIACTIVITY_NTF;
	data.petWiki=Proto.parseVector(entry,Proto.parseDWORD); -- 
	return data;
end

function Proto.writeP_CG_CompoundPetPiece_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_COMPOUNDPETPIECE_REQ);
	Proto.writeDWORD(msg,data.PetPieceID); -- 碎片ID
end

function Proto.parseP_GC_CompoundPetPiece_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_COMPOUNDPETPIECE_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	return data;
end

function Proto.writeP_CG_ChangePetName_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_CHANGEPETNAME_REQ);
	Proto.writeDWORD(msg,data.petObjID); -- 宠物objID
	Proto.writeString(msg,data.newName); -- 新名字
end

function Proto.parseP_GC_ChangePetName_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_CHANGEPETNAME_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.isModify=Proto.parseBYTE(entry); -- 属性提升了吗
	end
	return data;
end

function Proto.writeP_CG_IwatchCatchPet_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_IWATCHCATCHPET_REQ);
	Proto.writeDWORD(msg,data.petID); -- 宠物ID
	Proto.writeDWORD(msg,data.itemID); -- 精灵球类型
end

function Proto.parseP_GC_IwatchCatchPet_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_IWATCHCATCHPET_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	return data;
end

function Proto.writeP_CG_EatPet_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_EATPET_REQ);
	Proto.writeDWORD(msg,data.petObjID); -- 宠物ID
	Proto.writeDWORD(msg,data.eatPetObjID); -- 被吃宠物ID
end

function Proto.parseP_GC_EatPet_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_EATPET_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	return data;
end

function Proto.writeP_CG_ResetPetStar_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_RESETPETSTAR_REQ);
	Proto.writeDWORD(msg,data.objID); -- 宠物objID
end

function Proto.parseP_GC_ResetPetStar_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_RESETPETSTAR_ACK;
	data.code=Proto.parseWORD(entry); -- 错误码
	return data;
end

function Proto.writeP_CG_ClearEvoSkills_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_CLEAREVOSKILLS_REQ);
	Proto.writeDWORD(msg,data.objID); -- 宠物ObjID
end

function Proto.parseP_GC_ClearEvoSkills_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_CLEAREVOSKILLS_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	return data;
end

function Proto.writeP_CG_GetScienceDatas_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETSCIENCEDATAS_REQ);
end

function Proto.parseP_GC_GetScienceDatas_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETSCIENCEDATAS_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.datas=Proto.parseVector(entry,Proto.parseScienceData); -- 
		data.consumeDatas=Proto.parseVector(entry,Proto.parseDWORD); -- 
		data.consumedDatas=Proto.parseVector(entry,Proto.parseDWORD); -- 
		data.updateTime=Proto.parseString(entry); -- 
	end
	return data;
end

function Proto.writeP_CG_ScienceLevelUp_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_SCIENCELEVELUP_REQ);
	Proto.writeDWORD(msg,data.scienceID); -- 
end

function Proto.parseP_GC_ScienceLevelUp_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_SCIENCELEVELUP_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.data=Proto.parseScienceData(entry); -- 
	end
	return data;
end

function Proto.writeP_CG_ScienceStarUp_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_SCIENCESTARUP_REQ);
	Proto.writeDWORD(msg,data.scienceID); -- 
end

function Proto.parseP_GC_ScienceStarUp_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_SCIENCESTARUP_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.data=Proto.parseScienceData(entry); -- 
	end
	return data;
end

function Proto.writeP_CG_ScienceConsume_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_SCIENCECONSUME_REQ);
	Proto.writeDWORD(msg,data.consumeID); -- 
	Proto.writeDWORD(msg,data.consumeNum); -- 
end

function Proto.parseP_GC_ScienceConsume_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_SCIENCECONSUME_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.consumeDatas=Proto.parseVector(entry,Proto.parseDWORD); -- 
		data.consumedDatas=Proto.parseVector(entry,Proto.parseDWORD); -- 
	end
	return data;
end

function Proto.writeP_CG_ResetScienceConsumes_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_RESETSCIENCECONSUMES_REQ);
end

function Proto.parseP_GC_ResetScienceConsumes_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_RESETSCIENCECONSUMES_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.consumeDatas=Proto.parseVector(entry,Proto.parseDWORD); -- 
		data.consumedDatas=Proto.parseVector(entry,Proto.parseDWORD); -- 
	end
	return data;
end

function Proto.writeP_CG_ImportEthPet_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_IMPORTETHPET_REQ);
	Proto.writeString(msg,data.address); -- 
end

function Proto.parseP_GC_ImportEthPet_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_IMPORTETHPET_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code ==Proto.Error.ERROR_OK) then
		data.pet=Proto.parseString(entry); -- 
	end
	return data;
end

