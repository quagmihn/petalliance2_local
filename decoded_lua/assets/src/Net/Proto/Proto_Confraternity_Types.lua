-- Net.Proto.Proto_Confraternity_Types

Proto.FQT_NONE		= 0						-- [家族任务类型]
Proto.FQT_SEARCH	= Proto.FQT_NONE + 1	-- [家族任务类型]
Proto.FQT_ARREST	= Proto.FQT_SEARCH + 1	-- [家族任务类型]
Proto.FQT_PATROL	= Proto.FQT_ARREST + 1	-- [家族任务类型]
Proto.FQT_MONSTER	= Proto.FQT_PATROL + 1	-- [家族任务类型]
Proto.FDET_NONE				= 0									-- [家族副本事件类型]空事件
Proto.FDET_PICKITEM			= Proto.FDET_NONE + 1				-- [家族副本事件类型]拾取道具
Proto.FDET_PVE				= Proto.FDET_PICKITEM + 1			-- [家族副本事件类型]PVE战斗
Proto.FDET_OBSTACLE			= Proto.FDET_PVE + 1				-- [家族副本事件类型]障碍物
Proto.FDET_EXIT				= Proto.FDET_OBSTACLE + 1			-- [家族副本事件类型]出口
Proto.FDET_START			= Proto.FDET_EXIT + 1				-- [家族副本事件类型]起点
Proto.FDET_MECHANISM		= Proto.FDET_START + 1				-- [家族副本事件类型]机关
Proto.FDET_TRANS			= Proto.FDET_MECHANISM + 1			-- [家族副本事件类型]传送
Proto.FDET_TRAINER			= Proto.FDET_TRANS + 1				-- [家族副本事件类型]训练师
Proto.FDET_ATTRIBUTECHANGE	= Proto.FDET_TRAINER + 1			-- [家族副本事件类型]属性变化
Proto.FDET_RANDOMCHEST		= Proto.FDET_ATTRIBUTECHANGE + 1	-- [家族副本事件类型]随机宝箱
Proto.FDET_RECOVER			= Proto.FDET_RANDOMCHEST + 1		-- [家族副本事件类型]恢复
Proto.FDET_SPECIALEFFECT	= Proto.FDET_RECOVER + 1			-- [家族副本事件类型]特殊效果
Proto.FDET_NPC				= Proto.FDET_SPECIALEFFECT + 1		-- [家族副本事件类型]稀有NPC
Proto.FDET_RANDOMEVENT		= Proto.FDET_NPC + 1				-- [家族副本事件类型]随机事件
Proto.FDET_STATIONARYAWARD	= Proto.FDET_RANDOMEVENT + 1		-- [家族副本事件类型]固定奖励
Proto.FDET_PVPBATTLE		= Proto.FDET_STATIONARYAWARD + 1	-- [家族副本事件类型]PVP战斗
Proto.FDET_BOSS				= Proto.FDET_PVPBATTLE + 1			-- [家族副本事件类型]BOSS事件
Proto.FDET_TRIP				= Proto.FDET_BOSS + 1				-- [家族副本事件类型]陷阱
Proto.FDET_COLLECTION		= Proto.FDET_TRIP + 1				-- [家族副本事件类型]采集
Proto.FDCT_BATTLESTART	= 0								-- [家族命令类型]战斗开始
Proto.FDCT_BATTLEEND	= Proto.FDCT_BATTLESTART + 1	-- [家族命令类型]战斗结束
Proto.FDCT_KILLBOSS		= Proto.FDCT_BATTLEEND + 1		-- [家族命令类型]击杀boss
Proto.FDCT_OPENCHEST	= Proto.FDCT_KILLBOSS + 1		-- [家族命令类型]打开宝箱
Proto.FDCT_BUFF			= Proto.FDCT_OPENCHEST + 1		-- [家族命令类型]BUFF增加
Proto.FDCT_MOVECELL		= Proto.FDCT_BUFF + 1			-- [家族命令类型]移动格子
Proto.FDCT_CLEARCELL	= Proto.FDCT_MOVECELL + 1		-- [家族命令类型]格子清空
Proto.FDCT_LEAVEFLOOR	= Proto.FDCT_CLEARCELL + 1		-- [家族命令类型]离开楼层
Proto.FDCT_DISPLAYCELL	= Proto.FDCT_LEAVEFLOOR + 1		-- [家族命令类型]显示格子内容
Proto.FBT_NONE				= 0								-- [家族buff类型]无
Proto.FBT_PHYSICALATTACK	= Proto.FBT_NONE + 1			-- [家族buff类型]物理攻击
Proto.FBT_PHYSICALDEFENSE	= Proto.FBT_PHYSICALATTACK + 1	-- [家族buff类型]物理攻击
Proto.FBT_MAGICATTACK		= Proto.FBT_PHYSICALDEFENSE + 1	-- [家族buff类型]魔法攻击
Proto.FBT_MAGICDEFENSE		= Proto.FBT_MAGICATTACK + 1		-- [家族buff类型]魔法防御
Proto.FBT_HP				= Proto.FBT_MAGICDEFENSE + 1	-- [家族buff类型]血量

