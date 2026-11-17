-- Net.Proto.Proto_PetEquip_Types

Proto.PEP_ZERO		= 0							-- [宠物装备部位]
Proto.PEP_ORNAMENT	= Proto.PEP_ZERO + 1		-- [宠物装备部位]饰品
Proto.PEP_AMPLIFIER	= Proto.PEP_ORNAMENT + 1	-- [宠物装备部位]增幅器
Proto.PEP_BADGE		= Proto.PEP_AMPLIFIER + 1	-- [宠物装备部位]徽章
Proto.PEEQ_C	= 0					-- [宠物装备效果品级]C
Proto.PEEQ_B	= Proto.PEEQ_C + 1	-- [宠物装备效果品级]B
Proto.PEEQ_A	= Proto.PEEQ_B + 1	-- [宠物装备效果品级]A
Proto.PEEQ_S	= Proto.PEEQ_A + 1	-- [宠物装备效果品级]S
Proto.PEEQ_SS	= Proto.PEEQ_S + 1	-- [宠物装备效果品级]SS
Proto.PEET_NONE			= 0								-- [宠物装备效果类型]
Proto.PEET_HP			= Proto.PEET_NONE + 1			-- [宠物装备效果类型]生命
Proto.PEET_ATK			= Proto.PEET_HP + 1				-- [宠物装备效果类型]物攻
Proto.PEET_DEF			= Proto.PEET_ATK + 1			-- [宠物装备效果类型]物防
Proto.PEET_SATK			= Proto.PEET_DEF + 1			-- [宠物装备效果类型]魔攻
Proto.PEET_SDEF			= Proto.PEET_SATK + 1			-- [宠物装备效果类型]魔防
Proto.PEET_SPEED		= Proto.PEET_SDEF + 1			-- [宠物装备效果类型]速度
Proto.PEET_RATE			= Proto.PEET_SPEED + 1			-- [宠物装备效果类型]命中
Proto.PEET_EVD			= Proto.PEET_RATE + 1			-- [宠物装备效果类型]闪避
Proto.PEET_DAMAGEREDUCE	= Proto.PEET_EVD + 1			-- [宠物装备效果类型]减伤
Proto.PEET_CRT			= Proto.PEET_DAMAGEREDUCE + 1	-- [宠物装备效果类型]暴击
Proto.PEET_SPECIAL		= Proto.PEET_CRT + 1			-- [宠物装备效果类型]特殊
Proto.PEET_HP_Per		= Proto.PEET_SPECIAL + 1		-- [宠物装备效果类型]生命百分比
Proto.PEET_ATK_Per		= Proto.PEET_HP_Per + 1			-- [宠物装备效果类型]物攻百分比
Proto.PEET_DEF_Per		= Proto.PEET_ATK_Per + 1		-- [宠物装备效果类型]物防百分比
Proto.PEET_SATK_Per		= Proto.PEET_DEF_Per + 1		-- [宠物装备效果类型]魔攻百分比
Proto.PEET_SDEF_Per		= Proto.PEET_SATK_Per + 1		-- [宠物装备效果类型]魔防百分比
Proto.PEET_SPEED_Per	= Proto.PEET_SDEF_Per + 1		-- [宠物装备效果类型]速度百分比
Proto.PEET_CRTHURT		= Proto.PEET_SPEED_Per + 1		-- [宠物装备效果类型]爆伤
Proto.PEET_RAGE			= Proto.PEET_CRTHURT + 1		-- [宠物装备效果类型]怒气
Proto.PEET_ENERGY		= Proto.PEET_RAGE + 1			-- [宠物装备效果类型]能量
Proto.PEET_HEALRATE		= Proto.PEET_ENERGY + 1			-- [宠物装备效果类型]治疗修正
Proto.PEET_ANTICRT		= Proto.PEET_HEALRATE + 1		-- [宠物装备效果类型]暴击抵抗
Proto.PEET_ANTIHURT		= Proto.PEET_ANTICRT + 1		-- [宠物装备效果类型]减伤
Proto.PEET_SDEFFIX		= Proto.PEET_ANTIHURT + 1		-- [宠物装备效果类型]魔防修正
Proto.PEET_DEFFIX		= Proto.PEET_SDEFFIX + 1		-- [宠物装备效果类型]物防修正
Proto.PEET_SKILL		= Proto.PEET_DEFFIX + 1			-- [宠物装备效果类型]技能强化
Proto.PEET_PENETRATION	= Proto.PEET_SKILL + 1			-- [宠物装备效果类型]物理穿透
Proto.PEET_SPENETRATION	= Proto.PEET_PENETRATION + 1	-- [宠物装备效果类型]魔法穿透

