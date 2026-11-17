-- Net.Proto.Proto_Item_Types

Proto.IC_NORMAL					= 0									-- [道具类别]无
Proto.IC_SKILL_CARD				= Proto.IC_NORMAL + 1				-- [道具类别]技能卡
Proto.IC_PATTERN				= Proto.IC_SKILL_CARD + 1			-- [道具类别]碎片
Proto.IC_OTHER					= Proto.IC_PATTERN + 1				-- [道具类别]其他
Proto.IC_EQUIP					= Proto.IC_OTHER + 1				-- [道具类别]装备
Proto.IC_SANDBAG				= Proto.IC_EQUIP + 1				-- [道具类别]沙袋
Proto.IC_EVOSTONE				= Proto.IC_SANDBAG + 1				-- [道具类别]进化石
Proto.IC_SOUVENIR				= Proto.IC_EVOSTONE + 1				-- [道具类别]纪念品
Proto.IC_FOOD					= Proto.IC_SOUVENIR + 1				-- [道具类别]料理
Proto.IC_POKEMONBALL			= Proto.IC_FOOD + 1					-- [道具类别]精灵球
Proto.IC_GOLDBAG				= Proto.IC_POKEMONBALL + 1			-- [道具类别]金币袋
Proto.IC_MED					= Proto.IC_GOLDBAG + 1				-- [道具类别]药剂
Proto.IC_ADVENTURECARD			= Proto.IC_MED + 1					-- [道具类别]探索券
Proto.IC_STATUSMED				= Proto.IC_ADVENTURECARD + 1		-- [道具类别]状态药
Proto.IC_FISHROD				= Proto.IC_STATUSMED + 1			-- [道具类别]鱼竿
Proto.IC_PP						= Proto.IC_FISHROD + 1				-- [道具类别]PP
Proto.IC_PICK					= Proto.IC_PP + 1					-- [道具类别]镐
Proto.IC_DURG					= Proto.IC_PICK + 1					-- [道具类别]药品
Proto.IC_GIFT					= Proto.IC_DURG + 1					-- [道具类别]礼包
Proto.IC_EXP					= Proto.IC_GIFT + 1					-- [道具类别]经验道具
Proto.IC_QUITCLEARADV			= Proto.IC_EXP + 1					-- [道具类别]扫荡券
Proto.IC_FURNITURE				= Proto.IC_QUITCLEARADV + 1			-- [道具类别]家具
Proto.IC_FASHION				= Proto.IC_FURNITURE + 1			-- [道具类别]时装
Proto.IC_DRAWING				= Proto.IC_FASHION + 1				-- [道具类别]图纸配方
Proto.IC_LOSTTOWERSTEPNUMBER	= Proto.IC_DRAWING + 1				-- [道具类别]迷失之塔步数
Proto.IC_WISHINGTREESEED		= Proto.IC_LOSTTOWERSTEPNUMBER + 1	-- [道具类别]许愿树种子
Proto.IC_PETEQUIPPIECE			= Proto.IC_WISHINGTREESEED + 1		-- [道具类别]宠物装备碎片
Proto.IC_LUCKSTONE				= Proto.IC_PETEQUIPPIECE + 1		-- [道具类别]幸运石
Proto.IC_SELECTABLEBOX			= Proto.IC_LUCKSTONE + 1			-- [道具类别]多选一宝箱
Proto.IC_CHANGENAME				= Proto.IC_SELECTABLEBOX + 1		-- [道具类别]改名卡
Proto.IC_COUNT					= Proto.IC_CHANGENAME + 1			-- [道具类别]道具类别数量
Proto.FT_NONE		= 0							-- []无
Proto.FT_DOORBOARD	= Proto.FT_NONE + 1			-- []门牌
Proto.FT_BED		= Proto.FT_DOORBOARD + 1	-- []床
Proto.FT_WARDROBE	= Proto.FT_BED + 1			-- []衣柜
Proto.FT_COMPUTER	= Proto.FT_WARDROBE + 1		-- []电脑
Proto.FT_SUITCASE	= Proto.FT_COMPUTER + 1		-- []旅行箱
Proto.FT_TV			= Proto.FT_SUITCASE + 1		-- []TV
Proto.FT_SOFA		= Proto.FT_TV + 1			-- []沙发
Proto.FT_DESK		= Proto.FT_SOFA + 1			-- []桌子
Proto.FT_TREADMILL	= Proto.FT_DESK + 1			-- []跑步机
Proto.FT_CHAIR		= Proto.FT_TREADMILL + 1	-- []椅子
Proto.FT_DOOR		= Proto.FT_CHAIR + 1		-- []门
Proto.FT_BONSAI		= Proto.FT_DOOR + 1			-- []盆栽
Proto.FT_WALLITEM	= Proto.FT_BONSAI + 1		-- []墙饰
Proto.FT_LAMP		= Proto.FT_WALLITEM + 1		-- []吊灯
Proto.FT_WALLPAPER	= Proto.FT_LAMP + 1			-- []墙纸
Proto.FT_FLOOR		= Proto.FT_WALLPAPER + 1	-- []地板
Proto.FT_ROOT		= Proto.FT_FLOOR + 1		-- []天花板
Proto.IBT_NONE	= 0						-- [道具绑定类型]无绑定
Proto.IBT_USAGE	= Proto.IBT_NONE + 1	-- [道具绑定类型]使用绑定
Proto.IBT_FETCH	= Proto.IBT_USAGE + 1	-- [道具绑定类型]获取绑定
Proto.CS_OP_ADD		= 0							-- [玩家状态更新动作]增加
Proto.CS_OP_UPDATE	= Proto.CS_OP_ADD + 1		-- [玩家状态更新动作]更新
Proto.CS_OP_DELETE	= Proto.CS_OP_UPDATE + 1	-- [玩家状态更新动作]删除
Proto.CS_NORMAL						= 0										-- [玩家状态]普通
Proto.CS_DOUBLE_EXP_IN_STAGE		= Proto.CS_NORMAL + 1					-- [玩家状态]打野双倍经验
Proto.CS_DOUBLE_EXP_IN_TRAINING		= Proto.CS_DOUBLE_EXP_IN_STAGE + 1		-- [玩家状态]训练场双倍经验
Proto.CS_POINT_WAR_BUFF				= Proto.CS_DOUBLE_EXP_IN_TRAINING + 1	-- [玩家状态]积分战buff
Proto.CS_CROSS_WORLD_BATTLE_BUFF	= Proto.CS_POINT_WAR_BUFF + 1			-- [玩家状态]跨服战buff
Proto.CS_COUNT						= Proto.CS_CROSS_WORLD_BATTLE_BUFF + 1	-- [玩家状态]总数
Proto.LT_SS	= 0					-- [道具等级类型类型]SS级
Proto.LT_S	= Proto.LT_SS + 1	-- [道具等级类型类型]S级
Proto.LT_A	= Proto.LT_S + 1	-- [道具等级类型类型]A级
Proto.LT_B	= Proto.LT_A + 1	-- [道具等级类型类型]B级
Proto.LT_C	= Proto.LT_B + 1	-- [道具等级类型类型]C级
Proto.LT_D	= Proto.LT_C + 1	-- [道具等级类型类型]D级
Proto.LT_E	= Proto.LT_D + 1	-- [道具等级类型类型]E级
Proto.EXTEND_GCASH	= 0							-- [道具等级类型类型]金币
Proto.EXTEND_MCASH	= Proto.EXTEND_GCASH + 1	-- [道具等级类型类型]M币
Proto.EXTEND_ITEM	= Proto.EXTEND_MCASH + 1	-- [道具等级类型类型]道具
Proto.AET_NONE				= 0								-- [奖励元素类型]
Proto.AET_GCASH				= Proto.AET_NONE + 1			-- [奖励元素类型]银币
Proto.AET_MCASH				= Proto.AET_GCASH + 1			-- [奖励元素类型]M币
Proto.AET_ITEM				= Proto.AET_MCASH + 1			-- [奖励元素类型]道具
Proto.AET_EXP				= Proto.AET_ITEM + 1			-- [奖励元素类型]经验
Proto.AET_PET				= Proto.AET_EXP + 1				-- [奖励元素类型]宠物
Proto.AET_STRENGTHEN		= Proto.AET_PET + 1				-- [奖励元素类型]强化点数
Proto.AET_STARPOINT			= Proto.AET_STRENGTHEN + 1		-- [奖励元素类型]升星点数
Proto.AET_WASHSTONE			= Proto.AET_STARPOINT + 1		-- [奖励元素类型]洗练石
Proto.AET_LOSTTOWERPOINT	= Proto.AET_WASHSTONE + 1		-- [奖励元素类型]迷失之塔积分
Proto.AET_ARENAPOINT		= Proto.AET_LOSTTOWERPOINT + 1	-- [奖励元素类型]竞技场点数
Proto.AET_GOLDCOIN			= Proto.AET_ARENAPOINT + 1		-- [奖励元素类型]金币
Proto.AET_FAMILYCOIN		= Proto.AET_GOLDCOIN + 1		-- [奖励元素类型]家族徽章
Proto.AET_ACTIONPOINT		= Proto.AET_FAMILYCOIN + 1		-- [奖励元素类型]体力
Proto.AET_TERRITORYPOINT	= Proto.AET_ACTIONPOINT + 1		-- [奖励元素类型]领主积分
Proto.AET_ACTIVITYPOINT		= Proto.AET_TERRITORYPOINT + 1	-- [奖励元素类型]活动积分
Proto.AET_EXPEDITIONPOINT	= Proto.AET_ACTIVITYPOINT + 1	-- [奖励元素类型]远征积分
Proto.AET_PVPARENACOIN		= Proto.AET_EXPEDITIONPOINT + 1	-- [奖励元素类型]大联盟币
Proto.AET_SCIENCEPOINT		= Proto.AET_PVPARENACOIN + 1	-- [奖励元素类型]科技点
Proto.EQUIP_NONE	= 0							-- [装备部位]
Proto.EQUIP_WEAPON	= Proto.EQUIP_NONE + 1		-- [装备部位]武器
Proto.EQUIP_DEFENCE	= Proto.EQUIP_WEAPON + 1	-- [装备部位]防具
Proto.BT_BIND_NON		= 0							-- [绑定类型枚举]不绑定
Proto.BT_BIND_OBTAIN	= Proto.BT_BIND_NON + 1		-- [绑定类型枚举]拾取绑定
Proto.FT_BIND_USE		= Proto.BT_BIND_OBTAIN + 1	-- [绑定类型枚举]使用绑定

