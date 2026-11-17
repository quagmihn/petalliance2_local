-- Net.Proto.Proto_Define_ItemPacketID_Types

Proto.IPT_CHARACTER		= 0								-- [道具背包类型]人物
Proto.IPT_PET			= Proto.IPT_CHARACTER + 1		-- [道具背包类型]宠物
Proto.IPT_NPC			= Proto.IPT_PET + 1				-- [道具背包类型]NPC
Proto.IPT_GARDEN		= Proto.IPT_NPC + 1				-- [道具背包类型]庄园
Proto.IPT_PETCARDPACKET	= Proto.IPT_GARDEN + 1			-- [道具背包类型]宠物卡片包
Proto.IPT_CONFRATERNITY	= Proto.IPT_PETCARDPACKET + 1	-- [道具背包类型]公会仓库
Proto.IPT_FASHION		= Proto.IPT_CONFRATERNITY + 1	-- [道具背包类型]时装包
Proto.IPT_EQUIP			= Proto.IPT_FASHION + 1			-- [道具背包类型]装备包
Proto.IPT_CHAREQUIP		= Proto.IPT_EQUIP + 1			-- [道具背包类型]人物装备包

function Proto.parseItemPacketID(entry)
	local data={};
	data.type=Proto.parseBYTE(entry); -- 类型
	data.id=Proto.parseDWORD(entry); -- 相关类型ID
	return data;
end

function Proto.getItemPacketIDIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeItemPacketID(msg,data)
	Proto.writeBYTE(msg,data.type); -- 类型
	Proto.writeDWORD(msg,data.id); -- 相关类型ID
end