function Proto.parseFamilyQuestInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- id
	data.familyQuestType=Proto.parseDWORD(entry); -- 类型
	data.name=Proto.parseString(entry); -- 名称
	data.icon=Proto.parseString(entry); -- 图标
	data.classType=Proto.parseDWORD(entry); -- 级别
	data.level=Proto.parseDWORD(entry); -- 家族等级
	data.charLevel=Proto.parseDWORD(entry); -- 家族等级
	data.rate=Proto.parseDWORD(entry); -- 权重
	data.desc=Proto.parseString(entry); -- 描述
	data.params=Proto.parseVector(entry,Proto.parseDWORD); -- 参数
	data.awardElements=Proto.parseVector(entry,Proto.parseDWORD); -- 奖励元素
	data.awardElementNums=Proto.parseVector(entry,Proto.parseDWORD); -- 奖励数量
	data.devotePoint=Proto.parseDWORD(entry); -- 贡献度
	data.familyCoin=Proto.parseDWORD(entry); -- 公会徽章
	data.groupType=Proto.parseDWORD(entry); -- 组别
	return data;
end

function Proto.getFamilyQuestInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeFamilyQuestInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- id
	Proto.writeDWORD(msg,data.familyQuestType); -- 类型
	Proto.writeString(msg,data.name); -- 名称
	Proto.writeString(msg,data.icon); -- 图标
	Proto.writeDWORD(msg,data.classType); -- 级别
	Proto.writeDWORD(msg,data.level); -- 家族等级
	Proto.writeDWORD(msg,data.charLevel); -- 家族等级
	Proto.writeDWORD(msg,data.rate); -- 权重
	Proto.writeString(msg,data.desc); -- 描述
	Proto.writeVector(msg,data.params,Proto.writeDWORD); -- 参数
	Proto.writeVector(msg,data.awardElements,Proto.writeDWORD); -- 奖励元素
	Proto.writeVector(msg,data.awardElementNums,Proto.writeDWORD); -- 奖励数量
	Proto.writeDWORD(msg,data.devotePoint); -- 贡献度
	Proto.writeDWORD(msg,data.familyCoin); -- 公会徽章
	Proto.writeDWORD(msg,data.groupType); -- 组别
end

function Proto.parseFamilyLevelInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- id
	data.familyCoin=Proto.parseDWORD(entry); -- 公会徽章
	data.donationLimit=Proto.parseDWORD(entry); -- 捐赠上限
	data.resetFamilyQuestCost=Proto.parseDWORD(entry); -- 重置任务费用
	return data;
end

function Proto.getFamilyLevelInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeFamilyLevelInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- id
	Proto.writeDWORD(msg,data.familyCoin); -- 公会徽章
	Proto.writeDWORD(msg,data.donationLimit); -- 捐赠上限
	Proto.writeDWORD(msg,data.resetFamilyQuestCost); -- 重置任务费用
end

function Proto.parseFamilyDevoteBufferInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- id
	data.bufferRate=Proto.parseDWORD(entry); -- 
	return data;
end

function Proto.getFamilyDevoteBufferInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeFamilyDevoteBufferInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- id
	Proto.writeDWORD(msg,data.bufferRate); -- 
end

function Proto.parseFamilyRandomChestInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.openCount=Proto.parseDWORD(entry); -- 打开次数
	data.display=Proto.parseString(entry); -- 显示
	data.awardElements=Proto.parseVector(entry,Proto.parseDWORD); -- 奖励元素
	data.awardElementNums=Proto.parseVector(entry,Proto.parseDWORD); -- 奖励个数
	data.contribute=Proto.parseDWORD(entry); -- 贡献度
	data.picRes=Proto.parseString(entry); -- 
	return data;
end