function Proto.parseCustomDeck(entry)
	local data={};
	data.deck=Proto.parseDWORD(entry); -- 装饰物
	data.pos=Proto.parsePOS2D(entry); -- 位置
	return data;
end

function Proto.writeCustomDeck(msg,data)
	Proto.writeDWORD(msg,data.deck); -- 装饰物
	Proto.writePOS2D(msg,data.pos); -- 位置
end

function Proto.parseEquipmentAffix(entry)
	local data={};
	data.affixID=Proto.parseWORD(entry); -- 词缀ID
	data.value=Proto.parseshort(entry); -- 参数
	return data;
end

function Proto.writeEquipmentAffix(msg,data)
	Proto.writeWORD(msg,data.affixID); -- 词缀ID
	Proto.writeshort(msg,data.value); -- 参数
end

function Proto.parseNatureAllele(entry)
	local data={};
	data.geneID_a=Proto.parseWORD(entry); -- 基因编号a
	data.geneID_b=Proto.parseWORD(entry); -- 基因编号b
	return data;
end

function Proto.writeNatureAllele(msg,data)
	Proto.writeWORD(msg,data.geneID_a); -- 基因编号a
	Proto.writeWORD(msg,data.geneID_b); -- 基因编号b
end

function Proto.parseStruggleRandomInfo(entry)
	local data={};
	data.min=Proto.parseWORD(entry); -- 最小值
	data.max=Proto.parseWORD(entry); -- 最大值
	return data;
