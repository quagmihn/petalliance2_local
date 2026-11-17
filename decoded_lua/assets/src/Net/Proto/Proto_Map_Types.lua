-- Net.Proto.Proto_Map_Types

Proto.AT_WALK				= 0								-- [动作类型]行走
Proto.AT_STANDUP			= Proto.AT_WALK + 1				-- [动作类型]站立
Proto.AT_SITDOWN			= Proto.AT_STANDUP + 1			-- [动作类型]坐下
Proto.AT_WALK_UNDER_ACHE	= Proto.AT_SITDOWN + 1			-- [动作类型]在生病状态下行走
Proto.AT_ROTATE_LEFT		= Proto.AT_WALK_UNDER_ACHE + 1	-- [动作类型]左旋
Proto.AT_ROTATE_RIGHT		= Proto.AT_ROTATE_LEFT + 1		-- [动作类型]右旋
Proto.AT_SEAT_WAIT			= Proto.AT_ROTATE_RIGHT + 1		-- [动作类型]座位等待
Proto.AT_SEAT_EAT			= Proto.AT_SEAT_WAIT + 1		-- [动作类型]座位进食
Proto.AT_COOK				= Proto.AT_SEAT_EAT + 1			-- [动作类型]烹调
Proto.AT_IRRIGATE			= Proto.AT_COOK + 1				-- [动作类型]灌溉
Proto.AT_INGATHER			= Proto.AT_IRRIGATE + 1			-- [动作类型]收获
Proto.AT_REMOVEPLANT		= Proto.AT_INGATHER + 1			-- [动作类型]移除植物
Proto.AT_GO_COOKING			= Proto.AT_REMOVEPLANT + 1		-- [动作类型]去烹饪
Proto.AT_GO_SERVING			= Proto.AT_GO_COOKING + 1		-- [动作类型]去上菜
Proto.AT_GO_PUTTINGDISH		= Proto.AT_GO_SERVING + 1		-- [动作类型]去保存菜
Proto.AT_IN_SPA				= Proto.AT_GO_PUTTINGDISH + 1	-- [动作类型]在温泉中
Proto.AT_BYPRODUCT			= Proto.AT_IN_SPA + 1			-- [动作类型]收获副产品
Proto.AT_DETECTITEM			= Proto.AT_BYPRODUCT + 1		-- [动作类型]勘测道具
Proto.AT_DETECTWAIT			= Proto.AT_DETECTITEM + 1		-- [动作类型]勘测等待
Proto.AT_CASTSTATE			= Proto.AT_DETECTWAIT + 1		-- [动作类型]施展状态
Proto.AT_COLLETE			= Proto.AT_CASTSTATE + 1		-- [动作类型]采集
Proto.AT_RANA				= Proto.AT_COLLETE + 1			-- [动作类型]rana触发动作
Proto.AT_COUNT				= Proto.AT_RANA + 1				-- [动作类型]动作总数
Proto.CMT_TOWN		= 0						-- [频道地图类型]城填地图
Proto.CMT_SCROLL	= Proto.CMT_TOWN + 1	-- [频道地图类型]卷轴地图
Proto.CT_TOWN	= 0					-- [频道类型]城填
Proto.CT_FARM	= Proto.CT_TOWN + 1	-- [频道类型]野外
Proto.CT_MATCH	= Proto.CT_FARM + 1	-- [频道类型]比赛
Proto.TA_PASSPORT			= 0									-- [小镇权限]通行证
Proto.TA_LOCKPETBAG			= Proto.TA_PASSPORT + 1				-- [小镇权限]锁定宠物袋收放
Proto.TA_SKIPDATABASE		= Proto.TA_LOCKPETBAG + 1			-- [小镇权限]不计登陆位置
Proto.TA_FORBIDTRADE		= Proto.TA_SKIPDATABASE + 1			-- [小镇权限]禁止交易
Proto.TA_FORBIDCOMPETITION	= Proto.TA_FORBIDTRADE + 1			-- [小镇权限]禁止竞技
Proto.TA_VENDALLOW			= Proto.TA_FORBIDCOMPETITION + 1	-- [小镇权限]摆摊许可
Proto.TA_CONFRATERNITY		= Proto.TA_VENDALLOW + 1			-- [小镇权限]公会场景
Proto.TA_USEMEDICINE		= Proto.TA_CONFRATERNITY + 1		-- [小镇权限]使用恢复药
Proto.TA_RIDINGPET			= Proto.TA_USEMEDICINE + 1			-- [小镇权限]允许骑宠
Proto.TA_LOCKPETORDER		= Proto.TA_RIDINGPET + 1			-- [小镇权限]锁定手动调整宠物顺序
Proto.MFUT_MORNINGEXERCISES	= 0	-- [地图功能单元类型]做早操

