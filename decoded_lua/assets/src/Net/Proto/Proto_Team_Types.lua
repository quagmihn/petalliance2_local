-- Net.Proto.Proto_Team_Types

Proto.ALLOT_RANDOM	= 0							-- [道具分配方式]随机分配
Proto.ALLOT_LEADER	= Proto.ALLOT_RANDOM + 1	-- [道具分配方式]队长分配
Proto.ALLOT_TEAM	= Proto.ALLOT_LEADER + 1	-- [道具分配方式]队伍分配
Proto.ALLOT_TURNS	= Proto.ALLOT_TEAM + 1		-- [道具分配方式]轮流分配
Proto.STANDARD_SS	= 0						-- [分配道具标准]SS级道具
Proto.STANDARD_S	= Proto.STANDARD_SS + 1	-- [分配道具标准]S级道具
Proto.STANDARD_A	= Proto.STANDARD_S + 1	-- [分配道具标准]A级道具
Proto.STANDARD_B	= Proto.STANDARD_A + 1	-- [分配道具标准]B级道具
Proto.STANDARD_C	= Proto.STANDARD_B + 1	-- [分配道具标准]C级道具
Proto.STANDARD_D	= Proto.STANDARD_C + 1	-- [分配道具标准]D级道具
Proto.STANDARD_E	= Proto.STANDARD_D + 1	-- [分配道具标准]E级道具
Proto.STANDARD_ALL	= Proto.STANDARD_E + 1	-- [分配道具标准]所有道具
Proto.TIT_NONE			= 0						-- [组队意图类型]考虑中
Proto.TIT_FARM			= Proto.TIT_NONE + 1	-- [组队意图类型]野外
Proto.TIT_REPETITION	= Proto.TIT_FARM + 1	-- [组队意图类型]副本

function Proto.parseDistributeMode(entry)
	local data={};
	data.itemdist=Proto.parseBYTE(entry); -- 道具分配方式,ItemDistribute
	data.diststan=Proto.parseBYTE(entry); -- 分配道具标准,DistributeStandard
	return data;
end

function Proto.writeDistributeMode(msg,data)
	Proto.writeBYTE(msg,data.itemdist); -- 道具分配方式,ItemDistribute
	Proto.writeBYTE(msg,data.diststan); -- 分配道具标准,DistributeStandard
end

function Proto.parseBattleArrayPos(entry)
	local data={};
	data.row=Proto.parseBYTE(entry); -- 阵形中排数
	data.line=Proto.parseBYTE(entry); -- 阵形中列数
	return data;
end

function Proto.writeBattleArrayPos(msg,data)
	Proto.writeBYTE(msg,data.row); -- 阵形中排数
	Proto.writeBYTE(msg,data.line); -- 阵形中列数
end

function Proto.parseBagPetBrief(entry)
	local data={};
	data.id=Proto.parsePetID(entry); -- PetID
	data.raceType=Proto.parseDWORD(entry); -- 宠物种族
	data.name=Proto.parseLifeNick(entry); -- 宠物名称
	data.level=Proto.parseWORD(entry); -- 宠物等级
	data.gender=Proto.parseBYTE(entry); -- 宠物等级
	return data;
end

function Proto.getBagPetBriefIDLen()
	return Proto.getPetIDLen();
end

function Proto.writeBagPetBrief(msg,data)
	Proto.writePetID(msg,data.id); -- PetID
	Proto.writeDWORD(msg,data.raceType); -- 宠物种族
	Proto.writeLifeNick(msg,data.name); -- 宠物名称
	Proto.writeWORD(msg,data.level); -- 宠物等级
	Proto.writeBYTE(msg,data.gender); -- 宠物等级
end

function Proto.parseTeamMember(entry)
	local data={};
	data.roleID=Proto.parseDWORD(entry); -- 角色ID
	data.name=Proto.parseUnitName(entry); -- 名称
	data.offline=Proto.parseBYTE(entry); -- 玩家是否掉线(0:未掉线)
	data.arrayPos=Proto.parseBattleArrayPos(entry); -- 阵形中位置
	if (data.offline==0) then
		data.havePet=Proto.parseBYTE(entry); -- 是否携带宠物(0:未携带,1:已携带)
	end
	if (data.offline==1) then
		data.petBrief=Proto.parseBagPetBrief(entry); -- 宠物信息
	end
	return data;
end