end

function Proto.writeStruggleRandomInfo(msg,data)
	Proto.writeWORD(msg,data.min); -- 最小值
	Proto.writeWORD(msg,data.max); -- 最大值
end

function Proto.parseSelfAttribRandomInfo(entry)
	local data={};
	data.min=Proto.parseBYTE(entry); -- 最小值
	data.max=Proto.parseBYTE(entry); -- 最大值
	return data;
end

function Proto.writeSelfAttribRandomInfo(msg,data)
	Proto.writeBYTE(msg,data.min); -- 最小值
	Proto.writeBYTE(msg,data.max); -- 最大值
end

function Proto.parseNatureGene(entry)
	local data={};
	data.alleles=Proto.parseVarArray(entry,Proto.parseNatureAllele,Proto.parseWORD); -- 基因对
	return data;
end

function Proto.writeNatureGene(msg,data)
	Proto.writeVarArray(msg,data.alleles,Proto.writeNatureAllele,Proto.writeWORD); -- 基因对
end

function Proto.parsePetRecord(entry)
	local data={};
	data.gender=Proto.parseBYTE(entry); -- 性别
	data.forbidProcreate=Proto.parseBYTE(entry); -- 是否是杂交
	data.fatherID=Proto.parseDWORD(entry); -- 母亲
	data.motherID=Proto.parseDWORD(entry); -- 父亲
	data.selfAttrib=Proto.parseBYTE(entry); -- 个体值
	data.natureGene=Proto.parseNatureGene(entry); -- 携带基因
	data.cards=Proto.parseVarArray(entry,Proto.parseDWORD,Proto.parseWORD); -- 卡片ID列表(必然为1级)
	data.struggles=Proto.parseVarArray(entry,Proto.parseWORD,Proto.parseWORD); -- 努力值
	return data;