function Proto.parseActionInfo_BODY_Walk(entry)
	local data={};
	data.nextPos=Proto.parsePOS2D(entry); -- 下一步位置
	data.leftTime=Proto.parseWORD(entry); -- 剩余到达时间
	return data;
end

function Proto.writeActionInfo_BODY_Walk(msg,data)
	Proto.writePOS2D(msg,data.nextPos); -- 下一步位置
	Proto.writeWORD(msg,data.leftTime); -- 剩余到达时间
end

function Proto.parseActionInfo_BODY_SeatWait(entry)
	local data={};
	data.facilityID=Proto.parseQWORD(entry); -- 所在设施ID
	data.facilityIndex=Proto.parseBYTE(entry); -- 所在设施索引
	return data;
end

function Proto.writeActionInfo_BODY_SeatWait(msg,data)
	Proto.writeQWORD(msg,data.facilityID); -- 所在设施ID
	Proto.writeBYTE(msg,data.facilityIndex); -- 所在设施索引
end

function Proto.parseActionInfo_BODY_SeatEat(entry)
	local data={};
	data.dishID=Proto.parseDWORD(entry); -- 菜ID
	data.facilityID=Proto.parseQWORD(entry); -- 所在设施ID
	data.facilityIndex=Proto.parseBYTE(entry); -- 所在设施索引
	return data;
end

function Proto.writeActionInfo_BODY_SeatEat(msg,data)
	Proto.writeDWORD(msg,data.dishID); -- 菜ID
	Proto.writeQWORD(msg,data.facilityID); -- 所在设施ID
	Proto.writeBYTE(msg,data.facilityIndex); -- 所在设施索引
end

function Proto.parseActionInfo_BODY_Cook(entry)
	local data={};
	data.cookerID=Proto.parseDWORD(entry); -- 烹饪用具ID(炊具或电器)
	data.dishID=Proto.parseDWORD(entry); -- 菜ID
	data.facilityID=Proto.parseQWORD(entry); -- 所在设施ID
	data.facilityIndex=Proto.parseBYTE(entry); -- 所在设施索引
	return data;
end

function Proto.writeActionInfo_BODY_Cook(msg,data)
	Proto.writeDWORD(msg,data.cookerID); -- 烹饪用具ID(炊具或电器)
	Proto.writeDWORD(msg,data.dishID); -- 菜ID
	Proto.writeQWORD(msg,data.facilityID); -- 所在设施ID
	Proto.writeBYTE(msg,data.facilityIndex); -- 所在设施索引
end

function Proto.parseActionInfo_BODY_GoCooking(entry)
	local data={};
	data.nextPos=Proto.parsePOS2D(entry); -- 下一步位置
	data.leftTime=Proto.parseWORD(entry); -- 剩余到达时间
	data.dishID=Proto.parseDWORD(entry); -- 菜ID
	return data;
end

function Proto.writeActionInfo_BODY_GoCooking(msg,data)
	Proto.writePOS2D(msg,data.nextPos); -- 下一步位置
	Proto.writeWORD(msg,data.leftTime); -- 剩余到达时间
	Proto.writeDWORD(msg,data.dishID); -- 菜ID
end

function Proto.parseActionInfo_BODY_GoServing(entry)
	local data={};
	data.nextPos=Proto.parsePOS2D(entry); -- 下一步位置
	data.leftTime=Proto.parseWORD(entry); -- 剩余到达时间
	data.dishID=Proto.parseDWORD(entry); -- 菜ID
	return data;
