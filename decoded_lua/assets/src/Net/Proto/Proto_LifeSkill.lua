-- Net.Proto.Proto_LifeSkill

function Proto.writeP_CG_GetLifeSkillData_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_GETLIFESKILLDATA_REQ);
end

function Proto.parseP_GC_GetLifeSkillData_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_GETLIFESKILLDATA_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code==Proto.Error.ERROR_OK) then
		data.lifeSkillData=Proto.parseString(entry); -- 角色生活技能信息
	end
	return data;
end

function Proto.writeP_CG_ChangeLifeCareer_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_CHANGELIFECAREER_REQ);
	Proto.writeBYTE(msg,data.career); -- 新职业
end

function Proto.parseP_GC_ChangeLifeCareer_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_CHANGELIFECAREER_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code==Proto.Error.ERROR_OK) then
		data.lifeSkillData=Proto.parseString(entry); -- 生活信息
	end
	return data;
end

function Proto.writeP_CG_Manufacture_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_MANUFACTURE_REQ);
	Proto.writeDWORD(msg,data.drawingID); -- 配方ID
	Proto.writeDWORD(msg,data.count); -- 制作数量
end

function Proto.parseP_GC_Manufacture_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_MANUFACTURE_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code==Proto.Error.ERROR_OK) then
		data.lifeSkillData=Proto.parseString(entry); -- 生活信息
	end
	return data;
end

function Proto.parseP_GC_LifeSkillUpdate_Ntf(entry)
	local data={};
	data.msgID=Proto.Command.GC_LIFESKILLUPDATE_NTF;
	data.lifeSkillData=Proto.parseString(entry); -- 角色生活技能信息
	return data;
end

function Proto.writeP_CG_UnlockLifeSkill_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_UNLOCKLIFESKILL_REQ);
	Proto.writeBYTE(msg,data.career); -- 初始生活职业
end

function Proto.parseP_GC_UnlockLifeSkill_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_UNLOCKLIFESKILL_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	if (data.code==Proto.Error.ERROR_OK) then
		data.lifeSkillData=Proto.parseString(entry); -- 生活信息
	end
	return data;
end

function Proto.writeP_CG_BuyDrawings_Req(msg,data)
	Proto.writeWORD(msg,Proto.Command.CG_BUYDRAWINGS_REQ);
	Proto.writeDWORD(msg,data.drawingID); -- 图纸ID
end

function Proto.parseP_GC_BuyDrawings_Ack(entry)
	local data={};
	data.msgID=Proto.Command.GC_BUYDRAWINGS_ACK;
	data.code=Proto.parseWORD(entry); -- 返回码
	return data;
end