function Proto.writeTeamMember(msg,data)
	Proto.writeDWORD(msg,data.roleID); -- 角色ID
	Proto.writeUnitName(msg,data.name); -- 名称
	Proto.writeBYTE(msg,data.offline); -- 玩家是否掉线(0:未掉线)
	Proto.writeBattleArrayPos(msg,data.arrayPos); -- 阵形中位置
	if (data.offline==0) then
		Proto.writeBYTE(msg,data.havePet); -- 是否携带宠物(0:未携带,1:已携带)
	end
	if (data.offline==1) then
		Proto.writeBagPetBrief(msg,data.petBrief); -- 宠物信息
	end
end

function Proto.parseBattleArrayInfo(entry)
	local data={};
	data.roleID=Proto.parseDWORD(entry); -- 角色ID
	data.arrayPos=Proto.parseBattleArrayPos(entry); -- 阵形中位置
	return data;
end

function Proto.writeBattleArrayInfo(msg,data)
	Proto.writeDWORD(msg,data.roleID); -- 角色ID
	Proto.writeBattleArrayPos(msg,data.arrayPos); -- 阵形中位置
end

function Proto.parseTeamData(entry)
	local data={};
	data.teamID=Proto.parseDWORD(entry); -- 组队ID
	data.leaderID=Proto.parseDWORD(entry); -- 组队ID
	data.adventureID=Proto.parseDWORD(entry); -- 副本ID
	data.canAutoJoin=Proto.parseDWORD(entry); -- 能否自动匹配
	data.isStart=Proto.parseDWORD(entry); -- 是否开始
	data.teamSort=Proto.parseVector(entry,Proto.parseDWORD); -- 组队位置排列，空数组代表正常排列位置，[0,1,2]正常顺序排列
	return data;
end

function Proto.writeTeamData(msg,data)
	Proto.writeDWORD(msg,data.teamID); -- 组队ID
	Proto.writeDWORD(msg,data.leaderID); -- 组队ID
	Proto.writeDWORD(msg,data.adventureID); -- 副本ID
	Proto.writeDWORD(msg,data.canAutoJoin); -- 能否自动匹配
	Proto.writeDWORD(msg,data.isStart); -- 是否开始
	Proto.writeVector(msg,data.teamSort,Proto.writeDWORD); -- 组队位置排列，空数组代表正常排列位置，[0,1,2]正常顺序排列
end

function Proto.parseTeamMemberData(entry)
	local data={};
	data.charID=Proto.parseDWORD(entry); -- 玩家ID
	data.charInfo=Proto.parseString(entry); -- 玩家信息
	data.pets=Proto.parseVector(entry,Proto.parseString); -- 
	data.helperPets=Proto.parseVector(entry,Proto.parseString); -- 
	data.isReady=Proto.parseDWORD(entry); -- 是否准备
	return data;
end

function Proto.writeTeamMemberData(msg,data)
	Proto.writeDWORD(msg,data.charID); -- 玩家ID
	Proto.writeString(msg,data.charInfo); -- 玩家信息
	Proto.writeVector(msg,data.pets,Proto.writeString); -- 
	Proto.writeVector(msg,data.helperPets,Proto.writeString); -- 
	Proto.writeDWORD(msg,data.isReady); -- 是否准备
end

function Proto.parseTeamInfo(entry)
	local data={};
	data.teamID=Proto.parseDWORD(entry); -- 组队ID
	data.teamName=Proto.parseTeamName(entry); -- 组队名称
	data.leaderID=Proto.parseDWORD(entry); -- 队长ID
	data.diceID=Proto.parseDWORD(entry); -- 色子权ID
	data.open=Proto.parseBYTE(entry); -- 开放标志(0:不开放;非0:开放)
	data.mode=Proto.parseDistributeMode(entry); -- 分配模式
	data.members=Proto.parseVector(entry,Proto.parseTeamMember); -- 队伍成员
	return data;
end

function Proto.writeTeamInfo(msg,data)
	Proto.writeDWORD(msg,data.teamID); -- 组队ID
	Proto.writeTeamName(msg,data.teamName); -- 组队名称
	Proto.writeDWORD(msg,data.leaderID); -- 队长ID
	Proto.writeDWORD(msg,data.diceID); -- 色子权ID
	Proto.writeBYTE(msg,data.open); -- 开放标志(0:不开放;非0:开放)
	Proto.writeDistributeMode(msg,data.mode); -- 分配模式
	Proto.writeVector(msg,data.members,Proto.writeTeamMember); -- 队伍成员
end

