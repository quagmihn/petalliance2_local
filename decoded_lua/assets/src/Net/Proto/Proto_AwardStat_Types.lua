-- Net.Proto.Proto_AwardStat_Types

Proto.AST_HASAWARD	= 0							-- [奖励状态]有奖励
Proto.AST_NOAWARD	= Proto.AST_HASAWARD + 1	-- [奖励状态]无奖励
Proto.AICT_NONE			= 0							-- [奖励形式]非奖励
Proto.AICT_QUEST		= Proto.AICT_NONE + 1		-- [奖励形式]任务奖励
Proto.AICT_REPETITION	= Proto.AICT_QUEST + 1		-- [奖励形式]副本掉落
Proto.AICT_ACTIVITY		= Proto.AICT_REPETITION + 1	-- [奖励形式]活动奖励
Proto.AICT_NPC			= Proto.AICT_ACTIVITY + 1	-- [奖励形式]NPC交易
Proto.AICT_MAIL			= Proto.AICT_NPC + 1		-- [奖励形式]邮件附件
Proto.AICT_PUZZLE		= Proto.AICT_MAIL + 1		-- [奖励形式]拼图奖励
Proto.AICT_POCKETSHOP	= Proto.AICT_PUZZLE + 1		-- [奖励形式]随身商店
Proto.AICT_SYNTHESIZE	= Proto.AICT_POCKETSHOP + 1	-- [奖励形式]道具合成
Proto.AICT_CARDUPGRADE	= Proto.AICT_SYNTHESIZE + 1	-- [奖励形式]卡片升级
Proto.ACIT_DOWN	= 0						-- [货币增长形式]减少
Proto.ACIT_UP	= Proto.ACIT_DOWN + 1	-- [货币增长形式]增长
Proto.ACCT_NONE			= 0								-- [货币改变形式]非奖励
Proto.ACCT_QUEST		= Proto.ACCT_NONE + 1			-- [货币改变形式]任务奖励
Proto.ACCT_REPETITION	= Proto.ACCT_QUEST + 1			-- [货币改变形式]副本掉落
Proto.ACCT_ACTIVITY		= Proto.ACCT_REPETITION + 1		-- [货币改变形式]活动奖励
Proto.ACCT_NPC			= Proto.ACCT_ACTIVITY + 1		-- [货币改变形式]NPC交易
Proto.ACCT_MAIL_SEND	= Proto.ACCT_NPC + 1			-- [货币改变形式]发送邮件
Proto.ACCT_MAIL_RECEIVE	= Proto.ACCT_MAIL_SEND + 1		-- [货币改变形式]收取邮件
Proto.ACCT_PUZZLE		= Proto.ACCT_MAIL_RECEIVE + 1	-- [货币改变形式]拼图奖励
Proto.ACCT_CHAT			= Proto.ACCT_PUZZLE + 1			-- [货币改变形式]使用喇叭
Proto.ACCT_TOWNJUMP		= Proto.ACCT_CHAT + 1			-- [货币改变形式]小镇跳跃
Proto.ACCT_TRADE		= Proto.ACCT_TOWNJUMP + 1		-- [货币改变形式]玩家交易
Proto.ACCT_POCKETSHOP	= Proto.ACCT_TRADE + 1			-- [货币改变形式]随身商店
Proto.ACT_NONE	= 0						-- [货币类型]非货币
Proto.ACT_GCASH	= Proto.ACT_NONE + 1	-- [货币类型]贝壳币
Proto.ACT_CARD	= Proto.ACT_GCASH + 1	-- [货币类型]点券

function Proto.parseCashStatData(entry)
	local data={};
	data.state=Proto.parseBYTE(entry); -- 奖励状态
	data.type=Proto.parseBYTE(entry); -- 奖励形式
	data.cashFrom=Proto.parseQWORD(entry); -- 奖励来源
	data.cashTo=Proto.parseDWORD(entry); -- 道具获得者
	data.isIncrease=Proto.parseBYTE(entry); -- 是否增长
	data.number=Proto.parseDWORD(entry); -- 变化的数量
	return data;
end

function Proto.writeCashStatData(msg,data)
	Proto.writeBYTE(msg,data.state); -- 奖励状态
	Proto.writeBYTE(msg,data.type); -- 奖励形式
	Proto.writeQWORD(msg,data.cashFrom); -- 奖励来源
	Proto.writeDWORD(msg,data.cashTo); -- 道具获得者
	Proto.writeBYTE(msg,data.isIncrease); -- 是否增长
	Proto.writeDWORD(msg,data.number); -- 变化的数量
end

function Proto.parseTradeStatData(entry)
	local data={};
	data.state=Proto.parseBYTE(entry); -- 奖励状态
	data.itemType=Proto.parseDWORD(entry); -- 道具类型
	data.itemFrom=Proto.parseDWORD(entry); -- 道具来源
	data.itemTo=Proto.parseDWORD(entry); -- 道具获得者
	data.number=Proto.parseWORD(entry); -- 变化的数量
	return data;
end

function Proto.writeTradeStatData(msg,data)
	Proto.writeBYTE(msg,data.state); -- 奖励状态
	Proto.writeDWORD(msg,data.itemType); -- 道具类型
	Proto.writeDWORD(msg,data.itemFrom); -- 道具来源
	Proto.writeDWORD(msg,data.itemTo); -- 道具获得者
	Proto.writeWORD(msg,data.number); -- 变化的数量
end

function Proto.parseAwardStatData(entry)
	local data={};
	data.state=Proto.parseBYTE(entry); -- 奖励状态
	data.type=Proto.parseBYTE(entry); -- 奖励形式
	data.itemFrom=Proto.parseQWORD(entry); -- 奖励来源
	data.ownerType=Proto.parseBYTE(entry); -- 奖励获得者类型
	data.itemTo=Proto.parseQWORD(entry); -- 奖励获得者
	data.number=Proto.parseWORD(entry); -- 变化的数量
	return data;
end

function Proto.writeAwardStatData(msg,data)
	Proto.writeBYTE(msg,data.state); -- 奖励状态
	Proto.writeBYTE(msg,data.type); -- 奖励形式
	Proto.writeQWORD(msg,data.itemFrom); -- 奖励来源
	Proto.writeBYTE(msg,data.ownerType); -- 奖励获得者类型
	Proto.writeQWORD(msg,data.itemTo); -- 奖励获得者
	Proto.writeWORD(msg,data.number); -- 变化的数量
end