function Proto.parseDWORDPair(entry)
	local data={};
	data.first=Proto.parseDWORD(entry); -- 
	data.second=Proto.parseDWORD(entry); -- 
	return data;
end

function Proto.writeDWORDPair(msg,data)
	Proto.writeDWORD(msg,data.first); -- 
	Proto.writeDWORD(msg,data.second); -- 
end

function Proto.parsePetEquipInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 
	data.name=Proto.parseString(entry); -- 装备名称
	data.icon=Proto.parseString(entry); -- 装备icon
	data.pos=Proto.parseBYTE(entry); -- 装备部位
	data.quality=Proto.parseBYTE(entry); -- 装备品质
	data.elemAttrRange=Proto.parseVector(entry,Proto.parseDWORD); -- 装备系别范围
	data.elemAttrNum=Proto.parseBYTE(entry); -- 装备系别数量
	data.hpMax=Proto.parseDWORD(entry); -- 生命上限
	data.hpMin=Proto.parseDWORD(entry); -- 生命下限
	data.atkMax=Proto.parseDWORD(entry); -- 物攻上限
	data.atkMin=Proto.parseDWORD(entry); -- 物攻下限
	data.defMax=Proto.parseDWORD(entry); -- 物防上限
	data.defMin=Proto.parseDWORD(entry); -- 物防下线
	data.satkMax=Proto.parseDWORD(entry); -- 魔攻上限
	data.satkMin=Proto.parseDWORD(entry); -- 魔攻下限
	data.sdefMax=Proto.parseDWORD(entry); -- 魔防上限
	data.sdefMin=Proto.parseDWORD(entry); -- 魔防下限
	data.speedMax=Proto.parseDWORD(entry); -- 速度上限
	data.speedMin=Proto.parseDWORD(entry); -- 速度下限
	data.strengthenMax=Proto.parseBYTE(entry); -- 强化上限
	data.purifyMax=Proto.parseBYTE(entry); -- 淬炼上限
	data.effects=Proto.parseVector(entry,Proto.parseDWORD); -- 词条池组
	return data;
end

function Proto.getPetEquipInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writePetEquipInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 
	Proto.writeString(msg,data.name); -- 装备名称
	Proto.writeString(msg,data.icon); -- 装备icon
	Proto.writeBYTE(msg,data.pos); -- 装备部位
	Proto.writeBYTE(msg,data.quality); -- 装备品质
	Proto.writeVector(msg,data.elemAttrRange,Proto.writeDWORD); -- 装备系别范围
	Proto.writeBYTE(msg,data.elemAttrNum); -- 装备系别数量
	Proto.writeDWORD(msg,data.hpMax); -- 生命上限
	Proto.writeDWORD(msg,data.hpMin); -- 生命下限
	Proto.writeDWORD(msg,data.atkMax); -- 物攻上限
	Proto.writeDWORD(msg,data.atkMin); -- 物攻下限
	Proto.writeDWORD(msg,data.defMax); -- 物防上限
	Proto.writeDWORD(msg,data.defMin); -- 物防下线
	Proto.writeDWORD(msg,data.satkMax); -- 魔攻上限
	Proto.writeDWORD(msg,data.satkMin); -- 魔攻下限
	Proto.writeDWORD(msg,data.sdefMax); -- 魔防上限
	Proto.writeDWORD(msg,data.sdefMin); -- 魔防下限
	Proto.writeDWORD(msg,data.speedMax); -- 速度上限
	Proto.writeDWORD(msg,data.speedMin); -- 速度下限
	Proto.writeBYTE(msg,data.strengthenMax); -- 强化上限
	Proto.writeBYTE(msg,data.purifyMax); -- 淬炼上限
	Proto.writeVector(msg,data.effects,Proto.writeDWORD); -- 词条池组
end

function Proto.parsePetEquipEffectSetInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 
	data.wordPoolName=Proto.parseString(entry); -- 
	data.effects=Proto.parseVector(entry,Proto.parseDWORDPair); -- 词条权重组
	return data;
end

function Proto.getPetEquipEffectSetInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writePetEquipEffectSetInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 
	Proto.writeString(msg,data.wordPoolName); -- 
	Proto.writeVector(msg,data.effects,Proto.writeDWORDPair); -- 词条权重组
end

function Proto.parsePetEquipEffectInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 
	data.name=Proto.parseString(entry); -- 名称
	data.type=Proto.parseBYTE(entry); -- 类型
	data.valueMax=Proto.parseDWORD(entry); -- 值上限
	data.valueMin=Proto.parseDWORD(entry); -- 值下限
	return data;
end

function Proto.getPetEquipEffectInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writePetEquipEffectInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 
	Proto.writeString(msg,data.name); -- 名称
	Proto.writeBYTE(msg,data.type); -- 类型
	Proto.writeDWORD(msg,data.valueMax); -- 值上限
	Proto.writeDWORD(msg,data.valueMin); -- 值下限
end

function Proto.parsePetEquipPurifyInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 装备品级
	data.expAndpercents=Proto.parseVector(entry,Proto.parseDWORDPair); -- 经验和淬炼效果组
	return data;
end

function Proto.getPetEquipPurifyInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writePetEquipPurifyInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 装备品级
	Proto.writeVector(msg,data.expAndpercents,Proto.writeDWORDPair); -- 经验和淬炼效果组
end

function Proto.parsePetEquipPurifyExpInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 品级
	data.exp=Proto.parseDWORD(entry); -- 经验
	return data;
end

function Proto.getPetEquipPurifyExpInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writePetEquipPurifyExpInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 品级
	Proto.writeDWORD(msg,data.exp); -- 经验
end

function Proto.parsePetEquipBaptismInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 品级
	data.costInfo=Proto.parseVector(entry,Proto.parseDWORDPair); -- 洗炼石消耗
	return data;
end

function Proto.getPetEquipBaptismInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writePetEquipBaptismInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 品级
	Proto.writeVector(msg,data.costInfo,Proto.writeDWORDPair); -- 洗炼石消耗
end

function Proto.parsePetEquipRestorePurifyInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 
	data.nums=Proto.parseVector(entry,Proto.parseDWORD); -- 淬炼石返还
	return data;
end

function Proto.getPetEquipRestorePurifyInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writePetEquipRestorePurifyInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 
	Proto.writeVector(msg,data.nums,Proto.writeDWORD); -- 淬炼石返还
end

function Proto.parsePetEquipRestoreStrengthenInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 
	data.nums=Proto.parseVector(entry,Proto.parseDWORD); -- 强化石返还
	return data;
end

function Proto.getPetEquipRestoreStrengthenInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writePetEquipRestoreStrengthenInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 
	Proto.writeVector(msg,data.nums,Proto.writeDWORD); -- 强化石返还
end

function Proto.parsePetEquipStrengthenParam(entry)
	local data={};
	data.rate=Proto.parseDWORD(entry); -- 成功率
	data.itemCost=Proto.parseDWORD(entry); -- 强化石消耗
	data.moneyCost=Proto.parseDWORD(entry); -- 金币消耗
	data.effect=Proto.parseDWORD(entry); -- 强化效果
	return data;
end

function Proto.writePetEquipStrengthenParam(msg,data)
	Proto.writeDWORD(msg,data.rate); -- 成功率
	Proto.writeDWORD(msg,data.itemCost); -- 强化石消耗
	Proto.writeDWORD(msg,data.moneyCost); -- 金币消耗
	Proto.writeDWORD(msg,data.effect); -- 强化效果
end

function Proto.parsePetEquipStrengthenInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 品级
	data.infos=Proto.parseVector(entry,Proto.parsePetEquipStrengthenParam); -- 参数组
	return data;
end

function Proto.getPetEquipStrengthenInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writePetEquipStrengthenInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 品级
	Proto.writeVector(msg,data.infos,Proto.writePetEquipStrengthenParam); -- 参数组
end