function Proto.parseJoinableTeamInfo(entry)
	local data={};
	data.teamID=Proto.parseDWORD(entry); -- 队伍ID
	data.teamName=Proto.parseTeamName(entry); -- 组队名称
	data.members=Proto.parseBYTE(entry); -- 当前成员数
	data.leaderID=Proto.parseDWORD(entry); -- 队长ID
	data.leaderHandle=Proto.parseRoleHandle(entry); -- 队长Handle
	return data;
end

function Proto.writeJoinableTeamInfo(msg,data)
	Proto.writeDWORD(msg,data.teamID); -- 队伍ID
	Proto.writeTeamName(msg,data.teamName); -- 组队名称
	Proto.writeBYTE(msg,data.members); -- 当前成员数
	Proto.writeDWORD(msg,data.leaderID); -- 队长ID
	Proto.writeRoleHandle(msg,data.leaderHandle); -- 队长Handle
end

function Proto.parseTeamIntention_BODY_Farm(entry)
	local data={};
	data.townID=Proto.parseTownID(entry); -- 
	return data;
end

function Proto.writeTeamIntention_BODY_Farm(msg,data)
	Proto.writeTownID(msg,data.townID); -- 
end

function Proto.parseTeamIntention_BODY_Repetition(entry)
	local data={};
	data.repStyle=Proto.parseRepStyle(entry); -- 
	return data;
end

function Proto.writeTeamIntention_BODY_Repetition(msg,data)
	Proto.writeRepStyle(msg,data.repStyle); -- 
end

function Proto.parseTeamIntention(entry)
	local data={};
	data.type=Proto.parseBYTE(entry); -- 意图类型
	data.body={}; -- 内容
	if (data.type ==Proto.TIT_FARM) then
		data.body.farm=Proto.parseTeamIntention_BODY_Farm(entry); -- 
	end
	if (data.type ==Proto.TIT_REPETITION) then
		data.body.repetition=Proto.parseTeamIntention_BODY_Repetition(entry); -- 
	end
	return data;
end

function Proto.writeTeamIntention(msg,data)
	Proto.writeBYTE(msg,data.type); -- 意图类型
	if (data.type ==Proto.TIT_FARM) then
		Proto.writeTeamIntention_BODY_Farm(msg,data.body.farm); -- 
	end
	if (data.type ==Proto.TIT_REPETITION) then
		Proto.writeTeamIntention_BODY_Repetition(msg,data.body.repetition); -- 
	end
end

function Proto.parseTeamDungeonInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.mapID=Proto.parseDWORD(entry); -- 副本ID
	data.floor=Proto.parseDWORD(entry); -- 层数
	data.x=Proto.parseDWORD(entry); -- x
	data.y=Proto.parseDWORD(entry); -- x
	data.eventListID=Proto.parseDWORD(entry); -- 事件ID
	return data;
end

function Proto.getTeamDungeonInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeTeamDungeonInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeDWORD(msg,data.mapID); -- 副本ID
	Proto.writeDWORD(msg,data.floor); -- 层数
	Proto.writeDWORD(msg,data.x); -- x
	Proto.writeDWORD(msg,data.y); -- x
	Proto.writeDWORD(msg,data.eventListID); -- 事件ID
end

function Proto.parseTeamEventList(entry)
	local data={};
	data.eventType=Proto.parseDWORD(entry); -- 事件类型
	data.event=Proto.parseDWORD(entry); -- 事件ID
	data.rate=Proto.parseDWORD(entry); -- 概率
	return data;
end

function Proto.writeTeamEventList(msg,data)
	Proto.writeDWORD(msg,data.eventType); -- 事件类型
	Proto.writeDWORD(msg,data.event); -- 事件ID
	Proto.writeDWORD(msg,data.rate); -- 概率
end

function Proto.parseTeamEventInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.eventList=Proto.parseVector(entry,Proto.parseTeamEventList); -- 事件信息列表
	return data;
end

function Proto.getTeamEventInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeTeamEventInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeVector(msg,data.eventList,Proto.writeTeamEventList); -- 事件信息列表
end

function Proto.parseTeamObstacleInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.type=Proto.parseDWORD(entry); -- 类型
	data.iconRes=Proto.parseString(entry); -- 图标资源
	return data;
end

function Proto.getTeamObstacleInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeTeamObstacleInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeDWORD(msg,data.type); -- 类型
	Proto.writeString(msg,data.iconRes); -- 图标资源
end

function Proto.parseTeamTransferInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.type=Proto.parseDWORD(entry); -- 类型
	data.picRes=Proto.parseString(entry); -- 图标资源
	return data;
end

function Proto.getTeamTransferInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeTeamTransferInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeDWORD(msg,data.type); -- 类型
	Proto.writeString(msg,data.picRes); -- 图标资源