end

function Proto.writeActionInfo_BODY_GoServing(msg,data)
	Proto.writePOS2D(msg,data.nextPos); -- 下一步位置
	Proto.writeWORD(msg,data.leftTime); -- 剩余到达时间
	Proto.writeDWORD(msg,data.dishID); -- 菜ID
end

function Proto.parseActionInfo_BODY_GoPuttingDish(entry)
	local data={};
	data.nextPos=Proto.parsePOS2D(entry); -- 下一步位置
	data.leftTime=Proto.parseWORD(entry); -- 剩余到达时间
	data.dishID=Proto.parseDWORD(entry); -- 菜ID
	return data;
end

function Proto.writeActionInfo_BODY_GoPuttingDish(msg,data)
	Proto.writePOS2D(msg,data.nextPos); -- 下一步位置
	Proto.writeWORD(msg,data.leftTime); -- 剩余到达时间
	Proto.writeDWORD(msg,data.dishID); -- 菜ID
end

function Proto.parseActionInfo_BODY_DetectItem(entry)
	local data={};
	data.detectItemType=Proto.parseDWORD(entry); -- 使用道具类型
	return data;
end

function Proto.writeActionInfo_BODY_DetectItem(msg,data)
	Proto.writeDWORD(msg,data.detectItemType); -- 使用道具类型
end

function Proto.parseActionInfo_BODY_DetectWait(entry)
	local data={};
	data.detectItemType=Proto.parseDWORD(entry); -- 使用道具类型
	return data;
end

function Proto.writeActionInfo_BODY_DetectWait(msg,data)
	Proto.writeDWORD(msg,data.detectItemType); -- 使用道具类型
end

function Proto.parseActionInfo_BODY_CastState(entry)
	local data={};
	data.castItemType=Proto.parseDWORD(entry); -- 使用道具类型
	data.target=Proto.parseRoleHandle(entry); -- 目标Handle
	return data;
end

function Proto.writeActionInfo_BODY_CastState(msg,data)
	Proto.writeDWORD(msg,data.castItemType); -- 使用道具类型
	Proto.writeRoleHandle(msg,data.target); -- 目标Handle
end

function Proto.parseActionInfo_BODY_RanaActionType(entry)
	local data={};
	data.type=Proto.parseBYTE(entry); -- rana动作类型
	return data;
end

function Proto.writeActionInfo_BODY_RanaActionType(msg,data)
	Proto.writeBYTE(msg,data.type); -- rana动作类型
end

function Proto.parseActionInfo(entry)
	local data={};
	data.action=Proto.parseBYTE(entry); -- 动作,ActionType
	data.body={}; -- 动作内容
	if (data.action==Proto.AT_WALK) then
		data.body.walk=Proto.parseActionInfo_BODY_Walk(entry); -- 
	end
	if (data.action==Proto.AT_SEAT_WAIT) then
		data.body.seatWait=Proto.parseActionInfo_BODY_SeatWait(entry); -- 
	end
	if (data.action==Proto.AT_SEAT_EAT) then
		data.body.seatEat=Proto.parseActionInfo_BODY_SeatEat(entry); -- 
	end
	if (data.action==Proto.AT_COOK) then
		data.body.cook=Proto.parseActionInfo_BODY_Cook(entry); -- 
	end
	if (data.action==Proto.AT_GO_COOKING) then
		data.body.goCooking=Proto.parseActionInfo_BODY_GoCooking(entry); -- 
	end
	if (data.action==Proto.AT_GO_SERVING) then
		data.body.goServing=Proto.parseActionInfo_BODY_GoServing(entry); -- 
	end
	if (data.action==Proto.AT_GO_PUTTINGDISH) then
		data.body.goPuttingDish=Proto.parseActionInfo_BODY_GoPuttingDish(entry); -- 
	end
	if (data.action==Proto.AT_DETECTITEM) then
		data.body.detectItem=Proto.parseActionInfo_BODY_DetectItem(entry); -- 
	end
	if (data.action==Proto.AT_DETECTWAIT) then
		data.body.detectWait=Proto.parseActionInfo_BODY_DetectWait(entry); -- 
	end
	if (data.action==Proto.AT_CASTSTATE) then
		data.body.castState=Proto.parseActionInfo_BODY_CastState(entry); -- 
	end
	if (data.action==Proto.AT_RANA) then
		data.body.ranaActionType=Proto.parseActionInfo_BODY_RanaActionType(entry); -- 
	end
	return data;