end

function Proto.writePetRecord(msg,data)
	Proto.writeBYTE(msg,data.gender); -- 性别
	Proto.writeBYTE(msg,data.forbidProcreate); -- 是否是杂交
	Proto.writeDWORD(msg,data.fatherID); -- 母亲
	Proto.writeDWORD(msg,data.motherID); -- 父亲
	Proto.writeBYTE(msg,data.selfAttrib); -- 个体值
	Proto.writeNatureGene(msg,data.natureGene); -- 携带基因
	Proto.writeVarArray(msg,data.cards,Proto.writeDWORD,Proto.writeWORD); -- 卡片ID列表(必然为1级)
	Proto.writeVarArray(msg,data.struggles,Proto.writeWORD,Proto.writeWORD); -- 努力值
end

function Proto.parseEquipGene(entry)
	local data={};
	data.geneID=Proto.parseWORD(entry); -- 技能id
	data.geneLevel=Proto.parseWORD(entry); -- 技能等级
	data.pumpSoulPoint=Proto.parseDWORD(entry); -- 抽魂点数
	return data;
end

function Proto.writeEquipGene(msg,data)
	Proto.writeWORD(msg,data.geneID); -- 技能id
	Proto.writeWORD(msg,data.geneLevel); -- 技能等级
	Proto.writeDWORD(msg,data.pumpSoulPoint); -- 抽魂点数
end

function Proto.parseItemInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 道具类型ID
	data.itemType=Proto.parseDWORD(entry); -- 道具种类
	data.itemTypeID=Proto.parseDWORD(entry); -- 类型ID
	data.name=Proto.parseString(entry); -- 名称
	data.desc=Proto.parseString(entry); -- 描述
	data.icon=Proto.parseString(entry); -- 图标
	data.reclaimPrice=Proto.parseDWORD(entry); -- 道具回收价格
	data.itemRare=Proto.parseDWORD(entry); -- 稀有度
	data.bindType=Proto.parseBYTE(entry); -- 绑定类型
	data.bUse=Proto.parseBYTE(entry); -- 能否使用
	data.effectName=Proto.parseString(entry); -- 道具参数效果名
	data.paramA=Proto.parseDWORD(entry); -- 道具效果参数A
	data.paramB=Proto.parseDWORD(entry); -- 道具效果参数B
	data.paramC=Proto.parseDWORD(entry); -- 道具效果参数C
	data.paramD=Proto.parseDWORD(entry); -- 道具效果参数D
	data.paramE=Proto.parseDWORD(entry); -- 道具效果参数E
	data.selectID=Proto.parseString(entry); -- 
	return data;
end

function Proto.getItemInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeItemInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 道具类型ID
	Proto.writeDWORD(msg,data.itemType); -- 道具种类
	Proto.writeDWORD(msg,data.itemTypeID); -- 类型ID
	Proto.writeString(msg,data.name); -- 名称
	Proto.writeString(msg,data.desc); -- 描述
	Proto.writeString(msg,data.icon); -- 图标
	Proto.writeDWORD(msg,data.reclaimPrice); -- 道具回收价格
	Proto.writeDWORD(msg,data.itemRare); -- 稀有度
	Proto.writeBYTE(msg,data.bindType); -- 绑定类型
	Proto.writeBYTE(msg,data.bUse); -- 能否使用
	Proto.writeString(msg,data.effectName); -- 道具参数效果名
	Proto.writeDWORD(msg,data.paramA); -- 道具效果参数A
	Proto.writeDWORD(msg,data.paramB); -- 道具效果参数B
	Proto.writeDWORD(msg,data.paramC); -- 道具效果参数C
	Proto.writeDWORD(msg,data.paramD); -- 道具效果参数D
	Proto.writeDWORD(msg,data.paramE); -- 道具效果参数E
	Proto.writeString(msg,data.selectID); -- 
end