end

function Proto.parseTeamMonsterInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.number=Proto.parseString(entry); -- 怪物编号
	data.petnumber=Proto.parseDWORD(entry); -- 宠物编号
	data.maxHP=Proto.parseDWORD(entry); -- 最大血量
	data.level=Proto.parseDWORD(entry); -- 宠物等级
	data.petStage=Proto.parseDWORD(entry); -- 宠物强化等级
	data.petStar=Proto.parseDWORD(entry); -- 宠物星数
	data.amendmentHP=Proto.parseDWORD(entry); -- HP修正比例
	data.amendmentSPD=Proto.parseDWORD(entry); -- SPD修正比例
	data.amendmentATK=Proto.parseDWORD(entry); -- ATK修正比例
	data.amendmentDEF=Proto.parseDWORD(entry); -- DEF修正比例
	data.amendmentSATK=Proto.parseDWORD(entry); -- SATK修正比例
	data.amendmentSDEF=Proto.parseDWORD(entry); -- SDEF修正比例
	data.awardItems=Proto.parseVector(entry,Proto.parseDWORD); -- 奖励道具
	data.awardCounts=Proto.parseVector(entry,Proto.parseDWORD); -- 奖励数量
	data.skill1=Proto.parseVector(entry,Proto.parseDWORD); -- 怪物技能1
	data.skill2=Proto.parseVector(entry,Proto.parseDWORD); -- 怪物技能2
	data.skill3=Proto.parseVector(entry,Proto.parseDWORD); -- 怪物技能3
	data.skill4=Proto.parseDWORD(entry); -- 怪物技能4
	data.skill1_pro=Proto.parseDWORD(entry); -- 怪物技能1发动概率
	data.skill2_pro=Proto.parseDWORD(entry); -- 怪物技能2发动概率
	data.skill3_pro=Proto.parseDWORD(entry); -- 怪物技能3发动概率
	data.skill4_pro=Proto.parseDWORD(entry); -- 怪物技能4发动概率
	data.catchRate=Proto.parseDWORD(entry); -- 捕获率
	data.away=Proto.parseDWORD(entry); -- 逃跑率
	data.capture=Proto.parseDWORD(entry); -- 最大捕获机会
	data.paSkills=Proto.parseVector(entry,Proto.parseDWORD); -- 被动技能
	data.petGeneID=Proto.parseDWORD(entry); -- 宠物生成ID
	data.mailID=Proto.parseDWORD(entry); -- 奖励邮件ID
	data.contribute=Proto.parseDWORD(entry); -- 贡献度
	data.badge=Proto.parseDWORD(entry); -- 徽章
	return data;
end

function Proto.getTeamMonsterInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeTeamMonsterInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeString(msg,data.number); -- 怪物编号
	Proto.writeDWORD(msg,data.petnumber); -- 宠物编号
	Proto.writeDWORD(msg,data.maxHP); -- 最大血量
	Proto.writeDWORD(msg,data.level); -- 宠物等级
	Proto.writeDWORD(msg,data.petStage); -- 宠物强化等级
	Proto.writeDWORD(msg,data.petStar); -- 宠物星数
	Proto.writeDWORD(msg,data.amendmentHP); -- HP修正比例
	Proto.writeDWORD(msg,data.amendmentSPD); -- SPD修正比例
	Proto.writeDWORD(msg,data.amendmentATK); -- ATK修正比例
	Proto.writeDWORD(msg,data.amendmentDEF); -- DEF修正比例
	Proto.writeDWORD(msg,data.amendmentSATK); -- SATK修正比例
	Proto.writeDWORD(msg,data.amendmentSDEF); -- SDEF修正比例
	Proto.writeVector(msg,data.awardItems,Proto.writeDWORD); -- 奖励道具
	Proto.writeVector(msg,data.awardCounts,Proto.writeDWORD); -- 奖励数量
	Proto.writeVector(msg,data.skill1,Proto.writeDWORD); -- 怪物技能1
	Proto.writeVector(msg,data.skill2,Proto.writeDWORD); -- 怪物技能2
	Proto.writeVector(msg,data.skill3,Proto.writeDWORD); -- 怪物技能3
	Proto.writeDWORD(msg,data.skill4); -- 怪物技能4
	Proto.writeDWORD(msg,data.skill1_pro); -- 怪物技能1发动概率
	Proto.writeDWORD(msg,data.skill2_pro); -- 怪物技能2发动概率
	Proto.writeDWORD(msg,data.skill3_pro); -- 怪物技能3发动概率
	Proto.writeDWORD(msg,data.skill4_pro); -- 怪物技能4发动概率
	Proto.writeDWORD(msg,data.catchRate); -- 捕获率
	Proto.writeDWORD(msg,data.away); -- 逃跑率
	Proto.writeDWORD(msg,data.capture); -- 最大捕获机会
	Proto.writeVector(msg,data.paSkills,Proto.writeDWORD); -- 被动技能
	Proto.writeDWORD(msg,data.petGeneID); -- 宠物生成ID
	Proto.writeDWORD(msg,data.mailID); -- 奖励邮件ID
	Proto.writeDWORD(msg,data.contribute); -- 贡献度
	Proto.writeDWORD(msg,data.badge); -- 徽章
