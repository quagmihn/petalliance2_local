-- Net.Proto.Proto_Expedition_Types

Proto.EQT_PETCOUNT	= 0							-- []使用宠物个数
Proto.EQT_PETTYPE	= Proto.EQT_PETCOUNT + 1	-- []使用指定系别宠物
Proto.EQT_ROUND		= Proto.EQT_PETTYPE + 1		-- []回合数限制
Proto.EQT_PETLEVEL	= Proto.EQT_ROUND + 1		-- []使用宠物等级
Proto.EDT_NONE		= 0							-- []当前难度
Proto.EDT_EASY		= Proto.EDT_NONE + 1		-- []简单
Proto.EDT_NORMAL	= Proto.EDT_EASY + 1		-- []普通
Proto.EDT_HARD		= Proto.EDT_NORMAL + 1		-- []困难
Proto.EDT_NIGHTMARE	= Proto.EDT_HARD + 1		-- []噩梦
Proto.EDT_HELL		= Proto.EDT_NIGHTMARE + 1	-- []地狱

function Proto.parseExpeditionInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.easyPool=Proto.parseDWORD(entry); -- 简单难度怪物池
	data.normalPool=Proto.parseDWORD(entry); -- 普通难度怪物池
	data.hardPool=Proto.parseDWORD(entry); -- 困难难度怪物池
	data.nightmarePool=Proto.parseDWORD(entry); -- 噩梦难度怪物池
	data.hellPool=Proto.parseDWORD(entry); -- 地狱难度怪物池
	data.questCount=Proto.parseDWORD(entry); -- 任务个数
	data.easyDropID=Proto.parseDWORD(entry); -- 普通掉落ID
	data.normalDropID=Proto.parseDWORD(entry); -- 普通掉落ID
	data.hardDropID=Proto.parseDWORD(entry); -- 困难掉落ID
	data.nightmareDropID=Proto.parseDWORD(entry); -- 噩梦掉落ID
	data.hellDropID=Proto.parseDWORD(entry); -- 噩梦掉落ID
	data.easyDisplay=Proto.parseVector(entry,Proto.parseDWORD); -- 简单掉落显示
	data.normalDisplay=Proto.parseVector(entry,Proto.parseDWORD); -- 普通掉落显示
	data.hardDisplay=Proto.parseVector(entry,Proto.parseDWORD); -- 困难掉落显示
	data.nightmareDisplay=Proto.parseVector(entry,Proto.parseDWORD); -- 噩梦掉落显示
	data.hellDisplay=Proto.parseVector(entry,Proto.parseDWORD); -- 地狱掉落显示
	return data;
end

function Proto.getExpeditionInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeExpeditionInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeDWORD(msg,data.easyPool); -- 简单难度怪物池
	Proto.writeDWORD(msg,data.normalPool); -- 普通难度怪物池
	Proto.writeDWORD(msg,data.hardPool); -- 困难难度怪物池
	Proto.writeDWORD(msg,data.nightmarePool); -- 噩梦难度怪物池
	Proto.writeDWORD(msg,data.hellPool); -- 地狱难度怪物池
	Proto.writeDWORD(msg,data.questCount); -- 任务个数
	Proto.writeDWORD(msg,data.easyDropID); -- 普通掉落ID
	Proto.writeDWORD(msg,data.normalDropID); -- 普通掉落ID
	Proto.writeDWORD(msg,data.hardDropID); -- 困难掉落ID
	Proto.writeDWORD(msg,data.nightmareDropID); -- 噩梦掉落ID
	Proto.writeDWORD(msg,data.hellDropID); -- 噩梦掉落ID
	Proto.writeVector(msg,data.easyDisplay,Proto.writeDWORD); -- 简单掉落显示
	Proto.writeVector(msg,data.normalDisplay,Proto.writeDWORD); -- 普通掉落显示
	Proto.writeVector(msg,data.hardDisplay,Proto.writeDWORD); -- 困难掉落显示
	Proto.writeVector(msg,data.nightmareDisplay,Proto.writeDWORD); -- 噩梦掉落显示
	Proto.writeVector(msg,data.hellDisplay,Proto.writeDWORD); -- 地狱掉落显示
end