function Proto.getFamilyRandomChestInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeFamilyRandomChestInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeDWORD(msg,data.openCount); -- 打开次数
	Proto.writeString(msg,data.display); -- 显示
	Proto.writeVector(msg,data.awardElements,Proto.writeDWORD); -- 奖励元素
	Proto.writeVector(msg,data.awardElementNums,Proto.writeDWORD); -- 奖励个数
	Proto.writeDWORD(msg,data.contribute); -- 贡献度
	Proto.writeString(msg,data.picRes); -- 
end

function Proto.parseFamilyAttributeChangeInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.values=Proto.parseDWORD(entry); -- 数值
	data.display=Proto.parseString(entry); -- 显示
	data.type=Proto.parseDWORD(entry); -- 类型
	data.contribute=Proto.parseDWORD(entry); -- 采集贡献度
	data.picRes=Proto.parseString(entry); -- 图片资源
	return data;
end

function Proto.getFamilyAttributeChangeInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeFamilyAttributeChangeInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeDWORD(msg,data.values); -- 数值
	Proto.writeString(msg,data.display); -- 显示
	Proto.writeDWORD(msg,data.type); -- 类型
	Proto.writeDWORD(msg,data.contribute); -- 采集贡献度
	Proto.writeString(msg,data.picRes); -- 图片资源
end

function Proto.parseFamilyMonsterInfo(entry)
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

function Proto.getFamilyMonsterInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeFamilyMonsterInfo(msg,data)
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

function Proto.parseFamilyDungeonInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.mapID=Proto.parseDWORD(entry); -- 副本ID
	data.x=Proto.parseDWORD(entry); -- x
	data.y=Proto.parseDWORD(entry); -- x
	data.eventListID=Proto.parseDWORD(entry); -- 事件ID
	return data;
end

function Proto.getFamilyDungeonInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeFamilyDungeonInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeDWORD(msg,data.mapID); -- 副本ID
	Proto.writeDWORD(msg,data.x); -- x
	Proto.writeDWORD(msg,data.y); -- x
	Proto.writeDWORD(msg,data.eventListID); -- 事件ID
end

function Proto.parseFamilyEventList(entry)
	local data={};
	data.eventType=Proto.parseDWORD(entry); -- 事件类型
	data.event=Proto.parseDWORD(entry); -- 事件ID
	data.rate=Proto.parseDWORD(entry); -- 概率
	return data;
end

function Proto.writeFamilyEventList(msg,data)
	Proto.writeDWORD(msg,data.eventType); -- 事件类型
	Proto.writeDWORD(msg,data.event); -- 事件ID
	Proto.writeDWORD(msg,data.rate); -- 概率
end

function Proto.parseFamilyEventInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.eventList=Proto.parseVector(entry,Proto.parseFamilyEventList); -- 事件信息列表
	return data;
end

function Proto.getFamilyEventInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeFamilyEventInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeVector(msg,data.eventList,Proto.writeFamilyEventList); -- 事件信息列表
end

function Proto.parseFamilyDungeonCell(entry)
	local data={};
	data.x=Proto.parseDWORD(entry); -- x
	data.y=Proto.parseDWORD(entry); -- y
	data.eventID=Proto.parseDWORD(entry); -- 事件ID
	data.eventType=Proto.parseDWORD(entry); -- 事件类型
	data.isDisplay=Proto.parseDWORD(entry); -- 是否显示
	data.data=Proto.parseString(entry); -- 格子其他内容
	return data;
end

function Proto.writeFamilyDungeonCell(msg,data)
	Proto.writeDWORD(msg,data.x); -- x
	Proto.writeDWORD(msg,data.y); -- y
	Proto.writeDWORD(msg,data.eventID); -- 事件ID
	Proto.writeDWORD(msg,data.eventType); -- 事件类型
	Proto.writeDWORD(msg,data.isDisplay); -- 是否显示
	Proto.writeString(msg,data.data); -- 格子其他内容
end

function Proto.parseFamilyMapRandomRuleInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 层数
	data.mapList=Proto.parseVector(entry,Proto.parseDWORD); -- 地图列表
	return data;
end

function Proto.getFamilyMapRandomRuleInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeFamilyMapRandomRuleInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 层数
	Proto.writeVector(msg,data.mapList,Proto.writeDWORD); -- 地图列表
end

function Proto.parseFamilyDungeonPos(entry)
	local data={};
	data.x=Proto.parseDWORD(entry); -- x
	data.y=Proto.parseDWORD(entry); -- y
	return data;
