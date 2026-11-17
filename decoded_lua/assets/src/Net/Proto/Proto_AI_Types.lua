-- Net.Proto.Proto_AI_Types

Proto.AL_NORMAL			= 0								-- [AI登出时状态]正常登出
Proto.AL_ADMINISTRATOR	= Proto.AL_NORMAL + 1			-- [AI登出时状态]管理员关闭
Proto.AL_SCRIPTERROR	= Proto.AL_ADMINISTRATOR + 1	-- [AI登出时状态]脚本错误
Proto.AM_IDLE	= 0						-- [AI模式]休闲模式
Proto.AM_CHEF	= Proto.AM_IDLE + 1		-- [AI模式]厨师模式
Proto.AM_CUSTOM	= Proto.AM_CHEF + 1		-- [AI模式]自定义
Proto.AM_COUNT	= Proto.AM_CUSTOM + 1	-- [AI模式]模式计数

function Proto.parsePetAIBaseInfo(entry)
	local data={};
	data.id=Proto.parsePetID(entry); -- 宠物ID
	data.name=Proto.parseLifeNick(entry); -- 宠物名称
	data.raceType=Proto.parseDWORD(entry); -- 种族
	data.mode=Proto.parseBYTE(entry); -- AI模式(AIMode)
	return data;
end

function Proto.getPetAIBaseInfoIDLen()
	return Proto.getPetIDLen();
end

function Proto.writePetAIBaseInfo(msg,data)
	Proto.writePetID(msg,data.id); -- 宠物ID
	Proto.writeLifeNick(msg,data.name); -- 宠物名称
	Proto.writeDWORD(msg,data.raceType); -- 种族
	Proto.writeBYTE(msg,data.mode); -- AI模式(AIMode)
end

function Proto.parseNpcAIBaseInfo(entry)
	local data={};
	data.id=Proto.parseNpcID(entry); -- NPC ID
	data.name=Proto.parseLifeNick(entry); -- NPC 名称
	data.mode=Proto.parseBYTE(entry); -- AI模式(AIMode)
	return data;
end

function Proto.getNpcAIBaseInfoIDLen()
	return Proto.getNpcIDLen();
end

function Proto.writeNpcAIBaseInfo(msg,data)
	Proto.writeNpcID(msg,data.id); -- NPC ID
	Proto.writeLifeNick(msg,data.name); -- NPC 名称
	Proto.writeBYTE(msg,data.mode); -- AI模式(AIMode)
end