function Proto.parseItemUnit(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 道具类型ID
	return data;
end

function Proto.getItemUnitIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeItemUnit(msg,data)
	Proto.writeDWORD(msg,data.id); -- 道具类型ID
end

function Proto.parseItem(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 道具类型ID
	return data;
end

function Proto.getItemIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeItem(msg,data)
	Proto.writeDWORD(msg,data.id); -- 道具类型ID
end

function Proto.parseAwardElementInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 
	data.elementType=Proto.parseDWORD(entry); -- 
	data.elementID=Proto.parseDWORD(entry); -- 
	return data;
end

function Proto.getAwardElementInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeAwardElementInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 
	Proto.writeDWORD(msg,data.elementType); -- 
	Proto.writeDWORD(msg,data.elementID); -- 
end

function Proto.parseConsumeElementInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 
	data.elementType=Proto.parseDWORD(entry); -- 
	data.elementID=Proto.parseDWORD(entry); -- 
	data.num=Proto.parseDWORD(entry); -- 
	return data;
end

function Proto.getConsumeElementInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeConsumeElementInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 
	Proto.writeDWORD(msg,data.elementType); -- 
	Proto.writeDWORD(msg,data.elementID); -- 
	Proto.writeDWORD(msg,data.num); -- 
end

function Proto.parsePokemonBallInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 
	data.c=Proto.parseVector(entry,Proto.parseDWORD); -- 
	data.b=Proto.parseVector(entry,Proto.parseDWORD); -- 
	data.a=Proto.parseVector(entry,Proto.parseDWORD); -- 
	data.s=Proto.parseVector(entry,Proto.parseDWORD); -- 
	data.ss=Proto.parseVector(entry,Proto.parseDWORD); -- 
	return data;
end

function Proto.getPokemonBallInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writePokemonBallInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 
	Proto.writeVector(msg,data.c,Proto.writeDWORD); -- 
	Proto.writeVector(msg,data.b,Proto.writeDWORD); -- 
	Proto.writeVector(msg,data.a,Proto.writeDWORD); -- 
	Proto.writeVector(msg,data.s,Proto.writeDWORD); -- 
	Proto.writeVector(msg,data.ss,Proto.writeDWORD); -- 
end

function Proto.parseSevenDayInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 七日任务ID
	data.sevenQuestType=Proto.parseDWORD(entry); -- 七日任务类型
	data.linkQuestId=Proto.parseDWORD(entry); -- 关联原任务系统id
	data.openDay=Proto.parseDWORD(entry); -- 第几天开放
	data.rewardInfos=Proto.parseVector(entry,Proto.parseDWORD); -- 奖励id数组
	data.sevenQuestName=Proto.parseString(entry); -- 七日任务名称
	data.questTabTag=Proto.parseString(entry); -- 7日活动tab标签
	data.needCondition=Proto.parseVector(entry,Proto.parseDWORD); -- 完成任务的条件
	data.wayToGetReward=Proto.parseVector(entry,Proto.parseDWORD); -- 获得奖励的方式
	data.keyName=Proto.parseString(entry); -- 关键字
	return data;
end

function Proto.getSevenDayInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeSevenDayInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 七日任务ID
	Proto.writeDWORD(msg,data.sevenQuestType); -- 七日任务类型
	Proto.writeDWORD(msg,data.linkQuestId); -- 关联原任务系统id
	Proto.writeDWORD(msg,data.openDay); -- 第几天开放
	Proto.writeVector(msg,data.rewardInfos,Proto.writeDWORD); -- 奖励id数组
	Proto.writeString(msg,data.sevenQuestName); -- 七日任务名称
	Proto.writeString(msg,data.questTabTag); -- 7日活动tab标签
	Proto.writeVector(msg,data.needCondition,Proto.writeDWORD); -- 完成任务的条件
	Proto.writeVector(msg,data.wayToGetReward,Proto.writeDWORD); -- 获得奖励的方式
	Proto.writeString(msg,data.keyName); -- 关键字
end

function Proto.parseSelectableAwardInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.name=Proto.parseString(entry); -- 奖池编号
	data.elements=Proto.parseVector(entry,Proto.parseDWORD); -- 奖励
	data.nums=Proto.parseVector(entry,Proto.parseDWORD); -- 数量
	return data;
end

function Proto.getSelectableAwardInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeSelectableAwardInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeString(msg,data.name); -- 奖池编号
	Proto.writeVector(msg,data.elements,Proto.writeDWORD); -- 奖励
	Proto.writeVector(msg,data.nums,Proto.writeDWORD); -- 数量
end

