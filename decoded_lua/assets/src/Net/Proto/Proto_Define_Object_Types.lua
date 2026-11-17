-- Net.Proto.Proto_Define_Object_Types

Proto.ORT_NONE			= 0								-- [目标角色类型]当前上下文
Proto.ORT_PIONEERBEGPET	= Proto.ORT_NONE + 1			-- [目标角色类型]首发宠物袋宠物
Proto.ORT_HANDLE		= Proto.ORT_PIONEERBEGPET + 1	-- [目标角色类型]句柄类型
Proto.ORT_PETID			= Proto.ORT_HANDLE + 1			-- [目标角色类型]宠物ID

function Proto.parseObjectRoleDescription(entry)
	local data={};
	data.type=Proto.parseBYTE(entry); -- 目标角色类型
	data.body={}; -- 内容
	if (data.type ==Proto.ORT_HANDLE) then
		data.body.roleHandle=Proto.parseRoleHandle(entry); -- 
	end
	if (data.type ==Proto.ORT_PETID) then
		data.body.petID=Proto.parseDWORD(entry); -- 
	end
	return data;
end

function Proto.writeObjectRoleDescription(msg,data)
	Proto.writeBYTE(msg,data.type); -- 目标角色类型
	if (data.type ==Proto.ORT_HANDLE) then
		Proto.writeRoleHandle(msg,data.body.roleHandle); -- 
	end
	if (data.type ==Proto.ORT_PETID) then
		Proto.writeDWORD(msg,data.body.petID); -- 
	end
end

function Proto.parseRoleAttachObject(entry)
	local data={};
	data.isInBagPet=Proto.parseBYTE(entry); -- 是否是袋中宠物
	if (data.isInBagPet ~=0) then
		data.inBagPetID=Proto.parseDWORD(entry); -- 袋中宠物ID
	end
	return data;
end

function Proto.writeRoleAttachObject(msg,data)
	Proto.writeBYTE(msg,data.isInBagPet); -- 是否是袋中宠物
	if (data.isInBagPet ~=0) then
		Proto.writeDWORD(msg,data.inBagPetID); -- 袋中宠物ID
	end
end