end

function Proto.parseTeamFloorInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 副本ID
	data.maxFloor=Proto.parseDWORD(entry); -- 最大楼层
	data.maxKill=Proto.parseDWORD(entry); -- 击杀个数显示BOSS
	data.name=Proto.parseString(entry); -- 副本名称
	data.enterMinLevel=Proto.parseDWORD(entry); -- 最小进入等级
	data.enterMaxLevel=Proto.parseDWORD(entry); -- 最大进入等级
	data.animationRes=Proto.parseString(entry); -- 副本动画资源
	data.awardChestIDs=Proto.parseVector(entry,Proto.parseDWORD); -- 奖励池1宝箱ID
	data.awardRates=Proto.parseVector(entry,Proto.parseDWORD); -- 奖励池1宝箱概率
	data.awardChestCount=Proto.parseDWORD(entry); -- 奖励池1宝箱个数
	data.awardChestIDsTwo=Proto.parseVector(entry,Proto.parseDWORD); -- 奖励池2宝箱ID
	data.awardRates2=Proto.parseVector(entry,Proto.parseDWORD); -- 奖励池2宝箱概率
	data.awardChestCount2=Proto.parseDWORD(entry); -- 奖励池2宝箱个数
	data.sence=Proto.parseDWORD(entry); -- 场景
	return data;
end

function Proto.getTeamFloorInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeTeamFloorInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 副本ID
	Proto.writeDWORD(msg,data.maxFloor); -- 最大楼层
	Proto.writeDWORD(msg,data.maxKill); -- 击杀个数显示BOSS
	Proto.writeString(msg,data.name); -- 副本名称
	Proto.writeDWORD(msg,data.enterMinLevel); -- 最小进入等级
	Proto.writeDWORD(msg,data.enterMaxLevel); -- 最大进入等级
	Proto.writeString(msg,data.animationRes); -- 副本动画资源
	Proto.writeVector(msg,data.awardChestIDs,Proto.writeDWORD); -- 奖励池1宝箱ID
	Proto.writeVector(msg,data.awardRates,Proto.writeDWORD); -- 奖励池1宝箱概率
	Proto.writeDWORD(msg,data.awardChestCount); -- 奖励池1宝箱个数
	Proto.writeVector(msg,data.awardChestIDsTwo,Proto.writeDWORD); -- 奖励池2宝箱ID
	Proto.writeVector(msg,data.awardRates2,Proto.writeDWORD); -- 奖励池2宝箱概率
	Proto.writeDWORD(msg,data.awardChestCount2); -- 奖励池2宝箱个数
	Proto.writeDWORD(msg,data.sence); -- 场景
end

function Proto.parseTeamPickUpItemInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.itemID=Proto.parseDWORD(entry); -- 物品ID
	data.count=Proto.parseDWORD(entry); -- 个数
	return data;
end

function Proto.getTeamPickUpItemInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeTeamPickUpItemInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeDWORD(msg,data.itemID); -- 物品ID
	Proto.writeDWORD(msg,data.count); -- 个数
end

function Proto.parseTeamItemInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.name=Proto.parseString(entry); -- 名称
	data.picRes=Proto.parseString(entry); -- 图片资源
	return data;
end

function Proto.getTeamItemInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeTeamItemInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeString(msg,data.name); -- 名称
	Proto.writeString(msg,data.picRes); -- 图片资源
end

function Proto.parseTeamMonsterHp(entry)
	local data={};
	data.monsterID=Proto.parseDWORD(entry); -- 怪物血量
	data.hp=Proto.parseDWORD(entry); -- 血量
	return data;
end

function Proto.writeTeamMonsterHp(msg,data)
	Proto.writeDWORD(msg,data.monsterID); -- 怪物血量
	Proto.writeDWORD(msg,data.hp); -- 血量
end

