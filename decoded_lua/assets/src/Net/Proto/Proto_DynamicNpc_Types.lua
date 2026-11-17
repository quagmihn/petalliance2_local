-- Net.Proto.Proto_DynamicNpc_Types

function Proto.parseDynamicNpcInfo(entry)
	local data={};
	data.id=Proto.parseNpcID(entry); -- NpcID
	data.nation_id=Proto.parseBYTE(entry); -- 阵营ID
	data.name=Proto.parseLifeNick(entry); -- Npc名称
	data.level=Proto.parseBYTE(entry); -- 声望等级
	data.industries=Proto.parseVarArray(entry,Proto.parseBYTE,Proto.parseWORD); -- 产业
	data.control=Proto.parseString(entry); -- 控制脚本文件名
	return data;
end

function Proto.getDynamicNpcInfoIDLen()
	return Proto.getNpcIDLen();
end

function Proto.writeDynamicNpcInfo(msg,data)
	Proto.writeNpcID(msg,data.id); -- NpcID
	Proto.writeBYTE(msg,data.nation_id); -- 阵营ID
	Proto.writeLifeNick(msg,data.name); -- Npc名称
	Proto.writeBYTE(msg,data.level); -- 声望等级
	Proto.writeVarArray(msg,data.industries,Proto.writeBYTE,Proto.writeWORD); -- 产业
	Proto.writeString(msg,data.control); -- 控制脚本文件名
end

function Proto.parseFestaDynamicNpcInfo(entry)
	local data={};
	data.id=Proto.parseNpcID(entry); -- NpcID
	data.festaID=Proto.parseDWORD(entry); -- 节日ID
	data.name=Proto.parseLifeNick(entry); -- Npc名称
	data.industries=Proto.parseVarArray(entry,Proto.parseBYTE,Proto.parseWORD); -- 产业
	data.control=Proto.parseString(entry); -- 控制脚本文件名
	return data;
end

function Proto.getFestaDynamicNpcInfoIDLen()
	return Proto.getNpcIDLen();
end

function Proto.writeFestaDynamicNpcInfo(msg,data)
	Proto.writeNpcID(msg,data.id); -- NpcID
	Proto.writeDWORD(msg,data.festaID); -- 节日ID
	Proto.writeLifeNick(msg,data.name); -- Npc名称
	Proto.writeVarArray(msg,data.industries,Proto.writeBYTE,Proto.writeWORD); -- 产业
	Proto.writeString(msg,data.control); -- 控制脚本文件名
end

function Proto.parseNpcDependantInfo(entry)
	local data={};
	data.id=Proto.parseNpcID(entry); -- NpcID
	data.orderDishes=Proto.parseDynamicNpcScript(entry); -- 点菜脚本
	data.dnpcFirstOrder=Proto.parseDynamicNpcDialogText(entry); -- 动态NPC首次点菜
	data.dnpcReorder=Proto.parseDynamicNpcDialogText(entry); -- 动态NPC再次点菜
	data.dnpcOrderFail=Proto.parseDynamicNpcDialogText(entry); -- 动态NPC点不着菜
	data.dnpcFetchDish=Proto.parseDynamicNpcDialogText(entry); -- 动态NPC拿到菜
	data.dnpcNoFavirateDish=Proto.parseDynamicNpcDialogText(entry); -- 动态NPC没有喜欢的菜
	data.waiterFindDish=Proto.parseDynamicNpcDialogText(entry); -- 侍者查找菜
	data.waiterFindDishFail=Proto.parseDynamicNpcDialogText(entry); -- 侍者查不到菜
	data.waiterPrepareDish=Proto.parseDynamicNpcDialogText(entry); -- 侍者准备菜
	data.waiterDeliverDish=Proto.parseDynamicNpcDialogText(entry); -- 侍者交付菜
	data.dnpcFetchDishEvent=Proto.parseDynamicNpcScript(entry); -- 动态NPC拿到菜事件
	return data;
end

function Proto.getNpcDependantInfoIDLen()
	return Proto.getNpcIDLen();
end

function Proto.writeNpcDependantInfo(msg,data)
	Proto.writeNpcID(msg,data.id); -- NpcID
	Proto.writeDynamicNpcScript(msg,data.orderDishes); -- 点菜脚本
	Proto.writeDynamicNpcDialogText(msg,data.dnpcFirstOrder); -- 动态NPC首次点菜
	Proto.writeDynamicNpcDialogText(msg,data.dnpcReorder); -- 动态NPC再次点菜
	Proto.writeDynamicNpcDialogText(msg,data.dnpcOrderFail); -- 动态NPC点不着菜
	Proto.writeDynamicNpcDialogText(msg,data.dnpcFetchDish); -- 动态NPC拿到菜
	Proto.writeDynamicNpcDialogText(msg,data.dnpcNoFavirateDish); -- 动态NPC没有喜欢的菜
	Proto.writeDynamicNpcDialogText(msg,data.waiterFindDish); -- 侍者查找菜
	Proto.writeDynamicNpcDialogText(msg,data.waiterFindDishFail); -- 侍者查不到菜
	Proto.writeDynamicNpcDialogText(msg,data.waiterPrepareDish); -- 侍者准备菜
	Proto.writeDynamicNpcDialogText(msg,data.waiterDeliverDish); -- 侍者交付菜
	Proto.writeDynamicNpcScript(msg,data.dnpcFetchDishEvent); -- 动态NPC拿到菜事件
end

function Proto.parseInvitationRestaurantFestaInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 邀请函的道具类型ID
	data.festaID=Proto.parseDWORD(entry); -- 节日ID
	data.festaNinki=Proto.parseDWORD(entry); -- 对应人气
	data.npcCount=Proto.parseWORD(entry); -- 召唤NPC人数
	return data;
end

function Proto.getInvitationRestaurantFestaInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeInvitationRestaurantFestaInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 邀请函的道具类型ID
	Proto.writeDWORD(msg,data.festaID); -- 节日ID
	Proto.writeDWORD(msg,data.festaNinki); -- 对应人气
	Proto.writeWORD(msg,data.npcCount); -- 召唤NPC人数
end