end

function Proto.writeActionInfo(msg,data)
	Proto.writeBYTE(msg,data.action); -- 动作,ActionType
	if (data.action==Proto.AT_WALK) then
		Proto.writeActionInfo_BODY_Walk(msg,data.body.walk); -- 
	end
	if (data.action==Proto.AT_SEAT_WAIT) then
		Proto.writeActionInfo_BODY_SeatWait(msg,data.body.seatWait); -- 
	end
	if (data.action==Proto.AT_SEAT_EAT) then
		Proto.writeActionInfo_BODY_SeatEat(msg,data.body.seatEat); -- 
	end
	if (data.action==Proto.AT_COOK) then
		Proto.writeActionInfo_BODY_Cook(msg,data.body.cook); -- 
	end
	if (data.action==Proto.AT_GO_COOKING) then
		Proto.writeActionInfo_BODY_GoCooking(msg,data.body.goCooking); -- 
	end
	if (data.action==Proto.AT_GO_SERVING) then
		Proto.writeActionInfo_BODY_GoServing(msg,data.body.goServing); -- 
	end
	if (data.action==Proto.AT_GO_PUTTINGDISH) then
		Proto.writeActionInfo_BODY_GoPuttingDish(msg,data.body.goPuttingDish); -- 
	end
	if (data.action==Proto.AT_DETECTITEM) then
		Proto.writeActionInfo_BODY_DetectItem(msg,data.body.detectItem); -- 
	end
	if (data.action==Proto.AT_DETECTWAIT) then
		Proto.writeActionInfo_BODY_DetectWait(msg,data.body.detectWait); -- 
	end
	if (data.action==Proto.AT_CASTSTATE) then
		Proto.writeActionInfo_BODY_CastState(msg,data.body.castState); -- 
	end
	if (data.action==Proto.AT_RANA) then
		Proto.writeActionInfo_BODY_RanaActionType(msg,data.body.ranaActionType); -- 
	end
end

function Proto.parseSenceCharBriefInfo(entry)
	local data={};
	data.id=Proto.parseUserID(entry); -- 玩家ID
	data.handle=Proto.parseRoleHandle(entry); -- 句柄
	data.nickname=Proto.parseNickName(entry); -- 呢称
	data.gender=Proto.parseBYTE(entry); -- 玩家性别(0:女,1:男)
	data.equipVersion=Proto.parseDWORD(entry); -- 装备更新版本
	data.hasConfraternity=Proto.parseBYTE(entry); -- 有无帮会
	if (data.hasConfraternity~=0) then
		data.confraternityID=Proto.parseDWORD(entry); -- 帮会ID
	end
	data.isTeamLeader=Proto.parseBYTE(entry); -- 是否是队长
	data.teamMemberCount=Proto.parseBYTE(entry); -- 组队成员数
	data.teamID=Proto.parseDWORD(entry); -- 队伍ID
	data.inCompetition=Proto.parseBYTE(entry); -- 是否正在竞技
	data.nationality=Proto.parseCountryID(entry); -- 玩家国籍
	data.hasRidingPet=Proto.parseBYTE(entry); -- 是否在骑宠上
	data.isPassenger=Proto.parseBYTE(entry); -- 是否乘客
	if (data.isPassenger~=0) then
		data.ridingPetOwner=Proto.parseDWORD(entry); -- 骑宠主人
	end
	if (data.hasRidingPet~=0) then
		data.ridingPetType=Proto.parseWORD(entry); -- 骑宠类型
		data.ridingPetID=Proto.parseDWORD(entry); -- 骑宠id
		data.ridingPetSurface=Proto.parseBYTE(entry); -- 骑宠外表
	end
	data.hasMarriage=Proto.parseBYTE(entry); -- 婚否
	if (data.hasMarriage~=0) then
		data.consortID=Proto.parseDWORD(entry); -- 配偶ID
	end
	data.speed=Proto.parseDWORD(entry); -- 人物速度
	return data;