function Proto.parseMonsterDetail(entry)
	local data={};
	data.monsterID=Proto.parseDWORD(entry); -- 怪物ID
	data.weight=Proto.parseDWORD(entry); -- 权重
	return data;
end

function Proto.writeMonsterDetail(msg,data)
	Proto.writeDWORD(msg,data.monsterID); -- 怪物ID
	Proto.writeDWORD(msg,data.weight); -- 权重
end

function Proto.parseExpeditionMonsterPoolInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.monsterList=Proto.parseVector(entry,Proto.parseMonsterDetail); -- 怪物列表
	return data;
end

function Proto.getExpeditionMonsterPoolInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeExpeditionMonsterPoolInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeVector(msg,data.monsterList,Proto.writeMonsterDetail); -- 怪物列表
end

function Proto.parseExpeditionMonsterInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.level=Proto.parseDWORD(entry); -- 宠物等级
	data.number=Proto.parseString(entry); -- 怪物编号
	data.petnumber=Proto.parseDWORD(entry); -- 宠物编号
	data.maxHP=Proto.parseDWORD(entry); -- 最大血量
	data.petStage=Proto.parseDWORD(entry); -- 宠物强化等级
	data.petStar=Proto.parseDWORD(entry); -- 宠物星数
	data.amendmentHP=Proto.parseDWORD(entry); -- HP修正比例
	data.amendmentSPD=Proto.parseDWORD(entry); -- SPD修正比例
	data.amendmentATK=Proto.parseDWORD(entry); -- ATK修正比例
	data.amendmentDEF=Proto.parseDWORD(entry); -- DEF修正比例
	data.amendmentSATK=Proto.parseDWORD(entry); -- SATK修正比例
	data.amendmentSDEF=Proto.parseDWORD(entry); -- SDEF修正比例
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
	data.quests=Proto.parseVector(entry,Proto.parseDWORD); -- 任务列表
	return data;
end

function Proto.getExpeditionMonsterInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeExpeditionMonsterInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeDWORD(msg,data.level); -- 宠物等级
	Proto.writeString(msg,data.number); -- 怪物编号
	Proto.writeDWORD(msg,data.petnumber); -- 宠物编号
	Proto.writeDWORD(msg,data.maxHP); -- 最大血量
	Proto.writeDWORD(msg,data.petStage); -- 宠物强化等级
	Proto.writeDWORD(msg,data.petStar); -- 宠物星数
	Proto.writeDWORD(msg,data.amendmentHP); -- HP修正比例
	Proto.writeDWORD(msg,data.amendmentSPD); -- SPD修正比例
	Proto.writeDWORD(msg,data.amendmentATK); -- ATK修正比例
	Proto.writeDWORD(msg,data.amendmentDEF); -- DEF修正比例
	Proto.writeDWORD(msg,data.amendmentSATK); -- SATK修正比例
	Proto.writeDWORD(msg,data.amendmentSDEF); -- SDEF修正比例
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
	Proto.writeVector(msg,data.quests,Proto.writeDWORD); -- 任务列表
end

function Proto.parseFinishQuestList(entry)
	local data={};
	data.quests=Proto.parseVector(entry,Proto.parseDWORD); -- 任务ID
	return data;
end

function Proto.writeFinishQuestList(msg,data)
	Proto.writeVector(msg,data.quests,Proto.writeDWORD); -- 任务ID
end

function Proto.parseMapInfo(entry)
	local data={};
	data.monsterID=Proto.parseDWORD(entry); -- 怪物ID
	data.hp=Proto.parseDWORD(entry); -- 血量
	data.quests=Proto.parseVector(entry,Proto.parseDWORD); -- 怪物携带任务
	return data;
end

function Proto.writeMapInfo(msg,data)
	Proto.writeDWORD(msg,data.monsterID); -- 怪物ID
	Proto.writeDWORD(msg,data.hp); -- 血量
	Proto.writeVector(msg,data.quests,Proto.writeDWORD); -- 怪物携带任务
end

function Proto.parseExpeditionQuestInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.type=Proto.parseDWORD(entry); -- 类型
	data.param=Proto.parseDWORD(entry); -- 参数
	data.awardID=Proto.parseDWORD(entry); -- 奖励ID
	data.awardCount=Proto.parseDWORD(entry); -- 奖励个数
	data.clientDisplay=Proto.parseString(entry); -- 客户端显示字段
	return data;
