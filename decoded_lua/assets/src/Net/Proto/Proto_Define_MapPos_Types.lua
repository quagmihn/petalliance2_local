-- Net.Proto.Proto_Define_MapPos_Types

function Proto.parseMapPos(entry)
	local data={};
	data.map=Proto.parseMapID(entry); -- 地图ID
	data.pos=Proto.parsePOS2D(entry); -- 位置
	return data;
end

function Proto.writeMapPos(msg,data)
	Proto.writeMapID(msg,data.map); -- 地图ID
	Proto.writePOS2D(msg,data.pos); -- 位置
end