end

function Proto.getSenceCharBriefInfoIDLen()
	return Proto.getUserIDLen();
end

function Proto.writeSenceCharBriefInfo(msg,data)
	Proto.writeUserID(msg,data.id); -- 玩家ID
	Proto.writeRoleHandle(msg,data.handle); -- 句柄
	Proto.writeNickName(msg,data.nickname); -- 呢称
	Proto.writeBYTE(msg,data.gender); -- 玩家性别(0:女,1:男)
	Proto.writeDWORD(msg,data.equipVersion); -- 装备更新版本
	Proto.writeBYTE(msg,data.hasConfraternity); -- 有无帮会
	if (data.hasConfraternity~=0) then
		Proto.writeDWORD(msg,data.confraternityID); -- 帮会ID
	end
	Proto.writeBYTE(msg,data.isTeamLeader); -- 是否是队长
	Proto.writeBYTE(msg,data.teamMemberCount); -- 组队成员数
	Proto.writeDWORD(msg,data.teamID); -- 队伍ID
	Proto.writeBYTE(msg,data.inCompetition); -- 是否正在竞技
	Proto.writeCountryID(msg,data.nationality); -- 玩家国籍
	Proto.writeBYTE(msg,data.hasRidingPet); -- 是否在骑宠上
	Proto.writeBYTE(msg,data.isPassenger); -- 是否乘客
	if (data.isPassenger~=0) then
		Proto.writeDWORD(msg,data.ridingPetOwner); -- 骑宠主人
	end
	if (data.hasRidingPet~=0) then
		Proto.writeWORD(msg,data.ridingPetType); -- 骑宠类型
		Proto.writeDWORD(msg,data.ridingPetID); -- 骑宠id
		Proto.writeBYTE(msg,data.ridingPetSurface); -- 骑宠外表
	end
	Proto.writeBYTE(msg,data.hasMarriage); -- 婚否
	if (data.hasMarriage~=0) then
		Proto.writeDWORD(msg,data.consortID); -- 配偶ID
	end
	Proto.writeDWORD(msg,data.speed); -- 人物速度
end

function Proto.parseUnitDominantGene(entry)
	local data={};
	data.gene_id=Proto.parseWORD(entry); -- 杂交组编号
	return data;
end

function Proto.writeUnitDominantGene(msg,data)
	Proto.writeWORD(msg,data.gene_id); -- 杂交组编号
end

function Proto.parsePetBriefInfo(entry)
	local data={};
	data.id=Proto.parsePetID(entry); -- 宠物ID
	data.name=Proto.parseLifeNick(entry); -- 宠物名称
	data.raceType=Proto.parseDWORD(entry); -- 动物类型
	data.gender=Proto.parseBYTE(entry); -- 性别
	data.dominantGenes=Proto.parseVector(entry,Proto.parseUnitDominantGene); -- 显性基因
	data.level=Proto.parseWORD(entry); -- 宠物等级
	return data;
end

function Proto.getPetBriefInfoIDLen()
	return Proto.getPetIDLen();
end

function Proto.writePetBriefInfo(msg,data)
	Proto.writePetID(msg,data.id); -- 宠物ID
	Proto.writeLifeNick(msg,data.name); -- 宠物名称
	Proto.writeDWORD(msg,data.raceType); -- 动物类型
	Proto.writeBYTE(msg,data.gender); -- 性别
	Proto.writeVector(msg,data.dominantGenes,Proto.writeUnitDominantGene); -- 显性基因
	Proto.writeWORD(msg,data.level); -- 宠物等级
end

