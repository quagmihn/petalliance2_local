-- Net.Proto.Proto_AiRule_Types

Proto.AROT_PET	= 0						-- [AI规则所有者类型]宠物
Proto.AROT_NPC	= Proto.AROT_PET + 1	-- [AI规则所有者类型]NPC

function Proto.parseAiRuleItem(entry)
	local data={};
	data.item=Proto.parseDWORD(entry); -- 道具
	data.data=Proto.parseAiRuleParam(entry); -- 数据
	return data;
end

function Proto.writeAiRuleItem(msg,data)
	Proto.writeDWORD(msg,data.item); -- 道具
	Proto.writeAiRuleParam(msg,data.data); -- 数据
end

function Proto.parseAiRuleObjectQualifier(entry)
	local data={};
	data.index=Proto.parseBYTE(entry); -- 索引
	data.qualifier=Proto.parseAiRuleItem(entry); -- 限定道具
	return data;
end

function Proto.writeAiRuleObjectQualifier(msg,data)
	Proto.writeBYTE(msg,data.index); -- 索引
	Proto.writeAiRuleItem(msg,data.qualifier); -- 限定道具
end

function Proto.parseAiRuleUnit(entry)
	local data={};
	data.object=Proto.parseAiRuleItem(entry); -- 对象条件
	data.action=Proto.parseAiRuleItem(entry); -- 动作条件
	data.qualifiers=Proto.parseVarArray(entry,Proto.parseAiRuleObjectQualifier,Proto.parseWORD); -- 目标限定
	return data;
end

function Proto.writeAiRuleUnit(msg,data)
	Proto.writeAiRuleItem(msg,data.object); -- 对象条件
	Proto.writeAiRuleItem(msg,data.action); -- 动作条件
	Proto.writeVarArray(msg,data.qualifiers,Proto.writeAiRuleObjectQualifier,Proto.writeWORD); -- 目标限定
end

function Proto.parseAiRule(entry)
	local data={};
	data.index=Proto.parseBYTE(entry); -- 索引
	data.on=Proto.parseBYTE(entry); -- 是否有效(0:关 1:开)
	data.aiRuleUnit=Proto.parseAiRuleUnit(entry); -- AI规则
	return data;
end

function Proto.writeAiRule(msg,data)
	Proto.writeBYTE(msg,data.index); -- 索引
	Proto.writeBYTE(msg,data.on); -- 是否有效(0:关 1:开)
	Proto.writeAiRuleUnit(msg,data.aiRuleUnit); -- AI规则
end

function Proto.parseAiRuleInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- ID
	data.name=Proto.parseString(entry); -- 规则名称
	data.aiRuleUnit=Proto.parseAiRuleUnit(entry); -- AI规则
	return data;
end

function Proto.getAiRuleInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeAiRuleInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- ID
	Proto.writeString(msg,data.name); -- 规则名称
	Proto.writeAiRuleUnit(msg,data.aiRuleUnit); -- AI规则
end

function Proto.parseAiRuleOwner(entry)
	local data={};
	data.type=Proto.parseBYTE(entry); -- 类型
	data.id=Proto.parseDWORD(entry); -- 相关类型ID
	return data;
end

function Proto.getAiRuleOwnerIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeAiRuleOwner(msg,data)
	Proto.writeBYTE(msg,data.type); -- 类型
	Proto.writeDWORD(msg,data.id); -- 相关类型ID
end

function Proto.parseAiRuleItemInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 道具类型
	data.param=Proto.parseAiRuleItemParam(entry); -- 规则参数
	data.script=Proto.parseAiRuleItemScript(entry); -- 规则脚本
	return data;
end

function Proto.getAiRuleItemInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeAiRuleItemInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 道具类型
	Proto.writeAiRuleItemParam(msg,data.param); -- 规则参数
	Proto.writeAiRuleItemScript(msg,data.script); -- 规则脚本
end

