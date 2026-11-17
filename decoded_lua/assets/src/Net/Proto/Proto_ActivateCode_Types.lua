-- Net.Proto.Proto_ActivateCode_Types

function Proto.parseActivateCodeInfo(entry)
	local data={};
	data.id=Proto.parseint(entry); -- 类型
	data.name=Proto.parsestring(entry); -- 名称
	data.group=Proto.parseint(entry); -- 共享组
	data.awardID=Proto.parseint(entry); -- 奖励
	data.channel=Proto.parsebool(entry); -- 限定渠道
	data.unlimited=Proto.parsebool(entry); -- 不限数量
	return data;
end

function Proto.getActivateCodeInfoIDLen()
	return Proto.getintLen();
end

function Proto.writeActivateCodeInfo(msg,data)
	Proto.writeint(msg,data.id); -- 类型
	Proto.writestring(msg,data.name); -- 名称
	Proto.writeint(msg,data.group); -- 共享组
	Proto.writeint(msg,data.awardID); -- 奖励
	Proto.writebool(msg,data.channel); -- 限定渠道
	Proto.writebool(msg,data.unlimited); -- 不限数量
end

function Proto.parseActivateCodeGroupInfo(entry)
	local data={};
	data.id=Proto.parseint(entry); -- ID
	data.maxCount=Proto.parseint(entry); -- 最大激活数量
	return data;
end

function Proto.getActivateCodeGroupInfoIDLen()
	return Proto.getintLen();
end

function Proto.writeActivateCodeGroupInfo(msg,data)
	Proto.writeint(msg,data.id); -- ID
	Proto.writeint(msg,data.maxCount); -- 最大激活数量
end

function Proto.parseActivateCodeChannelInfo(entry)
	local data={};
	data.id=Proto.parseint(entry); -- ID
	data.code=Proto.parsestring(entry); -- 编码
	data.desc=Proto.parsestring(entry); -- 描述
	return data;
end

function Proto.getActivateCodeChannelInfoIDLen()
	return Proto.getintLen();
end

function Proto.writeActivateCodeChannelInfo(msg,data)
	Proto.writeint(msg,data.id); -- ID
	Proto.writestring(msg,data.code); -- 编码
	Proto.writestring(msg,data.desc); -- 描述
end