function Proto.parseMapCharBriefInfo(entry)
	local data={};
	data.senceInfo=Proto.parseSenceCharBriefInfo(entry); -- 简要信息
	data.channelMapType=Proto.parseBYTE(entry); -- 频道地图类型
	data.direct=Proto.parseDirectType(entry); -- 方向
	data.pos=Proto.parsePOS2D(entry); -- 位置
	data.actionInfo=Proto.parseActionInfo(entry); -- 动作信息
	data.enclosingPet=Proto.parseBYTE(entry); -- 是否正在收宠物
	data.hasInBegPet=Proto.parseBYTE(entry); -- 有无袋中宠物
	if (data.hasInBegPet ~=0) then
		data.inBagPetInfo=Proto.parsePetBriefInfo(entry); -- 袋中宠物信息
	end
	return data;
end

function Proto.writeMapCharBriefInfo(msg,data)
	Proto.writeSenceCharBriefInfo(msg,data.senceInfo); -- 简要信息
	Proto.writeBYTE(msg,data.channelMapType); -- 频道地图类型
	Proto.writeDirectType(msg,data.direct); -- 方向
	Proto.writePOS2D(msg,data.pos); -- 位置
	Proto.writeActionInfo(msg,data.actionInfo); -- 动作信息
	Proto.writeBYTE(msg,data.enclosingPet); -- 是否正在收宠物
	Proto.writeBYTE(msg,data.hasInBegPet); -- 有无袋中宠物
	if (data.hasInBegPet ~=0) then
		Proto.writePetBriefInfo(msg,data.inBagPetInfo); -- 袋中宠物信息
	end
end

function Proto.parseMapPetBriefInfo(entry)
	local data={};
	data.handle=Proto.parseRoleHandle(entry); -- 句柄
	data.direct=Proto.parseDirectType(entry); -- 方向
	data.pos=Proto.parsePOS2D(entry); -- 位置
	data.actionInfo=Proto.parseActionInfo(entry); -- 动作信息
	data.ownerID=Proto.parseUserID(entry); -- 主人ID
	data.ownerName=Proto.parseNickName(entry); -- 主人呢称
	data.briefInfo=Proto.parsePetBriefInfo(entry); -- 基础信息
	data.equipVersion=Proto.parseDWORD(entry); -- 装备更新版本
	data.metier=Proto.parseWORD(entry); -- 职业
	data.hasFood=Proto.parseBYTE(entry); -- 有无食物
	if (data.hasFood~=0) then
		data.foodID=Proto.parseDWORD(entry); -- 食物ID
	end
	data.isFeeding=Proto.parseBYTE(entry); -- 是否正在进食
	if (data.isFeeding~=0) then
		data.feedingInfo=Proto.parsePetFeedingInfo(entry); -- 进食信息
	end
	return data;
end

function Proto.writeMapPetBriefInfo(msg,data)
	Proto.writeRoleHandle(msg,data.handle); -- 句柄
	Proto.writeDirectType(msg,data.direct); -- 方向
	Proto.writePOS2D(msg,data.pos); -- 位置
	Proto.writeActionInfo(msg,data.actionInfo); -- 动作信息
	Proto.writeUserID(msg,data.ownerID); -- 主人ID
	Proto.writeNickName(msg,data.ownerName); -- 主人呢称
	Proto.writePetBriefInfo(msg,data.briefInfo); -- 基础信息
	Proto.writeDWORD(msg,data.equipVersion); -- 装备更新版本
	Proto.writeWORD(msg,data.metier); -- 职业
	Proto.writeBYTE(msg,data.hasFood); -- 有无食物
	if (data.hasFood~=0) then
		Proto.writeDWORD(msg,data.foodID); -- 食物ID
	end
	Proto.writeBYTE(msg,data.isFeeding); -- 是否正在进食
	if (data.isFeeding~=0) then
		Proto.writePetFeedingInfo(msg,data.feedingInfo); -- 进食信息
	end
end

