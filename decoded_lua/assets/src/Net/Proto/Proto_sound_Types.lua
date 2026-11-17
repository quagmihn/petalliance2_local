-- Net.Proto.Proto_sound_Types

function Proto.parseSoundEffectInfo(entry)
	local data={};
	data.id=Proto.parseDWORD(entry); -- 编号
	data.type=Proto.parseString(entry); -- 类型
	data.loadBefore=Proto.parseString(entry); -- 游戏前加载
	data.path=Proto.parseString(entry); -- 路径
	data.soundType=Proto.parseString(entry); -- 音乐音效
	return data;
end

function Proto.getSoundEffectInfoIDLen()
	return Proto.getDWORDLen();
end

function Proto.writeSoundEffectInfo(msg,data)
	Proto.writeDWORD(msg,data.id); -- 编号
	Proto.writeString(msg,data.type); -- 类型
	Proto.writeString(msg,data.loadBefore); -- 游戏前加载
	Proto.writeString(msg,data.path); -- 路径
	Proto.writeString(msg,data.soundType); -- 音乐音效
end