end

function Proto.getExpeditionQuestInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeExpeditionQuestInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeDWORD(msg,data.type); -- 类型
	Proto.writeDWORD(msg,data.param); -- 参数
	Proto.writeDWORD(msg,data.awardID); -- 奖励ID
	Proto.writeDWORD(msg,data.awardCount); -- 奖励个数
	Proto.writeString(msg,data.clientDisplay); -- 客户端显示字段
end

function Proto.parsePetDetail(entry)
	local data={};
	data.currentPet=Proto.parseDWORD(entry); -- 当前宠物ObjID
	data.currentPetHp=Proto.parseDWORD(entry); -- 当前宠物血量
	return data;
end

function Proto.writePetDetail(msg,data)
	Proto.writeDWORD(msg,data.currentPet); -- 当前宠物ObjID
	Proto.writeDWORD(msg,data.currentPetHp); -- 当前宠物血量
end

function Proto.parseExpeditionData(entry)
	local data={};
	data.createTime=Proto.parseDWORD(entry); -- 创建时间
	data.currentSchedule=Proto.parseDWORD(entry); -- 当前进度
	data.point=Proto.parseDWORD(entry); -- 分数
	data.level=Proto.parseDWORD(entry); -- 难度
	data.petCount=Proto.parseDWORD(entry); -- 宠物个数
	data.usedPets=Proto.parseVector(entry,Proto.parseDWORD); -- 已使用过的宠物
	data.mapList=Proto.parseVector(entry,Proto.parseMapInfo); -- 地图信息
	data.finishQuest=Proto.parseVector(entry,Proto.parseFinishQuestList); -- 已完成任务列表
	data.usedCount=Proto.parseDWORD(entry); -- 已经使用积分
	data.buyCount=Proto.parseDWORD(entry); -- 购买积分次数
	return data;
end

function Proto.writeExpeditionData(msg,data)
	Proto.writeDWORD(msg,data.createTime); -- 创建时间
	Proto.writeDWORD(msg,data.currentSchedule); -- 当前进度
	Proto.writeDWORD(msg,data.point); -- 分数
	Proto.writeDWORD(msg,data.level); -- 难度
	Proto.writeDWORD(msg,data.petCount); -- 宠物个数
	Proto.writeVector(msg,data.usedPets,Proto.writeDWORD); -- 已使用过的宠物
	Proto.writeVector(msg,data.mapList,Proto.writeMapInfo); -- 地图信息
	Proto.writeVector(msg,data.finishQuest,Proto.writeFinishQuestList); -- 已完成任务列表
	Proto.writeDWORD(msg,data.usedCount); -- 已经使用积分
	Proto.writeDWORD(msg,data.buyCount); -- 购买积分次数
end

function Proto.parseLotteryAwardList(entry)
	local data={};
	data.awardID=Proto.parseDWORD(entry); -- 奖励ID
	data.awardCount=Proto.parseDWORD(entry); -- 奖励个数
	data.weight=Proto.parseDWORD(entry); -- 权重
	return data;
end

function Proto.writeLotteryAwardList(msg,data)
	Proto.writeDWORD(msg,data.awardID); -- 奖励ID
	Proto.writeDWORD(msg,data.awardCount); -- 奖励个数
	Proto.writeDWORD(msg,data.weight); -- 权重
end

function Proto.parseExpeditionLotteryInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 难度1普通,2困难,3噩梦
	data.lotteryAwardList=Proto.parseVector(entry,Proto.parseLotteryAwardList); -- 奖励信息列表
	return data;
end

function Proto.getExpeditionLotteryInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeExpeditionLotteryInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 难度1普通,2困难,3噩梦
	Proto.writeVector(msg,data.lotteryAwardList,Proto.writeLotteryAwardList); -- 奖励信息列表
end

function Proto.parseLotteryBuyCountInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.costCount=Proto.parseDWORD(entry); -- 消耗钻石数
	return data;
end

function Proto.getLotteryBuyCountInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeLotteryBuyCountInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeDWORD(msg,data.costCount); -- 消耗钻石数
end