function Proto.parseMapNpcBriefInfo(entry)
	local data={};
	data.handle=Proto.parseRoleHandle(entry); -- 句柄
	data.direct=Proto.parseDirectType(entry); -- 方向
	data.pos=Proto.parsePOS2D(entry); -- 位置
	data.actionInfo=Proto.parseActionInfo(entry); -- 动作信息
	data.id=Proto.parseNpcID(entry); -- NpcID
	data.name=Proto.parseLifeNick(entry); -- Npc名称
	data.equipVersion=Proto.parseDWORD(entry); -- 装备更新版本
	data.metier=Proto.parseWORD(entry); -- 职业
	data.raceType=Proto.parseDWORD(entry); -- 动物类型
	data.hasFood=Proto.parseBYTE(entry); -- 有无食物
	if (data.hasFood~=0) then
		data.foodID=Proto.parseDWORD(entry); -- 食物ID
	end
	return data;
end

function Proto.getMapNpcBriefInfoIDLen()
	return Proto.getNpcIDLen();
end

function Proto.writeMapNpcBriefInfo(msg,data)
	Proto.writeRoleHandle(msg,data.handle); -- 句柄
	Proto.writeDirectType(msg,data.direct); -- 方向
	Proto.writePOS2D(msg,data.pos); -- 位置
	Proto.writeActionInfo(msg,data.actionInfo); -- 动作信息
	Proto.writeNpcID(msg,data.id); -- NpcID
	Proto.writeLifeNick(msg,data.name); -- Npc名称
	Proto.writeDWORD(msg,data.equipVersion); -- 装备更新版本
	Proto.writeWORD(msg,data.metier); -- 职业
	Proto.writeDWORD(msg,data.raceType); -- 动物类型
	Proto.writeBYTE(msg,data.hasFood); -- 有无食物
	if (data.hasFood~=0) then
		Proto.writeDWORD(msg,data.foodID); -- 食物ID
	end
end

function Proto.parseTownInfo(entry)
	local data={};
	data.id=Proto.parseTownID(entry); -- 小镇ID
	data.name=Proto.parseString(entry); -- 名称
	data.accessMask=Proto.parseWORD(entry); -- 权限掩码(Mask TownAccess)
	data.competitionChangePetCount=Proto.parseBYTE(entry); -- 经济允许换宠次数
	data.mapFile=Proto.parseMapFile(entry); -- 地图文件
	data.mapType=Proto.parseBYTE(entry); -- 地图类型
	data.channelType=Proto.parseBYTE(entry); -- 小镇类型
	data.initLocation=Proto.parsePOS2D(entry); -- 初始位置
	data.initDirect=Proto.parseDirectType(entry); -- 初始方向
	data.maxTeamUpDistance=Proto.parseDWORD(entry); -- 组队距离限定
	return data;
end

function Proto.getTownInfoIDLen()
	return Proto.getTownIDLen();
end

function Proto.writeTownInfo(msg,data)
	Proto.writeTownID(msg,data.id); -- 小镇ID
	Proto.writeString(msg,data.name); -- 名称
	Proto.writeWORD(msg,data.accessMask); -- 权限掩码(Mask TownAccess)
	Proto.writeBYTE(msg,data.competitionChangePetCount); -- 经济允许换宠次数
	Proto.writeMapFile(msg,data.mapFile); -- 地图文件
	Proto.writeBYTE(msg,data.mapType); -- 地图类型
	Proto.writeBYTE(msg,data.channelType); -- 小镇类型
	Proto.writePOS2D(msg,data.initLocation); -- 初始位置
	Proto.writeDirectType(msg,data.initDirect); -- 初始方向
	Proto.writeDWORD(msg,data.maxTeamUpDistance); -- 组队距离限定
end

function Proto.parseTownScript(entry)
	local data={};
	data.id=Proto.parseTownID(entry); -- 小镇ID
	data.script=Proto.parseString(entry); -- 脚本名称
	return data;
end

function Proto.getTownScriptIDLen()
	return Proto.getTownIDLen();
end

function Proto.writeTownScript(msg,data)
	Proto.writeTownID(msg,data.id); -- 小镇ID
	Proto.writeString(msg,data.script); -- 脚本名称
end

