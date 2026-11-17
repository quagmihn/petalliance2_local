-- Net.Proto.Proto_Portal

function Proto.parsePlatformDeviceInfo(entry)
	local data={};
	data.id=Proto.parsestring(entry); -- 设备ID
	data.world=Proto.parsestring(entry); -- 世界
	data.token=Proto.parsestring(entry); -- 设备令牌
	return data;
end

function Proto.getPlatformDeviceInfoIDLen()
	return Proto.getstringLen();
end

function Proto.writePlatformDeviceInfo(msg,data)
	Proto.writestring(msg,data.id); -- 设备ID
	Proto.writestring(msg,data.world); -- 世界
	Proto.writestring(msg,data.token); -- 设备令牌
end

function Proto.writeP_CG_PlatformLogin_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_PLATFORMLOGIN_REQ);
	Proto.writestring(msg,data.username); -- 账号
	Proto.writestring(msg,data.token); -- 令牌
end

function Proto.parseP_GC_PlatformLogin_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_PLATFORMLOGIN_ACK;
	data.code=Proto.parseCode(entry); -- 返回码
	if (data.code.value==Proto.Error.ERROR_OK) then
		data.devices=Proto.parseVector(entry,Proto.parsePlatformDeviceInfo); -- 设备列表
	end
	return data;
end

function Proto.writeP_CG_DeviceLogin_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_DEVICELOGIN_REQ);
	Proto.writestring(msg,data.id); -- 设备ID
	Proto.writestring(msg,data.world); -- 世界
	Proto.writestring(msg,data.token); -- 设备令牌
end

function Proto.parseP_GC_DeviceLogin_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_DEVICELOGIN_ACK;
	data.code=Proto.parseCode(entry); -- 返回码
	if (data.code.value==Proto.Error.ERROR_OK) then
		data.roleID=Proto.parseint(entry); -- 角色ID,如果角色不存在roleID等于0
		data.serverTime=Proto.parseQWORD(entry); -- 
		data.serverTimeZone=Proto.parseint(entry); -- 时区秒数 (例 +8时区为8*3600) 
		data.userToken=Proto.parsestring(entry); -- 角色令牌
	end
	if (data.code.value==Proto.Error.ERROR_OK and data.roleID~=0) then
		data.baseInfo=Proto.parseCharBaseInfo(entry); -- 基本信息
	end
	return data;
end

function Proto.writeP_CG_DeviceBind_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_DEVICEBIND_REQ);
	Proto.writestring(msg,data.id); -- 设备ID
	Proto.writestring(msg,data.world); -- 世界
	Proto.writestring(msg,data.token); -- 设备令牌
end

function Proto.parseP_GC_DeviceBind_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_DEVICEBIND_ACK;
	data.code=Proto.parseCode(entry); -- 返回码
	return data;
end

function Proto.writeP_CG_DeviceRelogin_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_DEVICERELOGIN_REQ);
	Proto.writeint(msg,data.userID); -- 角色ID
	Proto.writestring(msg,data.userToken); -- 角色令牌
end

function Proto.parseP_GC_DeviceRelogin_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_DEVICERELOGIN_ACK;
	data.code=Proto.parseCode(entry); -- 返回码
	if (data.code.value==Proto.Error.ERROR_OK) then
		data.roleID=Proto.parseint(entry); -- 角色ID,如果角色不存在roleID等于0
	end
	if (data.code.value==Proto.Error.ERROR_OK and data.roleID~=0) then
		data.baseInfo=Proto.parseCharBaseInfo(entry); -- 基本信息
	end
	return data;
end