end

function Proto.writeFamilyDungeonPos(msg,data)
	Proto.writeDWORD(msg,data.x); -- x
	Proto.writeDWORD(msg,data.y); -- y
end

function Proto.parseFamilyMemberData(entry)
	local data={};
	data.name=Proto.parseString(entry); -- 名称
	data.charID=Proto.parseDWORD(entry); -- 玩家ID
	data.pos=Proto.parseFamilyDungeonPos(entry); -- 所在副本位置
	data.floor=Proto.parseDWORD(entry); -- 层数
	data.world=Proto.parseDWORD(entry); -- 世界
	data.fashions=Proto.parseVector(entry,Proto.parseDWORD); -- 时装信息
	data.gender=Proto.parseDWORD(entry); -- 性别
	data.level=Proto.parseDWORD(entry); -- 等级
	return data;
end

function Proto.writeFamilyMemberData(msg,data)
	Proto.writeString(msg,data.name); -- 名称
	Proto.writeDWORD(msg,data.charID); -- 玩家ID
	Proto.writeFamilyDungeonPos(msg,data.pos); -- 所在副本位置
	Proto.writeDWORD(msg,data.floor); -- 层数
	Proto.writeDWORD(msg,data.world); -- 世界
	Proto.writeVector(msg,data.fashions,Proto.writeDWORD); -- 时装信息
	Proto.writeDWORD(msg,data.gender); -- 性别
	Proto.writeDWORD(msg,data.level); -- 等级
end

function Proto.parseFamilyObstacleInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.type=Proto.parseDWORD(entry); -- 类型
	data.iconRes=Proto.parseString(entry); -- 图标资源
	return data;
end

function Proto.getFamilyObstacleInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeFamilyObstacleInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeDWORD(msg,data.type); -- 类型
	Proto.writeString(msg,data.iconRes); -- 图标资源
end

function Proto.parseFamilyTransferInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.type=Proto.parseDWORD(entry); -- 类型
	data.picRes=Proto.parseString(entry); -- 图标资源
	return data;
end

function Proto.getFamilyTransferInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeFamilyTransferInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeDWORD(msg,data.type); -- 类型
	Proto.writeString(msg,data.picRes); -- 图标资源
end

function Proto.parseFamilyAwardInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.awardElements=Proto.parseVector(entry,Proto.parseDWORD); -- 奖励道具
	data.awardCounts=Proto.parseVector(entry,Proto.parseDWORD); -- 奖励数量
	return data;
end

function Proto.getFamilyAwardInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeFamilyAwardInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeVector(msg,data.awardElements,Proto.writeDWORD); -- 奖励道具
	Proto.writeVector(msg,data.awardCounts,Proto.writeDWORD); -- 奖励数量
end

function Proto.parseDungeonLogData(entry)
	local data={};
	data.charID=Proto.parseDWORD(entry); -- 玩家ID
	data.action=Proto.parseDWORD(entry); -- 动作0显示,1进行,2结束
	data.eventID=Proto.parseDWORD(entry); -- 事件ID
	data.eventType=Proto.parseDWORD(entry); -- 事件类型
	data.time=Proto.parseDWORD(entry); -- 事件
	data.floor=Proto.parseDWORD(entry); -- 楼层
	return data;
end

function Proto.writeDungeonLogData(msg,data)
	Proto.writeDWORD(msg,data.charID); -- 玩家ID
	Proto.writeDWORD(msg,data.action); -- 动作0显示,1进行,2结束
	Proto.writeDWORD(msg,data.eventID); -- 事件ID
	Proto.writeDWORD(msg,data.eventType); -- 事件类型
	Proto.writeDWORD(msg,data.time); -- 事件
	Proto.writeDWORD(msg,data.floor); -- 楼层
end

function Proto.parseFamilyShopInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.awardElementID=Proto.parseDWORD(entry); -- 奖励元素ID
	data.awardCount=Proto.parseDWORD(entry); -- 购买个数
	data.price=Proto.parseDWORD(entry); -- 价格
	data.needLevel=Proto.parseDWORD(entry); -- 需要家族等级
	return data;
end

function Proto.getFamilyShopInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeFamilyShopInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeDWORD(msg,data.awardElementID); -- 奖励元素ID
	Proto.writeDWORD(msg,data.awardCount); -- 购买个数
	Proto.writeDWORD(msg,data.price); -- 价格
	Proto.writeDWORD(msg,data.needLevel); -- 需要家族等级
end