function Proto.parseScopeMapInfo(entry)
	local data={};
	data.id=Proto.parseWORD(entry); -- 场景id
	data.type=Proto.parseBYTE(entry); -- 场景类型
	data.mapFile=Proto.parseMapFile(entry); -- 地图文件
	data.initDirect=Proto.parseDirectType(entry); -- 初始方向
	data.initLocation=Proto.parsePOS2D(entry); -- 初始位置
	return data;
end

function Proto.getScopeMapInfoIDLen()
	return Proto.getWORDLen();
end

function Proto.writeScopeMapInfo(msg,data)
	Proto.writeWORD(msg,data.id); -- 场景id
	Proto.writeBYTE(msg,data.type); -- 场景类型
	Proto.writeMapFile(msg,data.mapFile); -- 地图文件
	Proto.writeDirectType(msg,data.initDirect); -- 初始方向
	Proto.writePOS2D(msg,data.initLocation); -- 初始位置
end

function Proto.parseConfraternityWarMapInfo(entry)
	local data={};
	data.id=Proto.parseWORD(entry); -- 公会战地图id
	data.mapName=Proto.parseString(entry); -- 公会战地图名
	data.mapFile=Proto.parseMapFile(entry); -- 地图文件
	data.initDefDirect=Proto.parseDirectType(entry); -- 防守方初始方向
	data.initDefLocation=Proto.parsePOS2D(entry); -- 防守方初始位置
	data.initAtkDirect=Proto.parseDirectType(entry); -- 攻方初始方向
	data.initAtkLocation=Proto.parsePOS2D(entry); -- 攻方初始位置
	data.script=Proto.parseString(entry); -- 规则脚本名
	data.pkDistance=Proto.parseDWORD(entry); -- pk距离
	return data;
end

function Proto.getConfraternityWarMapInfoIDLen()
	return Proto.getWORDLen();
end

function Proto.writeConfraternityWarMapInfo(msg,data)
	Proto.writeWORD(msg,data.id); -- 公会战地图id
	Proto.writeString(msg,data.mapName); -- 公会战地图名
	Proto.writeMapFile(msg,data.mapFile); -- 地图文件
	Proto.writeDirectType(msg,data.initDefDirect); -- 防守方初始方向
	Proto.writePOS2D(msg,data.initDefLocation); -- 防守方初始位置
	Proto.writeDirectType(msg,data.initAtkDirect); -- 攻方初始方向
	Proto.writePOS2D(msg,data.initAtkLocation); -- 攻方初始位置
	Proto.writeString(msg,data.script); -- 规则脚本名
	Proto.writeDWORD(msg,data.pkDistance); -- pk距离
end

function Proto.parseMapFuncUnit(entry)
	local data={};
	data.coord1=Proto.parsePOS2D(entry); -- 单元格坐标1
	data.coord2=Proto.parsePOS2D(entry); -- 单元格坐标2
	return data;
end

function Proto.writeMapFuncUnit(msg,data)
	Proto.writePOS2D(msg,data.coord1); -- 单元格坐标1
	Proto.writePOS2D(msg,data.coord2); -- 单元格坐标2
end

function Proto.parseMapFuncInfo(entry)
	local data={};
	data.type=Proto.parseBYTE(entry); -- 地图功能单元类型
	data.units=Proto.parseVector(entry,Proto.parseMapFuncUnit); -- 地图功能单元数组
	return data;
end

function Proto.writeMapFuncInfo(msg,data)
	Proto.writeBYTE(msg,data.type); -- 地图功能单元类型
	Proto.writeVector(msg,data.units,Proto.writeMapFuncUnit); -- 地图功能单元数组
end

function Proto.parseTownMapFuncInfo(entry)
	local data={};
	data.id=Proto.parseTownID(entry); -- 城镇ID
	data.infos=Proto.parseVector(entry,Proto.parseMapFuncInfo); -- 地图功能信息数组
	return data;
end

function Proto.getTownMapFuncInfoIDLen()
	return Proto.getTownIDLen();
end

function Proto.writeTownMapFuncInfo(msg,data)
	Proto.writeTownID(msg,data.id); -- 城镇ID
	Proto.writeVector(msg,data.infos,Proto.writeMapFuncInfo); -- 地图功能信息数组
end

