-- Net.Proto.Proto_Define_Money_Types

Proto.MT_GCASH		= 0						-- [货币类型]G币
Proto.MT_MCASH		= Proto.MT_GCASH + 1	-- [货币类型]M币
Proto.MT_CREDITCARD	= Proto.MT_MCASH + 1	-- [货币类型]信用卡
Proto.CCT_CONFRATERNITYCONTRIBUTE		= 0											-- [信用卡类型]帮派贡献
Proto.CCT_ACHIEVEMENT					= Proto.CCT_CONFRATERNITYCONTRIBUTE + 1		-- [信用卡类型]成就
Proto.CCT_NATION						= Proto.CCT_ACHIEVEMENT + 1					-- [信用卡类型]npc阵营
Proto.CCT_PLAYER						= Proto.CCT_NATION + 1						-- [信用卡类型]玩家
Proto.CCT_CONFRATERNITYCOMMERCE			= Proto.CCT_PLAYER + 1						-- [信用卡类型]帮派跑商
Proto.CCT_ARENA_HONOR_POINT				= Proto.CCT_CONFRATERNITYCOMMERCE + 1		-- [信用卡类型]竞技场信用点
Proto.CCT_ARENA_CHARM_POINT				= Proto.CCT_ARENA_HONOR_POINT + 1			-- [信用卡类型]竞技场魅力点
Proto.CCT_PET_SOUL_POINT				= Proto.CCT_ARENA_CHARM_POINT + 1			-- [信用卡类型]宠物魂点
Proto.CCT_CHAR_SOUL_POOL_EXPAND_TIMES	= Proto.CCT_PET_SOUL_POINT + 1				-- [信用卡类型]灵魂池扩充次数
Proto.CCT_CHAR_DIG_TREASURE_WORD		= Proto.CCT_CHAR_SOUL_POOL_EXPAND_TIMES + 1	-- [信用卡类型]挖宝致富字类型
Proto.CCT_CHAR_DIG_TREASURE_POS			= Proto.CCT_CHAR_DIG_TREASURE_WORD + 1		-- [信用卡类型]挖宝致富宝箱位置类型
Proto.CCT_ID_PET_TURN_NONAME		= 0										-- [宠物魂点信用卡ID]无名之魂
Proto.CCT_ID_PET_TURN_FAINT			= Proto.CCT_ID_PET_TURN_NONAME + 1		-- [宠物魂点信用卡ID]暗淡之魂
Proto.CCT_ID_PET_TURN_MICROLIGHT	= Proto.CCT_ID_PET_TURN_FAINT + 1		-- [宠物魂点信用卡ID]微光之魂
Proto.CCT_ID_PET_TURN_LIGHT			= Proto.CCT_ID_PET_TURN_MICROLIGHT + 1	-- [宠物魂点信用卡ID]闪耀之魂
Proto.CCT_ID_PET_TURN_TALE			= Proto.CCT_ID_PET_TURN_LIGHT + 1		-- [宠物魂点信用卡ID]传说之魂
Proto.CCT_ID_PET_TURN_MYTH			= Proto.CCT_ID_PET_TURN_TALE + 1		-- [宠物魂点信用卡ID]神话之魂
Proto.CCT_ID_TREASURE_ONE	= 0									-- [挖宝致富宝箱位置信用卡ID]第一个宝箱 0未开启 1开启
Proto.CCT_ID_TREASURE_TWO	= Proto.CCT_ID_TREASURE_ONE + 1		-- [挖宝致富宝箱位置信用卡ID]第二个宝箱
Proto.CCT_ID_TREASURE_THREE	= Proto.CCT_ID_TREASURE_TWO + 1		-- [挖宝致富宝箱位置信用卡ID]第三个宝箱
Proto.CCT_ID_TREASURE_FOUR	= Proto.CCT_ID_TREASURE_THREE + 1	-- [挖宝致富宝箱位置信用卡ID]第四个宝箱
Proto.CCT_ID_TREASURE_FIVE	= Proto.CCT_ID_TREASURE_FOUR + 1	-- [挖宝致富宝箱位置信用卡ID]第五个宝箱
Proto.CCT_ID_TREASURE_SIX	= Proto.CCT_ID_TREASURE_FIVE + 1	-- [挖宝致富宝箱位置信用卡ID]第六个宝箱
Proto.CCT_ID_TREASURE_SEVEN	= Proto.CCT_ID_TREASURE_SIX + 1		-- [挖宝致富宝箱位置信用卡ID]第七个宝箱
Proto.CCT_ID_TREASURE_EIGHT	= Proto.CCT_ID_TREASURE_SEVEN + 1	-- [挖宝致富宝箱位置信用卡ID]第八个宝箱
Proto.CCT_ID_TREASURE_SHOU	= 0									-- [挖宝致富信用卡ID]兽
Proto.CCT_ID_TREASURE_SHEN	= Proto.CCT_ID_TREASURE_SHOU + 1	-- [挖宝致富信用卡ID]神
Proto.CCT_ID_TREASURE_CHUAN	= Proto.CCT_ID_TREASURE_SHEN + 1	-- [挖宝致富信用卡ID]传
Proto.CCT_ID_TREASURE_SHUO	= Proto.CCT_ID_TREASURE_CHUAN + 1	-- [挖宝致富信用卡ID]说

function Proto.parseCreditCardID(entry)
	local data={};
	data.type=Proto.parseBYTE(entry); -- 类型
	data.id=Proto.parseDWORD(entry); -- 对应ID
	return data;
end

function Proto.getCreditCardIDIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeCreditCardID(msg,data)
	Proto.writeBYTE(msg,data.type); -- 类型
	Proto.writeDWORD(msg,data.id); -- 对应ID
end

function Proto.parseMoneyType(entry)
	local data={};
	data.moneyType=Proto.parseBYTE(entry); -- 阵营信用卡道具ID
	data.body={}; -- 内容
	if (data.moneyType ==Proto.MT_CREDITCARD) then
		data.body.creditCard=Proto.parseCreditCardID(entry); -- 
	end
	return data;
end

function Proto.writeMoneyType(msg,data)
	Proto.writeBYTE(msg,data.moneyType); -- 阵营信用卡道具ID
	if (data.moneyType ==Proto.MT_CREDITCARD) then
		Proto.writeCreditCardID(msg,data.body.creditCard); -- 
	end
end

function Proto.parseMoney(entry)
	local data={};
	data.type=Proto.parseMoneyType(entry); -- 金钱类型
	data.value=Proto.parseDWORD(entry); -- 值
	return data;
end

function Proto.writeMoney(msg,data)
	Proto.writeMoneyType(msg,data.type); -- 金钱类型
	Proto.writeDWORD(msg,data.value); -- 值
end

